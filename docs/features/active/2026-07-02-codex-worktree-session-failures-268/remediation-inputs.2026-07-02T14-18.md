# Remediation Inputs: codex-worktree-session-failures (#268)

Timestamp: 2026-07-02T14-18
Feature Folder: `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
Base Branch: `main`
Head Commit: `8126e749e5270c5bca37e1bf03581e04f631ff81`

## Authoritative Findings

1. Fix post-Codex script empty-copy-plan execution.
   - Severity: Blocker
   - Files:
     - `.codex/scripts/post-codex-worktree-session.ps1`
     - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`
     - `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1`
   - Expected behavior: Same-root execution and missing-source `.codex`/`.agents` folders complete without error.
   - Current evidence: Direct reviewer commands failed with `Cannot bind argument to parameter 'CopyOperation' because it is an empty array.`
   - Required verification:
     - `& .\.codex\scripts\post-codex-worktree-session.ps1 -SourceRoot (Get-Location).Path -WorktreeRoot (Get-Location).Path`
     - A missing-source-folder invocation using existing repository test conventions, without introducing persistent temporary test dependencies.
     - `mcp__drm-copilot__run_poshqc_format`
     - `mcp__drm-copilot__run_poshqc_analyze`
     - `mcp__drm-copilot__run_poshqc_test`
     - SHA-256 parity comparison between root and bundled post-Codex scripts.

2. Add missing PowerShell no-op coverage.
   - Severity: Major
   - File: `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1`
   - Expected behavior: Pester tests must cover the script execution or invocation function path where copy operations are empty.
   - Current evidence: Existing tests cover `Get-CodexCustomizationCopyPlan` but did not catch full-script empty-array failure.
   - Required verification:
     - Focused Pester test proves empty copy-operation handling does not throw.
     - PoshQC test evidence records passing Pester suite and coverage values.

3. Correct non-canonical research artifact location.
   - Severity: Major
   - File: `artifacts/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md`
   - Expected behavior: `python scripts\dev_tools\validate_evidence_locations.py --root .` exits 0.
   - Current evidence: Validator output reported `VIOLATION: artifacts\research\2026-07-02T13-17-codex-worktree-session-failures-268-research.md — use docs/features/active/<feature>/research/ or docs/research/ instead`.
   - Required verification:
     - Move or mirror research to `docs/features/active/2026-07-02-codex-worktree-session-failures-268/research/` or another validator-approved location.
     - Update references in `spec.md`, `plan.2026-07-02T13-13.md`, and any evidence that points to `artifacts/research/...`.
     - Rerun `python scripts\dev_tools\validate_evidence_locations.py --root .`.

## Do Not Do

- Do not weaken evidence-location validation or ignore `validate_evidence_locations.py`.
- Do not hardcode repository-specific `.codex` or `.agents` copy behavior into the TypeScript extension.
- Do not remove source-root post-Codex invocation behavior.
- Do not mark acceptance criteria or review status as PASS until the direct no-op script verification and evidence-location validator pass.
- Do not create evidence under non-canonical `artifacts/baseline`, `artifacts/qa`, `artifacts/evidence`, `artifacts/coverage`, or `artifacts/research` paths.

## Required Artifact References

- Policy audit: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/policy-audit.2026-07-02T14-18.md`
- Code review: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/code-review.2026-07-02T14-18.md`
- Feature audit: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/feature-audit.2026-07-02T14-18.md`
- PR context summary: `artifacts/pr_context.summary.txt`
- PR context appendix: `artifacts/pr_context.appendix.txt`
- Original plan: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md`
