# Follow-ups for Issue #523 (P12-T1)

Timestamp: 2026-09-30T15-57
Source: `spec.md` `## Rollout & Follow-up`, "Post-fix monitoring or clean-up tasks (follow-ups, not part of #523)", items 1-6 (spec lines 383-388).
Disposition: recorded only. The orchestrator decides whether and how to file each item through the MCP promotion path; the executor filed nothing.

1. Reconcile the documentation-only `blocked_reason` members in `.agents/skills/orchestrator-workflow/SKILL.md` (`checkpoint_conflict`, `lifecycle_preconditions_missing`, `review_status_missing`, `commit_context_missing`, `no_staged_changes`, `pre_implementation_gate_violation`) with the validators, including the `checkpoint_conflict` prose in `.codex/agents/*.toml`. Source: spec `## Rollout & Follow-up` item 1 (line 383); relates to AC-14.
2. Cross-runtime message rendering for boolean and float `blocked_reason` values. Source: spec `## Rollout & Follow-up` item 2 (line 384).
3. Python `TypeError` for array or object `blocked_reason` under `require_complete` and PR readiness. Source: spec `## Rollout & Follow-up` item 3 (line 385); relates to AC-11.
4. PR-creation-readiness gate absent from the TypeScript validator. Source: spec `## Rollout & Follow-up` item 4 (line 386).
5. `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` exceeds the 500-line cap (pre-existing; 508 lines at P0-T5). Source: spec `## Rollout & Follow-up` item 5 (line 387).
6. The `test_orchestration_guardrail_contracts.py` skip reason states that `.codex` and `.agents` are gitignored, which does not match the current `.gitignore`. Source: spec `## Rollout & Follow-up` item 6 (line 388).
