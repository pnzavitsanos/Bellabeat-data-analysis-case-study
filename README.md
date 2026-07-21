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

- BigQuery
- Google Sheets 
- Excel 
- Python

## Data Cleaning and Preparation

In the initial data preparation phase, the following tasks were performed:

- Loading and inspecting the daily activity dataset in Python (`pandas`).
- Checking user counts across all files: 35 users in the main daily activity file, but only 23 logged sleep, 14 logged heart rate, and 11 logged weight. Confirmed this is not a data error — every user in the smaller files also exists in the main file, they simply didn't use those extra features. Any result built from a joined table (like sleep vs. activity) is reported alongside its actual sample size rather than presented as if it came from all 35 users.
- Correcting the format of the `ActivityDate` column from text to a proper date type.
- Identifying and removing non-wear days — rows where `TotalSteps = 0` for the full day, since a real day of wear almost never records exactly zero steps. This removed 61 rows across 14 users.
- As a result of that same filter, one user (`4388161847`) had every single one of their rows flagged as non-wear — their tracker reported the same calorie value and a full day of sedentary time for eight straight days with zero steps throughout. Removing the non-wear rows dropped this user from the dataset entirely, bringing the daily activity user count from 35 to 34.

```python
import pandas as pd

""" Load the raw daily activity data """
daily_activity = pd.read_csv(r"data/raw/Fitabase Data 3.12.16-4.11.16/dailyActivity_merged.csv")

""" Fix the date format """
daily_activity["ActivityDate"] = pd.to_datetime(daily_activity["ActivityDate"], format="%m/%d/%Y")

""" Remove non-wear days: TotalSteps = 0 for a full day almost always means
the tracker wasn't worn, not that the person truly took zero steps """
daily_activity_clean = daily_activity[daily_activity["TotalSteps"] > 0].copy()

""" Save the cleaned file """
daily_activity_clean.to_csv(r"data/cleaned/dailyActivity_cleaned.csv", index=False)
```

Full script: [`python/clean_daily_activity.py`](python/clean_daily_activity.py).

## Exploratory Data Analysis

Before writing any queries, the daily, hourly, and minute-level tables were explored to understand how activity, calories, and sleep were structured across users and dates, and to scope the analysis down to five guiding questions that each point to a concrete recommendation:

- How many steps do users take per day, on average?
- Which days of the week are users most and least active?
- Does taking more steps lead to burning more calories?
- How much time do users spend sedentary versus active?
- How does sleep relate to activity levels?

These questions carried through into the [Data Analysis](#data-analysis) section below, where each one is answered with a BigQuery query and its result.

## Data Analysis

All queries run in Google BigQuery using the cleaned data uploaded as daily activity. Full file: [`sql/bigquery_queries.sql`](sql/bigquery_queries.sql).

**Aggregates minute-level sleep records into one hours-slept figure per user per night.**
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

**Pulls daily steps and calories, and collapses the three "active minutes" columns into one combined figure.**
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

Each finding ties back to its query in [Data Analysis](#data-analysis) above.

1. Users average **6,546.6 steps per day**, well below the commonly cited 10,000-step benchmark — most users aren't casually reaching typical daily movement goals without some added encouragement.

2. Activity isn't evenly spread across the week. **Wednesday** sees the highest average steps (7,511), while **Tuesday** is consistently the lowest (4,915).

![Average steps per week day](images/Average%20steps%20per%20week%20day.png)

3. There's a **moderate positive correlation (r = 0.58)** between daily steps and calories burned — more movement predictably burns more calories, though the relationship isn't perfectly linear, since resting metabolism still burns calories even on low-step days.

![Calories vs. Total Steps](images/Calories%20vs.%20TotalSteps.png)

4. Sedentary time dominates the day: users average **995 sedentary minutes** against a combined ~200 active minutes (very + fairly + lightly active) — sedentary behavior makes up roughly **69% of the day**.

![Activity minutes average](images/Activity%20minutes%20average.png)

5. Average sleep is **6.56 hours/night**, short of the recommended 7–9 hours, and shows only a weak negative correlation with activity (**r = -0.12**) — more movement does not translate into more sleep in this dataset.

**Summarized insight:** Taken together, these findings describe a mostly sedentary user base whose activity is concentrated in short, uneven bursts across the week, with sleep quality largely decoupled from daytime activity levels. That combination points to a real opportunity for a wellness product — not just counting steps, but actively interrupting long sedentary stretches and separately reinforcing healthy sleep habits, rather than assuming one will fix the other.

## Recommendations

Each recommendation ties back to a specific finding above, or to a pattern surfaced during [data cleaning](#data-cleaning-and-preparation).

1. **Detect non-wear time and prompt users to put the device back on.** Cleaning this dataset turned up 61 zero-step days across 14 users, and one user whose tracker was effectively never worn. A silent zero-activity day looks the same as a real rest day in the raw data, but it isn't — it's missing data, not low activity. Bellabeat's app could flag stretches with no motion or heart-rate signal and nudge the user to wear the device, so both the user and the data get a truer picture of their activity.

2. **Target the app's lowest-activity day directly.** Tuesday was consistently the lowest-step day across the sample (Finding 2), with Wednesday the highest. Instead of one generic daily reminder, a nudge scheduled specifically for a user's own historically low day would target the actual gap the data shows, rather than treating every day the same.

3. **Interrupt long sedentary stretches, not just track total steps.** Sedentary time made up roughly 69% of the day on average (Finding 4). A move reminder triggered after a set period of no movement (e.g. 60–90 minutes) addresses this pattern more directly than a single end-of-day step goal, which says nothing about how that inactivity was distributed.

4. **Show users the steps-to-calories payoff in the moment.** Steps and calories burned had a moderate positive correlation (r = 0.58, Finding 3). Surfacing that connection in the app in real time — e.g. estimated extra calories burned for a short walk right now — turns an abstract step count into an immediate, concrete incentive to move.

5. **Treat sleep as its own feature, not a side effect of activity.** Average sleep was 6.56 hours/night, short of the recommended 7–9, and only weakly related to daytime activity (r = -0.12, Finding 5). Since being more active during the day didn't translate into more sleep in this data, Bellabeat should invest in dedicated sleep habits features — wind-down reminders, consistent bedtime prompts — rather than assuming a step-focused product will fix sleep on its own.


