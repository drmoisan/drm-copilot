# Feature Audit: legacy-discovery-reports (#368)

**Audit Date:** 2026-07-18
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-reports-368`
**Base Branch:** `epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-reports-368` (`20c26abd85dd2a58b28d77578edd7bc2fc403f8c`)
**Work Mode:** `full-feature` (persisted marker `- Work Mode: full-feature` confirmed in `issue.md`)
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/legacy-discovery-and-parity-integration` (resolved
  `origin/epic/legacy-discovery-and-parity-integration @ 3a4985fa904da7b5925091b393f9551c874ab006`)
- **Head branch/commit:** `feature/legacy-discovery-reports-368` (`20c26abd85dd2a58b28d77578edd7bc2fc403f8c`)
- **Merge base:** `e395efb7cf55953a93088964f10edc4d9dede404`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated this session against the resolved
    base branch, since no artifact existed prior to this review)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (regenerated alongside the summary)
  - Feature evidence: `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/{baseline,qa-gates}/**`
  - Additional evidence: `artifacts/python/lcov.info` (raw coverage artifact, parsed directly);
    direct source inspection of `scripts/dev_tools/discovery/{io,rendering,coverage_report,parity_report,completion_report}.py`
    and their five mirrored test files; direct source inspection of
    `scripts/dev_tools/validate_discovery_schema_artifacts.py`; a live, independent CLI
    double-invocation of `coverage_report.main()` confirming byte-identical output.
- **Feature folder used:** `docs/features/active/2026-07-17-legacy-discovery-reports-368`
  (selected as the only active feature folder with material scoping-doc changes in this diff and
  matching the `-368` issue suffix in the branch name).
- **Requirements source:** `spec.md` and `user-story.md` (per `full-feature` work mode).
- **Work mode resolution note:** `issue.md` line 13 states `- Work Mode: full-feature` explicitly;
  no fail-closed inference was required.
- **Scope note:** No PR-context artifacts existed prior to this review; they were regenerated via
  `poetry run python -m scripts.dev_tools.pr_context.collector --base epic/legacy-discovery-and-parity-integration --head HEAD` before this audit began, per the `pr-context-artifacts` refresh rule. The full
  branch-vs-base diff (`git diff --stat` against the merge-base) was independently re-derived and
  used as the audit scope, not any plan/task/phase subset.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-17-legacy-discovery-reports-368/spec.md` — primary source (embedded
  in "Behavior" and cross-referenced by "Seeded Test Conditions"; the canonical 8-item checkbox
  list lives in `user-story.md`)
- `docs/features/active/2026-07-17-legacy-discovery-reports-368/user-story.md` — primary source
  (`## Acceptance Criteria`, 8 checkbox items)

Both files carry an identical 8-item acceptance-criteria list (verified by direct comparison);
`user-story.md` holds the canonical `## Acceptance Criteria` checkbox section, while `spec.md`
restates the same behavior narratively in "Behavior" and tracks it via its own "Definition of
Done" and "Seeded Test Conditions" checklists.

### Acceptance criteria (from `user-story.md` / `spec.md`)

1. A coverage report is rendered deterministically from a Coverage Ledger artifact.
2. A parity report is rendered deterministically from a Parity Matrix artifact.
3. A completion report presents aggregate readiness across the discovery artifacts.
4. Given identical input artifacts, report output is byte-identical across runs.
5. Input artifacts are validated (via the validators) before rendering; a malformed artifact fails
   fast with a clear error and non-zero exit code.
6. Report generation is exposed as `dev.discovery.*` Poetry console-script CLI entry point(s)
   following the repository substrate convention.
7. The reporting framework contains no domain-specific identifiers.
8. Tests satisfy quality-tier policy (line >= 85%, branch >= 75%).

