# Final QA Gate 7 — PowerShell Per-File Line Coverage (issue #516)

Timestamp: 2026-08-24T16-38
Command: read the per-class `<counter type="LINE" ...>` elements from `artifacts/pester/powershell-coverage.xml` produced by the [P4-T4] full-suite run
EXIT_CODE: 0

## Per-File Line Coverage — the two canonical hook copies

| File | Lines covered | Lines missed | Total lines | Line coverage | Threshold >= 85% |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 100 | 11 | 111 | **90.09%** | **PASS** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 122 | 1 | 123 | **99.19%** | **PASS** |

## Aggregate Line Coverage

| Scope | Lines covered | Lines missed | Total lines | Line coverage |
| --- | --- | --- | --- | --- |
| Whole configured coverage set (report-level counter) | 6409 | 255 | 6664 | **96.17%** |

The report-level `<counter type="LINE">` and the sum over every `<class>` node agree exactly (6409 covered / 255 missed in both), so the aggregate figure is internally consistent.

## Acceptance Conditions

| Condition | Result |
| --- | --- |
| Each per-file line-coverage percentage at or above 85 | **Yes** — 90.09% and 99.19% |
| No recorded value is a placeholder | **Yes** — every value is a number read directly from a JaCoCo counter |

## The Conditional Clause Is Not Triggered

[P4-T7] carries a fallback for the case where a [P0-T11] baseline is already below 85%. That case did not arise: the baselines are 90.00% for the Claude copy and 99.18% for the Codex copy, both above the threshold. The plain per-file >= 85% gate is therefore the binding condition and it is satisfied outright. There is no pre-existing shortfall to report on either file.

## Branch Coverage

PowerShell is exempt from the >= 75% branch-coverage threshold under `.claude/rules/quality-tiers.md`, because Pester does not measure branch coverage in any output format. That exemption removes an unevaluable threshold; it does not remove either hook copy from the line-coverage denominator. Both canonical copies are measured above and appear in no coverage exclusion list. The two bundle mirrors are executed by no suite and inherit their measurement through SHA256 equality with their canonical counterparts, confirmed at [P4-T9].

Output Summary: Post-change per-file line coverage is 90.09% (100/111) for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and 99.19% (122/123) for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, with an aggregate of 96.17% (6409/6664). All three values are numbers read directly from the JaCoCo counters; none is a placeholder. Both per-file values are at or above the uniform 85% line threshold, so the acceptance condition is satisfied and the below-baseline fallback clause is not triggered.
