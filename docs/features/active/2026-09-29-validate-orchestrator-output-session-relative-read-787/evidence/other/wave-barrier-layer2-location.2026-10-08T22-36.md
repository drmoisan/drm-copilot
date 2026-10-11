# WAVE Layer 2 Sentence Location (P0-T13)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/locate-text.ps1 -Path .claude/hooks/enforce-epic-wave-barrier.ps1 -Literal 'Layer 2'
EXIT_CODE: 0
Output Summary:
HELP_END_LINE=40
MATCH line=30 text=retrospective backstop (Layer 2) is the wave-barrier ordering invariant inside
MATCH-SUMMARY count=1

Located paragraph (merged tree, MERGED_SHA 35790c07): lines 29-32 of `.claude/hooks/enforce-epic-wave-barrier.ps1`, bounded by the blank comment-help lines 28 and 33. Every match line (30) is less than HELP_END_LINE (40).

Paragraph text (verbatim, 4-space indent):

```text
    This is the per-call deterrent (Layer 1) of the two-layer wave-barrier design; the
    retrospective backstop (Layer 2) is the wave-barrier ordering invariant inside
    validate_epic_orchestrator_state_text, enforced separately at epic-orchestrator
    SubagentStop time.
```

This is the paragraph P5-T3 replaces. The paragraph holds no additional Layer 1 sentences beyond its opening clause, which the Appendix E3 text restates.

Result: PASS (count 1, match inside the help block).
