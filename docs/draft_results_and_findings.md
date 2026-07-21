<!-- DRAFT — proposed "Results and Findings" section for README.md. Not yet merged. -->

## Results and Findings

Each finding below ties back to its query in [Data Analysis](#data-analysis).

**Q1 — How many steps do users take per day?**
Average of **6,546.6 steps/day** across all users and tracked days — below the commonly cited 10,000-step benchmark. *(from the `AverageDailySteps` query)*

**Q2 — Which days are users most active?**

![Average steps per week day](images/Average%20steps%20per%20week%20day.png)

**Wednesday** is the most active day (7,511 avg steps), **Tuesday** the least (4,915 avg steps). *(from the day-of-week `AvgSteps` query)*

**Q3 — Do more steps lead to more calories burned?**
A **moderate positive correlation (r = 0.58)** between daily steps and calories burned. *(from the `CORR(TotalSteps, Calories)` query)* — no chart currently in `images/` for this one; the earlier scatter plot export isn't in the folder anymore.

**Q4 — How much time do users spend sedentary vs. active?**

![Activity minutes average](images/Activity%20minutes%20average.png)

Users average **995 sedentary minutes/day** against a combined ~200 active minutes (very + fairly + lightly active) — sedentary time is roughly **69% of the full day**. *(from the `AvgSedentaryMinutes` / active-minutes query)*

**Q5 — How much do users sleep, and is it related to activity?**
Average sleep is **6.56 hours/night**, short of the recommended 7–9 hours. Correlation between active minutes and sleep is weak and slightly negative (**r = -0.12**) — more activity doesn't translate into more sleep in this dataset. *(from the `AverageHoursSlept` and `CORR(ActiveMinutes, HoursSlept)` queries)*
