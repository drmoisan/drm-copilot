# RT-3 CI Run and Shell-Coverage Artifact (OI-2, orchestrator-provided)

Timestamp: 2026-10-11T05-11
Command: gh run view 38112992719 --json status,conclusion,headSha,jobs (polled until status completed); gh run download 38112992719 -n shell-coverage -D artifacts/pester/kcov
EXIT_CODE: 0
RunId: 38112992719
HeadSha: d1211a7aebefe9648e16542919027587544ee153
RunStatus: completed (conclusion: success)
ShellCoverageJob: shell-coverage / Shell Coverage (Bats + kcov)
ShellCoverageJobConclusion: success
DownloadedFiles: artifacts/pester/kcov/cov.xml, artifacts/pester/kcov/index.html, artifacts/pester/kcov/index.js, artifacts/pester/kcov/amber.png, artifacts/pester/kcov/bcov.css, artifacts/pester/kcov/glass.png, artifacts/pester/kcov/data/**, artifacts/pester/kcov/kcov-merged/** (126 files total)
Output Summary: ci.yml dispatched via workflow_dispatch on chore/epic-852-main-sync-852 at d1211a7ae completed with conclusion success; all 17 jobs success. The shell-coverage artifact was downloaded after the shell-coverage job had completed with success (the artifact is uploaded by that job and is immutable after upload); the run status was confirmed completed afterwards. cov.xml line 3 root element reports line-rate="0.945" (lines-covered 3049 of lines-valid 3225).

## Run job conclusions

- shell-coverage / Shell Coverage (Bats + kcov) = success
- docs-validation / Documentation Validation = success
- NPM Audit Gate / npm audit (extensions/drm-copilot) = success
- quality-checks7 / Code Quality & Tests (3.10, 3.11, 3.12, 3.13) = success
- poshqc / PowerShell hook suites (Linux) = success
- poshqc / PowerShell QC = success
- security-scan / Security Scanning = success
- build-check / Build Package = success
- NPM Audit Gate / npm audit (packages/mcp-server) = success
- NPM Audit Gate / npm audit (.) = success
- root-typescript-tests / Root TypeScript Tests (windows-latest, ubuntu-latest) = success
- drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest, windows-latest) = success
