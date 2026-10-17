# Remediation Inputs: ci-green-gate-all-checks-and-codex-parity (Issue #899)

- Timestamp: 2026-10-12T16-45
- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `a14899f7b059f0059866c0a67216475ceecf0a94`
- Base: `origin/main` @ `9338ed463c63a039cadbe4f0548af7151f43f687`
- Source artifacts:
  - `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/policy-audit.2026-10-12T16-45.md`
  - `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/code-review.2026-10-12T16-45.md`
  - `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/feature-audit.2026-10-12T16-45.md`
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-10-12 20:43:41 UTC, head `a14899f7b`)

## Remediation-Required Findings

### R-1 (policy-audit PA-1) - Python coverage artifact absent

- Severity: Blocking
- Remediability: autonomous
- Finding: The branch changes one Python file (`tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, test code only). `artifacts/python/lcov.info` does not exist in the worktree, and the feature evidence records coverage for the single module `scripts.dev_tools.generate_codex_agent_variants` (89%) only, with no repo-wide Python line or branch figure.
- Required outcome: produce `artifacts/python/lcov.info` from a Python coverage run over `tests/` with branch measurement, record the repo-wide Python line and branch percentages against the 85% line and 75% branch thresholds, and record a baseline comparison (no Python production file changed, so the production denominator and numerator match `origin/main`).
- Evidence location: `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/`.
- Scope limit: evidence-only. No production, test, mirror, policy, or configuration change. AC text in `issue.md` is not changed.
- Precedent: the same finding and evidence-only remediation in `docs/features/active/subagentstop-envelope-feature-review-coverage-896/remediation-plan.2026-10-12T11-25.md`.

## Not Remediation-Required

- AC-9: PENDING-CI; checked by the orchestrator against the PR `CI` artifact `poshqc-test-results`.
- Code-review CR-1, CR-2 (Minor) and CR-3, CR-4 (Info): non-blocking; CR-2 and CR-3 are pre-existing follow-up candidates.
