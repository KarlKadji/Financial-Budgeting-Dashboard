# Overview

This Financial Budgeting Dashboard Project focuses on analyzing and optimizing 2024/2025 personal financial data through a structured approach encompassing data cleaning, exploratory data analysis (EDA), and interactive visualization. The initial phase involves meticulously preparing raw financial data by backing it up, refining columns, handling missing values, and ensuring data consistency. Subsequently, the EDA phase delves into the cleaned data to extract key insights, such as total and average monthly financials, essential versus non-essential expense breakdowns, and spending trends, aiming to pinpoint major spending areas and potential savings. Finally, a Personal Budgeting Dashboard consolidates these findings into actionable visualizations, showcasing income, expenses, savings, and key spending categories to empower informed budgeting decisions.


# The Questions

Below are the questions I want to answer in my project:

1. What are the monthly trends in income and expenses, including the overall savings rate, and were there any months where expenses resulted in a deficit?
2. What percentage of the monthly income goes to essential vs non-essential spending?
3. What are the top 5 overall expense categories, how does spending differ within sub-categories, and do any seasonal patterns emerge in expenditures?
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

View my SQL file with detailed steps here: [2_Skill_Demand.ipynb](3_Project/2_Skills_Demand.ipynb)

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

View my SQL file with detailed steps here: [2_Skill_Demand.ipynb](3_Project/2_Skills_Demand.ipynb)

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
- As expected, the line graph representing the likelihood of skills requested in data-related Canadian job postings shows consistency, with SQL, Python, and Excel being the top three skills for Data Analysts in Canada.

- SQL is clearly the most in-demand skill, maintaining above 50% likelihood in postings throughout the year. A noticeable peak in September suggests a surge in demand during the fall hiring cycle.

- Python ranks second in demand, with steady interest between 30–40%. Like SQL, it experiences minor fluctuations but no significant decline, indicating stable and potentially growing demand.

- Excel, Tableau, and Power BI are closely competing. Tableau shows notable spikes in May and September, possibly tied to project or reporting cycles. The monthly variability seen across these three tools suggests that they are more role-specific or industry-dependent in their demand.


## 3. How well do jobs and skill pay for Data Analysts?

To identify the highest-paying roles and skills, I only got jobs in Canada and looked at their median salary. But first I looked at the salary distributions of common data jobs like Data Scientist, Data Engineer, and Data Analyst, to get an idea of which jobs are paid the most.

View my SQL file with detailed steps here: [2_Skill_Demand.ipynb](3_Project/2_Skills_Demand.ipynb)

### Visualize Data
```python
sns.boxplot(data = df_US, x='salary_year_avg', y='job_title_short', order = job_order)

ticks_x = plt.FuncFormatter(lambda y, pos: f'${int(y/1000)}K')

plt.gca().xaxis.set_major_formatter(ticks_x)

plt.show()
```

### Results

![Salary Distribution in Canada](3_Project/images/salary_distibution_in_canada.png)


*Box plot visualizing the salary distribution for various data tech positions in Canada in 2023*

### Insights
- Median salaries tend to increase with seniority and specialization. Senior roles, such as Senior Data Engineer, not only command higher median salaries but also show greater variability in compensation, reflecting wider salary differences as responsibilities and expertise grow.
- Data Analysts have the lowest median salary among the top six roles. This aligns with expectations, as higher-paying positions typically require more specialized technical skills in areas like machine learning, cloud engineering, or advanced data modeling.
- Roles with higher outliers—such as Machine Learning Engineer and Senior Data Engineer—indicate that top performers or professionals in leading companies can earn significantly above the median. Meanwhile, Data Analysts exhibit a much lower outlier range, suggesting limited salary spikes even at senior levels.

## Highest Paid & Most Demanded Skills for Data Analysts

Next, I narrowed my analysis and focused only on data analyst roles. I looked at the highest-paid skills and the most in-demand skills. I used two horizontal bar charts to showcase these.
### Visualize Data
```python
fig, ax = plt.subplots(2,1)

# Top 10 Paid SKills for Data Analysts
sns.barplot(data=df_DA_toppay, x='median', y=df_DA_toppay.index, ax=ax[0], hue='median', palette= 'dark:b_r')

# Top 10 Most In-Demand Skills for Data Analysts
sns.barplot(data=df_DA_skills, x='median', y=df_DA_skills.index, ax=ax[1], hue='median', palette= 'light:b')
ax[1].legend().remove()

plt.show()
```

### Results

![Salary Distribution in Canada](3_Project/images/skills_vs_pay.png)


*Horizontal Bar Charts visualizing the Top 10 Highest Paid Skills for Data Analysts in Canada in 2023*

### Insights
- Most of the highest paid skills are not the most in-demand skills for data analysts in Canada. Similarly, many high-demand skills are not among the highest paying. This suggests that niche skills—those less commonly required—may offer higher salaries due to their specialization and lower supply in the job market.

- Skills such as Snowflake and Spark are particularly valuable because they are both highly paid and highly in demand. While foundational tools like Python, SQL, and Excel may not top the salary charts, they remain essential for breaking into the field and improving job prospects.

- Cloud and Big Data tools—such as Redshift, Snowflake, BigQuery, AWS, and GCP—feature prominently among the highest-paid skills. This highlights the strong earning potential for data analysts who specialize in modern data infrastructure.





## 4. What are the most optimal skills to learn for Data Analysts?

To identify the most optimal skills to learn (the ones that are the highest paid and highest in demand) I calculated the percent of skill demand and the median salary of these skills. To easily identify which are the most optimal skills to learn.

### Visualize Data
```python
import matplotlib.pyplot as plt
from adjustText import adjust_text

sns.scatterplot(
    data=df_plot,
    x='skill_percent',
    y='median_salary',
    hue='technology'
)
plt.show()
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
