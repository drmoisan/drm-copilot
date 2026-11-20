# Feature Audit — bundle-hard-lock-resolver-into-extension (#103)

## Scope and baseline

- **Base branch:** `development`
- **Feature folder:** `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/`
- **Feature folder selection rule:** Used the active folder specified by the user; it matches issue suffix `-103` and contains the primary scoping docs.
- **Evidence sources:**
  - Primary: refreshed `artifacts/pr_context.summary.txt`
  - Secondary: refreshed `artifacts/pr_context.appendix.txt`
  - Supplemental: live workspace inspection plus fresh verification commands from this review
- **Baseline note:** the refreshed PR context shows `HEAD == origin/development` at `811bd5cf221fc8d97de2be71d41ece26698db8c9`, so the commit range is empty. For this audit, the appendix working-tree diff and current on-disk files are the effective baseline evidence.
- **Work mode marker:** `issue.md` contains `- Work Mode: full-feature`, so the authoritative acceptance-criteria sources are `spec.md` and `user-story.md`.

## Acceptance criteria inventory (authoritative)

Authoritative checkbox acceptance criteria come from `user-story.md`; `spec.md` provides supporting behavior detail and definition-of-done evidence.

1. `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.resolveExecuteHardLockPrompt`, and `extensions/drm-copilot/src/extension.ts` registers a matching handler that reuses an active feature-plan editor when possible or otherwise prompts from `docs/features/active/`, then passes `--target <selected-plan>` and `--workspace <workspace-root>` to the bundled wrapper.
2. `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` remains a thin wrapper that only bootstraps `resources/scripts` onto `sys.path`, injects `--template-root` pointing at bundled codex assets when absent, imports `dev_tools.resolve_hard_lock_prompt`, and delegates to its `main()` function without duplicating prompt-resolution logic.
3. The extension package includes synchronized bundled copies of `scripts/dev_tools/resolve_hard_lock_prompt.py`, `.github/codex/execute-hard-lock.prompt.md`, and `.github/codex/resume-hard-lock.prompt.md` under the existing extension resource layout so prompt resolution works in workspaces that do not contain repo-local `.github/codex` assets.
4. `scripts/dev_tools/resolve_hard_lock_prompt.py` adds an optional `--template-root` seam that checks the supplied template root first, then falls back to `<workspace>/.github/codex`, while preserving existing `--template-kind`, plan-path normalization, work-mode lookup, fallback-reason substitution, stdout output, and best-effort clipboard behavior.
5. The extension command produces the same resolved execute prompt content as the root Python resolver for the same target plan, including forward-slash `${plan-path}` output and deterministic work-mode behavior for versioned plan folders such as `v2`.
6. Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1 | PASS | `extensions/drm-copilot/package.json` contributes the command; `extensions/drm-copilot/src/extension.ts` registers it and passes `--target` / `--workspace`; extension Jest covers registration, active-editor reuse, picker fallback, and argv wiring. | `npm --prefix extensions/drm-copilot run test:unit` | Command contribution and wiring are present and verified. |
| 2 | PASS | The wrapper remains thin and adapter-only: it prepends bundled scripts, injects `--template-root` when absent, imports `dev_tools.resolve_hard_lock_prompt`, and delegates directly to `main()`. | `poetry run pytest` | The wrapper now also preserves delegated exit status without adding business logic. |
| 3 | PASS | Bundled resolver and both prompt templates exist under extension resources; the README documents the command; Python tests cover bundled-template preference and fallback behavior. | `poetry run pytest` | Works for workspaces without repo-local `.github/codex` assets. |
| 4 | PASS | Root resolver adds `--template-root`, deterministic lookup order, checked-location error reporting, forward-slash plan-path substitution, versioned-folder work-mode lookup, and best-effort clipboard behavior. | `poetry run pytest`; `shell: QC: 4 Pytest: run tests with coverage` | Fresh Python coverage remains `97%` for the root resolver. |
| 5 | PASS | Root and bundled tests cover forward-slash Windows path normalization and parent `issue.md` lookup for versioned folders such as `v2`; extension tests verify command wiring. | `poetry run pytest`; `npm --prefix extensions/drm-copilot run test:unit` | Prompt-content parity behavior is evidenced across the resolver stack. |
| 6 | PASS | Missing-runtime behavior is covered in `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`; missing-target and missing-template failures are covered in the split Python wrapper tests; direct subprocess probe printed a clear missing-target error and exited with `WRAPPER_EXIT=1`. | `npm --prefix extensions/drm-copilot run test:unit`; `poetry run pytest`; `python extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py --target <missing-target> --workspace <feature-folder>` | This was the previously failed acceptance criterion and is now verified. |

## Summary

- **Overall feature readiness:** PASS
- **Top gaps preventing PASS:** None.
- **Recommended follow-up verification:** Normal CI is sufficient; no special remediation verification remains.

## Acceptance criteria check-off

- Updated `user-story.md` to check off the final verified criterion for clear failure behavior.
- `spec.md` acceptance criteria remain prose and were evaluated here without reformatting.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/spec.md`, `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/user-story.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Final assessment

This feature passes its acceptance criteria in the current post-remediation workspace state and is ready to open or merge as a PR into `development`.
