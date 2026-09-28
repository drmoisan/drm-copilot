# Remediation Cycle 1 Fail-Before RB1 ([P1-T4], expect-fail)

Timestamp: 2026-09-25T21-22
Command: sh <SCRATCHPAD>/rem1/runout.sh ce-run  (R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1, before any production change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PassedCount 226, FailedCount 12, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly the six expanded "issue #663 remediation denies <Label>" names, each twice (once per suite); no remediation name appears on a PASSED line. RSCOPED_EXIT_CODE 1 and PROCESS_EXIT_CODE 1.

## Runner Output

```
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1

Starting discovery in 2 files.
Discovery found 238 tests in 231ms.
Running tests.
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
 29ms (28ms|1ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
 8ms (8ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
 7ms (6ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
 6ms (6ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
 6ms (5ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
 6ms (5ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:483
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:482
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
 10ms (10ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
 8ms (7ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
 7ms (7ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
 6ms (5ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
 9ms (8ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
[-] Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #663 remediation escaped quotes (CR-1, CR-3).issue #663 remediation denies a backslash inside a double-quoted message
 6ms (6ms|0ms)
 at Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown', <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:490
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:489
 Expected strings to be the same, because an unmodelled backslash escape makes the quoted-span boundaries unknown, but they were different.
 Expected length: 4
 Actual length:   5
 Strings differ at index 0.
 Expected: 'deny'
 But was:  'allow'
            ^
Tests completed in 2.74s
Tests Passed: 226,
Failed: 12,
Skipped: 0,
Inconclusive: 0,

NotRun: 0
PassedCount: 226
FailedCount: 12
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
FAILED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
FAILED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
FAILED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
FAILED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
FAILED: issue #663 remediation denies a backslash inside a double-quoted message
FAILED: issue #663 remediation denies an escaped double quote hiding an output redirection (CR-1)
FAILED: issue #663 remediation denies an escaped double quote hiding an output redirection after a semicolon (CR-1)
FAILED: issue #663 remediation denies an escaped double quote hiding chain operators (CR-3)
FAILED: issue #663 remediation denies an unquoted escaped double quote opening a scan-only span
FAILED: issue #663 remediation denies an unquoted escaped single quote opening a scan-only span
FAILED: issue #663 remediation denies a backslash inside a double-quoted message
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
RSCOPED_EXIT_CODE: 1
PROCESS_EXIT_CODE: 1
```
