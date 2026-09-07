# 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (Spec)

- **Issue:** #634
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening`, child G (gap 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** `full-bug`

> Acceptance-criteria source. Per the `acceptance-criteria-tracking` skill's `full-bug` row, this
> `spec.md` is the sole acceptance-criteria source for this feature. `user-story.md` exists in this
> folder for a separate reason recorded in that file and carries no acceptance criteria.

## Context

The `cleanup-merged-worktrees` skill produces a consolidation pull request
(`documentationandmemories` into `main`), but the merge of that pull request is denied by
`.claude/hooks/enforce-epic-merge-gate.ps1`, because none of the gate's three accept paths can
ever describe a consolidation pull request. The skill's End-to-End Workflow step 5 therefore
depends on a merge that no agent running the skill can perform, and the skill text does not say
who performs it.

Environment:

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (the gate is PowerShell; no Python leg by standing policy)
- Command/flags used: the `gh` pull-request merge invocation carrying the merge-commit flag,
  issued against the consolidation pull request
- Data source or fixture: `.claude/hooks/enforce-epic-merge-gate.ps1`,
  `.claude/skills/cleanup-merged-worktrees/SKILL.md`

Impact / Severity:

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The cleanup workflow is not blocked outright — a human can perform the merge — but every cleanup
run that consolidates content stalls at step 5 and requires an out-of-band human action that the
skill text does not disclose. The cost is an undocumented handoff, not data loss or an unsafe
allow.

## Repro & Evidence

Steps to Reproduce:

1. Run the `cleanup-merged-worktrees` skill through its End-to-End Workflow to the point where
   step 4 has pushed the `documentationandmemories` branch and `Agent(pr-author)` has opened the
   consolidation pull request against `main`.
2. Confirm the required checks are green on that pull request.
3. Attempt to merge the consolidation pull request from the agent session.

Expected:
The skill's own workflow is executable end to end by the agent that runs it, or the skill states
plainly that the merge is a human step and does not present it as an agent action.

Actual:
The merge is denied with `EPIC_MERGE_GATE_BLOCKED`. The gate allows the merge only when one of
three checkpoint shapes is present:

1. a per-feature `artifacts/orchestration/orchestrator-state.json` with `epic_mode == true` and
   `step9_status == "passed"`;
2. an `artifacts/orchestration/epic-orchestrator-state.json` with
   `epic_merge_pr.ci_gate.conclusion == "success"` and, when the command names an explicit pull
   request number, a matching `epic_merge_pr.pr_number`;
3. an `artifacts/orchestration/parallel-orchestrator-state.json` with `route_id == "parallel"`
   whose target item, matched by `pr_number`, has `merge_status == "ci_green"`.

A cleanup run is neither a per-feature orchestration, nor an epic integration, nor a parallel
run, so it writes none of those three checkpoints. The gate fails closed, which is the intended
behavior, and the skill's step 5 is unreachable from the agent session that authored the pull
request.

Logs / Screenshots:

- [x] Attached minimal logs or screenshot
- Snippet: `EPIC_MERGE_GATE_BLOCKED: ... No checkpoint satisfied this gate.`

Supporting research record (evidence base for every citation below):
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/research/2026-09-06T23-15-cleanup-worktrees-consolidation-pr-merge-gate-research.md`.

## Decision

**Option A is selected: document the consolidation merge as a human-performed step in the skill.**

**Option B is rejected: no fourth `artifacts/orchestration/cleanup-worktrees-state.json` checkpoint
shape is added to `.claude/hooks/enforce-epic-merge-gate.ps1`.**

The decision is recorded here as settled. The reasoning is stated in full below so that a later
reader can evaluate it without re-deriving it, and so that a reader who disagrees can identify
precisely which premise to challenge.

### R1 — Option B does not buy the safety property it claims, because the repository ruleset already provides it server-side

This is the decisive reason.

Verified in this session by direct query against the GitHub API
(`gh api repos/drmoisan/drm-copilot/rules/branches/main`):

- The legacy branch-protection endpoint for `main` returns HTTP 404 with the message
  "Branch not protected". A repository **ruleset** (id 15241672) supplies the protection instead.
  **An inspection that checks only the legacy branch-protection endpoint will therefore wrongly
  conclude that `main` is unprotected.** This is recorded explicitly because it is a trap for the
  next reader: the absence of legacy branch protection is not the absence of protection.
