-- Take a look at the scraped data --
SELECT *
FROM RENTAL
LIMIT 30;

-- MISSING VALUES --

-- Update missing values, where the user did not provide input.
UPDATE RENTAL
SET CONDITION = NULL
WHERE CONDITION = 'nincs megadva';

UPDATE RENTAL
SET YEAR = NULL
WHERE YEAR = 'nincs megadva';

UPDATE RENTAL
SET RENTAL_FLOOR = NULL
WHERE RENTAL_FLOOR = 'N/A' OR RENTAL_FLOOR = 'nincs megadva';

UPDATE RENTAL
SET ELEVATOR = NULL
WHERE ELEVATOR = 'nincs megadva';

UPDATE RENTAL
SET HEAT = NULL
WHERE HEAT = 'nincs megadva';

UPDATE RENTAL
SET AIR_CONDITIONER = NULL
WHERE AIR_CONDITIONER = 'nincs megadva';

UPDATE RENTAL
SET FURNISHED = NULL
WHERE FURNISHED = 'nincs megadva';

UPDATE RENTAL
SET ACCESSIBLE = NULL
WHERE ACCESSIBLE = 'nincs megadva';

UPDATE RENTAL
SET BATHROOM_TOILET = NULL
WHERE BATHROOM_TOILET = 'nincs megadva';

UPDATE RENTAL
SET RENTAL_VIEW = NULL
WHERE RENTAL_VIEW = 'nincs megadva';

UPDATE RENTAL
SET BALCONY = NULL
WHERE BALCONY = 'nincs megadva';

UPDATE RENTAL
SET MECHANIZED = NULL
WHERE MECHANIZED = 'nincs megadva';

UPDATE RENTAL
SET PET = NULL
WHERE PET = 'nincs megadva';


-- DATA TRANSFORMATION --

-- PET COLUMN --
SELECT PET, COUNT(*)
FROM RENTAL
GROUP BY PET;

UPDATE RENTAL
SET PET = CASE 
              WHEN PET = 'nem'
                  OR PET = 'nem hozható'
                  OR PET = 'nem megengedett' THEN 'No'
              WHEN PET = 'igen'
                  OR PET = 'hozható'
                  OR PET = 'megengedett' THEN 'Yes'
              ELSE PET
             
END;

-- ACCESSIBLE COLUMN --

SELECT ACCESSIBLE, COUNT(*)
FROM RENTAL
GROUP BY ACCESSIBLE;

DELETE FROM RENTAL
WHERE ACCESSIBLE NOT IN ('igen', 'nem', 'NaN');

UPDATE RENTAL
SET ACCESSIBLE =
    CASE
    WHEN ACCESSIBLE = 'igen' THEN 'Yes'
    WHEN ACCESSIBLE = 'nem' THEN 'No'
    ELSE ACCESSIBLE
    END;
    
-- BATHROOM TOILET COLUMN --

SELECT BATHROOM_TOILET, COUNT(*)
FROM RENTAL
GROUP BY BATHROOM_TOILET;

UPDATE RENTAL
SET BATHROOM_TOILET =
    CASE
    WHEN BATHROOM_TOILET = 'igen' THEN 'Yes'
    WHEN BATHROOM_TOILET = 'nem' THEN 'No'
    WHEN BATHROOM_TOILET = 'külön helyiségben' THEN 'Separate'
    WHEN BATHROOM_TOILET = 'egy helyiségben' THEN 'Full bathroom'
    WHEN BATHROOM_TOILET = 'külön és egyben is' THEN 'Separate and full'
    ELSE BATHROOM_TOILET
    END;

-- RENTAL VIEW COLUMN --

SELECT RENTAL_VIEW, COUNT(*)
FROM RENTAL
GROUP BY RENTAL_VIEW;

DELETE FROM RENTAL
WHERE RENTAL_VIEW LIKE '%m²'
    OR RENTAL_VIEW IN ('délnyugat', 'kelet', 'dél');
    
