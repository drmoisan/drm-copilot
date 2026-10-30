# Preflight Fixes

Timestamp: 2026-10-30T23-41
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md

Each entry is a trivial in-place fix to task text. No task was added, removed, or reordered.

## Fix 1 - [P6-T1]

- Defect class: validator-blind acceptance that cannot fail (write-mode command observed through `git status --porcelain`).
- Finding: [P6-T1] formats only new and edited files. Those files are already modified or untracked when the formatter runs, so their porcelain status line is the same whether or not the formatter rewrites them; the stated check cannot detect a rewrite.
- Change: the acceptance now records the `git hash-object` value of every formatted file before and after the run and requires each pair to be equal. The asserted meaning (the formatter changed nothing) is unchanged.

## Fix 2 - [P2-T4]

- Defect class: validator-blind constraint from existing tests outside the task's acceptance.
- Finding: `test_every_psscriptroot_occurrence_is_recognized` in `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` fails on a `$PSScriptRoot` use whose leaf is a variable, and detection class 3 of `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` reports an `&`-invoked variable that is not a `[scriptblock]` parameter under the `.codex/hooks` scan root. The adapter's dispatch table and default seam could take either form.
- Change: the task text now requires each twin path to be written as a literal `Join-Path $PSScriptRoot '<twin>.ps1'` form and the default seam to start `pwsh` by literal command name or through `System.Diagnostics.ProcessStartInfo`. No acceptance condition changed.

## Fix 3 - [P5-T2]

- Defect class: stale sibling text in the edited file.
- Finding: `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` states "Exactly three scan roots" in a comment and "the three scan roots" in the `Get-GuardedPowerShellFile` synopsis; both become incorrect once the task adds two roots.
- Change: the task text now includes updating that comment and synopsis to five. No acceptance condition changed.
