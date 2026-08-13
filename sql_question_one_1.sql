/* Question 1

Business Question: How many total accounts and how many total subscriptions exist in the database?
Business Objective: Establish baseline record counts before any analysis — the first thing any analyst checks.
Difficulty: Beginner
SQL Concepts Required: COUNT(), basic SELECT
*/
select count(*) from accounts ;
select count(*) from subscriptions;

/* Question 2

Business Question: Are there any duplicate account_id values in the accounts table, or duplicate subscription_id values in subscriptions?
Business Objective: Data quality check — primary keys must be unique before any join or aggregation is trusted.
Difficulty: Beginner
SQL Concepts Required: GROUP BY, HAVING, COUNT()
*/
select account_id , count(*) from accounts 
group by account_id 
having count(account_id) > 1;
select subscription_id , count(*) from subscriptions 
group by subscription_id 
having count(subscription_id) > 1;

/*Question 3

Business Question: Are there any subscriptions.account_id values that do NOT exist in the accounts table (orphan records)?
Business Objective: Referential integrity check — critical before joining tables for revenue reporting.
Difficulty: Beginner
SQL Concepts Required: LEFT JOIN, IS NULL (anti-join pattern)
*/
SELECT 
    COUNT(*) AS orphan_records
FROM subscriptions s
LEFT JOIN accounts a
    ON s.account_id = a.account_id
WHERE a.account_id IS NULL; 

/* Question 4

Business Question: Which columns in accounts and subscriptions contain NULL values, and how many NULLs are in each?
Business Objective: Understand data completeness before building KPIs (e.g., NULL end_date means active subscription, not missing data — must confirm this assumption).
Difficulty: Beginner
SQL Concepts Required: SUM(CASE WHEN ... IS NULL), conditional aggregation
*/
SELECT 
    SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) AS null_account_id,
    SUM(CASE WHEN account_name IS NULL THEN 1 ELSE 0 END) AS null_account_name,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup_date,
    SUM(CASE WHEN referral_source IS NULL THEN 1 ELSE 0 END) AS null_referral_source,
    SUM(CASE WHEN plan_tier IS NULL THEN 1 ELSE 0 END) AS null_plan_tier,
    SUM(CASE WHEN seats IS NULL THEN 1 ELSE 0 END) AS null_seats,
    SUM(CASE WHEN is_trial IS NULL THEN 1 ELSE 0 END) AS null_is_trial,
    SUM(CASE WHEN churn_flag IS NULL THEN 1 ELSE 0 END) AS null_churn_flag
FROM accounts;
SELECT 
    SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) AS null_subscription_id,
    SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) AS null_account_id,
    SUM(CASE WHEN start_date IS NULL THEN 1 ELSE 0 END) AS null_start_date,
    SUM(CASE WHEN end_date IS NULL THEN 1 ELSE 0 END) AS null_end_date,
    SUM(CASE WHEN plan_tier IS NULL THEN 1 ELSE 0 END) AS null_plan_tier,
    SUM(CASE WHEN seats IS NULL THEN 1 ELSE 0 END) AS null_seats,
    SUM(CASE WHEN mrr_amount IS NULL THEN 1 ELSE 0 END) AS null_mrr_amount,
    SUM(CASE WHEN arr_amount IS NULL THEN 1 ELSE 0 END) AS null_arr_amount,
    SUM(CASE WHEN is_trial IS NULL THEN 1 ELSE 0 END) AS null_is_trial,
    SUM(CASE WHEN upgrade_flag IS NULL THEN 1 ELSE 0 END) AS null_upgrade_flag,
    SUM(CASE WHEN downgrade_flag IS NULL THEN 1 ELSE 0 END) AS null_downgrade_flag,
    SUM(CASE WHEN churn_flag IS NULL THEN 1 ELSE 0 END) AS null_churn_flag,
    SUM(CASE WHEN billing_frequency IS NULL THEN 1 ELSE 0 END) AS null_billing_frequency,
    SUM(CASE WHEN auto_renew_flag IS NULL THEN 1 ELSE 0 END) AS null_auto_renew_flag
