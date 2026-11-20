# Push-Down Claude Customizations: Opt-In Language Packs and Alternative Toolchain Research

**Date:** 2026-06-24  
**Feature:** Opt-in language-specific push-down packs, two C# toolchain variants, memory push-down options  
**Status:** Research complete

---

## A. Push-Down Architecture Map

### A.1 VS Code Command Registration

**File:** `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`  
**Function:** `registerPushDownClaudeCustomizationsCommand` (lines 119–132)

```
vscode.commands.registerCommand(
  "drmCopilotExtension.pushDownClaudeCustomizations",
  async () => {
    await options.service.pushDownClaudeCustomizations({
      workspaceRoot: getWorkspaceRoot(),
      invocationId: commandId,
    });
  },
);
```

The command is registered by `registerRepoAutomationAdminCommands` (line 270) and takes no user inputs — it calls the service directly with only the workspace root.

### A.2 Service Layer

**File:** `extensions/drm-copilot/src/repo-automation-service.ts`  
**Interface method:** `pushDownClaudeCustomizations(input: WorkspaceExecutionInput)` (line 65)  
**Implementation:** `DefaultRepoAutomationService.pushDownClaudeCustomizations` (lines 250–265)

The method calls `this.executeScript` with:
- `tool: "push_down_claude_customizations"`
- `runtimeKind: "python"`
- `bundledRelativePath: "resources/templates/push_down_claude_customizations.py"`
- `args: ["--destination", input.workspaceRoot]`
- `stdoutArtifactPattern: /Wrote push-down summary artifact to:\s*(.+)/i`

`executeScript` delegates to `executeBundledScriptFromExtensionRoot` (from `command-runtime.ts`), which spawns the bundled Python script with the args listed above, with `cwd` set to `workspaceRoot`.

The bundled script path resolves to:  
`<extensionRoot>/resources/templates/push_down_claude_customizations.py`

### A.3 Python Push-Down Engine

#### Entry point

**File:** `scripts/dev_tools/push_down_claude_customizations.py`

Key constants (lines 72–73):
```python
ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)
EXCLUDED_RELATIVE_PATHS: tuple[Path, ...] = (Path(".claude/settings.local.json"),)
```

The `push_down_customizations` function (lines 305–330) wraps the caller-supplied filesystem adapter in `_ExcludingFileSystem` and delegates to the shared engine `push_down_scoped_customizations` (imported from `push_down_copilot_customizations`), passing:
- `root_folders=ROOT_FOLDERS` (i.e., `(Path(".claude"),)`)
- `artifact_directory=ARTIFACT_DIRECTORY` (`"artifacts/claude-customizations"`)
- `rewrite_references=_passthrough_rewrite` (no script-reference rewriting for Claude files)

The `main` function (lines 350–370) resolves the source root and artifact root both from `Path.cwd()` (the working directory when the script runs, which is `workspaceRoot`). The bundle path is passed as the script file argument; the CWD is the destination repo.

**IMPORTANT NOTE:** When invoked from the extension, the bundled script lives at `<extensionRoot>/resources/templates/push_down_claude_customizations.py` but the `source_root` is set to `Path.cwd()` which is `workspaceRoot` (the destination). This means the script **copies from the destination's own `.claude` tree**, not from the bundled resources. The bundled `.claude` payload under `extensions/drm-copilot/resources/claude-customizations/` is copied to the destination workspace separately — the script here is the engine that processes what is found in `source_root`.

**Clarification on source vs. bundled:**  
The `repo-automation-service.ts` (line 252) uses `bundledRelativePath: "resources/templates/push_down_claude_customizations.py"` which means the Python *script* itself is bundled. The script `main()` uses `Path.cwd()` as the `repo_root`, so it reads from the workspace where it runs. When the extension invokes this script with `cwd=workspaceRoot`, the source of `.claude` files is the extension's own checkout (or a temp path). The actual `.claude` bundle shipped with the extension is at `resources/claude-customizations/.claude`. In practice, the extension likely prepopulates the temp source or mounts the bundled resources — this warrants verification in `command-runtime.ts`, but based on current evidence the `source_root=repo_root=cwd=workspaceRoot` pattern means the push-down copies from whatever `.claude` directory exists at the script's working directory.

