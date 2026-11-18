# Phase 0 Gate — Issue #1030 ([P0-T1])

Plan: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md`
INTEGRATION: `origin/epic/shared-agent-harness-layer-integration` (fetched before the checks)
BASE: merge base of INTEGRATION and HEAD; INTEGRATION equals HEAD at the time of the checks, so BASE is the integration tip.
Scratch helpers: `SCRATCH/issue-1030-p0d.sh`, `SCRATCH/issue-1030-p0exist.sh`

## Check (a) — Child 1 matrix (#1025)

Timestamp: 2026-11-18T07-22
Command: `git fetch origin`; `git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD`; file reads of `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`, `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `quality-tiers.yml`; heading and rule reads of the #1025 `spec.md`
EXIT_CODE: 0
Output Summary:
- Ancestry: `git merge-base --is-ancestor` exit 0 (INTEGRATION is an ancestor of HEAD).
- Matrix and schema exist; `schema_version` is `1.0.0` (major 1).
- `Get-HarnessRawFeature` reads the `hooks.PreToolUse` groups of `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` through `Get-HarnessJsonHookTriple -EventFilter @('PreToolUse')` as `hook-registration` records.
- LOADER: Import-HarnessParityMatrix
- SKELETON: New-HarnessParityMatrixSkeleton
- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` exists; `scripts/harness` is classified in `quality-tiers.yml`.
- GAP-ENCODING: NOTES (the schema contains no gap field; text search for `gap` in the schema returns no match).
- `id` grammar, `name` form (`<Event>/<matcher>/<command-stem>`), matcher percent-encoding, duplicate tie-break (`~<encoded source_path>[~<nn>]`) and Q6 (registrations only) in `HarnessInventory.psm1` equal #1025 `spec.md` `### Parity Matrix: Feature Entry`, `### Parity Matrix: Identifier Encoding` and `## Open Owner Questions` Q6.
- Result: MATCH

## Check (b) — Child 3 generators (#1028)

Timestamp: 2026-11-18T07-23
Command: text search of `scripts/harness-generation/*.psm1` and `Invoke-HarnessGeneration.ps1` for `config.toml`, `pretooluse-dispatch` and `[[hooks`
EXIT_CODE: 0
Output Summary:
- `HarnessMcpConfig.psm1` owns only the `[mcp_servers.*]` region of `.codex/config.toml`; no generator module names `[[hooks.*]]` or either dispatch registry.
- CONFIG-HOOKS-OWNER: HAND
- GENERATOR-CHECK: `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check`
- Result: MATCH

## Check (c) — Feature-folder resolver

Timestamp: 2026-11-18T07-24
Command: read of `.claude/hooks/enforce-feature-folder-order.ps1` (guarded loads and `Test-IsFeaturePlanPath`); `ls .codex/lib`; `git log --oneline -3 -- .claude/hooks/enforce-feature-folder-order.ps1`
EXIT_CODE: 0
Output Summary:
- Expected: the Claude source loads exactly `hook-dependency-guard.ps1`, `HookPayload.psm1` and `feature-folder-resolution.ps1`.
- Observed: the Claude source loads `hook-dependency-guard.ps1`, `../lib/hook-payload/HookPayload.psm1`, `../lib/development-docs/DevelopmentDocsRoot.psm1` (comment: "Development-docs root module (issue #1035)") and `feature-folder-resolution.ps1`.
- `Test-IsFeaturePlanPath` calls `Get-DevelopmentDocsKnownRootPattern` from `DevelopmentDocsRoot.psm1`, so a twin-rule copy of that function needs the #1035 resolver module at run time.
- The import was introduced by the #1035 commit "accept both development-docs roots in folder resolution and review hooks (P5-T6)", now on the integration branch.
- `.codex/lib` does not exist in the tree (`ls .codex/lib`: no such file or directory), so the published-first `.codex/lib/development-docs` path the plan names has no published module yet; the self-hosted fallback is a `.claude/lib` module, which spec OQ-3 defers to child 4.
- FFO-RESOLVER: MISMATCH (feature-folder-resolution.ps1 plus .claude/lib/development-docs/DevelopmentDocsRoot.psm1)
- Result: MISMATCH

## Check (d) — Edit-set re-check

