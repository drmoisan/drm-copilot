# Remediation Inputs - issue #798, cycle 1

- Timestamp: 2026-10-09T03-29
- Branch: `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798` at `ee7d144d96dd7a18acfdc62a2298c6537c7dda74`
- Base: `origin/main`, merge base `e7d3779b398604af919678c16c877c8539a86cc0`
- Review verdict: REMEDIATION_REQUIRED (1 blocking finding, remediability `autonomous`)
- Source artifacts:
  - `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/policy-audit.2026-10-09T03-29.md`
  - `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/code-review.2026-10-09T03-29.md`
  - `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/feature-audit.2026-10-09T03-29.md`

## Scope of Remediation

**Evidence-only.** No production, test, or documentation change is required for the blocking finding. All 21 acceptance criteria evaluate PASS and remain checked; none should be changed by this remediation. Code review found no code-level blocker.

## Blocking Findings

### PA-1 - Python coverage artifact absent at review time (Blocking)

- Remediability: autonomous
- Finding: `artifacts/python/lcov.info` does not exist in the worktree. Coverage verification is mandatory for every language with changed files, and Python has 3 changed files (`scripts/dev_tools/validate_orchestration_artifacts.py`, two new test modules).
- Context: the executor's run recorded in `evidence/qa-gates/pytest-full-coverage.2026-10-09T03-10.md` would have written the artifact through `pyproject.toml` `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. The `artifacts/` directory was recreated at 03:25 and contains only `orchestration/` and the PR-context files. Recorded values meet every threshold (dispatcher 97.99% lines / 92.86% branches; scripts.dev_tools 93.68% / 87.09%; changed lines 16-19 covered).
- Required fix:
  1. From the worktree root, run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`. Do not pass a `.py` file path to `--cov`.
  2. Confirm `artifacts/python/lcov.info` exists after the run and is not cleaned up before the reaudit.
  3. Record `<FEATURE>/evidence/qa-gates/python-coverage-artifact.<yyyy-MM-ddTHH-mm>.md` with the command, EXIT_CODE, the verbatim dispatcher row and TOTAL row, the artifact path and size, and the dispatcher file line and branch percentages.
- Expected result: exit 0; dispatcher line coverage >= 85% and branch coverage >= 75%; no uncovered line among dispatcher lines 16-19; artifact present.
- Verification commands:
  - `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`
  - `ls -la artifacts/python/lcov.info`
  - `poetry run python -S -m scripts.dev_tools.validate_evidence_locations --root .`

## Non-Blocking Findings (no remediation cycle required)

- **CR-2 (Medium):** in the shared Poetry environment, the file-path dispatcher form resolves `scripts` to another worktree through an editable-install entry, because the bootstrap appends rather than prepends. Plan PD8 assigns filing a follow-up to the orchestrator; none has been filed. Action: the orchestrator files the follow-up through the normal promotion route. Not part of this remediation plan.
- **CR-3 (Low):** optional comment expansion on dispatcher line 16 explaining the E402-driven statement shape.
- **CR-4 (Low):** optional correction of the stale folder path in `issue.md` line 5.

## Do Not Do

- Do not change `scripts/dev_tools/validate_orchestration_artifacts.py`, the new test modules, or any `.claude/` document or mirror for PA-1.
- Do not uncheck or edit any acceptance criterion in `spec.md`.
- Do not add a coverage `omit`/`exclude` entry or lower any threshold.
- Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`; evidence goes under `<FEATURE>/evidence/qa-gates/`.
- Do not expand scope to CR-2 (prepend change or virtual-environment change) within this cycle.

## Reaudit Expectation

After PA-1 is resolved, a feature-review reaudit is expected to report zero blocking findings, provided no other change is introduced.
