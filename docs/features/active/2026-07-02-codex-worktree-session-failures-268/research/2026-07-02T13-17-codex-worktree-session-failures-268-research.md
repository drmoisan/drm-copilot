<!-- markdownlint-disable-file -->

# Task Research Notes: codex-worktree-session-failures (Issue #268)

## Research Executed

### File Analysis

- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/issue.md`
  - Verified issue #268 identifies four implementation targets: invalid generated PowerShell trust syntax containing `; elseif`, bare `codex` command invocation, source-root-resolved post-Codex script execution before Codex starts, and repository-specific `.codex`/`.agents` copy behavior through the configured post-Codex script.
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md`
  - Verified the acceptance criteria require the extension to remain generic, require `.codex/scripts/post-codex-worktree-session.ps1` to exist, and require regression coverage for trust command formatting, Codex CLI resolution, post-Codex first-run behavior, and `.codex`/`.agents` copy behavior.
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md`
  - Verified the draft plan requires fail-before regression evidence, formatter-linter-typecheck-test ordering, and evidence accounting for issue #268.
- `extensions/drm-copilot/src/codex-worktree-session.ts`
  - Verified `buildCodexTrustCommand` emits the `elseif` clause as a separate array element and joins all fragments with `"; "`, producing `... } ; elseif (...) { ... }`.
  - Verified `buildCodexWorktreeSessionCommands` builds the post-Codex command from `postCodexScriptPath` alone and runs it as a worktree-relative path after `Set-Location`.
  - Verified the same builder emits `codex${objectiveSuffix}` with no Codex executable resolution input.
- `extensions/drm-copilot/src/extension.ts`
  - Verified `newCodexWorktreeSession` resolves only the PowerShell runtime before terminal creation, reads `postCodexScriptPath`, sends git, `Set-Location`, trust, optional Poetry, optional post-Codex, then defers `commands.codex`.
  - Verified it does not read a Codex executable-path setting and does not preflight Codex CLI availability before creating the terminal.
- `extensions/drm-copilot/package.json`
  - Verified the extension contributes `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath` with default `.codex/scripts/post-codex-worktree-session.ps1` and describes the current behavior as worktree-relative.
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
  - Verified current pure-builder tests cover trust content, path quoting, command ordering, Poetry, guarded post-Codex command emission, blank post-Codex omission, and bare `codex` output.
  - Verified current tests do not assert absence of `; elseif`, Codex executable resolution, source-root-resolved post-Codex invocation, or Codex executable fallback behavior.
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
  - Verified command-handler tests use a mocked VS Code terminal, fake timers for the deferred Codex send, `setExecutablePresence` for PowerShell runtime probing, and configuration fixtures for `postCodexScriptPath`.
  - Verified current tests assert a missing PowerShell runtime error but do not assert missing Codex CLI behavior.
- `extensions/drm-copilot/test/extension-test-harness.ts` and `extensions/drm-copilot/test/runtime-test-helpers.ts`
  - Verified the test harness centralizes VS Code mocks and executable-presence fixtures. `ExecutablePresence` currently includes `python`, `py`, `pwsh`, and `powershell`, but not `codex`.
- `extensions/drm-copilot/src/command-runtime.ts`
  - Verified runtime probing has an internal PATH/PATHEXT-aware `executableExists` helper that returns a boolean and is scoped to PowerShell runtime resolution.
- `.codex/scripts/post-codex-worktree-session.ps1`
  - Verified the script exists but currently contains only `[CmdletBinding()]`, `param()`, `Set-StrictMode -Version Latest`, and `$ErrorActionPreference = 'Stop'`.
- `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`
  - Verified existing Pester tests import individual functions with `Import-ScriptFunction`, use `Describe`/`Context`/`It`, and inject scriptblocks for deterministic command/path behavior.
- `tests/scripts/powershell/Support/TestHelpers.ps1`
  - Verified `Import-ScriptFunction` parses a PowerShell script AST and dot-sources a single function into the test scope, supporting isolated tests without running script body side effects.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Verified Pester run paths include `scripts`, `tests/powershell`, and `tests/scripts`, so tests under `tests/scripts/...` can import `.codex/scripts/post-codex-worktree-session.ps1` directly.
- `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
  - Verified existing extension push-down behavior copies `.codex` then `.agents` in deterministic root order and uses pass-through content semantics.
- `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`
  - Verified existing tests assert `.codex` before `.agents`, sorted nested file order, byte-identical content, created/overwritten classification, and artifact path behavior for the extension push-down service.
- `.github/instructions/typescript-code-change.instructions.md` and `.agents/skills/typescript/SKILL.md`
  - Verified TypeScript work requires Prettier, ESLint, TSC, Jest, strong typing, ES modules, no new runtime dependencies without approval, and pure logic separated from VS Code APIs.