Timestamp: 2026-11-18T07-24
Command: `sh SCRATCH/issue-1030-p0d.sh <worktree root>`; `sh SCRATCH/issue-1030-p0exist.sh <worktree root>`; timeout sum over `.codex/hooks/pretooluse-dispatch.json`
EXIT_CODE: 0
Output Summary:
- Every file and test row the plan names exists at HEAD (`MISSING-COUNT=0` over the file list and test-row anchors in `SCRATCH/issue-1030-p0exist.sh`).
- CAPPED: enforce-completion-consistency.ps1 (499), enforce-epic-merge-gate-review.ps1 (699), enforce-orchestration-preimplementation-gate.ps1 (497), enforce-orchestration-preimplementation-gate-epic-resolution.ps1 (493), enforce-orchestration-preimplementation-gate-epic-scope.ps1 (497), enforce-orchestration-preimplementation-gate-modes.ps1 (494), hook-docs-only-diff.ps1 (511), hook-epic-fan-in.ps1 (500), hook-release-allowance-context.ps1 (495), test-execution-command-form.ps1 (632); contains the four files of spec `## Constraints & Risks`.
- IDENTICAL-HELPERS (37): enforce-batch-budget-route.ps1, enforce-completion-helpers.ps1, enforce-epic-merge-gate-child-ci.ps1, enforce-epic-merge-gate-command.ps1, enforce-epic-merge-gate-regeneration.ps1, enforce-epic-merge-gate-review.ps1, enforce-orchestration-preimplementation-gate-bookkeeping.ps1, enforce-orchestration-preimplementation-gate-classify.ps1, enforce-orchestration-preimplementation-gate-cleanup.ps1, enforce-orchestration-preimplementation-gate-commands.ps1, enforce-orchestration-preimplementation-gate-docs.ps1, enforce-orchestration-preimplementation-gate-helpers.ps1, enforce-orchestration-preimplementation-gate-operands.ps1, enforce-orchestration-preimplementation-gate-release.ps1, enforce-orchestration-preimplementation-gate-targets.ps1, epic-wave-barrier-early-start.ps1, feature-folder-resolution.ps1, feature-review-coverage-thresholds.ps1, hook-cleanup-context.ps1, hook-command-heredoc.ps1, hook-command-invocation.ps1, hook-command-invocation-operands.ps1, hook-command-payload.ps1, hook-command-payload-powershell.ps1, hook-command-scanner.ps1, hook-dependency-guard.ps1, hook-docs-estate-context.ps1, hook-docs-only-diff.ps1, hook-epic-fan-in.ps1, hook-epic-regeneration.ps1, hook-planner-worktree-removal.ps1, hook-release-allowance-context.ps1, test-execution-command-form.ps1, test-execution-lock.ps1, test-execution-lock-decision.ps1, test-execution-policy.ps1, worktree-poetry-venv-policy.ps1.
- `.claude/hooks/validate-pr-author-output.ps1` dot-sources only `hook-dependency-guard.ps1` and `subagentstop-envelope.ps1`; `subagentstop-envelope.ps1` has no dot-source, `Import-Module` or `using module` line.
- Each of the five AD-2 validators references `subagentstop-target-worktree.ps1` once.
- REGISTRY-TIMEOUT-SUM: 720 (24 hooks); the `.codex/config.toml` dispatcher `timeout` is 720 (equal).
- Result: MATCH

## Gate Result

PHASE0-GATE: STOP
MISMATCH (c): `.claude/hooks/enforce-feature-folder-order.ps1` imports the #1035 resolver `../lib/development-docs/DevelopmentDocsRoot.psm1` in addition to `hook-dependency-guard.ps1`, `HookPayload.psm1` and `feature-folder-resolution.ps1`, and its `Test-IsFeaturePlanPath` calls `Get-DevelopmentDocsKnownRootPattern` from that module; `.codex/lib/development-docs` is not published (no `.codex/lib` directory exists), so the [P1-T4] port as written (no `.claude` path, loads limited to `hook-dependency-guard.ps1`, `codex-pretooluse-file-mapping.ps1` and `feature-folder-resolution.ps1`) cannot keep `Test-IsFeaturePlanPath` text-identical under the twin rule.
