# `epic-child-ci-opt-out` — User Story

- Issue: #1233
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-24T04-02
- Spec: `.dev/active/1233-epic-child-ci-opt-out/spec.md`

## Story Statement

- As the repository owner running an epic, I want to opt the epic out of per-child CI with `child_ci: integration_only`, so that each child merges into the integration branch on verified local final-QC evidence and a current concurrent review, and a full green `CI` run is required only on the integration-to-`main` pull request.

## Problem / Why

Every epic child must pass CI on its own pull request before it merges into the epic integration branch. The merge gate helper `enforce-epic-merge-gate-child-ci.ps1` (issue #1130), byte-identical in `.claude/hooks/` and `.codex/hooks/`, enforces this, and the S9 dispatch fallback starts a `CI` run for a child head that has none. An epic with N children pays for N full CI runs plus the integration run, and each child waits for its own run before it merges. The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main". The owner chose to change the gate rather than bypass it.

In this repository `ci.yml` already triggers on pull requests into `epic/**`, so a child pull request still starts a `CI` run automatically (spec decision D1). The opt-out removes that run as a merge condition and removes the S9 wait and dispatch; it does not stop the automatic run.

## Personas & Scenarios

- Persona: repository owner running an epic
  - Owns the repository and directs autonomous epic runs through `epic-plan`, `epic-run`, and `epic-orchestrate`.
  - Cares about CI compute and wall-clock time per epic, and about keeping every gate enforced rather than bypassed.
  - Constraint: the integration-to-`main` merge must still be backed by a full green `CI` run.
  - Frustration: N per-child CI runs and N waits for changes that are verified again at the integration PR.
  - Motivation: a recorded, revertible gate reduction that applies only when chosen.

- Scenario 1: planning an opted-out epic
  - The owner tells the planner to opt the epic out of per-child CI.
  - The planner writes `child_ci: integration_only` in the epic manifest frontmatter and writes child acceptance criteria that do not depend on CI, or marks such criteria pending integration CI.
  - At kickoff the epic orchestrator validates the key, copies it to the epic checkpoint, and adds the line `Child CI: integration_only.` to each child's delegation prompt.
  - Outcome: each child orchestrator records `child_ci: "integration_only"` in its first checkpoint write.

- Scenario 2: an opted-out child reaches S9 and merges
  - The child runs with `review_mode: "concurrent"`, passes review at its head, and completes the final QC loop locally.
  - At S9 the child orchestrator confirms the live PR base equals `epic_context.integration_branch`, writes and commits `<feature-folder>/evidence/qa-gates/local-qc-gate.<timestamp>.md` naming the reviewed head with `EXIT_CODE: 0`, records `local_qc_gate` and `step9_status: "passed"`, and issues no `CI` dispatch.
  - The merge gate verifies the base, the concurrent review, the `local_qc_gate` record, and the evidence file at the live head, and allows the merge.
  - The completion-consistency hook accepts the DONE checkpoint because `local_qc_gate` is present; `ci_gate` is absent.
  - Outcome: the child merges into the integration branch without waiting for `CI`.

- Scenario 3: an opted-out child fails a local-QC condition
  - The evidence file is missing at the live head, its first `EXIT_CODE:` is not `0`, its `Head:` line does not match, or the run is not concurrent.
  - The merge gate denies with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` and names the failing stage.
  - Outcome: the orchestrator corrects the evidence or record and retries; the merge is never allowed on missing evidence.

- Scenario 4: a pull request outside the integration branch
  - A child checkpoint carries the opt-out, but the live PR base is `main` or another branch, or the recorded integration branch is malformed.
  - The gate does not apply the opt-out and requires green per-child CI as today.
  - Outcome: the opt-out can never admit a merge into `main`.

- Scenario 5: the integration PR into `main`
  - After all children merge, the epic orchestrator opens the integration PR into `main`.
  - S9 for the integration PR requires a full green `CI` run, as today; CI-dependent child criteria are checked off in the integration worktree after that run is green.
  - Outcome: `main` receives the epic only after full CI.

- Scenario 6: an epic without the opt-out
  - The manifest has no `child_ci` key, or `child_ci: per_child`.
  - Every hook, validator, and skill behaves exactly as today, including the S9 dispatch fallback and the existing deny texts.
  - Outcome: existing epics are unaffected.

## Acceptance Criteria

- [ ] Given an epic manifest with `child_ci: integration_only`, when the epic is kicked off, then the epic checkpoint carries `child_ci`, each child delegation prompt carries the separate line `Child CI: integration_only.`, and the pinned kickoff literal is unchanged; a manifest value other than `per_child` or `integration_only` is rejected before kickoff. Verified by `child-ci-opt-out-skill-contract.Tests.ps1` and `early-start-skill-contract.Tests.ps1`.
- [ ] Given an opted-out child with a current concurrent `PASS` review, a valid `local_qc_gate`, the evidence file at the live head, and a live base equal to its integration branch, when the child merge is requested, then the merge gate allows it on Claude and Codex without a `CI` run on the child head. Verified by the allow rows of both new merge-gate opt-out suites.
- [ ] Given an opted-out child whose evidence, record, review mode, or PR lookup fails a check, when the child merge is requested, then the gate denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED:` naming the failing stage. Verified by the deny rows of both new merge-gate opt-out suites.
- [ ] Given an opted-out child checkpoint whose live PR base is `main`, another branch, or a malformed recorded integration branch, when the merge is requested, then the gate applies per-child CI verification as today. Verified by the main-base and base-mismatch rows of both new merge-gate opt-out suites.
- [ ] Given an opted-out child at S9, when the orchestrate procedure runs, then no `CI` dispatch is issued for the child head, the local-QC evidence file is written and committed, and `local_qc_gate` and `step9_status: "passed"` are recorded. Verified by `child-ci-opt-out-skill-contract.Tests.ps1`.
- [ ] Given an opted-out child DONE checkpoint, when it is written, then the completion-consistency hooks accept it only with a valid `local_qc_gate`, and the deny text for checkpoints without the key is unchanged. Verified by the extended completion-consistency and completion-helper suites.
- [ ] Given a completed opted-out child checkpoint without `ci_gate`, when it is validated by the Python, TypeScript, and PowerShell validators, then each validator accepts it, each reports the same byte-identical error strings for each failing local-QC condition, and each reports the existing `ci_gate` errors when the opt-out is removed. Verified by the shared corpus `tests/fixtures/orchestrator_state_child_ci/` in the Python, TypeScript, and PowerShell suites.
- [ ] Given the integration PR into `main`, when it reaches S9 and the merge gate, then a full green `CI` run is still required and the integration-to-`main` branch of the merge gate is unchanged. Verified by the unchanged existing merge-gate suites and the skill-text contract test.
- [ ] Given an epic without `child_ci` or with `child_ci: per_child`, when any child runs, then hooks, validators, and skills behave as today. Verified by the default rows of the new suites and the unchanged existing suites.
- [ ] Given the opt-out is adopted, when the owner reviews the reduction, then a process-reduction ledger entry records the prior text, the revert steps, the residual automatic `CI` run on child PRs, and the self-declared-key disclosure. Verified by `ProcessReductionChain.Ledger.Tests.ps1`.

## Non-Goals

- No change to any workflow file, including `.github/workflows/ci.yml`.
- No change to the integration-to-`main` PR gate (merge-gate branch 2).
- No change to `per_child` behavior.
- No change to the review guard `enforce-epic-merge-gate-review.ps1` or to integration-tip regeneration CI.
