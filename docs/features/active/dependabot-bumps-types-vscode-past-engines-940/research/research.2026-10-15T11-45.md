# Research: Dependabot `@types/vscode` ignore (issue #940)

Date: 2026-10-15. All findings below were verified by reading the current tree with file tools.

## 1. `.github/dependabot.yml` and edit locations

The file is 73 lines (`.github/dependabot.yml`). Four `updates` entries:

| Lines | Ecosystem / directory | Existing `ignore` |
|---|---|---|
| 5-21 | npm `/` (group `npm-root`, `patterns: ["*"]`) | lines 15-17: `typescript`, `update-types: ["version-update:semver-major"]` |
| 24-40 | npm `/extensions/drm-copilot` (group `npm-extensions-drm-copilot`) | lines 34-36: same `typescript` entry |
| 43-56 | npm `/packages/mcp-server` (group `npm-mcp-server`) | none |
| 59-73 | github-actions `/` | none |

Edit locations: append a new list item after line 17 (root entry) and after line 36 (extension entry), at 6-space indentation matching the existing item:

```yaml
      - dependency-name: "@types/vscode"
```

`packages/mcp-server` needs no change. `packages/mcp-server/package.json` contains zero occurrences of `vscode` (grep count 0), so it neither depends on `@types/vscode` nor declares `engines.vscode`. The github-actions entry is unrelated.

## 2. Where `@types/vscode` and `engines.vscode` are declared

- Root `package.json`: `engines.vscode` = `^1.118.0` (line 8); devDependency `@types/vscode` = `^1.138.0` (line 45).
- `extensions/drm-copilot/package.json`: `engines.vscode` = `^1.138.0` (line 30); devDependency `@types/vscode` = `^1.138.0` (line 236).
- No other `package.json` in the repo matches (repo-wide grep of `"vscode":` / `"@types/vscode":` in `**/package.json`).

Observation: the root manifest already has `@types/vscode` (1.138) above `engines.vscode` (1.118). `vsce package` is run only in `extensions/drm-copilot` (`.github/workflows/publish-extension.yml` lines 58-60), so the root mismatch does not break the Publish check, but it is the same drift class. Making the root ignore entry covers the root so Dependabot cannot widen the gap. Reconciling the root `engines.vscode` value is outside the stated intended fix and is not recommended in this plan.

## 3. Mirrored or bundled copies; parity tests

- `Glob **/dependabot.y*ml` returns only `.github/dependabot.yml`. There is no bundled or push-down copy under `extensions/drm-copilot/resources/`.
- Repo-wide case-insensitive grep for "dependabot" (excluding node_modules and archive) lists docs, completed feature folders, and these non-doc files only:
  - `extensions/drm-copilot/resources/customizations/.github/instructions/github-actions-ci-cd-best-practices.instructions.md` line 100 and `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` (prose mention: "Use `dependabot` for action version updates"). Not a copy of the config.
  - `tests/scripts/dev_tools/npm_token_guard_test_support.py` line 170 (a comment noting dependabot config may use `.yml`/`.yaml`; the helper `enumerate_github_yaml_files` scans all `.github/` YAML for NPM token routes). That scan will include the edited file; the new entries contain no token text, so no effect.
