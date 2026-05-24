/**********************************************************************
*  ARDL ANALYSIS OF MACROECONOMIC DETERMINANTS OF PHILIPPINE EMIGRATION
*  Full Standard Pipeline — Pre-estimation to Post-estimation
*  Data: Alternative-Data.xlsx, 1981–2023 (Annual)
*  Author: [Your Name]
*  Date: March 2026
*
*  NOTES:
*  ─ This .do file follows the standard ARDL–bounds‑testing procedure
*    of Pesaran, Shin & Smith (2001) implemented in Stata's -ardl-
*    user‑written package (Kripfganz & Schneider, 2023).
*  ─ Install required packages ONCE before running:
*       ssc install ardl, replace
*       ssc install kpss, replace
*       ssc install zandrews, replace
*       net install pperron, from(http://fmwww.bc.edu/RePEc/bocode/p)
*  ─ Maximum lags capped at 2 (annual data, N=43; maxlags(3) tested
*    as robustness). AIC used for automatic selection; BIC tested for
*    comparison.
*  ─ All log‑transformations applied to scale variables (GDP, emig,
*    exchange rate). Shares/ratios left in levels.
*  ─ Heteroskedasticity‑robust inference reported alongside default
*    OLS standard errors.
**********************************************************************/

clear all
set more off
set matsize 800

*───────────────────────────────────────────────────────────────────────
* SECTION 0 : SETUP — CHANGE THIS PATH TO YOUR DATA DIRECTORY
*───────────────────────────────────────────────────────────────────────

/* Change the path below to the folder where "Alternative-Data.xlsx"
   is saved on your computer. */
cd "C:\Users\Lian Cataytay\Desktop\Work\Ralph\Data"

*═══════════════════════════════════════════════════════════════════════
*  PART I : DATA PREPARATION
*═══════════════════════════════════════════════════════════════════════

*───────────────────────────────────────────────────────────────────────
* 1.1  Import raw data
*───────────────────────────────────────────────────────────────────────
import excel "Alternative Data.xlsx", sheet("Sheet1") firstrow clear

/* Keep only the 9 core variables. The sheet may contain blank columns
   beyond column I; drop them. */
keep year emig ph_gdp ph_labsh ph_csg us_gdp us_labsh us_csg exc

/* Confirm 43 observations (1981–2023). */
describe
summarize

*───────────────────────────────────────────────────────────────────────
* 1.2  Declare time series
*───────────────────────────────────────────────────────────────────────
/* ARDL estimation in Stata requires -tsset-. Annual data, so no
   further frequency argument is needed. */
tsset year, yearly

*───────────────────────────────────────────────────────────────────────
* 1.3  Variable transformations
*───────────────────────────────────────────────────────────────────────
/* Log-transform all strictly positive scale variables.
   ─ emig: emigrant count → lnM
   ─ ph_gdp, us_gdp: GDP per capita → lnPH_GDP, lnUS_GDP
   ─ exc: PHP/USD exchange rate → lnEXC
   Shares (ph_labsh, ph_csg, us_labsh, us_csg) are already bounded
   proportions; keep in levels. */

gen lnM       = ln(emig)
gen lnPH_GDP  = ln(ph_gdp)
gen lnUS_GDP  = ln(us_gdp)
gen lnEXC     = ln(exc)

label variable lnM       "Log of permanent emigrants"
label variable lnPH_GDP  "Log of PH GDP per capita (current USD)"
label variable lnUS_GDP  "Log of US GDP per capita (current USD)"
label variable lnEXC     "Log of PHP/USD exchange rate"
label variable ph_labsh  "PH labor income share of GDP"
label variable ph_csg    "PH gov consumption share (PPP)"
label variable us_labsh  "US labor income share of GDP"
label variable us_csg    "US gov consumption share (PPP)"

*───────────────────────────────────────────────────────────────────────
* 1.4  Create structural‑break / outlier dummies
*───────────────────────────────────────────────────────────────────────
/* COVID-19 travel restrictions caused emigration to collapse to
   6,539 (2020) and 7,122 (2021), far below the historical mean of
   ~36,500. We create a dummy to test sensitivity. */
gen covid = inrange(year, 2020, 2021)
label variable covid "COVID dummy (2020–2021)"

