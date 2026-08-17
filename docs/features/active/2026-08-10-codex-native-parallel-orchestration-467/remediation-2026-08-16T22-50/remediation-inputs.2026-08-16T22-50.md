# Issue #467 Remediation Pass 7 Inputs

- Issue: `#467`
- Timestamp: `2026-08-16T22-50`
- Feature root: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
- Triggering review: `audit-2026-08-16T22-35/`
- Reviewed head: `0c49cc61a73d85e29b3b91b0fccf31b7b76b0980`
- Merge base: `768e485ddf3b48b16aa7588a72709e17568ee5f5`
- Authorization after R5: `requested=2 consumed=1 remaining=1`
- Authorized pass: `7` only

## Trigger

The complete pass-6 feature-vs-`main` review returned `REVIEW_STATUS: REMEDIATION_REQUIRED` with exactly one Blocker. Code, tests, retained coverage, owner coverage, policy scope, and all non-hosted acceptance criteria pass. S-D15 and U21 remain UNVERIFIED pending exact-head hosted CI.

The sole blocker is authoritative MCP validation of `artifacts/orchestration/orchestrator-state.json`:

1. Missing legacy `model_routing_receipts` entries for delegated identities `atomic-executor`, `atomic-executor-c4`, `atomic-planner`, `atomic-planner-c4`, `commit-steward`, `commit-steward-c4`, `feature-review`, `feature-reviewer-c4`, `orchestrator-c4`, `prd-feature`, and `task-researcher`.
2. Unsupported preserved historical Codex logical-agent value `commit-steward` at `codex_model_routing_receipts` indexes 162, 166, 172, 199, 200, 216, 225, and 242. Each diagnostic is emitted twice.
3. The repository-local strict command passes:
   `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state artifacts/orchestration/orchestrator-state.json --require-codex-model-routing --require-codex-topology`
4. The authoritative MCP call with `require_codex_topology=true`, `require_codex_model_routing=true`, and `require_model_routing=true` returns `ok=false`.

## Required Fixes

1. Inspect `config/orchestration-routing.json`, the checkpoint's `delegation_receipts.agents`, `model_routing_receipts`, and `codex_model_routing_receipts`, plus the repository and active MCP validator contracts. Record an exact identity/index inventory before mutation.
2. Reconcile legacy `model_routing_receipts` only through truthful deterministic receipts derived from existing canonical delegation and Codex routing records. Every delegated identity required by the authoritative validator must have a valid receipt.
3. Preserve every historical `codex_model_routing_receipts` entry byte-for-byte unless the canonical repository contract provides a documented, validator-supported additive compatibility representation. Never delete, relabel, reorder, or fabricate a historical `commit-steward` receipt.
4. Determine whether the active MCP runtime can validate the repository's canonical `commit-steward` route. If the running validator catalog is stale or does not support that logical agent and no truthful additive checkpoint representation exists, record an exact mechanically non-remediable runtime blocker and stop without claiming success.
5. Rerun the repository-local strict validator and the authoritative MCP validator after every permitted correction. Proceed only when both validators pass; otherwise preserve exact diagnostics.
6. Keep the PowerShell branch result and exception disposition distinct in every new artifact: `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`; `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`; no measured branch PASS.
7. Preserve the current implementation, retained QA results, 41 PASS/0 FAIL/2 UNVERIFIED AC state, committed head, runbook, exception receipt, and prefix artifact layout.

## Expected Behavior

- Success requires the authoritative MCP checkpoint validator to return `ok=true` without removing or falsifying any historical receipt.
- Local strict validation must remain passing.
- No production, test, dependency, policy, threshold, suppression, coverage configuration, requirement source, or committed feature file changes are permitted unless a delegated plan proves they are necessary and within issue #467 scope.
- If the active MCP validator cannot accept the canonical historical `commit-steward` route, the pass must fail closed with a terminal evidence-backed blocker. It must not consume another cycle before R5 and must not claim checkpoint validation passed.

## Verification Commands and Tools

1. `git branch --show-current; git rev-parse HEAD; git status --porcelain=v1 -uall`
2. `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state artifacts/orchestration/orchestrator-state.json --require-codex-model-routing --require-codex-topology`
3. `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=orchestrator-state`, `artifact_path=artifacts/orchestration/orchestrator-state.json`, `require_complete=false`, `require_codex_topology=true`, `require_codex_model_routing=true`, and `require_model_routing=true`
4. Exact before/after SHA-256 and ordered-entry comparisons for `model_routing_receipts`, `codex_model_routing_receipts`, and `delegation_receipts.agents`
5. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`

## Do Not Do

- Do not delete, reorder, rewrite, relabel, or hide historical routing receipts.
- Do not fabricate validator success or add synthetic/fallback receipts without canonical evidence.
- Do not broaden the PowerShell branch exception or treat it as a checkpoint exception.
- Do not change policy, thresholds, exclusions, suppressions, dependencies, coverage configuration, source, tests, or acceptance text to avoid the blocker.
- Do not create suffix audit/remediation folders, flat new-cycle artifacts, or evidence outside `<FEATURE>/evidence/<kind>/`.
- Do not start remediation pass 8 or consume the remaining cycle before R5.
- Do not push, create or update a PR, or monitor CI unless every canonical gate later authorizes it.
