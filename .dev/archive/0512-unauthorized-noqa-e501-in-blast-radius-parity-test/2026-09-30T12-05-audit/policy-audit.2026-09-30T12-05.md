# Policy Audit (Issue #512)

- Timestamp: 2026-09-30T12-05
- Branch: bug/unauthorized-noqa-e501-in-blast-radius-parity-test-512
- Base: main (`git diff origin/main`)
- Work mode: full-bug (AC source: `spec.md`)
- Blocking count: 1

## Scope

Branch diff against `origin/main`: 36 files. One non-documentation file: `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (1 line added, 1 line deleted). All other paths are under `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/`. Verified with `git diff origin/main --name-only`.

The PR context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) are absent from this worktree. The audit used `git diff origin/main` directly, which is the same baseline diff.

## Rejected Scope Narrowing

None. The caller prompt described the change as a single-file rename but did not narrow scope, skip a toolchain check, or exclude a language.

## Policy Verdicts

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 1 | Tone (`.claude/rules/tonality.md`) | PASS | Feature documents use factual wording; no humor or hyperbole found on read-through. |
| 2 | Python suppression policy (`.claude/rules/python-suppressions.md`) | PASS | `grep -rn noqa` on the target file exits 1 (no match). The change removes the only unauthorized `# noqa: E501`; no suppression is added. E501 is not in the pre-authorized list. |
| 3 | Format (Black) | PASS | `black --check` on target: "1 file would be left unchanged." (re-run by reviewer). |
| 4 | Lint (Ruff) | PASS | `ruff check` on target: "All checks passed!" (re-run by reviewer). |
| 5 | Type check (Pyright) | PASS | Evidence `final-pyright.2026-09-29T15-16.md` and independent re-verification record 0 errors. Not re-run by reviewer; test-only rename. |
| 6 | Unit tests | PASS | `pytest --collect-only` re-run by reviewer: 20 tests collected, equal to baseline. Independent re-verification records 20 passed. |
| 7 | File size limit (500 lines) | PASS | Target file 499 lines before and after (`file-line-count-after` artifact; the rename adds no lines). |
| 8 | Test file location | PASS | Test remains under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. No file moved. |
| 9 | No temporary files / banned test APIs | PASS | Test body unchanged (numstat 1/1, header line only). |
| 10 | Policy files unmodified | PASS | No path under `.claude/rules/` or `.github/` in the diff. |
| 11 | No `pyproject.toml` / production change | PASS | Diff name list contains no production or configuration path. |
| 12 | Coverage exclusion policy | PASS | No `exclude`/`omit` entry changed. |
| 13 | Evidence location compliance | PASS | See below. |
| 14 | Coverage: Python | FAIL | See Coverage Verification. |

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exit code 0.
- `git diff origin/main --name-only -- artifacts` returned no paths.
- All 27 evidence files are under `evidence/baseline/`, `evidence/regression-testing/`, or `evidence/qa-gates/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.
- Verdict: PASS.

## Coverage Verification

Changed language: Python (one test file). No TypeScript, PowerShell, or C# file changed.

- Changed file `tests/scripts/dev_tools/test_blast_radius_config_parity.py` is a test file, excluded from measurement by project configuration (`omit = ["tests/*", ...]`). It has no per-file coverage row. Changed-line regression: none possible; the changed line is a `def` header.
- Coverage artifact: `artifacts/python/lcov.info` exists (untracked, produced 2026-09-30 07:45 by the executing run's targeted pytest invocation). It contains one source record: `scripts\dev_tools\compute_blast_radius.py`.
- Parsed values: `LF:80 LH:56` = 70.0% line; `BRF:14 BRH:3` = 21.43% branch.
- Repo-wide thresholds (line >= 85%, branch >= 75%) are not met by the only available artifact. The artifact is a one-module slice from a single test file, not a full-suite run, so it cannot demonstrate repo-wide compliance either way. The verification procedure requires a FAIL when the parsed repo-wide value is below threshold and forbids rerunning coverage generation.
- No regression: baseline and final coverage rows are identical (Stmts 80, Miss 24, Branch 14, BrPart 3, Cover 63%). The production module is not changed by this branch.
- Verdict: FAIL (Blocking, evidence gap). Nature: the feature does not degrade coverage, but a repo-wide artifact supporting the >= 85% / >= 75% thresholds is not present. The plan text (P0-T10) states the single-file slice "is not expected to meet" the thresholds; that statement does not override the review procedure.
- Additional finding (Major): `evidence/qa-gates/coverage-comparison.2026-09-29T15-16.md` and the baseline derive branch coverage as `(Branch - BrPart) / Branch` = 78.57%. `BrPart` counts partially covered branches, not missed branches. The lcov record gives 3 of 14 branches hit (21.43%), consistent with the printed combined Cover of 63% = (56 + 3) / (80 + 14). The 78.57% figure is incorrect; the no-regression conclusion is unaffected because both rows are identical.

## Additional Observations (non-blocking)

- Evidence file names carry the plan timestamp `2026-09-29T15-16`, while the in-file `Timestamp:` fields were corrected to commit times `2026-09-30T11-20` and `2026-09-30T11-27` (commit 49f1a69a). These are documented upper bounds, not measured creation times. The name/field mismatch is documented in `independent-reverification.2026-09-30T11-55.md`. Severity: Minor.
- `spec.md` and `plan.2026-09-29T15-16.md` still show `Status: Draft` and `Last Updated: 2026-09-29T15-16` after execution and AC check-off. Severity: Minor.
- Test Strategy in `spec.md` (lines 181-182) says "17 tests"; all evidence and the reviewer re-run show 20 collected. Severity: Minor (documentation inconsistency; AC5 correctly requires equality with the pre-change count).
- Three `# noqa: E501` precedents remain (follow-up (b)); recorded as out of scope pending user decision. Not a finding against this branch.

## Summary

- PASS: 13; FAIL: 1 (Python repo-wide coverage artifact); Blocking: 1.
