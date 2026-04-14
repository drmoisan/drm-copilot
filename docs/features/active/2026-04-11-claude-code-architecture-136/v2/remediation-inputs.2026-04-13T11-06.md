# Remediation Inputs: Claude Code architecture v2 post-review loop (#136)

Timestamp: 2026-04-13T11:06-04:00
Feature Folder: `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
Base Branch: `origin/development`
Head Branch: `feature/claude-code-architecture-136`
Primary Requirements Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-06.md`

## Scope Summary

This remediation loop is limited to the remaining blockers confirmed by the 2026-04-13T11-06 re-review:

1. `.claude/settings.json` still fails `validate_json`.
2. The canonical multi-folder `mcp__drmCopilotExtension__run_poshqc_test` wrapper still fails with a duplicate `ScanFolders` binding error.
3. Numeric PowerShell coverage evidence is still unavailable because the Koverage copy remains empty.

The prior stale PowerShell symbol finding is closed in the scoped runtime files and runtime tests and must stay closed.

## Enumerated Fix List

1. Restore a schema-valid and policy-consistent PowerShell test-runner settings contract.
   - Files in scope: `.claude/settings.json`, `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, `docs/engineering/claude-code-architecture.md`.
   - Current defect: `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` exits 1 because `mcp_drmcopilotext_run_poshqc_test` does not match the current schema regex.
   - Expected behavior: the runtime/test/docs contract remains internally consistent and `validate_json` exits 0.
   - Verification commands:
     - `poetry run python -m scripts.dev_tools.format_json .claude/settings.json`
     - `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
     - `rg -n "run_poshqc_test" .claude tests/scripts/claude-runtime docs/engineering/claude-code-architecture.md`

2. Restore the canonical multi-folder PowerShell MCP test command.
   - Files in scope: `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` and any repo-controlled invocation or packaging code required to pass the `scan_folders` array correctly.
   - Current defect: `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])` exits 1 with `Cannot bind parameter because parameter 'ScanFolders' is specified more than once`.
   - Expected behavior: the canonical MCP tool accepts the multi-folder scope and reaches Pester execution without fallback commands.
   - Verification commands:
     - `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
     - Any targeted regression test added for the wrapper argument-marshalling path.

3. Produce numeric PowerShell coverage evidence for the scoped remediation run.
   - Files in scope: `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `artifacts/pester/powershell-coverage.koverage.xml`, and any repo-controlled coverage-output path needed to emit the numeric values.
   - Current defect: the fallback targeted test run passes, but `artifacts/pester/powershell-coverage.koverage.xml` remains a 4-byte payload and `p4-t7` records `CoverageGateStatus: BLOCKED`.
   - Expected behavior: the final targeted PowerShell test run produces extractable numeric baseline, post-change, and changed/new-code coverage values, or a repository-approved alternative artifact path that carries those numbers.
   - Verification commands:
     - `Get-Item artifacts/pester/powershell-coverage.koverage.xml`
     - `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
     - Any targeted regression test added for coverage-copy generation or extraction.

## Verified Open Blockers

- `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
- `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t7.powershell-coverage-comparison.2026-04-13T09-58.md`

## Do Not Do

- Do not reopen the already-cleared stale-symbol finding unless the diff actually reintroduces `mcp__drmCopilotExtension__run_poshqc_test`.
- Do not broaden scope beyond the settings/schema contract, the canonical multi-folder PowerShell MCP test wrapper, and numeric coverage evidence generation.
- Do not weaken policy by skipping `validate_json`, substituting undocumented fallback commands in final QA, or treating unavailable coverage as PASS.
- Do not mark live Claude-session criteria PASS without transcript-level runtime evidence under `evidence/qa-gates/`.

## Required Context Package For Planning

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T11-06.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T11-06.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T11-06.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T09-58.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
