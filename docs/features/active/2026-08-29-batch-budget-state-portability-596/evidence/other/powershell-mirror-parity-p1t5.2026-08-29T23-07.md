# [P1-T5] PowerShell hook bundle-mirror parity after the D-1 edit

Timestamp: 2026-08-30T00-27

Task: [P1-T5] of the cycle-1 remediation plan.

## Execution context

The plan states its commands worktree-relative. The command was executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text, recorded verbatim below.

## The edit

Line 92 of `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
was replaced in place with the same single line applied by [P1-T4], one line for one line. The
mirror's corresponding line was confirmed to be line 92 and to carry the identical pre-edit text
before the replacement was applied.

## Hash parity

Command: `git hash-object .claude/hooks/enforce-powershell-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`

EXIT_CODE: 0

Output, verbatim:

```
bbbf70a648a68689939548d45ddbd8909ec98198
bbbf70a648a68689939548d45ddbd8909ec98198
```

| Check | Requirement | Observed | Result |
| --- | --- | --- | --- |
| Equal to each other | the two printed ids are equal | both `bbbf70a648a68689939548d45ddbd8909ec98198` | pass |
| Changed from baseline | both ids differ from the [P0-T6] pair | baseline was `d4503c778bace2d206bbaa356101ee34481446fa`; observed is `bbbf70a648a68689939548d45ddbd8909ec98198` | pass |

Both halves matter and both hold. Equality alone would be satisfied by leaving the pair untouched;
the change from the baseline id is what confirms the edit actually landed in both files.

## Mirror line-count preservation

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1').Count"`

EXIT_CODE: 0

Output Summary: `457`, unchanged from the [P0-T5] mirror baseline of `457`. The hash equality with the
repository copy, which also measures 457, is the stronger statement; the count is recorded so the
line-count preservation requirement is auditable per file.

## Why the mirror edit is mandatory

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
asserts presence and identical content for every repository `.claude/**` file except
`settings.local.json` and `.claude/agent-memory/**`. Editing the repository copy without the mirror
would fail that contract.

## Verdict

PASS. No BLOCKED branch taken.
