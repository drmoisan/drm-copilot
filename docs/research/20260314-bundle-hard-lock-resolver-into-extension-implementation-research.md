<!-- markdownlint-disable-file -->

# Task Research Notes: bundle hard-lock resolver into extension

## Research Executed

### File Analysis

- c:\Users\DanMoisan\repos\drm-copilot\.github\prompts\research-issue.prompt.md
  - Governs this task and requires a single recommendation, brief rejected alternatives, and exact use of the Task Researcher template.
- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-bundle-hard-lock-resolver-into-extension-103\issue.md
  - Defines the feature objective: add an extension command that resolves the hard-lock prompt through a thin bundled wrapper while keeping the root Python script and prompt template as the authoring source of truth.
- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-bundle-hard-lock-resolver-into-extension-103\spec.md
  - Confirms acceptance criteria, explicit non-repo-workspace requirement, and the need to preserve current execute-flow behavior without duplicating business logic inside the extension.
- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-bundle-hard-lock-resolver-into-extension-103\user-story.md
  - Repeats the thin-wrapper requirement and makes the execute-template bundle requirement explicit.
- c:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\resolve_hard_lock_prompt.py
  - Current source-of-truth resolver already supports `--target`, `--workspace`, and `--template-kind`; it resolves `${plan-path}`, `${work-mode}`, and `${fallback-reason}` but currently hardcodes template lookup to `<workspace>/.github/codex/<template-name>`.
- c:\Users\DanMoisan\repos\drm-copilot\.github\codex\execute-hard-lock.prompt.md
  - Canonical execute hard-lock prompt template consumed by the resolver today.
- c:\Users\DanMoisan\repos\drm-copilot\.github\codex\resume-hard-lock.prompt.md
  - Canonical sibling template already supported by `--template-kind resume`, making resume parity a real packaging consideration even if the first command only exposes execute.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\src\extension.ts
  - Live command handlers follow a repeated pattern: gather user inputs, compute bundled resource roots when needed, and call `executeBundledScript(...)` with a wrapper under `resources/templates/`; no hard-lock command exists yet.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\src\command-runtime.ts
  - Confirms the extension already resolves resource files with `vscode.Uri.joinPath(context.extensionUri, relativePath)`, probes runtimes, and executes subprocesses in the active workspace `cwd`.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\templates\potential_to_issue.py
  - Thin wrapper pattern: prepend `resources/scripts` to `sys.path`, import `dev_tools.*`, and delegate without reimplementing business logic.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\templates\new_active_feature_folder.py
  - Thin wrapper pattern plus resource-root injection precedent: computes bundled feature-template root and appends `--template-root` before delegating.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\scripts\dev_tools\potential_to_issue.py
  - Bundled Python logic modules are import-rewritten copies that import `dev_tools.*`, not `scripts.dev_tools.*`.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\scripts\dev_tools\new_active_feature_folder.py
  - Bundled package root exposes copied logic and helper modules under `resources/scripts/dev_tools/`.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\scripts\dev_tools\prompt_mode_contract.py
  - Shared dependency is already bundled once and reused by multiple extension-side Python workflows, which is the same dependency shape the hard-lock resolver needs.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\package.json
  - The extension manifest contributes command palette entries directly; adding a hard-lock command requires a new `contributes.commands` item, but no legacy `activationEvents` entry is necessary for the current `engines.vscode` range.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\.vscodeignore
  - The package ignores `src/**`, `test/**`, artifacts, coverage, and TypeScript configs, but does not ignore `resources/**`, so newly added bundled scripts/templates/customizations will ship automatically.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\README.md
  - Documents the current execution model: extension commands run bundled resource files in the active workspace; this feature should fit that documented model.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\test\extension.potential-to-issue.test.ts
  - Existing Jest tests verify command registration, prompt wiring, and exact spawned argv for the bundled wrapper path.
- c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\test\extension.new-active-feature-folder.test.ts
  - Existing Jest tests verify the same wrapper/argv contract for a command that also injects a bundled template root.
- c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_resolve_hard_lock_prompt.py
  - Current Python coverage already verifies path normalization, work-mode fallback behavior, execute-template lookup, resume-template lookup, clipboard best-effort behavior, and CLI handling; this is the strongest evidence that the resolver should be generalized rather than reimplemented.
