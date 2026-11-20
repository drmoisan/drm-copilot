# 2026-10-11-epic-planner-field-list-remainder (Spec)

- **Issue:** #543
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T12-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug

## Context

- Summary: the checkpoint field list in the `## Checkpoint Persistence` section of `.claude/agents/epic-planner.md` omits the top-level key `max_parallel_features` and the per-feature key `research_path`. The epic-planner-state validator requires both. An epic planner that writes a checkpoint from its own agent definition produces a file that fails plain validation with missing-key errors.
- Observed environment(s): any; observed on Windows 11 through the MCP `validate_orchestration_artifacts` tool with `artifact_type: epic-planner-state`.
- Impact and severity: Medium. The documented contract and the validator disagree. The defect affects every epic-planner run that follows the persona text literally. No data loss.
- First observed: recorded in the #874 spec (`docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`, line 255) and in the 2026-10-11 comment on issue #543.

## Repro & Evidence

- Steps to reproduce:
  1. Author `artifacts/orchestration/epic-planner-state.json` with exactly the fields listed in `.claude/agents/epic-planner.md` under `## Checkpoint Persistence`.
  2. Validate it with the `epic-planner-state` artifact type.
  3. Observe missing-key errors for `max_parallel_features` and for each feature's `research_path`.
- Expected: the persona field list names every key the validator requires.
- Actual: the list omits `max_parallel_features` and `research_path`.
- Frequency: deterministic.
- Evidence: research record `research/research.2026-10-11T12-05.md` (sections 1 to 3) compares the persona text at `.claude/agents/epic-planner.md:104-111` with `REQUIRED_KEYS` and `REQUIRED_FEATURE_KEYS` in `scripts/dev_tools/validate_epic_planner_state.py` (lines 34-57) and the TypeScript twin `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (lines 19-43). The two keys above are the only required keys missing.

## Scope & Non-Goals

- In scope:
  - Add `max_parallel_features` to the top-level field list and `research_path` to the per-feature list in `## Checkpoint Persistence` of `.claude/agents/epic-planner.md`.
  - Apply the byte-identical change to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md`.
  - Record the Codex counterparts as a verified non-change.
- Out of scope / non-goals:
  - Validator code changes (Python or TypeScript).
  - Per-feature `model_routing_receipt` and `topology_receipt` gating in `_validate_ready_features` / `validateReadyFeatures`.
  - Documenting optional or conditional validator fields (for example the top-level topology receipt).
  - Edits to `.claude/rules/` or `.github/instructions/`.
  - Reopening the earlier #543 work in PR #829 and PR #874.
- Explicitly excluded: `.claude/skills/epic-plan/SKILL.md` (it points to the agent section and does not duplicate the list); pack manifests (they list paths, not hashes).

## Root Cause Analysis

- Root cause: the persona field list was authored before `max_parallel_features` and `research_path` were added to the validator required-key tuples, and the persona text was not updated.
- Supporting evidence: the research record shows every other `REQUIRED_KEYS` and `REQUIRED_FEATURE_KEYS` entry is already listed; `epic_issue_num` is listed but is not a validator-required key (a documented extra, not a defect).
- Affected components: `.claude/agents/epic-planner.md` and its bundled mirror.

## Proposed Fix

### Design summary

Edit lines 106-110 of the `## Checkpoint Persistence` section in both Claude persona files:
- Insert `max_parallel_features` in the top-level list after `integration_branch`.
- Insert `research_path` in the per-feature parenthetical between `preparation_status` and `plan_path` (validator order).
- Keep the lines hard-wrapped at about 100 columns.

### Boundaries and invariants to preserve

