# Remediation Inputs (Issue #952) - R1 re-decision with the scoped coverage run (ORCH-R5)

Review-Verdict: HALT_NON_REMEDIABLE

**Entry timestamp:** 2026-10-16T22-01
**Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Base branch:** `main` (merge base `fa27cd5edcb39a5d5f63054c3e38cefef18ab316`; `origin/main` now `cdc7bbc99`, no file overlap)
**Head audited:** `bug/ci-merge-queue-for-main-952` @ `76d654eec7a3607a9782aa0876d5b60093631bb8`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** re-audit after the scoped `codex-hooks` coverage run; no tracked source change since `b844048d9`
**Blocking finding count:** 2 (R1 class human_decision_required; R3 class awaiting_ci). No autonomous finding remains.

## Audit Artifacts

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T22-01.md` (Section 8: PA-1 FAIL as measured with the R1 disposition; PA-3 UNVERIFIED; PA-N5, PA-N6 Info)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T22-01.md` (Findings Table: CR-1 Blocker; CR-10, CR-11, CR-16, CR-17, CR-18, CR-19 Info)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T22-01.md` (26 PASS, 0 PARTIAL, 1 UNVERIFIED (AC-28), 1 FAIL (AC-27))

## Resolved Since the Previous Review

- CR-15 / PA-N3: resolved. The scoped run was performed through `mcp__drm-copilot__run_poshqc_test` (`scan_folders=["tests/scripts/codex-hooks"]`) and `evidence/regression-testing/codex-helper-scoped-coverage.2026-10-16T21-56.md` records the correction of the earlier statements.
- CR-16 / PA-N4: closed with no action. gh 2.87.3 resolves only lowercase `/pull/` URLs; `/PULL/` and `/Pull/` tokens are treated as head-branch selectors (`no pull requests found for branch ...`, exit 1), and `git check-ref-format --branch` rejects such strings, so no merge can result.
- R1 evidence gap: closed. Reviewer parse of the scoped `artifacts/pester/powershell-coverage.xml`: `.codex/hooks/enforce-epic-merge-gate-command.ps1` 54/54 lines credited; lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189 at `ci` 1 to 3; the `.claude/hooks` twin 0/54 in the same report (not in scope); `pester-junit.xml` 1806 tests, 0 failures, 0 errors.

## Workflow Green-Run Evidence (`modified-workflow-needs-green-run`)

- Workflow: `.github/workflows/ci.yml` (modified by this branch).
- Run: R_final_3 38967059138, event `workflow_dispatch`, head `11242f03aae9b839a2a7b5d2bca37fb90594850f`, conclusion `success`, 17/17 jobs success.
- `git diff --stat 11242f03a HEAD` lists feature-folder files only.

## Findings

### R1 - Codex helper full-run coverage below 85% against AC-27 (PA-1, CR-1)

Severity: Blocking
Remediability: human_decision_required
Remediability-Evidence: The scoped run proves every line is executed and credited, so the evidence is complete; what remains is an authorization to accept the full-run figure against AC-27, which issue 935 obtained from its coordinator and recorded as not met as written, and which issue 936 had pre-authorized in operator-written criterion text that AC-27 does not contain.

**Problem.** `.codex/hooks/enforce-epic-merge-gate-command.ps1` measures 74.07% (40/54) in the full CI run (R_final_3), and the PR-head run will report the same figure. In the scoped `codex-hooks` run at the same blob (`94d2145cd`), it measures 100.00% (54/54). The shortfall is an attribution effect of the combined run (issue #936 breakpoint-binding mechanism), not untested code.

**Reviewer disposition.** The evidence suffices and no further evidence step is needed. The reviewer does not record AC-27 as met on the reviewer's authority because (1) AC-27 is verified from the full-run coverage-comparison artifact, whose figure is below the threshold; (2) issue #935, merged to `main` at `cdc7bbc99`, resolved the same evidence class by a coordinator decision record and an amendment line under its AC stating "not met as written"; (3) issue #936's exception was written into its own AC by the operator, and AC-27 has no such clause; (4) the governing coverage rules contain no attribution exception. Full reasoning: `policy-audit.2026-10-16T22-01.md` Section 8.

**Decision requested (option A recommended).** Accept the Codex helper's full-run figure against AC-27 on the basis of the scoped 54/54 result, the line-to-assertion map, and the 100.00% byte-identical Claude copy. Options B (`UseBreakpoints = $false`, being delivered separately by issue #953 / PR #959, open), C (order-dependent tests, rejected by the issue #936 research), and D (rewriting AC-27 text) are not recommended.

**Record format under option A (feature-folder files only; no tracked source change; no remediation cycle).**

1. Write `evidence/other/r1-decision.<timestamp>.md` naming the decision, the authorizing party (operator, or a coordinator with that authority as in issue #935), and the evidence: `evidence/regression-testing/codex-helper-scoped-coverage.2026-10-16T21-56.md`, `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md`, `evidence/qa-gates/coverage-comparison.2026-10-16T21-28.md`, and this file.
2. Add an indented amendment line beneath AC-27 in `spec.md`, leaving the criterion text unchanged, for example: `  - Amendment (<date>, <authorizing party>): the Codex helper's full-run line coverage of 74.07% is accepted as a Pester breakpoint attribution effect (scoped codex-hooks run 54/54); not met as written for that file; the 85% floor, the no-regression clause, and the no-exclusion rule still apply. Decision record: evidence/other/r1-decision.<timestamp>.md.`
3. Check off AC-27 with that qualification.
4. Optional (CR-19): add one sentence to `policy-followups.md` Record 4 citing the scoped-run evidence and issue #953.

