# Final PowerShell Pester Coverage Gate

Timestamp: `2026-08-11T16:29:58.4347523-04:00`

MCP invocation: `mcp__drm-copilot__run_poshqc_test(workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25")`

Repository-configured scan folders: `scripts`, `tests/powershell`, and `tests/scripts` from `config/poshqc-scan.json`.

EXIT_CODE: `0` (`ok: true`; `isError: false`)

Output Summary: The authoritative bundled PoshQC Pester run completed successfully as the third command in one clean P6-T10 through P6-T12 pass. Fresh JUnit and JaCoCo-compatible coverage receipts were written by that run.

## Pester result

- Total tests: `2,294`.
- Passed: `2,285`.
- Failed: `0`.
- Errors: `0`.
- Skipped/disabled: `9`.
- JUnit-reported time: `136.923 seconds`.
- JUnit SHA-256: `BC6B325B19022DA4C5AEC9D4CC5B0C8EADBC675C23272419379371A256835210`.
- JUnit timestamp: `2026-08-11T16:27:21.9175798-04:00`.

## Repository PowerShell coverage

| Metric | Covered / total | Percent |
| --- | ---: | ---: |
| Lines | `4,040 / 4,260` | `94.84%` |
| Instructions | `5,489 / 5,814` | `94.41%` |
| Methods | `336 / 363` | `92.56%` |
| Classes | `50 / 52` | `96.15%` |

- Koverage-normalized report SHA-256: `0F576DD52766B60DB8B4D8E9C90803CA2C75988392BF97EE906BE7E1909EC440`.
- Raw JaCoCo report SHA-256: `29795FE57630315E31D0AFA334009EA4C825D87F385EE779A29D8BCC4DE4A21E`.
- Coverage timestamp: `2026-08-11T16:27:22.1596130-04:00`.
- Covered source files represented in the report: `52`.

## New and changed hook/script coverage

The changed-code calculation used added line ranges relative to baseline HEAD `fe0413d4aca1e76b2d02d05701fba79a887d5405` plus every line in new authoritative root `.codex/hooks/**` and `.codex/scripts/**` files, intersected with the final Koverage source-line records. Byte-identical resource-bundle counterparts were excluded to avoid double-counting the same runtime code.

- Changed/new authoritative root hook and script files: `25`.
- Added or changed physical lines: `4,889`.
- Instrumented added or changed lines: `27`.
- Covered added or changed lines: `25`.
- Uncovered instrumented added or changed lines: `2`.
- New/changed instrumented line coverage: `92.59%`.
- The instrumented changed lines are in `.codex/hooks/enforce-completion-consistency.ps1` (`25 / 27`).
- Other new hook/script entrypoints are validated through external-process Pester contracts; those child processes are included in the green test result but do not contribute JaCoCo source-line nodes to the parent Pester process.

## Ordered-loop and policy verification

- Pre/post PowerShell source manifest: unchanged at `47BB374736FF15F5ACF3074C060474AD3AA0ADD82496A87371A6FF0C966EFD5B`.
- Formatter, analyzer, or test source writes: `0`.
- Changed PowerShell files checked for size: `85`.
- Files above `500` physical lines: `0`; maximum: `497` lines.
- New PowerShell suppression additions: `0`.
- `testResults.xml` baseline/current SHA-256: `02628E73BB8A090824E5E97ADEB385AF1068AD905E7DA636A40AB64FD5F0E96A`; status paths: `0`.
- `.claude` baseline/current files: `150 / 150`; missing, added, or mismatched: `0 / 0 / 0`; status paths: `0`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

`P6_T12_STATUS: COMPLETE`
