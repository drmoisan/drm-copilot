# Issue #615 Remediation Plan

- **Work mode:** full-bug remediation
- **Feature folder:** `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615`
- **Requirements:** `remediation-inputs.2026-08-31T14-01.md`
- **Scope:** reconcile evidence/review readiness and prove the exact PR head; preserve runtime and mirror files.

## Objective

Resolve the review finding that canonical full pytest evidence records an earlier failing local runtime-state condition despite separate isolated green evidence. Regenerate authoritative full Python QA proof after the approved digest correction, reconcile issue #615 documents, and verify exact-head CI. Do not weaken the frozen-surface assertion.

## Constraints

- If a current defect remains, only `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` may change, and only the matching `.claude/skills/epic-orchestrate/SKILL.md` tuple.
- Do not modify `.claude/skills/epic-orchestrate/SKILL.md`, its mirror, production code, unrelated expectations, or policy files.
- All evidence goes under `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/<kind>/`.
- Any failed or file-changing QA step restarts at formatting.

### Phase 0 — Remediation baseline and policy reconciliation

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`, and `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` in order; write the timestamp, policy order, and file list to `evidence/remediation-baseline/phase0-instructions-read.md`.
- [x] [P0-T2] Record branch, HEAD, workspace status, and feature path with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` in `evidence/remediation-baseline/repository-state.md`.
- [x] [P0-T3] Reconcile `issue.md`, `spec.md`, remediation inputs, review handoff, and original plan for issue #615, full-bug mode, target digest, scope, and preservation invariants; write the result to `evidence/other/remediation-requirements-reconciliation.md`.
- [x] [P0-T4] Classify the failing full-gate artifact versus isolated green artifacts and establish current reproducibility; write exact evidence lineage and conclusion to `evidence/remediation-baseline/coverage-evidence-reconciliation.md`.
- [x] [P0-T5] Independently compute the runtime skill SHA-256 and compare expected/current tuple values, second pin, fragments, and mirror parity; write all values to `evidence/remediation-baseline/digest-cross-check.md`.

### Phase 1 — Correction decision and scope proof

- [x] [P1-T1] Determine whether the stale tuple remains reproducibly incorrect; write `CODE_CHANGE_REQUIRED: yes|no`, evidence basis, and target path to `evidence/other/correction-decision.md`.
- [x] [P1-T2] If required by P1-T1, update only the matching digest value in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; otherwise preserve implementation and record no change.
- [x] [P1-T3] Verify the diff contains no runtime, mirror, production, unrelated-expectation, or policy changes; write changed paths and scope result to `evidence/other/remediation-scope-diff.md`.

### Phase 2 — Focused regression proof

- [x] [P2-T1] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`; record exact command, exit code, and summary in `evidence/regression-testing/frozen-surface-contract-remediation.md`.
- [x] [P2-T2] Verify the corrected digest, second pin, fragments, runtime bytes, and mirror parity remain consistent; record the comparison in `evidence/regression-testing/frozen-surface-preservation-remediation.md`.

### Phase 3 — Canonical full Python QA loop

- [x] [P3-T1] Run `poetry run black .`; record result in `evidence/qa-gates/remediation-python-format.md`; restart Phase 3 if it fails or changes files.
- [x] [P3-T2] After clean formatting, run `poetry run ruff check .`; record result in `evidence/qa-gates/remediation-python-lint.md`; restart Phase 3 if it fails or changes files.
- [x] [P3-T3] After clean formatting and linting, run `poetry run pyright`; record result in `evidence/qa-gates/remediation-python-typecheck.md`; restart Phase 3 if it fails or changes files.
- [x] [P3-T4] After clean prior steps, run `poetry run pytest --cov=. --cov-report=term-missing`; write numeric coverage and full summary to `evidence/qa-gates/remediation-python-tests-coverage.md`.
- [x] [P3-T5] Compare baseline, prior failing, isolated green, and remediation full-gate evidence; verify coverage thresholds and no regression; write numeric values and conclusion to `evidence/qa-gates/remediation-python-coverage-comparison.md`.

### Phase 4 — Review readiness and exact-head CI

- [x] [P4-T1] Check off only issue #615 acceptance criteria linked to canonical remediation evidence and mirror the update in `evidence/issue-updates/issue-615.2026-08-31T14-01-remediation.md`.
- [ ] [P4-T2] Collect commit context for the staged remediation diff and record SHA and changed-file list in `evidence/other/remediation-commit-context.md`; do not commit without parent workflow authorization.
- [ ] [P4-T3] Refresh full-bug review against the resolved base branch and close the evidence-lineage finding with canonical proof under `evidence/other/`.
- [ ] [P4-T4] Verify the exact PR head SHA and required GitHub Actions checks, including Python 3.11 and the frozen-surface contract; record URLs and conclusions in `evidence/qa-gates/remediation-ci-exact-head.md`.
- [ ] [P4-T5] If exact-head CI fails, identify the exact job/cause, apply only an in-scope correction, and repeat Phases 2–4 without bypass or merge.

### Phase 5 — Completion validation and handoff

- [ ] [P5-T1] Run orchestration validation for the feature folder, remediation plan, and required evidence; record the result in `evidence/other/remediation-completion-validation.md`.
- [ ] [P5-T2] Confirm issue, checklist, canonical evidence, review, exact-head CI, PR, and `orchestrator-state.json` are consistent; keep merge authorization independent.
- [ ] [P5-T3] Return `REMEDIATION_PLAN_READY` with this exact path, required preflight signal, correction decision, and any validator limitation to the parent orchestrator.
