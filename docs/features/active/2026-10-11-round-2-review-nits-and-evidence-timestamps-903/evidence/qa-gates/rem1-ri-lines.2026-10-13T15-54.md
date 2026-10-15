# Remediation cycle 1 RI line values from the remediated-head CI XML (P5-T4)

Timestamp: 2026-10-13T15-54
Command: (1) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_line_dump_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372; (2) the same with .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372; (3) the same with .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 182 210; (4) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_cov_extract_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml files
EXIT_CODE: 0
Output Summary: All four commands exited 0. Codex targets 356 0 -> 1 and 370 0 -> 1; Claude targets 356 and 370 remain 1. Codex epic-scope 183, 190, 191, 206, 207, 209 remain 0. Per-file: Codex targets 98.16 -> 99.39; Codex epic-scope 89.09 (unchanged). RI-1: PASS. RI-2: UNATTRIBUTED.

Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/38423196404 (headSha 41d406d20de2ae850b60ee2b81e47276c1f0d4ff). Baseline: `evidence/remediation-baseline/ps-coverage-rem-baseline.2026-10-13T15-16.md` (run 38410234897).

## RI line table

| File | Line | Baseline `ci` (P0-T5) | New `ci` |
|---|---|---|---|
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 353 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 354 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 356 | 0 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 360 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 364 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 370 | 0 | 1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 356 | 1 | 1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 370 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 182 | 1 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 183 | 0 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 190 | 0 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 191 | 0 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 206 | 0 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 207 | 0 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 209 | 0 | 0 |

Full dumps:

```
== .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372
353 1
354 1
356 1
360 1
364 1
370 1
== .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372
353 1
354 1
356 1
360 1
364 1
370 1
== .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 182 210
182 1
183 0
185 2
186 1
187 2
188 2
189 1
190 0
191 0
193 1
194 1
196 1
198 1
199 1
201 1
203 1
204 1
206 0
207 0
209 0
```

## Per-file table

| File | Covered | Missed | Percent |
|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 33 | 0 | 100.0 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 135 | 2 | 98.54 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 90.37 |
| .claude/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .codex/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .claude/hooks/enforce-completion-consistency.ps1 | 140 | 9 | 93.96 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 67 | 1 | 98.53 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | 6 | 89.09 |

## Results

RI-1: PASS (Codex targets 356 = 1, 370 = 1; Claude copy 356 = 1, 370 = 1).

RI-2: UNATTRIBUTED (Codex epic-scope 206 = 0, 207 = 0, although ES-D1 passes on Windows in the coverage job per `rem1-ps-rows.2026-10-13T15-54.md`).
