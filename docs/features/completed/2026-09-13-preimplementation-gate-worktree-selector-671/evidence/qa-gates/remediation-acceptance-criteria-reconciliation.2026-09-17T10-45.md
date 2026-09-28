# Remediation Acceptance-Criteria Reconciliation (issue #671, R1)

Timestamp: 2026-09-17T10-11
Task: [P7-T7]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/sscount.ps1` — `Select-String -SimpleMatch` over `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` for `- [x] ` and `- [ ] ` (and for the six check-off literals of [P7-T1]–[P7-T6], each returning exactly one line), followed by a line-by-line review against the evidence on disk.
EXIT_CODE: 0

Output Summary:
- spec.md `- [x] ` line count: `28` (26 acceptance criteria + the `Blocker` severity line + the `Attached minimal logs` line).
- spec.md `- [ ] ` line count: `3` (the `High`, `Medium`, and `Low` severity lines).
- Acceptance criteria: 26 total, 26 checked, 0 unchecked. Source: `spec.md` only (work mode `full-bug`).
- Every criterion names an existing evidence path. No criterion's re-verification failed in Phases 4–6, so no gap is recorded.

Evidence paths below are relative to `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/`. Task IDs without a qualifier are from `remediation-plan.2026-09-17T08-44.md`. IDs marked "prior" are from `plan.2026-09-13T20-46.md`.

| # | Criterion (leading text) | State | Last verified by | Evidence |
| --- | --- | --- | --- | --- |
| 1 | The seven `issue #671 LACS allow` rows all pass (Claude) | checked | [P4-T1] (46/46 `issue #671` nodes Passed in the Claude suite) | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |
| 2 | The same seven allow rows ... pass (Codex) | checked | [P4-T1] (46/46 Passed in the Codex suite) | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |
| 3 | The chained-segment allow is pinned | checked | [P4-T1] | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |
| 4 | The `cd`-chain denial is pinned | checked | [P4-T1] | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |
| 5 | Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass | checked ([P7-T1]) | [P4-T1] (L3a, L3b, L8 nodes Passed in both suites; all 46 `issue #671` nodes Passed), [P6-T3] (no failing `issue #671` node), [P3-T9] (row labels present) | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md`, `qa-gates/remediation-poshqc-test-coverage.2026-09-17T10-30.md`, `regression-testing/remediation-suite-edits.2026-09-17T09-45.md` |
| 6 | The pathspec, option, and metacharacter restrictions are not weakened | checked | [P4-T1] | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |
| 7 | No existing assertion is reversed | checked | [P5-T3] (numstat 135/0, 136/0), [P4-T2] (45/45 deny, 8/8 allow per suite) | `qa-gates/remediation-diff-additive-only.2026-09-17T10-15.md`, `regression-testing/remediation-regression-guards.2026-09-17T10-00.md` |
| 8 | The four gate files are byte-unchanged | checked | [P5-T1] | `qa-gates/remediation-diff-confinement-protected.2026-09-17T10-15.md` |
| 9 | The four modes files are byte-unchanged | checked | [P5-T1] | `qa-gates/remediation-diff-confinement-protected.2026-09-17T10-15.md` |
| 10 | The epic-merge gate's matcher is not widened | checked | [P5-T1], [P6-T6] (merge-gate suites 56/0 and 12/0) | `qa-gates/remediation-diff-confinement-protected.2026-09-17T10-15.md`, `qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md` |
| 11 | The helpers diff is confined to one axis plus the remediation R1 fail-closed repair | checked ([P7-T2]) | [P5-T2] | `qa-gates/remediation-diff-confinement-helpers.2026-09-17T10-15.md` |
| 12 | Gates still deny when a required document is genuinely absent | checked | [P6-T6] | `qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md` |
| 13 | Epic and standalone topologies behave exactly as now | checked | [P6-T6] | `qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md` |
| 14 | Node `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` passes | checked | [P4-T2], [P2-T9] | `regression-testing/remediation-regression-guards.2026-09-17T10-00.md`, `other/remediation-helpers-surface-parity.2026-09-17T09-30.md` |
| 15 | Bundled-payload mirroring is complete | checked | [P5-T4] (all four helpers paths listed), [P6-T6] (Codex byte-identity node Passed), [P6-T5] (push-down test PASSED) | `qa-gates/remediation-changed-path-set.2026-09-17T10-15.md`, `qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md`, `qa-gates/remediation-python-pushdown-contracts.2026-09-17T10-30.md` |
| 16 | No file exceeds the 500-line cap | checked | [P4-T2] (line-cap node Passed), [P2-T9] (441 lines per copy), [P6-T6] (Codex 500-line node Passed) | `regression-testing/remediation-regression-guards.2026-09-17T10-00.md`, `other/remediation-helpers-surface-parity.2026-09-17T09-30.md`, `qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md` |
| 17 | An executed fail-before capture exists | checked | prior [P0-T4] (not re-verified by this plan; the capture is historical) | `regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` |
| 18 | An executed pass-after capture exists | checked | [P2-T10] (rows 2 and 3 True; rows 1, 4–8 identical) | `regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md`, `regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` |
| 19 | Line coverage is at or above 85% ...; per-file coverage at or above 94.92% (112 of 118); every changed instrumented line hit | checked ([P7-T3]) | [P6-T3] (95.5551%; 147/152), [P6-T4] (changed lines 38/38) | `qa-gates/remediation-poshqc-test-coverage.2026-09-17T10-30.md`, `qa-gates/remediation-coverage-comparison.2026-09-17T10-30.md` |
| 20 | The full PowerShell toolchain passes in a single pass | checked ([P7-T4]) | [P6-T7] (with [P6-T1], [P6-T2], [P6-T3]) | `qa-gates/remediation-toolchain-single-pass.2026-09-17T10-30.md` |
| 21 | No Python leg is introduced | checked | [P5-T4] | `qa-gates/remediation-changed-path-set.2026-09-17T10-15.md` |
| 22 | The change adds no new production file and no F1 dependency | checked | [P5-T4], [P5-T5] (`Import-Module` 0 in all four copies) | `qa-gates/remediation-changed-path-set.2026-09-17T10-15.md`, `qa-gates/remediation-helpers-purity.2026-09-17T10-15.md` |
| 23 | The helpers module's declared purity survives | checked | [P5-T5] | `qa-gates/remediation-helpers-purity.2026-09-17T10-15.md` |
| 24 | The nested-subdirectory widening is recorded in the helpers file | checked | [P5-T5] (`Accepted widening` count 1 per copy); comment content last reviewed by prior [P5-T8] and unchanged by this plan (the block is outside every R1 hunk, see [P5-T2]) | `qa-gates/remediation-helpers-purity.2026-09-17T10-15.md`, `qa-gates/accepted-widening-record.2026-09-14T01-00.md` |
| 25 | The remediation R1 regression rows pass | checked ([P7-T5]) | [P4-T1] (seven named nodes Passed in both suites), [P2-T10] (Q6 and Q7 False with 0 error records) | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md`, `regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md` |
| 26 | The selector predicate and the fail-closed guard are pinned at the unit level | checked ([P7-T6]) | [P4-T1] (the 16 nodes are within the 46 Passed `issue #671` nodes per suite; guard node matched and Passed) | `regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` |

Acceptance: `- [x] ` count 28 and `- [ ] ` count 3; all 26 criteria checked, each with an existing evidence path; no gap. PASS.