- `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, and `.agents/skills/powershell/SKILL.md`
  - Verified PowerShell work requires PoshQC format, PSScriptAnalyzer, Pester, PowerShell 7+ compatibility, advanced functions, narrow seams for filesystem/executable boundaries, and tests that avoid ambient PATH/current-directory assumptions.

### Code Search Results

- `New Codex Worktree Session`
  - Found command contribution in `extensions/drm-copilot/package.json` and command handler in `extensions/drm-copilot/src/extension.ts`.
- `buildCodexTrustCommand`
  - Found builder and current tests in `extensions/drm-copilot/src/codex-worktree-session.ts` and `extensions/drm-copilot/test/codex-worktree-session.test.ts`.
- `postCodexScriptPath`
  - Found configuration default in `extensions/drm-copilot/package.json`, handler resolution in `extensions/drm-copilot/src/extension.ts`, builder input in `extensions/drm-copilot/src/codex-worktree-session.ts`, and harness setter in `extensions/drm-copilot/test/extension-test-harness.ts`.
- `.codex/scripts/post-codex-worktree-session.ps1`
  - Found the script at `.codex/scripts/post-codex-worktree-session.ps1`; no existing dedicated Pester tests were found for this script.
- `pushDownCodexAndAgentsCustomizations`
  - Found existing generic extension push-down implementation under `extensions/drm-copilot/src/lib/push-down/` and service wiring under `extensions/drm-copilot/src/repo-automation-service-push-down.ts`.

### External Research

- #fetch:https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if?view=powershell-7.6
  - Microsoft PowerShell documentation defines `elseif` as part of the `if` statement syntax and shows it chained directly after the prior `if` block, not as a separate command after a statement separator.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - VS Code API documentation states `Terminal.sendText(text, shouldExecute)` writes text to the terminal shell stdin, and when `shouldExecute` is true VS Code appends a platform newline for execution. It also documents `TerminalOptions.shellPath` and `shellArgs`, matching the current pattern of opening a PowerShell terminal and sending command lines.
- #fetch:https://developers.openai.com/codex/cli
  - OpenAI documentation identifies Codex CLI as a local terminal tool, documents running `codex` from a terminal, and states Codex CLI is available on Windows, macOS, and Linux.
- #fetch:https://developers.openai.com/codex/cli/features
  - OpenAI documentation confirms interactive mode starts with `codex` and supports an initial prompt such as `codex "Explain this codebase to me"`, matching the extension's objective-suffix behavior.
- #githubRepo:"openai/codex codex cli install run"
  - Search found the official OpenAI Codex repository, but the recommendation relies on the OpenAI Developers documentation above for Codex CLI command behavior.

### Project Conventions

- Standards referenced: repository TypeScript, PowerShell, general code change, and general unit test policies.
- Instructions followed: research-only scope, write only under `artifacts/research/`, no implementation or feature-doc edits, issue #268 cross-references, and final recommendation focused on one approach with rejected alternatives summarized inside `## Recommended Approach`.

## Key Discoveries

### Project Structure

The Codex worktree session feature is split between a pure TypeScript command builder (`extensions/drm-copilot/src/codex-worktree-session.ts`) and VS Code command wiring (`extensions/drm-copilot/src/extension.ts`). The configured post-Codex script is repository-local at `.codex/scripts/post-codex-worktree-session.ps1`. Existing repository push-down logic for `.codex` and `.agents` exists in the extension service, but issue #268 explicitly keeps the worktree-session extension generic and places repository-specific copy behavior in the configured post-Codex script.

### Implementation Patterns

TypeScript tests already isolate pure command-building from VS Code command wiring. The builder tests should cover string formatting contracts, while command-handler tests should cover configuration defaults, preflight errors, terminal command ordering, and deferred Codex invocation with fake timers.

PowerShell tests already use AST-based function import plus injected scriptblocks to avoid running whole scripts or relying on ambient machine state. This is the correct convention for testing the post-Codex copy script without using external services or mutable PATH.

### Complete Examples

```typescript
// Current source pattern that causes issue #268:
"elseif ($sectionMatch.Groups['body'].Value -notmatch 'trust_level\\s*=\\s*\"trusted\"') { throw \"Codex project trust entry exists but is not trusted: $trustedPath\" }",
].join("; ");
```

```typescript
// Current post-Codex and Codex command behavior:
postCodex:
  trimmedPostCodexPath.length > 0
    ? `if (Test-Path -LiteralPath ${quoteForPwsh(trimmedPostCodexPath)}) { & ${quoteForPwsh(trimmedPostCodexPath)} }`
    : undefined,
codex: `codex${objectiveSuffix}`,
```

```powershell
# Existing Pester convention for isolated script-function tests:
. (Import-ScriptFunction -Path $script:scriptPath -Name "Test-PreconditionsMet")
```

### API and Schema Documentation

`drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath` currently defaults to `.codex/scripts/post-codex-worktree-session.ps1`. Its current package description says the path is resolved relative to the worktree root; issue #268 requires source-root-resolved invocation so a first-run worktree can receive `.codex` and `.agents` before Codex starts.

The recommended config addition is `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` with an empty-string default. When set, validate the configured executable path or command. When unset, resolve `codex` through PATH/PATHEXT before terminal creation. The command builder should receive the resolved executable string and emit `& <quoted executable>` with the optional objective.

### Configuration Examples

