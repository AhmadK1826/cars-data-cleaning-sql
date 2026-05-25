USE cars;

-- 1.Remove Duplicates

CREATE TABLE Cars_dataset2025_2
LIKE `cars datasets 2025`;

ALTER TABLE  Cars_dataset2025_2
ADD COLUMN row_num INT ;

INSERT INTO Cars_dataset2025_2
SELECT * , ROW_NUMBER()OVER(PARTITION BY `Company Names`, `Cars Names`, `Engines`, `CC/Battery Capacity`, `HorsePower`, `Total Speed`, `Performance(0 - 100 )KM/H`, `Cars Prices`, `Fuel Types`, `Seats`, `Torque` ORDER BY `Company Names`) AS row_num
FROM `cars datasets 2025`;

DELETE FROM Cars_dataset2025_2
WHERE row_num > 1 ;

SELECT * FROM Cars_dataset2025_2;

-- 2.Data standardization 

UPDATE Cars_dataset2025_2
SET 
    `Company Names` = TRIM(`Company Names`),
    `Cars Names` = TRIM(`Cars Names`),
    `Engines` = TRIM(`Engines`),
    `CC/Battery Capacity` = TRIM(`CC/Battery Capacity`),
    `HorsePower` = TRIM(`HorsePower`),
    `Total Speed` = TRIM(`Total Speed`),
    `Performance(0 - 100 )KM/H` = TRIM(`Performance(0 - 100 )KM/H`),
    `Cars Prices` = TRIM(`Cars Prices`),
    `Fuel Types` = TRIM(`Fuel Types`),
    `Torque` = TRIM(`Torque`);
    
UPDATE Cars_dataset2025_2
SET `Company Names` = CASE
    WHEN LOWER(TRIM(`Company Names`)) = 'bmw' THEN 'BMW'
    WHEN LOWER(TRIM(`Company Names`)) = 'gmc' THEN 'GMC'
    ELSE CONCAT(UPPER(LEFT(TRIM(`Company Names`), 1)), LOWER(SUBSTRING(TRIM(`Company Names`), 2)))
END;

UPDATE Cars_dataset2025_2
SET `Fuel Types` = CASE
    WHEN LOWER(TRIM(`Fuel Types`)) = 'petrol' THEN 'Petrol'
    WHEN LOWER(TRIM(`Fuel Types`)) = 'diesel' THEN 'Diesel'
    WHEN LOWER(TRIM(`Fuel Types`)) = 'electric' THEN 'Electric'
    WHEN LOWER(TRIM(`Fuel Types`)) = 'hybrid' THEN 'Hybrid'
    ELSE TRIM(`Fuel Types`)
END;

-- 3.Handling Missing / Incorrect Values

SELECT
    SUM(CASE WHEN `Company Names` IS NULL OR TRIM(`Company Names`) = '' THEN 1 ELSE 0 END) AS company_missing,
    SUM(CASE WHEN `Cars Names` IS NULL OR TRIM(`Cars Names`) = '' THEN 1 ELSE 0 END) AS car_missing,
    SUM(CASE WHEN `Engines` IS NULL OR TRIM(`Engines`) = '' THEN 1 ELSE 0 END) AS engine_missing,
    SUM(CASE WHEN `CC/Battery Capacity` IS NULL OR TRIM(`CC/Battery Capacity`) = '' THEN 1 ELSE 0 END) AS capacity_missing,
    SUM(CASE WHEN `HorsePower` IS NULL OR TRIM(`HorsePower`) = '' THEN 1 ELSE 0 END) AS horsepower_missing,
    SUM(CASE WHEN `Total Speed` IS NULL OR TRIM(`Total Speed`) = '' THEN 1 ELSE 0 END) AS speed_missing,
    SUM(CASE WHEN `Performance(0 - 100 )KM/H` IS NULL OR TRIM(`Performance(0 - 100 )KM/H`) = '' THEN 1 ELSE 0 END) AS performance_missing,
    SUM(CASE WHEN `Cars Prices` IS NULL OR TRIM(`Cars Prices`) = '' THEN 1 ELSE 0 END) AS price_missing,
    SUM(CASE WHEN `Fuel Types` IS NULL OR TRIM(`Fuel Types`) = '' THEN 1 ELSE 0 END) AS fuel_missing,
    SUM(CASE WHEN `Seats` IS NULL THEN 1 ELSE 0 END) AS seats_missing,
    SUM(CASE WHEN `Torque` IS NULL OR TRIM(`Torque`) = '' THEN 1 ELSE 0 END) AS torque_missing
