# R1 CR-3 Row Discrimination (Issue #927, decision D-R1-5)

Timestamp: 2026-10-16T07-41
Command: git show afa951ac0207eae934ac695e7340f18b3cf77522:.claude/hooks/enforce-pr-author-skill.docs-only.ps1 > SCRATCH/927/r1-out/docs-only-merge-base.ps1
EXIT_CODE: 0
Output Summary: The merge-base docs-only hook denies only tokens that start with -B (one StartsWith('-B') line, no IndexOfAny); the current hook uses IndexOfAny (count 1). The modified row --base main -B=main is denied under both old and new code; the new row -dB=other resolves base main under the old rule and therefore fails against the old code.

Command 2: grep -n -F -e "StartsWith('-B'" SCRATCH/927/r1-out/docs-only-merge-base.ps1
EXIT_CODE_2: 0
OLD_RULE_LINE: 124:        if ($text.StartsWith('-B', [System.StringComparison]::Ordinal)) {

Command 3: grep -c -F -e 'IndexOfAny' SCRATCH/927/r1-out/docs-only-merge-base.ps1
EXIT_CODE_3: 1
COUNT_3: 0

Command 4: grep -c -F -e 'IndexOfAny' .claude/hooks/enforce-pr-author-skill.docs-only.ps1
EXIT_CODE_4: 0
COUNT_4: 1

OLD_RULE: StartsWith('-B')
OLD_RESULT --base main -B=main: denied (row passes under old and new code)
OLD_RESULT -dB=other: base main resolved (row fails under old code)
