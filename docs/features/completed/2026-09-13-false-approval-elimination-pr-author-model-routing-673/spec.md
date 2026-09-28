# 2026-09-13-false-approval-elimination-pr-author-model-routing (Spec)

- **Issue:** #673
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-19T09-00
- **Status:** Draft
- **Version:** 0.5
- **Epic:** `worktree-scoped-state-resolution`, feature **F5**, wave 1, `depends_on: [F1]`
- **Work Mode:** `full-bug` — this file is the sole acceptance-criteria source. No `user-story.md` exists for this feature.
- **Primary research record:** `research/2026-09-13T22-10-false-approval-elimination-research.md`

## Context
The PR-creation readiness gate (`.claude/hooks/enforce-pr-author-skill.ps1` and siblings) and the
model-routing-receipt deterrent (`.claude/hooks/enforce-model-routing-receipt.ps1`) resolve the
orchestrator checkpoint from a fixed relative path, `artifacts/orchestration/orchestrator-state.json`,
against the invoking session's current working directory. In a parallel or epic topology the session
root holds a different item's checkpoint, so both gates validate one item's action against a sibling
item's state and return allow. This is a false approval: the reported green carries no information
about the item actually being gated.

Environment:
- OS/version: Windows 11 Pro 10.0.26200 (defect is platform-independent; hooks are PowerShell)
- Python version: not applicable — both hooks are PowerShell and must remain Python-free
- Command/flags used: `gh pr create ...` intercepted by `enforce-pr-author-skill.ps1`; `Agent(...)`
  delegation intercepted by `enforce-model-routing-receipt.ps1`
- Data source or fixture: two orchestrator-state checkpoints present simultaneously — one at the
  session root belonging to a sibling item, one in the item worktree belonging to the gated item

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

A gate that silently validates one item's action against a different item's state is more damaging
than a gate that denies incorrectly: a false denial stalls a run visibly, whereas a false approval
lets the run proceed on an unverified basis with no record that anything was skipped.


## Repro & Evidence
Steps to Reproduce:
1. Create a session root containing `artifacts/orchestration/orchestrator-state.json` that belongs to
   item A and is in a PR-creation-ready state.
2. Create a separate item worktree for item B whose own checkpoint is absent, or present and not ready.
3. From the session root, issue a gated action that pertains to item B (`gh pr create` for B's branch
   for defect 3.2; an `Agent(...)` delegation for B for defect 3.4).
4. Observe the gate's decision.

Expected:
Each gate resolves the checkpoint belonging to the item the call pertains to. When that checkpoint
cannot be identified, the gate denies with a distinct, greppable reason code naming the ambiguity.
A sibling item's checkpoint is never used as the basis for an allow.

Actual:
Both gates read the checkpoint that happens to occupy the session root and evaluate against it. In
run `bugs-2026-09-11`, `gh pr create` was allowed for a child working on the runsettings fix because
the readiness gate passed against issue 838's checkpoint. The child reported the outcome as "a false
green with respect to this task's own state, not evidence that this task's own lifecycle was
validated." `enforce-model-routing-receipt.ps1` was separately observed mid-run reading
`route_id: small`, `next_step: pr_creation` while gating a delegation belonging to an unrelated
parallel item.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: not available. A false approval produces no denial record, so there is no error text to
  attach. The condition must be reconstructed and observed directly rather than read from a log.

### Reproduction status (hard precondition, not a footnote)

**Defects 3.2 and 3.4 have NOT been reproduced by direct execution.** Two independent attempts were
made and both were blocked by unrelated environment limits (research §0 and §15.1): the research
session held no command-execution tool at all, and the orchestrator session's attempt was refused by
the agent-worktree isolation guard, which declines any command that launches `pwsh`. The fixture
itself was built successfully; only the interpreter launch was refused. No attempt was made to route
around the guard.

The defect mechanism is therefore **established by a complete end-to-end static trace, not by
observation**. A static trace is categorically weaker evidence than an observed `allow`. Everything
in `## Root Cause Analysis` and `## Proposed Fix` below is written on that basis and must be read as
a reproduction script with a predicted outcome.

Consequences, which are binding on implementation:

1. Reproduction is the **first executable step** of implementation, before any hook file is edited.
2. Each reproduction runs as a **control pair** — the identical payload from the session-root cwd and
   from the item-worktree cwd. The pair (allow from session root, deny from item worktree) is the
   evidence that the verdict is a function of cwd and not of the payload.
3. The observed decision JSON, exit code, stdout, and stderr are archived verbatim under
   `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/`.
4. If the predicted `allow` is **not** observed for either defect, execution **halts** and the
   finding is reported. No hook file is edited on the strength of the static trace alone.
5. Two execution routes are named so the step cannot stall: a direct `pwsh` launch where permitted,
   or a Pester-expressed reproduction executed out of process via `mcp__drm-copilot__run_poshqc_test`
   where a direct `pwsh` launch is refused.

## Scope & Non-Goals

### In scope

Three cwd-relative orchestrator-state checkpoint bindings reachable on a decision path, enumerated
exhaustively in research §10 Claim N1 (two independent search strategies, identical member sets,
both counts 3):

| # | file | lines | binding | how it binds |
| --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-pr-author-skill.ps1` | 311 | `:49` | script-scoped variable `$script:OrchestratorStateCheckpointPath`, consumed at helpers `:240`/`:243` |
| 2 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 115 | `:35` | parameter default of `Get-PrAuthorCheckpointContent`; binds because the sole call site `:78` passes no argument |
| 3 | `.claude/hooks/enforce-model-routing-receipt.ps1` | 180 | `:46` | parameter default of `Get-ModelRoutingCheckpoint`; binds because the sole production call site `:157` passes no argument |

Also in scope:

- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (260 lines) — carries **no** binding. It only
  consumes the already-bound variable at `:240` and `:243`. It **is** edited nonetheless: the
  ordering rule recorded under `#### Data flow and validation changes` requires the ambiguity deny to
  sit after the pr-author scope filter, and that scope filter lives in `Get-PrAuthorBypassReason` at
  `:181-183`. The edited-file count for F5 is therefore **four** (three binding sites plus this
  file), matching research Claim N2, and this file's bundled mirror copy must change with it.
- The bundled mirror copy of every file edited under `.claude/**`, at
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- New sibling Pester test files under `tests/scripts/claude-hooks/` and committed fixture roots under
  `tests/fixtures/`.

### Out of scope / non-goals

- **`.codex/hooks/enforce-codex-model-routing.ps1` — excluded on positive evidence; do not
  re-litigate.** It reads no orchestrator-state checkpoint at all (a content search for
  `orchestrator-state` and `CheckpointPath` across `.codex/hooks/` returns zero matches in this
  file); it derives its root from the script's own location
  (`enforce-codex-model-routing.ps1:11`, `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`);
  it stores attestations outside the repository, asserted by
  `Assert-CodexAuthorityOutsideRepository` (`.codex/hooks/codex-authority-store.ps1:144`); and it is
  a model/profile-drift gate against a SubagentStart attestation, not a receipt-presence gate. It
  has no sibling checkpoint to confuse because it has no checkpoint. This closes the open question
  the epic manifest assigned to F5 (`epic.md:199-202`). F5 therefore carries **no** Codex parity
  obligation.
- `.claude/hooks/enforce-epic-merge-gate.ps1:48` (`$script:ChildCheckpointPath`) is likewise
  cwd-relative, but it is assigned to **F3** (`epic.md:258`). F5 does not fix it.
- `.claude/hooks/hook-command-scanner.ps1` and `.claude/hooks/hook-command-invocation.ps1` must not
  be modified. They are dot-sourced by F5's files (`enforce-pr-author-skill-helpers.ps1:31-32`,
  `enforce-pr-author-skill.epic-base-branch.ps1:14-15`) **and** by the pre-implementation gate, the
  epic-merge gate, and five other gates. Modifying either would alter the pre-implementation gate's
  pathspec/option/metacharacter restrictions and the epic-merge gate's matcher as a side effect.
  Nothing in the design needs them changed: target resolution operates on the checkpoint path, not
  on command tokenisation.
- `.claude/lib/orchestrator-state/OrchestratorState.psm1` must not be modified. It is measured at
  499 of the 500-line cap (research §15.2), so any addition breaches the cap immediately. The design
  passes an **absolute** path into this module instead of changing it.
- Re-implementing any part of the F1 resolution contract (target derivation, path normalisation, or
  the ambiguity reason code). A second implementation in F5's tree is a blocking defect.
- Porting any hook to Python, or adding any Python call to an enforcement path.
- A helpers extraction. Measured headroom across the four in-scope files is 189 + 240 + 385 + 320
  lines; the cap does not require a split, and the epic requires extractions only for F2, F3, and F4
  (`epic.md:209-220`). A gratuitous split is out of scope.
- The MCP/TypeScript `require_pr_creation_ready` divergence recorded in
  `docs/features/potential/2026-08-15-mcp-pr-creation-ready-parity-divergence.md`. It is a
  divergence between the MCP surface and the hook, not inside F5's decision path.
- The stale wording at `.claude/skills/orchestrate/SKILL.md:190`, which still describes `$Invoker` as
  a "subprocess seam" although issue #475 removed the subprocess. Deferred to a follow-up so that
  F5's mirror set stays confined to the hook files.
- Changing child-prompt construction (epic-level non-goal).

### Explicitly excluded systems, integrations, or datasets

- The `.codex/**` tree and its bundled mirror at
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`.
- The authoritative Python orchestrator-state validator and every Python surface. F5 changes no
  validation implementation.
- TaskMaster and any consumer repository. Delivery and push-down belong to F7.

## Root Cause Analysis

### The three bindings

1. `.claude/hooks/enforce-pr-author-skill.ps1:49` —
   `$script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`.
   A bare relative literal at script scope; nothing in the three pr-author files reassigns it. It
   reaches `Invoke-OrchestratorStatePreflight` verbatim at helpers `:240`, then
   `OrchestratorState.psm1:471` (`& $Invoker $CheckpointPath`), then the terminal
   `Test-Path -LiteralPath` / `Get-Content -LiteralPath` at `OrchestratorState.psm1:163`/`:171`,
   which resolve a relative path against the PowerShell provider location.
2. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:35` — a second, structurally
   independent binding on the same decision path, reached by a different mechanism (a parameter
   default bound at an argument-less call site rather than a script-scoped variable). Reached from
   `Test-PrAuthorReceiptVerification` check 6 (helpers `:136`) via
   `Test-EpicBaseBranchOverride`, which calls `Get-PrAuthorCheckpointContent` with no arguments at
   `:78`. **The issue's root-cause section and the epic manifest both name only binding 1. That is
   incomplete; a fix that changes only line 49 leaves the epic base-branch check reading the session
   root's checkpoint.**
3. `.claude/hooks/enforce-model-routing-receipt.ps1:46` — the same mechanism; sole production call
   site `:157` passes no argument, so the default always binds. `Test-Path`/`Get-Content` at `:49`
   and `:54` resolve it against process cwd. The `prompt` field of the delegation, which is where
   the item's feature folder appears, is never read by this hook.

### Why the hook process's cwd is the session root

`.claude/settings.json:101-104` wires the pr-author hook as
`pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1`, and `:191-194` wires the
model-routing hook the same way. A relative `-File` argument only resolves if the launching process's
working directory is the repository/session root, so the hook process is launched with
cwd == session root by construction. The command being gated frequently acts on a different
directory: `cd <worktree> && gh pr merge ...` (`enforce-epic-merge-gate.ps1:148`) and
`git -C <worktree_path> ...` (`.claude/skills/parallel-orchestrate/SKILL.md:351-364`). The `cd`/`-C`
takes effect inside the command, after PreToolUse has already decided.

