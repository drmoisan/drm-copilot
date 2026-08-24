# QA Gate: Acceptance Criteria Mapping

Timestamp: 2026-07-18T22-30

Source: `docs/features/active/2026-07-17-legacy-discovery-reports-368/user-story.md`
"## Acceptance Criteria" (8 items, work mode `full-feature`).

| # | Acceptance Criterion | Mapped Tasks | Evidence |
|---|---|---|---|
| AC-1 | A coverage report is rendered deterministically from a Coverage Ledger artifact. | P2-T1, P2-T2, P2-T3 | `scripts/dev_tools/discovery/coverage_report.py`; `tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries`, `::test_render_coverage_report_is_deterministic` |
| AC-2 | A parity report is rendered deterministically from a Parity Matrix artifact. | P3-T1, P3-T2, P3-T3 | `scripts/dev_tools/discovery/parity_report.py`; `tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries`, `::test_render_parity_report_is_deterministic` |
| AC-3 | A completion report presents aggregate readiness across the discovery artifacts. | P4-T1, P4-T2, P4-T3 | `scripts/dev_tools/discovery/completion_report.py`; `tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_readiness`, `::test_render_completion_report_is_deterministic` |
| AC-4 | Given identical input artifacts, report output is byte-identical across runs. | P1-T6, P2-T3, P3-T3, P4-T3 | `test_rendering.py::test_render_pretty_json_is_deterministic`; `test_coverage_report.py::test_render_coverage_report_is_deterministic`; `test_parity_report.py::test_render_parity_report_is_deterministic`; `test_completion_report.py::test_render_completion_report_is_deterministic` |
| AC-5 | Input artifacts are validated (via the validators) before rendering; a malformed artifact fails fast with a clear error and non-zero exit code. | P1-T3, P1-T4, P2-T4, P2-T6, P3-T4, P3-T6, P4-T4, P4-T6 | `scripts/dev_tools/discovery/io.py` (`ArtifactValidator`, `validate_or_raise`, `ArtifactValidationError`); `test_io.py`; `test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure`, `::test_main_returns_1_on_failure`; `test_parity_report.py` (same pattern); `test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build`, `::test_main_returns_1_when_either_validator_fails` |
| AC-6 | Report generation is exposed as `dev.discovery.*` Poetry console-script CLI entry point(s) following the repository substrate convention. | P2-T7, P3-T7, P4-T7 | `pyproject.toml` `[tool.poetry.scripts]`: `dev.discovery.coverage-report`, `dev.discovery.parity-report`, `dev.discovery.completion-report`; `poetry check` EXIT_CODE 0 |
| AC-7 | The reporting framework contains no domain-specific identifiers. | P5-T1 | `evidence/qa-gates/domain-neutrality-check.2026-07-18T22-05.md` (zero matches across this feature's own new files) |
| AC-8 | Tests satisfy quality-tier policy (line >= 85%, branch >= 75%). | P0-T5, P5-T5, P5-T6 | `evidence/baseline/py-test.2026-07-18T21-19.md`; `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`; `evidence/qa-gates/coverage-delta.2026-07-18T22-28.md` (final: 88.95% line, 79.60% branch, both thresholds met, no regression) |

All eight acceptance criteria are mapped to concrete implementation and/or test tasks and each
has been individually verified (see per-task check-off evidence in
`plan.2026-07-17T15-03.md` and the referenced evidence artifacts above).