- No parity test references `dependabot.yml`. No other file needs to change alongside it.
- Existing test `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (lines 323-375) enumerates `.github/` YAML; unaffected.

## 4. Dependabot `ignore` semantics

Fetched the GitHub options reference (`docs.github.com/.../dependabot-options-reference`). It describes `dependency-name` as "Ignore updates for dependencies with matching names, optionally using `*`". The fetched text (first 100000 of ~182000 characters) does not explicitly state the no-`versions`/no-`update-types` case, and does not describe `ignore` x `groups` interaction. Therefore the following are not verified from the fetched text:

- A bare `dependency-name` entry ignoring all updates is the widely documented behavior (the `versions` and `update-types` keys are the narrowing options) but was inferred here, not quoted.
- Ignored dependencies being excluded before group membership is evaluated is likewise not confirmed from the fetched portion.

The remaining ~82000 characters were not read. The plan should treat real-world confirmation as the post-merge `@dependabot recreate` check (section 8), not as a pre-merge acceptance criterion. The in-repo test can only assert config shape, not Dependabot runtime behavior.

## 5. Test language and location

- PyYAML is an approved dependency: `pyproject.toml` line 19 `PyYAML = ">=6.0"` (main dependencies); `poetry.lock` line 2724-2725 pins `pyyaml` 6.0.3. No `types-pyyaml` stub appears in the lock (`name = "types-pyyaml"` not matched), so tests use `yaml.safe_load` and `typing.cast`.
- Precedent for parsing real `.github/**/*.yml`:
  - `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` lines 15-48: `import yaml`, `REPO_ROOT = Path(__file__).resolve().parents[3]`, `WORKFLOW_PATH = ".github/workflows/_quality-checks.yml"`, `read_repo_text()`, and a `load_workflow_steps()` helper that isolates `yaml.safe_load` behind `cast("dict[str, object]", ...)`.
  - `tests/scripts/dev_tools/test_parallel_manifest_contract.py` (imports yaml) and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` line 27/161 use the same pattern.
  - Tests that read repo files without temp files are the established convention (module docstring of `test_ci_gate_epic_child_contracts.py`: "reads repository files only: it creates no file").
- Test-location rule: existing tests for `.github/workflows/*.yml` live flat in `tests/scripts/dev_tools/` (for example `test_quality_checks_workflow_contracts.py`, `test_workflow_npm_token_guard.py`), not in a path mirroring `.github/`. Recommended new file: `tests/scripts/dev_tools/test_dependabot_config_contract.py`, following that precedent.
- Test design (no code written here): safe-load `.github/dependabot.yml`; select `updates` entries with `package-ecosystem == "npm"` and `directory` in `{"/", "/extensions/drm-copilot"}`; assert each has an `ignore` item whose `dependency-name == "@types/vscode"` and which has neither `update-types` nor `versions` key; assert exactly two entries were selected (non-vacuity, as in `test_github_yaml_enumeration_is_non_vacuous`); optionally assert the existing `typescript` major-ignore entries are retained. Use `pytest.mark.parametrize` over the two directories. Per-AC failure messages should name the directory.
- CI command (`.github/workflows/_quality-checks.yml` lines 54-92): `poetry run black --check .`, `poetry run ruff check`, `poetry run pyright`, then `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`, then `check_python_coverage_thresholds --min-line 85 --min-branch 75`. `pyproject.toml` line 117 sets `testpaths = ["tests"]`, so the new file is collected automatically.

## 6. Coverage implications

`[tool.coverage.run] source = ["src", "scripts/dev_tools"]` (`pyproject.toml` line 120). The change edits YAML and adds a test under `tests/`; no production executable code changes, so line/branch coverage of production code is unchanged. The global thresholds (85% line, 75% branch) still run in CI and are unaffected. No production file is excluded or added.

Minimal-audit QC commands (Python; run from repo root):
1. `poetry run black --check tests/scripts/dev_tools/test_dependabot_config_contract.py`
2. `poetry run ruff check tests/scripts/dev_tools/test_dependabot_config_contract.py`
3. `poetry run pyright tests/scripts/dev_tools/test_dependabot_config_contract.py`
4. `poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py`

Baseline: run the same pytest command before editing (expect file-not-found/0 tests) or run the neighbor `test_quality_checks_workflow_contracts.py` to show a green baseline. Final: the four commands above, plus a red-then-green demonstration (test fails against the unmodified `dependabot.yml`, passes after edit). Full `poetry run pytest` is the CI step and may be run once at the end. The bundled seven-stage loop's TypeScript/PowerShell stages are not applicable (no TS or PS files changed). Prettier does not format YAML in this repo (`package.json` format globs cover only ts/js/json files).

## 7. Schema validation workflows and the Publish job

