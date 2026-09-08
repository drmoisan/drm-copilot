# Baseline PowerShell Test And Coverage State

Timestamp: 2026-09-08T02-15

Task: [P0-T7]

This artifact supersedes the version written at 2026-09-08T00-20 in place, at the same path. The
earlier version recorded values 5, 6 and 7 from the local MCP route and carried a heading for a
console coverage line that is not observable on either route in use. Values 5,
6 and 7 are now CI-derived, that heading is removed, and the earlier version's blocking-precondition
finding is superseded by the Known-Local-Red Inventory in the plan's toolchain preamble.

## Route deviation, stated before any figure is read

Mandated command (attempted first, refused by the runtime worktree-isolation guard):

`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

The guard refuses every `pwsh` invocation issued through the Bash tool for a worktree-isolated
agent, including a trivial one. No process starts, so the mandated command produced no exit code.
The capture is therefore split into a local half routed through the MCP runner and a CI half routed
through a `workflow_dispatch` of `.github/workflows/_poshqc.yml`, exactly as the plan's toolchain
preamble directs.

Command:
`mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e` and
no `scan_folders` argument, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

The run settings set `Run.Exit = $true`
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`) and `Invoke-PoshQCTest` does not
override it, so the process exit code equals the Pester failed count. The observed code of 2
corresponds to the two failing nodes enumerated in `Local Failing Set:` below, and both are members
of the plan's closed two-member Known-Local-Red Inventory.

## CI half — dispatched run identity

| Field | Value |
| --- | --- |
| Workflow | `.github/workflows/_poshqc.yml` |
| Run id | `34186767775` |
| Head SHA | `d250cf72ee24139735e7f08b07d002ae0e4f1d00` |
| Status | `completed` |
| Conclusion | `success` |

Command: `gh run view 34186767775 --json databaseId,headSha,status,conclusion`, exit status 0.

The recorded head SHA is the epic integration tip this branch is based on and the value [P0-T9]
recorded as `HEAD`, so the CI figures describe the same tree the local half measured.

Command:
`gh run download 34186767775 --name poshqc-test-results --dir artifacts/poshqc-ci/baseline-34186767775`,
exit status 0. The download produced all three uploaded members — `pester-junit.xml`,
`powershell-coverage.xml`, and `powershell-coverage.koverage.xml` — so the upload step ran, which
confirms the Format, Analyze and Test steps all succeeded (`_poshqc.yml:44-52` carries no
`if: always()`). The target directory is distinct from the one [P8-T5] uses, so both runs' coverage
XML survive for [P8-T6] to read.

## Denominator verification, both routes

The plan's toolchain preamble states that `mcp__drm-copilot__run_poshqc_test` resolves its PoshQC
settings from the installed extension's copy, so a `CodeCoverage.Path` entry present only in this
checkout is silently ignored. That was measured rather than assumed on the local half, and it
materialised.

| Route | Distinct `CodeCoverage.Path` entries declared in this checkout | Measured files emitted | Shortfall |
| --- | --- | --- | --- |
| Local MCP | 96 | 88, from `counter type="CLASS" covered="88"` | 8 |
| CI `_poshqc.yml` | 96 | 96, from `counter type="CLASS" covered="96"` | 0 |

The eight entries the local route did not measure are:

```
.claude/hooks/hook-command-invocation.ps1
.claude/hooks/hook-command-scanner.ps1
.codex/hooks/enforce-epic-merge-gate.ps1
.codex/hooks/enforce-epic-worktree-removal-gate.ps1
.codex/hooks/enforce-promotion-mcp-only.ps1
.codex/hooks/hook-command-invocation.ps1
.codex/hooks/hook-command-scanner.ps1
.codex/hooks/validate-bash.ps1
```

All eight were added to the repository runsettings by issue #545, which merged into this branch's
base at `d250cf72`. The CI route measures all 96 because `_poshqc.yml:41-42` imports the
repository's own `PoshQC.psm1`, which binds `$script:PesterSettings` to the repository's
`settings/pester.runsettings.psd1`. This is the observed confirmation that the CI route honours a
`CodeCoverage.Path` entry declared only in this checkout, which is the property [P6-T3] and [P8-T5]
depend on and the property the MCP runner lacks. Values 5, 6 and 7 below are therefore taken from
the CI route.

