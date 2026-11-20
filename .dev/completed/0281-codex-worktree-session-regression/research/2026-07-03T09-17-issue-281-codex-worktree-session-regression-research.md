<!-- markdownlint-disable-file -->

# Task Research Notes: Issue 281 Codex Worktree Session Regression

## Research Executed

### File Analysis

- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/issue.md`
  - Verified issue #281 scope: the command still reports malformed PowerShell trust command behavior, missing `.codex`/`.agents` copy behavior, and unresolved bare `codex` launch behavior in worktree `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-08-58` at commit `476b110`.
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`
  - Verified acceptance criteria and intended behavior: create worktree, change location, add Codex trust without parse error, install/activate Poetry when applicable, run `.codex/scripts/post-codex-worktree-session.ps1`, copy `.codex` and `.agents`, and start Codex through extension-level executable resolution.
- `extensions/drm-copilot/src/codex-worktree-session.ts`
  - Verified `buildCodexTrustCommand` currently joins each fragment with `"; "` and keeps the final conditional as one fragment: `if (...) { ... } elseif (...) { ... }` at line 56. This prevents the specific serialized substring `"; elseif"` inside the emitted command.
  - Verified `buildCodexWorktreeSessionCommands` builds the Codex invocation from `input.codexExecutablePath` at line 78 and emits the post-Codex script with `-SourceRoot` and `-WorktreeRoot` at lines 87-90.
- `extensions/drm-copilot/src/command-runtime.ts`
  - Verified `resolveCodexExecutable` exists at lines 190-230. It resolves configured path-like values by `fs.existsSync`, configured command names by PATH lookup, and blank configuration by resolving `codex` from PATH before terminal creation. It throws a specific error if resolution fails.
- `extensions/drm-copilot/src/extension.ts`
  - Verified `newCodexWorktreeSession` resolves PowerShell first, calculates the worktree, reads `postCodexScriptPath` and `codexExecutablePath`, calls `resolveCodexExecutable`, then passes `resolveSourceRootPath(workspaceRoot, configuredPostCodexScriptPath)` into `buildCodexWorktreeSessionCommands` at lines 252-286.
  - Verified terminal command order is `git`, `Set-Location`, trust, optional Poetry install, optional activation, optional post-Codex script, then deferred Codex launch at lines 296-311.
- `extensions/drm-copilot/package.json`
  - Verified the configuration default for `postCodexScriptPath` is `.codex/scripts/post-codex-worktree-session.ps1` and the description says it is resolved relative to the source repository root at lines 50-54.
  - Verified `codexExecutablePath` is configurable and defaults to an empty string at lines 55-59.
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
  - Verified unit coverage asserts the trust command does not contain `"; elseif"` and does contain `"} elseif ("` at lines 34-39.
  - Verified unit coverage asserts the command builder emits Codex through the supplied executable path at lines 79-101 and emits post-Codex script invocation with `-SourceRoot` and `-WorktreeRoot` at lines 114-122.
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
  - Verified command-handler coverage asserts the command sends git, location, trust, post script, and resolved Codex command in order at lines 38-99.
  - Verified default post-script path coverage at lines 143-166 and explicit source-root post-script coverage at lines 168-202.
  - Verified missing Codex executable resolution fails before terminal creation at lines 257-269 and configured executable path launch is covered at lines 271-297.
- `extensions/drm-copilot/test/extension.test.ts`
  - Verified resolver coverage for default PATH lookup, undefined configuration fallback, configured command-name lookup, configured executable path validation, and missing executable errors at lines 146-199.
