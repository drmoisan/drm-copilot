# dependabot-bumps-types-vscode-past-engines

- Work Mode: minor-audit
- Issue: #940
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/940

## Problem / Why

Every weekly Dependabot npm group PR fails CI. The grouped update bumps `@types/vscode` above `engines.vscode` in `extensions/drm-copilot/package.json`, and `vsce package` rejects the manifest, which fails the "Publish to Marketplace" job. Observed on PR #833 (run 38311531357), PR #832, and earlier PRs #827 and #828. The error is:

`@types/vscode ^1.140.0 greater than engines.vscode ^1.138.0`

`@types/vscode` versions track VS Code minor releases, so each grouped update can exceed the declared engine floor. The root `package.json` shows the same drift class (`@types/vscode` `^1.138.0` against `engines.vscode` `^1.118.0`), although `vsce package` runs only in `extensions/drm-copilot`.

## Implementation Intent

1. Edit `.github/dependabot.yml`: add an `ignore` item `- dependency-name: "@types/vscode"` (no `update-types` and no `versions` key, so all update types are ignored) to the npm entry for directory `/` and to the npm entry for directory `/extensions/drm-copilot`. Retain each entry's existing `typescript` major-version ignore.
2. Add a pytest contract module `tests/scripts/dev_tools/test_dependabot_config_contract.py` that parses the real `.github/dependabot.yml` with `yaml.safe_load` (no temporary files), asserts both npm entries ignore `@types/vscode` for all update types, and asserts exactly two entries were checked (non-vacuity). Follow the pattern in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`.

Out of scope:
- Reconciling the root `package.json` `engines.vscode` value. The root ignore entry only prevents Dependabot from widening the gap.
- `packages/mcp-server`. Its `package.json` has no `vscode` reference, and its Dependabot entry is not changed.
- The github-actions Dependabot entry, workflows (including `publish-extension.yml`), and bundled resources.

## Acceptance Criteria

- [x] AC-1: In `.github/dependabot.yml`, the npm entry for directory `/` has an `ignore` item `dependency-name: "@types/vscode"` with no `update-types` or `versions` key, and its existing `typescript` major-version ignore is retained.
- [x] AC-2: In `.github/dependabot.yml`, the npm entry for directory `/extensions/drm-copilot` has the same `@types/vscode` ignore item (no `update-types` or `versions` key), and its existing `typescript` major-version ignore is retained.
- [x] AC-3: The `/packages/mcp-server` npm entry and the github-actions entry in `.github/dependabot.yml` are unchanged (verified by diff against the pre-change file).
- [x] AC-4: A new pytest module at `tests/scripts/dev_tools/test_dependabot_config_contract.py` parses the real `.github/dependabot.yml` with `yaml.safe_load` (no temporary files), asserts both npm entries (`/` and `/extensions/drm-copilot`) ignore `@types/vscode` for all update types, and asserts exactly two entries were checked.
- [x] AC-5: The new test fails against the pre-change `.github/dependabot.yml` and passes after the change, with red/green evidence recorded in the feature evidence folder.
- [x] AC-6: `poetry run black --check`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest` pass for the new test file, and the full `poetry run pytest` suite passes with the line (85%) and branch (75%) coverage gates unchanged.

## Dependencies / Risks

- PyYAML is an approved dependency (`pyproject.toml`, `PyYAML = ">=6.0"`). No `types-pyyaml` stub is present, so the test uses `yaml.safe_load` with `typing.cast`.
- No parity test, bundled copy, or workflow references `.github/dependabot.yml`; no other file is expected to change.
- The "Publish to Marketplace" workflow is path-filtered to `extensions/drm-copilot/**` and the workflow file, so it does not run on this change's PR.
- Residual risk: the runtime semantics of a bare `dependency-name` ignore within a Dependabot group were not confirmed from the fetched GitHub documentation. The in-repo test asserts configuration shape only and cannot simulate Dependabot.
- Post-merge note (not an acceptance criterion): Dependabot reads configuration from the default branch. After merge to `main`, comment `@dependabot recreate` on PRs #832 and #833 (recreate rather than close, because they may carry other updates) and confirm the regenerated PRs omit `@types/vscode`. This is the empirical check of the ignore-within-group behavior.

## Verification Steps

1. Baseline: run `poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py` before editing `dependabot.yml` (after adding the test) and record the failure (AC-5).
2. Edit `.github/dependabot.yml` per Implementation Intent; confirm by diff that only the two npm ignore lists changed (AC-1 to AC-3).
3. Run, from the repository root:
   - `poetry run black --check tests/scripts/dev_tools/test_dependabot_config_contract.py`
   - `poetry run ruff check tests/scripts/dev_tools/test_dependabot_config_contract.py`
   - `poetry run pyright tests/scripts/dev_tools/test_dependabot_config_contract.py`
   - `poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py`
4. Run the full `poetry run pytest` suite with coverage and confirm the thresholds pass (AC-6).
5. After merge, perform the post-merge `@dependabot recreate` check described under Dependencies / Risks.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
