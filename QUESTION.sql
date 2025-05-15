-- [Q1] Which was the most frequent crime committed each week? 

SELECT CRIME_TYPE,
       CRIME_COUNT,
       WEEK_NUMBER
FROM ( SELECT CRIME_TYPE,
              CRIME_COUNT,
			  WEEK_NUMBER,
	RANK() OVER ( PARTITION BY WEEK_NUMBER ORDER BY CRIME_COUNT) AS RANKING
FROM ( SELECT CRIME_TYPE,
              COUNT(*) AS CRIME_COUNT,
			  WEEK_NUMBER
		FROM REP_LOC_OFF_V
        GROUP BY 1,3) AS WEEKLY_CRIME) AS RANKED_CRIME
        WHERE RANKING = 1;

-- [Q2] Is crime more prevalent in areas with a higher population density, fewer police personnel, and a larger precinct area? 
SELECT DISTINCT SUM(POPULATION_DENSITY) AS TOTAL_POPULATION,
	   COUNT(AREA_CODE) AS TOTAL_AREA,
       COUNT(OFFICER_CODE) AS TOTAL_OFFICER,
       COUNT(CRIME_CODE) AS TOTAL_CRIME,
       PRECINCT_CODE
   FROM REP_LOC_OFF_V
   GROUP BY PRECINCT_CODE;

 -- [Q3] At what points of the day is the crime rate at its peak? Group this by the type of crime.
 
SELECT CRIME_TYPE, TIME_DAY, CRIME_COUNT, WEEK_NUMBER
FROM
(SELECT CRIME_TYPE, TIME_DAY, CRIME_COUNT, WEEK_NUMBER,
      RANK() OVER (PARTITION BY CRIME_TYPE ORDER BY CRIME_COUNT DESC) AS RANKING
      FROM
          ( SELECT CRIME_TYPE, 
                   WEEK_NUMBER, 
                   TIME_F(INCIDENT_TIME) AS TIME_DAY,
                  COUNT(*) AS CRIME_COUNT
			FROM REP_LOC_OFF_V
            GROUP BY 1,2,3) AS CRIME_COUNT) AS RANK_CRIME
	WHERE RANKING = 1
    ORDER BY WEEK_NUMBER;
       
      -- [Q4] At what point in the day do more crimes occur in a different locality?
 SELECT AREA_NAME,
        TIME_DAY,
        CRIME_COUNT
FROM (SELECT AREA_NAME,
        TIME_DAY, 
        CRIME_COUNT,
        RANK() OVER (PARTITION BY AREA_NAME ORDER BY CRIME_COUNT DESC) AS RANKING
   FROM
       (SELECT AREA_NAME,
          COUNT(*) AS CRIME_COUNT,
          TIME_F(INCIDENT_TIME) AS TIME_DAY
		FROM REP_LOC_OFF_V
        GROUP BY 1,3) AS CRIME_COUNT) AS CRIMES
        WHERE RANKING = 1;
        
-- [Q5] Which age group of people is more likely to fall victim to crimes at certain points in the day?

SELECT AGE_GROUP,
      TIME_DAY,
      CRIME_COUNT
FROM ( SELECT AGE_GROUP,
      TIME_DAY,
      CRIME_COUNT,
      RANK() OVER (PARTITION BY AGE_GROUP ORDER BY CRIME_COUNT) AS RANKING
FROM ( SELECT
       AGE_F(VICTIM_AGE) AS AGE_GROUP,
       TIME_F(INCIDENT_TIME) AS TIME_DAY,
       COUNT(*) AS CRIME_COUNT
       FROM REP_VICT_V
       GROUP BY 1,2) AS CRIME) AS RANK_CRIME
      WHERE RANKING = 5;
     
-- [Q6] What is the status of reported crimes?.

SELECT CASE_STATUS_DESC,
 COUNT(COMPLAINT_TYPE) CRIME_COUNT
FROM CRIME_T
GROUP BY CASE_STATUS_DESC;

-- [Q8] How much footage has been recovered from the CCTV at the crime scene?

SELECT COUNT(CCTV_FLAG)
FROM CRIME_T
WHERE CCTV_FLAG = "TRUE";

SELECT COUNT(CCTV_FLAG)
FROM CRIME_T
WHERE CCTV_FLAG = "FALSE";

SELECT DISTINCT AREA_NAME,
COUNT(CCTV_COUNT) 
FROM CRIME_T
GROUP BY 1;
 
  -- [Q9] Is crime more likely to be committed by relation of victims than strangers?
  
SELECT DISTINCT CRIME_TYPE,OFFENDER_RELATION
FROM CRIME_T 
WHERE OFFENDER_RELATION ="YES";

-- [Q10] What are the methods used by the public to report a crime? 
 
 SELECT COMPLAINT_TYPE,
 COUNT( COMPLAINT_TYPE) AS COUNT_CRIME
 FROM CRIME.REP_LOC_OFF_V
 GROUP BY COMPLAINT_TYPE;
 