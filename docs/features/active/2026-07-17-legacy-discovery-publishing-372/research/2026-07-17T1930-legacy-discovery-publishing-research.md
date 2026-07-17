# legacy-discovery-publishing (#372) — Publishing-Contract Research

- Epic: legacy-discovery-and-parity (`docs/features/epics/legacy-discovery-and-parity/epic.md`,
  `objective-source.md`)
- Feature: `legacy-discovery-publishing` (issue #372, epic placeholder #9012)
- Scope confirmed: none of the upstream epic-child assets (agent personas, skills, hooks,
  schemas, init-templates) exist yet in this worktree. Verified by `Glob` over
  `.claude/agents/*.md`, `.claude/skills/**`, `.claude/hooks/*`, and
  `docs/features/epics/legacy-discovery-and-parity/**` — none contain any
  `legacy-discovery-*` asset. This research designs against the push-down/converter
  **contracts**, not against present asset files, per the task framing.

## Q1 — Byte-identical mirror contract for the three `resources/` subtrees

### `.claude/**` → `extensions/drm-copilot/resources/claude-customizations/.claude/**`

Read in full: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

- `SCOPED_ROOTS = (Path(".claude"),)` (line 19) — the parity scan enumerates only
  `.claude/**`, nothing else.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100-125) is
  **fully data-driven**: it calls `list_scoped_files(REPO_ROOT)` (an `rglob("*")` over the
  real root `.claude/` tree), excludes exactly two things —
  `Path(".claude/settings.local.json")` and any path under `.claude/agent-memory/**`
  (`_is_agent_memory_path`, lines 70-97) — and for every remaining path asserts (a) it exists
  in the bundle and (b) `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (byte/text
  identity). **No hardcoded anchor list gates this test.** Any new file dropped under
  `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/rules/`, or
  `.claude/settings.json` at repo root will fail this test the moment it exists at root
  without an identical counterpart in the bundle — and passes automatically once the mirror
  file is added with identical bytes. **No test-code change is required** to make this test
  cover new legacy-discovery assets; only the mirror copy is required.
- A second test, `test_bundled_claude_payload_contains_required_runtime_files` (lines 51-64),
  checks a **separate, hardcoded** `REQUIRED_BUNDLED_FILES` anchor tuple (lines 20-30, e.g.
  `.claude/settings.json`, several specific `SKILL.md` paths, `.claude/rules/python.md`,
  `.claude/agents/orchestrator.md`). This anchor list is a defense-in-depth spot-check of
  pre-existing files; it is not required to be extended for new assets to pass (the
  fully-enumerated test above already forces the mirror), but extending it with one or two
  new anchors (e.g. one new agent persona path) is optional, low-cost defense-in-depth.
- Exemptions: `.claude/agent-memory/**` (scope-distributed, not byte-mirrored — see
  `test_bundled_agent_memory_scopes_are_well_formed`, lines 243-286, which instead enforces a
  `metadata.scope: general` marker on every non-index memory file and `scope: repo` on every
  `MEMORY.md` index) and `.claude/settings.local.json` (local-only, must be **absent** from the
  bundle — `test_bundled_claude_payload_excludes_settings_local_json`, lines 148-156).
- Pack manifests (`pack-manifests/*.json`) and `.claude-variants/csharp-legacy/**` are
  siblings of `.claude/` inside the bundle and are explicitly asserted to be **outside** the
  `.claude/**` parity scope (`test_pack_manifests_are_outside_the_parity_scope`, lines
  128-145; `test_bundled_claude_payload_excludes_variant_subtree_from_parity`, lines 162-175).

### `.codex/` + `.agents/` → `extensions/drm-copilot/resources/codex-and-agents-customizations/`

Read in full: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.

- `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))` (line 34).
- `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (lines
  206-219) is likewise **fully data-driven**: `list_scoped_files(REPO_ROOT)` over real
  `.codex/**` + `.agents/**`, with **no exclusions at all** (no agent-memory analogue exists
  for Codex), asserting presence and byte identity in the bundle for every enumerated path,
  and additionally asserting a repo path never collides with a bundle-only path
  (`list_bundle_only_files` = `pack-manifests/**` + `.agents-variants/**` +
  `.codex-variants/**`, lines 117-126, 36-39).
- `test_bundled_codex_and_agents_payload_contains_required_runtime_files` (lines 178-185)
  is the hardcoded-anchor twin (`REQUIRED_BUNDLED_FILES`, lines 54-67) — same
  defense-in-depth relationship as the Claude side.
- `test_bundled_codex_pack_manifests_and_variants_exist` (lines 188-196) checks
  `REQUIRED_PACK_MANIFESTS` (six packs, lines 40-47) and `REQUIRED_VARIANT_FILES`
  (four C#-legacy paths, lines 48-53) are present as **bundle-only** files (not enumerated in
  the parity-scoped set).
- Two additional invariants specific to this subtree, both unrelated to new-asset mirroring
  but relevant if a new hook needs MCP-tool registration: `orchestration-routing.json`
  must remain a single shared resource with no Codex-bundle duplicate (lines 199-203), and
  `.codex/config.toml`'s `mcp_servers.drm-copilot` transport must retain the full approved
  tool allowlist (`EXPECTED_DRM_COPILOT_TOOLS`, lines 70-91) while individual agent-role
  `.toml` files must **omit** that transport block (lines 172-176, 229-237).

### `.github/**` → `extensions/drm-copilot/resources/customizations/.github/**` — gap found

- `.github/` at repo root is a genuine hand-authored native tree (verified:
  `.github/agents/*.agent.md` and `.github/skills/*/SKILL.md` exist at root, not just in the
  bundle — e.g. `.github/skills/atomic-plan-contract/SKILL.md` is byte-identical to
  `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`,
  spot-checked by direct `Read`).
- **No automated byte-identical resource-contract test exists for this subtree** analogous to
  the Claude/Codex ones. `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
  and `test_push_down_copilot_customizations_rewrites.py`/`_helpers.py` are in-memory unit
  tests of the *publisher engine* (rewrite/placeholder logic for text copied into a
  *destination consumer repo*), not real-filesystem parity assertions between repo root
  `.github/` and the bundle. This is a **pre-existing gap**, not introduced by this feature.
