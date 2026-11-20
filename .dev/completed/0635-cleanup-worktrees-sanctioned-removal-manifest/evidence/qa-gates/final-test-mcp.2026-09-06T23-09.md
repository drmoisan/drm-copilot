# Final PowerShell Test Pass (Local MCP Route)

Timestamp: 2026-09-08T04-29

Task: [P8-T4]

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the branch worktree and **no
`scan_folders` argument**, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

## Why the observed exit code is 2 and why that is the expected steady state

The run settings set `Run.Exit = $true`
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`) and `Invoke-PoshQCTest` does not
override it, so the process exit code equals the Pester failed count. The two failures observed are
exactly the two members of the Known-Local-Red Inventory recorded in the plan's toolchain preamble,
both produced by this run's own orchestration checkpoint at
`artifacts/orchestration/orchestrator-state.json`, which carries `epic_mode: true`. `/artifacts` is
gitignored, so no such checkpoint exists in CI and both nodes pass there. This is not a blanket
waiver: the two nodes are named below, the mechanism is identified, and a third failing node or a
failing node outside the inventory would fail this gate.

## Whole-run totals

Root `testsuites` start tag, transcribed verbatim from the `artifacts/pester/pester-junit.xml`
written by this run:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4460" errors="0" failures="2" disabled="9" time="148.716">
```

The element carries no `passed` attribute, so the passed count is derived by subtracting from `tests`
every non-passing count the element carries:

- Passed (derived): 4460 - 2 (failures) - 0 (errors) - 9 (disabled) = **4449**
- Failed: **2**
- Skipped / disabled: 9

The MCP runner returns a JSON result object and does not relay `Invoke-PoshQCTest`'s console totals
line, so no value above is read from console text.

## Failing-node inventory (2 of 2)

| # | Suite file | Node name | Classification |
| --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `enforce-pr-author-skill.ps1` > `allowed commands` > `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Known-Local-Red Inventory member 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` > `allows every registered handler for every tool name its own matcher admits` | Known-Local-Red Inventory member 2 |

The enumeration is complete and was derived mechanically rather than by inspection: the run's
`pester-junit.xml` contains exactly 2 `<failure` elements and exactly 2 `status="Failed"` testcase
elements, and both are the rows transcribed above.

Both failure messages confirm the recorded mechanism. Member 1 failed with
`Expected: 'allow' / But was: 'deny'`, which is
`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` denying with
`EPIC_BASE_BRANCH_MISMATCH` because the checkpoint carries `epic_mode: true` and the test's command
text carries no `--base`. Member 2 failed with a message naming
`enforce-epic-wave-barrier.ps1` denying with
`EPIC_WAVE_BARRIER_BLOCKED: '635' cannot mutate until every depends_on edge is merged or
worktree_removed in the epic checkpoint.`, which is the same checkpoint read from disk.

The observed `EXIT_CODE` of 2 equals the number of failing nodes this artifact names, that set is
exactly the two-member Known-Local-Red Inventory, and no other test failed. The gate therefore
passes and the toolchain loop does not restart at P8-T1.

## Per-suite start tags for the suites this work created or changed

Each element carries no `passed` attribute, so each derived count is `tests` minus every non-passing
count the element carries.

```xml
<testsuite name="...\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1" tests="7" errors="0" failures="0" hostname="MEGALODON4" id="80" skipped="0" disabled="0" package="..." time="0.092">
<testsuite name="...\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1" tests="82" errors="0" failures="0" hostname="MEGALODON4" id="2" skipped="0" disabled="0" package="..." time="1.882">
<testsuite name="...\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="50" errors="0" failures="0" hostname="MEGALODON4" id="13" skipped="0" disabled="0" package="..." time="0.680">
<testsuite name="...\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" tests="49" errors="0" failures="0" hostname="MEGALODON4" id="31" skipped="0" disabled="0" package="..." time="0.572">
```

| Suite | `tests` | Derived passed | Failures | Errors |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | 7 | **7** | 0 | 0 |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 82 | **82** | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 50 | **50** | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 49 | **49** | 0 | 0 |

The two gate-suite counts, 50 and 49, equal the values P3-T11 recorded for the same suites through
the same local MCP route, so the non-widening pin holds unchanged at the end of the loop. In the
`name` and `package` attributes above the repository-root prefix is elided as `...` for width; the
full attribute values are the absolute worktree paths.

The path elision is confined to the per-suite block. The root `testsuites` start tag earlier in this
artifact is transcribed with no elision, and it is the element the recorded totals are derived from.

## Route scope, and what this task is not

This task satisfies the `spec.md` AC-37 toolchain sequence together with P8-T1 and P8-T3. It is
**not** the coverage evidence. `mcp__drm-copilot__run_poshqc_test` reads the installed extension's
PoshQC settings and therefore ignores the `CodeCoverage.Path` entry P6-T3 added to this checkout's
runsettings; P0-T7's artifact measured that directly, recording 96 declared `CodeCoverage.Path`
entries against 88 emitted `sourcefile` elements. The coverage gate is P8-T5, which routes through a
`workflow_dispatch` of `.github/workflows/_poshqc.yml` so the repository's own runsettings are read.

Output Summary: The full local suite ran through `mcp__drm-copilot__run_poshqc_test` with no
`scan_folders` argument and exited 2, the declared expected steady state. Derived from the root
`testsuites` start tag: 4449 passed, 2 failed, 9 skipped, 0 errors. The failing set is exactly the
two-member Known-Local-Red Inventory, named above with the checkpoint mechanism that produces each,
confirmed by the run's own junit XML containing exactly two `status="Failed"` testcases and no
other. All four suites this work created or changed report zero failures and zero errors, with
derived passed counts of 7, 82, 50 and 49. The toolchain loop completed format, analyze and test in
a single pass with no restart. Satisfies AC-37 together with P8-T1 and P8-T3.
