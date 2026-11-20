# Research: Hook Process Cost - One Dispatcher per Tool Call (Issue #1159)

- Issue: #1159
- Branch: `feature/hook-dispatcher-process-cost-1159`
- Feature folder: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159`
- Requirements source: `issue.md` in the feature folder (authoritative scope; not reduced here)
- Timestamp: 2026-11-09T21-47 (UTC, read from an external time service because the researcher has no shell clock; the orchestrator may re-stamp)
- Scope of evidence: every statement below was verified by reading the named file or documentation page, unless it is marked "unverified" or "to confirm".

## 1. Summary and Recommendation

Every Claude Code `Bash` call today starts 12 separate `pwsh -NoProfile -File` hook processes in the main session (13 inside a `pr-author` subagent), and every `Write` or `Edit` call starts 13. Every Codex `Bash` call starts 12 and every `apply_patch` call 15. Each hook process pays the full PowerShell 7 start-up cost.

Recommended design (D1-D14 in section 10): one in-process PowerShell dispatcher per runtime, registered once per runtime under a single PreToolUse matcher that covers the union of today's tool matchers. A versioned registry file (`pretooluse-dispatch.json`) holds today's PreToolUse groups verbatim: matcher, then ordered hook commands. Per call the dispatcher reads the payload once, selects the groups whose matcher admits `tool_name` using the runtime's own matcher semantics, and runs every selected hook script unchanged in the same process. Each hook runs in its own script scope with standard input replaced by the captured payload. The dispatcher records each hook's stdout, stderr and exit code, applies the runtime's documented precedence, and emits one combined decision. Hook decision logic is not edited. The only hook-file edit is the removal of `-Force` from guarded `Import-Module` statements, which makes shared modules load once per call (D6). A bash front filter is rejected (section 5).

## 2. Inventory of Current Registrations

### 2.1 Claude Code - `.claude/settings.json` PreToolUse

No PreToolUse entry declares a `timeout`, so each uses the documented command-hook default of 600 seconds. Every command has the form `pwsh -NoProfile -File .claude/hooks/<script>`.

| Group matcher (verbatim) | Matcher class (Claude rules) | Hook scripts, in registration order |
|---|---|---|
| `Bash` | exact | `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-docs-complete-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, `enforce-worktree-poetry-venv.ps1` (10) |
| `Write\|Edit` | exact list | `check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-file-size-limit.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-feature-folder-order.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`, `enforce-mermaid-validation.ps1` (11) |
| `Bash\|Write\|Edit\|MultiEdit\|NotebookEdit\|Agent\|Task\|WebFetch\|WebSearch\|mcp__.*` | regex, unanchored (contains `.` and `*`) | `enforce-discovery-artifact-gate.ps1` (1) |
| `Agent` | exact | `enforce-prd-feature-before-planner.ps1`, `enforce-discovery-planning-gate.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-epic-invocation-origin.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1` (8) |
| `Write\|Edit\|MultiEdit\|NotebookEdit\|Bash` | exact list | `enforce-docs-role-write-scope.ps1` (1) |

Agent frontmatter PreToolUse (agent-scoped): `.claude/agents/pr-author.md` registers `enforce-pr-author-command-allowlist.ps1` on `Bash`. No other agent declares a PreToolUse hook. All other agent frontmatter hooks are SubagentStop.

Processes started per tool call (main session, before hook-internal children such as `git` and `gh`):

| Tool name | Matching groups | pwsh processes |
|---|---|---|
| `Bash` | `Bash` (10), broad regex (1), docs-role list (1) | 12 (13 in a `pr-author` subagent) |
| `Write`, `Edit` | `Write\|Edit` (11), broad (1), docs-role (1) | 13 |
| `Agent` | `Agent` (8), broad (1) | 9 |
| `MultiEdit`, `NotebookEdit` | broad (1), docs-role (1) | 2 |
| `Task`, `WebFetch`, `WebSearch`, any `mcp__*` | broad (1) | 1 |

Today no tool name selects the same script twice. `enforce-orchestration-preimplementation-gate.ps1` appears in three groups, but those groups are disjoint for every tool name.

### 2.2 Codex - `.codex/config.toml` PreToolUse

There is no separate Codex hooks registration file; `[features] hooks = true` and the `[[hooks.*]]` tables in `.codex/config.toml` are the registration. Every entry has `timeout = 30` and both `command` and `command_windows` of the form `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<script>"`, so each hook also implies a shell and a `git rev-parse` child (unmeasured).

| Group matcher (regex, as written) | Hook scripts |
|---|---|
| `^Bash$` | `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-worktree-poetry-venv.ps1` (6) |
| `^(Bash\|shell_command\|apply_patch\|Edit\|Write\|mcp__.*)$` | `enforce-discovery-artifact-gate.ps1`, `enforce-epic-root-invocation.ps1`, `enforce-codex-model-routing.ps1`, `enforce-epic-planning-only.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-child-worktree-binding.ps1` (6) |
| `^(apply_patch\|Edit\|Write)$` | `check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-file-size-limit.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1` (9) |
| `^(Agent\|Task\|spawn_agent\|run_subagent\|delegate)$` | `enforce-discovery-artifact-gate.ps1`, `enforce-discovery-planning-gate.ps1` (2) |

Per call: `Bash` 12, `apply_patch`/`Edit`/`Write` 15, `shell_command` and `mcp__*` 6, spawn tools 2. The bundled copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` carries the same registrations (it is checked by `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, which pins "21 PreToolUse hooks").

### 2.3 Other events - recommended out of scope