All 8 items are already marked `- [x]` in both `spec.md` (embedded checklist context) and
`user-story.md` at the start of this audit.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Coverage report rendered deterministically from a Coverage Ledger artifact | PASS | `scripts/dev_tools/discovery/coverage_report.py` (`parse_coverage_ledger`, `build_coverage_rows`, `render_coverage_report`); `tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries`, `::test_render_coverage_report_is_deterministic` | `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -q` | Independently re-run: 7 passed. Also independently invoked `coverage_report.main()` twice via a scratch script with a fake passing validator against identical input; output files were byte-identical (`diff` reported no differences). |
| 2 | Parity report rendered deterministically from a Parity Matrix artifact | PASS | `scripts/dev_tools/discovery/parity_report.py` (mirrors `coverage_report.py`'s pipeline exactly, per its own module docstring); `tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries`, `::test_render_parity_report_is_deterministic` | `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -q` | Independently re-run: 7 passed. Source read in full; structurally identical to the coverage-report pipeline. |
| 3 | Completion report presents aggregate readiness across the discovery artifacts | PASS | `scripts/dev_tools/discovery/completion_report.py` (`build_completion_summary`, `render_completion_report`); `tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_readiness` | `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -q` | Independently re-run: 7 passed. The v1 "readiness" signal is deliberately scoped to "both artifacts validated" per `spec.md` "Completion-report scope risk," which the criterion's plain wording ("presents aggregate readiness") is satisfied by; no over-claim of a richer readiness computation exists in the code or its docs. |
| 4 | Given identical input artifacts, report output is byte-identical across runs | PASS | `test_rendering.py::test_render_pretty_json_is_deterministic`; `test_coverage_report.py::test_render_coverage_report_is_deterministic`; `test_parity_report.py::test_render_parity_report_is_deterministic`; `test_completion_report.py::test_render_completion_report_is_deterministic`; direct grep confirming no `datetime`/`time.*`/`random`/`uuid` usage in any of the five new production modules | `grep -n "datetime\|time\.\|random\|uuid" scripts/dev_tools/discovery/*.py` (zero functional matches, only docstring prose) | This audit additionally performed a live end-to-end verification: invoked `coverage_report.main()` twice against an identical on-disk artifact with an injected passing validator, writing to two separate output files, and confirmed via `diff` that the two output files were byte-for-byte identical. |
| 5 | Malformed artifact fails fast with a clear error and non-zero exit code, validated before rendering | PASS | `scripts/dev_tools/discovery/io.py` (`ArtifactValidator`, `validate_or_raise`, `ArtifactValidationError`); every report module's `main()` calls `validate_or_raise` before any `parse_*`/`build_*`/`render_*` call; `test_io.py`; `test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure`, `::test_main_returns_1_on_failure`; `test_parity_report.py` (same pattern); `test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build`, `::test_main_returns_1_when_either_validator_fails` | `poetry run pytest tests/scripts/dev_tools/discovery/test_io.py -q` | Independently re-run: 4 passed. Confirmed by direct code inspection that `write_report`/`build_completion_summary` are never reachable on the validation-failure path (structurally enforced by early `return 1`, and explicitly asserted via `write_calls == []`/`build_calls == []` in the tests). |
| 6 | `dev.discovery.*` Poetry console-script CLI entry point(s) exposed | PASS | `pyproject.toml` `[tool.poetry.scripts]`: `"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"`, `"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"`, `"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"` | `git diff e395efb7c..20c26abd8 -- pyproject.toml` | Confirmed via direct diff inspection: exactly three new entries added, no existing entries modified. Each target module exposes `def main(argv: Sequence[str] | None = None) -> int` with an `argparse`-based `parse_args`, matching `spec.md` "API / CLI Surface". |
| 7 | The reporting framework contains no domain-specific identifiers | PASS | `evidence/qa-gates/domain-neutrality-check.2026-07-18T22-05.md` | `grep -inE "taskmaster\|\btmw\b\|outlook\|vsto\|task-management" scripts/dev_tools/discovery/{completion_report,coverage_report,parity_report,rendering,io}.py tests/scripts/dev_tools/discovery/test_{completion_report,coverage_report,parity_report,io,rendering}.py` | Independently re-run during this audit: zero matches (exit code 1, ripgrep's "no match" code). The evidence file's own claim of a directory-wide false-positive (matches in an unrelated, already-merged sibling feature's disallow-list test fixtures) was independently cross-checked and confirmed accurate — those matches belong to `test_domain_profile.py`/`test_domain_neutrality.py`, files this feature did not create or modify. |
| 8 | Tests satisfy quality-tier policy (line >= 85%, branch >= 75%) | PASS | `evidence/baseline/py-test.2026-07-18T21-19.md`; `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`; `evidence/qa-gates/coverage-delta.2026-07-18T22-28.md` | Direct parse of `artifacts/python/lcov.info` during this audit | Independently recomputed from the raw coverage artifact: repo-wide 88.95% line / 79.60% branch (both above the uniform 85%/75% floor); every one of the five new production modules independently measured at >= 92% line / 100% branch, exceeding the 90% new-file bar this review applies. No regression versus the 88.87%/79.51% baseline. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None.

**Recommended follow-up verification steps:**

1. Once `legacy-discovery-schemas` (#9002) and the validator module's field-level shape stabilize
   further, consider an integration-style test exercising the real lazy-imported
   `_default_coverage_ledger_validator`/`_default_parity_matrix_validator` binding end-to-end
   (currently verified only by direct source inspection and a clean Pyright run, per
   `code-review.2026-07-18T23-05.md` Findings Table Minor #2).
2. Correct the `completion_report.py` docstring citation from `spec.md` to
   `plan.2026-07-17T15-03.md` "Open Questions / Notes" for the CLI flag-naming-deviation note (per
   `code-review.2026-07-18T23-05.md` Findings Table Minor #1). Non-blocking.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- All 8 criteria evaluated PASS above.
- Both authoritative source files (`spec.md`'s embedded checklist context and `user-story.md`'s
  `## Acceptance Criteria` section) already had all 8 items marked `- [x]` before this audit began.
  This audit independently re-verified each item against primary evidence (direct source
  inspection, re-run tests, raw coverage-artifact parsing, and a live CLI double-invocation) and
  confirms every existing check-off is justified; no unchecked item required checking off, and no
  previously-checked item is disputed by this audit.

### AC Status Summary

- Source: `docs/features/active/2026-07-17-legacy-discovery-reports-368/spec.md`,
  `docs/features/active/2026-07-17-legacy-discovery-reports-368/user-story.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed, canonical `## Acceptance Criteria` section; all items were already checked and independently re-verified by this audit. |
| `spec.md` | 8 | 8 | 0 | Checkbox-backed (mirrors `user-story.md`'s 8 items in embedded context); all items were already checked and independently re-verified by this audit. |

No source-file checkbox change was made by this audit — all 8 acceptance criteria were already
checked off in both authoritative source files prior to this review, and this audit's independent
verification confirms each check-off is evidence-backed rather than premature.