- **Relevance to this feature: out of scope.** Every upstream asset this feature must mirror
  is Claude-native (`.claude/agents/*.md`, `.claude/skills/<name>/SKILL.md`,
  `.claude/hooks/*.ps1`) or Codex-native by conversion; the epic objective (section 1-7 of
  `objective-source.md`) never describes an authored `.github/agents/*.agent.md` or
  `.github/skills/<name>/SKILL.md` counterpart for the discovery personas/skills. No
  `.github` mirroring action is required by this feature unless a future epic child
  explicitly authors Copilot-native equivalents — flagged here so it is not silently assumed
  in-scope.

### Conclusion for Q1

The parity tests for the two subtrees this feature actually touches (`claude-customizations`,
`codex-and-agents-customizations`) are **data-driven, not anchor-list-driven**. No test source
change is required to make them "cover" new assets — copying the files into the bundle with
identical content is necessary and sufficient. Test-file changes are needed only for the
**pack-manifest** side (Q4/Q5 below), which is a separate, non-byte-identity contract.

## Q2 — Codex-native converter registration (`mapping.py`, `classifier.py`, `inventory.py`)

Read in full: `scripts/dev_tools/codex_native_converter/inventory.py`,
`classifier.py`, `mapping.py`, `README.md`.

- `inventory.py` lines 35-51 (`_SUPPORTED_ROOTS`) declares the **only** top-level surfaces the
  converter will ever scan for `SourceEcosystem.CLAUDE`: `CLAUDE.md`, `.claude/skills`,
  `.claude/agents`, `.claude/hooks`, `.claude/settings.json`, `.claude/rules`. This is a
  closed enumeration of *directories*, not of individual names — `_iter_supported_artifacts`
  (lines 123-166) walks every file beneath each supported root via `rglob("*")`.
