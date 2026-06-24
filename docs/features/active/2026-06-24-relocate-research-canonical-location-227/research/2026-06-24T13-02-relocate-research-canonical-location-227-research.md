# Task Research Notes: relocate-research-canonical-location (Issue #227)

## Research Executed

### File Analysis

All files listed in the task inventory were read end-to-end. Confirmed complete
coverage for the following sources:

**Claude ecosystem (root):**
- `.claude/agents/task-researcher.md`
- `.claude/agents/orchestrator.md`
- `.claude/skills/research-issue/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `.claude/hooks/validate-task-researcher-output.ps1`
- `.claude/hooks/enforce-evidence-locations.ps1`
- `.claude/settings.json`

**Claude ecosystem (bundled copy — confirmed byte-for-byte identical content):**
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

**Codex ecosystem (bundled):**
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md`

**GitHub Copilot ecosystem (root):**
- `.github/agents/task-researcher.agent.md`
- `.github/prompts/research-issue.prompt.md`
- `.github/prompts/fillout-prd-feature.prompt.md`

**GitHub Copilot ecosystem (bundled copy — confirmed identical content):**
- `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/fillout-prd-feature.prompt.md`

**Tests:**
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`
- `tests/scripts/dev_tools/test_validate_evidence_locations.py`

**Tooling:**
- `scripts/dev_tools/validate_evidence_locations.py`
- `.gitignore`

### Code Search Results

- `artifacts[/\\]research` grep across repo returned 95 matching files.
  Operational hits (files that actually enforce or instruct on the path, as
  opposed to historical plan/evidence docs that merely reference the path as
  context) are enumerated in the per-file inventory below.
- `research-path` grep returned 9 files: the hook, the bundled hook,
  `settings.json` (two copies), two feature evidence files (historical, not
  enforcement), and `docs/engineering/claude-code-architecture.md`.

### Project Conventions

- `.gitignore` line 6: `artifacts` — entire `artifacts/` tree is excluded from
  version control (bare entry with no trailing slash, matching any depth).
- The enforce-evidence-locations hook and the Python validator both use an
  explicit allowlist of forbidden prefixes; they do NOT contain a blocklist of
  allowed paths. Paths not on the forbidden list pass through.
- `docs/` is tracked; `docs/features/active/<feature>/` is the established home
  for all per-feature versioned artifacts.
- No existing `docs/research/` directory exists in the repo. It would need to
  be created (`.gitkeep` or first research file).

---

## Current-State Analysis

### How `artifacts/research/` is referenced across operational files

The table below covers only enforcement/instruction files — not historical
feature-doc references that happen to mention the path.

| File | Reference type | Exact text / logic | Required change |
|---|---|---|---|
| `.claude/agents/task-researcher.md` (frontmatter) | Write allowlist | `"Write(/artifacts/research/**)"` in `tools:` list | Replace with two new roots |
| `.claude/agents/task-researcher.md` (body) | Output-location prose | `Write all research artifacts to \`artifacts/research/\`` and constraint `Write only to \`artifacts/research/\`` | Update prose to describe two new roots and routing rule |
| `.claude/agents/task-researcher.md` (description) | Metadata prose | `"writes structured findings exclusively to artifacts/research/"` | Update description |
| `.claude/agents/orchestrator.md` (body) | Delegation prose | `"task-researcher — performs deep research and writes findings to \`artifacts/research/\`"` | Update |
| `.claude/skills/research-issue/SKILL.md` (body) | Output path prose | `Path: \`artifacts/research/<timestamp>-<short-name>-research.md\`` | Update to new routing rule |
| `.claude/skills/research-issue/SKILL.md` (description) | Metadata prose | `"writing structured findings to artifacts/research/"` | Update |
| `.claude/skills/orchestrate/SKILL.md` (body) | Delegation prose | `"task-researcher — performs deep research and writes findings to \`artifacts/research/\`"` | Update |
| `.claude/skills/orchestrate/SKILL.md` (Evidence Location Authority) | Permitted sub-path prose | `"artifacts/research/ — research outputs from task-researcher"` listed as permitted sub-path | Remove or replace: this path is no longer a permitted artifacts/ sub-path |
| `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Permitted sub-path list | `"artifacts/research/"` in `Allowed artifacts/ sub-paths` section | Remove (research is no longer an artifacts/ path) |
| `.claude/hooks/validate-task-researcher-output.ps1` | Root check function | `Test-IsUnderResearchRoot`: `return $normalized.StartsWith('artifacts/research/', ...)` | Rewrite to accept two new roots |
| `.claude/hooks/validate-task-researcher-output.ps1` | Error messages | Three messages hard-code `artifacts/research/` as the target | Update all three messages |
| `.claude/hooks/validate-task-researcher-output.ps1` | Missing research-path guidance | `"must report \`research-path: <path>\` pointing to artifacts/research/"` | Update message |
| `.claude/hooks/validate-task-researcher-output.ps1` | Filename convention message | `"artifacts/research/<timestamp>-<short-name>-research.md"` in error message | Update message |
| `.claude/hooks/enforce-evidence-locations.ps1` | Docstring + allowed-path list | Docstring explicitly lists `artifacts/research/` as a permitted allowed path | Update docstring; no logic change needed (the hook uses an exclusion-only approach, so `artifacts/research/` is currently allowed by absence from forbidden list — this remains valid as long as the path is not added to the forbidden list; however the docstring must be updated) |
| `.claude/settings.json` | SubagentStop inline hook regex | `'(plan-path\|research-path\|review-artifact\|PREFLIGHT\|evidence/)'` — `research-path` token is accepted regardless of the path value; no path root check here | No functional change needed; the `research-path` token remains the contract |
| `.claude/settings.json` | Write permission allowlist | `"Write(/artifacts/**)"` — covers any artifacts/ sub-path | No change needed for the orchestrator; the task-researcher agent-level allowlist is the relevant gate |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md` | All same as root copy | Identical content — same changes required | Mirror all changes from root copy |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | Delegation prose | Identical to root | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md` | Output path prose | Identical to root | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | Delegation prose + permitted sub-path | Identical to root | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Permitted sub-path list | Identical to root | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` | Root check + error messages | Identical to root | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1` | Docstring | Identical to root | Mirror docstring update |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | SubagentStop regex + allowlist | Identical to root | No functional change; mirror docstring/description updates if any |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` | Write allowlist in embedded frontmatter | `"Write(/artifacts/research/**)"` | Replace with two new roots |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` | Body prose | Same as Claude copy embedded as `developer_instructions` | Mirror all prose changes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` | Stop hook | `"Block termination unless research artifact path has been confirmed on disk under artifacts/research/."` | Update to two new roots |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` | Delegation prose | `"task-researcher: research artifacts under \`artifacts/research/\`"` in `developer_instructions` | Update |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1` | Docstring | Lists `artifacts/research/` as permitted | Mirror docstring update |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md` | Output path prose | Identical to root | Mirror |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` | Delegation prose + permitted sub-path | Identical to root | Mirror |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md` | Permitted sub-path list | Identical to root | Mirror |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md` | Authoritative research path reference | `"artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md"` — this is a concrete file path reference in the Authoritative Inputs section and the research basis reference in the plan template | This is a path to a specific historical research artifact, not a path-routing rule. No change is required for that historical reference. The plan template line `Research basis: artifacts/research/...` is also historical. However, after this feature ships, new translate-claude-to-codex research artifacts would go to a docs path. The SKILL.md does not need a change for the contract; future invocations will naturally use the new location. |
| `.github/agents/task-researcher.agent.md` | Role definition prose | `"Your sole responsibility is to write transient research notes in the untracked scratch area \`artifacts/research/\`"` | Update — research is now tracked |
| `.github/agents/task-researcher.agent.md` | Operational constraint | `"You MUST create and edit files ONLY in \`artifacts/research/\`"` | Update |
| `.github/agents/task-researcher.agent.md` | Collaborative process | `"Search for existing research files in \`artifacts/research/\`"` | Update |
| `.github/prompts/research-issue.prompt.md` | Output path prose | `Path: \`artifacts/research/<timestamp>-<short-name>-research.md\`` and filename convention example | Update |
| `.github/prompts/research-issue.prompt.md` | Operating rules reference | `"write to \`artifacts/research/\`, evidence-based"` | Update |
| `.github/prompts/fillout-prd-feature.prompt.md` | Research path reference | `"If research exists under \`artifacts/research\`, the caller must include the specific research file paths"` | Update to reference both new roots |
| `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md` | Same as root | Identical | Mirror all changes |
| `extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md` | Same as root | Identical | Mirror all changes |
| `extensions/drm-copilot/resources/customizations/.github/prompts/fillout-prd-feature.prompt.md` | Same as root | Identical | Mirror all changes |
| `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` | Test assertions | Multiple `It` blocks assert `artifacts/research/` root, error messages containing `artifacts/research/`, and valid path examples like `artifacts/research/2026-05-04T00-00-hook-contract-research.md` | Rewrite affected tests; add new tests for both new roots |
| `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` | Test assertion | One `It` block: `'allows writes to artifacts/research/ (permitted research path)'` with path `artifacts/research/notes.md` | This test must be updated: writing to `artifacts/research/` must now be rejected, and tests for both new canonical roots must be added |
| `tests/scripts/dev_tools/test_validate_evidence_locations.py` | Allowed path in `test_clean_tree_exits_zero` | `Path("/fake/repo/artifacts/research/notes.md")` listed as an allowed path in the clean-tree test | This path must be replaced with a new canonical path; `artifacts/research/` is no longer allowed |
| `scripts/dev_tools/validate_evidence_locations.py` | `_FORBIDDEN_PREFIX_TO_CANONICAL` dict | `artifacts/research/` is not in the forbidden list (allowed by omission) | `artifacts/research/` must be added to the forbidden prefix map with a canonical suggestion pointing to the two new roots |