- Workflow list: `_build-check`, `_docs-validation`, `_drm-copilot-extension-tests`, `_npm-audit-gate`, `_poshqc`, `_quality-checks`, `_root-typescript-tests`, `_security-scan`, `_shell-coverage`, `ci`, `npm-audit-gate`, `publish-extension`, `publish-mcp-npm`, `verify-published-releases`. Grep for "dependabot" across `.github/workflows` found no workflow referencing or validating `dependabot.yml`; GitHub itself validates the file on push (Dependabot error surface), which is not a repo workflow.
- The "Publish to Marketplace" job (`publish-extension.yml` lines 39-65) runs on `pull_request` paths `extensions/drm-copilot/**` and the workflow file. Editing `.github/dependabot.yml` and adding a test under `tests/` matches neither path, so that workflow will not run on the #940 PR. The job is not changed. Its `npx --yes @vscode/vsce package` step (line 60) is the failure point in the Dependabot PRs; the fix prevents those PRs from being generated rather than altering the job.

## 8. Automation Feasibility

- In scope pre-merge: editing `dependabot.yml` (two entries) and adding the parsing test; both are fully automatable and verifiable locally and in CI.
- Not feasible pre-merge: `@dependabot recreate` on #832/#833. Dependabot reads configuration from the default branch, so the recreate only reflects the fix after merge to `main`. Also, `gh pr comment` on a Dependabot PR is an externally visible action and, in this repo, `gh` write routes may be hook-restricted. A Dependabot run cannot be simulated locally.
- Recommendation: record as a post-merge note (a manual or follow-up step: after merge, comment `@dependabot recreate` on #832 and #833, or close them, and confirm the recreated PRs no longer touch `@types/vscode`). Do not make it an acceptance criterion; the pre-merge acceptance is the config assertion test. Also note the existing Dependabot PRs may carry other updates, so recreate (not close) is appropriate.
- Residual risk: the exact runtime semantics of ignore-within-group were not confirmed from docs (section 4); the post-merge recreate is the empirical check.

## Rejected alternatives

- Pinning `@types/vscode` via `update-types: ["version-update:semver-minor"]`: rejected because `@types/vscode` versions track VS Code minors (1.138.0 style), so ignoring only majors would not prevent the failure, and minors are exactly what breaks `engines.vscode`.
- Excluding `@types/vscode` from groups instead of ignoring it: rejected because it would still produce individual PRs that fail the same check.
- Pester or TypeScript host for the test: rejected; PyYAML is already approved and used for exactly this pattern in Python tests, and CI already runs pytest with `testpaths = ["tests"]`.

## Recommended Acceptance Criteria

- AC-1: In `.github/dependabot.yml`, the npm entry for directory `/` has an `ignore` item `dependency-name: "@types/vscode"` with no `update-types` or `versions` key, and its existing `typescript` major-version ignore is retained.
- AC-2: The npm entry for directory `/extensions/drm-copilot` has the same `@types/vscode` ignore item, and its existing `typescript` ignore is retained.
- AC-3: The `/packages/mcp-server` npm entry and the github-actions entry are unchanged.
- AC-4: A new pytest module at `tests/scripts/dev_tools/test_dependabot_config_contract.py` parses the real `.github/dependabot.yml` with `yaml.safe_load` (no temporary files), asserts both npm entries (`/` and `/extensions/drm-copilot`) ignore `@types/vscode` for all update types, and asserts exactly two entries were checked.
- AC-5: The new test fails against the pre-change `dependabot.yml` and passes after the change (red/green evidence recorded).
- AC-6: `black --check`, `ruff check`, `pyright`, and `pytest` pass for the new test file, and the full `poetry run pytest` suite passes with line/branch coverage gates unchanged.
- Post-merge note (not an AC): comment `@dependabot recreate` on #832 and #833 and confirm the regenerated PRs omit `@types/vscode`.

## Files in scope

- `.github/dependabot.yml` (edit: two ignore entries)
- `tests/scripts/dev_tools/test_dependabot_config_contract.py` (new)
- Feature artifacts under `docs/features/active/dependabot-bumps-types-vscode-past-engines-940/` (plan, evidence)
- Out of scope: `package.json` engines reconciliation, `packages/mcp-server/**`, workflows, bundled resources.
