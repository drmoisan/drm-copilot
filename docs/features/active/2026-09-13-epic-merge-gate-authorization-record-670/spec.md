# epic-merge-gate-authorization-record (Spec)

- **Issue:** #670
- **Parent (optional):** epic `worktree-scoped-state-resolution`, F3, wave 0, complexity C3, epic ref 3.6
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T22-05
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** `full-bug` — this file is the sole acceptance-criteria source. No `user-story.md` exists for this feature.
- **Primary research record:** `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/research/2026-09-13T21-10-epic-merge-gate-authorization-record-research.md`

## Context

`.claude/hooks/enforce-epic-merge-gate.ps1` is a project-wide `PreToolUse` hook registered under the
`Bash` matcher. When a Bash command structurally invokes `gh pr merge` **and** carries a `--merge`
flag, the gate allows the command only when one of three checkpoint-only conditions holds. The three
conditions are documented in the file's own header at lines 8-21 and implemented as three sequential
predicates in `Invoke-EpicMergeGateDecision` at lines 418-431:

1. **Child-feature path** (`Test-ChildCheckpointAllowsEpicMerge`, line 177) — the per-feature
   checkpoint `artifacts/orchestration/orchestrator-state.json` exists with `epic_mode == true` and
   `step9_status == "passed"`.
2. **Epic-integration path** (`Test-EpicCheckpointAllowsMerge`, line 206) — the epic checkpoint
   `artifacts/orchestration/epic-orchestrator-state.json` exists with
   `epic_merge_pr.ci_gate.conclusion == "success"` and, when the command names an explicit PR number,
   that number matches `epic_merge_pr.pr_number`.
3. **Parallel path** (`Test-ParallelCheckpointAllowsMerge`, line 264) — the parallel checkpoint
   `artifacts/orchestration/parallel-orchestrator-state.json` exists with `route_id == "parallel"`
   and the command's explicit PR number matches an `items[]` entry whose
   `merge_status == "ci_green"`.

### Root cause

A **standalone** pull request — one opened to land a fix that is not itself a tracked epic child or a
tracked parallel item — matches none of the three. It is not a child-feature merge, so no per-feature
checkpoint records `epic_mode`. It is not the epic integration PR, so `epic_merge_pr` names a
different number or is absent. It is not a parallel item, so no `items[]` entry carries its
`pr_number`. Control therefore falls through to line 433 and the command is denied with
`EPIC_MERGE_GATE_BLOCKED`.

The exclusion is deliberate and is stated in the header at lines 23-27: standalone orchestration
"never sets `epic_mode`, populates `epic_merge_pr`, or writes a parallel checkpoint with
`route_id == "parallel"`, so it is structurally prevented from invoking `gh pr merge --merge` at
all." That reasoning holds for a standalone *run*. It does not hold for a standalone *pull request
produced inside an epic or parallel run*, which is the case this defect covers.

### Observed consequence

TaskMaster parallel run `bugs-2026-09-11` stalled. An agent inside the run discovered a defect whose
fix had to land as a standalone pull request rather than as a tracked parallel item. The PR reached
CLEAN mergeable state with all required checks passing, and no agent in the run could merge it. The
orchestration was structurally unable to land the fix that would have unblocked it. Severity:
**Blocker** — total standstill of a 13-item run.

## Repro & Evidence

Steps to Reproduce:

1. Run a parallel orchestration (for example TaskMaster run `bugs-2026-09-11`) and let an agent
   discover a defect whose fix must land as a standalone pull request rather than as a tracked
   parallel item.
2. Open that standalone fix PR, drive it to CLEAN mergeable state with all required checks passing.
3. Invoke `gh pr merge` with an explicit PR number and the `--merge` flag from the orchestrating
   session.

Expected:
A standalone merge that the orchestration has explicitly and auditably authorized is permitted, so
the run can land its own unblocking fix.

Actual:
The gate denies with `EPIC_MERGE_GATE_BLOCKED` (the line-433 reason text). Observed consequence: run
`bugs-2026-09-11` stalled with a green, CLEAN, all-checks-passing PR that no agent could merge.

Environment:

- OS/version: Windows 11 Pro 10.0.26200. The hook is PowerShell 7+ and platform-neutral.
- Python version: not applicable. The hook is PowerShell and must remain PowerShell or bash.
- Command/flags used: `gh pr merge` with an explicit PR number and `--merge`.
- Data source or fixture: `artifacts/orchestration/*orchestrator-state.json` checkpoints.

Impact / Severity:

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Logs / Screenshots:

- [x] Attached minimal logs or screenshot
- Snippet: deny reason code `EPIC_MERGE_GATE_BLOCKED` emitted by the PreToolUse hook.

## Settled Rulings and Closed Anti-Patterns

### RULING 1 (settled by the user; not to be re-litigated)

Relax the epic-merge gate with an **authorization record**. A standalone `gh pr merge --merge` is
permitted only when an explicit, auditable authorization record naming **that specific pull request**
is present in orchestrator state. The `pr_number` matcher must **not** be widened — that is a
must-not-regress constraint carried from the epic. A blanket "standalone merges allowed" flag is not
an authorization record, and the design must **actively reject** it with a distinct deny code rather
than merely failing to match it.

### Closed anti-patterns (recorded so they are not re-proposed downstream)

1. **Injecting a synthetic `items[]` record** to satisfy the `pr_number` matcher. **Closed.**
   Satisfying a matcher by corrupting the state it inspects is not compliance. Invariant 13 would then
   demand a false cohort assignment, so the corruption propagates rather than staying local. Any
   implementation that writes an `items[]` entry for a pull request that is not a tracked parallel
   item is a defect, not a fix.
2. **Switching to `--squash`** to evade the matcher. **Closed.** Evading a gate is not satisfying it.
   See the corrected framing below for what `--squash` actually does today.

### Corrected framing: `--squash` is currently ALLOWED, not denied

The delegation prompt that originated this feature asserted that "`--squash` in any configuration
implies deny (unchanged)". **That assertion is factually wrong against this tree and is corrected
here so no downstream reviewer reintroduces it.**

Both hooks scope to a *structural* `gh pr merge` invocation that **also** carries `--merge`
(Claude lines 401-414; Codex lines 133-146). A command carrying `--squash` and not `--merge` fails
the `--merge` leg and returns an allow at Claude line 413 / Codex line 145 **before any allow-or-deny
branch is reached**. `--squash` is therefore out of the gate's trigger scope entirely and is allowed
today. This is pinned by a currently-passing test:
`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:27`,
`It 'allows gh pr merge without --merge (e.g., --squash)'`.

**Ruling: preserve current behaviour exactly.** This feature asserts that `--squash` remains out of
trigger scope and that the authorization record creates no new path to it. This spec deliberately
contains **no** acceptance criterion asserting that `--squash` denies; such a criterion would be
unsatisfiable against the real tree and would require widening the gate's trigger surface, which is
outside RULING 1's remit. The line-27 test must stay green and must not be edited. A new paired case
is added instead (see Test Strategy, row 11).

## Scope & Non-Goals

### In scope — change surface

Re-verified against this tree at branch `epic/worktree-scoped-state-resolution-integration`, HEAD
`499e288a`. This is research R4.4's checklist, confirmed item by item:

