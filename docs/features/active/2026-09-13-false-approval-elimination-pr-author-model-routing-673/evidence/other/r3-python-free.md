# Python-Free Enforcement Path: AC-27 (issue #673)

Timestamp: 2026-09-19T19-11

Command: `Select-String -SimpleMatch` for each of `python`, `poetry`, `py -3`, and `Start-Process` over the seven files below; then `[System.Management.Automation.Language.Parser]::ParseFile` with a token collection, to classify the one hit by whether a comment token spans its line, and to confirm no string expression in the file carries any of the four tokens.

EXIT_CODE: 0

## Files scanned

- `.claude/hooks/enforce-pr-author-skill.ps1`
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `.claude/hooks/enforce-model-routing-receipt.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`

## Results

| Token | Total occurrences | Code | Comment |
| --- | --- | --- | --- |
| `python` | 1 | **0** | 1 |
| `poetry` | 0 | 0 | 0 |
| `py -3` | 0 | 0 | 0 |
| `Start-Process` | 0 | 0 | 0 |

**Zero code matches**, which is the acceptance condition.

### The single comment match, classified

`.claude/hooks/enforce-model-routing-receipt.ps1:22` reads `authoritative Python validator.` It is prose, and the classification is established rather than assumed: the file's tokens include a comment token spanning lines 1 to 45, so line 22 lies inside the leading comment-based-help block. The same parse confirms that no `StringConstantExpressionAst` or `ExpandableStringExpressionAst` anywhere in the file carries any of the four tokens, so there is no value a reader could execute.

A line-shape heuristic would have misclassified this line, because a continuation line inside a `<# ... #>` block begins with neither a hash nor a dot. The tokenizer is used instead for exactly that reason.

The sentence is accurate and is deliberately retained: the hook performs presence-only gating and cannot read the delegate's chosen model, so correctness of the recorded model does stay with the authoritative Python validator, which runs elsewhere. Naming that division of responsibility in the header is what keeps a later reader from assuming this gate validates the model itself.

## The #475 guard

`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` is the standing regression guard that no enforcement hook invokes Python. Its scan roots are declared at `:40-41`:

```
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/hooks'),
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib')
```

and they are enumerated at `:60`:

```
            $files = Get-ChildItem -Path $root -Recurse -File |
```

Both roots cover every file scanned by this task, including the new identity module under `.claude/lib/worktree-resolution/`, so that module entered the guard's scope the moment it was created without any change to the guard.

This task records the guard's path and citations; its pass result is asserted by `[P11-T4]`, which requires the testsuite ending `enforcement-hooks-no-python-invocation.Tests.ps1` to have `failures` 0 in the full run.

Output Summary: Zero code matches of `python`, `poetry`, `py -3`, or `Start-Process` across the four in-scope hooks, the prd-feature helpers, and the identity module. The single total occurrence is one word of prose inside a comment-based-help block, classified by a comment token spanning its line rather than by line shape, and the same parse shows no string expression in that file carries any of the four tokens. The #475 guard's path and both citations are recorded, and its scan roots already cover the new module.
