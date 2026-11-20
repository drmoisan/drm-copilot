# epic-single-home-manifest — Spec

- **Issue:** #331
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/331
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-08
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Overview

The canonical folder structure for a multi-feature epic is defined in the drm-copilot repository
and pushed down to consumer repositories (for example TaskMaster). The current structure has three
defects, all confirmed against epic #260 (store-lockup-resilience), the repository's first epic:

1. **The epic lives in two trees.** Epic-level material is split between
   `docs/features/epics/<epic-slug>/` (`epic-plan.md` manifest + `epic-status.md`) and
   `docs/features/active/<date>-<epic-slug>-<issue>/` (`issue.md` + `initiative.md`), using two
   different naming schemes for the same entity.
2. **Decomposition is triplicated** across `epic-plan.md`, `initiative.md`, and `epic-status.md`.
   These copies drift out of sync; changing one feature's `depends_on` during #260 planning required
   hand-editing all three.
3. **The manifest DAG is keyed by `feature_folder` basename**, which embeds a date and issue number
   and changes when a feature is promoted `active/ → completed/`. The epic-orchestrate skill carries
   a brittle path-drift workaround as a symptom of this.

Two foundational decisions in the current design are correct and must be preserved: a
machine-readable manifest, and flat, independently-lifecycled sibling feature folders (each child
keeps its own git branch/worktree and independent `active/ → completed/` lifecycle). This is
corroborated by SAFe (Epic→Feature containment is a logical/backlog relationship, not a filesystem
one) and by docs-as-code practice (flat item files plus one index).

This feature adopts Option D from the authoritative design research
(`research/2026-07-07T19-00-epic-folder-structure-design-research.md` §5): "single epic home + flat
feature siblings + one manifest." The design is decided and is not re-litigated here.

## Goal

Adopt the single-epic-home layout in the drm-copilot repository (canonical source) so that the
change can be pushed down to consumer repositories:

- One epic home under `docs/features/epics/<epic-slug>/` containing `epic.md` (source of truth) and
  `epic-status.md` (generated projection only).
- The `new_active_feature_folder` MCP tool scaffolds only the single epic home for `type=epic`.
- The manifest DAG is keyed by stable `issue_num`, with `feature_folder` as a resolvable hint that
  may point into `active/` or `completed/`.
- An optional, additive SAFe-style intent block in the manifest frontmatter.
- All changes additive and key-gated so legacy manifests and checkpoints validate byte-identically.

## Non-Goals (explicitly out of scope)

- **Migrating existing epics to the new layout.** Migrating epic #260 (store-lockup-resilience) —
  or any other epic already realized in the legacy two-tree layout — is a deferred, per-consumer-repo
  follow-up. Backward compatibility (below) keeps the legacy layout valid so migration is non-urgent.
  This spec does not migrate #260. The change description must record this deferral.
- **Epic-status hand-edit guard.** The optional guard that prevents `epic-status.md` from being
  hand-authored is deferred and is NOT implemented here. Rationale: it requires a net-new
  deterministic epic-status projector (checkpoint JSON → expected `epic-status.md` text), which does
  not exist in any language today (research §6), plus a new PreToolUse hook, its bundle mirror, a
  `pack-manifests` entry, and a Pester test. It is marked "optional" by the objective and is not one
  of the six acceptance criteria. See "Deferred follow-up: epic-status hand-edit guard" below.
- Any change to child feature/bug scaffolding, child folder layout, or the child `active/ →
  completed/` lifecycle. Child feature folders remain exactly as they are.
- Changing which checks are required by branch protection, or altering `compute_wave_numbers`
  algorithmic behavior (it is already key-agnostic; see FR-3).

## Scope

In scope are the six implementation surfaces enumerated in the "File-Level Change List" below:
(a) the `new_active_feature_folder` MCP tool (TypeScript authoritative + Python co-authoritative);
(b) epic feature templates; (c) the manifest validators (Python + TS parity port);
(d) the epic-orchestrate skill and its byte-identical mirror; (e) push-down tooling; and
(f) the parity gates (pack manifest + resource-contract tests).