FROM subscriptions;

/*Question 5

Business Question: How many accounts exist per industry? List industries from highest to lowest count.
Business Objective: Understand customer base composition — a common opening slide in any business review.
Difficulty: Beginner
SQL Concepts Required: GROUP BY, ORDER BY, COUNT()
*/
select industry , count(*) as no_of_accounts from accounts 
group by industry order by count(*) desc;

/* Question 6

Business Question: How many accounts came from each referral_source (organic, ads, event, partner, other)?
Business Objective: Understand acquisition channel mix — foundational for marketing ROI questions later.
Difficulty: Beginner
SQL Concepts Required: GROUP BY, COUNT(), ORDER BY
*/
select referral_source , count(*) as no_of from accounts group by referral_source order by count(*) desc;

/* Question 7

Business Question: What percentage of all accounts are currently marked as churned (churn_flag = true)?
Business Objective: Calculate the headline churn rate metric — the single most important SaaS KPI.
Difficulty: Beginner
SQL Concepts Required: Conditional aggregation, CAST/type conversion for percentage calculation
*/
select round((sum(case when churn_flag ='True' then 1 else 0 end)* 100) / count(*) ,2) as churn_percentage
from accounts;

/*Question 8

Business Question: What is the distribution of accounts across plan_tier (Basic, Pro, Enterprise)?
Business Objective: Understand product mix — which plan tier has the most customers.
Difficulty: Beginner
SQL Concepts Required: GROUP BY, COUNT(), percentage calculation */

select plan_tier , count(*) as no_of_accounts ,
((count(*)*100) / (select count(*) from accounts)) as percentage_calculation  from accounts 
group by plan_tier order by no_of_accounts desc;
/* or */
with cte as ( select plan_tier , count(*) as no_of_accounts   from accounts group by plan_tier) 
select * ,((no_of_accounts * 100) / (select count(*) from accounts)) as percentage from cte ;

/* Question 9

Business Question: What is the earliest and latest signup_date in the accounts table? What is the full date range this dataset covers?
Business Objective: Understand the time window of the dataset — required before doing any time-based/trend analysis.
Difficulty: Beginner
SQL Concepts Required: MIN(), MAX(), date functions
*/
SELECT 
    MIN(signup_date) AS earliest_signup_date, 
    MAX(signup_date) AS latest_signup_date 
FROM accounts;

/* Question 10

Business Question: For each account, count how many subscription records they have in the subscriptions table. 
Are there accounts with more than one subscription record?
Business Objective: Understand subscription lifecycle behavior — some accounts may have multiple subscription periods
(renewals, plan changes) which changes how you calculate metrics per account vs per subscription.
Difficulty: Beginner–Intermediate
SQL Concepts Required: GROUP BY, HAVING, COUNT(), JOIN
*/
select a.account_id ,a.account_name, count(s.subscription_id) as subscription_count from accounts as a 
left join subscriptions as s on 
s.account_id = a.account_id 
group by a.account_id , a.account_name
having count(s.subscription_id) > 1 order by subscription_count desc;

/* Question 11

Business Question: What is the total MRR (Monthly Recurring Revenue) and total ARR (Annual Recurring Revenue)
currently active in the business (subscriptions where end_date is NULL)?
Business Objective: Calculate the core revenue health metric every SaaS company tracks — active recurring revenue.
Difficulty: Intermediate
SQL Concepts Required: WHERE, SUM(), filtering on NULL
*/

select sum(mrr_amount) as Monthly_Recurring_Revenue , sum(arr_amount) as Annual_Recurring_Revenue from subscriptions
where end_date is null or end_date = '' ;

/*Question 12

Business Question: What is the average MRR per account, broken down by plan_tier?
Business Objective: Understand which plan tier generates the most revenue per customer — informs upsell strategy.
Difficulty: Intermediate
SQL Concepts Required: AVG(), GROUP BY, JOIN
*/
SELECT 
    s.plan_tier,
    AVG(s.mrr_amount) AS avg_mrr_amount
