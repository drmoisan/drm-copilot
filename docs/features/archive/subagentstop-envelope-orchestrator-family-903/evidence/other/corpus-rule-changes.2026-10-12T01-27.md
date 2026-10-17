# Corpus Rule Changes (Amendment B, rule 16)

Timestamp: 2026-10-12T01-27
CORPUS_REF_SHA: 2ef8d361e978ca8b7733a545d76a87e8418005ce
CORPUS_RULE_CHANGE_COUNT: 2
CORPUS_ROWS_ADDED_LINES_PLANNER: 18

RULE-CHANGE 1:
- Validator: executor
- File: .claude/hooks/validate-executor-output.ps1
- Trigger: [P2-T13] first run reported FALSE_POSITIVES=164 (CORPUS_TOTAL=307, EXPECTED_PASS=164), every line with message `HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.` Classification: rule 16 (iii) excludes this binding message, so (iv) applies through the pre-resolved binding fix.
- Predicate before (line 86, Test-IsPreflightPlan; line 97, Get-TouchedLanguagesFromPlan): `        [string[]] $Lines`
- Predicate after (lines 86 and 97, edited in place): `        [AllowEmptyString()] [string[]] $Lines`
- Row: `CORPUS-EXE-1 accepts a plan line array that contains an empty line`, added to tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 after line 189 (7 lines including the leading blank line).
- Rationale: the mandatory `[string[]]` parameter rejects any empty-string element at binding time, so every plan that contains a blank line made the hook throw before any decision rule ran. A thrown exception is not a validation verdict. Allowing empty elements changes no decision rule: an empty line matches neither the preflight directive pattern nor the path pattern.
- Shift: none for production anchors (lines 86 and 97 edited in place; no line moves). Test file lines after 189 shift +7 (193 to 200); no executor-suite anchor cited by the plan lies after line 189 (the only cited anchor is lines 14-19 in [P4-T17]).
- SPEC_INVARIANT_EXCEPTION: spec.md:217 (operator Amendment B)

RULE-CHANGE 2:
- Validator: planner
- File: .claude/hooks/validate-planner-output.ps1 (Get-PlanStructureValidationReport)
- Trigger: [P2-T14] first run reported FALSE_POSITIVES=115 (CORPUS_TOTAL=307, EXPECTED_PASS=115), every line with message `HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.` Rule 16 (iv) pre-resolved planner fix: the binding fix and the four-line predicate change are applied together.
- Change A (binding fix), line 236 edited in place. Before: `        [string[]] $Lines`. After: `        [AllowEmptyString()] [string[]] $Lines`. Shift: none.
- Change B (predicate), 4 added lines. Before: every line matching `^- \[` after the first phase heading was treated as a task line and reported with `task line must match` when it did not match `$taskPattern`, including non-task checklist lines under a level-1 or level-2 heading after the final phase (for example `## Preflight Checklist`). After: `$insidePhaseSection` is set to `$false` after `$foundTask = $false`, set to `$true` as the first statement inside `if ($line -match '^### Phase ') {`, reset to `$false` by `if ($line -match '^#{1,2} ') { $insidePhaseSection = $false; continue }` before the `^- \[` check, and `if (-not $insidePhaseSection -and $line -notmatch $taskPattern) { continue }` precedes `$foundTask = $true`. Outside a phase section, a non-task `- [` line is skipped. A canonical task line is still evaluated everywhere, so `task appears before the first canonical phase heading` is unchanged. Inside a phase section, every `- [` line is still checked against `$taskPattern`.
- Row: `CORPUS-PLN-1 ignores a non-task checkbox line under a level-2 heading after the final phase`, added to tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 after line 311 (18 lines). Its line array carries an empty element (`'', '## Preflight Checklist',`), so the row covers both changes.
- Rationale: change A removes a binding exception, which is not a validation verdict, on every plan that contains a blank line. Change B stops the hook from rejecting non-task checklist lines in document sections that follow the final phase. Those lines are not tasks, and `_plan_structure_errors` (the canonical validator) does not treat them as tasks. Exact alignment with the oracle was not applied, because the oracle skips every `- [` line that lacks `[P` and `-T`, which would make the existing row at tests/scripts/claude-hooks/validate-planner-output.Tests.ps1:227-239 fail (rule 16 limit).
- Shifts: production lines after 246 shift +4 (371 -> 375, 372 -> 376, 376 -> 380, 381 -> 385, 386 -> 390, 389 -> 393, 392 -> 396, 397 -> 401; S1 lines 406-408 -> 410-412). Lines 1-246 do not move (guard 33, Set-StrictMode 35, $ErrorActionPreference 36, help block). Test lines after 311 shift +18 (329 -> 347); lines 1-311 do not move.
- SPEC_INVARIANT_EXCEPTION: spec.md:217 (operator Amendment B)