---

## Proposed Contract for the Two New Tracked Locations

### Filename Convention (preserved)

The timestamp-and-name convention is unchanged:

```
<timestamp>-<short-name>-research.md
```

where `<timestamp>` uses the existing `yyyy-MM-ddTHH-mm` format (e.g., `2026-06-24T13-02`).

### Two Canonical Research Roots

**Feature-associated research (orchestration context):**
```
docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md
```

Example: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md`

**One-off research (no associated feature):**
```
docs/research/<timestamp>-<short-name>-research.md
```

Example: `docs/research/2026-06-24T14-00-codex-native-ecosystem-research.md`

### Hook Regex / Path Validator Logic

The `Test-IsUnderResearchRoot` function in `validate-task-researcher-output.ps1`
must be rewritten to accept either root:

```
Accepted pattern A: docs/features/**/research/<timestamp>-<short-name>-research.md
Accepted pattern B: docs/research/<timestamp>-<short-name>-research.md
Rejected: artifacts/research/...
Rejected: any other path
```

The implementation approach: normalize to forward-slash, then check
`StartsWith('docs/features/')` with a `/research/` segment present after the
feature folder, OR `StartsWith('docs/research/')`. Both checks are
case-insensitive.

The filename pattern check `Test-IsValidResearchFileName` operates on
`[System.IO.Path]::GetFileName($normalized)` and uses:
```
^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$
```
This regex does not include a path prefix and therefore does not require change.

The `enforce-evidence-locations.ps1` hook does not need a logic change. It uses
an exclusion-only model: paths not in `$forbiddenPrefixes` pass through. As long
as `artifacts/research/` is added to the forbidden list and `docs/features/` and
`docs/research/` are not in the forbidden list, the hook will correctly:
- Block: `artifacts/research/...`
- Allow: `docs/features/**/research/...`
- Allow: `docs/research/...`

However, the `scripts/dev_tools/validate_evidence_locations.py` script uses the
`_FORBIDDEN_PREFIX_TO_CANONICAL` dict, and `artifacts/research/` is currently
absent (allowed by omission). After this change, it must be added as a forbidden
prefix with a canonical suggestion.

### Task-Researcher Agent Write-Path Allowlist

**Current form (Claude .md frontmatter):**
```yaml
tools:
  - "Write(/artifacts/research/**)"