FROM accounts a
JOIN subscriptions s 
    ON a.account_id = s.account_id
GROUP BY s.plan_tier
ORDER BY avg_mrr_amount DESC;

/* Question 13

Business Question: How many subscriptions are currently active vs. churned (based on end_date being NULL vs. not NULL)?
Business Objective: Distinguish subscription-level churn from account-level churn — a subscription-level view is often more accurate for revenue impact.
Difficulty: Intermediate
SQL Concepts Required: CASE WHEN, conditional aggregation
*/

select sum(case when end_date = '' or end_date is null  then 1 else 0 end ) as active_subscriptions ,
sum(case when end_date <> '' and end_date is not null then 1 else 0 end) as churned_subscriptions from subscriptions;

/*
Question 14

Business Question: What is the month-over-month trend of new subscriptions started, from the earliest to the latest month in the dataset?
Business Objective: Identify growth trends and seasonality in customer acquisition.
Difficulty: Intermediate
SQL Concepts Required: DATE_FORMAT(), GROUP BY, ORDER BY
*/

with cte as ( select * , date_format(start_date , '%y-%m-01') as subscription_month from subscriptions) 
select subscription_month , count(*) as no_of_new_subscriptions from cte 
group by subscription_month 
order by subscription_month asc;

/* Question 15
Business Question: What is the trial-to-paid conversion rate?
(What percentage of subscriptions that started as is_trial = TRUE are still active or converted, vs. those that churned during/after trial?)
Business Objective: Measure how effectively free trials convert into paying, retained customers — a critical SaaS growth metric.
Difficulty: Intermediate
SQL Concepts Required: CASE WHEN, conditional aggregation, percentage calculation
*/
SELECT 
    SUM(CASE WHEN is_trial = 'True' THEN 1 ELSE 0 END) AS total_trials,
    SUM(CASE WHEN is_trial = 'True' AND churn_flag = 'False' THEN 1 ELSE 0 END) AS converted_trials,
    ROUND(
        (SUM(CASE WHEN is_trial = 'True' AND churn_flag = 'False' THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(SUM(CASE WHEN is_trial = 'True' THEN 1 ELSE 0 END), 0), 
        2
    ) AS conversion_rate_percentage
FROM subscriptions;

/*Question 16

Business Question: How many subscriptions had an upgrade_flag = TRUE vs. a downgrade_flag = TRUE? What is the net upgrade ratio?
Business Objective: Understand product expansion vs. contraction behavior within the existing customer base.
Difficulty: Intermediate
SQL Concepts Required: Conditional aggregation, ratio calculation */
SELECT 
    SUM(CASE WHEN upgrade_flag = 'True' THEN 1 ELSE 0 END) AS total_upgrades,
    SUM(CASE WHEN downgrade_flag = 'True' THEN 1 ELSE 0 END) AS total_downgrades,
    ROUND(
        SUM(CASE WHEN upgrade_flag = 'True' THEN 1 ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN downgrade_flag = 'True' THEN 1 ELSE 0 END), 0), 
        2
    ) AS net_upgrade_ratio
FROM subscriptions;


/*Question 17
Business Question: What is the total revenue (MRR) broken down by billing_frequency (monthly vs. annual)? 
What percentage of revenue comes from each?
Business Objective: Understand billing preference mix — annual billing customers are typically more stable/predictable revenue.
Difficulty: Intermediate
SQL Concepts Required: JOIN, GROUP BY, percentage calculation */

SELECT 
    billing_frequency,
    SUM(mrr_amount) AS total_mrr,
    ROUND(
        (SUM(mrr_amount) * 100.0) / (SELECT SUM(mrr_amount) FROM subscriptions), 
        2
    ) AS revenue_percentage
FROM subscriptions
GROUP BY billing_frequency;

/* 
Question 18

Business Question: Which industry generates the highest total MRR? Join accounts and subscriptions to find total active revenue per industry.
Business Objective: Identify the most valuable customer segment by revenue, not just by headcount — a common gap between Q5 (accounts by industry) and true revenue impact.
Difficulty: Intermediate–Advanced
SQL Concepts Required: INNER JOIN, GROUP BY, SUM(), ORDER BY */

SELECT 
    a.industry, 
    SUM(s.mrr_amount) AS total_mrr 
FROM accounts AS a
JOIN subscriptions AS s 
    ON a.account_id = s.account_id
WHERE s.end_date = '' OR s.end_date IS NULL
GROUP BY a.industry
ORDER BY total_mrr DESC;

/* Question 19

Business Question: What is the churn rate specifically among Enterprise plan customers, compared to Basic and Pro? 
Does higher-tier plan correlate with lower churn?
Business Objective: Test the hypothesis that higher-value customers are stickier — informs retention strategy prioritization.
Difficulty: Intermediate–Advanced
SQL Concepts Required: JOIN, CASE WHEN, GROUP BY, percentage calculation */
SELECT 
    plan_tier,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        (SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS tier_churn_rate_percentage
FROM subscriptions
GROUP BY plan_tier
ORDER BY tier_churn_rate_percentage DESC;

/* Question 20

Business Question: For accounts acquired via each referral_source, what is the average MRR per account? Which acquisition channel brings the highest-value customers?
Business Objective: Connect marketing spend/channel decisions to actual revenue outcome — a classic "which channel is worth investing in" business question.
Difficulty: Advanced
SQL Concepts Required: JOIN, GROUP BY, AVG(), ORDER BY */
select a.referral_source , avg(s.mrr_amount) as avg_mrr_amount from accounts as a
join subscriptions as s on 
a.account_id = s.account_id 
group by a.referral_source order by avg_mrr_amount desc;

/* 📋 RavenStack SQL Roadmap — Set 3 of 3 (Questions 21–30)

Level: Advanced (Window Functions, CTEs, Subqueries, Ranking, Segmentation, Cohorts)
Question 21
Business Question: Rank all accounts by their total MRR within each industry 
(i.e., who is the #1 revenue account in DevTools, #1 in FinTech, etc.)?
Business Objective: Identify top revenue-generating accounts per segment — useful for account management prioritization.
Difficulty: Advanced
SQL Concepts Required: Window function (RANK() or DENSE_RANK()), PARTITION BY */

with ranks as ( select a.account_id, a.account_name , a.industry,
sum(s.mrr_amount) as mmr_total_ammount
from accounts as a join subscriptions as s 
on a.account_id = s.account_id 
group by a.account_id, a.account_name , a.industry ) , 
top_rank as ( select * , dense_rank() over(partition by industry  order by mmr_total_ammount desc) as ranks_amount  from ranks ) 
select * from top_rank where ranks_amount <= 5;

/* Question 22

Business Question: For each plan tier, find the top 3 highest-paying accounts (by MRR).
Business Objective: Identify VIP customers within each plan tier for account management or case-study purposes.
Difficulty: Advanced
SQL Concepts Required: ROW_NUMBER(), PARTITION BY, subquery/CTE to filter top-N per group
*/

with vip as ( select a.account_id , a.account_name 
,s.plan_tier , sum(s.mrr_amount) as total_amount 
, dense_rank() over(partition by plan_tier order by sum(s.mrr_amount) desc) as ranks from accounts as a join subscriptions as s
on a.account_id = s.account_id group by a.account_id , a.account_name , s.plan_tier ) 
select * from vip where ranks <= 3 ;

/* Question 23

Business Question: Calculate the cumulative (running total) MRR added by new subscriptions, month over month, 
from the start of the dataset to the end.
Business Objective: Visualize business growth trajectory — a classic "hockey stick" SaaS growth chart.
Difficulty: Advanced
SQL Concepts Required: Window function (SUM() OVER (ORDER BY ...)), CTE, DATE_FORMAT */

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS subscription_month,
        SUM(mrr_amount) AS monthly_mrr
    FROM subscriptions
    GROUP BY subscription_month
)
SELECT 
        subscription_month,
        monthly_mrr,
        SUM(monthly_mrr) OVER (ORDER BY subscription_month ASC) AS cumulative_mrr
    FROM monthly_revenue ;

/* Question 24
Business Question: What is the month-over-month percentage growth rate in new subscriptions 
(compare each month's count to the previous month's)?
Business Objective: Measure growth momentum, not just raw counts — critical for identifying acceleration or slowdown.
Difficulty: Advanced
SQL Concepts Required: Window function LAG(), CTE, percentage growth formula */
WITH monthly_subs AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS subscription_month,
        COUNT(subscription_id) AS new_subscriptions
    FROM subscriptions
    GROUP BY subscription_month
), 
monthly_lag AS (
    SELECT 
        subscription_month,
        new_subscriptions,
        LAG(new_subscriptions) OVER (ORDER BY subscription_month) AS previous_month_subs
    FROM monthly_subs
)
SELECT 
    subscription_month,
    new_subscriptions,
    previous_month_subs,
    ROUND(
        ((new_subscriptions - previous_month_subs) * 100.0) / NULLIF(previous_month_subs, 0), 
        2
    ) AS mom_growth_percentage
