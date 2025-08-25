 HR Data Analysis with SQL + power bi

 Project Overview

This project demonstrates end-to-end HR analytics:
The main goals are:

* Prepare a **clean and structured dataset** for reporting.
* Analyze **employee performance, retention, and salaries**.
* Use **CTEs, JOINs, and Window Functions** for efficient SQL design.
* power BI dashbord for interactive insights.
  
The dashboard helps HR leaders answer:

What is our employee retention rate?

How do salaries vary across departments?

Which departments have the highest turnover?

What is the distribution of performance scores?

How does tenure relate to termination risk?


The HR dataset contains:

* Employee personal details (ID, name, gender, race, birthdate).
* Job details (department, job title, hire date, termination date).
* Location details (city, state, remote vs HQ).

Data Preparation in SQL

All data transformations were done in SQL before loading into Power BI.

Key steps included:

Converting text columns (birthdate, hire_date, termdate) into DATE.

Creating derived columns: age_years, tenure_years, employment_status.

Assigning salary bands based on job titles.

Mapping performance scores by role

Key Metrics Produced

* **Performance Distribution** → Employee ratings by department.
* **Retention Rate** → Active vs Terminated employees.
* **Salary Analysis** → Average, minimum, and maximum salaries by department.
* **Tenure & Age Insights** → Average employee tenure and age.


Key Insights on the dashboard

Departments with higher average salaries tend to have lower turnover.

Most terminations occur within the first 2 years of tenure.

Performance ratings cluster in "Meets Expectations", with leadership roles skewing higher.

Workforce is unevenly distributed across race and gender, suggesting diversity gaps.

Tools & Technologies

SQL Server / PostgreSQL → Data Cleaning, Structuring, KPIs

Power BI → Interactive Dashboard

CTEs, Window Functions, Joins → Core SQL methods used.
