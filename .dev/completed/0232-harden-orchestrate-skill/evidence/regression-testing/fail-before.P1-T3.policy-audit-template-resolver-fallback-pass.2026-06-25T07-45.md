Timestamp: 2026-06-25T07-45
Command: poetry run pytest tests/scripts/dev_tools/test_validate_policy_audit_artifact.py::test_validate_policy_audit_text_rejects_missing_mcp_template_resolver_pass
EXIT_CODE: 1
Output Summary:
- Pytest collected 1 targeted test.
- The test failed before implementation because validate_policy_audit_text did not reject a policy audit that reported resolve_policy_audit_template_asset was not exposed while also reporting READY and PASS.
- Failure assertion: assert any("resolve_policy_audit_template_asset" in error for error in errors).