- `extensions/drm-copilot/test/extension-test-harness.ts`
  - Verified the harness simulates configuration for `postCodexScriptPath` and `codexExecutablePath` at lines 61-83 and resets PATH/PATHEXT to deterministic values at lines 318-328.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`
  - Verified the tracked resource script accepts `SourceRoot` and `WorktreeRoot`, skips only same-root operations, scans `.codex` before `.agents`, plans file-level copy operations, creates destination directories, and copies files with `Copy-Item -Force` at lines 1-130.
  - Verified fallback source root behavior still derives from `$PSScriptRoot/../..` when `SourceRoot` is blank at lines 113-118. This fallback remains unsafe for a copied destination stub or destination-local script; the TypeScript command should pass `-SourceRoot`.
- `.codex/scripts/post-codex-worktree-session.ps1`
  - Verified the current worktree root has only a strict-mode stub with no copy behavior. This file is not tracked by `git ls-files`; the tracked copy is under the extension resource tree.
- `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1`
  - Verified Pester tests import the tracked resource script, not the ignored root `.codex` script, at line 6.
  - Verified current tests cover same-root no-op, missing source folders, `.codex` then `.agents` copy planning, and copy-plan invocation. They do not cover invoking the full script entry point against an actual source/worktree fixture or the blank-`SourceRoot` fallback path.

### Code Search Results

- `newCodexWorktreeSession`
  - Matches found in `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/package.json`, and TypeScript tests. The command registration and configuration keys are present.
- `resolveCodexExecutable`
  - Matches found in `extensions/drm-copilot/src/command-runtime.ts`, exported through `extensions/drm-copilot/src/extension.ts`, and covered by `extensions/drm-copilot/test/extension.test.ts` and `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`.
- `post-codex-worktree-session`
  - Matches found in the tracked resource script, package configuration defaults, Pester tests, and generated root `.codex` stub. `git ls-files` confirmed only the tracked resource script is committed; the root `.codex` script is ignored workspace state.
- `; elseif`
  - The current source search found the guard assertion in `extensions/drm-copilot/test/codex-worktree-session.test.ts`. The current command builder emits `"} elseif ("`, not `"; elseif"`.

### External Research

- #githubRepo:"microsoft/vscode Terminal.sendText shouldExecute"
  - Verified from the VS Code repository that terminal text is sent to the terminal instance and execution behavior depends on the `shouldExecute` pathway. This supports keeping each generated PowerShell command as a complete standalone line before passing it to `Terminal.sendText`.
- #fetch:https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if?view=powershell-7.6
  - Verified PowerShell `elseif` is part of an `if` statement chain. This supports treating `} elseif (...) { ... }` as one PowerShell statement, not a separate prompt-level command.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - Verified VS Code extension APIs define the terminal surface used by this command. Current implementation uses `createTerminal` and `sendText` through that API.
- #fetch:https://nodejs.org/api/child_process.html
  - Verified Node child-process APIs can spawn without a shell by default. This supports keeping executable detection and explicit path resolution separate from shell fallback assumptions.

### Project Conventions

- Standards referenced: `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Instructions followed: research-only scope, professional tone, writes limited to `artifacts/research/`, issue number 281 used in artifact content and cross-references, TypeScript and PowerShell toolchain expectations recorded without implementing changes.

## Key Discoveries

### Project Structure

The Codex worktree-session behavior spans three main surfaces:

- TypeScript command builder: `extensions/drm-copilot/src/codex-worktree-session.ts`.
- VS Code command orchestration and configuration resolution: `extensions/drm-copilot/src/extension.ts`.
- Executable and runtime resolution: `extensions/drm-copilot/src/command-runtime.ts`.
- Repo-specific customization copy: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`.

The repository root `.codex` and `.agents` folders are runtime/customization state and are not reliable as tracked source. The tracked customization source for the post-worktree script is the extension resource tree.

### Implementation Patterns

The TypeScript implementation already separates pure command construction from VS Code command execution. `buildCodexWorktreeSessionCommands` returns a command object, while `extension.ts` handles configuration, runtime resolution, terminal creation, command ordering, and deferred Codex launch.

The PowerShell script already separates copy planning from copy execution through `Get-CodexCustomizationCopyPlan` and `Invoke-CodexCustomizationCopyPlan`, which is compatible with existing Pester tests and the PowerShell skill guidance for narrow seams.

### Complete Examples

```typescript
// Verified current command-builder pattern from extensions/drm-copilot/src/codex-worktree-session.ts
const codexCommand = `& ${quoteForPwsh(input.codexExecutablePath)}${objectiveSuffix}`;
const postCodex =
  trimmedPostCodexPath.length > 0
    ? `if (Test-Path -LiteralPath ${quoteForPwsh(trimmedPostCodexPath)}) { & ${quoteForPwsh(trimmedPostCodexPath)} -SourceRoot ${quotedRepoRoot} -WorktreeRoot ${quotedPath} }`
    : undefined;
