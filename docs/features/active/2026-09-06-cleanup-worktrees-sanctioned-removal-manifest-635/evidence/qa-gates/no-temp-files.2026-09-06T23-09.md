# No Temporary Files In Any Test Added By This Work

Timestamp: 2026-09-08T04-21

Task: [P7-T6]

Command:
`grep -n -F -e "New-TemporaryFile" -e "GetTempPath" -e "TestDrive" -e "Out-File" tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`

EXIT_CODE: 1

ExpectedExitCode: 1

## Why the expectation is 1

The success case of this search is zero matches, and `grep` reports zero matches as exit code 1.
`scripts/dev_tools/pr_context/verification_evidence.py:25` collects `evidence/qa-gates/**/*.md` into
the PR body and defaults a missing expectation to `0`, so without the `ExpectedExitCode: 1` row this
passing gate would render as a failed one. An observed exit code of **0** would mean the search
matched and this gate fails; an observed exit code of **2** would mean `grep` could not read one of
the named files and this gate fails. The observed value is 1.

## Route substitution

The task previously named a `pwsh`-hosted `Select-String` form. The runtime worktree-isolation guard
refuses every `pwsh` invocation issued here and no process starts, so that form produces no exit code
at all. `grep -n -F` reads the same working-tree files, matches the same four literals, and reports
the file, the 1-based line number, and the matching line, so the substitution changes the tool and
not the observation. The search reads the **working tree** rather than the index: two of the four
files are created by this plan and are never staged, and `git grep` searches tracked files only, so a
`git grep` against them would print nothing whatever they contained.

## Tokens searched

| # | Literal | What it would indicate |
| --- | --- | --- |
| 1 | `New-TemporaryFile` | Creation of a temporary file |
| 2 | `GetTempPath` | Resolution of the host temporary directory |
| 3 | `TestDrive` | Pester's temporary-filesystem facility |
| 4 | `Out-File` | A write to a file from a test |

## Files searched

| # | Path | Origin |
| --- | --- | --- |
| 1 | `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | Created by this work (Phase 1) |
| 2 | `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | Created by this work (Phase 3) |
| 3 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | Changed by this work |
| 4 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | Changed by this work |

The search is scoped to these four files rather than to the whole `tests/scripts/claude-hooks`
directory because `tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1` carries
`New-TemporaryFile` and `GetTempPath` as fixture strings; a directory-scoped search would always
print a line for that file and the absence assertion could never hold. No P3-T25 split contingency
suite was created, so no path is added to this list.

## Result

The command printed **no result row**. Exit code 1.

```text
<no output>
```

## Seam-exclusivity corroboration

The absence of a temporary-file token is one half of the criterion; the other half is that the
manifest read boundary and the clock boundary are exercised exclusively through the module's
injectable seams. Counted in the same run against the two suites this work created:

| Observation | `CleanupWorktreeManifest.Tests.ps1` | `CleanupWorktreeManifestGateMatrix.Tests.ps1` |
| --- | --- | --- |
| Lines naming `Get-CleanupWorktreeManifestContent` | 2 | 12 |
| Lines naming `Get-CleanupWorktreeManifestUtcNow` | 2 | 8 |
| Lines carrying `ModuleName 'CleanupWorktreeManifest'` | 4 | 21 |
| Lines naming `Get-Content`, `Set-Content`, `Add-Content`, `New-Item`, or `Remove-Item` | 0 | 0 |

Every reference to either boundary is a `Mock ... -ModuleName 'CleanupWorktreeManifest'`
registration, and neither suite names any filesystem cmdlet that could create, write, or read a file
outside those seams. That combination is what makes the exclusivity claim observable rather than
asserted: a test that reached the real filesystem would have to name one of those cmdlets or one of
the four searched tokens, and neither suite names any of them.

Each subsidiary corroboration count above was produced by a `grep -c` invocation whose own exit
status is transcribed in this wording rather than as its own `EXIT_CODE:` row, because
`scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last row whose text before
the first colon is exactly `EXIT_CODE` as the artifact's rendered result. This file carries exactly
one such line, the `EXIT_CODE: 1` row above, and it is the outcome of this task's verification as a
whole.

Output Summary: The four-token fixed-string search across the four test files this work created or
changed printed no result row and exited 1, which is the declared success case. No test added by
this work creates, writes, or reads a temporary file. The manifest read boundary and the clock
boundary are exercised exclusively through `Get-CleanupWorktreeManifestContent` and
`Get-CleanupWorktreeManifestUtcNow`, mocked with `-ModuleName 'CleanupWorktreeManifest'`, and
neither new suite names any filesystem cmdlet. Satisfies AC-28.
