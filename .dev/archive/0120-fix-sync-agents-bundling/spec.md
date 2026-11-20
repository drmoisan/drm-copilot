# 2026-04-05-fix-sync-agents-bundling (Spec)

- **Issue:** #120
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T10-12
- **Status:** Active
- **Version:** 1.0

## Context
The bundled `drmCopilotExtension.syncAgentsFromInstructions` command crashes when the destination workspace does not have `.github/copilot-instructions.md`. The script should treat the preamble file as optional so it can generate `AGENTS.md` from whatever instruction files exist. Additionally, the generated output embeds each instruction file verbatim without compaction, producing repetitive content that is not optimized for agent consumption.

Environment:
- OS/version: Windows 11 / VS Code Insiders
- Extension: drm-copilot 0.0.1
- Command/flags used: `drmCopilotExtension.syncAgentsFromInstructions` via VS Code command palette
- Destination workspace: `open-claw-bridge` (lacks `.github/copilot-instructions.md`)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open a workspace that has `.github/instructions/*.instructions.md` files but lacks `.github/copilot-instructions.md`.
2. Run `drm-copilot: Sync AGENTS.md from Instructions` from the command palette.
3. Observe the command fails with: `Required AGENTS preamble file not found: .github/copilot-instructions.md`.

Expected:
The command should generate `AGENTS.md` from the discovered instruction files and optionally include the preamble if it exists. The output should be compacted for high-signal, non-repetitive agent content.

Actual:
The command throws a hard error and produces no output when `.github/copilot-instructions.md` is missing.

Error log:
```
[drmCopilotExtension.syncAgentsFromInstructions] command failure
Exception: Required AGENTS preamble file not found: c:/Users/DanMoisan/repos/open-claw-bridge/.github/copilot-instructions.md
```

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: See Actual Behavior section above.


## Scope & Non-Goals
- In scope:
  - Make `.github/copilot-instructions.md` optional in `sync-agents-from-instructions.ps1` so the script generates a valid `AGENTS.md` from discovered `*.instructions.md` files when the preamble is absent.
  - When the preamble is present, preserve current behavior (backward compatible).
  - Add compaction logic to strip redundant content from the consolidated `AGENTS.md` output: cross-reference boilerplate, duplicate toolchain commands, verbose suppression examples, and repeated reading-order statements.
  - Update Pester tests for optional-preamble behavior and compaction assertions.
  - Keep the bundled template at `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` byte-identical to the root script.
  - Regenerate `AGENTS.md` in the source repo to validate output.
- Out of scope / non-goals:
  - Changes to the VS Code extension TypeScript code (`extension.ts`, `command-runtime.ts`). The fix is entirely in the PowerShell script.
  - Adding new CLI flags or parameters to the sync script.
  - Changing the instruction file discovery order or naming conventions.
  - Restructuring or renaming the instruction files themselves.
- Explicitly excluded systems, integrations, or datasets:
  - Push-down rewrite logic (`test_push_down_copilot_customizations_rewrites.py`) is not affected; the Python test validates rewrite behavior, not script internals.

## Root Cause Analysis
- `Get-DiscoveredInstructionFile` in `sync-agents-from-instructions.ps1` hard-requires `.github/copilot-instructions.md` and throws if missing.
- `Get-AgentContent` calls `Get-InstructionsBody` on the preamble without checking existence first.
- The bundled template at `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` mirrors the root script exactly, so both carry the same defect.
- No compaction or deduplication logic exists in the current script; bodies are embedded verbatim.


## Proposed Fix

### Design summary (what changes where):

Two concerns addressed in the same script:

1. **Bug fix (preamble optional):** Remove the hard gate in `Get-DiscoveredInstructionFile` that throws when `.github/copilot-instructions.md` is absent. Add a `Test-Path` guard in `Get-AgentContent` so the copilot section, header source list entry, and header instruction text are conditionally included only when the preamble file exists.

2. **Enhancement (compaction):** Add a compaction pass in `Get-AgentContent` (or a new helper function) that applies pattern-based text transformations to each instruction body after reading and before embedding. The compaction rules target four categories of redundant content identified in the research.

