# hook-parity-across-claude-codex-copilot — Spec

- **Issue:** #1030
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 5
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
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

This feature follows research Approach A (matrix-first, minimal ports): record a disposition and a
gap class for every hook registration, add Codex counterparts only where the event and payload are
verified and the port needs no `.claude/lib` module, pin cross-tree helper identity, and record
lib-dependent and blast-radius-bound gates as DEFER with their reason.

## Terminology

- **Hook registration.** One (event, matcher, command) entry, inventoried by child 1's rules from
  `.claude/settings.json` `hooks`, `.claude/agents/*.md` frontmatter `hooks:`, `.codex/config.toml`
  `[[hooks.<Event>]]` and `.github/hooks/*.json`. Unregistered helper scripts are implementation and
  receive no matrix entry (child 1 working assumption Q6).
- **Shared function (restated per OQ-1).** Under child 1's `### Disposition Semantics`, `shared`
  means one source file mirrored to several locations, which hooks are not. In this feature every
  hook registration keeps `disposition: native`, and "shared function" means a `parity_group` that
  has members in more than one ecosystem. The issue's draft criterion "every hook whose disposition
  is shared has a counterpart" is restated as: every Claude hook registration's `parity_group` either
  has a Codex member or carries a recorded gap class.
- **Gap class.** The reason a Claude `parity_group` has no Codex member: `NOT-APPLICABLE` (the
  protected workflow does not exist in Codex), `NOT-EXPRESSIBLE` (the Codex hook system lacks the
  event, matcher or payload), `DEFER` (expressible, but blocked by a named dependency), or
  `CODEX-NATIVE` for a Codex `parity_group` that Claude expresses by another mechanism. Encoding is
  per OQ-2.
- **Port labels (research section 3).** `ALREADY-PARITY`, `ADD`, `ADD-CONDITIONAL`, `DEFER`,
  `NOT-APPLICABLE`, `NOT-EXPRESSIBLE`.

## Behavior

- Every hook registration enumerated by child 1's inventory module at execution time has exactly
  one parity-matrix entry with `disposition: native`, a `parity_group` that groups equivalent
  functions across ecosystems (including stems that differ, for example the model-routing and
  epic-invocation-origin families and discovery start/stop across all three ecosystems), and, where
  the group has no Codex member, a gap class with its reason.
- Codex gains counterparts only for the research's `ADD` rows that still hold at Phase 0:
  - SubagentStop output validators: `validate-planner-output.ps1`,
    `validate-task-researcher-output.ps1`, `validate-executor-output.ps1`,
    `validate-prd-feature-output.ps1`, `validate-pr-author-output.ps1`,
    `validate-required-artifact-output.ps1`, with Codex twins of `subagentstop-envelope.ps1` and
    `premortem-section.ps1`. Each honors `stop_hook_active` with one continuation. Enabled only
    under the OQ-7 precondition (child 3 generates Claude and Codex agent bodies from one
    definition).
  - PreToolUse: Codex `enforce-feature-folder-order.ps1` in the `^(apply_patch|Edit|Write)$` group,
    using the repository's apply_patch mapping and child 2's development-docs resolver (published
    `.codex/lib/development-docs` first, self-hosted `.claude/lib` second).
- `ADD-CONDITIONAL` rows (registering the existing Codex preimplementation gate on the Codex
  `Agent` group; a session-level `^Bash$` port of the pr-author Bash allowlist filtered on
  `agent_type`) are delivered only when Phase 0 holds a recorded positive verification of the
  required Codex payload fields. Otherwise each is recorded in the matrix with a `DEFER` gap class
  and its reason. No owner wait occurs inside the execution plan.
- `DEFER` rows (recorded, not ported, per OQ-3 and OQ-8): `enforce-prd-feature-before-planner`,
  `enforce-mermaid-validation`, every `validate-orchestrator-output` registration form, and
  `enforce-pr-author-skill`.
- Copilot registrations under `.github/hooks` receive `disposition: native`, `owner_child: 6`;
  child 5 records only.
- Logic divergences between same-named Claude and Codex hooks (for example the Codex
  `validate-bash.ps1` omission of the cd-chained read leg; the Claude payload-anomaly deny path) are
  recorded in matrix `notes`, not changed.
- The no-Python scan for enforcement hooks covers `.github/hooks` in addition to its existing roots.
- Bundled mirrors under `extensions/drm-copilot/resources/` stay byte-identical to their roots.

