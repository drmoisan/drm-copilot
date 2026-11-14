# 2026-11-09-hook-dispatcher-process-cost — Spec

- **Issue:** #1159
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-47
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-feature
- **Requirements source:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/issue.md` (authoritative scope; not reduced here)
- **Research:** `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/research/research.2026-11-09T21-47.md`

## Overview

Every PreToolUse tool call in Claude Code and in Codex starts one `pwsh -NoProfile -File` process per matching hook registration, and each process pays the full PowerShell 7 start-up cost. With about ten agents active, hook start-up alone kept machine load high when no tests were running.

This feature replaces the per-hook process fan-out with one in-process PowerShell dispatcher per runtime. The dispatcher is registered once per runtime under a single PreToolUse matcher, reads the payload once, selects the hook groups whose matcher admits the tool name, runs every selected hook script unchanged in its own script scope inside the same process, and emits one combined decision by the runtime's documented precedence. A repeatable measurement tool records process count, CPU seconds and wall time before and after the change, and a parity suite proves that per-hook decisions, deny codes and reason text are unchanged.

- Target users/personas and primary use cases: repository operators running several concurrent Claude Code or Codex agents; maintainers of the enforcement hook layer; destination repositories that receive the push-down payload.
- Success metrics or expected impact: the PreToolUse hook process count per tool call becomes one dispatcher process for every tool name, against the per-call count derived from the registrations at execution time; summed CPU seconds per call fall accordingly; decisions and deny codes are unchanged.

Context (observed on 2026-11-09, research section 2; not an acceptance target): a main-session Claude `Bash` call started 12 hook processes and a `Write` or `Edit` call 13; a Codex `Bash` call started 12 and an `apply_patch` call 15. These figures change whenever other items add or change PreToolUse hooks on `main`, which is why no acceptance criterion asserts them.

## Merge-Order Independence

- This item runs concurrently with every other open item and does not wait for, or assume, the merge state of any of them (D15).
- The first execution step merges `origin/main` into the feature branch and re-derives the PreToolUse hook inventory from the registrations in `.claude/settings.json` and `.codex/config.toml` as they exist at that point. The dispatcher registries are generated from that inventory (D10).
- Before the final QA gates, an integration pass merges `origin/main` again, re-derives the inventory, and moves every PreToolUse hook added, removed, reordered or changed in the meantime into the registries by the same rule, restoring the single dispatcher registration per runtime (D15). The pass is correct whether zero or many changes arrived.
- The registries, the measurement tool and the parity suite enumerate hooks from settings and config data (and from the registries derived from them) at run or test time. No hook list, hook count or hook name set is frozen in this spec, in the plan, or in any test.
- Any count named in this spec as "observed on 2026-11-09" is context only.

## Behavior

### Main flow (happy path)

1. The runtime fires PreToolUse for a tool call. The single dispatcher registration matches every tool name that any registry group matcher admits.
2. The dispatcher reads the payload once: the Claude dispatcher through `Read-ClaudeHookRawPayload` (stdin, then the existing environment fallback); the Codex dispatcher through `[Console]::In.ReadToEnd()` with no fallback. It writes no environment variable (D3).
3. It reads its runtime's registry, evaluates each group matcher against `tool_name` using that runtime's matcher semantics (Claude: exact string or exact list, otherwise unanchored JavaScript-style regex; Codex: regex as written, including the `apply_patch` to `Edit`/`Write` alias), and collects the selected hooks in registry order.
4. For each selected hook it replays the payload with `[Console]::SetIn`, records and later restores the current location, sets `$LASTEXITCODE` to a sentinel, redirects `[Console]::SetError` and `[Console]::SetOut` to per-hook writers, invokes the script with `&` in its own script scope, and captures stdout (the per-hook `[Console]::Out` writer text, which carries decisions written with `[Console]::Out.WriteLine`, followed by the success, warning and information streams), stderr (the per-hook error writer) and the exit code (D2). A hook that ends without `exit` leaves the sentinel unchanged and maps to exit code 0.
5. It never stops at the first deny; every selected hook runs (D5).
6. It normalizes each per-hook result (exit 2 is a deny with the stderr reason or the JSON blocking reason; exit 0 with a JSON `permissionDecision` is that decision; exit 0 with empty stdout is no decision; any other exit code or invalid JSON is a non-blocking error and no decision) and combines them by precedence `deny` > `defer` > `ask` > `allow` > none (D4).
7. It emits one combined JSON decision at exit 0, with every deny reason in registry order separated by a line feed and every `additionalContext` value concatenated in registry order. When the strongest decision is `allow`, it emits `allow`.

### Alternate and edge flows

- No group matches the tool name: the dispatcher emits nothing and exits 0 (no decision), as today when no hook matches.
- Registry `isolation` field absent: each selected hook runs as its own `pwsh -NoProfile -File` child with the payload on stdin, which reproduces today's per-process isolation; results are combined identically (D14).
- Registry `isolation` set to `in-process`: the in-process runner in step 4 is used. The shipped registries set this value explicitly.
- A hook that ends without `exit`: detected through the `$LASTEXITCODE` sentinel and treated as exit 0.
- Agent-frontmatter PreToolUse hooks (the `pr-author` agent's command allowlist) remain separate registrations and are not dispatched (D11).

### Error handling and recovery

- A terminating error inside one hook is caught and treated as that hook's non-blocking error, which preserves today's per-hook fail-open outcome.
- A failure of the dispatcher itself (registry missing, unreadable or schema-invalid; a registry hook path that does not resolve; a bootstrap failure) is fail-closed: a deny whose reason starts with `HOOK_DISPATCH_BLOCKED:`. If the dispatcher cannot load `hook-dependency-guard.ps1`, it writes the reason to stderr and exits 2, following the existing guard bootstrap pattern (D8).
- Process-global state changed per hook (`[Console]::SetIn`, error writer, output writer, location) is restored in `finally` blocks.
- Revert path: setting `isolation` to `per-process` (or removing the field) in a registry restores per-process hook isolation with one data edit and no code change.

## Inputs / Outputs

- Inputs: the PreToolUse JSON payload on stdin; `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` (registries); the hook scripts named in each registry.
- Outputs: one combined PreToolUse decision per call (compact JSON at exit 0, or exit 2 with stderr on dispatcher guard failure); a test-only `-PerHookTrace` switch on each dispatcher entry that writes per-hook results as JSON to stderr for the parity suite.
- Measurement outputs: a Markdown cost report carrying `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` lines, written to the feature folder's `evidence/baseline/` (before) and `evidence/regression-testing/` (after).
- Config keys and defaults:
  - Registry `isolation`: `in-process` or `per-process`; absent means `per-process` (today's behavior). The shipped registries set `in-process`.
  - Claude dispatcher registration: no `timeout` key (the runtime default applies, as for every PreToolUse entry today).
  - Codex dispatcher registration: `timeout` equal to the sum of the member hooks' timeouts in the derived inventory.
- Versioning and compatibility: the registry schema reuses the settings PreToolUse shape `{matcher, hooks: [{type, command}]}` plus a top-level `isolation` field, so existing command parsers (including the pack-manifest dependency scanner) read it unchanged. Hook script entry and tail shapes are unchanged.

## API / CLI Surface

- `pwsh -NoProfile -File .claude/hooks/invoke-pretooluse-dispatch.ps1` — the single Claude PreToolUse registration in `.claude/settings.json`.
- `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/invoke-pretooluse-dispatch.ps1"` — the single Codex PreToolUse registration in `.codex/config.toml` (`command` and `command_windows`).
- `scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Registration|Dispatcher` — measurement entry; `-Source Registration` derives the scenario from the settings and config PreToolUse groups (before), `-Source Dispatcher` from the dispatcher registration and registries (after). Representative payloads per runtime: a `Bash` call, a `Write` (Claude) or `apply_patch` (Codex) call to a docs path, an `Agent` spawn call, and one `mcp__drm-copilot__*` call.
- Contracts and validation rules:
  - Each runtime registers exactly one PreToolUse dispatcher entry, whose matcher admits the union of the registry group matchers.
  - Every registry hook command resolves to an existing `.ps1` file in that runtime's hooks folder whose file name matches `^[a-z0-9][a-z0-9.-]*\.ps1$`.

