# Remediation Inputs — Issue 1188 (re-audit after remediation cycle 3)

Timestamp: 2026-11-15T21-47
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Issue: 1188
Base: main
Merge-Base: 38f87bc2c4bab54be8121ee546f9eb0dc92272ee
Reviewed-Head: 06f085b30b352deb006126a4053cb2f39e26a37c
Source review artifacts:
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/policy-audit.2026-11-15T21-47.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/code-review.2026-11-15T21-47.md`
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/feature-audit.2026-11-15T21-47.md`

## Disposition

R2 and E1 from `remediation-inputs.2026-11-15T20-57.md` are resolved at the reviewed head. One finding (R3) requires remediation inside this item (owner rule: related findings are fixed in remediation cycles). It is autonomous and contained and changes test data only, but the prior cycle (cycle 3) was light, so this cycle takes the full path. AC-1 to AC-15 evaluate PASS and stay checked. The reviewer's full Pester gate at the head passed (27323 run, 0 failed, 18 skipped; 96.04% repo-wide lines; both siblings 100%), and every CI check on PR #1191 passed except PowerShell QC shard 5, pending at audit time.

## Finding R3

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The gap is a set of absent test rows in one Cases file on this branch, verifiable by local Pester rows and an in-memory reverted-mutant probe with no external system or owner decision.
Finding-Scope: contained

- Location: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1` (`$script:ClassifyFunctionRows`, `$script:ClassifyGateRows`), consumed by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`. The guards are in `Get-OrchestrationGateJoinedWordText` (the unclosed-substitution member filter) and `Get-OrchestrationGateSupplementalPatternIndex` (member tail match and member word checks) of `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three byte-identical copies.
- Observed: in-memory reverted mutants of the cycle 3 code, run against both row tables: N2 (drop the backtick arm of the filter), N5 (match the npm pattern against the whole run text instead of the member tail), N6 (drop the member `npm` word check), and N7 (drop the member `npx` word check) each fail no row. At the head the supplement returns no index for `` echo `npm --version` lint ``, `echo $(echo npm --version) lint`, `FOO=$(echo npx jest) ls`, and `FOO=$(echo npm x lint) npm --version`; under N2, N6, N7, and N5 respectively it returns index 2 or 3, and the first two commands become classified by the gate.
- Fix: add function rows with `Indexes = @()` for the four commands above, and Negative gate rows with `Expected = $false` for `` echo `npm --version` lint `` and `echo $(echo npm --version) lint`. Make no production change; the four classify copies stay byte-identical and unchanged.
- Verification: the new rows pass on both surfaces at the head; an in-memory probe that applies each of N2, N5, N6, and N7 to the classify source shows each failing at least one new row, with the unmutated control failing none; the classify parity suite and the parallel Pester gate pass.

## Non-remediation notes

- Info: wrapper payloads (`sh -c "npm run lint"`, `pwsh -Command "npm run lint"`) are unclassified by stage 1 on `main` and on this branch; recorded orchestrator decision: tracked as a follow-up outside #1188 (stage-1 design of #1160).
- Info: mutant M4 (run start accepted without an opener in the gap) still fails no row; cycle 1 code, unchanged in cycle 3, no reachable behavior difference found.
- The reviewer's probe scripts are in the gitignored `artifacts/scratch-issue-1188/` folder (`review-r5-mutants.ps1`, `review-r5-probe2.ps1`); the owner-directive decision file is `artifacts/orchestration/owner-directive-decisions/feature-review-1188-r5/OD-1.md`.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
