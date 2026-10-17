# Research Addendum: PreToolUse hook deny versus `permissions.allow` precedence

Timestamp: 2026-10-08T17-10
Issue: #791 (follow-ups to #763)
Supersedes: the "not stated explicitly" premise recorded in `spec.md` line 216 and the risk entry at `spec.md` line 278 of this feature folder, and the unverified assumption behind #763 D6. The existing `research.2026-10-08T14-00.md` is not modified.

Question: In Claude Code, does a PreToolUse hook that returns `permissionDecision: "deny"` (or exits with code 2) still block a tool call that matches a `permissions.allow` rule? Specifically, can the planned entries `"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"` and `"Bash(bash .claude/lib/bash/remove-parallel-item.sh*)"` bypass `.claude/hooks/enforce-parallel-abandon-gate.ps1`?

## Finding

Finding: deny overrides allow: yes. Basis: the Claude Code permissions documentation states that "A blocking hook also takes precedence over allow rules" and that the block "applies even when an allow rule would otherwise let the call proceed"; the hooks documentation states that `"deny"` prevents the tool call and that an exit-2 block "routes the same way as `"deny"`", which places the JSON `"deny"` emitted by the abandon gate in the same blocking category. The one documented exception (an installed plugin mod handling `tool.check`) is unrelated to `permissions.allow` and is recorded below.

## Verbatim citations

All passages fetched 2026-10-08 with WebFetch.

Fidelity note: the `/permissions` page content was returned as raw page markdown and the passages below are copied from that text. The `/hooks` page (258,323 characters) was returned through the WebFetch summarizer in 100,000-character windows; the passages below were presented as quotations and match the page's table/markdown structure, but byte-exact fidelity of the `/hooks` passages is likely rather than verified. The decisive precedence statement (citation 1) comes from the raw `/permissions` text.

### 1. Hook block takes precedence over allow rules

Source: https://code.claude.com/docs/en/permissions — section "Extend permissions with hooks"

