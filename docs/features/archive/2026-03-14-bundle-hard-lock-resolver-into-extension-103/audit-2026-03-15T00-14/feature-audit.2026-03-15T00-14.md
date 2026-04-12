# Feature Audit — bundle-hard-lock-resolver-into-extension (#103)

## Scope and baseline

- **Base branch:** development
- **Feature folder:** `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/`
- **Feature folder selection rule:** Used the active folder supplied by the user; it matches the issue suffix `-103` and contains the primary scoping docs for this feature.
- **Evidence sources:**
  - Primary: refreshed `artifacts/pr_context.summary.txt`
  - Secondary: refreshed `artifacts/pr_context.appendix.txt`
  - Supplemental: live workspace inspection and review-time verification commands
- **Important baseline note:** the refreshed PR context summary resolved an empty commit range because the feature currently exists as working-tree changes. For this audit, the appendix working-tree diff and on-disk files were used as the effective baseline diff evidence.
- **Work mode marker:** `issue.md` contains `- Work Mode: full-feature`, so the authoritative acceptance-criteria source files are `spec.md` and `user-story.md`.

## Acceptance criteria inventory (authoritative)

Authoritative checkbox acceptance criteria come from `user-story.md`. `spec.md` provides supporting behavior detail and definition-of-done evidence, but its acceptance criteria are prose rather than checkbox items.

1. `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.resolveExecuteHardLockPrompt`, and `extensions/drm-copilot/src/extension.ts` registers a matching handler that reuses an active feature-plan editor when possible or otherwise prompts from `docs/features/active/`, then passes `--target <selected-plan>` and `--workspace <workspace-root>` to the bundled wrapper.
2. `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` remains a thin wrapper that only bootstraps `resources/scripts` onto `sys.path`, injects `--template-root` pointing at bundled codex assets when absent, imports `dev_tools.resolve_hard_lock_prompt`, and delegates to its `main()` function without duplicating prompt-resolution logic.
3. The extension package includes synchronized bundled copies of `scripts/dev_tools/resolve_hard_lock_prompt.py`, `.github/codex/execute-hard-lock.prompt.md`, and `.github/codex/resume-hard-lock.prompt.md` under the existing extension resource layout so prompt resolution works in workspaces that do not contain repo-local `.github/codex` assets.
4. `scripts/dev_tools/resolve_hard_lock_prompt.py` adds an optional `--template-root` seam that checks the supplied template root first, then falls back to `<workspace>/.github/codex`, while preserving existing `--template-kind`, plan-path normalization, work-mode lookup, fallback-reason substitution, stdout output, and best-effort clipboard behavior.
5. The extension command produces the same resolved execute prompt content as the root Python resolver for the same target plan, including forward-slash `${plan-path}` output and deterministic work-mode behavior for versioned plan folders such as `v2`.
6. Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1 | PASS | `extensions/drm-copilot/package.json` contributes the command; `extension.ts` registers it and passes `--target` / `--workspace`; Jest file covers registration, active editor reuse, picker fallback, and argv wiring. | `npm --prefix extensions/drm-copilot run test:unit` | Command contribution and wiring are present and tested. |
| 2 | PASS | Wrapper file is 47 lines, prepends `resources/scripts`, injects `--template-root`, imports `dev_tools.resolve_hard_lock_prompt`, and contains no prompt interpolation logic. Python wrapper tests cover injection and explicit-template-root preservation. | `poetry run pytest` | Architecturally thin as intended. |
| 3 | PASS | Bundled resolver and both prompt templates exist under extension resources; README/spec align with the bundled layout; Python tests cover bundled-template preference and fallback behavior. | `poetry run pytest` | Resource packaging contract is present and tested. |
| 4 | PASS | Root resolver adds `--template-root`, `_resolve_template_path`, checked-location error reporting, and preserves existing prompt substitution and best-effort clipboard behavior. Coverage artifact reports 97% coverage on the root resolver. | `poetry run pytest` | Additive seam implemented without breaking root behavior in current tests. |
| 5 | PASS | Root and bundled resolver tests cover forward-slash path normalization and parent `issue.md` lookup for versioned folders like `v2`; coverage and test runs are green. | `poetry run pytest`; `npm --prefix extensions/drm-copilot run test:unit` | Deterministic plan-path/work-mode behavior is evidenced in both root and bundled test suites. |
| 6 | FAIL | Direct review probe of the bundled wrapper against a missing target printed `Error: Target file not found ...` but exited with `WRAPPER_EXIT=0`. The wrapper code calls delegated `module.main` then always `return 0`, so the extension runtime cannot distinguish success from failure. | `python extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py --target <missing-target> --workspace <feature-folder>` | This violates the explicit acceptance criterion and creates misleading success behavior on real failures. |

## Summary

- **Overall feature readiness:** NEEDS REVISION
- **Top gap preventing PASS:** the bundled wrapper does not propagate non-zero failure status from the resolver, so the extension can show success on missing-target or missing-template failures.
- **Additional gap:** `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` exceeds the repo's 500-line file limit and should be split during remediation.
- **Recommended follow-up verification after remediation:** rerun the full Python loop, the extension loop, JSON validation, and the targeted missing-target wrapper probe to confirm non-zero exit behavior.

## Acceptance criteria check-off

- Updated `user-story.md` to leave the failed criterion unchecked.
- No new items were checked off during this review; one previously checked item was reverted because verification did not support PASS.
- `spec.md` acceptance criteria are prose, so they were evaluated here but not rewritten.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/spec.md`, `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/user-story.md`
- Total AC items: 6
- Checked off (delivered): 5
- Remaining (unchecked): 1
- Items remaining:
  - `Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.`