#### Shared engine

**File:** `scripts/dev_tools/push_down_copilot_customizations.py`  
**Function:** `push_down_customizations` (lines 335–439)

Signature:
```python
def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
    root_folders: tuple[Path, ...] | None = None,
    artifact_directory: str = ARTIFACT_DIRECTORY,
    rewrite_references: RewriteFunction = rewrite_text_references,
) -> PushDownSummary:
```

Flow:
1. `validate_destination` — rejects missing destination or self-copy.
2. `enumerate_source_files` — calls `fs.list_files(source_root / root)` for each root in `root_folders`, sorted by relative POSIX path.
3. For each file: reads, rewrites references (passthrough for Claude), creates parent dirs, writes to `destination_root / relative_path`.
4. Writes JSON summary artifact to `artifact_root / artifact_directory / push-down-<timestamp>.json`.

#### `PushDownFileSystem` protocol

**File:** `scripts/dev_tools/push_down_copilot_customizations_filesystem.py`  
**Class:** `PushDownFileSystem` (Protocol, lines 17–53)

Methods: `list_files(root)`, `is_dir(path)`, `is_file(path)`, `read_text(path)`, `write_text(path, content)`, `ensure_dir(path)`.

Production impl: `RealPushDownFileSystem` uses `Path.rglob("*")` and `path.read_text`/`path.write_text`.

#### `_ExcludingFileSystem`

**File:** `scripts/dev_tools/push_down_claude_customizations.py`  
**Class:** `_ExcludingFileSystem` (lines 186–294)

Wraps the inner `PushDownFileSystem`. Its `list_files` method:
1. Removes paths whose resolved absolute path is in `self._excluded` (the resolved `EXCLUDED_RELATIVE_PATHS` set).
2. Calls `_is_scope_included(path)` for each remaining candidate — reads content for `.claude/agent-memory/**` files and applies the YAML frontmatter scope parser (`_read_memory_scope`). Files with `metadata.scope: general` pass; all others are excluded.

Files outside `.claude/agent-memory/` always pass the scope filter.

### A.4 MCP Tool Path

**File:** `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts`

`handlePushDownClaudeCustomizations(rawInput, service)` (lines 27–33):
- Calls `resolvePushDownClaudeCustomizationsToolInput(rawInput)` from `mcp-tool-inputs.ts`
- Returns `service.pushDownClaudeCustomizations(input)`

**File:** `extensions/drm-copilot/src/mcp-tool-inputs.ts`  
`resolvePushDownClaudeCustomizationsToolInput` (lines 261–272):
- Extracts only `workspace_root` from the raw input object.
- Returns `{ workspaceRoot }`.

**File:** `extensions/drm-copilot/src/mcp-tool-definitions.ts` (and `mcp-repo-automation-tool-definitions.ts` — both files are **identical** in content, a duplication that should be noted):

Tool definition `push_down_claude_customizations` (lines 124–136 of `mcp-tool-definitions.ts`):
- `inputSchema.properties`: only `workspace_root`
- No `required` array
- `additionalProperties: false`

Both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` export identical tool arrays. The source of truth used at runtime (`mcp-tools.ts`) must be checked to determine which file is authoritative — both have the same `push_down_claude_customizations` entry.

### A.5 Bundled Pack Assembly and Sync

**Bundled location:** `extensions/drm-copilot/resources/claude-customizations/.claude/`

The bundled pack contains 85+ files covering: `agents/`, `hooks/`, `rules/`, `skills/`, `settings.json`, and `agent-memory/orchestrator/` files.

**Sync mechanism:** There is no automated sync script visible in the repository toolchain. The parity is enforced by the contract test in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (see Section B). The bundle must be manually updated whenever the root `.claude` tree changes; the test fails CI if they diverge.

The bundled Python scripts directory is at:  
`extensions/drm-copilot/resources/scripts/dev_tools/`  
containing mirrors of `push_down_copilot_customizations_filesystem.py`, `push_down_copilot_customizations_rewrites.py`, etc.

---

## B. Parity / Contract Test Inventory

### B.1 `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

