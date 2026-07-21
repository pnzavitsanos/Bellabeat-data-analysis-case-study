# Data

Source: [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) (Kaggle, CC0: Public Domain, via Mobius).

Raw CSVs live in `data/raw/` locally but are **not pushed to GitHub** — several files are 50+ MB, well past what belongs in a git repository. To reproduce this analysis:

1. Download the dataset from the Kaggle link above.
2. Unzip it into `data/raw/`.

## Files

| File | Granularity | Description |
|---|---|---|
| `dailyActivity_merged.csv` | Daily | Steps, distance, active/sedentary minutes, calories per user/day |
| `hourlySteps_merged.csv` | Hourly | Step count per user/hour |
| `hourlyCalories_merged.csv` | Hourly | Calories burned per user/hour |
| `hourlyIntensities_merged.csv` | Hourly | Activity intensity per user/hour |
| `minuteStepsNarrow_merged.csv` | Minute | Step count per user/minute |
| `minuteCaloriesNarrow_merged.csv` | Minute | Calories per user/minute |
| `minuteIntensitiesNarrow_merged.csv` | Minute | Intensity per user/minute |
| `minuteMETsNarrow_merged.csv` | Minute | Metabolic equivalent per user/minute |
| `minuteSleep_merged.csv` | Minute | Sleep state (1 = asleep) per user/minute |
| `heartrate_seconds_merged.csv` | Second | Heart rate per user/second |
| `weightLogInfo_merged.csv` | Daily | Weight, BMI, body fat per user/day (sparse — only a few users logged this) |