### Why a sibling checkpoint is sitting at that exact path

The parallel orchestrator writes its own checkpoint to
`artifacts/orchestration/parallel-orchestrator-state.json` — a different filename
(`.claude/skills/parallel-orchestrate/SKILL.md:484`). Each item's per-feature checkpoint keeps the
name `artifacts/orchestration/orchestrator-state.json` inside that item's own worktree. So the file
at the session root under the gated path is whatever a previous single-feature run left there — in
the reported incident, issue 838's — a live, satisfactory-looking, unrelated checkpoint at exactly
the path the gate reads.

### Why binding 2 is worse than a plain false approval

Check 6 is **fail-open by design**: `epic-base-branch.ps1:79-81` returns `$null` (allow) on an
absent or blank checkpoint, `:83-87` returns `$null` on unparseable JSON, and `:90-92` returns
`$null` when `epic_mode` is absent or false. In an epic topology where the item's own checkpoint has
`epic_mode: true` but the session root's sibling checkpoint has `epic_mode: false` or no `epic_mode`
key, the epic base-branch requirement is silently skipped and `gh pr create --base main` is allowed
for a PR that should target the integration branch.

### Why 3.4 is a genuine false approval even though it is presence-only

The check is presence of **any** receipt whose `agent` matches the target `subagent_type`. Agent
names repeat across items, so a sibling's `atomic-planner` receipt satisfies the gate for a different
item's `atomic-planner` delegation. The gate reports that model selection was performed for this
delegation. It was not.

### Epistemic status

Confirmed by complete static trace, not by observation. See `### Reproduction status` above.


## Proposed Fix

### Design summary (what changes where):

In each hook entry point, replace the cwd-relative binding with a **single resolution step, executed
before any decision logic**, that returns exactly three outcomes:

| outcome | action |
| --- | --- |
| target resolved, checkpoint path known | proceed with that **absolute** path; all existing decision logic runs unchanged |
| target resolved, but the checkpoint is genuinely absent or unreadable at that location | **deny** with the **existing** reason (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` / `MODEL_ROUTING_RECEIPT_BLOCKED`), unchanged |
| target cannot be identified | **deny** with the ambiguity reason code supplied by F1. This is the **only** new deny path. |

There is no fourth outcome. In particular there is **no `else { use cwd }` branch** on the ambiguous
outcome: never silently fall back to a sibling's checkpoint.

Distinguishing the second outcome from the third is the substance of this feature. "Target resolved,
evidence genuinely absent" and "target not resolvable" must remain separately identifiable in the
reason text emitted to the caller.

### Boundaries and invariants to preserve:

- **Gates must still deny when required evidence is genuinely absent.** (Epic must-not-regress.)
- **Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions.**
  (Epic must-not-regress; enforced here by not modifying the two shared command parsers.)
- **Do not widen the epic merge gate's `pr_number` matcher as a side effect.** (Epic
  must-not-regress; enforced here by not modifying `enforce-epic-merge-gate.ps1`.)
- **Epic and standalone topologies must behave exactly as now when cwd and target coincide.** (Epic
  must-not-regress.) A standalone run has exactly one checkpoint, at the session root, and must keep
  passing unchanged. The exact standalone path, which must be observably untouched, is:
  `Invoke-PrAuthorSkillEntryPoint` (`:261`) -> `Invoke-PrAuthorSkillDecision` (`:293`) ->
  `Get-PrAuthorBypassReason` (helpers `:144`) -> the `--body-file` + context-present branch
  (helpers `:239`) -> `Invoke-OrchestratorStatePreflight` (helpers `:240`) ->
  `& $Invoker $CheckpointPath` (`OrchestratorState.psm1:471`) -> `Test-Path -LiteralPath`
  (`OrchestratorState.psm1:163`); then `Test-PrAuthorReceiptVerification` (helpers `:253`), whose
  check 6 calls `Test-EpicBaseBranchOverride` (helpers `:136`) -> `Get-PrAuthorCheckpointContent`
  (`epic-base-branch.ps1:78`). And for the model-routing hook:
  `Invoke-ModelRoutingReceiptDecision` (`:176`) -> scope filter (`:153`) ->
  `Get-ModelRoutingCheckpoint` (`:157`) -> `Test-Path -LiteralPath` (`:49`). In the standalone
  topology, target resolution and the former cwd binding must yield the **identical absolute path**.
- **The presence-only gating contract of `enforce-model-routing-receipt.ps1` is preserved exactly.**
  `.claude/rules/orchestrator-state.md:107` states that this hook "performs presence-only gating
  before a delegation"; the hook's own header (`:11-15`) records that it cannot read the delegate's
  chosen `model` because no `model` field is exposed in the tool input, so it verifies only that a
  `model_routing_receipts[]` entry already exists for the target `subagent_type`. Correctness of the
  recorded model stays with the authoritative Python validator, which runs elsewhere. All six
  decision branches keep their current semantics:
  1. envelope anomaly -> deny `MODEL_ROUTING_RECEIPT_BLOCKED: payload anomaly ...` (`:136-147`);
  2. extract `tool_input.subagent_type` (`:149`);
  3. empty, or not in the gated set -> allow (`:153-155`). Gated set (`:73-80`): `atomic-planner`,
     `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, `pr-author`;
     `orchestrator` is deliberately excluded (`:18-21`);
  4. read the checkpoint (`:157`);
  5. a `model_routing_receipts[]` entry whose `agent` string-equals the subagent -> allow
     (`:158-160`);
  6. otherwise -> deny `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to ...` (`:162-168`).
  `Test-ModelRoutingReceiptPresent` keeps returning `$false` for a `$null` checkpoint (`:100-102`)
  and when the `model_routing_receipts` property is absent (`:103-105`);
  `Get-ModelRoutingCheckpoint` keeps returning `$null` on a missing file (`:49-51`) and on
  unparseable JSON (`:53-59`). That is the fail-closed direction and it is preserved verbatim.
- **No enforcement hook may invoke Python.** This is currently satisfied, not a migration: the
  `$Invoker` seam (`OrchestratorState.psm1:430-468`) invokes nothing external and names no
  interpreter on any code path; the Python leg was deleted by issue #475. The live risk is
  regression only, so F5 carries a guard rather than a change.
- **`.claude/lib/orchestrator-state/OrchestratorState.psm1` is not modified** (499/500 lines).
- **The latent fourth binding at `OrchestratorState.psm1:427`** (a `[string] $CheckpointPath`
  parameter default holding the same relative literal) is not reached today, because helpers `:240`
  always passes `-CheckpointPath` explicitly. It must stay unreached; a regression guard covers it.

### Dependencies or blocked work:

- **F1 (`target-worktree-resolution-module`, wave 0) is a hard upstream dependency.** F1 must be
  merged into `epic/worktree-scoped-state-resolution-integration`, **with its `core.json` entry and
  its `*.Manifest.Tests.ps1`**, before F5's implementation phase begins. A `.claude/lib/` module is
  not delivered by push-down unless it is listed in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]`; if F5
  merged first, the pushed-down payload would contain an F5 hook importing a module push-down does
  not deliver, and the hook would fail at load.
- F5's research and spec are complete without F1. F5's **code** cannot be written until F1's
  identifiers exist. The first implementation step after reproduction is to read F1's merged module
  and fill the binding table below; that step's output is archived as evidence.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- `.claude/hooks/enforce-pr-author-skill.ps1` — binding 1.
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` — binding 2.
- `.claude/hooks/enforce-model-routing-receipt.ps1` — binding 3.
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — no binding, but the ambiguity deny must be
  placed after the pr-author scope filter, which lives in `Get-PrAuthorBypassReason` at `:181-183`.
- The mirror copy of each edited file under
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
- New Pester files under `tests/scripts/claude-hooks/` and committed fixtures under
  `tests/fixtures/`.

The edited-file count under `.claude/hooks/` is four, matching research Claim N2. Each of the four
requires its bundled mirror copy to be updated in the same change.

#### Functions/classes/CLI commands impacted:

1. `enforce-pr-author-skill.ps1` — `$script:OrchestratorStateCheckpointPath` becomes the resolved
   **absolute** path, or the hook emits the ambiguity deny before helpers are consulted. Helpers
   `:240`/`:243` then need no change.

   **Required form of the line-49 change.** The assignment at `:49` must be replaced by an
   initialisation to `$null` at script scope; it must not be deleted outright. Under
   `Set-StrictMode -Version Latest`, an unset script-scoped variable raises when
   `Get-PrAuthorBypassReason` evaluates it, which breaks every test that dot-sources the hook. A
   surviving `$null` initialisation at script scope is therefore the required form and is **not** a
   residual cwd-relative binding: it carries no path literal and cannot resolve against the process
   working directory. Reviewers must not record it as a failure to remove the cwd-relative binding.
   AC-4 is satisfied by this form.
2. `enforce-pr-author-skill.epic-base-branch.ps1:78` — pass the resolved path explicitly:
   `Get-PrAuthorCheckpointContent -CheckpointPath $script:OrchestratorStateCheckpointPath`. Make the
   `-CheckpointPath` parameter **mandatory** so the relative default cannot reappear on a future
   call site. This changes check 6's fail-open semantics only in the ambiguous case, where the hook
   has already denied upstream, so the `epic_mode` false/absent no-op guards stay green.
3. `enforce-model-routing-receipt.ps1:157` — pass the resolved path explicitly to
   `Get-ModelRoutingCheckpoint`; make `:46`'s parameter mandatory for the same reason.

Module import follows the uniform in-repo idiom,
`Import-Module (Join-Path $PSScriptRoot '../lib/<dir>/<Module>.psm1') -Force`, which resolves from
the script's own location and is already worktree-correct. The import is **unconditional at script
scope**; the `Get-Command ... -ErrorAction SilentlyContinue` tolerance used at
`OrchestratorState.psm1:437-439` must **not** be copied into a decision path, because a gate that
silently degrades when F1's module is absent is a fail-open. A missing module must be a hard load
failure at install time, not a silent allow at gate time.

#### Data flow and validation changes:

Only *which path string* reaches the existing validation changes. The validation implementations are
untouched. The resolved path is passed **absolute**, which is what permits
`OrchestratorState.psm1` to remain unmodified.

Ordering rules (these must hold exactly):

- **pr-author** decision order is unchanged: Case A -> Case B -> `gh pr edit` no-body allow ->
  Case C (`PR_CONTEXT_MISSING`) -> orchestrator-state preflight -> receipt checks 1-6. The new
  ambiguity deny sits **after** the scope filter at helpers `:181`, so a non-`gh pr` command is
  never denied for ambiguity, and **before** the orchestrator-state preflight, so an unresolvable
  target never reaches a validation that would be meaningless.
- **model-routing** decision order is unchanged: `:136` anomaly -> `:153` scope filter -> `:157`
  checkpoint read -> `:158` presence -> `:162` deny. The ambiguity deny sits between `:155` and
  `:157` — after the gated-subagent scope filter, before the checkpoint read.

Edge cases:

- Checkpoint present at the resolved target but empty or invalid JSON: this is a **genuine-absence
  deny**, not an ambiguity deny. The existing fail-closed handling
  (`OrchestratorState.psm1:175-193`; `enforce-model-routing-receipt.ps1:53-59`) must be reached
  **after** resolution.
- Target resolves to a path that is not inside any worktree: **ambiguity deny**.
- A command that names two different worktrees (for example a chained `cd A && ... && cd B`):
  **ambiguity deny, not first-match**.

