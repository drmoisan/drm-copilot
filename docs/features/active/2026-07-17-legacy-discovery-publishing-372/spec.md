# legacy-discovery-publishing — Spec

- **Issue:** #372
- **Parent (optional):** legacy-discovery-and-parity (epic; manifest placeholder #9012)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2

## Overview

The `legacy-discovery-and-parity` epic adds new customization assets (agent personas, skills,
hooks, schemas, templates) under the repository-root native trees (`.claude/`, `.github/`,
`.codex/`+`.agents/`). The repository enforces byte-identical mirrors of the `.claude/**` and
`.codex/**`+`.agents/**` trees under `extensions/drm-copilot/resources/` via push-down contract
tests (`test_push_down_claude_resource_contracts.py` and
`test_push_down_codex_and_agents_resource_contracts.py`). An asset that is not mirrored fails
those contract tests, and a consumer repository (TaskMaster, TMW) does not receive the
discovery capability through the existing push-down tooling.

This feature makes the discovery assets shippable. It does not re-author the assets being
mirrored (agent personas, skills, hooks, schemas, templates authored by the upstream epic
children `legacy-discovery-agent-roles` #365, `legacy-discovery-schemas` #9008,
`legacy-discovery-skills` #366, `legacy-discovery-hooks` #359, `legacy-discovery-init-templates`
#362). It mirrors those assets into the `resources/` subtrees, records the Codex-native
converter registration determination, selects the push-down pack-manifest placement, and
extends/aligns the push-down contract tests.

**Preparation-mode note:** at the time this spec was authored, none of the upstream epic-child
assets exist yet in this worktree (verified by the research artifact's `Glob` scan of
`.claude/agents/*.md`, `.claude/skills/**`, `.claude/hooks/*`, and the epic folder). This spec
therefore designs against the push-down and converter **contracts**, not against specific
present asset paths. Execution-time work must re-verify each concrete path against the
upstream branches as they land, per the conditional items below.

Research basis: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/research/2026-07-17T1930-legacy-discovery-publishing-research.md`.

## Behavior

- Mirror every new customization asset added by the epic (agent personas from
  `legacy-discovery-agent-roles`, skills from `legacy-discovery-skills`, hooks from
  `legacy-discovery-hooks`) into the matching `resources/` mirror subtrees so the push-down
  contract tests pass byte-identically. Mirror schemas (`legacy-discovery-schemas`) and
  init-templates (`legacy-discovery-init-templates`) only if they land under a mirrored root;
  otherwise document them as out of mirror-contract scope (see "Schema/Init-Template
  Placement" below).
- Record the Codex-native converter registration determination: mirroring is purely structural.
  No edits to `scripts/dev_tools/codex_native_converter/mapping.py`, `classifier.py`, or
  `inventory.py` are required for the new agent personas, skills, or hooks, because those
  modules classify and convert by path prefix (`.claude/agents/*.md`, `.claude/skills/**/SKILL.md`,
  `.claude/hooks/*`), not by artifact name (research artifact, Q2).
- Select `core` as the push-down pack-manifest placement for the discovery-framework assets
  (agent personas, skills, hooks) and justify the choice against the manifest-union mechanism
  (see "Pack-Manifest Placement" below).
- Add each new agent-persona path, skill `SKILL.md` path, and hook path as an individual entry
  in the `paths` array of `core.json`, in both
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
  (using the converted `.codex`/`.agents` destination path on the Codex side).
- Extend/align the push-down contract tests: close the Python/Codex-side manifest-completeness
  test gap by adding a real-filesystem test, on the Python or Codex side, equivalent to
  `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, so a
  future omission from a manifest's `paths` array cannot silently drop a bundled discovery
  asset from a scoped push-down.

## Codex-Native Converter Registration Determination

**Determination: mirroring is purely structural; no converter source changes are required for
new agent, skill, or hook names.**

`inventory.py`'s `_SUPPORTED_ROOTS` and `classifier.py`'s `_classify_claude` route by
directory/path-prefix shape (`.claude/skills/**/SKILL.md`, `.claude/agents/*.md`,
`.claude/hooks/*`, `.claude/settings.json`, `.claude/rules/*.md`), and `mapping.py`'s
`plan_target_paths` derives Codex-native destinations from `target_role` plus a normalized
basename. None of these modules contain a name-keyed table or per-agent/per-skill registry.
A new agent persona at `.claude/agents/<persona-name>.md`, a new skill at
`.claude/skills/<skill-name>/SKILL.md`, or a new hook at `.claude/hooks/<hook-name>.ps1` is
classified, mapped, and converted automatically by the existing rules. Registration in
`mapping.py`/`classifier.py`/`inventory.py` would only be required if the epic introduced a new
top-level directory under `.claude/` (for example a hypothetical `.claude/schemas/`), which the
epic's asset set does not do — schemas are expected to land under `scripts/` (see below), not
under `.claude/`. This satisfies `objective-source.md` scope item 10 and its corresponding
research question.

## Pack-Manifest Placement

**Determination: `core`.**

`core` is the only pack unconditionally unioned into every `--packs` selection on both the
Python side (`compute_published_paths`, `push_down_claude_pack_selection.py`) and the Codex
side (`push_down_codex_pack_selection.py`); a consumer repository selecting only its own
language pack (for example TaskMaster selecting `csharp-modern`, or TMW selecting
`typescript`) still receives everything in `core`. `core.json`'s existing contents are
domain- and language-neutral cross-cutting personas, hooks, and rules (`orchestrator.md`,
`atomic-planner.md`, `enforce-checkpoint-monotonic.ps1`, `general-code-change.md`, etc.) —
structurally identical in kind to the four new discovery personas and the discovery skills,
which are domain-neutral by epic mandate and have no language affinity. A new, separate pack
(for example a hypothetical `discovery` pack) would not receive the unconditional-union
guarantee: a consumer would have to explicitly opt in, which contradicts the epic's stated goal
that consumers receive the capability "through the existing push-down tooling" without bespoke
per-repo configuration (`objective-source.md` line 109-110; `epic.md` "Mirror contract").
Default (no `--packs` argument) push-downs are unfiltered and copy the entire bundle regardless
of manifest membership; manifest placement matters specifically for a scoped `--packs`
push-down, which is the mode TaskMaster and TMW are expected to use.

## Schema/Init-Template Placement (Conditional)

The seven schemas (`legacy-discovery-schemas`) and the initialization templates
(`legacy-discovery-init-templates`) most plausibly land under
`scripts/dev_tools/<legacy-discovery-package>/schemas/vN/*.schema.json` (Python package data),
consistent with the epic's stated reuse of `scripts/dev_tools/validate_json.py`'s governed-glob
machinery (`GOVERNED_GLOBS = ("scripts/**/*.json", "docs/**/*.json", "examples/**/*.json")`) and
with the repository's one existing multi-file dev-tools subpackage precedent
(`scripts/dev_tools/codex_native_converter/`).

- **If** the schemas or init-templates land under `scripts/` (a non-mirrored root), they are
  Python source distributed to consumers through the MCP-server npm package
  (`@danmoisan/drm-copilot-mcp`), not through the `.claude`/`.codex` push-down publishers. In
  that case they are outside the byte-identical mirror contract, and this feature's work item
  for them is limited to documenting that scope boundary — no mirror copy, no manifest entry.
- **If** instead the upstream branches place schema or template files under a mirrored root
  (`.claude/`, `.codex/`, `.agents/`), the mirror obligation applies to those files exactly as
  it applies to agent personas, skills, and hooks: byte-identical copy into the matching
  `resources/` subtree, and, if a `--packs`-scoped consumer must receive them, an individual
  `core.json` path entry on both sides.
- This condition must be resolved against the actual upstream asset paths at plan-execution
  time, once `legacy-discovery-schemas` (#359 in the issue draft; #9008 per epic decomposition)
  and `legacy-discovery-init-templates` (#362) land on the integration branch. This spec does
  not assume an outcome; it documents both branches of the decision so execution can select
  the correct one without re-deriving the analysis.

## Inputs / Outputs

- Inputs: the merged upstream epic-child branches contributing agent-persona files under
  `.claude/agents/`, skill folders under `.claude/skills/<name>/SKILL.md`, hook files under
  `.claude/hooks/`, and (conditionally) schema/template files under `.claude/` or `scripts/`.
- Outputs:
  - Byte-identical copies of every new `.claude/**` and `.codex/**`+`.agents/**` asset under
    `extensions/drm-copilot/resources/claude-customizations/` and
    `extensions/drm-copilot/resources/codex-and-agents-customizations/` respectively.
  - Updated `paths` arrays in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
    and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  - A new or extended real-filesystem manifest-completeness test on the Python or Codex side.
  - This spec's documented Codex-native converter registration determination and pack-manifest
    justification.
- Config keys and defaults: none introduced. No changes to `push_down_claude_pack_selection.py`
  or `push_down_codex_pack_selection.py` default behavior (unfiltered full-bundle copy when
  `--packs` is omitted remains unchanged).
- Versioning or backward-compatibility constraints: the mirror and manifest changes are
  additive; no existing bundled path is removed, renamed, or reassigned to a different pack.

## API / CLI Surface

No new CLI commands, MCP tools, or flags are introduced by this feature. The existing push-down
surfaces are exercised as-is against the newly mirrored files:

- Python: `scripts/dev_tools/push_down_claude_customizations.py`,
  `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (and their pack-selection /
  filesystem helper modules).
- TypeScript twins: `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`,
  `codex-agents-customizations.ts` (and their pack-selection helpers).
- MCP tools (unchanged, elevated-trust transport-level tools per
  `EXPECTED_DRM_COPILOT_TOOLS`): `push_down_claude_customizations`,
  `push_down_codex_and_agents_customizations`.
- Example invocation (illustrative, not new): `--packs csharp-modern` on either publisher must
  still publish every discovery-framework agent, skill, and hook path because those paths are
  entries in `core`, which is unconditionally unioned into any `--packs` selection.
- Contracts and validation rules: `PackManifest.paths` is a `tuple[str, ...]` of exact,
  individual, root-relative POSIX path strings; there is no glob or directory-level entry
  anywhere in the manifest schema or loader.

## Data & State

- Data transformations and invariants: none beyond file copy. The mirror obligation is
  byte-for-byte identity between the repo-root native tree and the corresponding `resources/`
  subtree path; no rewriting, templating, or placeholder substitution applies to `.claude`/
  `.codex`/`.agents` mirrored files (rewrite/placeholder logic exists only for the separate
  `.github`-native Copilot-customizations publisher, which is out of scope for this feature).
- Caching or persistence details: none. No new persisted state; manifests are static JSON files
  read at push-down time.
- Migration or backfill requirements: none. This feature adds new mirrored files and manifest
  entries; it does not modify or migrate existing mirrored content.

## Constraints & Risks

- Domain neutrality: publishing mirrors generic discovery assets; no
  TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior is introduced by the
  mirrored copies, the manifest entries, or the extended contract tests.
- Depends on upstream epic children (`legacy-discovery-agent-roles`, `legacy-discovery-skills`,
  `legacy-discovery-hooks`, and conditionally `legacy-discovery-schemas`,
  `legacy-discovery-init-templates`) being merged into the epic integration branch before
  execution. This feature's own research was conducted against the contracts because no
  upstream asset yet exists in this worktree; execution must re-verify concrete asset paths
  once the upstream branches land, particularly for the conditional schema/template placement.
- Byte-identical mirror requirement: any content drift between a repo-root native file and its
  `resources/` counterpart fails the corresponding push-down contract test
  (`test_push_down_claude_resource_contracts.py`,
  `test_push_down_codex_and_agents_resource_contracts.py`).
- Manifest omission risk: a bundled file that is never added to any manifest's `paths` array is
  silently dropped from a manifest-scoped (`--packs`) push-down even though the byte-identical
  mirror test passes — this is the exact failure mode `claude-pack-manifest-completeness.test.ts`
  exists to catch on the Claude/TS side, and the gap this feature closes on the Python/Codex
  side.
- `.github/**` mirroring: no automated byte-identical parity test exists for `.github/**`
  (pre-existing gap, not introduced by this feature). No upstream discovery asset is described
  as landing under `.github/agents/*.agent.md` or `.github/skills/<name>/SKILL.md`; `.github`
  mirroring is out of scope for this feature unless a future epic child explicitly authors a
  Copilot-native equivalent.

## Implementation Strategy

- Implementation scope: (1) copy each newly merged `.claude/agents/*.md`,
  `.claude/skills/<name>/SKILL.md`, and `.claude/hooks/*` file byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/...`; (2) copy the
  Codex-converted equivalents byte-identically into
  `extensions/drm-copilot/resources/codex-and-agents-customizations/...`; (3) add one `paths`
  entry per new file to both `core.json` manifests; (4) resolve the conditional
  schema/init-template placement against the actual upstream paths and mirror or document
  accordingly; (5) add the Python/Codex-side manifest-completeness test.
- New classes/functions/commands: none required for converter registration (structural, no
  code change). One new test module (or test functions added to an existing module) implementing
  the Python/Codex-side manifest-completeness check.
- Dependency changes: none anticipated.
- Logging/telemetry additions: none; this feature is a build-time/test-time asset-publishing
  concern with no runtime telemetry surface.
- Rollout plan: no feature flag. The mirrored assets and manifest entries take effect the next
  time a consumer repository runs a push-down pull; there is no staged deploy for this
  repository-internal contract work.

## Acceptance Criteria

- [ ] Every new `.claude/agents/*.md` persona file introduced by `legacy-discovery-agent-roles`
      is present byte-identically at the matching path under
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`.
- [ ] Every new `.claude/skills/<name>/SKILL.md` skill introduced by `legacy-discovery-skills`
      is present byte-identically at the matching path under
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`.
- [ ] Every new `.claude/hooks/*` file introduced by `legacy-discovery-hooks` is present
      byte-identically at the matching path under
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and any
      corresponding `.claude/settings.json` hook-registration change is mirrored.
- [ ] `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with all newly
      mirrored `.claude/**` assets present, with no modification to that test's enumeration
      logic (data-driven, full-tree coverage per the research determination).
- [ ] Each mirrored asset's Codex-native converted equivalent is present byte-identically under
      `extensions/drm-copilot/resources/codex-and-agents-customizations/`, and
      `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` passes.
- [ ] This spec documents the Codex-native converter registration determination (purely
      structural; no `mapping.py`/`classifier.py`/`inventory.py` edits), and no such edits are
      present in the change set for name-based registration of the new agent/skill/hook
      categories.
- [ ] Every new agent-persona path and every new skill `SKILL.md` path is added as an
      individual path-string entry to the `paths` array of both
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and
      `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
      (using the converted `.codex`/`.agents` destination path on the Codex side).
- [ ] Every new hook path is added as an individual path-string entry to both `core.json`
      manifests.
- [ ] A real-filesystem manifest-completeness test exists on the Python side or the Codex side
      (a functional twin of `claude-pack-manifest-completeness.test.ts`), asserting every
      bundled `.claude/agents/*.md`, `.claude/hooks/*`, and `.claude/skills/*/SKILL.md` file
      appears in the union of every manifest's `paths` array, and that test passes.
- [ ] The schema (`legacy-discovery-schemas`) and init-template (`legacy-discovery-init-templates`)
      mirror obligation is resolved per the conditional rule in "Schema/Init-Template
      Placement": mirrored into `resources/` with a `core.json` entry if landed under a
      mirrored root, or explicitly documented as out of mirror-contract scope if landed under
      `scripts/`.
- [ ] `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and
      `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pass.
- [ ] The TypeScript twin push-down tests under `extensions/drm-copilot/test/lib/push-down/`,
      including `claude-pack-manifest-completeness.test.ts` and its new Python/Codex-side
      counterpart, pass.
- [ ] No TaskMaster/TMW/Outlook/VSTO/email/task-management-specific identifier is introduced by
      any file, manifest entry, or test added by this feature (domain-neutrality invariant).

This section is traceable to the epic's capability-level acceptance criterion: "New
customization assets are mirrored into `resources/` subtrees and pass the push-down contract
tests" (`objective-source.md`, "Required Acceptance Criteria (capability-level)").

## Definition of Done

- [ ] Acceptance criteria documented above are each mapped to a passing test or an explicit
      documentation artifact.
- [ ] Behavior matches acceptance criteria in the local toolchain run (no CI-only dependency).
- [ ] Tests updated/added: Python push-down contract tests, TypeScript twin push-down tests,
      new manifest-completeness test.
- [ ] Edge cases covered: conditional schema/init-template placement decision recorded either
      way; manifest-omission gap closed by the new completeness test.
- [ ] Docs updated: this spec records the converter-registration and pack-placement
      determinations referenced by `objective-source.md` scope item 10.
- [ ] Telemetry/logging: not applicable (no runtime surface introduced).
- [ ] Toolchain pass completed (format → lint → type-check → architecture → unit tests →
      contract/schema checks → integration tests) with no regression on changed lines.

## Seeded Test Conditions (from potential)

- [ ] Python push-down contract tests over `.claude/**` and `.codex/**`+`.agents/**` (no
      automated parity test exists for `.github/**`; out of scope per research finding).
- [ ] TypeScript twin push-down tests, including the manifest-completeness test and its new
      Python/Codex-side counterpart.
- [ ] Codex converter classifier/mapping tests — no new registration is expected, so these
      tests confirm the existing path-prefix classification continues to route the new assets
      correctly rather than exercising new registration code.
