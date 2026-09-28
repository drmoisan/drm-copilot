# Path-resolution introduction guard (not a removal proof)

Timestamp: 2026-08-30T01-29

Task: [P4-T3]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Both commands were executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan's
command text is worktree-relative and is reproduced verbatim below; the absolute prefix was
supplied by `cd` into that path before each invocation.

## What this artifact does and does not claim

**These are introduction guards, not proofs of a removal, and neither is a before-and-after
gate.** Both literals were already absent from both hooks before this remediation began. The
searches therefore confirm that the D-1 edit did not introduce either API; they do not
demonstrate that either API was taken out, because neither was ever there. This is stated
plainly so a reviewer does not read the two exit-1 results as before-and-after evidence.

The absence at baseline is recorded here as an observation rather than an assertion. Both
searches were re-run against the remediation anchor commit `7840ecc3`, which predates every
edit in this plan:

```
git grep -c -F 'Resolve-Path' 7840ecc3 -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1
  -> exit 1, no output

git grep -c -F '[System.IO.Path]::GetFullPath' 7840ecc3 -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1
  -> exit 1, no output
```

Both literals were absent at the anchor and are absent now. The gate's value is that it would
have failed had the D-1 edit reached for either API.

## Search 1 — `Resolve-Path`

Command: `git grep -c -F 'Resolve-Path' -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 1
ExpectedExitCode: 1

Output, verbatim: no output. `git grep` exits 1 when it finds no match.

## Search 2 — `[System.IO.Path]::GetFullPath`

Command: `git grep -c -F '[System.IO.Path]::GetFullPath' -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 1
ExpectedExitCode: 1

Output, verbatim: no output.

## Why neither API may be used

`docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md` lines 329-333
record the reason, quoted here:

```
- `Resolve-Path` is **not** used. It throws on a path that does not exist, and every `Write` target a
  PreToolUse hook sees is by definition a path that may not exist yet.
  `[System.IO.Path]::GetFullPath` is also not used: it would resolve a relative candidate against the
  hook process's current directory, which is an incidental property of the `-File` invocation rather
  than a guaranteed one.
```

The containment rule the hooks implement instead is the string-normalization form at
`spec.md` lines 325-328, which the D-1 edit preserves and extends with the exact-root equality
operand.

## Scope note

The pathspec list is the two repository hooks only, exactly as the plan fixes it. The two
bundle mirrors are byte-identical to their sources, which [P4-T1] establishes independently, so
the guard result transfers to them without a separate search.

## Output Summary

Both searches produced no output and exited 1, meeting the stated `ExpectedExitCode: 1` for
each. Neither `Resolve-Path` nor `[System.IO.Path]::GetFullPath` appears in either batch-budget
hook. Both literals were already absent at the anchor commit `7840ecc3`, verified by re-running
the same two searches against that commit, so these results are introduction guards against the
D-1 edit rather than proofs of a removal, and neither constitutes before-and-after evidence.
