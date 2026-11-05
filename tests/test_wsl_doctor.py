import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from wsl_doctor import (
    CheckResult,
    calculate_optimal_wslconfig,
    compute_health_score,
    render_wslconfig,
    run_audit,
     main,
)


def test_calculate_optimal_wslconfig_8gb():
    cfg = calculate_optimal_wslconfig(8.0, 4)
    assert cfg["memory_mb"] == 4608
    assert cfg["processors"] == 4
    assert cfg["swap_gb"] == 2
    assert cfg["autoMemoryReclaim"] == "gradual"
    assert cfg["dnsTunneling"] is True


def test_calculate_optimal_wslconfig_16gb_and_32gb():
    cfg16 = calculate_optimal_wslconfig(16.0, 8)
    assert 9000 <= cfg16["memory_mb"] <= 10500
    assert cfg16["swap_gb"] == 4

    cfg32 = calculate_optimal_wslconfig(32.0, 16)
    assert cfg32["memory_mb"] > 20000
    assert cfg32["swap_gb"] == 8


def test_render_wslconfig_contains_required_keys():
    cfg = calculate_optimal_wslconfig(8.0, 4)
    text = render_wslconfig(cfg)
    assert "[wsl2]" in text
    assert "memory=4608MB" in text
    assert "autoMemoryReclaim=gradual" in text
    assert "dnsTunneling=true" in text
    assert "sparseVhd=true" in text
    assert "pageReporting" not in text


def test_compute_health_score():
    checks = [
        CheckResult("1", "Mem", "A", "PASS", "15", "15", "", ""),
        CheckResult("2", "Net", "B", "WARN", "cubic", "bbr", "", ""),
    ]
    assert compute_health_score(checks) == 75


def test_run_audit_offline():
    report = run_audit(skip_network=True)
    data = report.to_dict()
    assert 0 <= data["score"] <= 100
    assert len(data["checks"]) >= 5


def test_cli_json_output(capsys):
    rc = main(["check", "--json", "--skip-network"])
    assert rc == 0
    captured = capsys.readouterr().out
    parsed = json.loads(captured)
    assert "score" in parsed
    assert isinstance(parsed["checks"], list)
