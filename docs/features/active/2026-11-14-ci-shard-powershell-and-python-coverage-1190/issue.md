# ci-shard-powershell-and-python-coverage (Issue #1190)

- Date captured: 2026-11-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-shard-powershell-and-python-coverage/ (Issue #1190)

- Issue: #1190
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1190
- Last Updated: 2026-11-14
- Work Mode: full-feature

## Problem / Why

CI wall-clock time is dominated by two jobs. Measured on the main push run of 2026-11-14 19:24Z:

- The three PowerShell QC shards (`.github/workflows/_poshqc.yml`, `shard: [1, 2, 3]`, windows-latest) took 13.3, 16.7 and 16.9 minutes. The Test PowerShell step was about 16.3 minutes of each; checkout and tool install were about 30 seconds.
- Python 3.13 "Code Quality & Tests" (`.github/workflows/_quality-checks.yml`) took 16.4 minutes. Its "Run tests with Pytest and coverage" step (`pytest -n auto --cov --cov-branch`) was 13.6 minutes.

The PowerShell QC aggregator then adds about 1.5 minutes after the shards. On PR runs, shards also waited for runners when several PRs ran CI at once, so PR CI reached about 30 minutes. The owner asked for more shards on 2026-11-14.

## Proposed Behavior

- Raise the PowerShell QC shard matrix from 3 to 6. The shards are already size-balanced, and the matrix is the only place the count is written. Confirm that shard-completeness verification and coverage merge still pass with 6.
- Split the Python 3.13 coverage test step into 2 shards: a deterministic, balanced split of the test files, run under `pytest -n auto --cov --cov-branch`. Upload coverage data per shard, combine it in a follow-on job, and run the existing threshold enforcement (`check_python_coverage_thresholds`, 85% line and 75% branch) and the Codecov upload on the combined report. Every test must run exactly once across the shards, with a completeness check that fails if a file is missing or duplicated.
- Leave the 3.11 and 3.12 compatibility runs and all other jobs unchanged unless a change is needed for correctness.

## Acceptance Criteria (early draft)

- [ ] PowerShell QC runs 6 size-balanced shards; the completeness check and coverage merge pass, and the total test count equals discovery.
- [ ] Python 3.13 coverage runs in 2 shards whose union is the whole suite, verified by a completeness check, with coverage combined before thresholds are enforced.
- [ ] Coverage thresholds and the Codecov upload behave as before on the combined data; no threshold is lowered.
- [ ] The required CI gate still reports correctly and still blocks on any shard failure.
- [ ] A measured CI run after the change shows the PowerShell and Python 3.13 legs each at or below about 11 minutes, recorded as evidence.

## Constraints & Risks

- Avoid new Python. Put the split and completeness logic in PowerShell or bash, or in the workflow. Add no new test-split plugin dependency unless research shows that is clearly simpler and the dependency is well maintained.
- More jobs per run increase runner-queue contention when several PRs run CI at once; report that trade-off.
- The workflow surface may be mirrored in push-down packs or bundles; keep them consistent.
- Parallel-only test policy applies; nothing here may introduce a serial run.

## Test Conditions to Consider

- [ ] Pester or bats tests for any new split or completeness helper: balanced assignment, deterministic order, a missing file detected, a duplicate detected
- [ ] actionlint passes on the changed workflows
- [ ] One real CI run on the PR proves the timings

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/ci-shard-powershell-and-python-coverage/` folder from the template