UPDATE RENTAL
SET RENTAL_VIEW =
    CASE
    WHEN RENTAL_VIEW = 'utcai' THEN 'Street'
    WHEN RENTAL_VIEW = 'udvari' THEN 'Courtyard'
    WHEN RENTAL_VIEW = 'panorámás' THEN 'Panorama'
    WHEN RENTAL_VIEW = 'kertre néz' THEN 'Garden'
    ELSE RENTAL_VIEW
    END;


-- MECHANIZED COLUMN --
SELECT MECHANIZED, COUNT(*)
FROM RENTAL
GROUP BY MECHANIZED;

DELETE FROM RENTAL
WHERE MECHANIZED NOT IN  ('NaN', 'igen', 'nem');

UPDATE RENTAL
SET MECHANIZED =
    CASE
    WHEN MECHANIZED = 'igen' THEN 'Yes'
    WHEN MECHANIZED = 'nem' THEN 'No'
    ELSE MECHANIZED
    END;

-- BALCONY COLUMN --

SELECT BALCONY, COUNT(*)
FROM RENTAL
GROUP BY BALCONY;

UPDATE RENTAL
SET BALCONY = TRIM(REPLACE(BALCONY, 'm²', ''));

DELETE FROM RENTAL
WHERE BALCONY IN ('utcai', 'panorámás', 'udvari', 'kertre néz');


-- ELEVATOR COLUMN --

SELECT ELEVATOR, COUNT(*)
FROM RENTAL
GROUP BY ELEVATOR;

DELETE FROM RENTAL
WHERE ELEVATOR NOT IN ('NaN', 'van', 'nincs');

UPDATE RENTAL
SET ELEVATOR =
    CASE
    WHEN ELEVATOR = 'van' THEN 'Yes'
    WHEN ELEVATOR = 'nincs' THEN 'No'
    ELSE ELEVATOR
    END;


-- FURNISHED COLUMN --

SELECT FURNISHED, COUNT(*)
FROM RENTAL
GROUP BY FURNISHED;

DELETE FROM RENTAL
WHERE FURNISHED LIKE '%Ft/hó';

UPDATE RENTAL
SET FURNISHED =
    CASE
    WHEN FURNISHED IN ('igen', 'van') THEN 'Yes'
    WHEN FURNISHED IN ('nem', 'nincs') THEN 'No'
    WHEN FURNISHED = 'részben' THEN 'Partly'
    WHEN FURNISHED = 'megegyezés szerint' THEN 'Arrangeable'
    ELSE FURNISHED
    END;


-- AIR CONDITIONER COLUMN --

SELECT AIR_CONDITIONER, COUNT(*)
FROM RENTAL
GROUP BY AIR_CONDITIONER;

DELETE FROM RENTAL
WHERE AIR_CONDITIONER NOT IN ('van', 'nincs', 'NaN');

UPDATE RENTAL
SET AIR_CONDITIONER =
    CASE
    WHEN AIR_CONDITIONER = 'van' THEN 'Yes'
    WHEN AIR_CONDITIONER = 'nincs' THEN 'No'
    ELSE AIR_CONDITIONER
    END;


-- AREA COLUMN --

SELECT AREA, COUNT(*)
FROM RENTAL
GROUP BY AREA;

UPDATE RENTAL
SET AREA = TRIM(REPLACE(AREA, 'm²', ''));


-- ROOMS COLUMN

SELECT ROOMS, COUNT(*) AS RENTALS
FROM RENTAL
GROUP BY ROOMS
ORDER BY RENTALS DESC ;

DELETE FROM RENTAL
WHERE ROOMS IN (SELECT ROOMS
                FROM(SELECT ROOMS, COUNT(*) AS RENTALS
                     FROM RENTAL
                     WHERE ROOMS LIKE '%fél'
                     GROUP BY ROOMS
                     HAVING COUNT(*) < 5)DEL)
        OR ROOMS LIKE '%m²' ;

