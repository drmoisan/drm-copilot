# Remediation Inputs — push-down-copilot-customizations review follow-ups

Timestamp: 2026-03-11T07-42
Feature Folder: `docs/features/active/2026-03-09-push-down-copilot-customizations-84`
Source Reviews:
- `policy-audit.2026-03-11T07-42.md`
- `code-review.2026-03-11T07-42.md`
- `feature-audit.2026-03-11T07-42.md`

## Required Fixes

1. **Reduce `extensions/drm-copilot/src/extension.ts` to policy-compliant size**
   - **Files / locations:**
     - `extensions/drm-copilot/src/extension.ts` (whole file; live line count `585`)
     - Current concentration points include runtime helpers at lines `74-524` and command registration at lines `528-639`.
   - **Expected behavior:**
     - Keep all current command behavior unchanged.
     - Move reusable helper logic out of `extension.ts` so the touched file is `<= 500` lines.
     - Preserve command IDs, output channel behavior, branch discovery behavior, placeholder behavior, and bundled execution behavior.
   - **Acceptance criteria for remediation:**
     - `Get-Content extensions/drm-copilot/src/extension.ts | Measure-Object -Line` reports `<= 500`.
     - Existing Jest assertions for registration, bundled execution, PR-context flow, and placeholder failures still pass.
   - **Verification commands:**
     - `Get-Content extensions/drm-copilot/src/extension.ts | Measure-Object -Line`
     - `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
     - `npm --prefix extensions/drm-copilot run lint`
     - `npm --prefix extensions/drm-copilot run typecheck`
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text`

2. **Replace the untyped `Any` boundary in the bundled Python wrapper**
   - **Files / locations:**
     - `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py`
     - Exact evidence points: line `31` (`from typing import Any`) and line `77` (`publisher_module: Any = importlib.import_module(...)`).
   - **Expected behavior:**
     - Preserve the wrapper’s runtime behavior and CLI contract.
     - Remove `Any` by introducing a typed protocol / adapter / cast that describes the imported publisher surface precisely enough for Pyright.
     - Do not add `# type: ignore` or `# noqa` suppressions to get around the typing issue.
   - **Acceptance criteria for remediation:**
     - The wrapper file contains no `Any` import or `publisher_module: Any` assignment.
     - The wrapper still resolves `resources/scripts`, `resources/customizations`, `artifact_root`, and `--destination` exactly as before.
     - `poetry run pyright` remains clean.
   - **Verification commands:**
     - `poetry run pyright`
     - `poetry run black --check .`
     - `poetry run ruff check`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

3. **Correct README drift so docs match the actual extension surface**
   - **Files / locations:**
     - `extensions/drm-copilot/README.md`
     - Stale lines identified in review: `1`, `25`, `53`, `72`, `74`.
   - **Expected behavior:**
     - Replace stale `Scaffold Extension` branding with current `drm-copilot` naming.
     - Replace stale `Scaffold: Collect Commit Context` text with the actual command label from `package.json`.
     - Replace stale `Scaffold Utils` output-channel references with the actual output channel name used by `createOutputChannel()`.
   - **Acceptance criteria for remediation:**
     - README heading and command references match `extensions/drm-copilot/package.json` and `extensions/drm-copilot/src/extension.ts`.
     - README no longer contains `Scaffold Extension` or `Scaffold Utils`.
   - **Verification commands:**
     - `Select-String -Path extensions/drm-copilot/README.md -Pattern 'Scaffold Extension|Scaffold Utils'`
     - `Select-String -Path extensions/drm-copilot/README.md -Pattern 'drm-copilot: Collect Commit Context|drmCopilotExtension.collectPrContext|drmCopilotExtension.pushDownCopilotCustomizations'`

## Do Not Do

- Do **not** change public command IDs or user-visible behavior beyond correcting documentation labels.
- Do **not** weaken typing with new `Any`, `@ts-ignore`, `@ts-expect-error`, `# noqa`, or `# type: ignore` suppressions.
- Do **not** expand scope into unrelated feature work, new commands, or broader refactors outside what is needed to close the review findings.
- Do **not** remove or dilute existing tests to make the policy issues disappear.
- Do **not** weaken the repo’s 500-line policy by documenting it away; fix the structure instead.

## Acceptance-Criteria Status

All feature acceptance criteria are currently met. The minimum remediation scope is therefore limited to **policy and review follow-ups**, not feature-behavior changes.

## Minimum Change Set Required to Close Review

- Extract enough code from `extensions/drm-copilot/src/extension.ts` to bring that touched file to `<= 500` lines.
- Remove the bundled-wrapper `Any` usage by introducing a typed import boundary.
- Update `extensions/drm-copilot/README.md` so naming and output-channel docs reflect the shipped extension.
