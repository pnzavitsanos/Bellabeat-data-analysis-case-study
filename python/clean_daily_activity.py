import pandas as pd

""" Load the raw daily activity data """
daily_activity = pd.read_csv(
    r"C:\Users\nevez\OneDrive\Desktop\Bellabeat\data\raw\Fitabase Data 3.12.16-4.11.16\dailyActivity_merged.csv"
)

""" Inspect the data before touching anything """
print(daily_activity.shape)
print(daily_activity.isnull().sum())

""" Fix the date format """
daily_activity["ActivityDate"] = pd.to_datetime(daily_activity["ActivityDate"], format="%m/%d/%Y")

""" Remove non-wear days: TotalSteps = 0 for a full day almost always means
the tracker wasn't worn, not that the person truly took zero steps """
non_wear_rows = daily_activity[daily_activity["TotalSteps"] == 0]
print(f"Non-wear rows found: {len(non_wear_rows)}")
print(f"Users affected: {non_wear_rows['Id'].nunique()}")

daily_activity_clean = daily_activity[daily_activity["TotalSteps"] > 0].copy()

""" Confirm whether any user was removed entirely """
users_before = daily_activity["Id"].nunique()
users_after = daily_activity_clean["Id"].nunique()
print(f"Users before: {users_before}, users after: {users_after}")

""" Save the cleaned file """
daily_activity_clean.to_csv(
    r"C:\Users\nevez\OneDrive\Desktop\Bellabeat\data\cleaned\dailyActivity_cleaned.csv",
    index=False
)
