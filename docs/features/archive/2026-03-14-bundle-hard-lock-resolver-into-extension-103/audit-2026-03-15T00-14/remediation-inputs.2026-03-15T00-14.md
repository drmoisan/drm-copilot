# Remediation Inputs — bundle-hard-lock-resolver-into-extension (#103)

**Generated from review artifacts:**
- `policy-audit.2026-03-15T00-14.md`
- `code-review.2026-03-15T00-14.md`
- `feature-audit.2026-03-15T00-14.md`

## Required fixes

1. **Propagate bundled resolver exit status through the wrapper**
   - **Files:**
     - `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`
   - **Location:** around the delegated `module.main` call (`:58-60` in the reviewed file)
   - **Expected behavior:** when the delegated bundled resolver returns a non-zero exit code for missing target/template errors, the wrapper process must also exit non-zero so `executeBundledScript()` reports command failure instead of success.
   - **Acceptance criteria:** user-story criterion 6 (`Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.`)
   - **Verification commands:**
     - `python extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py --target <missing-target> --workspace <feature-folder>`
     - `poetry run pytest`
     - `npm --prefix extensions/drm-copilot run test:unit`

2. **Add a regression test for wrapper failure propagation**
   - **Files:**
     - `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` (or split successor files)
     - optionally `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` if an extension-level assertion is added
   - **Location:** new focused test case near existing wrapper error-path coverage
   - **Expected behavior:** at least one automated test must prove that a failing delegated resolver causes the wrapper to exit non-zero (or, equivalently, that the extension sees the command as failed).
   - **Acceptance criteria:** user-story criterion 6
   - **Verification commands:**
     - `poetry run pytest`
     - `npm --prefix extensions/drm-copilot run test:unit`

3. **Split the oversized Python wrapper test module below the repo limit**
   - **Files:**
     - `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py`
     - new successor test files as needed (for example `...part2.py`)
   - **Location:** whole file (current review measured 536 lines)
   - **Expected behavior:** every production, test, and reusable-script file in scope must be under 500 lines, while preserving current coverage and readability.
   - **Acceptance criteria:** repo general code change policy file-size rule
   - **Verification commands:**
     - `poetry run pytest`
     - line-count check for the split files

## Do not do

- Do **not** weaken policy requirements or mark the failed acceptance criterion as complete without fresh verification.
- Do **not** move prompt-resolution business logic into TypeScript or expand the wrapper beyond bootstrapping/delegation.
- Do **not** introduce scope creep such as a new resume command or packaging-system redesign.
- Do **not** suppress failing behavior silently; preserve clear stderr output and make the process exit status truthful.

## Unmet acceptance criteria and minimum changes

### Still unmet

- `Missing target files, missing Python runtime, or missing bundled template assets fail with clear errors and do not produce partial or misleading success output.`

### Minimum changes required to meet it

1. Return the delegated resolver's exit code from the wrapper instead of always returning `0`.
2. Add a regression test that fails if the wrapper ever masks non-zero delegated exit codes again.
3. Re-run the Python loop, extension loop, JSON validation, and targeted missing-target wrapper probe; only then re-check the user-story criterion.
