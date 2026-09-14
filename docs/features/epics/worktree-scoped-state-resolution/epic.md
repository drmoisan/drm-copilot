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
  - issue_num: 1001
    feature_folder: target-worktree-resolution-module
    depends_on: []
  - issue_num: 1002
    feature_folder: preimplementation-gate-worktree-selector
    depends_on: []
  - issue_num: 1003
    feature_folder: epic-merge-gate-authorization-record
    depends_on: []
  - issue_num: 1006
    feature_folder: collect-pr-context-explicit-target
    depends_on: []
  - issue_num: 1004
    feature_folder: prd-feature-gate-target-resolution
    depends_on: [1001]
  - issue_num: 1005
    feature_folder: false-approval-elimination-pr-author-model-routing
    depends_on: [1001]
  - issue_num: 1007
    feature_folder: taskmaster-push-down-and-resume
    depends_on: [1002, 1003, 1004, 1005, 1006]
---

# Epic: Worktree-Scoped State Resolution

> **Placeholder issue numbers.** The `issue_num` values above (1001-1007) are placeholders
> written at manifest-authoring time, before child promotion. Each is back-filled from its
> child's promotion receipt during preparation fan-in. The manifest is committed in final,
> resolved form before the kickoff artifact is written.

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

The false-approval mode is the more serious of the two. A gate that denies incorrectly stalls a
run visibly. A gate that silently validates one item's action against a different item's state
reports a green that means nothing, and the run proceeds on an unverified basis.

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
Fixing the defect anywhere other than `drm-copilot` produces work that does not survive.

## Scope

Seven defect sites, grouped by the required fix:

| ref | site | failure mode | fix |
| --- | --- | --- | --- |
| 3.1 | `enforce-prd-feature-before-planner.ps1` | false denial | resolve against call target; accept absolute paths |
| 3.2 | PR-creation readiness (`enforce-pr-author-skill*.ps1`) | **false approval** | never fall back to a sibling checkpoint |
| 3.3 | `enforce-orchestration-preimplementation-gate*.ps1` | unreachable exemption | permit an explicit worktree selector |
| 3.4 | `enforce-model-routing-receipt.ps1` | false approval | never fall back to a sibling checkpoint |
| 3.5 | `mcp__drm-copilot__collect_pr_context` | vacuous context | explicit target; fail loudly on empty diff |
| 3.6 | `enforce-epic-merge-gate.ps1` | unlandable fix | authorization record (RULING 1) |
| — | push-down to TaskMaster | — | deliver and confirm resume |

### The five required fixes

1. **Resolve against the call's target, not the session's cwd.** Derive the target worktree from
   the tool-call payload — the feature-folder path in the prompt, the item's branch, the file
   being staged — and resolve state relative to that. Use the session root only when the call
   genuinely has no target.
2. **Accept absolute paths.** Normalise to repo-relative by locating the containing worktree,
   instead of truncating to a fixed segment count. The four-segment truncation must not discard a
   valid prefix.
3. **Never silently fall back to a sibling's checkpoint.** If the correct checkpoint cannot be
   identified, deny with a distinct, greppable reason code naming the ambiguity. Applies to both
   3.2 and 3.4.
4. **Make the staging exemption reachable from a coordinating session.** Permit the
   repo/worktree selector (`-C`, or an equivalent explicit target) while keeping every other
   constraint intact — restricted pathspecs, `-m` only, single segment, no shell metacharacters.
   The exemption's purpose is to bound *what* may be committed, not *from where*.
5. **Make `collect_pr_context` take an explicit target branch/worktree** and fail loudly on an
   empty diff rather than emitting a vacuous context.

## Non-Goals

- Changing child-prompt construction. See the anti-pattern record below.
- Widening the epic-merge gate's `pr_number` matcher (RULING 1 forbids it explicitly).
- Weakening the pre-implementation gate's pathspec, option, or metacharacter restrictions.
- Porting any hook to Python. Enforcement hooks are PowerShell or bash only; a Python leg creates
  a second implementation of the rule that drifts from the first.
- Automatic epic decomposition, or any change to the wave-scheduling machinery itself.

## Must Not Regress

These four constraints are carried verbatim into every child feature's acceptance criteria:

- Gates must still deny when a required document is genuinely absent.
- Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions.
- Do not widen the merge gate's matcher as a side effect of fixes 1-3.
- Epic and standalone topologies must behave exactly as now when cwd and target coincide.

## User Rulings (settled; not to be re-litigated)

