# Research: Concurrency and Hardening Mechanisms for epic-orchestrate

- **Feature:** epic-orchestrate (Issue #275)
- **Feature folder:** `docs/features/active/2026-07-02-epic-orchestrate-275/`
- **Timestamp:** 2026-07-02T20-00
- **Scope:** Hook/validator feasibility for hard-gating epic-orchestrate invariants (PR base-branch
  override, merge-only-after-CI-green, wave-barrier enforcement, worktree-removal-only-after-merge)
  and merge-conflict-as-remediation-finding feasibility.

This is a research artifact. It records verified findings and feasibility conclusions; it does not
commit to final design choices for the atomic plan.

---

## 1. Existing Hook Patterns for Hard Gating

Five hooks were read in full. Each is a template for how `epic-orchestrate` hardening should be
built.

### 1.1 `.claude/hooks/enforce-pr-author-skill.ps1`

- **Event type:** `PreToolUse` (confirmed by `hookEventName = 'PreToolUse'` in every returned
  decision object, e.g. lines 371-375, 394-400).
- **Matcher/trigger:** Registered under the `Bash` matcher in `.claude/settings.json` (see §2). It
  self-scopes further by regex-matching the command text for `gh pr create` / `gh pr edit`
  (`enforce-pr-author-skill.ps1:270-271`: `$isPrCreate = $CommandText -match '(?i)\bgh\s+pr\s+create\b'`).
- **Seams read:** `CLAUDE_TOOL_INPUT` env var (JSON with a `.command` field, line 344:
  `$commandText = $toolInput.command`); filesystem existence of
  `artifacts/pr_context.summary.txt` via `Get-PrContextArtifactExistence` (lines 46-58, wraps
  `Test-Path`); PR body file bytes via `Get-PrBodyFileBytes` (lines 60-86, wraps
  `[System.IO.File]::ReadAllBytes`); sibling receipt JSON via `Get-PrAuthorReceiptContent` (lines
  88-113, wraps `Get-Content -Raw`); receipt-vs-context staleness via
  `Get-PrContextSummaryLastWriteUtc` (lines 115-135, wraps `(Get-Item ...).LastWriteTimeUtc`).
- **Fail-closed behavior:** Five ordered checks in `Test-PrAuthorReceiptVerification` (lines
  137-237) — non-canonical body path, missing receipt, number mismatch, SHA-256 hash mismatch,
  stale `created_at` — each short-circuits to a `deny` decision with a named reason code (e.g.
  `PR_BODY_PATH_NONCANONICAL`, `PR_AUTHOR_RECEIPT_HASH_MISMATCH`, line 172, 199, 217, 228). Malformed
  `CLAUDE_TOOL_INPUT` JSON throws (line 341: `throw "enforce-pr-author-skill hook received
  malformed JSON..."`), which is caught by the entry-point `try/catch` at lines 432-437 and causes
  `exit 1` — a hard failure, not a silent allow. The hook's own doc comment (lines 33-39) explicitly
  states the receipt is "a policy-level integrity check... not a cryptographic or security boundary"
  because "any actor with Write access to artifacts/ can replace both the body file and the receipt
  together." This caveat is directly relevant to epic-mode merge gating: a checkpoint-based gate has
  the same non-adversarial-but-policy-enforcing character.

### 1.2 `.claude/hooks/validate-orchestrator-output.ps1`

- **Event type:** `SubagentStop` (confirmed by the doc header, line 2: "SubagentStop hook for the
  orchestrator subagent," and by `.claude/settings.json:168-174` registering it under matcher
  `atomic-planner` — actually registered as `validate-planner-output.ps1` there; this specific
  script's own registration is inferred from its purpose and the parallel `pr-author` pattern at
  `.claude/settings.json:177-184`. Its file-level contract is unambiguous: it reads
  `CLAUDE_HOOK_INPUT`, not `CLAUDE_TOOL_INPUT`, which is the `SubagentStop` payload shape used
  elsewhere in this repo, e.g. `.claude/settings.json:154`).
- **Matcher/trigger:** Fires on orchestrator subagent termination attempts.
- **Seams read:** `CLAUDE_HOOK_INPUT` JSON `.output` field (agent's final message, lines 225-231);
  checkpoint file content via injectable `Get-CheckpointFileContent` (lines 35-58, wraps
  `Test-Path`/`Get-Content -Raw`); an external Python validator subprocess via injectable
  `Invoke-RoutingContractValidation` (lines 144-194) whose default `$Invoker` shells out to
  `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path>
  --require-complete` (lines 169-177) and captures both `$LASTEXITCODE` and combined output.
- **Fail-closed behavior:** Blocks (returns `Ok = $false`) on: empty `CLAUDE_HOOK_INPUT` (line
  216), malformed JSON (line 222), empty agent output (line 230), missing checkpoint file (line
  235), empty checkpoint content (line 239), invalid checkpoint JSON (line 245), missing required
  fields `objective, completed_steps, next_step, last_updated` (lines 248-259), empty `objective`
  (line 263), a malformed `human_interaction` block per `Test-HumanInteractionShape` (lines 60-142,
  itself blocking on missing `requirements`, unresolved `response`, out-of-enum `response`,
  `response == 'halt'`, or an `exception` response with missing/nonexistent `runbook_path`), and
  finally any non-zero-exit-or-nonempty-output result from the delegated Python validator (lines
  190-193, 283-285: `$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))`).
  This is the template the spec item 1 explicitly says to reuse for the new `epic-orchestrator`
  `SubagentStop` matcher: `Invoke-RoutingContractValidation`'s pattern of shelling out to an
  authoritative Python validator (rather than reimplementing checkpoint-shape logic in PowerShell)
  is the model for an epic-checkpoint validator too (see §6/Automation Feasibility).

### 1.3 `.claude/hooks/enforce-checkpoint-monotonic.ps1`

- **Event type:** `PreToolUse` (registered under the `Write|Edit` matcher,
  `.claude/settings.json:93-127`; every decision object sets `hookEventName = 'PreToolUse'`, e.g.
  lines 209, 226, 233, 242, 246, 261).
- **Matcher/trigger:** Self-scopes to the single-feature checkpoint path via
  `Test-IsCheckpointPath` (lines 186-195: `$NormalizedPath -match
  '(^|/)artifacts/orchestration/orchestrator-state\.json$'`), invoked from
  `Invoke-CheckpointMonotonicDecision` (line 219-227) after reading `file_path` out of
  `CLAUDE_TOOL_INPUT`. Only `Write` tool calls are validated; `Edit` calls are allowed unchecked
  because a partial `old_string`/`new_string` patch "is not reliable without the full target file
  content" (lines 36-39, 229-234).
- **Seams read:** `CLAUDE_TOOL_INPUT` JSON `.file_path` and `.content` fields only — no filesystem
  reads of its own; the tool call itself carries the full proposed file content (line 231:
  `$content = $toolInput.content`).
- **Fail-closed behavior:** Parses `completed_steps` from the proposed `content` JSON and compares
  each pair of entries' canonical step index via `Get-OutOfOrderPair` (lines 101-137); any
  out-of-order pair (unless `rollback_history` is non-empty, lines 256-261) produces a `deny`
  decision with reason `CHECKPOINT_ORDER_BLOCKED` (lines 265-273). A separate check,
  `Get-MissingPrerequisiteForAdvancedStep` (lines 153-184), blocks when a step at canonical index
  >= 5 (implementation/review/PR/CI/DONE) appears without both `S3_promotion` and
  `S4_atomic_planning` present in `completed_steps` (lines 172-181), again returning
  `CHECKPOINT_ORDER_BLOCKED` (lines 284-291). Malformed JSON in the proposed `content` is treated as
  an *allow* (lines 236-243, comment: "Let downstream tools surface the error rather than blocking
  with a misleading reason here") — this is the one hook of the five that intentionally does not
  fail closed on malformed *content* JSON (it still fails closed structurally by allowing the
  downstream JSON-parse error to surface elsewhere). This is directly relevant precedent for a
  wave-barrier-monotonicity hook on the new epic checkpoint (see §5).

### 1.4 `.claude/hooks/enforce-evidence-locations.ps1`

- **Event type:** `PreToolUse` (registered under `Write|Edit` matcher,
  `.claude/settings.json:93-127,114`; decisions set `hookEventName = 'PreToolUse'`, lines 122, 141).
- **Matcher/trigger:** Fires on every `Write`/`Edit`; self-scopes by testing `file_path` against a
  forbidden-prefix list (lines 60-70) via `Test-EvidenceLocationForbidden` (lines 43-82).
- **Seams read:** `CLAUDE_TOOL_INPUT` JSON `.file_path` only; no filesystem or subprocess reads.
  Pure string-matching against a normalized (`\` → `/`) path.
- **Fail-closed behavior:** Any path matching a forbidden prefix (`artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/evidence/`, `artifacts/research/`, etc., lines 60-70) is denied with
  reason `EVIDENCE_LOCATION_BLOCKED` (lines 84-105). Malformed `CLAUDE_TOOL_INPUT` JSON throws
  (line 129), caught by `Invoke-EvidenceLocationEntryPoint` (lines 163-168) which returns exit code
  `1` — a hard failure, not silent allow. This is the simplest of the five hooks: pure string
  matching with no external state, useful precedent for a lightweight PR-base-branch-override
  check (see §2/§3) that could similarly be pure string matching on `CLAUDE_TOOL_INPUT.command`.

### 1.5 `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`

- **Event type:** `PreToolUse` (registered under all three matchers — `Bash`, `Write|Edit`, and
  `Agent` — in `.claude/settings.json:71-146`; decisions set `hookEventName = 'PreToolUse'`, lines
  141, 158).
- **Matcher/trigger:** Broadest trigger surface of the five: it inspects `file_path` (for
  `Write`/`Edit`), `command` (for `Bash`), or the full tool-input payload text (for `Agent`
  delegations) to decide whether the operation "requires a ready checkpoint"
  (`Invoke-OrchestrationPreimplementationGateDecision`, lines 163-211). `Test-ImplementationPath`
  (lines 39-51) matches production file extensions outside `docs/features/active/` and outside the
  checkpoint path itself. `Test-ImplementationCommand` (lines 53-77) matches `git add|commit`,
  formatter/linter/test invocations. `Test-ImplementationDelegation` (lines 79-90) matches
  `Agent`-tool payloads whose serialized JSON contains one of
  `python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute`
  (line 89) — this is direct, verified evidence that a `PreToolUse` hook **can** be registered
  against and inspect the `Agent` tool's JSON payload by serializing the whole `ToolInput` object
  (line 88: `$payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)`), not just a single
  named field.
- **Seams read:** `CLAUDE_TOOL_INPUT` JSON; checkpoint content via `Get-CheckpointContent` (lines
  122-131, wraps `Test-Path`/`Get-Content -Raw`); `Test-OrchestrationReady` (lines 92-120) checks
  for non-empty `issue-num`, `feature-folder` (must start with `docs/features/active/`),
  `route_id`/`path_selected`, and `lifecycle_ready == true`.
- **Fail-closed behavior:** When an operation is classified as requiring readiness and the
  checkpoint does not satisfy `Test-OrchestrationReady`, the hook denies with reason
  `PREIMPLEMENTATION_GATE_BLOCKED` (line 210). Malformed `CLAUDE_TOOL_INPUT` JSON throws (line 177),
  caught at lines 217-222, `exit 1`. A malformed/unreadable checkpoint is treated as `$null` (lines
  201-205, `catch { $checkpoint = $null }`) which then fails `Test-OrchestrationReady` (line 97:
  `if ($null -eq $Payload) { return $false }`) and denies — i.e., checkpoint-read failure fails
  closed, not open.

**Conclusion:** All five hooks share a uniform contract: `PreToolUse` hooks read
`$env:CLAUDE_TOOL_INPUT`, `SubagentStop` hooks read `$env:CLAUDE_HOOK_INPUT`; both emit
`hookSpecificOutput.{hookEventName, permissionDecision, permissionDecisionReason}` JSON to stdout
and use `exit 0` for a decision (allow or deny) vs. `exit 1` only for a hard/malformed-input
failure. Every hook fails closed on ambiguous or unreadable state (deny or hard-exit), with the
single documented exception of malformed *checkpoint content being written* in
`enforce-checkpoint-monotonic.ps1`, which intentionally defers to the downstream JSON-parse error
rather than blocking with a misleading reason. Filesystem/subprocess seams are always wrapped in
small, named, mockable functions (`Get-*`, `Test-*`, `Invoke-*Invoker`) — this is the seam
convention `.claude/rules/powershell.md` requires and that a new epic-hardening hook must follow.

---

## 2. `.claude/settings.json` Hook Wiring

Full file read (`.claude/settings.json:1-192`). Verified structure:

- **PreToolUse** is an array of matcher blocks, each with a `matcher` string (a tool-name pattern,
  not a regex on command text) and a `hooks` array of `{ type: "command", command: "pwsh
  -NoProfile -File .claude/hooks/<script>.ps1" }` entries. Three matchers exist today:
  - `"Bash"` (lines 72-92) — four hooks chained: `validate-bash.ps1`,
    `enforce-promotion-mcp-only.ps1`, `enforce-pr-author-skill.ps1`,
    `enforce-orchestration-preimplementation-gate.ps1`.
  - `"Write|Edit"` (lines 93-133) — eight hooks chained, including
    `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1`.
  - `"Agent"` (lines 134-146) — two hooks chained: `enforce-prd-feature-before-planner.ps1`,
    `enforce-orchestration-preimplementation-gate.ps1`.
  All hooks registered under a matcher run in sequence for every tool call matching that pattern;
  any one of them can independently deny.
- **SubagentStop** (lines 148-185) uses a `matcher` string that is a `|`-delimited list of *agent
  names* (not tool names), e.g. line 150:
  `"atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer"`.
  Three additional matcher blocks scope single agents: `"feature-review"` (line 159, runs
  `validate-feature-review-coverage.ps1`), `"atomic-planner"` (line 168, runs
  `validate-planner-output.ps1`), `"pr-author"` (line 177, runs `validate-pr-author-output.ps1`).
  Note: the generic catch-all matcher block (line 150) does **not** currently include
  `"orchestrator"` in its list — the spec (issue.md item 1 / spec.md item 1) explicitly calls for
  reusing `validate-orchestrator-output.ps1` with matcher `"orchestrator"`; this matcher is not yet
  present in `.claude/settings.json` and would need to be added as a new block (following the exact
  pattern of the `"pr-author"` block at lines 177-184) for both `orchestrator` and, per the spec,
  `epic-orchestrator`.
- **`permissions.allow`** (lines 5-58) is a flat list of `Bash(...)`/`Read`/`Edit(...)`/`Write(...)`/
  `Agent(...)`/`Skill(...)`/`mcp__...` capability strings. `Agent(atomic-planner)`,
  `Agent(atomic-executor)`, `Agent(feature-review)`, etc. (lines 25-37) are individually
  enumerated — there is **no** `Agent(orchestrator)` entry today, confirming the spec's premise
  that nested orchestration is not yet authorized at the permissions layer either.

**How to register the two new hooks the objective calls for:**

(a) **New `SubagentStop` matcher for `"epic-orchestrator"` reusing `validate-orchestrator-output.ps1`:**
Add a new block to the `SubagentStop` array (parallel to the `"pr-author"` block, lines 177-184):
```json
{
  "matcher": "epic-orchestrator",
  "hooks": [
    { "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1" }
  ]
}
```
The existing catch-all `SubagentStop` matcher (line 150) would also need `epic-orchestrator` (and
`orchestrator`, per spec item 1) appended to its `|`-delimited list to get the baseline
completion-artifact-path check every other agent gets.

(b) **New `PreToolUse` hook(s) for `gh pr merge` / `git worktree remove`:** Both are `Bash`
invocations, so a new hook script would be registered as an additional entry in the existing
`"Bash"` matcher block (lines 72-92), alongside `enforce-pr-author-skill.ps1`. No new matcher block
is needed; the `Bash` matcher already fires on every Bash call and the script itself narrows scope
by regex on the command text, exactly as `enforce-pr-author-skill.ps1` narrows to
`gh pr create`/`gh pr edit`.

**Conclusion:** Registration for both required hooks follows exact precedent already present in
`.claude/settings.json` — no new matcher *type* is needed for the `Bash`-based merge/worktree gates
(reuse the `"Bash"` matcher), and a `SubagentStop` matcher block reusing an existing script by
literal filename is already the established pattern (`"pr-author"` block).

---

## 3. Feasibility: Gating `gh pr merge --merge` via a PreToolUse Hook

**What `CLAUDE_TOOL_INPUT` contains for a `Bash(gh pr merge ...)` call:** confirmed by every
`Bash`-matched hook read in §1 — the payload is JSON with (at minimum) a `.command` string field
(`enforce-pr-author-skill.ps1:344`: `$commandText = $toolInput.command`;
`enforce-orchestration-preimplementation-gate.ps1:186`: `$command = Get-StringProperty -Value
$toolInput -Name 'command'`). A `gh pr merge --merge <N>` invocation would appear as that literal
string in `.command`.

**Can a hook check "epic_mode is true AND ci_gate.conclusion==success AND ci_gate.head_sha==current
PR head" before allowing the merge?** Yes, mechanically, by direct analogy to two already-verified
patterns:

1. `enforce-pr-author-skill.ps1` demonstrates that a `PreToolUse` hook on `Bash` can (a) regex-match
   the command text to decide whether to activate at all (lines 270-277), and (b) read
   supplementary filesystem state (a receipt file, a context-summary timestamp) to make a
   multi-condition allow/deny decision (lines 137-237) — this is structurally identical to reading
   `ci_gate.conclusion` and `ci_gate.head_sha` out of a checkpoint file.
2. `validate-orchestrator-output.ps1`'s `Invoke-RoutingContractValidation` (lines 144-194)
   demonstrates that a hook can shell out to an external validator (there, Python) for the
   authoritative decision logic rather than reimplementing it in PowerShell, and treat any nonzero
   exit code or nonempty output as a block. A merge-gate hook could apply this exact pattern: an
   injectable `$Invoker` scriptblock that (in production) reads
   `artifacts/orchestration/orchestrator-state.json` (or the new epic checkpoint) via
   `Get-Content -Raw | ConvertFrom-Json`, checks `.epic_mode`/similar flag, `.ci_gate.conclusion ==
   'success'`, and `.ci_gate.head_sha` equals the SHA reported by a live `gh pr view <N> --json
   headRefOid` call (or a cached value in the checkpoint, at the cost of staleness risk — see the
   head-SHA freshness caveat below).

**Constraint to flag for the plan:** `enforce-checkpoint-monotonic.ps1` and
`validate-orchestrator-output.ps1` both read the checkpoint **as a static file on disk** at hook
invocation time; neither hook queries `gh` live. A merge-gate hook has the same two options: (a)
trust the checkpoint's last-recorded `ci_gate.head_sha`/`conclusion` (fast, but only as fresh as the
last S9 write — a staleness risk if the PR head SHA advanced after S9 last ran and before the merge
attempt), or (b) shell out to `gh pr view <N> --json headRefOid,mergeStateStatus` live inside the
hook for a real-time check (slower, network-dependent, but closes the staleness gap). No existing
hook in this repo shells out to `gh` directly (`enforce-pr-author-skill.ps1` and
`validate-orchestrator-output.ps1` only read the filesystem and invoke a *local* Python script,
respectively) — a `gh`-invoking hook would be a new pattern, not precedent-backed, but mechanically
identical to how the orchestrator itself already calls `gh pr checks --required --json ...` per
`.claude/skills/orchestrate/SKILL.md:158`.

**Conclusion:** Feasible. A PowerShell `PreToolUse` hook matching `Bash` commands containing
`gh pr merge` can read `CLAUDE_TOOL_INPUT.command`, extract the PR number, read the epic
checkpoint (or shell out live to `gh pr view`/`gh pr checks`) via the same injectable-seam pattern
as `Invoke-RoutingContractValidation`, and deny the merge when `epic_mode` is not set, or
`ci_gate.conclusion != 'success'`, or the checkpoint's recorded head SHA does not match the PR's
current head SHA. This closes the gap flagged in the objective: an agent's own S9 gate is prose an
agent might skip; a hook reading the same checkpoint fields is a structural gate the agent cannot
bypass by simply omitting the S9 step (though it can still be bypassed by writing a false
`ci_gate.conclusion: "success"` to the checkpoint — the same non-adversarial caveat
`enforce-pr-author-skill.ps1`'s header documents for its own receipt mechanism, lines 33-39).

---

## 4. Feasibility: Gating `git worktree remove` via a PreToolUse Hook

**Mechanically checkable inputs:** identical seam shape to §3 — `CLAUDE_TOOL_INPUT.command` for a
`Bash(git worktree remove <path>)` call, plus whatever the hook script chooses to read from disk or
shell out to. No hook in this repo currently inspects "conversation state" (e.g., what the
orchestrating agent believes it just did) — every one of the five hooks read in §1 operates purely
on (a) the current tool-input JSON and (b) filesystem/subprocess reads it performs itself. This
confirms the framing in the objective: a `PreToolUse` hook has **no access to in-memory
conversation state**, only `CLAUDE_TOOL_INPUT` plus whatever it can read from disk or invoke via
`git`/`gh` itself.

**What can be checked:**
1. Extract the worktree path (or branch name, if resolvable from the path via a
   `git worktree list --porcelain` shell-out) from the command text.
2. Cross-reference that path/branch against the epic checkpoint's per-child-feature record (worktree
   path, branch name, PR number, merge status — exactly the fields the spec's item 6 requires the
   epic checkpoint to carry).
3. Verify merge status either from the checkpoint's recorded `merge_status` field, or — for a
   real-time, tamper-resistant check — shell out to `gh pr view <N> --json state,mergedAt` and
   confirm `state == "MERGED"` and `mergedAt` is non-null, following the exact pattern the spec's
   item 6 itself names (`gh pr view --json state,mergedAt`) and that `.claude/skills/orchestrate/
   SKILL.md` already uses for `gh pr checks --required --json ...` (line 158).

**Fail-closed shape:** Following the `enforce-orchestration-preimplementation-gate.ps1` precedent
(a malformed/unreadable checkpoint is treated as `$null`, which fails `Test-OrchestrationReady` and
denies, lines 201-205 + 97), a worktree-removal hook should treat an unreadable epic checkpoint, or
a checkpoint with no record for the target worktree, as **deny**, not allow — mirroring "ambiguous
state fails closed" across every hook read in §1.

**Conclusion:** Feasible, using the same two mechanisms available to the merge gate in §3: a
checkpoint-file read (fast, but exposed to the same non-adversarial-integrity caveat) or a live
`gh pr view --json state,mergedAt` shell-out (closes the staleness gap, costs a network round trip
per hook invocation). Both are mechanically available to a `PreToolUse` hook using only
`CLAUDE_TOOL_INPUT` and filesystem/`git`/`gh` calls — no conversation-state access is required or
available.

---

## 5. Wave-Barrier Feasibility

**Does `.claude/settings.json` have an existing `Agent`-tool matcher, and does it support matching
on tool name the same way `Bash` does?** Yes — confirmed directly:
`.claude/settings.json:134-146` registers a `"matcher": "Agent"` `PreToolUse` block running
`enforce-prd-feature-before-planner.ps1` and `enforce-orchestration-preimplementation-gate.ps1`.
`enforce-prd-feature-before-planner.ps1` (read in full) confirms the payload shape for an `Agent`
tool call: `CLAUDE_TOOL_INPUT` contains `.subagent_type` (line 172: `$subagent =
$toolInput.subagent_type`) and `.prompt` (line 177: `$prompt = [string]$toolInput.prompt`).
`enforce-orchestration-preimplementation-gate.ps1`'s `Test-ImplementationDelegation` (lines 79-90)
further confirms the *whole* tool-input object can be serialized and regex-matched (line 88:
`ConvertTo-Json -Depth 20 -Compress`), so a hook is not limited to named fields — it can inspect
anything present in the payload.

**Can a `PreToolUse` hook on `Agent` enforce "do not start wave N+1 until wave N is durably
confirmed merged"?** Partially, with an important structural limit that must be stated precisely:

- A `PreToolUse` hook fires **once per tool call**, before that individual call executes. It can
  reliably answer, at the moment of *each individual* `Agent(orchestrator)` call: "does the epic
  checkpoint currently show every dependency of the feature named in this call's `.prompt` as
  merged?" This is mechanically identical to `enforce-prd-feature-before-planner.ps1`'s existing
  pattern of resolving a target feature folder from `.prompt` text and checking prerequisite file
  existence (lines 82-124, 126-148) — the same resolution technique (regex-scan `.prompt` for a
  feature identifier, or fall back to checkpoint-recorded state) can resolve "which wave/feature
  does this Agent call target" and "what are its `depends_on` entries," then check the epic
  checkpoint for each dependency's recorded merge status.
- What a `PreToolUse` hook **cannot** reliably do is reason about *the batch as a whole* when
  "one message contains multiple concurrent `Agent` calls" (spec item 7's own wording). Each call in
  that batch fires the hook independently and, per every hook read in §1, has no access to sibling
  tool calls in the same assistant message or to conversation state — only to its own
  `CLAUDE_TOOL_INPUT` and whatever is durably on disk at that instant. If the epic-orchestrator emits
  all of wave N+1's `Agent` calls in one message *after* durably recording wave N's merges to the
  checkpoint, each individual call's hook check is sound (the checkpoint is already updated by the
  time any of them fires). If, however, the epic-orchestrator tried to start wave N+1 calls
  *speculatively* before wave N's merges are checkpointed, no per-call hook can detect that the
  *batching itself* was premature — it can only detect, per call, whether the checkpoint (at that
  instant) shows the dependency as merged. In practice this means the hook is a strong deterrent
  against the common failure mode (starting wave N+1 while wave N genuinely has not merged) but does
  not by itself prove that the orchestrator's *decision to batch* the calls was made after a correct
  wave-barrier check — that decision happens inside the orchestrating agent's own turn, before any
  tool call is emitted.
- The spec itself anticipates this limit and proposes the fallback: enforce the barrier
  **retrospectively** at `SubagentStop` time by refusing to mark the epic-orchestrator run
  DONE/valid if checkpoint evidence shows a wave started (e.g., a child feature's worktree/branch
  was created, or its `Agent(orchestrator)` delegation receipt was recorded) before its dependency
  wave's merge confirmations were durably recorded. This is directly analogous to
  `validate-orchestrator-output.ps1`'s existing `Invoke-RoutingContractValidation` pattern: delegate
  the actual ordering-logic check to an authoritative validator (Python or PowerShell) that inspects
  the full epic checkpoint's timestamped history (per-feature `wave_number`, worktree-creation
  timestamp, and merge-confirmation timestamp) and blocks DONE if any wave-N+1 event timestamp
  precedes wave-N's last merge-confirmation timestamp — the same "checkpoint-order" reasoning
  `enforce-checkpoint-monotonic.ps1`'s `Get-OutOfOrderPair` (lines 101-137) already implements for
  the single-feature `completed_steps` array, generalized to per-wave event ordering.

**Conclusion:** A `PreToolUse` hook matching the `Agent` tool name is achievable and precedent-backed
(`.claude/settings.json:134-146`, `enforce-prd-feature-before-planner.ps1`) and can enforce a
**per-call** check ("does the checkpoint currently show this call's dependencies as merged").
It cannot, by itself, prove that a *batch* of concurrent `Agent` calls was correctly gated as a
whole, because hooks have no cross-call/conversation-state visibility. The retrospective
`SubagentStop`-time validator approach (refusing DONE/valid when checkpoint timestamps show
out-of-order wave starts) is the mechanism that closes that residual gap, following the
`enforce-checkpoint-monotonic.ps1` ordering-check pattern generalized to epic-checkpoint wave
events. Both mechanisms are complementary, not alternatives: the per-call `PreToolUse` hook is the
primary deterrent; the `SubagentStop` retrospective check is the structural backstop.

---

## 6. Merge-Conflict-as-Remediation-Finding Feasibility

**Does `atomic-executor` have sufficient `Bash(git *)` access?** Confirmed directly from
`.claude/agents/atomic-executor.md` frontmatter `tools:` list (lines 4-23): `Read`, `Grep`, `Glob`,
`Edit`, `Write`, and `"Bash(git *)"` (line 19) — an unrestricted `git` wildcard, not a narrowed
subset like the Python/TypeScript entries (`"Bash(poetry run pytest *)"`,
`"Bash(npx vitest *)"`). This is sufficient to run `git merge --no-commit`, `git status`,
`git diff --name-only --diff-filter=U` (list conflicted files), and `git commit`. `Read` and `Grep`
are sufficient to inspect conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) inside conflicted
files; `Edit`/`Write` are sufficient to resolve them.

**Is there an existing skill that already models "convert an external failure into a
`remediation-inputs.<ts>.md` blocking finding"?** Yes — `.claude/skills/orchestrate/SKILL.md`'s
"Remediation Loop — CI-Failure Handling" section (lines 199-207) documents exactly this pattern for
CI-check failures:

> "1. The failed-check log from `gh run view <run-id> --log-failed` (or the timeout log) is written
> as `remediation-inputs.<timestamp>.md` in the active feature folder. 2. The failure is converted
> to a synthetic finding with severity `Blocking` that identifies the failing check by name and the
> failing job by URL. 3. The existing R1-R5 remediation loop processes that finding exactly as it
> processes a local blocking finding. No new loop is introduced. 4. The `remediation_pass` counter
> is shared with local-finding passes; the cap is 3. 5. On the third CI-failure pass without
> resolution, the orchestrator records `step9_status: "blocked_ci_loop_limit"`, does not write DONE,
> and halts."

This is reused verbatim in shape by `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`,
which defines the full R1–R5 chain (`orchestrator -> remediation-inputs.<ts>.md -> atomic-planner
-> remediation-plan.<ts>.md -> atomic-executor preflight -> atomic-executor execution ->
feature-review reaudit`, lines 20-42) and the required five artifacts per cycle (lines 63-71). A
merge conflict during fan-in is structurally the same shape as a CI-check failure: an external,
git-observable failure (`git merge --no-commit` exits non-zero and leaves conflict markers,
observable via `git diff --name-only --diff-filter=U`) that can be captured as a
`remediation-inputs.<ts>.md` synthetic Blocking finding (naming the conflicting branch, the
conflicted file list, and the conflict-marker content) and handed to `atomic-planner` exactly as the
CI-failure log is today. The termination guard (`remediation_pass` cap of 3,
`.claude/skills/remediation-handoff-atomic-planner/SKILL.md:109` "Exit Gate" +
`.claude/skills/orchestrate/SKILL.md:139` "Termination guard") applies unmodified.

**Minimal adaptation needed:** The CI-failure handling section is keyed to a specific artifact
source (`gh run view <run-id> --log-failed`) and a specific checkpoint field
(`step9_status: "blocked_ci_loop_limit"`, tied to the single-feature checkpoint). For epic-mode
fan-in conflicts, the adaptation is:
1. A new synthetic-finding source: `git diff --name-only --diff-filter=U` output plus the raw
   conflict-marker content of each conflicted file, in place of `gh run view --log-failed`.
2. A new checkpoint field on the epic checkpoint (parallel to `step9_status`), e.g. a per-child-
   feature `merge_status: "blocked_conflict_loop_limit"`, in place of the single-feature
   `step9_status`.
3. Confirmation that `atomic-executor`'s merge/conflict-resolution work happens **inside the child
   feature's own worktree** (the merge attempt is `git merge <integration-branch-tip> --no-commit`
   run from the child feature's branch, or the reverse direction depending on final design) — this
   is a design detail for the plan author, not a tool-access gap, since `Bash(git *)` in that
   worktree's working directory is unrestricted per the tool allowlist above.

No missing tool access or missing detection seam was found: `atomic-executor`'s tool allowlist
already covers merge, inspection, edit, and commit; the conflict-detection seam (`git`'s own
non-zero exit and conflict markers) is a standard, scriptable signal; and the
`remediation-inputs.<ts>.md` synthetic-finding conversion pattern is already proven in production
for an analogous external failure (CI-check failure).

**Conclusion: Feasible.** `atomic-executor` has sufficient tool access
(`Bash(git *)`, `Read`, `Grep`, `Edit`, `Write`) to detect, inspect, and resolve a merge conflict and
commit the resolution. The CI-failure-handling section of `.claude/skills/orchestrate/SKILL.md`
(lines 199-207) and the R1–R5 chain in `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
already model the exact "external failure to synthetic Blocking finding to standard remediation
loop" conversion this design needs; the minimal adaptation is a new synthetic-finding source (git
conflict state instead of a CI log) and a new epic-checkpoint status field (parallel to
`step9_status`) rather than any new mechanism. No `scope_change`/`exception`/`halt` fallback is
required by tool-access or seam-availability constraints — the spec author can still choose to add
a documented iteration/complexity cap (e.g., "conflicts touching more than N files trigger a
`scope_change`/`exception`" as an authored policy choice, not a research-derived necessity) but that
is a design decision, not a feasibility gap.

---

## Automation Feasibility

Per the orchestrate skill's Autonomous-Execution Mandate research gate, this section summarizes
which mechanisms above are confirmed automatable purely by hooks/existing tool access, versus which
require a documented `scope_change`/`exception`/`halt`.

**Confirmed automatable (hook/tool-access only, no human-interaction fallback required):**

- **PR-merge gating on epic-mode + CI-green + head-SHA match (§3):** A `PreToolUse` hook on `Bash`
  matching `gh pr merge` can read the checkpoint (or shell out to `gh pr view`/`gh pr checks`) using
  the exact seam pattern already proven by `enforce-pr-author-skill.ps1` and
  `validate-orchestrator-output.ps1`'s `Invoke-RoutingContractValidation`. Caveat: the gate is
  policy-level, not adversarial-proof (same caveat the pr-author receipt hook documents about
  itself), and a checkpoint-only read (vs. a live `gh` call) carries a staleness risk that the plan
  author should resolve explicitly.
- **Worktree-removal gating on confirmed merge (§4):** A `PreToolUse` hook on `Bash` matching
  `git worktree remove` can cross-reference the epic checkpoint or a live `gh pr view --json
  state,mergedAt` call, following the same seam pattern. Same staleness/policy-level caveat applies.
- **Per-call wave-barrier deterrence (§5):** A `PreToolUse` hook on the `Agent` tool matcher
  (already registered and precedent-backed) can check, for each individual `Agent(orchestrator)`
  call, whether the epic checkpoint currently shows that call's declared dependencies as merged —
  using the same feature-folder/prompt-scanning technique already proven by
  `enforce-prd-feature-before-planner.ps1`.
- **Retrospective wave-barrier backstop (§5):** A `SubagentStop`-time validator (parallel to
  `Invoke-RoutingContractValidation`, generalized from `enforce-checkpoint-monotonic.ps1`'s
  ordering-check logic) can refuse DONE/valid if checkpoint timestamps show a wave started before
  its dependency wave's merge confirmations were recorded.
- **Merge-conflict-as-remediation-finding (§6):** `atomic-executor`'s existing tool allowlist
  (`Bash(git *)`, `Read`, `Grep`, `Edit`, `Write`) and the already-productionized CI-failure
  synthetic-finding pattern in `.claude/skills/orchestrate/SKILL.md` (lines 199-207) and
  `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` together confirm this is
  automatable via the standard R1–R5 loop with a new synthetic-finding source and a new
  epic-checkpoint status field; no new tool access is required.

**Requires an explicit design decision, but not a research-identified infeasibility:**

- **Wave-batch-level (not per-call) enforcement (§5):** No mechanism inspects "was this entire batch
  of concurrent `Agent` calls correctly gated as a whole" — hooks operate per-call, with no
  cross-call or conversation-state visibility. This residual gap is closed by the retrospective
  `SubagentStop` backstop above, not by a stronger `PreToolUse` mechanism (none exists in this
  runtime). This is not a `scope_change`/`exception`/`halt` case; it is a two-layer
  (deterrent + backstop) design the plan author should adopt explicitly rather than relying on the
  per-call hook alone.
- **Checkpoint-integrity non-adversarial caveat (§3/§4):** Both the merge-gate and worktree-removal-
  gate hooks are policy-level checks that trust the on-disk checkpoint's truthfulness (same caveat
  `enforce-pr-author-skill.ps1`'s own documentation states about its receipt mechanism). If the spec
  author wants to close this gap, the choice is between (a) accepting the same
  policy-level-not-cryptographic posture already accepted repo-wide for the receipt hook, or (b)
  requiring hooks to always shell out live to `gh` rather than trusting the checkpoint — a
  design/performance tradeoff, not a feasibility question this research resolves.

No mechanism examined in this research was found to be mechanically infeasible in a way that would
require falling back to `scope_change`/`exception`/`halt` under the Autonomous-Execution Mandate.
All five hardening mechanisms named in the objective (base-branch override is out of this research's
explicit scope — see note below — merge-on-green gating, wave-barrier enforcement, worktree-removal
gating) and the merge-conflict-remediation design are confirmed automatable using hooks and tool
access already present in this repository, following patterns already in production.

**Note on scope:** This research's six questions did not include a dedicated read of
`.claude/skills/pr-base-branch-merge-base/SKILL.md` (the spec references it for the PR base-branch
override item); that skill's feasibility for hard-gating the base-branch override was not directly
verified here and should be confirmed in a follow-up research pass or by the atomic-planner before
committing to a specific hook design for that invariant.
