# Remediation Cycle 1 — R3 Outcome Verification, Codex Gate Hook

Timestamp: 2026-08-28T00-33
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T8]
Command: `python -c "<XML read>"` over the `artifacts/pester/powershell-coverage.xml` produced by [P3-T4], selecting the `enforce-orchestration-preimplementation-gate.ps1` sourcefile under the `.codex/hooks` package
EXIT_CODE: 0

## File: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

| Metric | Baseline [P0-T7] | Final | Movement |
| --- | --- | --- | --- |
| Covered lines | 133 | **135** | +2 |
| Missed lines | 29 | **27** | -2 |
| Measured lines | 162 | 162 | 0 |
| **File line coverage** | **82.10%** | **83.33%** | **+1.23 pp** |

The file-level line-coverage figure is the numeric value **83.33**. It remains below the 85%
uniform threshold. That shortfall is the single shipping exception this feature carries, and its
cause is stated by name below and recorded formally at [P3-T9] condition 5.

## R3 — lines 352 and 353

```text
line352 ci = 1   line353 ci = 2
```

**Both lines are COVERED.** They are the body of `Get-OrchestrationModeDenyReason`: line 352
resolves the canonical checkpoint path from the fixed map, and line 353 begins the returned reason
string. Line 353 carries `ci = 2` because the two cases added at [P1-T5] both execute it, once for
the epic mode and once for the parallel mode.

The function is the implementation of acceptance criterion (Amendment 3) — "A denied delegation's
reason names the checkpoint actually consulted and the failed predicate" — and its Codex copy was
entirely unverified before this remediation. The two cases assert the `PREIMPLEMENTATION_GATE_BLOCKED:`
prefix, the presence of the mode's canonical checkpoint path, and the presence of the quoted failed
predicate, for both modes. R3 is closed.

## The twenty-seven remaining uncovered lines, stated explicitly

```text
197, 206, 292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433,
434, 435, 436, 437, 439, 441, 442, 443
```

The residual set partitions exactly:

| Lines | Count | Attribution |
| --- | --- | --- |
| 197, 206 | 2 | **Pre-existing uncovered lines**, uncovered at the merge base as well. The cycle-1 policy audit placed both in the pre-existing set at its §"Regression on pre-existing lines". Not added lines, not a regression. |
| 292, 293, 294, 296, 304, 305, 306, 308 | 8 | **Group 1 accepted residual** — the bodies of `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent`, which perform real filesystem I/O. |
| 421, 422 | 2 | **Group 2 accepted residual** — the `declared-checkpoint-path` deny return. These are **not** the non-injected `else` arm; that arm is line 430, which falls inside the 426-443 range below. They are uncovered for the decision-D5 transport reason, because no Codex case can reach the decision function's mode branches. |
| 426 through 443 | **15** | **The one shipping exception, tied to issue #555** — the epic/parallel decision branch. Confirmed by direct probe: exactly 15 measurable lines in that range are uncovered, and they are 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443. |

2 + 8 + 2 + 15 = 27, which matches the missed count exactly. No uncovered line on this file is
unattributed.

## The shipping exception, named

Driving lines 426-443 requires constructing a delegation payload for the Codex decision function
`Invoke-OrchestrationPreimplementationGateDecision`. Decision D5 of `spec.md` **prohibits** that:
`.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name, so
an `Agent` delegation never reaches this hook on the Codex surface, and asserting a decision on a
fabricated envelope would produce a green test proving nothing about the shipped surface. The
transport gap is owned by **issue #555**, which is out of scope for issue #554. The gap itself is
recorded as a deliberate, tested fact by the case
`registers no PreToolUse matcher admitting an Agent or Task tool name` in the Codex suite.

This exception is stated at greater length, with its reason and its #555 linkage, as condition 5 of
the re-issued coverage-delta artifact at [P3-T9]. It is not absorbed into an aggregate.

Output Summary: R3 is closed. Lines **352 and 353 are both covered** (`ci = 1` and `ci = 2`).
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` moves from 133 covered / 29 missed
(**82.10%**) to 135 covered / 27 missed (**83.33%**). The 27 remaining uncovered line numbers are
listed in full and partition into 2 pre-existing, 8 read-seam, 2 declared-path-deny, and the
**15-line issue #555 exception at lines 426-443**, which is why the file remains below 85%.
