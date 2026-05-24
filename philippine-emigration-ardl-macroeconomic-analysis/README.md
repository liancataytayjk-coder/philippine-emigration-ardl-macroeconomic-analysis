# Philippine Emigration ARDL Macroeconomic Analysis

A macroeconomics and migration analytics portfolio project using ARDL bounds testing, error-correction modeling, diagnostic testing, and time-series visualization to study the macroeconomic determinants of Philippine emigration.

## Portfolio objective

This project analyzes how Philippine and United States macroeconomic variables relate to Philippine emigration over time. It is positioned as a research-grade econometrics project with reproducible Stata workflows and executive-ready interpretation.

## Target stack

- **Stata**: ARDL bounds testing, ECM estimation, residual diagnostics, CUSUM stability testing
- **Excel**: source macroeconomic and migration data preparation
- **Econometrics**: time-series modeling, stationarity testing, robustness checks
- **Macroeconomics / Migration economics**: interpretation of GDP, labor share, consumption share, exchange rate, and emigration dynamics
- **GitHub Actions**: lightweight repository file validation

## Business and research questions

1. Which macroeconomic indicators are associated with Philippine emigration?
2. Do domestic and U.S. economic conditions have short-run or long-run relationships with migration?
3. Are the estimated ARDL models stable and diagnostically acceptable?
4. How can migration analytics inform policy, labor planning, and macroeconomic risk monitoring?

## Dataset scope

The prepared ARDL dataset covers annual observations from **1981 to 2023** and includes:

- Philippine emigration count
- Philippine GDP per capita
- Philippine labor share
- Philippine consumption share
- U.S. GDP per capita
- U.S. labor share
- U.S. consumption share
- PHP/USD exchange rate

## Repository structure

```text
.
├── data/
│   ├── raw/                         # Source Excel, Stata, and macroeconomic datasets
│   └── processed/                   # Diagnostic logs and processed outputs
├── docs/                            # Research papers, thesis/write-up, documentation
├── notebooks/                       # Stata .do analysis scripts
├── reports/
│   ├── figures/                     # Time-series, residual, and CUSUM visuals
│   └── tables/                      # ARDL/ECM model result tables
├── src/
│   └── validate_files.py
├── requirements.txt
├── pyproject.toml
└── .github/workflows/python-ci.yml
```

## Analysis modules

- **ARDL Analysis.do**: full ARDL and ECM modeling pipeline
- **BG, BP, RESET, and Normality Tests.do**: diagnostic test workflow
- **CUSUM and VIF.do**: model stability and multicollinearity checks

## Key outputs

- Descriptive statistics table
- ARDL and ECM results tables
- Diagnostic test logs
- CUSUM stability plots
- Time-series level and difference plots
- Research write-up and thesis documentation

## How to validate repository files

```bash
python -m venv .venv
. .venv/Scripts/activate
pip install -r requirements.txt
python src/validate_files.py
```

## How to reproduce the econometric analysis

Open Stata and run the scripts in `notebooks/` after updating the local data directory path inside the `.do` files.

Recommended execution order:

1. `ARDL Analysis.do`
2. `BG, BP, RESET, and Normality Tests.do`
3. `CUSUM and VIF.do`

## Portfolio value

This repository demonstrates applied econometric modeling, migration economics, macroeconomic interpretation, time-series diagnostics, and reproducible research documentation.