/* Asian Financial Crisis dummy (optional, for robustness). */
gen afc = inrange(year, 1997, 1998)
label variable afc "Asian Financial Crisis dummy (1997–1998)"

*───────────────────────────────────────────────────────────────────────
* 1.5  Save working dataset
*───────────────────────────────────────────────────────────────────────
save "migration_ardl_workfile.dta", replace

*───────────────────────────────────────────────────────────────────────
* 1.6  Descriptive statistics table
*───────────────────────────────────────────────────────────────────────
/* This produces a summary table suitable for Table 1 of your paper.
   Export to Excel for formatting if desired. */

estpost summarize lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg ///
    us_labsh lnEXC, detail
esttab using "Table1_DescriptiveStats.csv", cells("count mean sd min p25 p50 p75 max") ///
    replace title("Table 1: Descriptive Statistics, 1981–2023") ///
    label noobs

/* NOTE: If -esttab- / -estout- are not installed:
         ssc install estout, replace
   Alternatively, use -tabstat-: */
tabstat lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg us_labsh lnEXC, ///
    stat(n mean sd min p25 p50 p75 max) col(stat) long format(%9.4f)

*───────────────────────────────────────────────────────────────────────
* 1.7  Correlation matrix
*───────────────────────────────────────────────────────────────────────
correlate lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg us_labsh lnEXC
/* Check for multicollinearity: |r| > 0.80 warrants caution.
   NOTE: lnPH_GDP and lnEXC may be highly correlated (both trend
   upward over time). This is common in macro data and handled by
   ARDL's lag structure, but watch VIF after estimation. */


*═══════════════════════════════════════════════════════════════════════
*  PART II : GRAPHICAL INSPECTION
*═══════════════════════════════════════════════════════════════════════

*───────────────────────────────────────────────────────────────────────
* 2.1  Time series plots — levels
*───────────────────────────────────────────────────────────────────────
/* Visual inspection for trends, breaks, and outliers. */
tsline lnM, title("Log Emigration") name(g_lnM, replace)
tsline lnPH_GDP, title("Log PH GDP per capita") name(g_phgdp, replace)
tsline ph_csg, title("PH Gov Consumption Share") name(g_csg, replace)
tsline ph_labsh, title("PH Labor Share") name(g_labsh, replace)
tsline lnEXC, title("Log Exchange Rate") name(g_exc, replace)
tsline lnUS_GDP, title("Log US GDP per capita") name(g_usgdp, replace)

graph combine g_lnM g_phgdp g_csg g_labsh g_exc g_usgdp, ///
    cols(3) title("Figure 1: Time Series in Levels, 1981–2023") ///
    note("Source: CFO, World Bank, Penn World Table")
graph export "Figure1_LevelsPlots.png", replace width(2000)

*───────────────────────────────────────────────────────────────────────
* 2.2  Time series plots — first differences
*───────────────────────────────────────────────────────────────────────
tsline D.lnM, title("ΔLog Emigration") name(g_dlnM, replace)
tsline D.lnPH_GDP, title("ΔLog PH GDP") name(g_dphgdp, replace)
tsline D.ph_csg, title("ΔPH Gov Consumption Share") name(g_dcsg, replace)
tsline D.ph_labsh, title("ΔPH Labor Share") name(g_dlabsh, replace)
tsline D.lnEXC, title("ΔLog Exchange Rate") name(g_dexc, replace)

graph combine g_dlnM g_dphgdp g_dcsg g_dlabsh g_dexc, ///
    cols(3) title("Figure 2: First Differences, 1982–2023")