```

```powershell
# Verified current copy planning pattern from the tracked post-Codex resource script.
foreach ($customizationFolder in @('.codex', '.agents')) {
    $sourceFolder = "$normalizedSourceRoot/$customizationFolder"
    if (-not (& $TestPath -LiteralPath $sourceFolder)) {
        continue
    }

    foreach ($file in @(& $GetChildItem -LiteralPath $sourceFolder)) {
        $relativePath = Get-RelativeCustomizationPath -SourceFolder $sourceFolder -SourcePath $sourcePath
        [pscustomobject]@{
            CustomizationFolder = $customizationFolder
            SourcePath          = $sourcePath.Replace('\', '/')
            DestinationPath     = "$normalizedWorktreeRoot/$customizationFolder/$relativePath"
        }
    }
}
```

### API and Schema Documentation

Relevant configuration keys are defined in `extensions/drm-copilot/package.json`:

```json
{
  "drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath": {
    "type": "string",
    "default": ".codex/scripts/post-codex-worktree-session.ps1"
  },
  "drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath": {
    "type": "string",
    "default": ""
  }
}
```

The current contract is source-root-relative `postCodexScriptPath`, optional configured Codex executable path or command name, and fail-fast executable resolution before terminal creation.

### Configuration Examples

```json
{
  "drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath": ".codex/scripts/post-codex-worktree-session.ps1",
  "drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath": "C:/Tools/Codex/codex.exe"
}
```

### Technical Requirements

- The emitted trust command must not split `elseif` into a separate PowerShell prompt command. Current source and tests support this requirement, but a live generated-terminal integration test would provide stronger coverage than string-only assertions.
- The post-Codex script must be invoked from the source repository path with explicit `-SourceRoot` and `-WorktreeRoot` before Codex launch. Current TypeScript source supports this requirement.
- The PowerShell copy script must copy the tracked source repository `.codex` and `.agents` trees into the new worktree. Current planning functions support this, but tests do not execute the full script entry point or verify actual filesystem copy results.
- Codex must launch through a resolved executable path, or the command must fail before terminal creation with the existing actionable error. Current source and tests support this requirement.

**Mandatory unachievable objective callout**:
- No objective was proven unachievable during this research.

## Recommended Approach

Implement issue 281 as a narrow regression hardening pass across the existing TypeScript and PowerShell seams rather than replacing the workflow.

Recommended design:

- Keep `resolveCodexExecutable` as the single Codex executable resolution boundary in `extensions/drm-copilot/src/command-runtime.ts`.
- Keep `buildCodexTrustCommand` in `extensions/drm-copilot/src/codex-worktree-session.ts`, but add stronger regression coverage that parses or executes the generated trust command in PowerShell with a controlled temporary Codex config target if the implementation is changed. If direct execution would require writing outside allowed test boundaries, add a parser-level assertion that the final conditional is one AST statement.
- Keep `postCodexScriptPath` source-root-relative in `extensions/drm-copilot/src/extension.ts` and continue passing explicit `-SourceRoot` and `-WorktreeRoot`.
- Harden `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1` with entry-point coverage that imports the tracked resource script and verifies real copy behavior from a controlled source tree into a controlled destination tree. The most important missing coverage is a full-script or near-entry-point test proving `.codex` and `.agents` are copied when destination folders are absent.
- Treat the root `.codex/scripts/post-codex-worktree-session.ps1` stub as a symptom of the failed generated worktree, not the implementation source. Do not implement repo-specific copy behavior in `extension.ts`; keep it in the configured post-Codex script mechanism.

Rejected alternatives:

- Hardcode `.codex` and `.agents` copy logic directly into `newCodexWorktreeSession`. Rejected because prior issue #268 requirements and current package configuration keep repo-specific setup in the configured post-Codex script mechanism.
- Invoke the post-Codex script from the new worktree relative path only. Rejected because the issue #281 failure shows a first-run worktree may not yet contain a functional `.codex` script, and the current configuration description requires source-root-relative resolution.

## Implementation Guidance

- **Objectives**: Close issue 281 by preserving the current design, adding or repairing missing regression coverage, and correcting any implementation drift found by those tests.
- **Key Tasks**:
  - Verify the installed/bundled extension state used by VS Code includes the current `extension.ts`, `command-runtime.ts`, and tracked resource script behavior. The live issue symptoms are consistent with a stale installed extension or a generated worktree that received only the stub root `.codex` script, while the checked-out source at `476b110` contains the intended TypeScript paths.
  - Add a TypeScript regression test that fails if the Codex command sent after the timer is bare `codex` instead of `& '<resolved path>'`.
  - Add a TypeScript regression test or strengthen the existing test to assert the emitted trust command is sent as one complete line and contains no prompt-separating `; elseif`.
  - Add a PowerShell entry-point or integration-style Pester test for the tracked resource script proving `.codex` and `.agents` copy from source root to an initially missing worktree root when explicit `-SourceRoot` and `-WorktreeRoot` are supplied.
  - Consider adding a negative test that blank `SourceRoot` fallback is not used by the extension command path. If fallback behavior remains, document it as manual compatibility only.
- **Dependencies**:
  - TypeScript validation requires `extensions/drm-copilot/node_modules` to be installed. Focused `npm run test -- codex-worktree-session` could not run in this research environment because `jest/bin/jest` was missing.
  - PowerShell validation can run through Pester; the focused post-Codex script test passed with 5 tests, 0 failed.
- **Success Criteria**:
  - Issue #281 repro no longer emits `elseif: The term 'elseif' is not recognized`.
  - A new worktree receives both `.codex` and `.agents` from the source repository before Codex launch.
  - Final Codex launch uses a resolved executable path or fails before terminal creation with the configured error.
  - TypeScript and PowerShell toolchains are run in repository order after implementation: format, lint/analyze, type-check where applicable, tests.