```

**Required new form:**
```yaml
tools:
  - "Write(/docs/features/**/research/**)"
  - "Write(/docs/research/**)"
```

**Current form (Codex .toml `developer_instructions` embedded frontmatter):**
```
"Write(/artifacts/research/**)"
```

**Required new form:**
```
"Write(/docs/features/**/research/**)"
"Write(/docs/research/**)"
```

Note: Claude's `Write(...)` tool allowlist uses glob syntax with `/` prefix
anchored at repo root. The double-star `**` matches any intermediate segments,
including the `<feature>` folder segment.

### Orchestrator Routing Decision Rule

The orchestrator must determine which root to use before delegating to
`task-researcher`. The rule is:

- If there is an active feature folder in scope (i.e., `feature-folder` is set
  in `orchestrator-state.json`), write research to
  `<feature-folder>/research/<timestamp>-<short-name>-research.md`.
- If no active feature folder is in scope (standalone research request, ad-hoc
  investigation), write research to
  `docs/research/<timestamp>-<short-name>-research.md`.

The delegation prompt from the orchestrator to `task-researcher` must include
the resolved output path. The `task-researcher` agent does not infer the feature
folder independently.

The `research-issue` skill must similarly be updated to document both paths and
the routing rule, replacing the single `artifacts/research/` instruction.

---

## Recommended Approach

**Direct substitution with dual-root acceptance.** Update every occurrence of
`artifacts/research/` in the enforcement/instruction layer to express the new
two-root contract. This is the only viable approach because:

1. The change is purely a relocation of a path contract, not a new behavioral
   system. No architectural re-design is needed.
2. All enforcement points (hook functions, agent frontmatter, skill prose) are
   individually addressable — each file has a well-defined and isolated change.
3. The `validate_evidence_locations.py` script must add `artifacts/research/`
   as a forbidden prefix to prevent agents from writing there; this is a
   two-line addition to the existing dict.
4. The `enforce-evidence-locations.ps1` hook logic requires no code change —
   only a docstring update — because it already uses an exclusion-only approach.

**Rejected alternative — create a redirect shim at `artifacts/research/`:** A
shim that detects writes and re-routes them would add complexity, is not
supported by the Claude Code permissions model (Write allowlist is a strict
gate, not a redirect), and cannot be tested reliably. Rejected.

---

## Cross-Ecosystem Consistency Map

### Root copies and their bundled mirrors

The root copy is the source of truth. The bundled copy must remain identical.

| Root file | Bundled mirror | Sync mechanism |
|---|---|---|
| `.claude/agents/task-researcher.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md` | Manual copy; content verified identical in this investigation |
| `.claude/agents/orchestrator.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | Manual copy; content verified identical |
| `.claude/skills/research-issue/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md` | Manual copy; content verified identical |
| `.claude/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | Manual copy; content verified identical |
| `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Manual copy; content verified identical |
| `.claude/hooks/validate-task-researcher-output.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` | Manual copy; content verified identical |
| `.claude/hooks/enforce-evidence-locations.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1` | Manual copy; content verified identical |
| `.claude/settings.json` | `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | Manual copy; content verified identical |
| `.github/agents/task-researcher.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md` | Manual copy; content verified identical |
| `.github/prompts/research-issue.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md` | Manual copy; content verified identical |
| `.github/prompts/fillout-prd-feature.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/fillout-prd-feature.prompt.md` | Manual copy; content verified identical |

### Codex-only files (no root copy)

The Codex `.toml` agents and Codex `.agents/skills/` files are separate
translations; they do not have a root-repo counterpart. The
`translate-claude-to-codex` skill is the documented mechanism for keeping them
aligned with the Claude source.

The Codex `task-researcher.toml` embeds the Claude agent frontmatter and body
verbatim inside `developer_instructions`. After this change, both the embedded
frontmatter (`"Write(/artifacts/research/**)"`) and the embedded body prose must
be updated. The `translate-claude-to-codex` SKILL.md notes that
`.claude/agents/<name>.md` maps to `.codex/agents/<name>.toml` — consistent
with requiring a manual Codex-side update whenever the Claude source changes.

### Role of translate-claude-to-codex skill

The `translate-claude-to-codex` skill is invoked when changes to the Claude
surface must be propagated to the Codex surface. After the root Claude files are
updated, the Codex files must be updated to match. The skill can be invoked with
`mode=apply` to execute this propagation. However, because the Codex
`task-researcher.toml` also contains a migration-source header and stop-hook
body that mention `artifacts/research/` directly, those sections must be updated
as part of the same change, either via the skill or manually.

The Codex `evidence-and-timestamp-conventions/SKILL.md`,
`orchestrate/SKILL.md`, and `research-issue/SKILL.md` mirror their Claude
counterparts exactly and must receive the same text changes.

---

## Requirements Mapping

### AC: Feature-associated research is written to `<FEATURE>/research/`; one-off to `docs/research/`; `artifacts/research/` is no longer canonical

Files requiring change to satisfy this criterion:

- `.claude/agents/task-researcher.md` (frontmatter tools + body)
- `.claude/skills/research-issue/SKILL.md` (output path)
- `.github/agents/task-researcher.agent.md` (role definition, constraint, process)
- `.github/prompts/research-issue.prompt.md` (output path + scope rule)
- All bundled copies of the above

The `research-issue` skill and prompt must also document the routing rule: the
caller (orchestrator or user) supplies the resolved output directory, and the
researcher writes to that directory.

### AC: Claude ecosystem reflects new contract in agents, skills, and hooks

Files requiring change:

- `.claude/agents/task-researcher.md` — frontmatter `tools`, description, body
- `.claude/agents/orchestrator.md` — delegation prose
- `.claude/skills/research-issue/SKILL.md` — output path, description
- `.claude/skills/orchestrate/SKILL.md` — delegation prose, permitted sub-path
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — remove `artifacts/research/` from allowed list
- `.claude/hooks/validate-task-researcher-output.ps1` — `Test-IsUnderResearchRoot` logic, three error messages
- `.claude/hooks/enforce-evidence-locations.ps1` — docstring only (no logic change)
- All bundled copies of the above

### AC: Codex ecosystem reflects new contract

Files requiring change:

- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` — embedded frontmatter and body
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` — delegation prose
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1` — docstring only
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`

### AC: GitHub Copilot ecosystem reflects new contract

Files requiring change:

- `.github/agents/task-researcher.agent.md` — role definition, constraint, process
- `.github/prompts/research-issue.prompt.md` — output path, scope rule
- `.github/prompts/fillout-prd-feature.prompt.md` — research path reference
- All bundled copies of the above

### AC: `validate-task-researcher-output` and `enforce-evidence-locations` accept new locations and reject old

Files requiring change:

- `.claude/hooks/validate-task-researcher-output.ps1` — `Test-IsUnderResearchRoot` function body and error messages (3 locations)
- `.claude/hooks/enforce-evidence-locations.ps1` — add `artifacts/research/` to `$forbiddenPrefixes` array; update docstring
- `scripts/dev_tools/validate_evidence_locations.py` — add `artifacts/research/` to `_FORBIDDEN_PREFIX_TO_CANONICAL` dict
- Bundled copies of the hook files

### AC: Both tracked research locations resolve to git-tracked paths (not under ignored `artifacts/` tree)

`docs/features/active/` and `docs/research/` are under `docs/`, which is not in
`.gitignore`. The `artifacts` entry in `.gitignore` (line 6, bare match) covers
the entire `artifacts/` tree. Moving research to `docs/` fully satisfies this
criterion.

No `.gitignore` modification is needed; the new paths are tracked by default.

### AC: `validate-task-researcher-output` and `enforce-evidence-locations` tests updated

Files requiring change:

- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` — see Testing Implications below
- `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` — see Testing Implications below
- `tests/scripts/dev_tools/test_validate_evidence_locations.py` — see Testing Implications below

