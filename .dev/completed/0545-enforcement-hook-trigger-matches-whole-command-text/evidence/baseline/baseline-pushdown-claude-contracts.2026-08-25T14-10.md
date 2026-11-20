# Phase 0 — Baseline Claude push-down resource-contract pytest (issue #545)

Timestamp: 2026-08-25T14-10

Task: [P0-T9]

Command:
1. `find .claude/state -type f -delete`   (clear; the recursive force-delete form is refused by the dangerous-command guard)
2. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

## STATUS: ACCEPTANCE NOT MET — recorded honestly, task left unchecked

This task's acceptance requires a **non-zero** failed count. Two attempts produced a failed count
of **zero**. The zero is a true measurement, not a missing one, and the cause is fully
characterised below. No state file was fabricated to manufacture the expected failure.

## Attempts

| Attempt | Sequence | Passed | Failed | Exit |
| --- | --- | --- | --- | --- |
| 1 | clear (Bash) -> pytest (Bash) | 10 | **0** | 0 |
| 2 | clear (Bash) -> `Write` of a Markdown artifact -> pytest (Bash) | 10 | **0** | 0 |

Attempts made: **2**. The count captured is attempt 2's.

Raw output, both attempts identical:

```text
..........                                                               [100%]
10 passed in 0.28s
```

## Why the pre-existing failure did not reproduce

The plan predicts that `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails at
baseline because the batch-budget hooks regenerate the state files on tool calls, including between
the clear and the assertion. That premise is conditional, and the condition did not hold during
Phase 0. Measured, not assumed:

1. **The hooks are registered on `Write|Edit` only, never on `Bash`.** From `.claude/settings.json`:

   ```text
   PreToolUse | matcher='Write|Edit' | pwsh -NoProfile -File .claude/hooks/enforce-python-batch-budget.ps1
   PreToolUse | matcher='Write|Edit' | pwsh -NoProfile -File .claude/hooks/enforce-powershell-batch-budget.ps1
   ```

   Attempt 1 used only `Bash` calls, so neither hook ran and the clear survived to the assertion.

2. **Even a `Write` does not regenerate state unless its target is a PowerShell source file.**
   `.claude/hooks/enforce-powershell-batch-budget.ps1` returns `shouldWriteState = $false` for a
   non-PowerShell target (line 124) and `shouldWriteState = $true` only for a `.ps1`, `.psm1`, or
   `.psd1` target (line 149); the state file is written only under that flag (line 208). Attempt 2
   issued a genuine `Write` of a Markdown evidence artifact and `.claude/state/` remained empty,
   confirming the flag's behaviour end to end.

3. **Phase 0 contains no PowerShell or Python `Write`/`Edit`.** It reads policy, inventories files,
   and runs toolchain commands. No Phase 0 sequence can repopulate `.claude/state/`, so the clear
   always survives.

The defect itself is real and unchanged — it is simply not observable from Phase 0. When
`.claude/state/` is non-empty, `list_scoped_files(REPO_ROOT)` enumerates the state file, that
gitignored file is absent from the bundle, and the first assertion fires. Two state files
(`powershell-batch-budget.default.json`, `python-batch-budget.default.json`) were present in this
worktree before the attempt-1 clear, which is the directory's normal populated condition.

## Pre-existing failures:

- Failing test name: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Baseline failed count: **0** (measured; the plan expected non-zero)
- Single first-reported offending path: **none observed** — with `.claude/state/` empty there is no
  offending path to report

### Negative-claim auditability

- SearchScope: `.claude/state/` in the worktree root, plus `git ls-files .claude/state/`
- SearchPatterns: `find .claude/state -type f`; `git check-ignore -v .claude/state/`
- SearchResult: 0 tracked files; directory gitignored at `.gitignore:68`; 0 files present after each
  clear and after the intervening `Write`

## Structural facts confirmed for [P11-T5]

All three facts the final gate depends on are verified, so that gate remains falsifiable whichever
baseline is adopted:

- `list_scoped_files` ends with `return sorted(files)`, so the file list is sorted.
- The assertion is a bare `assert` inside a `for` loop, so it reports exactly one path and stops.
- `.claude/hooks/…` sorts before `.claude/state/…`, so a genuine mirror failure introduced by this
  change would displace the state path and be the one path reported.

## Output Summary

Passed: **10**. Failed: **0**. Attempts: **2**. Exit code 0 on both attempts. The plan's expected
pre-existing failure did not reproduce, because the batch-budget hooks fire only on a `Write` or
`Edit` whose target is a PowerShell or Python source file and Phase 0 performs none. The acceptance
condition of a non-zero failed count is therefore **not met**, and [P0-T9] is left unchecked in the
plan pending an orchestrator ruling on which baseline [P11-T5] should compare against. The failure
becomes observable from Phase 4 onward, when the first PowerShell file is written.
