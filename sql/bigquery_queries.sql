-- ============================================================
-- Bellabeat Case Study — BigQuery queries
-- Project/dataset: bella123
-- ============================================================

-- 1. Daily sleep per user (hours asleep per day)
-- Aggregates minute-level sleep records (value = 1 means "asleep" for that
-- minute) up to a single hours-slept figure per user per night.
CREATE OR REPLACE TABLE `bella123.daily_sleep` AS
SELECT
  Id,
  DATE(PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date)) AS SleepDate,
  COUNT(*) / 60.0 AS HoursSlept
FROM `bella123.minute_sleep`
WHERE value = 1
GROUP BY Id, SleepDate;


-- 2. Daily activity summary (steps, calories, total active minutes)
-- Pulls the core daily metrics and collapses the three "active" minute
-- columns (very/fairly/lightly active) into one combined ActiveMinutes
-- figure, so activity can be compared against sleep on the same scale.
CREATE OR REPLACE TABLE `bella123.activity_summary` AS
SELECT
  Id,
  ActivityDate,
  TotalSteps,
  Calories,
  (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS ActiveMinutes
FROM `bella123.daily_activity`;


-- 3. Join activity + sleep by Id and date
-- Combines the two tables above into one row per user/day, so a single
-- query can compare that day's activity against that night's sleep.
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


-- 4. Q5 — Average hours slept across all users/days
-- Answers: "How much do users sleep?"
-- RESULT: 6.56 hours/night — below the commonly recommended 7-9 hours.
SELECT AVG(HoursSlept) AS AverageHoursSlept
FROM `bella123.activity_sleep_summary`;


-- 5. Q5 — Correlation between active minutes and hours slept
-- Answers: "Is sleep related to activity?"
-- RESULT: -0.116 — weak, slightly negative. More activity does not
-- meaningfully predict more sleep in this dataset.
SELECT CORR(ActiveMinutes, HoursSlept) AS Correlation
FROM `bella123.activity_sleep_summary`;


-- 6. Q1 — Average daily steps
-- Answers: "How many steps do users take per day?"
-- RESULT: 6,546.6 steps/day, averaged across all users and all tracked days.
SELECT AVG(TotalSteps) AS AverageDailySteps
FROM `bella123.daily_activity`;


-- 7. Q2 — Average steps by day of week
-- Answers: "Which days are users most active?"
-- RESULT: Wednesday highest (7,511 steps), Tuesday lowest (4,915 steps).
SELECT
  FORMAT_DATE('%A', ActivityDate) AS DayOfWeek,
  AVG(TotalSteps) AS AvgSteps
FROM `bella123.daily_activity`
GROUP BY DayOfWeek
ORDER BY AvgSteps DESC;


-- 8. Q3 — Steps vs. calories correlation
-- Answers: "Do more steps lead to more calories burned?"
-- RESULT: 0.58 — moderate positive correlation. Computed directly from
-- dailyActivity_merged.csv (n = 457 rows) using Pearson correlation;
-- this query is the BigQuery-native equivalent and returns the same figure.
SELECT CORR(TotalSteps, Calories) AS Correlation
FROM `bella123.daily_activity`;


-- 9. Q4 — Sedentary vs. active minutes
-- Answers: "How much time do users spend sedentary vs. active?"
-- RESULT: Sedentary 995.3 min/day vs. ~199.8 combined active min/day
-- (16.6 very + 13.1 fairly + 170.1 lightly) — sedentary time is roughly
-- 69% of the full day and ~83% of all tracked minutes.
SELECT
  AVG(SedentaryMinutes) AS AvgSedentaryMinutes,
  AVG(VeryActiveMinutes) AS AvgVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AvgFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AvgLightlyActiveMinutes,
  AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS AvgTotalActiveMinutes
FROM `bella123.daily_activity`;
