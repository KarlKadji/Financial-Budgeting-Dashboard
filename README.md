# Overview

This Financial Budgeting Dashboard Project focuses on analyzing and optimizing 2024/2025 personal financial data through a structured approach encompassing data cleaning, exploratory data analysis (EDA), and interactive visualization. The initial phase involves meticulously preparing raw financial data by backing it up, refining columns, handling missing values, and ensuring data consistency. Subsequently, the EDA phase delves into the cleaned data to extract key insights, such as total and average monthly financials, essential versus non-essential expense breakdowns, and spending trends, aiming to pinpoint major spending areas and potential savings. Finally, a Personal Budgeting Dashboard consolidates these findings into actionable visualizations, showcasing income, expenses, savings, and key spending categories to empower informed budgeting decisions.


# The Questions

Below are the questions I want to answer in my project:

1. What are the monthly trends in income and expenses, including the overall savings rate, and were there any months where expenses resulted in a deficit?
2. What percentage of the monthly income goes to essential vs non-essential spending?
3. What are the top 5 overall expense categories? How does spending differ within sub-categories, and do any seasonal patterns emerge in expenditures?
4. How do average weekly expenses look over time?
5. What are the various sources of income, and how consistent are they, specifically identifying any irregular or declining contributions?
6. Are there any unnecessary expenses that can be cut?


# Tools I used

For my deep dive into the financial budgeting data, I harnessed the power of several key tools:

- **SQL**: The main analysis tool used to clean and analyze the data. I used the following SQL techniques:
  - **CTE's**
  - **Window Functions**
  - **Date and Time Functions**
  - **Conditional Logic**
  - **Data Type Conversion and String Manipulation**
  - **Table Operations and Schema Definitions**
  - **Joins**

 - **Power BI**: Served as the primary tool for visualizing the data.


# Data Preparation and Cleanup
This section outlines the steps taken to prepare the data for analysis, ensuring accuracy and usability.

## Import & Clean Up Data

The data cleaning process was crucial for ensuring the accuracy and usability of the financial data, involving several key steps across both the expense and income datasets. It began by creating backup tables for both expenses (oexpenses from my finances) and income (income2 from income) to preserve the original raw data.

For a comprehensive, in-depth view of the cleaning process, including detailed SQL code, please refer to the provided link: [Financial Budgeting Dashboard (Cleaning)](Financial_Budgeting_Dashboard_(Cleaning).sql)

### Created backup tables

* Created Backup Tables: To work safely without altering the original raw data, duplicate tables were created for both 'my finances' (aliased as expenses) and income (aliased as income2). This involved dropping the tables if they already existed, then creating new tables with the same structure and inserting all data from the originals.

```SQL
drop table if exists expenses;

create table expenses
like `my finances`;

insert into expenses
select * from `my finances`;
```
```SQL
drop table if exists income2;

create table income2
like income;

insert into income2
select * from income;
```

## Cleaning the "expenses" table

For the expenses table, critical steps included: 
* Removing irrelevant header and footer rows
* Renaming generic columns to descriptive names like date, category, and amount
* Replacing blank values with NULL for consistency
* Meticulously converting the date and amount columns to proper DATE and DECIMAL(10,2) data types respectively, which involved removing symbols like '$' and ','.
* Standardized transaction descriptions using a temporary mapping table to ensure consistent naming for recurring purchases.
* Added Primary Key: An id column with AUTO_INCREMENT and PRIMARY KEY constraints was added to 'oexpenses'.
* Reordered the expenses table to have the ID column match the dates and renamed it 'oexpenses'.
  * This is the table that was used for EDA moving forward.

## Cleaning the "income2" table

Similarly, the income2 table underwent essential cleaning which involved: 
* Renaming columns
* Removing irrelevant rows (such as 'Total Income' and 'Net Total')
* Converting the amount to DECIMAL(10,2)
* Transforming the date column into a proper DATE format
* Added Primary Key: An id column with AUTO_INCREMENT and PRIMARY KEY constraints was added to income2.



