<!-- markdownlint-disable-file -->

# Task Research Notes: Fix Sync-Agents Bundling (Issue #120)

## Research Executed

### File Analysis

- `scripts/dev-tools/sync-agents-from-instructions.ps1` (290 lines, root production script)
  - Contains 8 functions plus an entry-point invocation block
  - Functions: `Convert-ToDisplayPath`, `Convert-ToNormalizedRelativePath`, `Get-InstructionFileData`, `Get-InstructionsBody`, `Get-SectionKey`, `Get-SectionTitle`, `Get-DiscoveredInstructionFile`, `Get-AgentContent`, `Invoke-SyncAgentInstruction`
- `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` (290 lines, bundled template)
  - Confirmed byte-identical to root script (enforced by Pester parity test)
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (225 lines, Pester test file)
  - 10 test cases across 5 Contexts
- `extensions/drm-copilot/src/extension.ts` (lines 146-160, command registration)
  - `syncAgentsFromInstructions` registered via `executeBundledScript`
- `extensions/drm-copilot/src/command-runtime.ts` (lines 334-413, script execution engine)
  - `executeBundledScriptFromExtensionRoot` resolves script from extension root, detects runtime, spawns process
- `AGENTS.md` (1757 lines, generated output)
  - Verbatim embedding of all 12 instruction files plus copilot-instructions.md preamble
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py` (lines 422-461)
  - One Python test references sync-agents behavior for push-down rewrite validation

### Project Conventions

- Standards referenced: PowerShell Code Change Policy, PowerShell Unit Test Policy, general-code-change policy
- Bundled script parity: enforced by Pester test `"Bundled sync-agents template matches the repo-root script exactly"`
- Toolchain: PoshQC format → PoshQC analyze → Pester (no type-check step for PowerShell)

---

## Preamble Dependency Analysis

Three code locations require `.github/copilot-instructions.md` to exist. If the file is absent, the script throws and produces no output.

### Location 1: `Get-DiscoveredInstructionFile` (line ~168 in root script)

```powershell
$copilotPath = Join-Path $RepoRootParam '.github/copilot-instructions.md'
if (-not (Test-Path -LiteralPath $copilotPath)) {
    throw "Required AGENTS preamble file not found: $(Convert-ToDisplayPath -Path $copilotPath)"
}
```

**Role**: Gate at the start of instruction discovery. This is the crash site reported in the issue.
**Fix needed**: Remove the existence check and throw. Let `Get-AgentContent` handle presence/absence.

### Location 2: `Get-AgentContent` (line ~207 in root script)

```powershell
$copilotPath = Join-Path $RepoRootParam ".github/copilot-instructions.md"
...
$copilotBody = Get-InstructionsBody -Path $copilotPath
```

**Role**: Unconditionally reads the preamble body and constructs a dedicated `## Repository Instructions (GitHub Copilot Canonical)` section. `Get-InstructionsBody` will throw if the file is missing because it calls `Test-Path` internally (line ~102).
**Fix needed**: Guard with `Test-Path` before calling `Get-InstructionsBody`. If absent, set `$copilotBody` to empty and skip the copilot section block.

### Location 3: `Get-AgentContent` header source list (line ~243 in root script)

```powershell
$headerSourceLines = @('.github/copilot-instructions.md') + $instructionFiles.RelativePath
```

**Role**: Always includes `.github/copilot-instructions.md` in the generated `> NOTE: This file is **generated** from:` header, even if the file does not exist.
**Fix needed**: Conditionally include `.github/copilot-instructions.md` in `$headerSourceLines` only when the file existed.

### Location 4: `Get-AgentContent` copilot section assembly (line ~228 in root script)

```powershell
$copilotSection = @"
## Repository Instructions (GitHub Copilot Canonical)

<!-- BEGIN: copilot-instructions -->
$copilotBody

<!-- END: copilot-instructions -->

"@
```

**Role**: Always emits the copilot-instructions section block.
**Fix needed**: Build `$copilotSection` only when preamble exists; otherwise set to empty string.

### Location 5: Header instruction text (line ~258)

```powershell
> To update policies, edit the source *.instructions.md files and
> `.github/copilot-instructions.md`, then run:
```

**Fix needed**: Omit mention of `.github/copilot-instructions.md` when it does not exist.

---

## Compaction Opportunity Analysis

The current AGENTS.md is 1757 lines. Each instruction file body is embedded verbatim with no deduplication. The following specific repetitive patterns were identified:

### Pattern 1: Cross-reference boilerplate (11 occurrences)

Statements like these appear in 6 distinct policy sections:
- `"This policy **extends** general-code-change.instructions.md"` (4 occurrences)
- `"You must follow **both**:"` (2 occurrences)
- `"halt and notify the user"` (5 occurrences)

In a consolidated AGENTS.md these are redundant because all policies are already in a single document. The reader does not need to be told to follow both policies when both are inline.

