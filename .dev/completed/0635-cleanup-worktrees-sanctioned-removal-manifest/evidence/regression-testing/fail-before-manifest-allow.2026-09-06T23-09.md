# Fail-Before Regression Run Against The Unfixed Gate Hooks

Timestamp: 2026-09-08T03-25

Task: [P2-T4] `[expect-fail]`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the branch worktree and **no
`scan_folders` argument**, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 4

ExpectedExitCode: 4

## Why the full scan set rather than a scoped run

A run scoped to `tests/scripts/claude-hooks` would exclude
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, the second member of the
Known-Local-Red Inventory, and would have produced exit code 3 rather than the declared 4. The run
was therefore issued with no `scan_folders` argument.

## Why the exit code equals the failed count

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4` sets `Run.Exit = $true` and
`Invoke-PoshQCTest` does not override it, so the process exit code equals the Pester failed count.
The expected count is the two Known-Local-Red Inventory members plus the two tests added by P2-T2
and P2-T3, which is 4. The observed code is 4.

## Root `testsuites` start tag, transcribed verbatim

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4372" errors="0" failures="4" disabled="9" time="152.271">
```

Derivation by the subtraction rule in the plan's toolchain preamble: the element carries no `passed`
attribute, so passed = `tests` minus every non-passing count the element carries.

- Total tests: 4372
- Failed: 4
- Errors: 0
- Disabled (skipped): 9
- **Passed (derived): 4372 - 4 - 0 - 9 = 4359**

The MCP runner returns a JSON result object and does not relay the module's console totals line, so
no value in this artifact is read from console text; all counts come from
`artifacts/pester/pester-junit.xml` written by this run.

## Complete failing-node inventory (4 of 4)

| # | Suite file | Node name | Classification |
| --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | `enforce-epic-worktree-removal-gate.ps1 manifest branch` > `allows removal when a fresh manifest record authorizes the target` | Added by [P2-T2]; expected to fail |
| 2 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | `enforce-parallel-worktree-removal-gate.ps1 manifest branch` > `allows removal when a fresh manifest record authorizes the target` | Added by [P2-T3]; expected to fail |
| 3 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `enforce-pr-author-skill.ps1` > `allowed commands` > `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Known-Local-Red Inventory member 1 |
| 4 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` > `allows every registered handler for every tool name its own matcher admits` | Known-Local-Red Inventory member 2 |

No other test failed. The observed `EXIT_CODE` of 4 equals the number of failing nodes this artifact
names. Rows 3 and 4 are exactly the two-member Known-Local-Red Inventory recorded in the plan's
toolchain preamble; both are produced by this run's own `epic_mode: true` orchestration checkpoint
under gitignored `artifacts/`, and both pass in the canonical environment on `_poshqc.yml` run
`34186767775`. Neither is a branch defect and neither is caused by this change.

## Observed decision for each of the two expected failures

Both new tests assert `permissionDecision` equal to `allow`. Both received `deny`.

Epic gate, failure message transcribed from the `testcase` element:

```text
Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'
```

Parallel gate, failure message transcribed from its `testcase` element:

```text
Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'
```

The observed decision is `deny` in both cases. That is the proof the failure is the **missing
manifest branch** rather than a missing command, an unresolved function name, or a fixture error:
each hook parsed the envelope, matched its trigger, extracted the removal target, evaluated its
existing positive predicates against checkpoint fixtures that record nothing, and reached its
unchanged final deny. A fixture or wiring error would have surfaced as a terminating error or as a
different assertion failure, not as a well-formed `deny` decision.

## Toolchain steps preceding this run

Per the mandatory PowerShell toolchain order, format ran first, then analyze, then this test run.

| Step | Command | Result |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | `ok: true`; exit status 0. `git status --porcelain` after the run listed no file the formatter rewrote beyond the two suites this phase edited, and the anchored `--numstat` for both suites reported zero deleted lines, so no pinned path was rewritten. |
| Analyze | `mcp__drm-copilot__run_poshqc_analyze` | `ok: true`; exit status 0. No findings. |
| Test | `mcp__drm-copilot__run_poshqc_test` | exit status 4, recorded above as this artifact's `EXIT_CODE`. |

Each per-step status above is transcribed in a form whose text before the first colon is not exactly
`EXIT_CODE`, because `scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last
such row as the artifact's result. This file carries exactly one line whose pre-colon text is exactly
`EXIT_CODE`, the `EXIT_CODE: 4` row above, matched by its `ExpectedExitCode: 4` declaration.

Output Summary: The full configured scan set ran against the **unfixed** hooks and exited 4, equal
to the declared expectation and to the number of failing nodes named above. Passed 4359, failed 4,
skipped 9, derived from the root `testsuites` start tag transcribed above. Exactly two failures
carry the name `allows removal when a fresh manifest record authorizes the target`, one in each gate
suite, and the observed `permissionDecision` recorded for each is `deny`. The remaining two failures
are precisely the two-member Known-Local-Red Inventory and no other test failed. This satisfies the
fail-before half of AC-01 and AC-02.
