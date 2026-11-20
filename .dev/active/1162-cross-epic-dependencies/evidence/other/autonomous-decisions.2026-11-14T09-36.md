# Autonomous Decisions — Remediation Cycle 1 (Issue 1162)

Timestamp: 2026-11-14T09-36
Mode: autonomous (owner). Each decision below was taken without halting, and the rationale is recorded here.

## D-1 — Preflight fix of the P1-T4 toml route (trivial, in place)

- Decision: classify the P1-T4 statement "the generator writes the toml bundle copy" as a trivial defect, and correct it in place to a byte copy plus generator `--check`.
- Rationale: `epic-orchestrator` is not in `GENERATED_AGENT_FAMILIES`, so the stated route would leave the bundle copy stale. The correction keeps the asserted outcome (bundle parity, generator `--check` exit 0) and adds no task. Record: evidence/other/preflight-fixes.2026-11-14T07-52.md.

## D-2 — Resolution of the 0010 stored patch after the #1156 merge

- Decision: resolve each conflict block of `0010-early-dependent-starts.patch` to main's side, then add the #1162 re-baseline block to the expectations-file hunk as context and set the `+` digest lines to the merged-byte digests.
- Rationale: #1156 regenerated the same hunks, so main's headers match the auto-merged bodies. The README `## Revert Order` rule keeps later landings in both images, which is why the #1162 block is context. Verified by PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS, 5 of 5 tests passing. Record: evidence/other/main-sync.2026-11-14T09-02.md.

## D-3 — Pester repository-wide coverage comparison across the merge

- Decision: treat the P2-T7 repository-wide Pester comparison as PASS. The figures are 95.97% in both runs at reported precision; at four decimals they are 95.9696% at baseline and 95.9665% after the merge.
- Rationale: the P1 phase gate measured this cycle's changes before the merge and recorded the identical 40622/42328. The four-decimal difference consists only of the 835 lines that #1156 brought in through the required origin/main merge (OD-7), covered at 95.81%. This cycle cannot change those lines without editing out-of-scope code. The changed file meets the threshold with no drop. Record: evidence/qa-gates/coverage-comparison.2026-11-14T09-36.md.
