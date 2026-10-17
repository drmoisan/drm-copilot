# AC-3 PR CI Evidence (PR #865)

Timestamp: 2026-10-09T09-40
Command: gh pr checks 865 --repo drmoisan/drm-copilot --json name,state --jq '{total: length, non_success: [.[]|select(.state!="SUCCESS")|.name]}'
EXIT_CODE: 0
Output Summary: {"non_success":[],"total":23}. All 23 checks on head 16ad96ee7758f99770bddf975ff9c1b24782fa6c concluded SUCCESS, including Publish to Marketplace, both NPM Audit Gate and npm-audit matrices (., extensions/drm-copilot, packages/mcp-server), root and extension TypeScript tests on ubuntu and windows, quality-checks7 (3.10-3.13), poshqc, shell-coverage, security-scan, build-check, and docs-validation. mergeStateStatus: CLEAN.

## Full check list (head 16ad96ee)

| Check | Result |
|---|---|
| Extension Tests (ubuntu-latest) | pass |
| Extension Tests (windows-latest) | pass |
| NPM Audit Gate / npm audit (.) | pass |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | pass |
| NPM Audit Gate / npm audit (packages/mcp-server) | pass |
| Publish to Marketplace | pass |
| build-check / Build Package | pass |
| docs-validation / Documentation Validation | pass |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | pass |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | pass |
| npm-audit / npm audit (.) | pass |
| npm-audit / npm audit (extensions/drm-copilot) | pass |
| npm-audit / npm audit (packages/mcp-server) | pass |
| poshqc / PowerShell QC | pass |
| poshqc / PowerShell hook suites (Linux) | pass |
| quality-checks7 / Code Quality & Tests (3.10) | pass |
| quality-checks7 / Code Quality & Tests (3.11) | pass |
| quality-checks7 / Code Quality & Tests (3.12) | pass |
| quality-checks7 / Code Quality & Tests (3.13) | pass |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | pass |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | pass |
| security-scan / Security Scanning | pass |
| shell-coverage / Shell Coverage (Bats + kcov) | pass |

The toolchain portion of AC-3 is evidenced by the qa-gates root-*, extension-*, and coverage-delta artifacts in this folder. The pre-existing root format:check failure on tests/fixtures JSON is excluded per #802 (tracked in #848).