### Boundaries and invariants to preserve:

- When `.github/copilot-instructions.md` is present, the generated `AGENTS.md` must include the `## Repository Instructions (GitHub Copilot Canonical)` section with full preamble content. Existing consumers of the current output format must not break.
- The `<!-- BEGIN: ... -->` / `<!-- END: ... -->` markers around each section must be preserved for downstream tooling that parses section boundaries.
- `Get-InstructionsBody` internal behavior (throws on missing file, strips frontmatter) is unchanged; the guard is added at the caller (`Get-AgentContent`).
- Instruction file discovery order (ordinal sort of normalized relative paths) is unchanged.
- Bundled template parity: the Pester test enforcing byte-identical content between root and bundled script must continue to pass.

### Dependencies or blocked work:

- None. No extension code changes required. No new dependencies.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

| File | Role | Change Type |
|------|------|-------------|
| `scripts/dev-tools/sync-agents-from-instructions.ps1` | Root production script | Bug fix + compaction logic |
| `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` | Bundled template (must byte-match root) | Copy of root after changes |
| `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` | Pester tests | Update existing + add new tests |
| `AGENTS.md` | Generated output | Regenerated by running updated script |

#### Functions/classes/CLI commands impacted:

- **`Get-DiscoveredInstructionFile`**: Remove the `Test-Path` + `throw` block for `.github/copilot-instructions.md` (lines ~168-170). This function's responsibility is discovering `*.instructions.md` files, not validating the preamble.
- **`Get-AgentContent`**: Five locations require conditional logic:
  1. Guard `Get-InstructionsBody` call for the preamble with `Test-Path`. If absent, set `$copilotBody` to `$null`.
  2. Build `$copilotSection` only when preamble exists; set to empty string otherwise.
  3. Conditionally include `.github/copilot-instructions.md` in `$headerSourceLines`.
  4. Conditionally include the copilot-instructions mention in the header instruction text.
  5. Apply compaction transformations to instruction bodies before embedding.
- **New function (compaction):** A `Compress-InstructionBody` function (or inline logic within `Get-AgentContent`) that applies regex-based transformations to strip redundant patterns from instruction bodies.

#### Data flow and validation changes:

- `Get-AgentContent` receives the repo root path and discovered instruction files. It now checks for preamble existence at runtime rather than assuming it. The output string assembly branches on a `$preambleExists` boolean.
- Compaction transformations are applied to each instruction body string after `Get-InstructionsBody` returns and before the body is interpolated into the section template. Transformations are pure string operations with no side effects.

#### Error handling and logging updates:

- The `throw "Required AGENTS preamble file not found"` in `Get-DiscoveredInstructionFile` is removed.
- No new exceptions are introduced. If the preamble is absent, the script proceeds silently (the absence is a valid state, not an error).
- Existing error behavior for truly invalid states (no instruction files found at all) is preserved.

#### Rollback/feature-flag considerations (if applicable):

- Not applicable. The fix is backward compatible: when the preamble exists, output is functionally equivalent (with compaction applied). Compaction is always-on; no feature flag is needed because the compaction rules are deterministic and the output is regenerated on each run.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- **Input:** `-RepoRoot <path>` parameter pointing to a workspace directory. The script discovers `.github/instructions/*.instructions.md` files and optionally `.github/copilot-instructions.md`.
- **Output:** `AGENTS.md` written to the repo root. Markdown format with `<!-- BEGIN/END -->` section markers. When preamble is absent, the `## Repository Instructions (GitHub Copilot Canonical)` section and its markers are omitted entirely.

#### Required configuration keys and defaults:

- No new configuration. Existing `-RepoRoot` parameter is the sole input.

#### Backward-compatibility expectations:

- Workspaces with `.github/copilot-instructions.md` present: output includes the copilot section as before, with compaction applied to instruction bodies.
- Workspaces without `.github/copilot-instructions.md`: output is a valid `AGENTS.md` containing only the discovered instruction file sections. The header omits the copilot file from the source list.

