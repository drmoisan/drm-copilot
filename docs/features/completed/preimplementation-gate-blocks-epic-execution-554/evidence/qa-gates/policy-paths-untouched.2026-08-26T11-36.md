# P5-T2 — No Policy Path Appears in the Branch Diff

Timestamp: 2026-08-26T11-36

Command:

```powershell
git diff --name-only origin/main...HEAD | Select-String -Pattern '^\.claude/rules/|^\.claude/skills/|^\.github/'
```

EXIT_CODE: 0

Output Summary:

MATCH_COUNT: 0

The pattern matches any diff path beginning with `.claude/rules/`, `.claude/skills/`, or `.github/`.
Zero paths in the branch diff match. The `Select-String` invocation produced no output rows.

Total paths in the branch diff against `origin/main...HEAD`: 45. All 45 are outside the three
prohibited prefixes.

### Why this matters

Three separate authorities forbid these writes and all three are satisfied:

- `CLAUDE.md` names `.github/copilot-instructions.md` and `.github/instructions/**` as canonical
  policy sources that must not be modified.
- `spec.md` statement (b) under `## DECLARED BLAST RADIUS`: "No file under `.claude/rules/`,
  `.claude/skills/`, `.github/instructions/`, and no `.github/copilot-instructions.md`, is written
  by this feature."
- `spec.md` `## Scope & Non-Goals` prohibits modifying any `.claude/skills/**` or `.claude/rules/**`
  file, "including the epic kickoff contract gap identified in D3."

The D3 epic kickoff contract gap is therefore recorded as an evidence-only follow-up (P5-T7) rather
than closed by a skill edit, which is what keeps this match count at zero.

### Verdict

PASS. The recorded match count is the integer 0.
