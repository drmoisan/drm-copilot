# Remediation Plan: execution-env-test-worktree-filter (#1019), Cycle 1 (re-plan)

Remediation-Mode: proportionate
Inputs: `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019/remediation-inputs.2026-11-06T17-59.md`
Scope: Finding 1 only (the Python coverage artifact `artifacts/python/lcov.info` is absent). No production or test file changes in this cycle. `poetry install` is never run. Tool routes follow the `execution-environment` skill.

Why the first plan failed: the earlier measurement recorded 48.36% line coverage because the shared Poetry `.venv` resolves `drm_copilot_discovery` to a sibling worktree, so all 140 files under `packages/discovery-runtime/src` in this worktree measured 0%. The other 226 source files measured 94.27% line and 89.11% branch. This was verified by importing the package and printing its file path, and by splitting the JSON report totals by source root. This plan re-measures with `PYTHONPATH` pointing at this worktree's `packages/discovery-runtime/src`.

Correction to the inputs: `evidence/coverage/` is not a canonical evidence kind. Coverage evidence is written to `<FEATURE>/evidence/qa-gates/`, where `<FEATURE>` is `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019`.

`SCRATCH` is `<session scratchpad>/issue-1019/`. The launcher `SCRATCH/issue-1019-cov.sh` already exists.

### Phase 0 — Policy Reading

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/python.md` in that order. Acceptance: the artifact `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` (lexicographically greatest match) exists and lists all four files.

### Phase 1 — Coverage Re-Measurement and Self-Review

- [x] [P1-T1] From the worktree root, run `sh SCRATCH/issue-1019-cov.sh`. The launcher sets `PYTHONPATH` to this worktree's `packages/discovery-runtime/src`, prints the imported `drm_copilot_discovery` package path, runs the CI-shaped Pytest coverage command, and runs `scripts.dev_tools.check_python_coverage_thresholds` with thresholds 85 and 75. Write `<FEATURE>/evidence/qa-gates/qc-python-coverage.<timestamp>.md` carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The summary states the printed package path as a repository-relative path only, the pass and fail counts, and the numeric repo-wide line and branch percentages read from the totals of the JSON report. The artifact states that it supersedes the `qc-python-coverage.2026-11-06T18-08.md` measurement because that measurement resolved the discovery package to a sibling worktree. Acceptance: the imported package path lies inside this worktree, `artifacts/python/lcov.info` exists, `PYTEST_EXIT` and `THRESHOLD_EXIT` printed by the launcher are both 0, line coverage is at least 85%, and branch coverage is at least 75%. No absolute path appears in the artifact.
- [x] [P1-T2] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. The Python coverage row cites the artifact selected in P1-T1. Acceptance: no FAIL row remains.

## Pre-Mortem

- Review checklists: P1-T2 walks all three policy-audit templates against the merge-base diff, so the checklist that reported Finding 1 is re-run against the corrected measurement.
- Coverage: P1-T1 produces the missing `artifacts/python/lcov.info` from a run whose discovery package resolves inside this worktree, and records numeric repo-wide line and branch values against the 85 and 75 thresholds.
- Mirror parity: not applicable, because no mirrored, bundled, or brief file changes in this cycle.
- File size: not applicable, because no production or test file changes in this cycle.
- Test isolation: no test changes in this cycle, so the reversed-order run already recorded for the changed Python test module stands.
- CI-only behavior: CI installs the package from its own checkout, so the `Enforce Python coverage thresholds` step measures the same population as the corrected local run; the stale sibling-worktree resolution does not occur there.
- Evidence: all artifacts are written to `<FEATURE>/evidence/` under `<name>.<timestamp>.md` names in the canonical `baseline` and `qa-gates` kinds, and record no absolute paths.
