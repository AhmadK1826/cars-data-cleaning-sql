# Cars Data Cleaning SQL

## Project Overview

This project focuses on cleaning the Cars Dataset 2025 using SQL.  
The dataset contains information about car companies, car names, engines, horsepower, speed, acceleration, prices, fuel types, seats, torque, and engine or battery capacity.

The main goal of this project is to prepare the dataset for analysis by removing duplicates, standardizing values, handling missing or incorrect data, converting text-based numeric values into numerical columns, and validating the cleaned data.

## Files in This Repository

| File Name | Description |
|---|---|
| Cars Datasets 2025.csv | Original cars dataset |
| Cars Datasets 2025.sql | SQL script used for data cleaning |
| Data Cleaning Report Cars Dataset 2025.docx | Report explaining the cleaning process |
| README.md | Project documentation |

## Data Cleaning Steps

### 1. Removing Duplicates

Duplicate rows were identified using the `ROW_NUMBER()` window function.  
Rows with `row_num > 1` were considered duplicates and removed from the dataset.

### 2. Data Standardization

Text values were standardized using SQL string functions such as:

- `TRIM()`
- `LOWER()`
- `UPPER()`
- `CASE`

This step was used to remove extra spaces and standardize values such as company names and fuel types.

### 3. Handling Missing and Incorrect Values

The dataset was checked for missing values using `NULL` and empty string conditions.  
One incorrect value was found in the Nissan Urvan record, where the engine capacity was placed in the wrong column.  
The value was corrected by updating the engine capacity and horsepower fields.

### 4. Data Type Conversion

Several columns contained numeric values stored as text because they included units or symbols, such as:

- `$28,000`
- `248 hp`
- `240 km/h`
- `6.3 sec`
- `500 Nm`
- `1,984 cc`
- `13.8 kWh`

New numeric columns were created to support analysis and visualization, including:

- `price_min_usd`
- `price_max_usd`
- `price_avg_usd`
- `horsepower_num`
- `total_speed_kmh`
- `acceleration_0_100_sec`
- `torque_nm`
- `engine_capacity_cc`
- `battery_capacity_kwh`

### 5. Data Validation and Outlier Detection

Validation queries were used to detect unusual or invalid values, such as:

- Negative or zero prices
- Extremely high horsepower values
- Unrealistic speed values
- Unusual acceleration values
- Invalid seat numbers
- Cases where minimum price is greater than maximum price

Torque values were also checked because some cars used `Nm`, while others used `lb-ft`.  
A converted torque column was created to make torque values easier to compare.

## Tools Used

- MySQL
- SQL Window Functions
- SQL String Functions
- Regular Expressions
- Data Validation Queries

## Skills Demonstrated

- Data cleaning
- Duplicate removal
- Data standardization
- Handling missing values
- Data type conversion
- Outlier detection
- SQL data preparation for analysis

## Conclusion

The Cars Dataset 2025 was cleaned and prepared for further analysis.  
The final dataset is more consistent, accurate, and ready for visualization or analytical tasks.
