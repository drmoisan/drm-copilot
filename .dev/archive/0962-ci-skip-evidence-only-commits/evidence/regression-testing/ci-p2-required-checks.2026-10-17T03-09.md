# P7-T11 Proof step P2.6: required checks on PR #967

Timestamp: 2026-10-17T03-09
Command: gh pr checks 967 --repo drmoisan/drm-copilot --required --json name,bucket,state
EXIT_CODE: 0
Output Summary: Required checks of PR #967 listed verbatim.


## `gh pr checks 967 --repo drmoisan/drm-copilot --required --json name,bucket,state`

exit: 0

```text
[{"bucket":"pass","name":"build-check / Build Package","state":"SUCCESS"},{"bucket":"pass","name":"shell-coverage / Shell Coverage (Bats + kcov)","state":"SUCCESS"},{"bucket":"pass","name":"drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)","state":"SUCCESS"},{"bucket":"pass","name":"quality-checks7 / Code Quality & Tests (3.10)","state":"SUCCESS"},{"bucket":"pass","name":"quality-checks7 / Code Quality & Tests (3.11)","state":"SUCCESS"},{"bucket":"pass","name":"quality-checks7 / Code Quality & Tests (3.12)","state":"SUCCESS"},{"bucket":"pass","name":"quality-checks7 / Code Quality & Tests (3.13)","state":"SUCCESS"},{"bucket":"pass","name":"security-scan / Security Scanning","state":"SUCCESS"},{"bucket":"pass","name":"drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)","state":"SUCCESS"},{"bucket":"pass","name":"poshqc / PowerShell QC","state":"SUCCESS"},{"bucket":"pass","name":"docs-validation / Documentation Validation","state":"SUCCESS"}]
```
