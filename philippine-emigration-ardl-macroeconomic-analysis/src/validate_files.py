from pathlib import Path

REQUIRED = [
    "README.md",
    "data/raw/Alternative Data.xlsx",
    "notebooks/ARDL Analysis.do",
    "notebooks/BG, BP, RESET, and Normality Tests.do",
    "notebooks/CUSUM and VIF.do",
    "docs/business_summary.md",
    "docs/data_dictionary.md",
]

missing = [path for path in REQUIRED if not Path(path).exists()]

if missing:
    raise SystemExit("Missing required files:\n" + "\n".join(missing))

print("Repository file validation passed.")
