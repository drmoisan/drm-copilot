# P5-T2 PA-N3 Commit Confirmation (issue #927, AC-13)

Timestamp: 2026-10-16T04-02
Command: git cat-file -t ff1b7cbd4
EXIT_CODE: 0
Output Summary: Both commits exist locally (the gh api fallback was not needed). Committer times confirm C1 = 2026-10-13T11-17 UTC (ff1b7cbd4) and C2 = 2026-10-13T11-34 UTC (70e58ca84), the values Appendix P cites. Every Appendix P file with a commit dependency appears in its commit's file listing; no MEMBERSHIP_MISMATCH.

## Commands and results

- `git cat-file -t ff1b7cbd4` -> `commit` (EXIT 0)
- `git cat-file -t 70e58ca84` -> `commit` (EXIT 0)
- `git show -s --format=%cI ff1b7cbd4 70e58ca84` (EXIT 0):
  - `2026-10-13T07:17:24-04:00`
  - `2026-10-13T07:34:54-04:00`
- `git show --name-status --format=%H ff1b7cbd4 70e58ca84 -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence` (EXIT 0), verbatim below.

C1_COMMITTER_TIME: 2026-10-13T07:17:24-04:00
C1_UTC_MINUTE: 2026-10-13T11-17
C2_COMMITTER_TIME: 2026-10-13T07:34:54-04:00
C2_UTC_MINUTE: 2026-10-13T11-34

## File listing (verbatim)

```text
ff1b7cbd481c222d2f54485449d96ddbdefa396f

A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/remediation-baseline/p0-local-coverage-before.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/remediation-baseline/p0-repo-state.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/remediation-baseline/p1-direct-run-before.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/remediation-baseline/phase0-instructions-read.2026-10-12T19-50.md
70e58ca8401ce229a761c45d9cc49c04fb73997f

A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md
A	docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md
```

## Membership check (Appendix P commit-dependent rows)

- ff1b7cbd4: P1 p1-pester-junit, P3 p1-xml-regenerated, P5 p1-direct-xml-regenerated, P6 p1-pester-junit-direct, P7 local-powershell-coverage-direct, P8 p2-ac-state, P9 p2-scope-before-stage, P13 local-powershell-coverage -> all listed.
- 70e58ca84: P11 p1-pester-junit-direct-rerun, P12 local-powershell-coverage-direct-rerun -> both listed.

MEMBERSHIP_MISMATCH: none
