# pytest-xdist-parallel-test-cycle (Potential)

- Date captured: 2026-10-31
- Author: Dan Moisan
- Status: Promoted (#1048)

## Problem / Why

The repository's two big test suites run slowly, both locally and in CI.

**Python (pytest).** The suite (about 3,000 parametrized tests across `tests/unit`, `tests/scripts` and `tests/discovery_runtime`) runs serially in CI on four Python versions, and the `quality-checks7 / Code Quality & Tests (3.13)` job took about 18 minutes on a recent run. Locally there is a single `QC: 4 Pytest: run tests` task and no parallel option. A downstream repository ported to this toolset measured `pytest-xdist`: on a 2 vCPU runner `-n auto` gave no gain (269 s against 275 s serial), on a 16-core runner it took 43.8 s with 16 workers, and locally 2 workers were 1.75 times faster than 1. This repository is public, so `ubuntu-latest` has 4 vCPUs.

**Pester (PowerShell).** The repository has 482 Pester test files (`tests/scripts/claude-hooks` 195, `claude-lib` 112, `codex-hooks` 83, `dev-tools` 37, and others). Local runs are reported by the owner as taking an extraordinary amount of time. CI already shards Pester across three Windows runners with `Invoke-PoshQCTest -ShardIndex -ShardCount` (`scripts/powershell/PoshQC/PoshQC.Shard.psm1`, weighted shard assignment), but a recent run's shards took 462 s, 290 s and 364 s, so the shards are unbalanced, and the separate Linux hook-suite job (`tests/scripts/claude-hooks` and `codex-hooks`, 316 s) and the static job (224 s) add to the total. Locally there is no way to run the shards concurrently on one machine; a full run is a single process. Pester 5 has no built-in parallel mode, and the repository's coverage tooling (`artifacts/pester/powershell-coverage.xml`) must come from a merged result, not from a partial run.

## Proposed Behavior

### Part 1: pytest parallelism (port of the tested downstream configuration)

1. Add `pytest-xdist = "^3"` to the dev dependencies, with `poetry.lock` updated by Poetry. `pytest-cov` already merges worker coverage with no extra configuration.
2. Run the CI unit pytest step with `-n auto`, keeping `--cov`, `--cov-branch`, the XML and JSON reports and the threshold check working. Never put `-n auto` in `addopts`, because it breaks the VS Code Test Explorer (the `vscode_pytest` result hook runs in the xdist controller with an empty node-id map, so results are keyed to the wrong file).
3. Add parallel pytest tasks to `.vscode/tasks.json` (unit tests with `-n auto`, and unit tests with coverage and the lcov report), without removing the existing `QC: 4 Pytest: run tests` task.
4. Fix any test-isolation failure that xdist exposes (leaked global state, temp files, wall-clock waits) and any Windows portability problem the downstream repository found where this repository's tests have it.
5. Evaluate, as separate decisions, the strictness options the downstream repository uses (`--import-mode=importlib`, `--strict-markers`, `--strict-config`, `xfail_strict`, `filterwarnings = ["error"]`) and adopt only those that pass with zero or trivial test edits. Record the others as follow-ups with the reason.

### Part 2: Pester parallelism (new scope, added by the owner on 2026-10-31)

Research first, then decide. The researcher must establish, from the repository and primary sources, which of these (or others) are sound, and the plan adopts the smallest set that meets the goal:

- A local parallel runner: a PowerShell command and a VS Code task that launches N `Invoke-PoshQCTest -ShardIndex i -ShardCount N` processes concurrently on one machine, waits for all, and merges the JUnit and coverage outputs into the same artifacts a serial run produces, with the same pass/fail exit semantics. N defaults from the logical core count and is overridable.
- Shard balance: measure real per-file durations (JUnit) and feed them to the existing weighted assignment so the three CI shards finish together (the last run's spread was 290 s to 462 s), and consider more shards where the Windows runners allow.
- Whether the Linux hook-suite job duplicates work already done in the Windows shards, and whether it can be narrowed or merged.
- Whether Pester itself offers a supported in-process parallel mechanism usable with coverage in the installed version; adopt it only if it keeps coverage correct.
- Test isolation: any Pester suite that shares state across files (module-scope imports, environment variables, files) fails under concurrent shards; fix the leaker and the victim (repository rule: never work around by ordering).
- Constraint: no new Python; the runner is PowerShell (the PoshQC module and a task), and the existing coverage and completeness checks (shard completeness against a Pester discovery count, merged coverage) must keep passing.

### Documentation

6. Update the execution-environment brief's `## Test Runtime` section (six byte-identical copies) so that its guidance on parallel workers matches the new configuration for both runners.

Out of scope: classifying pytest tests into `architecture`, `contract` and `integration` markers and sharding integration tests in CI (no such tests are marked here; record as a follow-up unless classification is trivial), and a VS Code Test Explorer workspace settings file.

## Acceptance Criteria (early draft)

- [ ] `pytest-xdist` is a locked dev dependency, and `poetry.lock` is regenerated by Poetry.
- [ ] The CI unit pytest step runs with `-n auto` and the coverage threshold step passes on the merged `coverage.json`; `-n` is not in `addopts` and the serial task remains.
- [ ] The Python suite passes serially and with `-n auto`, several times and under a seeded shuffle, with no order dependence.
- [ ] The before and after duration of the `quality-checks7 / Code Quality & Tests (3.13)` job is recorded.
- [ ] Each pytest strictness option has a recorded adopt or defer decision with the reason.
- [ ] A local command and VS Code task run Pester shards concurrently, merge their results, and produce the same JUnit and coverage artifacts and exit semantics as a serial run.
- [ ] The CI Pester shards are balanced from measured durations, and the before and after wall-clock time of the Pester jobs is recorded.
- [ ] Pester suites pass when run as concurrent shards, with no cross-file state leaks.
- [ ] The brief's `## Test Runtime` section is updated in all six copies and the mirror contract tests pass.
- [ ] `test_quality_checks_workflow_contracts.py` passes with the changed pytest step, and the PoshQC and workflow contract tests pass with the changed Pester path.

## Constraints & Risks

- Any test that depends on order, on shared global state or on a shared temp file fails under xdist or concurrent shards. Fix the leaker and the victim; never work around by ordering or sharding.
- A 2 vCPU runner gave no pytest gain downstream; this repository's runner has 4 vCPUs. The measured CI result decides whether the pytest change stays.
- Pester coverage must be merged from all shards; a partial run must never overwrite the merged artifact.
- A workflow change needs a green workflow run on the branch head before merge (rule `modified-workflow-needs-green-run`).
- No new Python scripts; enforcement hooks do not invoke Python.
- Weekly model quota is tight (about 30 points in the pool on 2026-10-31); choose the smallest plan that meets the scope.

## Test Conditions to Consider

- [x] Unit coverage areas: the Python suite serially and under `-n auto`; the workflow contract test; the shard assignment with measured weights; the result and coverage merge for concurrent shards.
- [x] Integration scenarios: a full CI run with the changed steps comparing durations and coverage totals; a local concurrent Pester run compared with a serial run.
- [ ] CLI/API examples

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/` folder from the template
