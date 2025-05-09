import boto3
import csv
import os
import datetime
import logging
from dateutil.relativedelta import relativedelta

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

REGION_NAME = os.getenv("REGION_NAME", "us-east-1")

# setting up aws clients
cost_explorer_client = boto3.client("ce", region_name=REGION_NAME)
s3_client = boto3.client("s3")
sts_client = boto3.client("sts")

# fetching account id
account_id = sts_client.get_caller_identity()["Account"]
logger.info(f"Fetching AWS Account ID: {account_id}")

# Environment variables
CUR_S3_BUCKET = os.getenv("CUR_S3_BUCKET", f"{account_id}-cost-usage-reports")
CUR_RANGE = os.getenv("CUR_RANGE", "daily")

logger.info(f"Using CUR bucket: {CUR_S3_BUCKET}")
logger.info(f"Using CUR range: {CUR_RANGE}")

# fetches the cost and usage data from AWS Cost Explorer api
def get_cur_data(time_range):
    end_date = datetime.date.today() - datetime.timedelta(days=1)
    if time_range == "daily":
        start_date = end_date - datetime.timedelta(days=1)
    elif time_range == "weekly":
        start_date = end_date - datetime.timedelta(weeks=1)
    elif time_range == "monthly":
        start_date = end_date - relativedelta(months=1)
    else:
        logger.error("Invalid time range specified")
        raise ValueError("Invalid time range")

    logger.info(f"Fetching AWS Cost and Usage data from {start_date} to {end_date}...")

    try:
        response = cost_explorer_client.get_cost_and_usage(
            TimePeriod={"Start": str(start_date), "End": str(end_date)},
            Granularity="DAILY",
            Metrics=["UnblendedCost"],
            GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
        )

        data = [["Date", "Service", "Cost (USD)"]]
        for result in response["ResultsByTime"]:
            for group in result["Groups"]:
                date = result["TimePeriod"]["Start"]
                service = group["Keys"][0]
                cost = group["Metrics"]["UnblendedCost"]["Amount"]
                data.append([date, service, cost])

        logger.info("Successfully fetched cost data.")
        return data

    except Exception as e:
        logger.error(f"Error fetching cost data: {e}")
        raise

# Save to CSV and upload to S3
def save_to_s3(data):
    date_str = datetime.date.today().strftime("%Y-%m-%d")
    file_name = f"cost-usage-report-{date_str}.csv"
    file_path = f"/tmp/{file_name}"

    try:
        logger.info(f"Saving cost data to CSV: {file_name}")
        with open(file_path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerows(data)

        logger.info(f"Uploading {file_name} to s3://{CUR_S3_BUCKET}/{file_name}...")
        s3_client.upload_file(file_path, CUR_S3_BUCKET, file_name)
        logger.info("File uploaded successfully.")

    except Exception as e:
        logger.error(f"Error saving/uploading CSV: {e}")
        raise

# lambda handler function
def lambda_handler(event, context):
    logger.info("Lambda function triggered.")
    try:
        data = get_cur_data(CUR_RANGE)
        save_to_s3(data)
        return {"statusCode": 200, "body": f"Cost data saved to S3 as CSV."}
    except Exception as e:
        logger.error(f"Lambda execution failed: {e}")
        return {"statusCode": 500, "body": "Error processing cost data"}

# For local testing
if __name__ == "__main__":
    logger.info("Running script locally...")
    try:
        data = get_cur_data(CUR_RANGE)
        save_to_s3(data)
        logger.info("Execution completed successfully.")
    except Exception as e:
        logger.error(f"Local execution failed: {e}")
