# Remediation Cycle 1 — The Six Pre-Existing Suites Are Unmodified and Passing

Timestamp: 2026-08-28T00-40
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T10]
Command: `git diff --name-only 34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`, filtered for the six suite filenames; and a per-`testsuite` read of `artifacts/pester/pester-junit.xml` produced by the [P3-T4] run
EXIT_CODE: 0

## Part 1 — absence from the diff against the branch head recorded at [P0-T3]

Base: `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`, the branch head [P0-T3] recorded.

The complete `git diff --name-only` listing against that base is sixteen paths:

```text
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-batch-budget-reset.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-claude-classifier-line-count.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-claude-classifier-suite-run.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-suite-line-count.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-suite-run.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-instructions-read.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-analyze.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-format.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-test-coverage.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-requirements-sources.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-revision-anchors.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-test-suite-line-counts.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-uncovered-inventory.2026-08-27T22-47.md
docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-plan.2026-08-27T22-47.md
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
```

A fixed-pattern count of the six suite filenames against that listing returns **0**. **None of the
six appears in the diff.** They are byte-untouched by this remediation.

| # | Suite | In the diff? |
| --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | **No** |
| 2 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | **No** |
| 3 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | **No** |
| 4 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | **No** |
| 5 | `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | **No** |
| 6 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | **No** |

## Part 2 — zero failures in all six, from the [P3-T4] run

Read per `testsuite` element from `artifacts/pester/pester-junit.xml`:

| # | Surface | Suite | Tests | Failures | Errors | Skipped |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | claude-hooks | `enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | **0** | 0 | 0 |
| 2 | claude-hooks | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | **0** | 0 | 0 |
| 3 | claude-hooks | `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | **0** | 0 | 0 |
| 4 | codex-hooks | `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 58 | **0** | 0 | 0 |
| 5 | claude-hooks | `PreToolUseSchema.Contract.Tests.ps1` | 15 | **0** | 0 | 0 |
| 6 | codex-hooks | `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |
| | | **Total across the six** | **242** | **0** | **0** | **0** |

All six were discovered and executed by the [P3-T4] run — none is `NOT FOUND` — and all six report
zero failures and zero errors. The JUnit report root confirms the same at the whole-run level:
`tests="3825" errors="0" failures="0" disabled="9"`.

## Why this matters

`spec.md` §Test Strategy makes the pre-existing suites passing **unmodified** the proof obligation
for the amendment's guardrail that "Edit/Write and Bash legs are behaviorally unchanged", including
the issue #539 orchestration-bookkeeping staging exemption. Suite 5 additionally pins
`Get-OrchestrationPreimplementationGateBlockDecision -Reason` to its single mandatory string
parameter, and suite 6 is the reason the Codex copy of `Test-PreparationModeDelegation` retained
coverage where the Claude copy lost it — the asymmetry that diagnosed finding R2 and the reason the
production-side removal alternative was rejected.

## The two suites this remediation wrote, for contrast

| Surface | Suite | Tests | Failures |
| --- | --- | --- | --- |
| claude-hooks | `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (byte-untouched; carried by the branch, not by this cycle) | 83 | 0 |
| codex-hooks | `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (**edited** in Phase 1) | 53 | 0 |
| claude-hooks | `enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` (**created** in Phase 2) | 7 | 0 |

The Claude mode-resolution suite — the file the remediation directive named as the R2/R4 edit target
— is absent from the diff above and therefore byte-untouched, which is the Scope Note outcome
[P0-T8] evidenced.

Output Summary: All six pre-existing suites are **absent from the `git diff --name-only` listing
against the [P0-T3] branch head**, and all six report **zero failures and zero errors** in the
[P3-T4] run, across 242 tests. Exit code 0.
