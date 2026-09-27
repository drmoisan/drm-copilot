# B2 Scoped Pester ([P2-T8])

Timestamp: 2026-09-27T07-02
Command: sh <SCRATCHPAD>/x707p2-rscoped.sh <the eleven test files named by [P2-T8]> (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: PassedCount 448, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0 across eleven containers, each with failed=0 (Suite A 48, Suite B 53). The ten names listed as FAILED in regression-testing/fail-before-b2-gate.md all appear on PASSED lines.

Launcher note: the Phase 1 launcher `x707p1-rscoped.sh` passed its arguments after `-TestPath`, and `-File` binds only one value to that parameter, so a first launch at 2026-09-27T07-02 exited 1 with `A positional parameter cannot be found` before Pester ran. `x707p2-rscoped.ps1` is the same R-SCOPED body with the parameter declared `ValueFromRemainingArguments`; `x707p2-rscoped.sh` passes the paths without the parameter name.

Test files (in run order):

- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
- tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
- tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
- tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T07-02

Starting discovery in 11 files.
Discovery found 448 tests in 379ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
 1.25s (810ms|329ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
 1.03s (888ms|99ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
 1.03s (842ms|151ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
 281ms (161ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
 142ms (82ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
 242ms (171ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1
 208ms (106ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1
 23.22s (23.13s|66ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1
 10.22s (10.16s|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1
 12.95s (12.92s|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
 37ms (8ms|19ms)
Tests completed in 50.63s
Tests Passed: 448, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 448
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=48 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=53 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=119 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | passed=2 | failed=0
PASSED: resolves reason epic-scope for the session-root HEAD matching integration_branch
PASSED: resolves reason epic-scope for a -C selector worktree whose HEAD matches integration_branch
PASSED: resolves reason session-root-unresolved for a session root outside any worktree
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an absent epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an unparseable epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an array-shaped epic checkpoint
PASSED: resolves reason route_id for a route_id other than epic
PASSED: resolves reason integration_branch for an empty integration_branch
PASSED: resolves reason selector-unresolved for a -C selector outside any worktree
PASSED: resolves reason branch-mismatch for an effective HEAD that differs from integration_branch
PASSED: resolves reason branch-mismatch for a detached HEAD
PASSED: reports MergeInProgress True when the MERGE_HEAD probe returns True
PASSED: reports MergeInProgress False when the MERGE_HEAD probe returns False
PASSED: composes an absolute checkpoint path from the resolved session root
PASSED: consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
PASSED: declares the fixed head-match signature without Text or MatchWorktreeHead parameters
PASSED: returns null checkpoint text when the checkpoint file is absent
PASSED: returns the checkpoint text when the checkpoint file exists
PASSED: reads the HEAD branch of a linked worktree through its gitdir file
PASSED: reads the HEAD branch of a main checkout through its git directory
PASSED: resolves a relative gitdir target against the worktree root
PASSED: returns no HEAD branch for a detached HEAD
PASSED: returns no git directory for a missing git entry
PASSED: returns no git directory for a gitdir file without a gitdir line
PASSED: returns no git directory for a relative worktree root
PASSED: probes MERGE_HEAD in the worktree git directory and reports True
PASSED: probes MERGE_HEAD in the worktree git directory and reports False
PASSED: reports no merge in progress when the worktree has no git directory
PASSED: finds the worktree root by ascending to the first level that carries a git directory
PASSED: finds a linked worktree root whose git entry is a gitdir file
PASSED: returns no worktree root for a relative start path
PASSED: returns no worktree root for an ascent that reaches the filesystem root without a git entry
PASSED: normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
PASSED: returns a null normalised path for blank input
PASSED: rejects a relative worktree root when composing a path
PASSED: returns null from the checkpoint parser for null text
PASSED: returns null from the checkpoint parser for whitespace text
PASSED: returns null from the checkpoint parser for a JSON scalar
PASSED: command-leg readiness passes for a ready epic checkpoint while a merge is in progress
PASSED: command-leg readiness names checkpoint-absent for a null checkpoint
PASSED: command-leg readiness names route_id for a route_id other than epic
PASSED: command-leg readiness names epic_feature_folder for a missing epic_feature_folder
PASSED: command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
PASSED: command-leg readiness names integration_branch for a missing integration_branch
PASSED: command-leg readiness names features for an empty features array
PASSED: command-leg readiness names merge-in-progress for no merge in progress
PASSED: command-leg readiness reports the earliest failed conjunct when several fail
PASSED: command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
PASSED: epic scope allows the command leg of a production path while a merge is in progress
PASSED: epic scope allows the apply_patch leg of a production path while a merge is in progress
PASSED: epic scope allows the path leg of a production path while a merge is in progress
PASSED: epic scope denies the command leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the apply_patch leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the path leg of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies the command leg when epic_feature_folder is missing and names it and the epic checkpoint
PASSED: epic scope denies the command leg when epic_manifest_path is missing and names it and the epic checkpoint
PASSED: epic scope denies the command leg when features is missing and names it and the epic checkpoint
PASSED: the epic-scope decision names route_id and the epic checkpoint when the resolved scope carries an invalid route_id
PASSED: the epic-scope decision names epic_feature_folder and the epic checkpoint when the resolved scope carries an invalid epic_feature_folder
PASSED: the epic-scope decision names epic_manifest_path and the epic checkpoint when the resolved scope carries an invalid epic_manifest_path
PASSED: the epic-scope decision names integration_branch and the epic checkpoint when the resolved scope carries an invalid integration_branch
PASSED: the epic-scope decision names features and the epic checkpoint when the resolved scope carries an invalid features
PASSED: epic scope decides a -C selector command by the selector worktree HEAD and allows it
PASSED: a -C selector command whose selector HEAD differs returns the single-feature decision although the session-root HEAD matches
PASSED: with no epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with no epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the command leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an integration_branch that differs from HEAD the path leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the command leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with a missing route_id the path leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the command leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the apply_patch leg returns the unchanged single-feature decision and reason
PASSED: with an empty integration_branch the path leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the command leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the apply_patch leg is allowed by a ready single-feature checkpoint
PASSED: without an epic checkpoint the path leg is allowed by a ready single-feature checkpoint
PASSED: a bookkeeping path operand stays exempt without reading the epic checkpoint
PASSED: a bookkeeping command operand stays exempt without reading the epic checkpoint
PASSED: the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: the epic-scope selector returns the selector path for a leading git -C selector
PASSED: the epic-scope selector returns no selector for a command without a selector
PASSED: the epic-scope selector returns no selector for an unbalanced command line
PASSED: resolves every Codex epic-scope seam name as a function after dot-sourcing the gate
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 at or under 500 lines in the repository and the bundle
PASSED: keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 byte-identical to its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 byte-identical to its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-scope.ps1 or its bundle copy
PASSED: reports no interpreter invocation in enforce-orchestration-preimplementation-gate-epic-resolution.ps1 or its bundle copy
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-scope.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: keeps enforce-orchestration-preimplementation-gate-epic-resolution.ps1 free of interpreter-name tokens and declares the predicate PowerShell-authoritative
PASSED: allows staging an epic document under the epics tree
PASSED: allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: allows a quoted operand under the active feature tree
PASSED: allows a backslash-spelled operand after separator normalization (D4 row 18)
PASSED: allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: allows a chained two-segment line whose every segment is independently exempt
PASSED: allows staging a lifecycle record under the potential feature tree
PASSED: denies an exempt operand paired with a .ps1 production operand
PASSED: denies an exempt operand paired with a .py production operand
PASSED: denies an exempt operand paired with a .ts production operand
PASSED: denies an exempt operand paired with a .cs production operand
PASSED: denies D4 row 1 - bare staging with zero operands
PASSED: denies D4 row 2a - the tree-wide short all flag
PASSED: denies D4 row 2b - the tree-wide long all flag
PASSED: denies D4 row 2c - the update short flag with an exempt operand
PASSED: denies D4 row 2d - the update long flag
PASSED: denies D4 row 2e - the no-all flag with an exempt operand
PASSED: denies D4 row 3a - the dot whole-tree operand
PASSED: denies D4 row 3b - the colon-slash whole-tree operand
PASSED: denies D4 row 4 - a pathless message-only integration invocation
PASSED: denies D4 row 5a - the content-widening short all option
PASSED: denies D4 row 5b - the content-widening long all option
PASSED: denies D4 row 5c - the include short option
PASSED: denies D4 row 5d - the include long option
PASSED: denies D4 row 5e - the interactive long option
PASSED: denies D4 row 5f - the patch short option
PASSED: denies D4 row 5g - the history-rewriting amend option
PASSED: denies D4 row 6a - pathspecs supplied from a file
PASSED: denies D4 row 6b - the nul-delimited pathspec file option
PASSED: denies D4 row 7 - a double-dash separator with nothing after it
PASSED: denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: denies D4 row 9a - the exclude pathspec magic operand
PASSED: denies D4 row 9b - the bang shorthand exclude operand
PASSED: denies D4 row 9c - the top pathspec magic operand
PASSED: denies D4 row 9d - the glob pathspec magic operand
PASSED: denies D4 row 9e - the icase pathspec magic operand
PASSED: denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: denies D4 row 12b - a backtick substitution inside an operand
PASSED: denies D4 row 12c - an output redirection in the segment
PASSED: denies D4 row 12d - an input redirection in the segment
PASSED: denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: denies D4 row 14c - a git-dir option before the subcommand
PASSED: denies D4 row 14d - a work-tree option before the subcommand
PASSED: denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: denies a message-body payload that merely contains the staging literal
PASSED: denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: allows issue #671 LACS allow 3 - backslash-spelled absolute selector normalized before the rooting test
PASSED: allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: denies issue #671 LACS L1a - attached selector spelling
PASSED: denies issue #671 LACS L1b - config-injection selector
PASSED: denies issue #671 LACS L2 - repeated selector
PASSED: denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: denies issue #671 LACS L4a - bare relative selector
PASSED: denies issue #671 LACS L4b - UNC selector
PASSED: denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: denies issue #671 LACS L6 - wildcard in the selector
PASSED: denies issue #671 LACS L7 - stray colon in the selector
PASSED: denies issue #671 LACS L8 - empty selector value
PASSED: denies issue #671 selector followed by an unmodelled subcommand
PASSED: denies issue #671 selector with a non-exempt pathspec operand
PASSED: denies issue #671 selector with the tree-wide all flag
PASSED: denies issue #671 selector with an absolute pathspec operand
PASSED: denies issue #671 selector with an output redirection
PASSED: denies issue #671 cd chain into the target worktree
PASSED: allows issue #671 empty commit message beside an exempt operand
PASSED: denies issue #671 empty token beside a non-exempt operand
PASSED: denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: denies issue #671 trailing empty token after a non-exempt operand
PASSED: denies issue #671 empty commit message beside a non-exempt operand
PASSED: accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: rejects issue #671 predicate L1a - single token segment
PASSED: rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: rejects issue #671 predicate L2 - repeated selector
PASSED: rejects issue #671 predicate L3a - no token after the selector value
PASSED: rejects issue #671 predicate L3b - option token after the selector value
PASSED: rejects issue #671 predicate L4a - relative selector
PASSED: rejects issue #671 predicate L4b - UNC selector
PASSED: rejects issue #671 predicate L5a - parent-directory segment
PASSED: rejects issue #671 predicate L5b - current-directory segment
PASSED: rejects issue #671 predicate L6 - wildcard
PASSED: rejects issue #671 predicate L7 - stray colon
PASSED: rejects issue #671 predicate L8 - empty selector value
PASSED: returns false when segment classification raises an error
PASSED: issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: issue #663 exempts a single-quoted message carrying angle brackets
PASSED: issue #663 denies the single-quoted apostrophe idiom
PASSED: issue #663 denies a command substitution inside a double-quoted message
PASSED: issue #663 denies a variable expansion inside a double-quoted message
PASSED: issue #663 denies a backtick substitution inside a double-quoted message
PASSED: issue #663 denies a pathless commit whose message carries angle brackets
PASSED: issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: issue #663 remediation denies a backslash inside a double-quoted message
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the epic mode for its marker prompt
PASSED: resolves the parallel mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: maps the preparation mode to its canonical checkpoint path
PASSED: maps the epic mode to its canonical checkpoint path
PASSED: maps the parallel mode to its canonical checkpoint path
PASSED: maps the single-feature mode to its canonical checkpoint path
PASSED: returns an empty checkpoint path for a mode name that is not in the table
PASSED: accepts the declared checkpoint path for epic mode
PASSED: accepts the declared checkpoint path for epic mode
PASSED: rejects the declared checkpoint path for epic mode
PASSED: accepts the declared checkpoint path for parallel mode
PASSED: rejects the declared checkpoint path for parallel mode
PASSED: returns nothing for a prompt carrying no feature-folder token
PASSED: returns the parent basename for a token ending in a Markdown file
PASSED: returns the basename for a bare directory token
PASSED: returns the basename for a token followed by sentence punctuation
PASSED: returns nothing for a prompt carrying no issue number
PASSED: returns the numeric string for a keyed issue number
PASSED: returns the numeric string for a bare-hash issue number
PASSED: builds an epic deny reason naming the epic checkpoint and the failed predicate
PASSED: builds a parallel deny reason naming the parallel checkpoint and the failed predicate
PASSED: names route_id as the failed conjunct
PASSED: names epic_feature_folder as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names integration_branch as the failed conjunct
PASSED: names features as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: reports ready for the epic readiness wrapper
PASSED: denies the terminal-merged worktree_removed status for the epic readiness wrapper
PASSED: allows the failure status blocked_conflict_loop_limit for the epic readiness wrapper
PASSED: returns false from the wrapper for a null checkpoint
PASSED: names route_id as the failed conjunct
PASSED: names parallel_slug as the failed conjunct
PASSED: names parallel_manifest_path as the failed conjunct
PASSED: names items as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: reports ready for the parallel readiness wrapper
PASSED: denies the terminal-merged worktree_removed status for the parallel readiness wrapper
PASSED: allows the blocked status blocked_drift, adding no enum member for the parallel readiness wrapper
PASSED: returns false from the wrapper for a null checkpoint
PASSED: classifies atomic-executor as implementation: True
PASSED: classifies powershell-typed-engineer as implementation: True
PASSED: classifies task-researcher as implementation: False
PASSED: classifies orchestrator as implementation: False
PASSED: classifies orchestrator as implementation: True
PASSED: returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface
PASSED: returns true for an orchestrator carrying both preparation markers on the Codex surface
PASSED: registers no PreToolUse matcher admitting an Agent or Task tool name
PASSED: allows an epic-mode delegation against an injected ready epic checkpoint
PASSED: denies an epic-mode delegation and names integration_branch as the failed predicate
PASSED: denies an epic-mode delegation whose injected checkpoint text is malformed JSON
PASSED: denies an epic-mode delegation whose injected checkpoint text is empty
PASSED: denies an epic-mode delegation that declares a non-canonical checkpoint path
PASSED: allows a parallel-mode delegation against an injected ready parallel checkpoint
PASSED: denies a parallel-mode delegation and names parallel_slug as the failed predicate
PASSED: denies a parallel-mode delegation whose injected checkpoint declares the epic route
PASSED: denies an epic-mode delegation against the canonical epic checkpoint read seam
PASSED: denies a parallel-mode delegation against the canonical parallel checkpoint read seam
PASSED: allows a research delegation that carries the epic marker
PASSED: allows a quoted mention of the staging invocation inside an echo argument
PASSED: allows a heredoc body that quotes the staging invocation in prose
PASSED: allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: allows prose containing the English word black
PASSED: allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: denies a relocating git add carrying a directory global option
PASSED: denies a relocating git commit carrying a git-dir global option
PASSED: denies a relocating git add carrying a work-tree global option
PASSED: denies an unmodeled dash-leading token between git and its subcommand
PASSED: denies the subshell spelling of a staging command
PASSED: denies the command-substitution spelling of a staging command
PASSED: does not classify git log --grep add as a staging command
PASSED: wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: still classifies an apply_patch add of a production script
PASSED: still declines to classify an apply_patch add of feature documentation
PASSED: still classifies an apply_patch rename onto a production script
PASSED: still declines to classify an apply_patch update of feature documentation
PASSED: allows the repo-relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/parallel-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-planner-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/epic-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/powershell-orchestrator-state.json
PASSED: allows the repo-relative spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the forward-slash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: allows the backslash absolute spelling of artifacts/orchestration/csharp-orchestrator-state.json
PASSED: admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json
PASSED: admits the leading dot-slash relative spelling of artifacts/orchestration/orchestrator-state.json
PASSED: allows the repo-relative spelling of a feature-folder .json artifact
PASSED: allows the forward-slash absolute spelling of a feature-folder .json artifact
PASSED: allows the backslash absolute spelling of a feature-folder .json artifact
PASSED: allows an absolute checkpoint path whose literal differs only in letter case
PASSED: denies an absolute path whose documentation prefix differs only in letter case
PASSED: denies a synthetic absolute path ending in a production .ps1 file
PASSED: denies a synthetic absolute path ending in a production .py file
PASSED: denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals
PASSED: denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment
PASSED: denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop
PASSED: denies a repo-relative file-marker path for a production .ps1 file
PASSED: allows a repo-relative file-marker path for a checkpoint literal
PASSED: allows a safe Edit payload on every group handler
PASSED: allows a safe Write payload on every group handler
PASSED: allows a safe apply_patch payload on every group handler
PASSED: allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'')
PASSED: allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'noop')
PASSED: fails closed with exit 2 when a batch-budget payload omits session_id
PASSED: allows an apply_patch update that touches only ungoverned files with a missing source
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for check-python-test-purity.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for check-powershell-test-purity.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-evidence-locations.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-checkpoint-monotonic.ps1 on a forbidden Edit payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Write payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden apply_patch payload
PASSED: emits only the native deny envelope for enforce-completion-consistency.ps1 on a forbidden Edit payload
PASSED: denies a preimplementation-gate implementation path mapped from Edit
PASSED: denies a preimplementation-gate implementation path mapped from Write
PASSED: denies a preimplementation-gate implementation path mapped from apply_patch
PASSED: fails closed with exit 2 for a missing tool_input on every group handler
PASSED: fails closed with exit 2 for a null tool_input on every group handler
PASSED: returns null checkpoint content when the path is not a file
PASSED: returns the file text when the checkpoint path resolves to a file
PASSED: returns an empty string for a null checkpoint payload property lookup
PASSED: returns an empty string when the checkpoint property value is null
PASSED: treats a null payload as asserting no completion
PASSED: detects completion asserted by next_step
PASSED: detects completion asserted by completed_steps
PASSED: detects completion asserted by step8_status
PASSED: detects completion asserted by step9_status
PASSED: detects completion asserted by step10_status
PASSED: detects no completion assertion for an in-progress next_step
PASSED: detects no completion assertion for completed_steps without the terminal step
PASSED: detects no completion assertion for an empty completed_steps list
PASSED: detects no completion assertion for an in-progress step8_status
PASSED: returns null edited content when the tool input carries no old_string
PASSED: returns null edited content when the on-disk checkpoint is empty
PASSED: returns null edited content when the old_string is absent from the checkpoint
PASSED: applies the old_string to new_string replacement in memory
PASSED: reads the governed checkpoint path through the injected reader
PASSED: allows when no mapped tool_input is supplied
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows mapped tool_input that carries no file_path
PASSED: allows a file path that is not the governed checkpoint
PASSED: denies a checkpoint edit whose patch cannot be resolved
PASSED: allows a checkpoint write that does not assert completion
PASSED: denies a completion-asserting checkpoint write through its own entrypoint
PASSED: allows an unrelated mapped write through its own entrypoint
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: reads issue-num and feature-folder from variables and reports ci_gate gaps
PASSED: parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: keeps the canonical hooks byte-identical to their bundled copies
PASSED: reads stdin in every hook entrypoint
PASSED: contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: lists every shared hook module in the core pack manifest
PASSED: ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: emits the current PreToolUse deny envelope for shell and patch violations
PASSED: fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: denies preimplementation and batch-budget violations through their pure decisions
PASSED: allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: reconstructs update patches in memory and includes move destinations
PASSED: uses one SubagentStop continuation and stops repeated continuation loops
PASSED: classifies a feature documentation path as implementation path False
PASSED: classifies the orchestrator checkpoint as implementation path False
PASSED: classifies a production script as implementation path True
PASSED: classifies a plain text file as implementation path False
PASSED: classifies an empty command as implementation command False
PASSED: classifies an apply_patch add of a script as implementation command True
PASSED: classifies an apply_patch add of documentation as implementation command False
PASSED: classifies an apply_patch rename onto a script as implementation command True
PASSED: classifies a git commit as implementation command True
PASSED: classifies a pytest run as implementation command True
PASSED: classifies an unrelated command as implementation command False
PASSED: treats a null tool_input as no implementation delegation
PASSED: detects an implementation delegation inside a serialized tool_input
PASSED: treats an unrelated serialized tool_input as no delegation
PASSED: treats a null checkpoint payload as not ready
PASSED: treats a checkpoint missing lifecycle readiness as not ready
PASSED: treats a complete checkpoint as ready
PASSED: returns empty checkpoint content when the checkpoint file is absent
PASSED: returns the checkpoint file content when the checkpoint file is present
PASSED: allows when no mapped tool_input is supplied
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows a documentation file path without consulting the checkpoint
PASSED: denies an implementation command when the checkpoint is not ready
PASSED: denies an implementation delegation when the checkpoint is not ready
PASSED: allows an implementation path when the checkpoint is ready
PASSED: reads the checkpoint from disk when no checkpoint text is supplied
PASSED: denies an apply_patch implementation through its own entrypoint
PASSED: denies a mapped Edit implementation through its own entrypoint
PASSED: allows a mapped Write of feature documentation through its own entrypoint
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: derives 17 PreToolUse hooks and excludes 4 non-PreToolUse registrations from the bundle config
PASSED: returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location
PASSED: leaves no batch-budget state in the bundle
PASSED: keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the helpers module under the 500-line cap
EXIT_CODE=0
```
