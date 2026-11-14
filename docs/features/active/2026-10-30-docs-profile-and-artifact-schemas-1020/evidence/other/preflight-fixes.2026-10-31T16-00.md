# Preflight Fixes - Issue 1020

Timestamp: 2026-10-31T16-00
Plan: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/plan.2026-10-30T16-08.md

## Fixes

1. [P4-T4] | literal-formatting defect (unstated root derivation in a test that reads committed files) | The real-context tests and the call-operator runs of the guarded top-level body pass "the repository root" without stating how the suite derives it. `.claude/rules/powershell.md` `### Deterministic Test Requirements` forbids implicit working-directory assumptions. Added that the root is resolved from the suite's `$PSScriptRoot`, as in `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1`, never from the current location, and that every repository-root use in the suite takes that value. The asserted outcomes are unchanged.
2. [P4-T4] | validator-blind defect (exit-code assertion that could pass without `exit` being reached) | The `-Help` call-operator run asserts `$LASTEXITCODE` 0, which an earlier zero value in the session would also satisfy. Added that the global `$LASTEXITCODE` is set to the sentinel 99 before each call-operator run, following the precedent in `tests/scripts/dev-tools/verify-host.Tests.ps1`. The asserted values (0 and 2) are unchanged.