FROM Cars_dataset2025_2;

SELECT * FROM Cars_dataset2025_2
WHERE `CC/Battery Capacity` IS NULL OR TRIM(`CC/Battery Capacity`) = "";

SELECT * FROM Cars_dataset2025_2
WHERE `Company Names` = "Nissan" AND `Cars Names` = "Urvan" AND `Engines`="2.5L Turbo Diese";

UPDATE Cars_dataset2025_2
SET 
    `CC/Battery Capacity` = '2488 cc',
    `HorsePower` = '127 HP'
WHERE LOWER(TRIM(`Company Names`)) = 'nissan'
  AND LOWER(TRIM(`Cars Names`)) = 'urvan'
  AND LOWER(TRIM(`Engines`)) LIKE '%2.5l turbo diese%';
  
SELECT * FROM Cars_dataset2025_2
WHERE `Company Names` = "Nissan" AND `Cars Names` = "Urvan" AND `Engines`="2.5L Turbo Diese";

SELECT * FROM Cars_dataset2025_2;

-- New numeric columns were created to support analysis and visualization.

ALTER TABLE Cars_dataset2025_2
ADD COLUMN price_min_usd DECIMAL(14,2),
ADD COLUMN price_max_usd DECIMAL(14,2),
ADD COLUMN price_avg_usd DECIMAL(14,2),
ADD COLUMN horsepower_num DECIMAL(10,2),
ADD COLUMN total_speed_kmh DECIMAL(10,2),
ADD COLUMN acceleration_0_100_sec DECIMAL(10,2),
ADD COLUMN torque_nm DECIMAL(10,2),
ADD COLUMN engine_capacity_cc DECIMAL(10,2),
ADD COLUMN battery_capacity_kwh DECIMAL(10,2);


SELECT * FROM Cars_dataset2025_2;

