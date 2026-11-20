# scaffold-extension (Issue #16)

- Date captured: 2026-01-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/scaffold-extension/ (Issue #16)

- Issue: #16
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/16
- Last Updated: 2026-02-12
## Problem / Why

The repo has Python, PowerShell, JSON, and Bash QC tooling, but there is no extension framework to invoke these tools within a destination workspace.
Without a proven pattern for extension-to-workspace scripting, teams cannot build production-ready extensions that leverage the repo's utilities.
A minimal, well-tested extension scaffold establishes the foundational pattern: how extension code discovers workspace roots, validates runtimes, and executes scripts that produce deterministic artifacts.

## Proposed Behavior

Create a minimal VS Code Extension that demonstrates the foundational pattern for extension-based workspace scripting:
- **Extension scaffold** (`extensions/scaffold-extension/`) with manifest and TypeScript entry point.
- **Hello Python command**: discovers workspace root, validates Python runtime, executes bundled `hello_python.py` from inside the extension package (no workspace copy), produces `artifacts/hello_python.txt` in the destination workspace.
- **Hello PowerShell command**: discovers workspace root, validates PowerShell runtime (`pwsh` preferred), executes bundled `hello_pwsh.ps1` from inside the extension package (no workspace copy), produces `artifacts/hello_pwsh.txt` in the destination workspace.
- **Self-contained scripts**: `hello_python.py` and `hello_pwsh.ps1` are packaged with the extension and executed in place.
- **Unit and integration tests** that verify command registration, runtime detection, script execution, and artifact generation.
- **README** documenting installation, required runtimes, and the first-run smoke test workflow.

The extension establishes a reusable pattern: TypeScript + Node.js runtime detection → extension-resource script resolution → subprocess execution against destination workspace context with clear error handling.

## Acceptance Criteria (refined)

- [ ] VS Code extension manifest (`package.json`) and entry point (`src/extension.ts`) are present and register **Hello Python** and **Hello PowerShell** commands.
- [ ] Running **Hello Python** executes bundled `hello_python.py` from the extension package and produces `artifacts/hello_python.txt` in the active workspace root.
- [ ] Running **Hello PowerShell** executes bundled `hello_pwsh.ps1` from the extension package and produces `artifacts/hello_pwsh.txt` in the active workspace root.
- [ ] Commands resolve workspace root and bundled script paths with no manual edits required.
- [ ] Commands do not copy `hello_python.py` or `hello_pwsh.ps1` into the destination workspace.
- [ ] Runtime detection logic validates `python` and `pwsh`/`powershell` availability and surfaces clear, actionable errors when runtimes are missing.
- [ ] Output is logged to a dedicated VS Code OutputChannel for traceability.
- [ ] Unit tests cover command registration, runtime detection logic, and bundled script path resolution/execution behavior.
- [ ] Integration tests verify end-to-end execution on Windows and POSIX platforms.
- [ ] README documents installation, required runtimes, first-run workflow, and the extension-to-workspace scripting pattern for future extensions.
- [ ] Extension works on Windows, macOS, and Linux with platform-specific handling documented (e.g., path separators, shell detection).

## Constraints & Risks

- Must not assume global installs beyond typical runtimes; detect and report missing Python/PowerShell runtimes clearly.
- Extension packaging size must stay small; use only bundled `hello_*.py` and `hello_*.ps1` scripts.
- Cross-platform shell invocation differences require robust platform-specific handling (path separators, shell paths).
- Scope risk: keep this MVP minimal and focused on the scripting pattern; future production extensions will extend this foundation.
- No feature flags or staged rollout; extension loads in all environments but commands gracefully fail with clear errors if workspace is missing or runtimes unavailable.

## Test Conditions to Consider

- [ ] Unit tests: command registration, runtime detection (happy path and missing runtime cases).
- [ ] Unit tests: bundled script path resolution logic (extension resource path discovery and validation).
- [ ] Integration tests: end-to-end execution of both hello commands on Windows (pwsh available).
- [ ] Integration tests: end-to-end execution of both hello commands on POSIX (python available).
- [ ] Error handling: missing workspace, missing Python runtime, missing PowerShell runtime, non-zero exit codes.
- [ ] Artifact verification: `artifacts/hello_python.txt` and `artifacts/hello_pwsh.txt` are created with expected content.
- [ ] Invariant verification: `hello_python.py` and `hello_pwsh.ps1` are not copied into destination workspace root during command execution.

## Next Steps

- [ ] Finalize spec with focus on scripting pattern and testing strategy.
- [ ] Implement extension scaffold under `extensions/scaffold-extension/`.
- [ ] Add unit and integration tests with clear documentation of patterns.
- [ ] Document the extension-to-workspace scripting model in README for future extensions.
