# Remediation Inputs: Independent Portable Handoff Binding Authority (#614)

- Timestamp: `2026-09-03T00-07`
- Review status: `REMEDIATION_REQUIRED`
- Reviewed head: `541e8d89250bdc9a49f78c4ac4fcb6217799a4dd`
- Base branch: `origin/main`
- Merge base: `9f3514bf5da84110f23617382cbbeabf54f27427`
- Work mode: `full-feature`
- Primary finding: `FR-614-005`
- Resolved findings to preserve: `FR-614-001`, `FR-614-003`, `FR-614-004`
- Required plan target: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-03T00-07.md`

## Authoritative Requirements

These remediation inputs are the primary requirements source for the next plan. The implementation must also preserve the feature requirements and already delivered behavior in:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-08-31T17-20.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-02T22-17.md`

## Finding FR-614-005

### Classification

- Priority: P1
- Severity: Major
- Category: production validation boundary / fail-closed authorization

### Observed defect

The published `PortableHandoffReferenceRequest` and MCP schema contain only:

- `workspace_root`
- `handoff_envelope_path`
- `expected_handoff_envelope_sha256`
- `destination_provider`

The production authority then calls `collectHandoffValidationFailures` with these values copied from the envelope under validation:

- `repositoryId: envelope.binding.repositoryId`
- `branch: envelope.binding.branch`
- `issueNumber: envelope.identity.issueNumber`
- `featureFolder: envelope.identity.featureFolder`
- `workMode: envelope.identity.workMode`
- `sourceHeadRelationshipValid: true`

Those comparisons are tautological. The envelope digest authenticates the selected bytes but does not prove that those bytes describe the intended repository, branch lineage, source HEAD, issue, feature, or work mode. `transition_prepared_orchestration` converts its request back to the same incomplete reference request before invoking topology and routing authority, so materialization inherits the gap.

### Direct reproduction

A read-only exact-head Node reproduction loaded the valid ordinary Claude-to-Codex fixture, kept its workspace/provider/plan valid, changed all of the following, recalculated the selected-envelope digest, and called `resolvePortableHandoffAuthority`:

- `repository_id` -> `github.com/other/repository`
- `branch` -> `feature/unrelated-999`
- `source_head_sha` -> 40 `f` characters
- `issue_number` -> `999`
- `feature_folder` -> `docs/features/active/unrelated-999`
- `work_mode` -> `minor-audit`

Observed result:

```json
{
  "status": "validated",
  "primaryFailureCode": null,
  "resolution": {
    "kind": "destination_topology",
    "provider": "codex"
  }
}
```

The focused authority/materializer/contract test run passed 4/4 suites and 61/61 tests, but `orchestration-handoff-authority-service.test.ts` tests only workspace mismatch among these context bindings. Repository, branch/source-HEAD lineage, issue, feature, and work-mode rejection are tested only against the generic validator with a manually independent context, not through the supported production authority or transition path.

### Requirement impact

FR-614-005 causes these authoritative criteria to fail:

- `spec.md`: AC1, AC8, AC10.
- `user-story.md`: criteria 1, 7, 8, 10.

The seven markers are intentionally unchecked by the final review and may be checked again only after direct passing evidence proves their complete behavior.

### Primary affected paths

