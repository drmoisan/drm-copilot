# [P12-T9] Coverage remediation for the five files below the 85 percent line gate

Timestamp: 2026-09-07T16-46

Command:

```
# batch-budget reset 1 (before the first test-file edit in this task)
rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json

# batch-budget reset 2 (after three distinct test files, before the fourth)
rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json

mcp__drm-copilot__run_poshqc_format   (scan_folders: tests/scripts/codex-hooks)
mcp__drm-copilot__run_poshqc_analyze  (scan_folders: tests/scripts/codex-hooks)
mcp__drm-copilot__run_poshqc_test     (scan_folders: tests/scripts/codex-hooks)
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable anywhere in this
session. The plan's `Remove-Item -LiteralPath (Join-Path '.claude/state' (...))` reset form and the
self-hosted PoshQC command could not be executed as written. The reset was performed with `rm -f`
against the identical resolved path, which is the same filesystem effect; the toolchain was run
through the three MCP PoshQC functions. Results were read from
`artifacts/pester/pester-junit.xml`. No coverage figure was measured locally for the four newly
registered files: the MCP test runner resolves its runsettings from the installed VS Code
extension, which does not carry the `CodeCoverage.Path` entries [P4-T10] added, so it cannot report
them. The ending percentages are pending the second CI dispatch of `.github/workflows/_poshqc.yml`.

## Output Summary

Five files were below the 85 percent line-coverage gate in
`evidence/qa-gates/post-change-per-file-coverage.2026-09-07T16-25.md`. **99 named Pester cases**
were added across **five new test files** under `tests/scripts/codex-hooks/`. All 99 pass. No
production hook file was modified, no `CodeCoverage.Path` entry was removed or altered, and no
existing assertion was weakened or deleted.

Toolchain, in order, over `tests/scripts/codex-hooks`:

| Stage | Command | Result |
|---|---|---|
| Format | `mcp__drm-copilot__run_poshqc_format` | `ok: true`; `git status --porcelain` after the run showed no path repaired by the formatter beyond the files this task authored |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` | `ok: true` (zero error-severity diagnostics) |
| Type check | n/a | PowerShell has no type-check stage |
| Test | `mcp__drm-copilot__run_poshqc_test` | 851 tests, 1 failure, 0 errors |

The single failure is `codex-pretooluse-integration.Tests.ps1` ::
`allows every registered handler for every tool name its own matcher admits`, which fails because
`enforce-epic-wave-barrier.ps1` reads the live gitignored
`artifacts/orchestration/orchestrator-state.json` present in this worktree and denies. It is one of
the ambient-state failures recorded earlier in this feature, it is green on the clean CI checkout
(run `34139262327`), and no file this task touched is in its scan path.

## Batch-budget resets

The session id resolves to `worktree-agent-a478b73e41951af31-e3281c7b`, cross-checked against the
file names present in `.claude/state/` at each reset.

| # | Point in the task | Command | EXIT_CODE | Cross-check of `.claude/state/` |
|---|---|---|---|---|
| 1 | before the first test-file edit | `rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json` | 0 | directory was already empty; the last preceding reset was [P10-T16], so the counter was at zero and the deletion removed nothing. Directory empty after. |
| 2 | after three distinct test files, before the fourth | `rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json` | 0 | the file was present under exactly that name, carrying `"testFiles"` with the three paths edited in group 1 and an empty `"prodFiles"`, confirming the resolved id matches what the hook writes. Directory empty after. |

Two groups of test files were edited, so two resets were required and two were performed:

- Group 1: `validate-bash-decision-surface.Tests.ps1`,
  `enforce-promotion-mcp-only-decision-surface.Tests.ps1`,
  `enforce-epic-merge-gate-decision-surface.Tests.ps1`.
- Group 2: `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`,
  `enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`.

## Constraint compliance

| Constraint | Observation |
|---|---|
| No `CodeCoverage.Path` entry removed or altered | `git status --porcelain` lists no change to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` or its bundle mirror |
| No production hook file modified | `git status --porcelain` lists no change under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/resources/` |
| No existing assertion weakened or deleted | every added case is in a NEW file; no existing test file was edited by this task |
| `legacy-codex-hook-contracts.Tests.ps1` did not grow | unchanged, still 494 lines |
| 500-line cap on each new test file | 329, 214, 161, 251, 205 lines |
| Test files mirror the production layout | all five are under `tests/scripts/codex-hooks/` |
| No temporary files, no child processes spawning live executables, no ambient state in assertions | entry-point cases run the hook in process behind a redirected `[System.Console]::In`, restoring the original readers in `finally`; every asserted outcome is invariant to the presence and content of any on-disk checkpoint |

## Remediation detail, per file

### 1. `.codex/hooks/validate-bash.ps1`

- Starting percentage: **39.7260** (covered 29, missed 44)
- Ending percentage: **PENDING the second CI measurement**
- Test file: `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` (new, 329 lines)
- Cases added: 37, all passing

