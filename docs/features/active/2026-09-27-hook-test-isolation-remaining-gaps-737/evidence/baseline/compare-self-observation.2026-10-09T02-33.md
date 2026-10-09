# P0-T14 CR-COMPARE observation (P0-T12 artifact compared with itself)

Timestamp: 2026-10-09T02-33
Command: Route C: CR-COMPARE with the P0-T12 artifact as BEFORE and AFTER, empty by-design list, via pwsh -NoProfile -File (result=EQUAL lines summarized by count; every other COMPARE line kept)
EXIT_CODE: 1
Output Summary:
EQUAL-LINES: 176
COMPARE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | result=DIFFERENT
COMPARE-DIFFERENT-COUNT: 1

DEVIATION DEV-2 (continued): the single DIFFERENT line is the suite with Failed=1 in the P0-T12 baseline (the local item-checkpoint dependence of the spawned Codex handlers, recorded in the P0-T12 artifact). CR-COMPARE classifies a suite EQUAL only when Failed is 0 on both sides, so a suite compared with itself reports DIFFERENT while its baseline Failed count is non-zero. Every other suite (176) reports result=EQUAL.
EXIT_CODE_COMPUTED: 1
