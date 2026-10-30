# hook-parity-across-claude-codex-copilot — Spec

- **Issue:** #1030
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 5
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/research/research.2026-10-30T23-03.md`
- **Epic manifest:** `docs/features/epics/shared-agent-harness-layer/epic.md`
- **Settled design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`

## Overview

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`, registered in `.claude/settings.json` and in `hooks:` blocks of
`.claude/agents/*.md` frontmatter), Codex (`.codex/hooks`, registered in `[[hooks.<Event>]]` tables
of `.codex/config.toml`) and GitHub Copilot (`.github/hooks`, registered in
`.github/hooks/discovery.json`). The sets were built separately and drifted. Several Claude gates
have no Codex counterpart (feature-folder order, the SubagentStop output validators, the
preimplementation delegation leg), some Codex hooks exist only to express Codex-specific
attestation, and the Copilot hooks cover only the discovery surface. No record states, for each
hook registration, which function it implements and why a counterpart is or is not present in
another ecosystem, so a missing gate in one ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hook counts need not match, and
Codex gains a hook only where its hook system can express the behavior. This feature (child 5)
records the function of every hook registration as a parity group, adds Codex counterparts where
they are expressible and safe, records a written reason where they are not, and adds the tests
that keep the two ecosystems equivalent.

Registration and file counts in the research record are informational snapshots of the planning
tree. No acceptance criterion in this spec depends on them; criteria are stated against the set
that child 1's inventory module enumerates at execution time.

## Terminology and Disposition Semantics (O1)

This spec adopts child 1's disposition semantics (child 1 spec, `### Disposition Semantics`):

- Each hook registration is a separate `hook-registration` matrix entry. Its `disposition` is
  `native`, or `generated` where child 3's generator writes the registering file.
- `shared` is used only when a single source file is published unchanged to more than one runtime.
  A Claude hook and its Codex counterpart are two registrations with different entry adapters, so
  they are not `shared` in this sense.
- A **shared function** is a parity group: a `parity_group` value of the form `hook:<function>`
  whose members span two or more ecosystems.
- A **Codex counterpart** of a Claude registration is a Codex registration with the same
  `parity_group` value.
- A parity group with a member in one ecosystem and no member in another carries a non-empty
  `reason` (not expressible in that ecosystem, no surface in that ecosystem, or deferred by owner
  decision) plus `decision_status` and `decision_ref`.

The early-draft acceptance criteria in `issue.md` used "shared" in the function sense; the
acceptance criteria below restate them under these semantics.

## Behavior

- Every hook registration on each registration surface has a matrix entry with a `parity_group`.
- Every parity group that has a Claude member and no Codex member, or a Codex member and no Claude
  member, has a written `reason`.
- Where a Claude gate's function is expressible in Codex and the owner defaults below select a
  port, the Codex counterpart exists and returns the same allow, deny or continue decision as the
  Claude entry on a shared fixture set.
- Ported rule logic lives in byte-identical files under `.claude/hooks/` and `.codex/hooks/`;
  only the thin entry adapters differ (stdin envelope and block or continuation shape).
- Copilot registrations under `.github/hooks` receive `parity_group` values only; their
  disposition and any change to `.github/hooks` belong to child 6 (O7).
- No enforcement hook, and no PowerShell file a registered hook executes, invokes Python. The
  Python-invocation guard covers `.github/hooks` and `.codex/scripts` in addition to its current
  roots.
- Bundled mirrors under `extensions/drm-copilot/resources/` stay byte-identical to their root
  files, every new bundled file is listed in its pack manifest, and the existing contract tests
  stay green.

### Planned parity groups and dispositions

Derived from the research record, section 2.2. The Phase 0 gate re-derives this table from child
1's inventory and stops for re-planning when it differs.

| Parity group | Ecosystems with members today | Child 5 action | Reason recorded when a member is absent |
| --- | --- | --- | --- |
| `hook:validate-bash`, `hook:promotion-mcp-only`, `hook:epic-merge-gate`, `hook:epic-worktree-removal-gate`, `hook:python-test-purity`, `hook:python-batch-budget`, `hook:powershell-test-purity`, `hook:powershell-batch-budget`, `hook:evidence-locations`, `hook:file-size-limit`, `hook:checkpoint-monotonic`, `hook:completion-consistency`, `hook:feature-review-coverage` | Claude, Codex | Set `parity_group`; no code change | n/a |
| `hook:discovery-artifact-gate`, `hook:discovery-planning-gate`, `hook:discovery-agent-start`, `hook:discovery-agent-stop` | Claude, Codex, Copilot | Set `parity_group` on all members; Copilot disposition left to child 6 | Hosted-tool limit (Codex PreToolUse does not cover hosted tools such as `WebSearch`) recorded on the discovery-artifact-gate Codex entries |
| `hook:epic-wave-barrier`, `hook:model-routing` | Claude, Codex | Set `parity_group`; mechanism difference recorded | n/a (mechanism note only) |
| `hook:epic-root-invocation` | Claude, Codex | Set `parity_group` | Claude form not expressible: Codex PreToolUse input carries no caller identity; Codex uses a UserPromptSubmit root receipt |
| `hook:feature-folder-order` | Claude | Port to Codex (PreToolUse) | n/a after port |
| `hook:planner-output`, `hook:executor-output`, `hook:task-researcher-output`, `hook:required-artifact-output`, `hook:prd-feature-output`, `hook:pr-author-output` | Claude | Port to Codex (SubagentStop), gated on child 3 | n/a after port |
| `hook:preimplementation-gate` | Claude (command, file-edit, delegation legs); Codex (command, file-edit legs) | Add the Codex delegation-leg registration only after the O2 runbook result is recorded | Until then: delegation leg pending owner-run Codex runbook (O2) |
| `hook:mermaid-validation`, `hook:prd-feature-before-planner` | Claude | None (O4) | Requires library publication; deferred to child 4 |
| `hook:pr-author-skill-gate`, `hook:orchestrator-output` | Claude | None (O5) | Depends on `.claude/lib/orchestrator-state`; Codex completion boundary is the MCP validator and CI |
| `hook:pr-author-command-allowlist` | Claude | None | Not expressible in Codex: no per-agent hook declaration and no agent identifier in PreToolUse input |
| `hook:session-id-persist` | Claude | None | Consumer skill is Claude-only; Codex supplies `session_id` in every hook input |
| `hook:parallel-worktree-removal-gate`, `hook:parallel-abandon-gate`, `hook:parallel-cohort-barrier`, `hook:parallel-drift-gate` | Claude | None | No Codex parallel-orchestration surface |
| `hook:epic-planning-only`, `hook:epic-child-worktree-binding` | Codex | None (O6) | Codex-native mechanism; Claude epic children use isolated subagent worktrees and the preimplementation gate's preparation mode |

## Owner Questions

Each question is adopted at its recommended default as a working assumption. The owner may
override any default; an override that changes scope triggers the one accepted plan revision
(see `## Upstream Dependencies`).

| ID | Question | Recommended default (working assumption) |
| --- | --- | --- |
| O1 | Use child 1's disposition semantics, or the issue's sense of "shared"? | Child 1's semantics: each registration is `native` (or `generated` where child 3 writes the registering file); a shared function is a `parity_group` with members in two or more ecosystems. Acceptance criteria are restated accordingly. |
| O2 | Is an owner-run Codex runbook acceptable to confirm that Codex fires PreToolUse inside subagents and to record the `spawn_agent` tool-input shape before the preimplementation delegation-leg registration is added? | Yes. Until the runbook result is recorded, the delegation registration is not added and the matrix records the reason. |
| O3 | Seven frontmatter `SubagentStop` registrations duplicate settings registrations, and their matrix `id` values collide under the current encoding. Keep both or drop one? | Keep both until child 1's E5 experiment records the firing behavior; child 1 resolves the `id` encoding (source discriminator and matcher encoding). Child 5 does not edit either source. |
| O4 | Lib-dependent Claude gates (`hook:mermaid-validation`, `hook:prd-feature-before-planner`): port through a published `.codex/lib`, port as `.codex/hooks` twins, or record native with a deferral reason? | Record native with reason "requires library publication; deferred to child 4". No new issue unless the owner prefers a port. |
| O5 | Confirm `hook:pr-author-skill-gate` and `hook:orchestrator-output` stay Claude-native. | Native (Claude) with the reasons in the parity-group table. |
| O6 | Should Claude gain `hook:epic-planning-only` and `hook:epic-child-worktree-binding`? | No; both recorded Codex-native with mechanism reasons. |
| O7 | Does child 5 set Copilot `parity_group` values while child 6 owns Copilot disposition and `.github/hooks` changes? | Yes. |
| O8 | Who edits the `[[hooks.*]]` tables of `.codex/config.toml` after child 3? | Child 5 edits them by hand unless child 3's merged spec states that its generator owns them; the Phase 0 gate re-checks. If child 3 owns them, child 5 edits the generator source instead and runs its `--check`. |
| O9 | After child 3 makes `AGENTS.md` the instruction source, should the Codex `feature-review-coverage-thresholds.ps1` read `AGENTS.md`? | Codex reads `AGENTS.md` first and falls back to `CLAUDE.md`. The change lands in child 5 only if child 3 moves the threshold text out of `CLAUDE.md`; otherwise no change. |

## Upstream Dependencies (owner decision E3)

Child 5 is planned before its upstream children merge. Neither is merged at the time of writing.

- **Child 1 (#1025).** Owns `config/harness-parity-matrix.json`, its schema, the inventory module
  (planned as `scripts/harness/HarnessInventory.psm1`), the matrix completeness test, and the
  `id` encoding, which is still open. Child 5 edits only the `parity_group`, `reason`,
  `decision_status` and `decision_ref` fields of `hook-registration` entries.
- **Child 3.** Owns the agent generator (`.claude/agents/*.md` and `.codex/agents/*.toml` from one
  logical definition) and, per the epic manifest `## Dependency Rationale`, the hook registrations
  in agent frontmatter and `.codex/config.toml`. No child 3 branch is pushed yet; this spec cites
  the epic manifest `## Scope` and `## Dependency Rationale` for its contract.

Execution begins with a Phase 0 gate that re-checks child 1's and child 3's merged outputs against
the assumptions in this spec: the matrix path, schema fields and `id` encoding; the inventory
module's entry point and the `hook-registration` kind; the completeness test location; whether
child 3's generator owns the `[[hooks.*]]` tables (O8); and whether the generated Codex agent
bodies state each output contract the ported SubagentStop validators check (`plan-path:`,
`research-path:`, `spec-path:`, `staged-review-path:`, `status-sync-path:`, `epic-audit-path:`,
`## Pre-Mortem`, and the pr-author created-or-updated pull-request report). When any of these
differs, execution stops for re-planning. One plan revision is accepted for this purpose.

## Execution Preconditions

- The parallel run `bugs-1001-1002-1003-1006` (items 1001, 1002, 1003, 1006, 1009, 1010, 1011,
  1012, 1013) has merged to `main`. The Phase 0 gate confirms each item's merge state with `gh`.
- Child 1 and child 3 have merged, and the Phase 0 checks in `## Upstream Dependencies` pass.
- Every file, symbol and heading named in this spec is unchanged against current `origin/main`, or
  execution stops for re-planning (epic `## Execution Preconditions`).
- The Claude and Codex copies of `hook-dependency-guard.ps1`, `hook-command-scanner.ps1`,
  `hook-command-invocation.ps1` and `feature-folder-resolution.ps1` are compared with
  `git hash-object` before the plan relies on them being identical.

Files in child 5's edit set that overlap the parallel run's blast radius, and therefore wait for
that run to merge:

- `.codex/config.toml` (items 1009, 1010) and its bundled copy
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
  (items 1002, 1006, 1009, 1010, 1012, 1013)
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (items 1001,
  1009, 1011, 1012)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (items 1009, 1010)

Suites in the blast radius that child 5 does not edit but must keep green:
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`,
`tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, and the push-down
contract tests under `tests/scripts/dev_tools/` listed in `## Acceptance Criteria`.

## Inputs / Outputs

- Inputs:
  - `config/harness-parity-matrix.json` and child 1's inventory module (enumeration of
    `hook-registration` entries from `.claude/settings.json`, `.claude/agents/*.md` frontmatter,
    `.codex/config.toml` and `.github/hooks/*.json`).
  - Hook stdin payloads: Claude PreToolUse and SubagentStop envelopes; Codex PreToolUse and
    SubagentStop envelopes (`agent_type`, `last_assistant_message`, `stop_hook_active`).
  - The O2 owner-run Codex runbook result (recorded evidence), when available.
- Outputs:
  - Updated `hook-registration` matrix entries (`parity_group`, `reason`, `decision_status`,
    `decision_ref`).
  - New Codex hook files and twins under `.codex/hooks/`, a new Claude rule helper under
    `.claude/hooks/`, their bundle copies and pack-manifest entries.
  - New `[[hooks.PreToolUse]]` and `[[hooks.SubagentStop]]` registrations in `.codex/config.toml`
    (or the child 3 generator source, per O8) and the bundled copy.
  - Evidence under `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/<kind>/`
    (`qa-gates/` for Phase 0 and toolchain gates, `regression-testing/` for suite runs), each
    record carrying `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.
- Config keys and defaults: no new configuration keys.
- Versioning and compatibility: Claude hook behavior is unchanged; the feature-folder-order
  extraction is a refactor with existing suites as the regression check. Codex gains blocking
  behavior only for the registrations listed in `## Implementation Strategy`.

## API / CLI Surface

- Codex PreToolUse entry `.codex/hooks/enforce-feature-folder-order.ps1`: reads Codex stdin, maps
  `apply_patch`, `Edit` and `Write` targets through `codex-pretooluse-file-mapping.ps1`, calls the
  shared rule helper, and denies with exit code 2 and a reason on stderr when a plan write precedes
  the work mode's prerequisite documents. Malformed stdin fails closed with exit 2.
- Codex SubagentStop adapter `.codex/hooks/validate-codex-agent-output.ps1`: reads Codex stdin,
  dispatches on `agent_type` to the matching dot-sourced validator, emits JSON with
  `decision: "block"` and a reason to continue the subagent when validation fails, exits 0 with an
  allow result when validation passes or the `agent_type` has no registered validator, and allows
  without re-validation when `stop_hook_active` is true (loop guard). Malformed stdin fails closed
  with exit 2. Precedent: `.codex/hooks/validate-feature-review-coverage.ps1`.
- Claude entry points are unchanged in signature and exit-code behavior.

## Data & State

- Matrix invariants after this feature:
  - Every `hook-registration` entry has a non-empty `parity_group` matching `^hook:[a-z0-9-]+$`.
  - Every parity group with a Claude member and no Codex member, or the reverse, has a non-empty
    `reason` on each member entry of the present ecosystem.
  - Copilot entries keep child 1's default disposition and `owner_child` 6; only `parity_group`
    is set by child 5.
- Byte-identity invariants: each `.claude/hooks/<x>.ps1` and `.codex/hooks/<x>.ps1` twin has equal
  content hashes; each root hook file equals its bundle copy.
- No persistence, caching, migration or backfill is introduced.

## Constraints & Risks

- Upstream contracts are not final (E3); see `## Upstream Dependencies`.
- The parallel run `bugs-1001-1002-1003-1006` edits many of the same files; see
  `## Execution Preconditions`.
- Batch budget: the work exceeds the per-session PowerShell file budget, so execution uses the
  `large` route with a checkpoint in the item worktree.
- File size: `legacy-codex-hook-contracts.Tests.ps1` caps listed Codex hooks at 500 lines.
  `validate-planner-output.ps1` and `validate-executor-output.ps1` are close to that cap; the
  copies add no lines, and line counts are recorded before copying.
- Coverage: byte-identical copies executed only through the Codex adapter can fall below the line
  threshold; unit suites dot-source each copy directly and exercise every decision branch.
- Test isolation: equivalence suites load Claude and Codex files that define the same function
  names; each entry runs in a separate child process or functions are removed in `AfterAll`, and
  seeded shuffled file-order runs verify independence.
- Linux CI: `tests/scripts/codex-hooks` runs in the Linux hook-suite job on a case-sensitive file
  system; fixtures use `Join-Path`, forward-slash relative paths, exact file-name case and no drive
  letters.
- Live hook behavior on a branch is not exercised by isolated subagents before merge; Pester
  suites are the stated proof.
- Codex documentation describes tool hooks as "a useful guardrail, not a complete enforcement
  boundary"; Codex counterparts reduce drift but do not make Codex hooks the authoritative
  completion gate.

## Language Classification

Per the epic `## Shared Design` language rule: pushed-down hooks and libraries are PowerShell or
bash; TypeScript is only for MCP tools and extension commands; no new Python. Exception E2 is not
needed.

| Artifact | Runs where | Language | Rule outcome |
| --- | --- | --- | --- |
| `.claude/hooks/feature-folder-order-rules.ps1` and its `.codex/hooks/` twin | pushed down | PowerShell | allowed |
| `.claude/hooks/enforce-feature-folder-order.ps1` (rule functions moved to the helper) | pushed down | PowerShell | allowed |
| `.codex/hooks/enforce-feature-folder-order.ps1` | pushed down | PowerShell | allowed |
| `.codex/hooks/` twins: `subagentstop-envelope.ps1`, `premortem-section.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, `validate-task-researcher-output.ps1`, `validate-required-artifact-output.ps1`, `validate-prd-feature-output.ps1`, `validate-pr-author-output.ps1` | pushed down | PowerShell | allowed |
| `.codex/hooks/validate-codex-agent-output.ps1` | pushed down | PowerShell | allowed |
| `.codex/hooks/feature-review-coverage-thresholds.ps1` change (O9, conditional) | pushed down | PowerShell | allowed |
| Bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` | pushed down | PowerShell | allowed |
| `.codex/config.toml` hook tables and the bundled copy | pushed down | TOML configuration | not code |
| Both `pack-manifests/core.json` entries | extension payload data | JSON | not code |
| `config/harness-parity-matrix.json` field updates | repository only | JSON | not code |
| Pester suites under `tests/scripts/codex-hooks/` and `tests/scripts/harness/` | repository only | PowerShell | allowed |
| Python-invocation guard scan-root extension and its tests | repository only | PowerShell | allowed |

A library-publication route for O4 (publishing `.claude/lib/<x>` to `.codex/lib/<x>`) would be a
TypeScript extension-command change in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`,
which belongs to child 4's consolidation. It is out of scope for child 5.

## Implementation Strategy

- **Phase 0 gate.** Confirm the parallel run merged; confirm child 1 and child 3 outputs per
  `## Upstream Dependencies`; compare named files, symbols and headings against `origin/main`;
  compare `git hash-object` of the existing shared helpers; record results under
  `evidence/qa-gates/`. Stop for re-planning on any difference.
- **Feature-folder order.** Move the pure rule functions of
  `.claude/hooks/enforce-feature-folder-order.ps1` into `.claude/hooks/feature-folder-order-rules.ps1`
  (pattern: `feature-folder-resolution.ps1`) and dot-source it; create the byte-identical
  `.codex/hooks/feature-folder-order-rules.ps1` and the Codex entry
  `.codex/hooks/enforce-feature-folder-order.ps1`; register the entry in the
  `^(apply_patch|Edit|Write)$` PreToolUse group of `.codex/config.toml`.
- **SubagentStop validators.** Create byte-identical `.codex/hooks/` copies of the dot-source-safe
  Claude rule files listed in `## Language Classification`; create the Codex adapter
  `.codex/hooks/validate-codex-agent-output.ps1`; add `[[hooks.SubagentStop]]` registrations whose
  matchers name the agent types of each ported validator (planner, executor, task-researcher,
  prd-feature, pr-author, and the required-artifact agents prd-feature, staged-review,
  status-updater and epic-review), limited to agent types whose generated Codex body states the
  contract (Phase 0).
- **Preimplementation delegation leg (O2).** Add `enforce-orchestration-preimplementation-gate.ps1`
  to the `^(Agent|Task|spawn_agent|run_subagent|delegate)$` PreToolUse group only after the
  owner-run Codex runbook result is recorded and confirms the required input fields; otherwise
  record the pending reason in the matrix.
- **Native-with-reason groups (O4, O5, O6).** No code change; matrix `reason`, `decision_status`
  and `decision_ref` set per the parity-group table.
- **O9 (conditional).** If child 3 moves the coverage-threshold text out of `CLAUDE.md`, change the
  Codex `feature-review-coverage-thresholds.ps1` to read `AGENTS.md` first and fall back to
  `CLAUDE.md`.
- **Matrix.** Set `parity_group` for every `hook-registration` entry, and `reason`,
  `decision_status` and `decision_ref` where required.
- **Python-invocation guard.** Add `.github/hooks` and `.codex/scripts` to
  `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` and add
  root-membership tests to `enforcement-hooks-no-python-invocation.Tests.ps1`.
- **Tests.** New suites `tests/scripts/codex-hooks/hook-parity-twins.Tests.ps1`,
  `tests/scripts/codex-hooks/hook-parity-equivalence.Tests.ps1`,
  `tests/scripts/codex-hooks/validate-codex-agent-output.Tests.ps1`,
  `tests/scripts/codex-hooks/enforce-feature-folder-order.Tests.ps1`, and the repository gate
  `tests/scripts/harness/hook-parity-gate.Tests.ps1` (file name aligned with child 1's harness test
  conventions at Phase 0). Add the new Codex entries and helpers to the name lists in
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- **Mirrors and manifests.** Byte-identical bundle copies of each new or changed root hook file;
  entries in the Claude and Codex `pack-manifests/core.json`; the bundled `.codex/config.toml`
  equal to the root file.
- Dependency changes: none. Logging: hooks keep the existing stderr reason and JSON decision
  conventions. Rollout: no feature flag; Codex registrations take effect for destinations on the
  next push-down.

## Non-Goals

- No edits to `.claude/settings.json`, `.claude/agents/*.md` or `.codex/agents/*.toml`. Frontmatter
  hook changes go through child 3's agent source; duplicate registrations stay per O3.
- No edits to `.github/hooks/**` or their bundle copies (child 6).
- No edits to push-down TypeScript under `extensions/drm-copilot/src/lib/push-down/**` (child 4),
  including any O4 library-publication route.
- No edit to any path in the parallel run's blast radius before that run merges.
- No change to `.claude/hooks/validate-orchestrator-output*.ps1`,
  `.claude/hooks/enforce-pr-author-*.ps1`, `.claude/hooks/enforce-mermaid-validation.ps1`,
  `.claude/hooks/enforce-prd-feature-before-planner*.ps1`, the parallel gate hooks, or `.claude/lib/**`.
- No new Python, and no edits to existing Python contract tests (they are run, not edited).
- No Claude counterparts for the Codex-only epic hooks (O6).
- No change to the matrix schema, the `id` encoding or the completeness test (child 1).
- No new generator (child 3 owns generation).

## Acceptance Criteria

- [ ] Phase 0 evidence under `evidence/qa-gates/` records, with `gh` and `git` command output, that every item of the parallel run `bugs-1001-1002-1003-1006` has merged to `main`, that child 1 and child 3 have merged, the confirmed matrix path, schema fields and `id` encoding, the O8 ownership finding for `[[hooks.*]]` tables, and the per-agent-type finding that the generated Codex agent body states the output contract each ported validator checks; when any check differs from this spec, the evidence records the stop and the plan revision.
- [ ] Every `hook-registration` entry that child 1's inventory module enumerates at execution time from `.claude/settings.json`, `.claude/agents/*.md` frontmatter, `.codex/config.toml` and `.github/hooks/*.json` has a non-empty `parity_group` matching `^hook:[a-z0-9-]+$`, and child 1's matrix completeness test passes.
- [ ] Every Claude and Codex `hook-registration` entry has `disposition` `native`, or `generated` where child 3's generator writes the registering file, and no hook entry uses `shared` unless a single source file is published unchanged to more than one runtime; verified by `tests/scripts/harness/hook-parity-gate.Tests.ps1`.
- [ ] `tests/scripts/harness/hook-parity-gate.Tests.ps1` passes and asserts that every parity group with a Claude member and no Codex member, or a Codex member and no Claude member, carries a non-empty `reason`, `decision_status` and `decision_ref` on each present member.
- [ ] Copilot `hook-registration` entries carry `parity_group` values and keep child 1's default disposition and `owner_child` 6 unchanged; verified by `tests/scripts/harness/hook-parity-gate.Tests.ps1`.
- [ ] `.codex/hooks/feature-folder-order-rules.ps1` is byte-identical to `.claude/hooks/feature-folder-order-rules.ps1`, `.codex/hooks/enforce-feature-folder-order.ps1` is registered in the `^(apply_patch|Edit|Write)$` PreToolUse group of `.codex/config.toml`, and `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` and `tests/scripts/codex-hooks/enforce-feature-folder-order.Tests.ps1` pass.
- [ ] Codex twins of `subagentstop-envelope.ps1`, `premortem-section.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, `validate-task-researcher-output.ps1`, `validate-required-artifact-output.ps1`, `validate-prd-feature-output.ps1` and `validate-pr-author-output.ps1` exist under `.codex/hooks/`, and `tests/scripts/codex-hooks/hook-parity-twins.Tests.ps1` passes, asserting equal content hashes for every `.claude/hooks` and `.codex/hooks` twin pair and for every new root file and its bundle copy.
- [ ] `.codex/hooks/validate-codex-agent-output.ps1` is registered under `[[hooks.SubagentStop]]` in `.codex/config.toml` for each agent type whose contract Phase 0 confirmed, and `tests/scripts/codex-hooks/validate-codex-agent-output.Tests.ps1` passes, covering allow, continuation on a failed contract, exit 2 on malformed stdin, the `stop_hook_active` loop guard, and allow for an unregistered `agent_type`.
- [ ] `tests/scripts/codex-hooks/hook-parity-equivalence.Tests.ps1` passes, running the Claude entry and the Codex entry of each ported parity group on one shared fixture table per group and asserting the same normalized decision (allow, deny or continue) for every fixture.
- [ ] The Codex preimplementation delegation-leg registration is present in `.codex/config.toml` only when recorded O2 runbook evidence confirms that Codex fires PreToolUse inside subagents and that `spawn_agent` input carries the fields the delegation leg reads; otherwise it is absent and the `hook:preimplementation-gate` matrix entries record the pending-runbook reason; verified by `tests/scripts/harness/hook-parity-gate.Tests.ps1`.
- [ ] Matrix entries for `hook:mermaid-validation`, `hook:prd-feature-before-planner`, `hook:pr-author-skill-gate`, `hook:orchestrator-output`, `hook:pr-author-command-allowlist`, `hook:session-id-persist`, the parallel-gate groups, `hook:epic-planning-only` and `hook:epic-child-worktree-binding` record the reasons stated in this spec's parity-group table, unless an owner override is recorded in `decision_ref`.
- [ ] `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` includes `.github/hooks` and `.codex/scripts`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with root-membership tests for both roots, an empty allowlist and zero residual findings.
- [ ] `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lists each new Codex entry and helper and passes (parse, 500-line cap in root and bundle, stdin read for entries, no `$env:CLAUDE_*` read, Codex `core.json` membership).
- [ ] `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` pass with the new registrations.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass, and the bundled `.codex/config.toml` equals the root file.
- [ ] Each new PowerShell production file under `.claude/hooks/` and `.codex/hooks/` has line coverage at or above the threshold governed by the root `CLAUDE.md` (default 85 percent) in `artifacts/pester/powershell-coverage.xml`, recorded under `evidence/qa-gates/`.
- [ ] Three seeded shuffled file-order runs and one fresh single-process run over `tests/scripts` pass, recorded under `evidence/regression-testing/`, showing that the twin and equivalence suites do not leak function definitions.
- [ ] If child 3 moved the coverage-threshold text out of `CLAUDE.md`, the Codex `feature-review-coverage-thresholds.ps1` reads `AGENTS.md` first and falls back to `CLAUDE.md` with a passing Pester case for each source; otherwise the Phase 0 evidence records that O9 does not apply.
- [ ] The branch diff against its merge base adds no `.py` file and modifies no path under `.claude/settings.json`, `.claude/agents/`, `.codex/agents/`, `.github/hooks/` or `extensions/drm-copilot/src/lib/push-down/`, recorded under `evidence/qa-gates/`.
- [ ] The `poshqc-linux-hooks` job and the Windows PowerShell QC shards of `.github/workflows/_poshqc.yml` conclude `success` on the pull-request head (CI-dependent; checked off at S9).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or evidence
- [ ] Behavior matches acceptance criteria on Windows and in the Linux hook-suite job
- [ ] Tests updated/added (Pester unit, twin, equivalence and repository-gate suites)
- [ ] Edge cases and error handling covered by tests (malformed stdin, loop guard, unknown agent type)
- [ ] Docs updated (this folder; matrix entries carry reasons)
- [ ] Logging conventions unchanged (stderr reasons, JSON decisions)
- [ ] Toolchain pass completed (format, lint, architecture, unit, contract, integration)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: each new or ported Codex hook (Pester), matrix hook-entry coverage.
- [ ] Integration scenarios: Linux hook-suite job over `tests/scripts/codex-hooks`.
- [ ] CLI/API examples: Codex stdin fixtures for the PreToolUse entry and the SubagentStop adapter.
