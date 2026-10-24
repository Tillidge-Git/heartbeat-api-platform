from app.main import create_app


def test_health_returns_200():
    app = create_app(table="unused")
    client = app.test_client()

    resp = client.get("/health")

    assert resp.status_code == 200
    assert resp.get_json() == {"status": "healthy"}

    