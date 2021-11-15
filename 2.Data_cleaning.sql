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
                  OR PET = 'nem hozhat�'
                  OR PET = 'nem megengedett' THEN 'No'
              WHEN PET = 'igen'
                  OR PET = 'hozhat�'
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
    WHEN BATHROOM_TOILET = 'k�l�n helyis�gben' THEN 'Separate'
    WHEN BATHROOM_TOILET = 'egy helyis�gben' THEN 'Full bathroom'
    WHEN BATHROOM_TOILET = 'k�l�n �s egyben is' THEN 'Separate and full'
    ELSE BATHROOM_TOILET
    END;

-- RENTAL VIEW COLUMN --

SELECT RENTAL_VIEW, COUNT(*)
FROM RENTAL
GROUP BY RENTAL_VIEW;

DELETE FROM RENTAL
WHERE RENTAL_VIEW LIKE '%m?'
    OR RENTAL_VIEW IN ('d�lnyugat', 'kelet', 'd�l');
    
UPDATE RENTAL
SET RENTAL_VIEW =
    CASE
    WHEN RENTAL_VIEW = 'utcai' THEN 'Street'
    WHEN RENTAL_VIEW = 'udvari' THEN 'Courtyard'
    WHEN RENTAL_VIEW = 'panor�m�s' THEN 'Panorama'
    WHEN RENTAL_VIEW = 'kertre n�z' THEN 'Garden'
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
SET BALCONY = TRIM(REPLACE(BALCONY, 'm?', ''));

DELETE FROM RENTAL
WHERE BALCONY IN ('utcai', 'panor�m�s', 'udvari', 'kertre n�z');


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
WHERE FURNISHED LIKE '%Ft/h�';

UPDATE RENTAL
SET FURNISHED =
    CASE
    WHEN FURNISHED IN ('igen', 'van') THEN 'Yes'
    WHEN FURNISHED IN ('nem', 'nincs') THEN 'No'
    WHEN FURNISHED = 'r�szben' THEN 'Partly'
    WHEN FURNISHED = 'megegyez�s szerint' THEN 'Arrangeable'
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
SET AREA = TRIM(REPLACE(AREA, 'm?', ''));


-- ROOMS COLUMN

SELECT ROOMS, COUNT(*) AS RENTALS
FROM RENTAL
GROUP BY ROOMS
ORDER BY RENTALS DESC ;

DELETE FROM RENTAL
WHERE ROOMS IN (SELECT ROOMS
                FROM(SELECT ROOMS, COUNT(*) AS RENTALS
                     FROM RENTAL
                     WHERE ROOMS LIKE '%f�l'
                     GROUP BY ROOMS
                     HAVING COUNT(*) < 5)DEL)
        OR ROOMS LIKE '%m?' ;

UPDATE RENTAL
SET ROOMS = 
    CASE
    WHEN ROOMS = '4 + 1 f�l' THEN '4.5'
    WHEN ROOMS IN ('1 + 3 f�l', '2 + 1 f�l') THEN '2.5'
    WHEN ROOMS = '1 + 2 f�l' THEN '2'
    WHEN ROOMS = '2 + 2 f�l' THEN '3'
    WHEN ROOMS = '1 f�l'     THEN '0.5'
    WHEN ROOMS = '5 + 1 f�l' THEN '5.5'
    WHEN ROOMS = '1 + 1 f�l' THEN '1.5'
    WHEN ROOMS = '3 + 2 f�l' THEN '4'
    WHEN ROOMS = '3 + 1 f�l' THEN '3.5'
    ELSE ROOMS
    END;
    
-- RENTAL FLOOR COLUMN --

SELECT RENTAL_FLOOR, COUNT(*)
FROM RENTAL
GROUP BY RENTAL_FLOOR;