# The Analysis

Each question addressed in this project is documented and explained in detail within the Financial Budgeting Project (EDA) file. A concise summary of the analytical approach taken to answer each question is provided below.

## 1. What are the monthly trends in income and expenses, including the overall savings rate, and were there any months where expenditures resulted in a deficit?

To analyze trends in monthly income, expenses, and savings, I used SQL to create summary tables for each month’s total income and total spending. These were joined to calculate monthly savings (income minus expenses), allowing me to identify months with surpluses or deficits. I also included average income and spending across all months to better understand how each month compared to overall financial trends.

View my SQL file with detailed steps here: [Financial Budgeting Dashboard (EDA)](Financial_Budgeting_Dashboard_(EDA).sql)

### Visualize Data
```SQL
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
```

### Results
![Monthly Trend of Income and Expenses](3_Project/images/skill_demand_all_data_roles.png)

*Table visualizing the monthly trend of income, expenses and savings*

### Insights

* **Income fluctuations:** Income peaked in July 2024 (33.47% above average) due to insurance reimbursements and a likely bonus or overtime. November 2024 also exceeded average income by 24.64%, while months like October and December 2024 fell significantly below average (−16.85% and −16.93%, respectively), indicating financial volatility across the period.

* **Expense patterns and deficits:** October and November 2024 saw the highest spending, driven by major one-time purchases (e.g., clothing, gifts, music-related costs) and inconsistent rent inclusion. October, in particular, resulted in a large deficit due to high expenses and one of the lowest monthly incomes, highlighting a misalignment between earnings and outflows.

* **Impact of unemployment:** A drop in income in early 2025, combined with the appearance of Employment Insurance (EI), suggests job loss. Although March showed spending restraint, other months during this period did not reflect significant cutbacks, with elevated expenses contributing to sustained deficits despite reduced income.

* **Savings behavior:** The seven months with below-average spending generally coincided with months where savings were recorded. July 2024 saw the largest savings due to both increased income and moderate spending. However, October and early 2025 emphasize the financial strain caused when spending fails to adjust in tandem with declining income.





## 2. What percentage of the monthly income goes to essential vs non-essential spending?

To assess how income was distributed between essential and non-essential spending, I used SQL to calculate monthly income and categorize expenses accordingly. I then compared each spending type to total income to find their respective percentages, giving a clear view of monthly budgeting priorities.

View my SQL file with detailed steps here: [Financial Budgeting Dashboard (EDA)](Financial_Budgeting_Dashboard_(EDA).sql)

### Visualize Data
```SQL
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
```

### Results

![Essential vs Non-Essential Spending Percentages](3_Project/images/top_skills_trend.png)

*Line graph visualizing the monthly percentage of essential and non-essential spending compared to monthly income*

### Insights
* **On average, approximately 27.46% of your monthly income goes towards non-essential spending.**
* **On average, approximately 72.28% of your monthly income goes towards essential spending.**

* Non-Essential Spending Fluctuations:
	* Non-essential spending percentage varies widely from low (~7% in May 2025) to very high (~61% in October 2024), suggesting irregular discretionary spending patterns. Peaks in non-essential spending coincide with high overall spending months.

* Essential Spending Consistently High:
 	* Essential spending percentage often represents a large share of income, regularly above 60% after September 2024. Some months exceed 100% (May, June 2025), showing essential expenses alone are greater than monthly income, which may signal financial stress or misclassification.






## 3. What are the top 5 overall expense categories? How does spending differ within sub-categories, and do any seasonal patterns emerge in expenditures?

To answer the question, I first used a query to identify the top 5 expense categories by total spending. Then, I analyzed sub-categories by comparing their total and average monthly expenditures to estimate expected yearly spending and detect variances. Lastly, I used seasonal groupings based on transaction dates to assess total spend, transaction counts, and average transaction sizes across seasons, revealing spending patterns over the year.

View my SQL file with detailed steps here: [Financial Budgeting Dashboard (EDA)](Financial_Budgeting_Dashboard_(EDA).sql)

