# Containment-path hook audit (issue #824, AC-17)

Timestamp: 2026-10-03T10-01

This record lists every hook that reaches `Resolve-CommandLineInvocation`, and therefore inherited the R2 fail-closed rule, on each runtime. Before the fix, R2 classified a wrapper-led or live-substitution segment when its raw text contained the command word and every subcommand element anywhere, as substrings (`Test-CommandLineRawContainment`). After the fix, R2 calls `Test-CommandLineRawInvocation` (`hook-command-raw-invocation.ps1`), which requires a token-bounded, ordered sequence. No hook file was changed; every hook is corrected through the shared helper.

| Hook (runtime) | Resolver call sites | Effect of an R2 false positive before the fix | Disposition after the fix | Covering Issue824 test |
|---|---|---|---|---|
| `enforce-promotion-mcp-only.ps1` (Claude) | `.claude/hooks/enforce-promotion-mcp-only.ps1:126`, `:127` | Unconditional deny with `Get-PromotionMcpOnlyGhIssueBlockedReason` | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | P824-A1, P824-A2, P824-A3, P824-D1 to P824-D11 (S1) |
| `enforce-promotion-mcp-only.ps1` (Codex) | `.codex/hooks/enforce-promotion-mcp-only.ps1:123`, `:124` | Unconditional deny with the same reason | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | P824-A1, P824-A2, P824-A3, P824-D1 to P824-D11 (S2) |
| `enforce-pr-author-skill-helpers.ps1` (Claude) | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:279`, `:280`, `:290`, `:291` | `gh pr create` with no body flags: Case B `PR_AUTHOR_SKILL_BLOCKED` deny; Case A deny when `--body` text is present | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-PR1 (S5) |
| `enforce-pr-author-skill.epic-base-branch.ps1` (Claude) | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:92`, `:100`, `:138` | Reached only after the helpers' checks; conditional on the checkpoint `epic_mode` | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | none - corrected through the shared helper; checkpoint-conditional |
| `enforce-epic-worktree-removal-gate.ps1` (Claude) | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:140`, `:141`, `:355` | In scope with no operand (`OperandIndex = -1`), so every allow predicate rejects the null path; effectively unconditional deny | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-WT1, A824-WT2 (S6) |
| `enforce-epic-worktree-removal-gate.ps1` (Codex) | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:58`, `:59`, `:126` | Same structure; effectively unconditional deny | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-WT1, A824-WT2 (S8) |
| `enforce-parallel-worktree-removal-gate.ps1` (Claude) | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:201`, `:202`, `:361` | Same structure; effectively unconditional deny | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-WT1, A824-WT2 (S7) |
| `validate-bash.ps1` (Claude) | `.claude/hooks/validate-bash.ps1:123`, `:127` | Structural leg returns a denylist literal when a `--force`/`-f` or `--hard` token is also present | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-VB1 (S9) |
| `validate-bash.ps1` (Codex) | `.codex/hooks/validate-bash.ps1:96`, `:100` | Same | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-VB1 (S10) |
| `enforce-orchestration-preimplementation-gate.ps1` (Claude) | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:142` | `Test-ImplementationCommand` true, so the readiness checkpoint is consulted (deny when not ready) | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-PI1 (S11) |
| `enforce-orchestration-preimplementation-gate.ps1` (Codex) | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:161` | Same; checkpoint check | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-PI1 (S12) |
| `enforce-epic-merge-gate.ps1` (Claude) | `.claude/hooks/enforce-epic-merge-gate.ps1:128`, `:134`, `:342`, `:343` | Requires a `--merge` flag, then the checkpoint and authorization chain | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-MG1 (S13) |
| `enforce-epic-merge-gate.ps1` (Codex) | `.codex/hooks/enforce-epic-merge-gate.ps1:63`, `:69`, `:141`, `:142` | Same; checkpoint check | R2 now requires a token-aware sequence through the shared helper; no per-hook code change | A824-MG1 (S14) |

`enforce-parallel-abandon-gate.ps1` dot-sources the helper but calls only `Read-CommandLineSegment` and `Test-CommandLineSegmentRawScan`, so it does not reach R2 and is not affected by this change.

Derivation. The call-site set is taken from research `research/research.2026-10-03T08-30.md`, Numeric Derivation Evidence, Claim N1 (34 call expressions in 13 files: Claude 22 in 8, Codex 12 in 5), and the effect column from section 3 of the same document. The set was re-derived against the worktree after the fix in `evidence/other/call-site-derivation.2026-10-03T10-01.md` (FEATURE/evidence/other/call-site-derivation.TS.md), which prints the same 34 `file:line` values in 13 files.

## Remediation cycle 1 addendum (issue #824)

Timestamp: 2026-10-03T13-23

Re-derived in `evidence/other/r1-call-site-derivation.2026-10-03T13-23.md` (step script SCRATCH/steps/r1-p7-t9.ps1):

CALL-SITES=37 FILES=13

The three new call sites, one in each worktree-removal gate:

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:364`
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:370`
- `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:134`

Each is the `Resolve-CommandLineWrappedInvocationOperand -CommandText ... -CommandWord 'git' -SubcommandPath @('worktree', 'remove')` call that the worktree-removal gates now use to read a wrapped removal's operand. A raw operand joins the checkpoint lookup, a wrapped match that names no operand is allowed, and an indeterminate match keeps the structural path and is denied. The file count is unchanged at 13 because all three gates already carried call sites.

Covering tests: `A824-WT3` to `A824-WT9` in S6, S7, and S8 (`A824-WT3`, `A824-WT4-1` to `-5`, `A824-WT5-1` to `-5`, `A824-WT6`, `A824-WT7`, `A824-WT8`, `A824-WT9`).

## Remediation cycle 2 addendum (issue #824)

Timestamp: 2026-10-03T16-23

Re-derived in `evidence/other/r2-call-site-derivation.2026-10-03T16-23.md` (step script SCRATCH/steps/r2-p7-t6.ps1):

CALL-SITES=37 FILES=13

The call-site set is unchanged from cycle 1; only line numbers in the three worktree-removal gates moved (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1:365`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:371`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:135`).

R2 now classifies a wrapper-led or substitution segment when the command word and every subcommand element occur as whole tokens in its raw text, in any order. Every R2 caller in the audit table therefore classifies the review-pass-2 forms Y1, Y2, Y3, and Y5 (`gh "$@"`, `gh $*`, `xargs gh`, and `gh $1 $2` with the subcommand words supplied after the wrapper).

The three worktree-removal gates now deny every R2-classified removal from which exactly one literal operand is not read, with or without a checkpoint record: the cycle-1 `NoOperand` allow is removed, and only a `Status = 'Operand'` result replaces the structural path.

Covering tests: `P824-D16` to `P824-D19` (S1 and S2); `A824-X1` to `A824-X10` (`A824-X1`, `A824-X2`, `A824-X3`, `A824-X4`, `A824-X7`, `A824-X8`, `A824-X10`), `A824-WT6`, `A824-WT10`, and `A824-WT11-1` to `A824-WT11-2` (S6, S7, and S8).
