# Phase 2 Suite Run Record — WorktreeTargetResolution.Tests.ps1

Timestamp: 2026-09-17T08:24:29-04:00
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru; $r.PassedCount; $r.FailedCount; $r.SkippedCount; $r.Passed.ExpandedPath
EXIT_CODE: 0
Output Summary: PassedCount=51, FailedCount=0, SkippedCount=0. The passed set contains 1 name with "preserves the absolute prefix" ([P2-T5]), 6 names beginning "ambiguous sub-case" ([P2-T7]), 12 names beginning "required matrix row" ([P2-T6]; the four own-target rows are the cwd-equals-target regression guards), and 4 names with "join composes an absolute path" ([P2-T4]).

## Counts

- PassedCount: 51
- FailedCount: 0
- SkippedCount: 0

## Phrase counts in the passed set (test name = last dotted segment)

| Phrase | Position | Count |
| --- | --- | --- |
| `preserves the absolute prefix` | contains | 1 |
| `ambiguous sub-case` | begins with | 6 |
| `required matrix row` | begins with | 12 |
| `join composes an absolute path` | contains | 4 |

Regression guard (cwd equals target): the rows `required matrix row: cwd session, relative path, own target resolves to SessionRoot`, `... cwd session, absolute path, own target ...`, `... cwd item, relative path, own target ...`, and `... cwd item, absolute path, own target ...` assert `Status = SessionRoot`, `WorktreeRoot` equal to `SessionRoot`, `ReasonCode` null, and `Candidates` holding exactly that root.

## Passed tests (full names, verbatim)

```text
WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status SessionRoot
WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status OtherWorktree
WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status NoTarget
WorktreeTargetResolution.result factory and field invariants.enforces the field invariants for Status Ambiguous
WorktreeTargetResolution.result factory and field invariants.refuses a resolved Status without a WorktreeRoot
WorktreeTargetResolution.result factory and field invariants.refuses an empty Detail or SessionRoot and an unknown Status
WorktreeTargetResolution.result factory and field invariants.returns an object carrying exactly the eight contract fields from Resolve-WorktreeCallTarget
WorktreeTargetResolution.result factory and field invariants.defaults SessionRoot to the worktree containing the current location
WorktreeTargetResolution.result factory and field invariants.falls back to the normalised current location when no worktree contains it
WorktreeTargetResolution.signal extraction.preserves the absolute prefix of a Windows-style feature-folder path
WorktreeTargetResolution.signal extraction.returns the bare token for a repo-relative path
WorktreeTargetResolution.signal extraction.returns the bare token for a quoted path ending a sentence
WorktreeTargetResolution.signal extraction.reads a branch from a --head option
WorktreeTargetResolution.signal extraction.reads a branch from a --branch= option
WorktreeTargetResolution.signal extraction.reads a branch from a branch: label
WorktreeTargetResolution.signal extraction.reads an absolute file path from a drive-rooted path
WorktreeTargetResolution.signal extraction.reads an absolute file path from a slash-rooted path
WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFeatureFolderSignal for an embedded non-token
WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionBranchSignal for prose naming no branch
WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFilePathSignal for relative paths and a URL
WorktreeTargetResolution.signal extraction.returns null from Find-WorktreeResolutionFeatureFolderSignal for a null payload
WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, own target resolves to SessionRoot
WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, own target resolves to SessionRoot
WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, sibling target resolves to OtherWorktree
WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, sibling target resolves to OtherWorktree
WorktreeTargetResolution.required matrix.required matrix row: cwd session, relative path, absent target resolves to Ambiguous
WorktreeTargetResolution.required matrix.required matrix row: cwd session, absolute path, absent target resolves to Ambiguous
WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, own target resolves to SessionRoot
WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, own target resolves to SessionRoot
WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, sibling target resolves to OtherWorktree
WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, sibling target resolves to OtherWorktree
WorktreeTargetResolution.required matrix.required matrix row: cwd item, relative path, absent target resolves to Ambiguous
WorktreeTargetResolution.required matrix.required matrix row: cwd item, absolute path, absent target resolves to Ambiguous
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a relative feature-folder token present in two worktrees
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a relative feature-folder token present in no worktree
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: an absolute path whose upward walk finds no .git entry
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a branch matching no worktree
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: a branch matching more than one worktree
WorktreeTargetResolution.ambiguity, no target, and Ruling B.ambiguous sub-case: two signals resolving to different worktree roots
WorktreeTargetResolution.ambiguity, no target, and Ruling B.returns NoTarget with empty signal fields for a payload naming nothing, without reading the filesystem
WorktreeTargetResolution.ambiguity, no target, and Ruling B.distinguishes NoTarget from Ambiguous by Status and ReasonCode alone
WorktreeTargetResolution.ambiguity, no target, and Ruling B.deduplicates two agreeing signals and reports the higher-precedence kind FeatureFolderPath
WorktreeTargetResolution.ambiguity, no target, and Ruling B.deduplicates two agreeing signals and reports the higher-precedence kind FilePath
WorktreeTargetResolution.ambiguity, no target, and Ruling B.never lets precedence suppress a disagreement between a relative file path and a branch
WorktreeTargetResolution.ambiguity, no target, and Ruling B.concatenates into a gate deny reason carrying both tokens
WorktreeTargetResolution.ambiguity, no target, and Ruling B.produces each of the four Status values from a documented input
WorktreeTargetResolution.path composition.join composes an absolute path from a backslash-separated root
WorktreeTargetResolution.path composition.join composes an absolute path from a root with a trailing slash
WorktreeTargetResolution.path composition.join composes an absolute path from a remainder deeper than four segments
WorktreeTargetResolution.path composition.join composes an absolute path from a blank remainder
WorktreeTargetResolution.path composition.refuses a relative worktree root
```