#### Performance constraints (latency/throughput/memory):

- No meaningful performance impact. Compaction adds regex operations on strings that are at most a few hundred lines each. Total script runtime remains sub-second.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The workspace has at least one `.github/instructions/*.instructions.md` file. If none are found, the existing `Get-DiscoveredInstructionFile` throw for "no instruction files discovered" remains in effect.
  - PowerShell 7+ is available (enforced by existing PSScriptAnalyzer settings).
- Constraints (budget, performance, compatibility):
  - Bundled template must remain byte-identical to root script; both updated in the same commit.
  - Compaction transformations must be deterministic: same input always produces the same output.
- External dependencies (services, libraries, releases):
  - None. No new modules or packages required.

## Data / API / Config Impact
- User-facing or API changes:
  - The `drmCopilotExtension.syncAgentsFromInstructions` command now succeeds in workspaces without `.github/copilot-instructions.md`. No CLI flag changes.
- Data or migration considerations:
  - `AGENTS.md` in the source repo will be regenerated with compacted content. The generated file is not versioned as a stable API; it is regenerated on each run.
- Logging/telemetry updates (if any):
  - None.
- Compatibility notes (CLI flags, config schemas, versioning):
  - The `-RepoRoot` parameter interface is unchanged. The script remains invocable directly via `pwsh -File` or through the VS Code extension command.

## Test Strategy
Seeded from issue:

- [x] Make `.github/copilot-instructions.md` preamble optional: skip preamble section when file is absent, still generate AGENTS.md from discovered instruction files.
- [x] Add compaction logic to reduce repetitive content across instruction files for agent-optimized output.
- [x] Update Pester tests for: missing preamble generates valid output, compaction produces non-repetitive content.
- [x] Ensure bundled template mirror stays in sync with root script.
- [x] Regenerate AGENTS.md in the source repo to validate output.

- Regression tests to add or update:
  - **Update** `"throws when copilot-instructions.md is missing"` (Context: `Get-AgentContent failure paths`): Change from `Should -Throw` to `Should -Not -Throw`. Verify the returned content omits the `## Repository Instructions (GitHub Copilot Canonical)` section and its `<!-- BEGIN/END: copilot-instructions -->` markers.
  - **Update** `"builds AGENTS content with all sections"` (Context: `Get-AgentContent`): Verify copilot section is present when the preamble mock is active. No structural change expected; existing mock provides the preamble file.
  - **Preserve** all `Get-InstructionsBody` tests (4 tests): No changes needed; `Get-InstructionsBody` behavior is unchanged.
  - **Preserve** `Get-DiscoveredInstructionFile` tests (2 tests): The "sorts normalized relative paths" test is unchanged. The "throws when no instruction files discovered" test is unchanged.
  - **Preserve** `Invoke-SyncAgentInstruction` tests (2 tests): Idempotency and write behavior unchanged.
  - **Preserve** bundled parity test: Must pass after both files are updated identically.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - No Python test changes needed. `test_push_down_copilot_customizations_rewrites.py` validates rewrite behavior, not script internals, and is unaffected.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - **New test:** `"generates valid output when copilot-instructions.md is absent"` — Verify output contains section headers from discovered instruction files, does not contain `copilot-instructions` section or markers, and the header source list omits `.github/copilot-instructions.md`.
  - **New test:** `"header omits copilot-instructions.md from source list when absent"` — Verify the `> NOTE: This file is **generated** from:` block lists only the discovered instruction files.
  - **New test:** `"compacted output strips cross-reference boilerplate"` — Verify output does not contain known redundant phrases such as `"This policy **extends**"`, `"You must follow **both**"`, `"halt and notify the user"`.
  - **New test:** `"compacted output consolidates duplicate toolchain commands"` — Verify that each toolchain command string (e.g., `poetry run black .`, `poetry run ruff check`) appears at most once in the output, within the language-specific section where it is authoritative.
  - **New test:** `"compacted output condenses suppression examples"` — Verify that multi-line code-block examples from the suppression policy are reduced; each suppression rule retains its name, required comment format, and a one-line rationale, but full code-block examples are removed.
  - **New test:** `"compacted output removes repeated reading-order statements"` — Verify that the reading-order / authority statement appears only in the `## Repository Setup` section, not repeated in language-specific sections.
