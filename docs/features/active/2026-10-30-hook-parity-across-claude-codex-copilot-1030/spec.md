# hook-parity-across-claude-codex-copilot — Spec

- **Issue:** #1030
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 5
- **Owner:** drmoisan
- **Last Updated:** 2026-11-18
- **Status:** Draft
- **Version:** 0.4
- **Primary research:** `research/research.2026-10-30T22-59.md` (this feature folder)
- **Settled design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`; epic manifest `docs/features/epics/shared-agent-harness-layer/epic.md`
- **Parity matrix contract:** child 1 spec, #1025, `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` on its branch

## Overview

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`), Codex (`.codex/hooks`) and GitHub Copilot (`.github/hooks`). The sets were built
separately and drifted: some Claude gates have no Codex counterpart, some Codex hooks exist only to
express Codex-specific attestation, and the Copilot hooks cover only the discovery surface. No
record states, for each hook registration, whether its function has an equivalent in another
ecosystem, is native to one ecosystem, or is deliberately not ported, so a missing gate in one
ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hooks stay native in each
ecosystem; hook counts need not match; Codex gains a hook only where its hook system can express
the behavior; enforcement hooks do not invoke Python.

Registration-shape parity for PreToolUse is already delivered by #1159, which replaced per-hook
PreToolUse registrations with one dispatcher per runtime (see `## Decisions`, AD-4). This feature is narrowed to function parity. It follows research Approach A (matrix-first,
minimal ports): record a disposition and a gap class for every hook registration, add Codex
counterparts only where the event and payload are verified and the port needs no `.claude/lib`
module, pin cross-tree helper identity, and record lib-dependent and unverified gates with their
gap class and reason.

## Decisions

A superseded-work check against this branch, which contains `origin/main` as of 2026-11-14,
found the 2026-10-30 spec partially superseded. The orchestrator took decisions AD-1 to AD-6 on
2026-11-14 and AD-8 on 2026-11-18, in autonomous mode; they are final for this feature. AD-7 is
not assigned.

