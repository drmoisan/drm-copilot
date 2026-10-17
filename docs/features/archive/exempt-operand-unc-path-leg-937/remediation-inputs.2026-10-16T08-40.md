# Remediation Inputs — Cycle 2

- Timestamp: 2026-10-16T08-40
- Issue: #937
- Branch: bug/exempt-operand-unc-path-leg-937 (HEAD `5d34fe4368dcb65244352b0c633514a2424b4b79` before the merge of origin/main)
- Source audits: `policy-audit.2026-10-16T08-30.md`, `code-review.2026-10-16T08-30.md`, `feature-audit.2026-10-16T08-30.md` (cycle 1 reaudit, verdict PASS, blocking count 0)
- Blocking count at entry: 0
- Author: orchestrator. Cycle opened under the run rule that related non-blocking findings (same files, same feature) are fixed inside the item before DONE.

Review-Verdict: PASS (cycle opened for related non-blocking findings)

## Findings In Scope

### RI-7 (code-review CR-1) — URI schemes other than `file:` still resolve to the session root

- File: `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` lines 41-42 (`OrchestrationTargetNonLocalPattern`) and its three byte-identical copies.
- Observation (reviewer regex probe): `http://server/share/a.ps1`, `smb://server/share/a.ps1`, and `vscode-remote://wsl/x` match no alternative, fail the absolute pattern after normalization, and take the relative fallback to the session root. Same misresolution class as #937.
- Required outcome: generalize the `file:` alternative to a URI scheme of two or more characters (for example `[A-Za-z][A-Za-z0-9+.-]+:`), keep the drive-letter alternatives and the drive-root exception (`C:\`, `C:/`) unchanged, keep every currently passing row passing, and add expect-fail rows for at least `http`, `smb`, and `vscode-remote` spellings on both surfaces before the fix (CI fail-before, then pass-after). Re-copy the three mirrors byte-for-byte and re-run the Parity suite and the push-down contract tests. Add a spec.md acceptance criterion for this behavior (next free AC number); AC-1..AC-19 text unchanged.

### RI-8 (code-review CR-2 / policy-audit PA-3) — targets test file at 496 of 500 lines

- File: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`.
- Required outcome: before adding RI-7 rows, move the #937 rows (U27 to U31) into a sibling test file under `tests/scripts/claude-hooks/` that runs on both surfaces the same way, with row names unchanged so existing JUnit filters still match; every test file stays at or below 500 lines.

## Not In Scope

- PA-2 (branch behind origin/main): handled by the orchestrator with `git merge origin/main` (no rebase, no force-push, per run rules).
- PA-4 / CR-4 (local MCP coverage population narrower than CI because the runner reads the installed extension's runsettings): unrelated tooling behavior of the installed extension; not a defect of this item's files.
- PA-1 / CR-5 and CR-7: dispositioned in cycle 1 as unrelated.

## Do Not Do

- Do not edit `config/poshqc-coverage.json`, PoshQC settings, or coverage populations.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not widen the production change beyond the non-local pattern of the targets copies.

## Exit Condition

- RI-7 and RI-8 resolved with evidence; re-review artifacts report a blocking count of 0.