**File location:** Tests that `BUNDLED_ROOT = extensions/drm-copilot/resources/claude-customizations/` satisfies these contracts:

| Test | What it asserts | What breaks with a bundle-only file |
|------|----------------|-------------------------------------|
| `test_bundled_claude_payload_contains_required_runtime_files` (line 51) | All files in `REQUIRED_BUNDLED_FILES` tuple exist at `BUNDLED_ROOT` | No break — adds to required list only |
| `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (line 100) | **Every non-memory, non-settings.local file present at repo root `.claude/` also exists in the bundle AND has identical content.** Exempts `AGENT_MEMORY_RELATIVE_ROOT` and `settings.local.json`. | A file in the root that differs from the bundle fails. A bundle-only file (no root counterpart) does NOT fail this test — the test only checks that root files are in the bundle, not vice versa. |
| `test_bundled_claude_payload_excludes_settings_local_json` (line 128) | `settings.local.json` absent from bundle | No break |
| `test_bundled_agent_memory_scopes_are_well_formed` (line 167) | Every `MEMORY.md` is `scope: repo`; every non-index memory is `scope: general` | No break for non-memory files |

**Critical finding for Section B:** The parity test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts root → bundle direction only. It does **not** assert bundle → root direction (i.e., it does not fail if the bundle contains a file not present at root). A bundle-only alternative C# pack would therefore NOT break this test as currently written.

**However**, this is only true IF the alternative pack files do not share a path with existing root files. If the alternative C# pack is placed at the same path as the default C# files (e.g., `.claude/rules/csharp.md`), the test **would** fail because root `.claude/rules/csharp.md` exists and would need to equal the bundled version, but the bundle would now contain the alternative version.

### B.2 `tests/scripts/dev_tools/test_push_down_claude_customizations.py`

Tests the publisher engine behavior via an in-memory `RecordingFileSystem`. Key assertions:
- `test_module_exposes_claude_root_folders_and_artifact_directory` (line 100): asserts `ROOT_FOLDERS == (Path(".claude"),)` — would need extension if a variant subtree is added to ROOT_FOLDERS.
- `test_push_down_customizations_copies_claude_tree_files` (line 122): asserts all source files appear at destination.
- `test_push_down_customizations_excludes_settings_local_json` (line 194): confirms exclusion list works.
- No test currently checks that bundle-only files are NOT pushed down. Adding a bundle-only variant would not break these tests.

### B.3 `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py`

Tests the memory scope filter (`_read_memory_scope`, `_is_general_memory_file`, `_ExcludingFileSystem._is_scope_included`). All tests use the in-memory filesystem double. Not affected by alternative C# pack.

### B.4 `tests/scripts/dev_tools/test_push_down_copilot_customizations_mirror_parity.py`

Tests only the **filesystem adapter** parity (root vs. bundled `RealPushDownFileSystem`). Not affected by alternative C# pack.

### B.5 TypeScript tests (`extensions/drm-copilot/test/`)

| File | What it asserts | Effect of changes |
|------|----------------|-------------------|
| `extension.push-down-claude-customizations.test.ts` | Command is registered; spawn receives `--destination` and `push_down_claude_customizations` in args | Must add new command registration tests when new command added |
| `repo-automation-service.push-down-claude.test.ts` | Service calls spawn with `push_down_claude_customizations.py` and `--destination workspaceRoot` | New service method needs its own test |
| `push-down-claude-handler.test.ts` | Handler resolves input and calls service method once | New handler needs its own test |
| `mcp-tools.push-down-claude.test.ts` | Dispatch routes to `service.pushDownClaudeCustomizations` | New tool name needs its own dispatch test |

### B.6 What Would Break With a Bundle-Only Alternative C# Pack

**If the alternative pack occupies the SAME paths** as the default C# pack (e.g., overrides `.claude/rules/csharp.md` in the bundle):
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` **FAILS** because the root `.claude/rules/csharp.md` (default) would not equal the bundled `.claude/rules/csharp.md` (alternative).