## Data & State

- Registry generation: group order and hook order are copied verbatim from the merged `origin/main` PreToolUse blocks at execution start and again at the pre-merge integration pass (D10, D15).
- Invariants: the dispatcher's process exit code is 0 whenever it emits a decision; deny reasons keep registry order; no hook is skipped; no environment variable is written.
- Side effects preserved: hooks that record state on every call (the batch-budget hooks write their `.claude/state` budget files) still run when another hook denies.
- Module loading: guarded `Import-Module` statements in the dispatched Claude hooks lose `-Force` so a shared module loads once per call, except where a module audit finds mutable module-scope state (D6).
- No migration or backfill. Destination repositories receive the new files and registrations through the push-down payload.

## Decisions

Adopted by the orchestrator from research section 10.

- **D1. One dispatcher per runtime, registered once with the union matcher.** Claude: `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*` (or the union of the groups derived at execution time). Codex: the anchored union of its group matchers. Rationale: one pwsh process per PreToolUse call regardless of how many groups match; per-group dispatchers would still start several processes per `Bash` call.
- **D2. Run each selected hook script unchanged with `& <script>` in its own script scope**, after `[Console]::SetIn` replay, capturing streams, the `[Console]::Out` and `[Console]::Error` writers (redirected per hook with `[Console]::SetOut` and `[Console]::SetError`) and `$LASTEXITCODE`. Rationale: no re-implementation of the differing hook tails, isolated script scope (no function-name collisions, no shared `$script:HookDependencyFailures`, no leaked strict mode), and parity by construction.
- **D3. Read the payload once.** Claude reads through `Read-ClaudeHookRawPayload`; Codex reads `[Console]::In.ReadToEnd()`. No environment variable is written. Rationale: preserves each runtime's transport and satisfies `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`.
- **D4. Combine by documented precedence** `deny` > `defer` > `ask` > `allow` > none. Join every deny reason in registry order separated by a line feed so every deny code token remains visible; concatenate `additionalContext` values; emit `allow` when it is the strongest decision; map exit 2 to deny with the stderr reason and other exit codes or invalid JSON to no decision. Codex uses the same rule with JSON deny output. Rationale: reproduces Claude's documented combination and today's per-hook fail-open.
- **D5. Never short-circuit; run every selected hook.** Rationale: the batch-budget hooks record state on calls that another hook denies.
- **D6. Remove `-Force` from guarded `Import-Module` statements** of the dispatched Claude hooks and the sibling helpers they dot-source, after auditing each imported `.psm1` (enumerated by `Get-HookScriptEdge`) for mutable module-scope state; a stateful module keeps `-Force`, documented in the registry notes. Rationale: issue AC 2 requires shared modules to load once per call. Codex hooks dot-source `.ps1` helpers and import no modules, so for Codex the requirement is met by the single process.
- **D7. Timeouts.** The Claude dispatcher keeps the runtime default (no `timeout` key). The Codex dispatcher sets `timeout` to the sum of its members' timeouts. Rationale: avoids a fail-open caused by a combined budget shorter than today's per-hook budgets.
- **D8. Dispatcher self-failure is fail-closed** (`HOOK_DISPATCH_BLOCKED:` deny; exit 2 with stderr if its own guard cannot load). A per-hook failure keeps today's per-hook outcome. The dispatcher follows the `hook-dependency-guard.ps1` bootstrap pattern so the dependency-guard completeness rules apply to it. Rationale: a broken dispatcher must not silently disable every gate.
- **D9. Narrow carve-out (c) in `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` — adopted.** The carve-out is not an allowlist entry. It admits only the dispatcher runner's single `&` call whose target is resolved through the registry to a hooks-folder `.ps1` sibling (file name `^[a-z0-9][a-z0-9.-]*\.ps1$`, existence verified). Fixtures keep every other dynamic `&` call reported as `DynamicInvocation`. Fallback (a') — a uniform `Invoke-HookScriptMain` function per hook loaded without a dynamic `&` call — is recorded as not selected. Rationale: the carve-out is the smallest policy-oracle change that permits D2; (a') would move every hook tail and its bundle mirror and collide with the tail-shape rules of `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- **D10. Generate the registry at execution time** from the PreToolUse blocks of the `origin/main` settings and config merged at execution start, and regenerate it by the same rule at the pre-merge integration pass (D15), preserving group order and hook order. The registry schema reuses the settings shape `{matcher, hooks: [{type, command}]}`. Rationale: other items add or change hooks at any time; a frozen list would drop or misorder them.
- **D11. Agent-frontmatter PreToolUse hooks (`pr-author`) stay separate registrations.** Rationale: folding them into the global dispatcher would change their lifetime scoping.
- **D12. SessionStart, SubagentStart, SubagentStop, UserPromptSubmit and Codex non-PreToolUse events are out of scope.** Rationale: they fire per session, prompt or subagent, orders of magnitude less often than PreToolUse, and are outside the issue's problem statement.
- **D13. Family (D) tails (`exit (Invoke-...EntryPoint)`) are reproduced as-is by D2.** The Phase 0 baseline records their real process output. If they emit no JSON (suspected fail-open), the finding is reported to the orchestrator under the related-findings rule and fixed only as a separate, explicitly stated change with its own before/after evidence, not as part of the parity claim. Rationale: the parity claim must compare like with like.
- **D14. Isolation knob.** A registry field `isolation` with values `in-process` and `per-process`. An absent field means `per-process`: each hook runs as its own `pwsh -NoProfile -File` child with the payload on stdin, matching today's isolation. The shipped registries set `in-process` explicitly. Rationale: a destination registry without the field keeps today's isolation, the operator can revert with one data edit, and the shipped setting meets issue AC 2.
- **D15. Merge-order independence and the pre-merge integration pass (owner directive OD-2026-11-09-max-parallel) — adopted.** The item executes concurrently with every other open item; no step waits for, or assumes, any other item's merge state. Execution starts by merging `origin/main` (D10). In the final phase, before the QA gates, one integration pass merges `origin/main` again, re-derives the PreToolUse inventory from `.claude/settings.json` and `.codex/config.toml`, moves every hook added, removed, reordered or changed in the meantime (including a PreToolUse registration the merge placed beside the dispatcher registration) into the registries by the D10 rule, restores the single dispatcher registration per runtime, applies the D6 and D13 audits to every arrived hook and to every dispatched hook, dot-sourced helper or imported module whose content the merge changed, keeps the bundle mirrors, pack manifests and the Codex timeout sum consistent, gives each arrived registry hook parity envelopes to the corpus standard or records why none is possible, and records the result in the feature's `evidence/other/` folder. Acceptance: every hook registered on the merged origin/main is dispatched and passes parity, proven by the parity suite in the final gate and an inventory showing zero PreToolUse registrations outside the dispatcher (agent-frontmatter hooks excluded per D11). The owner accepts at most one such pass. Rationale: maximum parallelism, at the cost of one integration pass and of the registration rule for later items stated under Risks.

Rejected alternatives (research section 5): a bash front filter and a filter-plus-dispatcher hybrid (a second implementation of each hook's scope test that would drift, contrary to the one-implementation rule for enforcement hooks); dot-sourcing every hook into one shared scope; passing the payload through `CLAUDE_HOOK_INPUT`; per-group dispatchers.

## Constraints & Risks

### Constraints

- Pushed-down code is PowerShell or bash. No new Python is added. Enforcement hooks contain no Python invocation. Existing Python contract tests are edited only where they pin the registration shape.
- Pure logic (matcher evaluation, result normalization, combination, registry validation, cost summary and report formatting) lives in host-neutral modules with injected seams: a `[scriptblock]` script invoker, a stdin replayer, a process starter, a clock or timestamp provider, and filesystem readers. Entry scripts are thin wiring.
- Tests create no temporary files and use no wall-clock waits (`Start-Sleep`, real timers). Process-global console and location changes in tests are restored in `finally`.
- Test gates run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, plus `Invoke-PoshQCLeakScan`. No serial, single-process, shuffled or reversed runs.
- Test order dependence is a defect to be fixed in both the leaking and the affected test, not worked around by ordering or sharding.
- Evidence is append-only: no evidence file is edited after creation, back-dated or deleted; a re-run writes a new timestamped file.
- Every new knob defaults to today's behavior (registry `isolation` absent means `per-process`).
- File size: production, test and script files stay under the 500-line guidance where a logical split exists, and none reaches 801 lines. `.claude/lib/hook-dispatch/HookDispatch.psm1` is split (matcher and combiner separate from the runner) if it passes 500 lines; the parity corpus helper is split by runtime. No existing hook file grows.
- Coverage: line coverage of at least 85% per changed or new PowerShell file, measured from the single parallel gate run.
- Evidence location: all evidence is written under the feature folder's `evidence/<kind>/` directories.

### Risks and mitigations

- Timeouts: one dispatcher budget replaces per-hook budgets and sequential evaluation sums hook times. Mitigation: D7; the measurement reports wall time.
- Wall time: sequential in-process evaluation may exceed today's parallel wall time for gates that call `git` or `gh`. Mitigation: the measurement reports it and the PR states it.
- `exit` under `&`: pinned by the process-level parity suite, which runs the real dispatcher; unit tests use a seam-supplied stub, not a temp file.
- Stream rendering: warning and information records are captured as stdout text so an invalid-JSON fail-open outcome stays identical.
- Linux CI: case-exact paths, `Join-Path`, no drive letters, LF fixtures, no reads of gitignored `artifacts/` state; bounded parity corpus.
- Hook execution context: isolated subagents run `main`'s hooks, so live sessions use the dispatcher only after merge; branch proof is the Pester suites plus the measurement script, which launches branch files directly.
- `TotalProcessorTime` readability after exit on Linux is unconfirmed; Windows is the measured host.
- Later items (owner-accepted under D15): an item that merges after this one and adds or changes a PreToolUse hook must register it in `.claude/hooks/pretooluse-dispatch.json` or `.codex/hooks/pretooluse-dispatch.json`, not beside the dispatcher in `.claude/settings.json` or `.codex/config.toml`. Mitigation: the single-registration tests and the parity suite fail on a registration placed beside the dispatcher, and the execution-environment brief states where new PreToolUse hooks are registered.

## Implementation Strategy

- Implementation scope: dispatcher entry scripts, dispatcher logic module, registries, registrations, D6 import edits, measurement tool, parity suite, guard carve-out, consistency surfaces.
- New production files (each with its bundle mirror and pack-manifest entry):
  - `.claude/hooks/invoke-pretooluse-dispatch.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/invoke-pretooluse-dispatch.ps1`
  - `.claude/lib/hook-dispatch/HookDispatch.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/hook-dispatch/HookDispatch.psm1`
  - `.claude/hooks/pretooluse-dispatch.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/pretooluse-dispatch.json`
  - `.codex/hooks/invoke-pretooluse-dispatch.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/invoke-pretooluse-dispatch.ps1`
  - `.codex/hooks/hook-dispatch.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dispatch.ps1`
  - `.codex/hooks/pretooluse-dispatch.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/pretooluse-dispatch.json`
  - `scripts/dev-tools/HookProcessCost.psm1` and `scripts/dev-tools/Measure-HookProcessCost.ps1` (repository dev tooling; not pushed down)
- Edited registrations: `.claude/settings.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`, `.codex/config.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
- Edited pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- D6 edits: the dispatched Claude hook scripts in `.claude/hooks/` that carry guarded `Import-Module -Force` statements, the sibling helpers they dot-source, and their mirrors in `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. The exact file set is derived from the re-derived inventory at execution time.
- Documentation: `README.md` (Enforcement layer paragraph); `docs/engineering/claude-code-architecture.md` (enforcement boundaries); the execution-environment brief in every copy that carries `## Hook Execution Context`, kept byte-identical: `.claude/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`. The brief gains a dispatcher bullet under `## Hook Execution Context`, and the `## Batch Budget` statement that names the hook matcher is re-pointed to the registry group matcher. `.claude/rules/powershell.md` is read during preflight and edited only if it states the batch-budget hook registration.
- Guard carve-out (D9): `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` and its fixtures in `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- New tests:
  - `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1` (matcher, normalizer, combiner, registry validation, runner via seams, isolation knob default)
  - `tests/scripts/codex-hooks/hook-dispatch.Tests.ps1` (Codex helper)
  - `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` with corpus helpers `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Claude.ps1` and `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Codex.ps1` (integration tag; envelopes defined in memory; Write envelopes target paths the batch-budget hooks never record)
  - `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` and `tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1`
- Existing tests edited because they pin the registration shape: `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` (`Get-HookRegistration` also enumerates the registries, keeping `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` and `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` in scope; the Claude failure test's reason-prefix map gains the dispatcher entry), `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (its fixed PreToolUse hook count is replaced by a count derived from the registry), `tests/scripts/codex-hooks/discovery-capability.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (re-targeted to the registry groups that list the gate), `tests/scripts/dev_tools/test_discovery_publication_contracts.py`, `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (registry files added as hook-command sources).
- Preflight read list (edited only if an assertion there pins the registration shape): `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/discovery-capability.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/dev_tools/test_claude_payload_scope_support.py`.
- Verification-only contract tests (run, not edited unless they fail on the new files): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, and `scripts/dev_tools/generate_codex_agent_variants.py --check`.
- Dependency changes: none.
- Logging/telemetry: the `-PerHookTrace` switch (test use) and the cost report.
- Rollout: lands on `main`; live sessions adopt it after merge. Fallback: registry `isolation` set to `per-process` or removed.
- Phasing: Phase 0 (after merging `origin/main`) re-derives the inventory and runs `Measure-HookProcessCost.ps1 -Source Registration` before any registration edit; the final phase starts with the D15 integration pass, then runs the QA gates and `-Source Dispatcher` with identical payloads.

## Acceptance Criteria

Issue AC 1 — repeatable measurement, before and after:

- [x] `scripts/dev-tools/Measure-HookProcessCost.ps1` with `scripts/dev-tools/HookProcessCost.psm1` measures, for each runtime (Claude and Codex) and each representative payload (`Bash`, a write-class call, an `Agent` spawn call, an `mcp__` call), the hook process count per call, the summed CPU seconds of those processes, and the wall time from first start to last exit, and reports median, mean and max per scenario; the report states that grandchild processes (`git`, `gh`) are excluded.
- [x] `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` covers scenario derivation from both `-Source Registration` and `-Source Dispatcher`, sampling through the injected process-starter and timestamp seams, summary statistics, and report formatting, with no process start, temporary file or wall-clock wait.
- [x] A before report taken with `-Source Registration` after merging `origin/main` and before any registration edit exists under the feature folder's `evidence/baseline/`, and an after report taken with `-Source Dispatcher` on identical payloads exists under `evidence/regression-testing/`; each carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` and neither is edited after creation.
- [x] In the before report, the process count per call for each scenario equals the number of PreToolUse hook commands whose group matcher admits that tool name in the registrations derived at execution time; in the after report it equals one dispatcher process for every scenario.

Issue AC 2 — one dispatcher process per call that loads shared modules once:

- [x] `.claude/settings.json` contains exactly one PreToolUse entry, invoking `.claude/hooks/invoke-pretooluse-dispatch.ps1`, whose matcher admits every tool name admitted by any group in `.claude/hooks/pretooluse-dispatch.json`; a test derives the union from the registry at test time.
- [x] `.codex/config.toml` contains exactly one `[[hooks.PreToolUse]]` table, invoking `.codex/hooks/invoke-pretooluse-dispatch.ps1` in both `command` and `command_windows`, whose matcher admits every tool name admitted by any group in `.codex/hooks/pretooluse-dispatch.json`, and whose `timeout` equals the sum of the member timeouts derived at execution time.
- [x] Each registry reproduces the PreToolUse groups of the merged `origin/main` registrations at execution time, in the same group order and hook order, in the settings shape `{matcher, hooks: [{type, command}]}`; every registry hook command resolves to an existing hooks-folder `.ps1` file.
- [x] Each dispatcher evaluates group matchers with its runtime's semantics (Claude exact string or exact list versus unanchored regex; Codex regex including the `apply_patch` to `Edit`/`Write` alias), proven by unit tests in `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1` and `tests/scripts/codex-hooks/hook-dispatch.Tests.ps1`.
- [x] With `isolation` set to `in-process`, each selected hook runs in the dispatcher process in its own script scope after payload replay; the payload is read once (Claude through `Read-ClaudeHookRawPayload`, Codex through `[Console]::In.ReadToEnd()`) and no environment variable is written.
- [x] The dispatched Claude hooks import each shared module without `-Force`, so a module imported by several selected hooks loads once per call, except for modules that the D6 audit records as holding mutable module-scope state; those exceptions are listed in the registry notes with the reason.
- [x] Every selected hook runs on every call even when an earlier hook denies (no short-circuit), proven by a unit test in which the first hook denies and every later hook's invocation is recorded.

Issue AC 3 — decision logic and deny codes unchanged, proven by a parity suite:

- [x] No hook decision function, deny code or reason text is edited; the only hook-file edits are the D6 `-Force` removals, and the existing per-hook suites in `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` pass unchanged in the single parallel Pester gate.
- [x] `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` enumerates hooks from the registries and the settings and config registrations at test time (no frozen hook list), and for each corpus envelope and tool name on each runtime runs (i) every selected hook as its own `pwsh -NoProfile -File` process and (ii) the dispatcher as one process with `-PerHookTrace`, then asserts per-hook equality of exit code, parsed decision and reason text, and equality of the combined outcome: decision, ordered deny reasons, deny code tokens and ordered `additionalContext` values.
- [x] The parity corpus contains at least one allow envelope and at least one deny envelope for every hook in each registry that can be exercised without filesystem mocks, and the suite reports each registry hook that has no corpus envelope by name.
- [x] Combination follows D4: unit tests prove precedence `deny` > `defer` > `ask` > `allow` > none, deny reasons joined in registry order by a line feed, `additionalContext` concatenation, `allow` emitted when it is the strongest decision, exit 2 mapped to deny with the stderr reason, and any other exit code, invalid JSON or terminating error in a hook mapped to no decision.
- [x] With the registry `isolation` field absent, the dispatcher runs each selected hook as its own `pwsh -NoProfile -File` child with the payload on stdin (today's per-process behavior), proven by a unit test through the process seam; the shipped registries set `isolation` to `in-process`.
- [x] Dispatcher self-failure is fail-closed per D8: a missing, unreadable or schema-invalid registry, or a registry hook path that does not resolve, yields a deny whose reason starts with `HOOK_DISPATCH_BLOCKED:`, and a failure to load `hook-dependency-guard.ps1` yields exit 2 with the reason on stderr; the dispatcher entry scripts satisfy `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- [x] The Phase 0 baseline records the real process output of the hooks whose tail is `exit (Invoke-...EntryPoint)` (D13); any fail-open finding is reported to the orchestrator and is not altered within this feature's parity claim.
- [x] `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` admits only the dispatcher runner's single `&` call whose target is resolved through the registry to a hooks-folder `.ps1` sibling, adds no allowlist entry, and fixtures in `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` prove that every other dynamic `&` call is still reported as `DynamicInvocation`.

Issue AC 4 — the PR reports before and after cost:

- [ ] The pull request body quotes the before and after cost reports (process count, CPU seconds and wall time per scenario and runtime), cites both evidence file paths, and states any scenario whose after wall time exceeds its before wall time.

Issue AC 5 — registration, documentation and push-down payload consistent:

- [x] The bundle copies `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` carry the same single dispatcher registration as their repository sources, and every new dispatcher file and registry has a byte-identical bundle mirror, as do the D6-edited hooks.
- [x] Both `pack-manifests/core.json` files list every new dispatcher file and registry, and the push-down resource contract, pack-manifest completeness and dependency-closure tests pass, with the registries scanned as hook-command sources.
- [x] `README.md`, `docs/engineering/claude-code-architecture.md`, and every copy of the execution-environment brief that carries `## Hook Execution Context` describe the dispatcher registration and the registry; the brief copies remain byte-identical and the `## Batch Budget` statement refers to the registry group matcher.
- [x] Every existing test that pinned the per-hook registration shape is updated to read the registry, and `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` enumerates registry hooks so the dependency-guard, dependency-failure and imported-module stdout suites still cover every dispatched hook.
- [x] The `pr-author` agent-frontmatter PreToolUse hook and all non-PreToolUse registrations (SessionStart, SubagentStart, SubagentStop, UserPromptSubmit, Codex non-PreToolUse events) are unchanged.

Quality gates:

- [x] One `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run and `Invoke-PoshQCLeakScan` pass, with no new leak allowlist entry; every new or changed PowerShell file has at least 85% line coverage in that run; no file reaches 801 lines.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or evidence
- [ ] Behavior matches acceptance criteria on Windows and on the Linux hook-suite CI job
- [x] Tests updated/added (unit and process-level parity)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, architecture doc, execution-environment brief copies)
- [x] Cost evidence recorded before and after
- [x] Toolchain pass completed (format, lint, type-check where applicable, tests)