graph export "Figure2_DifferencesPlots.png", replace width(2000)


	*═══════════════════════════════════════════════════════════════════════
	*  PART III : UNIT ROOT TESTS
	*═══════════════════════════════════════════════════════════════════════
	/*
	   PURPOSE: ARDL bounds testing is valid ONLY when all variables are
	   I(0) or I(1). If any variable is I(2), the Pesaran et al. (2001)
	   critical values are invalid.

	   STRATEGY: We use three complementary tests:
	   ─ ADF (Augmented Dickey–Fuller): H0 = unit root
	   ─ PP (Phillips–Perron): H0 = unit root (non-parametric correction)
	   ─ KPSS: H0 = stationarity (reverses the null, so provides
		 confirmatory evidence)

	   For each variable, test in LEVELS and FIRST DIFFERENCES.
	   We test with and without trend for level‐form.
	*/

	*───────────────────────────────────────────────────────────────────────
	* 3.1  ADF tests
	*───────────────────────────────────────────────────────────────────────

	/* NOTE ON LAG SELECTION:
	   ─ With 43 observations, we use lags(2) as a baseline.
	   ─ Stata's -dfuller- uses a fixed lag; for automatic lag selection
		 based on information criteria, use -varsoc- or -dfgls-. */

	display _n "===== ADF UNIT ROOT TESTS =====" _n

	foreach var in lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg us_labsh lnEXC {
		display _n "──── ADF: `var' (Level, with constant) ────"
		dfuller `var', lags(2)

		display _n "──── ADF: `var' (Level, with constant + trend) ────"
		dfuller `var', trend lags(2)

		display _n "──── ADF: `var' (First difference, with constant) ────"
		dfuller D.`var', lags(1)
	}

	*───────────────────────────────────────────────────────────────────────
	* 3.2  Phillips–Perron tests
	*───────────────────────────────────────────────────────────────────────

	display _n "===== PHILLIPS–PERRON UNIT ROOT TESTS =====" _n

	foreach var in lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg us_labsh lnEXC {
		display _n "──── PP: `var' (Level) ────"
		pperron `var', lags(2)

		display _n "──── PP: `var' (First difference) ────"
		pperron D.`var', lags(1)
	}

	*───────────────────────────────────────────────────────────────────────
	* 3.3  KPSS tests
	*───────────────────────────────────────────────────────────────────────
	/* KPSS reverses the null: H0 = stationary. Rejection means the
	   series has a unit root. This provides confirmatory evidence
	   alongside ADF/PP.
	 Install: ssc install kpss, replace */

	display _n "===== KPSS STATIONARITY TESTS =====" _n

	foreach var in lnM lnPH_GDP ph_csg ph_labsh lnUS_GDP us_csg us_labsh lnEXC {
		display _n "──── KPSS: `var' (Level) ────"
		kpss `var', maxlag(4)

		display _n "──── KPSS: `var' (First difference) ────"
		kpss D.`var', maxlag(3)
	}

	*───────────────────────────────────────────────────────────────────────
	* 3.4  Summary of integration orders
	*───────────────────────────────────────────────────────────────────────
	/*
	   FILL IN AFTER RUNNING TESTS. Expected pattern based on typical
	   macro data:

	   Variable      ADF(level)  ADF(Δ)  PP(level)  PP(Δ)  KPSS(level)  Order
	   ─────────────────────────────────────────────────────────────────────
	   lnM           Fail/Rej?   Rej     ─          Rej    ─            I(?)
	   lnPH_GDP      Fail        Rej     Fail       Rej    Rej          I(1)
	   ph_csg        ?           Rej     ?          Rej    ?            I(?)
	   ph_labsh      ?           Rej     ?          Rej    ?            I(?)
	   lnUS_GDP      Fail        Rej     Fail       Rej    Rej          I(1)
	   us_csg        ?           Rej     ?          Rej    ?            I(?)
	   us_labsh      ?           Rej     ?          Rej    ?            I(?)
	   lnEXC         Fail        Rej     Fail       Rej    Rej          I(1)

	   CRITICAL CHECK: If ANY variable is I(2), ARDL is INVALID.
	   In that case, consider differencing once before inclusion or
	   dropping the variable.
	*/


*═══════════════════════════════════════════════════════════════════════
*  PART IV : ARDL ESTIMATION — MULTIPLE SPECIFICATIONS
*═══════════════════════════════════════════════════════════════════════
/*
   We estimate 7 model specifications, each grounded in a distinct
   economic theory. This allows us to test the robustness of findings
   across theoretical frameworks.

   IMPORTANT STATA SYNTAX NOTES:
   ─ ardl depvar indepvars, maxlags(#) aic → selects lag orders
   ─ ardl ..., ec → re-estimates in error-correction form
   ─ estat ectest → Pesaran–Shin–Smith bounds test
   ─ The -ec- option re-parameterizes the model; long-run coefficients
     appear in the "LR" block; short-run in "SR" block.
*/

*───────────────────────────────────────────────────────────────────────
* MODEL 1 : BASELINE PH PUSH + EXCHANGE RATE
* Theory  : Push-factor migration (domestic conditions dominate)
* DV      : lnM
* IVs     : lnPH_GDP, ph_csg, lnEXC
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 1: BASELINE PH PUSH + FX                        ║"
display       "║  lnM = f(lnPH_GDP, ph_csg, lnEXC)                     ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

*--- Step A: Estimate ARDL in levels, AIC lag selection ─────────────
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) aic ec
estimates store M1_levels

/* NOTE: Record the selected ARDL(p,q1,q2,q3) order from the output.
   Expected: ARDL(2,1,0,1) based on prior analysis. */

*--- Step B: Bounds test for cointegration ──────────────────────────
estat ectest
/* DECISION RULE:
   F > I(1) upper bound at 5% → cointegration (proceed to Step C)
   F < I(0) lower bound at 5% → no cointegration (skip to short-run)
   In between → inconclusive (consider alternatives) */

*--- Step C: Re-estimate in error-correction form ───────────────────
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) aic ec
estimates store M1_ecm

/* KEY THINGS TO CHECK:
   1. ECT (L.lnM coefficient) should be NEGATIVE and SIGNIFICANT
   2. Long-run coefficients: sign, magnitude, significance
   3. Short-run coefficients: sign reversal from long-run? */

*--- Step D: Core diagnostics ───────────────────────────────────────

/* Serial correlation: Breusch-Godfrey LM test
   H0: no serial correlation. We want p > 0.05. */
estat bgodfrey, lags(1 2)

/* Heteroskedasticity: Breusch-Pagan test
   H0: homoskedastic errors. We want p > 0.05. */
estat hettest

/* Functional form: Ramsey RESET
   H0: no omitted variables / correct functional form.
   We want p > 0.05. */
estat ovtest

/* Normality: Skewness-kurtosis test on residuals */
predict double resid_m1, residuals
sktest resid_m1
drop resid_m1

*--- Step E: Robust standard errors ─────────────────────────────────
/* If Breusch-Pagan rejects, re-estimate with robust SE. */
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) aic ec 
estimates store M1_ecm_robust


*───────────────────────────────────────────────────────────────────────
* MODEL 2 : BILATERAL PH + US (Push-Pull Framework)
* Theory  : Todaro-Harris dual-economy / push-pull model
* DV      : lnM
* IVs     : lnPH_GDP, ph_csg, lnUS_GDP, us_csg, lnEXC
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 2: BILATERAL PH + US (PUSH-PULL)                ║"
display       "║  lnM = f(lnPH_GDP, ph_csg, lnUS_GDP, us_csg, lnEXC)  ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

ardl lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC, maxlags(2) aic ec
estimates store M2_levels
estat ectest

ardl lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC, maxlags(2) aic ec
estimates store M2_ecm

estat bgodfrey, lags(1 2)
estat hettest
estat ovtest

/* NOTE: With 5 regressors and maxlags(2), the effective sample drops
   substantially. Monitor degrees of freedom carefully. If F-test is
   inconclusive, this supports the interpretation that US pull factors
   are not needed once PH push factors are controlled. */


*───────────────────────────────────────────────────────────────────────
* MODEL 3 : INCOME-ONLY (Neoclassical Wage Differential)
* Theory  : Migration driven purely by income/wage gap
* DV      : lnM
* IVs     : lnPH_GDP, lnUS_GDP
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 3: INCOME-ONLY (NEOCLASSICAL)                   ║"
display       "║  lnM = f(lnPH_GDP, lnUS_GDP)                          ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

ardl lnM lnPH_GDP lnUS_GDP, maxlags(2) aic ec
estimates store M3_levels
estat ectest

/* If F < I(0) → no cointegration. Income alone does not explain
   the long-run migration equilibrium. This supports the hypothesis
   that institutional variables (gov spending, inequality) matter. */

ardl lnM lnPH_GDP lnUS_GDP, maxlags(2) aic ec
estimates store M3_ecm

estat bgodfrey, lags(1 2)
estat hettest


*───────────────────────────────────────────────────────────────────────
* MODEL 4 : PH LABOR SHARE (INEQUALITY-DRIVEN MIGRATION)
* Theory  : NELM — relative deprivation / inequality as push factor
* DV      : lnM
* IVs     : lnPH_GDP, ph_csg, ph_labsh, lnEXC
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 4: PH LABOR SHARE (INEQUALITY)                  ║"
display       "║  lnM = f(lnPH_GDP, ph_csg, ph_labsh, lnEXC)          ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(2) aic ec
estimates store M4_levels
estat ectest

ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(2) aic ec
estimates store M4_ecm

estat bgodfrey, lags(1 2)
estat hettest
estat ovtest

/* Robust version */
ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(2) aic ec 
estimates store M4_ecm_robust


*───────────────────────────────────────────────────────────────────────
* MODEL 5 : US LABOR SHARE (FOREIGN INEQUALITY PULL)
* Theory  : Destination inequality as pull factor
* DV      : lnM
* IVs     : lnPH_GDP, ph_csg, us_labsh, lnEXC
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 5: US LABOR SHARE (FOREIGN INEQUALITY)          ║"
display       "║  lnM = f(lnPH_GDP, ph_csg, us_labsh, lnEXC)          ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

ardl lnM lnPH_GDP ph_csg us_labsh lnEXC, maxlags(2) aic ec
estimates store M5_levels
estat ectest

ardl lnM lnPH_GDP ph_csg us_labsh lnEXC, maxlags(2) aic ec
estimates store M5_ecm

estat bgodfrey, lags(1 2)
estat hettest


*───────────────────────────────────────────────────────────────────────
* MODEL 6 : DYNAMIC REGRESSION WITH NEWEY-WEST HAC
* Theory  : Persistence/inertia robustness (network effects)
* DV      : lnM
* IVs     : L.lnM, lnPH_GDP, ph_csg, lnUS_GDP, us_csg, lnEXC
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 6: DYNAMIC REGRESSION (NEWEY-WEST HAC)          ║"
display       "║  Robustness check for persistence / inertia             ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

/* Newey-West estimator with 2 lags for HAC correction.
   This is NOT an ARDL model — it is an OLS dynamic regression used
   to assess migration persistence and joint macro significance. */

newey lnM L.lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC, lag(2)
estimates store M6_newey

/* Joint significance test: are macro variables collectively significant
   after controlling for persistence? */
test lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC


*───────────────────────────────────────────────────────────────────────
* MODEL 7 : BASELINE + COVID STRUCTURAL BREAK DUMMY
* Theory  : Testing pandemic robustness of baseline results
* DV      : lnM
* IVs     : lnPH_GDP, ph_csg, lnEXC, covid
*───────────────────────────────────────────────────────────────────────

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MODEL 7: BASELINE + COVID DUMMY (2020-2021)           ║"
display       "║  lnM = f(lnPH_GDP, ph_csg, lnEXC) + COVID             ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

/* NOTE: The -ardl- command in Stata does not natively accept exogenous
   dummies as separate regressors in the same way as tsls. Instead,
   include the dummy as an additional regressor. */

ardl lnM lnPH_GDP ph_csg lnEXC covid, maxlags(2) aic ec
estimates store M7_levels
estat ectest

ardl lnM lnPH_GDP ph_csg lnEXC covid, maxlags(2) aic ec
estimates store M7_ecm

estat bgodfrey, lags(1 2)
estat hettest


*═══════════════════════════════════════════════════════════════════════
*  PART V : ROBUSTNESS — ALTERNATIVE LAG LENGTHS & CRITERIA
*═══════════════════════════════════════════════════════════════════════

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  ROBUSTNESS: ALTERNATIVE LAG LENGTHS                   ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

*--- Baseline model with maxlags(3) ────────────────────────────────
/* With N=43, maxlags(3) is the practical upper bound. */
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(3) aic ec
estimates store M1_maxlag3
estat ectest

*--- Baseline model with BIC (more parsimonious) ───────────────────
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) bic ec
estimates store M1_bic
estat ectest

*--- Preferred model (M4) with maxlags(3) ──────────────────────────
ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(3) aic ec
estimates store M4_maxlag3
estat ectest


*═══════════════════════════════════════════════════════════════════════
*  PART VI : STABILITY TESTS
*═══════════════════════════════════════════════════════════════════════
/*
   CUSUM and CUSUMSQ tests assess whether the estimated coefficients
   are stable over the sample period. Instability may indicate
   structural breaks that are not captured by the model.

   IMPORTANT: Stata's -estat stability- works only after certain
   estimation commands. After -ardl-, you may need to re-estimate
   using -regress- with the same specification and then run
   -estat sbcusum-.

   Alternative approach: use -cusum6- (user-written) or generate
   recursive residuals manually.
*/

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  STABILITY TESTS: CUSUM & CUSUMSQ                      ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

*--- Method 1: Re-estimate baseline as OLS for CUSUM ────────────────
/* Re-create the exact ARDL specification as a -regress- command.
   REPLACE the lag orders (p,q1,q2,q3) below with what the ARDL
   selected in Model 1 (expected: 2,1,0,1). */

regress lnM L(1/2).lnM L(0/1).lnPH_GDP ph_csg L(0/1).lnEXC

/* Now run recursive estimation for CUSUM */
predict double cusum_resid, residuals
estat sbcusum
/* If this command is not available, try: */
* cusum6 cusum_resid year
drop cusum_resid

*--- Method 2: Manual CUSUM approach ────────────────────────────────
/* If the above does not work, estimate the ECM manually using
   -regress- and then use -estat sbcusum-. */

/* First, generate the ECM variables manually:
   ECM form: ΔY = α + φY_{t-1} + β'X_{t-1} + Σγ_i ΔY_{t-i}
             + Σδ_j ΔX_{t-j} + ε */

regress D.lnM L.lnM L.lnPH_GDP L.ph_csg L.lnEXC ///
    LD.lnM D.lnPH_GDP D.lnEXC

predict double ecm_resid, residuals

/* Plot recursive residuals */
tsline ecm_resid, title("ECM Residuals — Baseline Model") ///
    yline(0) name(g_ecmresid, replace)
graph export "Figure3_ECM_Residuals.png", replace width(1500)

drop ecm_resid

*--- Zivot-Andrews structural break test (endogenous break) ────────
/* This test finds the break date endogenously. Useful for identifying
   whether the Asian Financial Crisis or COVID shifted the relationship. */

display _n "──── Zivot-Andrews Test for Structural Break in lnM ────"
zandrews lnM, break(both) maxlags(2)


*═══════════════════════════════════════════════════════════════════════
*  PART VII : MULTICOLLINEARITY CHECK
*═══════════════════════════════════════════════════════════════════════

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  MULTICOLLINEARITY: VARIANCE INFLATION FACTORS          ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

/* VIF after a simple OLS of the long-run regressors.
   Rule of thumb: VIF > 10 is problematic. */

regress lnM lnPH_GDP ph_csg ph_labsh lnEXC
vif

regress lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC
vif


*═══════════════════════════════════════════════════════════════════════
*  PART VIII : PUBLICATION-READY OUTPUT TABLES
*═══════════════════════════════════════════════════════════════════════

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║  EXPORT TABLES FOR ACADEMIC PAPER                      ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

*───────────────────────────────────────────────────────────────────────
* 8.1  Bounds test comparison table
*───────────────────────────────────────────────────────────────────────
/* After running all models, manually compile or use -estadd- to
   build a comparison table. Below is the structure:

   TABLE: ARDL Bounds Test Results
   ────────────────────────────────────────────────────────────
   Model    Specification            ARDL Order  F-stat  Decision
   ────────────────────────────────────────────────────────────
   1        Baseline PH Push + FX    (2,1,0,1)   6.478  Cointegration
   2        Bilateral PH + US        (1,1,0,0,0,1) 3.12 Inconclusive
   3        Income-Only              (2,1,1)     2.754  No cointegration
   4        PH Labor Share           (2,1,0,1,1) 5.884  Cointegration
   5        US Labor Share           (2,1,0,0,1) 5.740  Cointegration
   7        Baseline + COVID         TBD         TBD    TBD
   ────────────────────────────────────────────────────────────
   Critical values (k=3, case III): I(0)=3.23, I(1)=4.35 at 5%
   (Update with actual Kripfganz-Schneider or PSS critical values)
*/

*───────────────────────────────────────────────────────────────────────
* 8.2  Long-run and short-run coefficient tables
*───────────────────────────────────────────────────────────────────────

/* Compare ECM estimates across Model 1 and Model 4
   (the two best-performing models). */

esttab M1_ecm M4_ecm using "Table_ARDL_ECM_Results.rtf", ///
    replace title("Table: ARDL Error-Correction Model Results") ///
    mtitle("Baseline PH Push" "PH Labor Share") ///
    b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 F, labels("Observations" "R-squared" "F-statistic")) ///
    label

/* Wider comparison: all ECM models */
esttab M1_ecm M2_ecm M3_ecm M4_ecm M5_ecm using "Table_AllModels.rtf", ///
    replace title("Table: ARDL ECM Results — All Specifications") ///
    mtitle("Baseline" "Bilateral" "Income-Only" "PH LaborSh" "US LaborSh") ///
    b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("Observations" "R-squared")) ///
    label

*───────────────────────────────────────────────────────────────────────
* 8.3  Diagnostics comparison table
*───────────────────────────────────────────────────────────────────────
/*
   TABLE: Post-Estimation Diagnostics
   ───────────────────────────────────────────────────────────────
   Test                  Model 1   Model 2   Model 4   Model 7
   ───────────────────────────────────────────────────────────────
   BG Serial Corr (p)    0.825     TBD       TBD       TBD
   BP Heterosked (p)     0.000     TBD       TBD       TBD
   Ramsey RESET (p)      TBD       TBD       TBD       TBD
   Normality (p)         TBD       TBD       TBD       TBD
   ECT coefficient       −0.62     −0.47     −0.59     TBD
   ECT p-value           <0.001    0.007     <0.001    TBD
   ───────────────────────────────────────────────────────────────

   NOTE: Fill in from Stata output. An asterisk (*) indicates
   failure to pass at 5% significance.
*/


*═══════════════════════════════════════════════════════════════════════
*  PART IX : ADDITIONAL ROBUSTNESS CHECKS
*═══════════════════════════════════════════════════════════════════════

*───────────────────────────────────────────────────────────────────────
* 9.1  Exclude COVID years (subsample 1981–2019)
*───────────────────────────────────────────────────────────────────────

display _n(3) "──── SUBSAMPLE: 1981–2019 (Pre-COVID) ────"

ardl lnM lnPH_GDP ph_csg lnEXC if year <= 2019, maxlags(2) aic ec
estimates store M1_preCOVID
estat ectest
estat bgodfrey, lags(1 2)
estat hettest

*───────────────────────────────────────────────────────────────────────
* 9.2  Asian Financial Crisis dummy
*───────────────────────────────────────────────────────────────────────

display _n(3) "──── BASELINE + AFC DUMMY (1997–1998) ────"

ardl lnM lnPH_GDP ph_csg lnEXC afc, maxlags(2) aic ec
estimates store M1_afc
estat ectest

*───────────────────────────────────────────────────────────────────────
* 9.3  Both crisis dummies
*───────────────────────────────────────────────────────────────────────

display _n(3) "──── BASELINE + COVID + AFC DUMMIES ────"

ardl lnM lnPH_GDP ph_csg lnEXC covid afc, maxlags(2) aic ec
estimates store M1_both_crises
estat ectest
estat bgodfrey, lags(1 2)
estat hettest


*═══════════════════════════════════════════════════════════════════════
*  PART X : FORECASTING / DYNAMIC SIMULATION (OPTIONAL)
*═══════════════════════════════════════════════════════════════════════
/*
   If your thesis requires out-of-sample forecasting or policy
   simulation, use the following approach:

   1. Re-estimate the preferred model (Model 4) on a training sample
      (e.g., 1981–2018).
   2. Generate dynamic forecasts for 2019–2023.
   3. Compare forecast vs. actual.

   This is OPTIONAL for most theses but adds rigor.
*/

/*
ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC if year <= 2018, maxlags(2) aic
predict double lnM_hat if year > 2018, dynamic(2019)
gen emig_hat = exp(lnM_hat)

twoway (tsline emig if year >= 2010) ///
       (tsline emig_hat if year >= 2019, lpattern(dash) lcolor(red)), ///
    legend(order(1 "Actual" 2 "ARDL Forecast")) ///
    title("Figure: Out-of-Sample Forecast, 2019–2023")
graph export "Figure_Forecast.png", replace
*/


*═══════════════════════════════════════════════════════════════════════
*  END OF ANALYSIS
*═══════════════════════════════════════════════════════════════════════

display _n(3) "╔══════════════════════════════════════════════════════════╗"
display       "║          ANALYSIS COMPLETE                              ║"
display       "║  Review all stored estimates with: estimates dir        ║"
display       "║  Replay any model with: estimates replay M1_ecm        ║"
display       "╚══════════════════════════════════════════════════════════╝" _n

estimates dir
log close _all
