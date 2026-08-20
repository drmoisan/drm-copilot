# Claude Runtime Integration Mechanics — Mermaid Diagram Port (Issue #491)

- Date: 2026-08-19
- Feature: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/`
- Research question: what must be authored, registered, mirrored, and tested for the four planned
  `.claude` artifacts (rule, skill, hook, validator library) to be correct, enforced, distributable,
  and covered, and what exact contract does each surface impose.
- Method: direct reading of the existing hooks, rules, skills, push-down publisher, pack manifests,
  parity tests, Pester configuration, and CI workflows in this worktree. Every claim below cites the
  file and, where useful, the line range that establishes it.

## 1. Current State Analysis

The Copilot source pack is `.github/instructions/mermaid.instructions.md` (86 lines, `applyTo: "**"`).
Every mechanism it names (three LM tools, `mermaidChart.*` command IDs, `@mermaid-chart` chat
participants) is VS Code-extension-hosted and unreachable from Claude Code. The Claude runtime has
zero Mermaid-related content today: `grep -i mermaid .claude/` returns no matches.

The four Claude surfaces the port targets, and the reference implementations read for this research:

| Surface | Reference implementations read |
|---|---|
| PreToolUse hook | `.claude/hooks/enforce-evidence-locations.ps1`, `check-powershell-test-purity.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-discovery-artifact-gate.ps1` |
| Rule | `.claude/rules/python.md`, `shell.md`, `typescript.md`, `general-code-change.md` (scoped); `orchestrator-state.md`, `parallel-orchestration.md`, `benchmark-baselines.md`, `ci-workflows.md` (unscoped) |
| Skill | `.claude/skills/make-skill-template/SKILL.md`, `evidence-and-timestamp-conventions/SKILL.md`, `translate-copilot-to-claude/SKILL.md` |
| Distribution | `scripts/dev_tools/push_down_claude_customizations.py`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, three parity/completeness test suites |

## 2. PreToolUse Hook Contract

### 2.1 Input mechanism

All Write/Edit hooks in this repo read the tool input from the environment variable
`$env:CLAUDE_TOOL_INPUT`, containing the tool's parameter object as JSON. No hook reads stdin for
PreToolUse input. Evidence:

- `enforce-evidence-locations.ps1:160` — `[string] $ToolInputRaw = $env:CLAUDE_TOOL_INPUT`.
- `check-powershell-test-purity.ps1:144` — `Invoke-PowerShellTestPurityDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT`.
- (`SubagentStop` hooks use a different variable, `$env:CLAUDE_HOOK_INPUT` — `.claude/settings.json:216`. Do not confuse the two.)

Field paths, per the documented and implemented shapes:

- **Write**: `{"file_path": "<path>", "content": "<full file text>"}`.
- **Edit**: `{"file_path": "<path>", "old_string": "<fragment>", "new_string": "<fragment>"}`
  (plus `replace_all` when supplied by the caller).
- **Agent-matcher hooks** receive `{"subagent_type": "...", "prompt": "..."}` (see
  `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:132`), not relevant here.

The dual content-field dispatch pattern is at `check-powershell-test-purity.ps1:91-98`: check
`$toolInput.content` first (Write), fall back to `$toolInput.new_string` (Edit).

### 2.2 Block protocol

The repo uses the `hookSpecificOutput` JSON response on stdout with **exit code 0**, never the
`{"decision":"block"}` shape and never a non-zero exit to signal a block. The deny shape
(`enforce-evidence-locations.ps1:98-105`):

```powershell
[ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName            = 'PreToolUse'
        permissionDecision       = 'deny'
        permissionDecisionReason = 'TOKEN_PREFIX: <specific reason and remediation pointer>'
    }
}
```

serialized with `ConvertTo-Json -Compress -Depth 5 | Write-Output`, then `exit 0`. This exact
schema is load-bearing: `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:15-20`
records that "Claude honors a PreToolUse deny only when the hook emits the hookSpecificOutput
schema", and asserts the round-tripped shape for all 14 PreToolUse hooks. A new hook should add an
`It` block there (the list is hardcoded, so nothing fails automatically if it is omitted — but the
suite title's hook count and the convention both call for it).

Reason strings begin with an ALL_CAPS token (`EVIDENCE_LOCATION_BLOCKED:`,
`CHECKPOINT_ORDER_BLOCKED:`) followed by the specific defect and the corrective pointer. The
planned hook should define a token such as `MERMAID_VALIDATION_BLOCKED:` (and, for the managed
case, a distinct message keyed on the `id:` frontmatter).

Allow paths are handled two ways, both in production:

- Emit an explicit allow decision (`permissionDecision = 'allow'`) and exit 0 —
  `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1`.
- Emit nothing at all on allow and exit 0 — `check-powershell-test-purity.ps1:144-149` prints only
  deny decisions.

The repo is **not fully consistent** here; either form works. The explicit-allow form is the more
common one among the newer hooks and is recommended.

### 2.3 Fail-open behavior

Two patterns exist for malformed `CLAUDE_TOOL_INPUT` JSON:

- **Hard fail (exit 1)**: `enforce-evidence-locations.ps1:125-129` and
  `enforce-checkpoint-monotonic.ps1:212-217` throw; the entrypoint catches, `Write-Error`, exit 1.
- **Fail open (return `$null`, exit 0)**: `check-powershell-test-purity.ps1:75-80` swallows the
  parse failure and allows.

The issue's own test conditions require "malformed hook input fails open", and the issue's
false-positive constraint says the gate "must fail open on content it cannot classify". Follow the
purity-hook pattern: any of {empty input, unparseable JSON, missing `file_path`, path outside the
hook's scope, content the classifier cannot parse into a diagram} returns allow. Content that IS
classifiable as a Mermaid diagram and fails validation is the only deny path.

All other consistent conventions every hook shares (copy them):

- Read-only gate: "This script must not modify any state" (header of every hook).
- Path normalization before matching: `$FilePath -replace '\\', '/'` and prefix matching that
  accepts both relative and absolute forms (`enforce-evidence-locations.ps1:57-77`).
- Dot-sourcing guard so tests can load functions without running the entrypoint
  (`enforce-evidence-locations.ps1:176-178`):
  `if ($MyInvocation.InvocationName -eq '.') { return }`.
- Pure decision function (`Invoke-<X>Decision -ToolInputRaw ...`) separated from the thin
  entrypoint, so Pester exercises the logic directly.

### 2.4 Locating `.claude/lib/**` modules from a hook

Hooks resolve library modules relative to `$PSScriptRoot`, never the working directory:

- `enforce-pr-author-skill.ps1:49` —
  `Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force`
- `enforce-discovery-artifact-gate.ps1:64-70` — builds
  `Join-Path -Path $PSScriptRoot -ChildPath '../lib/discovery-validation/DiscoveryValidation.psm1'`,
  checks `Test-Path ... -PathType Leaf` first and degrades gracefully when the module is absent,
  then `Import-Module -Name $modulePath -Force -ErrorAction Stop`.

For the planned hook: `Join-Path $PSScriptRoot '../lib/mermaid/MermaidValidation.psm1'`, with a
missing-module guard that fails open (a consumer repo receiving the hook without the module must
not be bricked; `enforce-discovery-artifact-gate.ps1:66-68` is the precedent, though it fails with
a message rather than open — for a content gate, fail open).

Note the hook itself is registered in settings as `pwsh -NoProfile -File .claude/hooks/<name>.ps1`
(repo-relative), so the process CWD is the repo root, but no hook relies on that for module
resolution; all use `$PSScriptRoot`.

### 2.5 The Edit hazard

An `Edit` payload carries only `old_string`/`new_string` — a fragment, not the resulting file.
Findings on how existing hooks handle this:

- **No hook simulates an edit.** A `Get-Content` sweep across `.claude/hooks/` shows hooks read
  on-disk *state* files (checkpoints, receipts) but never reconstruct a post-edit target file.
- `enforce-checkpoint-monotonic.ps1:36-39` documents the explicit policy for whole-content
  validation: "Edit tool calls supply only old_string/new_string (a partial patch) and cannot be
  reliably validated without the full target file content, so they are allowed by this hook. The
  next Write call will catch a regression." Implementation at lines 231-234 (missing `content` →
  allow).
- `check-powershell-test-purity.ps1` takes the other viable route for *pattern-presence* checks: it
  scans `new_string` alone, because introducing a forbidden token is detectable from the fragment.

**Recommendation for the Mermaid hook**, split by check:

1. **Managed-diagram guard (`id:` frontmatter)** — this is a property of the *target file on disk*,
   not of the fragment. For `Edit` on a `.mmd`/`.mermaid` path, read the on-disk file through a
   mockable reader function (the wrapper-seam pattern of `.claude/rules/powershell.md`; precedent:
   `Get-EpicCheckpointContent`-style wrappers in the epic hooks and the injectable
   `$ReadFileContent` scriptblock parameter in `validate-task-researcher-output.ps1:133`). If the
   file exists and its frontmatter carries `id:`, deny both Write and Edit. This check works
   correctly for Edit with no simulation.
2. **Syntactic validation of the diagram** — for `Write`, validate the full `content` field. For
   `Edit`, follow the checkpoint-monotonic precedent and allow (optionally: reconstruct the
   post-edit text by reading the on-disk file and applying the `old_string`→`new_string`
   replacement, validating the result, and failing open when `old_string` does not match exactly
   once). The reconstruction variant has no repo precedent; the allow-on-Edit variant does. Given
   the issue's false-positive constraint, ship allow-on-Edit for syntax first and record
   reconstruction as a possible follow-up. The managed-diagram check (which the issue's test
   conditions explicitly require to block a hand-*edit*) is covered by item 1 regardless.

### 2.6 Registration in `.claude/settings.json`

The `Write|Edit` matcher block is `.claude/settings.json:131-175`; ten hooks are currently chained
there. Append one entry (shape in Copyable Contracts). Two additional facts:

- `.claude/settings.json` is itself distributed: it is `core.json` line 5 and is in the
  byte-identical parity scope (below). The registration edit therefore lands in **two** files: the
  repo settings and the bundled mirror copy.
- `defaultPermissionMode` is `bypassPermissions` (`settings.json:283`), which affects the skill
  permission question in section 4 but not hook execution.

## 3. Rules File Contract

### 3.1 Frontmatter schema

Scoped rules use exactly two frontmatter keys, `paths:` (list of globs) and `description:`
(one line). Verified in `python.md:1-5`, `typescript.md:1-5`, `shell.md:1-8`,
`general-code-change.md:1-5` (`paths: ["**"]`). `shell.md` demonstrates that both extension globs
(`**/*.sh`) and directory globs (`scripts/bash/**`) are accepted in one list.

### 3.2 Frontmatter is optional; unscoped rules load always

Four rule files have **no** frontmatter: `orchestrator-state.md`, `parallel-orchestration.md`,
`benchmark-baselines.md`, `ci-workflows.md` (verified by the `^---$` scan across
`.claude/rules/`). Observed behavior: those four files are injected into every session's standing
context unconditionally (they appear verbatim in this session's system context alongside the
`paths: "**"` rules). Frontmatter with `paths:` therefore *narrows* activation to sessions touching
matching files; omitting it means always-on. An always-on Mermaid rule would tax every session, so
scope it.

### 3.3 Glob recommendation for the Mermaid rule

```yaml
---
paths:
  - "**/*.mmd"
  - "**/*.mermaid"
