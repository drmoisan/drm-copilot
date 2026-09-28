# Phase 0 — Revision Anchors (remediation cycle 1)

Timestamp: 2026-08-27T23-50
Cycle Timestamp: 2026-08-27T22-47
Task: [P0-T3]
Command: `git rev-parse HEAD` and `git merge-base HEAD 1e991b86d78e4f979922b79268f19ca0e5ab19e3`
EXIT_CODE: 0

## Anchors

| Anchor | Value |
| --- | --- |
| Branch | `bug/preimplementation-gate-blocks-epic-execution-554-r3` |
| Branch head (full 40-character SHA) | `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a` |
| Merge base against `origin/main` | `1e991b86d78e4f979922b79268f19ca0e5ab19e3` |
| Working tree at capture | clean (`git status --porcelain` empty apart from the two Phase 0 evidence artifacts written by [P0-T1] and [P0-T2], which are untracked) |

## Merge-base comparability

The merge base resolves to `1e991b86d78e4f979922b79268f19ca0e5ab19e3`, which is the same merge base
recorded by the pre-remediation coverage-delta artifact
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/coverage-delta.2026-08-27T22-36.md`
and by `policy-audit.2026-08-27T22-47.md` (`Base: origin/main at 1e991b86`). The changed-line sets
computed from this base are therefore directly comparable with the pre-remediation figures, and the
post-remediation changed-line coverage reported at [P3-T9] is measured against the identical
denominator.

The branch head differs from the `f24bbc7f` recorded in the three cycle-1 audit inputs because the
audit artifacts themselves were committed after the audit ran. No production file changed between
`f24bbc7f` and `34c04b4d`; that invariant is re-proved by hash at [P3-T13].

Output Summary: Branch head `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`; merge base
`1e991b86d78e4f979922b79268f19ca0e5ab19e3`, identical to the base used by the pre-remediation
coverage-delta artifact. Both commands exited 0.