## Functional Requirements

Each functional requirement is traceable to an acceptance criterion (AC-1..AC-6, listed verbatim in
"Acceptance Criteria" below).

### FR-1 — Single epic home (→ AC-1, AC-2)

The canonical epic layout is a single home directory:

```
docs/features/epics/<epic-slug>/
├── epic.md          # source of truth: YAML frontmatter (manifest DAG + optional SAFe intent
│                    #   block) followed by the merged narrative
└── epic-status.md   # GENERATED projection of the epic checkpoint only; never hand-authored
```

- `epic.md` merges what are today three artifacts — the epic `issue.md`, the `epic-plan.md`
  manifest, and the `initiative.md` decomposition — into one file. Its YAML frontmatter carries the
  manifest DAG (see FR-3) and the optional intent block (FR-4); its body is the single narrative
  (goal / scope / non-goals / shared design / decomposition). `epic.md` is also the source from which
  the epic GitHub issue body is generated.
- `epic-status.md` is a generated projection of the epic checkpoint only. It is never the source of
  the DAG and is never hand-authored.
- The separate `active/<date>-<epic-slug>-<issue>/` epic folder is no longer created, and
  `initiative.md` is retired as a distinct artifact.

### FR-2 — `new_active_feature_folder(type=epic)` scaffolds the single home (→ AC-1)

When invoked with `type=epic`, the tool scaffolds only
`docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`. It does not create an `active/` epic
folder and does not create `initiative.md`.

This is net-new tool behavior. Today the tool computes `target_dir =
docs/features/active/<folder_slug>` for all types (no epic special-casing), recursively copies the
epic template tree, and stamps `initiative.md` as the file to open; it does not create the
`epics/<slug>/` tree at all (that tree is currently hand-authored by the epic-orchestrate agent).
See research §2.

Concretely, three functions gain an epic branch in each of the two parity trees:

1. **Target-directory routing** — currently the unconditional `docs/features/active/<slug>`; add an
   epic branch that targets `docs/features/epics/<epic-slug>/`
   (`flow.ts` / `new_active_feature_folder_flow.py`).
2. **Template copy** (`copyTemplate` / `copy_template`) — copy the new `epic.md` + `epic-status.md`
   template set instead of the whole tree / `initiative.md` (`io.ts` / `new_active_feature_folder_io.py`).
3. **Docs stamping** (`updateFeatureDocs` / `update_feature_docs`) — stamp `epic.md` and seed
   `epic-status.md` as a generated-only placeholder; drop `initiative.md`
   (`docs.ts` / `new_active_feature_folder_docs.py`).

The service-call summary and returned destination path remain valid but now resolve under `epics/`.
No test may hard-code `active/` for the epic path.

Child feature/bug scaffolding is unchanged.

### FR-3 — Manifest DAG keyed by stable `issue_num` (→ AC-2, AC-3)

The manifest DAG uses `issue_num` as the primary key. `feature_folder` becomes a resolvable hint
that may point into `active/` OR `completed/`.

- `scripts/dev_tools/epic_wave_computation.py`: `compute_wave_numbers` is already a pure,
  key-agnostic function over string keys and does not read the manifest file (research §3). No
  algorithmic change is required; the caller (the epic-orchestrator agent) supplies `issue_num`-keyed
  mappings. Its existing test uses abstract keys and stays byte-identical.
- `scripts/dev_tools/validate_epic_orchestrator_state.py`: add key-gated dependency resolution.
  Detect whether each `depends_on` entry is an `issue_num` reference or a legacy `feature_folder`
  basename, and resolve against a union index (the `feature_folder` set plus the `issue_num` set).
  Add the resolver as a single shared helper consumed by the uniqueness check
  (`_validate_feature_folder_uniqueness_and_dependencies`), the cycle detection
  (`_detect_dependency_cycle`), and the wave-barrier ordering / waves-consistency checks. When every
  `depends_on` entry is a folder-basename string (the legacy shape), the new branch is inert and the
  error output is byte-identical.
