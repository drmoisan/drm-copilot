# Preflight Fixes

Timestamp: 2026-11-15T23-02
Plan: docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195/plan.2026-11-15T17-03.md
Validator: branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan`, run inside the item worktree; EXIT_CODE 0 before the fixes.

## Fixes (trivial, task text only)

1. P0-T2 | validator-blind defect class (tool mode that does not exist) | "PoshQC format in check mode" replaced by `Invoke-PoshQCFormat` with a non-writing `-WriteFile` seam and the `Formatted:` log-line count as the drift count. `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` has no check switch and writes through `-WriteFile`. The asserted values (files the formatter would change, unchanged `git status --porcelain`) are unchanged.
2. P2-T1 | anchor precision | the split input is named as the segment record's `TokenText` field (the field `Read-CommandLineSegment` returns and the spec's "segment token text"). No behavior change.
3. P2-T1 | anchor precision | the encoded-flag check states that host flags are read from the words after the host word, because `Get-CommandLineWrapperPayload` returns `Wrapper`, `Kind`, `Payload`, `Words`, `Opaque`, and `OpaqueReason` only and decodes an `-EncodedCommand` payload instead of marking it Opaque. The asserted outcome (encoded rows return no index) is unchanged.
4. P2-T2 | disposition completeness | added the operands `$script:OperandGRows` row `bash -lc "pytest /synthetic-worktrees/w-item/tests"`, which becomes classified but drives `Get-OrchestrationGateCommandTargetOperand` alone, and the remaining decision-entry gate suites with disposition unchanged. Basis: a SCRATCH prototype of the design swept 5671 distinct string literals in the claude-hooks and codex-hooks gate, hook-command, Issue824, and trigger test files and found that single literal as the only classification change.
5. P2-T3 | anchor precision | "the sentence that begins" corrected to "the clause that begins ... and ends at the following 'before the tool word.'"; the quoted text starts inside a sentence of the #1160 bullet. The replacement scope is unchanged.

## Verified without change

- The P2-T5 anchors ` -or $beforeBackticks % 2 -ne 0`, `$member.Tail -match $script:OrchestrationGateSupplementNpmPattern`, ` -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npm')`, and ` -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npx')` each occur exactly once in the classify text. In an in-memory probe, N2, N5, N6, and N7 each fail at least one P1-T1 row and the control fails none.
- Base64 of UTF-16LE `pytest` recomputed: `cAB5AHQAZQBzAHQA`.
- With a SCRATCH prototype of `Get-OrchestrationGateWrappedPatternIndex` and the P2-T2 line, every Positive row is false before and true after, every Negative row is false before and after, every Control row is true before and after, and stage 2 confirms each new hit.
- Gate, classify, and brief copies are byte-identical within each set; no ledger patch or frozen-surface hash pins the #1160 bullet.

Scratch locations are recorded as SCRATCH.
