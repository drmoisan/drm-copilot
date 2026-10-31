# `hook-parity-across-claude-codex-copilot` — User Story

- Issue: #1030
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Spec: `spec.md` (this feature folder)

## Story Statement

- As a repository maintainer, I want every hook registration in Claude Code, Codex and GitHub
  Copilot to carry a parity-matrix disposition and a parity group, with a recorded reason wherever a
  Claude gate has no Codex counterpart, so that a missing gate in one ecosystem is detected by a
  test rather than discovered after a workflow runs unguarded.
- As a destination-repository operator using Codex, I want the Claude output validators and the
  feature-folder order gate that Codex can express to run as Codex hooks with the same decisions on
  the same inputs, so that Codex sessions are held to the same completion and ordering rules as
  Claude sessions.
- As a repository maintainer, I want enforcement hooks in every ecosystem to run without Python and
  the bundled mirrors to stay byte-identical, so that pushed-down hooks behave the same in
  destination repositories as in this one.

## Problem / Why

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`), Codex (`.codex/hooks`) and GitHub Copilot (`.github/hooks`). The sets were built
separately and drifted. No record states, for each hook registration, whether its function has an
equivalent in another ecosystem or why it does not, so a missing gate in one ecosystem is not
detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hooks stay native; hook counts need
not match; Codex gains a hook only where its hook system can express the behavior.

## Personas & Scenarios

- Persona: repository maintainer
  - Maintains the Claude, Codex and Copilot runtime surfaces and their bundled mirrors.
  - Cares about detectable drift, deterministic gates and not editing files owned by other epic
    children or by the in-flight parallel run.
  - Constraint: new pushed-down code must be PowerShell or bash; enforcement hooks must not invoke
    Python.
- Persona: destination-repository operator using Codex
  - Runs Codex in a repository that received the Codex pack through push-down.
  - Cares that planner, executor, researcher, prd-feature, pr-author and required-artifact outputs
    are validated before a subagent stops, and that plan writes are blocked until prerequisite
    feature documents exist.
  - Constraint: the destination does not receive `.claude/lib`; Codex hooks must be self-contained
    or use published `.codex/lib` modules.
- Scenario: maintainer detects a gap
  - The maintainer adds a new Claude PreToolUse registration in a later change.
  - Child 1's inventory enumerates it; the hook-parity gate finds its `parity_group` has no Codex
    member and no gap class, and fails.
  - The maintainer either adds a Codex counterpart or records the gap class and reason; the gate
    passes.
- Scenario: Codex planner output is incomplete
  - The operator delegates planning to the Codex atomic planner, which stops without a Pre-Mortem
    section.
  - The Codex SubagentStop validator blocks the stop with a reason; the planner continues once and
    produces the missing section; a second stop with `stop_hook_active` set is allowed.

## Acceptance Criteria

- [ ] Every hook registration enumerated by child 1's inventory module at execution time has exactly one matrix entry with `disposition: native`, a `parity_group` and a `decision_ref`, and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [ ] Every Claude hook `parity_group` has a Codex member or a recorded gap class with reason, and `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` passes, including its negative cases.
- [ ] Each delivered Codex port has a behavior suite under `tests/scripts/codex-hooks/` running the same decision cases as the corresponding Claude suite on equivalent Codex payloads, and each Codex SubagentStop validator stops repeated continuation when `stop_hook_active` is set.
- [ ] Items that depend on unverified Codex payload fields are delivered only with a recorded positive Phase 0 result; otherwise they carry a `DEFER` gap class and reason, with no owner wait during execution.
- [ ] Lib-dependent gates (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `enforce-pr-author-skill`, `validate-orchestrator-output`) are recorded as `DEFER` with their blocking dependency.
- [ ] Copilot hook registrations have `disposition: native` and `owner_child: 6`.
- [ ] `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.github/hooks` in addition to its existing roots and passes.
- [ ] Bundled mirrors, pack manifests and their contract tests listed in the spec pass.
- [ ] No edit is made to hook scripts in the parallel run's blast radius or to Codex hook files at 490 or more lines at Phase 0.
- [ ] The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head.

## Non-Goals

- Re-opening the settled design for hooks (native, parity of function).
- Porting the deferred hooks or publishing `.claude/lib` modules to `.codex/lib` (child 4).
- Finalizing the thin Copilot layer (child 6).
- Edits to files or branches of the parallel run `bugs-1001-1002-1003-1006`.