FROM monthly_lag
ORDER BY subscription_month ASC;

/* Question 25

Business Question: Segment all accounts into "High Value," "Medium Value," and "Low Value" tiers based on their total MRR 
(define your own reasonable thresholds, e.g., using average or quartile logic). How many accounts fall into each segment?
Business Objective: Build a simple customer value segmentation — foundational for targeted retention or upsell campaigns.
Difficulty: Advanced
SQL Concepts Required: CTE, CASE WHEN, subquery (to calculate average/thresholds dynamically)
*/
WITH account_mrr AS (
    SELECT 
        a.account_id,
        a.account_name,
        SUM(s.mrr_amount) AS total_mrr
    FROM accounts a
    JOIN subscriptions s 
        ON a.account_id = s.account_id
    GROUP BY a.account_id, a.account_name
),
segmented_accounts AS (
    SELECT 
        account_id,
        account_name,
        total_mrr,
        CASE 
            WHEN total_mrr >= 25000 THEN 'High Value'
            WHEN total_mrr >= 10000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_segment
    FROM account_mrr
)
SELECT 
    value_segment,
    COUNT(*) AS account_count
FROM segmented_accounts
GROUP BY value_segment
ORDER BY account_count DESC;

/*Question 26

Business Question: Group accounts into signup cohorts by month (e.g., "Jan 2023 cohort," "Feb 2023 cohort").
 What is the churn rate for each signup cohort?
Business Objective: Classic SaaS cohort analysis — do customers who signed up earlier churn at different rates than recent signups?
Difficulty: Advanced
SQL Concepts Required: CTE, DATE_FORMAT, GROUP BY, conditional aggregation */
WITH account_cohorts AS (
    SELECT 
        a.account_id,
        DATE_FORMAT(a.signup_date, '%Y-%m-01') AS signup_cohort,
        a.churn_flag
    FROM accounts a
),
cohort_summary AS (
    SELECT 
        signup_cohort,
        COUNT(*) AS total_accounts_in_cohort,
        SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned_accounts
    FROM account_cohorts
    GROUP BY signup_cohort
)
SELECT 
    signup_cohort,
    total_accounts_in_cohort,
    churned_accounts,
    ROUND(
        (churned_accounts * 100.0) / NULLIF(total_accounts_in_cohort, 0), 
        2
    ) AS cohort_churn_rate_percentage
