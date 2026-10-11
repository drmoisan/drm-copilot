# Remediation Cycle 1 Baseline Gate ([P0-T11])

Timestamp: 2026-10-10T09-00

[P0-T3]: GREEN (route sh; EXIT_CODE 0; FailedCount 0; PassedCount 2)
[P0-T4]: GREEN (HEAD equals upstream; AHEAD 0; BEHIND 0; both ancestry checks exit 0; FETCH 0; cycle-start diff and porcelain only under the feature folder; SPEC-IN-CYCLE-DIFF: no)
[P0-T5]: GREEN (Formatted 0; Already formatted 469; porcelain outputs equal)
[P0-T6]: GREEN (PSScriptAnalyzer passed: no findings)
[P0-T7]: GREEN (root failures 0, errors 0; W-CHANGED-PROD-COUNT 57; every COVERAGE row SOURCEFILE_MATCHES 1; S-COUNT 61; L 341 = 238 + 61 + 42)
[P0-T8]: GREEN (33 passed)
[P0-T9]: GREEN (Codex preimplementation gate 500 lines; other values at most 466; 57 mirrors equal)
[P0-T10]: GREEN (CAT_FILE_EXIT_CODE 0; ROOT-IS-EXTRACTION yes; BASELINE-ROW numeric; CONTROL-MATCH: yes)

BASE-ROW-REGRESSION: met (.claude/hooks/validate-orchestrator-output-resolution.ps1: [P0-T7] 98.94 missed=1 against [P0-T10] BASELINE-ROW 98.96 missed=1; post missed is not above baseline missed)

CONTROL-GAP: present (the [P0-T7] BELOW-FLOOR and REGRESSION lists are not none, and [P0-T7] records UNCOVERED-CHANGED lines in .codex/hooks/hook-dependency-guard.ps1:103-111, .codex/hooks/validate-bash.ps1:304-306, and .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466-468; lines 305-306 and 467-468 and the helper lines are not RS-4 candidates)
