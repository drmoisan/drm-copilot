# Research: PreToolUse hooks parse a flat payload and always allow (#501)

- Date: 2026-08-21
- Issue: #501 (Blocker)
- Feature folder: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
- Authoritative problem statement: `issue.md` in this feature folder

## Executive Summary — the defect is larger than the issue states

The issue frames the defect as a shape error: hooks read `$toolInput.command` where the payload
nests the tool arguments under `tool_input`. Research confirms the shape error and finds a second,
prior defect underneath it: **the transport is also wrong**. Official Claude Code documentation
(https://code.claude.com/docs/en/hooks, fetched 2026-08-21) states that command-hook input arrives
on **stdin as JSON** and enumerates the environment variables set for hook processes
(`CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_CODE_REMOTE`,
`CLAUDE_CODE_BRIDGE_SESSION_ID`, `CLAUDE_EFFORT`, `CLAUDE_PLUGIN_OPTION_<KEY>`). Neither
`CLAUDE_TOOL_INPUT` nor `CLAUDE_HOOK_INPUT` appears anywhere in the documentation. Every
`PreToolUse` hook in `.claude/hooks/` reads one or both of those variables and never reads stdin,
so at runtime each hook receives an empty payload, takes its empty-input early return, and allows.
Fixing only the property nesting would leave the hooks exactly as inert as they are today.

Consequently the fix has two mandatory legs, not one:

1. **Transport**: read the payload from stdin, with the existing environment variables retained as
   a fallback (precedent: `.claude/hooks/persist-session-id.ps1` `Read-HookPayload`, and the entire
   `.codex/hooks/` surface, which already reads `[Console]::In.ReadToEnd()`).
2. **Shape**: extract tool arguments from the envelope's `tool_input` object, not the root.

A third latent fail-open is recorded for the planner: the hooks' malformed-JSON path does
`throw` → `exit 1`. Per the documentation, only exit code 2 (or exit 0 with a deny JSON) blocks a
tool call; exit 1 is a non-blocking error. A hook that "fails" with exit 1 still lets the tool call
proceed. The fix should convert envelope anomalies into an emitted deny decision (exit 0 + JSON) or
exit 2, not exit 1.

## Q1 — The actual envelope

### Q1a. Transport

**Finding: stdin, as a single JSON object. The environment variables this repository reads are not
set by the harness.**

Evidence, by source class:

- **Official documentation** (https://code.claude.com/docs/en/hooks, fetched 2026-08-21 via
  redirect from docs.anthropic.com): "For command hooks, input arrives on stdin. For HTTP hooks, it
  arrives as the POST request body." The documented hook-process environment-variable list does not
  contain `CLAUDE_TOOL_INPUT` or `CLAUDE_HOOK_INPUT`. A follow-up query against the same page
  confirmed: "No, the documentation does not mention environment variables named
  `CLAUDE_TOOL_INPUT` or `CLAUDE_HOOK_INPUT`."
- **Prior in-repo research** (issue #334):
  `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/research/2026-07-09T09-50-subagent-tree-mcp-and-dropdown-334-research.md`
  lines 264-265 record the same contract ("Every hook event receives `session_id`,
  `transcript_path`, `cwd`, `hook_event_name` (and more) as JSON on stdin"), and
  `persist-session-id.ps1` was built stdin-first on that finding.
- **Codex-surface precedent**: the analogous transport defect was found and fixed on the Codex
  surface (`docs/features/potential/promoted/2026-07-25-codex-pretooluse-hook-transport.md`); every
  `.codex/hooks/*.ps1` entry point now reads `[Console]::In.ReadToEnd()`.
- **Field observation** (issue #501 Logs section): in a TaskMaster session on 2026-08-21, four
  `gh pr merge --merge` invocations, PR-creation paths, and issue-creation paths all completed with
  no hook objection. This is consistent with the env-var transport delivering nothing; it is not
  consistent with any transport theory under which the hooks receive the command text.
- **Provenance of the wrong belief**:
  `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/research/claude-runtime-integration-mechanics.2026-08-19T08-39.md`
  line 33 asserts `$env:CLAUDE_TOOL_INPUT` carries the tool parameter object and that "No hook
  reads stdin"; `docs/features/completed/2026-06-27-harden-claude-pretooluse-hook-schema-259/spec.md`
  line 37 asserts delivery "on standard input and via the environment variables". Neither claim
  cites an observed payload. These artifacts are how the wrong transport propagated.

Residual uncertainty and how the fix neutralizes it: no artifact in this repository records a
captured live payload, and this research agent has no shell tool to capture one. It is therefore
possible (though undocumented and unevidenced) that some wrapper sets the environment variables in
some configuration. The recommended reader reads **stdin first and falls back to
`CLAUDE_HOOK_INPUT` then `CLAUDE_TOOL_INPUT`** (the `persist-session-id.ps1` pattern), so the fix
is correct under either state of the world. An optional live-capture verification step is described
under Automation Feasibility.

### Q1b. Shape

Per the official documentation (source: docs fetch above, verbatim example), the `PreToolUse` input
object's top-level keys are:

`session_id`, `prompt_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`,
`tool_name`, `tool_input`, `tool_use_id` — plus `agent_id` and `agent_type` when the tool call is
made inside a subagent, and an `effort` object.

The tool arguments are nested one level down under `tool_input`. Documented example:

```json
{
  "session_id": "abc123",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test", "description": "Run test suite" },
  "tool_use_id": "toolu_01ABC123..."
}
```

This **confirms** `tool_name` + `tool_input.<property>` and **refutes** the flat root shape every
hook currently parses. The `agent_type` top-level key confirms the reading already implemented in
`enforce-epic-invocation-origin.ps1` (caller identity off the envelope root, target
`subagent_type` off `tool_input`).

## Q2 — Per-event variation

Events wired in `.claude/settings.json` (this repository uses no `PostToolUse` hooks):

| Event | Registered hooks | Documented input envelope |
| --- | --- | --- |
| `SessionStart` | `persist-session-id.ps1` | Common fields (`session_id`, `transcript_path`, `cwd`, `hook_event_name`, ...) plus optional `model`. `session_id` is a **root** key, so this hook's root-level read is correct. Already stdin-first. Not affected by the fix. |
| `PreToolUse` | 24 unique hook files (8 Bash-matcher, 11 Write\|Edit-matcher, 7 Agent-matcher; `enforce-orchestration-preimplementation-gate.ps1` appears in all three) | Common fields plus `tool_name`, `tool_input` (nested arguments), `tool_use_id`. This is the envelope the fix targets. |
| `PostToolUse` | none registered | Same pattern as PreToolUse plus `tool_response`. Not in scope; nothing to break. |
| `SubagentStop` | one inline `pwsh -Command` hook plus `validate-discovery-artifact-gate.ps1`, `validate-feature-review-coverage.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-orchestrator-output.ps1` (three parameterizations) | Common fields plus subagent fields; the documentation directs hooks needing the final assistant text to a `last_assistant_message` field. It does not document an `output` field. |

**Adjacent defect, out of #501 scope, must not be silently absorbed into the fix**: every
SubagentStop validator reads `$env:CLAUDE_HOOK_INPUT` (undocumented variable) and extracts
`$payload.output` (undocumented field; docs indicate `last_assistant_message`). These validators
are therefore very likely inert in the same way — but on a different envelope, with different
correct field names, and with exit-code semantics (`exit 2` blocks a Stop) that differ from
PreToolUse. The #501 fix must leave the SubagentStop hooks' parsing unchanged so it cannot break
them further, and this finding should be promoted as its own potential-bug entry. The shared reader
recommended below is designed so a follow-up fix for SubagentStop can reuse its stdin transport
function without rework.

## Q3 — Complete affected-file inventory

All 24 PreToolUse hook files read environment variables and never stdin (transport defect: 24/24).
23 of 24 additionally read the tool property off the parsed **root** (shape defect); only
`enforce-epic-invocation-origin.ps1` reads the nested shape (with a root-shape `CLAUDE_TOOL_INPUT`
leg). The issue's "20 of 36" undercounts; the verified enumeration:

| Hook (`.claude/hooks/`) | Matcher(s) | Property read | Location | Root or nested |
| --- | --- | --- | --- | --- |
| `validate-bash.ps1` | Bash | `command` | line 124-125 (`$parsed.command`; unparseable raw treated as the command; falls back `CLAUDE_TOOL_INPUT` → `CLAUDE_HOOK_INPUT`, lines 169-172) | root |
| `enforce-promotion-mcp-only.ps1` | Bash | `command` | line 211 | root |
| `enforce-pr-author-skill.ps1` | Bash | `command` | line 372 | root |
| `enforce-orchestration-preimplementation-gate.ps1` | Bash, Write\|Edit, Agent | `file_path` | line 181 (`Get-StringProperty -Value $toolInput -Name 'file_path'`) | root |
| `enforce-epic-merge-gate.ps1` | Bash | `command` | line 363 | root |
| `enforce-epic-worktree-removal-gate.ps1` | Bash | `command` | line 194 | root |
| `enforce-parallel-worktree-removal-gate.ps1` | Bash | `command` | line 201 | root |
| `enforce-parallel-abandon-gate.ps1` | Bash | `command` | line 231; env read wrapped in a seam function at line 56 | root |
| `check-python-test-purity.ps1` | Write\|Edit | `file_path`, `content`, `new_string` | lines 78-91 | root |
| `enforce-python-batch-budget.ps1` | Write\|Edit | `file_path` | line 175 | root |
| `check-powershell-test-purity.ps1` | Write\|Edit | `file_path`, `content`, `new_string` | lines 82-96 | root |
| `enforce-powershell-batch-budget.ps1` | Write\|Edit | `file_path` | line 178 | root |
| `enforce-evidence-locations.ps1` | Write\|Edit | `file_path` | line 132 | root |
| `enforce-feature-folder-order.ps1` | Write\|Edit | `file_path` | line 111 | root |
| `enforce-checkpoint-monotonic.ps1` | Write\|Edit | `file_path`, `content` | lines 219, 231 | root |
| `enforce-completion-consistency.ps1` | Write\|Edit | `file_path`, `content` | lines 346, 359 | root |
| `enforce-discovery-artifact-gate.ps1` | Write\|Edit | `file_path`, `content` (via `PSObject.Properties`) | lines 177-186 | root |
| `enforce-mermaid-validation.ps1` | Write\|Edit | `file_path`, `content` (via `Get-MermaidToolInputField`) | lines 311, 330 | root |
| `enforce-prd-feature-before-planner.ps1` | Agent | `subagent_type`, `prompt` | lines 172, 177 | root |
| `enforce-epic-wave-barrier.ps1` | Agent | `subagent_type`, `prompt` | lines 257, 262 | root |
| `enforce-model-routing-receipt.ps1` | Agent | `subagent_type` | line 145 | root |
| `enforce-parallel-cohort-barrier.ps1` | Agent | `subagent_type`, `prompt` | lines 452, 457 | root |
| `enforce-parallel-drift-gate.ps1` | Agent | `subagent_type`, `prompt` | lines 291, 294 | root |
| `enforce-epic-invocation-origin.ps1` | Agent | `subagent_type` (root of `CLAUDE_TOOL_INPUT`, then nested `tool_input.subagent_type` of `CLAUDE_HOOK_INPUT`); `agent_type` off the envelope root | lines 129-146, 168-176 | **nested-aware, env transport** |

Non-parsing helper files (receive already-extracted values; no change needed beyond call-site
updates if signatures move): `enforce-completion-helpers.ps1`,
`enforce-parallel-drift-gate-helpers.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`.

SubagentStop-envelope readers (out of #501 fix scope, see Q2): `validate-discovery-artifact-gate.ps1`,
`validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`,
`validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`,
`validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1` — all read
`$env:CLAUDE_HOOK_INPUT` root `output`.

Correct already: `persist-session-id.ps1` (stdin-first with env fallback; root `session_id` is the
documented location for SessionStart).

**On reusing `enforce-epic-invocation-origin.ps1`'s reader**: its nested extraction logic
(`Get-EpicInvocationOriginTargetSubagent`, lines 129-146) is shape-correct and its
`PSObject.Properties.Name -contains` guard style is the right defensive pattern; its transport is
wrong (env vars only). The shape logic is a valid model for the shared reader; the transport must
come from the `persist-session-id.ps1` / `.codex/hooks` stdin pattern.

**Mirror**: all 36 files are mirrored under
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` with the same defects at
the same line numbers (verified by matching greps, e.g. mirror `enforce-epic-merge-gate.ps1:363`
`$commandText = $toolInput.command`). Byte parity between repo-root `.claude/**` and the bundle is
already enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, so a fix that touches
`.claude/hooks/` or `.claude/lib/` **fails CI unless the mirror is updated in the same change** —
the sync obligation is mechanically enforced, not aspirational.

**`.codex/hooks/`**: not affected. Every Codex hook entry point already reads
`[Console]::In.ReadToEnd()` (verified by grep across all 26 files) and parses the Codex envelope,
fixed under the 2026-07-25 codex-pretooluse-hook-transport item. Do not touch.

## Q4 — Test-suite inventory

All hook suites live in `tests/scripts/claude-hooks/` (43 files). A repository-wide grep shows
exactly one suite mentioning `tool_input`: `enforce-epic-invocation-origin.Tests.ps1`. Every other
PreToolUse suite constructs the **flat** shape and passes it to the hook's decision function via
`-ToolInputRaw`, e.g. `enforce-epic-merge-gate.Tests.ps1` line 43: `$json = '{"command":"gh pr merge --merge"}'`.

Suites that must migrate to the nested envelope (and gain stdin-transport coverage at the
entry-point seam): `validate-bash`, `enforce-promotion-mcp-only`, `enforce-pr-author-skill` (plus
`.OrchestratorStatePreflight` and `.epic-base-branch` companions where they exercise the parse),
`enforce-orchestration-preimplementation-gate`, `enforce-epic-merge-gate`,
`enforce-epic-worktree-removal-gate`, `enforce-parallel-worktree-removal-gate`,
`enforce-parallel-abandon-gate`, `check-python-test-purity`, `enforce-python-batch-budget`,
`check-powershell-test-purity`, `enforce-powershell-batch-budget`, `enforce-evidence-locations`,
`enforce-feature-folder-order`, `enforce-checkpoint-monotonic`, `enforce-completion-consistency`,
`enforce-discovery-artifact-gate` (+`.ValidatorDispatch`), `enforce-mermaid-validation`,
`enforce-prd-feature-before-planner`, `enforce-epic-wave-barrier`, `enforce-model-routing-receipt`,
`enforce-parallel-cohort-barrier`, `enforce-parallel-drift-gate` (+`-helpers`),
`enforce-epic-invocation-origin` (extend, already nested-aware).

Out of migration scope: `persist-session-id.Tests.ps1` (already stdin/fallback),
`enforce-completion-consistency-codex.Tests.ps1` (Codex surface), the eight `validate-*` SubagentStop
suites (different envelope, unchanged by this fix), and
`PreToolUseSchema.Contract.Tests.ps1` (asserts the **output** deny schema; unaffected, but it is the
natural home for the new input-envelope contract assertions — see Q7).

Tests are not part of the push-down parity scope, so test changes are single-copy.

## Q5 — Fix-shape options and recommendation

### Option A (recommended): shared payload-reader module under `.claude/lib/`

A small module, e.g. `.claude/lib/hook-payload/HookPayload.psm1`, exporting approximately:

- `Read-ClaudeHookRawPayload` — stdin-first (`[Console]::In.ReadToEnd()` behind an injectable
  scriptblock seam, per the `persist-session-id.ps1` precedent), falling back to
  `$env:CLAUDE_HOOK_INPUT` then `$env:CLAUDE_TOOL_INPUT`. Returns the raw string.
- `ConvertFrom-ClaudeHookEnvelope` — parses the raw JSON, returns the envelope object or a typed
  failure; never a silent `$null`-for-malformed.
- `Get-ClaudeHookToolInput` — returns the envelope's `tool_input` object (see Q6 for the
  flat-shape policy).

Each hook imports it with `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force`
and keeps its pure decision function, now taking the extracted `tool_input` (or the raw envelope)
instead of re-parsing a flat root.

Assessment against the required criteria:

- **Mirror sync**: the module lands under `.claude/lib/`, which is inside the byte-parity scope
  enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`; the mirror copy is
  mandatory and mechanically checked. The mirrored hooks resolve `../lib/` relative to their own
  `$PSScriptRoot`, so the reference works identically in the destination repository (the bundle
  preserves the `.claude/hooks` / `.claude/lib` sibling layout).
- **Dot-source/import feasibility under `pwsh -NoProfile -File <path>`**: proven, not speculative —
  `enforce-pr-author-skill.ps1:49`, `enforce-mermaid-validation.ps1:58,77`,
  `enforce-discovery-artifact-gate.ps1:65,70`, and `validate-orchestrator-output.ps1:41` already
  `Import-Module` from `.claude/lib/` via `$PSScriptRoot`-relative paths.
- **Path resolution from an arbitrary working directory**: `$PSScriptRoot`-relative resolution is
  cwd-independent, unlike the checkpoint-file reads the hooks perform (which remain cwd-relative by
  design).
- **Per-hook startup cost**: one additional `Import-Module` of a small `.psm1` per invocation,
  comparable to the imports four hooks already perform. Eight Bash-matcher hooks run per Bash call
  today with module imports among them and no observed latency complaint.
- **File-size budget**: the 500-line ceiling bites here. `enforce-parallel-cohort-barrier.ps1`'s
  entry point sits at line 491; an inline stdin+envelope+fallback reader (~25-35 lines) duplicated
  into each of 24 hooks would push at least one file over the limit and add ~600-800 duplicated
  lines across the surface. The module adds ~3 lines per hook.
- **Coverage**: one module tested once (new suite at
  `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`, mirroring the existing
  `tests/scripts/claude-lib/` layout) instead of 24 duplicated parse paths each needing >= 85% line
  coverage.

### Option B: per-hook inline correction, no shared module

Every hook gains its own stdin read, envelope parse, and nested extraction. Rejected: 24 duplicated
implementations of exactly the contract whose per-hook re-implementation caused this defect (the
issue's own Suspected Cause: "the PreToolUse payload contract was never captured as a single shared
reader; each hook re-implements the parse inline, so the wrong shape propagated by copy"). It also
breaks the 500-line budget on at least one file, multiplies the test surface, and gives the Q7
regression guard nothing structural to assert against.

**Recommendation: Option A.** It is also the option the repository's own history endorses twice:
the Codex surface centralized its payload parse (`ConvertFrom-CodexPreToolUsePayload`) when fixing
the identical transport defect, and `enforce-epic-invocation-origin.ps1` shows what happens when a
correct parse exists in one file but has no shared home — it does not spread.

**No `.claude/settings.json` change is required, as a finding rather than a constraint.** The
harness pipes the payload to the spawned process's stdin under the existing
`pwsh -NoProfile -File <path>` command lines, and module resolution is `$PSScriptRoot`-relative, so
neither the transport fix nor the shared reader needs a different invocation form or any new
registration. A settings change was considered and found unnecessary, not avoided.

## Q6 — Backward compatibility: strict nested reader, fail-closed anomalies

**Recommendation: do not accept the flat shape.** Three-part policy, distinguishing envelope-level
from property-level absence:

1. **Envelope-level strictness (fail closed).** If the payload parses as JSON but carries no
   `tool_input` key, the reader reports an envelope anomaly and the hook emits a **deny** decision
   naming the anomaly (exit 0 + deny JSON, which the harness honors; not exit 1, which it treats as
   non-blocking). Rationale: per the documented contract every PreToolUse delivery carries
   `tool_input`, so a shape mismatch at runtime means the contract drifted — exactly the condition
   that produced #501 — and it must fail loudly. A permissive flat fallback would keep every
   legacy-shaped test green and reproduce the false-confidence mechanism that hid this defect;
   worse, a future harness change would again degrade to silent allow.
2. **Property-level tolerance (unchanged early returns).** Absence of `command` / `file_path` /
   `subagent_type` *inside* `tool_input` remains an allow. This is each hook's scope filter, not a
   shape failure: `enforce-orchestration-preimplementation-gate.ps1` is registered on Bash, Write|Edit,
   and Agent and legitimately sees no `file_path` on a Bash call; an Edit call carries `new_string`
   rather than `content`. These guards are correct once they read the right object.
3. **Empty-input policy (fail closed for gating hooks).** With stdin plus both env fallbacks empty,
   today's behavior is a silent allow — that is the live failure mode when only env vars are read.
   After the transport fix, a genuinely empty delivery for a PreToolUse hook is a harness anomaly
   and should also deny with a distinct reason. Consequence to weigh: a developer running a hook
   manually with no piped input will now see a deny instead of an allow; that is the desired
   behavior for an enforcement gate and matches the fail-closed posture of
   `enforce-epic-merge-gate.ps1`'s own EPIC_MERGE_GATE_BLOCKED branch. (`validate-bash.ps1`, which
   is a dangerous-command denylist rather than a receipt gate, can retain allow-on-empty without
   weakening any safety argument; the planner may treat it as the one deliberate exception, and
   must keep its documented CLI/manual usage working.)

Consequence for the test suites: every flat-shape fixture fails against the strict reader, which is
the point — the migration is forced and visible, and a suite that keeps asserting the flat shape
cannot pass.

## Q7 — Regression guards

Two guards, both automatable:

1. **No direct root reads / mandatory shared reader.** A static contract suite (natural home:
   extend `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, or a sibling
   `PreToolUsePayload.Contract.Tests.ps1`; precedent for source-scanning contract tests:
   `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`). For every hook
   registered under `PreToolUse` in `.claude/settings.json` (derive the list by parsing
   settings.json so a newly registered hook is automatically in scope), assert over the file text:
   - it contains an `Import-Module` reference to the shared payload module and a call to the
     reader entry point;
   - it does not contain `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT` (those literals may
     appear only inside the shared module's fallback);
   - it does not match a root-property access pattern such as
     `\$toolInput\.(command|file_path|subagent_type|prompt|content|new_string)` on a variable
     assigned directly from `ConvertFrom-Json` of the raw payload — operationally, the simplest
     robust assertion is the pair above (env-literal ban + mandatory reader call), which makes a
     bypass require deliberately re-implementing both transport and parse.
   Complement per hook with one behavioral negative test: a nested-envelope payload that must
   produce `permissionDecision: deny`.
2. **Mirror divergence.** Already enforced: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
   (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) asserts byte parity for
   all `.claude/**` files between the repo root and
   `extensions/drm-copilot/resources/claude-customizations/`. No new guard is needed; the plan must
   simply copy every changed hook and the new module into the mirror, and the executor should run
   this pytest as an acceptance gate. If the planner wants belt-and-braces, a Pester assertion that
   each `.claude/hooks/*.ps1` file's hash equals its mirror counterpart is cheap, but it duplicates
   the pytest.

## Q8 — Blast confirmation (`enforce-epic-merge-gate.ps1`)

This agent has no shell tool, so the differential could not be executed here; two evidence classes
are recorded instead, and the exact commands are supplied for the executor to run and file as
baseline evidence.

**Recorded observed run (issue #501, Logs / Screenshots, executed by the issue author on
2026-08-21 against the same code):** under the nested shape the hook emits a `PreToolUse` result
whose `permissionDecision` is `allow` and which carries no reason; under the flat shape the same
hook emits `permissionDecision` `deny` with a reason beginning `EPIC_MERGE_GATE_BLOCKED:` and
ending `No checkpoint satisfied this gate.`

**Independent static trace (this research, against
`.claude/hooks/enforce-epic-merge-gate.ps1` at worktree HEAD `fb30a9a5`):**

- Nested payload `{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}`:
  `Invoke-EpicMergeGateDecision` line 363 assigns `$toolInput.command`; the parsed root has no
  `command` member, so PowerShell resolves the access to `$null`; the guard at line 364
  (`if (-not $commandText)`) returns `Get-EpicMergeGateAllowDecision` (lines 308-319). Emitted
  through the entry point's `ConvertTo-Json -Compress`:
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}`
  The checkpoint logic at lines 376-388 is unreachable. The gate cannot deny any command under any
  checkpoint state.
- Flat payload `{"command":"gh pr merge 999 --merge"}`: `command` matches both regexes at line 370;
  with no checkpoint satisfying lines 376-388 the function returns the block decision (line 391):
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: ... No checkpoint satisfied this gate."}}`
- Under the true harness delivery (stdin; `CLAUDE_TOOL_INPUT` unset), `$ToolInputRaw` is empty and
  line 353 returns the allow decision before any parse — the gate is inert one guard earlier still.

**Executor reproduction commands** (run from the feature worktree root with no qualifying
checkpoint present; record both outputs under
`docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/evidence/baseline/`):

```powershell
$env:CLAUDE_TOOL_INPUT = '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}'
pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1   # expect (defective): allow

$env:CLAUDE_TOOL_INPUT = '{"command":"gh pr merge 999 --merge"}'
pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1   # expect: deny EPIC_MERGE_GATE_BLOCKED

Remove-Item Env:CLAUDE_TOOL_INPUT
'{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}' |
  pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1   # true harness transport; expect (defective): allow
```

## Hard constraints inherited by the plan

- **`.claude/settings.json` needs no change for this fix** (finding, not a scoping rule; an
  earlier delegation constraint prohibiting edits to this file was withdrawn by the user
  mid-research). The correct fix reads stdin inside each hook script and imports the shared module
  `$PSScriptRoot`-relative, so the existing `pwsh -NoProfile -File` command lines already deliver
  everything required. The planner should not add a settings change that the fix does not need.
- **No Python in the enforcement hooks.** Bash preferred, PowerShell acceptable; the fix stays
  PowerShell (shared `.psm1` + hook edits). The regression guard's settings.json parsing happens in
  test code (Pester/pytest), not in a hook.
- **Mirror must change with the originals.** Every modified hook and the new module must be copied
  byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/...`;
  `test_push_down_claude_resource_contracts.py` fails otherwise.
- **`.codex/hooks/` are out of scope** — already stdin-correct for their own envelope.
- **SubagentStop hooks are out of scope for behavior change** — different envelope
  (`last_assistant_message`, not `output`); their equivalent defect should be filed separately.
- **PowerShell coverage policy**: line coverage >= 85%; no branch gate (Pester does not measure
  branch coverage); the new module and every touched hook remain in the coverage denominator; the
  500-line file ceiling applies to the module and to each hook after edits.
- **Malformed-JSON / anomaly paths must not exit 1** if they intend to block: exit 1 is
  non-blocking for PreToolUse; block via exit 0 + deny JSON (repository convention) or exit 2.

## Behavior semantics for the fix

- Success: a PreToolUse delivery whose `tool_input` carries the gated property reaches the existing
  decision logic unchanged; all existing deny conditions fire under the nested envelope.
- Allow conditions preserved: property absent *within* a well-formed `tool_input` (hook scope
  filter); tool/command outside the hook's regex scope; checkpoint states that legitimately
  authorize.
- New deny conditions: payload empty on all transports (except any deliberate `validate-bash`
  exemption), payload unparseable, payload parsed but missing `tool_input`.
- Ordering: stdin → `CLAUDE_HOOK_INPUT` → `CLAUDE_TOOL_INPUT`; first non-whitespace source wins
  (matching `Read-HookPayload` precedent, extended with the second variable).
- Edge cases the tests must pin: stdin read throwing (fall back, per `persist-session-id`), CRLF
  and BOM in stdin text, `tool_input` present but `$null`, `tool_input` present as a non-object,
  Agent-matcher envelope carrying root `agent_type` (must remain readable off the envelope root for
  `enforce-epic-invocation-origin.ps1`), Edit payload carrying `new_string`/`old_string` without
  `content`.

## Testing implications

- New module suite `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`: transport
  precedence, fallback, anomaly classification, nested extraction, the edge cases above. No
  temporary files; stdin is injected through the scriptblock seam.
- Per-hook suites migrate every payload fixture to the nested envelope and add one negative
  (deny-under-nested-envelope) test per hook — the test class the issue's Proposed Fix requires.
- Contract suite additions per Q7 guard 1.
- Acceptance gates: `mcp__drm-copilot__run_poshqc_format` → `run_poshqc_analyze` →
  `run_poshqc_test` (>= 85% line coverage), plus
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for
  mirror parity. Per `.claude/rules/plan-acceptance-gates.md`, coverage arguments must use dotted
  module form where applicable and search-based gates must assert single-line, plan-quoted tokens.

## Automation Feasibility

Every step of the fix and its verification is automatable; no step requires human interaction.
Basis:

- Code and test edits: file writes under `.claude/hooks/`, `.claude/lib/`, the mirror, and
  `tests/` — standard agent operations.
- Verification: PoshQC format/analyze/test via MCP tools; pytest for mirror parity; the Q8
  differential reproduction is three non-interactive `pwsh -NoProfile -File` invocations with
  piped/env payloads and deterministic expected outputs.
- The one optional step that exceeds pure automation is capturing a **live** harness payload to
  re-confirm the documented envelope against this exact Claude Code version. It can be executed
  without human action in any running session (the fixed hooks themselves will demonstrate receipt
  the first time a gate fires, and an env-gated debug write inside the shared reader can persist
  one raw payload for inspection), but it requires a live session rather than a test runner. It is
  a confirmation, not a dependency: the fix is correct under the documented contract and remains
  correct under the env-var fallback if any wrapper sets those variables.

## Rejected alternatives (brief)

- **Per-hook inline correction (Option B)**: duplicates the contract 24 times, breaks the 500-line
  budget on at least one hook, multiplies test surface, defeats the structural regression guard.
- **Permissive dual-shape reader**: keeps wrong-shape tests green and restores the silent-allow
  failure mode on the next contract drift; rejected in favor of envelope-strict/property-tolerant.
- **Bash rewrite of the hooks**: bash is the preferred hook language for new enforcement surfaces,
  but rewriting 24 working PowerShell decision engines is a scope explosion unrelated to the
  defect; the fix corrects transport and shape only.
- **Registering a single wrapper/dispatcher hook in settings.json**: replacing the per-hook
  registrations with one dispatcher script would consolidate the payload read and reduce the eight
  `pwsh` spawns per Bash call to one. Rejected on merits, not on scheduling: it adds a routing
  layer that is unnecessary for correctness (stdin already reaches every hook under the current
  registrations), changes deny/allow aggregation semantics that the current matcher-level fan-out
  provides for free, and couples an unrelated performance refactor to a Blocker fix. If spawn
  overhead ever warrants consolidation, it should be its own feature.
