# Preflight Fixes (round two)

Timestamp: 2026-11-23T06-36
Plan: .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md
Command: single-pass preflight review, round two (DIRECTIVE: PREFLIGHT VALIDATION ONLY); validators `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md` and MCP `validate_orchestration_artifacts` (artifact_type plan)
EXIT_CODE: 0
Output Summary: Two trivial defects were fixed in place in the task text of P2-T2. No task was added, removed, or reordered. Both validators passed before the fixes. Three substantive defects are returned to the caller separately. The round-one record `preflight-fixes.2026-11-23T06-23.md` is unchanged.

## Fixes

1. [P2-T2] | validator-blind: test feasibility constraint | added that the lint-scope `run: |` body contains no `exit` statement. The in-memory behavior test runs the body through `[scriptblock]::Create` inside the Pester process, where an `exit` statement would end the test run. What the test asserts is unchanged.
2. [P2-T2] | validator-blind: existing tests affected by the change not named | added unchanged dispositions for `It 'runs inventory, check and validate in docs-complete mode with the revision and the receipt switch'` and `It 'runs surface-delta only when the base-ref input is supplied'` in `DocsInitTemplate.DocsWorkflow.Tests.ps1`, which read the rewritten template.
