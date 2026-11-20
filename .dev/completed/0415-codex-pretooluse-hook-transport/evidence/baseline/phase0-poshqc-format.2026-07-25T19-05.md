# Phase 0 — Baseline PoshQC Format (Issue #415)

Timestamp: 2026-07-25T19-05

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`
EXIT_CODE: 0

Raw result:

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
```

Post-run verification command: `git status --porcelain`
EXIT_CODE: 0

```
 M docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md
?? .codex/state/
?? docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/
```

Output Summary: Format passed with `ok: true`. Files changed: **none**. No PowerShell file was reformatted, so no `git restore` was required and the baseline is non-mutating. The working tree after the run is identical to the P0-T2 baseline: only the plan file (this execution's checkbox updates), the untracked `.codex/state/` runtime directory, and the untracked feature `evidence/` tree. Note that the plan's expectation of a pre-existing `M .codex/config.toml` does not apply — that edit was reverted before execution, as recorded in `phase0-git-baseline.2026-07-25T19-05.md`.
