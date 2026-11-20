## Fail-Before Reproduction — `--require-complete` Against the Real Live Checkpoint (Remediation Cycle 2, Issue #272)

Timestamp: 2026-07-02T22-05
Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete`
EXIT_CODE: 1
Output Summary:
- Confirmed the Blocking finding reproduces: `--require-complete` fails against the real, live, in-flight checkpoint with errors including `pr_gate must be an object with keys...`, `ci_gate must be an object with keys...`, and `Checkpoint missing required agent receipt: pr-author.` — the three structurally-impossible-to-satisfy-pre-PR conditions cited in `remediation/2026-07-02T22-05/remediation-inputs.md`.
- The live checkpoint has evolved since the remediation-inputs document was authored (it is an actively-mutating, in-flight checkpoint for this very remediation cycle): the current run also surfaces additional pre-existing gaps unrelated to this fix (`relativeFile`/`long-name` missing, an invalid `step5_status: complete` literal — the valid enum value is `completed`, `step9_status: pending`, unmet `required_agents`/`required_skills`/`required_mcp_tools` routing-contract entries, and non-empty-list checks on `local_execution_overrides`/`delegation_bypasses`). These additional errors are consistent with the checkpoint being genuinely pre-PR/pre-CI and are not fabricated for this evidence artifact.
- Full raw output:
```
Checkpoint missing required key: relativeFile
Checkpoint missing required key: long-name
Checkpoint has invalid step5_status: complete
Checkpoint completion validation failed: step9_status is pending.
Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.
Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.
Checkpoint required_agents must match routing matrix for route large.
Checkpoint required_skills must match routing matrix for route large.
Checkpoint required_mcp_tools must match routing matrix for route large.
Checkpoint missing required agent receipt: task-researcher.
Checkpoint missing required agent receipt: prd-feature.
Checkpoint missing required agent receipt: atomic-planner.
Checkpoint missing required agent receipt: atomic-executor.
Checkpoint missing required agent receipt: feature-review.
Checkpoint missing required agent receipt: pr-author.
Checkpoint missing required skill receipt: orchestrator-workflow.
Checkpoint missing required skill receipt: repo-automation-adapter.
Checkpoint missing required skill receipt: atomic-plan-contract.
Checkpoint missing required skill receipt: acceptance-criteria-tracking.
Checkpoint missing required skill receipt: pr-context-artifacts.
Checkpoint missing required skill receipt: pr-base-branch-merge-base.
Checkpoint missing successful MCP receipt: collect_pr_context.
Checkpoint missing successful MCP receipt: validate_orchestration_artifacts.
Checkpoint local_execution_overrides must be an empty list at completion.
Checkpoint delegation_bypasses must be an empty list at completion.
```
- This is the fail-before baseline this remediation cycle's Phase 6 must resolve for the new `--require-pr-creation-ready` flag (a materially narrower check that does not require `ci_gate`, `pr_gate`, routing-contract receipts, or step9/step10 completion — only steps 5-8, `blocked_reason`, and the two override lists).
