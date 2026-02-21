# Remediation Plan: 2026-02-19-minor-audit-small-change-28-v3 (2026-02-21T12-40)

- **Issue:** #28
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-21T12-40
- **Status:** In progress
- **Version:** 2.0

## Required References

- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`
- `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/python-suppressions.instructions.md`
- `.github/instructions/self-explanatory-code-commenting.instructions.md`
- `.github/skills/policy-compliance-order/SKILL.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/remediation-inputs.2026-02-21T12-40.md` (PRIMARY)
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/spec.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/research.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/policy-audit.2026-02-21T12-40.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/code-review.2026-02-21T12-40.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/feature-audit.2026-02-21T12-40.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/plan.2026-02-21T11-38.md` (status-sync source)

## Scope Lock and Non-Negotiables

- Remediation scope is limited to persisted work-mode marker correction and PR-context baseline consistency.
- Marker correction is now complete with canonical `- Work Mode: full` in `issue.md`; remaining scope is artifact alignment and verification closure.
- Do not weaken fail-closed mode semantics.
- Do not remove contract or smoke tests.
- Do not edit policy files under `.github/instructions/`.
- Do not skip evidence refresh when remediation modifies tracked files.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context, Mode Resolution, and Baseline Synchronization

- [x] [P0-T1] Record policy-read completion in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/policy-read.2026-02-21T12-40.md` after reading every file listed in `## Required References`.
	- Acceptance: File exists with exact labels `Timestamp: 2026-02-21T12-40`, `Command: policy-read`, and `EXIT_CODE: 0`.

- [x] [P0-T2] Resolve the selected work mode from canonical `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md` marker using marker-first precedence and fail-closed default to `full`.
	- Acceptance: `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/work-mode-resolution.2026-02-21T12-40.md` exists and contains exact labels `Timestamp:`, `Command: resolve-work-mode`, `EXIT_CODE: 0`, and `Resolved Mode:`.

- [x] [P0-T3] Capture baseline synchronization state of `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/plan.2026-02-21T11-38.md` in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/original-plan-status-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: snapshot-original-plan-status`, `EXIT_CODE: 0`, and `Observed Status:`.

- [x] [P0-T4] Capture baseline PR-context summary state from `artifacts/pr_context.summary.txt` in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/pr-context-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: snapshot-pr-context`, `EXIT_CODE: 0`, and `Base ref (requested):`.

- [x] [P0-T5] Run `poetry run black --check .` and record baseline output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/black-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T6] Run `poetry run ruff check` and record baseline output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/ruff-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T7] Run `poetry run pyright` and record baseline output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/pyright-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T8] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and record baseline output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/remediation-baseline/pytest-baseline.2026-02-21T12-40.md`.
	- Acceptance: Baseline file contains exact labels `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:`.

Phase completion criteria: All eight remediation-baseline artifacts exist and include machine-checkable schema labels.

### Phase 1 — Persist Canonical Work-Mode Marker in `issue.md`

- [x] [P1-T1] Insert exactly one `- Work Mode: <minor-audit|full>` line in `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md` metadata block above the first `##` heading, using the resolved mode from [P0-T2].
	- Acceptance: `issue.md` contains exactly one line matching regex `^- Work Mode: (minor-audit|full)$` and that line appears before the first `## ` heading.

- [x] [P1-T2] Run `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py`.
	- Depends on: [P1-T1]
	- Acceptance: Command exits with code `0`.

- [x] [P1-T3] Run `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_epic_review_status_updater_branch_by_marker"`.
	- Depends on: [P1-T1]
	- Acceptance: Command exits with code `0`.

Phase completion criteria: Marker placement is correct and both marker-routing verification commands pass.

### Phase 2 — Rebuild PR Context and Reconcile Audit References