## Inputs / Outputs

- Inputs:
  - `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` (child 1).
  - Child 1 inventory module (`scripts/harness/HarnessInventory.psm1`) and completeness gate.
  - Registration surfaces: `.claude/settings.json`, `.claude/agents/*.md`, `.codex/config.toml`,
    `.github/hooks/*.json`.
  - Child 2 development-docs resolver and its write-scope rule table (D-16).
  - Child 3 generator ownership of agent frontmatter `hooks:` and of `.codex/config.toml` regions.
  - Phase 0 Codex payload verification result (owner-run Codex check or a child 1 runbook result).
- Outputs:
  - Updated `hook-registration` entries in `config/harness-parity-matrix.json`.
  - Child 5 disposition record in this feature folder (the `decision_ref` target).
  - New Codex hook files under `.codex/hooks` and their bundle copies.
  - `[[hooks.SubagentStop]]` and `[[hooks.PreToolUse]]` entries in `.codex/config.toml` (root and
    bundle) and the Codex core pack-manifest entries.
  - New Pester suites (hook-parity gate, cross-tree helper identity, Codex behavior suites).
  - Phase 0 evidence under `<FEATURE>/evidence/baseline/`; QA and regression evidence under
    `<FEATURE>/evidence/qa-gates/` and `<FEATURE>/evidence/regression-testing/`.
- Versioning: matrix changes stay within child 1's `schema_version` major 1. A structured gap
  field, if chosen under OQ-2, is a child 1 minor bump, not a child 5 schema change.

## API / CLI Surface

- No new CLI, MCP tool or extension command.
- Hook contracts (Codex):
  - SubagentStop validators read `agent_type`, `last_assistant_message` and `stop_hook_active`;
    they block with `decision: "block"` and a reason (or exit 2 with stderr) and allow a stop when
    `stop_hook_active` is already set.
  - PreToolUse hooks deny with `hookSpecificOutput.permissionDecision: "deny"` or exit 2; they do
    not emit `ask`, `continue: false` or `stopReason`; they fail closed with exit 2 on malformed
    input and allow a benign payload for every tool name their matcher admits.
  - Commands in `.codex/config.toml` invoke `pwsh` only, with the `command_windows` twin and a
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
- No persistence, migration or backfill outside the matrix and the files listed under Outputs.

## Language Classification

Owner rule (epic `## Shared Design`): no new Python; anything pushed down to destination
repositories (skills, skill helpers, hooks, libs) is PowerShell or bash; TypeScript only for MCP
commands and extension commands.

| Artifact | Runs where | Classification |
| --- | --- | --- |
| New Codex hooks (SubagentStop validators, `enforce-feature-folder-order.ps1`) and bundle copies | pushed down | PowerShell; no Python invocation |
| Codex twins of `subagentstop-envelope.ps1` and `premortem-section.ps1` | pushed down | PowerShell |
| `.codex/config.toml` `[[hooks.*]]` entries (root and bundle) | pushed down | TOML configuration data; commands invoke `pwsh` only |
| Codex `core.json` pack-manifest entries | pushed-down manifest | JSON data |
| `config/harness-parity-matrix.json` hook entries | repository only | JSON data |
| Child 5 disposition record | repository docs | Markdown |
| Hook-parity repository gate, cross-tree helper identity test, Codex behavior suites | CI | Pester (PowerShell) |
| No-Python scan extension to `.github/hooks` | CI | Pester, edited in place |
| Existing Python contract tests (`tests/scripts/dev_tools/test_push_down_*`, `test_codex_core_manifest_closure.py`) | CI | existing Python; run, and edited in place only when an expected list must change |
| Publication of `.claude/lib` modules to `.codex/lib` | extension push-down | not in scope; owner question OQ-3 (child 4) |

E2 (language-native analyzer exception): not applicable; no analyzer is produced.

## Constraints & Risks

- **Execution precondition.** Execution starts only after the parallel run
  `bugs-1001-1002-1003-1006` has merged to `main` (epic `## Execution Preconditions`).
- **Dependencies.** Child 1 (matrix schema, inventory, completeness test; `id` grammar still open),
  child 2 (resolver, D-16 rule table), child 3 (generator ownership of hook registrations; single
  agent definition). Child 5 is wave 2.
