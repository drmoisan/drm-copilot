# Mirror Production (Remediation Cycle 1, P1-T8)

Timestamp: 2026-09-27T19-56
Command: sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source <primary> -Destination <mirror> (five runs, one per pair); then sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <the ten files>
EXIT_CODE: 0

## Copy outputs (each run exit 0)

```text
COPIED .claude/lib/blast-radius/BlastRadiusScheduling.psm1
COPIED .claude/lib/blast-radius/BlastRadius.psm1
COPIED .claude/agents/parallel-planner.md
COPIED .claude/skills/parallel-plan/SKILL.md
COPIED .claude/skills/parallel-add/SKILL.md
```

Destinations: the matching paths under extensions/drm-copilot/resources/claude-customizations/.

## Hash output (verbatim, exit 0)

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=FE9484E488D7C8FC4E19D6A70B43D9C3EB2A1A795224D77F136F9C6E383C12B1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=FE9484E488D7C8FC4E19D6A70B43D9C3EB2A1A795224D77F136F9C6E383C12B1
.claude/lib/blast-radius/BlastRadius.psm1 Hash=F571010210477F2CD43C6FD179DE2B52A7466F1DE272F9D66EC66CB2780C4276
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 Hash=F571010210477F2CD43C6FD179DE2B52A7466F1DE272F9D66EC66CB2780C4276
.claude/agents/parallel-planner.md Hash=F6B9CC65FF6AE7B478C940797B2BDC44990DC82E62FE4661B6CCDD0A77AB3394
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md Hash=F6B9CC65FF6AE7B478C940797B2BDC44990DC82E62FE4661B6CCDD0A77AB3394
.claude/skills/parallel-plan/SKILL.md Hash=9F19BC59BA67EB69B174436333996A3C15C7F370BAF214670B1DDA29F3743862
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md Hash=9F19BC59BA67EB69B174436333996A3C15C7F370BAF214670B1DDA29F3743862
.claude/skills/parallel-add/SKILL.md Hash=D3453623B50D6F80CE98ADF92581B61F407E487DCD3669DFCC1374B7ADD1B741
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md Hash=D3453623B50D6F80CE98ADF92581B61F407E487DCD3669DFCC1374B7ADD1B741
```

Output Summary: PASS. Five COPIED lines; each of the five pairs has two equal Hash values.