#### Error handling and logging updates:

One new deny reason is introduced: the ambiguity reason code supplied by F1. It is distinct and
greppable, and it must not be conflated with either existing reason. No existing reason string
changes. No new logging surface is added; the hooks' existing decision-JSON output is the only
channel.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. A flag on a fail-closed gate would create a configuration in which the defect is
still live, which defeats the purpose. Rollback is reverting the change set, which restores the
prior (defective) behaviour; the bundled mirror must be reverted in the same operation.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Inputs are unchanged: the Claude Code PreToolUse envelope on stdin, with `tool_name` and
`tool_input` (`command` for the Bash-gated pr-author hook; `subagent_type` and `prompt` for the
Agent-gated model-routing hook). Outputs are unchanged in shape: the existing decision JSON with
`permissionDecision` and a reason string, plus exit code 0.

#### Required configuration keys and defaults:

None added. The relative-literal defaults at the three binding sites are removed or made mandatory;
no replacement default is introduced, because a default is exactly what produces the sibling
fallback.

#### The F1 contract — bound by role, not by spelling

F5 consumes the F1 target-resolution module through three named contract **roles**:

- **`<TARGET_DERIVATION>`** — given the PreToolUse payload, returns the worktree the call pertains
  to, or an explicit "no target" result.
- **`<PATH_NORMALISATION>`** — given a path in relative or absolute form, returns its repo-relative
  form by locating the containing worktree. Segment-count truncation is prohibited.
- **`<AMBIGUITY_REASON_CODE>`** — the single distinct, greppable code emitted when the correct target
  cannot be identified.

These role names are **spec vocabulary only**. They must not appear in F5's code, in F5's tests, or
in any asserted search token. The concrete module path, exported function names, and reason-code
literal are **bound at implementation time** from F1 as merged into
`epic/worktree-scoped-state-resolution-integration`, and recorded in the binding table below. F5 must
not define, re-implement, or re-spell any of the three; a second definition of the reason code in
F5's tree is a blocking defect.

A placeholder literal is deliberately **not** written into this spec. A placeholder would be copied
into F5's code and tests and then diverge from F1's actual spelling, producing two reason codes for
one condition — the same "second implementation that drifts" failure this epic exists to eliminate.

##### BINDING TABLE — filled in by the executor at implementation time; do not guess

