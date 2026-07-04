# Policy Compliance Audit: Claude Code architecture v2 (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Audit Scope:** PowerShell test-runner contract remediation only

## Refreshed Evidence

- `evidence/qa-gates/p4-t1.poshqc-format.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t2.settings-json-format.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t3.settings-json-validation.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t4.poshqc-analyze.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t5.poshqc-test.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t6.powershell-test-symbol-green.2026-04-13T09-58.md`
- `evidence/qa-gates/p4-t7.powershell-coverage-comparison.2026-04-13T09-58.md`

## Findings

1. **FAIL — `.claude/settings.json` no longer validates against the configured Claude settings schema.**
   - Evidence: `p4-t2` shows formatting succeeded and `p4-t6` shows the runtime now uses `mcp_drmcopilotext_run_poshqc_test`, but `p4-t3` records schema validation failure because the current schema only accepts `mcp__.*` patterns in `permissions.allow`.
   - Impact: The remediation fixed the runtime contract mismatch but introduced a schema-validation blocker in the JSON gate.

2. **UNVERIFIED — Numeric PowerShell coverage remains unavailable for this remediation scope.**
   - Evidence: `p4-t5` records a passing targeted Pester run with `CoverageNumericValues: unavailable`, and `p4-t7` records `CoverageGateStatus: BLOCKED`.
   - Impact: Coverage policy closure remains blocked even though the targeted tests pass.

## Cleared Finding

- The stale PowerShell test-runner symbol `mcp__drmCopilotExtension__run_poshqc_test` is no longer present in the six scoped runtime and runtime-test files reviewed by this remediation. Evidence: `p4-t6`.

## Verdict

**Verdict:** ❌ FAIL — remediation incomplete

The stale PowerShell test-runner contract mismatch is corrected in the scoped runtime files and regression tests, and the targeted PowerShell format/analyze/test steps pass (`p4-t1`, `p4-t4`, `p4-t5`). The feature is still not policy-clean because `.claude/settings.json` fails schema validation (`p4-t3`) and PowerShell numeric coverage remains blocked (`p4-t7`).
