# 2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168 — Remediation Plan

## Overview

This remediation plan addresses the rerun review findings recorded at `2026-04-29T15-18`: `scripts/dev_tools/validate_orchestration_review_artifacts.py` still exceeds the repository 500-line production-file limit, and the two new split Python modules remain below the repository 90% coverage target for new modules. The remediation must preserve the current MCP-only feature behavior, the public validator CLI contract, and the additive `delegation_receipts.promotion.*` validation path.

## Authoritative inputs

- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-inputs.2026-04-29T15-18.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/policy-audit.2026-04-29T15-18.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/code-review.2026-04-29T15-18.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/feature-audit.2026-04-29T15-18.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`

## In-scope files

- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `scripts/dev_tools/validate_orchestration_review_artifacts.py`
- `scripts/dev_tools/validate_orchestrator_state.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- Follow-up timestamped review artifacts in this feature folder

## Out-of-scope guardrails

- Do not weaken the `delegation_receipts.promotion.*` validation contract.
- Do not change the public validator CLI entrypoint or artifact-type names.
- Do not expand the remediation into unrelated feature-scope work outside the split validator modules, their direct tests, and the review refresh.
- Do not use suppressions or policy exceptions to avoid the file-size or coverage findings.

### Phase 0 — Baseline refresh

- [ ] [P0-T1] Re-read the current rerun review artifacts and capture fresh file-size baseline evidence for the three Python production validator modules.
  - Acceptance: The evidence artifact records the exact line counts and identifies `validate_orchestration_review_artifacts.py` as the only oversized file when that remains true.
- [ ] [P0-T2] Re-run the focused Python baseline coverage command so the remediation starts from a fresh, auditable coverage snapshot for the split validator modules.
  - Acceptance: The baseline artifact records numeric coverage values for `validate_orchestration_artifacts.py`, `validate_orchestration_review_artifacts.py`, and `validate_orchestrator_state.py`.

### Phase 1 — Resolve the file-size and coverage gaps

- [ ] [P1-T1] Split `scripts/dev_tools/validate_orchestration_review_artifacts.py` into smaller cohesive helpers so every touched production file is below 500 lines.
  - Acceptance: The validator continues to pass its existing tests and line-count evidence shows every touched production file below 500 lines.
- [ ] [P1-T2] Add focused Python tests for the remaining uncovered review-artifact and orchestrator-state branches.
  - Acceptance: The targeted test suite covers the remaining defensive branches without weakening current assertions.
- [ ] [P1-T3] Validate that the workspace CLI entrypoint still accepts the live checkpoint shape and the review-artifact validators still pass on the follow-up rerun artifacts.
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` passes, and the follow-up review artifacts validate structurally.

### Phase 2 — Final QA loop and review refresh

- [ ] [P2-T1] Run the Python QA loop in order: Black, Ruff, Pyright, then the focused coverage-enabled Pytest command.
  - Acceptance: All four steps complete cleanly in one final pass and the Pytest coverage output shows each new Python production module at or above 90%.
- [ ] [P2-T2] Refresh the policy-audit, code-review, and feature-audit artifacts with the follow-up findings and validate each artifact.
  - Acceptance: The follow-up review package uses refreshed PR context against `development`, validates successfully, and reports merge readiness accurately.