---

## Testing Implications

### `validate-task-researcher-output.Tests.ps1`

**Current test inventory and required disposition:**

- `'blocks when the research-path is not under artifacts/research/'` — this test
  currently passes `docs/features/active/foo/notes.md` and expects a block. After
  the change, `docs/features/active/foo/research/2026-06-24T13-02-foo-research.md`
  must be ALLOWED and `docs/features/active/foo/notes.md` (no `/research/` segment)
  must still be blocked. The test's assertion and scenario description must be updated.

- `'allows termination when the research-path is valid and the file exists'` — uses
  `artifacts/research/2026-05-04T00-00-hook-contract-research.md`. Must be updated
  to use a valid path under one of the new roots, e.g.,
  `docs/features/active/my-feature/research/2026-05-04T00-00-hook-contract-research.md`.

- `'blocks when the advertised research file does not exist on disk'` — same path
  update required.

- `'extracts a quoted research-path value'` — path in the output string must be
  updated.

- `'returns true for valid research filenames'` — `Test-IsValidResearchFileName`
  operates on the filename only (not the full path), so this test may not need
  updating unless the test passes an artifacts-rooted path as the argument.

- `'returns false for invalid research filenames'` — same, no change required if
  test uses filename only.

- `Test-AutomationFeasibilitySection` tests — all use `artifacts/research/` paths
  as the `$researchPath` parameter. These must be updated to use new-root paths.

