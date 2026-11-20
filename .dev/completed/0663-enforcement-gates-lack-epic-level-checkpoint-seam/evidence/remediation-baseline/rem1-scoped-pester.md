# Remediation Cycle 1 Scoped Pester Baseline ([P0-T7])

Timestamp: 2026-09-25T21-12
Command: sh <SCRATCHPAD>/rem1/runout.sh sgate-run  (R-SCOPED over the 16 S-GATE files of remediation plan section 6; the resolved list is printed at the top of the output)
EXIT_CODE: 0
Output Summary: Resolved list: 16 entries. PassedCount: 631, FailedCount: 0, FailedBlocksCount: 0, FailedContainersCount: 0. "PASSED: denies D4 row 12c - an output redirection in the segment" and "PASSED: allows a backslash-spelled operand after separator normalization (D4 row 18)" each appear on exactly two lines.

## Runner Output

```
S-GATE resolved entries: 16
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
  tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
  tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
  tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
  tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1

Starting discovery in 16 files.
Discovery found 631 tests in 519ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
 754ms (261ms|363ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
 142ms (72ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
 63ms (28ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
 425ms (254ms|125ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
 1.49s (1.23s|218ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
 702ms (598ms|86ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1
 438ms (314ms|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
 318ms (236ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1
 242ms (143ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
 978ms (777ms|169ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
 316ms (175ms|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
 155ms (81ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
 284ms (179ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1
 10.53s (10.45s|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1
 351ms (271ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1
 96ms (43ms|38ms)
Tests completed in 17.31s
Tests Passed: 631,
Failed: 0,
Skipped: 0,
Inconclusive: 0,

NotRun: 0
PassedCount: 631
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
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
PASSED: returns false for a null tool input
PASSED: returns false for a non-orchestrator subagent type carrying both preparation markers
PASSED: returns false for an orchestrator carrying only one preparation marker
PASSED: returns true for an orchestrator carrying both preparation markers
PASSED: pins the preparation marker set equal to the preparation row of the mode table
PASSED: does not classify a non-orchestrator agent as an implementation delegation
PASSED: allows a non-orchestrator delegation against an unready single-feature checkpoint
PASSED: keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: keeps every surface copy of the helpers module under the 500-line cap
PASSED: denies an orchestrator delegation phrased with "atomic execution" and no mode markers against an unready single-feature checkpoint
PASSED: resolves the preparation mode for its marker prompt
PASSED: resolves the epic mode for its marker prompt
PASSED: resolves the parallel mode for its marker prompt
PASSED: resolves the single-feature mode for its marker prompt
PASSED: evaluates preparation first when an execution marker is also present
PASSED: requires both preparation markers, so a single marker falls through to the default mode
PASSED: resolves the default mode for an empty prompt
PASSED: resolves the default mode for an null prompt
PASSED: maps the preparation mode to its canonical checkpoint path
PASSED: maps the epic mode to its canonical checkpoint path
PASSED: maps the parallel mode to its canonical checkpoint path
PASSED: maps the single-feature mode to its canonical checkpoint path
PASSED: returns an empty checkpoint path for a mode name that is not in the table
PASSED: accepts an absent declared epic checkpoint path
PASSED: accepts an matching declared epic checkpoint path
PASSED: rejects a declared epic checkpoint path that differs from the canonical value
PASSED: rejects a declared parallel checkpoint path that differs from the canonical value
PASSED: accepts a matching declared parallel checkpoint path
PASSED: has nothing to cross-check for a mode carrying no declared-path key
PASSED: returns nothing for a prompt carrying no feature-folder token
PASSED: returns the parent basename for a token ending in a Markdown file
PASSED: returns the basename for a bare directory token
PASSED: returns nothing for a prompt carrying no issue number
PASSED: returns the numeric string for a prompt carrying an keyed issue number
PASSED: returns the numeric string for a prompt carrying an Issue number wording issue number
PASSED: returns the numeric string for a prompt carrying an mixed-prose hash-form issue number
PASSED: selects the later exact folder record in epic readiness
PASSED: selects the later exact folder record in parallel readiness
PASSED: retains first matching issue fallback when no folder matches
PASSED: names route_id as the failed conjunct
PASSED: names epic_feature_folder as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names epic_manifest_path as the failed conjunct
PASSED: names integration_branch as the failed conjunct
PASSED: names features as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: returns a non-empty failure name for a null checkpoint
PASSED: reports no failure for a fully ready epic checkpoint
PASSED: treats an absent merge_status as not_started and does not fail the last conjunct
PASSED: denies the terminal-merged merge status merged (decision D8)
PASSED: denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: allows the failure merge status merge_conflict, which is legitimate remediation (decision D8)
PASSED: allows the failure merge status blocked_conflict_loop_limit, which is legitimate remediation (decision D8)
PASSED: resolves the target by issue_num when no feature-folder basename matches
PASSED: returns false from the wrapper for a null checkpoint
PASSED: names route_id as the failed conjunct
PASSED: names parallel_slug as the failed conjunct
PASSED: names parallel_manifest_path as the failed conjunct
PASSED: names items as the failed conjunct
PASSED: names target-record as the failed conjunct
PASSED: names merge_status as the failed conjunct
PASSED: returns a non-empty failure name for a null checkpoint
PASSED: reports no failure for a fully ready parallel checkpoint
PASSED: denies the terminal-merged merge status merged (decision D8)
PASSED: denies the terminal-merged merge status worktree_removed (decision D8)
PASSED: allows the blocked merge status blocked_drift, adding no member to the parallel enum
PASSED: allows the blocked merge status blocked_ci_loop_limit, adding no member to the parallel enum
PASSED: returns false from the wrapper for a null checkpoint
PASSED: classifies the allow-listed agent python-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent powershell-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent typescript-engineer as an implementation agent
PASSED: classifies the allow-listed agent csharp-typed-engineer as an implementation agent
PASSED: classifies the allow-listed agent atomic-executor as an implementation agent
PASSED: holds exactly five members
PASSED: does not classify orchestrator as an implementation agent
PASSED: does not classify task-researcher as an implementation agent
PASSED: does not classify  as an implementation agent
PASSED: matrix case 1: a ready epic checkpoint allows
PASSED: matrix case 2: empty injected epic content denies, naming the epic checkpoint
PASSED: matrix case 3: a features array lacking the target record denies, naming the failed predicate
PASSED: matrix case 4: a non-canonical declared epic_checkpoint_path denies
PASSED: epic target unresolvable: a prompt with no resolvable target token and no issue number denies
PASSED: decision D8: a target record in a terminal-merged state denies
PASSED: decision D8: a target record in a failure state allows, as legitimate remediation
PASSED: matrix case 5: an epic marker in a non-prompt field resolves to the default single-feature mode
PASSED: matrix case 6a: an allow-listed implementation agent denies against an unready checkpoint whatever its prompt says
PASSED: matrix case 7: both preparation markers exempt the delegation
PASSED: matrix case 8: a standalone orchestrator allows against a ready single-feature checkpoint
PASSED: matrix case 8: a standalone orchestrator denies against an unready single-feature checkpoint
PASSED: a ready parallel checkpoint allows
PASSED: an items array lacking the target record denies, naming the parallel checkpoint
PASSED: a non-canonical declared parallel_checkpoint_path denies
PASSED: denies an unparseable payload
PASSED: denies a payload carrying no tool_input key
PASSED: denies an epic-mode delegation whose injected epic content is empty, with no filesystem read
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
PASSED: epic scope allows git add of a production path while a merge is in progress
PASSED: epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
PASSED: epic scope denies git add of a production path when epic_feature_folder is missing and names it
PASSED: epic scope denies git add of a production path when epic_manifest_path is missing and names it
PASSED: epic scope denies git add of a production path when features is missing and names it
PASSED: a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: epic scope resolves the -C selector worktree for the command leg
PASSED: epic scope allows an Edit of a production path while a merge is in progress
PASSED: epic scope denies a Write of a production path when no merge is in progress
PASSED: without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
PASSED: issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)
PASSED: emits the PreToolUse deny schema (hookEventName + permissionDecision=deny) after serialize-then-parse
PASSED: allows feature documentation writes
PASSED: allows evidence writes
PASSED: allows implementation writes when checkpoint readiness is present, regardless of issue number
PASSED: blocks implementation command payloads before readiness (generalized message)
PASSED: blocks staging and commit command payloads before readiness
PASSED: blocks formatter and test command payloads before readiness
PASSED: blocks implementation delegation payloads before readiness (generalized message)
PASSED: allows implementation operations for any ready workflow state regardless of issue number
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)
PASSED: allows a non-implementation file write (documentation path) without a checkpoint
PASSED: blocks an implementation write when the resolved checkpoint is malformed JSON
PASSED: allows an implementation write when readiness is supplied via path_selected fallback
PASSED: blocks an implementation write when the checkpoint omits the feature folder
PASSED: Test-OrchestrationReady returns false for a null payload
PASSED: Test-ImplementationDelegation returns false for a null tool input
PASSED: allows a Write to every exempt checkpoint literal with no ready checkpoint
PASSED: allows the backslash spelling of every exempt checkpoint literal
PASSED: denies a non-checkpoint .json under artifacts/orchestration/ (literal set, not directory prefix)
PASSED: denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)
PASSED: allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint
PASSED: allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint
PASSED: denies both markers when subagent_type is not orchestrator
PASSED: denies an orchestrator delegation whose prompt matches the implementation regex without the markers
PASSED: denies an orchestrator delegation carrying only one preparation marker
PASSED: denies an orchestrator delegation whose first marker is missing its trailing period
PASSED: denies markers placed in a non-prompt field while prompt matches the implementation regex
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits an allow decision JSON for a documentation write
PASSED: returns exit code 0 and never 1 for unparseable JSON
PASSED: registers the preimplementation gate in active and tracked Claude settings
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
PASSED: resolves epic scope when the --head branch equals integration_branch
PASSED: resolves epic scope when a branch: label equals integration_branch
PASSED: resolves epic scope for a command leg whose -C selector worktree HEAD equals integration_branch
PASSED: resolves epic scope for a command leg without a selector when the session-root HEAD equals integration_branch
PASSED: reports a merge in progress for a head-matched command leg when MERGE_HEAD exists
PASSED: is not epic scope when the epic checkpoint is absent
PASSED: is not epic scope when the epic checkpoint is unparseable
PASSED: is not epic scope when route_id is not epic
PASSED: is not epic scope when integration_branch is empty
PASSED: is not epic scope when the branch signal does not equal integration_branch
PASSED: is not epic scope when the worktree HEAD does not equal integration_branch
PASSED: is not epic scope and reads no checkpoint when there is no branch signal and head matching is off
PASSED: is not epic scope when the session root is not inside a worktree
PASSED: returns an absolute checkpoint path composed from the session worktree root
PASSED: never takes the checkpoint path from text that names another epic checkpoint
PASSED: reads the epic checkpoint through the seam exactly once per resolution
PASSED: returns null checkpoint text when the checkpoint file is absent
PASSED: reads the HEAD branch of a linked worktree through its gitdir file
PASSED: reads the HEAD branch of a main checkout through its git directory
PASSED: returns no HEAD branch for a detached HEAD
PASSED: probes MERGE_HEAD in the worktree git directory
PASSED: lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 in core.json paths
PASSED: lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 in core.json paths
PASSED: lists .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 in core.json paths
PASSED: lists .claude/lib/worktree-resolution/EpicScopeResolution.psm1 in core.json paths
PASSED: lists .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 in core.json paths
PASSED: lists .claude/lib/worktree-resolution/WorktreeResolution.psm1 exactly once
PASSED: lists .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 exactly once
PASSED: lists .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 exactly once
PASSED: lists .claude/lib/worktree-resolution/EpicScopeResolution.psm1 exactly once
PASSED: lists .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 exactly once
PASSED: registers every on-disk worktree-resolution module so none is unregistered
PASSED: mirrors .claude/lib/worktree-resolution/WorktreeResolution.psm1 byte-identically into the bundle
PASSED: mirrors .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 byte-identically into the bundle
PASSED: mirrors .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 byte-identically into the bundle
PASSED: mirrors .claude/lib/worktree-resolution/EpicScopeResolution.psm1 byte-identically into the bundle
PASSED: mirrors .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 byte-identically into the bundle
RSCOPED_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
