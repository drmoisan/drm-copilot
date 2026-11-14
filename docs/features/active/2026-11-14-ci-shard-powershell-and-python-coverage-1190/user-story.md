# `2026-11-14-ci-shard-powershell-and-python-coverage` — User Story

- Issue: #1190
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-14T17-45

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

CI wall-clock time is dominated by two jobs. Measured on the main push run of 2026-11-14 19:24Z:

- The three PowerShell QC shards (`.github/workflows/_poshqc.yml`, `shard: [1, 2, 3]`, windows-latest) took 13.3, 16.7 and 16.9 minutes. The Test PowerShell step was about 16.3 minutes of each; checkout and tool install were about 30 seconds.
- Python 3.13 "Code Quality & Tests" (`.github/workflows/_quality-checks.yml`) took 16.4 minutes. Its "Run tests with Pytest and coverage" step (`pytest -n auto --cov --cov-branch`) was 13.6 minutes.

The PowerShell QC aggregator then adds about 1.5 minutes after the shards. On PR runs, shards also waited for runners when several PRs ran CI at once, so PR CI reached about 30 minutes. The owner asked for more shards on 2026-11-14.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] PowerShell QC runs 6 size-balanced shards; the completeness check and coverage merge pass, and the total test count equals discovery.
- [ ] Python 3.13 coverage runs in 2 shards whose union is the whole suite, verified by a completeness check, with coverage combined before thresholds are enforced.
- [ ] Coverage thresholds and the Codecov upload behave as before on the combined data; no threshold is lowered.
- [ ] The required CI gate still reports correctly and still blocks on any shard failure.
- [ ] A measured CI run after the change shows the PowerShell and Python 3.13 legs each at or below about 11 minutes, recorded as evidence.


## Non-Goals

Call out what is explicitly excluded from this feature.
