# Skill and Module Literal Presence — [P5-T6] and [P5-T7]

Timestamp: 2026-08-28T12-46

## [P5-T6] — the hashtable-verdict literal in all six files

Command: `git grep -c -F 'the conflict key of the returned hashtable' -- .claude/skills/parallel-add/SKILL.md .claude/skills/parallel-plan/SKILL.md .claude/lib/blast-radius/BlastRadius.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`

EXIT_CODE: 0

### Verbatim Output

```
.claude/lib/blast-radius/BlastRadius.psm1:1
.claude/skills/parallel-add/SKILL.md:1
.claude/skills/parallel-plan/SKILL.md:1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1:1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md:1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md:1
```

Exactly six output rows, one per supplied path, each reporting a count of 1, which is at least 1. The
`-F` flag makes the match a fixed string, and `git grep` is line-oriented, so a count of 1 proves the
literal occupies a single line in each file and is not split across a wrap.

| # | Path | Count |
| --- | --- | --- |
| 1 | `.claude/lib/blast-radius/BlastRadius.psm1` | 1 |
| 2 | `.claude/skills/parallel-add/SKILL.md` | 1 |
| 3 | `.claude/skills/parallel-plan/SKILL.md` | 1 |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` | 1 |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` | 1 |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | 1 |

In `parallel-add/SKILL.md` and its bundled copy the occurrence sits inside step 3, the step that
instructs the agent to compute conflict edges over all items. In `parallel-plan/SKILL.md` and its
bundled copy it sits inside step 1 of the `### Seeding procedure` section. In both copies of
`BlastRadius.psm1` it sits inside the `.OUTPUTS` section of the comment-based help of
`Test-BlastRadiusConflict`.

## [P5-T7] — the ConflictResult-verdict literal in both plan-skill copies

Command: `git grep -c -F 'the conflict field of the returned ConflictResult' -- .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`

EXIT_CODE: 0

### Verbatim Output

```
.claude/skills/parallel-plan/SKILL.md:1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md:1
```

Exactly two output rows, each reporting a count of 1, which is at least 1. The occurrence sits inside
the `- **Contention.**` bullet of the landed-contract section, which documents the Python relation
signature and the reason vocabulary.

| # | Path | Count |
| --- | --- | --- |
| 1 | `.claude/skills/parallel-plan/SKILL.md` | 1 |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | 1 |

Output Summary: Both commands exited 0. The hashtable-verdict literal `the conflict key of the
returned hashtable` is present exactly once on a single line in each of the six supplied paths — the
two parallel-add skill copies, the two parallel-plan skill copies, and the two blast-radius module
copies. The ConflictResult-verdict literal `the conflict field of the returned ConflictResult` is
present exactly once on a single line in each of the two parallel-plan skill copies. [P5-T6]
discharges AC9 and the hashtable half of AC10; [P5-T7] discharges the ConflictResult half of AC10.
