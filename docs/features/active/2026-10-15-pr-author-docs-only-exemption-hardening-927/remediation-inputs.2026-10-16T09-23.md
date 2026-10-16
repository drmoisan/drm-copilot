# Remediation Inputs: pr-author docs-only exemption hardening (#927), review 2026-10-16T09-23

Review-Verdict: REMEDIATION_REQUIRED

- Branch: `bug/pr-author-docs-only-exemption-hardening-927` at `65c068515b561ba8b965e189d870efbd31fcdb37`
- Base: `main`; merge-base `4776ccd9366d8f580ac9ac0fe164d75306785218`
- Review timestamp: 2026-10-16T09-23 (R4 re-audit after remediation cycle 1)
- Source artifacts:
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/policy-audit.2026-10-16T09-23.md`
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/code-review.2026-10-16T09-23.md`
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/feature-audit.2026-10-16T09-23.md`
- Prior remediation inputs: `remediation-inputs.2026-10-16T05-09.md` (PA-1).

## Remediation Required

### PA-1R: regenerate the local PowerShell coverage artifact over the full population (carried from PA-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect is a gitignored tool output; one direct Invoke-PoshQCTest run in the item worktree regenerates it with no code change, no external service, and no operator decision, and the CI artifact of run 38876469175 shows the code meets every threshold.

- Finding: `artifacts/pester/powershell-coverage.xml` (mtime 2026-10-16 04:43:02 -04:00) is a scoped PoshQC MCP output. JaCoCo report-level LINE: covered 8128, missed 4170 (66.09%), below the 85% repo-wide floor. It has no `sourcefile` entry for `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, or `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. The companion `artifacts/pester/pester-junit.xml` reports tests=7183, against 10545 in the full-population CI run.
- Why remediation cycle 1 did not close it: decision D-R1-10 (`evidence/other/r1-decisions.2026-10-16T07-41.md:14`, "PA-1 closed from CI artifact (Option A); artifacts/pester not regenerated") replaced the required local run with the CI artifact. The reviewer contract names the local path as the PowerShell coverage artifact, and the `validate-feature-review-coverage` SubagentStop hook (`.claude/hooks/validate-feature-review-coverage-metrics.ps1:176`) reads that local path and requires a FAIL coverage verdict while its repo-wide line is below 85%. A CI artifact therefore cannot close this finding, however complete it is.
- Not a code defect: the reviewer parsed the CI artifact of run 38876469175 (head `7966e1564`, code identical to HEAD): repo-wide LINE 16580/18369 (90.26%); helper copies 97.52% each; `enforce-pr-author-skill.docs-only.ps1` 100.00%; `enforce-pr-author-skill.ps1` 92.98%; Claude gate 99.29%; resolution sibling 95.65%; Codex gate 88.41%.
- Required action: in the item worktree, run the repository module directly in PowerShell 7 (the CI form at `.github/workflows/_poshqc.yml`): `Import-Module <worktree>/scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree>`. Do not use `mcp__drm-copilot__run_poshqc_test` for this step; the MCP runner reads installed-extension settings and measures a scoped population. Do not hand-copy, download, or edit the XML. Record the run in a new file under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/` (command, exit code read from the host, XML mtime, report-level LINE counters, per-file LINE counters for the seven files below, the `pester-junit.xml` root tests/failures/errors, and a `Timestamp:` row read from the host clock). Do not commit the XML; it is gitignored.
- Pass condition: report-level LINE at or above 85.00%; a `sourcefile` entry at or above 85.00% line for each of `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`; `pester-junit.xml` root tests near the full population (about 10500) with failures=0 and errors=0.
- Verification commands: parse the regenerated XML for report-level and per-`sourcefile` `LINE` counters; read the `<testsuites>` root of `artifacts/pester/pester-junit.xml`.
- If the direct run cannot execute in the worktree (for example a hook denies it), stop and report the exact denial text rather than substituting another artifact; that outcome would change the classification of this finding.

## Related Non-blocking Observations (fix in this item where related)

Each item below is listed with file and line. None changes the review verdict.

1. CR-R1 (Low): `.claude/hooks/hook-docs-only-diff.ps1:199-222` - the `Process` object from the starter is not disposed. Action: `try { ... } finally { $process.Dispose() }` with a no-op `Dispose` on the test fake, or record the short-lived-process rationale in the function help. Any edit must be applied byte-identically to all four helper copies.
2. CR-R2 (Low): `.claude/hooks/hook-docs-only-diff.ps1:187` - the real `[System.Diagnostics.Process]::Start` path is not executed by any test, so tree termination is verified only against the fake. Action (optional): one integration row outside the unit suites against a real short-lived executable with a 1 ms limit asserting exit 124.
3. CR-R3 (Info): `.claude/hooks/hook-docs-only-diff.ps1:50-56` and `.codex/config.toml:144` - the 20 s worst case leaves about 10 s under the Codex 30 s timeout once start-up is included. No action.
4. CR-R4 (Info): `.codex/hooks/enforce-epic-merge-gate.ps1:403` - changed entry-point line uncovered in CI, also uncovered at baseline (line 377). No action.
5. CR-R5 (Info): `.claude/hooks/enforce-epic-merge-gate.ps1` is 491 lines (limit 500). No action in this item.
6. CR-R6 (Info): `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:21-28` - Claude seam mocks retained because the discovery guard requires them. No action.

## Pending CI (not findings)

- AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24: CI-dependent; checked off at S9 by the item's orchestrator run from the PR-head CI run. CI run 38876469175 on `7966e1564` supports each.

## Do Not Do

- Do not close PA-1R from a CI artifact or from an MCP test run.
- Do not edit `artifacts/pester/powershell-coverage.xml` by hand or copy it from a CI artifact.
- Do not exclude any production file from coverage measurement or narrow `config/poshqc-coverage.json`.
- Do not edit files under `.claude/rules/` or `.github/instructions/`.
- Do not rename evidence files or edit prior review artifacts.