| Case name | Previously-uncovered lines it is intended to reach |
|---|---|
| reports a run that begins part way through the token list | 2 |
| reports no run when the pattern tokens are present but not contiguous | 0 (behavioural reinforcement) |
| reports no run when the token list is shorter than the pattern | 1 |
| reports no run when the last candidate start position fails on its final token | 0 |
| returns the rm -rf literal for a whole-token match | 1 |
| returns the Remove-Item literal for its three-token spelling | 0 |
| returns the four-token git push origin --force literal ahead of any structural value | 0 |
| returns null for an empty command without scanning a segment | 1 |
| returns null for a null command | 0 |
| matches a literal carried on the second segment of a chained command | 0 |
| returns the git push -f literal for a relocating short force spelling | 1 |
| returns the git reset --hard literal for a relocating hard reset | 1 |
| allows a relocating soft reset because --hard is the conjoined flag | 0 |
| allows a relocating push that carries no force flag | 0 |
| reports no structural match directly for a non-git command word | 0 |
| names the matched pattern in the reason text | 3 |
| returns null for a safe command | 1 |
| carries hookEventName PreToolUse, permissionDecision deny, and the supplied reason | 1 |
| carries no legacy top-level decision or reason key | 0 |
| reads the command from well-formed mapped tool_input JSON | 4 |
| falls back to the positional input when the tool_input JSON carries an empty command | 2 |
| treats unparseable raw tool input as the command text itself | 1 |
| returns an empty string when no transport carries a command | 1 |
| returns a deny decision for a blocked command in the mapped tool_input | 4 |
| returns null for a safe command in the mapped tool_input | 1 |
| returns null when every transport is empty | 0 |
| denies a blocked command supplied only through the positional transport | 0 |
| throws for payload text that is only whitespace | 2 |
| throws for malformed JSON | 2 |
| throws when tool_input is absent from an otherwise well-formed envelope | 2 |
| throws when the envelope is not a PreToolUse Bash event | 2 |
| throws when the tool name is not Bash | 0 |
| returns the parsed payload for a well-formed PreToolUse Bash envelope | 1 |
| writes the deny envelope and exits 0 for a blocked command on stdin | 6 |
| writes nothing and exits 0 for a safe command on stdin | 0 |
| writes the reason to stderr and exits 2 for malformed stdin | 2 |
| fails closed with exit 2 and the empty-input reason for whitespace-only stdin | 0 |

Total previously-uncovered lines targeted: **44**, which is the whole missed set for this file.

### 2. `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`