- `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts`
- `extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts`
- `extensions/drm-copilot/src/repo-automation-service-contract.ts`
- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts`
- `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts`
- `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`
- `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts`
- Published extension bundle/resource and consumer parity paths derived from the final request/authority contract.

The planner must determine the smallest complete changed-path set. Listing a path here is not automatic permission to edit it when the chosen design does not require a change.

## Required Behavior

1. `resolve_orchestration_topology`, `resolve_provider_routing`, and `transition_prepared_orchestration` must validate repository identity, workspace identity, branch lineage/source-HEAD relationship, issue number, feature folder, work mode, and exact plan identity against facts that are independent of the envelope being validated.
2. No expected/observed field may be populated from the same envelope field it is intended to verify.
3. Repository and branch/source-HEAD facts should be observed from the explicit destination checkout through an injectable, testable local boundary where practical. Objective fields that cannot be safely observed must be supplied by a clearly named independent expected-context contract or proven against the exact source checkpoint without provider-specific fabrication.
4. `allowed_head_relationship: equal` must require the exact bound source HEAD. `equal_or_descendant` must establish actual Git ancestry. The implementation must not hard-code relationship validity.
5. Each mismatch must return the existing deterministic primary failure code at its defined precedence position:
   - wrong repository -> `HANDOFF_REPOSITORY_MISMATCH`
   - wrong workspace -> `HANDOFF_WORKSPACE_MISMATCH`
   - wrong issue, feature, or work mode -> `HANDOFF_ISSUE_FEATURE_MISMATCH`
   - wrong branch or invalid source-HEAD relationship -> `HANDOFF_BRANCH_LINEAGE_MISMATCH`
6. All affected checks must complete before dirty-worktree evaluation and before source archive, candidate write, canonical replacement, delegation, or execution.
7. Both dry-run and materialize modes must use the same validated context. A blocked result must leave source and destination files unchanged and must list no completed transition.
8. Public TypeScript interfaces, MCP JSON schemas, input parsing, service contracts, runtime/bundle resources, pack manifests, and installed-consumer artifacts must remain synchronized.
9. Production-path tests must hold independent expected/observed context fixed while changing each envelope binding individually and in precedence combinations. They must assert the exact result code and prove no write-boundary call.
10. Generic validator tests may remain, but they are not sufficient by themselves. At least the authority entry points and transition production path must prove the independent binding behavior.
11. No new network dependency may be added to the critical validation/materialization section.
12. FR-614-001 canonical path containment, FR-614-003 authority-service coverage, and FR-614-004 raw fixture byte identity must remain passing.

## Required Verification

Use the repository-mandated ordered toolchain and restart from formatting if any stage changes files or fails.

### Focused behavior

- TypeScript unit tests for `orchestration-handoff-authority-service`, `orchestration-handoff-materializer`, `orchestration-handoff-materializer-production`, MCP handoff handlers, tool definitions, service dispatch, and consumer publication.
- One matrix that independently exercises wrong repository, wrong branch, equal/source-HEAD mismatch, equal-or-descendant ancestry failure, wrong issue, wrong feature, and wrong work mode through the production authority request.
- Dry-run and materialize tests proving every mismatch occurs before archive/candidate/replace calls and before dirty-worktree evaluation where precedence requires it.
- Cross-language compatibility/precedence tests if the request or shared contract surface changes.

### Full quality gates

- `git status --short --branch`
- `git -c core.whitespace=cr-at-eol diff --check 9f3514bf5da84110f23617382cbbeabf54f27427...HEAD`
- `poetry run black .`
- `poetry run ruff check .`
- `poetry run pyright`
- `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
- `npm run format` from `extensions/drm-copilot`
- `npm run lint` from `extensions/drm-copilot`
- `npm run typecheck` from `extensions/drm-copilot`
- `npm run test:coverage` from `extensions/drm-copilot`
- MCP `run_poshqc_format` with the explicit workspace root and `scan_folders` omitted.
- MCP `run_poshqc_analyze` with the explicit workspace root and `scan_folders` omitted.
- MCP `run_poshqc_test` with the explicit workspace root and `scan_folders` omitted.
- Contract/schema compatibility, architecture-boundary, integration/publication parity, source/bundle/pack/install parity, parallel-scope, and epic-ready-gate regression suites named by the original plan.
- Re-run the raw fixture identity command and focused 2-case TaskMaster test to prove FR-614-004 remains resolved without hydration.

Each new command-step evidence artifact must use the canonical feature evidence tree and include `Timestamp`, exact `Command`, numeric `EXIT_CODE`, and `Output Summary`. Coverage evidence must include numeric line and branch values where measured. The authoritative PowerShell report must distinguish 3,923 active passes and 9 skipped/disabled rather than treating skipped cases as passes.

## Acceptance Criteria Reconciliation

- `spec.md` total: 15; checked: 12; unchecked: AC1, AC8, AC10.
- `user-story.md` total: 13; checked: 9; unchecked: criteria 1, 7, 8, 10.
- Combined total: 28; checked: 21; unchecked: 7.
- `issue.md` early-draft checkboxes remain non-authoritative and unchanged.

The remediation executor may change only the seven failing authoritative markers from unchecked to checked, one at a time, after each mapped direct verification passes. Criterion text must remain unchanged.

## Do Not Do

- Do not copy expected repository, branch, source HEAD, issue, feature, or work-mode values from the envelope under validation.
- Do not replace independent validation with the expected envelope digest alone.
- Do not hard-code Git ancestry or source-HEAD relationship validity.
- Do not silently infer ambiguous objective facts from folder names, branch names, or the legacy four-field checkpoint.
- Do not weaken deterministic failure precedence, path containment, dirty-worktree preservation, source archival, atomic replacement, replay prevention, provider neutrality, or scheduler ownership.
- Do not add shell-based materialization authority, preparation-gate patch permission, a network dependency, a third-party dependency, broad suppressions, coverage exclusions, sleeps, retries, or temporary-file unit tests.
- Do not skip, delete, or narrow existing full suites to make the remediation pass.
- Do not modify the two binary-preserved TaskMaster plan fixtures or introduce pre-test/in-test fixture hydration.
- Do not edit repository policy files.
- Do not commit, push, create or update a PR, monitor CI, or merge within the remediation plan. The parent orchestrator owns lifecycle transitions and merge remains unauthorized.

## Context Package for Atomic Planning

Primary requirements:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-09-03T00-07.md`

Canonical PR context:

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`

Triggering review artifacts:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-03T00-07.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-03T00-07.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-03T00-07.md`

Original and prior remediation plans:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-08-31T17-20.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-02T22-17.md`

Direct QA and regression evidence:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-unit-coverage.2026-09-02T22-17.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-unit-coverage.2026-09-02T22-17.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-unit-coverage.2026-09-02T22-17.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/integration-parity.2026-09-02T22-17.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/git-index-and-checkout-byte-identity.2026-09-02T22-17.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/typescript-containment-focused.2026-09-02T22-17.md`

## Completion Condition

Remediation is complete only when all three published tools use independently established contextual bindings, every named mismatch returns its deterministic code before any governed mutation, source/bundle/pack/install parity is restored, complete ordered QA passes with coverage and no regression, all seven acceptance markers are individually rechecked from direct evidence, and a new full feature review reports `PASS`.
