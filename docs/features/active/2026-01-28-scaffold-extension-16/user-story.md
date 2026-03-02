# `2026-01-28-scaffold-extension` — User Story

- Issue: #16
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-11T20-01

## Story Statement

- As a framework architect, I want a minimal, working VS Code extension that demonstrates how extension code can discover workspace roots, validate runtimes, and execute bundled scripts from inside the extension package to produce deterministic artifacts in the destination workspace, so that the pattern can be replicated for production-ready extensions.
- As an extension developer, I want to study the hello-world example (Hello Python and Hello PowerShell) to understand the scripting pattern: TypeScript command handler → runtime validation → extension-resource script resolution → subprocess execution against workspace context → artifact generation.

## Problem / Why

The repo contains Python, PowerShell, JSON, and Bash QC tooling, but there is no extension framework that demonstrates how to invoke these tools from within a destination workspace.
Without a proven pattern, teams cannot build production-ready extensions that leverage the repo's utilities or establish consistent extension-to-workspace scripting conventions.
A minimal, well-tested scaffold establishes the foundational contract: how extension code discovers, validates, and invokes workspace tools programmatically.


## Personas & Scenarios

- Persona: Extension consumer developer
  - who the user is: A developer onboarding a repo that adopts the scaffolded VS Code extension.
  - what they care about: Quick, reliable verification that the extension can run Python/PowerShell utilities without manual path edits.
  - their constraints: Works on Windows/macOS/Linux; may have Python or PowerShell missing.
  - their goals and frustrations: Wants a fast “hello world” workflow and clear errors when runtimes are missing.
  - their context and motivations: Evaluating whether the scaffold is ready for team adoption.
- Scenario: Running the hello commands to validate the scaffold
  - who is acting? The extension consumer developer.
  - what triggered the action? The repo includes the scaffold and the developer wants a quick smoke test.
  - what steps do they take?
    1) Open the repo in VS Code.
    2) Run “Hello Python” from the Command Palette.
    3) Run “Hello PowerShell” from the Command Palette.
  - what obstacles or decisions occur? If Python or PowerShell is missing, they must install the runtime shown in the error (`python`, `pwsh`, or `powershell`) and rerun.
  - what outcome do they expect? The bundled extension scripts run successfully from extension resources, `artifacts/hello_python.txt` + `artifacts/hello_pwsh.txt` are created with a success marker, command lifecycle is visible in the `Scaffold Utils` OutputChannel, and no `hello_*.py`/`hello_*.ps1` files are copied into the destination workspace root.


## Acceptance Criteria

- [ ] Extension manifest (`package.json`) and TypeScript entry point (`src/extension.ts`) are present and functional.
- [ ] **Hello Python** command: discovers workspace root → validates Python runtime → resolves bundled extension script path → executes bundled `hello_python.py` → produces `artifacts/hello_python.txt`.
- [ ] **Hello PowerShell** command: discovers workspace root → validates PowerShell runtime → resolves bundled extension script path → executes bundled `hello_pwsh.ps1` → produces `artifacts/hello_pwsh.txt`.
- [ ] Runtime probe order is deterministic and testable: Python probes `python`; PowerShell probes `pwsh` then `powershell`.
- [ ] Commands use workspace context without requiring local script files in the destination workspace.
- [ ] Command execution does not copy `hello_python.py` or `hello_pwsh.ps1` into workspace root.
- [ ] Runtime validation is explicit and surfaces clear, actionable errors (e.g., "Python not found on PATH").
- [ ] Output is logged to the `Scaffold Utils` VS Code OutputChannel and includes runtime detection, script resolution, command start/end, and failure details.
- [ ] Unit tests cover: command registration, runtime detection (present/missing), bundled script resolution/execution logic.
- [ ] Integration tests cover: end-to-end execution of both commands on Windows and POSIX platforms.
- [ ] Error cases are tested: no open workspace, missing Python, missing PowerShell, non-zero script exit.
- [ ] Platform notes document runtime naming differences and expected runtime availability on Windows/macOS/Linux.
- [ ] README documents the scripting pattern, required runtimes, and first-run workflow.
- [ ] README includes a section on how the extension demonstrates the foundation for production extensions.


## Non-Goals

- Task provider integration and `tasks.json` auto-detection beyond the two hello commands.
- A Bash “Hello” command in the MVP.
- Publishing the scaffolded extension to the VS Code Marketplace.
- Pre-installation of Python, PowerShell, or other runtimes; the extension detects and reports missing runtimes.
- Environment scaffolding (pyproject.toml, poetry.toml, PoshQC setup); this tooling already exists in the repo.
- Copying bundled hello scripts into destination workspace root as part of command execution.