# bootstrap-utility-scripts (Issue #40)

- Date captured: 2026-02-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-utility-scripts/ (Issue #40)

- Issue: #40
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/40
- Last Updated: 2026-02-22

- Work Mode: minor-audit

## Problem / Why

Contributors currently rely on tribal knowledge to manually bootstrap utility scripts from two roots (`scripts\dev_tools` and `scripts\dev-tools`). For audit work, we need explicit documentation of what scripts exist, which toolchain each script depends on, and what manual bootstrap expectations apply. The language toolchains (Python, PowerShell, TypeScript) already exist in the environment; this effort is about auditable documentation, not automation.

## Proposed Behavior

Create and maintain an audit-focused script inventory that documents the utility scripts that are manually bootstrapped in a clean worktree.

At a high level, the documentation should:
- enumerate scripts under `scripts\dev_tools` and `scripts\dev-tools`;
- record script purpose, owning toolchain, and expected manual bootstrap prerequisites;
- distinguish required scripts from optional scripts for standard contributor workflows;
- capture audit-relevant notes (constraints, known gaps, and verification expectations) without introducing a new bootstrap script.

Script inventory captured in this document (manual bootstrap scope):

- `scripts\dev_tools` (Python / Poetry)
	- `agentic_sync.py`
	- `clean_devcontainer.py`
	- `collect_commit_context.py`
	- `copy_research_to_issue.py`
	- `fix_all.py`
	- `format_json.py`
	- `json_config.py`
	- `markdown_label_formatter.py`
	- `new_active_feature_folder.py`
	- `new_potential_bug_entry.py`
	- `plan_progress_report.py`
	- `potential_to_issue.py`
	- `resolve_execute_plan_prompt.py`
	- `resolve_file_prompt.py`
	- `resolve_hard_lock_prompt.py`
	- `shell_qc.py`
	- `tk_dialog_helpers.py`
	- `validate_json.py`
	- `atomic_executor/` (Python package folder)
	- `pr_context/` (Python package folder)

- `scripts\dev-tools` (PowerShell / pwsh)
	- `bootstrap-host.helpers.ps1`
	- `bootstrap-host.ps1`
	- `format-powershell.ps1`
	- `link-feature-docs.ps1`
	- `link-parent-child.ps1`
	- `load-openai-key.ps1`
	- `new-potential-entry.ps1`
	- `publish-sideloaded-extension.ps1`
	- `run-actionlint.ps1`
	- `run-pester.ps1`
	- `run-psscriptanalyzer.ps1`
	- `sync-agents-from-instructions.ps1`
	- `tree.ps1`
	- `verify-host.ps1`

Manual bootstrap tool prerequisites captured in this document:
- Python scripts: Python + Poetry environment available.
- PowerShell scripts: PowerShell 7+ (`pwsh`) available.
- Repository baseline toolchains remain preinstalled (Python, PowerShell, TypeScript); this document does not define runtime/toolchain installation.

## Acceptance Criteria (early draft)

- [ ] Manual bootstrap enables running the full Python quality/test chain for utility scripts, and all required Python gates pass (format, lint, type-check, unit tests).
- [ ] Manual bootstrap enables running the full PowerShell quality/test chain for utility scripts, and all required PowerShell gates pass (format/analyze and unit tests).
- [ ] Manual bootstrap enables running the TypeScript quality/test chain required by this repository, and all required TypeScript gates pass.
- [ ] Completion is based on toolchain + unit-test pass status; a script-by-script smoke test run is not required for acceptance.
- [ ] Evidence is recorded for each gate with command, exit code, and pass/fail outcome; any blocked gate must include a concrete reason and remediation owner/action.

## Constraints & Risks

- Must work on Windows-first developer environments (primary target), while avoiding assumptions that block cross-platform usage for Python utilities.
- `scripts\dev_tools` and `scripts\dev-tools` are both in active use; changes must not break either path during transition.
- Audit drift risk: documentation can become stale if scripts are added/renamed without corresponding inventory updates.
- Scope boundary: this effort documents manual bootstrap expectations only; it does not introduce or modify runtime bootstrap automation.
- Classification risk: incorrect required/optional labels could mislead contributors and auditors.

## Test Conditions to Consider

- [ ] Unit coverage areas: if generation tooling is added later, verify deterministic inventory extraction and stable categorization logic.
- [ ] Integration scenarios: documentation review confirms both script roots are covered and each script entry includes toolchain + manual prerequisite metadata.
- [ ] CLI/API examples: include manual bootstrap examples (by toolchain) for representative scripts instead of a single automated bootstrap command.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bootstrap-utility-scripts/` folder from the template