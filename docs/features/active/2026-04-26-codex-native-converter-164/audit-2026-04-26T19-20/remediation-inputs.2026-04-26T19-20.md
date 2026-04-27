# Remediation Inputs: codex-native-converter (#164)

**Generated:** 2026-04-26T19-20
**Source audit:** `policy-audit.2026-04-26T19-20.md`, `code-review.2026-04-26T19-20.md`, `feature-audit.2026-04-26T19-20.md`
**Scope:** Feature-vs-base remediation for working-tree branch `feature/codex-native-converter-164` against explicit base `origin/development` @ `0762f58a1451994999c2f49f2dbdc489120d138a`

## Trigger Summary

Remediation is triggered by the following verified policy findings:

- File-size policy violation: `extensions/drm-copilot/src/extension.ts` is 751 lines at the reviewed head, exceeds the 500-line production-file limit, and grew from 622 lines on `origin/development`.
- File-size policy violation: `extensions/drm-copilot/src/repo-automation-service.ts` is 585 lines at the reviewed head, exceeds the 500-line production-file limit, and grew from 515 lines on `origin/development`.
- Review-scope note: `artifacts/pr_context.summary.txt` is current but empty because the base and head commit SHAs match. This is not a separate code defect, but the next review run must continue using `artifacts/pr_context.appendix.txt` plus feature evidence as the authoritative diff basis until the branch has a non-empty commit range.

All nine acceptance criteria from `user-story.md` are PASS. This remediation does not reopen delivered feature behavior; it addresses structural policy findings required for a merge-ready branch.

## Fix List (Authoritative)

### R-1 (Major): Reduce `extensions/drm-copilot/src/extension.ts` to 500 lines or fewer

- **Current state:** 751 lines at the reviewed head; 622 lines on `origin/development`.
- **Expected behavior:** Public command registrations remain unchanged, including `drmCopilotExtension.runCodexNativeConverter`.
- **Implementation direction:** Extract converter-specific prompting, command registration, or adjacent repo-automation helpers into focused modules so `extension.ts` becomes a thin activation and registration coordinator.
- **Verification commands:**
  - `npm --prefix extensions/drm-copilot run format`
  - `npm --prefix extensions/drm-copilot run lint`
  - `npm --prefix extensions/drm-copilot run typecheck`
  - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
  - `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/extension.ts' | Measure-Object -Line).Lines"`
- **Acceptance:** `extension.ts` is `<= 500` lines and all TypeScript QA gates remain green.

### R-2 (Major): Reduce `extensions/drm-copilot/src/repo-automation-service.ts` to 500 lines or fewer

- **Current state:** 585 lines at the reviewed head; 515 lines on `origin/development`.
- **Expected behavior:** `RunCodexNativeConverterInput`, `runCodexNativeConverter`, and the existing repo-automation service contract remain stable for callers.
- **Implementation direction:** Move converter-specific argument assembly, output parsing, or adjacent execution-helper logic into focused helper modules so the service remains a thin orchestration boundary.
- **Verification commands:**
  - `npm --prefix extensions/drm-copilot run format`
  - `npm --prefix extensions/drm-copilot run lint`
  - `npm --prefix extensions/drm-copilot run typecheck`
  - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
  - `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`
- **Acceptance:** `repo-automation-service.ts` is `<= 500` lines and the converter wrapper tests still pass.

### R-3 (Info): Preserve working-tree review basis in the rerun

- **Current state:** `artifacts/pr_context.summary.txt` shows base and head at the same commit SHA; `artifacts/pr_context.appendix.txt` contains the actual staged and unstaged feature diff.
- **Expected behavior:** The remediation rerun uses the appendix and feature evidence as the primary diff basis unless new commits produce a non-empty PR context range.
- **Verification commands:**
  - `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <updated-policy-audit-path>`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review <updated-code-review-path>`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit <updated-feature-audit-path>`
- **Acceptance:** The rerun review artifacts explicitly state whether the scope came from a commit range or the working-tree appendix.

## Do-Not-Do List

- Do not broaden the remediation into new converter features or new supported ecosystems.
- Do not change the authoritative Python-first architecture; the TypeScript layer should remain a thin wrapper.
- Do not modify `.github/instructions/*.md` policy files as part of this remediation.
- Do not weaken the repository’s 500-line production-file limit in order to accommodate the current file sizes.
- Do not drop existing command IDs, MCP tool names, or converter input schema fields while splitting files.

## Suggested Phase Skeleton (for remediation planning)

- **Phase 0 — Baseline capture:** Record current line counts for `extension.ts` and `repo-automation-service.ts`, capture the current PR-context status, and link the existing final TypeScript QA artifacts.
- **Phase 1 — `extension.ts` split:** Extract converter-related registration or prompt helpers into smaller modules and capture a post-change line-count artifact.
- **Phase 2 — `repo-automation-service.ts` split:** Extract converter-specific helper logic into focused modules and capture a post-change line-count artifact.
- **Phase 3 — TypeScript final QA:** Run format, lint, type-check, and unit tests with coverage; record the artifact paths.
- **Phase 4 — Review rerun:** Refresh PR context if needed, regenerate `policy-audit`, `code-review`, and `feature-audit`, and confirm the file-size findings are resolved.

## Context Package

- `docs/features/active/2026-04-26-codex-native-converter-164/policy-audit.2026-04-26T19-20.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/code-review.2026-04-26T19-20.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/feature-audit.2026-04-26T19-20.md`
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-format.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-lint.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-typecheck.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-test-coverage.md`

## Handoff

The remediation-plan target path for this branch is:

- `docs/features/active/2026-04-26-codex-native-converter-164/remediation-plan.2026-04-26T19-20.md`

This review session generated that plan directly in the same feature folder so the remediation handoff remains complete even without a separate planner delegation step.