Timestamp: 2026-02-21T12-30
Command: poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "powershell_atomic_agents_require_mode_aware_preflight_contract"
EXIT_CODE: 1
Output Summary:
- Selected test failed as expected in red phase.
- Failure assertion: missing `Work Mode: minor-audit` contract text in `.github/agents/powershell-atomic-planning.agent.md`.
- Pytest result: 1 failed, 7 deselected.