- `feature_folder` resolution accepts a hint that resolves to a concrete path under either `active/`
  or `completed/`. The epic-orchestrate skill's active→completed path-drift workaround text is
  removed (FR-6).
- The TypeScript parity port
  `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` receives the equivalent
  key-gated resolution; its error strings remain asserted identical to the Python validator.

### FR-4 — Optional additive SAFe-style intent block (→ AC-2, AC-3)

The manifest frontmatter may carry an optional intent block. It is not hard-required (backward
compatible). Fields:

- `epic_type` — enum, one of `business` or `enabler`.
- `business_outcome_hypothesis` — string.
- `leading_indicators` — list of strings.
- `nfrs` — list of strings.

Validation of this block is presence-gated (see "Intent-Block Validation Design"). When the block is
absent, behavior is byte-identical to today.

### FR-5 — Backward compatibility, additive and key-gated (→ AC-3)

Backward compatibility is a hard requirement.

- `epic_wave_computation.py` and `validate_epic_orchestrator_state.py` must remain byte-identical on
  the legacy two-tree layout and folder-basename keys. All new logic is additive and key-gated:
  it activates only when the new shape (`issue_num` keying, intent block) is present.
- Intent-block validation runs only when the block is present.
- Existing legacy fixtures and tests remain unchanged and passing (this is the byte-identical
  guarantee). New fixtures are added alongside, never in place of, the legacy fixtures.

### FR-6 — Skill and mirror document the single-home layout (→ AC-2)

`.claude/skills/epic-orchestrate/SKILL.md` documents: the single-home layout; `epic.md` as the
merged source; the DAG keyed by `issue_num`; generated-only `epic-status.md`; and the optional intent
block. The active→completed path-drift workaround text is removed. The byte-identical mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
is synced (enforced by the parity gate in FR-8).

Specific edit points (research §4): Epic Dependency Manifest (manifest path `epic-plan.md` →
`epic.md`, `feature_folder` from canonical identifier to resolvable hint with `issue_num` primary,
intent-block schema added); Documentation Maintenance Boundaries (`epic-plan.md` → `epic.md`,
reinforce generated-only `epic-status.md`); Context Handoff to Dependent Features (remove the
active-or-completed parenthetical, replace with `issue_num`-keyed resolvable-hint phrasing);
Epic-Level Checkpoint (`epic_manifest_path` naming); Completion Requirements (`epic-status.md`
path confirmation). Related runtime files that carry the manifest path/schema
(`.claude/agents/epic-orchestrator.md`, `.claude/agents/epic-review.md`,
`.claude/skills/review-epic/SKILL.md`) are reviewed during planning and edited + re-synced if they
reference the changed path or key; this is confirmed during planning, not assumed.

### FR-7 — Push-down so consumer repos receive the change (→ AC-5)

Run/update the push-down tooling so consumer repositories can pick up the change. The
epic-orchestrate skill and epic hooks are in the `.claude` push-down set (`core.json`); the change
must be published through `push_down_claude_customizations`. Feature templates ship as MCP resources
(not part of any `.claude` push-down) and are copied into the MCP package by `prepack.cjs`. The
epic-orchestrate skill is not in the `.codex`/`.agents` or `.github` (copilot) push-down sets
(research §5).

### FR-8 — Parity gates pass (→ AC-3, AC-4)

The bundled-mirror and push-down parity gates must pass:

- Python resource-contract test
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserts every `.claude/**`
  file is byte-identical in the bundle mirror.
- TypeScript pack-manifest completeness test
  `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` asserts every
  bundled `.claude` agent/skill/hook appears in a `pack-manifests/*.json` `paths[]`.
- The TS validator parity suite
  `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` asserts
  Python↔TS parity.

## Intent-Block Validation Design

