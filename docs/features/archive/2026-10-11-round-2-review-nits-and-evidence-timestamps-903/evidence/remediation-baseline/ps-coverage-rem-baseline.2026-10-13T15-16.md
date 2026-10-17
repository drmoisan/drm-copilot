# PowerShell coverage baseline for remediation lines (remediation cycle 1, P0-T5)

Timestamp: 2026-10-13T15-16
Command: (1) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_line_dump_903.py <worktree>/artifacts/scratch-903/ci-final2-903/powershell-coverage.xml .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372; (2) the same with .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372; (3) the same with .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 182 210; (4) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_cov_extract_903.py <worktree>/artifacts/scratch-903/ci-final2-903/powershell-coverage.xml files
EXIT_CODE: 0
Output Summary: All four commands exited 0. Codex targets: 356 0, 360 1, 364 1, 370 0. Claude targets: 356 1, 370 1. Codex epic-scope: 183 0, 190 0, 191 0, 206 0, 207 0, 209 0. Per-file: Codex targets 98.16, Codex epic-scope 89.09. All expected values match; no BASELINE-MISMATCH.

Source: coverage XML of CI run 38410234897 (headSha 17a6497e4).

## (1) Codex targets 353-372 (exit 0)

```
353 1
354 1
356 0
360 1
364 1
370 0
```

## (2) Claude targets 353-372 (exit 0)

```
353 1
354 1
356 1
360 1
364 1
370 1
```

## (3) Codex epic-scope 182-210 (exit 0)

```
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

## (4) Per-file table (exit 0)

| File | Covered | Missed | Percent |
|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 33 | 0 | 100.0 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 135 | 2 | 98.54 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 90.37 |
| .claude/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .codex/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 |
| .claude/hooks/enforce-completion-consistency.ps1 | 140 | 9 | 93.96 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 160 | 3 | 98.16 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 67 | 1 | 98.53 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | 6 | 89.09 |
