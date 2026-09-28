# Rollout completeness confirmation — all 28 modules and all 28 mirrors

Timestamp: 2026-08-30T00-38

Command:
1. `pwsh -NoProfile -Command "$all = @(Get-ChildItem -Path '.claude/lib' -Filter '*.psm1' -File -Recurse); $bad = @(); foreach ($f in $all) { $t = @(@(Get-Content -LiteralPath $f.FullName) | ForEach-Object { $_.Trim() }); $i = [array]::IndexOf($t, 'Set-StrictMode -Version Latest'); if (-not ($i -ge 0 -and $t[$i + 1] -eq '$ErrorActionPreference = ''Stop''')) { $bad += $f.Name } }; 'TOTAL={0} GUARDED={1} UNGUARDED={2}' -f $all.Count, ($all.Count - $bad.Count), $bad.Count; $bad"`
2. `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -File -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force"`
3. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

Supporting command, not part of the stated acceptance, run over the bundle tree with the same probe:

4. `pwsh -NoProfile -Command "$all = @(Get-ChildItem -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib' -Filter '*.psm1' -File -Recurse); ... 'MIRROR TOTAL={0} GUARDED={1} UNGUARDED={2}' -f $all.Count, ($all.Count - $bad.Count), $bad.Count; $bad"`

EXIT_CODE: 0

Output Summary:

- Command 1 printed exactly one line and no module name followed it:

  `TOTAL=28 GUARDED=28 UNGUARDED=0`

  The acceptance condition is met. `TOTAL` and `GUARDED` agree and `UNGUARDED` is `0`, so the condition fails on any module the rollout missed and on any module added to `.claude/lib/` after this plan was written. A bare guarded count of 27 would have been satisfiable on this 28-module tree with one module unguarded; this form is not.
- Command 1, unguarded module list: empty. No module name was printed after the summary line.
- Command 2. Files remaining under `.claude/state/` after removal: `0`.
- Command 3. `1 passed in 0.09s`. Parity exit code: `0`, which equals `PostMergeParityExitCode: 0` recorded by `[P0-T12]`.
- Command 4 (supporting). `MIRROR TOTAL=28 GUARDED=28 UNGUARDED=0`, with an empty unguarded list. The bundle mirror tree carries the same 28 guarded modules. Mirror byte-identity was separately established per batch by check 4 of the batch verification contract, `git diff --no-index --quiet -- MODULE MIRROR` exiting 0.

Phase 7 modules confirmed by this run, with their post-edit line counts:

| Batch | Module | Lines before | Lines after |
| --- | --- | --- | --- |
| B25 | `.claude/lib/codex-routing/CodexDeployment.psm1` | 312 | 314 |
| B26 | `.claude/lib/codex-routing/CodexTopology.psm1` | 392 | 394 |
| B27 | `.claude/lib/hook-payload/HookPayload.psm1` | 494 | 496 |
| B28 | `.claude/lib/requirements/GeneratedDocumentCounters.psm1` | 32 | 44 |

No module exceeds the 500-line cap stated in `.claude/rules/general-code-change.md`.
