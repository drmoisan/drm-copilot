# QA gate — Coverage-comparison evidence correction (Fix 2, remediation cycle 1) (#501)

Timestamp: 2026-08-22T15-15

Task: [P3-T1]

## (a) Superseded claim and its source

`evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md` (its "Verdict" section, and the "Output Summary" line at the end of that artifact) states:

> "Every changed and new production file clears 85% individually, so there is no regression on changed lines. ... the verdict is PASS, not remediation-required."

That claim is derived solely from the per-file table in that artifact's "Changed-line coverage" section, which lists only the **nine newly-registered denominator files** added by the [P5-T6] `CodeCoverage.Path` change (`HookPayload.psm1`, the two extracted helper siblings, and six previously-unregistered hooks). `enforce-powershell-batch-budget.ps1` and `enforce-python-batch-budget.ps1` were already present in the coverage denominator before this feature and were not re-examined by that table, so the "no regression on changed lines" claim did not actually cover those two files.

That artifact (`evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md`) is **not edited** by this correction; it is left as the original executor record, and this new artifact supersedes its verdict for the two affected files.

## (b) Falsifying measurement

`policy-audit.2026-08-21T22-23.md` section 5 ("Blocking finding: batch-budget hook coverage regression") reports a reviewer measurement, taken in a throwaway worktree at merge-base `fb30a9a5`, running only the two hooks' suites with coverage scoped to those two files:

| File | Baseline | Post-change (pre-remediation) | Delta |
| --- | --- | --- | --- |
| `enforce-powershell-batch-budget.ps1` | 96.30% (78/81, missed lines 169, 180, 223) | 81.93% (68/83, missed lines 158, 221-241 region) | **-14.37 pp** |
| `enforce-python-batch-budget.ps1` | 96.30% (78/81, missed lines 166, 177, 220) | 81.93% (68/83, missed lines 155, 218-238 region) | **-14.37 pp** |

The policy-audit further identifies a single regressed changed line per file — `enforce-powershell-batch-budget.ps1:235` and `enforce-python-batch-budget.ps1:232` (the tail `$decision = Invoke-...Hook -ToolInputRaw (Read-ClaudeHookRawPayload) ...` statement) — covered at baseline, uncovered post-change (pre-remediation), which is the concrete falsification of the superseded "no regression on changed lines" claim.

## (c) Corrected per-changed-file LINE coverage table (all 27 changed production files)

The 25 rows below are reused verbatim from `policy-audit.2026-08-21T22-23.md` section 5 (unaffected by this cycle's fix). The two batch-budget hook rows are substituted with this cycle's post-fix figures from `evidence/qa-gates/2026-08-22T15-01-batch-budget-hooks-coverage-postfix.md` ([P2-T1]).

| File | Coverage | >= 85% |
|---|---|---|
| `.claude/hooks/check-powershell-test-purity.ps1` | 92.73% | yes |
| `.claude/hooks/check-python-test-purity.ps1` | 93.33% | yes |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 95.74% | yes |
| `.claude/hooks/enforce-completion-consistency.ps1` | 91.34% | yes |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 95.16% | yes |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | 89.55% | yes |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.43% | yes |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 98.90% | yes |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94.12% | yes |
| `.claude/hooks/enforce-evidence-locations.ps1` | 90.00% | yes |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 91.11% | yes |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 92.41% | yes |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 92.68% | yes |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 88.37% | yes |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 91.49% | yes |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` (new) | 100.00% | yes |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 98.48% | yes |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 99.04% | yes |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 94.12% | yes |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | **95.56%** (corrected, this cycle, [P2-T1]) | **yes** |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (new) | 95.31% | yes |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 92.00% | yes |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 86.76% | yes |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.16% | yes |
| `.claude/hooks/enforce-python-batch-budget.ps1` | **95.56%** (corrected, this cycle, [P2-T1]) | **yes** |
| `.claude/hooks/validate-bash.ps1` | 88.10% | yes |
| `.claude/lib/hook-payload/HookPayload.psm1` (new) | 96.12% | yes |

All 27 rows now show LINE coverage >= 85%. The two previously-failing rows are corrected from 81.93% (fail) to 95.56% (pass) each.

## (d) Corrected verdict

**No regression on changed lines**, for all 27 changed production files, not only the nine newly-registered ones.

Verification method: intersecting the `git diff -U0 fb30a9a5..HEAD` changed-line set against the missed-line set for every changed production file. For the 25 files unaffected by this cycle, this was already established in `evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md`'s "Changed-line coverage" section (nine newly-registered files) and in the [P7-T3]/original-feature per-file table (the remaining sixteen pre-existing files, all >= 85% individually per `policy-audit.2026-08-21T22-23.md` section 5, none of them flagged with a regressed changed line). For the two batch-budget hooks this cycle re-examined, the verification is `evidence/qa-gates/2026-08-22T15-05-batch-budget-changed-line-regression.md` ([P2-T2]), which computed the same `git diff -U0 fb30a9a5..HEAD` changed-line set against the current (post-fix) missed-line set for both files and found the intersection empty for both.

The originally-reported repository-wide aggregate figures in `evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md` (95.8226% repository-denominator, 96.0873% published-package-denominator) remain the correct historical measurement of that point in time; they are not restated here as current, because Phase 1 of this cycle further improved both hooks' coverage (confirmed repository-wide LINE coverage of 96.47% in [P2-T1], see `evidence/qa-gates/2026-08-22T15-01-batch-budget-hooks-coverage-postfix.md`).

## Summary

- Superseded claim: identified and attributed (a).
- Falsifying measurement: cited (b).
- Corrected table: all 27 changed production files, single table, >= 85% for every row (c).
- Corrected verdict: no regression on changed lines, verified per-file for all 27 files, with the two batch-budget hooks' verification evidenced by this cycle's P2-T2 artifact (d).

Output Summary: Corrected the coverage-comparison record. Both previously-failing rows (`enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1`) now read 95.56% each (was 81.93%), and every one of the 27 changed production files in the corrected single table clears the 85% floor. Verdict: no regression on changed lines, confirmed for all 27 files.
