Select *
from Table1;

Select *
from Table2;

--Join clinical and lesion data for effective skin cancer analysis.

Select *
from Table1 T1
inner join Table2 T2
on T1.patient_id = T2.patient_id; 

--DEMOGRAPHIC QUESTIONS
--DEMOGRAPHIC ANALYSIS

--1. Age distribution of cancer patients
--What is the age distribution of patients with skin cancer?

SELECT 
    CASE
        WHEN age < 30 THEN 'Youth'
        WHEN age BETWEEN 30 AND 45 THEN 'Adult'
         WHEN age BETWEEN 46 AND 66 THEN 'Older_Adult'
		 ELSE 'Elderly'
    END AS age_group,
     COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 
ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY age_group
ORDER BY age_group;

--2. Which gender has more diagnosed skin cancer cases?

SELECT
t1.gender,
COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 
ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.gender;

--3. Does family history of cancer increase risk?
--Family history impact

SELECT
t1.cancer_history, 
COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.cancer_history;

--4. Do patients with previous skin cancer have higher recurrence?
--Previous skin cancer risk

SELECT 
t1.skin_cancer_history, 
COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.skin_cancer_history;

--Environmental Risk Factors

--5. Does pesticide exposure increase cancer likelihood?

SELECT 
t1.pesticide, 
COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.pesticide;

--6. Does access to piped water or sewage system affect diagnosis rates?

SELECT 
	t1.has_piped_water, 
	t1.has_sewage_system,
     COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.has_piped_water, t1.has_sewage_system;

--7. Is there a relationship between alcohol/smoking and cancer?
--Lifestyle impact

SELECT
	t1.smoke, 
	t1.drink, 
	COUNT(*) AS total_cases
FROM table1 t1
JOIN table2 t2 
ON t1.patient_id = t2.patient_id
WHERE t2.biopsed = TRUE
GROUP BY t1.smoke, t1.drink;

--C. Lesion Characteristics
--8. What is the most common type of lesion (diagnostic)?

SELECT
	diagnostic, 
COUNT(*) AS total_cases,
	case
		when diagnostic in ('BCC', 'SCC', 'MEL') then 'Cancerous'
		when diagnostic = 'ACK' then 'Precancerous'
		else 'Benign' 
		end as lesion_group
FROM table2
GROUP BY diagnostic
ORDER BY total_cases DESC;

--9. Are cancerous lesions larger in size?
--Compare diameter values
--lesion size vs cancer

SELECT 
    CASE 
        WHEN biopsed = TRUE THEN 'Cancerous'
        ELSE 'Non-cancerous'
    END AS lesion_status,
    ROUND(AVG(diameter_1)::numeric, 2) AS avg_d1,
    ROUND(AVG(diameter_2)::numeric, 2) AS avg_d2
FROM table2 t2
GROUP BY biopsed;

--10. Which symptoms are most associated with cancer?

SELECT 
	itch, 
	grew, 
	hurt, 
	changed, 
	bleed,
       COUNT(*) FILTER (WHERE biopsed = TRUE) AS cancer_cases,
       COUNT(*) AS total_cases
FROM table2
GROUP BY itch, grew, hurt, changed, bleed
ORDER BY cancer_cases DESC
LIMIT 5;


--11. Do raised (elevated) lesions indicate higher cancer risk?

SELECT 
	elevation,
       COUNT(*) FILTER (WHERE biopsed = TRUE) AS cancer_cases,
       COUNT(*) AS total_cases
FROM table2
GROUP BY elevation;

--D. Combined Analysis

--12. Which combination of factors most strongly correlates with cancer?

SELECT 
	t1.age, 
	t1.smoke,
       COUNT(*) FILTER (WHERE t2.biopsed = TRUE) AS cancer_cases
FROM table1 t1
JOIN table2 t2 ON t1.patient_id = t2.patient_id
GROUP BY t1.age, t1.smoke
ORDER BY t1.age;

--13. What is the profile of a “high-risk patient”?
SELECT 
    t1.patient_id, 
    t1.gender, 
    t1.smoke, 
    t1.pesticide,
    COUNT(*) FILTER (WHERE t2.biopsed = TRUE) AS cancer_cases
FROM table1 t1
JOIN table2 t2 
    ON t1.patient_id = t2.patient_id
GROUP BY 
    t1.patient_id, 
    t1.gender, 
    t1.smoke, 
    t1.pesticide
HAVING COUNT(*) FILTER (WHERE t2.biopsed = TRUE) > 0
ORDER BY cancer_cases DESC;

--E. Diagnostic & Prediction Insight

--14. What percentage of lesions were biopsy-confirmed as cancer?
SELECT 
    ROUND(
        COUNT(*) FILTER (WHERE biopsed = TRUE) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS cancer_percentage
FROM table2;

--15. Which lesion features best predict biopsy confirmation?

SELECT
	grew, 
	changed, 
	bleed, 
	elevation,
       COUNT(*) FILTER (WHERE biopsed = TRUE) AS cancer_cases,
       COUNT(*) AS total_cases
FROM table2 t2
GROUP BY grew, changed, bleed, elevation
ORDER BY cancer_cases DESC;

--16.Which body regions are with most lesions?
SELECT
    COALESCE(region, 'Unknown') AS region,
    COUNT(*) AS total_lesions
FROM table2
GROUP BY COALESCE(region, 'Unknown')
ORDER BY total_lesions DESC;

SELECT
    region,
    COUNT(*) AS total_lesions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS lesion_percentage
FROM table2
WHERE region IS NOT NULL
  AND region <> ''
GROUP BY region
ORDER BY total_lesions DESC;

SELECT
    region,
    COUNT(*) AS total_lesions
FROM table2
WHERE region IS NOT NULL
  AND region <> ''
GROUP BY region
ORDER BY total_lesions DESC;









































