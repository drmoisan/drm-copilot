# Remediation Plan: execution-env-test-worktree-filter (#1019), Cycle 1

Remediation-Mode: proportionate
Inputs: `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019/remediation-inputs.2026-11-06T17-59.md`
Scope: Finding 1 only (the Python coverage artifact `artifacts/python/lcov.info` is absent). No production or test file changes in this cycle. `poetry install` is never run; the Poetry environment is the shared main-checkout `.venv`. Tool routes follow the `execution-environment` skill.

Correction to the inputs: `evidence/coverage/` is not a canonical evidence kind. Coverage evidence for this cycle is written to `<FEATURE>/evidence/qa-gates/`, where `<FEATURE>` is `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019`.

`SCRATCH` is `<session scratchpad>/issue-1019/`.

### Phase 0 — Policy Reading

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/python.md` in that order and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carrying `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the artifact exists and lists all four files.

### Phase 1 — Python Coverage Artifact

- [ ] [P1-T1] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -n auto` from the repository root, in the background-tolerant route the `execution-environment` skill describes. The project `addopts` writes `artifacts/python/lcov.info`. Write `<FEATURE>/evidence/qa-gates/qc-python-coverage.<timestamp>.md` carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, where the summary states the numeric repo-wide line percentage and branch percentage read from the totals of `artifacts/python/coverage.json`. Acceptance: `artifacts/python/lcov.info` exists, line coverage is at least 85%, and branch coverage is at least 75%. The branch introduces no test failure. A pre-existing failure unrelated to the diff is named in the artifact with its test node and a statement of why it is unrelated, verified by running that test node against the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD` and observing the same failure.
- [x] [P1-T2] Confirm that `artifacts/python/lcov.info` is non-empty and that the JSON report totals used in P1-T1 match the percentages recorded in the artifact `qc-python-coverage.<timestamp>.md` (the lexicographically greatest match). Acceptance: both values agree with the report.

### Phase 2 — Self-Review

- [ ] [P2-T1] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. The Python coverage row cites the P1-T1 artifact. Acceptance: no FAIL row remains.

## Pre-Mortem

- Review checklists: P2-T1 walks all three policy-audit templates against the merge-base diff, so the checklist that reported Finding 1 is re-run.
- Coverage: P1-T1 produces the missing `artifacts/python/lcov.info` and records numeric repo-wide line (at least 85%) and branch (at least 75%) values from the JSON report totals; P1-T2 cross-checks them.
- Mirror parity: not applicable, because no mirrored, bundled, or brief file changes in this cycle.
- File size: not applicable, because no production or test file changes in this cycle.
- Test isolation: no test changes in this cycle, so the reversed-order run already recorded stands; the `-n auto` run in P1-T1 adds a concurrent-worker pass with zero new failures required.
- CI-only behavior: not applicable, because no code, workflow, or test changes in this cycle; the evidence-only diff is docs-only for change-scope purposes.
- Evidence: all artifacts are written to `<FEATURE>/evidence/` under `<name>.<timestamp>.md` names with the canonical `qa-gates` kind, and record no absolute paths.