### Pattern 2: Repeated "reading order / authority" statements

- general-code-change section: `"Apply this general policy first, then any language-specific code-change instructions, then any unit-test addenda."`
- Repository Setup section: `"For coding and testing policies, always follow the sections below in the order: Copilot instructions → general policies → language-specific policies → CI policies."`

These convey the same precedence rule.

### Pattern 3: Repeated toolchain commands

- general-code-change `## 8. After Making Changes` defines the abstract format/lint/type-check/test loop (~70 lines)
- python-code-change `## 1. Tooling & Baseline` re-specifies the same tools with exact commands (Black, Ruff, Pyright) (~50 lines)
- python-unit-test `## 4. Respecting the Toolchain Loop` restates the Pytest command (~10 lines)
- powershell-code-change `## 4. Running the Toolchain` restates the PoshQC equivalents (~20 lines)
- powershell-unit-test `## 4. Running the Toolchain (PowerShell Tests)` restates PoshQC test (~10 lines)

Total overlap: ~160 lines of near-duplicate toolchain instructions.

### Pattern 4: Design principle restatement

- general-code-change `## 1. Design Principles`, `## 2. Classes, Functions, and APIs`, `## 3. Error Handling` (~100 lines)
- python-code-change `## 2. Python Design & Typing Principles`, `## 3. Classes...`, `## 4. Error Handling` explicitly refine the same topics with mostly restated structure headers (~120 lines)

### Pattern 5: Suppression policy verbosity

- `python-suppressions` section: ~500 lines of detailed code examples, required patterns, justifications, non-authorized workarounds
- This is the single largest section (~28% of total AGENTS.md)
- Contains full multi-line code blocks for each pattern that could be condensed to table format

### Compaction Estimate

Conservative estimate: 400-600 lines could be removed through:
- Removing cross-reference boilerplate that is redundant in a consolidated doc
- Consolidating duplicate toolchain instructions into a single reference table
- Condensing suppression policy code examples (keep rule, comment format, one-line rationale; remove full code blocks)
- Removing repeated "halt and notify" and "extends" preambles

---

## Test Surface Analysis

### Existing Pester Tests (10 test cases in 5 Contexts)

| Context | Test Name | What It Asserts | Impact of Fix |
|---------|-----------|-----------------|---------------|
| `Get-InstructionsBody` | `throws when file is missing` | `Get-InstructionsBody` throws for missing path | No change needed |
| `Get-InstructionsBody` | `returns trimmed content without frontmatter` | Strips YAML frontmatter, returns trimmed body | No change needed |
| `Get-InstructionsBody` | `returns empty string for empty file` | Null content → empty string | No change needed |
| `Get-InstructionsBody` | `returns empty string for file with only frontmatter` | Frontmatter-only → empty string | No change needed |
| `Get-AgentContent failure paths` | `throws when copilot-instructions.md is missing` | **Expects throw when preamble missing** | **Must be updated**: change to expect success, output without copilot section |
| `Get-DiscoveredInstructionFile` | `throws when no instruction files discovered` | Empty `.github` → throw | No change needed |
| `Get-DiscoveredInstructionFile` | `sorts normalized relative paths ordinally` | Ordinal sort of discovered files | No change needed |
| `Get-AgentContent` | `includes newly added .instructions.md without allowlist` | New files automatically appear | No change needed (but copilot section now optional) |
| `Get-AgentContent` | `builds AGENTS content with all sections` | Checks copilot body + all section bodies present | **Must be updated**: copilot body check should be conditional |
| `Invoke-SyncAgentInstruction` | `produces identical content on repeated runs` | Idempotency check | **May need update** if header changes |
| `Invoke-SyncAgentInstruction` | `writes generated content to AGENTS.md` | `Set-Content` called with correct params | No change needed |
| `Bundled parity` | `Bundled template matches repo-root script exactly` | Byte-identical bundled ↔ root | **Constraint**: both files must be updated together |

### Tests Requiring Changes

1. **`"throws when copilot-instructions.md is missing"`**: Must change from `Should -Throw` to `Should -Not -Throw` and verify the output omits the copilot section.
2. **`"builds AGENTS content with all sections"`**: Must remain valid; the copilot body mock is still provided, so this test should pass as-is if the conditional logic correctly includes the section when present.
3. **New tests needed**:
   - `"generates valid output when copilot-instructions.md is absent"` (no copilot section, no copilot in source list, valid markdown)
   - `"header omits copilot-instructions.md from source list when absent"`
   - Compaction-related tests (if compaction logic is added)

### Bundled Parity Test Constraint

```powershell
It "Bundled sync-agents template matches the repo-root script exactly" {
    $bundledTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\extensions\drm-copilot\resources\templates\sync-agents-from-instructions.ps1"
    (Test-Path -LiteralPath $bundledTemplatePath) | Should -BeTrue
    (Get-Content -Raw -LiteralPath $bundledTemplatePath) | Should -Be (Get-Content -Raw -LiteralPath $script:scriptPath)
}
```

