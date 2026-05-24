*==========================================================
* ARDL ESTIMATION + DIAGNOSTICS FOR ALL MODELS
*==========================================================

* Make sure data are tsset, e.g.:
* tsset year

*----------------------------------------------------------
* MODEL 1: BASELINE PH PUSH + EXCHANGE RATE
*----------------------------------------------------------

* AIC-based ARDL with ECM (preferred, ARDL(2,1,0,1))
ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) aic ec
estimates store M1levels

* Bounds test
estat ectest

*----------------------------------------------------------
* MODEL 2: BILATERAL PH–US (PUSH–PULL)
* lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC
*----------------------------------------------------------

ardl lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC, maxlags(2) aic ec
estimates store M2levels

estat ectest

*----------------------------------------------------------
* MODEL 3: INCOME-ONLY (NEOCLASSICAL)
* lnM lnPH_GDP lnUS_GDP
*----------------------------------------------------------

ardl lnM lnPH_GDP lnUS_GDP, maxlags(2) aic ec
estimates store M3levels

estat ectest

*----------------------------------------------------------
* MODEL 4: PH LABOR SHARE (DOMESTIC INEQUALITY)
* lnM lnPH_GDP ph_csg ph_labsh lnEXC
*----------------------------------------------------------

ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(2) aic ec
estimates store M4levels

estat ectest

*----------------------------------------------------------
* MODEL 5: US LABOR SHARE (FOREIGN INEQUALITY)
* lnM lnPH_GDP ph_csg us_labsh lnEXC
*----------------------------------------------------------

ardl lnM lnPH_GDP ph_csg us_labsh lnEXC, maxlags(2) aic ec
estimates store M5levels

estat ectest

*----------------------------------------------------------
* MODEL 7: BASELINE + COVID DUMMY
* lnM lnPH_GDP ph_csg lnEXC covid
*----------------------------------------------------------

ardl lnM lnPH_GDP ph_csg lnEXC covid, maxlags(2) aic ec
estimates store M7levels

estat ectest


*==========================================================
* POST-ESTIMATION DIAGNOSTICS (BG, BP, RESET)
*==========================================================

local models "M1levels M2levels M3levels M4levels M5levels M7levels"

log using diagnostics_models.log, text replace

foreach m of local models {
    di _n "=============================="
    di "Diagnostics for `m'"
    di "=============================="
    estimates restore `m'

    * Serial correlation: Breusch–Godfrey LM (lags 1 and 2)
    estat bgodfrey, lags(1/2)

    * Heteroskedasticity: Breusch–Pagan
    estat hettest

    * Functional form: Ramsey RESET
    estat ovtest
}

log close


*==========================================================
* STABILITY TESTS: CUSUM PER MODEL
* (re-estimate equivalent OLS with same lag orders)
*==========================================================

* Model 1: Baseline PH push – ARDL(2,1,0,1)
regress lnM L(1/2).lnM  L(0/1).lnPH_GDP  ph_csg  L(0/1).lnEXC
predict double cusum_M1, resid
estat sbcusum
drop cusum_M1

* Model 2: Bilateral PH–US – ARDL(2,2,0,0,0,1)
* Variables: lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC
regress lnM L(1/2).lnM  L(0/2).lnPH_GDP  ph_csg ///
             lnUS_GDP us_csg            L(0/1).lnEXC
predict double cusum_M2, resid
estat sbcusum
drop cusum_M2

* Model 3: Income-only – ARDL(2,1,1)
regress lnM L(1/2).lnM  L(0/1).lnPH_GDP  L(0/1).lnUS_GDP
predict double cusum_M3, resid
estat sbcusum
drop cusum_M3

* Model 4: PH labor share – ARDL(2,1,0,1,1)
regress lnM L(1/2).lnM  L(0/1).lnPH_GDP  ph_csg ///
             L(0/1).ph_labsh           L(0/1).lnEXC
predict double cusum_M4, resid
estat sbcusum
drop cusum_M4

* Model 5: US labor share – ARDL(2,1,0,0,1)
regress lnM L(1/2).lnM  L(0/1).lnPH_GDP  ph_csg ///
             us_labsh                  L(0/1).lnEXC
predict double cusum_M5, resid
estat sbcusum
drop cusum_M5

* Model 7: Baseline + COVID – ARDL(1,2,2,0,0)
regress lnM L1.lnM  L(0/2).lnPH_GDP  ph_csg  L(0/2).lnEXC  covid
predict double cusum_M7, resid
estat sbcusum
drop cusum_M7


*==========================================================
* MULTICOLLINEARITY: VIF CHECKS FOR LONG-RUN SETS
*==========================================================

* PH-only long-run regressors (Models 1, 4, 5, 7)
regress lnM lnPH_GDP ph_csg ph_labsh lnEXC
vif

* Bilateral long-run regressors (Model 2 / extended)
regress lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC
vif