- c:\Users\DanMoisan\repos\drm-copilot\artifacts\research\20260301-scaffold-extension-extension-side-execution-research.md
  - Prior research established the extension-side execution foundation: bundled resources should be located with `extensionUri`, run in workspace context, and never be copied into the workspace root.
- c:\Users\DanMoisan\repos\drm-copilot\artifacts\research\20260311-expose-placeholder-commands-implementation-research.md
  - Prior research documents the exact bundled-script pattern now used in production: thin wrapper in `resources/templates/`, import-rewritten logic under `resources/scripts/dev_tools/`, and shared helper modules bundled once.

### Code Search Results

- bundled-script pattern (`executeBundledScript|resources/templates|resources/scripts/dev_tools`)
  - Found live usage in `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/command-runtime.ts`, `extensions/drm-copilot/resources/templates/potential_to_issue.py`, `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`, and the mirrored Python package under `extensions/drm-copilot/resources/scripts/dev_tools/`.
- hard-lock resolver scope (`resolve_hard_lock_prompt|execute-hard-lock|resume-hard-lock`)
  - Found only the root Python resolver, its root prompt templates, and Python tests; there is no existing extension command or bundled resource for hard-lock resolution yet.
- bundled template-root precedent (`template-root|feature-templates|resources/customizations`)
  - Found explicit `--template-root` injection in `scripts/dev_tools/new_potential_bug_entry.py`, `scripts/dev_tools/new_active_feature_folder_flow.py`, and extension wrappers/resources that pass bundled template roots rather than duplicating template content in code.
- extension packaging surface (`contributes.commands|.vscodeignore|README.md`)
  - Confirmed the manifest is the live command surface, runtime assets under `resources/**` are packaged by default, and README language already describes the right high-level model.

### External Research

- #githubRepo:"microsoft/vscode-extension-samples command registration bundled resources"
  - Prior verified extension-sample research in `artifacts/research/20260301-scaffold-extension-extension-side-execution-research.md` confirms the standard manifest + `src/extension.ts` shape for command registration and extension-resource access.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - Official docs confirm that user-facing commands require both `vscode.commands.registerCommand(...)` and a matching `package.json` command contribution, and that command handlers may be consumed by users or other extensions.
- #fetch:https://code.visualstudio.com/api/references/extension-manifest
  - Official docs confirm `package.json` is the authoritative extension manifest, `contributes.commands` is the command surface, and extension packaging behavior is controlled by manifest fields plus `.vscodeignore`.
- #fetch:https://code.visualstudio.com/api/references/activation-events
  - Official docs confirm that since VS Code 1.74, contributed commands do not need explicit `onCommand` activation events; the current extension engine range (`^1.108.0`) is safely above that threshold.
- #fetch:https://code.visualstudio.com/api/working-with-extensions/publishing-extension
  - Official docs confirm `.vscodeignore` excludes files from the VSIX package and that unignored runtime assets are packaged, which matters for adding prompt templates and bundled Python modules under `resources/**`.

### Project Conventions

- Standards referenced: `.github/prompts/research-issue.prompt.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/skills/policy-compliance-order/SKILL.md`.
- Instructions followed: research-only writes confined to `artifacts/research/`; recommendation constrained to one chosen approach with brief rejected alternatives; evidence grounded in direct repo reads and official VS Code docs.

## Key Discoveries

### Project Structure

The extension already has three distinct runtime asset zones that matter here:

1. `resources/templates/` for thin executable entrypoints.
2. `resources/scripts/dev_tools/` for import-rewritten Python business logic.
3. `resources/customizations/.github/` for packaged repo-style authoring assets.

That third zone is important: prompt-like content already ships there for other customization scenarios, so the hard-lock prompt template does **not** need to be awkwardly embedded inside Python code or moved into an unnatural script folder. The clean fit is to bundle `.github/codex/*.prompt.md` under the extension’s packaged `.github` payload and let the resolver receive that path as an injected template root.

### Implementation Patterns

The production bundling pattern is now stable and repeatable:

- VS Code command handler gathers user input.
- Handler passes a wrapper path under `resources/templates/` to `executeBundledScript(...)`.
- `executeBundledScript(...)` resolves the wrapper using `context.extensionUri` and launches it in the active workspace.
- Wrapper mutates `sys.path` so `resources/scripts/` becomes importable as top-level `dev_tools`.
- Wrapper delegates all business logic to a bundled `dev_tools.*` module and optionally injects a bundled resource root such as `--template-root`.

