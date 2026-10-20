# P5-T1 models6-ruff

Timestamp: 2026-10-19T15-06
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_report_models.py scripts/dev_tools/discovery/coverage_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1

Duration seconds: 1.217

```text
B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
  --> tests\discovery_runtime\test_report_models.py:87:9
   |
85 |     assert report.to_markdown() == markdown
86 |     with pytest.raises(FrozenInstanceError):
87 |         setattr(report, "document", JsonObject(()))
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
help: Replace `setattr` with assignment

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
