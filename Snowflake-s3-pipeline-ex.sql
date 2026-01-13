-- ------------------------------------------------------------
-- 1. CREATE STORAGE INTEGRATION
-- ------------------------------------------------------------
-- This creates a Snowflake storage integration object that allows
-- Snowflake to securely access an S3 bucket using an IAM role.
-- The integration stores the AWS IAM user ARN and External ID
-- that must be added to the AWS IAM role trust policy.
CREATE OR REPLACE STORAGE INTEGRATION s3_data_samples
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::926849997916:role/Snowflake_S3'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-test-bm02/data_samples/')
  COMMENT = 'S3 Bucket: snowflake-test-bm02 / data-samples';

-- ------------------------------------------------------------
-- 2. DESCRIBE INTEGRATION
-- ------------------------------------------------------------
-- Shows the integration details, including:
-- - STORAGE_AWS_IAM_USER_ARN
-- - STORAGE_AWS_EXTERNAL_ID
-- These values must be copied into the AWS IAM role trust policy.
DESC integration s3_data_samples;

-- NOTE:
-- After running DESC, update the AWS IAM role trust policy with:
--   Principal = STORAGE_AWS_IAM_USER_ARN
--   ExternalId = STORAGE_AWS_EXTERNAL_ID


-- ------------------------------------------------------------
-- 3. CREATE FILE FORMAT
-- ------------------------------------------------------------
-- Defines how Snowflake should interpret CSV files:
-- - comma-separated
-- - skip the header row
-- - treat NULL and empty fields as NULL values
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT
    TYPE = csv
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE;


-- ------------------------------------------------------------
-- 4. CREATE EXTERNAL STAGE
-- ------------------------------------------------------------
-- Creates a Snowflake stage that points to the S3 bucket.
-- The stage uses the storage integration and file format defined above.
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_csv
    URL = 's3://snowflake-test-bm02/data_samples/'
    STORAGE_INTEGRATION = s3_data_samples
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT;

-- View stage details
DESC stage MANAGE_DB.external_stages.aws_csv;


-- ------------------------------------------------------------
-- 5. LIST FILES IN THE STAGE
-- ------------------------------------------------------------
-- Lists all files in the S3 folder.
LIST @MANAGE_DB.external_stages.aws_csv;

-- Lists a specific file (weather.csv) if it exists.
LIST @MANAGE_DB.external_stages.aws_csv/weather.csv;


-- ------------------------------------------------------------
-- 6. INFER SCHEMA FROM A CSV FILE
-- ------------------------------------------------------------
-- Snowflake inspects the file and suggests column names and data types.
-- Useful for understanding the structure before creating a table.
SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@MANAGE_DB.external_stages.aws_csv/house-price.csv',
        FILE_FORMAT => 'MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT'
    )
);


-- ------------------------------------------------------------
-- 7. CREATE TARGET TABLE
-- ------------------------------------------------------------
-- Creates a table with a manually defined schema that matches
-- the structure of the house-price.csv dataset.
CREATE OR REPLACE TABLE TEST_DB.FIRST_SCHEMA.house_price (
    price              NUMBER(10,0),
    area               NUMBER(10,0),
    bedrooms           NUMBER(2,0),
    bathrooms          NUMBER(2,0),
    stories            NUMBER(2,0),
    mainroad           VARCHAR,
    guestroom          VARCHAR,
    basement           VARCHAR,
    hotwaterheating    VARCHAR,
    airconditioning    VARCHAR,
    parking            NUMBER(2,0),
    prefarea           VARCHAR,
    furnishingstatus   VARCHAR
);


-- ------------------------------------------------------------
-- 8. LOAD DATA FROM S3 INTO THE TABLE
-- ------------------------------------------------------------
-- Loads the CSV file from the external stage into the table.
-- Uses the CSV file format defined earlier.
COPY INTO TEST_DB.FIRST_SCHEMA.house_price
FROM @MANAGE_DB.external_stages.aws_csv/house-price.csv
FILE_FORMAT = (FORMAT_NAME = MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT);


-- ------------------------------------------------------------
-- 9. VERIFY THE LOADED DATA
-- ------------------------------------------------------------
-- Shows the first 20 rows of the loaded dataset.
SELECT *
FROM TEST_DB.FIRST_SCHEMA.house_price
LIMIT 20;


-- ------------------------------------------------------------
-- 10. (OPTIONAL) COPY TEMPLATE FOR WEATHER DATA
-- ------------------------------------------------------------
-- Placeholder for loading another dataset (weather.csv).
COPY INTO TEST_DB.FIRST_SCHEMA.weather;
