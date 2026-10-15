# P2-T8 Documentation contract (AC-10)

Timestamp: 2026-10-02T04-07
Command: `grep -c -F "semicolon" .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`; `grep -c -F "default pair" .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`; `grep -c -F "always added" .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`; the same three greps against `.claude/skills/cleanup-merged-worktrees/SKILL.md`
EXIT_CODE: 0
Output Summary:
- Wrapper: GREP value=1 exit=0 (semicolon); GREP value=1 exit=0 (default pair); GREP value=1 exit=0 (always added).
- SKILL.md: GREP value=1 exit=0 (semicolon); GREP value=2 exit=0 (default pair); GREP value=1 exit=0 (always added).
- All six print 1 or more (planning-time value 0 for all six). PASS.

Final wrapper entry (`.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` lines 142-152), verbatim:

```text
  CLEANUP_WT_ORPHAN_ROOTS      Worktree-tracking roots scanned for ORPHAN_DIR and
                               WARN|registration-lost. Entries are separated by a
                               semicolon, a newline, or a colon; a colon that follows
                               a single drive letter and precedes / or \ is part of
                               the path (C:/x). Empty and relative entries are
                               dropped. When set, it replaces the default pair
                               <main>/.claude/worktrees and <main>-wt. The parent of
                               every non-main registered worktree is always added,
                               except a parent that is the main worktree or its
                               ancestor, or is equal to or inside a registered
                               worktree.
```

Final SKILL.md bullet (`.claude/skills/cleanup-merged-worktrees/SKILL.md` lines 129-141), verbatim:

```text
- `ORPHAN_DIR|<path>|<size>` — a directory under a worktree-tracking root that carries
  no `.git` pointer file and no `git worktree list` entry. `<size>` is best-effort and
  may be the literal `unknown`. The scanned roots are the default pair
  `<main>/.claude/worktrees` and `<main>-wt`, or the `CLEANUP_WT_ORPHAN_ROOTS` entries
  when that variable is set (the override replaces the default pair), plus the parent
  directory of every non-main registered worktree, which is always added. A derived
  parent is skipped when it is the main worktree or one of its ancestors, or is equal to
  or inside a registered worktree. `CLEANUP_WT_ORPHAN_ROOTS` entries are separated by a
  semicolon, a newline, or a colon; a colon that follows a single drive letter and
  precedes `/` or `\` is part of the path, and empty or relative entries are dropped.
  The record is advisory: it reports the directory, and nothing in apply mode acts on
  it. For the disposition, see the Dirty Worktree Triage Procedure's step 7, which
  governs how an orphaned directory is handled.
```

Contract confirmation:
- Separator contract (semicolon, newline, colon; drive-letter colon kept; empty and relative entries dropped): stated in both.
- Override replaces the default pair: wrapper "When set, it replaces the default pair"; SKILL.md "the override replaces the default pair". Stated in both.
- Derived roots always added, with exclusions (main worktree, its ancestors, equal to or inside a registered worktree): stated in both.
- Both texts match D7 verbatim.
