def test_valid_ping_is_saved(client, table):
    resp = client.post("/ping", json={"machine_id": "m01", "seq": 1})

    assert resp.status_code == 200
    assert resp.get_json()["status"] == "accepted"

    item = table.get_item(Key={"machine_id": "m01"})["Item"]
    assert item["last_seq"] == 1

def test_dynamodb_failure_returns_500(client, table):
    table.delete()
    first = client.post("/ping", json={"machine_id": "m01", "seq": 5})

    assert first.status_code == 500
    assert first.get_json()["ERROR"] == "Internal server error"

def test_repeated_seq_returns_duplicate(client, table):
    first = client.post("/ping", json={"machine_id": "m01", "seq": 1})
    second = client.post("/ping", json={"machine_id": "m01", "seq": 1})

    assert first.status_code == 200
    assert first.get_json()["status"] == "accepted"
    assert second.status_code == 200
    assert second.get_json()["status"] == "duplicate"

def test_lower_seq_is_rejected_and_latest_kept(client, table):
    first = client.post("/ping", json={"machine_id": "m01", "seq": 5})
    second = client.post("/ping", json={"machine_id": "m01", "seq": 3})

    assert first.status_code == 200
    assert first.get_json()["status"] == "accepted"
    assert second.status_code == 200
    assert second.get_json()["status"] == "duplicate"
