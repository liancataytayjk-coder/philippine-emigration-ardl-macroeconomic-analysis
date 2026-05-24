*==========================================================
* ARDL + DIAGNOSTIC TESTS (BG, BP, RESET, NORMALITY)
* RUN SEQUENTIALLY FOR EACH MODEL, NO ESTIMATES STORE
*==========================================================

* tsset your time variable first, e.g.:
* tsset year

log using diagnostics_inline.log, text replace

*----------------------------------------------------------
* MODEL 1: BASELINE PH PUSH + EXCHANGE RATE
* lnM lnPH_GDP ph_csg lnEXC
*----------------------------------------------------------
display _n "========== MODEL 1: BASELINE PH PUSH + FX =========="

ardl lnM lnPH_GDP ph_csg lnEXC, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M1
predict double `resid_M1', residuals
display _n "Normality (sktest) – residuals, Model 1"
sktest `resid_M1'
drop `resid_M1'


*----------------------------------------------------------
* MODEL 2: BILATERAL PH–US PUSH–PULL
* lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC
*----------------------------------------------------------
display _n "========== MODEL 2: BILATERAL PH–US =========="

ardl lnM lnPH_GDP ph_csg lnUS_GDP us_csg lnEXC, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M2
predict double `resid_M2', residuals
display _n "Normality (sktest) – residuals, Model 2"
sktest `resid_M2'
drop `resid_M2'


*----------------------------------------------------------
* MODEL 3: INCOME-ONLY (PH & US GDP)
* lnM lnPH_GDP lnUS_GDP
*----------------------------------------------------------
display _n "========== MODEL 3: INCOME-ONLY =========="

ardl lnM lnPH_GDP lnUS_GDP, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M3
predict double `resid_M3', residuals
display _n "Normality (sktest) – residuals, Model 3"
sktest `resid_M3'
drop `resid_M3'


*----------------------------------------------------------
* MODEL 4: PH LABOR SHARE (DOMESTIC INEQUALITY)
* lnM lnPH_GDP ph_csg ph_labsh lnEXC
*----------------------------------------------------------
display _n "========== MODEL 4: PH LABOR SHARE =========="

ardl lnM lnPH_GDP ph_csg ph_labsh lnEXC, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M4
predict double `resid_M4', residuals
display _n "Normality (sktest) – residuals, Model 4"
sktest `resid_M4'
drop `resid_M4'


*----------------------------------------------------------
* MODEL 5: US LABOR SHARE (FOREIGN INEQUALITY)
* lnM lnPH_GDP ph_csg us_labsh lnEXC
*----------------------------------------------------------
display _n "========== MODEL 5: US LABOR SHARE =========="

ardl lnM lnPH_GDP ph_csg us_labsh lnEXC, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M5
predict double `resid_M5', residuals
display _n "Normality (sktest) – residuals, Model 5"
sktest `resid_M5'
drop `resid_M5'


*----------------------------------------------------------
* MODEL 7: BASELINE + COVID DUMMY
* lnM lnPH_GDP ph_csg lnEXC covid
*----------------------------------------------------------
display _n "========== MODEL 7: BASELINE + COVID =========="

ardl lnM lnPH_GDP ph_csg lnEXC covid, maxlags(2) aic ec
estat ectest

display _n "Breusch–Godfrey LM (lags 1–2)"
estat bgodfrey, lags(1/2)

display _n "Breusch–Pagan heteroskedasticity"
estat hettest

display _n "Ramsey RESET"
estat ovtest

tempvar resid_M7
predict double `resid_M7', residuals
display _n "Normality (sktest) – residuals, Model 7"
sktest `resid_M7'
drop `resid_M7'


log close