## Porcelain before and after the local run

Before:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/baseline/
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/qa-gates/phase0-halt-remediation-required.2026-09-08T00-30.md
```

After:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/baseline/
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/qa-gates/phase0-halt-remediation-required.2026-09-08T00-30.md
```

The two captures are identical. `artifacts/` is gitignored (`.gitignore:6`), so neither the files the
local run wrote under `artifacts/pester/` nor the CI download under
`artifacts/poshqc-ci/baseline-34186767775/` appears.

## The seven required values

| # | Value | Route | Measurement |
| --- | --- | --- | --- |
| 1 | Total passed | local | **4352** |
| 2 | Total failed | local | **2** |
| 3 | `enforce-epic-worktree-removal-gate.Tests.ps1` passed | local | **46** |
| 4 | `enforce-parallel-worktree-removal-gate.Tests.ps1` passed | local | **45** |
| 5 | Overall line coverage | CI | **95.4812%** |
| 6 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` line coverage | CI | **94.9495%** |
| 7 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` line coverage | CI | **93.2432%** |

### Values 1 and 2 — local totals, derived

`mcp__drm-copilot__run_poshqc_test` returns a JSON result object and does not relay the module's
console totals line, so no value here is read from console text. The totals are read from the root
`testsuites` start tag of `artifacts/pester/pester-junit.xml` written by this run, transcribed
verbatim:

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4363" errors="0" failures="2" disabled="9" time="166.056">
```

Passed = 4363 - 2 (`failures`) - 0 (`errors`) - 9 (`disabled`) = **4352**. Failed = **2**.

### Values 3 and 4 — local per-suite passed counts, derived

The `testsuite` element carries no `passed` attribute, so each count is derived by subtracting from
`tests` every non-passing count the element carries. The complete start tags are transcribed beside
the derived counts.

Epic gate suite:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="46" errors="0" failures="0" hostname="MEGALODON4" id="12" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" time="0.650">
```

Derived passed = 46 - 0 (`failures`) - 0 (`errors`) - 0 (`skipped`) - 0 (`disabled`) = **46**.

Parallel gate suite:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" tests="45" errors="0" failures="0" hostname="MEGALODON4" id="30" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" time="0.502">
```

Derived passed = 45 - 0 - 0 - 0 - 0 = **45**.

These two local derived counts are the reference values [P3-T11] compares against, because [P3-T11]
runs through the same local MCP route.

### Value 5 — overall line coverage, CI

The report-level `counter` elements, direct children of the root `report` element of
`artifacts/poshqc-ci/baseline-34186767775/powershell-coverage.koverage.xml`, transcribed verbatim:

```
  <counter type="INSTRUCTION" missed="627" covered="11627" />
  <counter type="LINE" missed="400" covered="8452" />
  <counter type="METHOD" missed="35" covered="719" />
  <counter type="CLASS" missed="0" covered="96" />