The AC requires `validate_epic_orchestrator_state.py` to validate the intent block "only when
present." This section specifies the concrete, additive, presence-gated approach, mirroring the
presence-gated validator patterns documented in `.claude/rules/orchestrator-state.md`
(`remediation_loop`, `human_interaction`, `complexity_assessments`).

### Location decision

The validator operates on the checkpoint JSON
(`artifacts/orchestration/epic-orchestrator-state.json`), not on the `epic.md` markdown; there is no
Python parser for the manifest frontmatter today (research §3). The intent block originates in the
`epic.md` frontmatter. The chosen location is: **carry the intent fields from the manifest into the
epic checkpoint as an optional top-level `intent` object, and validate it presence-gated inside
`validate_epic_orchestrator_state.py`.**

Justification:

- It keeps the legacy path byte-identical: a checkpoint with no `intent` key is unaffected, exactly
  as `remediation_loop` / `human_interaction` / `complexity_assessments` are today (key-gated).
- It is testable without temp files: fixtures are in-memory JSON dicts, consistent with the existing
  validator tests, and require no markdown parsing in Python.
- It reuses the established validator idiom (append one error per violated invariant, literal
  checkpoint-context-prefixed message style, return a list without mutating input).

A separate manifest-frontmatter parser is not introduced in this change, because it would add a
new markdown-parsing dependency/surface in Python solely to validate an optional block, and the
checkpoint-carried approach achieves the same coverage with the existing validator machinery. The
manifest frontmatter remains the human-authored source; the checkpoint `intent` object is the
machine-validated projection of it.

### Presence-gated invariants (apply only when `intent` is present)

When the checkpoint contains a top-level `intent` object:

1. **`intent` is an object.** A non-object `intent` value is a malformed block.
2. **`epic_type` enum membership.** `epic_type` must be present and one of `business` or `enabler`.
   A missing or out-of-enum value is a malformed block.
3. **`business_outcome_hypothesis` non-empty string.** When present it must be a non-empty
   (non-whitespace) string. (Required-when-block-present.)
4. **`leading_indicators` list of strings** when present; **`nfrs` list of strings** when present.
   A non-list value, or a list element that is not a string, is a malformed block.

Required-when-block-present fields are `epic_type` and `business_outcome_hypothesis`;
`leading_indicators` and `nfrs` are optional even within the block but are shape-checked when
present. When the `intent` key is absent, none of these checks run and the validator output is
byte-identical to today. The equivalent presence-gated check is added to the TS parity port with
identical error strings.

## Inputs / Outputs

- **Inputs:** `new_active_feature_folder` invocation with `type=epic` and an epic name; the epic
  `epic.md` frontmatter (manifest DAG + optional intent block); the epic checkpoint JSON consumed by
  the validator.
- **Outputs:** the scaffolded `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`;
  validator error lists (unchanged shape); wave-number mappings (unchanged shape).
- **Config keys / defaults:** the intent block is optional; `epic_type ∈ {business, enabler}`. No
  new config file keys.
- **Versioning / backward-compatibility constraints:** additive and key-gated only; legacy two-tree
  layout and folder-basename keys remain valid; legacy fixtures/tests unchanged and passing.

## API / CLI Surface

- MCP tool `new_active_feature_folder` (extension command
  `drmCopilotExtension.newActiveFeatureFolder`): `type=epic` behavior changes per FR-2. The tool
  interface (arguments) is unchanged; only the epic-path output location and file set change.
- Python CLI `python -m scripts.dev_tools.new_active_feature_folder ...`: co-authoritative parity
  reference; same epic-path behavior change.
- `validate_epic_orchestrator_state.py` (CLI and MCP `validate_orchestration_artifacts`): additive
  key-gated resolution and presence-gated intent validation; existing invocation contract unchanged.
- Push-down MCP tool / extension command `push_down_claude_customizations` /
  `drmCopilotExtension.pushDownClaudeCustomizations`: run to publish the skill/hook changes.

## Data & State

