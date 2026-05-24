# Philippine Emigration ARDL Macroeconomic Analysis

A migration economics and macroeconometric research portfolio project analyzing the determinants of Philippine emigration using ARDL bounds testing, ECM modeling, and Stata-based time-series workflows.

## Portfolio objective

This project evaluates how macroeconomic and labor-market indicators relate to Philippine emigration patterns. It is positioned as an applied econometrics project for migration research, policy analysis, and macroeconomic interpretation.

## Target stack

- **Stata**: ARDL, ECM, diagnostic testing, and econometric estimation
- **Excel**: source macroeconomic and migration datasets
- **Econometrics**: time-series modeling and bounds testing
- **Python**: lightweight repository validation
- **GitHub Actions**: automated file-structure validation

## Research questions

1. Which macroeconomic variables are associated with Philippine emigration?
2. Are there long-run relationships between emigration and selected economic indicators?
3. What short-run dynamics are captured by the ECM specification?
4. How can ARDL results inform migration and labor-market policy interpretation?

## Repository structure

```text
.
├── data/
│   ├── raw/                         # Source Excel datasets
│   └── processed/                   # Cleaned econometric inputs where applicable
├── docs/
│   ├── business_summary.md
│   └── data_dictionary.md
├── scripts/
│   └── stata/                       # Stata .do files and model workflow
├── reports/                         # Model outputs, tables, and diagnostic exports
├── src/
│   └── validate_files.py
├── requirements.txt
├── pyproject.toml
└── .github/workflows/python-ci.yml
```

## Analysis themes

- Philippine emigration trends
- Macroeconomic determinants of migration
- ARDL bounds testing
- Error correction modeling
- Time-series diagnostic checks
- Policy-oriented econometric interpretation

## How to use

1. Open the Stata scripts in `scripts/stata/`.
2. Verify the input paths point to the files in `data/raw/` or `data/processed/`.
3. Run the ARDL and ECM workflow in Stata.
4. Review outputs in `reports/` and documentation in `docs/`.

For file validation:

```bash
python -m venv .venv
. .venv/Scripts/activate
pip install -r requirements.txt
python src/validate_files.py
```

## Portfolio value

This repository demonstrates applied macroeconometrics, migration economics, Stata workflow documentation, and policy-facing interpretation of time-series results.
