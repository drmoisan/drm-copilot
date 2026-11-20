# Research: Implementation-Surface Mapping for the Single-Epic-Home Manifest Change (#331)

- Date: 2026-07-07
- Feature: `docs/features/active/2026-07-07-epic-single-home-manifest-331/`
- Canonical issue: #331
- Scope: file-level implementation map for adopting Option D (single epic home +
  flat feature siblings + one manifest) from the authoritative design at
  `docs/features/active/2026-07-07-epic-single-home-manifest-331/research/2026-07-07T19-00-epic-folder-structure-design-research.md`.
- Constraint honored: design is fixed; this document maps where and how to
  implement it, not whether to.

## 0. Design recap (from the authoritative research, not re-litigated)

Target end-state per the design doc §5 (Option D):
1. Single epic home `docs/features/epics/<epic-slug>/`: `epic.md` (YAML
   frontmatter = manifest DAG + optional SAFe intent block, then merged
   narrative) and generated-only `epic-status.md`. No `active/<date>-<epic>-<issue>/`
   epic folder; retire `initiative.md`.
2. `new_active_feature_folder(type=epic)` scaffolds only
   `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`. Child
   feature/bug scaffolding unchanged.
3. Manifest DAG keyed by stable `issue_num` (primary); `feature_folder` is a
   resolvable hint that may point into `active/` or `completed/`. Remove the
   active→completed path-drift workaround from the skill.
4. Optional additive SAFe intent block: `epic_type`,
   `business_outcome_hypothesis`, `leading_indicators[]`, `nfrs[]`.
5. Child feature folders unchanged.

Backward compatibility is a hard requirement: manifest validators and wave
computation must stay byte-identical on the legacy two-tree, folder-basename-keyed
layout (additive / key-gated only). Epic #260 (store-lockup-resilience) predates
this change.

## 1. MCP tool source of truth

### Definitive finding

The published MCP server `@danmoisan/drm-copilot-mcp` executes an **in-process
TypeScript implementation**; it ships **no Python**. The authoritative runtime
source for the `new_active_feature_folder` MCP tool is the TypeScript tree
`extensions/drm-copilot/src/lib/new-active-feature-folder/**`. The Python tree
`scripts/dev_tools/new_active_feature_folder*.py` is co-authoritative for the
repository's own CLI and agents (`python -m scripts.dev_tools...`) and is the
reference the TS is a "direct port" of. The Python files committed under
`packages/mcp-server/resources/scripts/dev_tools/**` are stale build-copy
leftovers that the packing step strips; they are not shipped and not
authoritative.

### Evidence

- `packages/mcp-server/package.json:2` name `@danmoisan/drm-copilot-mcp`;
  `bin` = `out/mcp-server.js` (line 8); `files` = `out/mcp-server.js` +
  `resources` (lines 10-13). There is no `src/` in the package (Glob
  `packages/mcp-server/src/**/*.ts` returns nothing).
- The server JS is built from the extension TS by esbuild:
  `extensions/drm-copilot/package.json:178` `"bundle:mcp-server": "node esbuild-mcp-server.cjs"`.
- `packages/mcp-server/prepack.cjs:6-8` states: "After F11 removed the dead
  Python bridge and bundled Python, the standalone MCP server must not ship any
  `.py` file or the (removed) bundled `scripts/` subtree." Its `shouldCopy`
  filter (lines 33-49) excludes every `*.py` and any `/scripts/` segment when
  copying `extensions/drm-copilot/resources` into `packages/mcp-server/resources`.