**Verification commands.**

```bash
git diff --name-only 76d654eec HEAD   # expect feature-folder files only
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

### R3 - AC-28 pending the `pull_request` CI run on the final PR head (PA-3)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC-28 is verified only by the pull_request run of ci.yml on the final PR head, which cannot exist before the PR is opened; it is resolved at S9 and needs no code change.

**Problem.** No PR exists for the branch, so the `pull_request` run required by AC-28 has not occurred.

**Required change.** None in code. After the R1 decision, merge `origin/main` (`cdc7bbc99`) into the branch (CR-18), open the PR, and check off AC-28 at S9 once `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

## In-Item Non-blocking Findings

| ID | Severity | File | Required change | In-item fix required |
|---|---|---|---|---|
| CR-18 (PA-N5) | Info | branch | Merge `origin/main` (`cdc7bbc99`; no file overlap) before opening the PR. Orchestrator step, not a code change. | No code fix; orchestrator step before the PR |
| CR-19 (PA-N6) | Info | `policy-followups.md` Record 4 | Optional sentence citing the scoped-run evidence and issue #953. | No |
| CR-16 (PA-N4) | Info | `hook-docs-only-diff.ps1:372` (four copies) | None; verified fail-safe. | No |
| CR-17 | Info | `hook-docs-only-diff.ps1` (four copies) | None; the file is at 497 lines. | No |
| CR-10 | Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | None. | No |
| CR-11 | Info | `.claude/settings.json` | None (pre-existing parity). | No |

## Do Not Do

- Do not edit policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not apply, PUT, or otherwise change ruleset 15241672.
- Do not edit `pester.runsettings.psd1`, `config/poshqc-coverage.json`, `.github/workflows/_poshqc.yml`, `.claude/hooks/hook-command-invocation.ps1`, or the PoshQC module in this item; profiler mode is owned by issue #953.
- Do not add coverage exclusions or lower thresholds.
- Do not rewrite the text of AC-27; record any acceptance as an amendment line beneath it.
- Do not check off AC-27 without the recorded decision; do not check off AC-28 before S9.
- Do not let any `.claude/`, `.codex/`, `.agents/` file and its bundle mirror diverge, and do not let the four `hook-docs-only-diff.ps1` copies diverge.

## Exit Gate

A decision on R1 is recorded by an authorized party. Under option A, the decision record and the AC-27 amendment line exist and AC-27 is checked off with the qualification; the item proceeds to the `origin/main` merge, the PR, and S9 without another review cycle, because no tracked source changes. AC-28 is completed at S9.