UPDATE RENTAL
SET ROOMS = 
    CASE
    WHEN ROOMS = '4 + 1 fél' THEN '4.5'
    WHEN ROOMS IN ('1 + 3 fél', '2 + 1 fél') THEN '2.5'
    WHEN ROOMS = '1 + 2 fél' THEN '2'
    WHEN ROOMS = '2 + 2 fél' THEN '3'
    WHEN ROOMS = '1 fél'     THEN '0.5'
    WHEN ROOMS = '5 + 1 fél' THEN '5.5'
    WHEN ROOMS = '1 + 1 fél' THEN '1.5'
    WHEN ROOMS = '3 + 2 fél' THEN '4'
    WHEN ROOMS = '3 + 1 fél' THEN '3.5'
    ELSE ROOMS
    END;
    
-- RENTAL FLOOR COLUMN --

SELECT RENTAL_FLOOR, COUNT(*)
FROM RENTAL
GROUP BY RENTAL_FLOOR;

UPDATE RENTAL
SET RENTAL_FLOOR = 
    CASE
    WHEN RENTAL_FLOOR = 'szuterén' THEN 'Suteren'
    WHEN RENTAL_FLOOR = 'félemelet' THEN 'Mezzanine'
    WHEN RENTAL_FLOOR = 'földszint' THEN 'Ground floor'
    WHEN RENTAL_FLOOR = '10 felett' THEN 'Over 10'
    ELSE RENTAL_FLOOR
    END;
    
-- CONDITION COLUMN --

SELECT CONDITION, COUNT(*)
FROM RENTAL
GROUP BY CONDITION;

UPDATE RENTAL
SET CONDITION =
    CASE
    WHEN CONDITION = 'új építésű' THEN 'New'
    WHEN CONDITION = 'jó állapotú' THEN 'Good'
    WHEN CONDITION = 'újszerű' THEN 'Novel'
    WHEN CONDITION = 'felújított' THEN 'Renovated'
    WHEN CONDITION = 'felújítandó' THEN 'To be renovated'
    WHEN CONDITION = 'közepes állapotú' THEN 'Moderate'
    ELSE CONDITION
    END ;

-- HEAT COLUMN --

SELECT HEAT, COUNT(*)
FROM RENTAL
GROUP BY HEAT
ORDER BY COUNT DESC;

UPDATE RENTAL
SET HEAT =
    CASE
    WHEN HEAT IN ('gáz (cirko)', 'gázkazán')   THEN 'Gas boiler'
    WHEN HEAT = 'gáz (konvektor)'              THEN 'Convector'
    WHEN HEAT = 'házközponti'                  THEN 'Central'
    WHEN HEAT = 'házközponti egyedi méréssel'  THEN 'Central with metering'
    WHEN HEAT = 'távfűtés'                     THEN 'District'
    WHEN HEAT = 'távfűtés egyedi méréssel'     THEN 'District with metering'
    WHEN HEAT = 'elektromos'                   THEN 'Electric'
    WHEN HEAT = 'fan-coil'                     THEN 'Fan-coil'
    WHEN HEAT = 'mennyezeti hűtés-fűtés'       THEN 'Ceiling'
    WHEN HEAT = 'hőszivattyú'                  THEN 'Heat pump'
    WHEN HEAT = 'egyéb'                        THEN 'Other'
    WHEN HEAT = 'padlófűtés'                   THEN 'Floor'
    WHEN HEAT = 'falfűtés'                     THEN 'Wall'
    WHEN HEAT = 'cserépkályha'                 THEN 'Tile stove'
    WHEN HEAT = 'megújuló energia'             THEN 'Renewable energy'
    WHEN HEAT = 'egyéb kazán'                  THEN 'Other boiler'
    WHEN HEAT = 'nincs'                        THEN 'None'
    WHEN HEAT = 'vegyes tüzelésű kazán'        THEN 'Mixed fuel boiler'
    WHEN HEAT LIKE '%,%'                       THEN 'Multiple'
    ELSE HEAT
    END;
  
