# scaffold-extension (Issue #16)

- Date captured: 2026-01-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/scaffold-extension/ (Issue #16)

- Issue: #16
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/16
- Last Updated: 2026-02-12
## Problem / Why

Teams want to reuse proven Python and PowerShell utilities from this repo, but there is no single, consistent extension scaffold that packages a minimal runnable starter.
This leads to copy-paste adoption, inconsistent setup, and higher onboarding costs across projects.
A focused scaffold would standardize installation, usage, and upgrades for these utilities with a minimal “hello” workflow.

## Proposed Behavior

Provide a minimal VS Code Extension scaffold that exposes two commands:
- **Hello Python**: ensures `hello_python.py` exists and produces `artifacts/hello_python.txt` when run.
- **Hello PowerShell**: ensures `hello_pwsh.ps1` exists and produces `artifacts/hello_pwsh.txt` when run.
A Python environment scaffold should be included using Poetry, Black, Ruff, Pyright, and Pytest. A PowerShell environment scaffold should be included using the PoshQC package.
A README should describe installation, required runtimes, and a first-run workflow.

## Acceptance Criteria (early draft)

- [ ] Scaffold includes a working VS Code extension manifest and entry point that registers **Hello Python** and **Hello PowerShell** commands.
- [ ] Running **Hello Python** creates `hello_python.py` (if missing) and produces `artifacts/hello_python.txt` in the workspace.
- [ ] Running **Hello PowerShell** creates `hello_pwsh.ps1` (if missing) and produces `artifacts/hello_pwsh.txt` in the workspace.
- [ ] Commands run without manual path edits in the consumer workspace.
- [ ] README documents installation, required runtimes (Python + PowerShell), and a minimal “first run” workflow.
- [ ] Python environment scaffold includes Poetry, Black, Ruff, Pyright, and Pytest setup guidance or configuration.
- [ ] PowerShell environment scaffold includes PoshQC setup guidance or configuration.
- [ ] Missing runtimes surface clear, actionable errors naming the missing runtime.
- [ ] Works on Windows, macOS, and Linux with documented platform caveats.

## Constraints & Risks

- Must not assume global installs beyond typical runtimes; should detect and report missing Python/PowerShell runtimes.
- Extension packaging size should stay small; avoid bundling large binaries.
- Cross-platform shell invocation differences may require platform-specific handling.
- Scope risk: avoid turning into a full toolbox; keep the scaffold minimal and extensible.

## Test Conditions to Consider

- [ ] Unit tests for command registration and runtime detection logic.
- [ ] Integration tests for running Hello Python and Hello PowerShell end-to-end.
- [ ] Template copy logic verifies `hello_python.py` and `hello_pwsh.ps1` land in workspace root.
- [ ] Errors when runtimes are missing or scripts exit non-zero.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/scaffold-extension/` folder from the template