UPDATE RENTAL
SET RENTAL_FLOOR = 
    CASE
    WHEN RENTAL_FLOOR = 'szuter�n' THEN 'Suteren'
    WHEN RENTAL_FLOOR = 'f�lemelet' THEN 'Mezzanine'
    WHEN RENTAL_FLOOR = 'f�ldszint' THEN 'Ground floor'
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
    WHEN CONDITION = '�j �p�t�s�' THEN 'New'
    WHEN CONDITION = 'j� �llapot�' THEN 'Good'
    WHEN CONDITION = '�jszer�' THEN 'Novel'
    WHEN CONDITION = 'fel�j�tott' THEN 'Renovated'
    WHEN CONDITION = 'fel�j�tand�' THEN 'To be renovated'
    WHEN CONDITION = 'k�zepes �llapot�' THEN 'Moderate'
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
    WHEN HEAT IN ('g�z (cirko)', 'g�zkaz�n')   THEN 'Gas boiler'
    WHEN HEAT = 'g�z (konvektor)'              THEN 'Convector'
    WHEN HEAT = 'h�zk�zponti'                  THEN 'Central'
    WHEN HEAT = 'h�zk�zponti egyedi m�r�ssel'  THEN 'Central with metering'
    WHEN HEAT = 't�vf�t�s'                     THEN 'District'
    WHEN HEAT = 't�vf�t�s egyedi m�r�ssel'     THEN 'District with metering'
    WHEN HEAT = 'elektromos'                   THEN 'Electric'
    WHEN HEAT = 'fan-coil'                     THEN 'Fan-coil'
    WHEN HEAT = 'mennyezeti h�t�s-f�t�s'       THEN 'Ceiling'
    WHEN HEAT = 'h�szivatty�'                  THEN 'Heat pump'
    WHEN HEAT = 'egy�b'                        THEN 'Other'
    WHEN HEAT = 'padl�f�t�s'                   THEN 'Floor'
    WHEN HEAT = 'falf�t�s'                     THEN 'Wall'
    WHEN HEAT = 'cser�pk�lyha'                 THEN 'Tile stove'
    WHEN HEAT = 'meg�jul� energia'             THEN 'Renewable energy'
    WHEN HEAT = 'egy�b kaz�n'                  THEN 'Other boiler'
    WHEN HEAT = 'nincs'                        THEN 'None'
    WHEN HEAT = 'vegyes t�zel�s� kaz�n'        THEN 'Mixed fuel boiler'
    WHEN HEAT LIKE '%,%'                       THEN 'Multiple'
    ELSE HEAT
    END;
  
-- YEAR COLUMN --
SELECT YEAR, COUNT(*) AS RENTALS
FROM RENTAL
GROUP BY YEAR
ORDER BY RENTALS DESC;

DELETE FROM RENTAL
WHERE YEAR IN ('�sszkomfortos', 'luxus');

UPDATE RENTAL
SET YEAR = 
    CASE
    WHEN YEAR = '1950 el�tt'          THEN 'Before 1950'
    WHEN YEAR = '1950 �s 1980 k�z�tt' THEN '1950-1980'
    WHEN YEAR = '2001 �s 2010 k�z�tt' THEN '2001-2010'
    WHEN YEAR = '1981 �s 2000 k�z�tt' THEN '1981-2000'
    ELSE YEAR
    END;


-- PRICE COLUMN --

-- Transforming HUF strings to numbers --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE NOT LIKE '%�%'
;

UPDATE RENTAL
SET PRICE = 
    CASE
    WHEN PRICE LIKE '%ezer%' THEN REPLACE(PRICE, ' ezer Ft', '000')
    WHEN PRICE LIKE '%milli�%' THEN REPLACE (PRICE, ' milli� Ft', '000000')
    ELSE PRICE
    END
WHERE PRICE LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE NOT LIKE '%�%'; 

-- Transforming EUR strings to numbers --

SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE LIKE '%�%';
    
UPDATE RENTAL
SET PRICE =
    CASE
    WHEN PRICE LIKE ' ezer �' THEN REPLACE(PRICE, ' ezer �', '000')
    WHEN PRICE NOT LIKE '%ezer%' THEN REPLACE (PRICE, ' �', '')
    ELSE PRICE
    END
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%,%'
    AND PRICE LIKE '%�';      