-- YEAR COLUMN --
SELECT YEAR, COUNT(*) AS RENTALS
FROM RENTAL
GROUP BY YEAR
ORDER BY RENTALS DESC;

DELETE FROM RENTAL
WHERE YEAR IN ('összkomfortos', 'luxus');

UPDATE RENTAL
SET YEAR = 
    CASE
    WHEN YEAR = '1950 előtt'          THEN 'Before 1950'
    WHEN YEAR = '1950 és 1980 között' THEN '1950-1980'
    WHEN YEAR = '2001 és 2010 között' THEN '2001-2010'
    WHEN YEAR = '1981 és 2000 között' THEN '1981-2000'
    ELSE YEAR
    END;


-- PRICE COLUMN --

-- Transforming HUF strings to numbers --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE NOT LIKE '%€%'
;

UPDATE RENTAL
SET PRICE = 
    CASE
    WHEN PRICE LIKE '%ezer%' THEN REPLACE(PRICE, ' ezer Ft', '000')
    WHEN PRICE LIKE '%millió%' THEN REPLACE (PRICE, ' millió Ft', '000000')
    ELSE PRICE
    END
WHERE PRICE LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE NOT LIKE '%€%'; 

-- Transforming EUR strings to numbers --

SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE LIKE '%€%';
    
UPDATE RENTAL
SET PRICE =
    CASE
    WHEN PRICE LIKE ' ezer €' THEN REPLACE(PRICE, ' ezer €', '000')
    WHEN PRICE NOT LIKE '%ezer%' THEN REPLACE (PRICE, ' €', '')
    ELSE PRICE
    END
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE LIKE '%€';      

-- Strip EUR price, if HUF is given. --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
  OR PRICE LIKE '%€%'
  OR PRICE LIKE  '%,%';


SELECT ADDRESS, PRICE, REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000') AS TRIMMED
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
     AND PRICE LIKE '%€%'
     AND PRICE NOT LIKE '%,%';
     --AND REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000') LIKE '%,%';

UPDATE RENTAL
SET PRICE = REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000')
WHERE PRICE LIKE '%Ft%'
     AND PRICE LIKE '%€%'
     AND PRICE NOT LIKE '%,%';


-- Transforming those that contain 'ezer' but not the currency --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%ezer%'
    AND PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%€%'
    AND PRICE NOT LIKE '%,%';
    
UPDATE RENTAL
SET PRICE = REPLACE(PRICE, ' ezer', '000')
WHERE PRICE LIKE '%ezer%'
    AND PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%€%'
    AND PRICE NOT LIKE '%,%'
RETURNING *;



-- Transforming those prices, where the comma is in the EUR price and HUF is also displayed.   
SELECT ADDRESS, PRICE--, SPLIT_PART(PRICE, 'Ft', 1) AS SPLIT
FROM RENTAL
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%€%'
    AND PRICE LIKE '%ezer%' OR PRICE LIKE '%millió%';
     
    
UPDATE RENTAL
SET PRICE = SPLIT_PART(PRICE, 'Ft', 1)
WHERE PRICE LIKE '%,%'
    AND PRICE LIKE '%Ft%'
    AND PRICE LIKE '%€%'
RETURNING *;

-- Transforming EUR floats --
SELECT ADDRESS, PRICE, CHAR_LENGTH(PRICE) AS LENGHT
FROM RENTAL
WHERE PRICE LIKE '%€%';

  
UPDATE RENTAL
SET PRICE = 
    CASE
    WHEN CHAR_LENGTH(PRICE) = 10 THEN REPLACE(REPLACE(PRICE,',',''), ' ezer €', '00')
    WHEN CHAR_LENGTH(PRICE) = 11 THEN REPLACE(REPLACE(PRICE,',',''), ' ezer €', '0')
    ELSE PRICE
    END
