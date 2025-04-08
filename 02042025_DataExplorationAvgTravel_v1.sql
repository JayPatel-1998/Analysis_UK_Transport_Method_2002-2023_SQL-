-- DATABASES --
CREATE DATABASE Travel;
USE TRAVEL;


-- CHECKING TABLE STRUCTURES -- 
EXPLAIN AvgmilesPersonPerYearclean_v1;


-- DISPLAYING TABLE DATA --
select * from AvgmilesPersonPerYearclean_v1;
SELECT DISTINCT `Main mode`, `Main mode (code)` from AvgmilesPersonPerYearclean_v1;

-- GIVING EACH MODE CATEGORY A UNIQUE VALUE -- 
SELECT `Main mode`, DENSE_RANK() OVER(ORDER BY `Main mode`) 
FROM AvgmilesPersonPerYearclean_v1;


-- ADDING A NEW COLUMN TO THE IMPORTED DATASET --

ALTER TABLE  AvgmilesPersonPerYearclean_v1
ADD COLUMN `Main mode (code)` INT NOT NULL;

ALTER TABLE  AvgmilesPersonPerYearclean_v1
MODIFY `Main mode (code)` INT NULL;

-- PITFALLS: DELETING UNNEEDED RANGE OF DATA --

 DELETE FROM AvgmilesPersonPerYearclean_v1
 WHERE shopping IS NULL;
 
 -- CREATING TEMPORARY TABLE FOR DATA BLENDING/JOINING --
 
CREATE TEMPORARY TABLE temp_1
(main_mode varchar(255),
main_mode_code int);
 
-- INSERTING DATA ASSIGNING EACH TRANSPORT MODE A UNIQUE NUMBER -- 

 INSERT INTO temp_1 (main_mode, main_mode_code)
 SELECT `Main mode`,DENSE_RANK()OVER( ORDER BY `Main mode`) as mode
 FROM (select distinct `Main mode` from AvgmilesPersonPerYearclean_v1) as mod_num; 
 
 --
UPDATE AvgmilesPersonPerYearclean_v1 a
INNER JOIN temp_1 b on  a.`Main mode` = b.main_mode
SET a.`Main mode (code)` =  b.main_mode_code ;


/* CALCULATING TOTAL MILES PER PERSON/ YEAR using a 'Bus in London BETWEEN 2002 AND 2012 */
SELECT year, `Main mode`, SUM(commuting) OVER (PARTITION BY `Main mode` ORDER BY year) as 'Total Miles pp', `Main mode (code)`
FROM AvgmilesPersonPerYearclean_v1
WHERE YEAR BETWEEN 2002 AND 2012 and `Main mode (code)`= 2;


-- TOTAL MILES PER PERSON/ YEAR TRAVELLED BY PUBLIC TRANSPORT (BUS,RAIL, AIR, FERRY[12,2,8,7,10]) BETWEEN 2010 AND 2015-- 
SELECT  COALESCE(year, 'Grand Total'),
		COALESCE(`Main mode`, 'Total') as 'MainMode', 
        SUM(commuting), 
        SUM(Business)
FROM AvgmilesPersonPerYearclean_v1
WHERE `Main mode (code)` in (12,2,8,7,10) and YEAR BETWEEN 2010 AND 2015
GROUP BY year, `Main mode`,`Main mode (code)` with rollup;


-- TOTAL MILES PER PERSON/ YEAR TRAVELLED IN  MOTOR VEHICLES [CARS, MOTORBIKES, TAXI] (4,6,13) -- 
SELECT  COALESCE(year, 'Grand Total'),
		COALESCE(`Main mode`, 'Total') as 'MainMode', 
        SUM(commuting), 
        SUM(Business)
FROM AvgmilesPersonPerYearclean_v1
WHERE `Main mode (code)` in (4,6,13,3) and YEAR BETWEEN 2010 AND 2015
GROUP BY  year, `Main mode`,`Main mode (code)`;



/* GRAND TOTALLING TOTAL MILES PER PERSON TO FIND THE MOST AND LEAST POPULAR 
ACTIVITY BETWEEN 2002 -2009*/
SELECT  COALESCE(year, 'Grand Total') AS YEAR,
		COALESCE(`Main mode`, 'Total') as 'MainMode', 
        SUM(commuting), 
        SUM(Business),
        sum(`Education or escort education`),
        SUM(Shopping),
        sum(`Other escort`),
        SUM(`Personal business`),
        SUM(`Leisure (friends, entertainment, sport, holiday, day drip)`)
FROM AvgmilesPersonPerYearclean_v1
WHERE YEAR between 2002 and 2009
GROUP BY year, `Main mode`,`Main mode (code)` with rollup
ORDER BY YEAR;
/* LEAST:  Education (5042)
   MOST: LEISURE(44808)
	COMMUTING: (22,237)
    SHOPPING: 13810
    BUSINESS: 10815
    PERSONAL BUSINESS: 7810
    OTHER ESCORT: 7729
    */
    
/* GRAND TOTALLING TOTAL MILES PER PERSON TO FIND THE MOST AND LEAST POPULAR 
ACTIVITY BETWEEN 2010 -2019*/ 

SELECT  COALESCE(year, 'Grand Total') AS YEAR,
		COALESCE(`Main mode`, 'Total') as 'MainMode', 
        SUM(commuting), 
        SUM(Business),
        sum(`Education or escort education`),
        SUM(Shopping),
        sum(`Other escort`),
        SUM(`Personal business`),
        SUM(`Leisure (friends, entertainment, sport, holiday, day drip)`)
FROM AvgmilesPersonPerYearclean_v1
WHERE YEAR between 2010 and 2019
GROUP BY year, `Main mode`,`Main mode (code)` with rollup
ORDER BY YEAR;
/* LEAST:  Education (6657)
   MOST: LEISURE(52584)
*/

/* GRAND TOTALLING TOTAL MILES PER PERSON TO FIND THE MOST AND LEAST POPULAR 
DURING  CORONOVIRUS 2020 -2021*/ 
SELECT  COALESCE(year, 'Grand Total') AS YEAR,
		COALESCE(`Main mode`, 'Total') as 'MainMode', 
        SUM(commuting), 
        SUM(Business),
        sum(`Education or escort education`),
        SUM(Shopping),
        sum(`Other escort`),
        SUM(`Personal business`),
        SUM(`Leisure (friends, entertainment, sport, holiday, day drip)`)
FROM AvgmilesPersonPerYearclean_v1
WHERE  YEAR between 2020 and 2021
GROUP BY year, `Main mode`,`Main mode (code)` with rollup
ORDER BY YEAR;
/* LEAST: Business + Education (915 and 916 respectively)
   MOST: LEISURE(freinds, entertainment, sports, holiday day drip)
*/

/* FINDING THE MOST AND LEAST ACTIVE YEAR ACCORDING TO THE TOTAL MILES TRAVELLED PER PERSON
ACROSS ALL TRANSPORTS*/
SELECT year,
			SUM(commuting + Business + `Education or escort education` + Shopping
			+ `Other escort`+ `Personal business`+ `Leisure (friends, entertainment, sport, holiday, day drip)`) as TotalMilespp
FROM AvgmilesPersonPerYearclean_v1
GROUP BY year  with rollup
ORDER BY TotalMilespp ASC;
/* 2003:14337 milespp
2020: 8416 milespp*/



 


