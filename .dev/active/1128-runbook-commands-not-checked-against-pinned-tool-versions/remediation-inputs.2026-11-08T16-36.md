# Remediation Inputs — Issue #1128 (cycle 2, CI failure)

- Timestamp: 2026-11-08T16-36
- Opened by: orchestrator, from a CI failure on PR #1137 at head f3e434f505fc570071d1737a7b7b8c55131758f8
- Remediation-Mode: proportionate
- Failing check: `quality-checks7 / Code Quality & Tests (3.11)`, step `tier-classification` (the 3.12 and 3.13 legs were cancelled by matrix fail-fast; `CI Required Gate` failed as a result). All other CI jobs on that head succeeded.
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/42498494971/job/128785995807

## Findings

### CI-1 — New project has no quality-tiers entry

- Remediability: autonomous
- Finding-Scope: contained
- Location: `quality-tiers.yml` at the repository root (the `.claude/lib/*` project entries).
- Observed: `poetry run python -m scripts.dev_tools.check_quality_tiers` exits 1 with `QT008: discovered project '.claude/lib/runbook' has no entry`. Reproduced locally in the item worktree.
- Required behavior: add a `.claude/lib/runbook` entry in the same shape and tier as the sibling `.claude/lib/*` runtime-library entries (`tier: T3`, rationale `Runtime library shipped in the .claude bundle`), placed in the existing order. `check_quality_tiers` then exits 0.

## Prevention for this cycle

The main plan's final gates did not run the full `_quality-checks.yml` step set, so this was first seen in CI. The cycle's final gate runs every step of that job locally against the head: Black check, Ruff, Pyright, the Codex generator `--check`, `check_quality_tiers`, and one `pytest -n auto` run, and records each result. No PowerShell file changes in this cycle, so no Pester run is required.
