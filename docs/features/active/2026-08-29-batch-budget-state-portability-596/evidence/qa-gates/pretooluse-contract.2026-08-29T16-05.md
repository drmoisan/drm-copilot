# [P6-T4] PreToolUse deny-schema contract suite — unchanged and green

Timestamp: 2026-08-29T22-12

Command: four commands, run in this order:

1. Form A, scoped:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1'"`
2. Form B:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`
3. `git diff --name-only main -- tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`
4. `git status --porcelain tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`

EXIT_CODE: 0

All four commands exited 0.

Output Summary: The PreToolUse deny-schema contract suite runs green after this feature's hook edits
— 15 tests passed, 0 failed — and the suite file itself is unmodified in both tracked and untracked
terms. Both hooks this feature repairs still emit a conforming PreToolUse deny shape. This satisfies
the acceptance criterion at `spec.md:771`.

## Absolute-path prefix actually used

The plan states the commands in worktree-relative form. Each was executed with the working directory
set to the absolute worktree root:

```
cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5 && <plan command text>
```

The `-Root (Get-Location).Path` argument therefore resolved to that same absolute worktree root, as
the Form A output below confirms.

## 1. Form A — scoped Pester run

Process exit code: 0

`Run.Exit = $true` in the settings file makes Pester terminate the process with a non-zero exit code
when the run has failures, so this exit of 0 is a real pass signal rather than an absence of
reporting.

Verbatim output, ANSI colour codes stripped:

```
Starting discovery in 1 files.
Discovery found 15 tests in 165ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 1.35s (863ms|348ms)
Tests completed in 1.37s
Tests Passed: 15, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 8.78% / 0%. 10,849 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

The replayed summary line, quoted verbatim as the acceptance requires:

```
Tests Passed: 15, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Count | Value |
| --- | --- |
| Passed | 15 |
| Failed | **0** |
| Skipped | 0 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is 0, as the acceptance requires.

The coverage figure of 8.78 percent in that output is an artefact of scoping the run to a single
suite while `CodeCoverage.Path` still enumerates the full repository set of 88 files. It is not a
coverage result for this feature and no coverage gate is asserted from this scoped run; the
coverage-bearing runs are [P0-T12] and the Phase 7 tasks.

## 2. Form B — Pester result-file extraction

Process exit code: 0

`artifacts/pester/pester-junit.xml` was present, so the blocked branch in the plan's Form B paragraph
was not taken. The run completed normally rather than exiting inside Pester, which is the case in
which the plan states the result file is written before the replayed summary is printed.

Verbatim output:

```
root=Pester tests=15 failures=0
```

| Field | Value |
| --- | --- |
| root | `Pester` |
| tests | 15 |
| failures | **0** |

The `//testcase[failure]` selector returned no nodes, so no failing test name was printed. The
`failures` count of 0 agrees with the Form A failed count of 0.

## Required `It` blocks present with no `failure` child

The acceptance requires the two named `It` blocks to be recorded as present among the `testcase`
names with no `failure` child. Form B prints only *failing* names, so their absence from its output
is necessary but not sufficient. The full `testcase` list was therefore enumerated with each node's
failure status, so that presence is positively observed rather than inferred from an empty failure
list:

```
ok | PreToolUse deny-schema contract (all 15 hooks).enforce-python-batch-budget.ps1 emits a PreToolUse deny shape
ok | PreToolUse deny-schema contract (all 15 hooks).enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape
```

| Required `It` title | Suite line | Present as a `testcase` | `failure` child |
| --- | --- | --- | --- |
| `enforce-python-batch-budget.ps1 emits a PreToolUse deny shape` | 77 | yes | none |
| `enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape` | 89 | yes | none |

The two suite line numbers cited by the plan were re-derived against the current tree and both hold:

```
77:    It 'enforce-python-batch-budget.ps1 emits a PreToolUse deny shape' {
89:    It 'enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape' {
```

The complete list of all 15 `testcase` names, every one carrying no `failure` child:

```
ok | validate-bash.ps1 emits a PreToolUse deny shape
ok | enforce-promotion-mcp-only.ps1 emits a PreToolUse deny shape
ok | enforce-pr-author-skill.ps1 emits a PreToolUse deny shape
ok | enforce-orchestration-preimplementation-gate.ps1 emits a PreToolUse deny shape
ok | check-python-test-purity.ps1 emits a PreToolUse deny shape
ok | enforce-python-batch-budget.ps1 emits a PreToolUse deny shape
ok | check-powershell-test-purity.ps1 emits a PreToolUse deny shape
ok | enforce-powershell-batch-budget.ps1 emits a PreToolUse deny shape
ok | enforce-evidence-locations.ps1 emits a PreToolUse deny shape
ok | enforce-feature-folder-order.ps1 emits a PreToolUse deny shape
ok | enforce-checkpoint-monotonic.ps1 emits a PreToolUse deny shape
ok | enforce-completion-consistency.ps1 emits a PreToolUse deny shape
ok | enforce-prd-feature-before-planner.ps1 emits a PreToolUse deny shape
ok | enforce-epic-invocation-origin.ps1 emits a PreToolUse deny shape
ok | enforce-mermaid-validation.ps1 emits a PreToolUse deny shape
```

The parent `Describe` is titled `PreToolUse deny-schema contract (all 15 hooks)`; the names above are
given with that prefix removed for readability and are otherwise verbatim.

## 3 and 4. Suite file is unmodified

Both git commands produced empty output and exited 0.

```
$ git diff --name-only main -- tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
(no output)

$ git status --porcelain tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
(no output)
```

The two spans are complementary and the pair is what establishes the claim:

- The anchored `git diff --name-only main` span reports tracked modifications relative to the base
  branch. Its empty output establishes that this feature made no committed change to the suite.
- The `git status --porcelain` span reports working-tree and index state, including untracked files.
  Its empty output establishes that there is no uncommitted or untracked modification of the suite
  that the anchored diff would be blind to.

Together they establish that the contract suite is unmodified in tracked and untracked terms alike,
so its green result is a genuine regression signal about the hooks rather than a suite that was
adjusted to accommodate them.