- Error handling and logging verification:
  - Verify no exception is thrown when preamble is absent and at least one instruction file exists.
  - Verify the existing throw for "no instruction files discovered" still fires when no `*.instructions.md` files are found.
- Coverage impact and targets for changed lines/modules:
  - All new branches (preamble-absent paths, compaction logic) must be exercised by Pester tests.
- Toolchain commands to run (format → lint → type-check → test):
  1. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  2. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  3. (Type checking not applicable for PowerShell; skip.)
  4. `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- Manual validation steps (if required):
  - After implementation, run `pwsh -File scripts/dev-tools/sync-agents-from-instructions.ps1` from the repo root and verify the regenerated `AGENTS.md` is valid Markdown with compacted content.
  - In a test workspace without `.github/copilot-instructions.md`, run the sync command and verify `AGENTS.md` is generated without the copilot section.


## Acceptance Criteria
- [x] The command succeeds when `.github/copilot-instructions.md` is absent, producing a valid AGENTS.md from discovered instruction files only.
- [x] When `.github/copilot-instructions.md` is present, the full output includes the preamble section (backward compatible).
- [x] The AGENTS.md header source list only includes `.github/copilot-instructions.md` when the file exists.
- [x] Cross-reference boilerplate is stripped from instruction bodies in the consolidated output.
- [x] Duplicate toolchain command lists are consolidated so each command appears once.
- [x] Suppression policy code examples are condensed to rule+comment-format+rationale.
- [x] Repeated reading-order statements are removed from language-specific sections.
- [x] The bundled template at `extensions/drm-copilot/resources/templates/` byte-matches the root script.
- [x] All existing Pester tests pass (updated as needed for the new optional-preamble behavior).
- [x] New Pester tests cover: absent preamble generates valid output, compacted output removes known redundant patterns.
- [x] PoshQC format, analyze, and Pester all pass in a single toolchain loop.

## Risks & Mitigations
- Technical or operational risks:
  - **Compaction regex fragility:** Pattern-based text stripping may inadvertently remove content that appears similar to a redundant pattern but is semantically distinct. Mitigation: Use narrow, anchored regex patterns that match only the exact known boilerplate phrases. Test with the current instruction file corpus to verify no false positives.
  - **Bundled parity drift:** If the root script is modified but the bundled template is not copied, the Pester parity test will fail. Mitigation: The existing parity test enforces this invariant. Implementation instructions explicitly require updating both files in the same commit.
  - **Compaction rules becoming stale:** If instruction files are restructured in the future, compaction patterns may no longer match and stale content may stop being stripped. Mitigation: Compaction tests assert on known patterns; if instruction files change and those patterns disappear, the tests will fail and signal that the compaction rules need updating.
- Mitigations and rollbacks:
  - Both concerns (preamble fix and compaction) are backward compatible; rolling back is a matter of reverting the script changes and regenerating `AGENTS.md`.
  - The regenerated `AGENTS.md` is not consumed as a stable API; it is a developer-facing document that is regenerated on each sync run.

## Rollout & Follow-up
- Release/rollout steps:
  1. Merge the PR with updated root script, bundled template, Pester tests, and regenerated `AGENTS.md`.
  2. Rebuild the VS Code extension VSIX to include the updated bundled template.
  3. Install the updated extension in target workspaces and verify the sync command succeeds with and without the preamble file.
- Post-fix monitoring or clean-up tasks:
  - Verify the `open-claw-bridge` workspace (original repro environment) can successfully generate `AGENTS.md` after installing the updated extension.
  - If additional compaction patterns are identified after initial rollout, they can be added incrementally without breaking existing behavior.
- Links: issue, PRs, related docs
  - Issue: [#120](https://github.com/drmoisan/drm-copilot/issues/120)
  - Research: `docs/features/active/2026-04-05-fix-sync-agents-bundling-120/research.md`