### Visualize Data
```SQL
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
```

### Results

![Salary Distribution in Canada](3_Project/images/salary_distibution_in_canada.png)


*Box plot visualizing the salary distribution for various data tech positions in Canada in 2023*

### Insights
* Top spending categories were Bills, Retail and Grocery, Car, Entertainment, and Health, indicating essential and lifestyle-related expenses dominate the budget.
* Sub-category analysis revealed overspending in areas like Maintenance, Music, and Eating Out, while categories like Rent and Phone showed under or stable spending relative to expectations.
* Seasonal patterns emerged, with Fall showing the highest total spend and transaction volume—suggesting increased costs from events or holidays—while Summer had more frequent but smaller purchases.
* Spending behavior varies significantly, with some categories reflecting consistent, planned expenses and others showing irregular or seasonal spikes, highlighting areas for budgeting improvement.





## 4. How do average weekly expenses look over time?

To answer the question, I first used a query to identify the top 5 expense categories by total spending. Then, I analyzed sub-categories by comparing their total and average monthly expenditures to estimate expected yearly spending and detect variances. Lastly, I used seasonal groupings based on transaction dates to assess total spend, transaction counts, and average transaction sizes across seasons, revealing spending patterns over the year.

View my SQL file with detailed steps here: [Financial Budgeting Dashboard (EDA)](Financial_Budgeting_Dashboard_(EDA).sql)

### Visualize Data
```SQL
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
```

### Results

![Salary Distribution in Canada](3_Project/images/salary_distibution_in_canada.png)


*Box plot visualizing the salary distribution for various data tech positions in Canada in 2023*

### Insights

* Spending fluctuates significantly week to week, with some weeks like Week 48 (Nov 25–Dec 1, 2024) and Week 40 (Sep 30–Oct 6, 2024) showing exceptionally high totals over $1,900, while others like Week 52 (Dec 23–29, 2024) are under $100.

* The most expensive weeks overall include:

	* Week 48 (2024/11/25 - 2024/12-01): $2,027.65

	* Week 40 (2024/09/30 - 2024/10/06): $1,960.89

	* Week 5 (2025/01/27 - 2025/02/02): $1,789.87

	* Week 24 (2025/06/09 - 2025/06/15): $1,536.93

	* Week 23 (2025/06-02 - 2025/06/08): $1,350.03
   
* These weeks likely involve major events, bills, or one-time purchases.

* Late summer and fall (weeks 32–44) show generally higher and more consistent spending, suggesting increased activity during this period—possibly related to back-to-school or seasonal events.

* Early winter (weeks 50–52) shows a steep drop in spending, despite the holiday season, which could indicate pre-holiday bulk purchases or a spending pause.

* 2025 has had several high-spending spikes (e.g., Weeks 5, 14, 19, 23–24), but also consistent low-spending weeks, pointing to an irregular but recoverable financial rhythm.

* The highest single average daily spending occurred in Week 1 of 2025 ($524.50), suggesting a large, concentrated expense—possibly rent, travel, or a lump payment.




## 5. What are the various sources of income, and how consistent are they, specifically identifying any irregular or declining contributions?

To identify the most optimal skills to learn (the ones that are the highest paid and highest in demand) I calculated the percent of skill demand and the median salary of these skills. To easily identify which are the most optimal skills to learn.

View my SQL file with detailed steps here: [Financial Budgeting Dashboard (EDA)](Financial_Budgeting_Dashboard_(EDA).sql)

### Visualize Data
```SQL
select category, sum(amount) from income2 group by category;
```

### Results

![Most Optimal Skills for Data Analysts in Canada](3_Project/images/optimal_skills.png)


*Scatter Plot visualizing the most optimal skills for data analysts categorized by technology in Canada in 2023*

