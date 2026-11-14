# Feature Audit: Epic-Child PR Merges Without CI (Issue #1130)

- **Branch:** `bug/epic-child-pr-ci-required` @ `03d222c55e3724bbd1d92db549e0017d02c306be`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. The caller supplied it, and `artifacts/pr_context.summary.txt` confirms it: that file resolves `origin/main` @ `cdcff3871765396183590128e142a929cf78327b` for head `03d222c55`.
- Merge base: `cdcff3871765396183590128e142a929cf78327b`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `cdcff3871765..03d222c55`, 66 files.
- Work mode: `full-bug` (`- Work Mode: full-bug` in `issue.md`), so the AC source is `spec.md` `## Acceptance Criteria`.
- Inputs read: `spec.md`, `issue.md`, the promoted record `docs/features/potential/promoted/2026-11-08-epic-child-pr-merges-without-ci.md`, `plan.2026-11-08T08-08.md`, `research/research.2026-11-08T13-40.md`, and every evidence artifact.
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
| AC1 | PASS | `CHILD-CI-NO-CI-GATE` failed before the fix with an observed allow (EXIT_CODE 1 expected 1) and passes in the post-merge Pester gate. |
| AC2 | PASS | Four copies share SHA-256 `372e696c...5013915`; the `helper twins` row asserts byte identity; no dot-source or import; `Invoke-DocsOnlyGhExe` appears only in `Get-EpicMergeGateChildCiLiveHeadSha` and `Get-EpicMergeGateChildCiRunList`; the entry returns `[ordered]@{ Verified; Reason }`. |
| AC3 | PASS | Guarded `try { . ... } catch { Add-HookDependencyFailure ... }` line in both gates; C11 denies on a Claude load failure. Code reading: both gates return the helper's deny directly. Claude rows assert no epic or parallel checkpoint read; Codex rows deny with an allowing epic checkpoint present. |
| AC4 | PASS | Stage order in `Get-EpicMergeGateChildCiFailureDetail` matches the spec. Deny rows for stages 1 to 6 in both suites; the Claude stage 1 mismatch is a direct row because the existing binding predicate rejects it before the helper. |
| AC5 | PASS | Allow rows `*-ALLOW-PULL-REQUEST-RUN` and `*-ALLOW-RECORDED-DISPATCH-RUN`; deny rows for unrecorded dispatch, newest failed, newest in progress, run on another SHA, and gh failure in both suites. A real-process probe against PR #1124 returned `Verified=True` for a green `pull_request` run. |
| AC6 | PASS | Each added mock carries a one-line reason naming #1130; the diff removes no assertion; the zero-call assertions on `Get-EpicMergeGateLivePrHeadSha` and the generic final deny text are unchanged; the review guard still precedes branch 1. |
| AC7 | PASS | `git diff --quiet` over both review helpers: no change. ReviewGuard, ReviewPaths, and the Codex review suite pass. No `review/verdict` suite exists at head or on `origin/main` (`git grep` finds none), so the stage J clause has nothing to fail; recorded as such. |
| AC8 | PASS | No Python invocation in the helper or either gate; `enforcement-hooks-no-python-invocation.Tests.ps1` passed in the gate. |
| AC9 | PASS | `.claude/skills/orchestrate/SKILL.md` S9 dispatch fallback and step 5 and 6 text; `epic-orchestrate` paragraph under `## Merge-on-Green Kickoff Parameter` and fan-in step 6; `epic-run` pointer. The polling assumption on `gh pr checks` is recorded as CR3 and is outside the criterion text. |
| AC10 | PASS | `.agents` and bundle copies hash-equal per pair; `.claude/agents/epic-orchestrator.md` unchanged. |
| AC11 | PASS | Pin digest equals the reviewer's SHA-256 of the skill (`934a7bca...abcb856`); comment present; the contracts test is not in the diff and passed. |
| AC12 | PASS | Section `## Epic-child CI verification (issue #1130)` and the updated `## Enforcement` bullet; six brief copies share SHA-256 `3d003f50...3986208`. |
| AC13 | PARTIAL | The text is present in all four files and their content is correct about the gate. The Codex skill `.agents/skills/ci-workflows/SKILL.md` and its bundle copy are in no Codex pack manifest, so push-down never delivers them, and their statement that destinations receive the rule through push-down is inaccurate for Codex destinations (F1). |
| AC14 | PASS | One entry in each `core.json`; manifest-completeness, dependency-closure, and bundle-parity tests passed in the pytest gate. |
| AC15 | PASS | Claude helper 100.00%, Codex helper 97.59% lines; Pester 19762 tests and pytest 16537 passed, 0 failures; PowerShell repo-wide 95.56% to 95.58%; static loop clean. |

## Summary

The merge gates now verify a green `CI` run on the live head of an epic child before allowing its merge, in both runtimes, and every verification stage fails closed without falling through. Fourteen criteria pass. AC13 is PARTIAL because the Codex `ci-workflows` skill that carries the `epic/**` trigger requirement is not in any Codex pack manifest (F1). CI on the PR head is pending-CI: no PR exists yet.

Verdict: REMEDIATION_REQUIRED, one blocking finding, `autonomous`, contained.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/spec.md`
- Total AC items: 15
- Checked off (delivered): 14
- Remaining (unchecked): 1
- Items remaining: AC13 (`.claude/rules/ci-workflows.md`, `.agents/skills/ci-workflows/SKILL.md`, and their bundle copies require `epic/**` ... and state that destinations need a push-down refresh).

## Acceptance Criteria Check-off

- AC1 to AC12, AC14, and AC15 were checked off by the executor. This review evaluates each as PASS, so they stay checked.
- AC13 was checked off by the executor. This review evaluates it as PARTIAL, so it was changed from `- [x]` to `- [ ]` in `spec.md`. Only the checkbox changed. The change is uncommitted in the item worktree for the orchestrator to commit with the review artifacts.
- No criterion was added and no criterion text was changed.
