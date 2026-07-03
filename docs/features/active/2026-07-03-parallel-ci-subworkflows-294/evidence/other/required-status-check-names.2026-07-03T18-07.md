# Confirmed Post-Extraction Required-Status-Check Names (P4-T9)

- Timestamp: 2026-07-03T22:46:00Z
- Command: `gh api repos/drmoisan/drm-copilot/commits/4125238fcecb5e37ab2c2193e902ed47752e7ccf/check-runs -q '.check_runs[] | {name, conclusion}'`
- Owner: orchestrator (direct `gh` invocation)
- EXIT_CODE: 0

## Output Summary

Raw response (name/conclusion pairs, one object per line, as emitted by the `-q` filter above):

```json
{"conclusion":"success","name":"shell-coverage / Shell Coverage (Bats + kcov)"}
{"conclusion":"success","name":"poshqc / PowerShell QC"}
{"conclusion":"success","name":"drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)"}
{"conclusion":"success","name":"drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)"}
{"conclusion":"success","name":"quality-checks7 / Code Quality & Tests (3.10)"}
{"conclusion":"success","name":"quality-checks7 / Code Quality & Tests (3.13)"}
{"conclusion":"success","name":"quality-checks7 / Code Quality & Tests (3.11)"}
{"conclusion":"success","name":"security-scan / Security Scanning"}
{"conclusion":"success","name":"build-check / Build Package"}
{"conclusion":"success","name":"quality-checks7 / Code Quality & Tests (3.12)"}
{"conclusion":"success","name":"docs-validation / Documentation Validation"}
```

## Confirmed check-run name table (11 rows)

| Extracted job | Confirmed check-run `name` string |
|---|---|
| `quality-checks7` (3.10) | `quality-checks7 / Code Quality & Tests (3.10)` |
| `quality-checks7` (3.11) | `quality-checks7 / Code Quality & Tests (3.11)` |
| `quality-checks7` (3.12) | `quality-checks7 / Code Quality & Tests (3.12)` |
| `quality-checks7` (3.13) | `quality-checks7 / Code Quality & Tests (3.13)` |
| `security-scan` | `security-scan / Security Scanning` |
| `docs-validation` | `docs-validation / Documentation Validation` |
| `build-check` | `build-check / Build Package` |
| `poshqc` | `poshqc / PowerShell QC` |
| `shell-coverage` | `shell-coverage / Shell Coverage (Bats + kcov)` |
| `drm-copilot-extension-tests` (ubuntu-latest) | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` |
| `drm-copilot-extension-tests` (windows-latest) | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` |

Composition rule confirmed empirically: **`<orchestrator job id> / <callee job's display name>`**.
This is the exact string format required if branch protection required-status-checks are configured
in the future.
