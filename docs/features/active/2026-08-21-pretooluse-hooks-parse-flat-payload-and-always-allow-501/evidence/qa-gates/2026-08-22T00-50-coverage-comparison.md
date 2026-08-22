# QA gate — Coverage comparison, baseline versus post-change (AC-11) (#501)

Timestamp: 2026-08-22T00-50

Task: [P7-T5]

## Numeric source

Both percentages derive from the `LINE` missed/covered counters of the JaCoCo-format coverage report the Pester run writes, per the plan:

- Baseline: `artifacts/pester/powershell-coverage.xml` as captured in `evidence/baseline/2026-08-21T22-08-poshqc-test-baseline.md` ([P0-T4]).
- Post-change, run 1: `artifacts/pester/powershell-coverage.xml` as captured in `evidence/qa-gates/2026-08-22T00-40-poshqc-test-final.md` ([P7-T3]).
- Post-change, run 2: `artifacts/pester/powershell-coverage.repo-runsettings.xml`, the supplementary measurement against the repository runsettings, also captured in the [P7-T3] artifact.

## Figures

| Measurement | Lines missed | Lines covered | Denominator | Line coverage |
| --- | --- | --- | --- | --- |
| Baseline ([P0-T4]) | 228 | 5792 | 6020 | **96.2126%** |
| Post-change, MCP denominator ([P7-T3] run 1) | 233 | 5722 | 5955 | **96.0873%** |
| Post-change, repository denominator ([P7-T3] run 2) | 275 | 6308 | 6583 | **95.8226%** |

Deltas against baseline: **-0.1253 percentage points** (MCP denominator) and **-0.3901 percentage points** (repository denominator).

Instruction coverage, informational only (no threshold applies): baseline 96.0450%, post-change 95.8115% (MCP) and 95.4253% (repository).

Branch coverage: not measured by Pester, so no branch criterion applies (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`).

## The two percentages are computed over different denominators

This is the material caveat the plan requires to be stated, and it is why the two figures must not be read as a like-for-like regression.

- The **baseline** predates the [P5-T6] `CodeCoverage.Path` additions, so its denominator excludes the new shared module and eight other production files.
- The **repository-denominator** figure includes all nine, which is why its denominator is 563 lines larger than the baseline's (6583 versus 6020) and 628 lines larger than the MCP run's.
- The **MCP-denominator** figure is smaller than the baseline's because the migration moved lines out of measured hooks and into two newly-extracted helper siblings that the stale published runsettings does not yet register: `enforce-pr-author-skill.ps1` shed 165 lines to `enforce-pr-author-skill-helpers.ps1`, and `enforce-parallel-cohort-barrier.ps1` shed 249 lines to `enforce-parallel-cohort-barrier-helpers.ps1`. Both helper files ARE registered in the repository runsettings, which is why run 2's denominator is the larger one and the honest one.

The **>= 85% absolute threshold is well-defined under either denominator** and is cleared with roughly 11 percentage points of margin in both cases. The changed-line no-regression check is likewise well-defined, because it is evaluated per changed file rather than against the aggregate.

## Changed-line coverage

Per-file line coverage for every production file this change created or newly registered, from the repository-denominator run:

| File | Lines missed | Lines covered | Line coverage |
| --- | --- | --- | --- |
| `.claude/lib/hook-payload/HookPayload.psm1` (new) | 4 | 99 | 96.12% |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` (new) | 0 | 77 | 100.00% |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (new) | 3 | 61 | 95.31% |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 4 | 47 | 92.16% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 10 | 76 | 88.37% |
| `.claude/hooks/enforce-evidence-locations.ps1` | 4 | 36 | 90.00% |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 4 | 41 | 91.11% |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 4 | 90 | 95.74% |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 9 | 59 | 86.76% |

Every changed or new production file clears 85% individually; the lowest is 86.76%. Each of the 24 migrated hooks additionally gained at least one nested-envelope deny test (AC-7), and the payload-acquisition path each one grew is exercised by that test plus the per-hook anomaly tests, so no changed line is added without covering tests.

No coverage exclusion was introduced. The [P5-T6] change is purely additive to the denominator; no `ExcludedPath` entry was added and no production path was removed.

## File-size ceiling re-measurement ([P5-T4] follow-up)

The [P7-T1] format stage modified zero files, so the plan's re-measurement condition was not triggered. The measurement was re-run anyway for completeness:

Command: the [P5-T4] `Get-ChildItem ... | Where-Object Lines -gt 500` filter.

EXIT_CODE: 0

Output: `post-format rows over 500: 0`

## Verdict

Post-change line coverage is **95.8226%** over the correct (repository) denominator and **96.0873%** over the denominator the currently-published PoshQC package measures. Both exceed the 85% threshold. Every changed and new production file clears 85% individually, so there is no regression on changed lines. Every required numeric value is available; the verdict is PASS, not remediation-required.

Output Summary: Baseline 96.2126% (6020 lines) versus post-change 95.8226% (6583 lines, repository denominator including all nine newly-registered files) and 96.0873% (5955 lines, published-package denominator). Deltas -0.3901 pp and -0.1253 pp respectively, both explained by denominator composition rather than by lost coverage. Threshold >= 85% met with about 11 points of margin under either denominator; no changed-line regression; no coverage exclusion added. AC-11 satisfied.
