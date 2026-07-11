# QA Gate — 500-Line File-Size Check (AC16)

- Timestamp: 2026-07-10T19-35
- Command: `wc -l` on each listed file; `git diff --stat` on `repo-automation-service.ts`
- Limit: no production/test/reusable-script file may exceed 500 lines
  (`.claude/rules/general-code-change.md`).

## Line Counts (workspace copies)

| Lines | File | Under 500 |
|---|---|---|
| 488 | extensions/drm-copilot/src/extension.ts | yes |
| 487 | extensions/drm-copilot/src/repo-automation-service.ts | yes (unchanged) |
| 192 | extensions/drm-copilot/src/poshqc-command-registration.ts | yes |
| 141 | extensions/drm-copilot/src/poshqc-terminal-output.ts | yes |
| 228 | extensions/drm-copilot/src/poshqc-scan-config.ts | yes |
| 190 | extensions/drm-copilot/src/poshqc-folder-picker.ts | yes |
| 418 | extensions/drm-copilot/src/mcp-tool-definitions.ts | yes |
| 470 | extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts | yes |
| 103 | scripts/powershell/PoshQC/PoshQC.psm1 | yes |
| 421 | scripts/powershell/PoshQC/PoshQC.Testing.psm1 | yes |
| 125 | scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 | yes |
| 81 | tests/scripts/dev_tools/test_poshqc_bundled_parity.py | yes |

The bundled PowerShell mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/`
(`PoshQC.psm1`, `PoshQC.Testing.psm1`, `PoshQC.ScanConfig.psm1`) are byte-identical to the
workspace copies (parity gate), so their line counts equal the workspace figures above (103, 421,
125) and are likewise under 500.

## repo-automation-service.ts Unchanged

`git diff --stat extensions/drm-copilot/src/repo-automation-service.ts` produced no output
(exit 0), confirming the file has no diff versus HEAD. Its 487 lines are pre-existing and
unmodified by this feature.

## Result

Every listed file is <= 500 lines (largest: `extension.ts` at 488). `repo-automation-service.ts`
shows no diff. AC16 file-size constraint satisfied.
