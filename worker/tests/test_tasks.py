from nexora.tasks import build_system_report


def test_system_report_has_meaningful_health_checks():
    report = build_system_report("worker-test")

    assert report["summary"] == "System report generated successfully"
    assert report["generated_by"] == "worker-test"
    assert len(report["checks"]) == 3
    assert {check["status"] for check in report["checks"]} == {"healthy"}
