# Remediation Inputs — 2026-02-19-minor-audit-small-change-28 (v3)

## Required Fixes (Numbered, Atomic)

1. ~~Add persisted work-mode marker to canonical feature `issue.md`~~ **Resolved**
   - Files: `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md`
   - Location: metadata block above first `##` heading
   - Resolved behavior: file now contains exactly one marker line in allowed form: `- Work Mode: full`
   - Acceptance criteria:
     - ✅ Marker exists exactly once.
     - ✅ Marker appears above first section heading.
     - ✅ Marker value matches selected/actual mode (`full`).
   - Verification commands:
     - `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py`
     - `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_epic_review_status_updater_branch_by_marker"`

2. Rebuild PR context artifacts for intended review base and reconcile audit references
   - Files: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, and the three audit artifacts in `v3`
   - Location: PR-context Base/Head sections and any dependent statements in audits
   - Expected behavior: review artifacts reference a single intended base branch for baseline truth.
   - Acceptance criteria:
     - PR context regenerated with explicit intended base.
     - `policy-audit.*`, `code-review.*`, and `feature-audit.*` no longer carry base mismatch warning.
   - Verification commands:
     - `poetry run python -m scripts.dev_tools.pr_context.collector --base <intended-base>`
     - Sanity check by reading `artifacts/pr_context.summary.txt`

3. Re-run verification gates and refresh evidence timestamps if any remediation modifies tracked files
   - Files: `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/**`
   - Expected behavior: all quality gates pass after remediation and evidence remains schema-valid.
   - Acceptance criteria:
     - Formatter/lint/type/tests pass in one clean loop.
     - Any newly generated evidence files include `Timestamp`, `Command`, `EXIT_CODE` (baseline includes `Output Summary`).
   - Verification commands:
     - `poetry run black --check .`
     - `poetry run ruff check`
     - `poetry run pyright`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

## Do Not Do (Hard Constraints)

- Do not broaden scope beyond the marker persistence + audit baseline consistency fixes.
- Do not weaken fail-closed semantics or remove existing contract/smoke tests.
- Do not alter policy files under `.github/instructions/`.
- Do not silently skip evidence updates when remediation changes files.

## Unmet Acceptance Criteria and Minimum Changes

Unmet AC (from `v3/user-story.md`):
- None related to marker persistence. `issue.md` now includes `- Work Mode: full` in the canonical location.

Minimum change required:
- Continue with PR-context baseline alignment and review-artifact reconciliation.

Secondary audit-readiness gap:
- Align PR context base and audit references to one intended baseline branch.
