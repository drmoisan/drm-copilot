# Mirror Hashes at Baseline (Remediation Cycle 1, P0-T7)

Timestamp: 2026-09-27T19-35
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 .claude/lib/blast-radius/BlastRadius.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 .claude/agents/parallel-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
EXIT_CODE: 0

## Output (verbatim)

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Hash=50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24
.claude/lib/blast-radius/BlastRadius.psm1 Hash=5D41E44410209242FA0E18EE337A176455CDA0724675ECD25A572F4F8D099400
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 Hash=5D41E44410209242FA0E18EE337A176455CDA0724675ECD25A572F4F8D099400
.claude/agents/parallel-planner.md Hash=9CED10C78584C52AB2DECC589052D38579873BFA3E5B3B2BF4B1E4D58183861E
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md Hash=9CED10C78584C52AB2DECC589052D38579873BFA3E5B3B2BF4B1E4D58183861E
.claude/skills/parallel-plan/SKILL.md Hash=CC253E4CEFC1D6727EA56F67FC09A55768109F15593615D2688E8EE78D58A265
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md Hash=CC253E4CEFC1D6727EA56F67FC09A55768109F15593615D2688E8EE78D58A265
.claude/skills/parallel-add/SKILL.md Hash=A96931FCBBED11251F60FD517448254A6AC1E784657517D6F54CE0433FAEAFF2
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md Hash=A96931FCBBED11251F60FD517448254A6AC1E784657517D6F54CE0433FAEAFF2
```

Output Summary: PASS. Exit 0; each of the five primary/mirror pairs has two equal Hash values.