| # | Path | Change | Verified |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-merge-gate.ps1` | Add branch 4 call block; add dot-source of (2); rewrite the "one of three" header block to four; move the two decision-envelope factories out. | 487 lines counted in this tree (every-line match count). Factories at lines 327-338 and 340-355. |
| 2 | `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | **New.** Authorization predicate, record selection, field-shape validation, the four reason-code constants, and the two moved decision-envelope factories. | Filename is unused in this tree. |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` and the mirror of (2) | Mirror both. | Mirror of (1) exists; mirror of (2) is new. |
| 4 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Add (2)'s repo-relative path. | Confirmed: `.claude/hooks/enforce-epic-merge-gate.ps1` is listed at line 29 and `.claude/hooks/enforce-pr-author-skill-helpers.ps1` at line 46, so helpers files are precedent-registered individually. |
| 5 | `.codex/hooks/enforce-epic-merge-gate.ps1` | Add the standalone branch **in place**. No extraction. | 186 lines counted. Confirmed no `route_id`, `items`, or `parallel` token occurs anywhere in the file. |
| 6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | Mirror of (5). | Byte-identity is asserted by a hardcoded allow-list test. |
| 7 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | Add (2) to `CodeCoverage.Path`. | Confirmed: `.claude/hooks/enforce-epic-merge-gate.ps1` at line 44, `.claude/hooks/enforce-pr-author-skill-helpers.ps1` at line 239, `.codex/hooks/enforce-epic-merge-gate.ps1` at line 280 — an explicit per-file allow-list. |
| 8 | `.claude/rules/orchestrator-state.md` | New key-gated scope-and-invariants section plus one Enforcement bullet. | Confirmed the additive key-gated convention is stated four times (lines 37, 49, 61, 79) and restated at line 95; Enforcement bullets at lines 127-132; Foreign Schema Warning at lines 29-33. |
| 9 | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | Mirror of (8). | The path is listed in `core.json` at line 66. |
| 10 | `.claude/skills/parallel-orchestrate/SKILL.md` and its bundled mirror | Writer procedure for the record, appended to the existing `**Merge-gate authorization.**` paragraph. | Confirmed that paragraph exists at lines 327-334 and already documents the three-branch gate contract. |
| 11 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (new) and `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` (new) | The matrix in Test Strategy. | The existing Claude suite is 455 lines against the 500 cap and cannot absorb the matrix. |

### Non-Goals

- **Widening the `pr_number` matcher.** Forbidden by RULING 1 and by the epic's Must Not Regress list.
  `Get-EpicMergeGateCommandPrNumber` (lines 131-175) is not modified.
- **Denying `--squash`.** Out of scope per the corrected framing above. Denying `--squash` would widen
  the gate's trigger surface and change behaviour in every topology; it is a distinct feature with its
  own blast radius.
- **Claude-side cwd-anchored checkpoint path resolution (research R1.7, open question OQ4).**
  The three Claude checkpoint paths (lines 48-50) are bare repo-relative strings resolved against the
  hook process's current working directory, while the Codex mirror anchors to a `$PSScriptRoot`-derived
  repository root (Codex lines 173-175). This asymmetry is squarely the epic's own defect class and is
  addressed by F1 and its consumers, not here. Changing it would violate the must-not-regress
  constraint that epic and standalone topologies behave exactly as now when cwd and target coincide.
  Recorded as follow-up **FU-2**.
- **Adding a parallel path to the Codex hook.** The Codex hook has two allow paths and no parallel
  path. Adding one is a behavioural change with no ruling behind it.