FROM cohort_summary
ORDER BY signup_cohort ASC;

/*  Question 27

Business Question: Which accounts have an average subscription MRR higher than the overall average MRR across all subscriptions?
Business Objective: Identify above-average-value customers without hardcoding a threshold — a common "find outliers relative to the mean" business ask.
Difficulty: Advanced
SQL Concepts Required: Subquery (scalar subquery in WHERE or HAVING), AVG(), GROUP BY
*/
WITH account_avg_mrr AS (
    SELECT 
        a.account_id,
        a.account_name,
        AVG(s.mrr_amount) AS avg_account_mrr
    FROM accounts a
    JOIN subscriptions s 
        ON a.account_id = s.account_id
    GROUP BY a.account_id, a.account_name
),
global_avg AS (
    SELECT AVG(mrr_amount) AS overall_avg_mrr 
    FROM subscriptions
)
SELECT 
    t.account_id,
    t.account_name,
    t.avg_account_mrr,
    g.overall_avg_mrr
FROM account_avg_mrr t
CROSS JOIN global_avg g
WHERE t.avg_account_mrr > g.overall_avg_mrr
ORDER BY t.avg_account_mrr DESC;
/*Question 28

Business Question: For accounts with more than one subscription record, calculate their total lifetime revenue (sum of MRR across all their subscriptions) and rank them from highest to lowest lifetime value.
Business Objective: Identify highest lifetime-value customers — informs loyalty/retention program targeting.
Difficulty: Advanced
SQL Concepts Required: CTE, HAVING COUNT() > 1, window function RANK()
*/
WITH multi_sub_accounts AS (
    SELECT 
        a.account_id,
        a.account_name,
        COUNT(s.subscription_id) AS total_subscriptions,
        SUM(s.mrr_amount) AS lifetime_mrr_sum
    FROM accounts a
    JOIN subscriptions s 
        ON a.account_id = s.account_id
    GROUP BY a.account_id, a.account_name
    HAVING COUNT(s.subscription_id) > 1
),
ranked_lifetime_value AS (
    SELECT 
        account_id,
        account_name,
        total_subscriptions,
        lifetime_mrr_sum,
        RANK() OVER (ORDER BY lifetime_mrr_sum DESC) as ltv_rank
    FROM multi_sub_accounts
)
SELECT * 
FROM ranked_lifetime_value
ORDER BY ltv_rank ASC;
/*Question 29

Business Question: What is the average customer tenure (in days, from signup_date to churn — or to today if still active) for churned vs. active accounts?
Business Objective: Understand how long customers typically stay before churning — informs early-warning retention triggers.
Difficulty: Advanced
SQL Concepts Required: DATEDIFF(), CASE WHEN, AVG(), conditional aggregation
*/
WITH multi_sub_accounts AS (
    SELECT 
        a.account_id,
        a.account_name,
        COUNT(s.subscription_id) AS total_subscriptions,
        SUM(s.mrr_amount) AS lifetime_mrr_sum
    FROM accounts a
    JOIN subscriptions s 
        ON a.account_id = s.account_id
    GROUP BY a.account_id, a.account_name
    HAVING COUNT(s.subscription_id) > 1
),
ranked_lifetime_value AS (
    SELECT 
        account_id,
        account_name,
        total_subscriptions,
        lifetime_mrr_sum,
        RANK() OVER (ORDER BY lifetime_mrr_sum DESC) as ltv_rank
    FROM multi_sub_accounts
)
SELECT * 
FROM ranked_lifetime_value
ORDER BY ltv_rank ASC;
/* Question 30

Business Question: Build a single "Executive KPI Summary" query that returns in one row: total accounts, active subscriptions, total active MRR, overall churn rate %, and average MRR per account.
Business Objective: Simulate a real executive dashboard request — "give me all the key numbers in one glance" is one of the most common real-world analyst asks.
Difficulty: Advanced
SQL Concepts Required: Multiple subqueries combined in a single SELECT, aggregate functions */
SELECT 
    (SELECT COUNT(*) FROM accounts) AS total_accounts,
    (SELECT COUNT(*) FROM subscriptions WHERE end_date = '' OR end_date IS NULL) AS active_subscriptions,
    (SELECT SUM(mrr_amount) FROM subscriptions WHERE end_date = '' OR end_date IS NULL) AS total_active_mrr,
    (SELECT ROUND((SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) FROM accounts) AS overall_churn_rate_pct,
    (SELECT ROUND(AVG(mrr_amount), 2) FROM subscriptions WHERE end_date = '' OR end_date IS NULL) AS avg_active_mrr_per_sub;


