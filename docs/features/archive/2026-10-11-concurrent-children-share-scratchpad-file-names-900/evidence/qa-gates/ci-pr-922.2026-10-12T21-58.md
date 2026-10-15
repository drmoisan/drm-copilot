# PR CI Evidence (PR #922)

Timestamp: 2026-10-12T21-58

Command: gh pr checks 922 ; gh run view 38312575298 --job 115021563848 --log (PowerShell QC job)

EXIT_CODE: 0

Output Summary:
- PR #922 head 0a830bc1965d374d18c666b4904810b4a2eca8f2; workflow run https://github.com/drmoisan/drm-copilot/actions/runs/38312575298
- 20 of 20 checks pass: Extension Tests (ubuntu, windows), NPM Audit Gate x3, Publish to Marketplace, build-check, docs-validation, drm-copilot-extension-tests (ubuntu, windows), poshqc / PowerShell QC, poshqc / PowerShell hook suites (Linux), quality-checks7 (3.10, 3.11, 3.12, 3.13), root-typescript-tests (ubuntu, windows), security-scan, shell-coverage.
- PowerShell QC Pester summary: "Tests Passed: 10242, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0".
- tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 reported "[+]" (passed) in that job (job https://github.com/drmoisan/drm-copilot/actions/runs/38312575298/job/115021563848).
- `gh pr checks 922` re-confirmed 20 of 20 pass at the time of recording.