- The heading `## Checkpoint Persistence` is unchanged.
- The `epic_issue_num` sentence on line 111 is unchanged (pinned by `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, lines 172-184).
- The two Claude files remain byte-identical, including line endings.
- Frontmatter is unchanged (pinned by `test_parallel_planner_surface_contracts.py` and `test_claude_rules_frontmatter.py`).

### Dependencies or blocked work

None. Before editing, re-check `git diff origin/main --stat -- .claude/agents/epic-planner.md` for concurrent edits, and rebase on main before opening the PR.

### Implementation strategy

#### Files/modules to change

- `.claude/agents/epic-planner.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md`

#### Functions/classes/CLI commands impacted

None. Markdown-only change; no executable code.

#### Data flow and validation changes

None. A checkpoint authored from the corrected list satisfies the existing validator required-key checks.

#### Error handling and logging updates

None.

#### Rollback/feature-flag considerations

Revert the two-file edit. No flag.

### Technical specifications

#### Inputs/outputs and formats

Documented checkpoint keys after the change:
- Top level: `objective`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `max_parallel_features`, `epic_issue_num`, `epic_worthiness`, `features[]`, `kickoff_prompt_path`, `completed_steps`, `next_step`, `last_updated`.
- Per feature: `issue_num`, `feature_folder`, `depends_on`, `wave`, `complexity_band`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`.

#### Required configuration keys and defaults

None added.

#### Backward-compatibility expectations

Documentation-only. Existing checkpoints and validators are unaffected.

#### Performance constraints

None.

### Verified non-change: Codex counterparts

- `.codex/agents/epic-planner.toml` (lines 69-76) describes the checkpoint in prose that already covers a bounded maximum and research and plan paths. No change required.
- `.agents/skills/epic-plan/SKILL.md` (lines 234-240) already names `max_parallel_features` and `research_path`. No change required.
- Bundled mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/` are therefore also unchanged.
- No test or generator requires the Codex text to match the Claude list.

## Assumptions, Constraints, Dependencies

- Assumptions: the validator required-key tuples in `scripts/dev_tools/validate_epic_planner_state.py` are the authoritative key set; the TypeScript twin has identical content.
- Constraints: no sh, bash, or pwsh wrapper scripts; Pester runs through the PoshQC MCP test tool or CI evidence.
- Dependencies: none external.

## Data / API / Config Impact

- User-facing or API changes: persona documentation only.
- Data or migration: none.
- Logging/telemetry: none.
- Compatibility: no CLI flag, schema, or version change.

## Test Strategy

- Regression tests to add or update: none to add; the change is documentation and existing contract tests pin the invariants.
- Existing tests that must pass:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
  - `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
  - `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` via the PoshQC MCP test tool or CI evidence.
  - `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`.
- Edge cases: if the parity test fails locally on gitignored state, compare the failing path with the scope filter in `tests/scripts/dev_tools/claude_payload_scope_test_support.py` (issue #510) before attributing it to this change.
- Coverage: unaffected; no production code changes.
- Toolchain: run the standard loop for completeness; format, lint, type-check, architecture, Jest, and contract stages have no changed inputs.
- Manual validation: none required.

## Acceptance Criteria

- [x] `.claude/agents/epic-planner.md` contains the token `max_parallel_features` inside the `## Checkpoint Persistence` section, in the top-level field list.
- [x] `.claude/agents/epic-planner.md` contains the token `research_path` inside the `## Checkpoint Persistence` section, in the per-feature list, positioned before `plan_path`.
- [x] The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md` carries the same two additions and is byte-identical to the root file, verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passing (including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`) together with `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
- [x] `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` passes (PoshQC MCP test tool or CI evidence), confirming the `## Checkpoint Persistence` heading and the `epic_issue_num` / `promotion_type: epic` text are unchanged.
- [x] Every key in `REQUIRED_KEYS` and `REQUIRED_FEATURE_KEYS` of `scripts/dev_tools/validate_epic_planner_state.py` appears in the documented list of `.claude/agents/epic-planner.md` (a comparison of the two tuples against the section text reports no missing key).
- [x] `.codex/agents/epic-planner.toml`, `.agents/skills/epic-plan/SKILL.md`, and their bundled mirrors are unchanged, recorded as a verified non-change.
- [x] No file outside the two persona files and `docs/features/active/2026-10-11-epic-planner-field-list-remainder-543/` changes (verified with `git diff --name-only origin/main`).
- [x] The frontmatter-contract tests `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` still pass.

## Risks & Mitigations

- Mirror drift if only one file is edited: apply the same edit to both in one step and run the parity tests.
- Concurrent edit by a sibling burn-down item: re-check the diff against `origin/main` before editing and rebase before the PR.
- Reflow breaking a pinned phrase: do not touch line 111 or the heading.

## Rollout & Follow-up

- Release: ships with the next extension bundle; no migration.
- Follow-up (not in scope): optional validator fields (topology receipt, per-feature `model_routing_receipt` / `topology_receipt`) remain undocumented in the persona list.
- Links: issue #543; `research/research.2026-10-11T12-05.md`; #874 spec line 255.