- [x] [P2-T1] Regenerate PR context artifacts with explicit intended review base using `poetry run python -m scripts.dev_tools.pr_context.collector --base <intended-base>`.
	- Acceptance: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` both contain exact line prefix `Base ref (requested):` and the same intended base value.

- [x] [P2-T2] Update `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/policy-audit.2026-02-21T12-40.md` to remove base-mismatch warning text and align baseline statements with regenerated PR context.
	- Depends on: [P2-T1]
	- Acceptance: File contains no occurrences of `base mismatch` and no occurrences of `PARTIAL` status attributed to PR-context base inconsistency.

- [x] [P2-T3] Update `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/code-review.2026-02-21T12-40.md` to remove base-mismatch finding and align recommendation text to regenerated PR context.
	- Depends on: [P2-T1]
	- Acceptance: File contains no occurrences of `PR context base mismatch`.

- [x] [P2-T4] Update `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/feature-audit.2026-02-21T12-40.md` to remove base-assumption mismatch notes and align scope/baseline section to regenerated PR context.
	- Depends on: [P2-T1]
	- Acceptance: File contains no occurrences of `Observed PR context base artifact` that conflict with the selected intended base.

Phase completion criteria: PR-context artifacts and all three audits reference one intended base branch without mismatch warnings.

### Phase 3 — Evidence Refresh and Toolchain Re-Verification

- [x] [P3-T1] Run `poetry run black --check .` and record output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/qa-gates/black-check.2026-02-21T12-40.md`.
	- Acceptance: Evidence file contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P3-T2] Run `poetry run ruff check` and record output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/qa-gates/ruff-check.2026-02-21T12-40.md`.
	- Depends on: [P3-T1]
	- Acceptance: Evidence file contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P3-T3] Run `poetry run pyright` and record output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/qa-gates/pyright-check.2026-02-21T12-40.md`.
	- Depends on: [P3-T2]
	- Acceptance: Evidence file contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P3-T4] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and record output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/qa-gates/pytest-full.2026-02-21T12-40.md`.
	- Depends on: [P3-T3]
	- Acceptance: Evidence file contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:`.

Phase completion criteria: Full quality-gate loop passes in one clean sequence and all QA evidence artifacts are schema-valid.

### Phase 4 — Original Plan Status Synchronization and End-State Closure

- [x] [P4-T1] Synchronize baseline remediation linkage into `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/plan.2026-02-21T11-38.md` by adding a remediation reference to `remediation-plan.2026-02-21T12-40.md`.
	- Acceptance: Original plan file contains exact string `Remediation Plan: remediation-plan.2026-02-21T12-40.md`.

- [x] [P4-T2] Synchronize end-state status in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/plan.2026-02-21T11-38.md` so the remediation handoff/result is explicitly recorded.
	- Depends on: [P4-T1], [P3-T4]
	- Acceptance: Original plan file contains exact string `Remediation Status: Complete`.

- [x] [P4-T3] Capture end-state synchronization evidence in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/other/original-plan-status-endstate.2026-02-21T12-40.md`.
	- Depends on: [P4-T2]
	- Acceptance: Evidence file contains exact labels `Timestamp:`, `Command: verify-original-plan-status-sync`, `EXIT_CODE: 0`, and `Observed Status:`.

Phase completion criteria: Original plan contains both remediation-link baseline sync and end-state completion sync, with evidence artifact proving closure.

### Phase 5 — Mandatory Preflight Validation-Only Loop

- [x] [P5-T1] Submit this remediation plan to atomic executor preflight using directive line `DIRECTIVE: PREFLIGHT VALIDATION ONLY`.
	- Acceptance: Preflight output includes either `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`.

- [x] [P5-T2] Apply only plan-text revisions required by preflight feedback when output is `PREFLIGHT: REVISIONS REQUIRED`.
	- Depends on: [P5-T1]
	- Acceptance: Updated plan resolves every explicitly reported preflight violation in the previous output.

- [x] [P5-T3] Re-run validation-only preflight loop until output is exactly `PREFLIGHT: ALL CLEAR`.
	- Depends on: [P5-T2]
	- Acceptance: Final preflight output contains exact string `PREFLIGHT: ALL CLEAR`.

Phase completion criteria: Final preflight signal is `PREFLIGHT: ALL CLEAR`.

## Verification Matrix

- Marker persistence and routing checks:
	- `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py`
	- `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_epic_review_status_updater_branch_by_marker"`
- PR-context regeneration:
	- `poetry run python -m scripts.dev_tools.pr_context.collector --base <intended-base>`
- Full QA loop:
	- `poetry run black --check .`
	- `poetry run ruff check`
	- `poetry run pyright`
	- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

## Open Questions / Notes

- Intended base value for PR-context regeneration must be supplied explicitly at execution time and reused consistently across all refreshed artifacts.
