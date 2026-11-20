# Feature Audit — extension-template-resolution (#93)

## Scope and baseline

- **Base branch:** `origin/feature/expose-placeholder-commands-92`
- **Head branch:** `bug/extension-template-resolution-93`
- **Primary evidence source:** `artifacts/pr_context.summary.txt`
- **Baseline diff source:** `artifacts/pr_context.appendix.txt`
- **Feature folder used:** `docs/features/active/2026-03-12-extension-template-resolution-93/`
- **Feature folder selection rule:** Selected this folder because it is the active feature folder referenced by PR context and its suffix matches issue `#93`.
- **Work mode:** `minor-audit`
- **Authoritative AC source:** `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md` only

## Acceptance criteria inventory (authoritative)

Extracted from `issue.md` → `## Proposed Fix / Validation Ideas`:

1. Bundle template markdown files in `resources/feature-templates/`.
2. Each script resolves templates from bundled resources (via `--template-root` or relative to bundled files) with workspace fallback.
3. Unit tests verify template resolution from both bundled and workspace paths.
4. Integration test: run `new-potential-entry` in a workspace without `docs/features/templates/` and succeed using bundled templates.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Bundle template markdown files in `resources/feature-templates/`. | PASS | New bundled tree exists under `extensions/drm-copilot/resources/feature-templates/` with bug, epic, feature, potential, and refactor templates. | Static file inspection from `artifacts/pr_context.appendix.txt`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | The bundle location matches the issue wording. |
| 2. Each script resolves templates from bundled resources with workspace fallback. | PASS | `extensions/drm-copilot/src/extension.ts` now passes `--template-root` / `-TemplateRoot`; Python and PowerShell scripts resolve bundled roots first and preserve workspace fallback. | `npm --prefix extensions/drm-copilot run typecheck`; `poetry run pyright`; `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | Fresh QA runs passed on 2026-03-13. |
| 3. Unit tests verify template resolution from both bundled and workspace paths. | PASS | `extensions/drm-copilot/test/extension.test.ts`, `tests/scripts/dev_tools/test_new_potential_bug_entry.py`, and `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` include bundled-template and fallback assertions. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage`; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Coverage delta file records Python `90.75%` and TypeScript `90.72%` changed-code coverage. |
| 4. Integration test: run `new-potential-entry` in a workspace without `docs/features/templates/` and succeed using bundled templates. | FAIL | `issue.md` still leaves this item unchecked. `extensions/drm-copilot/test/extension.integration.test.ts` has no `newPotentialEntry` runtime scenario, and `extension.test.ts` only proves argument injection. | Search in `extensions/drm-copilot/test/**/*.ts` for `newPotentialEntry|TemplateRoot|integration`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | This is the remaining delivery gap for the feature. |

## Summary

**Overall feature readiness:** **NEEDS REVISION**

The branch delivers the bundled-template implementation and supporting unit coverage, and fresh Python/TypeScript/PowerShell QA passes all succeeded. However, the feature is not complete relative to its own minor-audit acceptance checklist because the integration scenario in criterion 4 is still missing.

### Top gaps preventing PASS

1. No automated integration verification for `newPotentialEntry` in a template-less workspace.
2. The acceptance source file already records the gap by leaving criterion 4 unchecked.

### Recommended follow-up verification

- Add an integration test in the extension Jest suite that exercises `drmCopilotExtension.newPotentialEntry` against a workspace fixture without `docs/features/templates/` and asserts creation succeeds through the bundled template path.
- Re-run:
  - `npm --prefix extensions/drm-copilot run format`
  - `npm --prefix extensions/drm-copilot run lint`
  - `npm --prefix extensions/drm-copilot run typecheck`
  - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

## Acceptance criteria check-off

No checkbox edits were required during this audit. `issue.md` already reflects the current verified state: criteria 1-3 are checked `[x]`, and criterion 4 remains unchecked `[ ]`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`
- Total AC items: 4
- Checked off (delivered): 3
- Remaining (unchecked): 1
- Items remaining:
  - `Integration test: run new-potential-entry in workspace without docs/features/templates/ → should succeed using bundled templates`