UPDATE Cars_dataset2025_2
SET price_min_usd = CASE
    WHEN `Cars Prices` LIKE '%-%' THEN
        CAST(REPLACE(REGEXP_SUBSTR(SUBSTRING_INDEX(`Cars Prices`, '-', 1), '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(14,2))
    ELSE
        CAST(REPLACE(REGEXP_SUBSTR(`Cars Prices`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(14,2))
END;

UPDATE Cars_dataset2025_2
SET price_max_usd = CASE
    WHEN `Cars Prices` LIKE '%-%' THEN
        CAST(REPLACE(REGEXP_SUBSTR(SUBSTRING_INDEX(`Cars Prices`, '-', -1), '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(14,2))
    ELSE
        CAST(REPLACE(REGEXP_SUBSTR(`Cars Prices`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(14,2))
END;

UPDATE Cars_dataset2025_2
SET price_avg_usd = (price_min_usd + price_max_usd) / 2;

UPDATE Cars_dataset2025_2
SET horsepower_num =
    CAST(REPLACE(REGEXP_SUBSTR(`HorsePower`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(10,2));
    
UPDATE Cars_dataset2025_2
SET total_speed_kmh =
    CAST(REPLACE(REGEXP_SUBSTR(`Total Speed`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(10,2));
    
UPDATE Cars_dataset2025_2
SET acceleration_0_100_sec =
    CAST(
        REPLACE(
            REGEXP_SUBSTR(`Performance(0 - 100 )KM/H`, '[0-9][0-9,]*(\\.[0-9]+)?'),
            ',', ''
        ) AS DECIMAL(10,2)
    );
    
UPDATE Cars_dataset2025_2
SET torque_nm =
    CAST(REPLACE(REGEXP_SUBSTR(`Torque`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(10,2));
    
UPDATE Cars_dataset2025_2
SET engine_capacity_cc = CASE
    WHEN LOWER(`CC/Battery Capacity`) LIKE '%cc%' THEN
        CAST(REPLACE(REGEXP_SUBSTR(`CC/Battery Capacity`, '[0-9][0-9,]*(\\.[0-9]+)?'), ',', '') AS DECIMAL(10,2))
    ELSE NULL
END;

UPDATE Cars_dataset2025_2
SET battery_capacity_kwh = CASE
    WHEN LOWER(`CC/Battery Capacity`) LIKE '%kwh%' THEN
        CAST(
            REPLACE(
                REGEXP_SUBSTR(
                    REGEXP_SUBSTR(LOWER(`CC/Battery Capacity`), '[0-9]+(,[0-9]+)*(\\.[0-9]+)?\\s*kwh'),
                    '[0-9]+(,[0-9]+)*(\\.[0-9]+)?'
                ),
                ',', ''
            ) AS DECIMAL(10,2)
        )
    ELSE NULL
END;

SELECT
    `Company Names`,
    `Cars Names`,
    `Cars Prices`,
    price_min_usd,
    price_max_usd,
    price_avg_usd,
    `HorsePower`,
    horsepower_num,
    `Total Speed`,
    total_speed_kmh,
    `Performance(0 - 100 )KM/H`,
    acceleration_0_100_sec,
    `Torque`,
    torque_nm,
    `CC/Battery Capacity`,
    engine_capacity_cc,
    battery_capacity_kwh
FROM Cars_dataset2025_2
LIMIT 1000;


-- 5. Data Validation / Outlier Detection

SELECT *
FROM Cars_dataset2025_2
WHERE price_min_usd <= 0
   OR price_max_usd <= 0
   OR price_avg_usd <= 0;
   
SELECT *
FROM Cars_dataset2025_2
WHERE horsepower_num <= 0
   OR horsepower_num > 2000;
   
SELECT *
FROM Cars_dataset2025_2
WHERE total_speed_kmh <= 0
   OR total_speed_kmh > 500;

-- This query checks unusual acceleration values.
-- The returned row has 35 seconds acceleration, but it matches a very low horsepower and small engine capacity.
-- Therefore, it is considered a valid outlier and will be ke
-- ⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️
SELECT *
FROM Cars_dataset2025_2
WHERE acceleration_0_100_sec <= 0
   OR acceleration_0_100_sec > 30;
   
SELECT *
FROM Cars_dataset2025_2
WHERE torque_nm <= 0
   OR torque_nm > 3000;
   
-- Add torque unit and converted torque columns
ALTER TABLE Cars_dataset2025_2
ADD COLUMN torque_unit VARCHAR(20),
ADD COLUMN torque_converted_nm DECIMAL(12,2);

UPDATE Cars_dataset2025_2
SET torque_unit = CASE
    WHEN LOWER(`Torque`) LIKE '%lb-ft%' THEN 'lb-ft'
    WHEN LOWER(`Torque`) LIKE '%nm%' THEN 'Nm'
    ELSE 'Unknown'
END;

UPDATE Cars_dataset2025_2
SET torque_converted_nm = CASE
    WHEN torque_unit = 'Nm' THEN torque_nm
    WHEN torque_unit = 'lb-ft' THEN torque_nm * 1.35582
    ELSE NULL
END;

SELECT *
FROM Cars_dataset2025_2
WHERE torque_converted_nm <= 0
   OR torque_converted_nm > 20000;   

SELECT *
FROM Cars_dataset2025_2
WHERE Seats <= 0
   OR Seats > 20;
   
SELECT *
FROM Cars_dataset2025_2
WHERE price_min_usd > price_max_usd;