- `classifier.py`'s `_classify_claude` (lines 267-386) branches purely on **path shape**:
  `.claude/skills/**/SKILL.md` → `REUSABLE_SKILL`/`SHARED_SKILL` (lines 300-308);
  `.claude/agents/*.md` → `AGENT_MANIFEST`/`SUBAGENT` (lines 310-325);
  `.claude/hooks/*` → `HOOK_DEFINITION`/`HOOK` (lines 327-335);
  `.claude/settings.json` → `PERMISSIONS_OR_SETTINGS`/`MCP_CONFIG` (lines 337-349);
  `.claude/rules/*.md` → `PATH_SCOPED_INSTRUCTION`, routed to `STANDING_GUIDANCE` or
  `SHARED_SKILL` depending on whether the rule declares a repo-wide `paths:` YAML block
  (lines 351-376). There is **no name-keyed table or per-agent/per-skill registry anywhere**
  in this module.
- `mapping.py`'s `plan_target_paths` (lines 108-189) likewise derives the Codex-native
  destination purely from `target_role` plus a normalized basename
  (`_planned_skill_name`, `_planned_hook_name`, `_normalized_name`, lines 38-105): a skill at
  `.claude/skills/<name>/SKILL.md` always plans to `.agents/skills/<name>/SKILL.md`
  (lines 139-144); an agent at `.claude/agents/<name>.md` always plans to
  `.codex/agents/<name>.toml` (lines 146-151); a hook always plans to
  `.codex/hooks/<name>.ps1` (lines 156-161).

### Determination

