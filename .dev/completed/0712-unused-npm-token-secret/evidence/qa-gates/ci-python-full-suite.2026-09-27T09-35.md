# CI Linux Full-Suite Pytest and Coverage-Threshold Record (feature review)

Timestamp: 2026-09-27T09-35
Recorded by: feature-review (read-only query of GitHub Actions job metadata)
Run: https://github.com/drmoisan/drm-copilot/actions/runs/36322316826
Workflow: CI (event `workflow_dispatch`, branch `bug/unused-npm-token-secret-712`)
Run head SHA: bf4dc2b103d04cebc615238c60834573eb53bbfe (equals the reviewed branch head `bf4dc2b1`)
Run status at query time: in_progress (the `poshqc` and `shell-coverage` jobs were still running; neither runs pytest)

## Commands

Command: gh run view 36322316826 --json jobs
EXIT_CODE: 0

Command 2: gh api repos/drmoisan/drm-copilot/actions/jobs/<job-id> (one call per Python job listed below)
EXIT_CODE 2: 0 for each call

## Python quality-check jobs (runner label `ubuntu-latest`)

The pytest step in `.github/workflows/_quality-checks.yml` runs `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing` with `testpaths = ["tests"]` (full suite, no `-k` or `-m` filter). The next step runs `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.

| Job | Job ID | head_sha | Run tests with Pytest | Enforce Python coverage thresholds | Black | Ruff | Pyright |
|---|---|---|---|---|---|---|---|
| Code Quality & Tests (3.10) | 108628402543 | bf4dc2b1 | success | success | success | success | success |
| Code Quality & Tests (3.11) | 108628402635 | bf4dc2b1 | success | success | success | success | success |
| Code Quality & Tests (3.12) | 108628402546 | bf4dc2b1 | success | success | success | success | success |
| Code Quality & Tests (3.13) | 108628402581 | bf4dc2b1 | success | success | success | success | success |

## Interpretation

On a fresh Linux checkout, where the gitignored `.claude/state/` directory does not exist, the full pytest suite passed and the 85% line / 75% branch coverage floors were met on Python 3.10 through 3.13 at the branch head. This includes `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which fails locally only because of the hook-written gitignored file described in open issue #510.

Limitation: the step-level log text (per-test pass lines and the TOTAL coverage row) was not retrievable while the run was in progress (`gh run view --log` reports "run ... is still in progress; logs will be available when it is complete"). The job and step conclusions above are the recorded evidence.
