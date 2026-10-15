# PowerShell per-file and changed-line coverage (P12-T24 rerun, remediation cycle 1 P6-T1)

Timestamp: 2026-10-13T15-55
Command: poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_cov_extract_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml files; git -C <worktree> diff -U0 origin/main...HEAD -- <the ten files> > <worktree>/artifacts/scratch-903/ps-changed-lines-diff-rem1-903.txt; poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_changed_lines_903.py <worktree>/artifacts/scratch-903/ps-changed-lines-diff-rem1-903.txt <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml; git -C <worktree> merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary: Merge-base fd81a43b45de65078236da6c1cbfd077c3eb010c. Per-file line coverage: all ten files at or above 85% (lowest: Codex epic-scope 89.09%). Three files below their P1-T3 baseline (recorded, not blocking): Claude targets 99.39 (100.0), Codex targets 99.39 (100.0), Claude epic-scope 98.53 (98.63). Changed lines: 154 executable added lines, 149 with `ci` > 0 (96.75%). All 5 uncovered lines are exempt: rule (a) 1, rule (c) 2, rule (d) 2. Codex targets 356 and 370 are covered (`ci` 1). Acceptance: PASS.

Sources: CI run https://github.com/drmoisan/drm-copilot/actions/runs/38423196404 (headSha 41d406d20de2ae850b60ee2b81e47276c1f0d4ff; see `rem1-ci.2026-10-13T15-53.md`). CIDIR: `artifacts/scratch-903/ci-rem1-903/`. Path substitution: the original plan names `artifacts/scratch-903/ci-final-903/powershell-coverage.xml`; this rerun reads `artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml`. Baseline: `evidence/baseline/ps-coverage-baseline.2026-10-13T11-14.md` (original plan P1-T3). The diff base is `origin/main...HEAD` (merge-base fd81a43b4); the diff file is byte-identical to the prior `ps-changed-lines-diff-903.txt` used by `ps-coverage.2026-10-13T14-28.md` (`cmp` returned equal), confirming that no production file changed during remediation.

## Per-file line coverage

| File | Covered | Missed | Percent | P1-T3 baseline | At least 85% | Versus baseline |
|---|---|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 33 | 0 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 135 | 2 | 98.54 | 98.54 | yes | equal |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 90.37 | 90.37 | yes | equal |
| .claude/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 | 100.0 | yes | equal |
| .codex/hooks/feature-folder-resolution.ps1 | 111 | 0 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-completion-consistency.ps1 | 140 | 9 | 93.96 | 93.84 | yes | higher |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 | 100.0 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 162 | 1 | 99.39 | 100.0 | yes | lower (recorded, not blocking) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 67 | 1 | 98.53 | 98.63 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | 6 | 89.09 | 78.33 | yes | higher |

## Changed-line coverage

An added line is executable when the XML has a `line` element for it. Counts per file:

| File | Added lines | Executable | `ci` > 0 | `ci` = 0 |
|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 7 | 4 | 4 | 0 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 2 | 2 | 2 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 2 | 2 | 2 | 0 |
| .claude/hooks/feature-folder-resolution.ps1 | 2 | 1 | 1 | 0 |
| .codex/hooks/feature-folder-resolution.ps1 | 2 | 1 | 1 | 0 |
| .claude/hooks/enforce-completion-consistency.ps1 | 19 | 4 | 3 | 1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 122 | 64 | 63 | 1 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 122 | 64 | 63 | 1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 7 | 6 | 6 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 7 | 6 | 4 | 2 |
| Total | 292 | 154 | 149 | 5 |

Changed-line coverage: 149 / 154 = 96.75% (prior run: 147 / 154 = 95.45%).

### Uncovered changed lines and exemption status

| File:line | Text | `ci` | Exemption | Reason |
|---|---|---|---|---|
| .claude/hooks/enforce-completion-consistency.ps1:484 | `$decision = Invoke-CompletionConsistencyEntryPoint` | 0 | (a) exempt | The tail call that replaces former line 466, after the dot-source early `return`; the dot-sourced test harness never reaches it. Its logic is in `Invoke-CompletionConsistencyEntryPoint`, whose added executable lines are covered. |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | `$value = ''` | 0 | (c) exempt | CR-4 wrap isolating the `else { $value = '' }` part of P1-T4 line 146 (baseline `ci` 4); the line carrying the statement's opening condition (160) has `ci` greater than 0. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | `$value = ''` | 0 | (c) exempt | Same as the Claude copy. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 | `if ($outcome.Outcome -eq 'deny') {` | 0 | (d) exempt | Remediation rule (d): the P5-T5 artifact `evidence/qa-gates/rem1-ri2-exemption.2026-10-13T15-54.md` exists (Disposition: exempt (non-regression; coverage attribution anomaly)). ES-D1 drives this line to `deny` and passes on Windows; the replaced baseline statements were also `ci` 0. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 | `return Get-OrchestrationPreimplementationGateBlockDecision -Reason $outcome.Reason` | 0 | (d) exempt | Same as line 206. |

Resolved since the prior run: `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356` and `:370` now have `ci` 1 (U26 rows) and are not in the uncovered list.

## Acceptance

- Merge-base begins with `fd81a43b4`: PASS (fd81a43b45de65078236da6c1cbfd077c3eb010c).
- Every file's line coverage is at least 85%: PASS.
- Every changed executable line has `ci` > 0 except lines listed with exemption (a), (b), (c), or (d): PASS (5 uncovered, all exempt).
- Codex targets 356 and 370 not in the uncovered list: PASS.
- Per-file percentages below the P1-T3 baseline (three files) are recorded and are not blocking.

P12-T24: PASS