| ID | Decision | Rationale |
| --- | --- | --- |
| AD-1 | The execution precondition on the parallel run `bugs-1001-1002-1003-1006`, its blast-radius constraint, its Phase 0 check, its edit prohibition and its Non-Goals line are removed. The prohibition on editing Codex hook files at or above 490 physical lines is kept. | The parallel run and #1013 merged and their issues are closed; the run no longer has files in flight. |
| AD-2 | `validate-planner-output.ps1`, `validate-task-researcher-output.ps1`, `validate-executor-output.ps1`, `validate-prd-feature-output.ps1` and `validate-required-artifact-output.ps1` move from `ADD` to `DEFER`. `validate-pr-author-output.ps1` stays `ADD`, with a Codex twin of `subagentstop-envelope.ps1` only; the `premortem-section.ps1` twin is dropped. The D-16 criterion for `validate-required-artifact-output` and OQ-10 are not applicable. | Since #1105 and #1163, each of the five Claude sources dot-sources `.claude/hooks/subagentstop-target-worktree.ps1`, which imports `HookTargetWorktree.psm1`, `AgentTargetWorktree.psm1`, `WorktreeTargetResolution.psm1` and `WorktreeItemResolution.psm1` from `.claude/lib/worktree-resolution/`. Under OQ-3, lib-dependent ports defer to child 4 (`.codex/lib` publication). `validate-pr-author-output.ps1` dot-sources only `hook-dependency-guard.ps1` and `subagentstop-envelope.ps1`, and the envelope helper imports nothing. With `validate-required-artifact-output` deferred, no `-RequiredArtifact` registration is added to `.codex/config.toml`, so the D-16 pattern rule and the checker question in OQ-10 have no subject. Verified by text search of the six Claude sources and of `subagentstop-target-worktree.ps1` on 2026-11-14. |
| AD-3 | `ADD-CONDITIONAL` items are settled. C1 (registering the Codex preimplementation gate for the delegation tool names) takes gap class `NOT-EXPRESSIBLE`. C2 (Codex port of the pr-author Bash allowlist) takes gap class `DEFER`. The Phase 0 Codex payload check is removed. | C1: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` routes `tool_input` only for `Bash` and `apply_patch` and maps every other tool name through `ConvertTo-CodexFileEditInput`; the file is at the 500-line Codex cap and is not edited; the gap is owned by issue #555. C2: there is no recorded verification that Codex subagent PreToolUse payloads carry `agent_type`. |
| AD-4 | Registration-shape parity for PreToolUse is recorded as superseded by #1159. The hook-registration inventory names both dispatch registries as registration sources. The Codex `enforce-feature-folder-order.ps1` port registers in the Codex dispatch registry, not in `.codex/config.toml` (superseded by AD-8: the port is deferred, and no registry entry is added). | #1159 made `.codex/config.toml` register only `.codex/hooks/invoke-pretooluse-dispatch.ps1` for PreToolUse, with hooks registered in `.codex/hooks/pretooluse-dispatch.json`; Claude registers only `.claude/hooks/invoke-pretooluse-dispatch.ps1` in `.claude/settings.json`, with hooks in `.claude/hooks/pretooluse-dispatch.json`. The Codex registry `notes` state that a new PreToolUse hook is registered in the registry, not beside the dispatcher table, and that the dispatcher timeout is the sum of the hook timeouts listed in the registry. |
| AD-5 | OQ-4 decided: the Codex `validate-bash.ps1` keeps its omission of the cd-chained read leg; no brief edit. | The execution-environment brief already states that the Codex copy carries the destructive patterns and has no cd-chained leg, so brief and implementation agree. |
| AD-6 | The test-isolation gate is the parallel gate: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix. | Owner standing rule: tests are parallel-only (no serial, single-process, shuffled or reversed runs), and test-order dependence is a violation to be fixed, not worked around. |
| AD-8 (2026-11-18) | The Codex `enforce-feature-folder-order.ps1` port moves from `ADD` to `DEFER`, with a `GAP:DEFER: ` note naming `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and child 4, in the same way as the five AD-2 SubagentStop validators under OQ-3. No `.codex/hooks/enforce-feature-folder-order.ps1` file or bundle copy is added; the Codex dispatch registry gains no entry; the `.codex/config.toml` dispatcher `timeout` is not changed; `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Codex.ps1` gains no envelope and `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` gains no `codex` row for it. `enforce-feature-folder-order` joins the `DEFER` stem set, and the `hook:enforce-feature-folder-order` group has a Claude member only. The only remaining Codex `ADD` ports are `validate-pr-author-output.ps1` and the `subagentstop-envelope.ps1` twin. Phase 0 check (c) records the Claude source's imports and no longer stops on the child 2 import. | Phase 0 check (c) on 2026-11-18 (`evidence/baseline/phase0-gate.2026-11-18T07-25.md`) found that `.claude/hooks/enforce-feature-folder-order.ps1` imports `../lib/development-docs/DevelopmentDocsRoot.psm1` (child 2, #1035) alongside `hook-dependency-guard.ps1`, `../lib/hook-payload/HookPayload.psm1` and `feature-folder-resolution.ps1`, and that `Test-IsFeaturePlanPath` calls `Get-DevelopmentDocsKnownRootPattern` from that module; `.codex/lib` does not exist. A private Codex copy of the root-pattern function would be a second implementation that drifts; a load from `.claude/lib` breaks the rule that Codex hooks use no `.claude` path; OQ-3 already defers lib-dependent ports to child 4. Verified by text search of the Claude source and a file search for `.codex/lib` on 2026-11-18. |

Phase 0 checks are relettered after AD-1 and AD-3: former (b) child 1 is now (a), former (c)
child 3 is (b), former (d) child 2 is (c), and former (f) edit-set re-check is (d).

## Terminology

- **Hook registration.** One (event, matcher, command) entry, inventoried by child 1's rules from
  `.claude/settings.json` `hooks`, `.claude/hooks/pretooluse-dispatch.json`, `.claude/agents/*.md`
  frontmatter `hooks:`, `.codex/config.toml` `[[hooks.<Event>]]`,
  `.codex/hooks/pretooluse-dispatch.json` and `.github/hooks/*.json`. The dispatcher entry in
  `.claude/settings.json` and in `.codex/config.toml` is itself a registration. Unregistered helper
  scripts are implementation and receive no matrix entry (child 1 working assumption Q6).