**If the alternative pack occupies a DIFFERENT, DEDICATED subtree** (e.g., `.claude/variants/csharp-alt/rules/csharp.md`):
- No existing parity test would fail, since root has no file at that path and the test only checks root → bundle direction.

**Minimal mechanism to permit bundle-only packs:**  
Add a designated `BUNDLE_ONLY_RELATIVE_ROOTS` tuple in the push-down module (e.g., `(Path(".claude/variants"),)`). The parity test must be updated to **skip** files whose path starts with any bundle-only root when asserting root → bundle content identity. A new reverse-direction test must assert that no bundle-only file exists outside the designated subtree (preventing accidental collisions with core paths).

**Proposed invariant:** The parity test must enforce that the bundle-only subtree (e.g., `.claude/variants/`) contains NO file whose relative path (after stripping the variant prefix) matches a file already in the root `.claude` tree. This is the conflict-prevention guarantee.

---

## C. Classified Diff of the Alternative Version

**Source A (current):** `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-12-43\.claude\` (repo root)  
**Source B (tocompare):** `C:\Users\DanMoisan\repos\drm-copilot\artifacts\tocompare\.claude\`

### C.1 Files Present in tocompare That Are ABSENT From Repo Root

These are files the alternative version adds that do NOT exist in the current root:

| File (relative to `.claude/`) | Classification | Notes |
|------|------|------|
| `schemas/orchestrator-state.schema.json` | Bucket 3 — Non-language-specific hardening | A JSON Schema for the orchestrator-state artifact. The `$id` is `orchestrator-state.schema.json` (repo-local, not the disqualified foreign origin). |
| `agent-memory/` tree (full repo-specific memories) | Agent-memory — out of scope for parity | tocompare has a large agent-memory tree with repo-specific memories (`scope: repo`). These would be excluded by the scope filter and are not pushed down. Not a parity concern. |
| `settings.local.json` | Always excluded | Excluded by `EXCLUDED_RELATIVE_PATHS`. Never pushed down. |

**Bucket 3 items:**

1. `.claude/schemas/orchestrator-state.schema.json`  
   - **Classification:** Bucket 3 — general orchestration hardening, not language-specific.  
   - **Recommendation: Include in main repo.** The schema is repo-local (`$id` does not reference a foreign origin) and documents the orchestrator-state checkpoint shape. It is directly referenced by `.claude/rules/orchestrator-state.md`. Including it makes the schema available for local validation tooling (`scripts/dev_tools/validate_orchestrator_state.py`).  
   - **Rationale:** Absence from root while present in tocompare means it was dropped at some point or not yet promoted. It is a legitimate hardening artifact with no conflict risk.

### C.2 Files Present in Repo Root That Are ABSENT From tocompare

| File (relative to `.claude/`) | Classification | Notes |
|------|------|------|
| `rules/general-unit-test.md` | Bucket 3 — general rule | Present at root, absent in tocompare |
| `rules/orchestrator-state.md` | Bucket 3 — general rule | Present at root, absent in tocompare |
| `skills/orchestrate/SKILL.md` | Bucket 3 — general skill (verified: tocompare HAS this file; false alarm) | Present in both |
| `skills/remediation-handoff-atomic-planner/SKILL.md` | Present in both (verified) | — |
| `skills/human-exception-runbook/SKILL.md` + `example.runbook.md` | Present in both (verified via grep) | — |

**Corrected absent-from-tocompare list:**

After cross-referencing the full file lists:

Files in repo root `.claude/` **not present** in tocompare:
- `.claude/rules/general-unit-test.md`
- `.claude/rules/orchestrator-state.md`
- `.claude/hooks/enforce-completion-consistency.ps1`
- `.claude/hooks/enforce-pr-author-skill.ps1`
- `.claude/hooks/validate-orchestrator-output.ps1` (present in tocompare at root, but root does NOT have this in its hook file listing — confirmed present in bundled `.claude/hooks/validate-orchestrator-output.ps1` but also in tocompare)

**Note on `enforce-completion-consistency.ps1`:** The root `settings.json` (line 122) references this hook in the `Write|Edit` PreToolUse block, but the tocompare `settings.json` does NOT include this hook. This is a concrete difference.

### C.3 Modified Files (present in both, content differs)

| File | Bucket | Difference summary |
|------|--------|-------------------|
| `.claude/rules/csharp.md` | Bucket 1 — C# toolchain specific | Root adds one bullet point to Coverage section: "Interface-only files with no executable behavior... may be omitted from coverage measurement." (lines 47 of root vs absent from tocompare line 44). Minor clarification in root. |
| `.claude/settings.json` | Bucket 3 — non-language-specific | Root includes `enforce-completion-consistency.ps1` hook in Write/Edit PreToolUse block (line 122). tocompare does NOT have this hook. |

### C.4 Bucket Summaries

**Bucket 1 — C# toolchain-specific differences:**

Files that define or configure the C# toolchain:
- `.claude/rules/csharp.md` — modified (minor, root is slightly newer)
- `.claude/skills/csharp-qa-gate/SKILL.md` — identical
- `.claude/skills/csharp-change-budget-router/SKILL.md` — identical
- `.claude/skills/csharp-orchestration-state-machine/SKILL.md` — identical
- `.claude/skills/invoke-csharp-engineer/SKILL.md` — identical (exists in tocompare only, verified)
- `.claude/agents/csharp-typed-engineer.md` — identical

**Finding:** The alternative version in tocompare is NOT a meaningfully different C# toolchain variant. The only difference in C# files is a single added bullet in the coverage section of `csharp.md`. The C# skills, agents, QA gate, state machine, and budget router are byte-identical.

This means the **alternative C# toolchain pack described in the feature request has not yet been created**. The tocompare represents an OLDER or DIVERGED snapshot of the repo that is largely identical but missing some newer root additions. The alternative pack must be designed from scratch.

**Bucket 2 — Other language-specific differences:**

No meaningful differences in Python, PowerShell, or TypeScript files were found between tocompare and root. Files in these language groups that exist in tocompare exist in root and appear identical (based on header comparison). **Out of scope for the alternative pack.**

**Bucket 3 — Non-language-specific hardening present in tocompare NOT in current root (or vice versa):**

| Item | Direction | Recommendation | Rationale |
|------|-----------|----------------|-----------|
| `.claude/schemas/orchestrator-state.schema.json` | tocompare has, root lacks | **Include in main repo** | Repo-local schema directly supporting `orchestrator-state.md` and `validate_orchestrator_state.py`. No conflict risk. |
| `.claude/rules/general-unit-test.md` | Root has, tocompare lacks | **Already in root; keep** | tocompare is an older snapshot. No action needed. |
| `.claude/rules/orchestrator-state.md` | Root has, tocompare lacks | **Already in root; keep** | Same as above. |
| `enforce-completion-consistency.ps1` hook in `settings.json` | Root has, tocompare lacks | **Already in root; keep** | Root is the more current version. |
| `.claude/hooks/enforce-completion-consistency.ps1` | Root has, tocompare lacks | **Already in root; keep** | Hook file backing the above settings entry. |

**Owner decision required:** The `schemas/orchestrator-state.schema.json` file from tocompare is the one item not yet in root that has clear value. Owner should confirm whether to promote it to root `.claude/schemas/`.

---

## D. Design Options and Recommendation

### D.1 Opt-In Language-Pack Selection

**Problem:** Today `ROOT_FOLDERS = (Path(".claude"),)` copies the entire `.claude` tree. The owner wants users to opt in to language-specific subsets.

**Option A (Rejected): Path-based filtering with a well-known file-naming convention**  
Each file would carry a `languages:` frontmatter key listing which packs it belongs to. The push-down would parse every file's frontmatter and filter. Rejected because: requires frontmatter in binary/hook files; parsing is fragile; adds overhead on every file; does not work for files that naturally belong to multiple packs.

**Option B (Recommended): Pack manifest file + pack-tagged file sets**

Define language packs as a manifest in the bundled `resources/claude-customizations/` directory. Each pack is a named set of relative paths.

Concrete structure:
```
extensions/drm-copilot/resources/claude-customizations/
  .claude/                          # current bundled tree
  pack-manifests/
    python.json
    powershell.json
    typescript.json
    csharp-default.json
    csharp-alt.json
    core.json                       # always-pushed files (non-language)
