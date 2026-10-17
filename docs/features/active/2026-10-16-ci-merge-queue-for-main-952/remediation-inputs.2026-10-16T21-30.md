# Remediation Inputs (Issue #952) - after cycle 2 (ORCH-R4)

Review-Verdict: HALT_NON_REMEDIABLE

**Entry timestamp:** 2026-10-16T21-30
**Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Base branch:** `main` (merge base `fa27cd5edcb39a5d5f63054c3e38cefef18ab316`)
**Head audited:** `bug/ci-merge-queue-for-main-952` @ `b844048d9cbb0445b329ce220f1d4139a56910ae`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** re-audit after remediation cycle 2
**Blocking finding count:** 2 (R1 class human_decision_required; R3 class awaiting_ci). No autonomous finding remains.

## Audit Artifacts

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T21-30.md` (Section 8: PA-1 FAIL, PA-3 UNVERIFIED; PA-N3, PA-N4 non-blocking; R1 disposition)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T21-30.md` (Findings Table: CR-1 Blocker; CR-15 Minor; CR-10, CR-11, CR-16, CR-17 Info)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T21-30.md` (26 PASS, 0 PARTIAL, 1 UNVERIFIED (AC-28), 1 FAIL (AC-27))

## Resolved Since the Previous Review

- R2 (docs-only URL selector): resolved. M1 refuses any token containing `/pull/` in all four byte-identical `hook-docs-only-diff.ps1` copies (blob `62e0d3529`); N1 to N4 failed before the change and pass on R_final_3 38967059138 on Windows and Linux.
- CR-13: resolved (helpers remain byte-identical; comments accurate; row (g) comment reworded).
- CR-14: resolved (ORCH-R3 CauseStatement records the step-1 status and the `hook-docs-only-diff.ps1` observation).

## Workflow Green-Run Evidence (`modified-workflow-needs-green-run`)

- Workflow: `.github/workflows/ci.yml` (modified by this branch).
- Run: R_final_3 38967059138, event `workflow_dispatch`, head `11242f03aae9b839a2a7b5d2bca37fb90594850f`, conclusion `success`, 17/17 jobs success (reviewer `gh run view`).
- `git diff --stat 11242f03a HEAD` lists three evidence files and `spec.md` checkbox changes only.

## Findings

### R1 - New-file PowerShell coverage below 85% for the Codex helper (PA-1, CR-1)

Severity: Blocking
Remediability: human_decision_required
Remediability-Evidence: Every route that changes the measured figure is either a repository-wide coverage-configuration change that the issue 936 research and policy-followups Record 4 reserve for the operator, an order-dependent test arrangement that the issue 936 research rejected, or an acceptance of the measured shortfall against AC-27, which only the operator can approve.

**Problem.** `.codex/hooks/enforce-epic-merge-gate-command.ps1` measures 74.07% (40/54) on R_final_3, unchanged from R_final_2; uncredited lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189. Each of those lines is executed by a passing named assertion (`evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md`, 14/14), and the byte-identical Claude helper is credited at 100.00%. The uncredited set equals the lines inside the two functions that the first Codex-gate loader (CN-09 in `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`) invokes but does not execute, which is consistent with the issue #936 breakpoint-binding mechanism. That mechanism has not been verified for this file.

**Reviewer disposition.** Not accepted as meeting AC-27 on the reviewer's authority: AC-27 states a measured threshold; the governing coverage rules have no attribution exception; and the issue #936 precedent rested on a documentation-based expected outcome and on a scoped coverage run that showed the affected lines credited, neither of which applies here yet.

**Pre-decision evidence step (recommended; no tracked source change; does not need a remediation cycle).** Run `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the item worktree and `scan_folders = ["tests/scripts/codex-hooks"]`, as issue #936 did (`docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/test-scoped.2026-10-16T01-28.md`). Copy `artifacts/pester/powershell-coverage.xml` to the session scratchpad, read the `<line>` elements of `sourcefile name="enforce-epic-merge-gate-command.ps1"` inside the package whose name ends with `/.codex/hooks`, and record the `ci` value of each of the 14 lines and the file percentage in `evidence/regression-testing/codex-helper-scoped-coverage.<timestamp>.md`. If all 14 lines read `ci` >= 1, the mechanism is supported on the same basis as issue #936; if any reads `ci` 0, the mechanism is refuted for that line and the operator should be told so.