- **Dispatch registry.** `.claude/hooks/pretooluse-dispatch.json` or
  `.codex/hooks/pretooluse-dispatch.json`: the JSON file whose `hooks.PreToolUse` groups list the
  hooks the runtime's PreToolUse dispatcher runs.
- **Shared function (restated per OQ-1).** Under child 1's `### Disposition Semantics`, `shared`
  means one source file mirrored to several locations, which hooks are not. In this feature every
  hook registration keeps `disposition: native`, and "shared function" means a `parity_group` that
  has members in more than one ecosystem. The issue's draft criterion "every hook whose disposition
  is shared has a counterpart" is restated as: every Claude hook registration's `parity_group` either
  has a Codex member or carries a recorded gap class.
- **Gap class.** The reason a Claude `parity_group` has no Codex member: `NOT-APPLICABLE` (the
  protected workflow does not exist in Codex), `NOT-EXPRESSIBLE` (the Codex hook system or the
  Codex hook that would carry the function cannot express the event, matcher or payload), `DEFER`
  (expressible, but blocked by a named dependency), or `CODEX-NATIVE` for a Codex `parity_group`
  that Claude expresses by another mechanism. Encoding is per OQ-2.
- **Port labels (research section 3).** `ALREADY-PARITY`, `ADD`, `DEFER`, `NOT-APPLICABLE`,
  `NOT-EXPRESSIBLE`. The former `ADD-CONDITIONAL` label is retired by AD-3.

## Behavior

- Every hook registration enumerated by child 1's inventory module at execution time, including
  every entry of both dispatch registries, has exactly one parity-matrix entry with
  `disposition: native`, a `parity_group` that groups equivalent functions across ecosystems
  (including stems that differ, for example the model-routing and epic-invocation-origin families
  and discovery start/stop across all three ecosystems), and, where the group has no Codex member,
  a gap class with its reason.
- The rule above applies to Claude hooks added after 2026-10-31 (for example owner-directive
  pass-down, merge-gate review and child-CI helpers, and regeneration hooks) in the same way as to
  older hooks. Claude-only enforcement documented as Claude-only in
  `.claude/rules/orchestrator-state.md` (for example owner-directive pass-down) takes gap class
  `NOT-APPLICABLE` or `DEFER`, with the reason stated in that rule file.
- Codex gains one counterpart (`ADD`):
  - SubagentStop: `validate-pr-author-output.ps1`, with a Codex twin of `subagentstop-envelope.ps1`.
    It honors `stop_hook_active` with one continuation and registers as a `[[hooks.SubagentStop]]`
    table in `.codex/config.toml` with a matcher that admits `pr-author`.
- The Codex `enforce-feature-folder-order.ps1` port is `DEFER` (AD-8): the Claude source imports
  child 2's `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, which is not published to
  `.codex/lib`. The `hook:enforce-feature-folder-order` group has a Claude member only, and that
  member carries a `GAP:DEFER: ` note naming the module and child 4. No Codex PreToolUse hook is
  added, and the Codex dispatch registry and dispatcher `timeout` are unchanged.
- `ADD-CONDITIONAL` items are recorded, not delivered (AD-3):
  - C1, Codex preimplementation gate for the delegation tool names: `NOT-EXPRESSIBLE`, reason naming
    the `Bash`/`apply_patch`-only `tool_input` routing, the 500-line cap and issue #555.
  - C2, Codex port of the pr-author Bash allowlist: `DEFER`, reason naming the unverified
    `agent_type` field in Codex subagent PreToolUse payloads.
- `DEFER` rows (recorded, not ported, per OQ-3 and OQ-8): `enforce-prd-feature-before-planner`,
  `enforce-mermaid-validation`, every `validate-orchestrator-output` registration form,
  `enforce-pr-author-skill`, the five SubagentStop validators of AD-2
  (`validate-planner-output`, `validate-task-researcher-output`, `validate-executor-output`,
  `validate-prd-feature-output`, `validate-required-artifact-output`), and, per AD-8,
  `enforce-feature-folder-order`, each with a reason naming the `.claude/lib` dependency and child 4.
