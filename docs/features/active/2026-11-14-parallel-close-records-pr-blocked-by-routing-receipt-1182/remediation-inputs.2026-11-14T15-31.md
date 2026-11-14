# Remediation Inputs — Cycle 1 (#1182)

Timestamp: 2026-11-14T15-31
Source: non-blocking Minor rows CR-1 and CR-2 of `code-review.2026-11-14T15-19.md` (review verdict PASS at head 06cc8b03d215460418d7d5e881e007c1b18c8d0d). The orchestrator opens this cycle under the standing rule that related findings are fixed through remediation cycles before merge. No finding below is blocking; the cycle carries no `opened_by_review`.
Remediation-Mode: proportionate

## Findings

### CR-1 — AC-12 listing-throw row asserts less than its siblings

- Remediability: autonomous
- Finding-Scope: contained
- File: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1`, `Describe`/`It` for AC-12, row "declines with an empty suffix when the worktree listing throws, and the gate keeps its own target-resolution deny".
- Finding: the gate-level assertion is only `deny` plus absence of the parallel suffix, while the two sibling never-throw rows assert the exact reason with `Should -BeExactly`. The change was made during execution without a plan revision.
- Required change: tighten the row so it asserts the exact deny reason the gate produces today for this payload (the target-resolution deny that `Resolve-OrchestrationGateTarget` yields when the worktree listing fails), using the same exact-match style as the sibling rows, and keep the leg-level assertions (`Allowed` false, empty suffix). No production change.

### CR-2 — preimplementation leg starts a `git worktree list` process before its receipt-path prefilter

- Remediability: autonomous
- Finding-Scope: contained
- File: `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`, `Get-OrchestrationParallelRecordsRoot` (and its caller `Get-OrchestrationParallelRecordsResult`), plus the bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
- Finding: for any absolute implementation-path `Write` that reaches the deny tail, the leg calls `Get-OrchestrationCleanupListingRecord` (one `git worktree list` process) before checking that the path names the receipt file. The spec `#### Performance constraints (latency/throughput/memory):` allows one checkpoint read and one HEAD-branch read on a would-deny path.
- Required change: add a case-sensitive file-name prefilter (the normalized path must end with `/artifacts/pr_body_<digits>.receipt.json`, or equal `artifacts/pr_body_<digits>.receipt.json`) before any listing or resolver call, so a non-matching absolute path declines with an empty suffix and starts no process. Add a test row asserting that for an absolute non-receipt path (for example `<root>/scripts/x.ps1`) the listing seam is invoked zero times (`Should -Invoke ... -Times 0`) and the gate text is unchanged; keep every existing AC-9/AC-10/AC-11/AC-12 row passing. Update the bundle mirror byte-identically. File stays under 500 logical lines.

## Constraints

- No change to any spec acceptance criterion, public interface, or file inventory beyond the files already in the branch diff and their tests and mirrors.
- Tests run through the parallel gates only; evidence append-only with clock-read timestamps; no absolute paths in artifacts; hooks never invoke Python.