- **Codex file-size cap.** Codex hooks pinned by `legacy-codex-hook-contracts.Tests.ps1` are capped
  at 500 lines. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, its `-modes.ps1`
  and `-epic-resolution.ps1` parts, and `enforce-completion-consistency.ps1` are at or above 490
  lines and are not edited. A Codex twin of a large Claude validator places Codex-specific logic in
  a separate file.
- **Parallel-run blast radius.** The hook scripts named in the parallel run's manifest (epic merge
  gate, model-routing receipt, pr-author skill and allowlist, batch budgets, preimplementation
  gate, orchestrator output, `hook-target-worktree.ps1`) are not edited. Shared configuration and
  contract-test files the run also touches (`.codex/config.toml`, `core.json`,
  `legacy-codex-hook-contracts.Tests.ps1` and related suites) are edited only after Phase 0 confirms
  the run has merged, against their merged content.
- **Generator ownership.** `.claude/agents/*.md` frontmatter `hooks:` is generator-owned after
  child 3; this feature changes no Claude per-agent registration. `.codex/config.toml`
  `[[hooks.*]]` is edited directly only if child 3 owns only `[mcp_servers.*]`; otherwise the
  generator source is edited.
- **Codex coverage limits.** The vendor documentation states that tool hooks are a guardrail, not a
  complete enforcement boundary; hosted tools do not fire hooks.
- **Batch budget.** Phase 2 creates more than three PowerShell production files in one worktree;
  the plan uses the `large` route checkpoint or splits phases across sessions.
- **Linux CI.** `tests/scripts/codex-hooks` runs in `poshqc / PowerShell hook suites (Linux)` on a
  case-sensitive file system; fixtures use `Join-Path`, forward-slash relative paths, exact case
  and no drive letters.

## Execution-Time Gating (owner decision E3)

Phase 0 re-checks against `origin/main` before any edit and records each check under
`<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`
and `Output Summary`.

| Check | Content | On mismatch or negative result |
| --- | --- | --- |
| (a) Parallel run | `bugs-1001-1002-1003-1006` merged to `main` (all items) | Stop for one plan revision |
| (b) Child 1 matrix | Matrix and schema exist; `schema_version` major 1; final `id` grammar and `name` form for `hook-registration`; encoding of matchers containing regex characters and of duplicate settings/frontmatter registrations; presence of a structured gap field (OQ-2); Q6 answer | Stop for one plan revision |
| (c) Child 3 generators | Which regions are generator-owned (agent frontmatter `hooks:`; any part of `.codex/config.toml` outside `[mcp_servers.*]`); Claude and Codex agent bodies generated from one definition (OQ-7) | Stop for one plan revision |
| (d) Child 2 resolver | `.codex/lib/development-docs` published path, PowerShell resolver function names, D-16 checker coverage of `.codex/config.toml` hook arguments (OQ-10) | Stop for one plan revision |
| (e) Codex payload facts | `spawn_agent` argument field names under the `Agent` matcher; presence of `agent_type` in subagent PreToolUse payloads | No stop. Each `ADD-CONDITIONAL` item proceeds only with a recorded positive result; otherwise it is recorded with a `DEFER` gap class and reason |
| (f) Edit-set re-check | Every file, function and test named by the plan; physical line counts of Codex hooks near the cap; cross-tree identical-helper set by hash | Stop for one plan revision |

Owner stops do not occur inside the execution plan. The only owner-dependent outcomes are
resolved at Phase 0: a mismatch on (a) to (d) or (f) ends the run for one plan revision; a missing
or negative result on (e) converts the dependent item to `DEFER`.

## Implementation Strategy

- **Phase 0.** Re-check gate as above.
- **Phase 1, dispositions and gate.** Update every `hook-registration` entry (`parity_group`, gap
  class, `notes` for recorded divergences, `decision_status`, `decision_ref`); write the child 5
  disposition record; add `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` asserting
  that each Claude `parity_group` has a Codex member or a gap class, and that no Codex
  `parity_group` is unmatched without a `CODEX-NATIVE` note; add
  `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` pinning byte identity of the
  cross-tree helpers confirmed identical by hash at Phase 0, following
  `codex-batch-budget-route-parity.Tests.ps1`. Any production module the gate needs is placed in
  child 1's `scripts/harness/`.
- **Phase 2, Codex SubagentStop validators (ADD).** Codex twins and validators listed under
  Behavior; `[[hooks.SubagentStop]]` registrations with matchers that admit generated agent
  variants; bundle copies; core manifest entries; behavior suites under `tests/scripts/codex-hooks/`
  mirroring the decision cases of the Claude suites. The `validate-required-artifact-output.ps1`
  registrations carry the D-16 expanded pattern.
