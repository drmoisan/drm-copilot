# AC-22 Input and Section Check (P10-T5)

Timestamp: 2026-09-29T20-50
Command: git grep -c -F -e 'budget: prod=' -- .claude/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-python-engineer/SKILL.md .agents/skills/invoke-powershell-engineer/SKILL.md <their three bundle mirrors>; git grep -c -F -e 'Per-Batch Change Budget' -- <two router copies and their two mirrors>; git grep -c -F -e 'Scope Expansion Protocol' -- <same four>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: All three searches exit 1 with no output. Baseline (ac22-ac8-nonvacuity.2026-09-29T19-14.md) found `budget: prod=` in each of the three invoke skills.