- The manifest DAG in `epic.md` frontmatter is keyed by `issue_num`; `feature_folder` is a
  resolvable hint (may resolve into `active/` or `completed/`).
- The epic checkpoint gains an optional `intent` object (projection of the manifest intent block).
- `epic-status.md` is a generated projection; it is not a source of state.
- No migration or backfill is performed in this change (legacy layout stays valid; migration is a
  deferred follow-up).

## File-Level Change List

Grouped by surface, citing the implementation-surface mapping
(`research/2026-07-07-implementation-surface-mapping.md`). Both parity trees change together.

### (a) MCP tool — TypeScript authoritative + Python co-authoritative

TypeScript (MCP runtime, authoritative):
- `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` — epic target-dir branch to
  `docs/features/epics/<epic-slug>/`.
- `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` — `copyTemplate` epic branch
  copies the new `epic.md` + `epic-status.md` set.
- `extensions/drm-copilot/src/lib/new-active-feature-folder/docs.ts` — `updateFeatureDocs` epic
  branch stamps `epic.md`, seeds generated `epic-status.md`, drops `initiative.md`.

Python (repo CLI/agents, co-authoritative reference, kept in parity):
- `scripts/dev_tools/new_active_feature_folder_flow.py` — `create_active_folder` epic target-dir
  branch.
- `scripts/dev_tools/new_active_feature_folder_io.py` — `copy_template` epic branch.
- `scripts/dev_tools/new_active_feature_folder_docs.py` — `update_feature_docs` epic branch.

### (b) Epic feature templates

- New `docs/features/templates/epic/epic.md` and `docs/features/templates/epic/epic-status.md`;
  retire `docs/features/templates/epic/initiative.md`.
- New `extensions/drm-copilot/resources/feature-templates/epic/epic.md` and `.../epic-status.md`;
  retire `.../initiative.md`.
- `packages/mcp-server/resources/feature-templates/epic/*` is regenerated by `prepack.cjs` and need
  not be hand-edited (the mcp-server copy is a build artifact).

### (c) Validators

- `scripts/dev_tools/validate_epic_orchestrator_state.py` — `issue_num`-keyed dependency resolution
  via a shared union-index helper; presence-gated intent-block validation.
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` — TS parity port of both
  additions, error strings identical to Python.
- `scripts/dev_tools/epic_wave_computation.py` — no algorithmic change required (already
  key-agnostic); confirm the caller contract in the skill.

### (d) Skill + byte-identical mirror

- `.claude/skills/epic-orchestrate/SKILL.md` — edits per FR-6.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
  — byte-identical mirror, synced.
- If they reference the changed path/key: `.claude/agents/epic-orchestrator.md`,
  `.claude/agents/epic-review.md`, `.claude/skills/review-epic/SKILL.md` and their mirrors
  (confirmed during planning).

### (e) Push-down

- Run/update push-down tooling (`scripts/dev_tools/push_down_claude_customizations.py` and the MCP
  command) so consumer repos receive the change.

### (f) Parity gates

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (byte-identical `.claude`
  mirror).
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (pack
  manifest completeness). The epic-orchestrate skill is already listed in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.

## Test Requirements

All tests deterministic, no temporary files (per `.claude/rules/general-unit-test.md`).

### MCP epic scaffolding (FR-2) — both trees

- TypeScript (vitest/jest): `new_active_feature_folder(type=epic)` creates
  `docs/features/epics/<slug>/epic.md` and `.../epic-status.md`, and creates no `active/` epic folder
  and no `initiative.md`; child feature/bug scaffolding unchanged.
- Python (pytest): identical assertions against `create_active_folder` for the epic path.

### Validator (FR-3, FR-4, FR-5)

- `issue_num`-keyed DAG resolution: dependencies expressed by `issue_num` resolve correctly against
  the union index.
- `feature_folder` hint resolution into both `active/` and `completed/`.
- Presence-gated intent-block validation: positive (valid `intent` passes), negative (bad
  `epic_type`, empty `business_outcome_hypothesis`, non-list / non-string `leading_indicators` /
  `nfrs` each produce the expected error), and absent (no `intent` key → no new errors).
- Legacy-regression fixtures: the existing folder-basename-keyed fixtures remain unchanged and
  produce byte-identical validator output (proves FR-5).
- New fixtures added alongside legacy ones, never replacing them.

### TS validator port parity

- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`: the TS port
  produces identical results and error strings to the Python validator for the new `issue_num`-keyed
  and intent-block cases, and for the legacy cases.

