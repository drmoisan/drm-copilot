# QA Gate: CI Check Conclusions for the PR Head (P6-T12)

Timestamp: 2026-11-03T21-24
Command: gh pr checks 1063 --json name,bucket; gh run list --workflow ci.yml --branch feature/docs-profile-and-artifact-schemas-1020-r2 --json databaseId,headSha,conclusion,event
EXIT_CODE: 0
Output Summary: ci.yml pull_request run 41718630582 on head 15dc7bbb0d6190399d0f5dc0fa22fa40e6cc3b2a concluded success. All 25 reported checks pass, including every one of the 20 contexts of ruleset 15241672.

## Run

- Workflow: `.github/workflows/ci.yml` (event `pull_request`, PR #1063 into `epic/documentation-estate-tooling-integration`)
- Run identifier: 41718630582
- Head commit: 15dc7bbb0d6190399d0f5dc0fa22fa40e6cc3b2a

## Conclusions Asserted by P6-T12

| Check | Conclusion |
|---|---|
| CI full run | success |
| poshqc / PowerShell QC | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |

## Other Checks on the Head

All pass: Change scope; build-check / Build Package; docs-validation / Documentation Validation; drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) and (windows-latest); Extension Tests (ubuntu-latest) and (windows-latest); NPM Audit Gate / npm audit (.), (extensions/drm-copilot), and (packages/mcp-server); poshqc / PowerShell QC shard 1, shard 2, shard 3; poshqc / PowerShell QC static; poshqc / PowerShell hook suites (Linux); Publish to Marketplace; root-typescript-tests / Root TypeScript Tests (ubuntu-latest) and (windows-latest); security-scan / Security Scanning; shell-coverage / Shell Coverage (Bats + kcov).

## Disposition of P6-T6

The local single-process `tests/scripts` run on the Linux Codespace host failed pre-existing tests that also fail on the unchanged merge base on the same host (`evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`). The CI-shape run of the same scan folders on `windows-latest` (the three `poshqc / PowerShell QC` shards, aggregated and completeness-checked by `poshqc / PowerShell QC`) passed with zero failures in run 41718630582. P6-T6 is checked off on this evidence.
