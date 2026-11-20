# Feature Audit: Epic-Child PR Merges Without CI (Issue #1130), Re-audit After Cycle 1

- **Branch:** `bug/epic-child-pr-ci-required` @ `10c5da1894c7f18fcfab454f5ef5541787ca8212`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent
- **Prior audit:** `feature-audit.2026-11-08T15-30.md` at `03d222c55`

## Scope and Baseline

- Resolved base branch: `main`, confirmed by `artifacts/pr_context.summary.txt` (`origin/main` @ `cdcff3871765396183590128e142a929cf78327b`).
- Merge base: `cdcff3871765396183590128e142a929cf78327b`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `cdcff3871765..10c5da189`, 72 files. The six files added since `03d222c55` are the four prior review artifacts, the cycle-1 evidence artifact, and two cycle-1 files (the Codex `core.json` manifest and the manifest-completeness test module). No other file changed, so per-criterion evidence from the prior audit is carried forward for AC1 to AC12, AC14, and AC15, and AC13 is re-evaluated.
- Work mode: `full-bug` (`- Work Mode: full-bug` in `issue.md`), so the AC source is `spec.md` `## Acceptance Criteria`.
- Baseline behavior (fail before): `child-ci-fail-before.2026-11-08T13-55.md` records that the unmodified branch 1 allowed `gh pr merge 42 --merge` for an epic child with `step9_status` `passed` and no `ci_gate`.

## Acceptance Criteria Inventory

| ID | Criterion (abridged) |
|---|---|
| AC1 | Regression test in the Claude ChildCi suite: allowed before the fix, denied after. |
| AC2 | Helper twins exist, byte-identical (tested), dot-source nothing, call gh only in the two seams, expose `Get-EpicMergeGateChildCiDecision` with `Verified` and `Reason`. |
| AC3 | Both gates dot-source the helper with the guarded pattern; the child branch allows only on `Verified`; any failure denies with `EPIC_CHILD_CI_NOT_VERIFIED` without fall-through. |
| AC4 | Stages enforced in order, each with a deny test in both suites. |
| AC5 | Allow green `pull_request` and recorded `workflow_dispatch`; deny unrecorded dispatch, failed or in-progress newest, other SHA, gh failure; in both suites. |
| AC6 | Existing suites updated by named mocks with stated reasons; generic deny text, review-guard ordering, and zero-call assertion unchanged. |
| AC7 | `enforce-epic-merge-gate-review.ps1` unchanged; stage C and stage J suites pass. |
| AC8 | No added or changed hook invokes Python. |
| AC9 | S9 dispatch rule in `orchestrate`; `epic-orchestrate` requirement and fallback; `epic-run` pointer. |
| AC10 | `.agents` mirrors and bundle copies match; `.claude/agents/epic-orchestrator.md` unchanged. |
| AC11 | Frozen pin refreshed with `RE-BASELINED by issue #1130`; `test_ci_gate_epic_child_contracts.py` passes unchanged. |
| AC12 | Orchestrator-state section and `## Enforcement` bullet; six brief copies updated and byte-identical. |
| AC13 | `ci-workflows` rule, Codex skill, and bundles require `epic/**`, state the name denial, and state that destinations need a push-down refresh. |
| AC14 | Both `core.json` manifests list the helper; manifest, closure, and parity tests pass. |
| AC15 | Helper line coverage >= 85%; full toolchain passes with no regression against Phase 0. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC1 | PASS | Carried forward from `feature-audit.2026-11-08T15-30.md`: `CHILD-CI-NO-CI-GATE` failed before the fix with an observed allow and passes in the post-merge Pester gate. Test file unchanged since `03d222c55`. |
| AC2 | PASS | Carried forward: four helper copies share one SHA-256; no dot-source; gh only in the two seams; entry returns `Verified` and `Reason`. Helper files unchanged since `03d222c55`. |
| AC3 | PASS | Carried forward: guarded dot-source in both gates; child branch returns the helper deny directly. Gates unchanged since `03d222c55`. |
| AC4 | PASS | Carried forward: stage order matches the spec; deny rows for stages 1 to 6 in both suites. |
| AC5 | PASS | Carried forward: allow and deny rows in both suites; real-process probe against PR #1124 returned `Verified=True`. |
| AC6 | PASS | Carried forward: each added mock names #1130; no assertion removed; review guard ordering unchanged. |
| AC7 | PASS | Carried forward: both review helpers unchanged; review suites pass; no `review/verdict` suite exists, so the stage J clause has nothing to fail. |
| AC8 | PASS | Carried forward: no Python invocation in the helper or either gate. |
| AC9 | PASS | Carried forward: S9 dispatch fallback, `epic-orchestrate` paragraph and fan-in step, `epic-run` pointer. |
| AC10 | PASS | Carried forward: mirror and bundle copies hash-equal; `.claude/agents/epic-orchestrator.md` unchanged. |
| AC11 | PASS | Carried forward: pin digest equals the skill SHA-256; the contracts test passed again in the reviewer's cycle-1 run (74 passed). |
| AC12 | PASS | Carried forward: orchestrator-state section and enforcement bullet; six brief copies share one SHA-256. |
| AC13 | PASS | Re-evaluated at `10c5da189`. The text in all four files is unchanged and correct. `.agents/skills/ci-workflows/SKILL.md` is now listed at line 13 of the Codex `core.json`, its bundle copy exists and is byte-identical (`cmp`), and it is removed from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`. Push-down now delivers the Codex skill, so its statement that destinations need a push-down refresh is accurate. Reviewer `pytest -n auto` over the manifest-completeness, dependency-closure, Codex core closure, customizations, resource-contracts, variant-packs, and contracts modules: 74 passed, 0 failed. |
| AC14 | PASS | Carried forward, and re-confirmed by the reviewer's cycle-1 manifest test run (74 passed); the executor's full run records 16537 passed, 0 failed. |
| AC15 | PASS | Carried forward: Claude helper 100.00%, Codex helper 97.59% lines; PowerShell repo-wide 95.56% to 95.58%. Cycle 1 changed no PowerShell or Python production file; the cycle-1 pytest run records 17653 statements and 915 missed, equal to Phase 0. |

## Summary

All fifteen criteria pass at `10c5da189`. F1, the only blocking finding of the prior review, is resolved by cycle 1, which brings AC13 from PARTIAL to PASS. CR2 to CR5 remain non-blocking as recorded in the code review. CI on the PR head is pending-CI: no PR exists yet, and the S9 gate owns that result.

Verdict: PASS, no blocking finding.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

- All fifteen criteria are already `- [x]` in `spec.md` at `10c5da189` (reviewer count over the `## Acceptance Criteria` section: 15 checked, 0 unchecked). The prior review's uncheck of AC13 was never committed; AC13 now evaluates as PASS, so the committed checked state is correct and no change to `spec.md` was made in this re-audit.
- No criterion was added and no criterion text was changed.
