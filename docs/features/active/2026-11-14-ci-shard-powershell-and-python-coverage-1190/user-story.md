# `2026-11-14-ci-shard-powershell-and-python-coverage` — User Story

- Issue: #1190
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-14T17-45

## Story Statement

- As a repository maintainer, I want the PowerShell QC and Python 3.13 coverage legs sharded more finely, so that PR CI wall-clock time falls toward 11 minutes per leg.
- As a contributor opening a PR, I want a failing shard or an incomplete split to fail the required gate, so that faster CI never hides an unrun test or a lowered coverage bar.

## Problem / Why

CI wall-clock time is dominated by the PowerShell QC shards (13.3 to 16.9 minutes each on 3 shards) and the Python 3.13 job (16.4 minutes, 13.6 of them in the coverage pytest step), measured on the main push run of 2026-11-14 19:24Z. On PR runs, runner waits pushed total CI to about 30 minutes. The owner asked for more shards on 2026-11-14.

## Personas & Scenarios

- Persona: Repository maintainer and contributor
  - Opens several PRs a day and waits on CI before merging.
  - Needs coverage thresholds (85% line, 75% branch) and the required gate to stay trustworthy.
  - Constraint: no new Python, parallel-only test runs, stable required context names.
- Scenario: A contributor pushes a PR.
  - CI runs 6 PowerShell shards and 2 Python 3.13 coverage shards in parallel with the static checks.
  - A combine job checks that every test file ran exactly once, merges coverage, and enforces thresholds under the existing `Code Quality & Tests (3.13)` context.
  - If any shard fails or a file is missing or duplicated, the required gate stays red; otherwise the PR is mergeable sooner.

## Acceptance Criteria

- [ ] PowerShell QC runs the owner-specified number of size-balanced shards; the completeness check and coverage merge pass, and the total test count equals discovery.
- [x] Primary-version Python coverage runs in the owner-specified number of shards whose union is the whole suite, verified by a completeness check, with coverage combined before thresholds are enforced.
- [x] Coverage thresholds and the Codecov upload behave as before on the combined data; no threshold is lowered.
- [ ] The required CI gate still reports correctly and still blocks on any shard failure.
- [ ] A measured CI run after the change shows the PowerShell and primary-version Python legs each at or below the duration target stated in the issue, recorded as evidence.

## Non-Goals

- No change to the 3.11 and 3.12 compatibility runs or other jobs unless needed for correctness.
- No new Python code and no new test-split plugin dependency.
- No change to coverage thresholds, the PoshQC shard module, or `CI Required Gate` logic.
- No change to merge-queue or ruleset configuration.
