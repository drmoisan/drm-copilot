# parallel-only-test-gates-and-leak-scan — Spec

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T02-09
- **Status:** Draft
- **Version:** 0.3

## Overview

The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI, although the skill calls it "the CI shape".

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks. #1096 adds a static scan for that purpose.

The owner split this item on 2026-11-07. #1094 is the parallel-only test gate change alone, and it is text and contract tests only. The static leak scan and the test fixes moved to #1096, which starts after #1094 merges. `research/research.2026-11-06.md` predates the split. Where it differs from this specification, this specification governs.

## Behavior

### 1. Parallel-only test gates

- The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal parallel workers. A suite is re-run only after a fix.
- No plan task or review check requires a serial, single-process, seeded-shuffle, reversed-order, comparison, or pre-change test-suite baseline run.
- A focused run of one test file to debug a specific failure is debugging only. It is never a gate or evidence.
- Remove the single-process, seeded-shuffle, and reversed-order requirements from `## Test Isolation Checks` in the `execution-environment` skill, and remove the phrase "which is the CI shape". The section states the parallel gates only and names no leak scan and no `Invoke-PoshQCLeakScan`, because the scan does not exist yet. #1096 adds that line. The heading `## Test Isolation Checks`, the heading `## CI Shape and Required Checks`, and the frontmatter description stay, because they are pinned or remain accurate.
- Update the other passages of the brief:
  - `## Test Runtime`: delete the clause that makes the serial `poetry run pytest` command the isolation reference.
  - `## CI-Only Failure Classes`: state that files in one shard share a process, so a leak surfaces when shard contents change. The rewording names no scan.
  - `## PowerShell Route and PoshQC MCP Limits`: name `Invoke-PoshQCParallelTest` as the branch-current route. State that merged JUnit and coverage exist only after a fully green run, and that failure detail is under `artifacts/pester/parallel/shard-<i>/`.
- `## CI Shape and Required Checks` is not edited, because no CI change occurs.
- State in the brief that the parallel gates govern where a policy file names a toolchain test command (Decision 1).
- Update the `atomic-plan-contract` skill, so that the Pre-Mortem `Test isolation` bullet states the parallel gates only and names no leak scan, and update any other planner, executor, reviewer, or preflight text that requires the removed runs.
- Remove every requirement for a pre-change test-suite baseline run, and every before-and-after comparison of test or coverage figures, from skills, agent text, and templates in all mirrors:
  - Static tool baselines stay: format, lint, type check, and analyzer findings, with their deltas.
  - Coverage is read from the single gate run against the thresholds.
  - Other senses of the word stay, such as `config/file-size-baseline.json`, the `evidence/baseline/` folder, base-branch diffs, and benchmark baselines.
- In `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and its bundle copy, the instruction to capture a baseline and the requirement for numeric baseline figures go. The `Baseline Coverage` column, the baseline coverage artifact labels, and the `Baseline:` and `Change:` parts of the comparison line stay as validator anchors, recorded as `N/A - no pre-change run`. See `## Constraints & Risks`.
- Update every editable surface in table A3 of `research/research.2026-11-06.md`, except `scripts/dev_tools/fix_all_branches.py`:
  - The `powershell-qa-gate`, `python-qa-gate`, and `feature-review-workflow` skills, in each mirrored copy.
  - `.claude/agents/atomic-executor.md`. Its `tools:` entries are permissions and stay.
  - The `.github/agents` agents listed in the table, and their bundle copies.
  - `.agents/skills/repo-automation-adapter/SKILL.md` and `.github/prompts/remediate-comments.prompt.md`.
  - The `.codex` agents listed in the table. Variants are generated, so only base agents are edited and the generator is run.
