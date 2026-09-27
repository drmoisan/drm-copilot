# Final QC Full Pester with Coverage ([P6-T4])

Timestamp: 2026-09-27T07-28
Command: sh <SCRATCHPAD>/x707p6-pester.sh (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1), then sh <SCRATCHPAD>/x707p6-run.sh x707p6-parse (JUnit root and testsuite rows from artifacts/pester/pester-junit.xml; R-COV over artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: Pass 1. Tests Passed: 5416, Failed: 0, Skipped: 9, Inconclusive: 0. JUnit root tests=5425 failures=0 errors=0; no failed or errored testcase. All 15 listed testsuites present with failures 0 and errors 0. Section 4.1 48/48, section 4.2 53/53, section 4.3 6/6 Passed. Coverage: gate 100.00 (covered=164, missed=0); epic-scope sibling 100.00 (covered=44, missed=0); epic-resolution sibling 93.20 (covered=137, missed=10). All three at least 85.

Pass: 1

Run window (local): RUN_START 2026-09-27T07-28-12, RUN_END 2026-09-27T07-32-35 (runner exit code 0).

## Report last-write times

| Report | Last write (local) |
| --- | --- |
| `artifacts/pester/pester-junit.xml` | 2026-09-27T07-32-34 |
| `artifacts/pester/powershell-coverage.xml` | 2026-09-27T07-31-27 |

Both are at or after `Timestamp:` 2026-09-27T07-28.

## Console summary line

```
Tests Passed: 5416, Failed: 0, Skipped: 9, Inconclusive: 0,
```

(The console printed the counts with ANSI colour codes on separate segments; the line above joins the segments with the colour codes removed. The NotRun segment was printed on a later segment and is not part of the joined text above.)

## JUnit root

- root element: `Pester`
- tests: 5425
- failures: 0
- errors: 0

Failed or errored testcases: none

## Listed testsuites

| Test file | tests | failures | errors |
| --- | --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` | 48 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | 53 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 119 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 55 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 11 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 23 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 35 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 56 | 0 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | 3 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | 2 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` | 6 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1` | 9 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` | 4 | 0 | 0 |
| `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` | 5 | 0 | 0 |

Each path matched exactly one testsuite (testsuite `name` ends with `/` plus the path after backslash replacement).

## Section 4.1, 4.2, 4.3 name status

| Section | Expected | Testcases in owning testsuite | Passed |
| --- | --- | --- | --- |
| 4.1 (Suite A) | 48 | 48 | 48 |
| 4.2 (Suite B) | 53 | 53 | 53 |
| 4.3 (Suite C) | 6 | 6 | 6 |

Per-testcase status (testcase `name` as recorded in the JUnit report; status Passed means no `failure`, `error`, or `skipped` child):

```
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-scope for the session-root HEAD matching integration_branch
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-scope for a -C selector worktree whose HEAD matches integration_branch
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason session-root-unresolved for a session root outside any worktree
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an absent epic checkpoint
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an unparseable epic checkpoint
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason epic-checkpoint-absent-or-unparseable for an array-shaped epic checkpoint
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason route_id for a route_id other than epic
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason integration_branch for an empty integration_branch
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason selector-unresolved for a -C selector outside any worktree
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason branch-mismatch for an effective HEAD that differs from integration_branch
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.resolves reason branch-mismatch for a detached HEAD
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.reports MergeInProgress True when the MERGE_HEAD probe returns True
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.reports MergeInProgress False when the MERGE_HEAD probe returns False
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.composes an absolute checkpoint path from the resolved session root
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).Resolve-EpicScopeCheckpoint.declares the fixed head-match signature without Text or MatchWorktreeHead parameters
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns null checkpoint text when the checkpoint file is absent
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns the checkpoint text when the checkpoint file exists
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reads the HEAD branch of a linked worktree through its gitdir file
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reads the HEAD branch of a main checkout through its git directory
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.resolves a relative gitdir target against the worktree root
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no HEAD branch for a detached HEAD
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a missing git entry
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a gitdir file without a gitdir line
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.returns no git directory for a relative worktree root
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.probes MERGE_HEAD in the worktree git directory and reports True
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.probes MERGE_HEAD in the worktree git directory and reports False
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).checkpoint, HEAD, and MERGE_HEAD seams.reports no merge in progress when the worktree has no git directory
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.finds the worktree root by ascending to the first level that carries a git directory
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.finds a linked worktree root whose git entry is a gitdir file
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns no worktree root for a relative start path
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns no worktree root for an ascent that reaches the filesystem root without a git entry
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns a null normalised path for blank input
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.rejects a relative worktree root when composing a path
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for null text
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for whitespace text
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).worktree ascent and path primitives.returns null from the checkpoint parser for a JSON scalar
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness passes for a ready epic checkpoint while a merge is in progress
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names checkpoint-absent for a null checkpoint
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names route_id for a route_id other than epic
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names epic_feature_folder for a missing epic_feature_folder
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names integration_branch for a missing integration_branch
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names features for an empty features array
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness names merge-in-progress for no merge in progress
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness reports the earliest failed conjunct when several fail
CASE: 4.1 | Passed | Codex epic-scope resolution sibling (issue #707).command-leg readiness predicate.command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the command leg of a production path while a merge is in progress
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the apply_patch leg of a production path while a merge is in progress
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope allows the path leg of a production path while a merge is in progress
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope denies the command leg when features is missing and names it and the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names route_id and the epic checkpoint when the resolved scope carries an invalid route_id
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names epic_feature_folder and the epic checkpoint when the resolved scope carries an invalid epic_feature_folder
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names epic_manifest_path and the epic checkpoint when the resolved scope carries an invalid epic_manifest_path
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names integration_branch and the epic checkpoint when the resolved scope carries an invalid integration_branch
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.the epic-scope decision names features and the epic checkpoint when the resolved scope carries an invalid features
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.epic scope decides a -C selector command by the selector worktree HEAD and allows it
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a -C selector command whose selector HEAD differs returns the single-feature decision although the session-root HEAD matches
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the command leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the apply_patch leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with no epic checkpoint the path leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the command leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the apply_patch leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an integration_branch that differs from HEAD the path leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the command leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the apply_patch leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with a missing route_id the path leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the command leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the apply_patch leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.with an empty integration_branch the path leg returns the unchanged single-feature decision and reason
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the command leg is allowed by a ready single-feature checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the apply_patch leg is allowed by a ready single-feature checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.without an epic checkpoint the path leg is allowed by a ready single-feature checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a bookkeeping path operand stays exempt without reading the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope decisions through the gate.a bookkeeping command operand stays exempt without reading the epic checkpoint
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated epic read seam returns an empty string when the epic checkpoint file is absent
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated epic read seam returns the raw epic checkpoint text when the file exists
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).relocated read seams and the no-leg guard.the epic-scope decision returns null without resolving when the call carries neither a command nor a path
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns the selector path for a leading git -C selector
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns no selector for a command without a selector
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).epic-scope selector.the epic-scope selector returns no selector for an unbalanced command line
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.resolves every Codex epic-scope seam name as a function after dot-sourcing the gate
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate.ps1 at or under 500 lines in the repository and the bundle
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 at or under 500 lines in the repository and the bundle
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 at or under 500 lines in the repository and the bundle
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 byte-identical to its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 byte-identical to its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate.ps1 or its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-scope.ps1 or its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-resolution.ps1 or its bundle copy
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
CASE: 4.2 | Passed | Codex preimplementation gate epic scope (issue #707).structure, parity, and interpreter absence.keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept a completion-asserting Write to the epic checkpoint
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept a completion-asserting Edit to the epic checkpoint
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.does not intercept an apply_patch Add of the epic checkpoint
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).epic checkpoint writes are not intercepted.emits no mapped record for an apply_patch Update of the epic checkpoint
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
CASE: 4.3 | Passed | Codex completion-consistency gate epic checkpoint (issue #707).per-feature checkpoint writes are still intercepted.still denies a completion-asserting per-feature checkpoint that lacks ci_gate
```

## Coverage (R-COV)

Package selection: the `package` whose name, after backslash replacement, ends with `/.codex/hooks` and does not contain `extensions/`; each file matched exactly one `sourcefile` (SOURCEFILE_MATCHES 1).

```
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=164 | missed=0
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 100.00 | covered=44 | missed=0
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 93.20 | covered=137 | missed=10
```

Result: each of the three `COVERAGE:` percents is at least 85.

Parser note: the first parser invocation (07-32) printed malformed per-section totals because of an array-flattening defect in the scratchpad parser script; the script was corrected and re-run at 07-33 against the same unchanged reports. The Pester run itself was not repeated, and no repository file changed.