description: Mermaid diagram authoring standards, validation mandate, and managed-diagram constraint.
---
```

Do **not** add `**/*.md`: that scopes the rule onto every Markdown file in a documentation-heavy
repository, attaching Mermaid standards to all feature docs, plans, and research notes. The
fenced-```mermaid``` case inside Markdown is covered deterministically by the hook (which inspects
content, not extension) and procedurally by the skill; the rule does not need to fire on all
Markdown to cover it. If rule visibility for Markdown-embedded diagrams is judged necessary later,
that is a one-line frontmatter amendment.

### 3.4 CLAUDE.md indexing

`CLAUDE.md` has a `## Language-Specific Rules` section listing exactly four rule files (python,
powershell, typescript, csharp) and stating "Path-scoped language rules are loaded automatically
from `.claude/rules/`". Thirteen other rule files exist without being indexed there, and no test
asserts CLAUDE.md's rule list (checked `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`
and `claude-architecture-doc.Tests.ps1`). **Updating CLAUDE.md is optional.** Adding a one-line
mention is harmless and aids discovery, but nothing enforces it; note that `CLAUDE.md` is *not*
in the push-down payload (`ROOT_FOLDERS = ('.claude',)`,
`push_down_claude_customizations.py:101`), so consumer repos never see it either way.

## 4. Skill Contract and Bundled Resources

### 4.1 Frontmatter fields honored

Required: `name` (must match folder name, lowercase-hyphen) and `description` (WHAT + WHEN,
keyword-rich, single-quoted) — `make-skill-template/SKILL.md:36-54`. Optional fields observed in
production skills:

- `allowed-tools:` — either space-delimited on one line (`discovery-repo-inventory/SKILL.md:4`:
  `allowed-tools: Bash Read Glob Grep`) or a YAML block list (`commit-message`, `research-issue`).
- `context: fork` + `agent: <name>` — used only by the orchestration skills that route into a
  subagent (`epic-orchestrate`, `parallel-*`). The Mermaid skill is a direct-use workflow skill;
  it does not need `context`/`agent`.

### 4.2 Bundled resource convention

`make-skill-template/SKILL.md:89-113` documents `scripts/`, `references/`, `assets/`, `templates/`
subfolders with relative paths from the skill root. **No skill in this repo currently uses a
`references/` directory** (glob over `.claude/skills/*/*` shows only `human-exception-runbook`
carries a second file, `example.runbook.md`, as a direct sibling of SKILL.md). The template's
convention is the sanctioned shape; the planned per-diagram-type syntax references belong at
`.claude/skills/mermaid-diagram/references/<type>.md`, referenced from SKILL.md by relative path.
This will be the first skill with a `references/` subtree — see 5.3 for the distribution
consequence, which is the non-obvious part.

### 4.3 Permission entry

`.claude/settings.json` `permissions.allow` carries `Skill(<name> *)` entries for ~23 skills, but
not for all invocable skills (`make-skill-template`, `cleanup-merged-worktrees`, and all six
`parallel-*` skills are absent yet functional), and `defaultPermissionMode` is
`bypassPermissions`. Conclusion: a `Skill(mermaid-diagram *)` entry is **conventional, not
required**. Add it for consistency with the direct-use skills that do have entries
(`commit-message`, `research-issue`, etc.); remember the settings edit must be mirrored (5.5).

### 4.4 File-size ceiling

`.claude/rules/general-code-change.md` exempts "Markdown documentation files" from the 500-line
limit, so SKILL.md, the rule file, and reference Markdown are formally exempt. However,
`make-skill-template/SKILL.md:133` imposes its own checklist item "Body content is under 500
lines" for skills — treat 500 lines as the practical ceiling for SKILL.md and push per-type syntax
detail into `references/`. The hook `.ps1` and the `.psm1` module(s) are production script files
and are hard-bound by the 500-line limit (this is why `.claude/lib/blast-radius` is split across
six modules — `pester.runsettings.psd1:139-142` records that rationale).

## 5. Push-Down Distribution: Pack Manifest and Mirrored Resources

### 5.1 Mechanism

`scripts/dev_tools/push_down_claude_customizations.py` publishes the `.claude` tree
(`ROOT_FOLDERS = ('.claude',)`, line 101; only `.claude/settings.local.json` excluded, line 102)
into a destination workspace. With `--packs`, `_resolve_published_paths` (lines 137-185) loads
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json` via
`push_down_claude_pack_selection.load_pack_manifests` and publishes **only** the union of the
selected manifests' `paths` arrays (`core` always included). Consequence: a file present in the
bundle but absent from every manifest is silently dropped from any pack-scoped push-down — the
exact regression class issue #279 fixed and the completeness tests guard.

