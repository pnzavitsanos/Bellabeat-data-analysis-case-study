# Bellabeat Case Study: How Can a Wellness Technology Company Play It Smart?

## Table of Contents
- [Project Overview and Case Study Scenario](#project-overview-and-case-study-scenario)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results and Findings](#results-and-findings)
- [Recommendations](#recommendations)
- [References](#references)

## Project Overview and Case Study Scenario

 Bellabeat is a high-tech wellness company for women, and the task was to analyze public smart device fitness data to uncover usage trends, then apply those trends to a Bellabeat product and its marketing strategy. To scope the work, five guiding questions were set from the start: 
   1) how many steps users take per day
   2) which days they're most active
   3) whether more steps lead to more calories burned
   4) how much time is spent sedentary versus active
   5) and how sleep relates to activity.
      
Each question was picked because it points to a concrete recommendation Bellabeat could act on — prompting activity on low-activity days, nudging users after long sedentary stretches, or promoting sleep-tracking features.

## Data Source

[FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) (Kaggle, CC0: Public Domain, via Mobius) — minute-level activity, heart rate, and sleep data from roughly 30 consenting FitBit users, covering March 12 – April 12, 2016.

**Limitations (ROCCC):** small, self-selected sample (~30 Mechanical Turk participants); no demographic data despite Bellabeat's products targeting women specifically; a short, one-month window with some sparse user-days; data collected in 2016, so usage patterns may have shifted since; third-party submitted, so collection methodology can't be fully verified. Findings here should be read as directional trends, not definitive claims.

## Tools

Google Sheets, BigQuerry (SQL)

## Data Cleaning and Preparation

(what you did to get the data ready)

## Exploratory Data Analysis

(the key questions you set out to answer)

## Data Analysis

# Bellabeat Case Study: How Can a Wellness Technology Company Play It Smart?

## Table of Contents
- [Project Overview and Case Study Scenario](#project-overview-and-case-study-scenario)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results and Findings](#results-and-findings)
- [Recommendations](#recommendations)
- [References](#references)

## Project Overview and Case Study Scenario

This is the Bellabeat capstone case study from the Google Data Analytics Professional Certificate. Bellabeat is a high-tech wellness company for women, and the task was to analyze public smart device fitness data to uncover usage trends, then apply those trends to a Bellabeat product and its marketing strategy. To scope the work, five guiding questions were set from the start: how many steps users take per day, which days they're most active, whether more steps lead to more calories burned, how much time is spent sedentary versus active, and how sleep relates to activity. Each question was picked because it points to a concrete recommendation Bellabeat could act on — prompting activity on low-activity days, nudging users after long sedentary stretches, or promoting sleep-tracking features.

## Data Source

[FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) (Kaggle, CC0: Public Domain, via Mobius) — minute-level activity, heart rate, and sleep data from roughly 30 consenting FitBit users, covering March 12 – April 12, 2016.

**Limitations (ROCCC):** small, self-selected sample (~30 Mechanical Turk participants); no demographic data despite Bellabeat's products targeting women specifically; a short, one-month window with some sparse user-days; data collected in 2016, so usage patterns may have shifted since; third-party submitted, so collection methodology can't be fully verified. Findings here should be read as directional trends, not definitive claims.

### Files

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

## Tools

(what you used — BigQuery, Sheets, etc.)

## Data Cleaning and Preparation

(what you did to get the data ready)

## Exploratory Data Analysis

(the key questions you set out to answer)

## Data Analysis

In this section we present some interesting SQL queries we wrote in order to analyze the dataset.

**In order to find how much users sleep we create a table that records the sleeping time in hours per Id and Date**
```sql
CREATE OR REPLACE TABLE `bella123.daily_sleep` AS
SELECT
  Id,
  DATE(PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date)) AS SleepDate,
  COUNT(*) / 60.0 AS HoursSlept
FROM `bella123.minute_sleep`
WHERE value = 1
GROUP BY Id, SleepDate;
```

**We create a table that records the total Active minutes of the users.**
```sql
CREATE OR REPLACE TABLE `bella123.activity_summary` AS
SELECT
  Id,
  ActivityDate,
  TotalSteps,
  Calories,
  (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS ActiveMinutes
FROM `bella123.daily_activity`;
```

**Joins the two tables above into one row per user/day, so activity and sleep can be compared directly.**
```sql
CREATE OR REPLACE TABLE `bella123.activity_sleep_summary` AS
SELECT
  a.Id,
  a.ActivityDate,
  a.ActiveMinutes,
  a.TotalSteps,
  a.Calories,
  s.HoursSlept
FROM `bella123.activity_summary` AS a
JOIN `bella123.daily_sleep` AS s
  ON a.Id = s.Id
  AND a.ActivityDate = s.SleepDate;
```

**Q1 — average steps per day.**
```sql
SELECT AVG(TotalSteps) AS AverageDailySteps
FROM `bella123.daily_activity`;
-- RESULT: 6,546.6
```

**Q2 — average steps by day of week, to find the most/least active days.**
```sql
SELECT
  FORMAT_DATE('%A', ActivityDate) AS DayOfWeek,
  AVG(TotalSteps) AS AvgSteps
FROM `bella123.daily_activity`
GROUP BY DayOfWeek
ORDER BY AvgSteps DESC;
-- RESULT: Wednesday highest (7,511) → Tuesday lowest (4,915)
```

**Q3 — correlation between steps and calories burned.**
```sql
SELECT CORR(TotalSteps, Calories) AS Correlation
FROM `bella123.daily_activity`;
-- RESULT: 0.58 (moderate positive)
```

**Q4 — average minutes spent sedentary vs. in each active category.**
```sql
SELECT
  AVG(SedentaryMinutes) AS AvgSedentaryMinutes,
  AVG(VeryActiveMinutes) AS AvgVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AvgFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AvgLightlyActiveMinutes
FROM `bella123.daily_activity`;
-- RESULT: Sedentary 995.3 | Very Active 16.6 | Fairly Active 13.1 | Lightly Active 170.1
```

**Q5 — average hours slept per night.**
```sql
SELECT AVG(HoursSlept) AS AverageHoursSlept
FROM `bella123.activity_sleep_summary`;
-- RESULT: 6.56 hours/night
```

**Q5 — correlation between active minutes and hours slept.**
```sql
SELECT CORR(ActiveMinutes, HoursSlept) AS Correlation
FROM `bella123.activity_sleep_summary`;
-- RESULT: -0.12 (weak, slightly negative)
```

## Results and Findings

(what you found — numbers + charts, one per question)

## Recommendations

(your top 3, tied back to the findings)

## References

(Kaggle dataset, Coursera certificate, tools used)


## Results and Findings

(what you found — numbers + charts, one per question)

## Recommendations

(your top 3, tied back to the findings)

## References

(Kaggle dataset, Coursera certificate, tools used)
