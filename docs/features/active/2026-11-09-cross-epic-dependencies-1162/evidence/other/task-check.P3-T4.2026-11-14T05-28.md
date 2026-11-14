# Task Check P3-T4

Timestamp: 2026-11-14T05-28
Command: sh SCRATCH/issue-1162-tc.sh "tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1" "<selection>"; sh SCRATCH/issue-1162-py.sh -q -p no:cacheprovider tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py
EXIT_CODE: 1
Output Summary: format differences 0; analyzer findings 0; Pester passed=62 failed=2 total=64; pytest 8 passed, exit 0. Both remaining failures are 'epic-progress-report delivery' cases owned by P4-T5 (core.json listing of Get-EpicProgressReport.CrossEpic.ps1 and bundle byte identity of SKILL.md). Every 'SKILL.md structure and content' case passes, including 'states the report format fragments', 'contains every required heading', and 'stays under 500 lines'.

## Changed files

- .claude/skills/epic-progress-report/SKILL.md: the WIP commit added the `## Calculation Rules` cross-epic bullet and the `**Cross-epic:**` format line. This run added one sentence to the Critical-path bullet of `## Report Formats` stating when the line appears and that `<label>` is `external` or `external (default)`; the fragment test reads that section and the WIP text held `external (default)` only under `## Calculation Rules`. No heading was added; 498 physical lines (wc -l).
- tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1 (WIP commit): adds the `**Cross-epic:**` and `external (default)` fragments and changes both skill-folder file counts from 13 to 14.

## Selection and rule

Contract tests that read the changed Markdown path: EpicProgressReport.SkillContract.Tests.ps1, Get-EpicProgressReport.Tests.ps1 (its repository-constraints Describe scans SKILL.md), and tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py.

## First pass

Before the SKILL.md edit, the P3-T2 and P3-T3 task checks recorded 'states the report format fragments' failing on `external (default)`.