- The tool runs in-process TS, not a Python subprocess:
  `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts:30-36`
  ("The prior Python-spawn path threw on a non-zero exit... A workflow `Error`...
  propagates here unchanged"), and line 120 passes a no-op `codeLauncher`.
- The TS is an explicit direct port of the Python:
  `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts:6-14`
  ("Direct TypeScript port of the bundled `dev_tools/new_active_feature_folder_flow.py`...
  every emitted line, and every error message are byte-identical to the Python source").

### Files implementing the epic-type scaffolding path today (both trees must change, in parity)

TypeScript (MCP runtime — authoritative):
- `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` —
  `createActiveFolder`; computes the target dir at lines 198-201
  (`docs/features/active/${folderSlug}` for all types) and routes copy/docs.
- `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` —
  `copyTemplate` (lines 193-214; epic falls into the `else` branch that does
  `fs.copyTree(templateDir, targetDir)`); `materializePlanFile` (returns null
  for epic since no plan template).
- `extensions/drm-copilot/src/lib/new-active-feature-folder/docs.ts` —
  `updateFeatureDocs` epic branch (lines 205-219; stamps `initiative.md`, returns
  `[initiative.md]`).
- `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts`
  — wiring; `index.ts` — facade.

Python (repo CLI/agents — co-authoritative reference):
- `scripts/dev_tools/new_active_feature_folder_flow.py` — `create_active_folder`;
  target dir at line 133 (`docs/features/active/<folder_slug>` for all types);
  epic dispatch at lines 236-251 (via `update_feature_docs`).
- `scripts/dev_tools/new_active_feature_folder_io.py` — `copy_template` (epic
  path), `materialize_plan_file`.
- `scripts/dev_tools/new_active_feature_folder_docs.py` — `update_feature_docs`
  epic branch (mirror of docs.ts lines 205-219).
- `scripts/dev_tools/new_active_feature_folder_models.py` — `NAME_PATTERN`,
  `validate_feature_name`, `resolve_workspace` (used by target-dir logic).

Exact functions to change for the epic path:
1. Target-directory routing (currently unconditional `docs/features/active/<slug>`)
   — add an epic branch that targets `docs/features/epics/<epic-slug>/`
   (`flow.ts` + `new_active_feature_folder_flow.py`).
2. `copyTemplate`/`copy_template` epic branch — copy the new `epic.md` +
   `epic-status.md` template set instead of the whole tree / `initiative.md`.
3. `updateFeatureDocs`/`update_feature_docs` epic branch — stamp `epic.md`
   (and seed `epic-status.md` as generated placeholder), drop `initiative.md`.
4. The service-call summary string (`newActiveFeatureFolderServiceCall`,
   service-call.ts:127) and the returned `destinationPath` remain valid but now
   resolve under `epics/`; verify no test hard-codes `active/` for epic.

## 2. Current epic scaffolding behavior (traced)

Today `new_active_feature_folder(type=epic)`:
- Computes `target_dir = docs/features/active/<folder_slug>` — epics are NOT
  special-cased for path (`new_active_feature_folder_flow.py:133`,
  `flow.ts:198-201`).
- Recursively copies the epic template tree via `fs.copyTree`
  (`io.ts:211-213`, epic is in the non-bug `else`).
- Stamps `initiative.md` header metadata and returns it as the file to open
  (`docs.ts:205-219`).
- Does NOT create `epic-plan.md`, `epic-status.md`, or the `epics/<slug>/` tree.
  There is no such template and no code path for it.

Bundled templates used (all three are committed and each contains only
`initiative.md`):
- `docs/features/templates/epic/initiative.md` — workspace fallback
  (`flow.ts:159-162` / `new_active_feature_folder_flow.py:104-107`).
- `extensions/drm-copilot/resources/feature-templates/epic/initiative.md` —
  the bundled `templateRoot` the MCP tool passes
  (`new-active-feature-folder-service-call.ts:74-75`, forwarded as
  `templateRoot`).
- `packages/mcp-server/resources/feature-templates/epic/initiative.md` — build
  copy produced by `prepack.cjs`.

The epic template content is `docs/features/templates/epic/initiative.md`
(Initiative Overview + Decomposition + Milestones sections). There is no
`plan.yyyy-MM-ddTHH-mm.md` for epic, so `materialize_plan_file` returns null.

Conclusion: the `epics/<slug>/epic-plan.md` + `epic-status.md` layout described
for #260 in the design doc is produced by the epic-orchestrate **agent
workflow**, hand-authored per the skill, not by the MCP scaffolding tool.

New-state mapping (per §0):
- New epic template set: `epic.md` (frontmatter DAG + optional intent block +
  merged narrative) and `epic-status.md` (generated placeholder). Retire
  `initiative.md`. Add these templates to all three template locations
  (workspace + extension resources; the mcp-server copy is regenerated by
  prepack).
- New target-dir branch: `docs/features/epics/<epic-slug>/`.
- New docs-stamping branch: stamp `epic.md`; write a generated-only
  `epic-status.md` seed.

## 3. Manifest consumers

### `scripts/dev_tools/epic_wave_computation.py`

- `compute_wave_numbers(manifest: Mapping[str, Sequence[str]])` is a pure,
  key-agnostic function over string keys (lines 72-153). It does NOT read the
  manifest file; the caller (the epic-orchestrator agent) builds the mapping.
- Therefore keying the DAG by `issue_num` requires no change to this function —
  the caller supplies whatever string keys it uses. The reference-impl contract
  (skill §Wave Assignment) still holds.
- Test: `tests/scripts/dev_tools/test_epic_wave_computation.py` uses abstract
  string keys (`child-a`, etc.), so it is already key-neutral and stays
  byte-identical.

### `scripts/dev_tools/validate_epic_orchestrator_state.py`

- Validates the **checkpoint JSON** (`artifacts/orchestration/epic-orchestrator-state.json`),
  not the manifest markdown. There is no Python parser for the `epic.md` /
  `epic-plan.md` YAML frontmatter anywhere; the agent parses it.
- The checkpoint `features[]` already carries both `feature_folder` and
  `issue_num` (test fixture `build_valid_epic_state()`,
  `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py:29-49`), but
  the DAG is keyed on `feature_folder`:
  - `_validate_feature_folder_uniqueness_and_dependencies` (lines 140-199) —
    depends_on entries must resolve to a defined `feature_folder`.
  - `_detect_dependency_cycle` (lines 202-256) — graph keyed by `feature_folder`.
  - `_validate_wave_barrier_ordering` (lines 287-342) — `by_folder` index keyed
    by `feature_folder`.
  - `_validate_waves_consistency` (lines 345-388) — `waves[].feature_folders`.
- TS parity port that also must change:
  `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`
  (lines 1-26: "The MCP-served `validate_orchestration_artifacts` tool is backed
  by this TS port; the Python CLI remains the direct/test entrypoint"). Error
  strings are asserted identical to Python.

### Proposed key-gating strategy (keeps legacy byte-identical)

1. `issue_num` keying: because `compute_wave_numbers` is key-agnostic, the agent
   can build the mapping keyed by `issue_num`. In the validator, add key-gated
   resolution: detect whether each `depends_on` entry is an int/issue_num
   reference vs a `feature_folder` string, and resolve dependencies against the
   union index (`feature_folder` set plus `issue_num` set). When every
   `depends_on` entry is a folder-basename string (the legacy shape), the new
   branch is inert and existing error output is byte-identical. Add the resolver
   as a small helper so both the uniqueness check and the cycle/barrier checks
   share it.
2. Optional intent-block validation: the SAFe block lives in the `epic.md`
   frontmatter, which no Python tool parses today. Two additive options for the
   planner: (a) a new, presence-gated manifest-frontmatter validator, or (b)
   carry the intent fields into the checkpoint and validate them presence-gated
   inside `validate_epic_orchestrator_state.py` (mirroring the key-gated pattern
   used for `remediation_loop` / `human_interaction` / `complexity_assessments`
   in `.claude/rules/orchestrator-state.md`). Either way, the check must be
   key-gated so a checkpoint/manifest without the intent keys validates exactly
   as before.
3. Fixtures: the existing legacy fixtures in
   `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` and
   `tests/scripts/dev_tools/test_epic_wave_computation.py` must remain unchanged
   and passing (the byte-identical guarantee). Add new fixtures alongside for
   the issue_num-keyed DAG and the intent block. Mirror any TS-side fixtures in
   `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`.

## 4. Skill surface — `.claude/skills/epic-orchestrate/SKILL.md`

Sections to edit:
- **Epic Dependency Manifest (lines 23-49):** change the manifest path from
  `docs/features/epics/<epic-slug>/epic-plan.md` (line 26) to `.../epic.md`;
  change `feature_folder` from "the canonical identifier" (lines 44-46) to a
  resolvable hint, with `issue_num` as the primary key; add the optional SAFe
  intent block to the frontmatter schema (lines 32-42).
- **Documentation Maintenance Boundaries (lines 208-227):** rename `epic-plan.md`
  → `epic.md` throughout (lines 210-213); reinforce that `epic-status.md` is
  regenerated-only.
- **Context Handoff to Dependent Features (lines 134-145):** remove the
  active→completed path-drift workaround. The exact text to remove is the
  parenthetical on **line 140**:
  > `spec: docs/features/active/<dep_feature_folder>/spec.md — or docs/features/completed/<dep_feature_folder>/spec.md if already promoted to completed`
  Replace with an `issue_num`-keyed resolvable-hint phrasing that resolves the
  concrete path (active or completed) from the checkpoint at emit time.
- **Epic-Level Checkpoint (lines 229-248):** the `epic_manifest_path` field and
  the validate command reference the manifest; update naming to `epic.md`.
- **Completion Requirements (lines 250-259):** references `epic-status.md` path
  (line 257); confirm it still points into `epics/<slug>/`.

Bundled mirror and other duplicated locations:
- Byte-identical mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
  (enforced by the parity test in §5). Must be synced on any edit.
- The skill is **not** mirrored into `.codex` or `.agents` (Glob/Grep for
  `epic-orchestrate` under `.codex` returns nothing; the codex/agents and
  copilot push-down sets do not include it).
- Related runtime files that also carry the manifest path/schema and may need
  matching edits + re-sync: `.claude/agents/epic-orchestrator.md`,
  `.claude/agents/epic-review.md`, `.claude/skills/review-epic/SKILL.md`
  (each with its `resources/claude-customizations/.claude/...` mirror). The
  `.github`-side `review-epic.prompt.md` / `epic-review.agent.md` reference the
  epic review flow but not the manifest path directly; confirm during planning.

## 5. Bundled-mirror + push-down parity

### Contract tests that enforce runtime↔mirror parity

Python (pytest):
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` —
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines
  100-125) asserts **every** `.claude/**` file (except `settings.local.json` and
  `.claude/agent-memory/**`) is present and **byte-identical** in
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`. This is
  the gate that forces the epic-orchestrate SKILL.md (and any touched agent/hook)
  mirror sync.

TypeScript (Jest):
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
  — asserts every bundled `.claude` agent/skill/hook appears in the union of
  `pack-manifests/*.json` `paths[]` (lines 122-138), and explicitly asserts the
  epic-orchestrate skill/agent/hooks are present (lines 140-156). The
  epic-orchestrate skill is already listed in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:50`.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`
  — behavior/parity tests for the TS validator port.

Note: a `test_validate_orchestration_artifacts_bundle_parity` and
`test_push_down_claude_bundled_parity` exist only as stale `.pyc` under
`tests/scripts/dev_tools/__pycache__/` with no current `.py` source; treat their
prior guarantees as superseded by the resource-contracts test above and the
Python-exclusion packing model (`prepack.cjs`). This should be confirmed during
planning, not assumed.

### Mirror files to sync per surface

- epic-orchestrate skill → `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
- `epic-orchestrator.md` / `epic-review.md` / `review-epic/SKILL.md` (if edited)
  → their `resources/claude-customizations/.claude/...` counterparts.
- New epic-status guard hook (if added, §6) → `.claude/hooks/<name>.ps1`, its
  bundle mirror, and a `pack-manifests/*.json` `paths[]` entry (else the
  completeness test fails).
- Epic feature templates (`epic.md`, `epic-status.md`) →
  `docs/features/templates/epic/` and
  `extensions/drm-copilot/resources/feature-templates/epic/`
  (`packages/mcp-server/resources/feature-templates/epic/` is regenerated by
  `prepack.cjs` and need not be hand-edited, but is committed today).

### Push-down tooling

- `push_down_claude_customizations` (`scripts/dev_tools/push_down_claude_customizations.py`):
  copies the `.claude` tree (`ROOT_FOLDERS = (Path(".claude"),)`, line 101)
  from the bundle root
  `extensions/drm-copilot/resources/claude-customizations` (line 67), excluding
  `.claude/settings.local.json` (line 102) and scope-filtering agent memory.
  Pack selection is driven by `pack-manifests/*.json`. The epic-orchestrate
  skill and the epic hooks ARE in the pushed-down set (`core.json` lines 9-67).
  MCP tool / extension command: `push_down_claude_customizations` /
  `drmCopilotExtension.pushDownClaudeCustomizations`
  (`extensions/drm-copilot/package.json:108-111`). Tests:
  `pytest tests/scripts/dev_tools/test_push_down_claude_*.py` and the Jest
  suites under `extensions/drm-copilot/test/lib/push-down/` plus
  `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`.
- `push_down_codex_and_agents_customizations`
  (`scripts/dev_tools/push_down_codex_and_agents_customizations.py`): copies the
  `.codex` / `.agents` customizations. The epic-orchestrate skill and epic
  templates are NOT in this set.
- `push_down_copilot_customizations`
  (`scripts/dev_tools/push_down_copilot_customizations.py`): copies the
  `.github` customizations (with reference rewrites). The epic-orchestrate skill
  and epic templates are NOT in this set (though `.github` carries the
  separate review-epic prompt/agent).
- Feature templates are not part of any `.claude` push-down; they ship as MCP
  resources under `extensions/drm-copilot/resources/feature-templates` and are
  copied into the MCP package by `prepack.cjs`.

## 6. Optional epic-status hand-edit guard

- Hook pattern: existing guards are PowerShell PreToolUse hooks that read the
  tool-call JSON from stdin and emit
  `hookSpecificOutput.permissionDecision` = `allow`/`deny`. Model:
  `.claude/hooks/enforce-checkpoint-monotonic.ps1` (activates only when the
  target `file_path` matches a specific artifact; allows Edit partial patches;
  validates full Write content). Epic-specific precedents:
  `.claude/hooks/enforce-epic-merge-gate.ps1`,
  `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`.
- No epic-status regeneration logic exists anywhere today: Grep for
  `epic-status|epic_status|regenerat` returns no production Python, TS, or
  PowerShell implementation. `epic-status.md` is currently regenerated by the
  agent by hand per the skill (§Documentation Maintenance Boundaries).
- Smallest viable guard therefore has a prerequisite: a deterministic
  epic-status **projector** (checkpoint JSON → expected `epic-status.md` text)
  must exist first. Recommended shape:
  1. Add a pure projector (Python reference impl, e.g.
     `scripts/dev_tools/epic_status_projection.py`, key-neutral) that renders
     the status table from `epic-orchestrator-state.json`.
  2. Add a PreToolUse hook on Write/Edit matching
     `docs/features/epics/*/epic-status.md` that regenerates the expected
     projection and denies when the Write content differs (reason e.g.
     `EPIC_STATUS_HAND_EDIT_BLOCKED`). Edit partial patches follow the
     monotonic-hook precedent (allow, caught on next Write).
  - A lighter alternative (no projector) is to deny any direct hand Write/Edit
    to `epic-status.md` outright unless a generator provenance marker is present.
    This is smaller but weaker (does not verify content equals the projection).
- Any new hook must be bundled + pack-manifested + parity-tested per §5, and get
  a Pester test under `tests/scripts/claude-hooks/`.

## 7. Toolchain commands (for the planner to cite)

Python (`.claude/rules/python.md`):
- Format: `poetry run black .`
- Lint: `poetry run ruff check .`
- Type-check: `poetry run pyright`
- Test: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

TypeScript (run from `extensions/drm-copilot`; `.claude/rules/typescript.md`):
- Format: `npm run format`
- Lint: `npm run lint`
- Type-check: `npm run typecheck`
- Test: `npm run test` (coverage: `npm run test:coverage`)

PowerShell (PoshQC via MCP; `.claude/rules/powershell.md`):
- Format: `mcp__drm-copilot__run_poshqc_format`
- Analyze: `mcp__drm-copilot__run_poshqc_analyze` (autofix:
  `mcp__drm-copilot__run_poshqc_analyze_autofix`)
- Test: `mcp__drm-copilot__run_poshqc_test` (config
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)

Order: format → lint/analyze → type-check (skip for PowerShell) → test; restart
from step 1 on any failure or auto-fix.

## 8. Automation Feasibility

This is a pure code, tooling, template, and documentation change with no
third-party UI, no external service, and no network dependency. Every step is
automatable end-to-end with no human interaction:
- Edits are to text files (TS, Python, PowerShell, Markdown, JSON manifests) in
  the repository, all under the automatable toolchain in §7.
- The one interactive affordance in the scaffolding path — the VS Code editor
  launch — is already bypassed on the MCP/non-interactive path via a no-op
  `codeLauncher` (`new-active-feature-folder-service-call.ts:119-120`), so
  epic scaffolding produces files without spawning an editor.
- Parity and validation are enforced by deterministic automated tests
  (pytest, Jest, Pester) already present (§3, §5).
- The migration for the existing epic #260 is a low-cost, scriptable text
  reorganization (design doc §6) and requires no human decision beyond the
  already-fixed design.

No human-interaction requirements were found. The only planning-time decisions
(intent-block validation location in §3; projector-vs-marker guard in §6) are
design choices resolvable within the plan, not runtime human interactions.

## 9. Key file references (absolute-path anchors)

- TS runtime (authoritative for MCP): `extensions/drm-copilot/src/lib/new-active-feature-folder/{flow,io,docs,models,markdown,index}.ts`, `.../new-active-feature-folder-service-call.ts`
- TS validator port: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`
- Python reference: `scripts/dev_tools/new_active_feature_folder_{flow,io,docs,models,markdown}.py`
- Manifest consumers: `scripts/dev_tools/epic_wave_computation.py`, `scripts/dev_tools/validate_epic_orchestrator_state.py`
- Consumer tests: `tests/scripts/dev_tools/test_epic_wave_computation.py`, `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`
- Skill (runtime + mirror): `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- Parity gates: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
- Push-down tooling: `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_codex_and_agents_customizations.py`, `scripts/dev_tools/push_down_copilot_customizations.py`
- Epic templates (3 committed copies, `initiative.md` only today): `docs/features/templates/epic/`, `extensions/drm-copilot/resources/feature-templates/epic/`, `packages/mcp-server/resources/feature-templates/epic/`
- Packing model: `packages/mcp-server/prepack.cjs`, `packages/mcp-server/package.json`
- Hook model for §6: `.claude/hooks/enforce-checkpoint-monotonic.ps1`