| role | concrete identifier (fill in from F1 as merged) | source file:line in F1 |
| --- | --- | --- |
| module path | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` carries the derivation role; its sibling `.claude/lib/worktree-resolution/WorktreeResolution.psm1` carries the normalisation and reason-code roles | registered at `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:169` and `:170` |
| module import statement | `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeTargetResolution.psm1') -Force` **and** `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force`; both are required because F1's own sibling import is module-scoped and re-exports nothing, verified by observation | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27`, consumed in that two-statement form at `.claude/hooks/enforce-pr-author-skill-helpers.ps1:39` |
| `<TARGET_DERIVATION>` function name | `Resolve-WorktreeCallTarget` | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:233`, exported at `:346` |
| `<PATH_NORMALISATION>` function name | `ConvertTo-WorktreeResolutionRepoRelativePath` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:421`, exported at `:498` |
| `<AMBIGUITY_REASON_CODE>` accessor function name | `Get-WorktreeResolutionAmbiguityReasonCode` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:463`, exported at `:499` |
| `<AMBIGUITY_REASON_CODE>` literal value returned by that accessor | `TARGET_WORKTREE_AMBIGUOUS` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:55`, returned at `:472` |
| `<NO_TARGET_REASON_CODE>` accessor function name | `Get-WorktreeResolutionNoTargetReasonCode` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:475`, exported at `:500` |
| `<NO_TARGET_REASON_CODE>` literal value returned by that accessor | `TARGET_WORKTREE_NOT_DERIVABLE` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:59`, returned at `:487` |
| `<TARGET_DERIVATION>` identity form (Revision 0.5) | `Resolve-WorktreeItemTarget` | `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:337`, exported at `:392` |

The filled table, together with the F1 source lines it was read from, is archived under
`evidence/other/` as the record that the binding was performed against merged source rather than
assumed.

##### Upstream dependency note for F1's author

F5 requires F1 to export the ambiguity reason code through an **accessor function**, modelled on the
existing `Get-ClaudeHookPayloadAnomalyCode` (`.claude/lib/hook-payload/HookPayload.psm1:66-85`),
which exists precisely so that callers need not hard-code the literals in a second place
(`:68-70`). F5 obtains the literal only by calling that accessor. If F1 ships the code as a bare
exported constant with no accessor, F5's binding step must raise it with F1's author rather than
hard-coding the string.

#### Backward-compatibility expectations:

- No change to any allow path, any existing deny reason string, or either scope filter.
- No change to the checkpoint schema; F5 reads the same keys from the same structure.
- Callers of `Get-PrAuthorCheckpointContent` and `Get-ModelRoutingCheckpoint` must supply
  `-CheckpointPath` once the parameter is mandatory. Both functions have exactly one production call
  site each, both updated in this change. Test call sites are updated in the same change.

#### Performance constraints (latency/throughput/memory):

No stated numeric budget. The change adds one in-process resolution call per gated tool call and
removes no work; both hooks remain single-pass, in-process, and start no subprocess. Any
implementation that starts a process per gate invocation is rejected.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The reproduction environment can launch `pwsh` directly, or can run Pester out of process via
    `mcp__drm-copilot__run_poshqc_test`. At least one route must be available; both are named.
  - F1's module will expose target derivation as a named, mockable function, which is what permits
    the cheap table-driven rows to inject the seam rather than build directories.
  - **Unverified:** whether the Claude Code PreToolUse envelope carries a `cwd` key. No hook in the
    repository reads one and there is no in-repo evidence either way. F1 must establish this
    empirically; F5 must not assume it.
- Constraints (budget, performance, compatibility):
  - No production, test, or reusable script file may exceed 500 lines.
  - `OrchestratorState.psm1` is at 499/500 and must not be modified.
  - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is measured at 447 lines
    (53 lines of headroom); the new matrix goes in **new sibling test files**.
  - No temporary files in tests. Fixture roots must be committed repository content.
  - Line coverage >= 85%. Pester measures no branch coverage, so no branch-coverage gate applies.
  - Enforcement hooks are PowerShell or bash only; no Python.
- External dependencies (services, libraries, releases):
  - F1, merged into the epic integration branch with its `core.json` entry and manifest tests.
  - No new third-party dependency.

## Data / API / Config Impact
- User-facing or API changes: none. Both hooks are PreToolUse enforcement gates with no user-facing
  surface. One new deny reason becomes visible to an agent that triggers the ambiguous condition.
- Data or migration considerations: none. No checkpoint schema change, no migration.
- Logging/telemetry updates (if any): none beyond the new deny reason in the existing decision JSON.
- Compatibility notes (CLI flags, config schemas, versioning): `.claude/settings.json` hook wiring is
  unchanged. `core.json` needs no new entry for F5 unless F5 adds a new `.claude/**` file; all four
  in-scope hooks are already registered at `core.json:34`, `:44`, `:45`, `:46`.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: table-driven Pester over the cross product of cwd (session root vs item
      worktree), path form (relative vs absolute), and target (own item, sibling item, absent)
- [x] Integration scenario to retest: sibling-checkpoint-only case must deny with the ambiguity
      reason code; own-checkpoint-present cases must behave exactly as they do now
- [x] Manual verification notes: consume the target-worktree resolution contract delivered by epic
      feature F1 rather than re-implementing resolution locally; mirror every `.claude/**` edit into
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`

### The mandatory matrix

Table-driven Pester over the cross product of **cwd** (session root vs item worktree) x **path form**
(relative vs absolute) x **target** (own item vs sibling item vs absent), applied to **both** hook
families. The following rows are mandatory. Rows marked "unchanged" currently pass and are
**regression guards**; they must not be omitted as redundant.

| # | case | expected decision |
| --- | --- | --- |
| R1 | own item's checkpoint present and satisfactory | allow (unchanged) |
| R2 | **sibling's checkpoint is the only state present** | **deny with the distinct ambiguity reason** (currently allows — this is defect 3.2 / 3.4) |
| R3 | own checkpoint present but genuinely not ready | deny, existing reason (unchanged) |
| R4 | own and sibling checkpoints both present | resolves to **own**, never the sibling |
| R5 | no checkpoint resolvable at all | deny with the ambiguity reason code |
| R6 | cwd = item worktree, own checkpoint present | allow (unchanged) — the standalone guard |
| R7 | checkpoint present at the resolved target but empty or invalid JSON | genuine-absence deny, existing reason — **not** an ambiguity deny |
| R8 | target resolves outside any worktree | ambiguity deny |
| R9 | command names two different worktrees | ambiguity deny, **not** first-match |
| R10 | command is not a gated `gh pr` invocation / subagent is not in the gated set, and the target is unresolvable | allow (scope filter runs first) |

**R2 is the single most important assertion in this feature.** It is the row that distinguishes a
gate that resolves its own item's state from one that reports a green derived from a different
item's state. If R2 is not present and passing, the feature is not delivered regardless of the rest.

### The test-design constraint that shapes the new tests

The suite's dominant idiom — mocking the checkpoint reader (`Get-PrAuthorCheckpointContent`,
`Get-ModelRoutingCheckpoint`, `Invoke-OrchestratorStatePreflight`) — **cannot express R2**, because
mocking the reader replaces the resolution step under test. A sibling-case test that mocks the reader
asserts the hook's behaviour given a checkpoint object, not which checkpoint it chose; it would pass
without testing anything. This is stated explicitly because it is the path of least resistance and it
produces a verification gate that cannot fail.

Measured coverage of the required matrix today is effectively zero: a content search for
`Set-Location` and `Push-Location` across `tests/scripts/claude-hooks/` returns no matches, so no
test varies cwd at all; the only place a checkpoint path is chosen uses a relative path; and the
sibling case does not exist anywhere in the suite.

Required test construction:

- **Committed fixture roots under `tests/fixtures/`** for the rows that need two real directories
  (R2, R4, R6). Committed repository content is not a temporary file, so the no-temporary-files rule
  is not engaged. A fixture pair is one "session root" holding a ready sibling checkpoint and one
  "item worktree" holding its own checkpoint or none. The test spawns the hook out of process with
  its working directory set to the chosen fixture root, following the existing spawn pattern in
  `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:54-103`.
- **Seam injection** (mocking F1's target-derivation function, not the checkpoint reader) for the
  remaining table-driven rows, keeping the matrix cheap and fast.
- **Do not** create fixture directories from within a test. That is the one approach the
  no-temporary-files rule forbids.
- **Fixture-name collision check, not covered by research.** `.claude/rules/orchestrator-state.md`
  scopes itself with the path glob `artifacts/orchestration/*orchestrator-state.json`, and other
  tooling globs the same shape. Before committing a fixture whose relative path ends in
  `artifacts/orchestration/orchestrator-state.json`, confirm that no repository validator, hook, or
  path-scoped rule matches it outside `tests/fixtures/`. If a collision exists, keep the fixture
  directory layout and supply the trailing filename through the hook's resolved-path parameter
  instead of reproducing the exact glob shape.
- The fixture roots contain no `.claude/` tree of their own, so the hook must be invoked by
  **absolute** script path while the spawned process's working directory is the fixture root.

Two mechanical traps:

1. `Push-Location` changes `$PWD` but **not** `[Environment]::CurrentDirectory`. `Test-Path` and
   `Get-Content` follow `$PWD`; `[System.IO.File]::ReadAllBytes` at
   `enforce-pr-author-skill.ps1:92` follows `[Environment]::CurrentDirectory`. In an out-of-process
   invocation they agree; in an **in-process** Pester test that uses `Push-Location` they diverge and
   the body-file read hits the wrong directory. Prefer out-of-process with an explicit working
   directory, or set both.
2. Tests must be order-independent. Any cwd or environment change must be restored in a `finally`,
   matching the `$env:CLAUDE_TOOL_INPUT` save/restore at
   `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:78-101`.

- Regression tests to add or update:
  - Preserve and keep passing: `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:26-37`
    (evidence genuinely absent -> deny), `:39-51` (present but not ready -> deny with summarised
    text), `:64-102` (end-to-end deny in a real `pwsh` process, exit 0);
    `enforce-model-routing-receipt.Tests.ps1:62-68` (receipt present -> allow),
    `:71-92` (receipt absent / checkpoint missing -> deny), `:20-58` (envelope anomalies deny;
    out-of-scope subagents allow);
    `enforce-pr-author-skill.epic-base-branch.Tests.ps1:22-42` (`epic_mode` false/absent and
    non-create -> no-op).
  - Add row R6 as a new guard and observe it passing on the **unmodified** hooks before the fix.
  - Add a guard that `OrchestratorState.psm1:427`'s latent default stays unreached.
- Unit tests for the fixed behaviour and boundaries: new sibling Pester files, for example
  `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` and
  `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`. Tests
  mirror production structure under `tests/`; no file exceeds 500 lines.
- Edge cases and negative scenarios: rows R7, R8, R9, R10 above, plus envelope-anomaly rows retained
  unchanged.
- Error handling and logging verification: assert that the ambiguity deny reason and the two existing
  deny reasons are mutually distinguishable in the emitted decision JSON, and that the ambiguity
  reason never appears on a genuine-absence case.
- Coverage impact and targets for changed lines/modules: all four in-scope hooks are named coverage
  targets in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, so the >= 85% line floor
  applies to every new line. Pester measures no branch coverage; no branch gate applies. Coverage
  output is archived under `evidence/qa-gates/`.
- Non-Python guard: confirm issue #475's structural guard (asserting zero Python command invocations
  in the guarded tree) still covers the in-scope files. The guard is
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, with detection
  logic in the sibling `EnforcementHooksNoPythonInvocation.Helpers.ps1`. Its two scan roots,
  `.claude/hooks` and `.claude/lib`, are enumerated recursively, so all four in-scope files are
  already covered and no extension is expected. The obligation is to run the guard and record that
  coverage. If a further assertion is ever needed, add a new sibling test file: the guard file is
  measured at exactly 500 lines and cannot absorb another line.
- Coupling guard: assert the change set touches neither `.claude/hooks/hook-command-scanner.ps1`,
  nor `.claude/hooks/hook-command-invocation.ps1`, nor `.claude/hooks/enforce-epic-merge-gate.ps1`,
  nor `.claude/lib/orchestrator-state/OrchestratorState.psm1`.
- Mirror gate: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  enumerates every file under `.claude/` and asserts both presence in the bundle and equal contents,
  so the mirroring obligation is machine-enforced. This test is the mirroring proof; no ad-hoc diff
  substitutes for it.
- Toolchain commands to run (format -> lint -> type-check -> test): the full seven-stage loop per
  `.claude/rules/general-code-change.md`, repeated until all stages pass in a single pass. Type
  checking is skipped for PowerShell.
- Manual validation steps (if required): none beyond the reproduction step, which is executable and
  archived under `evidence/baseline/`.


## Revision 0.5 — Identity-Based Target Resolution

### 1.1 Established facts (empirical probe, 2026-09-18; treated as established)

1. A PreToolUse hook runs in the directory of the process that made the call. A call made from inside an item's own worktree already reads that worktree's checkpoint through the relative path.
2. An isolated subagent (`Agent` with `isolation: worktree`) gets a worktree built from `origin/main`'s tip, and its hooks run inside that worktree using `main`'s copy of the hook scripts. A hook change on this branch therefore cannot be exercised end to end by isolated subagents before merge. **All pre-merge verification in this plan is in-process or child-process Pester and the Python suite. No task delegates to an isolated subagent to verify behaviour.**
3. The hook payload's `cwd` field is, for the calls that produce false approvals, the coordinator's directory, not the item's. It is never used to identify the item.
4. False approvals arise only from calls made by a process whose directory is not the item's worktree: a coordinator delegating gated work on an item's behalf, or a process acting on an item through `cd` or `git -C`. The incident was green because a stale per-feature checkpoint for issue 838 sat at the coordinator's root.
5. `Resolve-WorktreeCallTarget` reads signals in the order FeatureFolderPath, FilePath, Branch (`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:276-280`) and treats any signal with other than exactly one candidate as `Ambiguous` (`:289-293`). A feature folder merged to `main` exists in every checkout branched from `main`, so a relative folder token is almost always `Ambiguous`, and it overrides a branch signal that is unique. Verified: `branch: <item branch>` alone resolves uniquely; the same text plus the relative folder path resolves `Ambiguous`. The folder identifies what the work is, not where it lives.
6. Verified 2026-09-18: a coordinating session delegating `atomic-planner` for an item whose feature folder has merged, and therefore also exists in other checkouts, matched twelve candidate worktrees and was denied `TARGET_WORKTREE_AMBIGUOUS` by `.claude/hooks/enforce-prd-feature-before-planner.ps1`. That is the ordinary state of a folder after merge, so the gate denies the ordinary case. §2.7.5 makes it a regression case.

### 2.1 Identity resolution module (design B)

New module `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`, beside F1's two modules. It imports `WorktreeResolution.psm1` and `WorktreeTargetResolution.psm1` with `-ErrorAction Stop` and re-uses F1's enumeration, marker test, ascent, branch reader, path normaliser, path join, result constructor, and reason-code accessors. It re-implements none of them. `WorktreeResolution.psm1` (500 lines) and `WorktreeTargetResolution.psm1` are **not modified**, so no extraction is needed; the coupling guard in [P10-T5] asserts both are absent from the diff.

Exported functions (all `[CmdletBinding()]`, each with `[OutputType()]` declared to match what it returns, including `[string[]], [object[]]` where it returns `, [string[]]`):

| Function | Contract |
| --- | --- |
| `Get-WorktreeItemCheckpointRelativePath` | Returns the one definition of the literal `artifacts/orchestration/orchestrator-state.json`. |
| `Get-WorktreeItemCheckpointPath -WorktreeRoot` | Returns `Join-WorktreeResolutionPath -WorktreeRoot <root> -RepoRelativePath (Get-WorktreeItemCheckpointRelativePath)`, an absolute forward-slash path. |
| `Find-WorktreeItemIssueSignal -Text` | Returns, as `, [string[]]`, the distinct normalised issue numbers named by lines matching `Canonical issue number for this feature is <digits>` (case-sensitive, optional `#` before the digits), in order of first appearance. |
| `ConvertTo-WorktreeItemIssueNumber -Value` | Pure. Returns the positive-integer issue number as a digit string without leading zeros for an integer value or a string of the form optional `#` plus digits (whitespace trimmed); `$null` for anything else, including zero, `none`, and an empty value. |
| `Get-WorktreeItemCheckpointText -Path` | The module's only filesystem read (seam): raw text of a file, or `$null` when absent or unreadable. |
| `Get-WorktreeItemCheckpointIssue -WorktreeRoot` | Reads the checkpoint at `Get-WorktreeItemCheckpointPath` through the seam, parses it with `ConvertFrom-Json` inside `try`, and returns `ConvertTo-WorktreeItemIssueNumber` of its `issue-num` property; `$null` when the file is absent, empty, unparseable, not a JSON object, or lacks the key. |
| `Get-WorktreeItemLiveRoot -SessionRoot [-Branch]` | Seam. Ascends from `SessionRoot` with `Find-WorktreeResolutionRoot`; when no worktree root is found returns an empty array. Otherwise returns `Get-WorktreeResolutionWorktreeRoot -SessionRoot <ascended root> [-Branch <b>]` filtered to roots for which `Test-WorktreeResolutionRootMarker` is true. |
| `Resolve-WorktreeItemTarget -Text [-SessionRoot]` | Always returns an object built by `New-WorktreeResolutionTargetResult`. Algorithm in §2.2. `SessionRoot` defaults to `(Get-Location).ProviderPath`. |

**Definition of live.** A worktree root `W` is live when (L1) it is registered in the administrative layout of the repository containing the calling process's directory, which is the main checkout plus every `worktrees/<name>/gitdir` registration (`Get-WorktreeResolutionWorktreeRoot`), and (L2) `Test-WorktreeResolutionRootMarker -Path W` is true, meaning the directory exists and its `.git` entry is a directory or a well-formed `gitdir:` file. A registration whose directory was deleted (git's "prunable" state) fails L2 and is excluded. A worktree records issue `N` when `Get-WorktreeItemCheckpointIssue -WorktreeRoot W` equals `N`. Only the canonical checkpoint path is read, so a checkpoint archived under `artifacts/orchestration/handoff/` is never matched.

**Stale attempts at the same issue.** A worktree from an earlier attempt is excluded when its directory is gone (L2) or its checkpoint was archived or removed. When it is still live and still records issue `N`, the issue alone places the call in two worktrees, which is `Ambiguous`. The only tie-breaker is a branch signal in the same call: git checks a branch out in at most one worktree, so the branch names exactly one of them. No timestamp, `last_updated`, lifecycle step, or path proximity is ever read to break the tie, because a stale checkpoint carries those values too; choosing by them is the defect class this feature removes. The ambiguity detail names the remedy: archive the stale checkpoint (design A) or add a `branch:` label.

### 2.2 Resolution algorithm (`Resolve-WorktreeItemTarget`)

Let `I` be the issue numbers from `Find-WorktreeItemIssueSignal`, `B` the branch from `Find-WorktreeResolutionBranchSignal` (first match, F1's reader unchanged), and `S` the normalised session path. Decided in this order:

| # | Condition | Status | Detail (no absolute path is ever included) |
| --- | --- | --- | --- |
| 1 | `I` has more than one member | Ambiguous | `the call names <k> different issue numbers (<list>), and an item has exactly one` |
| 2 | `I` empty and `B` absent | NoTarget, returned before any enumeration or file read | `the call carries neither a canonical issue number line nor a branch signal (--head, --branch, or branch:), so the item it acts on cannot be identified` |
| 3 | `B` present: `MB = Get-WorktreeItemLiveRoot -SessionRoot S -Branch B` has 0 members | NoTarget | `branch '<B>' is checked out in no live worktree` |
| 4 | `B` present: `MB` has more than one member | Ambiguous | `branch '<B>' is checked out in <k> live worktrees` |
| 5 | `B` present, `MB = {W}`, `I` empty | resolved `W` | `branch '<B>' resolves to the live worktree that has it checked out` |
| 6 | `B` present, `MB = {W}`, `I = {N}`, `W` records `N` | resolved `W` (this breaks a stale-attempt tie) | `branch '<B>' and issue <N> resolve to the same live worktree` |
| 7 | `B` present, `MB = {W}`, `I = {N}`, `W` records a different issue `M` | Ambiguous | `branch '<B>' places the call in a worktree whose checkpoint records issue <M>, not issue <N>` |
| 8 | `B` present, `MB = {W}`, `I = {N}`, `W`'s issue unknown, and some other live worktree records `N` | Ambiguous | `branch '<B>' and issue <N> place the call in different worktrees` |
| 9 | `B` present, `MB = {W}`, `I = {N}`, `W`'s issue unknown, no live worktree records `N` | resolved `W` | as row 5 |
| 10 | `B` absent, `I = {N}`: `MI` = live worktrees recording `N` has 0 members | NoTarget | `issue <N> is recorded in the orchestrator checkpoint of no live worktree` |
| 11 | `B` absent, `MI = {W}` | resolved `W` | `issue <N> resolves to the live worktree recording it` |
| 12 | `B` absent, `MI` has more than one member | Ambiguous | `issue <N> is recorded in the orchestrator checkpoints of <k> live worktrees; move the stale checkpoint to artifacts/orchestration/handoff/ or add a branch: label naming the item's branch` |

A resolved result has `Status` `SessionRoot` when `W` equals `S` or equals `Find-WorktreeResolutionRoot -Path S` (the latter evaluated only when the former is false), and `OtherWorktree` otherwise; `Signal` is `Branch` with `SignalValue` `B` when a branch was used, and empty otherwise; `Candidate` is `@(W)`. Ambiguous results carry the candidate roots in `Candidates` (an object field, never rendered into a reason). `ReasonCode` is supplied by F1's constructor: `NoTarget` carries the no-target code and `Ambiguous` the ambiguity code (user mapping, 2026-09-18: zero live matches or no identity deny with the no-target code; several, or disagreeing signals, deny with the ambiguity code).

The calling process's directory is used for exactly two things: to find the repository whose worktrees are enumerated, and to label a resolved result `SessionRoot`. It is never the checkpoint location unless identity resolution selects it. The payload `cwd` field is not read.

### 2.3 Signal precedence decision (point 5)

**Decision: a feature folder is used only to find documents and never to choose the worktree.** `Resolve-WorktreeItemTarget` reads no path signal at all: an absolute or relative feature-folder path, and an absolute file path, are ignored for worktree selection. Ranking unique signals above location-ambiguous ones was rejected, because an absolute path is still host-dependent, and a ranked resolver would keep a path as a fallback selector.

The rule applies to all four gates this plan touches. The three bindings of §2.6 locate no documents at all, so they read no folder. The prd-feature gate does locate documents, and §2.7 gives it the folder in exactly that role: identity picks the worktree, then the folder names which documents to check beneath it.

### 2.4 Checkpoint hygiene (design A) and where it is enforced

**Rule.** A coordinating session never holds a per-feature `artifacts/orchestration/orchestrator-state.json` at its own root when it hands work off. It moves such a file to `artifacts/orchestration/handoff/orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json`, following the existing convention (`artifacts/orchestration/handoff/` already holds `orchestrator-state.epic-678-integration-pr-686.2026-09-18T10-37.json` in this worktree).

**Enforcement decision.**

1. **Skill contract (normative).** [P8-T2] to [P8-T4] add the rule to `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` (archive a checkpoint belonging to a different issue instead of overwriting or leaving it; archive on handing an item to another session or worktree), `.claude/skills/parallel-orchestrate/SKILL.md` `## Per-Item Branch and Worktree Lifecycle`, and `.claude/skills/epic-orchestrate/SKILL.md` `## Epic-Level Checkpoint`. A Pester contract test ([P8-T6]) asserts each statement is present, so the rule cannot be removed silently.
2. **Mechanical check inside the four gates.** Under identity resolution a stale root checkpoint can affect a verdict only when it records the same issue as the call. In that case the root is a second live worktree recording the issue, and §2.2 row 12 denies `Ambiguous` with the archive remedy in the reason. A stale checkpoint for a different issue is never read by these gates. The gates therefore enforce hygiene exactly where it could change their verdict, with no new deny path.
3. **No separate hook or validator check is added.** A check that denied on the mere presence of a foreign checkpoint would add a deny path to gates for a condition that is not itself a gated action, and a Python validator check would require a TypeScript parity port. Neither is needed for the correctness of the four gates. The gates that still read cwd-relative checkpoints are listed in §8 as the places where hygiene continues to matter; they are tracked under issue #690 and are out of scope here.

**Delegation identity (skill contract).** `.claude/skills/orchestrate/SKILL.md:258` currently requires the canonical issue line only on delegations to `atomic-planner`, `atomic-executor`, and `feature-review`. [P8-T2] extends it to all six receipt-gated types (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, `pr-author`, matching `Get-ModelRoutingGatedAgent` at `.claude/hooks/enforce-model-routing-receipt.ps1:73-80`) and adds a `branch:` label naming the item's branch, written as the first `branch:` occurrence in the prompt. Before promotion assigns an issue number, the branch label alone is required. The same paragraph names both identity-resolving gates, `enforce-model-routing-receipt.ps1` and `enforce-prd-feature-before-planner.ps1`, because after Phase 9 an `atomic-planner` delegation is read for identity by both. The contract test pins the skill's agent list to the gate's list.

### 2.5 Hook outcomes (all four gates)

| Resolution state | Action | Reason text begins with |
| --- | --- | --- |
| `SessionRoot` or `OtherWorktree` | proceed against the resolved worktree root; all existing decision logic runs unchanged | existing reasons only |
| resolved; checkpoint or document state is genuinely bad | existing deny, unchanged | `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (pr-author), `MODEL_ROUTING_RECEIPT_BLOCKED` (model-routing), `PRD_FEATURE_BLOCKED: resolved feature folder ... is missing:` or the work-mode reason (prd-feature) |
| `NoTarget` | deny | `$target.ReasonCode` (the no-target code) |
| `Ambiguous` | deny | `$target.ReasonCode` (the ambiguity code) |

There is no working-directory fallback on any branch. A target-resolution deny never contains a document-family or checkpoint-family reason, and a document-family or checkpoint-family deny never contains either target-resolution code. §2.7.4 states the one place where the prd gate emits a resolution code on a non-identity path and why it belongs to the resolution family.

### 2.6 Hook changes (bindings 1, 2, and 3)

- **DD-1 — pr-author seam body.** `Resolve-PrAuthorWorktreeTarget` keeps its name and `-CommandText` parameter; its body becomes `Resolve-WorktreeItemTarget -Text $CommandText -SessionRoot (Get-Location).Path`. `Get-PrAuthorTargetCheckpointResolution` merges `SessionRoot` and `OtherWorktree` into one branch returning `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot`; its deny branch and reason text are unchanged (#687 behaviour, including the `--head` remedy). `enforce-pr-author-skill-helpers.ps1` adds `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop` after its two F1 imports (`:38-39`), which stay.
- **DD-2 — resolve once, pass explicitly (bindings 1 and 2).** `enforce-pr-author-skill.ps1:49` becomes `$script:OrchestratorStateCheckpointPath = $null` (the spec's required form). In `Get-PrAuthorBypassReason`, after the deny check, `$script:OrchestratorStateCheckpointPath` is assigned the resolved absolute path and passed to `Invoke-OrchestratorStatePreflight -CheckpointPath`, to `Test-PrAuthorReceiptVerification -CheckpointPath` (new mandatory parameter), and on to `Test-EpicBaseBranchOverride -CheckpointPath` (new mandatory parameter), which passes it to `Get-PrAuthorCheckpointContent -CheckpointPath` (now mandatory, default removed).
- **DD-3 — model-routing (binding 3).** `enforce-model-routing-receipt.ps1` imports `WorktreeItemResolution.psm1` at script scope with `-Force -ErrorAction Stop` after the `HookPayload.psm1` import at `:36`. New seam `Resolve-ModelRoutingWorktreeTarget -PromptText` calls `Resolve-WorktreeItemTarget -Text $PromptText -SessionRoot (Get-Location).Path`. New `Get-ModelRoutingTargetCheckpointResolution -PromptText` maps §2.5 and returns an ordered dictionary with `CheckpointPath` and `Reason`. The reason for an unresolved target is `"$($target.ReasonCode): $($target.Detail) The model-routing gate will not check this delegation against a checkpoint that may belong to a different item. Put the line 'Canonical issue number for this feature is <N>.' and a 'branch: <item branch>' label in the delegation prompt so the gate can identify the item."`. The deny sits between the scope filter (`:153-155`) and the checkpoint read (`:157`), which becomes `Get-ModelRoutingCheckpoint -CheckpointPath $resolution.CheckpointPath`; `Get-ModelRoutingCheckpoint`'s parameter becomes mandatory with no default. Only the `prompt` field is scanned.

### 2.7 prd-feature gate migration (design C, issue #672)

The gate's job is unchanged: block an `atomic-planner` delegation whose feature folder does not yet hold the prerequisite documents its persisted work mode requires. What changes is how it decides *where* to look.

#### 2.7.1 Identity picks the worktree

- **DD-4 — derivation seam.** `Get-PrdFeatureCallTarget` loses its `-Envelope` parameter and keeps `-ToolInput`. It assembles the prompt and description text exactly as today (`.claude/hooks/enforce-prd-feature-before-planner.ps1:265-267`) and returns `Resolve-PrdFeatureWorktreeTarget -Text $text`. That new one-line seam calls `Resolve-WorktreeItemTarget -Text $Text -SessionRoot (Get-Location).Path`. The envelope `cwd` read at `:272-275` is deleted with the parameter, so the gate has no syntactic route to it. The file's `Import-Module` of `WorktreeTargetResolution.psm1` (`:108`) **stays**, and an import of `WorktreeItemResolution.psm1` is added immediately after it, unguarded for the same stated reason — the two-import form of `.claude/hooks/enforce-pr-author-skill-helpers.ps1:38-39`.

  **Why both imports, not a swap (orchestrator ruling, 2026-09-19).** `Join-WorktreeResolutionPath`, which the probe composition at `:381` calls, is defined at `WorktreeTargetResolution.psm1:311` and appears only in that file's explicit `Export-ModuleMember -Function` list at `:341-347`. `WorktreeResolution.psm1`'s list at `:490-500` does not carry it. A module that imports a sibling does not re-export the sibling's functions to its own importer when its exports are pinned by an explicit list, so importing `WorktreeItemResolution.psm1` alone would not put `Join-WorktreeResolutionPath` in the gate's scope. Swapping the import would therefore make `:381` an unresolvable command on every `OtherWorktree` result — the coordinator case this feature exists to fix — and [P9-T9] row 1 could not pass. Keeping both imports is the minimal change, follows the precedent already in the tree for this exact reason, leaves the new module's export surface at the eight functions §2.1 specifies, and keeps DD-8's claim that `:379-382` is unchanged.

  **Scope sweep (recorded so it is not re-derived).** The same rule was checked against every other consumer in this plan and no second instance exists. `enforce-pr-author-skill-helpers.ps1` already imports both F1 modules explicitly and DD-1 adds the third. `enforce-model-routing-receipt.ps1` calls no F1 function — it reads `ReasonCode` and `Detail` as properties — so DD-3's single import suffices. `WorktreeItemResolution.psm1` imports both F1 modules itself and calls them from inside its own session state. The prd gate reaches `Get-WorktreeResolutionAmbiguityReasonCode` and the no-target accessor through the dot-sourced helpers' import of `WorktreeResolution.psm1` (`helpers:27`), because an `Import-Module` inside a dot-sourced file lands in the caller's session state; that is why the helpers' import is load-bearing for the parent and must not be removed. Every suite this plan authors imports all three modules explicitly per §4; the four pre-existing suites it edits import none or two and resolve through the hook and helpers they dot-source, which §4 records as sound and which no task changes.
- `Invoke-PrdFeatureBeforePlannerDecision` keeps its `-ResolvedTarget` injection seam and its `$PSBoundParameters.ContainsKey` binding rule unchanged.
- **DD-5 — unresolved identity denies first.** The Ambiguous-only check at `:337-339` becomes a check for `NoTarget`, for `Ambiguous`, and for a `$null` target from either source. It denies through `Get-PrdFeatureTargetDecision -ReasonCode <code> -Detail <detail>`, which replaces `Get-PrdFeatureAmbiguityDecision` (`:203-231`) and takes the code as a parameter instead of calling one accessor. `$null` has two origins and both mean the same thing: the `-ResolvedTarget` seam explicitly bound to `$null`, and `Get-PrdFeatureCallTarget`'s existing early return for empty text (`:268-270`), which DD-4 keeps so that a call carrying no text still performs no enumeration and no file read. For either, the code is `Get-WorktreeResolutionNoTargetReasonCode` and the detail is `the call target was not resolved`. The early return is load-bearing for a pinned assertion: `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1:186` asserts the resolver is invoked zero times for an empty-text call. The reason keeps the `PRD_FEATURE_BLOCKED: <code> - <detail>. ` prefix shape and replaces the remedy sentence, which currently instructs the caller to cite an absolute path (`:227-228`) and after this change would name an action that no longer selects anything. The new remedy is: `Put the line 'Canonical issue number for this feature is <N>.' and a 'branch: <item branch>' label in the delegation prompt so the gate can identify the item.` The deny still runs before any document probe.

#### 2.7.2 The folder locates documents beneath the resolved worktree

- **DD-6 — checkpoint fallback anchored to the resolved worktree.** `Get-PrdFeatureCheckpointFolder`'s `-CheckpointPath` parameter becomes `[Parameter(Mandatory)]` with no default (`:160`). The single production call site passes `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot`. The calling session's checkpoint is therefore never read unless identity resolved to the calling session's own worktree.
- **DD-7 — folder selection.** The parent computes `$candidates = @(Find-PrdFeatureFolderCandidate -Prompt $prompt)` as today (`:341`) and reads the checkpoint only when it needs it:
  - exactly one candidate: that candidate is the folder, and no checkpoint read occurs;
  - zero or more than one candidate: the checkpoint folder is read once, through DD-6.

  `Find-PrdFeatureFolderFromPrompt` replaces its `-Target` parameter with an optional `-CheckpointFolder`, and `Select-PrdFeatureFolderByTarget` (`helpers:211-244`) becomes `Select-PrdFeatureFolderByCheckpoint -Candidate -CheckpointFolder`, which normalises the checkpoint value through `ConvertTo-PrdFeatureFolderToken` and returns it when it is one of the candidates. The disambiguator is still not prompt position and is still not a foreign session's record: the checkpoint now consulted belongs to the worktree identity selected, which is the item's own. When it names none of the candidates the tie is unresolved and the gate denies with the ambiguity code, as today (`:346-348`), with the detail changed to name the checkpoint rather than a derived target. The replacement detail must retain the clause `cites $($candidates.Count) feature folders ($($candidates -join ', '))` verbatim, because `TargetResolution.Tests.ps1:417` asserts `*cites 2 feature folders*` and [P9-T5] step 5 keeps that assertion while [P9-T12] gates on the row.
  - When the prompt named no folder and the checkpoint supplied none, the decision logic of the existing `must reference a feature folder` deny at `:363-371` is unchanged. Its reason string at `:368` is reworded by [P9-T4], which is required rather than optional: that string is the file's second occurrence of the checkpoint filename literal, and three acceptance conditions require the literal to be gone from the file.
- **DD-8 — probe anchoring unchanged.** The probe folder is composed with `Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath $folderNormalized` when the resolved status is `OtherWorktree`, and is the bare repo-relative spelling when it is `SessionRoot` (`:379-382`, unchanged, including the call at `:381`). That call resolves only because DD-4 keeps the `WorktreeTargetResolution.psm1` import alongside the new one; the reasoning is recorded under DD-4 and is the single condition on which this bullet's "unchanged" claim depends. The `SessionRoot` case is correct because the gate is then executing inside the resolved worktree. The residual case — a process whose directory is a subdirectory of the resolved worktree — is recorded in §8; it is pre-existing, it can only produce a false denial, and closing it would rewrite the probe-path assertions of two suites that sit within fifty lines of the 500-line cap.
- **DD-8a — the folder-absent guard keeps its `$probeFolder -ne $folderNormalized` conjunct (`:393`).** Revision 4 proposed dropping it on the reasoning that composition is always absolute; DD-8 makes that false for a `SessionRoot` result, and dropping it would make `if ($null -eq $issueContent)` fire ahead of the work-mode branch on every session-root call whose `issue.md` is unreadable. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1:338-349` (`It 'denies with the indeterminate-marker reason when issue.md is unreadable'`) pins exactly that case and is a row [P9-T7] forbids editing. The conjunct is therefore kept byte-unchanged, which is also what §2.7.3 and §2.7.4 require.
- **DD-9 — dead branch removal.** `Test-PrdFeatureSessionRootTarget` (`:181-201`) and the deny at `:359-361` are deleted. Both exist to stop a session's own checkpoint standing in for another worktree's call; after DD-6 the checkpoint read is anchored by construction, so the guard is unreachable and would be uncovered code.

#### 2.7.3 Work-mode contract preserved exactly

`Resolve-PrdFeatureWorkMode`'s regex, its legacy `full` normalisation, and `Get-PrdFeatureRequiredFile`'s mapping and `default` arm (`helpers:52`, `:58-61`, `:90-95`) are not edited. `full-feature` requires `spec.md` and `user-story.md`; `full-bug` requires `spec.md`; `minor-audit` requires neither; an absent or unrecognised marker denies on its own branch (`:406-418`), naming no prerequisite set and running no required-file probe.

#### 2.7.4 Genuine denies preserved

A prerequisite document that is truly absent under the resolved folder still denies with the existing reason `PRD_FEATURE_BLOCKED: resolved feature folder '<folder>' is missing: <list> (work mode: <mode>). ...` (`:434-436`), which contains neither resolution code. The work-mode deny likewise contains neither.

One non-identity path keeps a resolution code: the resolved folder does not exist beneath a resolved worktree that is not the session root (`:393-395`, guarded by the DD-8a conjunct). That is a resolution failure and not a document failure — the gate cannot confirm it is looking at the item it resolved — so it stays in the resolution family and keeps the ambiguity code. What changes at that site is the decision helper and one phrase of the detail: the `return` on `:394` moves from the deleted `Get-PrdFeatureAmbiguityDecision` to `Get-PrdFeatureTargetDecision` with the ambiguity accessor passed explicitly, so the emitted code is identical and the detail differs only in reading `resolved target worktree` where it read `derived target worktree`. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1:481-497` (`It 'denies with the ambiguity reason when the folder is absent from the target root'`, asserting the code at `:495`) is a surviving row that requires exactly this, and it is not among [P9-T5]'s edits. When the resolved worktree is the session root the conjunct is false and an unreadable `issue.md` falls through to the work-mode branch, exactly as it does today. The gate therefore emits a resolution code on exactly three paths: unresolved identity, unresolved multi-candidate tie, and folder-absent-under-another-worktree. A named test asserts the two families never intersect.

#### 2.7.5 Regression case

A coordinating session delegates `atomic-planner` for an item whose feature folder also exists in other worktrees, which is the normal state once a folder has merged. Before this change the gate resolves folder-first, matches several worktrees, and denies `TARGET_WORKTREE_AMBIGUOUS` — observed 2026-09-18 with twelve candidate worktrees. After this change the prompt's canonical issue line resolves to the one live worktree whose checkpoint records that issue, the prerequisites are probed beneath it, and the call is allowed. [P9-T2] records the pre-change verdict deterministically and [P9-T9] row 1 asserts the post-change verdict.

#### 2.7.6 Files expected in the diff for #672

`.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, their two mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, the three existing suites `enforce-prd-feature-before-planner.Tests.ps1`, `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, the new suite `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1`, and `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`. `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` stay absent from the diff. No manifest edit is needed for #672: the two gate files are already registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` at `:48-49`, and the two F1 module paths at `:169-170`, which is the pair RS-9 cites and after which [P2-T4] inserts the new module.

## 3. Reconciliation record (every restated acceptance criterion)

| ID | AC | Original wording assumed | Restatement |
| --- | --- | --- | --- |
| RS-1 | AC-9, AC-10, AC-13, AC-15, AC-17 | one "ambiguity reason code" | Two target-resolution codes exist: the no-target code (no identity, or an identity that places in no live worktree) and the ambiguity code (several live worktrees, or disagreeing identities). Tests obtain both only from `Get-WorktreeResolutionNoTargetReasonCode` and `Get-WorktreeResolutionAmbiguityReasonCode`. AC-15 treats "the ambiguity reason code" as the set of both. AC-17 asserts one case per unresolved state. |
| RS-2 | AC-13 rows R8, R9 | R8 "target resolves outside any worktree"; R9 "a command naming two worktrees" | Paths no longer place a call. R8 becomes "an identity that places in no live worktree" (no-target code). R9 becomes "identities that place in different worktrees": two issue numbers, an issue and a branch that disagree, or an issue recorded by two live worktrees (ambiguity code); never first-match. |
| RS-3 | AC-9, AC-10 row R2 | the sibling-only case denies with the ambiguity code | R2's payload carries no identity, so it denies with the no-target code. A second model-routing R2 row uses the verbatim prompt of `evidence/baseline/repro-3-4-control-pair.md:28`, whose only path token is a repository-relative file path beneath a feature folder, and also denies with the no-target code, because neither a folder nor a file path is an identity. |
| RS-4 | AC-11 row R4 | own and sibling both present, verdict from own (mechanism unstated) | Proven through identity: the prompt or command names the own item by issue or branch, both fixture checkpoints are live, and the verdict comes from the own checkpoint. A further row proves a branch label breaks a stale-attempt tie. |
| RS-5 | AC-12 | fail-before observable for both families | pr-author R2 already denies on this tree (#687). Satisfied by the archived pre-#687 `allow` (`evidence/baseline/repro-3-2-control-pair.md`, AC-1, AC-2), the dossier `evidence/regression-testing/fail-before-exception.2026-09-19T09-00.md`, and the substitute binding-2 row `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present`, which allows before the fix and denies after it. The model-routing half is observed directly. |
| RS-6 | AC-14 row R7 | empty or unparseable checkpoint at a resolved target | Asserted on targets resolved by branch (§2.2 row 9) or by the hook seam. Under issue-only identity an unreadable checkpoint cannot be matched to its issue, so that call denies with the no-target code; that is still a deny and is stated, not hidden. |
| RS-7 | AC-8 | no fallback to the process working directory | The working directory only locates the repository and labels `SessionRoot` (§2.2). It is never the checkpoint location unless identity resolution selects that worktree. For the prd gate the one remaining use of the process directory is DD-8's `SessionRoot` probe spelling, which names the resolved worktree itself. |
| RS-8 | AC-19 | protected rows at spec line numbers, edit forms (a) and (b) | #687 moved rows and renamed the end-to-end row (audited by [P0-T6]). This plan edits: form (a) at `enforce-pr-author-skill.epic-base-branch.Tests.ps1:34` and `:40`, which are the two calls inside AC-19's protected span `:22-42`, plus `:48`, `:58`, `:68`, `:78`, `:84`, which are outside it, and `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:38`, `:52`; form (c), one Describe-level `BeforeEach` in `enforce-model-routing-receipt.Tests.ps1` mocking `Resolve-ModelRoutingWorktreeTarget` to `SessionRoot` at `(Get-Location).Path`, the form #687 used on `main`; no edit to `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (its end-to-end row resolves NoTarget before the pin at `:97` is read). |
| RS-9 | AC-21, AC-22 | F1 merged into an epic integration branch | F1 (#669) is on `main`. AC-21: both F1 module paths appear once in `core.json` `paths[]` (`:169-170`), `WorktreeResolution.Manifest.Tests.ps1` passes, and the commit adding `WorktreeTargetResolution.psm1` is an ancestor of `origin/main`. AC-22: the binding table is refreshed to current lines and gains the no-target rows and the identity-derivation row. |
| RS-10 | AC-23 | search the whole repository | Evaluated over files added or modified outside the feature folder, for both literals. Two #687 files carrying the literals are edited and cleaned: the doc comment at `helpers:74` and `:78`, and `enforce-pr-author-skill.TargetResolution.Tests.ps1`. Skill edits and every file Phase 9 touches must not carry either literal; the prd suites already obtain the code from the accessor. |
| RS-11 | AC-24 | F5 defines no target derivation; every use calls F1 | The identity derivation is a new resolution mode placed in the worktree-resolution library beside F1, re-using F1's enumeration, marker test, ascent, branch reader, join, constructor, and accessors. No hook file defines any derivation, normalisation, or reason code. |
| RS-12 | AC-25 | each hook imports F1's module | Each entry hook imports the library module it calls (`WorktreeItemResolution.psm1`) unconditionally at script scope, in the form its own file already uses: the pr-author helpers and the model-routing gate use `-Force -ErrorAction Stop`, and the prd-feature gate keeps the bare `-Force` form of `.claude/hooks/enforce-prd-feature-before-planner.ps1:108`, whose unguarded import is already documented as the fail-closed choice at `:104-107`. Both forms are unguarded, which is what AC-25 requires; neither is wrapped in `try` or softened with `SilentlyContinue`. That module imports F1's two modules with `-ErrorAction Stop`. `enforce-pr-author-skill.epic-base-branch.ps1` calls no library function (it receives the path) and gains no import. `enforce-prd-feature-before-planner.ps1` keeps its `WorktreeTargetResolution.psm1` import at `:108` and gains a second import of `WorktreeItemResolution.psm1`, because `Join-WorktreeResolutionPath` is exported only by the former (DD-4's scope note); `enforce-prd-feature-before-planner-helpers.ps1` keeps its `WorktreeResolution.psm1` import, which supplies both the normalisation `ConvertTo-PrdFeatureFolderToken` calls and, through the dot-source, the two reason-code accessors the parent calls. |
| RS-13 | AC-28 | diff against the epic integration branch | Diff against `F5_BASE_SHA`. |
| RS-14 | AC-30 | no file exceeds 500 lines | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` is 509 lines on `main`; [P6-T2] moves its value-contract block into a sibling file. The prd files are 456, 320, 499, 454, and 446 lines before Phase 9; DD-9's deletions give the gate file headroom, and the new identity rows go into a new suite rather than into the 499-line file. |
| RS-15 | AC-31 | four hooks | Coverage floor also applies to `WorktreeItemResolution.psm1` and to the two prd gate files. |
| RS-16 | AC-32, spec test construction | out-of-process fixture spawns | Fixture rows run in process with both `Set-Location` and `[Environment]::CurrentDirectory` set and restored in `finally` (spec trap 1 permits this), so their lines are coverage-instrumented. The prd suites are exempt from this mechanism entirely: they change no directory and touch no file (RS-19). |
| RS-17 | AC-1, AC-2 | verbatim decision JSON | [P1-T5] replaces host tokens in the archived runs with placeholders under the binding host-data rule; permission decisions and reason codes are unchanged, and a redaction log records per-file counts. |
| RS-18 | AC-33 | seven-stage loop for PowerShell | A Python test file changes ([P8-T5]), so format, lint, and type stages also run for it. |
| RS-19 | issue #672 spec, "The new suite creates no temporary file or directory..." | asserted of `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` as delivered | Re-asserted over that suite as Phase 9 leaves it and over the new `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1`. Both keep bare-literal synthetic roots, supply the modelled directory as data on an injected result, create nothing, and change no directory. [P10-T7] is the checking task and [P11-T9] records the closure. |
| RS-20 | issue #672 spec, multi-candidate disambiguator | "re-specified against the new disambiguator, not deleted" | Re-specified a second time, against DD-7's resolved-worktree checkpoint. The row is edited, never deleted, and it still proves selection is not earliest-occurrence. |

## Acceptance Criteria

Each criterion is checkable by a third party without re-deriving the reasoning in this document.
Where a criterion names a Pester test, the check is that the named test exists and passes; a
line-oriented search for a prose phrase is not an acceptable substitute.

### Reproduction before fix

- [x] AC-1 An evidence artifact under
      `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/`
      records four executed runs — defect 3.2 and defect 3.4, each as a control pair (identical
      payload, cwd = session root and cwd = item worktree) — and for each run it records the verbatim
      decision JSON, the exit code, stdout, and stderr.
- [x] AC-2 For each defect, the archived control pair shows the session-root run returning
      `permissionDecision: allow` and the item-worktree run returning a deny, establishing by
      observation that the verdict is a function of cwd and not of the payload. (If either predicted
      `allow` was not observed, execution halts, no hook file is edited, and this criterion stays
      unchecked with the observed result recorded in the baseline artifact.)
- [x] AC-3 The baseline artifact is committed before the first commit that modifies any file under
      `.claude/hooks/`, verifiable from `git log` ordering on the feature branch.

### The three binding sites

Note for AC-4: the required form of the line-49 change is an initialisation to `$null` at script
scope, not deletion of the line. See **Required form of the line-49 change** under
`#### Functions/classes/CLI commands impacted`. A `$null` initialisation is not a residual
cwd-relative binding.

- [x] AC-4 `.claude/hooks/enforce-pr-author-skill.ps1` no longer assigns a relative checkpoint path
      at line 49 or anywhere else; `$script:OrchestratorStateCheckpointPath` holds an absolute path
      produced by the resolution step, or the hook has already emitted the ambiguity deny.
- [x] AC-5 `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` no longer carries a relative
      default for `-CheckpointPath`; the parameter is mandatory, and the call site at line 78 passes
      the resolved path explicitly.
- [x] AC-6 `.claude/hooks/enforce-model-routing-receipt.ps1` no longer carries a relative default for
      `-CheckpointPath`; the parameter is mandatory, and the call site at line 157 passes the
      resolved path explicitly.
- [x] AC-7 A content search for the token `artifacts/orchestration/orchestrator-state.json` across
      the four in-scope hook files returns zero occurrences in executable code. Occurrences inside
      comment or doc-comment blocks are permitted and must be individually confirmed as such.
- [x] AC-8 No code path in the four in-scope hook files falls back to the process working directory
      when the resolution step reports that the target cannot be identified. Verified by reading each
      branch of the resolution step and confirmed by the Pester rows in AC-13.

### The sibling-only deny (the defining behaviour of this feature)

- [x] AC-9 A named Pester test in
      `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` exercises
      matrix row R2 for the pr-author family against committed fixture roots — sibling checkpoint
      present at the session root, gated item's own checkpoint absent — and asserts a deny carrying
      the ambiguity reason code. The test does not mock the checkpoint reader.
- [x] AC-10 A named Pester test in
      `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`
      exercises matrix row R2 for the model-routing family under the same conditions and asserts a
      deny carrying the ambiguity reason code. The test does not mock `Get-ModelRoutingCheckpoint`.
- [x] AC-11 A named Pester test per hook family covers matrix row R4 (own and sibling checkpoints
      both present) and asserts the decision is derived from the **own** checkpoint. Both tests pass.
- [x] AC-12 A failing-before record for AC-9 and AC-10 exists under `evidence/regression-testing/`:
      each test is observed failing against the unmodified hooks and passing against the fixed hooks.

### Genuine absence stays distinguishable from ambiguity

- [x] AC-13 Named Pester tests cover matrix rows R5, R8, and R9 (no resolvable target; target outside
      any worktree; a command naming two different worktrees) for both hook families and assert a
      deny carrying the ambiguity reason code. R9 asserts the ambiguity deny specifically, not a
      first-match resolution.
- [x] AC-14 Named Pester tests cover matrix rows R3 and R7 and assert the **existing** reason strings
      `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (pr-author) and `MODEL_ROUTING_RECEIPT_BLOCKED`
      (model-routing), not the ambiguity reason code, for a checkpoint that is present-but-not-ready,
      absent at the resolved target, or present but empty or unparseable.
- [x] AC-15 A named Pester test asserts that the ambiguity reason code does not appear in the
      decision output of any genuine-absence case, and that the existing reason strings do not appear
      in the decision output of any ambiguity case.

### Ordering

- [x] AC-16 A named Pester test covers matrix row R10 and asserts that a command which is not a gated
      `gh pr` invocation, and a delegation whose `subagent_type` is outside the gated set, are both
      **allowed** even when the target is unresolvable — proving the ambiguity deny sits after the
      scope filter.
- [x] AC-17 A named Pester test asserts that an unresolvable target denies with the ambiguity reason
      code without the orchestrator-state preflight (pr-author) or the checkpoint read
      (model-routing) being reached — proving the ambiguity deny sits before them.

### Standalone and epic topologies unchanged

- [x] AC-18 A named Pester test covers matrix rows R1 and R6 (cwd = item worktree, own checkpoint
      present and satisfactory) and asserts `allow`. It is observed passing against the
      **unmodified** hooks before the fix, and that pre-fix run is archived under
      `evidence/baseline/`.
- [x] AC-19 The seven pre-existing regression rows listed under `## Test Strategy` remain present and
      pass unmodified: `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:26-37`,
      `:39-51`, `:64-102`; `enforce-model-routing-receipt.Tests.ps1:62-68`, `:71-92`, `:20-58`;
      `enforce-pr-author-skill.epic-base-branch.Tests.ps1:22-42`. Any edit to these files is limited
      to exactly two permitted forms: (a) supplying `-CheckpointPath` where the parameter became
      mandatory, and (b) supplying the same checkpoint path through the new resolution seam in place
      of a script-variable pin — that is, replacing a pin of
      `$script:OrchestratorStateCheckpointPath` with a pin of the resolution seam that yields the
      same path the pin previously supplied. Form (b) exists because the pin at
      `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:84` pins a deliberately-absent
      relative path inside the spawned process, and that pin is itself the cwd-relative binding this
      feature removes from the decision path; no design both removes the binding and leaves that pin
      effective. Neither form is a licence to rewrite these tests: each row's assertions must remain
      byte-identical, no assertion may be added, weakened, reordered, or removed, and no row may be
      renamed. For every row edited under form (b), the evidence artifact under
      `evidence/regression-testing/` quotes both the pre-edit pin and the post-edit pin verbatim, so
      a reviewer can confirm the substitution supplies the same absent path and is therefore
      equivalent.
- [x] AC-20 All six decision branches of `enforce-model-routing-receipt.ps1` enumerated under
      `### Boundaries and invariants to preserve` retain their current semantics: the hook still
      performs presence-only gating and reads no `model` field. Verified by the existing
      `enforce-model-routing-receipt.Tests.ps1` suite passing with no assertion weakened or removed.

### F1 contract binding

- [x] AC-21 F1 is merged into `epic/worktree-scoped-state-resolution-integration`, its module path
      appears exactly once in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]`,
      and its `*.Manifest.Tests.ps1` exists and passes. Confirmed before F5's first hook edit.
- [x] AC-22 The BINDING TABLE in this spec has every row filled with a concrete identifier and the
      F1 `file:line` it was read from, and the filled table is archived under `evidence/other/`.
      No row remains `_unbound_`.
- [x] AC-23 F5 obtains the ambiguity reason code only by calling F1's exported accessor. A content
      search across the whole repository for the literal value recorded in the binding table returns
      occurrences only inside F1's module and inside F1's own tests; it returns **zero** occurrences
      in any file added or modified by F5.
- [x] AC-24 F5 defines no target-derivation, path-normalisation, or ambiguity-reason-code
      implementation of its own. Verified by reading the F5 change set: every use of the three roles
      is a call into F1's module.
- [x] AC-25 Each modified hook imports F1's module unconditionally at script scope using the
      `Join-Path $PSScriptRoot` idiom, with no `-ErrorAction SilentlyContinue` tolerance on the
      import or on any call in the decision path.

### Constraints and non-regression

- [x] AC-26 The mirroring gate
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes, so every file modified under `.claude/**` has a content-identical counterpart under
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- [x] AC-27 No enforcement hook in the change set invokes Python. A content search across the four
      in-scope hook files for `python`, `poetry`, `py -3`, and `Start-Process` returns zero
      executable-code occurrences, and issue #475's structural guard test is located, named in the
      change record, and confirmed to cover these four files. That guard is
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, with its
      detection logic in the sibling `EnforcementHooksNoPythonInvocation.Helpers.ps1`. Its
      two scan roots are `.claude/hooks` and `.claude/lib`, enumerated recursively, so all four
      in-scope files are already covered. Confirming that coverage satisfies this criterion; no
      extension is expected. If an additional assertion is ever required, it must be placed in a new
      sibling test file, because the guard file is measured at exactly 500 lines and has no headroom.
- [x] AC-28 `git diff --name-only` for the feature branch against the epic integration branch lists
      none of: `.claude/hooks/hook-command-scanner.ps1`,
      `.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`,
      `.claude/lib/orchestrator-state/OrchestratorState.psm1`,
      `.codex/hooks/enforce-codex-model-routing.ps1`.
- [x] AC-29 `.claude/lib/orchestrator-state/OrchestratorState.psm1` is still 499 lines and the
      parameter default at line 427 is still unreached from both hook families; a named Pester test
      asserts that every production call into `Invoke-OrchestratorStatePreflight` supplies
      `-CheckpointPath` explicitly.
- [x] AC-30 No file added or modified by F5 exceeds 500 lines, including the new test files and the
      bundled mirror copies.
- [x] AC-31 Line coverage for the four in-scope hook files is >= 85%, measured through
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, with the coverage report archived
      under `evidence/qa-gates/`. No branch-coverage gate applies, because Pester measures no branch
      coverage.
- [x] AC-32 No test added by F5 creates a temporary file or directory; all fixture content is
      committed under `tests/fixtures/`, and every cwd or environment mutation is restored in a
      `finally` block so the suite is order-independent.
- [x] AC-33 The full seven-stage toolchain loop completes with all stages passing in a single pass
      (formatting, linting, type checking where applicable, architecture-boundary tests, unit tests,
      contract/schema checks, integration tests), with the run archived under `evidence/qa-gates/`.

### Identity resolution, checkpoint hygiene, prd-feature migration, and host data (Revision 0.5)

- [x] AC-34 `.claude/skills/orchestrate/SKILL.md` (`## Checkpoint Handling`), `.claude/skills/parallel-orchestrate/SKILL.md` (`## Per-Item Branch and Worktree Lifecycle`), and `.claude/skills/epic-orchestrate/SKILL.md` (`## Epic-Level Checkpoint`) each state the checkpoint-hygiene rule: a per-feature `artifacts/orchestration/orchestrator-state.json` that does not belong to the session's own item is moved to `artifacts/orchestration/handoff/orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json`, and a coordinating session writes no per-feature checkpoint at its own root. Verified by the three hygiene tests in `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`.
- [x] AC-35 `## Issue Number Consistency` in `.claude/skills/orchestrate/SKILL.md` requires the canonical issue number line and a `branch:` label on every delegation to each receipt-gated subagent type returned by `Get-ModelRoutingGatedAgent`, and names both gates that identify the item from the delegation prompt. Verified by the four delegation-identity tests in the same file.
- [x] AC-36 The three bindings select the target worktree by portable identity only, through `Resolve-WorktreeItemTarget` in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`: the canonical issue number, matched against the `issue-num` of each live worktree's checkpoint, and a branch signal (`--head`, `--branch`, `branch:`). A worktree is live when it is registered in the repository's worktree administrative layout and its root still carries a worktree marker. A feature-folder path or file path never selects the worktree. No identity, or an identity matching no live worktree, denies with the no-target code; several live matches or disagreeing identities deny with the ambiguity code; a branch signal breaks a tie among live worktrees recording the same issue. Verified by the named tests in `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1`.
- [x] AC-37 The prd-feature gate (issue #672) selects the worktree by the same portable identity and uses the feature folder only to locate prerequisite documents. `.claude/hooks/enforce-prd-feature-before-planner.ps1` calls `Resolve-WorktreeItemTarget` through its own one-line seam, contains no occurrence of `Resolve-WorktreeCallTarget`, and declares no `Envelope` parameter and reads no `cwd` field from the hook envelope. No feature-folder path and no file path selects the worktree: the resolver receives the assembled prompt and description text unchanged and reads no path signal from it, deciding only on the canonical issue number and a branch signal. After identity resolves, the gate resolves the feature folder beneath the resolved worktree and probes its prerequisites there; when the prompt names no folder it reads the `feature-folder` field from the checkpoint of the resolved worktree, never from the calling session's root; when the prompt names more than one folder that checkpoint is the disambiguator. The work-mode contract is unchanged: `full-feature` requires `spec.md` and `user-story.md`, `full-bug` requires `spec.md`, `minor-audit` requires neither, and an absent or unrecognised marker denies on its own path naming no prerequisite set. A prerequisite document that is genuinely absent still denies with the gate's existing missing-document reason, which carries neither target-resolution code. A coordinating-session `atomic-planner` delegation for an item whose feature folder also exists in other worktrees resolves by identity and is allowed, where it previously denied with the ambiguity code. Expected in the diff for this criterion: `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, their two counterparts under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1`, and `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`. `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` remain absent from the diff.
- [x] AC-38 No file added or modified by this change, other than `plan.2026-09-13T20-48.md`, `plan.2026-09-18T13-30.md`, and `plan.2026-09-18T16-00.md`, contains a drive-letter path, a user-profile path, or the executing user's account name. Feature-folder artifacts that carried such tokens are redacted to placeholders, with per-file counts logged under `evidence/other/`.
- [x] AC-39 The two acceptance criteria left unchecked in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` — the test-hygiene criterion for the target-resolution suite and the PowerShell-toolchain single-pass criterion — are checked in that file, and a closure subsection in the same file cites the evidence artifact satisfying each.

## Risks & Mitigations

- Technical or operational risks:
  - **The defect is not reproduced and the fix is written against a static trace.** Mitigation: AC-1
    to AC-3 make reproduction a precondition with a halt rule; no hook is edited until the predicted
    `allow` is observed and archived.
  - **The reproduction environment may refuse to launch `pwsh`.** Observed twice already. Mitigation:
    two routes are named — direct `pwsh`, or a Pester-expressed reproduction run out of process via
    `mcp__drm-copilot__run_poshqc_test`.
  - **F1's identifiers may change between binding and merge.** Mitigation: the binding table is
    filled from F1 **as merged** into the integration branch (AC-21, AC-22), and AC-23 asserts the
    reason-code literal exists in exactly one place.
  - **A mocked sibling-case test that passes without testing anything.** This is the most likely
    silent failure of this feature. Mitigation: AC-9 and AC-10 forbid mocking the reader in those
    rows; AC-12 requires an observed fail-before.
  - **Converting a fail-open check into a fail-closed one.** Making
    `Get-PrAuthorCheckpointContent -CheckpointPath` mandatory changes check 6's behaviour in the
    ambiguous case. Mitigation: the hook denies upstream before check 6 in that case, and AC-19
    keeps the `epic_mode` false/absent no-op guards passing unmodified.
  - **The committed session-root fixture is schema-coupled and carries a standing maintenance
    obligation.** For the pr-author rows the fixture checkpoint must satisfy all 22
    `REQUIRED_STATE_KEYS` plus the U-family unconditional block implemented in
    `OrchestratorStateUnconditional.psm1`; otherwise the fixture fails validation for a reason
    unrelated to the behaviour under test, and the row stops testing resolution. The coupling is not
    static: feature F3 of this same epic adds a checkpoint schema field (`epic.md:258`), and any
    later schema addition has the same effect. Mitigation: record the fixture's schema dependency in
    a comment at the head of the fixture-consuming test file, naming `REQUIRED_STATE_KEYS` and
    `OrchestratorStateUnconditional.psm1` as the two sources it must satisfy; treat a fixture-row
    failure after a schema change as a fixture-maintenance task rather than a resolution defect; and
    on F3's merge into the epic integration branch, re-run the fixture rows and update the fixture
    checkpoint in the same change if the new field is required. No acceptance criterion is attached;
    this is an ongoing obligation on the epic, not a one-time deliverable of F5.
  - **A repo-side-only edit is inert at the push-down surface.** Mitigation: AC-26 binds the change
    to the existing machine-enforced mirroring gate.
  - **Scope creep into F3's `enforce-epic-merge-gate.ps1:48` or into the shared command parsers.**
    Mitigation: AC-28 asserts the change set excludes them.
  - **A false-denial storm if F1 cannot derive a target from a typical payload.** This is the largest
    residual risk and it is not closed by research. For `enforce-model-routing-receipt.ps1` the only
    target-bearing field identified in the payload is `prompt`; whether the envelope carries a `cwd`
    key is unverified, and no evidence establishes that every delegation to the six gated subagent
    types names its feature folder in the prompt. If derivation fails for ordinary payloads, every
    gated delegation becomes an ambiguity deny and runs stall visibly. Mitigation: before the hook
    edits, sample real payloads for each gated subagent type against F1's derivation function and
    record the result under `evidence/other/`; if derivation fails for an ordinary payload, raise it
    against F1 rather than adding a cwd fallback in F5. A visible stall is the intended failure
    direction, but it must be caused by genuine ambiguity and not by a derivation gap.
- Mitigations and rollbacks: rollback is a revert of the change set including the bundled mirror
  copies. No feature flag is introduced; a flag on a fail-closed gate would preserve a configuration
  in which the defect is still live.

## Rollout & Follow-up
- Release/rollout steps: F5 merges into `epic/worktree-scoped-state-resolution-integration` after
  F1. Delivery to consumer repositories (extension rebuild, reinstall, push-down, resume
  confirmation) belongs to **F7** and is not part of F5.
- Post-fix monitoring or clean-up tasks:
  - Confirm that no gate returns allow on the basis of a sibling item's checkpoint in the next
    parallel run (epic leading indicator).
  - Follow-up, deliberately excluded here: `.claude/skills/orchestrate/SKILL.md:190` still describes
    the `$Invoker` seam as a "subprocess seam", which has been stale since issue #475 removed the
    subprocess.
  - Follow-up owned by F3: `.claude/hooks/enforce-epic-merge-gate.ps1:48` carries the same
    cwd-relative binding.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/673
  - Epic manifest: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F5 row)
  - Research: `research/2026-09-13T22-10-false-approval-elimination-research.md`
  - Presence-only gating contract: `.claude/rules/orchestrator-state.md:107`
  - Python-free enforcement precedent: issue #475,
    `docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/`
