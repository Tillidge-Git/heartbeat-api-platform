import boto3
import pytest
from moto import mock_aws

from app.main import create_app

@pytest.fixture
def table():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="eu-west-2")
        table = dynamodb.create_table(
            TableName="heartbeat",
            KeySchema=[{"AttributeName": "machine_id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "machine_id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        yield table


@pytest.fixture
def client(table):
    app = create_app(table=table)
    return app.test_client()