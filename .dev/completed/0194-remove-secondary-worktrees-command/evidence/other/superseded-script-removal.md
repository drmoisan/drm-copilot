# Superseded Draft Script Removal (Issue #194)

Timestamp: 2026-06-17T16-55

Removed path: scripts/dev-tools/remove-worktrees.ps1

Rationale:
The TypeScript "Remove Secondary Worktrees" command replaces the untracked, untested,
Windows-centric draft PowerShell script. The draft was not tracked by git and relied on
an OS-specific file-lock probe that does not generalize. Deleting it removes the superseded
artifact so it is not mistaken for the supported implementation.

Verification:
- `ls scripts/dev-tools/remove-worktrees.ps1` after removal reports "No such file or directory".