WHERE PRICE LIKE '%€%'
RETURNING *;


-- Transforming HUF floats --
SELECT ADDRESS, PRICE, CHAR_LENGTH(PRICE) AS LENGHT
FROM RENTAL
WHERE PRICE LIKE '%Ft%';

UPDATE RENTAL
SET PRICE =
    CASE
    WHEN CHAR_LENGTH(PRICE) = 12
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer Ft', '00')
    WHEN CHAR_LENGTH(PRICE) = 13
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer Ft', '00')
    WHEN CHAR_LENGTH(PRICE) = 13
        AND PRICE LIKE '%millió%' THEN REPLACE(REPLACE(PRICE,',',''), ' millió Ft', '00000')
    WHEN CHAR_LENGTH(PRICE) = 14
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer Ft', '0')
    WHEN CHAR_LENGTH(PRICE) = 14
        AND PRICE LIKE '%millió%' THEN REPLACE(REPLACE(PRICE,',',''), ' millió Ft', '0000')
    ELSE PRICE
    END
WHERE PRICE LIKE '%Ft%'
RETURNING *;


-- Transforming remaining floats --
SELECT ADDRESS, PRICE, CHAR_LENGTH(PRICE) AS LENGHT
FROM RENTAL
WHERE PRICE LIKE '%,%';

UPDATE RENTAL
SET PRICE =
    CASE
    WHEN CHAR_LENGTH(PRICE) = 12
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer', '0')
    WHEN CHAR_LENGTH(PRICE) = 12
        AND PRICE LIKE '%millió%' THEN REPLACE(REPLACE(PRICE,',',''), ' millió', '0000')
    WHEN CHAR_LENGTH(PRICE) = 11
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer', '00')
    WHEN CHAR_LENGTH(PRICE) = 11
        AND PRICE LIKE '%millió%' THEN REPLACE(REPLACE(PRICE,',',''), ' millió', '00000')
    ELSE PRICE
    END
WHERE PRICE LIKE '%,%'
RETURNING *;

SELECT PRICE, COUNT(*)
FROM RENTAL
GROUP BY PRICE
ORDER BY COUNT(*) DESC;

-- Checking for remaining rows that need transforming --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%ezer%'
  OR PRICE LIKE '%millió%'
  OR PRICE LIKE '%Ft%'
  OR PRICE LIKE '%€%'
  OR PRICE LIKE ',';
  
UPDATE RENTAL
SET PRICE = '1000000'
WHERE PRICE = '1 millió '
RETURNING *;


-- After cleaning unnecessary strings from columns, changing their type to numeric. --

ALTER TABLE RENTAL
ALTER COLUMN PRICE TYPE NUMERIC USING (TRIM(PRICE):: NUMERIC),
ALTER COLUMN AREA TYPE NUMERIC USING (TRIM(AREA):: NUMERIC),
ALTER COLUMN ROOMS TYPE NUMERIC USING (TRIM(ROOMS):: NUMERIC),
ALTER COLUMN BALCONY TYPE NUMERIC USING (TRIM(BALCONY):: NUMERIC);


-- Changing EUR to HUF --

SELECT *
FROM RENTAL
WHERE PRICE < 10000
ORDER BY PRICE DESC;

UPDATE RENTAL
SET PRICE = PRICE * 350
WHERE PRICE < 10000
RETURNING *;

-- Creating a district column from the address column --

ALTER TABLE RENTAL
ADD COLUMN district VARCHAR(20);

UPDATE RENTAL
SET DISTRICT = SPLIT_PART(ADDRESS, '.', 1);

SELECT DISTRICT, COUNT(*)
FROM RENTAL
GROUP BY DISTRICT
ORDER BY COUNT(*) DESC;