### Parity gates (FR-8)

- The resource-contract and pack-manifest-completeness tests pass after the skill/mirror sync.

## Constraints & Risks

- **Backward compatibility (hard requirement):** validators and wave computation must still accept
  the legacy two-tree layout and folder-basename keys (key-gated / additive only). Epic #260
  (store-lockup-resilience) already exists in the legacy layout and must not break.
- Bundled mirrors under `.claude` / extension resources are enforced by contract tests; every
  runtime edit needs its mirror synced or the parity gate fails.
- Prefer additive, key-gated changes over breaking ones. No temporary files in tests; deterministic
  tests only.
- The mcp-server template copy is a build artifact (`prepack.cjs`) — edit the source template
  locations, not the generated copy.

## Deferred follow-up: epic-status hand-edit guard (out of scope)

Recorded here so the deferral is explicit and traceable. A guard that prevents `epic-status.md` from
being hand-authored is desirable but deferred because it has an unmet prerequisite: a deterministic
epic-status projector (checkpoint JSON → expected `epic-status.md` text) does not exist in any
language today (research §6). The smallest viable guard therefore requires, in order: (1) a pure
projector (for example `scripts/dev_tools/epic_status_projection.py`), then (2) a PreToolUse hook on
Write/Edit matching `docs/features/epics/*/epic-status.md` that regenerates the projection and denies
divergent content, plus its bundle mirror, a `pack-manifests` entry, and a Pester test. It is marked
optional by the objective and is not among the six acceptance criteria. It is not implemented in this
feature.

## Deferred follow-up: migration of existing epics (out of scope)

Migrating epic #260 (store-lockup-resilience) and any other epic already realized in the legacy
two-tree layout to the single-home layout is a deferred, per-consumer-repo follow-up. The
backward-compatibility guarantee keeps the legacy layout valid, so migration is low-cost and
non-urgent (research §6). The change description for this feature records this deferral.

## Acceptance Criteria

Carried forward verbatim from `issue.md` (the six canonical acceptance criteria). The
acceptance-criteria-tracking skill checks these off in this file and in `user-story.md` as work is
verified.

- [x] `new_active_feature_folder(type=epic)` scaffolds only `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`; no `active/` epic folder and no `initiative.md`.
- [x] The epic-orchestrate skill documents the single-home layout, `epic.md` as merged source, DAG keyed by `issue_num`, generated-only `epic-status.md`, and the optional intent block; the active→completed path workaround text is removed.
- [x] `epic_wave_computation.py` and `validate_epic_orchestrator_state.py` resolve the DAG by `issue_num`, accept `feature_folder` in `active/` or `completed/`, validate the intent block only when present, and remain byte-identical on legacy manifests (regression tests prove it).
- [x] New/changed logic has tests; the drm-copilot toolchain (format → lint → type-check → tests) passes in order.
- [x] Push-down tooling updated/run so consumer repos can pick up the change.
- [x] Change description records the deferred per-consumer migration (incl. TaskMaster epic #260).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to functional requirements and tests
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (MCP scaffolding TS+Python, validator, TS parity port)
- [ ] Edge cases and error handling covered by tests (intent-block negatives, legacy regression)
- [ ] Legacy fixtures/tests unchanged and passing (byte-identical guarantee)
- [ ] Skill mirror synced; parity gates pass
- [ ] Push-down tooling run
- [ ] Toolchain pass completed (format → lint → type-check → test) for both Python and TypeScript