```json
{
  "drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath": ".codex/scripts/post-codex-worktree-session.ps1",
  "drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath": ""
}
```

### Technical Requirements

- Trust setup must not contain `; elseif`; the `if`/`elseif` chain must be generated as one syntactic PowerShell statement.
- Codex CLI resolution must happen before creating the terminal or before deferred Codex send, with a clear error when neither configured executable nor PATH fallback resolves.
- The post-Codex script command must resolve the configured script path relative to the source repository root, not the new worktree root, and it must run after trust setup and optional Poetry activation but before Codex starts.
- The repository-specific post-Codex script must copy `.codex` and `.agents` from the source root into the worktree root and must be first-run safe.
- Tests must cover both TypeScript command behavior and PowerShell script behavior without hardcoding repository-specific copy logic into the extension.

**Mandatory unachievable objective callout**:
- No unachievable objective was found. The required behavior is achievable with scoped TypeScript command-builder/registration changes and a repository-specific PowerShell script update.

## Recommended Approach

Use a minimal two-boundary fix: keep the VS Code extension generic and responsible for correct command generation/preflight resolution, and put repository-specific `.codex`/`.agents` copy behavior in `.codex/scripts/post-codex-worktree-session.ps1`.

For the trust command, change `buildCodexTrustCommand` so the `if` and `elseif` clauses are emitted as one PowerShell statement. The smallest implementation is to keep the existing setup fragments but combine the final trust-entry branch into one fragment such as `if (...) { ... } elseif (...) { ... }`, then preserve semicolon joining around independent statements. Add a pure Jest regression asserting the command does not contain `; elseif` and does contain the expected chained `} elseif (` fragment.

For Codex CLI resolution, add a small TypeScript helper near the existing runtime-probing code that resolves a configured executable first and falls back to PATH/PATHEXT lookup for `codex`. Return the resolved executable string rather than only a boolean. Add `codexExecutablePath` to the contributed configuration with an empty-string default. In `newCodexWorktreeSession`, resolve Codex before terminal creation; on failure, throw a clear preflight error such as `Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.` Pass the resolved executable into `buildCodexWorktreeSessionCommands`, and emit the Codex start command as a PowerShell call operator invocation with `quoteForPwsh`, preserving objective quoting.

For post-Codex script invocation, resolve `postCodexScriptPath` against `repoRoot` in the builder or before builder invocation. Emit a guarded absolute-source script call after `Set-Location` and before the deferred Codex start. Pass both roots explicitly, for example `& '<sourceRoot>/.codex/scripts/post-codex-worktree-session.ps1' -SourceRoot '<repoRoot>' -WorktreeRoot '<worktreePath>'`. This preserves the generic extension mechanism while allowing the repository script to operate on both source and destination roots.

For `.codex/scripts/post-codex-worktree-session.ps1`, add parameters `SourceRoot` and `WorktreeRoot`, defaulting conservatively to the script's repository root and current location when omitted. Add focused functions that calculate copy operations for `.codex` and `.agents`, skip missing source folders, create destination directories, and copy files with `-Force` without deleting unrelated destination content. Make same-root invocation a no-op so the script is first-run safe and safe to execute in the source repository. Use injectable filesystem scriptblocks for Pester coverage rather than relying on temp directories.

Rejected alternatives: Hardcoding `.codex` and `.agents` copy behavior into the TypeScript extension was rejected because issue #268 requires the extension to remain generic. Replacing the trust setup with a separate bundled script was rejected because the current defect can be fixed in the pure builder with less surface area and existing Jest coverage. Relying on a bare `codex` command after adding a clearer failure message was rejected because the acceptance criteria allow either a clear preflight error or a resolved executable path, and a resolved executable path also supports configured non-PATH installs.

## Implementation Guidance

- **Objectives**: Satisfy issue #268 by fixing PowerShell trust syntax, adding Codex CLI preflight resolution/configuration, invoking the post-Codex script from the source root, and implementing repo-specific `.codex`/`.agents` copy behavior in the script.
- **Key Tasks**: Update `extensions/drm-copilot/src/codex-worktree-session.ts`; update `extensions/drm-copilot/src/extension.ts`; update `extensions/drm-copilot/package.json`; extend `extensions/drm-copilot/test/runtime-test-helpers.ts` and `extensions/drm-copilot/test/extension-test-harness.ts`; update `extensions/drm-copilot/test/codex-worktree-session.test.ts` and `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`; update `.codex/scripts/post-codex-worktree-session.ps1`; add a Pester test under `tests/scripts/...` for the post-Codex script.
- **Dependencies**: No new runtime dependency is required. Existing Node `fs/path`, VS Code APIs, PowerShell, Jest, and Pester are sufficient.
- **Success Criteria**: The generated trust command contains no `; elseif`; missing Codex CLI fails before terminal creation with a clear error unless a configured executable resolves; the Codex command uses the resolved executable; the post-Codex script is invoked from the source root with source/worktree parameters; the script copies `.codex` and `.agents` before Codex starts; TypeScript and PowerShell regression tests cover the new behavior; required toolchain loops pass in repository order.
