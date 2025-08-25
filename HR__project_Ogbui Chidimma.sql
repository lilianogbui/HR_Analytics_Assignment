-- Clean dataset and assign salaries
WITH EmpClean AS (
    SELECT
        id,
        first_name,
        last_name,
        TRY_CAST(birthdate AS DATE) AS birthdate,
        gender,
        race,
        department,
        jobtitle,
        location,
        TRY_CAST(hire_date AS DATE) AS hire_date,
        TRY_CAST(termdate AS DATE) AS termdate,
        location_city,
        location_state,
        CASE 
            WHEN jobtitle LIKE '%Manager%' THEN 80000
            WHEN jobtitle LIKE '%Director%' THEN 100000
            WHEN jobtitle LIKE '%Engineer%' THEN 75000
            WHEN jobtitle LIKE '%Analyst%'  THEN 60000
            WHEN jobtitle LIKE '%Sales%'    THEN 55000
            ELSE 50000
        END AS salary,
        CASE 
            WHEN jobtitle LIKE '%Manager%'  THEN 'Exceeds Expectations'
            WHEN jobtitle LIKE '%Director%' THEN 'Outstanding'
            WHEN jobtitle LIKE '%Engineer%' THEN 'Meets Expectations'
            WHEN jobtitle LIKE '%Analyst%'  THEN 'Needs Improvement'
            ELSE 'Meets Expectations'
        END AS performance_score
    FROM hr_cleaned
),

-- Add calculated fields
EmpSnap AS (
    SELECT
        *,
        DATEDIFF(YEAR, birthdate, GETDATE()) AS age_years,
        DATEDIFF(DAY, hire_date, ISNULL(termdate, GETDATE())) / 365.0 AS tenure_years,
        CASE 
            WHEN termdate IS NULL THEN 'Active' 
            ELSE 'Terminated' 
        END AS employment_status
    FROM EmpClean
),

-- Monthly hires
HiresByMonth AS (
    SELECT 
        FORMAT(hire_date, 'yyyy-MM') AS ym,
        COUNT(*) AS hires
    FROM EmpClean
    GROUP BY FORMAT(hire_date, 'yyyy-MM')
),

-- Monthly terminations
TermsByMonth AS (
    SELECT 
        FORMAT(termdate, 'yyyy-MM') AS ym,
        COUNT(*) AS terms
    FROM EmpClean
    WHERE termdate IS NOT NULL
    GROUP BY FORMAT(termdate, 'yyyy-MM')
),

-- Build full calendar of months from hires + terms
Months AS (
    SELECT ym FROM HiresByMonth
    UNION
    SELECT ym FROM TermsByMonth
),

-- Headcount calculation
HeadcountByMonth AS (
    SELECT
        m.ym,
        ISNULL(h.hires,0) AS hires,
        ISNULL(t.terms,0) AS terms,
        SUM(ISNULL(h.hires,0) - ISNULL(t.terms,0)) 
            OVER (ORDER BY m.ym ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS headcount
    FROM Months m
    LEFT JOIN HiresByMonth h ON m.ym = h.ym
    LEFT JOIN TermsByMonth t ON m.ym = t.ym
),

-- Retention & Turnover
MonthlyRates AS (
    SELECT
        ym,
        hires,
        terms,
        headcount,
        CASE 
            WHEN headcount > 0 THEN CAST(terms AS DECIMAL(10,2)) / headcount 
            ELSE 0 
        END AS turnover_rate,
        CASE 
            WHEN headcount > 0 THEN 1 - CAST(terms AS DECIMAL(10,2)) / headcount 
            ELSE 0 
        END AS retention_rate
    FROM HeadcountByMonth
),

-- Salary and Performance
PerfSalarySummary AS (
    SELECT
        department,
        performance_score,
        employment_status,
        COUNT(*) AS employee_count,
        AVG(salary) AS avg_salary,
        AVG(tenure_years) AS avg_tenure
    FROM EmpSnap
    GROUP BY department, performance_score, employment_status
)

-- Final Report
SELECT
    (SELECT COUNT(*) FROM EmpSnap WHERE employment_status = 'Active')     AS total_active,
    (SELECT COUNT(*) FROM EmpSnap WHERE employment_status = 'Terminated') AS total_terminated,
    (SELECT AVG(tenure_years) FROM EmpSnap)                               AS avg_tenure_years,
    (SELECT AVG(age_years) FROM EmpSnap)                                  AS avg_age_years,
    (SELECT AVG(salary) FROM EmpSnap)                                     AS avg_salary_overall,
    ps.department,
    ps.performance_score,
    ps.employment_status,
    ps.employee_count,
    ps.avg_salary,
    ps.avg_tenure,
    mr.ym,
    mr.hires,
    mr.terms,
    mr.headcount,
    mr.turnover_rate,
    mr.retention_rate
FROM PerfSalarySummary ps
CROSS JOIN MonthlyRates mr
ORDER BY mr.ym DESC, ps.department, ps.performance_score, ps.employment_status;