- That ruleset applies a `required_status_checks` rule to `main` with
  `strict_required_status_checks_policy: true`, over the following contexts:
  - `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`
  - `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`
  - `docs-validation / Documentation Validation`
  - `poshqc / PowerShell QC`
  - `shell-coverage / Shell Coverage (Bats + kcov)`
  - `security-scan / Security Scanning`
  - `quality-checks7 / Code Quality & Tests` at Python 3.10
  - `quality-checks7 / Code Quality & Tests` at Python 3.11
  - `quality-checks7 / Code Quality & Tests` at Python 3.12
  - `quality-checks7 / Code Quality & Tests` at Python 3.13
  - `build-check / Build Package`
- The same ruleset also applies `pull_request` (with `required_approving_review_count: 0`),
  `deletion`, and `non_fast_forward` rules to `main`.

The consequence is the argument. **A red consolidation pull request cannot be merged into `main`
by anyone — agent or human — regardless of what the merge gate decides.** GitHub enforces the
required checks server-side, and `strict_required_status_checks_policy: true` additionally
requires the branch to be up to date with `main` before the merge becomes available.

The merge gate is therefore not the control that keeps a failing pull request out of `main`. It is
a *procedure* deterrent: it keeps an orchestration agent from merging outside its own recorded
workflow. Option B would add a new trusted-input surface — a self-recorded `ci_gate.conclusion`
inside an `artifacts/` document that is gitignored and survives the run that wrote it — in exchange
for a safety property the server already guarantees. That trade is not worth making.

### R2 — Option B cannot meet the evidentiary standard its own rationale sets

`issue.md` states the condition on the checkpoint route: the specification must "state precisely
what prevents an agent from writing a `ci_gate.conclusion` of `success` that no CI run produced".

The research record's Q3 evaluates six candidate binding mechanisms and its Q2 examines the
precedent the gate itself cites. Two findings follow:

- Of the six candidates, **only a live `gh` call at hook-decision time proves that CI ran**. That
  mechanism is precisely the one the gate's own header records a deliberate decision against
  (`.claude/hooks/enforce-epic-merge-gate.ps1` header: the gate "trusts the on-disk checkpoint
  rather than shelling out live to gh pr view for a real-time head-SHA check"). The research also
  records that no hook under `.claude/hooks/` invokes `git` or `gh` at all, so the mechanism has no
  precedent in the hook family.
- The precedent the gate's header cites — the `pr-author` receipt in
  `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — hashes a local body file against a value in
  a local sibling JSON file that the same agent wrote. **It binds no external fact.** Its own
  header says it "MUST NOT be described as tamper-proof or as a security boundary".

Every mechanism compatible with the gate's stated posture is a local-artifact consistency check.
Stated plainly: **nothing available prevents an agent from writing a `ci_gate.conclusion` of
`success` that no CI run produced.** A specification claiming such a constraint would be false, and
the honest answer disqualifies Option B on the terms the issue itself set.

### R3 — Option B does not remove the human step, because the merge gate is only one of the blockers

The merge command is blocked at more than one layer:

1. **The skill's tool surface.** `gh pr merge` is absent from the `allowed-tools` list in
   `.claude/skills/cleanup-merged-worktrees/SKILL.md`. The sole `gh` entry there is
   `Bash(gh issue view *)`.
2. **The project permission allow-list.** `.claude/settings.json` `permissions.allow` carries no
   `gh` entry of any kind. Verified independently in this session by searching that file for `gh`,
   which returned no match. `.claude/settings.local.json` likewise carries no `gh` entry.
3. **The merge gate.** `.claude/hooks/enforce-epic-merge-gate.ps1` denies with
   `EPIC_MERGE_GATE_BLOCKED`.

Option B as scoped in `issue.md` changes only the third blocker. Removing the human step would
additionally require widening the skill's `allowed-tools` **and** granting a project-level
permission for an agent to merge into `main` unattended. That is a governance decision about
autonomous merge authority, not a bug fix, and it is not this issue's to make.

This reframes the cost comparison `issue.md` states. The comparison is not "a paragraph versus one
hook branch". It is **a paragraph versus a multi-file change plus a permission widening**. The
research record enumerates the Option B path list as ten files across four surfaces (hook, library,
skill, permissions) against Option A's two.

### R4 — A documented human merge is consistent with the cleanup skill's established posture

The skill already requires explicit, per-item human confirmation for two other irreversible or
shared-state mutations:

- **Deleting a branch on `origin`.** Dirty Worktree Triage Procedure step 10: "Because this mutates
  shared, visible remote state, each deletion requires explicit user confirmation — never delete an
  origin branch as an automatic consequence of local cleanup, and never rely on this skill's general
  `Bash(git push *)` allowance to perform it silently."
- **Plain filesystem removal of an orphaned worktree-tracking directory.** Dirty Worktree Triage
  Procedure step 7: "Filesystem removal of an orphaned directory is a destructive action outside
  this skill's pre-approved tool surface; it requires explicit user confirmation each time, the
  same as any other irreversible delete."

Both are recorded a second time in `## Prohibited Shortcuts`: "Never delete an origin branch, or
run plain filesystem removal on an orphaned worktree-tracking directory, without explicit per-item
user confirmation."

A human-performed merge into `main` is a third instance of a pattern the skill already applies
deliberately to irreversible, shared-state actions. Option A is consistent with that posture rather
than an exception to it.

### R5 — Option A removes this feature's dependency on issue #545 entirely

Under Option A, `#634` does not modify `.claude/hooks/enforce-epic-merge-gate.ps1` at all. It
therefore does not collide with child E (#545) in that file and can execute in wave 0 rather than
the wave 1 position `epic.md` assigns it.

This matters because of the unresolved scope contradiction recorded as Finding 3 below. Option A
makes that contradiction moot for `#634` specifically, without requiring it to be resolved first.

### Counter-argument, stated and answered

`epic.md`'s `business_outcome_hypothesis` names merge explicitly: a cleanup run should be carried
"from report through apply, consolidation, and merge without hand-written scripts, manual
consolidation commits, or hook workarounds". A reader may argue that Option A leaves that outcome
partially unmet, because the merge remains a manual step.

The answer has three parts:

1. A documented, disclosed human merge is **not a hand-written script**, **not a manual
   consolidation commit**, and **not a hook workaround**. It is the opposite of a hook workaround.
   A hook workaround is what an undocumented merge-gate evasion would be — for example writing an
   orchestration checkpoint for the purpose of satisfying the gate, which this specification
   forecloses in edit (d).
2. None of the epic's four `leading_indicators` names an unattended merge. They name detached-HEAD
   worktree removal, a sanctioned `SAFE_TO_DELETE` removal path, script-driven `PRESERVE`
   consolidation, and the end of hook denials on a gated command word quoted inside `printf` text.
3. **This is an interpretive reading of the epic's wording, and the epic's author may overrule it.**
   If the author decides that an unattended merge is load-bearing for the epic's business outcome,
   then the change required is not a fourth checkpoint shape on its own: it is a project-level
   permission grant for unattended agent merge authority into `main`, together with the skill
   `allowed-tools` widening from R3. That decision should be taken as its own issue with its own
   argument, and this specification does not take it.

### Rejected alternative, with its rejection reason

| Alternative | Description | Rejection reason |
| --- | --- | --- |
| **Option B** | Add a fourth checkpoint shape, `artifacts/orchestration/cleanup-worktrees-state.json` carrying `consolidation_pr: {pr_number, head_sha, ci_gate.conclusion}`, accepted by `.claude/hooks/enforce-epic-merge-gate.ps1`, written by the skill after the required checks pass. | Rejected on R1 through R5. Decisively on R1: the repository ruleset already prevents a red pull request from merging into `main` server-side, so the fourth shape would add a trusted-input surface in exchange for a property that is already guaranteed. R2 additionally establishes that the constraint `issue.md` requires the specification to state does not exist and cannot be built within the gate's stated posture. |

## Scope & Non-Goals

### In scope

Exactly the two files below, which must remain byte-identical to each other:

- `.claude/skills/cleanup-merged-worktrees/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`

The edit has five parts, labelled (a) through (e) and specified in `## Proposed Fix`. Each is
carried by its own acceptance criterion.

### Out of scope / non-goals

Each exclusion is listed with its reason.

- **Any modification to `.claude/hooks/enforce-epic-merge-gate.ps1`, including its
  `EPIC_MERGE_GATE_BLOCKED` deny-reason string.** Reason: that file is child E's file under the
  epic's recorded dependency edge (`epic.md`: "D depends on E, and G depends on E"), and it is
  subject to issue #545's committed acceptance criterion requiring it to carry no diff. Option A
  does not require the edit, so the collision is avoided rather than negotiated.
- **`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`.** Reason: child D (issue placeholder
  903, gap 3) owns that file.
- **`scripts/bash/cleanup_worktrees_*_lib.sh` and `scripts/bash/cleanup-worktrees.sh`.** Reason:
  children A (#630), B (901), C (902), and F (904) own the bash surface.
- **Any new `artifacts/orchestration/cleanup-worktrees-state.json`.** Reason: Option A is selected,
  so this file is not created and the name remains unclaimed. Recorded so the two names cannot be
  conflated: child D's `artifacts/orchestration/cleanup-worktrees-manifest.json` is a **different
  file with a different purpose** — a removal manifest keyed on a filesystem path, carrying one
  record per removal target, consumed by `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` to
  authorize destruction of a local worktree directory. The rejected
  `cleanup-worktrees-state.json` would have been keyed on a pull-request number, carried one record
  per cleanup run, and authorized a merge into `main`. The research record verified by
  repository-wide search that **neither name appears in any code, test, schema, or validator on this
  branch today**; both occur only in documents.
- **Widening `allowed-tools` in the skill frontmatter, or widening `.claude/settings.json`
  `permissions.allow`.** Reason: per R3, granting an agent unattended merge authority into `main`
  is a governance decision outside this issue's scope.
- **Filing the follow-up for shape 1's missing pull-request-number check.** Reason: it is a distinct
  defect in a file this feature does not touch. Recorded here as an observation for a separate
  issue: `Test-ChildCheckpointAllowsEpicMerge` in `.claude/hooks/enforce-epic-merge-gate.ps1` takes
  no pull-request-number parameter, so a child-feature checkpoint with `epic_mode == true` and
  `step9_status == "passed"` authorizes a merge of **any** pull request, unlike shapes 2 and 3 which
  both match on `pr_number`.

### Explicitly excluded systems, integrations, or datasets

- `.codex/hooks/enforce-epic-merge-gate.ps1`. It is a separate, smaller, already-divergent
  implementation with no parallel accept branch; the research record establishes that a Claude-side
  gate change does not obligate a Codex-side change. Under Option A no gate changes at all, so the
  question does not arise.
- Consumer-repository copies of the skill. Per `epic.md` non-goals, fixes land in `drm-copilot` and
  reach consumers through the existing push-down mechanism.

## Root Cause Analysis

The gate was designed around three orchestration surfaces (per-feature, epic, parallel). The
cleanup skill is a fourth surface that produces a merge-eligible pull request and was never given a
checkpoint shape. That is the mechanical cause of the denial.

The **documentation** defect, which is what this feature fixes, is narrower and separate: the skill
text never says who performs the consolidation merge. Step 5's heading is "Wait for merge and
verify git-natively" and its body is already passive — "After the consolidation PR merges". The
skill therefore does not claim the agent performs the merge; it simply does not say who does, does
not say why the agent cannot, and does not disclose that the wait is a handoff out of the session.

### Findings recorded against prior documents

Each finding below was verified against the tree by the research pass or verified in this session,
as stated. They are recorded because downstream agents would otherwise carry the wrong figures or
the wrong framing forward.

**Finding 1 — the assurance-asymmetry premise is false.** The delegation framing that a fourth
checkpoint shape "would trust a CI conclusion recorded by the same agent that wants to merge, which
is a materially weaker assurance than the three existing shapes" is contradicted by the tree. All
three existing accept paths already have exactly that property:

- Shape 1: the per-feature orchestrator records `step9_status: passed` and then merges, per
  `.claude/skills/orchestrate/SKILL.md`.
- Shape 2: `epic-orchestrator` records `epic_merge_pr.ci_gate` and then merges, per
  `.claude/skills/epic-orchestrate/SKILL.md`.
- Shape 3: `parallel-orchestrator` records `merge_status: ci_green` and then merges, per
  `.claude/skills/parallel-orchestrate/SKILL.md`.

Shape 1 is additionally **weaker** than any proposed fourth shape, because
`Test-ChildCheckpointAllowsEpicMerge` takes no pull-request-number parameter and therefore
authorizes a merge of any pull request.

The correct framing is: **a fourth shape would be as strong as shapes 2 and 3 and stronger than
shape 1.** The argument for Option A rests on R1 through R5 and **not** on an assurance asymmetry
that does not exist. This is recorded prominently because the false version of the argument is easy
to falsify at review, and would then discredit the surrounding reasoning.

**Finding 2 — line-count corrections.** The research pass re-derived these figures with a
whole-file line-count scan on this branch. They are recorded as single-source figures; the research
record documents one derivation method and no independent cross-check derivation, so they are
stated as re-derived rather than as doubly confirmed. No acceptance criterion in this document
depends on any of them.

- `.claude/hooks/enforce-epic-merge-gate.ps1` is **452** lines, not the 451 recorded in `issue.md`
  and in `epic.md` (twice, in the `nfrs` block and in Shared Design Constraints item 2).
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is **419** lines, not the 418 recorded in
  `epic.md` Shared Design Constraints item 2.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` at 264 lines and
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` at 455 lines are correct as
  recorded in `issue.md`.

**Finding 3 — the #545 scope contradiction is unresolved on this branch.** Issue #545's committed
`spec.md` at
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
lists `enforce-epic-merge-gate.ps1` under `Out of scope / non-goals`, carries an acceptance
criterion requiring that file (among others) to **carry no diff**, and carries a further acceptance
criterion requiring that a **separate follow-up issue** be filed for exactly those gates.
`epic.md` asserts the opposite: that "Child E extends #545 to cover the gate-hook instances rather
than opening a second issue for the same defect class", and records the dependency edge "D depends
on E, and G depends on E."

The contradiction is recorded, not resolved. **Option A makes it moot for `#634` specifically**,
because `#634` produces no diff in that file. It **remains live for child D** (issue placeholder
903), which does modify a gate hook (`enforce-epic-worktree-removal-gate.ps1`) and whose dependency
on E rests on the same reading.

**Finding 4 — the potential entry `epic.md` cites as unpromoted is in fact promoted.** `epic.md`
refers to
`docs/features/potential/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md` as
an "unpromoted potential entry". The file is not at that path. It is at
`docs/features/potential/promoted/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`
and records **issue #591**, promoted on 2026-08-29. It also describes a **different defect** from
gap 8: #591 is an unanchored pull-request-number capture in the merge gate (a mis-parse), whereas
gap 8 is an over-match on quoted command text (a false denial). Both live in
`enforce-epic-merge-gate.ps1`; they are not the same fix.

## Proposed Fix

### Design summary (what changes where)

Prose only, in one skill document and its byte-identical bundle mirror. No code, no tests, no
enforcement surface, no state model, no new artifact.

| Part | Location in `.claude/skills/cleanup-merged-worktrees/SKILL.md` | Nature |
| --- | --- | --- |
| (a) | End-to-End Workflow step 5 — heading and first sentence | name the actor |
| (b) | End-to-End Workflow step 5 — body | state why |
| (c) | End-to-End Workflow step 5 — body | state the handoff boundary |
| (d) | `## Prohibited Shortcuts` | new entry |
| (e) | `## Cross-References` | new entry |

Plus the byte-identical mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.

### (a) Name the human as the actor

Step 5 names the human as the actor performing the consolidation merge and states that the merge is
performed outside the agent session.

Rationale: this **completes an under-specified sentence rather than retracting a claim**. The
current heading is "Wait for merge and verify git-natively" and the current body is already passive
("After the consolidation PR merges"). The skill never claimed the agent performs the merge. What
it omits is who does.

The edit introduces the token `human-performed` into step 5.

### (b) State why the merge is human-performed

Step 5 states the reason, naming the blockers from R3 and the gate's deny reason, so that a future
agent that hits the denial finds the explanation in the skill text rather than treating the denial
as a defect to route around:

- `gh pr merge` is absent from this skill's `allowed-tools`;
- `.claude/settings.json` `permissions.allow` carries no `gh` entry;
- `.claude/hooks/enforce-epic-merge-gate.ps1` denies with `EPIC_MERGE_GATE_BLOCKED`.

The edit introduces the tokens `EPIC_MERGE_GATE_BLOCKED`, `settings.json`, and `permissions.allow`
into step 5.

### (c) State what the agent does at the handoff boundary, and then stops

Step 5 states that the agent reports the consolidation pull request's URL or number to the operator
and then stops. It also states that the ruleset on `main` sets
`strict_required_status_checks_policy`, so the branch must be up to date with `main` before the
merge becomes available to the operator. It discloses that the wait for the merge is **not bounded
within a session**.

The edit introduces the tokens `strict_required_status_checks_policy` and `unbounded` into step 5.

### (d) Add a `## Prohibited Shortcuts` entry

This part is the substantive hardening. The new entry states that the skill never issues the merge
command, and never writes or edits an orchestration checkpoint in order to satisfy
`.claude/hooks/enforce-epic-merge-gate.ps1`.

It names the specific evasion this forecloses: writing an
`artifacts/orchestration/orchestrator-state.json` carrying `epic_mode: true` and
`step9_status: "passed"`, which shape 1 would accept for **any** pull-request number whatsoever
(Finding 1). The entry is written in the same register as the existing `gh pr create` prohibition
in that section.

The edit introduces the tokens `epic_mode` and `step9_status` into `## Prohibited Shortcuts`.

### (e) Add a `## Cross-References` entry

The new entry names `.claude/hooks/enforce-epic-merge-gate.ps1`, explains its role (a PreToolUse
gate on the merge command, backed by orchestration checkpoints), and explains why a cleanup run
satisfies none of its three shapes: a cleanup run is neither a per-feature orchestration, nor an
epic integration, nor a parallel run, so it writes none of the three checkpoints the gate reads.

The edit introduces the token `enforce-epic-merge-gate.ps1` into `## Cross-References`.

### Boundaries and invariants to preserve

- **The three existing merge-gate accept paths must keep behaving identically.** Under Option A
  this is satisfied **by not touching them**: `.claude/hooks/enforce-epic-merge-gate.ps1` and
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` carry no diff. That is the whole
  mechanism, and it is asserted directly rather than through behavioral regression tests.
- `EPIC_MERGE_GATE_BLOCKED` remains the outcome for any agent-issued consolidation merge. It
  becomes documented rather than surprising.
- Step 5's existing git-native verification —
  `git merge-base --is-ancestor documentationandmemories main` — remains unchanged as the unlock
  condition for step 6.
- The two SKILL.md copies remain byte-identical.

### Dependencies or blocked work

None. Per R5, Option A has no dependency on issue #545 and can execute in wave 0. The wave 1
assignment in `epic.md` was derived from Option B's hook edit and no longer applies to this child.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

1. `.claude/skills/cleanup-merged-worktrees/SKILL.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`

#### Functions/classes/CLI commands impacted

None. No executable code changes.

#### Data flow and validation changes

None. No new artifact, no new schema, no new validator, no new checkpoint.

#### Error handling and logging updates

None in code. The gate's existing deny reason is documented in the skill text; the deny reason
string itself is out of scope.

#### Rollback/feature-flag considerations

Not applicable. The change is documentation prose; rollback is a revert of the two files.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

Unchanged. The skill's Report Line Contract, its `allowed-tools` list, and the merge gate's
checkpoint contracts are all untouched.

#### Required configuration keys and defaults

None added.

#### Backward-compatibility expectations

Full. No behavior of any script, hook, or agent changes. Existing cleanup runs behave identically;
only the documented expectation changes.

#### Performance constraints

Not applicable.

## Assumptions, Constraints, Dependencies

- **Assumptions.** The `main` ruleset verified in this session (id 15241672) remains in force. If
  the required-status-checks rule were removed, R1's decisive argument would weaken and the decision
  should be revisited.
- **Constraints.** Markdown documentation files are exempt from the 500-line cap per
  `.claude/rules/general-code-change.md`, so the skill's growth is not budget-constrained. Every
  `.claude/**` edit must be mirrored byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- **External dependencies.** None. No new library, service, or release is involved.

## Data / API / Config Impact

- User-facing or API changes: none. Skill documentation text only.
- Data or migration considerations: none. No artifact shape is created, changed, or read.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flag, config schema, or version changes.

## Test Strategy

**There is no PowerShell production change under Option A, so no Pester coverage obligation arises
from this feature.** The reason is stated explicitly rather than left implicit: the coverage
thresholds in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md` attach to changed
production source lines, and this feature changes no `.ps1` or `.psm1` file. No file enters or
leaves the coverage denominator, and no coverage baseline or delta is required.

Seeded from `issue.md`, with the resolution applied:

- Unit coverage areas: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` — the three
  existing accept paths must keep behaving identically. Under Option A this is satisfied by that
  file and its subject hook carrying no diff, asserted directly.
- Integration scenario to retest: a cleanup run reaching step 5, where the operator can determine
  from the skill text alone who performs the merge and why.
- Manual verification notes: the `.claude/**` edit is mirrored byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**` per
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

### Verification surface

1. **`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.** Its
   `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every repository
   `.claude/**` file recursively and asserts byte-identity against the bundled copy. The research
   pass established that the mirror scope is the whole `.claude` tree by recursive enumeration
   rather than an enumerated subtree list, so `.claude/skills/**` is in scope and this is the
   automated gate that observes the change.
2. **The `docs-validation / Documentation Validation` required check**, which is one of the
   contexts the `main` ruleset requires.
3. **A no-diff assertion on `.claude/hooks/enforce-epic-merge-gate.ps1` and on
   `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`**, anchored to
   `origin/epic/cleanup-merged-worktrees-hardening-integration`. This is how the hard constraint
   "the three existing accept paths must keep behaving identically" is satisfied under Option A:
   by not touching them.

### Fail-before evidence

A failing-run demonstration is structurally impossible for this defect: the defect is an omission
in prose and there is no assertion that can fail on it today. Per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, the delivery records a fail-before
exception dossier carrying a `WhyFailingRunImpossible` section and an alternative-proof section,
rather than fabricating a failing run. It is written to
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/regression-testing/`.

All evidence artifacts for this feature are written under
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written to
`artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/`.

### Toolchain commands to run

- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- No PowerShell toolchain loop is required, because no PowerShell file is changed.
- No bash toolchain loop is required, because no shell file is changed.

## Acceptance Criteria

Each criterion names the assertion that decides it. Search assertions use fixed-string, single-line
tokens that this document quotes verbatim above, so no assertion depends on a multi-word prose
phrase that could break across a line wrap. Diff assertions are anchored to the explicit ref
`origin/epic/cleanup-merged-worktrees-hardening-integration`.

- [ ] AC-1 — (a) Step 5 of the End-to-End Workflow in `.claude/skills/cleanup-merged-worktrees/SKILL.md` names the human as the actor and states the merge occurs outside the agent session. Assertion: `rg -F -n "human-performed" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match, and every reported match line lies within the End-to-End Workflow step 5 item.
- [ ] AC-2 — (b) Step 5 names the merge gate's deny reason. Assertion: `rg -F -n "EPIC_MERGE_GATE_BLOCKED" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match within the End-to-End Workflow step 5 item.
- [ ] AC-3 — (b) Step 5 names the project permission allow-list as a blocker. Assertion: `rg -F -n "permissions.allow" .claude/skills/cleanup-merged-worktrees/SKILL.md` and `rg -F -n "settings.json" .claude/skills/cleanup-merged-worktrees/SKILL.md` each report at least one match within the End-to-End Workflow step 5 item.
- [ ] AC-4 — (c) Step 5 states the up-to-date-branch precondition the ruleset imposes. Assertion: `rg -F -n "strict_required_status_checks_policy" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match within the End-to-End Workflow step 5 item.
- [ ] AC-5 — (c) Step 5 discloses that the wait for the merge is not bounded within a session. Assertion: `rg -F -n "unbounded" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match within the End-to-End Workflow step 5 item.
- [ ] AC-6 — (d) The `## Prohibited Shortcuts` section forbids writing or editing an orchestration checkpoint to satisfy the merge gate, naming the shape-1 evasion. Assertion: `rg -F -n "epic_mode" .claude/skills/cleanup-merged-worktrees/SKILL.md` and `rg -F -n "step9_status" .claude/skills/cleanup-merged-worktrees/SKILL.md` each report at least one match, and every reported match line lies within the `## Prohibited Shortcuts` section.
- [ ] AC-7 — (e) The `## Cross-References` section names the merge gate and explains why a cleanup run satisfies none of its checkpoint shapes. Assertion: `rg -F -n "enforce-epic-merge-gate.ps1" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match within the `## Cross-References` section.
- [ ] AC-8 — The two SKILL.md copies are byte-identical. Assertion: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"` exits 0.
- [ ] AC-9 — The merge gate hook is unmodified. Assertion: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-epic-merge-gate.ps1` produces empty output.
- [ ] AC-10 — The merge gate's test file is unmodified. Assertion: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` produces empty output.
- [ ] AC-11 — No out-of-scope surface is modified. Assertion: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks .claude/settings.json scripts/bash` produces empty output.
- [ ] AC-12 — No cleanup checkpoint contract is introduced anywhere in the runtime, test, or extension trees. Assertion: `rg -F -n "cleanup-worktrees-state" .claude scripts tests extensions` reports no match.
- [ ] AC-13 — A fail-before exception dossier is recorded under the canonical evidence location. Assertion: a file matching `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/regression-testing/fail-before-exception.*.md` exists, and `rg -F -n "WhyFailingRunImpossible"` over that directory reports at least one match.
- [ ] AC-14 — A manual read-through record is captured under the canonical evidence location, recording that step 5 now names its actor and that the push-down parity test passed. Assertion: a file exists under `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/qa-gates/` and `rg -F -n "human-performed"` over that directory reports at least one match.
- [ ] AC-15 — The `docs-validation / Documentation Validation` required check reports a `success` conclusion on this feature's pull request.

## Risks & Mitigations

- **Risk: the epic's author reads `business_outcome_hypothesis` as requiring an unattended merge.**
  Impact: this feature would be judged as leaving the epic's stated outcome partially unmet.
  Mitigation: the counter-argument is stated and answered in `## Decision`, the interpretive nature
  of the reading is labelled, and the precise change required if the author overrules it — a
  project-level permission grant for unattended agent merge authority, plus the skill
  `allowed-tools` widening — is named so the follow-up is well specified rather than open-ended.
- **Risk: a future reader checks only the legacy branch-protection endpoint and concludes `main` is
  unprotected**, then re-opens Option B on a false premise. Mitigation: R1 records the 404 and the
  ruleset id explicitly as a trap for the next reader.
- **Risk: a future agent hits `EPIC_MERGE_GATE_BLOCKED` and treats it as a defect to route around**,
  for example by writing an orchestration checkpoint that shape 1 would accept. Mitigation: edit (d)
  forecloses exactly that evasion by name in `## Prohibited Shortcuts`, and edit (b) puts the
  explanation at the point of the denial.
- **Risk: the two SKILL.md copies drift.** Mitigation: AC-8 pins byte-identity through the existing
  push-down parity test, which is a required check's subject.
- **Risk: Finding 3's #545 scope contradiction is read as resolved by this document.** Mitigation:
  the finding states explicitly that it is recorded and not resolved, that Option A makes it moot
  for `#634` only, and that it remains live for child D.

## Rollout & Follow-up

- **Release/rollout steps.** The change ships in `drm-copilot` and reaches consumer repositories
  through the existing push-down mechanism. No consumer copy is patched. A push-down serves the
  installed extension payload, so the edit does not reach a consumer until the extension is rebuilt
  and reinstalled.
- **Post-fix monitoring or clean-up tasks.**
  - File a follow-up issue for shape 1's missing pull-request-number check
    (`Test-ChildCheckpointAllowsEpicMerge` authorizes a merge of any pull request).
  - Resolve Finding 3's #545 scope contradiction before child D executes.
  - Correct the line counts in Finding 2 in `epic.md` when that file is next edited.
- **Links.**
  - Issue: https://github.com/drmoisan/drm-copilot/issues/634
  - Epic: `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`
  - Research: `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/research/2026-09-06T23-15-cleanup-worktrees-consolidation-pr-merge-gate-research.md`
  - Related: issue #545 (child E), issue #591 (merge-gate pull-request-number mis-parse)
