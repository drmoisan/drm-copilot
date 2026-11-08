# P6-T12 CI checks for the PR head (issue 1021)

Timestamp: 2026-11-04T01-28
Command: gh pr checks 1068 --json bucket,name,state,workflow; gh run list --branch feature/docs-page-quality-checker-1021-r2 --workflow ci.yml --limit 2 --json databaseId,headSha,conclusion,url,event; pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks> -HeadSha 4b4b4e07dee27a5a287c572720e23d489f911c54 -RequireWorkflow CI
EXIT_CODE: 0
Output Summary: ci.yml pull_request run 41752832137 (https://github.com/drmoisan/drm-copilot/actions/runs/41752832137) on head 4b4b4e07dee27a5a287c572720e23d489f911c54 concluded success. 25 checks on the PR head, all in bucket pass. The CI gate parser with -RequireWorkflow CI reported conclusion success.

- Pull request: #1068 into epic/documentation-estate-tooling-integration
- Head commit: 4b4b4e07dee27a5a287c572720e23d489f911c54
- Run identifier: 41752832137 (event pull_request)

| Check | Conclusion |
|---|---|
| CI full run | success |
| poshqc / PowerShell QC | success |
| poshqc / PowerShell QC static | success |
| poshqc / PowerShell QC shard 1 | success |
| poshqc / PowerShell QC shard 2 | success |
| poshqc / PowerShell QC shard 3 | success |
| poshqc / PowerShell hook suites (Linux) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| docs-validation / Documentation Validation | success |
| security-scan / Security Scanning | success |
| build-check / Build Package | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (.) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| Change scope | success |
| Publish to Marketplace | success |
| Extension Tests (ubuntu-latest) | success |
| Extension Tests (windows-latest) | success |

CI-dependent acceptance criteria checked off on this evidence: spec.md S20 (`poshqc / PowerShell QC` passes on the pull request head) and the CI part of user-story.md U10 (its coverage part was already verified in `qa-pester-coverage` and `coverage-delta`).
