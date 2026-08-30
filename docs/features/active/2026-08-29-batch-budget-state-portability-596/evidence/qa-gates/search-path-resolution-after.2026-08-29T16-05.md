# [P6-T2] After-state searches for the three host-path-resolution literals

Timestamp: 2026-08-29T22-07

Command: three commands, run in this order:

1. `git grep -c -F "(Get-Location).Path" -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
2. `git grep -c -F "Resolve-Path" -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
3. `git grep -c -F "[System.IO.Path]::GetFullPath" -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 1

ExpectedExitCode: 1

All three commands exited 1 and produced no output. The per-command exit codes are recorded
individually in the table below; the artifact-level `EXIT_CODE:` and `ExpectedExitCode:` above apply
to all three, which share the same expectation.

Output Summary: All three asserted literals are absent from all four in-scope files. Each of the
three searches printed nothing and exited 1. This satisfies the after-state half of the acceptance
criterion at `spec.md:725`. Only the first of the three searches is a falsifiable before-and-after
gate; the other two are introduction guards, and that distinction is set out explicitly below.

## Absolute-path prefix actually used

The plan states the commands in worktree-relative form. Each was executed with the working directory
set to the absolute worktree root:

```
cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5 && <plan command text>
```

The pathspecs and the searched literals are unchanged from the plan text.

## Per-command results

| # | Literal | Observed exit | ExpectedExitCode | Output |
| --- | --- | --- | --- | --- |
| 1 | `(Get-Location).Path` | 1 | 1 | none |
| 2 | `Resolve-Path` | 1 | 1 | none |
| 3 | `[System.IO.Path]::GetFullPath` | 1 | 1 | none |

Verbatim output of all three commands, concatenated:

```
```

No stdout line and no stderr line was produced by any of the three.

## Falsifiability — comparison against the [P0-T7] baseline

The baseline artifact
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/search-getlocation-before.2026-08-29T16-05.md`
recorded command 1 over the identical four pathspecs exiting 0 and printing four output lines, one
per pathspec, each reporting a count of `1`.

| Pathspec | [P0-T7] baseline count for `(Get-Location).Path` | [P6-T2] observed count |
| --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 1 | 0 (no line emitted) |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 1 | 0 (no line emitted) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | 1 | 0 (no line emitted) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | 1 | 0 (no line emitted) |

Baseline totals for command 1: 4 matching pathspecs, 4 total occurrences, exit 0.
After-state totals for command 1: 0 matching pathspecs, 0 total occurrences, exit 1.

## Required distinction: one proof of removal, two guards against introduction

The plan requires this artifact to state explicitly that the three searches are not three equivalent
proofs. They are not.

- **Command 1, `(Get-Location).Path`, is a genuine before-and-after gate.** It matched four times at
  baseline and matches zero times now. A reviewer can falsify the claim by reverting the Phase 2 and
  Phase 3 edits and re-running the same command, which would again exit 0 with four lines.
- **Commands 2 and 3, `Resolve-Path` and `[System.IO.Path]::GetFullPath`, are guards against an
  introduction, not proofs of a removal.** Both literals were already absent from all four files
  before this feature made any edit, so their exit of 1 today is consistent with the executor having
  changed nothing at all in respect of those two literals. They gate only the negative property that
  the Phase 2 and Phase 3 edits did not introduce a host-absolute path-resolution call as part of the
  repair.

That baseline absence is recorded here as a direct observation rather than carried over as an
assertion from the plan text. The same three searches were run against `main`, which is the state
preceding every edit this feature makes:

```
$ git grep -c -F "(Get-Location).Path" main -- <the four pathspecs>
main:.claude/hooks/enforce-powershell-batch-budget.ps1:1
main:.claude/hooks/enforce-python-batch-budget.ps1:1
main:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1:1
main:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:1
EXIT=0

$ git grep -c -F "Resolve-Path" main -- <the four pathspecs>
EXIT=1

$ git grep -c -F "[System.IO.Path]::GetFullPath" main -- <the four pathspecs>
EXIT=1
```

| Literal | Present at `main` | Present now | Reading |
| --- | --- | --- | --- |
| `(Get-Location).Path` | yes, 1 per file | no | removal proved |
| `Resolve-Path` | no | no | introduction guard only |
| `[System.IO.Path]::GetFullPath` | no | no | introduction guard only |

A reviewer should read exactly one proof of removal in this artifact, together with two guards whose
pass carries no information about what the edits did.

## Scope note

The pathspec list is fixed by the plan and was not broadened. The two `.codex/hooks/` siblings are
out of scope for this feature and were not searched.
