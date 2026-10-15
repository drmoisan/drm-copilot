# PowerShell Format Baseline ([P0-T14])

Timestamp: 2026-10-09T22-09
Command: sh <SCRATCHPAD>/r.sh p0t14 (git status --porcelain; capture of every W-CLOSURE file's bytes; Invoke-PoshQCFormat -Root $root -ScanFolders @('.claude/hooks','.claude/lib','.codex/hooks','.codex/scripts','tests/scripts/claude-hooks','tests/scripts/codex-hooks','tests/scripts/claude-runtime','tests/scripts/claude-lib','tests/scripts/codex-scripts') with the information stream captured; restore of captured bytes when changed; git status --porcelain)
EXIT_CODE: 0
Output Summary: Formatted: count 0; Already formatted: count 443; no captured file changed (no RESTORED-ORIGINALS); the final porcelain output equals the first.

Formatted: count: 0
Already formatted: count: 443

Tree Delta: the first and second porcelain outputs are in the output block below (sections "Porcelain 1" and "Porcelain 2"); they are identical, so no third porcelain output was required.

Output (the 443 `Already formatted:` lines are included):

```text
## Porcelain 1
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
## Formatter
FORMATTED_COUNT: 0
ALREADY_FORMATTED_COUNT: 443
## Porcelain 2
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
PORCELAIN_FINAL_EQUALS_FIRST: True
```
