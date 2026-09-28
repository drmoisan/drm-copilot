---
epic: worktree-scoped-state-resolution
integration_branch: epic/worktree-scoped-state-resolution-integration
created_at: 2026-09-13T20:45
intent:
  epic_type: enabler
  business_outcome_hypothesis: Parallel and epic orchestration runs complete without cwd-induced stalls; a coordinating session can delegate, stage, and merge for any child item regardless of which worktree occupies the session root.
  leading_indicators:
    - TaskMaster run bugs-2026-09-11 resumes its remediation cycles after push-down.
    - Zero gate denials attributable to cwd/target mismatch in the next parallel run.
    - No gate returns allow on the basis of a sibling item's checkpoint.
  nfrs:
    - Gates remain fail-closed; every ambiguity denies with a distinct, greppable reason code.
    - No production file exceeds the 500-line cap.
    - Line coverage >= 85% and branch coverage >= 75% where the tooling measures it.
features:
  - issue_num: 669
    feature_folder: 2026-09-13-target-worktree-resolution-module-669
    depends_on: []
  - issue_num: 670
    feature_folder: 2026-09-13-epic-merge-gate-authorization-record-670
    depends_on: []
  - issue_num: 671
    feature_folder: 2026-09-13-preimplementation-gate-worktree-selector-671
    depends_on: []
  - issue_num: 675
    feature_folder: 2026-09-13-collect-pr-context-explicit-target-675
    depends_on: []
  - issue_num: 672
    feature_folder: 2026-09-13-prd-feature-gate-target-resolution-672
    depends_on: [669]
  - issue_num: 673
    feature_folder: 2026-09-13-false-approval-elimination-pr-author-model-routing-673
    depends_on: [669]
  - issue_num: 674
    feature_folder: 2026-09-13-taskmaster-push-down-and-resume-674
    depends_on: [670, 671, 672, 673, 675]
---

# Epic: Worktree-Scoped State Resolution