- PreToolUse registration-shape parity (one dispatcher per runtime) is recorded in the child 5
  disposition record as superseded by #1159.
- Copilot registrations under `.github/hooks` receive `disposition: native`, `owner_child: 6`;
  child 5 records only.
- Logic divergences between same-named Claude and Codex hooks (for example the Codex
  `validate-bash.ps1` omission of the cd-chained read leg, kept per AD-5; the Claude payload-anomaly
  deny path) are recorded in matrix `notes`, not changed.
- The no-Python scan for enforcement hooks covers `.github/hooks` in addition to its existing roots.
- Bundled mirrors under `extensions/drm-copilot/resources/` stay byte-identical to their roots.

## Inputs / Outputs

- Inputs:
  - `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` (child 1).
  - Child 1 inventory module (`scripts/harness/HarnessInventory.psm1`) and completeness gate.
  - Registration surfaces: `.claude/settings.json`, `.claude/hooks/pretooluse-dispatch.json`,
    `.claude/agents/*.md`, `.codex/config.toml`, `.codex/hooks/pretooluse-dispatch.json`,
    `.github/hooks/*.json`.
  - The import list of the Claude `enforce-feature-folder-order.ps1` source, recorded at Phase 0
    check (c) as evidence for the AD-8 `DEFER` reason; child 2's development-docs resolver is not
    an input to any Codex file.
  - Child 3 generator ownership of agent frontmatter `hooks:` and of `.codex/config.toml` regions.
- Outputs:
  - Updated `hook-registration` entries in `config/harness-parity-matrix.json`.
  - Child 5 disposition record in this feature folder (the `decision_ref` target).
  - New Codex files `.codex/hooks/validate-pr-author-output.ps1` and
    `.codex/hooks/subagentstop-envelope.ps1`, any separate Codex-specific helper file, and their
    bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
  - One `[[hooks.SubagentStop]]` table for the pr-author validator in `.codex/config.toml` (root and
    bundle).
  - Codex core pack-manifest entries for the new files.
  - New Pester suites (hook-parity gate, cross-tree helper identity, one Codex behavior suite for
    the pr-author validator).
  - Not produced (AD-8): `.codex/hooks/enforce-feature-folder-order.ps1` and its bundle copy; any
    change to `.codex/hooks/pretooluse-dispatch.json` or to the dispatcher `timeout` in
    `.codex/config.toml` (root and bundle); a Codex envelope in
    `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Codex.ps1`; a `codex` row for
    `enforce-feature-folder-order.ps1` in
    `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`.
  - Phase 0 evidence under `<FEATURE>/evidence/baseline/`; QA and regression evidence under
    `<FEATURE>/evidence/qa-gates/` and `<FEATURE>/evidence/regression-testing/`.
- Versioning: matrix changes stay within child 1's `schema_version` major 1. A structured gap
  field, if chosen under OQ-2, is a child 1 minor bump, not a child 5 schema change.

## API / CLI Surface

- No new CLI, MCP tool or extension command.
- Hook contracts (Codex):
  - The SubagentStop validator reads `agent_type`, `last_assistant_message` and
    `stop_hook_active`; it blocks with exit 2 and a stderr reason (the Claude source's
    `PR_AUTHOR_OUTPUT_MALFORMED`, `PR_AUTHOR_OUTPUT_EMPTY`, `PR_AUTHOR_OUTPUT_NO_PR` and
    `PR_AUTHOR_OUTPUT_MISSING` prefixes) and allows a stop when `stop_hook_active` is already set.
  - No Codex PreToolUse hook is added (AD-8).
  - Every new `.codex/config.toml` table invokes `pwsh` only, with the `command_windows` twin and a
    `timeout`, matching existing entries.
- Matrix selection: child 5 selects entries by `ecosystem`, `kind`, `name`, `source_path` and
  `source_pointer`, not by parsing `id`.

## Data & State