- `'blocks termination when a matching artifact omits the Automation Feasibility
  section'` — path must be updated.

**New test cases to add:**

- Feature-folder path is accepted: `docs/features/active/some-feature-227/research/2026-06-24T13-02-some-feature-research.md` → allowed.
- One-off path is accepted: `docs/research/2026-06-24T13-02-some-topic-research.md` → allowed.
- Old path is rejected: `artifacts/research/2026-06-24T13-02-some-topic-research.md` → blocked with message referencing new roots.
- Path under `docs/features/` without `/research/` segment is rejected: `docs/features/active/some-feature/2026-06-24T13-02-some-feature-research.md` → blocked.
- Path under `docs/features/` with correct `/research/` segment but wrong filename is rejected: `docs/features/active/some-feature/research/bad-name.md` → blocked with filename convention message.

### `enforce-evidence-locations.Tests.ps1`

- `'allows writes to artifacts/research/ (permitted research path)'` — this test
  must be **changed to a rejection test**: `artifacts/research/notes.md` must now
  produce `decision: block` with `EVIDENCE_LOCATION_BLOCKED`.

- Two new allow tests must be added:
  - `'allows writes to docs/features/ research subfolder (new canonical feature research path)'` with path `docs/features/active/my-feature/research/2026-06-24T13-02-foo-research.md` → `decision: allow`.
  - `'allows writes to docs/research/ (new canonical one-off research path)'` with path `docs/research/2026-06-24T13-02-foo-research.md` → `decision: allow`.