`resolve_hard_lock_prompt.py` already has the right business logic shape for bundling, but it is missing one extension-friendly seam: it only resolves templates from `<workspace>/.github/codex/`. That single hardcoded lookup is the real blocker for non-repo workspaces.

### Complete Examples

```python
from __future__ import annotations

import importlib
import sys
from collections.abc import Callable
from pathlib import Path
from typing import cast


def _ensure_bundled_scripts_import_path() -> None:
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)
    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    _ensure_bundled_scripts_import_path()
    bundled_template_root = (
        Path(__file__).resolve().parent.parent / "customizations" / ".github" / "codex"
    )
    if "--template-root" not in sys.argv:
        sys.argv.extend(["--template-root", str(bundled_template_root)])

    module = importlib.import_module("dev_tools.resolve_hard_lock_prompt")
    module_main = cast(Callable[[], int], module.main)
    return module_main()


if __name__ == "__main__":
    raise SystemExit(main())
```

### API and Schema Documentation

Current resolver contract already present in `scripts/dev_tools/resolve_hard_lock_prompt.py`:

- `--target <path>`: required plan file path.
- `--workspace <path>`: optional workspace root; defaults to `Path.cwd()`.
- `--template-kind execute|resume`: already supported.

Recommended addition to preserve single-source-of-truth while enabling extension packaging:

- `--template-root <path>`: optional directory containing `execute-hard-lock.prompt.md` and/or `resume-hard-lock.prompt.md`.

Recommended resolution order inside the source-of-truth Python module:

1. If `--template-root` is supplied, check `<template-root>/<template-name>` first.
2. Otherwise check the workspace path (`<workspace>/.github/codex/<template-name>`).
3. If neither exists, fail clearly with the effective checked path(s).

This is the same design family already used by bundled feature-template workflows and keeps the business rules centralized in the root Python script.

### Configuration Examples

```json
{
  "contributes": {
    "commands": [
      {
        "command": "drmCopilotExtension.resolveExecuteHardLockPrompt",
        "title": "drm-copilot: Resolve Execute Hard-Lock Prompt"
      }
    ]
  }
}
```

### Technical Requirements

- Add one extension command for execute hard-lock prompt resolution; use the same wrapper + bundled-module pattern as `potentialToIssue` and `newActiveFeatureFolder`.
- Bundle an import-rewritten copy of `scripts/dev_tools/resolve_hard_lock_prompt.py` under `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py`.
- Reuse the already-bundled shared dependency pattern for `prompt_mode_contract.py`; no new dependency is required.
- Add a thin wrapper under `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` that only bootstraps imports and injects a bundled template root.
- Bundle `.github/codex/execute-hard-lock.prompt.md` under the extension’s packaged `.github` payload; bundle `resume-hard-lock.prompt.md` at the same time because the resolver already supports it and current tests cover it.
- Update the root source-of-truth resolver to support template-root injection with workspace fallback rather than forking extension-only logic.
- Add extension Jest coverage for command registration, file selection, argv wiring, and wrapper path.
- Add Python tests for the new `--template-root` resolution path while preserving current workspace-template behavior and resume-template behavior.
- Preserve clipboard copy as best-effort only; prompt generation success must not depend on clipboard availability.

**Mandatory unachievable objective callout**:
- **None identified.** The feature is achievable with the existing extension execution model, existing Python runtime dependency model, and current VS Code command/package APIs.

## Recommended Approach

Implement the hard-lock flow with the **same thin-wrapper + bundled-module pattern already used by `potential_to_issue` and `new_active_feature_folder`, but add a source-of-truth `--template-root` seam to `scripts/dev_tools/resolve_hard_lock_prompt.py` and ship the prompt templates as packaged `.github/codex` assets inside the extension**.

Why this is the best fit:

- It preserves the root Python resolver and root prompt files as the authoring source of truth.
- It solves the actual non-repo-workspace blocker without duplicating prompt-resolution logic inside TypeScript or the wrapper.
- It matches the extension’s proven packaging contract: wrapper in `resources/templates/`, logic in `resources/scripts/dev_tools/`, assets under packaged `resources/**`.
- It keeps parity with the script’s existing `--template-kind resume` support, which reduces future drift and avoids a second packaging change later.

