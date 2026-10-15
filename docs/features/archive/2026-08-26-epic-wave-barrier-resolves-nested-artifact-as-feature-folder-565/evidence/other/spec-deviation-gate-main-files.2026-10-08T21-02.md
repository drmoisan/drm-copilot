# Spec Deviation: preimplementation gate main files edited

Timestamp: 2026-10-08T21-02
Source finding: CR-9 / PA-6 in `code-review.2026-10-08T20-57.md` and `policy-audit.2026-10-08T20-57.md` (Minor, non-blocking).

## Deviation

`spec.md` line 76 lists `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` under "Explicitly excluded systems". Remediation cycle 1 (`remediation-plan.2026-10-08T19-24.md`, commit `29269337`) edited both files and their bundled mirrors.

## Reason

The CR-1 fix requires the multi-candidate tie-break to use only the keyed `issue_num:` form, while the decision-D3 zero-candidate fallback continues to use the keyed-or-bare-hash value. The gate main file is the only caller that holds the prompt, so it is the only place that can pass the two values separately (`-IssueNumber` keyed only; `-FallbackIssueNumber` for D3). `remediation-inputs.2026-10-08T19-24.md` permits this route ("pass the keyed value separately from the D3 fallback value").

## Extent

Two lines added per main file (466 to 468 lines on the Claude surface, 487 to 489 on the Codex surface). The D3 fallback receives the same value it received before the change. Bundled mirrors match by SHA256 (recorded in the cycle 1 QC evidence).

## Disposition

Recorded as an accepted deviation from the spec exclusion list. The spec text is not amended in this branch.
