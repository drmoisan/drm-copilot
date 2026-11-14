# `2026-11-09-hook-dispatcher-process-cost` — User Story

- Issue: #1159
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T21-47
- Spec: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/spec.md`

## Story Statement

- As a repository operator running several concurrent Claude Code and Codex agents, I want each tool call to start a single hook dispatcher process instead of one PowerShell process per hook, so that hook start-up no longer keeps machine load high when no tests are running.
- As a maintainer of the enforcement hook layer, I want a parity suite and before/after cost evidence, so that I can confirm the consolidation changed process cost and nothing else.
- As an owner of a destination repository that receives the push-down payload, I want the dispatcher, its registry and its registration delivered together with an isolation setting that defaults to today's per-process behavior, so that the change is consistent and revertible with one data edit.

## Problem / Why

Every PreToolUse tool call starts one `pwsh -NoProfile -File` process per matching hook registration, and each process uses roughly a third to half of a core for about a second. On 2026-11-09 a main-session Claude `Bash` call started 12 such processes and a Codex `apply_patch` call 15 (observed context; these figures change as sibling issues add hooks). With about ten agents active, hook start-up alone kept machine load high. The hooks' decisions are correct; the cost is in starting a process per hook.

## Personas & Scenarios

- Persona: Repository operator
  - Runs ten or more agents in parallel on one Windows workstation.
  - Cares about machine responsiveness and throughput of agent work.
  - Constrained by a fixed number of cores shared by agents, test runs and hooks.
  - Frustrated that idle-looking agents still load the machine through hook start-up.
  - Motivated to keep every enforcement gate active while cutting its overhead.
- Persona: Hook-layer maintainer
  - Owns the PreToolUse gates and their deny codes.
  - Cares that no gate stops enforcing, changes its reason text, or fails open after a refactor.
  - Constrained by the rule that each enforcement hook has one implementation, and by parallel-only test gates.
  - Wants proof by test, not by inspection.
- Persona: Destination repository owner
  - Receives `.claude` and `.codex` customizations through the push-down payload.
  - Cares that registrations, hook files, registries and documentation arrive consistent.
  - Wants a one-line revert if the in-process dispatcher misbehaves in their environment.
- Scenario: Operator measures the change
  - The operator runs `scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Registration` after merging `origin/main` and before the registration change, and later `-Source Dispatcher` on the same payloads.
  - The before report shows a per-call process count equal to the number of hooks registered for each tool name; the after report shows one dispatcher process per call, with summed CPU seconds and wall time for both.
  - The operator compares the two reports quoted in the pull request.
- Scenario: Agent issues a denied `Bash` command
  - An agent issues a `Bash` call that one gate denies.
  - The single dispatcher process reads the payload once, runs every hook registered for `Bash` in its own script scope, and emits one deny whose reason contains the same deny code and text the gate produced as a separate process.
  - Hooks that record state on every call (the batch-budget hooks on writes) still run, because the dispatcher does not stop at the first deny.
- Scenario: Dispatcher cannot read its registry
  - The registry file is missing or invalid.
  - The dispatcher denies the call with a `HOOK_DISPATCH_BLOCKED:` reason instead of letting every gate fail open.
- Scenario: Destination owner reverts isolation
  - The owner removes the `isolation` field (or sets it to `per-process`) in the registry.
  - The dispatcher runs each hook as its own process again, reproducing today's isolation, with no code change.

## Acceptance Criteria

- [x] A repeatable measurement tool reports, per runtime and per representative payload, the hook process count per call, summed CPU seconds and wall time, and before and after reports are stored append-only under the feature folder's `evidence/baseline/` and `evidence/regression-testing/`.
- [x] The before report's process count per call equals the number of hooks registered for that tool name in the registrations derived after merging `origin/main`; the after report shows one dispatcher process per call for every scenario.
- [x] Claude Code (`.claude/settings.json`) and Codex (`.codex/config.toml`) each register a single PreToolUse dispatcher entry whose matcher admits every tool name admitted by the groups in that runtime's registry, and the registry reproduces the derived groups in their original order.
- [x] The dispatcher reads the payload once, runs every selected hook in the same process in its own script scope without stopping at the first deny, and the dispatched Claude hooks load each shared module once per call except for modules recorded as stateful.
- [x] A parity suite that enumerates hooks from settings, config and registry data at test time shows identical per-hook exit codes, decisions and reason text, and identical combined decisions, deny codes and `additionalContext`, between per-hook processes and the dispatcher on both runtimes; the existing per-hook suites pass unchanged.
- [x] Combined decisions follow the precedence `deny` > `defer` > `ask` > `allow` > none, with every deny reason preserved in registry order.
- [x] When the registry `isolation` field is absent, each hook runs as its own process as it does today; the shipped registries set `in-process`.
- [x] A dispatcher self-failure denies the call with a `HOOK_DISPATCH_BLOCKED:` reason (or exits 2 with stderr when its own guard cannot load) instead of failing open.
- [x] The Python-invocation guard admits only the dispatcher runner's single registry-resolved `&` call, with fixtures proving every other dynamic `&` call is still reported.
- [x] The pull request reports before and after process count, CPU seconds and wall time, and states any scenario whose wall time increased.
- [x] Bundle settings and config, bundle mirrors of every new or edited hook file, both pack manifests, `README.md`, `docs/engineering/claude-code-architecture.md` and every copy of the execution-environment brief are updated consistently, and the push-down contract tests pass.

## Non-Goals

- Changing any hook's decision logic, deny codes or reason text.
- Fixing the suspected fail-open in hooks whose tail is `exit (Invoke-...EntryPoint)`; it is recorded in the baseline and handled as a separate, explicitly stated change (D13).
- Folding agent-frontmatter PreToolUse hooks (the `pr-author` command allowlist) into the dispatcher.
- Consolidating SessionStart, SubagentStart, SubagentStop, UserPromptSubmit or Codex non-PreToolUse hooks.
- A bash front filter or any second implementation of a hook's scope test.
- Reducing hook-internal child processes such as `git` and `gh`.
- Ordering this item's execution or merge behind any other open item; the item is merge-order independent and integrates PreToolUse changes that reach `origin/main` in one pre-merge pass (spec D15).
