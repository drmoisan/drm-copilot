# Remediation Cycle 2 AC-24 Per-Surface Baseline ([P0-T9], no run)

Timestamp: 2026-10-10T20-28
Command: copy of the `scope=judged` PER-SURFACE, BASE-SURFACE, FLOOR, NO-REGRESSION, and CHANGED-LINES lines, the HEAD_SHA line, and the PER-SURFACE-RESULT line from the last section headed `## Pass <n> current-tree re-run` (`## Pass 1 current-tree re-run`, lines 693 onward) of docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r1-ac24-per-surface.md
EXIT_CODE: 0
Output Summary: PS-SET per-surface percents (r1 Pass 1): enforce-epic-child-worktree-binding.ps1 95.78; enforce-epic-merge-gate.ps1 98.73; enforce-epic-planning-only.ps1 95.86; enforce-orchestration-preimplementation-gate.ps1 100.00; hook-dependency-guard.ps1 100.00; validate-bash.ps1 100.00. PER-SURFACE-RESULT: pass.

HEAD_SHA: 1dfe7ec71dbc4841b6f871c98a01045ac11fedb6

PER-SURFACE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.62 | covered=153 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | met | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=7 | total=7 | scope=judged
PER-SURFACE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.68 | covered=149 | missed=2 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-merge-gate.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-merge-gate.ps1 | met | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | covered=8 | total=8 | scope=judged
PER-SURFACE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.71 | covered=156 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-planning-only.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-planning-only.ps1 | met | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-planning-only.ps1 | covered=6 | total=6 | scope=judged
PER-SURFACE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=165 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | met | scope=judged
CHANGED-LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=12 | total=12 | scope=judged
PER-SURFACE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/hook-dependency-guard.ps1 | new file | scope=judged
FLOOR: .codex/hooks/hook-dependency-guard.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/hook-dependency-guard.ps1 | n/a | scope=judged
CHANGED-LINES: .codex/hooks/hook-dependency-guard.ps1 | covered=19 | total=19 | scope=judged
PER-SURFACE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=75 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/validate-bash.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/validate-bash.ps1 | met | scope=judged
CHANGED-LINES: .codex/hooks/validate-bash.ps1 | covered=8 | total=8 | scope=judged

PER-SURFACE-RESULT: pass