**RULING 1 — 3.6 epic-merge gate: RELAX WITH AUTHORIZATION RECORD.** Permit a standalone merge
when an explicit, auditable authorization record is present in orchestrator state. Do **not**
widen the `pr_number` matcher — that is a must-not-regress constraint. Both anti-patterns below
remain closed.

**RULING 2 — Topology: EPIC, wave-layered.**

## Rejected Workarounds (anti-patterns — recorded so they are not re-proposed)

Both were considered during the `bugs-2026-09-11` run and correctly rejected.

1. **Injecting a synthetic `items[]` record** to match the epic-merge gate's `pr_number` matcher.
   Satisfying a matcher by corrupting the state it inspects is not compliance. Invariant 13 would
   then demand a false cohort assignment, so the corruption propagates rather than staying local.
2. **Switching to `--squash`** to evade the matcher entirely. This is disallowed repo-wide, and
   evading a gate is not the same as satisfying it.

## Shared Design

### The resolution contract (F1)

F1 introduces the repository's first worktree/target resolution primitive. Verified: `.claude/lib/`
holds eleven modules (`bash`, `blast-radius`, `cleanup-manifest`, `codex-routing`,
`discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, `orchestrator-state`,
`project-file-merge`, `requirements`) and none of them resolves a worktree. `HookPayload.psm1` is
the existing payload-parsing primitive and is the natural adjacent module.

The contract F4 and F5 consume has three parts:

- **Target derivation** — given a tool-call payload, return the worktree the call pertains to, or
  an explicit "no target" result.
- **Path normalisation** — given a path in either relative or absolute form, return its
  repo-relative form by locating the containing worktree. Segment-count truncation is prohibited.
- **Ambiguity reason code** — a single distinct, greppable code emitted when the correct target
  cannot be identified, so a caller can deny with a specific reason instead of guessing.

F4 and F5 cannot specify their deny paths until this contract's reason code and resolution
semantics exist. That is a genuine upstream/downstream contract, not merely a shared file, and it
is the dependency edge that makes this epic wave-layered rather than flat.

### Bundled-payload mirroring (applies to every child that edits `.claude/**`)

Verified 2026-09-13: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
carries byte-identical copies of all five target hooks (`diff` reports no difference for
`enforce-prd-feature-before-planner.ps1` and `enforce-epic-merge-gate.ps1`). The push-down serves
the **installed extension's** payload, not the repository tree, so a repo-side-only edit is inert
at the push-down surface.

Consequently every child that edits a file under `.claude/**` must also update the corresponding
file under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, or F7 publishes
stale content and its acceptance criteria verify against the old hook.

A **new** module additionally requires registration: verified via
`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`, each `.claude/lib/`
module is asserted to appear exactly once in the `paths` array of
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. F1 must add its
module path there and ship the matching `*.Manifest.Tests.ps1`, or push-down does not deliver the
module at all under `--packs core`.

### Codex mirror surface

Verified: `.codex/hooks/` mirrors `enforce-orchestration-preimplementation-gate.ps1`,
`-helpers.ps1`, and `-modes.ps1` (three files) and `enforce-epic-merge-gate.ps1`. F2 and F3
therefore carry Codex parity work.

`enforce-prd-feature-before-planner.ps1` and `enforce-pr-author-skill*.ps1` have **no** Codex
mirror, so F4 has no Codex parity obligation. `enforce-model-routing-receipt.ps1` has no
same-named mirror, but `.codex/hooks/enforce-codex-model-routing.ps1` exists as a differently
named analogue; F5's research must determine whether it shares the defect.

### File-size pressure

Three of the five target hooks sit near the repository's 500-line cap and cannot absorb new logic
in place:

| file | lines | headroom |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` | 495 | 5 |
| `enforce-epic-merge-gate.ps1` | 486 | 14 |
| `enforce-prd-feature-before-planner.ps1` | 448 | 52 |
| `enforce-pr-author-skill.ps1` | 311 | 189 |
| `enforce-model-routing-receipt.ps1` | 180 | 320 |

F2, F3, and F4 each require a helpers extraction as part of the change, not as optional cleanup.
`enforce-orchestration-preimplementation-gate-helpers.ps1` (495 lines) already exists for F2's
site, so F2's extraction targets a second helpers file or a redistribution across the existing
three-file set.

## Decomposition Rationale

Seven child features. The decomposition follows the fix boundaries rather than the file
boundaries, because fixes 1-3 share the F1 contract while fixes 4 and 5 are independent.

**Wave 0 — foundation and self-unblocking.** F2, F3, and F6 are dependency-free and each closes a
blocker that the run hit. F2 and F3 are deliberately in wave 0 rather than later: F2 restores a
coordinating session's ability to commit work stranded in a child worktree (during the run, a rate
limit killed every agent mid-task and seven items' preparation output was unrecoverable from the
parent session), and F3 makes a run-unblocking fix landable by the orchestration that discovered
it. Both are self-unblocking capabilities, so they pay off inside this epic's own execution, not
only after it.

**Wave 1 — consumers of F1.** F4 and F5 both consume F1's resolution contract and reason code.

**Wave 2 — delivery.** F7 depends on every content-changing child. Its edge set
`[F2, F3, F4, F5, F6]` is minimal: F1 is reached transitively through F4 and F5, so declaring it
would add an edge without adding an ordering constraint.

### Wave assignment

Computed by longest-path layering, `wave(f) = 0` when `depends_on(f)` is empty, otherwise
`1 + max(wave(d))`. The graph is acyclic and every `depends_on` entry resolves.

| wave | features |
| --- | --- |
| 0 | F1, F2, F3, F6 |
| 1 | F4, F5 |
| 2 | F7 |

### Feature register

| ref | issue_num | feature_folder | wave | complexity | depends_on | scope |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | 1001 | `target-worktree-resolution-module` | 0 | C3 | — | new `.claude/lib/` resolution module; fixes 1-3 contract; `core.json` registration; Pester. No consumers. |
| F2 | 1002 | `preimplementation-gate-worktree-selector` | 0 | C3 | — | 3.3 staging exemption (fix 4); Claude + 3 Codex mirrors; helpers extraction. |
| F3 | 1003 | `epic-merge-gate-authorization-record` | 0 | C3 | — | 3.6 per RULING 1; Claude + Codex mirror; checkpoint schema addition. |
| F6 | 1006 | `collect-pr-context-explicit-target` | 0 | C2 | — | 3.5 (fix 5); TypeScript + Jest. |
| F4 | 1004 | `prd-feature-gate-target-resolution` | 1 | C3 | F1 | 3.1 (fixes 1-2); helpers extraction; no Codex mirror. |
| F5 | 1005 | `false-approval-elimination-pr-author-model-routing` | 1 | C3 | F1 | 3.2 + 3.4 (fix 3). **3.2 is the priority case.** |
| F7 | 1007 | `taskmaster-push-down-and-resume` | 2 | C2 | F2,F3,F4,F5,F6 | rebuild + reinstall extension, push down, confirm resume. |

### Complexity bands

Bands are assessed against the `model_policy` scale in `config/orchestration-routing.json`.

- **C3 (F1, F2, F3, F4, F5)** — each modifies a fail-closed enforcement gate where an error
  produces either a silent false approval or a total run stall. F1 additionally establishes a
  contract two downstream features are specified against. F2 and F3 carry cross-surface (Claude +
  Codex) parity. F4 and F5 must distinguish "target resolved, document genuinely absent" from
  "target not resolvable" and deny differently in each case, which is the substance of fix 3.
- **C2 (F6, F7)** — F6 is a bounded TypeScript signature and error-path change across a known file
  set with existing Jest coverage. F7 is procedural delivery with no new logic, but carries two
  human-interaction assessments (below).

## Verification Status

Carried from the originating run and re-verified during planning where noted.

**Verified by direct test during the run:** the 3.1 decision matrix, 3.3, and the 3.6 denial.

**Reported by the run's orchestrator and its children; re-confirm during research:** 3.2, 3.4,
3.5. F5's research must independently reproduce 3.2 and 3.4 before fixing them, because the
false-approval mode leaves no denial in the log to inspect after the fact.

**Re-verified during planning (2026-09-13), against this tree:**

- `enforce-prd-feature-before-planner.ps1` is 448 lines; `Find-PrdFeatureFolderFromPrompt`
  (line 219) truncates prompt tokens to a fixed segment count (documented at lines 16-18, applied
  at line 265), and `Get-PrdFeatureCheckpointFolder` (line 189) is the fallback. `Test-Path
  -LiteralPath` is used on relative candidates at lines 91, 108, and 201. No worktree resolution
  exists anywhere in the file.
- `.claude/lib/` holds eleven modules, none a worktree/target resolution primitive.
- `.codex/hooks/` mirrors the preimplementation gate (3 files) and the epic-merge gate.
- `Test-ExemptOrchestrationStagingCommand` is at
  `enforce-orchestration-preimplementation-gate-helpers.ps1` line 296; it tokenises each segment
  via `ConvertTo-OrchestrationCommandToken` and requires every segment to pass
  `Test-ExemptOrchestrationSegmentToken`.
- The epic-merge gate's three allow paths are documented at lines 8-19 of
  `enforce-epic-merge-gate.ps1`; the parallel path requires `route_id == "parallel"` and an
  `items[]` entry whose `merge_status == "ci_green"`.
- F6's TypeScript surface: `extensions/drm-copilot/src/lib/pr-context/` (16 files, including
  `pr-context-service-call.ts` and `git-client.ts`), `src/pr-context-branches.ts`,
  `src/mcp-tool-definitions.ts`, `src/mcp-repo-automation-tool-definitions.ts`, and
  `src/mcp-tools.ts`. Tests live under `extensions/drm-copilot/test/`, not `tests/` —
  `test/lib/pr-context/pr-context-service-call.test.ts`,
  `test/extension.collect-pr-context.test.ts`, and
  `test/repo-automation-dispatch-pr-context-verification.test.ts`.
- `push_down_claude_customizations` is wired at `src/mcp-tools.ts:198`,
  `src/mcp-tool-definitions.ts:134`, `src/mcp-repo-automation-tool-definitions.ts:145`, and
  `src/lib/push-down/push-down-service-call.ts:195`.

## Required Test Matrix

Every hook child (F2, F3, F4, F5) ships table-driven Pester tests asserting the decision for the
cross product of: **cwd** = session root vs item worktree; **path form** = relative vs absolute;
**target** = own item vs sibling item vs absent.

| case | expected |
| --- | --- |
| own folder named, cwd = session root | allow (currently denies) |
| own folder named, cwd = item worktree | allow (unchanged) |
| absolute path to own folder | allow (currently denies) |
| sibling's checkpoint is the only state present | deny, distinct reason (currently allows — 3.2) |
| required doc genuinely missing | deny (unchanged) |
| `git -C <worktree> add docs/features/active/...` | allow (currently denies) |
| `git -C <worktree> add` with non-exempt pathspec | deny (unchanged) |
| `git add` with `-A`, extra options, or `;` / `&&` / `\|` | deny (unchanged) |

Currently-passing cases are included as regression guards, not omitted as redundant. Each child
takes the rows applicable to its own site; F7 takes none.

## Epic Acceptance Criteria

- A parallel orchestrator whose cwd is the session root can delegate `Agent(atomic-planner)` for
  an item whose `spec.md` exists.
- No gate returns allow on the basis of a checkpoint belonging to a different item; such cases
  deny with a distinct, greppable reason code.
- A coordinating session can stage and commit exempt pathspecs in a child worktree.
- `collect_pr_context` either produces a real diff against an explicit target or fails loudly.
- RULING 1 is implemented: standalone merge is permitted on an auditable authorization record, and
  the `pr_number` matcher is unchanged.
- Pester coverage for the matrix above, including regression guards.
- The fixed customizations are pushed down to TaskMaster and run `bugs-2026-09-11` can resume its
  remediation cycles.

## Human-Interaction Assessment (Autonomous-Execution Mandate)

Surfaced at planning time rather than at execution, per the mandate's requirement that
unautomatable requirements be enumerated before kickoff wherever they are knowable up front. Both
records belong to F7 and are carried into its `human_interaction.requirements[]`.

**HI-1 — Confirm run `bugs-2026-09-11` resumes its remediation cycles.** This acts inside
TaskMaster, a different repository that is not present in this checkout, and the confirmation is
an observation of agent behaviour in that repository's orchestration session rather than a
command whose exit code can be asserted. **Proposed response: `exception`,** with a human-exception
runbook emitted by F7. `scope_change` was considered and not chosen: it would silently drop a
user-stated acceptance criterion. The exception keeps the criterion visible and hands over a
written procedure. The push-down itself is automatable via
`mcp__drm-copilot__push_down_claude_customizations` and is **not** covered by this record.

**HI-2 — Rebuild and reinstall the VS Code extension before the push-down.** The push-down serves
the installed extension's bundled payload, so F7's verification measures stale content unless the
extension is rebuilt and reinstalled first. Whether `vsce package` plus
`code --install-extension` runs unattended in this environment is not yet established.
**F7's research must record an explicit `## Automation Feasibility` assessment for this step** and
resolve it as `scope_change`, `exception`, or `halt`. Do not defer it to execution.

F7's first verification action is a one-line grep for a changed literal under the installed
extension's `resources/claude-customizations/.claude/hooks/` directory. If that grep finds the old
content, the push-down verifies nothing and must not be reported as passing.