- Claude `SessionStart` (`persist-session-id.ps1`) fires once per session. `SubagentStart` (discovery roles) and `SubagentStop` (validators) fire once per subagent lifecycle. There are no `PostToolUse`, `Stop` or `UserPromptSubmit` registrations in `.claude/settings.json`.
- Codex `UserPromptSubmit`, `SubagentStart` and `SubagentStop` fire per prompt or per subagent.
- These run orders of magnitude less often than PreToolUse and are not part of the issue's problem statement. Recommendation: out of scope (D12), stated explicitly in the plan.
- The agent-scoped `pr-author` PreToolUse hook stays a separate frontmatter registration (D11). Folding it into the global dispatcher would change its lifetime scoping.

## 3. Runtime Contract

### 3.1 Claude Code (code.claude.com/docs/en/hooks, fetched 2026-11-09)

- Concurrency: "When an event fires, its matching hooks run in parallel." There is no ordering guarantee among matching hooks.
- Matchers: `*`, empty or omitted matches all. A matcher made only of letters, digits, `_`, `-`, spaces, `,` and `|` is an exact string or a list of exact strings. Any other character makes it a JavaScript regular expression tested with `RegExp.prototype.test`, which is unanchored.
- Exit codes: exit 2 blocks a PreToolUse call, and the block message is the hook's stderr unless the hook also printed a JSON blocking decision. Any other non-zero exit, failure to start, or invalid JSON is a non-blocking error, so the call proceeds. Exit 0 with no output means no decision.
- JSON: `hookSpecificOutput.permissionDecision` takes `allow`, `deny`, `ask` or `defer`, with `permissionDecisionReason`. `allow` skips the permission prompt but does not override deny or ask rules. `additionalContext` from several hooks is all delivered. `updatedInput` replaces the tool input.
- Precedence across hooks (verbatim): "When multiple PreToolUse hooks return different decisions, precedence is `deny` > `defer` > `ask` > `allow`."
- How several `deny` reasons are presented when more than one hook denies is not documented (unknown).
- Timeout: default 600 s for a command hook. A timed-out PreToolUse hook does not block unless the hook sets `onFailure: "block"`, which requires Claude Code 2.1.295 or later.
- Deduplication: an identical handler defined in more than one settings file runs once. Not relevant today, because no tool selects a script twice.

### 3.2 Codex (learn.chatgpt.com/docs/hooks, fetched 2026-11-09)

- "Multiple matching command hooks for the same event are launched concurrently."
- PreToolUse blocks with `permissionDecision: "deny"` plus `permissionDecisionReason`, the legacy `decision: "block"` plus `reason`, or exit 2 with the reason on stderr. `ask` is unsupported, and the run is marked failed.
- The combination rule across PreToolUse hooks is not documented. The only documented combination rule is for PermissionRequest: "any `deny` wins".
- The matcher is a regex applied to `tool_name` and its aliases. For `apply_patch` the matcher can also use `Edit` or `Write`.
- Default timeout is 600 s. A PreToolUse error, timeout or malformed response can let the tool run.
- How Codex treats an explicit `permissionDecision: "allow"` is not documented (unknown). Seven Codex hooks emit one: the two batch-budget hooks, `enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-evidence-locations.ps1`, `enforce-completion-consistency.ps1` and `enforce-checkpoint-monotonic.ps1`.

### 3.3 Repository output conventions (verified in the hooks)

- PreToolUse hooks emit compact JSON `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":...}}` at exit 0. 23 Claude hooks also emit explicit `allow` decisions, for example `enforce-epic-wave-barrier.ps1` (`Get-EpicWaveBarrierAllowDecision`). Explicit `allow` skips the permission prompt, so the combined outcome must keep it.
- When a hook cannot load `hook-dependency-guard.ps1`, it writes `<PREFIX>: hook-dependency-guard.ps1 failed to load; the gate fails closed.` to stderr and exits 2. Any other recorded dependency failure emits a deny JSON at exit 0 (`Get-HookDependencyFailureDecision` in `.claude/hooks/hook-dependency-guard.ps1`).
- No Claude hook emits `updatedInput`, `additionalContext`, `systemMessage`, `continue` or `ask` (grep over `.claude/hooks`: no match). Sibling issue #1157 proposes a PreToolUse hook that "injects unacknowledged directives", which is likely to use `additionalContext`, so the dispatcher must aggregate it (D4).

### 3.4 The "combined decision" the parity suite compares

For one payload and one tool name, define the per-hook result as `{Hook, ExitCode, StdoutText, StderrText}` and the observable per-hook outcome as follows:

1. Exit 2: `deny`, with reason = stderr text, or the JSON reason when the stdout JSON carries a blocking decision.
2. Exit 0 with stdout that parses as JSON carrying `hookSpecificOutput.permissionDecision`: that decision, its reason, and its `additionalContext`.
3. Exit 0 with empty stdout: no decision.
4. Any other exit code, or stdout that does not parse as JSON: non-blocking error, so no decision. Today's behavior is fail-open, and that is preserved.