```

Overall line coverage = 8452 / (8452 + 400) = 8452 / 8852 = **95.4812%**, over the full 96-file
denominator this checkout declares.

### Values 6 and 7 — per-file line coverage for the two gate hooks, CI

Each `sourcefile` element's repo-relative path is the enclosing `package` element's `name` joined to
the `sourcefile` element's `name` with `/`. In the CI-produced `powershell-coverage.koverage.xml` the
`package` `name` attributes are already repo-relative — `Convert-PoshQCCoverageToRelative` ran on the
runner — so no prefix strip is needed. Both gate hooks sit under the package `.claude/hooks`.

| Repo-relative path | LINE `covered` | LINE `missed` | Line coverage | At least 85 |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 | 5 | 94 / 99 = **94.9495%** | **yes** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 | 5 | 69 / 74 = **93.2432%** | **yes** |

Neither value is below 85, so the pre-existing coverage-shortfall branch of this task's blocking
precondition was **not** triggered.

## CI Per-Suite Counts:

Derived from `artifacts/poshqc-ci/baseline-34186767775/pester-junit.xml` by the same subtraction
rule, with the start tags transcribed verbatim.

```
<testsuite name="D:\a\drm-copilot\drm-copilot\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="46" errors="0" failures="0" hostname="runnervmeef0v" id="12" skipped="0" disabled="0" package="D:\a\drm-copilot\drm-copilot\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" time="1.488">
<testsuite name="D:\a\drm-copilot\drm-copilot\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" tests="45" errors="0" failures="0" hostname="runnervmeef0v" id="30" skipped="0" disabled="0" package="D:\a\drm-copilot\drm-copilot\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1" time="0.539">
```

| Suite | CI derived passed | Local derived passed | Equal |
| --- | --- | --- | --- |
| `enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | 46 | **yes** |
| `enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | 45 | **yes** |

The two routes agree on both suites, so no route disagreement is present.

The CI run's root `testsuites` start tag, recorded so the clean-in-CI claim is auditable rather than
asserted:

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4363" errors="0" failures="0" disabled="9" time="182.389">
```

CI passed = 4363 - 0 - 0 - 9 = 4354, CI failed = **0**. The same 4363 tests run on both routes; the
two local failures are absent in CI.

## Local Failing Set:

Two failing nodes, enumerated from the `testcase` elements carrying `status="Failed"` in the local
`artifacts/pester/pester-junit.xml`.

1. Suite file `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, node
   `enforce-pr-author-skill.ps1` > `allowed commands` >
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
   Assertion site line 145, `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`;
   observed `deny`.
   Mechanism: `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:90-111` reads this run's
   own orchestration checkpoint at `artifacts/orchestration/orchestrator-state.json` through a read
   seam this suite does not mock, sees `epic_mode` true, and denies with
   `EPIC_BASE_BRANCH_MISMATCH` because the test's command text carries no `--base`.
2. Suite file `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, node
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` >
   `allows every registered handler for every tool name its own matcher admits`.
   Assertion site line 165; observed `enforce-epic-wave-barrier.ps1` denying every admitted tool
   name with `EPIC_WAVE_BARRIER_BLOCKED: '635' cannot mutate until every depends_on edge is merged
   or worktree_removed in the epic checkpoint.`
   Mechanism: `.codex/hooks/enforce-epic-wave-barrier.ps1:218-220` and `:259` read the same
   checkpoint file, see `epic_mode` true, resolve the feature key, and deny.

Both nodes are members of the closed two-member Known-Local-Red Inventory in the plan's toolchain
preamble, and the observed set contains no third member and no node outside it. The observed
`EXIT_CODE` of 2 equals the number of failing nodes this artifact names. `/artifacts` is gitignored,
so the checkpoint that produces both denials does not exist in CI, which is why the same 4363 tests
report `failures="0"` on run `34186767775`. The baseline is clean in the canonical environment and is
perturbed locally by the named mechanism. The blocking precondition is therefore not triggered: it
fires on a failing node outside the inventory, and no such node was observed.

9 tests are reported as `disabled` on both routes.

## Coverage XML Shape:

One complete `sourcefile` element together with its enclosing `package` start tag, transcribed from
`artifacts/poshqc-ci/baseline-34186767775/powershell-coverage.koverage.xml`, so every later coverage
assertion in this plan is written against an observed format.

```xml
  <package name=".claude/lib/orchestrator-state">
    <sourcefile name="OrchestratorStateUnconditional.psm1">
      <line nr="43" mi="0" ci="1" mb="0" cb="0" />
      <line nr="44" mi="0" ci="1" mb="0" cb="0" />
      <line nr="51" mi="0" ci="2" mb="0" cb="0" />
      <line nr="52" mi="0" ci="2" mb="0" cb="0" />
      <line nr="53" mi="0" ci="2" mb="0" cb="0" />
      <line nr="54" mi="0" ci="2" mb="0" cb="0" />
      <line nr="55" mi="0" ci="2" mb="0" cb="0" />
      <line nr="60" mi="0" ci="1" mb="0" cb="0" />
      <line nr="65" mi="0" ci="1" mb="0" cb="0" />
      <line nr="66" mi="0" ci="1" mb="0" cb="0" />
      <line nr="92" mi="0" ci="1" mb="0" cb="0" />
      <line nr="93" mi="0" ci="2" mb="0" cb="0" />
      <line nr="122" mi="0" ci="1" mb="0" cb="0" />
      <line nr="124" mi="0" ci="1" mb="0" cb="0" />
      <line nr="127" mi="0" ci="2" mb="0" cb="0" />
      <line nr="131" mi="0" ci="2" mb="0" cb="0" />
      <line nr="132" mi="0" ci="2" mb="0" cb="0" />
      <line nr="139" mi="0" ci="1" mb="0" cb="0" />
      <line nr="140" mi="0" ci="1" mb="0" cb="0" />
      <line nr="141" mi="0" ci="1" mb="0" cb="0" />
      <line nr="142" mi="0" ci="1" mb="0" cb="0" />
      <line nr="144" mi="0" ci="2" mb="0" cb="0" />
      <line nr="147" mi="0" ci="2" mb="0" cb="0" />
      <line nr="150" mi="0" ci="2" mb="0" cb="0" />
      <line nr="153" mi="0" ci="2" mb="0" cb="0" />
      <line nr="156" mi="0" ci="2" mb="0" cb="0" />
      <line nr="159" mi="0" ci="2" mb="0" cb="0" />
      <line nr="164" mi="0" ci="1" mb="0" cb="0" />
      <line nr="168" mi="0" ci="1" mb="0" cb="0" />
      <counter type="INSTRUCTION" missed="0" covered="44" />
      <counter type="LINE" missed="0" covered="29" />
      <counter type="METHOD" missed="0" covered="3" />
      <counter type="CLASS" missed="0" covered="1" />
    </sourcefile>
