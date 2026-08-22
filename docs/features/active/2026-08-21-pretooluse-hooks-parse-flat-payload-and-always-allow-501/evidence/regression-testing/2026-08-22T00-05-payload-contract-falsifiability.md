# Regression testing — AC-8 falsifiability probe [expect-fail] (#501)

Timestamp: 2026-08-22T00-05

Task: [P5-T2] (`[expect-fail]`: run 1 is required to FAIL; that failure is the expected outcome for this task only)

Purpose: prove the structural regression guard `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` is falsifiable. A contract suite that passes whatever the source says gates nothing. The probe temporarily restores the retired environment-variable transport literal in one hook, confirms the suite fails, reverts, and confirms it passes.

The probe script composes the injected literal from fragments (`'$' + 'env:' + 'CLAUDE_TOOL_' + 'INPUT'`) so the probe's own text does not carry it.

## Run 1 — temporary comment carrying the retired transport literal appended to `.claude/hooks/enforce-epic-merge-gate.ps1`

Command: `Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 -PassThru -Output None` (driven from `scratchpad/p5t2_probe.ps1`, which injects the line, runs Pester, and reverts in a `finally` block)

EXIT_CODE: 0 (the probe script's own exit code; the Pester result is the signal)

ExpectedExitCode: 0

Result, verbatim:

```
RUN1 Result=Failed Passed=76 Failed=1
RUN1 FailedTest: contains neither retired environment-variable transport literal in .claude/hooks/enforce-epic-merge-gate.ps1
```

The suite FAILED, as required. Exactly one assertion failed, and it is the per-hook literal-absence assertion for the hook that was tampered with — the guard is specific, not a blanket failure.

## Revert verification

```
restored-matches-original=True
restored-matches-mirror=True
```

The hook file's SHA-256 after revert equals both its pre-probe hash and the hash of its `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` mirror copy, so byte parity with the mirror is restored and no residue remains in the working tree.

## Run 2 — working tree restored

Command: `Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 -PassThru -Output None`

EXIT_CODE: 0

Result, verbatim:

```
RUN2 Result=Passed Passed=77 Failed=0
```

## Output Summary

One failing run and one passing run recorded. Restoring the retired transport literal in a single hook makes the contract suite fail on exactly that hook's assertion; removing it makes the suite pass with all 77 assertions green (24 registered PreToolUse hooks x 3 per-hook assertions, plus 5 suite-level assertions). The working tree is restored and byte-identical to its mirror. AC-8's falsifiability requirement is discharged.
