# Final Static Checks — [P3-T1] re-run by correction plan [P2-T1]

Timestamp: 2026-11-18T12-01
Command: `env -u VIRTUAL_ENV sh SCRATCH/issue-1030-final-static.sh` (PowerShell format with before and after hash lists, `Invoke-ScriptAnalyzer`, `Invoke-PoshQCLeakScan`, Codex generator check, harness generator check) over the 15 PowerShell files changed between the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`
EXIT_CODE: 0
Output Summary: all steps pass; this supersedes `final-static.2026-11-18T10-54.md` (earlier file kept, append-only). The correction changes no `.ps1`, `.psm1` or `.psd1` file, so the formatter and analyzer set is unchanged.

## PowerShell

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Format | `Invoke-PoshQCFormat` with a non-writing `-WriteFile` seam over the 15 changed files; SHA256 list before and after | 0 | 0 `Formatted:` lines (15 already formatted); digest `7BD013B16CADDE7DC7042BDF5B7822D5FFE326ABF2EF9B0FCD629FC3D8EA8477` before and after (identical) |
| Lint | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file | 0 | Error 0, Warning 0, Information 0, ParseError 0 |
| Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 896 files, 0 failures |
| Type check | not applicable to PowerShell | N/A | N/A |

## Generator checks

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Codex agent variants | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | 0 |
| Harness generator | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check` | 0 | 0 (`harness-generation: no drift`) |

`git status --porcelain` after the run is empty, so no step changed a file.

## Python and TypeScript

N/A - no Python or TypeScript file changed.