### `test_validate_evidence_locations.py`

- `test_clean_tree_exits_zero`: the `allowed_paths` list includes
  `Path("/fake/repo/artifacts/research/notes.md")`. After the change, this
  path is forbidden. It must be removed and replaced with a new-root path,
  e.g., `Path("/fake/repo/docs/features/active/my-feature/research/note.md")`.

- `test_seeded_violation_exits_one`: the seeded violation uses
  `artifacts/baselines/seeded.md`. This test does not need a path change, but
  the implementation must also forbid `artifacts/research/`, so a new test case
  should be added specifically seeding `artifacts/research/seeded.md` and
  verifying it is reported as a violation with a canonical suggestion.

- New test: `test_artifacts_research_is_forbidden`: seeds a file at
  `artifacts/research/seeded.md` and verifies `find_forbidden_paths` yields
  exactly one violation with a canonical suggestion referencing the new paths.

---

## Additional Findings from Grep

The `docs/features/` tree contains numerous historical references to
`artifacts/research/` in plan files, feature-audit files, and archive
documents. These are historical records of the old contract and do not require
update — they are not enforcement or instruction files. Only the
operational/enforcement files listed in the per-file inventory above require
change.

The `docs/engineering/claude-code-architecture.md` references
`artifacts/research/` in an architectural description. This is documentation and
should be updated for accuracy but is not a blocking enforcement concern.

`testResults.xml` contains test output from a prior Pester run and references
`artifacts/research/` in test result labels. This file is generated, not
authored, and requires no direct change.
