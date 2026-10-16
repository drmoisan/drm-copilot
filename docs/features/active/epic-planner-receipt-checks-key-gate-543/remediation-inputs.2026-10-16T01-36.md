# Remediation Inputs (Issue #543)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-16T01-36
**Feature folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Base branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Head audited:** `bug/epic-planner-receipt-checks-key-gate-543` @ `5e338716153fcf29c2d9e3c3ba23d16906220cd4`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** initial review
**Blocking finding count:** 1

## Audit Artifacts

- `docs/features/active/epic-planner-receipt-checks-key-gate-543/policy-audit.2026-10-16T01-36.md` (Section 8: PA-1 FAIL; PA-N1 to PA-N3 non-blocking)
- `docs/features/active/epic-planner-receipt-checks-key-gate-543/code-review.2026-10-16T01-36.md` (Findings Table: CR-1 Blocker, the same finding as PA-1; CR-2 to CR-5 non-blocking)
- `docs/features/active/epic-planner-receipt-checks-key-gate-543/feature-audit.2026-10-16T01-36.md` (17 PASS, 0 PARTIAL, 1 UNVERIFIED (AC18, pending CI), 0 FAIL)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8, clause "coverage artifact absent for any language that has changed files". TypeScript has three changed files (one production, two test) and no `lcov.info` exists. No production-code or test defect was found; the reviewer's re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (68 passed), and targeted Jest (68 passed) at `5e3387161` were clean.

## Findings

### R1 - TypeScript coverage artifact absent (PA-1, CR-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is to run the repository's existing coverage script, which writes the artifact locally; it needs no external system, policy change, CI run, or human decision, and no source edit is expected.

**Problem.** Coverage verification is mandatory for every language with changed files and is performed from the coverage artifact (`coverage/lcov.info` for TypeScript; the extension's jest config writes it to `extensions/drm-copilot/coverage/lcov.info`). Neither path exists. `find . -name lcov.info -not -path "*/node_modules/*"` returns only `./artifacts/python/lcov.info`. The final TypeScript coverage run (`evidence/qa-gates/final-typescript-test-coverage.2026-10-16T01-13.md`) used `--coverageReporters=text --coverageReporters=text-summary`, which replaces the `lcov` reporter configured at `extensions/drm-copilot/jest.config.cjs` line 18 (`coverageReporters: ["lcov", "text-summary"]`). The recorded text figures (file 98.36% lines / 94.06% branches; repo-wide 97.26% / 92.29%) indicate the thresholds are met, but they are not artifact-verified.

**Required change.**

1. From the worktree root, run `npm --prefix extensions/drm-copilot run test:coverage` (script: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`). Expect exit 0 and 4009 passing tests.
2. Confirm `extensions/drm-copilot/coverage/lcov.info` exists and contains an `SF:` record for `src/lib/validate/epic-planner-state-core.ts` (path separators may be backslashes on Windows).
3. From the artifact, compute and record: repo-wide line and branch coverage (sum of `LH`/`LF` and `BRH`/`BRF`), and per-file line and branch coverage for `epic-planner-state-core.ts`. Confirm line >= 85% and branch >= 75% for both, and confirm no added line from the diff hunks (291-296, 299, 335-336, 338-341, 343, 345, 348-360, 363-370, 433-436, 450-452) has `DA:<line>,0`.
4. Write the result to `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/qa-gates/typescript-lcov-coverage.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and the numeric figures. Do not write anything under `artifacts/coverage/` or `artifacts/qa/`.
5. Do not commit `lcov.info` itself unless the repository already tracks it; the artifact must exist in the worktree for re-audit.

**Optional, same step (non-blocking PA-N2 / CR-2).** Run the Python coverage over the repository's Python sources (for example `poetry run pytest --cov=scripts --cov-branch --cov-report=lcov:artifacts/python/lcov.info --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`) so `artifacts/python/lcov.info` carries a repository-wide figure, and record it in the same evidence file. Check `pyproject.toml` for the configured coverage options before choosing flags.

**Verification commands.**

```bash
# from the worktree root
npm --prefix extensions/drm-copilot run test:coverage
ls extensions/drm-copilot/coverage/lcov.info
grep -n "epic-planner-state-core.ts" extensions/drm-copilot/coverage/lcov.info
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect exit 0 for each
```

## Do Not Do

- Do not change production or test code; no defect was found in either.
- Do not add coverage `exclude` entries or lower any threshold.
- Do not edit `extensions/drm-copilot/jest.config.cjs` (AC13 requires it unchanged).
- Do not check off AC18; it is checked off at S9 after CI succeeds on the final PR head.
- Do not edit policy documents under `.claude/rules/` or `.github/instructions/`.

## Non-blocking Findings (no remediation required)

| ID | Severity | Same files / feature as this change | Summary |
|---|---|---|---|
| PA-N1 | Info | Same feature | AC18 (PR closes #543, CI success on final head) is pending CI and is checked off at S9. |
| PA-N2 / CR-2 | Minor | Same feature (coverage evidence); not a source file | `artifacts/python/lcov.info` covers only `validate_epic_planner_state.py`, so it has no repository-wide Python figure. The changed file passes (92.55% / 86.00%). |
| PA-N3 / CR-3 | Nit | Same file (`epic-planner-state-core.ts`) | The call site passes `requireLaunchPaths` as `keyGated`; the variable now gates more than launch paths, and the function takes a positional boolean while the sibling call uses an options object. The spec mandated this form. |
| CR-4 | Info | Same file (`epic-planner-state-core.ts`) | The file is at 488 of 500 lines; plan a module split before the next addition. |
| CR-5 | Info | Same files (both validators), pre-existing code not changed by this branch | `_extract_features` / `extractFeatures` drop non-object entries before the ready gate enumerates, so ready-gate error indices are compacted when a non-object entry precedes. Error-message accuracy only. |

## Exit Gate

Re-audit (policy-audit, code-review, feature-audit) with zero blocking findings: `extensions/drm-copilot/coverage/lcov.info` present and its figures recorded under `evidence/qa-gates/`, with line >= 85% and branch >= 75% for `epic-planner-state-core.ts` and repo-wide TypeScript. AC1 to AC17 remain checked; AC18 remains pending CI.
