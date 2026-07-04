# Remediation Inputs: update-extension-icon-description (Issue #285)

Timestamp: 2026-07-03T16-09
Feature Folder: `docs/features/active/2026-07-03-update-extension-icon-description-285`
Policy Audit: `docs/features/active/2026-07-03-update-extension-icon-description-285/policy-audit.2026-07-03T16-09.md`
Code Review: `docs/features/active/2026-07-03-update-extension-icon-description-285/code-review.2026-07-03T16-09.md`
Feature Audit: `docs/features/active/2026-07-03-update-extension-icon-description-285/feature-audit.2026-07-03T16-09.md`
PR Context Summary: `artifacts/pr_context.summary.txt`
PR Context Appendix: `artifacts/pr_context.appendix.txt`

## Remediation Trigger

Remediation is required because the policy audit contains a FAIL-level evidence-location finding.

Validator command:

```powershell
python scripts/dev_tools/validate_evidence_locations.py --root .
```

Observed result: exit code 1.

## Remediation-Required Findings

### Finding R1 - Repository evidence-location validator fails

- Severity: FAIL
- Policy: `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- Evidence: `docs/features/active/2026-07-03-update-extension-icon-description-285/policy-audit.2026-07-03T16-09.md`, section `## Evidence Location Compliance`
- Expected behavior: evidence artifacts are stored under `<FEATURE>/evidence/<kind>/`; research artifacts are stored under `docs/features/active/<feature>/research/` or `docs/research/`.
- Actual behavior: the repository validator reports non-canonical files under `artifacts/research/` and `artifacts/evidence/`.
- Required remediation: create an implementation plan that moves, archives, or otherwise policy-dispositions the reported non-canonical files without weakening validation or changing issue #285 implementation files.

Reported path inventory:

- `artifacts/research/2026-06-17-194-remove-worktrees-research.md`
- `artifacts/research/2026-06-17-196-bundled-validator-resync-research.md`
- `artifacts/research/20260301-scaffold-extension-extension-side-execution-research.md`
- `artifacts/research/20260303-expose-commit-script-implementation-research.md`
- `artifacts/research/20260305-expose-pr-context-script-implementation-research.md`
- `artifacts/research/20260309-push-down-copilot-customizations-implementation-research.md`
- `artifacts/research/20260311-expose-placeholder-commands-implementation-research.md`
- `artifacts/research/20260313-new-potential-entry-missing-directory-bug-research.md`
- `artifacts/research/20260314-bundle-hard-lock-resolver-into-extension-implementation-research.md`
- `artifacts/research/20260314-csharp-orchestrator-small-path-lifecycle-research.md`
- `artifacts/research/20260321-bundle-sync-agents-implementation-research.md`
- `artifacts/research/20260411-claude-code-architecture-implementation-research.md`
- `artifacts/research/20260412-claude-code-github-skills-agents-migration-research.md`
- `artifacts/research/20260412-codex-github-skills-agents-migration-implementation-research.md`
- `artifacts/research/20260417-github-bundled-customization-divergence-audit-research.md`
- `artifacts/research/20260417-github-instructions-not-migrated-to-claude-151-research.md`
- `artifacts/research/20260429-harden-feature-promotion-lifecycle-mcp-only-implementation-research.md`
- `artifacts/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`
- `artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`
- `artifacts/research/push-down-claude-dir-149.md`
- `artifacts/research/2026-05-04-publish-mcp-server-to-npm/research.md`
- `artifacts/evidence/baseline/eslint-baseline.md`
- `artifacts/evidence/baseline/jest-baseline.md`
- `artifacts/evidence/baseline/typecheck-baseline.md`
- `artifacts/evidence/post-change/ac-verification.md`
- `artifacts/evidence/post-change/coverage-comparison.md`
- `artifacts/evidence/post-change/eslint-qc.md`
- `artifacts/evidence/post-change/jest-qc.md`
- `artifacts/evidence/post-change/npm-pack-listing.md`
- `artifacts/evidence/post-change/npm-publish-dry-run.md`
- `artifacts/evidence/post-change/prettier-qc.md`
- `artifacts/evidence/post-change/typecheck-qc.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/phase1-rename-summary.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/phase2-feature-summary.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/post-change-black.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/post-change-pyright.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/post-change-pytest.md`
- `artifacts/evidence/post-change/2026-04-18T17-29/post-change-ruff.md`
- `artifacts/evidence/post-change/2026-04-18T21-20/analyze-pass2.log`
- `artifacts/evidence/post-change/2026-04-18T21-20/analyze.log`
- `artifacts/evidence/post-change/2026-04-18T21-20/format-pass2.log`
- `artifacts/evidence/post-change/2026-04-18T21-20/format.log`
- `artifacts/evidence/post-change/2026-04-18T21-20/pester-run.log`
- `artifacts/evidence/post-change/2026-04-18T21-20/post-change-analyze.md`
- `artifacts/evidence/post-change/2026-04-18T21-20/post-change-format.md`
- `artifacts/evidence/post-change/2026-04-18T21-20/post-change-pester.md`
- `artifacts/evidence/post-change/2026-04-25T18-15/post-change-summary.md`
- `artifacts/evidence/baseline/2026-04-18T17-15/baseline-black.md`
- `artifacts/evidence/baseline/2026-04-18T17-15/baseline-pyright.md`
- `artifacts/evidence/baseline/2026-04-18T17-15/baseline-pytest.md`
- `artifacts/evidence/baseline/2026-04-18T17-15/baseline-ruff.md`
- `artifacts/evidence/baseline/2026-04-18T17-15/phase0-instructions-read.md`
- `artifacts/evidence/baseline/2026-04-18T21-20/analyze.log`
- `artifacts/evidence/baseline/2026-04-18T21-20/baseline-analyze.md`
- `artifacts/evidence/baseline/2026-04-18T21-20/baseline-pester.md`
- `artifacts/evidence/baseline/2026-04-18T21-20/pester-run.log`
- `artifacts/evidence/baseline/2026-04-18T21-20/phase0-instructions-read.md`
- `artifacts/evidence/baseline/2026-04-25T18-15/baseline-summary.md`

## Verification Commands

- `python scripts/dev_tools/validate_evidence_locations.py --root .`
- `git diff --check 706e4d8b600146133c09a1732bbeb2c4c00b9d8e...HEAD`
- `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from `extensions/drm-copilot`
- `npm run lint` from `extensions/drm-copilot`
- `npm run typecheck` from `extensions/drm-copilot`
- `npm run test:unit` from `extensions/drm-copilot`

## Do Not Do

- Do not modify issue #285 implementation files unless a validator proves a direct issue #285 regression.
- Do not weaken `validate_evidence_locations.py`.
- Do not move evidence into `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`, or another non-canonical path.
- Do not mark remediation complete until `python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 or a policy-approved disposition is documented.
- Do not silently skip coverage, TypeScript checks, or review artifact validation.
