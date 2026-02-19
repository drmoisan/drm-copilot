# bootstrap-python-ecosystem (Issue #24)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-python-ecosystem/ (Issue #24)

- Issue: #24
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/24
- Last Updated: 2026-02-17
## Problem / Why

New workspaces do not consistently start with the same Python packaging, dependency, linting, type-checking, and test settings used in this repository. That drift creates avoidable setup failures and inconsistent local results across contributors. We need a deterministic bootstrap process that emits a Poetry-based Python project configuration aligned with the repo’s current standards.

## Proposed Behavior

Provide a bootstrap flow that generates Python ecosystem configuration files for a new workspace using requirement templates (not raw file copy).

Required output behavior:
- Generate a `pyproject.toml` using Poetry (`poetry-core` build backend) with canonical project metadata fields (name, version, description, author, license, readme, and package include rules).
- Set Python compatibility to a modern supported range beginning at 3.10 and keep Poetry-managed dependency sections split by purpose:
	- runtime dependencies,
	- optional runtime extras,
	- developer-only dependencies.
- Register CLI entry points for core tooling and developer aliases under Poetry scripts.
- Generate quality tool configuration in `pyproject.toml` for:
	- formatting (Black),
	- linting (Ruff + selected rule families + per-file exceptions),
	- testing (Pytest defaults),
	- coverage (sources, output path, omit rules, report excludes),
	- type checking (Pyright strict workspace settings).
- Generate `poetry.toml` with in-project virtual environment behavior enabled.
- Generate or update workspace editor settings to support Python test workflows:
	- enable Pytest test provider,
	- disable unittest provider,
	- set Pytest discovery path/arguments to the `tests` folder,
	- enable automatic test discovery on save.
- Include optional agent-automation settings for terminal command approval patterns used by Python workflows (`poetry`, `pyright`, `pytest`) when chat-driven execution is enabled.
- Validate generated files for required sections/keys and report missing fields with actionable diagnostics.

## Acceptance Criteria (early draft)

- [ ] Bootstrap creates `pyproject.toml` and `poetry.toml` in an empty target workspace from structured requirements (not direct file copy).
- [ ] Generated `pyproject.toml` contains build-system + Poetry metadata + package include configuration required to package the workspace’s intended Python module(s).
- [ ] Generated `pyproject.toml` defines runtime dependencies, optional runtime dependencies, and dev dependencies in separate groups.
- [ ] Generated `pyproject.toml` defines Poetry script entry points for the repository’s core dev-tool commands and aliases.
- [ ] Generated `pyproject.toml` includes Black, Ruff, Pytest, Coverage, and Pyright configuration blocks with project-standard defaults.
- [ ] Generated `poetry.toml` enables in-project virtualenv behavior.
- [ ] Generated/updated `.vscode/settings.json` enables Pytest, disables unittest, targets the `tests` folder for Pytest args, and enables test discovery on save.
- [ ] When automation mode is selected, generated/updated `.vscode/settings.json` includes terminal command approval patterns for `poetry`, `pyright`, and `pytest`.
- [ ] Bootstrap validation reports a clear failure when any required section/key is missing or malformed.

## Constraints & Risks

- Keep generated settings compatible with strict type-checking and existing quality gates.
- Do not overwrite unrelated existing editor settings; apply minimal, key-scoped updates for Python tooling and preserve user customizations.
- Preserve clear separation between required dependencies and optional heavy ML/NLP/API integrations.
- Risk: future dependency/version drift between bootstrap requirements and main repo if update policy is not maintained.
- Risk: overfitting bootstrap to one machine/OS; output must remain platform-neutral.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Bootstrap python environment from other projects
- [ ] Validate acceptance criteria met