This enforces byte-exact equality between:
- `scripts/dev-tools/sync-agents-from-instructions.ps1`
- `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`

Both files must be modified identically in the same commit.

### Python Test Dependency

`test_push_down_copilot_customizations_rewrites.py::test_sync_agents_script_reference_rewrites_to_live_command` (line 422):
- Tests that push-down rewrite replaces `sync-agents-from-instructions.ps1` references with the live extension command
- Asserts on output text containing `"Sync AGENTS.md from Instructions"` and `"drmCopilotExtension.syncAgentsFromInstructions"`
- **No impact** from this fix: the test validates push-down rewriting, not the script's internal behavior

---

## Extension Integration Analysis

### Command Registration (`extension.ts` lines 146-160)

```typescript
const syncAgentsFromInstructionsDisposable = vscode.commands.registerCommand(
  "drmCopilotExtension.syncAgentsFromInstructions",
  async () => {
    const commandId = "drmCopilotExtension.syncAgentsFromInstructions";
    const workspaceRoot = getWorkspaceRoot();
    await executeBundledScript(context, output, {
      runtimeKind: "powershell",
      bundledRelativePath: "resources/templates/sync-agents-from-instructions.ps1",
      commandId,
      args: ["-RepoRoot", workspaceRoot],
    });
  },
);
```

Key observations:
- The command passes `-RepoRoot` pointing to the active VS Code workspace folder
- `executeBundledScript` resolves the script from the **extension's install directory** (not the workspace)
- The script is spawned as a child process via `pwsh`; errors surface as non-zero exit codes + stderr
- **No extension-side changes needed** for the preamble fix; the fix is entirely in the PowerShell script
- Error handling in `executeBundledScriptFromExtensionRoot` catches `CommandExecutionError` and surfaces stderr via `getStderrExcerpt`

### Script Resolution

`executeBundledScript` → `executeBundledScriptFromExtensionRoot`:
1. Detects PowerShell runtime via `detectRuntime("powershell")`
2. Resolves script path: `resolveBundledScriptPath(extensionRoot, "resources/templates/sync-agents-from-instructions.ps1")`
3. Spawns: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File <resolved_path> -RepoRoot <workspaceRoot>`
4. Captures stdout/stderr and exit code

---

## Recommended Fix Strategy

### Step 1: Make preamble optional in `Get-DiscoveredInstructionFile`

Remove the hard gate at lines 168-170 that throws when `.github/copilot-instructions.md` is absent. The function's responsibility is discovering `*.instructions.md` files, not validating the preamble.

### Step 2: Make preamble optional in `Get-AgentContent`

Add a `Test-Path` guard before calling `Get-InstructionsBody`. When the preamble is absent:
- Set `$copilotBody` to `$null`
- Set `$copilotSection` to empty string
- Exclude `.github/copilot-instructions.md` from `$headerSourceLines`
- Omit the copilot-instructions mention from the header instruction text

When the preamble is present, behavior is unchanged.

### Step 3: Update Pester tests

- Change `"throws when copilot-instructions.md is missing"` to verify successful generation without the copilot section
- Add new test: `"generates output without copilot section when preamble is absent"`
- Add new test: `"header source list omits copilot-instructions.md when absent"`
- Existing tests that mock preamble presence should continue to pass

### Step 4: Copy root script to bundled template

After modifying `scripts/dev-tools/sync-agents-from-instructions.ps1`, copy it byte-for-byte to `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` to satisfy the parity test.

### Step 5: Compaction (separate concern, may be deferred)

Compaction is a distinct feature from the crash fix. If addressed in the same PR:
- Add a compaction pass in `Get-AgentContent` that strips known redundant patterns (cross-reference boilerplate, duplicate toolchain instructions)
- This requires careful Pester testing of both compacted and non-compacted output
- Risk: compaction rules are subjective and may diverge from user expectations

**Recommendation**: Fix the crash (Steps 1-4) as the primary deliverable. Evaluate compaction scope with the user before implementing.

### Step 6: Regenerate AGENTS.md

Run `pwsh -File scripts/dev-tools/sync-agents-from-instructions.ps1` from the repo root to regenerate `AGENTS.md` and verify the output.

### Step 7: Run full PowerShell toolchain

1. PoshQC format
2. PoshQC analyze
3. PoshQC test (Pester)

All must pass cleanly in a single loop iteration.

## Implementation Guidance

- **Objectives**: Eliminate crash when preamble is absent; produce valid AGENTS.md from instruction files only; maintain bundled parity
- **Key Tasks**: Modify 2 files (root script + bundled template, kept identical), update 1 test file
- **Dependencies**: No new dependencies; no extension code changes required
- **Success Criteria**: Command succeeds in workspaces without `.github/copilot-instructions.md`; existing behavior preserved when preamble exists; all Pester tests pass; bundled parity test passes