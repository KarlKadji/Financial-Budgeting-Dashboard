-- Exploratory Data Analysis

-- What is the monhtly spending?
with monthly_spending as (
select date_format(`transdate`, '%Y-%m') as Month, sum(amount) as Spending
from expenses
group by month
)

select month, spending, 
(select avg(spending) from monthly_spending) as average_spending
from monthly_spending
order by month;



-- What percentage of the monthly income goes to non-essential spending?

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
    ROUND((ne.non_essential_spending / i.income) * 100, 2) AS non_essential_percentage,
    e.essential_spending,
    ROUND((e.essential_spending / i.income) * 100, 2) AS essential_percentage,
    ROUND(((IFNULL(ne.non_essential_spending, 0) + IFNULL(e.essential_spending, 0)) / i.income) * 100, 2) AS total_spending_percentage
FROM monthly_income i
LEFT JOIN monthly_non_essentials ne 
ON i.month = ne.month
left join monthly_essentials e
on i.month = e.month
ORDER BY i.month;



-- Are there any unecessary expenses that can be cut?
WITH categorized AS (
    SELECT *,
        CASE
            WHEN category IN ('Health', 'Car', 'Home', 'Transportation', 'Bills', 'Financial Institution', 'Visa') 
                OR `sub-category` = 'Grocery' THEN 'Essential'
            ELSE 'Non-Essential'
        END AS category_type
    FROM expenses
)
SELECT category, `sub-category`, SUM(amount) AS total_spending
FROM categorized
WHERE category_type = 'Non-Essential'
GROUP BY category, `sub-category`
ORDER BY total_spending DESC
LIMIT 10;


-- Has the spending increased or decreased since January?

select date_format(`transdate`, '%Y-%m') as Month, sum(amount) as Spending
from expenses
where year(transdate) = 2025
group by month
order by month;

