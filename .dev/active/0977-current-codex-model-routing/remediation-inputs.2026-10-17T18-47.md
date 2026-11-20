# Review disposition inputs: Current Codex model routing (#977)

Review-Verdict: HALT_NON_REMEDIABLE
Remediation-Mode: proportionate
Timestamp: 2026-10-17T18-47
Issue: 977
Base: main
Merge-Base: f1408d0040e11432f3efbf4f7b6af4115c0b1f3d
Reviewed-Head: 9f7432dedd5456167e04595bf73bd6f27aa5d4cf

## Disposition

There are two non-remediable operational findings and zero autonomous findings. Per feature-review and remediation-handoff-atomic-planner, do not create a remediation plan target and do not delegate atomic-planner. REMEDIATION_PLAN: NONE. Local implementation, toolchain and coverage gates pass.

## Finding R1

Severity: Blocking
Remediability: external_dependency
Remediability-Evidence: The installed MCP executes an older extension rule set requiring former model identifiers; the branch cannot replace that running runtime merely by changing repository files.

- Location: installed validate_orchestration_artifacts runtime; artifacts/orchestration/orchestrator-state.json codex_model_routing_receipts indices 11, 12 and 13.
- Requirement: spec.md Constraints & Risks requires a matching installed validator for authoritative completion. Keep approved current-model policy and exact receipt rejection behavior.
- Verification performed: MCP validate_orchestration_artifacts with workspace_root=current checkout, artifact_type=orchestrator-state, artifact_path=artifacts/orchestration/orchestrator-state.json, require_codex_model_routing=true, require_codex_topology=true.
- Actual result: ok=false, isError=true. Exact returned errors:

~~~text
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
~~~

- Coordinator-owned next action: assess and arrange a matching supported installed runtime; re-run authoritative validation with truthful current profile/model/effort/path/hash/start evidence. Preserve all prior launches verbatim as historical evidence. Do not treat installation alone as proof that the checkpoint is valid.
- Expected exit condition: installed validation accepts the approved current model contract and the truthful completed checkpoint satisfies required topology/model receipts and completion gates.
- The reviewer did not install, reload, change source or alter receipts.

## Finding R2

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Required final PR-head checks have not been recorded; the bound canonical PR context reports no PR and CI status not available.

- Location: spec.md SPEC-08 and seeded CI-dependent condition; user-story.md STORY-05.
- Requirement: required CI succeeds for final PR head; the item's orchestrator checks off CI criteria at S9, commits/pushes that change and verifies CI again at the resulting final head.
- Current evidence: canonical PR summary/appendix generated 2026-10-17 18:44:40 UTC for reviewed head; all three criteria unchecked. Local Python/TypeScript/PowerShell evidence is separate and passes.
- Coordinator-owned next action: prepare draft PR/CI, verify actual required checks and ci_gate.conclusion=success with ci_gate.head_sha equal to final PR head before DONE.
- Verification commands: gh pr checks <item-pr>; repository CI gate parser; exact-head PR-context refresh and completion validation.
- Expected exit condition: all required remote checks pass, CI source items checked by item owner, resulting push reverified.

## Nonblocking documentation note

Initial committed diff had extra EOF blank lines in plan.2026-10-17T13-21.md and attestation-coverage-addendum.md. Parent requested and obtained only bounded whitespace repairs; git diff --check main passes after those edits. These are not autonomous review blockers and do not require a remediation cycle or repeated source QA.

## Context Package

- Canonical primary context: artifacts/pr_context.summary.txt.
- Canonical baseline appendix: artifacts/pr_context.appendix.txt.
- Policy audit: docs/features/active/2026-10-17-current-codex-model-routing-977/policy-audit.2026-10-17T18-47.md.
- Code review: docs/features/active/2026-10-17-current-codex-model-routing-977/code-review.2026-10-17T18-47.md.
- Feature audit: docs/features/active/2026-10-17-current-codex-model-routing-977/feature-audit.2026-10-17T18-47.md.
- Authoritative requirements: docs/features/active/2026-10-17-current-codex-model-routing-977/spec.md; docs/features/active/2026-10-17-current-codex-model-routing-977/user-story.md; issue.md supplies full-feature marker.
- Original plan: docs/features/active/2026-10-17-current-codex-model-routing-977/plan.2026-10-17T13-21.md.
- Approved bounded auxiliary plan: docs/features/active/2026-10-17-current-codex-model-routing-977/attestation-coverage-addendum.md.
- Complete execution evidence: docs/features/active/2026-10-17-current-codex-model-routing-977/evidence/qa-gates/execution-summary.2026-10-17T18-43.md.
- Coverage comparison: docs/features/active/2026-10-17-current-codex-model-routing-977/evidence/qa-gates/coverage-and-size.2026-10-17T18-32.md.
- Actual source/bundle measurements: latest evidence/qa-gates/powershell-bundle-coverage.*.md.
- Launch authorization and pending operational state: artifacts/orchestration/orchestrator-state.json.

## Do Not Do

- Do not weaken policy, exact-profile/hash/effort checks, receipt validation or final-head CI requirements.
- Do not relabel historical launches, overwrite their hashes or claim an old launch used a new model.
- Do not add a compatibility schema, fallback, dependency, broad refactor or unrelated file.
- Do not report review PASS, merge readiness or DONE from local gates alone.
- Do not create a remediation plan or delegate a planner for these non-autonomous findings.
