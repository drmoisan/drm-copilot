# Remediation Inputs — Issue #1159 — Review R4

- Timestamp: 2026-11-14T07-57
- Issue: #1159
- Branch: feature/hook-dispatcher-process-cost-1159
- PR: #1177 (base main)
- Reviewed head: 9478c4b659092881c0db1fe2e8e04f90bfad3189
- Merge base: 2c8dee6dd3a82f210561d9efe623767ae902de51
- Opened by: feature review (re-audit of main-sync cycle 1, concurrent PR review)
- Review-Verdict: REMEDIATION_REQUIRED
- Remediation-Path: full
- Remediation-Mode: proportionate

## Review Artifacts

- policy-audit: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/policy-audit.2026-11-14T07-57.md
- code-review: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/code-review.2026-11-14T07-57.md
- feature-audit: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/feature-audit.2026-11-14T07-57.md

## Context

Cycle 1 findings F1-F3 of remediation-inputs.2026-11-14T06-51.md are resolved: the arrived DocsReceiptRevision.psm1 edge lost -Force after a stateless audit, the D13 tail run shows no fail-open hook, and the integration record, mirrors and final QA loop are complete and green locally. CI on the reviewed head and on every head since the registry change shows two failures caused by the branch that the local gate set did not run. The path is full because F1 adds a file outside the branch diff (quality-tiers.yml).

## Findings

### F1 — Tier entry for the new hook-dispatch library

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the entry is a data edit to a repository file on the branch; the check runs locally with check_quality_tiers and needs no external party.
- Finding-Scope: contained
- Location: quality-tiers.yml, projects list
- Evidence: poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root at the reviewed head prints "QT008: discovered project '.claude/lib/hook-dispatch' has no entry"; the main checkout prints "quality-tiers: OK (33 entries, 33 discovered projects)"; CI quality-checks7 fails at the tier-classification step (runs 43573314091, 43570680445), which also skips the CI pytest and Python coverage-threshold steps.
- Required: add a `.claude/lib/hook-dispatch` entry with a tier and rationale consistent with the sibling runtime libraries shipped in the `.claude` bundle (for example T3, as for `.claude/lib/hook-payload`); run check_quality_tiers and record new evidence.

### F2 — TypeScript push-down closure helper ignores the Codex registry

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the change is a test-helper edit on the branch that mirrors the already updated Python twin; Jest runs locally and in CI without an external dependency.
- Finding-Scope: contained
- Location: extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts, collectRegisteredHookClosure (lines 163-193); failing test extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts line 100
- Evidence: CI run 43570680445 (head f97b8e543, identical TypeScript and bundle content): "Expected: > 21, Received: 10" in both the root TypeScript and the extension test jobs; run 43573314091 fails the same steps at the reviewed head. The Python twin tests/scripts/dev_tools/test_codex_core_manifest_closure.py added registry_hook_paths on this branch; the TypeScript helper was not changed.
- Required: add every hook command path named in the bundle `.codex/hooks/pretooluse-dispatch.json` as a closure root in collectRegisteredHookClosure, matching the Python registry_hook_paths rule; run Prettier, ESLint, the TypeScript type-check and the root Jest suite with coverage (`npm run test:unit:coverage`, writing coverage/lcov.info) plus the extension Jest suite; record each as new evidence. TypeScript becomes a changed language, so the next review needs the TypeScript coverage artifact.

## Acceptance criteria affected

- spec.md line 201 and line 203, user-story.md line 63: reverted to unchecked by this review; check them off after F2 is fixed and CI is green.
- Definition of Done "Linux hook-suite CI job": pending-CI, checked off at S9.
