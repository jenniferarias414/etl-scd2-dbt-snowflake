"""
Upload Product_Dim.csv to S3 for the Snowflake + dbt SCD Type 2 project.

Credentials are not hardcoded. This script uses the local AWS CLI profile:
scd2-lab
"""

from pathlib import Path
import argparse
import boto3
from botocore.exceptions import ClientError, NoCredentialsError, ProfileNotFound


BUCKET_NAME = "scd2-product-data-jenny"
S3_PREFIX = "raw_data"
AWS_PROFILE = "scd2-lab"


def upload_file_to_s3(local_file_path: Path) -> None:
    """Upload one local CSV file to the configured S3 bucket/prefix."""
    if not local_file_path.exists():
        raise FileNotFoundError(f"File not found: {local_file_path}")

    if local_file_path.suffix.lower() != ".csv":
        raise ValueError(f"Expected a CSV file, received: {local_file_path.name}")

    s3_key = f"{S3_PREFIX}/{local_file_path.name}"

    try:
        session = boto3.Session(profile_name=AWS_PROFILE)
        s3_client = session.client("s3")

        s3_client.upload_file(
            Filename=str(local_file_path),
            Bucket=BUCKET_NAME,
            Key=s3_key,
        )

        print(f"{local_file_path.name} uploaded successfully")
        print(f"s3://{BUCKET_NAME}/{s3_key}")

    except ProfileNotFound as exc:
        raise RuntimeError(
            f"AWS profile '{AWS_PROFILE}' was not found. "
            "Run: aws configure --profile scd2-lab"
        ) from exc

    except NoCredentialsError as exc:
        raise RuntimeError("AWS credentials were not found.") from exc

    except ClientError as exc:
        raise RuntimeError(f"AWS upload failed: {exc}") from exc


def main() -> None:
    parser = argparse.ArgumentParser(description="Upload Product_Dim.csv to S3.")
    parser.add_argument("file", help="Path to the local CSV file.")
    args = parser.parse_args()

    upload_file_to_s3(Path(args.file))


if __name__ == "__main__":
    main()