- **Phase 3, Codex PreToolUse (ADD).** Codex `enforce-feature-folder-order.ps1`.
- **Phase 4, conditional (ADD-CONDITIONAL).** Executed only for items with a recorded positive
  Phase 0 (e) result; the preimplementation-gate item is a `config.toml` registration change only.
  Otherwise recorded as `DEFER`.
- **Phase 5, Copilot and no-Python.** Copilot dispositions; extend the scan roots in
  `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` and
  `enforcement-hooks-no-python-invocation.Tests.ps1` to `.github/hooks`.
- No dependency changes. No logging or telemetry changes beyond the hooks' existing patterns.
- Rollout: Codex hooks take effect in Codex sessions on trusted projects after merge and in
  destination repositories after the next push-down.

## Acceptance Criteria

- [ ] Phase 0 evidence exists under `<FEATURE>/evidence/baseline/` recording checks (a) to (f) of `## Execution-Time Gating` against `origin/main`, each with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, and any mismatch on (a) to (d) or (f) resulted in a plan revision before implementation began.
- [ ] Every hook registration enumerated by child 1's inventory module at execution time from `.claude/settings.json`, `.claude/agents/*.md` frontmatter, `.codex/config.toml` and `.github/hooks/*.json` has exactly one matrix entry with `disposition: native`, a `parity_group` and a `decision_ref` to the child 5 disposition record; `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [ ] Shared function (restated per OQ-1): every Claude `hook-registration` `parity_group` either has a Codex member or carries a gap class with its reason, and every Codex `parity_group` without a Claude member carries a `CODEX-NATIVE` note; `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` passes on the committed matrix.
- [ ] `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` includes in-memory negative cases proving the gate fails for a Claude group with no Codex member and no gap class, and for an unmatched Codex group with no `CODEX-NATIVE` note.
- [ ] Each `ADD` port delivered (Codex SubagentStop validators and `enforce-feature-folder-order.ps1`) has a root file under `.codex/hooks`, a byte-identical bundle copy, a registration in `.codex/config.toml` (root and bundle), a Codex core pack-manifest entry, and a behavior suite under `tests/scripts/codex-hooks/` that runs the same decision cases as the corresponding Claude suite on equivalent Codex payloads.
- [ ] Each delivered Codex SubagentStop validator honors `stop_hook_active` with one continuation, verified by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` and its behavior suite.
- [ ] Codex `enforce-feature-folder-order.ps1` resolves the docs root through child 2's resolver (published path first, self-hosted second), verified by its behavior suite.
- [ ] Codex twins of `subagentstop-envelope.ps1` and `premortem-section.ps1` keep every function definition text-identical to the Claude source, and the cross-tree helper set confirmed identical at Phase 0 is pinned byte-identical, verified by `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` and the twin identity rows.
- [ ] Every `validate-required-artifact-output.ps1` registration added to `.codex/config.toml` carries the D-16 expanded pattern and is covered either by child 2's write-scope checker or by a Pester assertion against the same rule table, per the Phase 0 (d) result (OQ-10).
- [ ] Each `ADD-CONDITIONAL` item is either delivered with a recorded positive Phase 0 (e) result and a behavior suite, or recorded in the matrix with a `DEFER` gap class and reason; the execution plan contains no owner wait.
- [ ] `enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `enforce-pr-author-skill` and every `validate-orchestrator-output` registration form carry a `DEFER` gap class naming the blocking dependency, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [ ] Every Copilot `hook-registration` entry from `.github/hooks/*.json` has `disposition: native` and `owner_child: 6`, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [ ] No enforcement hook invokes Python: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks`, `.claude/lib`, `.codex/hooks` and `.github/hooks`, and passes.
- [ ] Bundled mirrors and pack manifests are green: `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` and `test_codex_core_manifest_closure.py` pass.
- [ ] The branch diff against the merge base contains no edit to the hook scripts named in the parallel run `bugs-1001-1002-1003-1006` manifest, and no edit to any Codex hook file whose physical line count at Phase 0 is 490 or more.
- [ ] The branch diff contains no direct edit to `.claude/agents/*.md` frontmatter `hooks:` or to the `hooks` section of `.claude/settings.json`; any generator-owned region is changed through child 3's generator source, and child 3's generator `--check` passes.
- [ ] No new Python or TypeScript file is added; every new hook and test file is PowerShell, and every new `.codex/config.toml` hook command invokes `pwsh`.
- [ ] Each new or changed Codex hook file reaches at least 85% line coverage in `artifacts/pester/powershell-coverage.xml`, recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head, including the new suites under `tests/scripts/codex-hooks/`.

## Open Owner Questions

The recommended defaults below are the working assumption for this spec. This spec does not
decide beyond them; an owner answer that differs from a default is applied through the Phase 0
plan revision.

| ID | Question | Working default |
| --- | --- | --- |
| OQ-1 | Hooks with equivalent function: keep `native` with a common `parity_group` (child 1 semantics), rather than `shared`? | Yes; the issue's "shared" criterion is restated as a `parity_group` with members in more than one ecosystem |
| OQ-2 | Record expressibility gaps as a structured optional matrix field (child 1 minor schema bump) or as a `notes` prefix? | Structured field if child 1 has not merged when planned; otherwise a `notes` prefix checked by the hook-parity gate |
| OQ-3 | Codex ports that need `.claude/lib` modules (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `validate-orchestrator-output`, `enforce-pr-author-skill`): defer until child 4 decides `.codex/lib` publication, or twin the modules under `.codex/hooks`? | Defer; publication belongs to child 4 |
| OQ-4 | Codex `validate-bash.ps1` omits the cd-chained read leg by design while the execution-environment brief names the function for both paths. Add the leg to Codex, or correct the brief? | Correct the brief text (all copies); keep the Codex omission unless a Codex prompt-approval problem is shown |
| OQ-5 | Feature-review coverage hooks read only root `CLAUDE.md`. In a Codex-only destination, should they also read `AGENTS.md`? | Yes for the Codex hook, after child 3 settles `AGENTS.md` content; otherwise unchanged |
| OQ-6 | Copilot is documented as reading `.claude/settings.json` hooks. Are Claude hooks expected to run in Copilot sessions, or must child 6 prevent it? | Child 1 experiment and child 6 decision; child 5 records only |
| OQ-7 | Enable Codex SubagentStop validators only after child 3 generates both agent bodies from one definition? | Yes; verified at Phase 0 (c) |
| OQ-8 | Is a Codex counterpart of `enforce-pr-author-skill` wanted, given Codex PR authoring uses its own receipts? | Not in child 5; record `DEFER` |
| OQ-9 | Keep duplicate SubagentStop registrations in both `.claude/settings.json` and agent frontmatter, or drop one copy? | Keep until child 1 experiment E5 shows whether both fire; any drop needs an owner decision |
| OQ-10 | Should child 2's D-16 checker cover `-RequiredArtifact` arguments in `.codex/config.toml`, or does child 5 add a Pester assertion against the same rule table? | Extend child 2's checker if it has not merged; otherwise a Pester assertion |

## Non-Goals

- Re-opening the settled design (hooks native, parity of function; no single-source generated hook
  body).
- Porting the deferred hooks (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`,
  `validate-orchestrator-output`, `enforce-pr-author-skill`) or the `ADD-CONDITIONAL` items without
  a recorded positive Phase 0 result.
- Push-down publication of `.claude/lib` modules to `.codex/lib` (child 4).
- Finalizing the thin Copilot layer, Copilot hook changes or Copilot collision controls (child 6).
- Edits to files or branches of the parallel run `bugs-1001-1002-1003-1006`, and edits to the hook
  scripts in its blast radius.
- Adding Claude hooks for Codex-native functions (root epic authorization, model/profile
  attestation, planning-only boundary, child worktree binding).
- Changing recorded logic divergences (cd-chained leg, payload-anomaly path) without an owner
  decision.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or gates
- [ ] Behavior matches acceptance criteria on Windows and in the Linux hook-suite job
- [ ] Tests added: hook-parity gate, cross-tree helper identity, one Codex behavior suite per port
- [ ] Edge cases and error handling covered: malformed payload fails closed, benign payload allowed for every admitted tool name, `stop_hook_active` loop stop
- [ ] Test isolation verified with seeded shuffled file-order runs of `tests/scripts/codex-hooks` and the touched harness suites plus one fresh single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`
- [ ] Docs updated: child 5 disposition record; execution-environment brief only if OQ-4 is answered
- [ ] Toolchain pass completed (format, lint, architecture, unit, contract, integration)