### Insights
- As an entry-level Data Analyst in 2023 in Canada, programming languages such as SQL and Python are the most optimal skills to aquire because although the salaries are just under $100K they are often in high-demand appearing in 50%+ of job postings. This indicates that the skills are foundational and expected. Mid-to-Senior Analysts aiming for higher salaries should consider learning Snowflake, Spark, BigQuery or Azure which are less common but highly compensated.
- Analyst Tools such as Excel and Tableau have a decent demand being in 20-40% of job postings but have a low median salary. These tools are often used in reproting heavy or junior roles and may not command higher pay unless combined with more technical skills.
- Cloud skills are the most profitable as they tend to be required for job postings with salaries on the higher end of what is offered, however, they have a low demand. This suggests they are specialized skills that are not needed by all employers but highly values by those who require them.

# What I learned
Throughout this project, I deepened my understanding of the data analyst job market and enhanced my technical skills in Python, especially in data manipulation and visualization. Here are a few specific things I learned:


- **Advanced Python Usage**: Utilizing libraries such as Pandas for data manipulation, Seaborn and Matplotlib for data visualization, and other libraries helped me perform complex data analysis tasks more efficiently.

- **Data Cleaning Importance**: I learned that thorough data cleaning and preparation are crucial before any analysis can be conducted, ensuring the accuracy of insights derived from the data.

- **Strategic Skill Analysis**: The project emphasized the importance of aligning one's skills with market demand. Understanding the relationship between skill demand, salary, and job availability allows for more strategic career planning in the tech industry.

# Insights

This project provided several general insights into the data job market for analysts:

- **Skill Demand and Salary Correlation**: There is a clear correlation between the demand for specific skills and the salaries these skills command. Advanced and specialized skills like Python and Oracle often lead to higher salaries.
- **Market Trends**: There are changing trends in skill demand, highlighting the dynamic nature of the data job market. Keeping up with these trends is essential for career growth in data analytics.
- **Economic Value of Skills**: Understanding which skills are both in-demand and well-compensated can guide data analysts in prioritizing learning to maximize their economic returns.

# Challenges I Faced

This project was not without its challenges, but each obstacle provided valuable learning opportunities that strengthened both my technical and analytical skills:

- **Data Inconsistencies**: Handling missing, duplicated, or inconsistent entries required careful attention and thorough data-cleaning techniques to maintain the integrity of the analysis.

- **Complex Data Visualization**: Designing visualizations that were not only accurate but also intuitive and visually engaging proved challenging—especially when trying to represent multi-dimensional data in a clear, impactful way.

- **Balancing Breadth and Depth**: Deciding how deep to go into each analysis, while still keeping a broad overview of the job market landscape, required constant judgment to avoid losing focus or missing key insights.

- **Tool Familiarity Gaps**: As someone new to the tech and data field, I occasionally encountered roadblocks related to unfamiliar Python functions or visualization libraries, which required extra time for self-directed learning and troubleshooting.

- **Interpretation Bias**: Making sure my conclusions were based on data—not assumptions—was an important discipline, especially when patterns seemed to align with what I expected. Cross-checking insights helped maintain objectivity.

- **Time Management**: Working through a full analysis pipeline—data collection, cleaning, analysis, visualization, and interpretation—required careful planning to avoid getting stuck too long on any single stage.

# Conclusion

This exploration into the data analyst job market has been incredibly informative, highlighting the critical skills and trends that shape this evolving field. The insights I gained not only deepened my technical expertise in Python, data manipulation, and visualization but also clarified the strategic importance of aligning technical skills with real-world market demand.

As someone new to the tech and data industry, this project gave me the confidence that I’m heading in the right direction—especially by choosing to focus on Python, a highly demanded and versatile language, instead of less-requested tools like R. It also helped me understand the growing relevance of cloud-based technologies such as Snowflake, BigQuery, and Azure, which offer strong salary potential and are becoming increasingly valuable in modern data environments.

Looking forward, once I’ve gained more hands-on experience as a data analyst, I intend to tailor my learning toward both tools required by my future employer and high-impact, specialized skills like those used in big data and cloud platforms.

This project serves as a solid foundation for future explorations and underscores the importance of continuous learning, skill adaptability, and proactive market analysis for long-term success in the data field.
