# Final QA — Python contract modules

Task: `[P5-T2]`
Timestamp: 2026-09-07T22-30

Command:
`poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -p no:cacheprovider --no-header -q`

EXIT_CODE: 0

## Recorded summary line

```
......................                                                   [100%]
22 passed in 0.20s
```

**`22 passed`**, equal to the `[P0-T8]` baseline of `22 passed`. No regression and no new test.

| Module | Role in this cycle |
|---|---|
| `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` | Enforces standing constraint 3: each of the two abandon token literals appears exactly once in the whole file text of `.claude/hooks/enforce-parallel-abandon-gate.ps1`. Edit 4 reconstructs both spellings from the split constant rather than restating either literal, and this suite is the check that the seam held. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Enforces the `.claude/**` to `extensions/drm-copilot/resources/claude-customizations/.claude/**` copy-set contract. |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | Enforces bundled PoshQC parity. |

## Ordering note

`test_push_down_claude_resource_contracts.py` is known to fail when `.claude/state/` is non-empty
(issue #510). This task ran after `[P4-T8]`, whose close-reset left `.claude/state/` empty, so the
suite ran against the state the contract expects. That ordering was preserved deliberately and is
the reason the run is clean.

## Python coverage

No Python production source file was edited by this cycle — every edit landed in `.claude/hooks/**`,
`.codex/hooks/**`, their bundle mirrors, and PowerShell test suites — so no Python coverage figure
is required and none is recorded.

## Output Summary

All three Python contract modules pass: `22 passed`, exit code 0, matching the `[P0-T8]` baseline
exactly. The abandon token seam, the push-down resource contract, and the bundled PoshQC parity
contract all hold after the six edits of this cycle.

TOOLCHAIN_SUBSTITUTION: none required. `poetry run pytest` is directly invocable in this session;
the substitution note in this cycle's other artifacts applies only to the PowerShell toolchain,
where `pwsh` is refused by the runtime guard.
