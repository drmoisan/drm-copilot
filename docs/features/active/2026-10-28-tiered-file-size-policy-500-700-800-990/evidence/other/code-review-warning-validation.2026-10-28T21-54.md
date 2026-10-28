# Code-Review Warning Row Validation

Timestamp: 2026-10-28T21-54
Command: mcp__drm-copilot__validate_orchestration_artifacts (artifact_type code-review) on evidence/other/code-review-warning-sample.2026-10-28T21-54.md; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review <same path>
EXIT_CODE: 0
Output Summary:
- Installed-extension MCP validator: `ok: true`, summary `Validated code-review artifact at '.../code-review-warning-sample.2026-10-28T21-54.md'.`
- Branch-current Python CLI: exit 0, `code-review validation passed: .../code-review-warning-sample.2026-10-28T21-54.md`.
- The sample is a complete artifact from the updated template with one `Warning` severity row in the Findings Table; both validators accept it.
