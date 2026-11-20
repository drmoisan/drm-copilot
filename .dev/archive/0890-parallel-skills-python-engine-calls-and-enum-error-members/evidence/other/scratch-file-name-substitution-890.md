# Scratch File Name Substitution (Issue #890)

Timestamp: 2026-10-12T20-10
Source: operator constraint 2 in the executor delegation prompt (every scratch file name must begin with `issue-890-`).

| Plan name | Name used |
| --- | --- |
| `artifacts/scratch/890/commit-msg-phase0-890.txt` | `artifacts/scratch/890/issue-890-commit-msg-phase0.txt` |
| `artifacts/scratch/890/commit-msg-phase1-890.txt` | `artifacts/scratch/890/issue-890-commit-msg-phase1.txt` |
| `artifacts/scratch/890/commit-msg-phase2-890.txt` | `artifacts/scratch/890/issue-890-commit-msg-phase2.txt` |
| `artifacts/scratch/890/commit-msg-handoff-890.txt` | `artifacts/scratch/890/issue-890-commit-msg-handoff.txt` |

Scratch files are untracked and never staged. This note is committed with the Phase 0 commit as one additional explicit path, because the P0-T13 acceptance requires `git status --porcelain` over the feature folder to print nothing after the commit.
