# B3 Scoped Pester ([P3-T5])

Timestamp: 2026-09-27T07-08
Command: sh <SCRATCHPAD>/x707p2-rscoped.sh tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: PassedCount 230, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0 across four containers, each with failed=0. Per-container passed values equal those recorded in evidence/qa-gates/b2-scoped-pester.md (absolute-paths 35, command-exemption 119, trigger-scoping 23, epic-scope 53), so the D10 mocks add no test.

Comparison with evidence/qa-gates/b2-scoped-pester.md:

| Test file | B2 passed | B3 passed | B3 failed |
| --- | --- | --- | --- |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | 35 | 35 | 0 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | 119 | 119 | 0 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | 23 | 23 | 0 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | 53 | 53 | 0 |

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T07-08

Starting discovery in 4 files.
Discovery found 230 tests in 231ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1
 837ms (442ms|288ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
 1.19s (994ms|147ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
 270ms (181ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
 1.06s (923ms|119ms)
Tests completed in 3.38s
Tests Passed: 230, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 230
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=35 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=119 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=23 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=53 | failed=0
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
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: issue #663 remediation denies a backslash inside a double-quoted message
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
EXIT_CODE=0
```
