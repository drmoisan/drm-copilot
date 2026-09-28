# Relation Audit After the Edits (Remediation Cycle 1, P1-T9)

Timestamp: 2026-09-27T19-57
Command: sh SCRATCH/run-ps.sh SCRATCH/relation-audit.ps1 -Root "."
EXIT_CODE: 0

## Output (verbatim)

```text
CALL .claude/lib/blast-radius/BlastRadiusScheduling.psm1:469 Get-BlastRadiusPairDecision HasRelation=True It=
CALL tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1:110 Get-BlastRadiusConflictEdge HasRelation=True It="matches detection at tolerance 0 for $($case['Run'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1:130 Get-BlastRadiusConflictEdge HasRelation=True It="reproduces the pinned AFTER edges and tolerated overlaps for $($case['Run'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:160 Get-BlastRadiusPairDecision HasRelation=True It='keeps a shared-surface overlap hard at every tolerance'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:169 Get-BlastRadiusPairDecision HasRelation=True It='treats a contract dependency as hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:232 Get-BlastRadiusPairDecision HasRelation=True It='applies the integer inequality strictly at its boundary'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:233 Get-BlastRadiusPairDecision HasRelation=True It='applies the integer inequality strictly at its boundary'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:243 Get-BlastRadiusPairDecision HasRelation=True It='records the first canonical reason kind'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:244 Get-BlastRadiusPairDecision HasRelation=True It='records the first canonical reason kind'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:280 Get-BlastRadiusConflictEdge HasRelation=True It="reproduces the expected decisions for $($case['FixtureName'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:316 Get-BlastRadiusConflictEdge HasRelation=True It="matches detection at tolerance 0 for $($case['FixtureName'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:334 Get-BlastRadiusConflictEdge HasRelation=True It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:337 Get-BlastRadiusConflictEdge HasRelation=True It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:338 Get-BlastRadiusConflictEdge HasRelation=True It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:348 Get-BlastRadiusPairDecision HasRelation=True It='decides (b, a) the same as (a, b)'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:349 Get-BlastRadiusPairDecision HasRelation=True It='decides (b, a) the same as (a, b)'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:358 Get-BlastRadiusPairDecision HasRelation=False It='fails fast naming -Relation when the relation is omitted'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:359 Get-BlastRadiusConflictEdge HasRelation=False It='fails fast naming -Relation when the relation is omitted'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:366 Get-BlastRadiusPairDecision HasRelation=True It='invokes the supplied relation rather than resolving a command'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:193 Get-BlastRadiusPairDecision HasRelation=True It='does not make a shared-surface read citation hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:194 Get-BlastRadiusPairDecision HasRelation=True It='does not make a shared-surface read citation hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:301 Get-BlastRadiusConflictEdge HasRelation=True It='reproduces the expected radius for <FixtureName>'
CALL extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1:469 Get-BlastRadiusPairDecision HasRelation=True It=
CALLER-AUDIT Calls=23 MissingRelation=2
DOC file=.claude/agents/parallel-planner.md CallLines=1 WithRelation=1
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md CallLines=1 WithRelation=1
DOC file=.claude/skills/parallel-plan/SKILL.md CallLines=1 WithRelation=1
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md CallLines=1 WithRelation=1
DOC file=.claude/skills/parallel-add/SKILL.md CallLines=1 WithRelation=1
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md CallLines=1 WithRelation=1
LOOKUP-AUDIT RelationHelperLines=0 GetCommandLines=0
```

## Checks

- CALLER-AUDIT Calls=23 MissingRelation=2: yes (16 scheduling Pester calls, 2 historical-runs, 3 write-intent, 1 per scheduling module copy).
- Exactly two CALL lines carry HasRelation=False, both in tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 with It='fails fast naming -Relation when the relation is omitted': yes (lines 358 and 359).
- Each of the six DOC file= lines reports CallLines=1 WithRelation=1: yes.
- LOOKUP-AUDIT RelationHelperLines=0 GetCommandLines=0: yes.

Output Summary: PASS. Exit 0; CALLER-AUDIT Calls=23 MissingRelation=2 (the two intentional omissions in the fail-fast It); six DOC lines with WithRelation=1; LOOKUP-AUDIT 0 and 0. This also verifies P1-T7.
