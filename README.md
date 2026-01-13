# Snowflake-S3-Test-Bm
This project demonstrates how to build a secure and fully functional data ingestion pipeline using Amazon S3 and Snowflake. The pipeline loads a CSV file (house-price.csv) stored in S3 into a Snowflake table for analysis.

**The workflow includes:**

⦁	Creating a Snowflake Storage Integration

⦁	Configuring AWS IAM trust

⦁	Creating a File Format

⦁	Creating an External Stage

⦁	Listing and previewing files in S3

⦁	Inferring schema from the CSV

⦁	Creating a target table

⦁	Loading the data using COPY INTO

**🏗️ Architecture**

S3 Bucket (data_samples/) 

│ 

▼ 

Snowflake Storage Integration 

│ 

▼ 

Snowflake External Stage 

│ 

▼ 

Snowflake Table (house_price)

**📊 Dataset Description**

The dataset contains housing attributes such as:

⦁	Price

⦁	Area (sq ft)

⦁	Bedrooms

⦁	Bathrooms

⦁	Stories

⦁	Road access

⦁	Guest room availability

⦁	Basement

⦁	Heating

⦁	Air conditioning

⦁	Parking spaces

⦁	Preferred area

⦁	Furnishing status

Ideal for regression modeling or exploratory analysis.
