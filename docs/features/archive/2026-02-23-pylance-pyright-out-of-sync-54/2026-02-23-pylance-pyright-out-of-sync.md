# pylance-pyright-out-of-sync (Issue #54)

- Date captured: 2026-02-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pylance-pyright-out-of-sync/ (Issue #54)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #54
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/54
- Last Updated: 2026-02-23
## Summary

Pylance (strict mode) reports four Python diagnostics in this workspace that are not being surfaced by the `poetry run pyright --project pyproject.toml` quality gate. This creates a type-safety gap between editor feedback and CI/toolchain enforcement.

We need to tighten `pyproject.toml` Pyright configuration so it is at least as strict as Pylance strict mode for this repo, then resolve the four currently reported diagnostics.

## Environment

- OS/version: Windows (workspace host)
- Python version: 3.12 (from `pyproject.toml` / tool configuration)
- Command/flags used: `poetry run pyright --project pyproject.toml` (passes), compared with VS Code Pylance strict diagnostics in-editor
- Data source or fixture: Current repository workspace (`scripts/`, `src/`, `tests/`) including nested mirrored folder (`drm-copilot/`)

## Steps to Reproduce

1. Open the repository in VS Code with Pylance strict diagnostics enabled.
2. Run `poetry run pyright --project pyproject.toml` from repo root and observe that Pyright does not report these four issues.
3. Inspect the Diagnostics panel for Python and open the flagged files.
4. Observe four Pylance diagnostics currently present:
	- `scripts/dev_tools/agentic_sync.py` line 671: `Type of "payload" is partially unknown` (`dict[str, Unknown]`).
	- `drm-copilot/scripts/dev_tools/agentic_sync.py` line 671: same partially unknown payload diagnostic.
	- `drm-copilot/scripts/dev_tools/fix_all.py` line 546: `runner_factory` argument type identity mismatch (`drm-copilot.scripts...` vs `scripts...`).
	- `drm-copilot/scripts/dev_tools/fix_all.py` line 547: `logger` argument type identity mismatch (`drm-copilot.scripts...` vs `scripts...`).

## Expected Behavior

Pyright configuration in `pyproject.toml` should be strict enough that `poetry run pyright --project pyproject.toml` reports the same (or stricter) actionable type issues that Pylance strict mode reports for tracked source files.

Both editor-time and CI/toolchain-time type checking should agree on error visibility for the same codebase scope.

## Actual Behavior

Pylance reports four strict-mode diagnostics, but Pyright as currently configured does not fail on those issues in the normal project type-check path.

Key error text observed in editor diagnostics includes:
- `Type of "payload" is partially unknown` (`dict[str, Unknown]`)
- `Argument of type "((str, StepLogger) -> CommandRunner) | None" cannot be assigned ...` with module-path identity mismatch (`drm-copilot.scripts...` vs `scripts...`)

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- `scripts/dev_tools/agentic_sync.py:671` → `Type of "payload" is partially unknown` / `Type of "payload" is "dict[str, Unknown]"`
	- `drm-copilot/scripts/dev_tools/fix_all.py:546-547` → incompatible argument type diagnostics due to cross-module type identity mismatch (`drm-copilot.scripts.dev_tools.fix_all.*` vs `scripts.dev_tools.fix_all.*`)

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- `pyproject.toml` currently sets `typeCheckingMode = "strict"` but also relaxes at least one strict diagnostic (`reportMissingTypeArgument = "none"`), and may not be aligned with the effective strict profile Pylance is applying in-editor.
- Workspace structure includes a nested mirrored repo folder (`drm-copilot/`) that appears to produce duplicated module identities (`scripts...` vs `drm-copilot.scripts...`) in diagnostics.
- `agentic_sync.py` payload inference likely needs explicit typed payload models (e.g., typed dict/dataclass serialization boundaries) to avoid `Unknown` propagation.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas
	- Add/adjust tests around `render_sync_summary` payload typing path in `scripts/dev_tools/agentic_sync.py`.
	- Add/adjust tests around `run_fix_all` wrapper typing boundary in `scripts/dev_tools/fix_all.py` to keep public/runtime alias signatures consistent.
- [ ] Integration scenario to retest
	- Retest full Python QC sequence with stricter Pyright settings: `black` → `ruff` → `pyright --project pyproject.toml` → `pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
	- Validate editor and CLI parity by confirming the four diagnostics are either surfaced by Pyright pre-fix and resolved post-fix.
- [ ] Manual verification notes
	- Update `[tool.pyright]` in `pyproject.toml` so effective strictness is equal to or greater than Pylance strict mode for this repo.
	- Resolve the four current diagnostics (two payload/unknown-type entries, two module-identity argument-type mismatches).
	- Confirm zero Pylance diagnostics for affected files and zero Pyright diagnostics in the final toolchain pass.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch