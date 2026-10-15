# Closure dispositions correction for #846 (written under issue #903)

Timestamp: 2026-10-13T11-29

This note is written under issue #903 (#846 CR-7). It supersedes two rationale cells of `closure-dispositions.2026-10-09T09-00.md` in this folder without editing that file. The dispositions and evidence columns of both rows are unchanged; only the rationale text below replaces the prior text.

| Finding | Prior rationale (verbatim) | Corrected rationale |
| --- | --- | --- |
| #734 CR-1 | The duplicated QT-code helper was moved into a shared test-support module and the misnamed test was renamed. | The finding was the missing `-> None` annotation on `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` (source: `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/code-review.2026-10-02T03-55.md:34`). It was resolved by renaming the test to a shorter name so the annotation fits 88 columns. |
| #723 N3 | The workflow test exit assertions were tightened to `exit 1`; the local Pester run is pending CI under A7-CI. | The workflow test assertions were tightened to an exact count of one `exit 1` line plus an error-block match. The pending-CI clause is superseded by `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ci-evidence-pr873.2026-10-10T03-00.md`. |