> **Resolved manifest.** Issue numbers and feature folders below are the real, promoted values
> (#669-#675), back-filled from each child's promotion receipt. The placeholder values 1001-1007
> used during decomposition are retired and appear nowhere in this file.

## Goal

Eliminate the defect class in which `drm-copilot` hooks and MCP tools resolve orchestration
state — feature folders, checkpoints, and diff bases — against the invoking session's current
working directory rather than against the worktree the tool call actually pertains to.

In a single-worktree topology cwd and target coincide, so the defect is invisible. In a parallel
or epic topology the orchestrating session's cwd is a different worktree from the item being
acted on, and the same code path produces two distinct failure modes:

- **False denial** — a gate reads the wrong root, does not find a document that exists, and
  denies a delegation that should have been allowed.
- **False approval** — a gate reads a sibling item's checkpoint, finds it satisfactory, and
  allows an action that was never validated against its own item's state.

The false-approval mode is the more serious. A gate that denies incorrectly stalls a run visibly.
A gate that silently validates one item's action against a different item's state reports a green
that means nothing, and the run proceeds on an unverified basis.

## Origin

TaskMaster parallel run `bugs-2026-09-11`, 2026-09-12/13. A 13-item run reached a complete
standstill: zero agents runnable, three items merged, five blocked behind gates, and one blocked
fix that the orchestration which produced it was structurally unable to land. Each blocker was
diagnosed separately before the common cause was recognised.

### Why the fix must land in this repository

`.claude/**` (166 files) plus `config/blast-radius.json` and `config/orchestration-routing.json`
are pushed from `drm-copilot` into consumer repositories with zero templating. A fix made in a
consumer repository is overwritten by the next push-down. That has already happened once: a local
fix to `enforce-model-routing-receipt.ps1` in TaskMaster (commit `4389d95b`, 2026-09-02) was lost.

## Scope

| ref | issue | site | failure mode | fix |
| --- | --- | --- | --- | --- |
| F4 | #672 | `enforce-prd-feature-before-planner.ps1` | false denial | resolve against call target; accept absolute paths |
| F5 | #673 | `enforce-pr-author-skill*.ps1` | **false approval** | never fall back to a sibling checkpoint |
| F2 | #671 | `enforce-orchestration-preimplementation-gate*.ps1` | unreachable exemption | permit an explicit worktree selector |
| F5 | #673 | `enforce-model-routing-receipt.ps1` | false approval | never fall back to a sibling checkpoint |
| F6 | #675 | `mcp__drm-copilot__collect_pr_context` | vacuous context | explicit target; fail loudly on empty diff |
| F3 | #670 | `enforce-epic-merge-gate.ps1` | unlandable fix | authorization record (RULING 1) |
| F7 | #674 | push-down to TaskMaster | — | deliver and confirm resume |

### The five required fixes

1. **Resolve against the call's target, not the session's cwd.** Derive the target worktree from
   the tool-call payload and resolve state relative to that. Use the session root only when the
   call genuinely has no target.
2. **Accept absolute paths.** Normalise to repo-relative by locating the containing worktree.
3. **Never silently fall back to a sibling's checkpoint.** If the correct checkpoint cannot be
   identified, deny with a distinct, greppable reason code naming the ambiguity.
4. **Make the staging exemption reachable from a coordinating session.** Permit the repo/worktree
   selector while keeping every other constraint intact. The exemption's purpose is to bound
   *what* may be committed, not *from where*.
5. **Make `collect_pr_context` take an explicit target** and fail loudly on an empty diff.

## Non-Goals

- Changing child-prompt construction. Every child prompt in the originating run already named its
  own feature folder; that hypothesis was tested and refuted.
- Widening the epic-merge gate's `pr_number` matcher (RULING 1 forbids it explicitly).
- Weakening the pre-implementation gate's pathspec, option, or metacharacter restrictions.
- Porting any hook to Python. Enforcement hooks are PowerShell or bash only.
- Reverting prior fix **#518**. See correction 4 below.

## Must Not Regress

Carried verbatim into every child's acceptance criteria:

- Gates must still deny when a required document is genuinely absent.
- Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions.
- Do not widen the merge gate's matcher as a side effect of fixes 1-3.
- Epic and standalone topologies must behave exactly as now when cwd and target coincide.

## User Rulings (settled)

**RULING 1 — 3.6 epic-merge gate: RELAX WITH AUTHORIZATION RECORD.** Permit a standalone merge
when an explicit, auditable authorization record is present in orchestrator state. Do **not**
widen the `pr_number` matcher.

**RULING 2 — Topology: EPIC, wave-layered.**

## Rejected Workarounds (anti-patterns)

1. **Injecting a synthetic `items[]` record** to match the merge gate's `pr_number` matcher.
   Satisfying a matcher by corrupting the state it inspects is not compliance; invariant 13 would
   then demand a false cohort assignment, so the corruption propagates rather than staying local.
2. **Switching to `--squash`** to evade the matcher. Disallowed as repository policy, and evading
   a gate is not satisfying it. See correction 3: the merge gate does not currently *enforce* this.

## Corrections to the Original Briefing

Each was found during preparation and verified against the tree. They are recorded because
several were propagated into child briefs before discovery, and because `epic-planner` has no
`SendMessage` with which to retract a premise from a running child.

**1. The preimplementation helpers file is 349 lines, not 495.** The 495 figure belongs to the
*gate* file. The original conclusion that F2 "requires a helpers extraction" was false; the
helpers file has ample headroom and F2 correctly dropped the extraction, removing six production
files and four config edits from its change.

**2. There are four mirror surfaces, not three.**
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` also carries the
gate files and is hash-asserted by an existing Codex contract test, so a three-surface change
fails at the last gate. F3 discovered this independently despite being briefed with three.

**3. `--squash` is NOT denied by the merge gate today.** Both hooks scope to a structural
`gh pr merge` carrying `--merge` (`enforce-epic-merge-gate.ps1` lines 402-412), so a `--squash`
command never reaches any branch and is allowed, pinned by a passing test. The repository policy
against `--squash` is real; this gate is not its enforcement point. Making `--squash` deny would
widen the gate's trigger surface and is a separate change outside RULING 1.

**4. The F4 defect site was misattributed, and "truncation is prohibited" was too broad.** The
absolute-path prefix is discarded by the **unanchored regex at line 251**, which begins matching
at the literal `docs`. The four-segment slice at 272-277 removes a *suffix*, came from prior fix
**#518**, and must be preserved byte-unmodified. Line 265 — originally cited as the applied
site — is a comment.

**5. The PoshQC MCP tools return no captured script output.**
`extensions/drm-copilot/src/repo-automation-service.ts:355-379` composes the `summary` before the
child process runs and passes no `stdoutArtifactPattern`, unlike `newPotentialEntry` at lines
225-236 which passes one. Any acceptance condition reading a count, percentage, per-file finding,
or per-node result *out of* a PoshQC MCP result is unsatisfiable. See the audit section below.

**6. Line counts differ by one between `wc -l` and PowerShell.** `wc -l` counts newline
characters, so a file with no trailing newline reads one short of `(Get-Content).Count`, which is
the counting the 500-line cap is judged by.

**7. `.codex/hooks/enforce-codex-model-routing.ps1` is out of F5's scope on positive evidence.**
It contains zero references to `orchestrator-state`, reads no checkpoint, and is a
model/profile-drift gate. The question was open in F5's brief; it is now closed.

**8. F5's root cause was incomplete — there are three cwd-relative binding sites, not one.** See
the shared-design section below.

## Shared Design

### The resolution contract (F1, #669)

F1 introduces the repository's first worktree/target resolution primitive. `.claude/lib/` holds
eleven modules and none resolves a worktree; `HookPayload.psm1` is the existing payload-parsing
primitive and the natural adjacent module.

The contract F4 and F5 consume has three parts:

- **Target derivation** — given a tool-call payload, return the worktree the call pertains to, or
  an explicit "no target" result.
- **Path normalisation** — given a path in relative or absolute form, return its repo-relative
  form by locating the containing worktree. The *prefix* must be preserved; see correction 4.
- **Ambiguity reason code** — a distinct, greppable code emitted when the correct target cannot be
  identified, so a caller denies with a specific reason instead of guessing.

**F1's Ruling C: the module includes a worktree enumerator.** Without one, a relative
feature-folder token cannot be placed in a sibling worktree, and this epic's headline acceptance
criterion is unreachable. It is derivable from the session root with no git subprocess, via the
`gitdir:`/`commondir` indirection, behind a third injectable seam. This enlarges F1 beyond its
original estimate and is why its main file carries a 480-line ceiling.

**Both wave-1 children bind the contract by role, not by literal.** Neither F4 nor F5 quotes an
F1 identifier anywhere; both read from a Phase 0 binding artifact and halt fail-closed if the
module or its exports are absent. F4 adds a second halt arm for the case where F1 cannot
distinguish "no derivation input" from "explicit no-target", without which the three-way gate is
not implementable.

### The third binding site (F5, #673)

`enforce-pr-author-skill.epic-base-branch.ps1` takes `CheckpointPath` defaulting to the relative
`artifacts/orchestration/orchestrator-state.json`, and its `Test-EpicBaseBranchOverride` is
documented as a no-op when `epic_mode` is absent or false, or when the checkpoint is unreadable.
That is **fail-open by design**. In a parallel or epic topology a sibling checkpoint lacking
`epic_mode` silently skips the epic base-branch requirement and permits `gh pr create --base main`
for a PR that should target the integration branch.

**This is a live risk to this epic's own execution.** F5 fixes it, but F5 is in wave 1 and the
wave-0 children execute first. `epic-orchestrator` must verify each wave-0 child's PR base branch
explicitly rather than trusting the gate.

### Bundled-payload mirroring

`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` carries byte-identical
copies of the target hooks. The push-down serves the **installed extension's** payload, not the
repository tree, so a repo-side-only edit is inert at the push-down surface.

Every child editing `.claude/**` must also update the corresponding bundled path. A **new**
module additionally requires registration: each `.claude/lib/` module is asserted to appear
exactly once in the `paths` array of
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, or push-down
does not deliver it under `--packs core`.

### File-size pressure

Counts are `(Get-Content).Count`, the measure the 500-line cap is judged by. Files marked with a
dagger have no trailing newline and read one lower under `wc -l`.

| file | lines | headroom |
| --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | **0** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` † | 496 | 4 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` † | 487 | 13 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 477 | 23 |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 448 | 52 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | 151 |
| `.claude/hooks/enforce-pr-author-skill.ps1` † | 312 | 188 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 186 | 314 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 180 | 320 |

The Codex preimplementation gate's zero headroom is load-bearing for F2's design: worktree-set
membership verification cannot be implemented there, cannot live in the helpers module (declared
pure), and a subprocess would resolve from the hook process's own working directory —
reintroducing the exact cwd-dependence this epic removes. F2 constrains the selector lexically
instead and records a nested-subdirectory residual as an accepted widening with measured exposure
(seven `.md` test fixtures the gate already treats as non-implementation), which F1 can close
upstream later.

## Waves

Computed by longest-path layering, verified against
`scripts/dev_tools/epic_wave_computation.py`. Acyclic; every `depends_on` resolves.

| wave | issues |
| --- | --- |
| 0 | #669, #670, #671, #675 |
| 1 | #672, #673 |
| 2 | #674 |

F7's edge set is minimal: #669 is reached transitively through #672 and #673.

## Feature Register

| ref | issue | folder | wave | band | plan-path | preflight |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | #669 | `2026-09-13-target-worktree-resolution-module-669` | 0 | C3 | `plan.2026-09-13T20-45.md` | ALL CLEAR (5 rounds) |
| F3 | #670 | `2026-09-13-epic-merge-gate-authorization-record-670` | 0 | C3 | `plan.2026-09-13T20-46.md` | ALL CLEAR (4 rounds) |
| F2 | #671 | `2026-09-13-preimplementation-gate-worktree-selector-671` | 0 | C3 | `plan.2026-09-13T20-46.md` | ALL CLEAR (revised) |
| F6 | #675 | `2026-09-13-collect-pr-context-explicit-target-675` | 0 | C2 | `plan.2026-09-13T20-49.md` | ALL CLEAR (3 rounds) |
| F4 | #672 | `2026-09-13-prd-feature-gate-target-resolution-672` | 1 | C3 | `plan.2026-09-13T20-47.md` | ALL CLEAR (revised) |
| F5 | #673 | `2026-09-13-false-approval-elimination-pr-author-model-routing-673` | 1 | C3 | `plan.2026-09-13T20-48.md` | ALL CLEAR (revised) |
| F7 | #674 | `2026-09-13-taskmaster-push-down-and-resume-674` | 2 | C2 | `plan.2026-09-13T20-48.md` | ALL CLEAR (2 rounds) |

All plan paths are relative to the feature folder under `docs/features/active/`.

## Unsatisfiable-Gate Audit

Four PowerShell plans were audited against correction 5. **All four had cleared
`atomic-executor` preflight.** Three carried acceptance conditions no tree state could satisfy:

| plan | result |
| --- | --- |
| #670 | clean — carried a governing derivation paragraph from the start |
| #671 | 8 of 10 PoshQC tasks unsatisfiable — revised |
| #673 | 12 unsatisfiable plus one route ambiguity — revised |
| #672 | 5 unsatisfiable plus two ambiguities — revised |

The single differentiator was whether a plan wrote a **governing derivation paragraph** naming a
readable source and the tasks it governs. The readable sources are
`artifacts/pester/pester-junit.xml` (`testsuites` attributes for counts, `testcase` elements for
per-node results), `artifacts/pester/powershell-coverage.xml` (keyed on the parent `package`
directory, not the bare leaf name), a direct `Invoke-ScriptAnalyzer … | @(…).Count`, and paired
`git status --porcelain` or `Get-FileHash` captures for write-mode tools.

**Two traps inside the remedy itself**, both found by children after the audit:

- `Invoke-PoshQCAnalyze` *throws* on a non-zero count and returns nothing, so a bare "count is 0"
  assertion against it has no observable and is itself a gate that cannot fail. It must be
  anchored to the zero-branch literal at `PoshQC.Analyzer.psm1:185`, which the line-183 throw
  pre-empts.
- Pester emits one `testcase` node per `-ForEach` row, so a "matches exactly one node" rule fails
  against a *correct* implementation for any parameterised test. Expected node counts must be
  fixed per identifier.

This class is invisible to both preflight and the plan validator, as
`.claude/skills/atomic-plan-contract/SKILL.md` states: "Check that the task-ordering does not make
the condition unsatisfiable. No rule covers this."

## Human-Interaction Assessment

Both records belong to F7 (#674) and are resolved as runbook-backed `exception` with non-empty
`runbook_path`.

**HI-1 — confirm run `bugs-2026-09-11` resumes.** Acts inside TaskMaster, a different repository,
and is an observation of agent behaviour rather than a command with an assertable exit code.
`scope_change` was considered and rejected: it would silently drop a user-stated acceptance
criterion. Runbook: `runbooks/confirm-taskmaster-run-resume.runbook.md`.

**HI-2 — rebuild and reinstall the extension before push-down.** Resolved as `exception` on a
stronger finding than anticipated: the rebuild, package, and install sub-steps *are* automatable
via an existing non-interactive script, but `mcpDidChangeEmitter` is created and wired yet **never
fired anywhere in `src/`**, so an install that exits 0 does not make the running window's MCP
server serve the new payload, and no safe automated non-disruptive reload path exists. Runbook:
`runbooks/reload-vscode-window-for-mcp-payload.runbook.md`.

F7's first verification action is a grep for a changed literal under the *installed* extension's
`resources/claude-customizations/.claude/hooks/`. A stale result means the push-down verified
nothing and must not be reported as passing.

## Execution-Time Warnings

1. **Verify each wave-0 child's PR base branch explicitly.** The fail-open epic base-branch check
   is not fixed until #673 merges in wave 1.
2. **F5 (#673) has never reproduced its defects.** Its plan carries reproduction as its first
   executable phase with a hard halt: if the predicted `allow` is not observed, no hook file may
   be edited. Do not let that halt be bypassed.
3. **F6 (#675) Phase 5 must run before Phase 6.** Five existing Jest suites pass today only
   because the diff they compute is empty; Phase 5 repairs them before Phase 6 wires the guard.
4. **TypeScript worktrees need `npm ci`** before their baseline; `node_modules` is absent in a
   fresh worktree.
5. **An epic-child PR into the integration branch receives no CI**, because `ci.yml` triggers only
   on PRs into `main`/`development`. Dispatch `ci.yml` explicitly against the feature branch and
   confirm the run's `headSha` equals the PR's `headRefOid`.

## Known Gaps (not blocking; worth filing separately)

- **`quality-tiers.yml` does not exist** at the repository root, though
  `.claude/rules/quality-tiers.md` declares it the authoritative tier map and states that adding a
  project without a tier classification fails CI.
- **No automated test enforces the 500-line cap on `.claude/hooks/**`.** Two files sit within 13
  lines of it and one Codex file is exactly at it.
- **The epic owns no GitHub issue.** The integration-to-`main` PR is blocked by
  `enforce-pr-author-skill.ps1` unless the epic has its own issue number; promote one with
  `promotion_type: epic` before `epic-orchestrator` reaches that PR.
- **Merged child worktrees cannot be removed by `epic-planner`.** `git worktree remove` returns
  `PARALLEL_WORKTREE_REMOVAL_BLOCKED`, demanding a parallel-checkpoint `items[]` record that an
  epic planner cannot legitimately produce. Writing a synthetic one is anti-pattern 1.
- **F3's authorization record is not tamper-proof.** `.claude/settings.json` sets
  `defaultPermissionMode: bypassPermissions` and its deny list does not cover `artifacts/**`. The
  adopted design converts an untraceable bypass into a deliberate, attributable act via a
  `session_id` cross-check; the stronger design — holding the record outside the gated agent's
  write permissions, as the Codex authority store does — is blocked on substrate, not rejected,
  and is filed as a follow-up. The spec discloses this in three places.
- **F4's plan header still reads `Last Updated: 2026-09-13T23-08`.** No gate depends on it.
