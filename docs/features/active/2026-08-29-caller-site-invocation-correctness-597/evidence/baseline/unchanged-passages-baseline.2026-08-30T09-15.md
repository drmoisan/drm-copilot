# Unchanged Passages Baseline (P0-T4)

Timestamp: 2026-08-30T09-15

Command: fixed-string (`-F`) searches restricted to individual files:
- `rg -F 'unconditionally truthy under PowerShell boolean coercion, so' .claude/lib/blast-radius/BlastRadius.psm1`
- `rg -F "The hashtable itself is always truthy, so a bare boolean test on the result treats every pair as" .claude/skills/parallel-plan/SKILL.md`
- `rg -F 'parallel_lane_assertion' .claude/skills/parallel-plan/SKILL.md`

EXIT_CODE: 0

Output Summary: Exactly one match found for each of the three tokens:
- `unconditionally truthy under PowerShell boolean coercion, so` in
  `.claude/lib/blast-radius/BlastRadius.psm1`: 1 match (line 436).
- `The hashtable itself is always truthy, so a bare boolean test on the result treats every pair as`
  in `.claude/skills/parallel-plan/SKILL.md`: 1 match (line 311; this passage is a single
  unwrapped line in the file, not wrapped as it appears in plan prose).
- `parallel_lane_assertion` in `.claude/skills/parallel-plan/SKILL.md`: 1 match (line 317).

These three passages are outside the scope of Phase 1 edits and are re-checked byte-unchanged in
Phase 2 tasks P2-T7, P2-T8, and P2-T9 against this baseline.
