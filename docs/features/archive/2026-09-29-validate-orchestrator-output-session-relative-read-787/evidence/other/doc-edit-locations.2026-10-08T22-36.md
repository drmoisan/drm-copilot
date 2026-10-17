# SKILL and AGENT Edit Locations (P0-T14)

Timestamp: 2026-10-08T22-36

## SKILL

Command: sh SCRATCH/run-ps.sh SCRATCH/locate-text.ps1 -Path .claude/skills/epic-orchestrate/SKILL.md -Literal 'retrospective backstop:'
EXIT_CODE: 0
Output Summary:
HELP_END_LINE=0
MATCH line=244 text=- **Layer 2 - retrospective backstop:** the wave-barrier ordering invariant inside
MATCH-SUMMARY count=1

(The console rendered the em dash of the source line as `-`; the file text is `**Layer 2 — retrospective backstop:**`.)

Bullet range: lines 244-254 of `.claude/skills/epic-orchestrate/SKILL.md` (the `**Layer 2 — retrospective backstop:**` bullet under `## Wave Barrier (Two-Layer Design)`, ending before the blank line 255). P5-T1 replaces this whole bullet.

## AGENT

Command: sh SCRATCH/run-ps.sh SCRATCH/locate-text.ps1 -Path .claude/agents/epic-orchestrator.md -Literal 'SubagentStop'
EXIT_CODE: 0
Output Summary:
HELP_END_LINE=0
MATCH line=25 text=SubagentStop:
MATCH line=127 text=at your own `SubagentStop` time.
MATCH-SUMMARY count=2

The line-127 match is inside the `## Wave Scheduling` paragraph, lines 118-127 (the paragraph that contains `validate_epic_orchestrator_state_text`, line 126). The sentence beginning "Do not launch wave N+1" starts on line 123 and runs to the end of the paragraph at line 127; P5-T2 replaces that span. The line-25 match is the frontmatter hook registration and is not edited.

Result: PASS. SKILL count is exactly 1; AGENT has a match (line 127) in the `## Wave Scheduling` paragraph, range 118-127.