Recommended concrete design:

1. **Source-of-truth Python change**
   - Extend `scripts/dev_tools/resolve_hard_lock_prompt.py` to accept optional `--template-root`.
   - Resolve templates from `--template-root` first, then workspace `.github/codex`, then fail clearly.
   - Keep `resolve_prompt(...)`, clipboard behavior, work-mode resolution, and `--template-kind` semantics unchanged.

2. **Bundled Python mirror**
   - Add `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` as an import-rewritten copy using `from dev_tools.prompt_mode_contract import ...`.
   - Do **not** reimplement logic in the wrapper.

3. **Bundled wrapper**
   - Add `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`.
   - Wrapper computes bundled codex root such as `resources/customizations/.github/codex` and injects `--template-root` if absent.
   - Wrapper delegates to `dev_tools.resolve_hard_lock_prompt.main()`.

4. **Bundled prompt assets**
   - Add `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`.
   - Also add `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md` for parity with the existing resolver contract and tests.

5. **Extension command wiring**
   - In `extensions/drm-copilot/src/extension.ts`, add a helper that resolves an active plan path or prompts the user with `showOpenDialog` rooted under `docs/features/active`.
   - Register `drmCopilotExtension.resolveExecuteHardLockPrompt`.
   - Pass `--target <selected-plan>` and `--workspace <workspaceRoot>` to `executeBundledScript(...)` with bundled wrapper `resources/templates/resolve_hard_lock_prompt.py`.
   - Do not pass `--template-root` from TypeScript; keep that responsibility in the wrapper so the command surface stays small and the wrapper remains the extension/bundling adapter.

6. **Testing strategy**
   - Jest: command registration, active-editor/selected-file wiring, cancellation behavior, missing Python runtime, and exact argv including wrapper path and `--target`/`--workspace`.
   - Pytest: current root tests plus new coverage for `--template-root`, fallback ordering, bundled-template success when workspace `.github/codex` is absent, and continued `resume` parity.

Rejected alternatives (brief, non-exhaustive):

- **Reimplement prompt resolution directly in `extension.ts` or a Node helper**: rejected because it duplicates Python business logic, increases drift risk, and violates the feature’s single-source-of-truth intent.
- **Bundle only `execute-hard-lock.prompt.md` and ignore `resume-hard-lock.prompt.md`**: rejected because the resolver already supports `resume`, existing tests already assert it, and shipping only half the contract creates an avoidable parity gap.
- **Embed the prompt template text inside the wrapper script**: rejected because it hides the canonical authored prompt content inside code and makes synchronization harder than bundling the prompt file itself.

## Implementation Guidance

- **Objectives**: Expose execute hard-lock prompt resolution from the extension in arbitrary workspaces while keeping root Python logic and root prompt content as the canonical sources.
- **Key Tasks**:
  - Add optional `--template-root` support to `scripts/dev_tools/resolve_hard_lock_prompt.py` and preserve current workspace fallback behavior.
  - Mirror the resolver into `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` with import rewrites only.
  - Create thin wrapper `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` that injects bundled codex template root.
  - Bundle `execute-hard-lock.prompt.md` and `resume-hard-lock.prompt.md` under `extensions/drm-copilot/resources/customizations/.github/codex/`.
  - Register a new command in `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/package.json`.
  - Add Jest tests in `extensions/drm-copilot/test/` and Pytest updates in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`.
- **Dependencies**: No new runtime dependency is justified; reuse existing Python runtime requirement, existing `prompt_mode_contract.py`, existing extension command runtime, and packaged `resources/**` behavior.
- **Success Criteria**:
  - The extension command can resolve the execute hard-lock prompt in a workspace that lacks repo-local `.github/codex` assets.
  - The wrapper remains adapter-only; business logic lives in bundled `resources/scripts/dev_tools/resolve_hard_lock_prompt.py` and the root source-of-truth script.
  - The bundled prompt output still preserves plan-path normalization, work-mode resolution, fallback-reason substitution, and best-effort clipboard behavior.
  - The root script and root prompt files remain the authoring source of truth, with extension assets acting as synchronized packaged copies only.