- Matrix invariants written by child 5 for `kind: hook-registration`:
  - `disposition: native` for every entry; `dropped` only with a recorded owner decision (OQ-9).
  - `parity_group` of the form `hook:<function>`; equivalent functions with different stems share
    one group.
  - A gap class with reason for each Claude group without a Codex member and each Codex group
    without a Claude member.
  - `decision_status: provisional` with `decision_ref` pointing to the child 5 disposition record
    until the owner approves; `approved` thereafter.
- Codex dispatch registry invariant: the dispatcher `timeout` in `.codex/config.toml` equals the sum
  of the `timeout` values of every hook in `.codex/hooks/pretooluse-dispatch.json`. This feature
  changes neither side (AD-8); the invariant held at Phase 0 and must still hold on the PR head.
- No persistence, migration or backfill outside the matrix and the files listed under Outputs.

## Language Classification

Owner rule (epic `## Shared Design`): no new Python; anything pushed down to destination
repositories (skills, skill helpers, hooks, libs) is PowerShell or bash; TypeScript only for MCP
commands and extension commands. Hooks never invoke Python.

| Artifact | Runs where | Classification |
| --- | --- | --- |
| Codex `validate-pr-author-output.ps1`, `subagentstop-envelope.ps1` twin, any Codex-specific helper, and bundle copies | pushed down | PowerShell; no Python invocation |
| `.codex/config.toml` pr-author `[[hooks.SubagentStop]]` table (root and bundle) | pushed down | TOML configuration data; commands invoke `pwsh` only |
| Codex `core.json` pack-manifest entries | pushed-down manifest | JSON data |
| `config/harness-parity-matrix.json` hook entries | repository only | JSON data |
| Child 5 disposition record | repository docs | Markdown |
| Hook-parity repository gate, cross-tree helper identity test, Codex behavior suites | CI | Pester (PowerShell) |
| No-Python scan extension to `.github/hooks` | CI | Pester, edited in place |
| Existing Python contract tests (`tests/scripts/dev_tools/test_push_down_*`, `test_codex_core_manifest_closure.py`) | CI | existing Python; run, and edited in place only when an expected list must change |
| Publication of `.claude/lib` modules to `.codex/lib` | extension push-down | not in scope; child 4 (OQ-3) |

No new Python or TypeScript file is produced. E2 (language-native analyzer exception): not
applicable; no analyzer is produced.

## Constraints & Risks

- **Dependencies.** Child 1 (matrix schema, inventory, completeness test; `id` grammar still open),
  child 3 (generator ownership of hook registrations). Child 2's resolver is imported by the Claude
  feature-folder-order source, which is why that port is `DEFER` (AD-8); child 4 owns its later
  publication to `.codex/lib`. Child 5 is wave 2.
- **Codex file-size cap.** Codex hooks pinned by `legacy-codex-hook-contracts.Tests.ps1` are capped
  at 500 lines. Codex hook files at or above 490 physical lines at Phase 0 (today
  `enforce-orchestration-preimplementation-gate.ps1`, its `-modes.ps1` and `-epic-resolution.ps1`
  parts, and `enforce-completion-consistency.ps1`) are not edited. Codex-specific logic in a port
  that would exceed the cap goes in a separate file.
- **Generator ownership.** `.claude/agents/*.md` frontmatter `hooks:` is generator-owned after
  child 3; this feature changes no Claude per-agent registration and no Claude dispatch-registry
  entry. The `.codex/config.toml` pr-author `[[hooks.SubagentStop]]` table is edited directly only
  if Phase 0 check (b) finds child 3 owns no `[[hooks.*]]` region; otherwise the generator source is
  edited (OQ-7).
- **Dispatch registry provenance.** The Codex registry `notes` describe it as generated from the
  `.codex/config.toml` PreToolUse tables at the #1159 merge base and also as the place where new
  PreToolUse hooks are registered. After AD-8 this feature neither edits nor regenerates the
  registry (root and bundle).
- **Codex coverage limits.** The vendor documentation states that tool hooks are a guardrail, not a
  complete enforcement boundary; hosted tools do not fire hooks.
- **Batch budget.** After AD-8, Phase 2 creates two PowerShell production files (the pr-author
  validator and the envelope twin) plus any Codex-specific helper in one worktree; the plan selects
  the batch-budget route from that file count.
