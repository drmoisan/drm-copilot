# Final pytest gate (P5-T3)

Timestamp: 2026-11-08T15-03
Command: sh SCRATCH/issue-1130-pytest-final.sh (from the worktree root: env -u VIRTUAL_ENV <main-checkout .venv python> -m pytest -n auto -q -p no:cacheprovider --cov=scripts --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1130-cov-final.json); env -u VIRTUAL_ENV <main-checkout .venv python> -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary:
- pytest: 16537 passed, 6 skipped, 0 failed in 368.56s (one parallel run, pytest-xdist -n auto); exit 0. Phase 0 baseline: 16537 passed, 6 skipped, 0 failed; no new failure.
- Repo-wide scripts coverage (combined line+branch column): TOTAL 17653 statements, 915 missed, 6418 branches, 432 partial, 94% (baseline 94%; no production Python file changed).
- The run covers the manifest-completeness, dependency-closure, both resource-contract, frozen-surface (PINNED_FROZEN_SURFACE_HASHES), and test_ci_gate_epic_child_contracts.py tests; all passed.
- Codex generator check (--check): exit 0, no drift.
- The run's tree differed from the final head only in two PowerShell test files (the P5-T2 isolation fix), which pytest does not read.