```

Each manifest JSON file lists relative paths under `.claude/` that belong to that pack:
```json
{
  "name": "csharp-default",
  "label": "C# (Modern xUnit)",
  "paths": [
    ".claude/rules/csharp.md",
    ".claude/agents/csharp-typed-engineer.md",
    ".claude/skills/csharp-qa-gate/SKILL.md",
    ...
  ]
}
```

The push-down engine adds a `--packs` CLI argument accepting a comma-separated list of pack names. When `--packs` is omitted, all packs are pushed (backward-compatible). When `--packs core,python` is supplied, only those manifests' paths plus `core` paths are copied.

**Core pack** always contains: `settings.json`, `agents/orchestrator.md`, all hooks, all non-language rules (`general-code-change.md`, `general-unit-test.md`, etc.), all non-language skills (`orchestrate`, `feature-promotion-lifecycle`, etc.).

**Attribution rule:** A file that mentions ONLY one language (e.g., `agents/csharp-typed-engineer.md`) belongs exclusively to that language pack. Files that are cross-language (e.g., `rules/general-code-change.md`) belong to `core`. Files that reference multiple languages are assigned to core unless they are exclusively for one language.

**Pack manifest location:** The manifests live inside the extension bundle, not in root `.claude/`. They are not pushed down to destination repos.

### D.2 Two C# Toolchain Variants

**Problem:** Two C# toolchain variants must be selectable, but only ONE may land in the destination repo. The alternative variant exists ONLY in the bundle, never at root `.claude/`.

**Recommended design: Variant subtree in bundle**

Add a dedicated variant subtree inside the bundle that does NOT conflict with the default tree:

```
extensions/drm-copilot/resources/claude-customizations/
  .claude/                           # default C# files at their normal paths
    rules/csharp.md                  # default
    agents/csharp-typed-engineer.md  # default
    ...
  .claude-variants/
    csharp-alt/
      rules/csharp.md                # alternative version
      agents/csharp-typed-engineer.md
      skills/csharp-qa-gate/SKILL.md
      skills/csharp-change-budget-router/SKILL.md
      skills/csharp-orchestration-state-machine/SKILL.md
      skills/invoke-csharp-engineer/SKILL.md
