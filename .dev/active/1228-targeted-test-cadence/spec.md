# targeted-test-cadence — Spec

- **Issue:** #1228
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `feature/targeted-test-cadence-1228`
- **Last Updated:** 2026-11-23
- **Status:** Draft
- **Version:** 0.2
- **Research:** `.dev/active/1228-targeted-test-cadence/research/research.2026-11-23T12-00.md`

## Owner Objective (verbatim)

"The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."

## Overview

The orchestration rules currently run the full unit suite at every `[phase-gate]` task. Some skills also require a full run for remediation cycles, for the regenerate path of a merge conflict, and for post-merge sync checks; the typed engineers run a full QA gate that the plan's final QC block repeats; and the feature-review coverage step can force a full coverage run at each review. On large destination repositories this repeats a multi-minute full run many times per orchestration.

This feature changes the policy text on every surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop. Every other test run within an orchestration uses a test selection. The change is wording-only on rules, skills, agents, prompts, instructions, plan templates, and their generated and bundle copies, plus the contract tests that pin that wording and a process-reduction ledger entry. No hook, validator, CI workflow, or Python tool changes.

## Behavior

### Test runs by orchestration point

| Point | Unit-test scope | Coverage | Other stages |
|---|---|---|---|
| `Phase 0 baseline` | Full suite, one parallel run per language gate | Measured | Unchanged |
| Task check (after each task) | The task's test selection (unchanged) | Not measured | Format, lint, type check scoped to changed files (unchanged) |
| `[phase-gate]` task | Union of the test selections of the phase's tasks | Not measured | Format, lint, type check, architecture-boundary tests, and contract checks across the repository |
| `[expect-fail]` phase gate | Union of the phase's task selections; passes when its only failures are the plan's named expected failures, each confirmed failing, and every other selected test passes | Not measured | As phase gate |
| Remediation cycle | Task checks per task; one remediation gate in phase-gate form over the union of the cycle's task selections | Measured for each changed language, recorded per changed file | As phase gate |
| Sync check (main sync, integration sync, early-start sync, regenerate path) | Test selection of the paths the merge changed on either side since the merge base | Not measured | As phase gate |
| Feature review coverage re-run | Branch test selection (initial review: union of all plan task selections; R4: the cycle's selection) | Measured over the selection | Not applicable |
| Final QA loop | Full suite, one parallel run per language gate | Measured and compared with the `Phase 0 baseline` | Unchanged |
| CI | Unchanged | Unchanged | Unchanged |

### Test selection

The selection rule is the existing task-check rule of `## Test Cadence (Mandatory)`: the mirrored test files of each changed production file, every test file that imports, dot-sources, or names a changed module or file, and the contract tests that read a changed Markdown or configuration path. A union is the set union of those files over the tasks of a phase or cycle, or over the paths a merge changed.

### Unit stage at a phase gate

- One parallel launcher run per language whose union is non-empty: the launcher `pester` suite with `-TestPath <union>` (one `Invoke-PoshQCParallelTest` run), the launcher `pytest` suite with the union files (one `pytest -n auto` run), and the launcher Jest suite with the union test paths (Jest through its normal parallel workers).
- A language whose union is empty records "no selected tests" for its unit stage.
- Restart from step 1 on any failure or file rewrite, and one clean pass of every stage, are unchanged.
- Evidence path is unchanged: `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. The artifact also records the union and the selection rule that produced it.

### Failure conditions

- Any rule, skill, agent, prompt, instruction, or plan template on any surface or bundle that requires a full-suite run outside the `Phase 0 baseline` and the final QA loop is a defect. The extended sweep in `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` fails on such text.
- Any use of the swept tokens "targeted tests", "targeted Pester", "targeted Pytest", "targeted xUnit", or "targeted MSTest" on a swept surface fails the existing `runClassForbidden` and `PGW-SWEEP-*` checks.

## Design Decisions

Each decision adopts the recommended option of the research record.

| ID | Decision | Rationale |
|---|---|---|
| D1 | The phase-gate unit stage is the union of the phase's task test selections, run in parallel through the launcher, with no coverage measurement. | States the owner rule directly and reuses the existing selection rule and the launcher `-TestPath` route. Repository-wide static, architecture, and contract stages stay at every phase gate. |
| D2 | A remediation cycle ends with one remediation gate in phase-gate form, run in coverage mode for each changed language so per-file coverage of the files the cycle changed is recorded. The remediation plan's Phase 0 captures static baselines only and cites the orchestration's `Phase 0 baseline` artifact; it does not re-run the full suite. Light cycles are unchanged (task checks only). | The owner objective lists remediation cycles as non-full runs. Changed-file coverage is still measured; the repository-wide backstop is the final-QC artifact and CI. A full QA loop per cycle was rejected. |
| D3 | When the review coverage report is absent or stale for a changed language, the reviewer re-runs coverage over the branch's test selection, not the full suite. The repository-wide total comes from the final-QC artifact and the CI result recorded in `## CI Cross-check`. No hook code changes. | A selection run refreshes the report files that `.claude/hooks/validate-feature-review-coverage-freshness.ps1` reads (`artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `coverage/lcov.info`), so the freshness hook is satisfied without a full run and no PowerShell production file is edited. |
| D4 | `## Workflow` item 5 of the three typed-engineer agent sources (Python, PowerShell, C#) states that, when the delegation comes from an orchestration whose plan carries a `Phase 0 baseline` and a final QC block, the engineer runs the task check and leaves the full gate to the plan's final QA loop. Standalone direct use keeps its own Phase 0 and final QA gate. | Removes the duplicate full run in the small path. Standalone use already brackets its own run with a beginning and a QC run. |
| D5 | The epic surfaces frozen by `PINNED_FROZEN_SURFACE_HASHES` (`.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`) are not edited, and the `.agents` epic-orchestrate copy is left unchanged with them. "Local gate" for sync checks is defined in `## Test Cadence (Mandatory)` and in the execution-environment brief as the phase-gate form over the merge's changed-path selection. | A definition at the canonical location makes the existing "re-run the local gate" step non-full without a hash re-baseline of the frozen surfaces. |
| D6 | The Python atomic executor CLI (`scripts/dev_tools/atomic_executor/`) is unchanged. The ledger entry records it as unchanged. | It is a repository-local developer tool that is not pushed down; editing it would add Python changes outside the owner's scope. The brief's `## Test Runtime` description of it ("its phase-gate QC loop", pinned) stays accurate. |
| D7 | Vocabulary is "test selection" and "selected tests". The tokens "targeted tests", "targeted Pester", "targeted Pytest", "targeted xUnit", and "targeted MSTest" are never used on a swept surface. | Those tokens are banned by the `test-cadence-wording` and `parallel-gate-wording` contract sweeps. |
| D8 | The ledger record is a new entry `.dev/engineering/process-reductions/0014-targeted-test-cadence.md` with a `## Stored Patch` section naming `patches/0014-targeted-test-cadence.patch` (precedent `0009`). | The restated cadence sentence occurs more than once in several files, so a `Current` fence would need contextual disambiguation; a stored patch avoids that class of revert-chain failure. |
| D9 | Item 5 of `## Merge-Conflict Remediation` in `.claude/skills/orchestrate/SKILL.md` replaces "the standard parallel unit gates" with the phase-gate unit stage over the test selection of the paths the merge changed. `config/orchestration-regeneration.json` `unit_gate` stays repository-owned and unchanged. | Brings the regenerate-path fallback gate under the owner rule without a configuration change. |
| D10 | The standalone Copilot agents and prompts (`staged-review`, `commentary-remediation`, `remediate-comments` prompt, the Copilot typed engineers, `pytest-unit-test-coding`, `Powershell DI Unit Test Engineer`, `python-execution-only-typed`) are unchanged. | They are not orchestrator steps; each brackets its own standalone run, and several rows are pinned by `parallel-gate-wording.Tests.ps1` to `poetry run pytest -n auto`. |

## Inputs / Outputs

- Inputs: the canonical `## Test Cadence (Mandatory)` sections; the harness sources under `scripts/harness-generation/sources/`; the hand-authored files listed in section 4.1 of the research record.
- Outputs: edited sources and hand-authored files; regenerated targets and Codex variants with their bundle copies; hand-copied bundle copies; updated contract tests; ledger entry `0014` with its stored patch and README index row; evidence files under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`.
- Config keys and defaults: none added or changed.
- Versioning or backward-compatibility constraints: destination repositories receive the new wording on their next push-down. The `Phase 0 baseline` and final QA loop artifacts keep their existing paths and formats.

## API / CLI Surface

No command, flag, or schema changes. The commands used to produce and verify the change:

- `scripts/harness-generation/Invoke-HarnessGeneration.ps1` (write), then with `-Check`, then `-Surface instructions -Check`. In an agent worktree these run from a `sh <SCRATCH>/<file>.sh` launcher, as the execution-environment brief requires.
- `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, then with `--check`.
- The launcher `pester` suite with `-TestPath` for the edited contract tests.

## Data & State

- No runtime data, checkpoint field, or persisted state changes.
- Invariant: every surface restates the cadence as a pointer to `## Test Cadence (Mandatory)`; the canonical section is the single definition.
- Invariant: the `AGENTS.md` `## Mandatory Toolchain Loop` section does not become whitespace-equal to the same section of `.claude/rules/general-code-change.md` (`EMBEDDED-RULE` check in `HarnessInstructions.psm1`).

## Constraints

- No new Python. Test and tooling changes are PowerShell or bash; TypeScript only for MCP or extension surfaces. No TypeScript change is expected.
- Test runs are parallel only. No serial, single-process, shuffled, or reversed run is used or introduced in any wording.
- Do not edit `.claude/lib/docs/`, the `docs-*` skills, `documentation-workflow`, their `.agents` twins, or any bundle copy of those paths (epic #1217 owns them).
- Never hand-edit a generated output. Change a generated file through its source and the generator.
- Evidence is append-only. Every evidence timestamp comes from a clock reading. No evidence file is back-dated, rewritten, or deleted.
- Hand-authored files are copied to their bundle paths by hand in the same change; no generator produces those copies.

## Risks

- Cross-module regressions surface later, in the final QA loop or CI, instead of at a phase gate. Mitigation: repository-wide static, architecture, and contract stages stay at every phase gate; the final QA loop remains a full run compared with the `Phase 0 baseline`; CI gates the merge.
- A reviewer could cite the policy-audit template rows to demand a full phase gate. Mitigation: those rows already read coverage from the single final-QC gate run, and the rewritten restatements remove the basis for that demand.
- Epic #1217 may edit the docs-estate bullets of the execution-environment brief in parallel. Mitigation: merge `origin/main` before the final QA loop.
- The restated sentence occurs more than once in several files; a partial replacement leaves an old occurrence. Mitigation: the extended sweep fails on any remaining occurrence.

## Out of Scope

- CI workflows under `.github/workflows/`.
- The Python atomic executor CLI under `scripts/dev_tools/atomic_executor/` (D6).
- The frozen epic surfaces `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md`, their pinned digests in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, and the `.agents` epic-orchestrate copy (D5).
- The standalone Copilot agents and prompts listed in D10.
- Hooks and validators; none pins the phase-gate cadence (research section 1.3).
- The docs estate owned by epic #1217.

## Implementation Strategy

- Rewrite the `Phase gate` and `Expect-fail phase` bullets of `## Test Cadence (Mandatory)` in both `atomic-plan-contract` copies, and add bullets for the remediation gate, sync checks ("local gate"), and the statement that the full suite runs only at the `Phase 0 baseline` and in the final QA loop.
- Replace the restated cadence sentence on every surface with one new sentence that points to the canonical section and names the phase gate's unit stage as the union of the phase's task test selections.
- Update the independent full-run instructions listed in research section 4.1 items 7 to 23, except the frozen epic surfaces (D5) and standalone Copilot agents (D10).
- Regenerate generated targets and Codex variants; hand-copy bundles of hand-authored files.
- Extend `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` and update the `RSC-REGENERATE` literals in `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.
- Record ledger entry `0014` with its stored patch and README index row.
- New classes, functions, or commands: none. Dependency changes: none. Logging or telemetry: none. Rollout: delivered to destination repositories through push-down.

## Acceptance Criteria

- [x] AC-01: `## Test Cadence (Mandatory)` in `.claude/skills/atomic-plan-contract/SKILL.md` and in `.agents/skills/atomic-plan-contract/SKILL.md` states that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and defines the `[phase-gate]` unit stage as the union of the phase's task test selections, run in parallel through the launcher with no coverage measurement. Verified by new required-token rows for both copies in `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` that pass.
- [x] AC-02: The same section in both copies defines the remediation gate (D2) and the sync-check "local gate" as the phase-gate form over the test selection of the paths the merge changed (D5, D9), and the existing canonical tokens (`stages 1 to 6`, `restart from step 1`, `one clean pass`, ``one `Invoke-PoshQCParallelTest` run``, ``one `pytest -n auto` run``, `Jest through its normal parallel workers`, `phase-gate.P<N>.<timestamp>.md`, `-TestPath`, `Phase 0 baseline`) and the `TCW-CANONICAL-DISCRIMINATES` tokens remain present. Verified by the `CANONICAL-*` and `TCW-CANONICAL-DISCRIMINATES` rows passing.
- [x] AC-03: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` carries a second sweep token list containing at least the removed phrases "and the full toolchain loop at each phase gate", "the full unit suite", "runs the full toolchain loop instead", "still runs the full loop", "as the full loop at each phase gate", and "the standard parallel unit gates", with a count assertion equal to that list's length, swept over every rule, skill, agent, prompt, instruction, plan template, `AGENTS.md`, and bundle surface (excluding the D5 and D10 paths by name), plus a helper row that proves the sweep reports a planted phrase from in-memory text. The sweep rows pass with no match.
- [x] AC-04: A repository-wide search evidence file under `.dev/active/1228-targeted-test-cadence/evidence/other/` records `SearchScope` (the whole worktree excluding `node_modules/`, `.venv/`, `.git/`, `.claude/worktrees/`, and `.dev/`), `SearchPatterns` (the AC-03 phrases plus `full suite`, `full test suite`, `full toolchain`, `full loop`, `full unit`, and `local gate`), and `SearchResult`. The result shows no text that requires a full-suite run outside the `Phase 0 baseline` and the final QA loop, and classifies every remaining hit with its reason (final QA loop, CI, D5, D6, D10, or developer documentation).
- [x] AC-05: `## Plan Shape` of `remediation-handoff-atomic-planner` (source and all generated and bundle copies) no longer requires a `Phase 0 baseline` test-suite run or a full final QA loop per cycle; it requires static baselines that cite the orchestration's `Phase 0 baseline` artifact and one remediation gate in phase-gate form with coverage measured for each changed language. Verified by a new required-token row in `test-cadence-wording.Tests.ps1` that passes and by the AC-03 sweep.
- [x] AC-06: Item 5 of `## Merge-Conflict Remediation` in `.claude/skills/orchestrate/SKILL.md` and its bundle copy states the regenerate-path fallback gate as the phase-gate unit stage over the test selection of the paths the merge changed (D9), and both `RSC-REGENERATE` literals in `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` are updated in the same commit and pass.
- [x] AC-07: `## Workflow` item 5 of the Python, PowerShell, and C# typed-engineer agent sources under `scripts/harness-generation/sources/agents/` carries the D4 orchestration-delegation sentence in both the Claude and Codex halves, and every generated `.claude/agents/`, `.codex/agents/`, Codex variant, and bundle copy carries it. Verified by a new required-token row in `test-cadence-wording.Tests.ps1` that passes and by the AC-11 and AC-12 generator checks.
- [x] AC-08: Step 5 of `feature-review-workflow` (`.claude` and `.agents` copies and bundles) states the D3 coverage re-run over the branch's test selection and names the final-QC artifact and `## CI Cross-check` as the source of repository-wide totals. Verified by a new required-token row in `test-cadence-wording.Tests.ps1`, and by the `REVIEW-*` rows of `parallel-gate-wording.Tests.ps1` and `less-evidence-contract.Tests.ps1`, all passing.
- [x] AC-09: `## When to Use This Skill` of the `python`, `powershell`, and `csharp` `*-qa-gate` skills in `.claude/skills/` and `.agents/skills/`, their bundles, and the csharp-legacy qa-gate variants applies the QA gate to the final QA loop and the remediation gate, not to a phase gate. Verified by the updated `QAGATE` literal rows in `test-cadence-wording.Tests.ps1` and the QA-gate rows of `parallel-gate-wording.Tests.ps1` passing.
- [x] AC-10: The execution-environment brief (source, generated copy, and bundle copies) `## Test Isolation Checks` and the `test-execution-policy` `### Scoped Pester runs` section (all copies) name the phase gate, the remediation gate, and the sync check as selection runs through the launcher. Verified by the `BRIEF` rows and a new brief row in `test-cadence-wording.Tests.ps1`, and the `PGW-SCOPED-*` rows of `parallel-gate-wording.Tests.ps1`, passing.
- [x] AC-11: Generated outputs are regenerated from sources: `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` and `-Surface instructions -Check` report no drift, and `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` passes. The command output is recorded under `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/`.
- [x] AC-12: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exits 0 with no drift. The command output is recorded under `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/`.
- [x] AC-13: Bundle copies are in parity: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, and the `TCW-BUNDLE-*` rows pass, and `AGENTS.md` is byte-identical to `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`, verified by the `TCW-BUNDLE-AGENTS-MD` row and by equal SHA-256 digests recorded in evidence.
- [x] AC-14: The existing vocabulary sweeps pass on the changed tree: the `runClassForbidden` rows of `test-cadence-wording.Tests.ps1` and the `PGW-SWEEP-SURFACES` and `PGW-SWEEP-HELPER` rows of `parallel-gate-wording.Tests.ps1`, with the `PGW-SWEEP-*` token list and its count assertion unchanged (D7).
- [x] AC-15: The `EXECUTOR`, `PLANNER`, `POLICY`, and `TCW-TEMPLATE-*` rows of `test-cadence-wording.Tests.ps1` pass after the executor, planner, rule, prompt, and plan-template rewording, with their per-template gate-count assertions unchanged.
- [x] AC-16: Ledger entry `.dev/engineering/process-reductions/0014-targeted-test-cadence.md` exists with non-blank `## Summary` (including `reduction: 0014` and `Issue: #1228`), `## Reason and Evidence` (quoting the owner objective verbatim and recording D6 and D10), `## Files Changed` (every changed path including mirrors, bundles, generated variants, and contract tests), `## Stored Patch` naming `patches/0014-targeted-test-cadence.patch` (the prior text in patch form), `## Revert Steps` with the labels `Apply the blocks`, `Re-copy mirrors and bundles`, `Regenerate Codex variants`, `Restore pinned hashes`, `Restore contract-test literals`, and `Run the contract tests` in that order ("not applicable" where a label does not apply), and `## Revert Signals`; the README index carries its row; and `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` and `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` pass.
- [x] AC-17: The `Final QA loop` bullet of `## Test Cadence (Mandatory)` in both copies still requires a full run of each language gate with coverage compared with the `Phase 0 baseline`, and the `Phase 0 baseline` remains a full run with coverage. Verified by the `CANONICAL-*` rows and by this item's own `Phase 0 baseline` and final QA artifacts under `evidence/baseline/` and `evidence/qa-gates/`, the final QA artifact recording the coverage comparison.
- [x] AC-18: CI is unchanged: `git diff --name-only <merge-base>...HEAD` recorded under `.dev/active/1228-targeted-test-cadence/evidence/other/` lists no path under `.github/workflows/`.
- [x] AC-19: Out-of-scope and protected paths are unchanged: the AC-18 diff lists no path under `scripts/dev_tools/atomic_executor/`, no `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, or `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, no D10 standalone Copilot agent or prompt, no path under `.claude/lib/docs/`, `docs-*` skills, or `documentation-workflow` (any surface or bundle), and no new `.py` file; and `test_frozen_epic_surface_matches_pinned_baseline_digest` passes.

## Definition of Done

- [ ] Every acceptance criterion above is checked off with its named test, generator check, or recorded search.
- [ ] Contract tests run through the launcher `pester` suite with `-TestPath`, in parallel.
- [ ] Phase gates follow the new cadence; the final QA loop is a full run compared with the `Phase 0 baseline`.
- [ ] Evidence files are append-only with clock timestamps under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`.
