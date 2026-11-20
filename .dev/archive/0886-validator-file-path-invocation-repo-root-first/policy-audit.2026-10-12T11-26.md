# Policy Audit (issue #886, minor-audit)

- Branch: bug/validator-file-path-invocation-repo-root-first-886
- Reviewed HEAD: d2135d5fed681b273bd04e8b76bc3f4f5dbb11d6
- Base: origin/main (three-dot diff, 43 files)
- Work mode: minor-audit (AC source: `## Acceptance Criteria` in issue.md)

## Rejected Scope Narrowing

None. The caller prompt requested the full change set relative to origin/main; no narrowing was attempted.

## Language Coverage Scope

Changed languages: Python only (one production file, one test file). Markdown changes are policy-rule text (two byte-identical rule files) and feature documentation. No TypeScript, PowerShell, or C# files changed.

## Findings

| Policy | Verdict | Evidence |
|---|---|---|
| No suppression added | PASS | Added-line diff has no `noqa`, `type: ignore`, `pyright: ignore`; `git grep` for `noqa\|E402` returns no match in the production file, test file, or pyproject.toml; pyproject.toml is unchanged. Bootstrap uses a slice-prepend statement, so Ruff E402 does not apply (evidence/qa-gates/suppression-*.md, ruff-e402-*.md). |
| File size <= 500 lines | PASS | Verified with `wc -l`: production 498, test 295. |
| Coverage, Python (repo module scope) | PASS | coverage-final-886.json parsed independently: 146/149 statements = 97.99% line; 52/56 branches = 92.86% branch. Thresholds 85% / 75% met. Changed line 17 is not in `missing_lines` ([409, 411, 413]); delta versus baseline is 0.00. |
| Coverage artifact path | PASS (note) | The task-specific JSON under evidence/qa-gates is the module-scoped artifact; `artifacts/python/lcov.info` is an untracked side effect and was not staged (no `artifacts/` path in the branch diff). Repo-wide Python lcov was not recomputed (no rerun per procedure); the module under change meets thresholds. |
| No temporary files in tests | PASS | No `tmp_path`, `tempfile`, or `NamedTemporaryFile` in the test file. The foreign package is served by an in-memory `PathEntryFinder` registered through `monkeypatch.setitem` on `sys.path_importer_cache`; no child process. |
| Test location mirrors source | PASS | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` mirrors `scripts/dev_tools/`. |
| Determinism / banned APIs | PASS | No clock, sleep, or randomness; `sys.path` and module state restored by `isolated_import_state`. Independent run: `6 passed`. |
| Toolchain (Black, Ruff, Pyright, Pytest) | PASS | Recorded evidence: Black unchanged, Ruff clean, Pyright 0 errors, 198 passed. Reviewer re-ran the invocation test file: 6 passed. |
| Tonality | PASS | Diff text and evidence use neutral, factual phrasing. |
| Policy-file edits (scope addition) | PASS | The `.claude/rules/orchestrator-state.md` sentence and its bundled mirror were edited with documented operator approval (issue.md "Operator-approved scope addition" paragraph; evidence/other/operator-approval-rule-sentence-886.*.md). Both files are byte-identical (`cmp` verified); the diff is one sentence at line 204 only ("appends it to" to "inserts it first in"). Treated as a documented scope addition, not a violation. |
| Evidence location compliance | PASS | `validate_evidence_locations.py --root .` exits 0; no `artifacts/` path in the branch diff; all evidence under `<FEATURE>/evidence/<kind>/`. |
| Evidence artifact schema fields | PARTIAL (non-blocking) | 34 of 35 markdown artifacts carry `Timestamp`; `EXIT_CODE` is present in 33; a non-empty single-line `Command` is present in 31. Gaps: `baseline/phase0-instructions-read.md` has no `Command` or `EXIT_CODE` (documentation record, not a gate); `baseline/git-baseline-886.*.md` and `baseline/issue-ac-source-886.*.md` declare `Command:` with an empty value and list commands on following lines, so the first-occurrence parser reads an empty command. Recommend a single-line `Command:` value for these three. |
| Evidence Checklist in issue.md | PARTIAL (non-blocking) | The `## Evidence Checklist` boxes (baseline, targeted verification, end-state) remain unchecked although the evidence exists. These are not acceptance criteria and do not affect AC status. |

## Evidence Location Compliance

No violations. Scan exit code 0; zero `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` paths in the branch diff.

## Remediation Triggers

None blocking.

Verdict: PASS (2 non-blocking PARTIAL items: evidence-schema gaps in three baseline artifacts; unchecked Evidence Checklist boxes)
