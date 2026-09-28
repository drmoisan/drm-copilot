# Final QC: Scoped Coverage Run (Issue #710)

Timestamp: 2026-09-27T02-40
Command: sh <SCRATCHPAD>/p5-cov.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/p5-cov.ps1; R-COV of plan section 5 over the 10 HRS files plus tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1, CodeCoverage.Path = the two canonical helper copies, OutputPath <SCRATCHPAD>/p5-cov.coverage.xml)
EXIT_CODE: 0
Output Summary: Pass 2. PassedCount 483, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; 38 PASSED lines in the ChainEscape suite. Line coverage .claude/hooks helpers 97.08% (166 covered, 5 missed); .codex/hooks helpers 97.08% (166 covered, 5 missed). Four CHANGED_LINE entries (lines 76 and 78 in each canonical copy), all executed.

Pass: 2

FAILED lines: none. B_SCOPED is empty, and no failure belongs to the ChainEscape, Parity, or legacy-codex suites.

ChainEscape PASSED lines (lines containing `preimplementation gate helpers chain escapes`): 38.

## Runner Output

```text
PassedCount: 483
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
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows git add of a production path while a merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_feature_folder is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when epic_manifest_path is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies git add of a production path when features is missing and names it
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope resolves the -C selector worktree for the command leg
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope allows an Edit of a production path while a merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope denies a Write of a production path when no merge is in progress
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).epic scope ignores a text branch label and decides the -C selector worktree by its own HEAD
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic scope (issue #663).issue #663 relocated read seams and the no-leg guard of the epic-scope sibling.issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a quoted mention of the staging invocation inside an echo argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc body that quotes the staging invocation in prose
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows prose containing the English word black
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git commit carrying a git-dir global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a work-tree global option
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies an unmodeled dash-leading token between git and its subcommand
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the subshell spelling of a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the command-substitution spelling of a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).the non-classifying stop case.does not classify git log --grep add as a staging command
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.emits the PreToolUse deny schema (hookEventName + permissionDecision=deny) after serialize-then-parse
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows feature documentation writes
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows evidence writes
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows implementation writes when checkpoint readiness is present, regardless of issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation command payloads before readiness (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks staging and commit command payloads before readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks formatter and test command payloads before readiness
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.blocks implementation delegation payloads before readiness (generalized message)
PASSED: enforce-orchestration-preimplementation-gate.ps1.implementation writes before orchestration readiness.allows implementation operations for any ready workflow state regardless of issue number
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies an empty payload as an envelope anomaly (fail closed)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows a non-implementation file write (documentation path) without a checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.blocks an implementation write when the resolved checkpoint is malformed JSON
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.allows an implementation write when readiness is supplied via path_selected fallback
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.blocks an implementation write when the checkpoint omits the feature folder
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.Test-OrchestrationReady returns false for a null payload
PASSED: enforce-orchestration-preimplementation-gate.ps1.tool input parsing and checkpoint resolution.Test-ImplementationDelegation returns false for a null tool input
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.allows a Write to every exempt checkpoint literal with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.allows the backslash spelling of every exempt checkpoint literal
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.denies a non-checkpoint .json under artifacts/orchestration/ (literal set, not directory prefix)
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 checkpoint write exemptions.denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies both markers when subagent_type is not orchestrator
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation whose prompt matches the implementation regex without the markers
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation carrying only one preparation marker
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies an orchestrator delegation whose first marker is missing its trailing period
PASSED: enforce-orchestration-preimplementation-gate.ps1.issue #535 preparation-mode delegation exemption.denies markers placed in a non-prompt field while prompt matches the implementation regex
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and emits a deny when every transport is empty
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and emits an allow decision JSON for a documentation write
PASSED: enforce-orchestration-preimplementation-gate.ps1.Entrypoint (exit code seam, no child process).returns exit code 0 and never 1 for unparseable JSON
PASSED: enforce-orchestration-preimplementation-gate.ps1.Claude runtime registration.registers the preimplementation gate in active and tracked Claude settings
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a quoted mention of the staging invocation inside an echo argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc body that quotes the staging invocation in prose
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a heredoc whose JSON body names a governed tool as a receipt value
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows prose containing the English word black
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).over-match allow cases - a mention is not an invocation.allows a cross-segment line whose npm segment and lint mention are in different segments
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a directory global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git commit carrying a git-dir global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies a relocating git add carrying a work-tree global option
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies an unmodeled dash-leading token between git and its subcommand
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the subshell spelling of a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).under-match deny cases - the latent bypass.denies the command-substitution spelling of a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).the non-classifying stop case.does not classify git log --grep add as a staging command
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 1: denies a staging command relocated through xargs
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 2: denies a staging command nested inside a bash -c argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 3: denies a staging command nested inside an sh -c argument
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 4: denies a staging command behind the env transparent wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 6: denies a heredoc body piped into bash
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test.wrapper deny pin 7: denies a live substitution inside a double-quoted span
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still classifies an apply_patch add of a production script
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still declines to classify an apply_patch add of feature documentation
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still classifies an apply_patch rename onto a production script
PASSED: Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545).apply_patch marker legs are unaffected (Codex-only).still declines to classify an apply_patch update of feature documentation
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the preparation mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the epic mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the parallel mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the preparation mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.resolves the single-feature mode for its marker prompt
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the preparation mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the epic mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the parallel mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.maps the single-feature mode to its canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.returns an empty checkpoint path for a mode name that is not in the table
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.rejects the declared checkpoint path for epic mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.accepts the declared checkpoint path for parallel mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).mode resolution parity.rejects the declared checkpoint path for parallel mode
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns nothing for a prompt carrying no feature-folder token
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the parent basename for a token ending in a Markdown file
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the basename for a bare directory token
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the basename for a token followed by sentence punctuation
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns nothing for a prompt carrying no issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the numeric string for a keyed issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).target folder resolution parity.returns the numeric string for a bare-hash issue number
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the mode deny-reason builder.builds an epic deny reason naming the epic checkpoint and the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the mode deny-reason builder.builds a parallel deny reason naming the parallel checkpoint and the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names route_id as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names epic_feature_folder as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names epic_manifest_path as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names integration_branch as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names features as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names target-record as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.names merge_status as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.reports ready for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.denies the terminal-merged worktree_removed status for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.allows the failure status blocked_conflict_loop_limit for the epic readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).epic readiness predicate parity.returns false from the wrapper for a null checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names route_id as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names parallel_slug as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names parallel_manifest_path as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names items as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names target-record as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.names merge_status as the failed conjunct
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.reports ready for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.denies the terminal-merged worktree_removed status for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.allows the blocked status blocked_drift, adding no enum member for the parallel readiness wrapper
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).parallel readiness predicate parity.returns false from the wrapper for a null checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies atomic-executor as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies powershell-typed-engineer as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies task-researcher as implementation: False
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies orchestrator as implementation: False
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).classifier parity through the mapped flat tool_input the Codex seam consumes.classifies orchestrator as implementation: True
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the preparation-mode delegation predicate on the Codex surface.returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the preparation-mode delegation predicate on the Codex surface.returns true for an orchestrator carrying both preparation markers on the Codex surface
PASSED: Codex enforce-orchestration-preimplementation-gate mode resolution (issue #554).the recorded Agent-transport gap (decision D5, deliverable ii).registers no PreToolUse matcher admitting an Agent or Task tool name
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.allows an epic-mode delegation against an injected ready epic checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation and names integration_branch as the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation whose injected checkpoint text is malformed JSON
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation whose injected checkpoint text is empty
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the epic leg of the decision router.denies an epic-mode delegation that declares a non-canonical checkpoint path
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.allows a parallel-mode delegation against an injected ready parallel checkpoint
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.denies a parallel-mode delegation and names parallel_slug as the failed predicate
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the parallel leg of the decision router.denies a parallel-mode delegation whose injected checkpoint declares the epic route
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the per-mode read seams supply the checkpoint when no text is injected.denies an epic-mode delegation against the canonical epic checkpoint read seam
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the per-mode read seams supply the checkpoint when no text is injected.denies a parallel-mode delegation against the canonical parallel checkpoint read seam
PASSED: Codex enforce-orchestration-preimplementation-gate mode routing (issue #545).the mode legs do not capture a non-implementation delegation.allows a research delegation that carries the epic marker
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps every surface copy of the helpers module under the 500-line cap
PASSED: Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
PASSED: Legacy Codex hooks use native lifecycle contracts.reads stdin in every hook entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: Legacy Codex hooks use native lifecycle contracts.lists every shared hook module in the core pack manifest
PASSED: Legacy Codex hooks use native lifecycle contracts.ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: Legacy Codex hooks use native lifecycle contracts.emits the current PreToolUse deny envelope for shell and patch violations
PASSED: Legacy Codex hooks use native lifecycle contracts.fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.denies preimplementation and batch-budget violations through their pure decisions
PASSED: Legacy Codex hooks use native lifecycle contracts.allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: Legacy Codex hooks use native lifecycle contracts.reconstructs update patches in memory and includes move destinations
PASSED: Legacy Codex hooks use native lifecycle contracts.uses one SubagentStop continuation and stops repeated continuation loops
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a feature documentation path as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies the orchestrator checkpoint as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a production script as implementation path True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a plain text file as implementation path False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an empty command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch add of documentation as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an apply_patch rename onto a script as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a git commit as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies a pytest run as implementation command True
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).classifies an unrelated command as implementation command False
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null tool_input as no implementation delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).detects an implementation delegation inside a serialized tool_input
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats an unrelated serialized tool_input as no delegation
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a null checkpoint payload as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a checkpoint missing lifecycle readiness as not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).treats a complete checkpoint as ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns empty checkpoint content when the checkpoint file is absent
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).returns the checkpoint file content when the checkpoint file is present
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows when no mapped tool_input is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).throws a hook-named error for malformed mapped tool_input JSON
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a documentation file path without consulting the checkpoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation command when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an implementation delegation when the checkpoint is not ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows an implementation path when the checkpoint is ready
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).reads the checkpoint from disk when no checkpoint text is supplied
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies an apply_patch implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).denies a mapped Edit implementation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).allows a mapped Write of feature documentation through its own entrypoint
PASSED: Legacy Codex hooks use native lifecycle contracts.enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1).fails closed with exit 2 when its entrypoint receives empty stdin
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).exempts a commit whose message contains an escaped semicolon
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).exempts a commit whose message contains an escaped semicolon
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a chained command after an escaped backslash
LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=166 missed=5 percent=97.08
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=166 missed=5 percent=97.08
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:76 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:78 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:76 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:78 executed
```
