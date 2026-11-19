# Final Static Checks — [P3-T1]

Timestamp: 2026-11-18T10-53
Command: `env -u VIRTUAL_ENV sh SCRATCH/issue-1030-final-static.sh` (PowerShell format with before and after hash lists, `Invoke-ScriptAnalyzer`, `Invoke-PoshQCLeakScan`, Codex generator check, `GENERATOR-CHECK`) over the 15 PowerShell files changed between BASE and HEAD
EXIT_CODE: 1
Output Summary: format, analyzer, leak scan and the Codex generator check pass; `GENERATOR-CHECK` exits 1 on the pre-existing drift of `.claude/rules/orchestrator-state.md`, so the [P3-T1] acceptance (exit code 0 for both generator checks) is not met and the task stays unchecked.

## PowerShell

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Format | `Invoke-PoshQCFormat` with a non-writing `-WriteFile` seam over the 15 changed files; SHA256 list before and after | 0 | 0 `Formatted:` lines; digest `7BD013B16CADDE7DC7042BDF5B7822D5FFE326ABF2EF9B0FCD629FC3D8EA8477` before and after (identical) |
| Lint | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file | 0 | Error 0, Warning 0, Information 0 |
| Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 896 files, 0 failures |
| Type check | not applicable to PowerShell | N/A | N/A |

Changed files: `.codex/hooks/subagentstop-envelope.ps1`, `.codex/hooks/validate-pr-author-output.ps1`, their two `BUNDLE` copies, `scripts/harness/HarnessHookParity.psm1`, `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, `tests/scripts/codex-hooks/codex-subagentstop-envelope.Tests.ps1`, `tests/scripts/codex-hooks/codex-validate-pr-author-output.Tests.ps1`, `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`, `tests/scripts/harness/HarnessHookParity.Tests.ps1`.

## Generator checks

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Codex agent variants | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | 0 |
| GENERATOR-CHECK | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check` | 1 | 2: `DRIFT .claude/rules/orchestrator-state.md (content differs)`; `DRIFT extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md (content differs)` |

The drift is pre-existing at BASE (the same finding fails `Harness generation repository gate.reports no drift for any generated target in the working tree` in `pester-baseline.2026-11-18T08-34.md`). The `## Release-Commit Allowance Scope` section that issue #1201 added to `.claude/rules/orchestrator-state.md` on `main` is absent from the generator source `scripts/harness-generation/sources/rules/orchestrator-state.md`. Neither file is in this plan's file set, `.claude/rules/` is a policy location this executor does not edit, and regenerating the rule from the current source would remove the #1201 section. The finding is escalated to the orchestrator and is not fixed in this item.

## Python and TypeScript

N/A - no Python or TypeScript file changed.
