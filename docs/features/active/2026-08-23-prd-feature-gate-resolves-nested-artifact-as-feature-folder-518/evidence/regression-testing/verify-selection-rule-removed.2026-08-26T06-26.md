# Selection-Rule Removal Verification — [P3-T4]

Timestamp: 2026-08-26T06-26

Task: [P3-T4]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`

Command:

```text
git grep -n -F "Sort-Object -Property Length -Descending" -- .claude/hooks/enforce-prd-feature-before-planner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1
```

EXIT_CODE: 1

ExpectedExitCode: 1

`git grep` exits 1 when it finds no match. A non-zero exit is therefore the required outcome of this
task, not a failure: it is the proof that the deleted selection rule is absent. An exit code of 0
would mean the rule is still present in at least one of the two files and would fail this task.

## Matching Lines

**Zero matching lines.** The command produced no output at all. The literal
`Sort-Object -Property Length -Descending` appears in neither
`.claude/hooks/enforce-prd-feature-before-planner.ps1` nor its bundled mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`.

The `-F` flag makes the pattern a fixed string rather than a regular expression, so the match is
literal and no metacharacter in the pattern can alter it.

## Why the Rule Had to Be Deleted Rather Than Fed Truncated Input

Recorded so a later reader does not restore the sort as a harmless ordering step. After truncation
every surviving candidate has exactly four path segments, so a length-descending sort degenerates
into "the feature folder with the longest slug wins" — an arbitrary criterion unrelated to which
folder the delegation is about. Truncation alone is therefore not sufficient; the sort is replaced by
the explicit checkpoint-then-earliest-occurrence rule, and the order-preserving `List[string]` that
feeds it exists because PowerShell hashtable key enumeration order is unspecified.

## Scope Note

The same literal remains present in the three sibling hooks named in the Scope Containment section of
`spec.md` — `enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1`, and
`enforce-parallel-drift-gate.ps1` — and in their bundled mirrors. That is intended: those files are
out of scope for issue #518 under the change budget in `.claude/rules/powershell.md:37-40`, and each
warrants its own follow-up issue. This task deliberately scopes its search to the two files in the
declared write set, so it neither reports nor is affected by the sibling hooks.

Output Summary: `git grep -n -F "Sort-Object -Property Length -Descending"` scoped to the two hook
copies exited 1, matching its declared ExpectedExitCode of 1, and produced zero matching lines. The
deleted length-based selection rule is absent from both
`.claude/hooks/enforce-prd-feature-before-planner.ps1` and its bundled mirror under
`extensions/drm-copilot/resources/claude-customizations/`. The three sibling hooks that still carry
the literal are out of scope for this change by design and are not searched by this command.
