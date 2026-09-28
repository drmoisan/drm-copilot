# Containment literal, pre-remediation state (remediation cycle 1)

Timestamp: 2026-08-30T00-50

Task: [P0-T7]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command (plan command text, quoted verbatim):

```
git grep -c -F 'StartsWith($normalizedRoot,' -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
```

Executed with the working directory set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`.

EXIT_CODE: 0

## Observed output, verbatim — four lines, one per pathspec

```
.claude/hooks/enforce-powershell-batch-budget.ps1:1
.claude/hooks/enforce-python-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1:1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1:1
```

Every one of the four pathspecs reports a count of `1`. The acceptance condition holds.

## The asserted literal and why the trailing comma matters

The literal asserted is:

```
StartsWith($normalizedRoot,
```

including its trailing comma. `-F` makes the match a fixed string, so `$normalizedRoot` is matched literally rather than interpreted as a shell or regex construct.

The trailing comma is what distinguishes the defective form from the corrected form. The corrected form that decision D-1 pins reads:

```
StartsWith($normalizedRoot + '/',
```

In the corrected form the character following `$normalizedRoot` is a space, not a comma, so the defective literal cannot match a corrected line. Without the comma the search would match both forms and the [P4-T2] gate would report the same count before and after the fix, which would make that gate incapable of failing.

## Independent confirmation that the corrected form is currently absent

Recorded as a micro-check supporting the falsifiability claim above, not as a separate acceptance condition of this task:

```
git grep -c -F "StartsWith(\$normalizedRoot + '/'," -- <the same four pathspecs>
EXIT_CODE: 1, no output
```

`git grep` exits 1 with no output when no line matches in any pathspec. The corrected literal therefore appears zero times across all four files at baseline. Together with the four counts of `1` above, this establishes both halves of the before-state: the defective form is present exactly once per file, and the corrected form is present nowhere. The [P4-T2] gate can therefore fail if the edits are not made, which is what makes it a real gate.

## Scope

The pathspec list is fixed by the plan and was not broadened. The four files are:

1. `.claude/hooks/enforce-powershell-batch-budget.ps1`
2. `.claude/hooks/enforce-python-batch-budget.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

The `.codex/hooks/` siblings are out of scope for this remediation and were not searched.

## Output Summary

`git grep -c -F 'StartsWith($normalizedRoot,'` exited 0 and reported a count of `1` for each of the four in-scope pathspecs, confirming the defective containment form is present exactly once per file. The corrected form `StartsWith($normalizedRoot + '/',` is absent from all four (companion search exits 1 with no output). This is the before-state half of the [P4-T2] gate and is what makes that gate capable of failing.