-- Strip EUR price, if HUF is given. --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
  OR PRICE LIKE '%�%'
  OR PRICE LIKE  '%,%';


SELECT ADDRESS, PRICE, REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000') AS TRIMMED
FROM RENTAL
WHERE PRICE LIKE '%Ft%'
     AND PRICE LIKE '%�%'
     AND PRICE NOT LIKE '%,%';
     --AND REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000') LIKE '%,%';

UPDATE RENTAL
SET PRICE = REPLACE(SPLIT_PART(PRICE, 'Ft', 1), ' ezer', '000')
WHERE PRICE LIKE '%Ft%'
     AND PRICE LIKE '%�%'
     AND PRICE NOT LIKE '%,%';


-- Transforming those that contain 'ezer' but not the currency --
SELECT ADDRESS, PRICE
FROM RENTAL
WHERE PRICE LIKE '%ezer%'
    AND PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%�%'
    AND PRICE NOT LIKE '%,%';
    
UPDATE RENTAL
SET PRICE = REPLACE(PRICE, ' ezer', '000')
WHERE PRICE LIKE '%ezer%'
    AND PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%�%'
    AND PRICE NOT LIKE '%,%'
RETURNING *;



-- Transforming those prices, where the comma is in the EUR price and HUF is also displayed.   
SELECT ADDRESS, PRICE--, SPLIT_PART(PRICE, 'Ft', 1) AS SPLIT
FROM RENTAL
WHERE PRICE NOT LIKE '%Ft%'
    AND PRICE NOT LIKE '%�%'
    AND PRICE LIKE '%ezer%' OR PRICE LIKE '%milli�%';
     
    
UPDATE RENTAL
SET PRICE = SPLIT_PART(PRICE, 'Ft', 1)
WHERE PRICE LIKE '%,%'
    AND PRICE LIKE '%Ft%'
    AND PRICE LIKE '%�%'
RETURNING *;

-- Transforming EUR floats --
SELECT ADDRESS, PRICE, CHAR_LENGTH(PRICE) AS LENGHT
FROM RENTAL
WHERE PRICE LIKE '%�%';

  
UPDATE RENTAL
SET PRICE = 
    CASE
    WHEN CHAR_LENGTH(PRICE) = 10 THEN REPLACE(REPLACE(PRICE,',',''), ' ezer �', '00')
    WHEN CHAR_LENGTH(PRICE) = 11 THEN REPLACE(REPLACE(PRICE,',',''), ' ezer �', '0')
    ELSE PRICE
    END
WHERE PRICE LIKE '%�%'
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
        AND PRICE LIKE '%milli�%' THEN REPLACE(REPLACE(PRICE,',',''), ' milli� Ft', '00000')
    WHEN CHAR_LENGTH(PRICE) = 14
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer Ft', '0')
    WHEN CHAR_LENGTH(PRICE) = 14
        AND PRICE LIKE '%milli�%' THEN REPLACE(REPLACE(PRICE,',',''), ' milli� Ft', '0000')
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
        AND PRICE LIKE '%milli�%' THEN REPLACE(REPLACE(PRICE,',',''), ' milli�', '0000')
    WHEN CHAR_LENGTH(PRICE) = 11
        AND PRICE LIKE '%ezer%' THEN REPLACE(REPLACE(PRICE,',',''), ' ezer', '00')
    WHEN CHAR_LENGTH(PRICE) = 11
        AND PRICE LIKE '%milli�%' THEN REPLACE(REPLACE(PRICE,',',''), ' milli�', '00000')
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
  OR PRICE LIKE '%milli�%'
  OR PRICE LIKE '%Ft%'
  OR PRICE LIKE '%�%'
  OR PRICE LIKE ',';
  
UPDATE RENTAL
SET PRICE = '1000000'
WHERE PRICE = '1 milli� '
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

    



