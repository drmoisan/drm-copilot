# Remediation Inputs: Parallel Scheduling Integration Cost (#1013)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

- Branch: `feature/parallel-scheduling-integration-cost-1013` @ `8683e0a7531b22794dac7b0431127cba5b390484`
- Base: `main`, merge base `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`
- Source review artifacts:
  - `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/policy-audit.2026-10-31T17-21.md`
  - `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/code-review.2026-10-31T17-21.md`
  - `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/feature-audit.2026-10-31T17-21.md`

Blocking finding count: 2 (both autonomous).

## Findings

### F-1 BLOCKING: TypeScript coverage artifact absent

Remediability: autonomous
Remediability-Evidence: The fix is to run the existing repository coverage script and record its output; it needs no external system, policy decision, or human input.

- Policy: mandatory coverage verification for every language with changed files on the branch (`.claude/rules/general-unit-test.md`; feature-review coverage procedure).
- Observation: four TypeScript test files changed (`extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts`, `blast-radius-derive-tolerance-keys.test.ts`, `config-carriage.test-helpers.ts`, `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`). `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` do not exist; `evidence/qa-gates/typescript.2026-10-31T16-01.md` shows every Jest run omitted `--coverage`.
- Expected behavior: a TypeScript coverage artifact exists at `coverage/lcov.info`, and repository-wide TypeScript coverage is line >= 85% and branch >= 75%.
- Fix:
  1. Run `npm run test:unit:coverage` at the repository root (produces `coverage/lcov.info`). If the extension package is measured separately, also run its Jest with `--coverage` (`extensions/drm-copilot/coverage/lcov.info`).
  2. Parse LF/LH and BRF/BRH totals and record them in `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/evidence/qa-gates/typescript-coverage.<timestamp>.md` with Command, EXIT_CODE, and Output Summary.
  3. If either figure is below threshold, stop and report; do not lower thresholds or add exclusions.
- Verification: `coverage/lcov.info` exists; the evidence file records line >= 85% and branch >= 75%.

### F-2 BLOCKING: Duplicate-key negative flow untested in the combination library

Remediability: autonomous
Remediability-Evidence: Adding one test per runtime inside existing test files is self-contained and needs no external system or decision.

- Policy: Scenario Completeness requires negative flows for invalid inputs (`.claude/rules/general-unit-test.md`).
- Observation: `scripts/dev_tools/_blast_radius_combination.py:245-246` raises `ValueError("combination item keys must be distinct: ...")`; line 246 is the only uncovered line (`artifacts/python/lcov.info`: `DA:246,0`). `.claude/lib/blast-radius/BlastRadiusCombination.psm1:95-96` throws the same message; no Pester row exercises it (instruction coverage 134/135). Neither `tests/scripts/dev_tools/test_blast_radius_combination.py` nor `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` references the error.
- Expected behavior: both runtimes have a test asserting that two items with the same key are rejected with an error containing `must be distinct`.
- Fix:
  1. Add `test_find_combinations_rejects_a_repeated_item_key` to `tests/scripts/dev_tools/test_blast_radius_combination.py` using `pytest.raises(ValueError, match="must be distinct")` with a config whose `tolerance_percent` is nonzero.
  2. Add a matching `It` to `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` that calls `Get-BlastRadiusCombination` with two items sharing one key and asserts `Should -Throw` with the pattern `*must be distinct*`.
  3. Run the seven-stage loop for Python and PowerShell on the touched files; no production file changes and no bundle copy changes are expected.
- Verification: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_combination.py --cov=scripts.dev_tools._blast_radius_combination --cov-branch` shows 100% line coverage for the module; the Pester file passes on PowerShell 7.

## Non-Blocking Items (do not remediate in this cycle unless trivially adjacent)

- AC-14, US-05, and traceability T-4 remain unchecked pending the CI bats lane `shell-coverage / Shell Coverage (Bats + kcov)`; they are checked off at S9 per the CI-dependent criteria rule.
- Recommended while running F-1: also write the post-change Pester coverage to `artifacts/pester/powershell-coverage.xml`, so a later review session can inspect the canonical path.

## Do Not Do

- Do not change production logic in `_blast_radius_*.py` or `BlastRadius*.psm1`; F-2 is test-only.
- Do not add coverage exclusions, lower thresholds, or edit `jest.config.cjs` thresholds.
- Do not edit policy files under `.claude/rules/` or `.github/instructions/`.
- Do not write evidence outside `<feature>/evidence/<kind>/`.
- Do not create temporary files in tests.
- Do not check off AC-14, US-05, or T-4 during remediation.
