# QA Gate — Skill Documentation Token Presence (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P6-T4]

Command: `grep -cF -- "ANCESTRY_ERROR" .claude/skills/cleanup-merged-worktrees/SKILL.md && grep -cF -- "BLOCKED-LOCKED" .claude/skills/cleanup-merged-worktrees/SKILL.md && grep -cF -- "NOT_ANCESTOR" .claude/skills/cleanup-merged-worktrees/SKILL.md`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P6-T4] literal is the same three-`grep` chain wrapped in:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && <the three-grep chain>'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard. The three-`grep` chain was run natively from the worktree root
   with the same flags, the same fixed-string patterns, the same target file, and the same
   `&&` joining.

## Printed Counts, in Command Order

| Token | Count |
|---|---|
| `ANCESTRY_ERROR` | 2 |
| `BLOCKED-LOCKED` | 1 |
| `NOT_ANCESTOR` | 1 |

`grep -c` exits 1 when a token has zero matches, so the `&&` chain reaches its third stage
and exits 0 only when all three tokens are present. The chain exited **0**, and each of the
three counts is **at least 1**. All three tokens were absent from this file before [P6-T1]
through [P6-T3], so this gate could fail and did not.

## Verbatim — the Report-Line Bullet Added by [P6-T1]

Quoted exactly as it appears in `.claude/skills/cleanup-merged-worktrees/SKILL.md`:

```
- `WORKTREE|<path>|DETACHED|<state>|<flags>` — a detached-HEAD worktree registration,
  classified on its own HEAD SHA. This five-field record replaces the four-field record
  above for a detached registration; it is not emitted in addition to it. `state` is one
  of `MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT | NOT_MERGED |
  HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT | ANCESTRY_ERROR`, where `ANCESTRY_ERROR` is
  the fail-closed verdict for a hard git failure at any rung of the classification. The
  fifth field carries the porcelain flag set unchanged, so the `locked` and `prunable`
  markers are preserved in the record.
```

It sits immediately after the pre-existing four-field worktree bullet in the
`## Report Line Contract` list.

## Verbatim — the Consolidation Sentence Added by [P6-T3]

Quoted exactly as it appears in `.claude/skills/cleanup-merged-worktrees/SKILL.md`, in
workflow step 6:

```
   A consolidation branch whose tip equals `main`, which is the state of
   `documentationandmemories` between its creation off `main` and its first commit, is
   reported `NOT_ANCESTOR` by a tip-equality pre-check that runs before any network fetch
   and is therefore not delete-eligible; the post-merge cleanup described above is
   unaffected, because a merged consolidation branch's tip differs from `main`, and an
   empty or unresolvable tip on either side is reported `ANCESTRY_ERROR` rather than
   treated as equality.
```

Output Summary: The three-`grep` chain exited **0**, printing the counts **2, 1, and 1** for
`ANCESTRY_ERROR`, `BLOCKED-LOCKED`, and `NOT_ANCESTOR` respectively — each at least 1. The
report-line bullet added by [P6-T1] and the consolidation sentence added by [P6-T3] are
quoted verbatim above, so the documented record shape and the documented consolidation
behavior are auditable without a wrap-fragile search. This gate checks the repository copy
of the skill file, which is the source of the [P6-T5] mirror; the mirror parity check is
recorded separately in the [P6-T6] artifact. This is the evidence for AC20.
