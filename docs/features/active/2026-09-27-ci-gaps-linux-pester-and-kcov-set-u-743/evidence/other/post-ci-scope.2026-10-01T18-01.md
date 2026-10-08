# Post-CI Scope (P7-T25)

Timestamp: 2026-10-01T18-01
CI_SHA: ecba8829604f6265dc491c74cf42546f9d5aab57

Command: git diff --name-only ecba8829604f6265dc491c74cf42546f9d5aab57
EXIT_CODE: 0
Output Summary: five tracked paths, all under `<FEATURE>/`: `evidence/qa-gates/qc-loop-pass.2026-10-01T17-23.md`, `evidence/qa-gates/qc-ps-analyze.2026-10-01T17-15.md`, `evidence/qa-gates/qc-ps-format.2026-10-01T17-14.md` (CI citations filled in after the final run), `plan.2026-09-30T03-15.md` (check marks and Execution Deviations), and `spec.md` (AC check-offs).

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: the five modified paths above plus untracked evidence files written after P7-T15, all under `<FEATURE>/` (`evidence/other/ac-evidence-index.2026-10-01T18-00.md`, `evidence/other/commit-push-final.2026-10-01T17-46.md`, `evidence/qa-gates/ci-final-*.md`, `coverage-comparison`, the closed AC-10 inventory, `no-unconditional-skip`, `qc-ps-pester-full`, `scope-check`, `scope-forbidden-paths`) and this file. No `tools/actionlint/` entry (actionlint is on PATH).

These files are committed by the commit/PR stage in a commit restricted to `<FEATURE>/`. CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57 identifies the code verified in P7-T17 to P7-T20; no file outside `<FEATURE>/` has changed since CI_SHA.