- Update every mirrored copy of the changed skills: `.claude/skills/`, `.github/skills/`, `.agents/skills/`, and the three bundles under `extensions/drm-copilot/resources/`.
- Replace the contract tests that pin the old wording, `test_brief_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`. The replacements assert the gates and carry negative tokens, so that reintroducing a removed requirement fails in any mirrored copy. The replacement covers every mirrored copy, not only the copies in `_CONTRACTS`. The replacements do not require `Invoke-PoshQCLeakScan`.
- In `test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, fix the worktree filter. The filter tests absolute `path.parts`, so a checkout under `.claude/worktrees/` finds no copies. It tests the parts relative to `REPO_ROOT` instead. The exclusion set and the asserted copy count are unchanged.
- Serial VS Code tasks may remain for debugging a single failure. They are not a validation gate.

### 2. Out of scope

Deferred to #1096:

- The static leak scan, including `Invoke-PoshQCLeakScan`.
- The leak allowlist.
- The CI step for the scan.
- The PoshQC modules for the scan.
- All test fixes: `Enter-DrmCopilotShell.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `TestHelpers.ps1`, and the batch-budget suites.
- The aggregates in `.vscode/tasks.json`.
- The serial command edits in `scripts/dev_tools/fix_all_branches.py`, `fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, and `cli_preflight.py`.

These are deferred because this reduced change is text and contract tests only.

Also out of scope:

- Any CI change.
- A code change to `scripts/dev_tools/validate_policy_audit_artifact.py` or `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`. No issue currently owns this change.
- A runtime check that compares session state before and after each test file during the parallel run.
- Adopting Pester `Run.Parallel`, which is experimental.
- Editing `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python` (Decision 1).

## Inputs / Outputs

- Inputs:
  - The skill, agent, prompt, and template text listed in `### 1. Parallel-only test gates`.
- Outputs:
  - The updated text in every mirrored copy, and the replaced contract tests.
  - `Invoke-PoshQCParallelTest` writes per-shard results to `artifacts/pester/parallel/shard-<i>/`, and merged results only when every shard succeeded. This behavior already exists and is not changed.
- Config keys and defaults: none.
- Versioning or backward-compatibility constraints:
  - An installed policy-audit template older than this change is still accepted, because the validators are unchanged.

## API / CLI Surface

No public function, command, or configuration key is added or changed. The gates use existing entry points:

- `Invoke-PoshQCParallelTest`, which returns an object with `ExitCode`. The caller exits with that value.
- `poetry run pytest -n auto`, with `-n auto` on the command line only.
- Jest through its normal parallel workers.

## Data & State

- Data transformations and invariants: none. The mirrored copies of each changed file stay in step, as the existing parity tests require.
- Caching or persistence details: none.
- Migration or backfill requirements: none. No state model or data migration is involved.

## Constraints & Risks

- Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Until #1096 lands, no check covers this.
- **Residual limit on the first acceptance criterion.** `fix_all_branches.py`, `fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, `cli_preflight.py`, and the VS Code aggregates `QC: Coverage: All Providers` and `QC: 5 Run All Checks` still invoke a serial command until #1096. The first acceptance criterion therefore covers skill, agent, and template text, and does not cover those Python tools or VS Code aggregates. Preflight requirements stated in skill or agent text are covered. Commands generated by `cli_preflight.py` and `prompt_builder.py` are not.
- **Policy-audit validators still read baseline fields.** `validate_policy_audit_artifact.py` and its TypeScript twin require the seven-column coverage table, the baseline coverage artifact labels, and `Baseline:` and `Change:` text in the comparison line. A code change to them is outside a text-only item, so the template keeps those fields as anchors. A reading of the validator source indicates that `N/A - no pre-change run` satisfies them, as a `Baseline Coverage` cell, as a label value, and in the line `Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A.` This was not confirmed by a run, so a contract test confirms it. Audits therefore carry fields that hold no data until the validators change.
- The negative tokens in the contract tests must not match the retained heading `## CI Shape and Required Checks`, the frontmatter description, the replacement text that states the debugging exception, or the retained policy-audit anchors, including the `Baseline Coverage` column.
- The frontmatter description of `atomic-plan-contract` stays, because `test_parallel_planner_surface_contracts.py` pins its baseline capture wording. Static baselines keep that wording accurate.
- `mcp__drm-copilot__run_poshqc_test` runs without shards, and no MCP tool exposes `Invoke-PoshQCParallelTest`. Executors reach the parallel gate through the `sh` launcher route. Gate evidence comes from `Invoke-PoshQCParallelTest` output and JUnit files, not MCP summaries.
- A failed parallel run can leave older merged files in place, so `ExitCode` is read first.
- `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` have pinned hashes and are not edited.
- This item runs alongside Epic #1019. It must not edit the epic's feature folders, and it must itself use the parallel-only gates.
- A narrow hook change was required. RF-6 found that the coverage stop hooks reject the `N/A - no pre-change run` record the template prescribes, so `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and their bundle copies change. This item is therefore no longer text and contract tests only, and this statement supersedes the text-only wording in `## Overview`, `### 2. Out of scope`, and `## Implementation Strategy`. The policy-audit validators stay unchanged.