**Mirroring is purely structural.** Four new agent personas landing at
`.claude/agents/<persona-name>.md` and any number of new skill folders at
`.claude/skills/<skill-name>/SKILL.md` and hook files at `.claude/hooks/<hook-name>.ps1` are
classified, mapped, and converted automatically by the existing path-prefix rules with **no
edits to `mapping.py`, `classifier.py`, or `inventory.py`**. No function or table needs a new
entry for a new agent/skill/hook *name* — only a new top-level *directory* (e.g. a
hypothetical `.claude/schemas/`) would require a new `_SUPPORTED_ROOTS` entry and a new
`_classify_claude` branch, and per the Q on schema placement below, the schemas are not
expected to land under `.claude/` at all, so this edge case does not apply to this epic's
asset set. This directly answers the epic's own open research question
(`objective-source.md` lines 145-147: "Codex-native converter: whether new skill/agent
categories require registration ... or whether mirroring is purely structural") — the
answer is **purely structural, no registration required**, evidenced above.

### Note on schema/init-template placement (informs scope, not this converter)

- `scripts/dev_tools/json_config.py` lines 12-16 define `GOVERNED_GLOBS = ("scripts/**/*.json",
  "docs/**/*.json", "examples/**/*.json")` — the repo's only existing "versioned JSON schema
  validation" machinery (`validate_json.py`) governs JSON files under `scripts/`, `docs/`,
  and `examples/`, **not** under `.claude/`. The epic's schema-versioning convention
  explicitly reuses this governed-glob machinery (`objective-source.md` lines 108-110), so the
  seven schemas most plausibly land under `scripts/dev_tools/<legacy-discovery-package>/schemas/vN/*.schema.json`
  (Python package data), consistent with the repo's one existing multi-file dev-tools
  subpackage precedent, `scripts/dev_tools/codex_native_converter/` (verified via `Glob` on
  `scripts/dev_tools/*`).
- If schemas/init-templates land under `scripts/` (Python source), they are **not** part of
  the `.claude`/`.github`/`.codex`+`.agents` byte-identical mirror contract at all — Python
  package code ships to consumers through the MCP-server npm package
  (`@danmoisan/drm-copilot-mcp`, referenced in
  `test_push_down_codex_and_agents_resource_contracts.py` line 144-145 and the
  `.codex/config.toml` transport asserted at lines 141-170), not through the `.claude`/`.codex`
  push-down publishers. **This is an inference from repository convention, not a fact
  verified against the (not-yet-merged) upstream schema/init-template branches** — flag for
  re-verification once `legacy-discovery-schemas` (#359) and `legacy-discovery-init-templates`
  (#362) land on the integration branch, since if either instead places files under `.claude/`
  the mirror obligation would change accordingly.

## Q3 — Variant subtrees (`.claude-variants/`, `.codex-variants/`, `.agents-variants/`)

- The only variant profile that exists today is `csharp-legacy` vs. `csharp-modern`, and it
  exists to let the **same four canonical destination paths** be sourced from two different
  content profiles for one language toolchain choice:
  `push_down_claude_pack_selection.py` lines 58-63
  (`CSHARP_CANONICAL_PATHS`), lines 319-361 (`resolve_variant_source_path` — swaps the
  `.claude/` prefix for `.claude-variants/csharp-legacy` only for those four paths and only
  under `csharp_variant == "legacy"`).
- Contract-test evidence: `test_variant_subtree_is_bundle_only_and_non_colliding`
  (`test_push_down_claude_resource_contracts.py` lines 178-212) asserts every variant file
  maps to an existing modern counterpart at the same relative tail and has **different**
  content — i.e. a variant is always an alternate profile for an existing canonical
  destination, never a new destination path of its own. `REQUIRED_VARIANT_FILES`
  (`test_push_down_codex_and_agents_resource_contracts.py` lines 48-53) is the same four-path
  shape mirrored to the Codex side.

### Determination

Discovery-framework assets (agent personas, skills, hooks) are domain-neutral and have
exactly one profile — there is no "legacy" vs. "modern" alternate content for a Legacy
Parity Analyst persona or a discovery skill. **No `.claude-variants/`, `.codex-variants/`, or
`.agents-variants/` entries are required.** Variants are strictly a language-toolchain-profile
mechanism (currently C# only) and are out of scope for this feature.

## Q4 — Pack-manifest placement (`core` vs. a language-neutral pack)

- Existing packs, both ecosystems (verified via `Glob`): `core`, `csharp-legacy`,
  `csharp-modern`, `powershell`, `python`, `typescript`. **No pack named
  "language-neutral" or similar exists today** — `core` already fills that role. Its own
  source comments say so verbatim:
  `push_down_claude_pack_selection.py` line 52, `# Pack name reserved for the always-included
  non-language customization set`, and its manifest label is literally `"Core (always
  included)"` (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  line 3; identical label in the Codex analogue).
- Mechanism, not just convention: `compute_published_paths` (lines 269-316) and
  `load_pack_manifests` (lines 130-179) **always union `core`** into any explicit `--packs`
  selection (`effective_names = set(selected_pack_names) | {CORE_PACK_NAME}`, line 307;
  `names_to_load = set(selected_pack_names) | {CORE_PACK_NAME}`, line 166), verified by
  `test_compute_published_paths_always_includes_core`
  (`tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` lines 216-229: selecting
  `python` alone still publishes `.claude/settings.json` and `.claude/agents/orchestrator.md`
  from `core`). The identical always-include-core mechanism exists on the Codex side
  (`push_down_codex_pack_selection.py` lines 16, 57, 63, 168).
- `core.json`'s current content (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`)
  is exactly domain/language-neutral cross-cutting policy and generic workflow personas:
  orchestration agents (`orchestrator.md`, `epic-orchestrator.md`, `atomic-executor.md`,
  `atomic-planner.md`, `task-researcher.md`, `prd-feature.md`, `human-exception-runbook.md`,
  `staged-review.md`, `status-updater.md`, `commit-message.md`), universal hooks
  (`enforce-checkpoint-monotonic.ps1`, `validate-*-output.ps1`, etc.), and universal rules
  (`general-code-change.md`, `general-unit-test.md`, `tonality.md`, `quality-tiers.md` —
  none of the per-language rule files `python.md`/`typescript.md`/`csharp.md` are in `core`;
  those are in their respective language packs). Note this file's contents already reflect
  agent personas structurally identical in kind to the four new discovery personas (generic,
  workflow-role personas, not language-bound).
- **Default (no `--packs` argument) behavior is unfiltered.**
  `_resolve_published_paths` in `push_down_claude_customizations.py` (lines 137-185,
  specifically 171-174) returns `None` and copies the **entire** bundle tree when no explicit
  pack selection is supplied — pack-manifest membership only matters for a *scoped*
  `--packs <name>` push-down. This means a manifest omission does not break the default
  full-tree push, but does silently drop the asset from any consumer that requests a
  language-scoped subset (e.g. TaskMaster pulling only `csharp-modern`, or TMW pulling only
  `typescript`) — exactly the failure mode `claude-pack-manifest-completeness.test.ts` exists
  to catch (see Q5).

### Determination

**Discovery-framework assets (the four agent personas, the discovery skills, and the
completion-gate hooks) belong in `core`.** Justification: (1) `core` is the only pack
guaranteed to reach every consumer regardless of which language pack(s) they select, which is
required because TaskMaster and TMW are expected to select their own respective language
packs (C#/.NET and TypeScript) rather than the unfiltered default; (2) the assets are
domain- and language-neutral by explicit epic mandate (`objective-source.md` "Required
Operating Mode" and "Architectural Boundaries"), matching every other persona/skill/hook
already resident in `core`; (3) inventing a new, separate pack (e.g. "discovery") would not
be automatically included under a scoped `--packs` selection — only `core` receives that
unconditional-union guarantee — so a new pack would require every consumer to explicitly
opt in, contradicting the epic's goal of consumers receiving the capability "through the
existing push-down tooling" without bespoke per-repo configuration
(`objective-source.md` line 109-110, epic.md line 121-122). This is a **design
recommendation for the eventual plan**, consistent with the mechanism as-verified; the actual
manifest edit is an atomic-plan-execution task, not something this research artifact performs.

## Q5 — Publishers/MCP tools in scope, and directory-vs-file manifest listing

### Publishers and helper modules in scope

- Python: `scripts/dev_tools/push_down_claude_customizations.py` (+ helpers
  `push_down_claude_pack_selection.py`, `push_down_claude_filesystem.py`);
  `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (+
  `push_down_codex_pack_selection.py`, `push_down_codex_filesystem.py`).
  `push_down_copilot_customizations.py` (+ `_filesystem.py`, `_rewrites.py`) is in scope only
  if a `.github`-native equivalent of the discovery assets is later authored (see Q1 gap
  note); not required for the currently-described asset set.
- TypeScript twins (`extensions/drm-copilot/src/lib/push-down/`):
  `claude-customizations.ts`, `claude-filesystem-adapter.ts`, `claude-pack-selection.ts`,
  `claude-pack-name-translation.ts`, `claude-memory-scope.ts`; `codex-agents-customizations.ts`,
  `codex-pack-selection.ts`; `copilot-customizations.ts`/`copilot-customizations-engine.ts`
  (same conditional scope note as the Python copilot publisher);
  `push-down-service-call.ts`, `filesystem-adapter.ts`, `reference-rewrites.ts` are shared
  infrastructure exercised indirectly.
- MCP tools: `push_down_claude_customizations`, `push_down_codex_and_agents_customizations`,
  `push_down_copilot_customizations` (all three appear in `EXPECTED_DRM_COPILOT_TOOLS`,
  `test_push_down_codex_and_agents_resource_contracts.py` lines 70-91, and are explicitly
  excluded from `APPROVED_DRM_COPILOT_TOOLS`, lines 92-102, meaning they require elevated
  `mcp_servers.drm-copilot` transport-level trust rather than per-tool `approval_mode`
  settings — verified by `assert_full_drm_copilot_transport`/`assert_no_role_local_drm_copilot_transport`,
  lines 141-176). `run_codex_native_converter` is the fourth tool in that same
  transport-level-only group and is in scope if/when the converter needs to be re-run to
  regenerate `.codex`/`.agents` output from the newly-mirrored `.claude` assets, though the
  converter's `apply` mode targets a `--destination-root` outside the repository
  (`codex_native_converter/README.md` lines 32-42) — it is not itself how the
  `resources/codex-and-agents-customizations/` bundle gets populated; that bundle is
  maintained by direct copy, mirroring the same manual-parity discipline as the `.claude`
  bundle (no automated generator script was found for either bundle in this repository).

### Directory vs. individual-file manifest entries

- `PackManifest.paths` is a `tuple[str, ...]` of exact, individual, `.claude`-relative POSIX
  path strings (`push_down_claude_pack_selection.py` lines 96-127, dataclass definition;
  lines 239-251, `_parse_manifest` validates each entry is a `str`, not a glob pattern).
  **There is no directory- or glob-level entry anywhere in the manifest schema or the loader.**
- Confirmed independently by the real-filesystem completeness test
  (`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`,
  read in full): it exists specifically because `computePublishedPaths()` "only publishes
  files listed in a selected pack manifest's `paths` array, so a bundled `.claude` agent,
  skill, or hook that is never added to any manifest is silently dropped from a
  manifest-scoped push-down" (file header comment, lines 8-17, documenting the fix for issue
  #279). The test enumerates every bundled `.claude/agents/*.md`, `.claude/hooks/*.ps1`, and
  `.claude/skills/*/SKILL.md` file from the real bundle
  (`enumerateBundledClaudeRelativePaths`, lines 62-91) and asserts each appears in the union
  of every manifest's `paths` array (`unionOfManifestPaths`, lines 98-120), excluding three
  named, pre-existing, explicitly out-of-scope exceptions (lines 50-55).

### Determination

**Every new `.claude/agents/*.md` persona file and every new `.claude/skills/<name>/SKILL.md`
skill must be added as an individual path string to the `core` manifest's `paths` array**
(both `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and
the Codex analogue `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`,
using the converted `.codex`/`.agents` destination paths for the latter). New hooks similarly
require an entry, plus a corresponding `.claude/settings.json` (and `.codex/config.toml`, if
converted) registration — `.claude/settings.json` itself is already a `core.json` entry
(line 5), so no manifest edit is needed for the settings file path itself, only for its
changed *content* (already covered by the byte-identical mirror obligation in Q1).
**A gap exists on the Python/Codex side**: no Python-side or Codex-side real-filesystem
manifest-completeness test currently exists (verified by `Grep` across
`tests/scripts/dev_tools/` and `extensions/drm-copilot/test/` for "completeness"/"real
filesystem" — only the one Claude/TS test found). Extending/aligning contract tests for this
feature (per the feature's stated scope item 4) should include adding a Python-side twin of
`claude-pack-manifest-completeness.test.ts` (or a Codex-side TS/Python equivalent) so a future
regression on either side cannot silently drop a bundled discovery asset from a scoped
push-down — this is a genuine pre-existing asymmetry the feature's "align the contract tests"
work should close, not merely reproduce.

## Summary of Determinations

| Question | Determination |
|---|---|
| Q1 mirror contract | Data-driven, full-tree byte-identical enumeration for `.claude/**` and `.codex/**`+`.agents/**`; no test-code change needed to *cover* new assets, only the copy. `.github` mirror has no automated parity test (pre-existing gap, out of scope for this asset set). |
| Q2 converter registration | Purely structural — path-prefix classification in `inventory.py`/`classifier.py`/`mapping.py`; no registration needed for new agent/skill/hook names. |
| Q3 variants | Not required — variants are a C#-toolchain-profile mechanism only; discovery assets are single-profile and domain-neutral. |
| Q4 pack placement | `core` — the only pack unconditionally unioned into every scoped `--packs` selection; already holds structurally identical generic workflow personas/rules/hooks. |
| Q5 publishers/manifests | Python + TS push-down modules for `claude` and `codex-and-agents`; MCP tools `push_down_claude_customizations`/`push_down_codex_and_agents_customizations`; manifests require individual path-string entries per new file (no glob/dir support) — Python-side completeness-test gap should be closed as part of "align the contract tests." |

## Rejected Alternatives

- **New "discovery" pack instead of `core`.** Rejected: not unioned automatically under a
  scoped `--packs` selection, so consumers selecting only their language pack would silently
  miss the capability unless every consumer's push-down invocation is updated to add
  `discovery` explicitly — contradicts the epic's "via the existing push-down tooling"
  acceptance criterion.
- **Registering new categories in `codex_native_converter`.** Rejected: the converter already
  classifies by path prefix within already-declared `_SUPPORTED_ROOTS`; no code path exists
  that keys on artifact name/category, so there is nothing to register.
- **Adding `.claude-variants` entries for discovery assets.** Rejected: variants model
  alternate content for one canonical destination path under a language-toolchain choice;
  domain-neutral, single-profile discovery assets have no second profile to route.
