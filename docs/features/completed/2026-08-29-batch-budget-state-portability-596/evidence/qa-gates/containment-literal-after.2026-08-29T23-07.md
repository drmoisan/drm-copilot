# Containment-literal gate, post-remediation (B-1)

Timestamp: 2026-08-30T01-28

Task: [P4-T2]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Both commands were executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan's
command text is worktree-relative and is reproduced verbatim below; the absolute prefix was
supplied by `cd` into that path before each invocation.

## Search 1 — the defective literal must now be absent

Command: `git grep -c -F 'StartsWith($normalizedRoot,' -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 1
ExpectedExitCode: 1

Output, verbatim: no output. `git grep` exits 1 when it finds no match, so the empty output and
the exit code of 1 are the same signal recorded two ways.

The asserted literal is `StartsWith($normalizedRoot,`, including its trailing comma. The comma
is what distinguishes the defective form from the corrected form, which reads
`StartsWith($normalizedRoot + '/',` and therefore does not match this search.

## Search 2 — the corrected literal must now be present once per file

Command: `git grep -c -F "StartsWith(\$normalizedRoot + '/'," -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 0

Output, verbatim:

```
.claude/hooks/enforce-powershell-batch-budget.ps1:1
.claude/hooks/enforce-python-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:1
```

Four lines, one per pathspec, each reporting a count of `1`. Both hooks and both bundle mirrors
carry exactly one occurrence of the corrected containment comparison.

## Cross-reference to [P0-T7] — why this gate is capable of failing

`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/containment-literal-before.2026-08-29T23-07.md`
recorded the same Search 1 command at baseline with `EXIT_CODE: 0` and four output lines:

```
.claude/hooks/enforce-powershell-batch-budget.ps1:1
.claude/hooks/enforce-python-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:1
```

The defective literal was therefore present exactly once in each of the four files before the
D-1 edit and is absent from all four after it. That before-and-after transition is what makes
this a genuine gate rather than a search that would return the same result whatever the
executor did: had the D-1 edit not been applied, Search 1 would still exit 0 and this task
would fail.

| Search | [P0-T7] baseline | [P4-T2] observed |
| --- | --- | --- |
| `StartsWith($normalizedRoot,` (defective) | exit 0, four lines each `:1` | exit 1, no output |
| `StartsWith($normalizedRoot + '/',` (corrected) | not searched at baseline | exit 0, four lines each `:1` |

Search 2 has no baseline counterpart, so it is a presence assertion rather than a
before-and-after transition. Its falsifiability comes from the count: a missed mirror would
report three lines rather than four, and a duplicated edit would report a count above 1.

## Scope note

The pathspec list is exactly the four paths [P0-T7] fixed and was not broadened. The
`.codex/hooks/` siblings are out of scope for this remediation and are not searched.

## Output Summary

The defective containment literal `StartsWith($normalizedRoot,` is absent from all four
in-scope files: Search 1 produced no output and exited 1, against a baseline of exit 0 with
four matches. The corrected literal `StartsWith($normalizedRoot + '/',` is present exactly once
in each of the four files: Search 2 exited 0 and printed four lines each reporting `1`. Both
acceptance conditions are met.
