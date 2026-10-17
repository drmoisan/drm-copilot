# Preflight Validation (Round 2) - Plan plan.2026-09-29T21-55.md (Issue #739)

Timestamp: 2026-09-29T22-55
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY, round 2)
Plan: docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md (Version 1.1)
Prior round: docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/other/preflight.2026-09-29T22-40.md
Signal: PREFLIGHT: ALL CLEAR
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Defects

none

## Round 1 deltas verified

- D1 (P1-T4): the summary text now carries "(the summary may wrap onto a second line; every line stays within 88 characters)". `pyproject.toml` `[tool.ruff.lint] select` is `E, F, I, B, UP, S, TID, TCH`; no `D` (pydocstyle) rule is selected, so a two-line summary raises no D205/D400 finding, and no plan command asserts the summary text. Closes the E501 finding.
- D2a (Phase 1 constraints, plan line 88): one-line docstrings for tests added or rewritten; helper docstrings bounded to a summary line, at most four description lines, `Args:`, and `Returns:`. The P1-T8 and P1-T11 content requirements each fit within four description lines at 4-space indentation. The bound applies to added helpers only, so it does not conflict with P1-T4, which edits the existing `find_npm_token_references`.
- D2b (P1-T19): an over-500 result is resolved in the same file by shortening description paragraphs of helpers added by this plan, then rerunning P1-T17 through P1-T19; no test case is removed. Consistent with D2a. Round 1 prototype measured 487 lines after Black.

## Specific check requested: P1-T16 assertion message

- The plan specifies "a message of the form" the quoted f-string, which permits implicit concatenation of adjacent literals. The current module already uses that construction at lines 239-242 and 260-263 and passes Ruff and Black. Split as `f"{family_label} found; npm publishing uses OIDC trusted "` / `f"publishing and needs no token: {offenders}"` at 8-space indentation, the longest line is about 68 characters. Ruff does not select `ISC`, and Black does not join string literals. Satisfiable.

## Whole-plan re-check (no new defect)

- Validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0; only the G4 warnings on P0-T12 and P2-T5 (assessed in round 1 as not defects).
- Structure: three phases; IDs P0-T1..T19, P1-T1..T22, P2-T1..T27 sequential; all evidence paths under `<FEATURE>/evidence/{baseline,regression-testing,other,qa-gates}/`; Phase 2 command tasks unconditional.
- Traceability: AC1-AC12 in `issue.md` each map to implementation, verification, evidence, and a check-off task (P2-T16..P2-T27).
- Counts: P1-T17/P2-T4/P2-T10 total 52 = 9+6+2+3+7+6+7+6+1+1+4. P1-T4 `_NPM_TOKEN_CONTEXT_REFERENCE` count 2 (definition plus the P1-T3 call site).
- Runbook: step 2 is the single line 136 under `### Recording completion`; the replacement text contains `human-action-pending.2026-09-27T09-19.md`, `(spec decision D5)`, and `Do not change acceptance criterion AC4`, and contains neither `features/active` nor `issue.md`, so P1-T21 expects `1 1 1 0 0` and P2-T12 expects one numstat line `1 1 <path>`.
- Observation (non-blocking): P1-T22 prose refers to "five routes" while the module docstring names four families; this is descriptive text in an exception dossier and no acceptance condition depends on it.