- **Linux CI.** `tests/scripts/codex-hooks` runs in `poshqc / PowerShell hook suites (Linux)` on a
  case-sensitive file system; fixtures use `Join-Path`, forward-slash relative paths, exact case
  and no drive letters.

## Execution-Time Gating (owner decision E3)

Phase 0 re-checks before any edit. All checks run at the epic integration branch
`origin/epic/shared-agent-harness-layer-integration`, with the scope base derived as the merge base
of the integration branch and `HEAD` (reconciled 2026-10-31 with the plan's `INTEGRATION` and
`BASE` terms, because epic children merge into the integration branch, not `main`). Phase 0 records
each check under `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` with `Timestamp`,
`Command`, `EXIT_CODE` and `Output Summary`.

| Check | Content | On mismatch or negative result |
| --- | --- | --- |
| (a) Child 1 matrix | Matrix and schema exist; `schema_version` major 1; final `id` grammar and `name` form for `hook-registration`; encoding of matchers containing regex characters and of duplicate settings/frontmatter registrations; presence of a structured gap field (OQ-2); Q6 answer; the inventory module enumerates the entries of `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` as hook registrations | Stop for one plan revision |
| (b) Child 3 generators | Which regions are generator-owned (agent frontmatter `hooks:`; any `[[hooks.*]]` region of `.codex/config.toml`; either dispatch registry) | Stop for one plan revision |
| (c) Feature-folder resolver (revised by AD-8) | Record the modules the Claude `enforce-feature-folder-order.ps1` source imports as `FFO-RESOLVER`, and whether `.codex/lib/development-docs` exists. The import of child 2's `DevelopmentDocsRoot.psm1` is the expected state and supports the `DEFER` reason | Record only; the child 2 import does not stop the run. A Claude source that no longer imports any `.claude/lib` module is recorded for the disposition record and does not reopen the port in this feature |
| (d) Edit-set re-check | Every file, function and test named by the plan; physical line counts of Codex hooks near the cap; cross-tree identical-helper set by hash; the six Claude SubagentStop validator sources still match the AD-2 import facts | Stop for one plan revision |

Owner stops do not occur inside the execution plan. A mismatch on check (a), (b) or (d) ends the
run for one plan revision; check (c) records only (AD-8).

## Implementation Strategy

- **Phase 0.** Re-check gate as above.
- **Phase 1, dispositions and gate.** Update every `hook-registration` entry (`parity_group`, gap
  class, `notes` for recorded divergences, `decision_status`, `decision_ref`); write the child 5
  disposition record, including the AD-3 gap reasons and the #1159 supersession; add
  `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` asserting that each Claude
  `parity_group` has a Codex member or a gap class, and that no Codex `parity_group` is unmatched
  without a `CODEX-NATIVE` note; add `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`
  pinning byte identity of the cross-tree helpers confirmed identical by hash at Phase 0, following
  `codex-batch-budget-route-parity.Tests.ps1`. Any production module the gate needs is placed in
  child 1's `scripts/harness/`.
- **Phase 2, Codex port (ADD).** The pr-author validator and `subagentstop-envelope.ps1` twin with
  their `[[hooks.SubagentStop]]` table; bundle copies; core manifest entries; a behavior suite under
  `tests/scripts/codex-hooks/` mirroring the decision cases of the Claude suite. No
  `enforce-feature-folder-order.ps1` port, registry entry or dispatcher `timeout` change (AD-8).
- **Phase 3, Copilot and no-Python.** Copilot dispositions; extend the scan roots in
  `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` and
  `enforcement-hooks-no-python-invocation.Tests.ps1` to `.github/hooks`.
- No dependency changes. No logging or telemetry changes beyond the hooks' existing patterns.
- Rollout: Codex hooks take effect in Codex sessions on trusted projects after merge and in
  destination repositories after the next push-down.

## Acceptance Criteria

