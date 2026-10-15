# Final QC: changed files and scope boundary

Timestamp: 2026-10-09T06-30
Command: git diff --name-only origin/main ; git status --porcelain
EXIT_CODE: 0
Output Summary: both commands exited 0. The union of printed paths contains .prettierignore. Every other printed path begins with docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/ or equals docs/features/potential/promoted/2026-10-08-root-format-check-fails-on-test-fixtures.md (committed by the preparation run). No production source, test, script, package manifest, lockfile, or fixture path appears.

## Diff against origin/main (committed state)

```
.prettierignore
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/evidence/baseline/ (8 artifacts)
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/evidence/qa-gates/prettierignore-no-cr.2026-10-09T06-15.md
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/evidence/qa-gates/prettierignore-token.2026-10-09T06-15.md
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/issue.md
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/plan.2026-10-09T01-32.md
docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/research/2026-10-09T05-40-root-prettier-fixture-exclusion.md
docs/features/potential/promoted/2026-10-08-root-format-check-fails-on-test-fixtures.md
```

## Porcelain status (uncommitted/untracked, all under the feature folder evidence directory)

```
?? .../evidence/qa-gates/fixtures-unchanged.2026-10-09T06-30.md
?? .../evidence/qa-gates/format-script-file-set.2026-10-09T06-30.md
?? .../evidence/qa-gates/manifests-unchanged.2026-10-09T06-30.md
?? .../evidence/qa-gates/root-format-check-no-fixture-lines.2026-10-09T06-30.md
?? .../evidence/qa-gates/root-format-check.2026-10-09T06-30.md
?? .../evidence/regression-testing/
```
