# OI-2 RT-3 Input Check

Timestamp: 2026-10-11T01-17
Task: [P0-T4]
Command: Read docs/features/active/epic-852-main-sync/evidence/other/rt3-ci-run.md; Glob artifacts/pester/kcov/cov.xml; Glob artifacts/pester/kcov/**/cov.xml
EXIT_CODE: 0

Field check of `evidence/other/rt3-ci-run.md`:

| Field | Present | Value |
|---|---|---|
| Timestamp | yes | 2026-10-11T05-11 |
| Command | yes | both gh commands (view, download) |
| EXIT_CODE | yes | 0 |
| RunId | yes | 38112992719 |
| HeadSha | yes | d1211a7aebefe9648e16542919027587544ee153 (40 characters) |
| RunStatus | yes | completed (conclusion: success) |
| ShellCoverageJob | yes | shell-coverage / Shell Coverage (Bats + kcov) |
| ShellCoverageJobConclusion | yes | success |
| DownloadedFiles | yes | paths under artifacts/pester/kcov/ |
| Output Summary | yes | present |

cov.xml candidates: `artifacts/pester/kcov/cov.xml`, `artifacts/pester/kcov/kcov-merged/cov.xml`.

Resolved cov.xml path: `artifacts/pester/kcov/cov.xml` (top-level preferred).

Output Summary: OI-2 provided; input record complete with RunStatus completed and a 40-character HeadSha; cov.xml resolved to artifacts/pester/kcov/cov.xml.
