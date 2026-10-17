# Review disposition inputs: Current Codex model routing (#977)

Review-Verdict: HALT_NON_REMEDIABLE
Remediation-Mode: proportionate
Timestamp: 2026-10-17T19-07
Issue: 977
Base: main
Merge-Base: f1408d0040e11432f3efbf4f7b6af4115c0b1f3d
Reviewed-Head: c9902b54ffdb146b5039d5b7aaf4c1145afe5066

## Disposition

There are two non-remediable operational findings and zero autonomous findings. Per feature-review and remediation-handoff-atomic-planner, do not create a remediation plan target and do not delegate atomic-planner. REMEDIATION_PLAN: NONE. Local implementation, toolchain and coverage gates pass.

## Finding R1

Severity: Blocking
Remediability: external_dependency
Remediability-Evidence: The installed MCP executes an older extension rule set requiring former model identifiers; the branch cannot replace that running runtime merely by changing repository files.

- Location: installed validate_orchestration_artifacts runtime; artifacts/orchestration/orchestrator-state.json codex_model_routing_receipts indices 11 through 16.
- Requirement: spec.md Constraints & Risks requires a matching installed validator for authoritative completion. Keep approved current-model policy and exact receipt rejection behavior.
- Verification performed: MCP validate_orchestration_artifacts with workspace_root=current checkout, artifact_type=orchestrator-state, artifact_path=artifacts/orchestration/orchestrator-state.json, require_codex_model_routing=true, require_codex_topology=true.
- Actual result: ok=false, isError=true. Exact returned errors:

~~~text
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[16].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[16].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
~~~

- Coordinator-owned next action: assess and arrange a matching supported installed runtime; re-run authoritative validation with truthful current profile/model/effort/path/hash/start evidence. Preserve all prior launches verbatim as historical evidence. Do not treat installation alone as proof that the checkpoint is valid.
- Expected exit condition: installed validation accepts the approved current model contract and the truthful completed checkpoint satisfies required topology/model receipts and completion gates.
- The reviewer did not install, reload, change source or alter receipts.

## Finding R2

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Initial required CI succeeded at remote PR head 6b7572ae6fcfe863d13609fe9452d5f769715209; local acceptance check-off commit c9902b54ffdb146b5039d5b7aaf4c1145afe5066 still requires push and resulting-head re-verification.

- Location: spec.md SPEC-08 and seeded CI-dependent condition; user-story.md STORY-05.
- Requirement: required CI succeeds for final PR head; the item's orchestrator checks off CI criteria at S9, commits/pushes that change and verifies CI again at the resulting final head.
- Current evidence: canonical PR summary/appendix generated 2026-10-17 19:06:08 UTC for reviewed head; all 16 source criteria now checked, including three initial-green S9 check-offs whose final resulting-head re-verification remains outstanding. Thirteen local criteria are fully verified; three CI criteria are conditional. Local Python/TypeScript/PowerShell evidence is separate and passes.
- Coordinator-owned next action: push acceptance check-off continuation for draft PR #978, verify actual required checks and ci_gate.conclusion=success with ci_gate.head_sha equal to final PR head before DONE.
- Verification commands: gh pr checks <item-pr>; repository CI gate parser; exact-head PR-context refresh and completion validation.
- Expected exit condition: all required remote checks pass, CI source items checked by item owner, resulting push reverified.

## Nonblocking documentation note

Prior plan/addendum EOF nits were corrected. Coordinator also corrected local-vsix-readiness integer EXIT_CODE and EOF formatting, keeping MCP_VALIDATION_OK=false and the exact rejection. Reviewer inspected the corrected working copy and git diff --check main passes. These evidence-only repairs do not change source, tests or runtime and require no repeated broad source QA.

## Context Package

- Canonical primary context: artifacts/pr_context.summary.txt.
- Canonical baseline appendix: artifacts/pr_context.appendix.txt.
- Policy audit: docs/features/active/2026-10-17-current-codex-model-routing-977/policy-audit.2026-10-17T19-07.md.
- Code review: docs/features/active/2026-10-17-current-codex-model-routing-977/code-review.2026-10-17T19-07.md.
- Feature audit: docs/features/active/2026-10-17-current-codex-model-routing-977/feature-audit.2026-10-17T19-07.md.
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


## Refreshed evidence assessment

Previous audit set at 2026-10-17T18-47 remains preserved. Current canonical PR context pair binds c9902b54ffdb146b5039d5b7aaf4c1145afe5066 at 2026-10-17 19:06:08 UTC. The complete feature-vs-base scope remains covered; no executable/config/test/generated/bundle drift occurred since prior review. Local ordered toolchain and raw coverage measurements are reused on this evidence.

Fresh live gh pr view/checks confirms draft/open PR #978 at remote 6b7572ae6fcfe863d13609fe9452d5f769715209 with 26 passing checks. evidence/qa-gates/ci-initial.2026-10-17T19-05.md records this initial green result and explicitly disclaims resulting check-off head success.

Supported local VSIX package/install/file verification succeeded per evidence/qa-gates/local-vsix-readiness.2026-10-17T18-54.md. The running provider still rejects current models on fresh validation. R1 remains external_dependency; source changes or successful installation alone cannot prove current live-provider/checkpoint readiness. No install, reload, source edits or receipt edits were performed by the reviewer.

This review still has zero autonomous findings. No remediation plan target exists and no atomic-planner handoff occurred, as required for HALT_NON_REMEDIABLE.