- [x] Phase 0 evidence exists under `<FEATURE>/evidence/baseline/` recording checks (a) to (d) of `## Execution-Time Gating` at the integration branch and scope base that section names, each with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, and any mismatch resulted in a plan revision before implementation began.
- [x] Every hook registration enumerated by child 1's inventory module at execution time from `.claude/settings.json`, `.claude/hooks/pretooluse-dispatch.json`, `.claude/agents/*.md` frontmatter, `.codex/config.toml`, `.codex/hooks/pretooluse-dispatch.json` and `.github/hooks/*.json` has exactly one matrix entry with `disposition: native`, a `parity_group` and a `decision_ref` to the child 5 disposition record; `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [x] Shared function (restated per OQ-1): every Claude `hook-registration` `parity_group` either has a Codex member or carries a gap class with its reason, and every Codex `parity_group` without a Claude member carries a `CODEX-NATIVE` note; `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` passes on the committed matrix and includes in-memory negative cases proving it fails for a Claude group with no Codex member and no gap class, and for an unmatched Codex group with no `CODEX-NATIVE` note.
- [x] Codex `validate-pr-author-output.ps1` has a root file under `.codex/hooks`, a byte-identical bundle copy, a Codex core pack-manifest entry, and a behavior suite under `tests/scripts/codex-hooks/` that runs the same decision cases as the corresponding Claude suite on equivalent Codex payloads, including a malformed payload that fails closed with exit 2.
- [x] Codex `validate-pr-author-output.ps1` is registered by one `[[hooks.SubagentStop]]` table in `.codex/config.toml` (root and bundle) whose matcher admits `pr-author`, and its behavior suite proves one continuation: a stop that fails validation is blocked when `stop_hook_active` is unset and allowed when it is set.
- [ ] The Codex `enforce-feature-folder-order` port is deferred per AD-8: the branch adds no `.codex/hooks/enforce-feature-folder-order.ps1` root or bundle file and no `enforce-feature-folder-order` entry in `.codex/hooks/pretooluse-dispatch.json` or `.codex/config.toml` (root and bundle), and leaves the dispatcher `timeout` in `.codex/config.toml` (root and bundle) unchanged and equal to the sum of the registry hook timeouts; the `hook:enforce-feature-folder-order` group has a Claude member only, and that member's `notes` begin with `GAP:DEFER: ` and name `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and child 4, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` (rules H1 and H5).
- [x] The Codex `subagentstop-envelope.ps1` twin keeps every function definition text-identical to the Claude source, and the cross-tree helper set confirmed identical at Phase 0 is pinned byte-identical, verified by `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`.
- [x] The matrix records C1 (Codex preimplementation gate for the delegation tool names) with gap class `NOT-EXPRESSIBLE` and a reason naming issue #555, and C2 (Codex pr-author Bash allowlist) with gap class `DEFER` and a reason naming the unverified `agent_type` payload field, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [x] `enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `enforce-pr-author-skill`, every `validate-orchestrator-output` registration form, `validate-planner-output`, `validate-task-researcher-output`, `validate-executor-output`, `validate-prd-feature-output`, `validate-required-artifact-output` and `enforce-feature-folder-order` carry a `DEFER` gap class whose reason names the blocking dependency, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [x] Every Copilot `hook-registration` entry from `.github/hooks/*.json` has `disposition: native` and `owner_child: 6`, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [ ] No enforcement hook invokes Python: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks`, `.claude/lib`, `.codex/hooks` and `.github/hooks`, and passes.
- [ ] Bundled mirrors and pack manifests are green: `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` and `test_codex_core_manifest_closure.py` pass.
- [ ] The branch diff against the scope base contains no edit to any Codex hook file whose physical line count at Phase 0 is 490 or more, no direct edit to `.claude/agents/*.md` frontmatter `hooks:`, to the `hooks` section of `.claude/settings.json` or to `.claude/hooks/pretooluse-dispatch.json`; any generator-owned region is changed through child 3's generator source, and child 3's generator `--check` passes.
- [ ] No new Python or TypeScript file is added; every new hook and test file is PowerShell, and every new Codex hook command invokes `pwsh`.
- [ ] Each new or changed Codex hook file reaches at least 85% line coverage in `artifacts/pester/powershell-coverage.xml`, recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head, including the new suites under `tests/scripts/codex-hooks/`.

## Open Owner Questions

The recommended defaults below are the working assumption for this spec. Rows marked "Decided"
were settled on 2026-11-14 (see `## Decisions`). An owner answer that differs
from a working default is applied through the Phase 0 plan revision.

