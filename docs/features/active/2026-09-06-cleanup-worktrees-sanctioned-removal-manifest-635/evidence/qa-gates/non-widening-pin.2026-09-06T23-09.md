# Non-Widening Pin — Both Gate Suites

Timestamp: 2026-09-08T04-05

Task: [P3-T11]

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the branch worktree and **no
`scan_folders` argument**, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

## Route and comparability

This gate asserts per-suite counts rather than a coverage number, so it does not need the new
`CodeCoverage.Path` entry honored and the MCP runner is the valid route. The self-hosted PoshQC
invocation cannot run in this worktree at all. Both sides of the comparison below are therefore
MCP-route counts — P0-T7's values 3 and 4 and this task's — which is what makes them comparable.
P0-T7's `CI Per-Suite Counts:` block is recorded there for visibility and is not the comparison
basis here. The per-suite counts below are derived from the `pester-junit.xml` this task's run
wrote, not from a file left by an earlier task's run.

## Additions-only diff, anchored on the epic integration tip

`git diff --numstat d250cf72ee24139735e7f08b07d002ae0e4f1d00 -- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`

```text
67	0	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
65	0	tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
```

Both files report **zero deleted lines**. The manifest work was added as a separate `Describe` block
appended after each suite's pre-existing `Describe`, so no pre-existing line was edited, no
assertion was weakened, and no pre-existing fixture was altered. That is the mechanical proof behind
the "unchanged" half of the criterion; the passing counts below are the behavioral half.

`git status --porcelain -- tests/scripts/claude-hooks`

```text
 M tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
 M tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
```

Both `git` commands exited with exit status 0. Those statuses are transcribed in this wording rather
than as their own `EXIT_CODE:` rows because `scripts/dev_tools/pr_context/verification_evidence.py:122-128`
takes the last row whose text before the first colon is exactly `EXIT_CODE` as the artifact's
result; a bare row carrying 0 would replace the observed 2, disagree with the declared expectation,
and render this passing gate as a failed one. This file carries exactly one line whose pre-colon
text is exactly `EXIT_CODE`, the `EXIT_CODE: 2` row above, and it is the suite run's outcome.

## Per-suite passed counts, derived

The `testsuite` element carries no `passed` attribute, so both sides of every comparison use the one
subtraction rule stated in the plan's toolchain preamble: `tests` minus every non-passing count the
element carries.

Epic gate suite, complete start tag from this run:

```xml
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="50" errors="0" failures="0" hostname="MEGALODON4" id="12" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" time="0.805">
```

Derived passed = 50 - 0 - 0 - 0 - 0 = **50**. P0-T7 baseline (value 3): **46**. 50 is not lower
than 46.

Parallel gate suite, complete start tag from this run:

```xml
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" tests="49" errors="0" failures="0" hostname="MEGALODON4" id="30" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" time="0.637">
```

Derived passed = 49 - 0 - 0 - 0 - 0 = **49**. P0-T7 baseline (value 4): **45**. 49 is not lower
than 45.

Both suites report `failures="0"` and `errors="0"`, so every pre-existing `It` in each — including
every test exercising the epic gate's branch 1 and branch 2 and the parallel gate's single branch —
still passes. The count rose by exactly the four tests this batch added to each file, and by
nothing else.

## Whole-run totals

Root `testsuites` start tag, transcribed verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4378" errors="0" failures="2" disabled="9" time="154.350">
```

Passed (derived): 4378 - 2 - 0 - 9 = 4367.

## Failing-node inventory (2 of 2)

| # | Suite file | Node name | Classification |
| --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `enforce-pr-author-skill.ps1` > `allowed commands` > `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Known-Local-Red Inventory member 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` > `allows every registered handler for every tool name its own matcher admits` | Known-Local-Red Inventory member 2 |

The observed `EXIT_CODE` of 2 equals the number of failing nodes this artifact names, that set is
exactly the two-member Known-Local-Red Inventory, and no other test failed.

## Toolchain steps preceding this run

| Step | Command | Result |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | `ok: true`; exit status 0. The anchored `--numstat` above, taken after the format run, still reports zero deleted lines on both suites, so the formatter rewrote neither. |
| Analyze | `mcp__drm-copilot__run_poshqc_analyze` | `ok: true`; exit status 0. No findings. |
| Test | `mcp__drm-copilot__run_poshqc_test` | exit status 2, recorded above as this artifact's `EXIT_CODE`. |

## Recorded ordering deviation

The [P3-T12] edit, which adds `It 'keeps the merge_status allow-set unchanged'` to each suite, was
applied to both files before this task's run rather than after it. The deviation does not weaken
either of this task's acceptance conditions. The zero-deleted-lines condition is unaffected, because
that edit is an insertion. The count condition requires each suite's derived passed count to be
**not lower than** its baseline, and the extra passing test raises the count rather than lowering
it, so the condition remains satisfiable only by the pre-existing tests continuing to pass. Recorded
here rather than left implicit.

Output Summary: Both gate suites report zero deleted lines against the anchored base ref, so no
pre-existing line, assertion, or fixture was altered. Epic suite derived passed 50 against a
baseline of 46; parallel suite derived passed 49 against a baseline of 45; both suites report zero
failures and zero errors. Whole run: 4367 passed, 2 failed, 9 skipped, exit code 2, the failing set
being exactly the two-member Known-Local-Red Inventory. Satisfies AC-06.
