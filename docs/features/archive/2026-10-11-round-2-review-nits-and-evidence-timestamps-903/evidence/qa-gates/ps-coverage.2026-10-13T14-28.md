# PowerShell per-file and changed-line coverage (P12-T24)

Timestamp: 2026-10-13T14-28
Command: poetry -C <worktree> run python -I artifacts/scratch-903/ps_cov_extract_903.py artifacts/scratch-903/ci-final2-903/powershell-coverage.xml files; git -C <worktree> diff -U0 origin/main...HEAD -- <the ten files> > artifacts/scratch-903/ps-changed-lines-diff-903.txt; poetry -C <worktree> run python -I artifacts/scratch-903/ps_changed_lines_903.py artifacts/scratch-903/ps-changed-lines-diff-903.txt artifacts/scratch-903/ci-final2-903/powershell-coverage.xml; poetry -C <worktree> run python -I artifacts/scratch-903/ps_line_dump_903.py <xml> <file> <first> <last> (baseline and final per-line checks)
EXIT_CODE: 1
Output Summary: Per-file line coverage: all ten files are at or above 85% (lowest: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` 89.09%, up from 78.33%). Three files are below their P1-T3 baseline (recorded, not blocking): Claude targets 99.39 (baseline 100.0), Codex targets 98.16 (baseline 100.0), Claude epic-scope 98.53 (baseline 98.63). Changed lines: 154 executable added lines, 147 with `ci` > 0. Of the 7 with `ci` 0, 3 are exempt (rule (a): 1; rule (c): 2) and 4 are not exempt: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206` and `:207`, and `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356` and `:370`. Acceptance: FAIL (blocking finding: four non-exempt uncovered changed lines, all in Codex-surface copies).

Sources: coverage XML of CI run https://github.com/drmoisan/drm-copilot/actions/runs/38410234897 (headSha 17a6497e4ca2b50baca1dc2510108d7128ded79a). Path substitution: the plan names `artifacts/scratch-903/ci-final-903/powershell-coverage.xml`; that directory holds the failed iteration 1 run (no Windows artifact). This pass reads `artifacts/scratch-903/ci-final2-903/powershell-coverage.xml`. Baselines: `evidence/baseline/ps-coverage-baseline.2026-10-13T11-14.md` (P1-T3) and `evidence/baseline/ps-catch-lines-baseline.2026-10-13T11-14.md` (P1-T4), both from run 38386628228 on PHASE0 95d6c9b22. The diff base is `origin/main...HEAD` (merge-base fd81a43b4; PHASE0 already contains the branch's merge of origin/main 606c1d517, and `git diff --stat 2ef8d361e fd81a43b4 -- <ten files>` is empty, so the baseline line numbers are consistent with this diff).

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
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 160 | 3 | 98.16 | 100.0 | yes | lower (recorded, not blocking) |
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
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 122 | 64 | 61 | 3 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 7 | 6 | 6 | 0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 7 | 6 | 4 | 2 |
| Total | 292 | 154 | 147 | 7 |

Changed-line coverage: 147 / 154 = 95.45%.

### Uncovered changed lines and exemption status

| File:line | Text | `ci` | Exemption | Reason |
|---|---|---|---|---|
| .claude/hooks/enforce-completion-consistency.ps1:484 | `$decision = Invoke-CompletionConsistencyEntryPoint` | 0 | (a) exempt | The tail call that replaces former line 466, after the dot-source early `return`; the dot-sourced test harness never reaches it. Its logic is in `Invoke-CompletionConsistencyEntryPoint`, whose added executable lines are covered (the three O-4 rows). |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | `$value = ''` | 0 | (c) exempt | CR-4 wrap isolating the `else { $value = '' }` part of P1-T4 line 146 (baseline `ci` 4); the line carrying the statement's opening condition, `if ($index -lt $Token.Count) {` at 160, has `ci` 1. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:167 | `$value = ''` | 0 | (c) exempt | Same as the Claude copy: part of P1-T4 line 146 (baseline `ci` 4); line 160 has `ci` 1. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356 | `return $prefix + "more than one worktree claims the epic integration branch for target $Detail. " +` | 0 | none — BLOCKING | CR-4 wrap of P1-T4 line 318 (the `target-ambiguous` return), baseline `ci` 1. The line carries the statement's opening `return` keyword itself and has `ci` 0, so (c) does not apply; baseline `ci` was not 0, so (b) does not apply. The Claude copy of the same line (356) has `ci` 1. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:370 | `return $prefix + "the target worktree of this epic-scope operation cannot be resolved ($Detail). " +` | 0 | none — BLOCKING | CR-4 wrap of P1-T4 line 327 (the final unresolvable return), baseline `ci` 1. Same reasoning as line 356. The Claude copy (370) has `ci` 1. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 | `if ($outcome.Outcome -eq 'deny') {` | 0 | none — BLOCKING | #732 CR-3 tail rewrite (P9). Exemptions (b) and (c) are limited to targets-file lines and (a) to the completion-consistency tail call. The replaced baseline statements (`if ($verdict.Verdict -eq 'deny')` at 202 and the `foreach` block at 206-215) also had `ci` 0 at baseline (dumped from the P1-T3 XML: 202 0, 203 0, 206-217 0), so this is unchanged reachability, not a regression, but it is not an exempt category. The Claude copy of the same tail is covered. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 | `return Get-OrchestrationPreimplementationGateBlockDecision -Reason $outcome.Reason` | 0 | none — BLOCKING | Same as line 206. |

Observation: in the final run, the Codex targets copy's `target-mixed` (360) and `target-not-ready` (364) returns are covered (`ci` 1) while `target-ambiguous` (356) and the final return (370) are not; at PHASE0 all four Codex statements had `ci` 1. No Codex-surface test in run 38410234897 drives a `target-ambiguous` or unresolvable deny reason through the Codex copy, and no Codex epic-scope test reaches a `deny` outcome.

## Acceptance

- Every file's line coverage is at least 85%: PASS.
- Every changed executable line has `ci` > 0 except listed exempt lines: FAIL. Four non-exempt lines have `ci` 0 (Codex epic-scope 206, 207; Codex targets 356, 370).
- Per-file percentages below the P1-T3 baseline (three files) are recorded and are not blocking.

Result: blocking finding. Remediation requires Codex-surface tests that drive the Codex `Get-OrchestrationEpicScopeDecision` to a `deny` outcome and the Codex `Get-OrchestrationEpicTargetDenyReason` through `target-ambiguous` and the unresolvable fall-through; that is new test work outside the approved plan and is escalated to the orchestrator.
