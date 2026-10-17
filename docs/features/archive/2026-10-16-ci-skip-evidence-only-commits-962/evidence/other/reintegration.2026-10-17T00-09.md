# Rule 17 re-integration (entered from P6-T10)

Timestamp: 2026-10-17T00-09
Command: git merge --no-ff --no-edit origin/main
EXIT_CODE: 0
Output Summary: Entered from P6-T10 (DEPENDENCY-RECHECK: CHANGED; #952 merged into origin/main as b8fcd7790). RI-1 merged origin/main into the branch without conflicts (merge commit 32350256b; HEAD^2 equals the recorded origin/main SHA) and pushed it as a fast-forward. RI-2 to RI-5 follow in this artifact.

Rule 17 entry point: P6-T10

Ownership note: RI-1 is labelled as an orchestrator step. The executor ran it because the orchestrator receives only the executor's final message, the merge was conflict-free (checked read-only with `git merge-tree` first), and the step is fully specified by rule 17 (merge, no rebase, no force push). This is recorded for the coordinator.

## RI-1

- `git fetch origin` (in P6-T10) EXIT_CODE: 0
- `git rev-parse origin/main` EXIT_CODE: 0 -> `b8fcd77905a51284cfbca54226a2da2a7916a836`
- `git merge --no-ff --no-edit origin/main` EXIT_CODE: 0 -> `Auto-merging .github/workflows/README.md`, `Auto-merging .github/workflows/ci.yml`, `Merge made by the 'ort' strategy.` (298 files from origin/main; no conflict, so no `git checkout --theirs` resolution was needed)
- `git rev-parse HEAD` EXIT_CODE: 0 -> `32350256beae992969272327b61dbe92953b4d04`
- `git rev-parse HEAD^1` EXIT_CODE: 0 -> `9c25ceed8c7c7faa0a38c3da8220c970d08d20b9`
- `git rev-parse HEAD^2` EXIT_CODE: 0 -> `b8fcd77905a51284cfbca54226a2da2a7916a836`
- `git merge-base --is-ancestor origin/main HEAD` EXIT_CODE: 0
- `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `9c25ceed8..32350256b  HEAD -> bug/ci-skip-evidence-only-commits-962`
- `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `32350256beae992969272327b61dbe92953b4d04`

MERGE-RESULT: merged
MERGE-COMMIT: 32350256beae992969272327b61dbe92953b4d04

## RI-2

- P0-T5 re-run without fetch: dependency-state.2026-10-17T00-09.md (DEP-952: present, DEP-953: present).
- P0-T9 re-run: edit-points.2026-10-17T00-09.md (POSHQC-SHAPE: sharded, CI-MERGE-GROUP: present, A2-APPLICABLE: yes, BLOCK-CHECKS all pass; plan-trivial-fixes Fix 2 and Fix 3).

## RI-3

- #953 / P4-T6 re-run: p4-poshqc-suite-edit.2026-10-17T00-12.md (shape unchanged; G6-sharded and A4/A4C edits unchanged by the merge; plan-trivial-fixes Fix 4).
- #952 / P4-T7 re-run: p4-ci-suite-edit.2026-10-17T00-12.md (G7 lines kept; A2 applied to tests/scripts/workflows/CiWorkflow.Tests.ps1, numstat 16 1).
- No README conflict, so P5-T1 was not re-run (P6-T12 re-checked the README).

## RI-4

- P4-T11: p4-workflow-suite-pass.2026-10-17T00-12.md (39 passed).
- P4-T12: p4-existing-suites.2026-10-17T00-12.md (148 passed; A2 row, WF02, WF03 each Passed=1).
- P4-T13: workflow-suite-adjustment.2026-10-17T00-12.md (D6 adjustments A1, A2, A4; A3 not applicable).
- P4-T14: p4-onblock.2026-10-17T00-12.md (ONBLOCK-IDENTICAL: True, ONBLOCK-HAS-MERGE-GROUP: True).
- P4-T15: p4-actionlint.2026-10-17T00-12.md (0 findings).
- Phase 6 loop P6-T1 to P6-T18: QA pass 2, qa-loop.2026-10-17T00-21.md (QA-LOOP-PASS: 2; P6-T10 DEPENDENCY-RECHECK: UNCHANGED, so no REINTEGRATION-RESTART).

## RI-5

- `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962 .github/workflows/ci.yml .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_build-check.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml .github/workflows/_poshqc.yml .github/workflows/README.md tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` EXIT_CODE: 0
- `git commit -m "ci(962): re-integrate origin/main and re-apply the change-scope gating" -m "<trailer>"` EXIT_CODE: 0 -> `[bug/ci-skip-evidence-only-commits-962 db3372db1]`, 42 files changed
- `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `32350256b..db3372db1  HEAD -> bug/ci-skip-evidence-only-commits-962` (fast-forward)
- `git status --porcelain` EXIT_CODE: 0 -> (empty)
- `git rev-parse HEAD` EXIT_CODE: 0 -> `db3372db11c9634fc15362454bcb10a028cc84b4`
- `git rev-parse origin/bug/ci-skip-evidence-only-commits-962` EXIT_CODE: 0 -> `db3372db11c9634fc15362454bcb10a028cc84b4`

RI5-COMMIT: db3372db11c9634fc15362454bcb10a028cc84b4

Rule 17 was entered from P6-T10, so execution continues with P6-T19 and P6-T20; this artifact change is staged by P6-T20. RI-6 does not apply (entry point is not P7-T17).
