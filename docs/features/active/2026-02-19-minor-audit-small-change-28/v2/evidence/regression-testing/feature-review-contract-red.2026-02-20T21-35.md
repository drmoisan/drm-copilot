Timestamp: 2026-02-20T21-35
Command: poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_branching_contract"
EXIT_CODE: 1
Output Summary: 
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\unit\test_minor_audit_mode_contract_docs.py F                      [100%]

================================== FAILURES ===================================
___________________ test_feature_review_branching_contract ____________________

    def test_feature_review_branching_contract() -> None:
        """Verify feature review agent defines marker-driven AC source branching."""
        path = Path(".github/agents/feature-review.agent.md")
        content = _read_text(path)
    
>       assert "Work Mode: minor-audit" in content
E       AssertionError: assert 'Work Mode: minor-audit' in '---\nname: feature_code_review_agent\nmodel: GPT-5.2-Codex (copilot)\ndescription: Review an entire feature branch re...tifact is missing, continue execution and create/regenerate it; do not claim completion.\n\nEnd of agent instructions.'

tests\unit\test_minor_audit_mode_contract_docs.py:18: AssertionError
=========================== short test summary info ===========================
FAILED tests/unit/test_minor_audit_mode_contract_docs.py::test_feature_review_branching_contract
============================== 1 failed in 0.04s ==============================