The combined outcome is the highest-precedence decision (`deny` > `defer` > `ask` > `allow` > none). With it come the ordered multiset of deny reasons, the set of deny code tokens (the leading `UPPER_SNAKE` token before the first `:` of each reason, or the whole reason for prose reasons such as validate-bash's), and the ordered `additionalContext` values. The dispatcher's own process exit code is always 0 when it emits a decision. The parity suite compares: (a) each per-hook result field-for-field (exit code, parsed decision, reason text) between the per-process path and the in-process path, and (b) the combined outcome. Wall-clock or stderr noise that is not a reason (for example non-terminating error records on exit 0) is excluded from (b) but recorded in (a).

## 4. Per-Hook Behavior the Dispatcher Must Preserve

### 4.1 Payload transport

- Claude: every registered PreToolUse hook acquires its payload through `Read-ClaudeHookRawPayload` in `.claude/lib/hook-payload/HookPayload.psm1`. The order is stdin (guarded by `[Console]::IsInputRedirected`), then `CLAUDE_HOOK_INPUT`, then `CLAUDE_TOOL_INPUT`. `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` forbids either environment literal in any registered hook file.
- Codex: hooks read `[Console]::In.ReadToEnd()` directly in the tail, with no environment fallback. The empty or malformed convention is exit 2 with the reason on stderr (for example `ConvertFrom-CodexBashHookPayload` in `.codex/hooks/validate-bash.ps1`).
- Consequence: stdin is consumed once per process. The dispatcher reads it once and replays it to each hook by `[Console]::SetIn([System.IO.StringReader]::new($raw))` before each hook. `IsInputRedirected` reflects the real OS handle, so it stays `true` in a Claude or Codex launched dispatcher. The Claude dispatcher acquires `$raw` through `Read-ClaudeHookRawPayload`, which keeps the environment fallback and satisfies the payload contract test. The Codex dispatcher acquires it with `[Console]::In.ReadToEnd()`, which keeps the Codex no-fallback behavior. No environment variable is written (D3).

### 4.2 Entry and tail shapes (all registered Claude PreToolUse hooks)

- Every registered hook dot-sources `hook-dependency-guard.ps1` in a bootstrap `try`, guards each import, and ends with `if ($MyInvocation.InvocationName -eq '.') { return }`, then the guard-failure `exit 2`, then the dependency-decision check, then a tail. `exit` appears only in those tail statements; no function calls `exit`, `[Environment]::Exit` or `$host.SetShouldExit` (grep verified).
- Tail families:
  - (A) `$decision = Invoke-<X>Decision -ToolInputRaw (Read-ClaudeHookRawPayload)`, emit the JSON, `exit 0`.
  - (B) Emit only when deny: `validate-bash.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-docs-role-write-scope.ps1`, `enforce-worktree-poetry-venv.ps1`.
  - (C) `@(Invoke-<X>EntryPoint)` returning the JSON lines plus an `[int]` exit code (preimplementation gate, pr-author skill, promotion, epic merge, docs-complete, both worktree-removal gates, evidence, file size, feature-folder order, both batch budgets, pr-author allowlist).
  - (D) `exit (Invoke-<X>EntryPoint)` in `enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1` and `enforce-parallel-drift-gate.ps1`.
  - (E) `enforce-mermaid-validation.ps1` calls its entry point as a statement and then `exit 0`.
- Because the tails differ, a dispatcher that re-implemented them would duplicate output plumbing and drift. Running the unchanged script (D2) avoids that.
- Family (D) latent defect (likely; confirm before baseline). Each of the three entry points writes its decision with `| Write-Output` and then `return 0`, so `exit (Invoke-...EntryPoint)` passes a two-element array to `exit`. Five other hooks carry the comment "`exit (<call>)` would capture BOTH into the exit expression and emit nothing". If that is so, these three Agent-matcher gates emit no JSON as processes today and do not enforce. Their Pester suites call the entry points as functions, and no process-level test covers these tails (searched `tests/scripts/claude-hooks/*wave-barrier*`, `*cohort-barrier*`, `*drift-gate*`). Running the unchanged scripts in-process (D2) reproduces whatever `exit` does with an array, so parity holds either way. D13 asks the orchestrator to record the observed process behavior in the baseline and to keep the fix out of this feature's parity claim.

### 4.3 State, scope and side effects relevant to sharing one process

- Function-name collisions exist across hooks: `ConvertFrom-CheckpointJson` is defined in `enforce-completion-consistency.ps1`, `enforce-checkpoint-monotonic.ps1` and `enforce-orchestration-preimplementation-gate.ps1`, and `Test-IsCheckpointPath` in the first two. All of these sit in the `Write|Edit` group. The bodies are identical today, but dot-sourcing several hooks into one scope makes the last definition win. Running each hook with `& <script>` gives each its own script scope, so definitions are discarded on return.
- `$script:HookDependencyFailures` (`hook-dependency-guard.ps1`) is a script-scope list created when absent. In one shared scope, a dependency failure recorded by one hook would make every later hook deny. A per-script scope isolates it.
- `enforce-mermaid-validation.ps1` runs `Set-StrictMode -Version Latest` at script scope. Strict mode is scope-inherited, so it must not leak into a shared scope; a per-script scope contains it.
- `enforce-discovery-artifact-gate.ps1` hashes its own file through `$PSCommandPath`, and many hooks resolve paths through `$PSScriptRoot`. Both bind to the executing script file under `&` invocation.
- `hook-docs-only-diff.ps1` uses `Push-Location`. The dispatcher records the location before each hook and restores it afterwards.
- No hook or hook library assigns `$env:*` or calls `SetEnvironmentVariable`, and none uses `$global:` or `Import-Module -Global` (grep over `.claude/hooks` and `.claude/lib`).
- `Import-Module` from a script imports into the global session state. Hooks re-import with `-Force`, so each re-executes the module script (see D6).
- Side effects: `enforce-python-batch-budget.ps1` and `enforce-powershell-batch-budget.ps1` write `.claude/state/<kind>-batch-budget.*.json` even when another hook denies the call. The dispatcher must therefore run every selected hook and never stop at the first deny (D5).
- Hook-internal children (`git worktree list`, `gh pr view`, `gh run list`) are unchanged by any design here. They are the residual per-call process cost.

### 4.4 Hooks that cannot share a process as-is

None, under the per-script-scope runner (D2). Under a single-scope dot-source runner (rejected), the `Write|Edit` group would collide on function names, the guard list and strict mode, and a `Get-<Hook>Decision` refactor of every hook would be required. That refactor is the rejected alternative recorded in section 5.

## 5. Design Options

| Option | Description | Assessment |
|---|---|---|
| (a) PowerShell dispatcher, unchanged scripts in-process (recommended) | One registration per runtime. The registry lists today's groups, and each selected hook runs with `& <script>` after stdin is replayed. Results are combined by the documented precedence. | One pwsh start per call. Hook logic stays byte-identical except D6. Works on Windows and Linux. The tail families need no per-hook knowledge. Needs one guard carve-out (D9). |
| (a') Dispatcher with a uniform `Invoke-HookScriptMain` per hook, loaded by `New-Module -ReturnResult` with dot-source | Avoids any dynamic `&` call. | Moves about 53 hook tails (31 Claude, 22 Codex) plus bundle mirrors into a new function, collides with the `hook-dependency-guard-completeness.Tests.ps1` tail-shape rules S1 and S6, and has a larger blast radius. Rejected; it is the fallback if D9 is refused. |
| (b) Bash front filter that starts pwsh only when a cheap pattern says a check might apply | `sh`/`bash` script per matcher. | Several gates apply to every call (`validate-bash.ps1`, `enforce-docs-role-write-scope.ps1`, `enforce-discovery-artifact-gate.ps1`, the preimplementation gate, both batch budgets on every Write). The filter would be a second implementation of each hook's scope test and would drift, contrary to the repository rule that an enforcement hook has one implementation. On Windows, Claude Code would need a bash on PATH for a hook command (unverified). Rejected. |
| (c) Hybrid: bash filter in front of the dispatcher | | Saves little over (a), because the dispatcher already pays one start-up per call, and it adds the drift risk of (b). Rejected. |

Windows and Linux: `pwsh` start-up is paid once per call in (a). The dispatcher uses only PowerShell 7 and .NET APIs available on both (`[Console]::SetIn`, `[Console]::SetError`, `System.IO.StringReader`/`StringWriter`). Paths are built with `Join-Path` and forward-slash relative paths for the Linux hook-suite job.

## 6. Parity Suite Design

1. Enumeration (not frozen). The test file reads `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json` at Pester discovery time, together with `.claude/settings.json` and `.codex/config.toml`. It asserts that each runtime registers exactly one PreToolUse dispatcher entry whose matcher admits the union of the registry group matchers, and that every registry hook file exists. Hook rows come from the registry, so hooks added or removed by #1157, #1158, #1160 or #1163 are covered automatically. The registry itself is re-derived from the merged `origin/main` settings and config at execution time (D10).
2. Pure-logic unit tests (in-process, no processes). These cover matcher evaluation (`Test-HookDispatchMatcher`: Claude exact list against unanchored regex; Codex anchored regex plus the `apply_patch` to `Edit`/`Write` alias), result normalization (exit 2, exit 0 with JSON, exit 0 empty, exit 1, invalid JSON), the combiner (precedence, reason order, `additionalContext` aggregation, no short-circuit), and the runner with injected seams (`[scriptblock]` parameters for the script invoker, the stdin replayer and the clock).
3. Existing hook corpus. The per-hook suites under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` run unchanged against unchanged hook decision functions. The full parallel Pester gate passing is the function-level proof that decision logic and deny codes are unchanged.
4. Process-level parity (integration tag). A corpus of envelopes is defined in memory in a `.ps1` data helper, one or more allow and deny envelopes per hook. They are harvested from payload literals in the existing hook tests and limited to cases that need no filesystem mocks. For each envelope and tool name, the suite runs (i) every selected registry hook as its own `pwsh -NoProfile -File` process with the envelope on stdin (today's registration semantics), and (ii) the dispatcher as one process with a test-only `-PerHookTrace` switch that writes the per-hook results as JSON to stderr. It then compares section 3.4 (a) and (b).
   - Write envelopes target paths that the batch-budget hooks never record (test files or the root `artifacts/` directory), so the suite writes no state file.
   - Corpus size is chosen to keep the file under about two minutes on the Linux hook-suite job, because each Claude Bash envelope costs about 13 processes.

## 7. Measurement Design

Prior evidence: `f3-hook-process-before.*`, `f3-hook-process-after.*` and `f4-f5-hook-process.*` under `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/regression-testing/` are decision tables for `enforce-docs-complete-gate.ps1`. They record no CPU or wall time, and their producing scripts were under `SCRATCH` and were never committed. They are not reusable for cost. Their method (one real pwsh process per row with the envelope on stdin) is reused by the parity suite.

Proposed tool (pattern of `scripts/dev-tools/Get-StageTimingReport.ps1` with `StageTiming.psm1`):

- `scripts/dev-tools/HookProcessCost.psm1` (pure):
  - `Get-HookCostScenario` builds the scenario per tool name from either the settings or config PreToolUse groups (`-Source Registration`, used for the Phase 0 "before" run) or the dispatcher registry (`-Source Dispatcher`).
  - `Measure-HookCostSample` takes an injected `[scriptblock] $StartHookProcess` returning `{ProcessCount, CpuSeconds, StartTicks, EndTicks, ExitCode}` and an injected `[scriptblock] $GetTimestamp`.
  - `Get-HookCostSummary` produces median, mean and max per scenario.
  - `Format-HookCostReport` produces the Markdown table with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.
- `scripts/dev-tools/Measure-HookProcessCost.ps1` (thin): it starts the real processes through `System.Diagnostics.Process` with stdin redirected. Per-hook mode launches all selected hooks concurrently, as Claude does. It reads `TotalProcessorTime` after `WaitForExit` and uses a `Stopwatch` for wall time.
- Metrics: pwsh process count per call, summed CPU seconds of those processes, and wall time from first start to last exit. Grandchildren (`git`, `gh`) are excluded from CPU and are identical in both modes. The report states this.
- Representative payloads: `Bash` (`git status`), `Write` (a docs path), `Agent` (`subagent_type` `task-researcher` without the epic marker), and one `mcp__drm-copilot__*` call, on both runtimes.
- Run on Windows, the host where the problem was observed. Whether `TotalProcessorTime` remains readable after exit on Linux is to be confirmed. The unit tests use the seams only, with no temp files and no wall-clock waits.
- Evidence (append-only): `evidence/baseline/hook-process-cost.<UTC>.md` (before) and `evidence/regression-testing/hook-process-cost.<UTC>.md` (after). The PR body quotes both.

## 8. Consistency Surfaces

- Registration: `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`; `.codex/config.toml` and the bundled `.codex/config.toml`. Each `hooks.PreToolUse` block is replaced by one dispatcher entry.
- New files, each with a bundle mirror and pack-manifest entries:
  - `.claude/hooks/invoke-pretooluse-dispatch.ps1` (thin entry)
  - `.claude/lib/hook-dispatch/HookDispatch.psm1` (pure matcher, normalizer, combiner and runner)
  - `.claude/hooks/pretooluse-dispatch.json`
  - `.codex/hooks/invoke-pretooluse-dispatch.ps1` and `.codex/hooks/hook-dispatch.ps1` (Codex has no lib folder; dot-sourced helper)
  - `.codex/hooks/pretooluse-dispatch.json`
  - Manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (hand-edited paths; `scripts/dev_tools/generate_codex_agent_variants.py --check` re-renders only agent paths)
- Documentation: `README.md` (Enforcement layer paragraph); `docs/engineering/claude-code-architecture.md` (section on enforcement boundaries, item 1 says Claude Code executes `validate-bash.ps1` directly); the execution-environment brief, all six byte-identical copies (`## Hook Execution Context` gains a dispatcher bullet; the `## Batch Budget` statement "the hook matcher is `Write|Edit`" becomes "the registry group matcher"); and `.claude/rules/powershell.md` if the batch-budget statement there references registration (to confirm).
- Tests that pin the current registration shape and need updating:
  - `tests/scripts/claude-runtime/claude-settings.Tests.ps1`: "registers the native discovery start, tool, stop and planning handlers for the four discovery agents (issue #980)" (PreToolUse rows) and "requires the Bash PreToolUse hook chain to include validate-bash and enforce-promotion-mcp-only".
  - `tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1`: "registers exactly one PreToolUse write-scope group in <Path>".
  - `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`: the hook set is derived from settings `-File` commands and must also read the registry.
  - `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` (`Get-HookRegistration`) feeds `hook-dependency-guard-completeness.Tests.ps1` (S1-S9), `hook-dependency-failure.Claude.Tests.ps1` (B1-B4, including the reason-prefix map that needs a dispatcher entry), `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` and `hook-imported-modules-no-stdout.Tests.ps1` (N1-N3). It must enumerate the registry as well as settings and config, so the dispatched hooks stay in scope.
  - `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` and `codex-bundle-hook-probe.Tests.ps1` ("derives 21 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config").
  - `tests/scripts/codex-hooks/discovery-capability.Tests.ps1` ("registers the artifact gate on the broad and spawn PreToolUse groups...").
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` ("registers no PreToolUse matcher admitting an Agent or Task tool name"). This test fails by construction against a union dispatcher matcher, so it must re-target the registry groups that list the preimplementation gate.
  - `tests/scripts/dev_tools/test_discovery_publication_contracts.py` (`test_roles_carry_stop_and_tool_controls_on_every_host`: text presence of the discovery hook names in settings and config).
  - `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` with `pack_manifest_dependency_scan.py`. The registry files are added as hook-command sources; the registry reuses the settings `command` shape, so `_settings_commands` parses it unchanged.
  - Resource and manifest contracts: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`.
  - Preflight must also search `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1`, `enforce-parallel-drift-gate.Tests.ps1`, `enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/discovery-capability.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, and `test_claude_payload_scope_support.py` for registration assertions. Each names `settings.json` or `config.toml`; their dispositions are not yet verified.
- Unaffected: `test_claude_planning_integrity_contracts.py` and the prd-feature rows of `claude-settings.Tests.ps1` (SubagentStop only). `PreToolUseSchema.Contract.Tests.ps1` is function-level.
- Python guard: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks`, `.claude/lib` and `.codex/hooks`. An `&` call of a string variable is reported as `DynamicInvocation` (detection class 3); only `[scriptblock]` parameter seams (carve-out (a)) and dot-source loads (carve-out (b)) are exempt. See D9.

## 9. Risks

- Timeouts. Claude has one 600 s dispatcher timeout in place of 600 s per hook, and sequential evaluation sums hook times. Codex today allows 30 s per hook, so a 30 s dispatcher timeout could fail open for all hooks. Mitigation: the Codex dispatcher timeout is the sum of member timeouts (D7), and the measurement reports the wall time.
- One hook crash. A terminating error in one hook is caught by the dispatcher and treated as that hook's non-blocking error, which preserves today's per-hook fail-open. A failure in the dispatcher itself (registry unreadable, bootstrap failure) denies with a `HOOK_DISPATCH_BLOCKED:` reason. This is fail-closed, consistent with `hook-dependency-guard.ps1` (D8).
- Ordering. Today's hooks run in parallel and unordered. Sequential registry order changes only the order of concatenated reasons. No hook reads another hook's side effects within a call (batch-budget state is per kind).
- Wall time. Sequential in-process evaluation may exceed today's parallel wall time for gates that call `git` or `gh`. The measurement reports it, and the PR states it.
- `exit` semantics under `&`. `exit N` inside a script invoked with `&` returns to the caller and sets `$LASTEXITCODE`. This is the expected PowerShell behavior and must be pinned by a unit test with a stub script supplied through a seam, not a temp file. The dispatcher sets `$LASTEXITCODE` to a sentinel before each call, so a script that ends without `exit` is detected.
- Stream rendering. In a `pwsh -File` process, warning and information records reach stdout and would make the JSON invalid, which is fail-open today. The runner captures success, warning and information streams as stdout text to keep that outcome. `hook-imported-modules-no-stdout.Tests.ps1` keeps modules from writing those streams.
- File size. The new files are small. `HookDispatch.psm1` holds the pure logic and stays under 500 lines. No hook file grows.
- Batch budget. More than three production PowerShell files change (D6 alone touches the dispatched hooks and their mirrors), so the item runs on the orchestrated large route.
- CI-only. The process-level parity suite runs on `poshqc / PowerShell hook suites (Linux)`: it needs case-exact paths and `Join-Path`, no drive letters, LF fixtures, and no reads of gitignored `artifacts/` state.
- Sibling changes. #1157 adds a PreToolUse hook that injects directives (likely `additionalContext`) for executor and worker agents. If it is registered in agent frontmatter, it stays outside the dispatcher (D11). If it is registered globally, it enters the registry. #1158, #1160 and #1163 may add or alter gates (pages fetched; no registration detail). The registry is therefore re-derived after merging `origin/main` (D10).
- Hook execution context. Isolated subagents run `main`'s hooks, so the dispatcher affects live sessions only after merge. Branch proof is the Pester suites plus the measurement script, which launches the branch files directly.

## 10. Decisions

- D1. Use one dispatcher per runtime, registered once, with the union matcher. Claude: `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*`. Codex: the anchored union of its four group matchers. Rationale: one pwsh process per PreToolUse call regardless of how many groups match. Per-group dispatchers would leave 3 processes per Bash call.
- D2. Run each selected hook script unchanged with `& <script>` in its own script scope, after `[Console]::SetIn` replay, capturing streams and `$LASTEXITCODE`. Rationale: no tail re-implementation, isolated script scope, and parity by construction.
- D3. Read the payload once. Claude reads through `Read-ClaudeHookRawPayload`; Codex reads `[Console]::In.ReadToEnd()`. Write no environment variable. Rationale: preserves each runtime's transport and the payload contract test.
- D4. Combine by documented precedence `deny` > `defer` > `ask` > `allow` > none. Join every deny reason in registry order, separated by a line feed, so every deny code token remains visible. Concatenate `additionalContext` values. Emit `allow` when the strongest decision is `allow`, because explicit allow skips the prompt today. Map exit 2 to deny with the stderr reason, and other exit codes or invalid JSON to no decision. Codex uses the same rule with JSON deny output. Rationale: reproduces Claude's documented combination and today's fail-open per hook.
- D5. Never short-circuit; run every selected hook. Rationale: the batch-budget hooks record state on calls another hook denies.
- D6. Remove `-Force` from the guarded `Import-Module` statements of the dispatched Claude hooks and the sibling helpers they dot-source. First audit each imported `.psm1` (enumerated by `Get-HookScriptEdge`) for mutable module-scope state; a stateful module keeps `-Force`, documented in the registry notes. Rationale: AC 2 requires shared modules to load once per call. Codex hooks dot-source `.ps1` helpers into their own scope and import no modules; for Codex the requirement is met by the single process.
- D7. Timeouts: the Claude dispatcher keeps the default (no `timeout` key). The Codex dispatcher sets `timeout` to the sum of its members' timeouts. Rationale: avoids a fail-open caused by a shorter combined budget.
- D8. Dispatcher self-failure is fail-closed (`HOOK_DISPATCH_BLOCKED:` deny; exit 2 with stderr if its own guard cannot load). A per-hook failure keeps today's per-hook outcome. The dispatcher follows the `hook-dependency-guard.ps1` bootstrap pattern so S1-S7 apply to it.
- D9. Extend `EnforcementHooksNoPythonInvocation.Helpers.ps1` with one tight carve-out (c). It covers the single `&` call in the dispatcher runner, whose target is resolved only through the registry to a `<name>.ps1` sibling of the hooks folder (`^[a-z0-9][a-z0-9.-]*\.ps1$`, existence verified). Add fixtures that keep every other dynamic `&` call reported. This is a policy-oracle change; the orchestrator records the decision. If it is refused, the fallback is option (a').
- D10. Generate the registry at execution time from the PreToolUse blocks of the merged `origin/main` settings and config (after #1157, #1158, #1160 and #1163 merge), preserving group order and hook order. The registry schema reuses the settings shape `{matcher, hooks: [{type, command}]}`.
- D11. Agent-frontmatter PreToolUse hooks (`pr-author`) stay as separate registrations.
- D12. SessionStart, SubagentStart, SubagentStop, UserPromptSubmit and Codex non-PreToolUse events are out of scope.
- D13. The family (D) tails (`exit (Invoke-...EntryPoint)`) are reproduced as-is by D2. The Phase 0 baseline records their real process output. If they emit no JSON (suspected fail-open), that finding is reported to the orchestrator under the related-findings rule, and it is fixed only as a separate, explicitly stated change with its own before/after evidence, not as part of the parity claim.
- D14. Fallback knob: a registry field `"isolation"` with values `"in-process"` and `"per-process"`. An absent field means `per-process`: the dispatcher runs each hook as its own `pwsh -NoProfile -File` child with the payload on stdin, which matches today's process isolation. The shipped registries set `"in-process"` explicitly. Rationale: a destination registry without the field keeps today's isolation, the operator can revert with one data edit (revertible process change), and the shipped setting meets AC 2.

## 11. Requirements Mapping

| Acceptance criterion | Design element | Verification |
|---|---|---|
| Repeatable measurement, before and after | Section 7 tool; Phase 0 run with `-Source Registration`, final run with `-Source Dispatcher` | Two evidence files; unit tests of `HookProcessCost.psm1` |
| One dispatcher process per tool call that loads shared modules once | D1, D2, D6 | Settings and config tests; registry enumeration test; measurement process count is 1 |
| Decision logic and deny codes unchanged | D2 (scripts unchanged), D4, D5 | Existing hook suites unchanged and green; process-level parity suite (section 6) |
| PR reports before and after cost | Evidence files quoted in the PR body | pr-author collects them from evidence |
| Settings registration, hook documentation and push-down payload consistent | Section 8 surfaces | Contract tests in section 8; six-copy brief update |

## 12. Testing Implications

- Pester only for production logic; no new Python. Python contract tests change only where they pin registration (`test_discovery_publication_contracts.py`, the closure scanner).
- Unit tests inject seams: a `[scriptblock]` invoker that returns canned per-hook results, an in-memory payload, and a clock. No temp files and no waits. The `exit`-under-`&` and `SetIn` behaviors are proven by the process-level parity file, which runs the real dispatcher.
- Coverage: the new `.claude/lib/hook-dispatch/HookDispatch.psm1`, the dispatcher entry scripts, and `scripts/dev-tools/HookProcessCost.psm1` fall under the `config/poshqc-coverage.json` roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `scripts`). The 85% line threshold applies per changed file. Thin entry scripts keep their logic in the module.
- Gates are parallel only: one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, and `Invoke-PoshQCLeakScan`. `[Console]::SetIn` and `SetError` changes in tests are restored in `finally`, because they are process-global and Pester shards share a process.

## Numeric Derivation Evidence

Claim N1: Claude Code starts 12 hook processes per main-session `Bash` PreToolUse call.

- Complete Family: every PreToolUse hook command registered in `.claude/settings.json` whose group matcher admits the tool name `Bash` under Claude's matcher rules, plus agent-frontmatter PreToolUse hooks (`.claude/agents/*.md`).
- Exhaustive Search Scope: the whole `hooks.PreToolUse` array of `.claude/settings.json` (five groups) and every `.claude/agents/*.md` frontmatter.
- Inclusion Rules: groups whose matcher is an exact list containing `Bash`, or a regex for which `Bash` tests true; each `command` counts as one process.
- Exclusion Rules: agent-scoped frontmatter hooks are excluded from the main-session count and reported separately (`pr-author` +1). Non-PreToolUse events are excluded.
- Primary Search Strategy or Query Expression: Read of `.claude/settings.json`, then evaluating each group matcher against `Bash` by the documented exact-vs-regex rule.
- Primary Member Set: validate-bash, enforce-promotion-mcp-only, enforce-pr-author-skill, enforce-orchestration-preimplementation-gate, enforce-epic-merge-gate, enforce-docs-complete-gate, enforce-epic-worktree-removal-gate, enforce-parallel-worktree-removal-gate, enforce-parallel-abandon-gate, enforce-worktree-poetry-venv, enforce-discovery-artifact-gate, enforce-docs-role-write-scope.
- Primary Count: 12.
- Cross-check Search Strategy or Query Expression: Grep of `"matcher"|"command"` in `.claude/settings.json` with line numbers, assigning each `command` line to the nearest preceding `matcher` line, plus a Grep of `^\s+- matcher:|^\s+matcher:` over `.claude/agents/*.md` frontmatter to confirm the only agent PreToolUse hook.
- Cross-check Member Set: Bash group 10 commands (validate-bash through enforce-worktree-poetry-venv); broad regex group 1 (enforce-discovery-artifact-gate); `Write|Edit|MultiEdit|NotebookEdit|Bash` group 1 (enforce-docs-role-write-scope); `Write|Edit` and `Agent` groups do not admit `Bash`; frontmatter: only `pr-author.md` has a PreToolUse `Bash` hook.
- Cross-check Count: 12.
- Member-set Comparison: the normalized sets are identical (12 equal names). Both strategies agree, and the frontmatter cross-check confirms the single excluded agent-scoped member.

Claim N2: Codex starts 12 hook processes per `Bash` call and 15 per `apply_patch` call.

- Complete Family: every `[[hooks.PreToolUse.hooks]]` command in `.codex/config.toml` whose group matcher regex admits `Bash` (N2a) or `apply_patch` (N2b).
- Exhaustive Search Scope: all four `[[hooks.PreToolUse]]` tables of `.codex/config.toml`.
- Inclusion Rules: the group regex matches the tool name; each command entry counts once.
- Exclusion Rules: `command_windows` duplicates of the same entry are not counted twice; non-PreToolUse tables are excluded.
- Primary Search Strategy or Query Expression: Read of `.codex/config.toml` and manual evaluation of each anchored regex.
- Primary Member Set: N2a = the `^Bash$` group (6) plus the broad group (6). N2b = the `^(apply_patch|Edit|Write)$` group (9) plus the broad group (6).
- Primary Count: N2a 12; N2b 15.
- Cross-check Search Strategy or Query Expression: the `codex-bundle-hook-probe.Tests.ps1` assertion "derives 21 PreToolUse hooks" (unique hook names), reconciled against the union of the four groups' unique names.
- Cross-check Member Set: unique names = 6 (Bash group) + 6 (broad) + 9 (apply_patch group, of which `enforce-orchestration-preimplementation-gate.ps1` duplicates a Bash-group name, giving 8 new) + 2 (spawn group, of which `enforce-discovery-artifact-gate.ps1` duplicates a broad-group name, giving 1 new) = 21.
- Cross-check Count: 21 unique names, consistent with the per-group member counts 6, 6, 9 and 2 used for N2a and N2b.
- Member-set Comparison: the group memberships used for N2a and N2b reproduce the independently pinned 21-name union. The counts agree.

No numeric acceptance criterion exists in the current `spec.md` (template text only). These counts are offered for the spec author.

## Automation Feasibility

All work is automatable by the orchestrator and its specialists. Nothing requires human interaction to execute. One item is a policy-oracle change rather than a tool action: the D9 guard carve-out. The test file states that allowlist entries are added "only by an owner decision". A carve-out is a different mechanism, but the orchestrator should record the decision explicitly. If the run's standing directives treat it as owner-gated, fallback (a') removes the need for it. Ordering constraint: execution starts only after #1157, #1158, #1160 and #1163 merge, then merges `origin/main` and re-derives the registry (D10).

## Rejected Alternatives

- Bash front filter, and a hybrid filter plus dispatcher: duplicated scope logic would drift, and much of the hook set applies to every call (section 5).
- Dot-sourcing every hook into one shared scope: function-name collisions (`ConvertFrom-CheckpointJson`, `Test-IsCheckpointPath`), a shared `$script:HookDependencyFailures`, and leaked strict mode.
- Passing the payload through `CLAUDE_HOOK_INPUT`: violates `PreToolUsePayload.Contract.Tests.ps1` and is inherited by `git` and `gh` children.
- Per-group dispatchers: 3 processes per Claude Bash call instead of 1.
- Uniform `Invoke-HookScriptMain` refactor (a'): retained only as the D9 fallback.

## Items for the Orchestrator to Confirm

- Observed process behavior of the family (D) tails (D13), from one real process run per hook in the Phase 0 baseline.
- Whether `TotalProcessorTime` is readable after exit on Linux pwsh (section 7). Windows is the measured host either way.
- The D9 carve-out decision.
- Registration details of the sibling issues after they merge (section 9).

## Pre-Mortem

- Review checklists: a reviewer could find a hook whose deny code or reason text changed, or a section 8 consumer test not updated. Mitigation: the plan carries the section 8 test list with a disposition for each, and the preflight search of the unverified files; the parity suite asserts per-hook reason text equality.
- Coverage: the new module and entry scripts could fall below 85% line coverage if logic stays in thin scripts, or if per-hook runner branches (exit 2, invalid JSON, throw, missing exit) are untested. Mitigation: all logic lives in `HookDispatch.psm1` and `HookProcessCost.psm1` with seam-driven unit tests for every branch; per-file figures come from `artifacts/pester/powershell-coverage.xml` of the single parallel gate run.
- Mirror parity: the bundle copies of settings, config, registries, dispatcher files, the D6-edited hooks and the six execution-environment brief copies could diverge, and pack manifests could miss new paths. Mitigation: one task per mirror set, then `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both manifest-completeness tests, `test_push_down_pack_manifest_dependency_closure.py` and the Codex generator `--check`, with the brief-update task named in the plan.
- File size: `HookDispatch.psm1` or the parity data helper could exceed the 500-line guidance or the 800-line hard limit. Mitigation: split the matcher and combiner from the runner if the module passes 500 lines; split the corpus data helper by runtime; no existing hook grows.
- Test isolation: process-global `[Console]::SetIn`/`SetError`, `Set-Location` and globally imported modules could leak between test files in a shard, and Write envelopes could write batch-budget state. Mitigation: `try`/`finally` restores in the runner and the tests; envelopes target never-counted paths; `Invoke-PoshQCLeakScan` is clean with no new allowlist entry.
- CI-only behavior: the Linux hook-suite job could fail on path case, drive letters, backslashes or CRLF, and the process-level parity file could time out. Mitigation: `Join-Path` and forward slashes only, case-exact names, LF fixtures, no `artifacts/` reads, a bounded corpus, and timing read from the JUnit `time` attribute of the first CI run.
- Evidence: before and after cost could be missing, non-append-only, or measured on different payloads; a baseline taken after the registration change would be invalid. Mitigation: Phase 0 runs `Measure-HookProcessCost.ps1 -Source Registration` before any registration edit and writes `evidence/baseline/hook-process-cost.<UTC>.md`; the final run uses identical payloads and writes `evidence/regression-testing/hook-process-cost.<UTC>.md`; both carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, and the PR body quotes both.