**Operator question.** Issue #952 AC-27 requires PowerShell line coverage >= 85% for new production files. `.codex/hooks/enforce-epic-merge-gate-command.ps1` measures 74.07% in CI because 14 lines, each executed by a passing test, are not credited (likely the issue #936 breakpoint-binding mechanism; the scoped-run result above states whether it is confirmed). Choose one:

- (A) Accept a recorded exception for this one file: treat AC-27 as met on the basis of the line-to-assertion map, the 100.00% byte-identical Claude copy, and the scoped-run result; the orchestrator records the approval and checks off AC-27, and the item proceeds to the PR and S9. Record 4 stays open.
- (B) Adopt `CodeCoverage.UseBreakpoints = $false` (`policy-followups.md` Record 4) in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror, either in this item (after a one-off CI dispatch shows the repository-wide effect) or in a separate item that this item waits for. This changes measurement for every file and for PoshQC extension consumers, and Pester 5.x labels the option experimental.
- (C) Authorize an order-dependent test arrangement in this item (for example, making the CN-09 Codex rows in `hook-command-consumers.Issue824.Tests.ps1` exercise the 14 lines). The issue #936 research rejected this approach because it depends on discovery order and script-cache occupancy.
- (D) Amend AC-27 in `spec.md` to state the attribution exception explicitly.

**Verification commands.**

```bash
# pre-decision evidence step (orchestrator; PoshQC MCP test tool, not a pwsh launcher)
#   mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/codex-hooks"]
#   copy artifacts/pester/powershell-coverage.xml to <scratchpad>; parse the .codex/hooks package entry
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

### R3 - AC-28 pending the `pull_request` CI run on the final PR head (PA-3)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC-28 is verified only by the pull_request run of ci.yml on the final PR head, which cannot exist before the PR is opened; it is resolved at S9 and needs no code change.

**Problem.** No PR exists for the branch, so the `pull_request` run required by AC-28 has not occurred.

**Required change.** None in code. After the R1 decision and the PR is opened, the item's own orchestrator run checks off AC-28 at S9 once `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

## In-Item Non-blocking Findings

| ID | Severity | File | Required change |
|---|---|---|---|
| CR-15 (PA-N3) | Minor | `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md` Section 1; `evidence/qa-gates/coverage-comparison.2026-10-16T21-28.md` CauseStatement | The stated reason that the scoped run could not be performed is inaccurate (the PoshQC MCP test tool route was available). Satisfied by the R1 pre-decision evidence step; the new artifact should state the correction. |
| CR-16 (PA-N4) | Info | `hook-docs-only-diff.ps1:372` (four copies) | Optional: make the `/pull/` check case-insensitive to match `ConvertFrom-EpicMergeGateSelector`; apply to all four copies with one test row per runtime. Fold into any cycle that edits these files. |
| CR-17 | Info | `hook-docs-only-diff.ps1` (four copies) | None; the file is at 497 lines. |

## Do Not Do

- Do not edit policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not apply, PUT, or otherwise change ruleset 15241672.
- Do not edit `pester.runsettings.psd1`, `config/poshqc-coverage.json`, `.github/workflows/_poshqc.yml`, `.claude/hooks/hook-command-invocation.ps1`, or the PoshQC module without the operator choosing option (B).
- Do not add coverage exclusions or lower thresholds.
- Do not check off AC-27 unless the operator chooses option (A) or (D); do not check off AC-28 before S9.
- Do not let any `.claude/`, `.codex/`, `.agents/` file and its bundle mirror diverge, and do not let the four `hook-docs-only-diff.ps1` copies diverge.

## Exit Gate

An operator decision on R1 is recorded. Under (A) or (D), AC-27 is checked off with the decision reference and the scoped-run evidence. Under (B) or (C), a further cycle applies the chosen change, a new `ci.yml` dispatch passes, and ORCH-R3 reports the Codex helper at >= 85%. AC-28 is completed at S9 in every case.
