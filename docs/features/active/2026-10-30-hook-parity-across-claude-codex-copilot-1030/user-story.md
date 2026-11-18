# `hook-parity-across-claude-codex-copilot` — User Story

- Issue: #1030
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-18
- Version: 0.4
- Spec: `spec.md` (this feature folder)

## Story Statement

- As a repository maintainer, I want every hook registration in Claude Code, Codex and GitHub
  Copilot, including every entry of the two PreToolUse dispatch registries, to carry a parity-matrix
  disposition and a parity group, with a recorded gap class and reason wherever a Claude gate has no
  Codex counterpart, so that a missing gate in one ecosystem is detected by a test rather than
  discovered after a workflow runs unguarded.
- As a destination-repository operator using Codex, I want the pr-author output validator to run as
  a Codex hook with the same decisions on the same inputs, so that Codex sessions are held to the
  same pr-author completion rules as Claude sessions. The feature-folder order gate is deferred
  (spec AD-8) until child 4 publishes the development-docs module it needs, and the matrix records
  that gap.
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
not match; Codex gains a hook only where its hook system can express the behavior. Registration
shape for PreToolUse (one dispatcher per runtime) is already aligned by #1159, so this feature
covers function parity only.

## Personas & Scenarios

- Persona: repository maintainer
  - Maintains the Claude, Codex and Copilot runtime surfaces and their bundled mirrors.
  - Cares about detectable drift, deterministic gates and not editing files owned by other epic
    children.
  - Constraint: new pushed-down code must be PowerShell or bash; enforcement hooks must not invoke
    Python.
- Persona: destination-repository operator using Codex
  - Runs Codex in a repository that received the Codex pack through push-down.
  - Cares that pr-author output is validated before the subagent stops, and that plan writes are
    blocked until prerequisite feature documents exist; the second gate is deferred in Codex and
    recorded as a gap.
  - Constraint: the destination does not receive `.claude/lib`; Codex hooks must be self-contained
    or use published `.codex/lib` modules, which is why lib-dependent validators and the
    feature-folder order gate are deferred.
- Scenario: maintainer detects a gap
  - The maintainer adds a new Claude hook to `.claude/hooks/pretooluse-dispatch.json` in a later
    change.
  - Child 1's inventory enumerates it; the hook-parity gate finds its `parity_group` has no Codex
    member and no gap class, and fails.
  - The maintainer either adds a Codex counterpart or records the gap class and reason; the gate
    passes.
- Scenario: Codex pr-author output names no pull request
  - The operator delegates PR authoring to the Codex pr-author agent, which stops with a message
    that contains no PR URL or PR number.
  - The Codex SubagentStop validator blocks the stop with a `PR_AUTHOR_OUTPUT_NO_PR` reason; the
    agent continues once; a second stop with `stop_hook_active` set is allowed.

## Acceptance Criteria

- [x] Every hook registration enumerated by child 1's inventory module at execution time, including the entries of `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json`, has exactly one matrix entry with `disposition: native`, a `parity_group` and a `decision_ref`, and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [ ] Every Claude hook `parity_group` has a Codex member or a recorded gap class with reason, and `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` passes, including its negative cases.
- [x] Codex `validate-pr-author-output.ps1` has a behavior suite under `tests/scripts/codex-hooks/` running the same decision cases as the corresponding Claude suite on equivalent Codex payloads, and the validator allows a stop when `stop_hook_active` is set.
- [ ] The Codex `enforce-feature-folder-order` port is deferred (spec AD-8): no `.codex/hooks/enforce-feature-folder-order.ps1` file and no Codex dispatch-registry or `.codex/config.toml` entry for it is added (root and bundle), and the Claude `hook:enforce-feature-folder-order` entry carries a `GAP:DEFER: ` note naming `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` and child 4, verified by `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1`.
- [ ] The matrix records the five worktree-resolution-dependent SubagentStop validators, `enforce-feature-folder-order`, `enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `enforce-pr-author-skill`, `validate-orchestrator-output` and the pr-author Bash allowlist as `DEFER`, and the Codex preimplementation-gate delegation registration as `NOT-EXPRESSIBLE` naming issue #555, each with its reason.
- [ ] Copilot hook registrations have `disposition: native` and `owner_child: 6`.
- [ ] `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.github/hooks` in addition to its existing roots and passes.
- [ ] Bundled mirrors, pack manifests and their contract tests listed in the spec pass.
- [ ] No edit is made to Codex hook files at 490 or more physical lines at Phase 0.
- [ ] The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head.

## Non-Goals

- Re-opening the settled design for hooks (native, parity of function).
- PreToolUse registration-shape parity (delivered by #1159).
- Porting the deferred hooks (including `enforce-feature-folder-order`) or publishing `.claude/lib` modules to `.codex/lib` (child 4).
- Finalizing the thin Copilot layer (child 6).
