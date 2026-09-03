# Remediation Inputs — Portable Prepared Orchestration Handoff (#614)

- Timestamp: `2026-08-31T17-20`
- Review status: `REMEDIATION_REQUIRED`
- Branch: `feature/portable-prepared-orchestration-handoff-614`
- Head: `b06a3516d52d1693a38106eeb33817c261983620`
- PR base: `main`
- Merge base: `9f3514bf5da84110f23617382cbbeabf54f27427`
- Primary requirements source for planning: this file
- Plan target: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-08-31T17-20.md`
- Delegation ID: `s9-remediation-atomic-planner-614-001`
- Deployment agent: `atomic-planner-c4`

## Authoritative Context Package

The remediation planner must read these artifacts before producing the plan:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-inputs.2026-08-31T17-20.md`
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-08-31T17-20.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-08-31T17-20.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-08-31T17-20.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/issue.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/research/20260831-portable-prepared-orchestration-handoff-implementation-research.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/other/progress-commit-*.2026-08-31T07-58.md`

## Findings Requiring Remediation

### FR-614-001 — P0 / Blocker — TypeScript containment is not symlink-safe

`extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts:44-50` and `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-support.ts:12-29` validate containment with `path.resolve` plus a lexical prefix comparison. They do not resolve the real filesystem target or reject symlinked path components. A repository-relative path can therefore traverse an in-workspace symlink to read or materialize outside the workspace. This violates `spec.md:338-339`, compromises the safety promised by `spec.md:360-363`, and leaves the invalid-path fail-closed behavior in `user-story.md:109-117` incomplete. The Python implementation at `scripts/dev_tools/orchestration_handoff_contract_support.py:43-51` uses strict real-path resolution, so the TypeScript consumer path is also behaviorally inconsistent with the Python authority.

Required remediation:

1. Introduce a deterministic, testable filesystem-boundary abstraction for canonical real-path or component-link inspection in the TypeScript authority and materialization paths.
2. Resolve and validate the workspace root and every contract-controlled source, envelope, plan, archive, candidate, destination, and canonical checkpoint path before reading or mutating it.
3. Reject symlink/junction/reparse-point escape and any canonical target outside the resolved workspace root before all source archive, candidate write, or canonical replacement operations.
4. Preserve ordinary, parallel-child, and epic-child ownership constraints and the existing ordered `HANDOFF_*` primary-error precedence.
5. Add deterministic TypeScript tests for symlink escape on validation and materialization paths. Tests must use repository-approved seams and fixtures; do not create temporary files.
6. Prove parity with the strict Python behavior and published consumer surfaces.

Acceptance evidence:

- TypeScript unit/contract tests reject an in-workspace link whose real target is outside the workspace.
- The rejection occurs before source read/archive and before candidate/canonical checkpoint mutation.
- Traversal, absolute path, raw-byte digest, stale content, and normal in-workspace cases remain green.
- Root, bundle, core/variant pack, and installed-consumer parity tests remain green.

### FR-614-003 — P1 / Major — New TypeScript authority file is below 90%

The checked-in `extensions/drm-copilot/coverage/lcov.info` reports 181/208 executable lines covered for `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`, or 87.02%. Uncovered executable lines are 82-83, 88-89, 96-102, 118-119, 160-163, 166-169, and 193-198. This is a new production file and must reach at least 90% line coverage.

Required remediation:

1. Add deterministic tests for the uncovered contract and error branches, including the symlink-safe behavior required by FR-614-001.
2. Do not suppress, ignore, or remove executable branches solely to change the percentage.
3. Keep every new production module, class, and method at or above 90% and every modified production file at or above 80% without regression.

Acceptance evidence:

- The authority service reports at least 90% line coverage in the generated LCOV artifact.
- Repository TypeScript line coverage remains at least 85%, branch coverage remains at least 75%, and neither metric regresses from the merge-base baseline.
- The full TypeScript test suite passes.

## PowerShell QA Disposition — PASS, Not a Remediation Finding

The earlier 19.00% reading (1,491/7,848) came from a narrow hook-only invocation that ran 637 tests while retaining the full 88-file coverage denominator. That combination cannot establish repository-wide PowerShell coverage and invalidates the prior coverage-debt finding. The authoritative full MCP `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})` run omitted `scan_folders`, passed 3,932/3,932 tests, and reported 7,437/7,848 covered lines (94.763%). PowerShell therefore receives an explicit PASS verdict and requires no code or test remediation. The historical targeted run remains relevant only for its 91.82% changed-hook measurement and for documenting why the repository-wide interpretation was rejected.

## Acceptance-Criteria Reconciliation

The requirement sources currently show all 15 spec criteria and all 13 user-story criteria checked. Review verification found 24 PASS, 2 PARTIAL, and 2 FAIL:

- `spec.md` AC3 is FAIL because TypeScript does not reject symlink escape.
- `spec.md` AC10 is PARTIAL because atomic materialization is not contained against symlink escape.
- `user-story.md` criterion 8 is PARTIAL for the same materialization-safety gap.
- `user-story.md` criterion 10 is FAIL because invalid symlinked plan/checkpoint paths do not fail closed.

The remediation executor must leave non-PASS criteria unchecked while work is in progress and check them only after the required tests and audit evidence prove PASS. Review ownership did not modify requirement-source checkboxes.

## Preserved Contracts and Scope Boundaries

- Do not synthesize historical destination receipts or rewrite opaque source receipts.
- Preserve raw-byte SHA-256 identity, immutable source archive behavior, digest-linked history, completed-phase replay rejection, and exact next-transition continuity.
- Preserve provider-neutral logical complexity and lifecycle semantics; destination-specific model, reasoning, profile, topology, launch, and receipt evidence applies only to new destination work.
- Preserve ordinary child boundaries: ordinary orchestrators may return bounded parallel/epic child results but may not assume scheduling, barrier, fan-in, integration, cleanup, or parent-completion authority.
- Preserve root, extension-resource, core/variant-pack, and installed-consumer publication parity.
- Issue #467 remains the sole owner of full Codex-native parallel scheduling behavior.
- Issue #543 remains the sole owner of the provider-specific epic-planner ready-gate defect.
- Do not edit repository policies, reduce thresholds, introduce suppression comments, add dependencies without approval, or exceed the 500-line cap.
- Do not fabricate lifecycle, routing, launch, validation, test, coverage, or commit evidence.

## Required QA and Integrity Gates

1. Validate the remediation plan through `validate_orchestration_artifacts` before execution.
2. Re-run Python formatting, linting, typing, and Pytest coverage in the required order.
3. Re-run TypeScript formatting, linting, type checking, and Jest coverage in the required order.
4. Re-run PowerShell formatting, analysis, and coverage in the required order as a no-regression QA gate. Coverage must use only full MCP `mcp__drm_copilot__run_poshqc_test` with `scan_folders` omitted, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and its configured `CodeCoverage.Path`; direct Pester and narrow `scan_folders` runs are not acceptable repository coverage evidence. Require all tests to pass and repository line coverage to remain at or above policy.
5. Re-run architecture, contract, handoff, provider-parity, publishing-parity, pack/install, hook-process, ordinary/parallel/epic ownership, #469 end-to-end, #467, and #543 regression suites.
6. Recompute per-new-file and per-modified-file coverage from fresh coverage artifacts.
7. Verify no changed production, test, or reusable script file exceeds 500 lines.
8. Run `git diff --check` against the recorded merge base and preserve clean, linear, evidence-backed progress commits.
9. Re-evaluate all 28 acceptance criteria and reconcile checkboxes strictly to verified PASS results.

## Plan Requirements

The delegated plan must comply with the atomic-plan contract, use sequential `[P#-T#]` task identifiers, begin with Phase 0 policy/baseline capture, define exact file ownership and command evidence, include cross-language QA loops, and end with validation of the remediation plan and all review-triggered acceptance conditions. It must not treat the existing 108-task feature plan as a mutable remediation plan. Its complete bounded remediation scope is FR-614-001 and FR-614-003 only; it must include no PowerShell debt implementation and no authorization wait. The user has explicitly authorized automated continuation through remediation, post-remediation review, PR creation, and exact-head CI. Merge is not authorized.