## Decisions

### Decision 1: Policy files are not edited

- **Status:** To be reported to the owner at PR completion.
- **Decision:** `.claude/rules/` and `.github/instructions/` are not edited, by repository hard constraint. Those files use no serial, single-process, seeded-shuffle, or reversed-order wording as a requirement, but they name a toolchain test command (table A3).
- **Measurement:** the first acceptance criterion is measured as follows. No skill, agent, or template text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command.
- **Scope:** every editable surface in table A3 is in scope, except `scripts/dev_tools/fix_all_branches.py`, which moved to #1096. `.agents/skills/powershell` and `.agents/skills/python` follow the policy files and are unchanged.
- **Residual limit:** after this item, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, their bundle copies, and the two `.agents/skills` files still name a command that runs in a single process. The criterion is therefore met by the brief's governing statement, not by removal of those commands. The policy files remain the canonical policy source, and `.claude/rules/powershell.md` still directs agents to the MCP commands. The policy files also still state that coverage must not regress on changed lines. With no pre-change run, that statement is not measured, and coverage is checked against the thresholds only. A reader of those files alone sees the old command, and removing it requires a separate change authorized by the owner.

## Implementation Strategy

- Implementation scope:
  - Skill, agent, prompt, and template text as listed in `### 1. Parallel-only test gates`.
  - The contract tests that pin that text, and the worktree filter fix.
- New classes/functions/commands to add or update: none in production code. Contract tests are replaced or updated as listed.
- Dependency changes: none.
- Logging/telemetry additions and locations: none.
- Rollout plan: no feature flag. The new text applies from the merge of this item. Fallback is reverting the merge.

## Acceptance Criteria

### Locally verifiable criteria

- [x] No skill, agent, or template text in the repository requires a serial, single-process, seeded-shuffle, reversed-order, comparison, or pre-change test-suite baseline run. Measured as stated in Decision 1: no skill, agent, or template text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command. The residual limit in `## Constraints & Risks` applies: the deferred Python tools and VS Code aggregates still invoke a serial command until #1096.
- [x] The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
- [x] The branch diff changes no file under `.github/workflows/` or `scripts/powershell/PoshQC/`, and does not change `.vscode/tasks.json`, the Python tools named in `### 2. Out of scope`, or the policy-audit validators.
- [x] `## Test Isolation Checks` states the parallel gates, names no leak scan, and all mirrored copies match.
- [x] The `## Test Runtime`, `## CI-Only Failure Classes`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes listed in `### 1. Parallel-only test gates`, in every mirrored copy, and `## CI-Only Failure Classes` names no scan.
- [x] The Pre-Mortem `Test isolation` bullet of `atomic-plan-contract` states the parallel gates, names no leak scan, and names no removed run, in every mirrored copy.
- [x] No plan-contract or review text requires a comparison run, and the brief states that a focused run of one test file is debugging only and is never a gate or evidence.
- [x] Static tool baselines remain required, and skill, agent, and template text reads coverage from the single gate run against the thresholds, in every mirrored copy.
- [x] The policy-audit template requires no pre-change run, its retained baseline fields record `N/A - no pre-change run`, and a contract test shows that an audit filled in that way passes the unchanged policy-audit validators.
- [x] Every editable surface in table A3 of the research, except `scripts/dev_tools/fix_all_branches.py`, no longer names a serial command as a validation gate, and tool-permission entries in those surfaces are unchanged.
- [x] The contract tests pass against the new wording and fail if the removed requirements are reintroduced, in any mirrored copy.
- [x] `test_execution_environment_fact_is_unchanged_across_copies` filters on the parts relative to `REPO_ROOT` and passes in a checkout under `.claude/worktrees/`.
- [x] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
- [x] The validation evidence for this item comes from the parallel gates, and cites no single-process, seeded-shuffle, reversed-order, comparison, or focused run.

### CI-dependent criteria

These criteria require CI on the PR head. They stay unchecked and pending until CI has run.

- [x] CI-dependent: `CI Required Gate` reports success on the final PR head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Contract tests for the removed wording across all mirrored copies