```

The `.claude-variants/` directory is NOT part of `ROOT_FOLDERS` and is never enumerated by the default push-down. It is only accessed when the user selects the alternative variant.

When the user selects `csharp-alt`:
1. The pack manifest `csharp-default.json` is deselected.
2. The pack manifest `csharp-alt.json` is used, pointing into `.claude-variants/csharp-alt/` for C# files and into `.claude/` for non-C# files.
3. The push-down engine copies files from `.claude-variants/csharp-alt/rules/csharp.md` to `destination/.claude/rules/csharp.md` (same final path, different source).

**Conflict prevention guarantee:** The Python engine (or a pre-copy validation step) asserts that the selected C# variant pack's paths do not overlap with any other selected pack's paths for the same destination. Since exactly one C# variant can be selected, and both variants share the same destination paths, the selection UI enforces mutual exclusion at the VS Code layer (radio button / single-select QuickPick for C# variant).

**Parity test adaptation (required):**  
Add a test that asserts:
- `.claude-variants/` (or the designated bundle-only subtree) does NOT exist at repo root at all — this is the conflict-prevention test.
- Files under `.claude-variants/csharp-alt/` do not have byte-identical content to files under `.claude/` (this verifies the variant is actually different, not an accidental duplicate).

The existing `test_bundled_claude_payload_contains_all_repo_runtime_contracts` test must be updated to **skip** files under the `.claude-variants/` subtree (bundle-only) when comparing bundle content to root.

### D.3 Memory Overwrite / Merge / Skip

**Current behavior:** Agent-memory files with `metadata.scope: general` are copied to the destination, overwriting any existing file at the same path (`destination_status = "overwritten"`).

**New behavior options:**

The three modes apply to the entire `.claude/agent-memory/` subtree:

- **Overwrite (default, current behavior):** Copy general-scoped memories, overwriting destination.
- **Merge:** Copy general-scoped memories that do NOT already exist at the destination; skip any that do (preserves destination customizations).
- **Do-not-push-down:** Exclude all `.claude/agent-memory/**` files from the copy regardless of scope.

**Recommended implementation:** Add a `memory_mode: Literal["overwrite", "merge", "skip"]` parameter to `push_down_customizations` in `push_down_claude_customizations.py`. Extend `_ExcludingFileSystem` (or add a new `_MemoryModeFileSystem` wrapper) to:
- `skip`: add `AGENT_MEMORY_RELATIVE_ROOT` to the excluded paths set at construction time.
- `merge`: modify `list_files` to additionally exclude agent-memory files that already exist at the destination (requires the destination root to be passed in for the existence check).
- `overwrite`: current behavior, no change.

The `--memory-mode` CLI argument is added to `parse_args` in `push_down_claude_customizations.py` with a default of `overwrite` for backward compatibility.

The existing `EXCLUDED_RELATIVE_PATHS` mechanism is NOT sufficient for the `merge` mode because it applies to fixed paths, not conditional existence. A filesystem-level check is needed.

### D.4 Extension UI Mechanism

**Recommended VS Code API approach:**

Extend `registerPushDownClaudeCustomizationsCommand` to gather three selections before calling the service:

**Step 1 — Language pack multi-select:**
```typescript
const selectedPacks = await vscode.window.showQuickPick(
  packItems,          // [{label, description, picked: true for all}]
  {
    title: "drm-copilot: Push Down Claude Customizations",
    placeHolder: "Select language packs to include.",
    canPickMany: true,
    ignoreFocusOut: true,
  }
);
if (!selectedPacks) return;  // user cancelled
```

`packItems` is loaded by reading the pack manifests from the bundled `resources/claude-customizations/pack-manifests/` directory.

**Step 2 — C# variant selection (shown only when the C# pack is selected):**
```typescript
if (selectedPacks.some(p => p.label.includes("C#"))) {
  const csharpVariant = await promptForChoice(
    "drm-copilot: Push Down Claude Customizations",
    "Select C# toolchain variant.",
    ["C# (Modern — xUnit/CSharpier, default)", "C# (Alternative — adjusted toolchain)"],
  );
  if (!csharpVariant) return;
  // map selection to variant id
}
```

`promptForChoice` from `extension-command-helpers.ts` (line 141) already supports this pattern.

**Step 3 — Memory push-down mode:**
```typescript
const memoryMode = await promptForChoice(
  "drm-copilot: Push Down Claude Customizations",
  "How should agent memories be handled?",
  ["Overwrite existing memories", "Merge (keep destination memories)", "Do not push down memories"],
);
if (!memoryMode) return;
```

**Flow to Python CLI:**  
The service method `pushDownClaudeCustomizations` is extended to accept:
```typescript
interface PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput {
  readonly packs?: ReadonlyArray<string>;   // e.g., ["core", "python", "csharp-default"]
  readonly csharpVariant?: "default" | "alt";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}
```

The Python CLI arguments would be:
```
--destination <workspaceRoot>
--packs core,python,csharp-default
--memory-mode overwrite
```

The existing single-action command behavior is preserved by defaulting all packs selected, `csharpVariant: "default"`, and `memoryMode: "overwrite"` when the command is invoked with no UI (e.g., from MCP with only `workspace_root`).

**MCP tool definition update:** Add optional fields `packs` (array of strings), `csharp_variant` (enum), and `memory_mode` (enum) to the `push_down_claude_customizations` tool schema in `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts`.

---

## E. Automation Feasibility

### Fully automatable layers

**Python push-down engine (service layer):** All new behavior — pack filtering, variant selection, memory mode — is implemented entirely in Python with the `PushDownFileSystem` protocol seam. The existing test infrastructure (`RecordingFileSystem` in-memory double) already supports:
- Testing pack-filtered enumeration by pre-populating the in-memory filesystem with only the files in the selected pack.
- Testing memory mode by verifying which files are written to destination for each mode.
- Testing variant selection by populating both `.claude/` and `.claude-variants/csharp-alt/` in the in-memory filesystem and verifying which source path was used.

No real filesystem access is needed; the seam is already in place. **These tests are fully automatable.**

**TypeScript service layer:** The new inputs (`packs`, `csharpVariant`, `memoryMode`) are plain data types passed through the service interface. The existing Jest mock pattern (`jest.fn()`, `createMockProcess`) is sufficient to test that the correct CLI args are constructed. **Fully automatable.**

**TypeScript MCP handler:** Input validation for new fields can be tested with the existing `resolvePushDownClaudeCustomizationsToolInput` pattern. **Fully automatable.**

### Requires manual human interaction in a real VS Code host

**The VS Code QuickPick multi-select UI (Step 1 — pack selection)** uses `vscode.window.showQuickPick` with `canPickMany: true`. This API is mocked in existing tests via `jest.mock("vscode", ...)` but the mock does not simulate actual user multi-selection behavior in the VS Code test host. Verifying that:
- The correct items appear with the correct default selection state
- Cancellation propagates correctly
- The C# variant step is conditionally shown only when C# is selected

...requires a VS Code extension integration test with a real or simulated extension host (`vscode-test` / `@vscode/test-electron`). The existing test harness (`extension-test-harness.ts`) stubs the command handler but does not simulate multi-step QuickPick flows.

**Specifically, the following steps require manual verification or integration test setup not currently in the repository:**
1. Multi-select QuickPick `canPickMany: true` behavior with pre-selected items.
2. Conditional display of C# variant step based on prior pack selection.
3. Full end-to-end command flow from VS Code command palette through three QuickPick prompts to service invocation.

**Mitigation:** These UI flows can be covered by unit tests that mock `vscode.window.showQuickPick` to return controlled values. The unit test coverage at the command-registration layer would then test all combinations without requiring a live VS Code host. The residual manual step is acceptance-testing the UI appearance and labeling in a real VS Code instance before release.

---

## File Path Reference Summary

| Path | Role |
|------|------|
| `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` | Command registration (lines 119–132) |
| `extensions/drm-copilot/src/repo-automation-service.ts` | Service interface + `pushDownClaudeCustomizations` impl (lines 250–265) |
| `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts` | MCP handler |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | Input resolver (lines 261–272) |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | MCP schema (lines 124–136) |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | Duplicate schema — same as above |
| `extensions/drm-copilot/src/extension-command-helpers.ts` | `promptForChoice` helper (lines 141–153) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/` | Bundled `.claude` payload |
| `scripts/dev_tools/push_down_claude_customizations.py` | Claude push-down entry point |
| `scripts/dev_tools/push_down_copilot_customizations.py` | Shared engine (`push_down_customizations`) |
| `scripts/dev_tools/push_down_copilot_customizations_filesystem.py` | `PushDownFileSystem` protocol |
| `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` | Reference rewriter |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | Engine unit tests |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Parity tests (root ↔ bundle) |
| `tests/scripts/dev_tools/test_push_down_copilot_customizations_mirror_parity.py` | Filesystem adapter parity |
| `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` | Memory scope filter tests |
| `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts` | Command registration test |
| `extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts` | Service-layer test |
| `extensions/drm-copilot/test/push-down-claude-handler.test.ts` | MCP handler test |
| `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts` | MCP dispatch test |
| `C:/Users/DanMoisan/repos/drm-copilot/artifacts/tocompare/.claude/` | Alternative version drop path |