- Starting percentage: **64.7059** (covered 44, missed 24)
- Ending percentage: **PENDING the second CI measurement**
- Test file: `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  (new, 251 lines)
- Cases added: 20, all passing

| Case name | Previously-uncovered lines it is intended to reach |
|---|---|
| returns null rather than throwing for an empty optional source | 2 |
| throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for an empty required source | 1 |
| returns null rather than throwing for a malformed optional source | 1 |
| throws a named EPIC_WORKTREE_REMOVAL_BLOCKED error for a malformed required source | 0 |
| returns the --force marker when the flag is present and no operand follows | 2 |
| returns the empty string for a bare removal that names neither operand nor flag | 0 |
| returns the empty string for a subcommand that is not remove | 0 |
| resolves a relative path against the supplied working directory | 1 |
| keeps a rooted path and trims a trailing separator | 0 |
| returns null for a null checkpoint | 1 |
| returns null for a checkpoint that carries no features array | 1 |
| skips a feature record whose worktree_path is blank and reports no match | 0 |
| returns the matching feature record when the normalized paths agree | 0 |
| returns null for a non-Bash payload | 1 |
| denies an in-scope removal that names no operand at all | 1 |
| falls back to the current location when the payload carries no cwd | 1 |
| allows a removal whose feature record reports worktree_removed | 0 |
| writes nothing and exits 0 for a non-Bash payload on stdin | 9 |
| writes the deny envelope and exits 0 for a removal no epic checkpoint authorizes | 1 |
| writes the reason to stderr and exits 2 for malformed stdin | 2 |

Total previously-uncovered lines targeted: **24**. One of the two branches of the entry point's
multi-line `if (Test-Path ...) { Get-Content } else { '' }` checkpoint read is unreachable in any
single environment, because only one branch runs. `artifacts/orchestration/` is gitignored, so on
the CI checkout the file is absent and the `else` branch runs. That leaves one line expected to
remain uncovered.

### 3. `.codex/hooks/enforce-promotion-mcp-only.ps1`

- Starting percentage: **66.1538** (covered 43, missed 22)
- Ending percentage: **PENDING the second CI measurement**
- Test file: `tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1`
  (new, 214 lines)
- Cases added: 18, all passing

| Case name | Previously-uncovered lines it is intended to reach |
|---|---|
| reports true for a genuine promotion-script invocation | 1 |
| reports false for an ordinary read command | 0 |
| falls back to the legacy promotion-script reason when no reason is supplied | 1 |
| carries the supplied reason verbatim when one is supplied | 0 |
| carries hookEventName PreToolUse and permissionDecision allow with no reason key | 0 |
| allows when the mapped tool_input is absent | 1 |
| allows when the mapped tool_input carries no command text | 1 |
| throws a named error for malformed mapped tool_input JSON | 1 |
| throws for payload text that is only whitespace | 2 |
| throws for malformed JSON | 2 |
| throws when tool_input is absent from an otherwise well-formed envelope | 2 |
| throws when the envelope is not a PreToolUse event | 2 |
| throws when the tool name is not Bash | 0 |
| returns the parsed payload for a well-formed PreToolUse Bash envelope | 1 |
| writes the deny envelope and exits 0 for a gh issue create on stdin | 6 |
| writes nothing and exits 0 for an allowed command on stdin | 0 |
| writes the reason to stderr and exits 2 for malformed stdin | 2 |
| fails closed with exit 2 and the empty-input reason for whitespace-only stdin | 0 |

Total previously-uncovered lines targeted: **22**, which is the whole missed set for this file.

### 4. `.codex/hooks/enforce-epic-merge-gate.ps1`

- Starting percentage: **76.1194** (covered 51, missed 16)
- Ending percentage: **PENDING the second CI measurement**
- Test file: `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`
  (new, 161 lines)
- Cases added: 13, all passing

| Case name | Previously-uncovered lines it is intended to reach |
|---|---|
| throws a named EPIC_MERGE_GATE_BLOCKED error for an empty required source | 1 |
| returns null rather than throwing for an empty optional source | 0 |
| returns null rather than throwing for a malformed optional source | 1 |
| throws a named EPIC_MERGE_GATE_BLOCKED error for a malformed required source | 0 |
| returns the parsed object for a well-formed required source | 0 |
| reports not ready when the epic merge PR carries no ci_gate record | 1 |
| reports not ready when the ci_gate conclusion is not success | 0 |
| reports ready when the ci_gate succeeded and the command names no PR number | 0 |
| reports not ready when epic_mode is the string true rather than the boolean | 0 |
| reports not ready when step9_status is pending | 0 |
| returns null for a Write payload without consulting either checkpoint | 1 |
| writes nothing and exits 0 for a non-Bash payload on stdin | 9 |
| writes the reason to stderr and exits 2 for malformed stdin | 2 |

Total previously-uncovered lines targeted: **15 of 16**. The one line deliberately not targeted is
the entry point's deny-write statement. Reaching it requires the entry point to produce a deny,
which depends on the content of the on-disk `artifacts/orchestration/orchestrator-state.json`
child checkpoint that the entry point reads before the decision seam. An assertion built on that
would pass or fail according to a gitignored file that changes during an orchestration, so it was
not written. Every other entry-point line is reached by the two cases above, both of which return
or throw before either checkpoint can influence the outcome.

### 5. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

- Starting percentage: **84.9398** (covered 141, missed 25)
- Ending percentage: **PENDING the second CI measurement**
- Test file:
  `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`
  (new, 205 lines)
- Cases added: 11, all passing

| Case name | Previously-uncovered lines it is intended to reach |
|---|---|
| allows an epic-mode delegation against an injected ready epic checkpoint | 12 |
| denies an epic-mode delegation and names integration_branch as the failed predicate | 2 |
| denies an epic-mode delegation whose injected checkpoint text is malformed JSON | 1 |
| denies an epic-mode delegation whose injected checkpoint text is empty | 0 |
| denies an epic-mode delegation that declares a non-canonical checkpoint path | 2 |
| allows a parallel-mode delegation against an injected ready parallel checkpoint | 1 |
| denies a parallel-mode delegation and names parallel_slug as the failed predicate | 0 |
| denies a parallel-mode delegation whose injected checkpoint declares the epic route | 0 |
| denies an epic-mode delegation against the canonical epic checkpoint read seam | 4 |
| denies a parallel-mode delegation against the canonical parallel checkpoint read seam | 3 |
| allows a research delegation that carries the epic marker | 0 |

Total previously-uncovered lines targeted: **23 of 25**. The two not targeted are the `Get-Content`
statements inside `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent`. Each runs only
when its canonical checkpoint file exists. `artifacts/orchestration/` is gitignored, so on the CI
checkout neither file exists and the `return ''` branch runs instead. Reaching the `Get-Content`
branch would require creating those files, which the no-temporary-files rule forbids and which
would also make the surrounding assertion depend on their content.

Local corroboration for this file only: the folder-scoped MCP test run over
`tests/scripts/codex-hooks` measured this file at **164 of 166 lines covered**, with only the two
`Get-Content` lines missed. This file is registered in the installed extension's runsettings, so
the MCP runner reports it; the other four files in this task are not, which is why no local figure
exists for them. This local number is a corroborating observation from a partial-folder run, not
the ending figure the acceptance criterion requires.

## Acceptance status

This task's acceptance requires an ENDING percentage at or above 85 for each of the five files.
That figure can only come from the second CI dispatch of `.github/workflows/_poshqc.yml` against
the pushed branch, which the orchestrator performs after this delegation. **[P12-T9] is therefore
recorded here as incomplete and is left unchecked in the plan.** The starting percentages, the case
names, and the targeted line counts required by the task are all recorded above; only the ending
column is outstanding.
