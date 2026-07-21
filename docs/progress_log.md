# Bellabeat Case Study — Progress Log

Coursera Google Data Analytics Capstone (Case Study 2). Roadmap: Ask → Prepare → Process → Analyze → Share → Act.

## Business questions (Ask)

1. How many steps do users take per day?
2. Which days are users most active?
3. Do more steps lead to more calories burned?
4. How much time do users spend sedentary versus active?
5. How much do users sleep, and is sleep related to activity?

## Data (Prepare)

FitBit Fitness Tracker Data, Kaggle (CC0, via Mobius). ~30 users, minute-level activity/heart rate/sleep, March 12–April 11, 2016. Stored in `01_Raw_Data/`.

Known limitations to flag in the final report: small, self-selected sample (Amazon Mechanical Turk); no demographic data (age, sex — though Bellabeat's audience is women, this dataset isn't women-only); short time window (~1 month); some users have sparse or missing days.

## Process / Analyze — status

Tool: BigQuery (SQL). Plan was Sheets first, then redo in SQL — went straight to SQL.

Done:
- Uploaded tables to BigQuery, checked schema/data types.
- Built `daily_sleep`: minutes asleep per user/day (from `minuteSleep_merged`, value = 1), converted to hours.
- Built `activity_summary`: steps, calories, and total active minutes (very + fairly + lightly active) from `dailyActivity_merged`.
- Joined into `activity_sleep_summary` (by Id + date).
- Results so far:
  - Average hours slept: **6.56 hrs**
  - Correlation (active minutes vs. hours slept): **-0.116** (weak, slightly negative — more active minutes very slightly associated with less sleep, not a strong relationship)

Answers question 5 (sleep vs. activity).

SQL used lives in `03_SQL/bigquery_queries.sql`.

## Process / Analyze — Google Sheets (with ChatGPT), Q1/Q2/Q4

Separate from the BigQuery work: the raw CSVs were also uploaded to Google Drive (folder "Bellabeat" in Drive, distinct from this local folder) and opened in Sheets, with ChatGPT helping build formulas. Each CSV got auto-converted into a Sheets version alongside the original .csv (worth cleaning up later — 18 files for 10 datasets, some duplicated).

The real analysis lives in the **`dailyActivity_merged`** Sheet. Two columns were added (`DayOfWeek`, `Total activity Minutes`), and three pivot tables were built from them:

- [x] **Q1 — daily step distribution**: average steps per user/day across the dataset = **6,546.6**
- [x] **Q2 — most/least active days**: by average steps, **Wednesday** is highest (7,511), **Tuesday** is lowest (4,915). By average VeryActiveMinutes, Saturday (18.97) and Monday (18.96) lead, Tuesday (13.15) still trails — Tuesday is consistently the least active day.
- [x] **Q4 — sedentary vs. active time**: average minutes/day — Sedentary 995.3, Lightly Active 170.1, Fairly Active 13.1, Very Active 16.6. So users are sedentary roughly **69% of their tracked day**, with the vast majority of "active" time being just light activity.
- [x] **Q3 — steps vs. calories**: confirmed via the exported "Calories vs. TotalSteps" scatter chart (now in `images/`) and a Pearson correlation computed directly from `dailyActivity_merged.csv` (n = 457 rows): **r = 0.58**, a moderate positive correlation. Equivalent BigQuery query added to `sql/bigquery_queries.sql`.

Both charts exported to `images/`: "Activity minutes average.png" (bar chart, backs Q4) and "Calories vs. TotalSteps.png" (scatter, backs Q3). Both are now embedded in the main README.md.

Note: `heartrate_seconds_merged.csv` was never uploaded to the Drive folder (only the other 10 files were).

## Combined status across both tools

| Question | Status | Method |
|---|---|---|
| Q1 — steps/day | Done | Sheets |
| Q2 — most active days | Done | Sheets |
| Q3 — steps vs. calories | Done (r = 0.58) | Sheets chart + computed correlation |
| Q4 — sedentary vs. active | Done | Sheets |
| Q5 — sleep vs. activity | Done | BigQuery SQL |

## Share / Act — not started

- No visualizations yet
- No written analysis summary
- No top-3 recommendations
- Final report/deck not started — goes in `04_Deliverables/`

## Folder structure

Reorganized into GitHub-repo layout (see repository README.md at the project root for the full writeup):

```
Bellabeat/
├── README.md               — main case study writeup (this is the GitHub-facing summary)
├── .gitignore               — excludes data/raw/ (too large for git)
├── data/
│   ├── README.md            — data dictionary + Kaggle source link
│   └── raw/                 — original Kaggle CSVs + zip (not committed to git)
├── docs/
│   ├── progress_log.md       — this file
│   ├── original_notes_raw.txt — original messy notes, kept for reference
│   └── case_study_brief.pdf  — the assignment PDF
├── sql/
│   └── bigquery_queries.sql  — BigQuery scripts
└── images/                  — chart exports (empty for now)
```
