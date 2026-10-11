# Fail-before run over NEW-732, D2A, and TRAILER (issue #732)

Timestamp: 2026-10-09T03-50
Task: [P1-T10]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 7 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 7
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
PassedCount: 382
FailedCount: 58
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 brace-expansion shape
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 escaped dot-segment shape
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped semicolon in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped ampersand in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped pipe in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a mixed dot-backslash segment in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a backslash-spelled operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a comma brace in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a range brace in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a brace in an unquoted message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted comma in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted at-sign name in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted opening parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted closing parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a star glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a question-mark glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a bracket glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a tilde in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a percent sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a caret in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an exclamation mark in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an equals sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a plus sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a non-ASCII division-slash look-alike in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 brace-expansion shape
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 escaped dot-segment shape
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped semicolon in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped ampersand in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped pipe in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a mixed dot-backslash segment in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a backslash-spelled operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a comma brace in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a range brace in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a brace in an unquoted message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted comma in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted at-sign name in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted opening parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted closing parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a star glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a question-mark glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a bracket glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a tilde in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a percent sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a caret in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an exclamation mark in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an equals sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a plus sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a non-ASCII division-slash look-alike in an operand
FAILED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 brace-expansion shape without an authorizing checkpoint
FAILED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
FAILED: Codex preimplementation gate exempt-operand bypass (issue #732).denies the issue 732 brace-expansion shape without an authorizing checkpoint
FAILED: Codex preimplementation gate exempt-operand bypass (issue #732).denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
FAILED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
FAILED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
FAILED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.denies a backslash-spelled operand (D4 row 18 reversed by issues #732 and #735)
FAILED: Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #732 LACS allow 3 reversed - backslash-spelled absolute selector
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a commit whose message contains an escaped semicolon (issue #732 D2a)
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an at sign
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an at sign
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging an epic document under the epics tree
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows staging a parallel manifest and its kickoff in one two-operand invocation
PASSED: enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #539 orchestration-tree staging exemption allow cases.allows a quoted operand under the active feature tree
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
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate attribution trailers (claude).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (claude).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (claude).admits two trailer options
PASSED: preimplementation gate attribution trailers (claude).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (claude).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (claude).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (claude).admits an empty single-quoted trailer value
PASSED: preimplementation gate attribution trailers (claude).admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (claude).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (claude).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (claude).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (claude).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (claude).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (claude).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (claude).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (claude).denies a message-file option
PASSED: preimplementation gate attribution trailers (claude).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (claude).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (claude).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (claude).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (claude).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies a typographic single-quoted command substitution
PASSED: preimplementation gate attribution trailers (claude).denies a typographic double-quoted command substitution
PASSED: preimplementation gate attribution trailers (claude).denies a typographic single quote around a non-exempt pathspec
PASSED: preimplementation gate attribution trailers (claude).denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: preimplementation gate attribution trailers (claude).denies a single low-9 quotation mark (U+201A)
PASSED: preimplementation gate attribution trailers (claude).denies a single high-reversed-9 quotation mark (U+201B)
PASSED: preimplementation gate attribution trailers (claude).denies a double low-9 quotation mark (U+201E)
PASSED: preimplementation gate attribution trailers (codex).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (codex).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (codex).admits two trailer options
PASSED: preimplementation gate attribution trailers (codex).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (codex).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (codex).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (codex).admits an empty single-quoted trailer value
PASSED: preimplementation gate attribution trailers (codex).admits a trailer option taking the double-dash separator as its value (CR-4)
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (codex).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (codex).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (codex).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (codex).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (codex).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (codex).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (codex).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (codex).denies a message-file option
PASSED: preimplementation gate attribution trailers (codex).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (codex).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (codex).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (codex).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (codex).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies a typographic single-quoted command substitution
PASSED: preimplementation gate attribution trailers (codex).denies a typographic double-quoted command substitution
PASSED: preimplementation gate attribution trailers (codex).denies a typographic single quote around a non-exempt pathspec
PASSED: preimplementation gate attribution trailers (codex).denies a trailer option taking the double-dash separator before a non-exempt operand (CR-4)
PASSED: preimplementation gate attribution trailers (codex).denies a single low-9 quotation mark (U+201A)
PASSED: preimplementation gate attribution trailers (codex).denies a single high-reversed-9 quotation mark (U+201B)
PASSED: preimplementation gate attribution trailers (codex).denies a double low-9 quotation mark (U+201E)
```

Output Summary: EXIT_CODE 1 as expected (fail-before). PassedCount 382, FailedCount 58, FailedBlocksCount 0, FailedContainersCount 0. FAILED set equals the planned set: 48 section-5.1 fails rows (24 per surface), 4 section-5.2 rows, 2 D4 row 18 rows, 2 LACS allow 3 reversed rows, 2 ChainEscape rows. All 10 section-5.4 TRAILER tests are PASSED.
