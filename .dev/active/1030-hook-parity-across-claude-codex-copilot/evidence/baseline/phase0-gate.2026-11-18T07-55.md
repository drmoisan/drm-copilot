# Phase 0 Gate — Issue #1030 ([P0-T1], plan version 2.1)

Plan: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md`
INTEGRATION: `origin/epic/shared-agent-harness-layer-integration` (fetched before the checks)
BASE: merge base of INTEGRATION and HEAD; equal to the INTEGRATION tip at the time of the checks.
Scratch helpers: `SCRATCH/issue-1030-p0abc.sh`, `SCRATCH/issue-1030-p0d.sh`, `SCRATCH/issue-1030-p0exist2.sh`
The earlier STOP record `phase0-gate.2026-11-18T07-25.md` is unchanged (append-only).

## Check (a) — Child 1 matrix (#1025)

Timestamp: 2026-11-18T07-54
Command: `git fetch origin`; `sh SCRATCH/issue-1030-p0abc.sh <worktree root>` (ancestry, file reads of the matrix, schema, `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `quality-tiers.yml`; #1025 `spec.md` read from INTEGRATION)
EXIT_CODE: 0
Output Summary:
- `git merge-base --is-ancestor INTEGRATION HEAD` exit 0.
- Matrix and schema exist; `schema_version` `1.0.0` (major 1).
- `HarnessInventory.psm1` iterates `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` as `hook-registration` sources.
- LOADER: Import-HarnessParityMatrix
- SKELETON: New-HarnessParityMatrixSkeleton
- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` exists; `scripts/harness` is classified in `quality-tiers.yml`.
- GAP-ENCODING: NOTES (case-insensitive search for `gap` in the schema: 0 matches).
- `id` grammar (`IdPattern` and schema pattern), `name` form `<Event>/<matcher>/<command-stem>`, matcher percent-encoding, `~` duplicate tie-break and Q6 equal #1025 `spec.md` (`### Parity Matrix: Feature Entry`, `### Parity Matrix: Identifier Encoding`); `scripts/harness`, the matrix and the schema are unchanged since the previous Phase 0 record (empty `git diff --stat` over those paths).
- Result: MATCH

## Check (b) — Child 3 generators (#1028)

Timestamp: 2026-11-18T07-54
Command: text search of `scripts/harness-generation/*.psm1` and `scripts/harness-generation/Invoke-HarnessGeneration.ps1` for `config.toml`, `pretooluse-dispatch` and `[[hooks`
EXIT_CODE: 0
Output Summary:
- Only `HarnessMcpConfig.psm1` names `.codex/config.toml`, and it owns only the `[mcp_servers.*]` region; no generator names `[[hooks` or either dispatch registry (`NO-HOOK-REGION-OWNER`).
- CONFIG-HOOKS-OWNER: HAND
- GENERATOR-CHECK: `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check`
- Result: MATCH

## Check (c) — Feature-folder resolver (record only, AD-8)

Timestamp: 2026-11-18T07-54
Command: text search of the guarded loads and `Test-IsFeaturePlanPath` in `.claude/hooks/enforce-feature-folder-order.ps1`; directory test of `.codex/lib/development-docs`
EXIT_CODE: 0
Output Summary:
- FFO-RESOLVER: hook-dependency-guard.ps1, ../lib/hook-payload/HookPayload.psm1, ../lib/development-docs/DevelopmentDocsRoot.psm1, feature-folder-resolution.ps1; Test-IsFeaturePlanPath calls Get-DevelopmentDocsKnownRootPattern
- CODEX-LIB-DEVDOCS: ABSENT
- The import list equals the expected state of [P0-T1] check (c); recorded only.
- Result: RECORDED

## Check (d) — Edit-set re-check

Timestamp: 2026-11-18T07-55
Command: `sh SCRATCH/issue-1030-p0exist2.sh <worktree root>`; `sh SCRATCH/issue-1030-p0d.sh <worktree root>`; `node -e` sum of the `timeout` values in `.codex/hooks/pretooluse-dispatch.json`; text search of the guarded loads in `.claude/hooks/validate-pr-author-output.ps1`
EXIT_CODE: 0
Output Summary:
- Every file and test-row text the plan names exists at HEAD (`MISSING-COUNT=0`); `.codex/hooks/enforce-feature-folder-order.ps1` and every file the plan creates are absent.
- CAPPED: enforce-completion-consistency.ps1 (499), enforce-epic-merge-gate-review.ps1 (699), enforce-orchestration-preimplementation-gate.ps1 (497), enforce-orchestration-preimplementation-gate-epic-resolution.ps1 (493), enforce-orchestration-preimplementation-gate-epic-scope.ps1 (497), enforce-orchestration-preimplementation-gate-modes.ps1 (494), hook-docs-only-diff.ps1 (511), hook-epic-fan-in.ps1 (500), hook-release-allowance-context.ps1 (495), test-execution-command-form.ps1 (632); contains the four files of spec `## Constraints & Risks`.
- IDENTICAL-HELPERS (37): enforce-batch-budget-route.ps1, enforce-completion-helpers.ps1, enforce-epic-merge-gate-child-ci.ps1, enforce-epic-merge-gate-command.ps1, enforce-epic-merge-gate-regeneration.ps1, enforce-epic-merge-gate-review.ps1, enforce-orchestration-preimplementation-gate-bookkeeping.ps1, enforce-orchestration-preimplementation-gate-classify.ps1, enforce-orchestration-preimplementation-gate-cleanup.ps1, enforce-orchestration-preimplementation-gate-commands.ps1, enforce-orchestration-preimplementation-gate-docs.ps1, enforce-orchestration-preimplementation-gate-helpers.ps1, enforce-orchestration-preimplementation-gate-operands.ps1, enforce-orchestration-preimplementation-gate-release.ps1, enforce-orchestration-preimplementation-gate-targets.ps1, epic-wave-barrier-early-start.ps1, feature-folder-resolution.ps1, feature-review-coverage-thresholds.ps1, hook-cleanup-context.ps1, hook-command-heredoc.ps1, hook-command-invocation.ps1, hook-command-invocation-operands.ps1, hook-command-payload.ps1, hook-command-payload-powershell.ps1, hook-command-scanner.ps1, hook-dependency-guard.ps1, hook-docs-estate-context.ps1, hook-docs-only-diff.ps1, hook-epic-fan-in.ps1, hook-epic-regeneration.ps1, hook-planner-worktree-removal.ps1, hook-release-allowance-context.ps1, test-execution-command-form.ps1, test-execution-lock.ps1, test-execution-lock-decision.ps1, test-execution-policy.ps1, worktree-poetry-venv-policy.ps1.
- `.claude/hooks/validate-pr-author-output.ps1` dot-sources only `hook-dependency-guard.ps1` and `subagentstop-envelope.ps1`; `subagentstop-envelope.ps1` has no dot-source, `Import-Module` or `using module` line.
- Each of the five AD-2 validators references `subagentstop-target-worktree.ps1` once.
- REGISTRY-TIMEOUT-SUM: 720 (24 hooks); the `.codex/config.toml` dispatcher `timeout` is 720 (equal).
- Result: MATCH

## Gate Result

PHASE0-GATE: PASS