| ID | Question | Working default or decision |
| --- | --- | --- |
| OQ-1 | Hooks with equivalent function: keep `native` with a common `parity_group` (child 1 semantics), rather than `shared`? | Yes; the issue's "shared" criterion is restated as a `parity_group` with members in more than one ecosystem |
| OQ-2 | Record expressibility gaps as a structured optional matrix field (child 1 minor schema bump) or as a `notes` prefix? | Structured field if child 1 has not merged when planned; otherwise a `notes` prefix checked by the hook-parity gate |
| OQ-3 | Codex ports that need `.claude/lib` modules (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `validate-orchestrator-output`, `enforce-pr-author-skill`, since AD-2 the five worktree-resolution-dependent SubagentStop validators, and since AD-8 `enforce-feature-folder-order`): defer until child 4 decides `.codex/lib` publication, or twin the modules under `.codex/hooks`? | Defer; publication belongs to child 4 |
| OQ-4 | Codex `validate-bash.ps1` omits the cd-chained read leg. Add the leg to Codex, or adjust the brief? | Decided (AD-5): keep the Codex omission; no brief edit, because the execution-environment brief already states the Codex copy has no cd-chained leg |
| OQ-5 | Feature-review coverage hooks read only root `CLAUDE.md`. In a Codex-only destination, should they also read `AGENTS.md`? | Yes for the Codex hook, after child 3 settles `AGENTS.md` content; otherwise unchanged |
| OQ-6 | Copilot is documented as reading `.claude/settings.json` hooks. Are Claude hooks expected to run in Copilot sessions, or must child 6 prevent it? | Child 1 experiment and child 6 decision; child 5 records only |
| OQ-7 | If child 3 owns a `[[hooks.*]]` region of `.codex/config.toml`, is the pr-author `[[hooks.SubagentStop]]` table added through the generator source? | Yes; ownership verified at Phase 0 check (b). Relevant only if that region is generator-owned |
| OQ-8 | Is a Codex counterpart of `enforce-pr-author-skill` wanted, given Codex PR authoring uses its own receipts? | Not in child 5; record `DEFER` |
| OQ-9 | Keep duplicate SubagentStop registrations in both `.claude/settings.json` and agent frontmatter, or drop one copy? | Keep until child 1 experiment E5 shows whether both fire; any drop needs an owner decision |
| OQ-10 | Should child 2's D-16 checker cover `-RequiredArtifact` arguments in `.codex/config.toml`, or does child 5 add a Pester assertion? | Decided (AD-2): not applicable; `validate-required-artifact-output` is deferred, so no `-RequiredArtifact` registration is added to `.codex/config.toml` |

## Non-Goals

- Re-opening the settled design (hooks native, parity of function; no single-source generated hook
  body).
- PreToolUse registration-shape parity, delivered by #1159.
- Porting the `DEFER` hooks (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`,
  `validate-orchestrator-output`, `enforce-pr-author-skill`, the five AD-2 SubagentStop validators,
  `enforce-feature-folder-order` per AD-8, the pr-author Bash allowlist) or the `NOT-EXPRESSIBLE` preimplementation-gate registration
  (issue #555).
- Push-down publication of `.claude/lib` modules to `.codex/lib` (child 4).
- Finalizing the thin Copilot layer, Copilot hook changes or Copilot collision controls (child 6).
- Adding Claude hooks for Codex-native functions (root epic authorization, model/profile
  attestation, planning-only boundary, child worktree binding).
- Changing recorded logic divergences (cd-chained leg, payload-anomaly path) without an owner
  decision.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or gates
- [ ] Behavior matches acceptance criteria on Windows and in the Linux hook-suite job
- [ ] Tests added: hook-parity gate, cross-tree helper identity, one Codex behavior suite per port
- [ ] Edge cases and error handling covered: malformed payload fails closed, `stop_hook_active` loop stop
- [ ] Parallel test gates passed: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each re-run only after a fix, recorded under `<FEATURE>/evidence/regression-testing/`
- [ ] Docs updated: child 5 disposition record
- [ ] Toolchain pass completed (format, lint, architecture, unit, contract, integration)