```

The per-line attribute names are `nr`, `mi`, `ci`, `mb`, and `cb`; the per-file totals sit on the
trailing `counter` elements, and `counter type="LINE"` is the element every per-file percentage above
is computed from. The `sourcefile` `name` attribute carries the file name only, with the directory on
the enclosing `package` element, so a repo-relative path is the two joined with `/` and a search for a
full repo-relative path in a `sourcefile` `name` attribute alone would match nothing.

One shape observation is recorded rather than left implicit: the local MCP route wrote only
`pester-junit.xml` and `powershell-coverage.xml` into `artifacts/pester/` and did not write the
relativized `.koverage.xml` copy, and the `package` `name` attributes in the file it did write carry
absolute paths. The CI route calls `Invoke-PoshQCTest` with no `-DisableKoverageCopy` switch
(`_poshqc.yml:42`), so the derivation at `PoshQC.Testing.psm1:402-418` runs, the relativized copy is
produced and uploaded, and the block above needs no prefix strip. This is why the coverage figures
are taken from the CI download.

Output Summary: Baseline captured on both halves. Local half through
`mcp__drm-copilot__run_poshqc_test`: **4352 passed, 2 failed, 9 skipped** of 4363 in 166.056 s, exit
code 2, the two failing nodes being exactly the two members of the plan's Known-Local-Red Inventory
and no others; per-suite derived passed counts **46** and **45**. CI half from the
`workflow_dispatch` of `_poshqc.yml`, run id **34186767775** at head
**d250cf72ee24139735e7f08b07d002ae0e4f1d00**, status `completed`, conclusion `success`: the same 4363
tests report `failures="0"`, per-suite counts **46** and **45** matching local, overall line coverage
**95.4812%** (8452 / 8852) over the full 96-file declared denominator, per-file line coverage
**94.9495%** for `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and **93.2432%** for
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, both at least 85. No blocking
precondition is triggered: no failing node lies outside the inventory and neither per-file coverage
value is below 85.