> A blocking hook also takes precedence over allow rules. A hook that exits with code 2 stops the tool call before permission rules are evaluated, so the block applies even when an allow rule would otherwise let the call proceed. To run all Bash commands without prompts except for a few you want blocked, add `"Bash"` to your allow list and register a PreToolUse hook that rejects those specific commands. See [Block edits to protected files](/docs/en/hooks-guide#block-edits-to-protected-files) for a hook script you can adapt.

### 2. Hooks run before the permission prompt and can deny

Source: https://code.claude.com/docs/en/permissions — section "Extend permissions with hooks"

> [Claude Code hooks](/docs/en/hooks-guide) let you register custom shell commands that evaluate permissions at runtime. When Claude Code makes a tool call, PreToolUse hooks run before the permission prompt, for every tool except [`EndConversation`](/docs/en/tools-reference#endconversation-tool-behavior). The hook output can deny the tool call, force a prompt, or skip the prompt to let the call proceed.

### 3. Converse direction: hook allow does not bypass deny/ask rules

Source: https://code.claude.com/docs/en/permissions — section "Extend permissions with hooks"

> PreToolUse hook decisions don't bypass permission rules. Claude Code evaluates deny and ask rules regardless of what a PreToolUse hook returns: a matching deny rule blocks the call, and a matching ask rule still prompts even when the hook returned `"allow"` or `"ask"`. This preserves the deny-first precedence described in [Manage permissions](#manage-permissions), including deny rules set in managed settings.

### 4. Documented exception: installed plugin mods

Source: https://code.claude.com/docs/en/permissions — section "Extend permissions with hooks"

> That precedence covers hooks in settings files and in a plugin's `hooks/hooks.json`. A [mod](/docs/en/plugins/mods/overview) you install that handles `tool.check` answers after the rules and the `PreToolUse` hooks have decided, and its answer can replace theirs:

> * **A block from a `PreToolUse` hook**: the mod can approve the call, unless the hook is in managed settings

### 5. Rule evaluation order among permission rules

Source: https://code.claude.com/docs/en/permissions — section "Manage permissions"

> Rules are evaluated in order: deny, then ask, then allow. The first match in that order determines the outcome, and rule specificity doesn't change the order.

### 6. `permissionDecision` semantics and deny/exit-2 equivalence

Source: https://code.claude.com/docs/en/hooks — section "PreToolUse decision control"

> | `permissionDecision` | `"allow"` skips the permission prompt, except for the [actions no mode auto-approves](/docs/en/permission-modes#actions-no-mode-auto-approves) and for `AskUserQuestion` and `ExitPlanMode`, which need [`updatedInput` paired with it](#allow-with-updatedinput). `"deny"` prevents the tool call. `"ask"` prompts the user to confirm. `"defer"` exits gracefully so the tool can be resumed later. [Deny and ask rules](/docs/en/permissions#manage-permissions) are still evaluated regardless of what the hook returns |

> When multiple PreToolUse hooks return different decisions, precedence is `deny` > `defer` > `ask` > `allow`.

> A hook that blocks by exiting 2 routes the same way as `"deny"`: Claude sees the stderr message as the denial reason.

### 7. Exit code 2 for PreToolUse

Source: https://code.claude.com/docs/en/hooks — section "Exit code 2 behavior per event"

> | `PreToolUse` | Yes | Blocks the tool call |

### 8. Timed-out hooks do not gate

Source: https://code.claude.com/docs/en/hooks — section "Timeouts"

> A timed-out `command`, `http`, or `mcp_tool` hook doesn't block the tool call. The call continues through the normal [permission flow](/docs/en/permissions), so don't count on a stalled hook to act as a gate.

## Repository evidence

Deny-emission mechanism (JSON decision, not exit code 2):

- `.claude/hooks/enforce-parallel-abandon-gate.ps1:254-277` — `Get-ParallelAbandonGateBlockDecision` builds `hookSpecificOutput` with `permissionDecision = 'deny'` (line 273) and `permissionDecisionReason` (line 274).
- `.claude/hooks/enforce-parallel-abandon-gate.ps1:235-252` — `Get-ParallelAbandonGateAllowDecision` builds `permissionDecision = 'allow'` (line 249).
- `.claude/hooks/enforce-parallel-abandon-gate.ps1:301-342` — `Invoke-ParallelAbandonGateDecision`: fails closed (deny) on an unreadable envelope (lines 322-327); returns allow when the command is not in scope (lines 331-333) or carries the confirmation marker (lines 337-339); otherwise deny (line 341).
- `.claude/hooks/enforce-parallel-abandon-gate.ps1:41-42` — scope tokens `--disposition abandon` and `--confirm-abandon`. Scope is determined from command text only, so a `bash .claude/lib/bash/abandon-parallel-item.sh ... --disposition abandon` invocation is in scope by the same token match.
- `.claude/hooks/enforce-parallel-abandon-gate.ps1:349-353` — entrypoint writes the decision as compressed JSON to stdout and always `exit 0`. The hook never uses exit code 2.
- The hook reads no settings file: its only input is the tool payload (line 349, `Get-ParallelAbandonGateToolInput`); no reference to `settings`, `permissions`, or `allow` lists appears in the file (grep for `exit|settings|permissions` returns only line 353).
- `.claude/settings.json:121-124` — the hook is registered as a project-settings PreToolUse command hook (`pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1`).

Pester assertions that observe the decision:

- `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1:29-34` — unconfirmed abandon command yields `permissionDecision` `deny` with reason matching `PARALLEL_ABANDON_BLOCKED`; further deny assertions at lines 45, 51, 78-79, 109-110, 121-122, 133, 140-141; allow assertions at lines 59, 65, 84, 90, 96, 102.
- `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1:66-67, 77-78, 84-85` — deny with `PARALLEL_ABANDON_BLOCKED`; allow at lines 50, 91, 97.
- The suites dot-source the hook and call `Invoke-ParallelAbandonGateDecision` directly with literal JSON (`enforce-parallel-abandon-gate.Tests.ps1:8-11, 20-22`).

Limitation: the Pester suites exercise the hook's decision function in isolation. They demonstrate that the hook emits a JSON `deny` for an unconfirmed abandon command and that this output does not depend on settings contents. They cannot demonstrate how the Claude Code runtime combines that decision with `permissions.allow`; that precedence is established only by the documentation cited above.

Existing coexistence in this repository:

- `.claude/settings.json:6` already allows `"Bash(poetry run *)"`, and the abandon gate denies the `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py ... --disposition abandon ...` form (`enforce-parallel-abandon-gate.Tests.ps1:24, 29-34`). The planned allow entries therefore do not introduce a new allow/hook-deny overlap; the same overlap is already in place for the Python CLI form.
- `.claude/settings.json:8-10` already allows three `Bash(bash .claude/lib/bash/<script>.sh*)` entries, which is the pattern the plan follows.

Repository documentation on precedence:

- No file under `.claude/rules/`, `.claude/skills/`, or `docs/` records the documented precedence (regex search for hook/allow override/precedence/bypass phrasing). The only statements found are this feature's `spec.md:216` and `spec.md:278`, which record it as an unverified assumption, and #763 `spec.md:93-94` (D6), which declined the allow entry on the basis that "the hook already gates the destructive command".

## Implication for the plan

The documented precedence supports the allow entries as specified in spec D3: a matching `permissions.allow` rule does not override the abandon gate's `deny`, so `"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"` cannot be used to run an unconfirmed `--disposition abandon` command. No narrowing is required on precedence grounds.

Recommended plan changes:

1. Add an evidence task (option b) that records the documented passages verbatim in an evidence artifact under the feature's canonical `evidence/<kind>/` path (for example `evidence/other/`), citing URL, section heading, and fetch date. This addendum may serve as the source.
2. A grep-based assertion against this addendum may use these exact single-line tokens, each of which appears on one line above:
   - `A blocking hook also takes precedence over allow rules.`
   - `so the block applies even when an allow rule would otherwise let the call proceed`
   - `A hook that blocks by exiting 2 routes the same way as`
3. Update the risk wording at `spec.md:216` and `spec.md:278` from "unverified assumption" to "documented precedence", citing citation 1 and citation 6. That is a spec edit for the planner/orchestrator; this addendum does not modify `spec.md`.

Residual caveats to record in the plan, stated without overstating them:

- The precedence sentence in citation 1 names exit code 2 explicitly; the JSON `"deny"` used by this hook is covered by citation 6 ("`"deny"` prevents the tool call" and exit 2 "routes the same way as `"deny"`"). The equivalence is documented, but the link is two passages rather than one.
- Citation 4: an installed plugin mod that handles `tool.check` can approve a call blocked by a project-settings PreToolUse hook. This is independent of `permissions.allow` and applies equally with or without the new entries.
- Citation 8: a timed-out command hook does not block. If the `pwsh` hook times out, the call falls through to the permission flow, where the new allow entry would then approve it without a prompt. Without the entry, the same timeout would fall through to a permission prompt. This is the one scenario where the allow entry changes the outcome; it is a fail-open property of hook timeouts, not of rule precedence.
- Observation (not verified at runtime): the abandon gate returns `permissionDecision: "allow"` for every out-of-scope and every confirmed command (lines 331-339). Per citation 6, `"allow"` skips the permission prompt, subject to other hooks' decisions (`deny` > `defer` > `ask` > `allow`) and to deny/ask rules. This suggests the prompt anticipated by #763 D6 for a confirmed abandon command may already be skipped by the hook itself; that runtime behavior was not tested in this research.
