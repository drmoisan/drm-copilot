# Phase 0 — Baseline PoshQC Analyze (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T4]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`

Timestamp: 2026-07-26T14-37

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`

EXIT_CODE: 0

## Raw Result (MCP, mandated loop stage)

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
```

The MCP surface reports a clean analyzer run as `ok: true` with no enumerated diagnostics; a run with
findings returns `ok: false` with the finding detail attached. It does not emit numeric counts, so a
corroborating local run against the repo-resident PoshQC module was executed to obtain them.

## Corroborating Local Run (numeric counts)

Command: `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCAnalyze -Root '.'"`
EXIT_CODE: 0

```
PSScriptAnalyzer passed: no findings under .
```

## Output Summary

Analyze passed. Numeric finding counts at baseline SHA `37d0ecb46c222ddd3f20d1e26e5742ecf26acd73`:

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total findings** | **0** |

Both the MCP stage (`ok: true`) and the local repo-resident run (`PSScriptAnalyzer passed: no findings under .`)
agree. This reproduces the cycle-1 baseline recorded at
`evidence/remediation-baseline/phase0-poshqc-analyze.2026-07-26T11-41.md`. Any analyzer finding appearing in a
later phase of this remediation is therefore attributable to cycle-2 changes, not to pre-existing debt.
Hard Constraint 8 prohibits resolving any such finding with an analyzer suppression.
