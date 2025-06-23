-- Income vs Expenses
/* What is the monthly trend of income and expenses? Are there any surplus or deficit months?
what is the overall savings rate over the time period?
Are there any months where expenses exceeded income? Why?
*/

-- calculating the monthly income, earning, savings, and average income and earnings
with monthly_spending as (
select date_format(transdate, '%Y-%m') as month,
sum(amount) as spending
from oexpenses
group by month),

monthly_income as (
select date_format(date, '%Y-%m') as month,
sum(amount) as earnings
from income2
group by month)

select s.month,
 spending, 
 round(avg(spending) over () ,2) as average_spending, 
 earnings, 
 round(avg(earnings) over () ,2) as average_earnings, 
 earnings-spending as 'savings'
from monthly_spending s
join monthly_income i
on i.month = s.month
order by month;

-- filtering the table to see specific transactions made in specific months for further analysis
select * from income2 where `date` between '2024-07-01' AND '2024-08-01';
select * from oexpenses where `transdate` between '2024-10-01' AND '2024-12-01';
select * from income2 where `date` >= '2025-01-01';
select * from oexpenses where `transdate` between '2025-05-01' AND '2025-07-01';

-- Calculating the monthly salary income, the average salary income, and the percentage difference between the two
WITH monthly_income AS (
  SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month,
    SUM(amount) AS income
  FROM income2
  WHERE `sub-category` = 'salary'
  GROUP BY month
)
SELECT 
  month,
  income,
  ROUND(AVG(income) OVER (), 2) AS avg_income,
  ROUND(income / AVG(income) OVER () * 100-100, 2) AS percent_diff
FROM monthly_income;


-- What percentage of the monthly income goes to essential vs non-essential spending?

with monthly_income as 
(
	select
		date_format(date, '%Y-%m') as month,
        sum(amount) as income
	from income2
    group by month
    ),

monthly_non_essentials as (
select
	date_format(transdate, '%Y-%m') as month, 
    sum(amount) as non_essential_spending
from expenses
where NOT (category IN ('Health', 'Car', 'Home', 'Transportation', 'Bills', 'Financial Institution', 'Visa') OR `sub-category` = 'Grocery')
group by month
),

monthly_essentials as (
select
		date_format(transdate, '%Y-%m') as month, 
        sum(amount) as essential_spending
        from expenses
		where category in ('Health', 'Car', 'Home', 'Transportation', 'Bills', 'Financial Institution', 'Visa') or `sub-category` = 'Grocery'
group by month
)
select
    i.month,
    i.income,
    ne.non_essential_spending,
    e.essential_spending,
    ROUND((ne.non_essential_spending / i.income) * 100, 2) AS non_essential_percentage,
    ROUND((e.essential_spending / i.income) * 100, 2) AS essential_percentage,
    ROUND(((IFNULL(ne.non_essential_spending, 0) + IFNULL(e.essential_spending, 0)) / i.income) * 100, 2) AS total_spending_percentage
FROM monthly_income i
LEFT JOIN monthly_non_essentials ne 
ON i.month = ne.month
left join monthly_essentials e
on i.month = e.month
ORDER BY i.month;

/* Spending Analysis
What are the top 5 expense categories by total spend?
How does spending vary by sub-category?
Are there any seasonal patterns in spending?
*/

-- calculating the top 5 expense categories
select 
	category, 
	sum(amount) as total 
from 
	oexpenses 
group by 
	category 
    order by 
		total desc
limit 5;


-- filtering to see the sub-categories' total expenditures and comparing it to the expected yearly expenditures
select 
	`sub-category`, 
	sum(amount) as total, 
    avg(amount) as avg_expenditure, 
    avg(amount)*12 as ex_yearly_exp,
    sum(amount)-avg(amount)*12 as diff
from 
	oexpenses 
group by 
	`sub-category` 
    order by 
		total desc
;


-- filtering the data to see total expenditures per seasons, the number of transactions, and the average transaction per seasons

WITH transactions_with_season AS (
  SELECT *,
    CASE 
      WHEN MONTH(transdate) IN (12, 1, 2) THEN 'Winter'
      WHEN MONTH(transdate) IN (3, 4, 5) THEN 'Spring'
      WHEN MONTH(transdate) IN (6, 7, 8) THEN 'Summer'
      WHEN MONTH(transdate) IN (9, 10, 11) THEN 'Fall'
    END AS season
  FROM oexpenses
)
SELECT 
  season,
  SUM(amount) AS total_spent,
  COUNT(*) AS num_transactions,
  ROUND(AVG(amount), 2) AS avg_transaction
FROM transactions_with_season
GROUP BY season
ORDER BY FIELD(season, 'Winter', 'Spring', 'Summer', 'Fall');



-- Time Based Patterns
-- How do average weekly expenses look over time?

-- filtering the data to show me total weekly spending and the amount of the average transaction in that week
SELECT
  year,
  week_number,
  week_start,
  DATE_ADD(week_start, INTERVAL 6 DAY) AS week_end,
  CONCAT(
    DATE_FORMAT(week_start, '%Y-%m-%d'),
    ' - ',
    DATE_FORMAT(DATE_ADD(week_start, INTERVAL 6 DAY), '%Y-%m-%d')
  ) AS week_range,
  SUM(amount) AS total_spent,
  AVG(amount) AS avg_spent
FROM (
  SELECT 
    YEAR(transdate) AS year,
    WEEK(transdate, 1) AS week_number,
    DATE_SUB(transdate, INTERVAL WEEKDAY(transdate) DAY) AS week_start,
    amount
  FROM oexpenses
) AS derived
GROUP BY year, week_number, week_start
ORDER BY year, week_number;

-- filtering the data to see daily average spending
SELECT 
    transdate,
    AVG(amount) AS avg_daily_expense
FROM expenses
GROUP BY transdate
ORDER BY transdate;



/* Income Breakdown
What are the sources of income and how consistent are they?
Is any income source irregular or declining?
*/

select * from income2;
select distinct category, sum(amount) from income2 group by category;
select category, sum(amount) from income2 group by category;
select `sub-category`, sum(amount) from income2 where category = 'Government' group by `sub-category`;

select * from income2 where category = 'Pay';
select * from income2 where category = 'Government';
select * from income2 where category = 'Debt';