### 5.2 The bundle is a required byte-identical mirror

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126) enumerates **every** file under the repo `.claude/**` (excluding
`settings.local.json` and `agent-memory/**`) and asserts (a) it exists in
`extensions/drm-copilot/resources/claude-customizations/.claude/**` and (b) its text is equal.
Direction is repo→bundle: bundle-only extras (legacy C# variant, general memories) are permitted;
a repo file missing from the bundle, or differing by one byte, fails. So every new `.claude` file
— rule, SKILL.md, every `references/*.md`, hook, every `.psm1` — must be copied verbatim into the
bundle, and every later edit must be double-applied.

### 5.3 Manifest-completeness tests and how they fail

Two twin suites:

- **TypeScript** — `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
  Enumerates the bundled tree: `agents/*.md`, `hooks/*.ps1`, `skills/<name>/SKILL.md`,
  `rules/*.md`, and `lib/**` (recursive, all extensions) (lines 78-125), unions all manifests'
  `paths`, and asserts the difference (minus three documented pre-#279 exceptions, lines 67-71) is
  `[]`. A new bundled hook `.ps1`, rule `.md`, SKILL.md, or lib file not listed in any manifest
  fails with the missing path in the diff. The exception list is explicitly closed: "Do not add
  further entries here to mask a new regression."
- **Python** — `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
  Same assertion, but enumerates only `agents/*.md`, `hooks/*` (any file), and
  `skills/<name>/SKILL.md` (lines 79-102); it does not walk `rules/` or `lib/`.

**Coverage gap to know about**: neither suite enumerates skill files other than SKILL.md. A
`references/*.md` file under the skill therefore does not trip completeness — but the parity test
(5.2) forces it into the bundle, and if it is not also listed in `core.json` it will be silently
dropped from pack-scoped push-downs (the #279 failure mode, unguarded for this file class).
Precedent: `.claude/skills/human-exception-runbook/example.runbook.md` is manually listed at
`core.json:82`. **List every reference file in `core.json` explicitly.**

### 5.4 core.json shape and the planned diff

`core.json` is `{ "name": "core", "label": "Core (always included)", "paths": [ ... ] }` — a flat
array of bundle-root-relative paths, loosely grouped by kind (agents, hooks, rules, skills, lib,
config). Copyable diff in the Copyable Contracts section. Placement: hooks entry alphabetically in
the hooks block (~line 40), rule in the rules block (~line 60), skill in the skills block
(~line 85), lib entries near the other lib blocks (~line 127). Exact position is cosmetic; the
tests check set membership only.

### 5.5 settings.json distribution

Yes — `.claude/settings.json` is distributed (`core.json:5`) and is inside the byte-identical
parity scope (it is also the first entry of `REQUIRED_BUNDLED_FILES`,
`test_push_down_claude_resource_contracts.py:22`). The hook registration therefore requires the
same edit in `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`.

### 5.6 Codex (`.agents`) surface

No enforced requirement is broken by adding Claude-only files. The Codex inventory suite
(`tests/scripts/dev_tools/test_codex_full_migration_inventory.py:11-15`) is `skipif`-guarded —
`.codex` and `.agents` are gitignored and unavailable in CI — and its assertions run in the
direction repo-`.agents` → bundle, not `.claude` → `.agents`. No test asserts that every `.claude`
skill or hook has a Codex counterpart. The dynamic guard that *does* apply automatically is
`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, which recursively
scans `.claude/hooks` and `.claude/lib` (excluding `lib/bash`) for any Python-interpreter
invocation and fails on it — this hard-blocks a Python leg in the new hook or module with no
registration needed. (This matches the recorded repo policy: enforcement hooks are PowerShell,
never Python.) A Codex port of the Mermaid gate can be recorded as follow-up scope, mirroring how
`.codex/hooks/` ports exist for the purity/budget/evidence hooks.

## 6. Test Layout and Coverage Obligations

### 6.1 Locations and naming

- Hook tests: `tests/scripts/claude-hooks/<hook-name>.Tests.ps1` (42 existing files). Planned:
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.
- Lib tests: `tests/scripts/claude-lib/<lib-dir>/<ModuleName>.Tests.ps1`, one directory per lib
  subtree (e.g., `tests/scripts/claude-lib/blast-radius/BlastRadius*.Tests.ps1`). Planned:
  `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` (split by concern if large).
- Also add an `It` block to `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` for
  the new hook's deny shape (section 2.2).

### 6.2 Invocation and coverage output

CI (`.github/workflows/_poshqc.yml:38-42`) runs:

```powershell
Import-Module "$repo/scripts/powershell/PoshQC/PoshQC.psm1"
Invoke-PoshQCTest -Root "$repo"
```

which consumes `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: run paths
`scripts`, `tests/powershell`, `tests/scripts`; JUnit to `artifacts/pester/pester-junit.xml`;
CoverageGutters XML to `artifacts/pester/powershell-coverage.xml`. Locally, the sanctioned entry
points are the same command or the MCP tool `mcp__drm-copilot__run_poshqc_test` (per
`.claude/rules/powershell.md`, which mandates the MCP functions over ad hoc wrappers).

### 6.3 Coverage registration — the actual mechanism

`CodeCoverage.Path` in `pester.runsettings.psd1:23-173` is an **explicit opt-in list of production
files**. Every previously added hook and lib module was appended there with a comment naming its
issue (for example `.claude/hooks/enforce-parallel-abandon-gate.ps1` for #442 at line 172, the six
blast-radius modules for #447/#489 at lines 148-153). A new file not listed there is outside the
coverage denominator and its "coverage" is unmeasured — which feature review treats as a Coverage
Exclusion Policy violation. **Required additions**: `.claude/hooks/enforce-mermaid-validation.ps1`
and every `.claude/lib/mermaid/*.psm1`, each with an issue-#491 comment.

There is no test manifest or workflow path filter to touch beyond this: the Pester run paths
already include `tests/scripts/**`, so new test files are picked up automatically.

### 6.4 Thresholds

Per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`: line coverage
>= 85% uniformly; branch coverage >= 75% **does not apply to PowerShell** (Pester measures command
and line coverage only; the exemption is explicit in both rules and in
`.claude/rules/powershell.md`). Enforcement is procedural, not a CI numeric gate: `_poshqc.yml`
only uploads the coverage XML; the `powershell-qa-gate` skill (`SKILL.md:43-45`) enforces the
>= 85% floor on new modules and zero per-file regression at QA time, and feature review checks the
evidence. `quality-tiers.yml` **does not exist at repo root** (confirmed by glob), and no
`tier-classification` CI stage exists in any workflow (confirmed by grep). The tier map described
in `quality-tiers.md` is currently aspirational prose; the operative classification mechanism for
PowerShell is the coverage-path registration in 6.3 plus the QA-gate/feature-review process.
Nothing to add to a tier file; do not create one for this feature.

### 6.5 Test purity — supplying content without temp files

`check-powershell-test-purity.ps1:103-121` blocks, in any file under `tests/**/*.ps1` or
`*.Tests.ps1`: `New-TemporaryFile`, `[System.IO.Path]::GetTempFileName`, `GetTempPath`,
`$env:TEMP`, `$env:TMP`, `Invoke-WebRequest`, `Invoke-RestMethod`, `System.Net.*`,
`Start-Process`, `Start-Sleep`, and direct `Mock git/gh/actionlint`. The block fires on the
*written test content itself*, at authoring time.

Sanctioned alternatives, all in current use:

- **Inline JSON/string payloads** passed to the pure decision function:
  `enforce-evidence-locations.Tests.ps1:17-20` sets
  `$env:CLAUDE_TOOL_INPUT = '{"file_path":"..."}'` and calls
  `Invoke-EvidenceLocationDecision -ToolInputRaw ...`. Diagram fixtures for the validator are
  simply PowerShell here-strings in the test file (valid flowchart, unbalanced-bracket sequence
  diagram, CRLF variant, frontmatter-bearing diagram, etc.).
- **Mocking the file-reader seam** for on-disk reads: `PreToolUseSchema.Contract.Tests.ps1:104`
  mocks `Get-FeatureFolderFileExistence`; the drift-gate and epic-gate tests mock their
  `Get-*Content` wrapper functions. The Mermaid hook's on-disk reader (for the Edit-path
  managed-diagram check) must be a named wrapper function precisely so tests can `Mock` it.
- **Committed fixtures** under `tests/fixtures/<area>/` exist (`tests/fixtures/blast_radius/*.json`)
  and are legitimate for larger corpora, but the hook tests do not use them; here-strings suffice
  for Mermaid-sized inputs and keep each test self-describing. Raw text fixtures are also exempt
  from the 500-line limit if a corpus file is ever wanted.

## 7. Claude-Native Rendering and Preview

Findings, with confidence levels stated per the evidence-first rule:

- **No repo skill documents any diagram-rendering path.** `grep -i 'artifact tool|SendUserFile|render|mermaid'`
  over `.claude/skills/` finds only orchestration-artifact prose; `show-my-agent-tree` (the
  consumer of `render_subagent_tree`) emits Mermaid text without any rendering step. This feature
  writes the first such guidance.
- **`Artifact` / `SendUserFile` are harness-provided tools, not repo capabilities, and are not
  universally present.** They are absent from this session's own tool set, which is itself
  evidence that any Claude Code session in this repo may lack them. Where the harness provides
  them (claude.ai-connected surfaces): Markdown artifacts render fenced ```mermaid blocks
  natively; HTML artifacts render `<pre class="mermaid">` with the Mermaid library loaded from the
  CSP-permitted CDN (external scripts outside the allowed CDN are blocked by the artifact CSP, so
  no self-hosted or arbitrary-CDN Mermaid build can be used, and theming must be done via Mermaid
  init/theme configuration inside the document rather than external assets); `SendUserFile` with
  `display: "render"` presents a file (e.g., an exported SVG) inline. These behaviors are
  harness-documented, not verifiable from this repository — the skill must treat them as
  conditional capabilities, not assumed ones.
- **The universally available preview path in this repo's environment is the file itself**: write
  the validated diagram to a `.mmd` file (or Markdown fence) and direct the user to VS Code
  preview — the Mermaid Chart extension auto-previews `.mmd`/`.mermaid` files (per the Copilot
  pack, lines 13-15 and 29), and built-in Markdown preview handles fenced blocks with the
  appropriate extension installed.

**Recommendation the skill should encode**: after validation passes, (1) if the session's tool
set includes `Artifact`, publish a Markdown artifact containing the ```mermaid fence (preferred:
no CSP/theme handling needed, unlike HTML); (2) else if `SendUserFile` with `display: "render"` is
available, use it; (3) else state that the diagram was written to `<path>` and name the VS Code
preview route. Also record explicitly, as the issue's mapping table anticipates: **a hook cannot
perform any of these steps** — hooks are non-interactive `pwsh` subprocesses whose stdout is
consumed by the hook protocol (section 2.2), so publishing a user-visible artifact is exclusively
a skill-workflow step. The hook enforces only the validation invariant.

## 8. Candidate Approaches — Validator Implementation

Two approaches were evaluated for the validator the hook calls; a third was disqualified outright.

**Selected: dependency-free structural validator as PowerShell module(s) under
`.claude/lib/mermaid/`.** Checks: first-line diagram-type keyword against the known-type table
(after optional YAML frontmatter and blank/comment lines), bracket/quote balance, per-type arrow
grammar for the declared type, empty/whitespace rejection, CRLF/LF tolerance, `id:` frontmatter
detection for the managed-diagram guard. Rationale: zero new dependencies (satisfies the
dependency policy in `.claude/rules/general-code-change.md` with no written justification needed);
runs in the same `pwsh` process as the hook with no interpreter hop (satisfying the
no-Python-invocation guard, which scans `.claude/lib/**` too); fully unit-testable under Pester
with in-memory strings; portable to consumer repos through the existing push-down with no runtime
prerequisites beyond PowerShell 7. Accepted cost, recorded per the issue's risk note: it is weaker
than the extension's real parser — it validates structure, not full grammar, so some invalid
diagrams will pass. The gate's contract should be stated as "rejects the named defect classes",
not "proves validity".

**Rejected alternatives** (brief, per policy):

- *Real Mermaid parser (`mermaid` npm or `@mermaid-js/parser`)*: new third-party dependency; the
  jison-parsed types (flowchart, sequence — the most common) are DOM-dependent in the `mermaid`
  package; `@mermaid-js/parser` covers only Langium-parsed types; the hook would have to shell out
  from `pwsh` to Node, adding a Node runtime requirement to every consumer repo the hook is pushed
  into and a subprocess seam the purity rules make hard to test.
- *Python validator*: structurally blocked — `enforcement-hooks-no-python-invocation.Tests.ps1`
  dynamically scans `.claude/hooks` and `.claude/lib` and fails on any Python invocation; also
  contradicts the recorded enforcement-hook language policy.

## 9. Requirements Mapping — Complete Artifact/Registration Matrix

Every file the implementation must create (C) or modify (M):

| # | Path | C/M | Contract satisfied |
|---|---|---|---|
| 1 | `.claude/rules/mermaid.md` | C | §3 frontmatter, scoped to `**/*.mmd`, `**/*.mermaid` |
| 2 | `.claude/skills/mermaid-diagram/SKILL.md` | C | §4 frontmatter; body < 500 lines |
| 3 | `.claude/skills/mermaid-diagram/references/*.md` | C | per-type syntax references (the `get-syntax-docs-mermaid` port) |
| 4 | `.claude/hooks/enforce-mermaid-validation.ps1` | C | §2 full hook contract; < 500 lines |
| 5 | `.claude/lib/mermaid/MermaidValidation.psm1` (split if needed) | C | pure logic; < 500 lines each; no Python |
| 6 | `.claude/settings.json` | M | append to `Write|Edit` matcher (§2.6); optional `Skill(mermaid-diagram *)` allow entry (§4.3) |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror of items 1-6 | C/M | byte-identical (§5.2) |
| 8 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | M | one entry per file in 1-5 incl. every reference file (§5.3-5.4) |
| 9 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | M | add items 4-5 to `CodeCoverage.Path` with #491 comment (§6.3) |
| 10 | `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` | C | §6.1, §6.5 purity |
| 11 | `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` | C | §6.1, §6.5 purity |
| 12 | `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | M | add deny-shape `It` block; update hook count in title/docs (§2.2) |
| 13 | `CLAUDE.md` | M (optional) | §3.4 — no test enforces it |

Capability-mapping completeness (issue AC "every capability ported or recorded out of scope"):
items 1-5 carry the ports; the `mermaidChart.*` command IDs and Mermaid Chart cloud login/sync
commands must be recorded **in the skill or rule text** as out of scope with the stated reason
(VS Code command API and extension host unavailable), and the sync-cooperation rule survives as
the `id:`-frontmatter hand-edit block (hook) plus rule prose.

## 10. Testing Implications (strategy, no code)

- **Validator (lib) suite**: per supported diagram type, one valid here-string accepted; wrong and
  missing first-line keyword rejected with the specific defect named; unbalanced `[]`/`()`/`{}`/
  quotes rejected; arrow forms invalid for the declared type rejected; empty and whitespace-only
  rejected; CRLF and LF byte-equivalent verdicts; frontmatter-bearing diagram validated past the
  frontmatter; `id:`-frontmatter detection positive/negative.
- **Hook suite**: deny on invalid `.mmd` Write; allow on valid `.mmd` Write; fenced ```mermaid
  block inside a Markdown Write validated, invalid fence denied, valid fence and non-Mermaid
  Markdown allowed; non-Mermaid path allowed untouched; Edit on managed (`id:`) diagram denied via
  mocked reader seam; Edit syntax path allowed (documented fail-open); empty/malformed
  `CLAUDE_TOOL_INPUT` allowed (fail-open); entrypoint emits compact JSON and exit code 0 on both
  allow and deny (evidence-locations entry-point tests are the template, lines 127-175).
- **Contract suite**: new `It` block asserting the round-tripped `hookSpecificOutput` deny shape.
- **Parity/completeness**: run the existing three suites (Python resource-contracts, Python and TS
  manifest-completeness) as the negative control — they must fail before the mirror/manifest edits
  and pass after; this is the issue's "gate shown capable of failing" condition applied to
  distribution.
- **Purity constraint on all of the above**: inline here-strings and mocked reader seams only; no
  temp files, no `Start-Process`, no sleeps (§6.5).

## Automation Feasibility

Assessment: **no step of the planned work requires human interaction.** All deliverables are file
authoring, registration edits, and Pester/pytest/Jest runs, each verifiable by an existing local
gate. Items evaluated:

| Candidate interaction | Classification | Disposition |
|---|---|---|
| Dependency decision (structural validator vs. Mermaid parser) | none needed | Decided in §8 on recorded evidence: dependency-free structural validator. No new dependency means the dependency-policy approval path is never entered. |
| Live-harness verification that the new hook actually receives `CLAUDE_TOOL_INPUT` and that its deny is honored | none needed | The mechanism is established by 14 production hooks and by the deny-schema contract suite; unit tests exercise the same seam. A live smoke check is desirable post-merge but is not a delivery gate. |
| Artifact/`SendUserFile` rendering behavior confirmation | none needed | The skill treats rendering as a conditional capability with a file-based fallback (§7); no acceptance criterion depends on a harness-specific rendering result. |
| Retrofit of existing Mermaid emitters (`render_subagent_tree`, codex-native-converter) | `scope_change` if attempted | Explicitly out of scope per the issue's Scope containment note; record as follow-up, do not deliver. Only becomes a human interaction if someone tries to pull it in. |

No `exception` (runbook) or `halt` conditions identified. The orchestrator can record
`human_interaction` as absent or with an empty `requirements` list.

## Copyable Contracts

### Hook input JSON (as delivered in `$env:CLAUDE_TOOL_INPUT`)

```json
{"file_path": "docs/diagrams/flow.mmd", "content": "flowchart TD\n  A --> B\n"}
```

```json
{"file_path": "docs/diagrams/flow.mmd", "old_string": "A --> B", "new_string": "A --> C"}
```

### Hook deny response (stdout, compact JSON, exit 0)

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MERMAID_VALIDATION_BLOCKED: 'docs/diagrams/flow.mmd' declares 'flowchart' but line 3 uses a sequence-diagram arrow '->>'. Fix the arrow or the diagram type. See .claude/skills/mermaid-diagram/SKILL.md."}}
```

Allow response: same envelope with `"permissionDecision":"allow"` and no reason field.

### Rule frontmatter (`.claude/rules/mermaid.md`)

```yaml
---
paths:
  - "**/*.mmd"
  - "**/*.mermaid"
description: Mermaid diagram authoring standards, validation mandate, and managed-diagram constraint.
---
```

### Skill frontmatter (`.claude/skills/mermaid-diagram/SKILL.md`)

```yaml
---
name: mermaid-diagram
description: 'Generate, validate, and render Mermaid diagrams (flowchart, sequence, class, state, ER, C4, gantt, pie). Use when asked to create, edit, fix, or visualize a diagram, write a .mmd file, or embed a mermaid fence in Markdown. Bundles per-type syntax references and the generate-validate-render workflow enforced by the enforce-mermaid-validation hook.'
---
```

### core.json additions (into the `paths` array; every skill reference file listed individually)

```json
    ".claude/hooks/enforce-mermaid-validation.ps1",
    ".claude/rules/mermaid.md",
    ".claude/skills/mermaid-diagram/SKILL.md",
    ".claude/skills/mermaid-diagram/references/flowchart.md",
    ".claude/lib/mermaid/MermaidValidation.psm1",
```

(Extend with one line per additional reference file and per additional `.psm1` if the module is
split for the 500-line limit.)

### settings.json hook registration (append inside the existing `"matcher": "Write|Edit"` block, both repo and bundled copies)

```json
          {
            "type": "command",
            "command": "pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1"
          }
```

Optional permission entry in `permissions.allow`:

```json
      "Skill(mermaid-diagram *)",
```

### Module import from the hook

```powershell
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath '../lib/mermaid/MermaidValidation.psm1'
if (Test-Path -LiteralPath $modulePath -PathType Leaf) {
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}
```

### Pester run (repo convention; produces artifacts/pester/pester-junit.xml and powershell-coverage.xml)

```powershell
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"
```

or the MCP tool `mcp__drm-copilot__run_poshqc_test`. Coverage for the new files appears only after
they are appended to `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:

```powershell
            # Issue #491 added the Mermaid validation hook and library; measured here so the
            # new production files are not excluded from coverage.
            '.claude/hooks/enforce-mermaid-validation.ps1'
            '.claude/lib/mermaid/MermaidValidation.psm1'
```
