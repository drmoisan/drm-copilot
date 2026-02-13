# `2026-01-28-scaffold-extension` — User Story

- Issue: #16
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-11T20-01

## Story Statement

- As a repo maintainer, I want a minimal VS Code extension scaffold that creates `hello_python.py` and `hello_pwsh.ps1` with runnable commands, so that downstream teams can adopt a consistent starter without wiring scripts by hand.
- As a developer consuming the scaffold, I want to run “Hello Python” and “Hello PowerShell” from the Command Palette and get workspace artifacts, so that I can quickly verify runtime availability and end-to-end wiring.

## Problem / Why

Teams want to reuse proven Python, PowerShell, and Bash utilities from this repo, but there is no single, consistent extension scaffold that packages those tools with templates and tasks.
This leads to copy-paste adoption, inconsistent setup, and higher onboarding costs across projects.
A focused scaffold would standardize installation, usage, and upgrades for these utilities.


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
  - what obstacles or decisions occur? If Python or PowerShell is missing, they must install the runtime.
  - what outcome do they expect? `hello_python.py` and `hello_pwsh.ps1` exist in the repo and `artifacts/hello_python.txt` + `artifacts/hello_pwsh.txt` are created with a success marker.


## Acceptance Criteria

- [ ] Scaffold includes a working VS Code extension manifest and entry point that registers **Hello Python** and **Hello PowerShell** commands.
- [ ] Running **Hello Python** creates `hello_python.py` (if missing) and produces `artifacts/hello_python.txt` in the workspace.
- [ ] Running **Hello PowerShell** creates `hello_pwsh.ps1` (if missing) and produces `artifacts/hello_pwsh.txt` in the workspace.
- [ ] Commands run without manual path edits in the consumer workspace.
- [ ] README documents installation, required runtimes (Python + PowerShell), and a minimal “first run” workflow using the two commands.
- [ ] Missing runtimes surface clear, actionable errors naming the missing runtime.
- [ ] Works on Windows, macOS, and Linux with documented platform caveats.


## Non-Goals

- Task provider integration and `tasks.json` auto-detection beyond the two hello commands.
- A Bash “Hello” command in the MVP.
- Publishing the scaffolded extension to the VS Code Marketplace.
