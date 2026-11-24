# `targeted-test-cadence` — User Story

- Issue: #1228
- Owner: drmoisan
- Branch: `feature/targeted-test-cadence-1228`
- Status: Draft
- Last Updated: 2026-11-23
- Spec: `.dev/active/1228-targeted-test-cadence/spec.md`

## Story Statement

- As the repository owner, I want every orchestrator on every surface to run the full test suite of a destination repository only at the `Phase 0 baseline` and in the final QA loop, and to run a test selection everywhere else, so that orchestrations on large destination repositories finish sooner while the full suite still brackets the work at its start and its end.
- As the repository owner, I want the change recorded as a revertible process reduction and enforced by contract tests, so that a later edit cannot reintroduce a full-suite requirement unnoticed and the prior cadence can be restored from the ledger.

## Owner Objective (verbatim)

"The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."

## Problem / Why

The orchestration rules run the full unit suite at every `[phase-gate]` task, and some skills also require it for remediation cycles, the regenerate path of a merge conflict, and post-merge sync checks. On large destination repositories this repeats a multi-minute full run many times per orchestration.

## Personas & Scenarios

- Persona: repository owner
  - Maintains the harness that is pushed down to destination repositories and runs orchestrations against them.
  - Cares about orchestration duration and token use on large repositories, and about keeping a full-suite check before merge.
  - Constraint: test runs are parallel only; no new Python; CI is not to change.
  - Goal: one full run at the start and one at the end of each orchestration, with selected tests in between.
- Scenario: multi-phase orchestration on a large destination repository
  - The orchestrator runs the `Phase 0 baseline`: one full parallel run of each language gate with coverage.
  - The executor completes the tasks of Phase 1, running each task's test selection.
  - At the Phase 1 `[phase-gate]` task, the executor runs format, lint, type check, architecture-boundary tests, and contract checks across the repository, and runs the union of Phase 1's task test selections in parallel through the launcher. It records the union in `phase-gate.P1.<timestamp>.md`.
  - A merge of `origin/main` conflicts and is regenerated; the fallback gate runs the selection of the paths the merge changed.
  - Review finds a defect; the remediation cycle ends with one remediation gate over the cycle's selection, with coverage measured for the changed files.
  - The final QA loop runs the full suite with coverage and compares it with the `Phase 0 baseline`. CI then runs unchanged.
  - Outcome: the full suite ran twice locally instead of once per phase, cycle, and sync.

## Acceptance Criteria

- [x] `## Test Cadence (Mandatory)` in both the Claude and Codex `atomic-plan-contract` copies states that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and defines the phase gate's unit stage as the union of the phase's task test selections, the remediation gate, and the sync-check local gate; the new required-token rows of `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` pass (spec AC-01, AC-02).
- [x] No rule, skill, agent, prompt, instruction, plan template, or bundle copy requires a full-suite run outside the `Phase 0 baseline` and the final QA loop: the extended sweep in `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` passes with no match, and a repository-wide search recorded with `SearchScope`, `SearchPatterns`, and `SearchResult` classifies every remaining hit (spec AC-03, AC-04).
- [x] The remediation plan shape, the regenerate-path fallback gate, the typed-engineer workflow, the feature-review coverage step, the QA-gate skills, and the execution-environment and test-execution-policy sections state the selection-based runs, each verified by its named contract-test rows passing (spec AC-05 to AC-10).
- [x] Generated outputs are regenerated from sources: `Invoke-HarnessGeneration.ps1 -Check` and the Codex variant generator `--check` report no drift, with the output recorded in evidence (spec AC-11, AC-12).
- [x] Bundle copies are in parity, `AGENTS.md` is byte-identical to its bundle copy, and the push-down contract tests and `TCW-BUNDLE-*` rows pass (spec AC-13).
- [x] The pinned tests `test-cadence-wording.Tests.ps1` and `regeneration-path-skill-contract.Tests.ps1` are updated in the same change as the wording they pin, and they pass together with the unchanged vocabulary sweeps of `parallel-gate-wording.Tests.ps1` (spec AC-06, AC-14, AC-15).
- [x] Ledger entry `0014-targeted-test-cadence.md` records the prior text as a stored patch and the revert steps, carries a README index row, and the ledger chain and index tests pass (spec AC-16).
- [x] The `Phase 0 baseline` and the final QA loop remain full runs with coverage comparison, shown by the canonical rows and by this item's own baseline and final QA artifacts (spec AC-17).
- [x] CI is unchanged and the out-of-scope paths (Python atomic executor CLI, frozen epic surfaces, standalone Copilot agents, epic #1217 docs estate) are untouched, shown by a recorded branch diff and the frozen-surface digest test passing (spec AC-18, AC-19).

## Non-Goals

- Changing CI workflows or the CI full run.
- Changing the Python atomic executor CLI.
- Editing the epic surfaces frozen by `PINNED_FROZEN_SURFACE_HASHES`.
- Changing the standalone Copilot agents and prompts that bracket their own runs.
- Adding or changing hooks, validators, or configuration, except the spec D11 exception: the launcher run-scope record `artifacts/test-execution/run-scope.<suite>.json` and the coverage-hook selection rule in the Claude and Codex feature-review coverage hooks and their freshness twins.
