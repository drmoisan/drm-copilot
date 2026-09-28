# Batch 1 Existing-Suite Check: CommandExemption (Issue #710)

Timestamp: 2026-09-27T02-13
Command: sh <SCRATCHPAD>/p2-exemption.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/p2-exemption.ps1: R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1)
EXIT_CODE: 0
Output Summary: PassedCount 238, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. No FAILED lines. The Parity suite was not run (rule 10: the four helper copies differ between batches).

B_SCOPED entries for these two files: none (B_SCOPED is empty).

## Runner Output

```text
PassedCount: 238
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging an epic document under the epics tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a quoted operand under the active feature tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a backslash-spelled operand after separator normalization (D4 row 18)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a chained two-segment line whose every segment is independently exempt
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a lifecycle record under the potential feature tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ps1 production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .py production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ts production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .cs production operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 1 - bare staging with zero operands
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2a - the tree-wide short all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2b - the tree-wide long all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2c - the update short flag with an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2d - the update long flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2e - the no-all flag with an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3a - the dot whole-tree operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3b - the colon-slash whole-tree operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 4 - a pathless message-only integration invocation
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5a - the content-widening short all option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5b - the content-widening long all option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5c - the include short option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5d - the include long option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5e - the interactive long option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5f - the patch short option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5g - the history-rewriting amend option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6a - pathspecs supplied from a file
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6b - the nul-delimited pathspec file option
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 7 - a double-dash separator with nothing after it
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9a - the exclude pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9b - the bang shorthand exclude operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9c - the top pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9d - the glob pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9e - the icase pathspec magic operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12b - a backtick substitution inside an operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12c - an output redirection in the segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12d - an input redirection in the segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14c - a git-dir option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14d - a work-tree option before the subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies a message-body payload that merely contains the staging literal
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 3 - backslash-spelled absolute selector normalized before the rooting test
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1a - attached selector spelling
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1b - config-injection selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L2 - repeated selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4a - bare relative selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4b - UNC selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L6 - wildcard in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L7 - stray colon in the selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector followed by an unmodelled subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with a non-exempt pathspec operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with the tree-wide all flag
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an absolute pathspec operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an output redirection
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 cd chain into the target worktree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.allows issue #671 empty commit message beside an exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 trailing empty token after a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty commit message beside a non-exempt operand
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1a - single token segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L2 - repeated selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3a - no token after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3b - option token after the selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4a - relative selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4b - UNC selector
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5a - parent-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5b - current-directory segment
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L6 - wildcard
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L7 - stray colon
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L8 - empty selector value
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 selector predicate and fail-closed guard.returns false when segment classification raises an error
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a single-quoted message carrying angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies the single-quoted apostrophe idiom
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a command substitution inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a variable expansion inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a backtick substitution inside a double-quoted message
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a pathless commit whose message carries angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging an epic document under the epics tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a quoted operand under the active feature tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a backslash-spelled operand after separator normalization (D4 row 18)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a kickoff markdown file under the orchestration artifacts tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows the pathspec-bearing integration form with a message option and a double-dash separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a chained two-segment line whose every segment is independently exempt
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a lifecycle record under the potential feature tree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ps1 production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .py production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .ts production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 mixed pathspec deny cases.denies an exempt operand paired with a .cs production operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 1 - bare staging with zero operands
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2a - the tree-wide short all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2b - the tree-wide long all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2c - the update short flag with an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2d - the update long flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 2e - the no-all flag with an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3a - the dot whole-tree operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 3b - the colon-slash whole-tree operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 4 - a pathless message-only integration invocation
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5a - the content-widening short all option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5b - the content-widening long all option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5c - the include short option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5d - the include long option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5e - the interactive long option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5f - the patch short option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 5g - the history-rewriting amend option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6a - pathspecs supplied from a file
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 6b - the nul-delimited pathspec file option
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 7 - a double-dash separator with nothing after it
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 8 - an unmodeled dash-leading option before the separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9a - the exclude pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9b - the bang shorthand exclude operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9c - the top pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9d - the glob pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 9e - the icase pathspec magic operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 10 - a leading-dash operand with no preceding separator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 11 - an unbalanced quote around an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12a - a dollar-sign interpolation inside an operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12b - a backtick substitution inside an operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12c - an output redirection in the segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 12d - an input redirection in the segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13a - a chained line whose second segment is not exempt
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 13b - unsplittable text whose quote spans the chain operator
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14a - an environment-style prefix relocating the pathspec base
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14b - a directory-relocating option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14c - a git-dir option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 14d - a work-tree option before the subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15a - a glob whose literal prefix stops above the exempt trees
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15b - a glob whose wildcard occupies an ancestor segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 15c - a glob carrying a parent-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16a - an absolute operand in the leading-slash spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16b - an absolute operand in the drive-letter spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 16c - an absolute operand in the UNC spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 17 - a parent-directory segment inside an otherwise exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 fail-closed rule table deny cases.denies D4 row 19 - a mixed operand set of one exempt and one production path
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies a message-body payload that merely contains the staging literal
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 residual whole-command-text behaviour (D3 and D8).denies the same heredoc body when it feeds a shell wrapper instead of a file
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 3 - backslash-spelled absolute selector normalized before the rooting test
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 4 - absolute selector on the message-bearing commit form
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector allow cases.allows issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1a - attached selector spelling
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L1b - config-injection selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L2 - repeated selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4a - bare relative selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L4b - UNC selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5a - parent-directory segment in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L5b - current-directory segment in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L6 - wildcard in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L7 - stray colon in the selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector followed by an unmodelled subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with a non-exempt pathspec operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with the tree-wide all flag
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an absolute pathspec operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 selector with an output redirection
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 cd chain into the target worktree
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.allows issue #671 empty commit message beside an exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty token after the separator beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 trailing empty token after a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 empty-token fail-closed cases.denies issue #671 empty commit message beside a non-exempt operand
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 1 - drive-letter selector followed by add
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 2 - rooted selector followed by commit
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.accepts issue #671 predicate accept 3 - non-option token after the value is left to the caller
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1a - single token segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L1b - option other than the selector at index 1
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L2 - repeated selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3a - no token after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L3b - option token after the selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4a - relative selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L4b - UNC selector
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5a - parent-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L5b - current-directory segment
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L6 - wildcard
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L7 - stray colon
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.rejects issue #671 predicate L8 - empty selector value
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 selector predicate and fail-closed guard.returns false when segment classification raises an error
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 exempts a single-quoted message carrying angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies the single-quoted apostrophe idiom
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a command substitution inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a variable expansion inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a backtick substitution inside a double-quoted message
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies a pathless commit whose message carries angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 quote-aware angle brackets.issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
PASSED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
```
