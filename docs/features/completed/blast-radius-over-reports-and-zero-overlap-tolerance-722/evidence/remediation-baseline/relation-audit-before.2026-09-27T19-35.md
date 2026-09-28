# Relation Audit at Baseline (Remediation Cycle 1, P0-T9)

Timestamp: 2026-09-27T19-35
Command: sh SCRATCH/run-ps.sh SCRATCH/relation-audit.ps1 -Root "."
EXIT_CODE: 0

## Output (verbatim)

```text
CALL .claude/lib/blast-radius/BlastRadiusScheduling.psm1:473 Get-BlastRadiusPairDecision HasRelation=False It=
CALL tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1:107 Get-BlastRadiusConflictEdge HasRelation=False It="matches detection at tolerance 0 for $($case['Run'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1:127 Get-BlastRadiusConflictEdge HasRelation=False It="reproduces the pinned AFTER edges and tolerated overlaps for $($case['Run'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:157 Get-BlastRadiusPairDecision HasRelation=False It='keeps a shared-surface overlap hard at every tolerance'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:166 Get-BlastRadiusPairDecision HasRelation=False It='treats a contract dependency as hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:229 Get-BlastRadiusPairDecision HasRelation=False It='applies the integer inequality strictly at its boundary'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:230 Get-BlastRadiusPairDecision HasRelation=False It='applies the integer inequality strictly at its boundary'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:240 Get-BlastRadiusPairDecision HasRelation=False It='records the first canonical reason kind'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:241 Get-BlastRadiusPairDecision HasRelation=False It='records the first canonical reason kind'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:277 Get-BlastRadiusConflictEdge HasRelation=False It="reproduces the expected decisions for $($case['FixtureName'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:313 Get-BlastRadiusConflictEdge HasRelation=False It="matches detection at tolerance 0 for $($case['FixtureName'])"
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:331 Get-BlastRadiusConflictEdge HasRelation=False It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:334 Get-BlastRadiusConflictEdge HasRelation=False It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:335 Get-BlastRadiusConflictEdge HasRelation=False It='sorts edges and tolerated overlaps by pair'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:345 Get-BlastRadiusPairDecision HasRelation=False It='decides (b, a) the same as (a, b)'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:346 Get-BlastRadiusPairDecision HasRelation=False It='decides (b, a) the same as (a, b)'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1:356 Get-BlastRadiusPairDecision HasRelation=False It='fails fast naming the facade when Test-BlastRadiusConflict is unavailable'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:190 Get-BlastRadiusPairDecision HasRelation=False It='does not make a shared-surface read citation hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:191 Get-BlastRadiusPairDecision HasRelation=False It='does not make a shared-surface read citation hard'
CALL tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1:298 Get-BlastRadiusConflictEdge HasRelation=False It='reproduces the expected radius for <FixtureName>'
CALL extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1:473 Get-BlastRadiusPairDecision HasRelation=False It=
CALLER-AUDIT Calls=21 MissingRelation=21
DOC file=.claude/agents/parallel-planner.md CallLines=1 WithRelation=0
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md CallLines=1 WithRelation=0
DOC file=.claude/skills/parallel-plan/SKILL.md CallLines=1 WithRelation=0
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md CallLines=1 WithRelation=0
DOC file=.claude/skills/parallel-add/SKILL.md CallLines=1 WithRelation=0
DOC file=extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md CallLines=1 WithRelation=0
LOOKUP-AUDIT RelationHelperLines=2 GetCommandLines=2
```

Output Summary: PASS. Exit 0; one CALLER-AUDIT line (Calls=21 MissingRelation=21, equal to the expected values), six DOC file= lines (each CallLines=1 WithRelation=0), and one LOOKUP-AUDIT line reporting RelationHelperLines=2 GetCommandLines=2.