- **Porting any hook to Python.** Enforcement hooks are PowerShell or bash only. A Python leg creates
  a second implementation of the rule that drifts from the first, and
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` asserts an empty
  allowlist over `.claude/hooks/**`.
- **A Python checkpoint validator for the new block, and any TypeScript parity port of it.** The hook
  validates the record itself and must be complete and fail-closed on its own, because in the
  production path no validator may have run on that checkpoint. A structural validator is
  defence-in-depth, not the gate. Recorded as follow-up **FU-3**.
- **Attesting `authorized_by` (open question OQ2).** `authorized_by` is a **declaration, not an
  attestation**. The runtime exposes no attested agent identity at Bash `PreToolUse` time that this
  design relies on. The hook must not claim it verifies identity, and the disclosure must say so.
  A bounded spike on whether `agent_type` is present on a Bash-matcher envelope is follow-up **FU-4**.
- **Editing `.claude/settings.json`.** A helpers file needs no hook registration: neither
  `enforce-orchestration-preimplementation-gate-helpers.ps1`, nor `-modes.ps1`, nor
  `enforce-pr-author-skill-helpers.ps1` appears in `.claude/settings.json`.
- **Changing any of the three existing branch predicates.** They are unit-tested by name and moving or
  editing them would churn test files for no behavioural reason.

### Explicitly excluded systems, integrations, and datasets

- Live `gh` calls of any kind from any hook. No hook in `.claude/hooks/` makes one today.
- Any network access, subprocess launch, or filesystem write from the decision path.
- Any JSON Schema file for the new checkpoint block.

## Root Cause Analysis

- Allow paths documented at `.claude/hooks/enforce-epic-merge-gate.ps1:8-21`; the deliberate
  standalone exclusion at lines 23-27.
- Decision router `Invoke-EpicMergeGateDecision` at line 357; scope filter at lines 401-414; the three
  branch calls at lines 418-431; the fall-through deny at line 433.
- Branch predicates: `Test-ChildCheckpointAllowsEpicMerge` (line 177),
  `Test-EpicCheckpointAllowsMerge` (line 206), `Test-ParallelCheckpointAllowsMerge` (line 264).
  `$script:ParallelCheckpointPath` at line 50.
- The file is 487 lines against the repository's 500-line cap, so a fourth allow path plus its helper
  cannot be added in place. A helpers extraction is required. (The epic manifest and `issue.md` state
  486; the difference is a measurement-tool artefact — a newline count versus a
  `(Get-Content).Count` line count — not a disagreement about content.)
- Bundled payload mirror at
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
  must receive the same change, or the push-down publishes stale content.
- `.codex/hooks/enforce-epic-merge-gate.ps1` is a separate, smaller implementation of the same
  decision surface and carries a parity obligation.

## Proposed Fix

### Design summary

Add a **fourth allow path (branch 4)** to the gate, evaluated **last**, after branches 1, 2 and 3 have
each declined. Branch 4 reads a new, key-gated, top-level `standalone_merge_authorizations` array from
whichever of the **three checkpoints the gate already reads** carries the key, and allows the merge
only when that array contains a well-formed record whose `pr_number` equals the PR number the existing
matcher extracted from the command, and whose `session_id` equals the `session_id` on the live
`PreToolUse` envelope.

### WHAT the record contains — field contract

Shape (illustrative values; the block name deliberately avoids the three key tokens
`depends_on`, `integration_branch`, and `epic_merge_pr` that the parallel-checkpoint validator rejects
at any nesting level):

```json
"standalone_merge_authorizations": [
  {
    "pr_number": 691,
    "pr_url": "https://github.com/drmoisan/drm-copilot/pull/691",
    "issue_num": 670,
    "branch_name": "fix/epic-merge-gate-authorization-record-670",
    "authorized_by": "parallel-orchestrator",
    "authorized_at": "2026-09-13T21:04:00Z",
    "session_id": "0f3c1a2b-4d5e-6f70-8192-a3b4c5d6e7f8",
    "basis": "Standalone fix for #670 unblocks run bugs-2026-09-11; PR is CLEAN with all required checks passed.",
    "run_slug": "bugs-2026-09-11"
  }
]
```

| Field | JSON type | Required | Audit question it answers | Hook obligation (exact validation rule) |
| --- | --- | --- | --- | --- |
| `pr_number` | integer | required | **which PR** | **The binding.** Must be a JSON integer strictly greater than zero and must equal the PR number returned by `Get-EpicMergeGateCommandPrNumber` for the command under evaluation. Absent, `null`, `0`, negative, non-integer numeric, string, array, or object produces `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC`. A string that happens to spell digits is **not** accepted; the type test is on the parsed JSON value, not on its string form. |
| `pr_url` | string | required | which PR (corroboration) | Non-empty after trimming, and must end with the literal `/pull/` followed by the decimal spelling of this entry's own `pr_number` and nothing else. Catches a copy-paste that updated one field and not the other. Failure produces `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming `pr_url`. |
| `issue_num` | integer | required | why the record exists | Must be a JSON integer strictly greater than zero. Presence and type only; the hook does not check that the issue exists. Failure produces `..._MALFORMED` naming `issue_num`. |
| `branch_name` | string | required | which change | Non-empty after trimming. **The hook must not compare it against the live branch or the working directory**; doing so would reintroduce cwd dependence, which is the epic's own defect class. Failure produces `..._MALFORMED` naming `branch_name`. |
| `authorized_by` | string | required | **who** | Non-empty after trimming. **Presence and non-emptiness only.** The hook records a declaration and must not claim it verifies identity. Failure produces `..._MALFORMED` naming `authorized_by`. |
| `authorized_at` | string | required | **when** | Must parse as a date-time using `[DateTime]::TryParse` with `InvariantCulture` and the styles `AdjustToUniversal` combined with `AssumeUniversal` — the same call the pull-request body receipt already uses for its own timestamp check. Unparseable, non-string, or empty produces `..._MALFORMED` naming `authorized_at`. The hook does not compare the value against wall-clock time; no clock is read on the decision path. |
| `session_id` | string | required | **when / which run** | Non-empty after trimming, and must equal, by ordinal string comparison, the `session_id` read from the live `PreToolUse` envelope. This is the only field a forging agent cannot invent without also being inside the authorizing session. If the envelope carries no `session_id`, the comparison cannot be made and the gate **fails closed**. Failure in either direction produces `..._MALFORMED` naming `session_id`. |
| `basis` | string | required | **on what basis** | Non-empty after trimming and **at least 20 characters** after trimming, so a single character does not satisfy "auditable". Failure produces `..._MALFORMED` naming `basis`. |
| `run_slug` | string | optional | traceability | When the key is absent the entry is still valid. When present it must be a non-empty string after trimming; an empty or non-string value produces `..._MALFORMED` naming `run_slug`. |

**Field-check evaluation order.** For the entry selected by `pr_number`, the field checks run in this
fixed, declared order and the **first** failure wins, so the emitted message is deterministic:
`pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis`, `run_slug`,
`session_id`. Determinism of the message matters because the tests assert on it.

### WHERE in orchestrator state it lives

`standalone_merge_authorizations` is a **key-gated top-level array** carried in **all three
checkpoints the gate already reads**:

- `artifacts/orchestration/orchestrator-state.json` (per-feature)
- `artifacts/orchestration/epic-orchestrator-state.json` (epic)
- `artifacts/orchestration/parallel-orchestrator-state.json` (parallel)

Branch 4 consults whichever of the three parsed checkpoint objects carries the key. Consequences, each
of which is a design reason rather than a convenience:

- **No new read seam.** The three read seams (`Get-ChildOrchestratorCheckpointContent` line 52,
  `Get-EpicOrchestratorCheckpointContent` line 70, `Get-ParallelOrchestratorCheckpointContent`
  line 88) already supply the text, and `ConvertFrom-EpicMergeGateJson` (line 106) already parses it.
  No new mock is required in any existing test. This matters: the existing suites state a determinism
  rule that every decision-level case mocks **all** checkpoint read seams, so a fourth seam would make
  every existing case order-dependent until it was amended.
- **No new file.** No pack-manifest entry, no coverage-config entry, and no bundle mirror for a data
  artifact.
- **Key-gated additivity.** A checkpoint that omits the key validates exactly as before and produces
  no new errors, matching the convention `.claude/rules/orchestrator-state.md` already states for
  `remediation_loop`, `human_interaction`, `complexity_assessments`, and `model_routing_receipts`.
- **All three, not only the parallel checkpoint.** Scoping the block to the parallel checkpoint alone
  would leave an epic run with the identical unlandable-fix problem. The observed failure occurred
  under a parallel run, but nothing about the defect is parallel-specific (open question OQ3, ruled).

**Why an array rather than a single object.** One run may legitimately land more than one standalone
fix. An array lets the hook select by `pr_number` and deny when the command's number matches no entry,
which is the same selection shape the parallel branch already uses over `items[]` — without touching
that branch's matcher. A single object would force either one authorization per run or an overwrite
that destroys the audit trail of the previous one.

### WHAT makes it auditable

The record answers the four audit questions explicitly and in writing, at the moment of authorization:

- **Who** — `authorized_by`, a declared authorizer.
- **Which PR** — `pr_number`, corroborated by `pr_url`, and bound to the specific command by equality
  with the number the existing matcher extracted.
- **When / which run** — `authorized_at` plus `session_id`, and optionally `run_slug`.
- **On what basis** — `basis`, a free-text justification of at least 20 characters, plus `issue_num`
  and `branch_name` identifying the change.

A standalone merge therefore leaves a reviewable trail in a checkpoint that is already read, already
mirrored into review artifacts, and already inspected during feature review.

### HOW the gate verifies it without becoming forgeable by the agent it gates

The adopted mechanism is research designs **(i) + (ii)**:

- **(i) Required self-consistent fields.** Every field above is validated for presence, type, and
  internal consistency. The `pr_url`-ends-with-`pr_number` check is the strongest of these: it is the
  direct analogue of the pull-request body receipt's number-versus-path check and it catches the
  realistic failure mode, which is a record copied from another PR with one field updated.
- **(ii) A `session_id` cross-check against the live envelope.** `Resolve-ClaudeHookToolInput`
  already returns the parsed envelope on an `Envelope` member alongside `Value`
  (`.claude/lib/hook-payload/HookPayload.psm1:478-483`), and its docstring at lines 446-452 states
  that the member exists precisely so a hook can read envelope-root fields.
  `Get-ClaudeHookEnvelopeValue` is exported from the same module (line 491) and reads a named field
  from a parsed envelope. Reading `session_id` is therefore a one-line addition with **no new
  plumbing and no new seam**. On the Codex side the parsed payload object is already in scope inside
  `Invoke-CodexEpicMergeDecision` (`.codex/hooks/enforce-epic-merge-gate.ps1:123`), so `session_id` is
  reachable there with no new plumbing either.

#### Designs considered and explicitly rejected

- **(iii) Live `gh pr view` corroboration in the hook. Rejected.** It directly contradicts the gate's
  own documented design decision at `.claude/hooks/enforce-epic-merge-gate.ps1:29-32`, which names
  `gh pr view` and rejects it by name; adopting it would reverse a documented decision without a
  ruling. It would also be the first live `gh` call from any hook, would add network latency to every
  in-scope Bash call, and would fail closed on a network blip — converting a transient outage into a
  merge stall, which is the exact failure class this feature exists to remove.
- **(iv) A SHA-256 sidecar receipt over the record. Rejected.** The pull-request body receipt
  precedent's own honest disclosure (`.claude/agents/pr-author.md:79-88`) states that an actor who can
  write the artifact can write the matching receipt alongside it. A record and its own receipt written
  by the same agent in the same session is strictly weaker than the body-receipt case, because there
  is no third artifact to anchor staleness against. It costs a read seam, a pack-manifest entry, a
  coverage-config entry, and a bundled mirror for no measurable gain.
- **(v) A record stored outside the gated agent's write permissions. Not rejected on merit —
  BLOCKED ON SUBSTRATE.** This is the strongest available design. The Codex runtime implements it
  (`.codex/hooks/codex-authority-store.ps1`, which derives a repository- and session-bound directory
  under an isolated `CODEX_HOME`), but that works only because Codex declares a real permissions
  profile. The Claude runtime has no equivalent authority store, and `.claude/settings.json` sets
  `defaultPermissionMode` to `bypassPermissions`, so no path is outside any agent's write reach and
  one cannot be constructed from `settings.json`. Recorded as follow-up **FU-1**: propose a
  Claude-side permissions posture change as a separate issue. This is a named deferral, not a silent
  drop.

#### Honest disclosure (normative text)

This paragraph is contract. It must appear, in substance, in **three** places: the hook's `.NOTES`
block, the new helpers file's header comment, and the new section of
`.claude/rules/orchestrator-state.md`. It follows the disclosure templates at
`.claude/agents/pr-author.md:79-88` and `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:38-46`
("This is a documented accepted trade, not an unexamined gap.").

> The standalone-merge authorization record is a **policy-level, auditable declaration, not a
> cryptographic or security control.** It names a specific pull request, a specific session, an
> authorizer, a time, and a stated basis, so that a standalone merge leaves a reviewable trail and
> cannot be reached by accident or by a record written for a different pull request. `authorized_by`
> is a declaration only: the hook checks that it is present and non-empty and does **not** verify the
> identity it names, because the runtime exposes no attested agent identity this gate relies on at
> Bash `PreToolUse` time. The record is not tamper-proof: any actor able to write
> `artifacts/orchestration/*.json` inside the authorizing session can write a record, because all
> agents share one filesystem and `defaultPermissionMode` is `bypassPermissions`. The `session_id`
> cross-check binds a record to the session that emitted it, so a stale record from a previous run or
> a record copied between runs does not authorize anything; it does not stop same-session forgery.
> The mechanism converts an untraceable bypass into a deliberate, attributable, auditable act. This
> is a documented accepted trade, not an unexamined gap.

### WHY the blanket flag is rejected — actively, not by omission

RULING 1 requires that a blanket "standalone merges allowed" flag be **actively rejected**. If such a
flag merely failed to match, it would fall through to the "absent" code and the rejection would be
invisible in the transcript: an operator would see "no authorization record" while looking at a
checkpoint that plainly contains one. The design therefore emits a distinct code,
`STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC`, whenever the key is present but names no specific
pull request. That code fires for **every** of the following spellings:

- the block value is not an array at all — `true`, `false`, a number, a string, or an object;
- the block is an array with zero entries;
- an entry is not an object;
- an entry's `pr_number` is absent, `null`, `0`, negative, a non-integer number, a string (including
  a digit-spelling string), a wildcard string such as `"*"` or `"all"`, an array, or an object;
- no entry in the array is PR-specific under the rules above.

### WHY branch 4 cannot widen branches 1-3 — the structural argument

Three independent properties, each individually sufficient:

1. **Ordering.** Branch 4 is a disjunct evaluated **after** branches 1, 2 and 3. A checkpoint that
   satisfies any of those branches returns an allow before branch 4 is reached, so branch 4 cannot
   change any existing allow. Because branch 4 only ever returns allow or a deny that replaces an
   existing deny, it can convert a current **deny** into an **allow** and never the reverse.
2. **Different key.** Branch 4 reads `standalone_merge_authorizations`. Branch 1 reads `epic_mode` and
   `step9_status`; branch 2 reads `epic_merge_pr`; branch 3 reads `route_id` and `items[]`. No key is
   shared, so a record cannot satisfy a condition belonging to another branch.
3. **The matcher is untouched.** Branch 4 consumes the value `Get-EpicMergeGateCommandPrNumber`
   already returns. It does not modify the extractor, does not add a second extraction path, and does
   not accept a PR number from any other source. When the extractor returns no number, branch 4 is not
   entered at all.

This is the same structural argument the worktree-removal gate already makes for its own second
branch (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1:30-33`).

### Boundaries and invariants to preserve

- `Get-EpicMergeGateCommandPrNumber` (lines 131-175) is unchanged, including both occurrences of the
  anchored `'^\d+$'` test at lines 164 and 170 and the call position at line 416.
- The three `$script:*CheckpointPath` assignments (lines 48-50) are unchanged; path resolution
  semantics are not touched on either runtime.
- The scope filter (lines 401-414) is unchanged, including the raw-scan fallback.
- The two existing deny-reason emission sites (line 382 envelope anomaly; line 433 fall-through)
  retain their existing `EPIC_MERGE_GATE_BLOCKED` token.
- The hook never starts a process, never reads a clock, never writes to disk, and never invokes
  Python.
- The three existing branch predicates are not renamed, moved, or edited.

### Dependencies or blocked work

None. F3 is wave 0 and dependency-free. It does not consume F1's resolution contract.

### Implementation strategy — asymmetric by design

**This treatment is asymmetric on purpose and must not be read as a parity gap.**

**Claude side — extract, because the parent is at the cap.** The parent hook is 487 lines against a
500-line cap: 13 lines of headroom, which a fourth branch plus its predicate plus a header rewrite
cannot fit. A new file is created at `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`,
dot-sourced by the parent with `$PSScriptRoot`, following the `enforce-pr-author-skill-helpers.ps1`
idiom: `[CmdletBinding()] param()` plus a self-contained dot-source of any shared parser it needs, so
a test can dot-source the helpers file directly.

Preferred extraction boundary and line budget:

| Content | Est. lines |
| --- | --- |
| Header comment block: split rationale, the honest disclosure, the non-forgeability limits | 35-45 |
| `[CmdletBinding()] param()` plus shared-parser dot-sources | 5 |
| Four reason-code constants, declared **once each**, following the `enforce-parallel-abandon-gate.ps1:38-45` precedent ("the ONLY places either token literal appears in this file") | 12-16 |
| `Get-StandaloneMergeAuthorizationRecord` — select the entry for a given PR number from a parsed checkpoint | 35-45 |
| `Test-StandaloneMergeAuthorizationRecord` — field-shape and PR-binding validation; returns the failing reason code or nothing | 60-90 |
| `Test-StandaloneCheckpointAllowsMerge` — the branch-4 predicate composing the two above | 30-40 |
| **Moved from the parent:** `Get-EpicMergeGateAllowDecision` (currently lines 327-338) and `Get-EpicMergeGateBlockDecision` (currently lines 340-355) | 28 |
| **New file total** | **205-269** |

The two decision-envelope factories are moved because they are pure envelope constructors with no
script-scoped dependencies and **no test calls either of them by name**, so the move is invisible to
every existing suite. Moving them frees 28 lines in the parent.

Parent line budget: 487 currently, minus 28 moved, plus one dot-source line, plus a branch-4 call
block of roughly 5 lines, plus a net header rewrite of roughly 8 lines, lands the parent at
approximately **473** lines — roughly 27 lines of headroom. Every file stays under 500.

**Codex side — add the branch in place, because there is ample headroom.** The Codex hook is 186
lines, leaving over 300 lines of headroom, and adding the branch in place avoids a second Codex
pack-manifest entry, a second `$script:RuntimePaths` byte-identity entry, a second coverage-config
entry, and a second bundled file. The branch is added to `Invoke-CodexEpicMergeDecision` after the
existing epic branch (currently line 154), reading the key from the `ChildCheckpointRaw` and
`EpicCheckpointRaw` values the function already receives as parameters.

**What Codex parity means here.** Behavioural parity on the standalone decision, plus identical
reason-code spelling. Concretely:

- **Must match:** the activation condition (a well-formed record naming this PR, session matching);
  the four reason-code tokens, spelled byte-identically, because a token that differs by runtime is
  not greppable across a mixed transcript; the `pr_number` matcher, unchanged on both sides;
  `--squash` remaining out of scope on both sides.
- **Must NOT be changed as a side effect:** the Codex hook has no parallel path and **must not acquire
  one**. Seam shape stays different (Claude mockable read functions; Codex parameters plus a repo-root
  anchored entry point). Allow representation stays different (`$null` on Codex, an explicit allow
  object on Claude). The `exit 2` throw channel, the wider `step9_status` accepted set, the stricter
  `epic_mode` type test, and the path anchoring all stay as they are.

#### Files/modules to change

See the In-scope table above.

#### Functions/classes/CLI commands impacted

- New: `Get-StandaloneMergeAuthorizationRecord`, `Test-StandaloneMergeAuthorizationRecord`,
  `Test-StandaloneCheckpointAllowsMerge` (Claude helpers file); a Codex counterpart set under the
  Codex naming convention.
- Moved unchanged: `Get-EpicMergeGateAllowDecision`, `Get-EpicMergeGateBlockDecision`.
- Modified: `Invoke-EpicMergeGateDecision` (one branch-4 call block plus reading `session_id` from
  `$payload.Envelope`); `Invoke-CodexEpicMergeDecision` (one branch call block plus reading
  `session_id` from the already-parsed payload).
- Unmodified: `Get-EpicMergeGateCommandPrNumber`, all three existing branch predicates, all three read
  seams, `ConvertFrom-EpicMergeGateJson`, `Invoke-EpicMergeGateEntryPoint`.

#### Data flow and validation changes

Envelope in, decision out — unchanged in shape. Branch 4 adds one additional read from the parsed
envelope (`session_id`) and one additional read from each already-parsed checkpoint object
(`standalone_merge_authorizations`). No new I/O of any kind.

#### Error handling and logging updates

Four new reason codes (below). All denials remain non-throwing on the Claude side; the Claude hook
continues to return exit code 0 and express denial through the decision envelope only.

#### Rollback / feature-flag considerations

None, and none wanted. The change is additive and key-gated: a checkpoint that omits
`standalone_merge_authorizations` produces byte-identical decisions to today for every command. Rollback
is a straight revert. A runtime feature flag would add a second bypass surface to a fail-closed gate
and is explicitly not introduced.

### Technical specifications

#### Reason codes

Four new distinct, greppable codes. Each is declared **once** as a script-scoped constant in the
helpers file, and each is spelled **byte-identically** on both runtimes.

| Code | Fires when |
| --- | --- |
| `STANDALONE_MERGE_AUTHORIZATION_ABSENT` | The command is in scope and names an explicit PR number, branches 1-3 have all declined, and **none** of the three checkpoints carries the `standalone_merge_authorizations` key. The message must tell the operator that an authorized path exists and how to take it. |
| `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH` | The key is present with at least one PR-specific entry, but **no** entry's `pr_number` equals the command's extracted number. Distinct from `..._ABSENT` on purpose: "you have records, but not for this pull request" is a different operator situation from "you have none". |
| `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` | The entry matching the command's PR number fails a field-shape check. The message must name the failing field. Covers `pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis`, `run_slug`, and `session_id` — including the case where the envelope carries no `session_id` at all, which fails closed. |
| `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC` | The key is present but names no specific pull request, under any of the spellings enumerated above. This is the code that makes the "a blanket flag is not an authorization record" ruling executable and visible in the transcript. |

**The bare-command case keeps the existing code.** A `gh pr merge --merge` with no explicit PR number
can never match a PR-specific record, so branch 4 is not entered and the command continues to deny
with the **existing line-433 `EPIC_MERGE_GATE_BLOCKED` text**. This is a decision, not an omission, and
it must be pinned by a named test rather than left implicit — the existing inherited case at
`enforce-epic-merge-gate.Tests.ps1:205` covers the bare command with a parallel checkpoint present, but
not with an authorization record present.

#### Inputs / outputs and formats

Input: the `PreToolUse` envelope JSON, unchanged. Output: the existing allow / deny decision envelope
shape (`hookSpecificOutput` with `hookEventName`, `permissionDecision`, and on deny
`permissionDecisionReason`), unchanged.

#### Required configuration keys and defaults

`standalone_merge_authorizations` is **optional** in every checkpoint. Its default is absence, and
absence is the existing behaviour.

#### Backward-compatibility expectations

A checkpoint that omits the key produces a byte-identical decision to today for every command. No
existing checkpoint requires migration. No existing writer requires a change.

#### Performance constraints

The decision path performs no additional I/O, starts no process, and makes no network call. The added
work is bounded by the number of entries in the array, which is the number of standalone merges a
single run has authorized. No latency target beyond "no measurable change" is claimed.

## Assumptions, Constraints, Dependencies

Assumptions:

- The `PreToolUse` envelope carries a top-level `session_id` on the `Bash` matcher. Corroborated by
  `.claude/hooks/persist-session-id.ps1`, which extracts `session_id` from a SessionStart payload, and
  by `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:406`, which already feeds an
  envelope carrying `{"session_id":"s1","tool_name":"Bash"}`. **If a live Bash envelope is observed to
  carry no `session_id`, the design still holds**: the gate fails closed on that case by contract,
  so the outcome is a deny with `..._MALFORMED`, never a false allow.
- The orchestrating session that authorizes a standalone merge is the session that issues the merge
  command. If it is not, the `session_id` check denies, which is the intended conservative outcome.

Constraints:

- No file may exceed 500 lines.
- Enforcement hooks are PowerShell or bash only.
- No temporary files anywhere in tests.
- No `Mock gh` and no `Mock git` in any Pester test.
- Line coverage at least 85 percent. PowerShell is exempt from the branch-coverage threshold because
  Pester does not measure branch coverage.

External dependencies: none. No new library, no new service, no new release.

## Data / API / Config Impact

### Checkpoint schema

One new **optional, key-gated, top-level** array, `standalone_merge_authorizations`, recognised in all
three orchestrator-state checkpoints. Documented as prose invariants in a new section of
`.claude/rules/orchestrator-state.md` following the additive convention that file already states four
times. **No JSON Schema file is authored, imported, or read**, per the Foreign Schema Warning at
`.claude/rules/orchestrator-state.md:29-33`. The new section carries one Enforcement bullet naming the
`PreToolUse` gate as the enforcing surface and stating explicitly that the Python checkpoint validator
does not currently validate this block (follow-up FU-3).

The block name avoids `depends_on`, `integration_branch`, and `epic_merge_pr` at every nesting level,
because the parallel-checkpoint validator rejects those three names at any depth.

### The three registrations a new `.claude/hooks/*.ps1` file requires

| Registration | Path | Test-enforced? |
| --- | --- | --- |
| Bundled mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | **Yes, automatically.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) walks every file under `.claude/` recursively, so a new file enters the enumeration by virtue of existing and both the presence and the content assertions fire. No test edit is required. Caveat: the comparison is text-mode, so a pure line-ending difference would pass. |
| Pack manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | **Yes.** `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139` (`test_bundled_claude_files_are_listed_in_some_pack_manifest`) asserts every bundled `.claude/` file appears in the union of the manifests' `paths` arrays. Hooks are enumerated individually, not by directory glob. |
| Coverage configuration | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `CodeCoverage.Path` | **NO — not auto-covered.** `CodeCoverage.Path` is an explicit per-file allow-list. A file absent from it sits outside the coverage denominator, which the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` forbids and which a feature-review agent is instructed to treat as **Blocking**. The entry must be added **before** the coverage baseline is taken, or the baseline measures nothing for the new file. |

Codex-side registration for the change: the Codex hook is modified in place, so it needs no new
manifest entry and no new byte-identity list entry. Its bundled mirror at
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
must be updated; byte identity there is asserted by a hardcoded allow-list test that already lists the
hook.

### The 500-line cap is not test-enforced on the Claude side

An automated line-cap assertion exists only for `.codex/**`. **No automated test enforces the 500-line
cap on `.claude/hooks/**` in this tree.** The cap is therefore a policy obligation for this feature,
verified by an explicit enumerated count of every changed and added file, not by a gate.

### User-facing, logging, and compatibility notes

- User-facing: a standalone merge becomes possible where it was previously impossible, and only via
  an explicit written authorization.
- Logging/telemetry: four new deny reason codes in `PreToolUse` transcripts. No other telemetry.
- CLI flags and config schemas: unchanged. `.claude/settings.json` is not edited.

## Test Strategy

### Structure

- The existing Claude suite `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is 455 lines
  against the 500 cap and **cannot** absorb the matrix. Add a sibling suite
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, following the
  established split convention (`enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`).
- Add `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` for the Codex branch.
- Test files live under `tests/` mirroring the production structure. A new file under `tests/scripts/`
  is discovered automatically; no discovery-config entry is needed.
- Load pattern: dot-source both the parent hook and the new helpers file in `BeforeAll`, with the
  "deliberately redundant, idempotent" comment the existing suites carry, so a change to the parent's
  dot-source line cannot silently leave cases asserting against functions from somewhere else.
- Table-driven `-ForEach` over the matrix rows, each row supplying the command text, the checkpoint
  JSON literals, the envelope `session_id`, the expected decision, and the expected reason token.
- A determinism block in each new file's header, mirroring
  `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:14-20`: every case drives the pure decision seam,
  every case mocks **every** checkpoint read seam, no case writes to disk, no case starts a process,
  no case reads a clock.
- **No temporary files.** Repository policy prohibits them in tests, and the existing suites already
  cover the real read seams by mocking `Test-Path` and `Get-Content` with a `-ParameterFilter` on the
  script-scoped path variable rather than creating a fixture.
- Direct predicate coverage: parse checkpoint literals with `ConvertFrom-Json` and call the new
  predicates by name, following the existing pattern. This is what makes the coverage threshold
  reachable on the new file.

### The false-allow idiom the new tests must follow

The hook's own comment at `.claude/hooks/enforce-epic-merge-gate.ps1:143-150` describes a defect that
failed in **both** directions, and the test that pins its false-allow direction is at
`tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:87-131`. That construction
has four properties that make it a genuine discriminator rather than a tautology, and the new
PR-mismatch tests must reproduce all four:

1. **Two distinct PR numbers, exactly one of them authorized.** If both were authorized the test could
   not distinguish which number the gate read.
2. **The unauthorized number appears in the operand; the authorized number appears elsewhere on the
   line** (inside a `cd` path). A naive implementation and the correct one disagree about which one is
   read.
3. **All three checkpoint seams mocked, and only the one under test populated**, so the decision turns
   on exactly one variable.
4. **A paired positive case** proving the implementation does not simply deny everything.

Applied to this feature: an authorization record naming PR 501 only, and the command
`cd /repo/worktrees/501 && gh pr merge --merge 777`. A naive "a record is present, therefore allow"
implementation allows; the correct implementation denies with `..._PR_MISMATCH`. The paired positive
is the same record with the command merging 501.

### Mandatory matrix

Every currently-passing case is retained as a **regression guard**, not omitted as redundant.

| # | Command | Checkpoint / envelope state | Expected | Reason code |
| --- | --- | --- | --- | --- |
| 1 | `gh pr merge 691 --merge` | record naming 691, all fields valid, `session_id` matches the envelope | **allow** (currently denies) | — |
| 2 | `gh pr merge 691 --merge` | record naming 777 only, well-formed | **deny** | `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH` |
| 3 | `gh pr merge 691 --merge` | no `standalone_merge_authorizations` key on any of the three checkpoints | **deny** (currently denies) | `STANDALONE_MERGE_AUTHORIZATION_ABSENT` |
| 4 | `gh pr merge 691 --merge` | key present, value is the boolean `true` (blanket flag) | **deny** | `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC` |
| 5 | `gh pr merge 691 --merge` | one case per non-PR-specific `pr_number` spelling: absent, `null`, `0`, negative, non-integer number, digit-spelling string, `"*"`, array, object; plus an empty array and a non-object entry | **deny** | `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC` |
| 6 | `gh pr merge 691 --merge` | one case per field-shape failure: `pr_url` not ending in the matching `/pull/691`; `issue_num` non-integer; `branch_name` empty; `authorized_by` empty; `authorized_at` unparseable; `basis` empty; `basis` shorter than the stated minimum; `run_slug` present but empty | **deny** | `STANDALONE_MERGE_AUTHORIZATION_MALFORMED`, message naming the failing field |
| 7 | `gh pr merge 691 --merge` | record naming 691, `session_id` differs from the envelope's | **deny** | `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming `session_id` |
| 8 | `gh pr merge 691 --merge` | record naming 691 with a `session_id`, envelope carries **no** `session_id` | **deny** (fail closed) | `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming `session_id` |
| 9 | `cd /repo/worktrees/501 && gh pr merge --merge 777` | record naming 501 only | **deny** | `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH` — the four-property discriminator |
| 10 | `cd /repo/worktrees/501 && gh pr merge --merge 501` | record naming 501 | **allow** | — the paired positive for row 9 |
| 11 | `gh pr merge --merge` (bare, no PR number) | record naming 691, well-formed | **deny** | existing `EPIC_MERGE_GATE_BLOCKED` line-433 text, pinned exactly |
| 12 | `gh pr merge 691 --merge` | checkpoint text is malformed JSON | **deny** (unchanged) | existing `EPIC_MERGE_GATE_BLOCKED` |
| 13 | `gh pr merge --merge` | branch-1 child checkpoint `epic_mode: true`, `step9_status: "passed"` | **allow** (unchanged) | — regression guard |
| 14 | `gh pr merge 688 --merge` | branch-2 epic checkpoint, `epic_merge_pr.ci_gate.conclusion: "success"`, matching `pr_number` | **allow** (unchanged) | — regression guard |
| 15 | `gh pr merge 501 --merge` | branch-3 parallel checkpoint, item 501 `merge_status: "ci_green"`, **no** standalone key | **allow** (unchanged) | — regression guard |
| 16 | `gh pr merge 501 --merge` | branch-3 parallel item 501 whose `merge_status` is not `ci_green` | **deny** (unchanged) | existing `EPIC_MERGE_GATE_BLOCKED` |
| 17 | `gh pr merge 501 --merge` | branch-3 parallel item 501 at `ci_green` **and** a standalone record naming 777 only | **allow** (unchanged) | — proves branch 4 is evaluated last and never overrides a branch-1-to-3 allow |
| 18 | `gh pr merge 691 --squash` | a valid authorization record naming 691 is present | **allow** — out of trigger scope | — **new paired case**, proves the record does not widen trigger scope |
| 19 | `gh pr merge 10 --squash` | any | **allow** (unchanged) | — the existing `enforce-epic-merge-gate.Tests.ps1:27` case, which must stay green and **must not be edited** |
| 20 | `printf` whose quoted text mentions the gated merge phrase | any | **allow** (unchanged) | — scope-filter regression guard |
| 21 | empty payload; unparseable JSON payload | any | **deny** (unchanged) | existing `EPIC_MERGE_GATE_BLOCKED` envelope-anomaly text |

Rows 1-11, 17 and 18 are new. Rows 12-16 and 19-21 are the existing regression guards, asserted in
place.

Codex suite: rows 1-8, 11, 13, 14, 18, 19 and 21 have Codex counterparts with the Codex allow
representation (`$null`) and the Codex parameter seam. Rows 15-17 have **no** Codex counterpart,
because the Codex hook has no parallel path and must not acquire one.

### Tests that must not be edited

Every case in the four existing suites is a regression guard. A change to one is a signal that the fix
widened something. In particular the extractor cases (the number-before-flag, flag-before-number,
equals-joined, cd-prefixed, and bare-command forms), the false-allow context, the fail-closed cases,
and the scope-filter cases stay byte-unchanged.

### Toolchain

Format, lint (PSScriptAnalyzer), architecture/contract checks, unit tests (Pester), and the
push-down contract tests, repeated from stage 1 whenever any stage fails or auto-fixes a file.
Type checking is not applicable to PowerShell.

### Coverage

`CoveragePercentTarget` is `0` in the Pester run settings, so Pester will not fail the run on the
percentage; the threshold is enforced by review. A coverage baseline, a post-change measurement, and a
comparison must therefore be captured as explicit evidence artifacts under
`docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/coverage/`, with the
new helpers file registered in `CodeCoverage.Path` **before** the baseline is taken.

## Acceptance Criteria

### Behaviour — the authorization record

- [x] With a valid authorization record naming PR 691 present in any one of the three orchestrator
      checkpoints and a matching envelope `session_id`, `gh pr merge 691 --merge` is allowed, where it
      denies today. Pinned by a named case in
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`.
- [x] The allow in the preceding criterion holds when the record is carried in the per-feature
      checkpoint, when it is carried in the epic checkpoint, and when it is carried in the parallel
      checkpoint. Three named cases, one per checkpoint.
- [x] A record naming a different PR denies with `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH`, proved
      by the four-property discriminator: record naming 501 only, command
      `cd /repo/worktrees/501 && gh pr merge --merge 777`, all three read seams mocked with only one
      populated, and a paired positive case merging 501 that allows.
- [x] With no `standalone_merge_authorizations` key on any of the three checkpoints, an in-scope
      command naming an explicit PR denies with `STANDALONE_MERGE_AUTHORIZATION_ABSENT`, and the deny
      message states that an authorized path exists and how to take it.
- [x] Every non-PR-specific spelling denies with `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC`, with
      one named case for each of: block value `true`; block value a string; block value an object;
      empty array; entry not an object; `pr_number` absent; `pr_number` `null`; `pr_number` `0`;
      `pr_number` negative; `pr_number` a non-integer number; `pr_number` a digit-spelling string;
      `pr_number` the wildcard string `"*"`; `pr_number` an array.
- [x] Every field-shape failure on the matched entry denies with
      `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` and a message naming the failing field, with one named
      case per field: `pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis`
      empty, `basis` below the stated minimum length, and `run_slug` present but empty.
- [x] A record whose `session_id` differs from the live envelope's denies with
      `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming `session_id`; an envelope carrying no
      `session_id` at all also denies, naming `session_id`. Two named cases.
- [x] A bare `gh pr merge --merge` carrying no explicit PR number denies with the **existing**
      line-433 `EPIC_MERGE_GATE_BLOCKED` reason text even when a valid authorization record is present.
      Pinned by a named case that asserts the existing text, not merely the token.
- [x] Branch 4 is evaluated after branches 1, 2 and 3. Pinned by a named case in which a parallel
      checkpoint authorizes item 501 at `ci_green` and a standalone record names 777 only: the command
      merging 501 is allowed via branch 3, and the case asserts the allow carries no
      standalone-authorization reason.
- [x] The field-check evaluation order is fixed and the first failure wins, so a record failing two
      field checks emits a deterministic message. Pinned by a named case supplying a record that
      violates both `pr_url` and `basis` and asserting the message names `pr_url`.

### Trigger scope

- [x] `gh pr merge 691 --squash` with a valid authorization record naming 691 present is **allowed**
      as out of trigger scope. New named case; this is the paired case proving the record does not
      widen trigger scope.
- [x] `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:27`
      (`It 'allows gh pr merge without --merge (e.g., --squash)'`) is green and its text is unedited.
- [ ] This spec contains no acceptance criterion asserting that `--squash` denies, and the corrected
      framing — that `--squash` is out of trigger scope and allowed today on both runtimes — is
      recorded in this spec and reflected in the hook's header comment.

### Must not regress (carried verbatim from the epic)

- [x] **The `pr_number` matcher is unchanged.** Verified two ways, both of which can fail.
      (a) A named Pester case asserts `Get-EpicMergeGateCommandPrNumber` returns 410 for the
      number-before-flag form, 410 for the flag-before-number form, 410 for the equals-joined form, 688
      for the cd-prefixed form, 777 for the false-allow form, and nothing for the bare form — the same
      six behaviours the existing suites pin, re-asserted after the change.
      (b) Running `git diff origin/epic/worktree-scoped-state-resolution-integration -- .claude/hooks/enforce-epic-merge-gate.ps1`
      produces no hunk whose context or changed lines fall inside the
      `Get-EpicMergeGateCommandPrNumber` function body, and the same diff is paired with
      `git status --porcelain` showing the file as modified, so a diff that returns nothing because
      the change was never written or never staged is distinguishable from a diff that returns nothing
      because the function is untouched.
- [ ] **The pre-implementation gate's restrictions are not weakened.** No file matching
      `.claude/hooks/enforce-orchestration-preimplementation-gate*.ps1` or its Codex mirrors is
      modified by this change, verified by
      `git diff --name-only origin/epic/worktree-scoped-state-resolution-integration` listing none of
      them, and the gate's existing Pester suites are green and unedited.
- [ ] **Epic and standalone topologies behave exactly as now when cwd and target coincide.** The three
      `$script:*CheckpointPath` assignments and the Codex repository-root anchoring are unchanged, and
      every branch-1, branch-2 and branch-3 allow and deny case in the existing suites is green and
      unedited.
- [ ] **Gates still deny when the required evidence is genuinely absent.** All existing fail-closed
      cases stay green: both checkpoints absent; both checkpoints unreadable; parallel checkpoint
      absent; parallel checkpoint malformed; bare merge with a parallel checkpoint present; empty
      payload; unparseable payload; the end-to-end nested-envelope deny. A checkpoint carrying no
      `standalone_merge_authorizations` key produces the same decision for every command as before the
      change, pinned by at least one named case per existing branch.

### Codex parity

- [ ] `.codex/hooks/enforce-epic-merge-gate.ps1` gains the standalone branch in place, with the same
      activation condition as the Claude side (a well-formed record naming this PR, with a matching
      `session_id`), covered by named cases in
      `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`.
- [ ] All four reason-code tokens are spelled byte-identically on both runtimes, verified by a named
      assertion that compares the token literals extracted from the Claude helpers file and the Codex
      hook.
- [ ] The Codex hook still has no parallel allow path: the tokens `route_id`, `items`, and `parallel`
      occur zero times in `.codex/hooks/enforce-epic-merge-gate.ps1` after the change, as they do
      before it.
- [ ] The Codex allow representation stays `$null`, the `exit 2` throw channel is unchanged, the
      `step9_status` accepted set is unchanged, and the `epic_mode` type test is unchanged.

### Registration, configuration, and file size

- [ ] Both bundled Claude mirrors are updated: the modified
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
      and the new
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1`,
      with `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` green.
- [ ] The bundled mirror of `.claude/rules/orchestrator-state.md` and of
      `.claude/skills/parallel-orchestrate/SKILL.md` are updated to match their repository-side files.
- [ ] `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` is added to the `paths` array of
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, with
      `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` green.
- [x] `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` is added to `CodeCoverage.Path` in
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the coverage baseline was taken
      after that entry was added.
- [ ] The Codex bundled mirror
      `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
      is byte-identical to `.codex/hooks/enforce-epic-merge-gate.ps1`, with the Codex runtime-contract
      suite green.
- [ ] Every file created or modified by this change is under 500 lines, verified by an enumerated
      per-file line count recorded in the evidence artifacts, because no automated test enforces the
      cap on `.claude/hooks/**`. The count explicitly includes
      `.claude/hooks/enforce-epic-merge-gate.ps1`,
      `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`,
      `.codex/hooks/enforce-epic-merge-gate.ps1`, both new test suites, and all four bundled mirrors.
- [ ] `.claude/settings.json` is unmodified.

### Documentation and disclosure

- [ ] The honest-disclosure text appears in all three required locations: the `.NOTES` block of
      `.claude/hooks/enforce-epic-merge-gate.ps1`, the header comment of
      `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, and the new section of
      `.claude/rules/orchestrator-state.md`. Each copy states that the record is a policy-level
      auditable declaration and not a cryptographic or security control, that `authorized_by` is a
      declaration the hook does not verify, that the record is not tamper-proof against a same-session
      writer, and what the `session_id` cross-check does and does not stop.
- [x] The hook's header comment block no longer says the gate allows the merge when "one of three"
      conditions holds; it documents four conditions, and the standalone-exclusion paragraph at the
      current lines 23-27 is rewritten so the file's own documentation is not left false.
- [ ] `.claude/rules/orchestrator-state.md` gains a `standalone_merge_authorizations` scope-and-
      backward-compatibility section stating the invariants are additive and key-gated, plus one
      Enforcement bullet. No JSON Schema file is authored, imported, or read for the block, and the
      Enforcement bullet states that the Python checkpoint validator does not currently validate this
      block.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` documents the writer procedure: which fields a
      coordinating session writes, into which checkpoint, and that a blanket flag is rejected. The
      existing `**Merge-gate authorization.**` paragraph is updated to name four allow conditions
      rather than describing only the parallel one.
- [ ] The writer surface is bounded to exactly the two authored surfaces named above plus their
      bundled mirrors. No other skill, agent, or rule file is edited to write or describe the record.
- [ ] The two closed anti-patterns (synthetic `items[]` injection; switching to `--squash`) are
      recorded as closed in this spec, and the implementation introduces neither.
- [ ] Follow-ups FU-1 through FU-4 are filed as issues, or their deferral is explicitly recorded in the
      pull-request description, before this feature is closed.

### Tests, toolchain, and coverage

- [x] Every currently-passing case in all four existing suites
      (`enforce-epic-merge-gate.Tests.ps1`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`,
      `enforce-epic-merge-gate-decision-surface.Tests.ps1`,
      `enforce-epic-merge-gate-trigger-scoping.Tests.ps1`) is green and its text is unedited, with the
      sole permitted exception being additions the matrix requires. Verified by
      `git diff origin/epic/worktree-scoped-state-resolution-integration` over those four files showing
      no deletion and no modification of an existing `It` block.
- [x] `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` exists, is
      table-driven, and carries a header determinism block stating that every case drives the pure
      decision seam, mocks every checkpoint read seam, writes nothing to disk, starts no process, and
      reads no clock.
- [ ] No test in this change creates a temporary file, uses `Mock gh`, uses `Mock git`, uses
      `Start-Sleep`, or makes a network call, with the PowerShell test-purity check green.
- [ ] No file under `.claude/hooks/**` added or modified by this change invokes Python by any route,
      with `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` green and
      its allowlist still empty.
- [ ] Line coverage is at least 85 percent for
      `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`,
      `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`, with
      baseline, post-change, and comparison artifacts stored under
      `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/coverage/`.
      The baseline was taken after the new file was added to `CodeCoverage.Path`.
- [ ] Coverage for the changed lines does not decrease relative to the recorded baseline.
- [ ] The full toolchain loop completed in a single clean pass: format, lint, architecture and
      contract checks, unit tests, with no stage auto-fixing a file on the final pass. Type checking is
      not applicable to PowerShell.

## Risks & Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| A same-session agent forges a record and merges a PR it should not. | A merge that no human authorized. | Not fully mitigable on the Claude substrate. Mitigated by making the act deliberate, attributable, and visible in a checkpoint that feature review reads, and disclosed honestly in three places. Follow-up FU-1 records the substrate change that would close it. |
| The live Bash `PreToolUse` envelope turns out to carry no `session_id`. | Every branch-4 evaluation denies with `..._MALFORMED`. | The design fails closed by contract, so the outcome is a deny, never a false allow. Detectable immediately in the first real use; recoverable by removing the `session_id` requirement, which is a one-field change. The assumption is corroborated by an existing test envelope and by the session-id persistence hook. |
| A stale record from a previous run authorizes a merge in a later run. | An unintended merge. | The `session_id` cross-check denies it. This is the primary value of design (ii). |
| The header rewrite pushes the parent hook over the 500-line cap. | Policy violation with no automated gate to catch it. | The two decision-envelope factories are moved out first, freeing 28 lines; the per-file line count is an explicit acceptance criterion. |
| A new bundled mirror diverges only by line endings and the text-mode parity test passes. | Push-down publishes content that differs from the repository. | Line endings are matched to the sibling files at authoring time; the byte-level test covers only three unrelated files, which is recorded here so a reviewer does not assume otherwise. |
| A reviewer reads the asymmetric Claude-extract / Codex-in-place treatment as a parity gap and requests a Codex helpers file. | Unnecessary Codex manifest, byte-identity list, coverage, and bundle entries. | The asymmetry and its rationale are stated explicitly in the Implementation strategy section. |
| A downstream reviewer reintroduces the false premise that `--squash` denies. | An unsatisfiable acceptance criterion and a proposal to widen trigger scope. | The corrected framing is recorded prominently in this spec with the pinning test cited, and an acceptance criterion forbids the false criterion. |

## Rollout & Follow-up

Release/rollout steps:

1. Land the change on the epic integration branch
   `epic/worktree-scoped-state-resolution-integration`.
2. Epic child F7 (`taskmaster-push-down-and-resume`) rebuilds and reinstalls the extension, then pushes
   the customizations down to TaskMaster. The push-down serves the **installed extension's** bundled
   payload, not the repository tree, so a repository-side-only edit is inert at the push-down surface.
3. F7's first verification action is a grep for changed content under the installed extension's
   `resources/claude-customizations/.claude/hooks/` directory. A grep that finds the old content means
   the push-down verified nothing.

Post-fix monitoring and clean-up:

- Watch the first standalone merge for which reason code, if any, fires. If `..._MALFORMED` naming
  `session_id` dominates, the envelope assumption needs revisiting before anything else is concluded.
- Confirm that no `..._NOT_PR_SPECIFIC` denial is observed in normal operation; one would indicate a
  writer surface producing a blanket flag.

Named follow-ups (these are deferrals with owners to be assigned, not silent drops):

- **FU-1** — Propose a Claude-side permissions posture that would allow an authorization store outside
  the gated agent's write reach, matching the Codex authority-store model. Design (v) is blocked on
  this substrate, not rejected on merit.
- **FU-2** — Claude-side checkpoint path anchoring. The Claude hook resolves the three checkpoint paths
  against the process working directory; the Codex mirror anchors to a repository root derived from
  `$PSScriptRoot`. This is the epic's own defect class and is addressed by F1 and its consumers, not
  here (open question OQ4).
- **FU-3** — A key-gated Python checkpoint validator for `standalone_merge_authorizations`, following
  the `_orchestrator_state_<block>.py` sibling pattern, as defence in depth at completion-gate time.
  A TypeScript parity port is not required; `complexity_assessments` is the established Python-only
  precedent.
- **FU-4** — Bounded spike: determine empirically whether a Bash-matcher `PreToolUse` envelope carries
  `agent_type`. The statement at `.claude/hooks/enforce-epic-invocation-origin.ps1:18-20` and the
  disclosure at `.claude/agents/pr-author.md:85` are in tension, and resolving it would upgrade
  `authorized_by` from a declaration to an attestation. Not required for this design.

Links:

- Issue: https://github.com/drmoisan/drm-copilot/issues/670
- Epic: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F3, wave 0, ref 3.6)
- Research: `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/research/2026-09-13T21-10-epic-merge-gate-authorization-record-research.md`
