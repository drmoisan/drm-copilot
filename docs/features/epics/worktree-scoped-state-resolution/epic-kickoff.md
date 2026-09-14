# Epic Kickoff: worktree-scoped-state-resolution

Planned by epic-planner on 2026-09-14T11:00:00Z. All child features are prepared: issues
promoted, active folders created, research complete, spec written, atomic plans approved,
preflight ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json
(branch: epic/worktree-scoped-state-resolution-integration).

## Invocation Prompt

Run `/epic-run worktree-scoped-state-resolution` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at docs/features/epics/worktree-scoped-state-resolution/epic.md.
The integration branch epic/worktree-scoped-state-resolution-integration already contains
every prepared feature folder and approved atomic plan.
Every child resumes at atomic execution from its committed plan-path rather than re-planning.
Execute per the
epic-orchestrate skill: wave-scheduled child orchestrator runs in isolated worktrees,
merge-on-green fan-in to the integration branch, and the final integration-to-main PR.
Read the Prerequisites and Execution Amendments sections of this artifact before launching
wave 0; EA-1 through EA-6 are binding on named children and are not carried in any child's
cleared plan.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 669 | docs/features/active/2026-09-13-target-worktree-resolution-module-669 | 0 | C3 | docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md |
| 670 | docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670 | 0 | C3 | docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md |
| 671 | docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671 | 0 | C3 | docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md |
| 675 | docs/features/active/2026-09-13-collect-pr-context-explicit-target-675 | 0 | C2 | docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/plan.2026-09-13T20-49.md |
| 672 | docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672 | 1 | C3 | docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md |
| 673 | docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673 | 1 | C3 | docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md |
| 674 | docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674 | 2 | C2 | docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/plan.2026-09-13T20-48.md |

## Integrity

planning_commit: 15a3a4f094bfdb95935c27bd23bee499b1bb205d

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md | 7a43afa6934b56c53ada1fecde1178a3e78a3b51 |
| docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md | 781fd077e28b68d890cc3255dabe3aa2450c6b1a |
| docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md | 3e498aaed0ef4e953d3c82a60ed24bdb28059bb7 |
| docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/plan.2026-09-13T20-49.md | d13a938d2a4bc85e321b29e35497a56b2a99045d |
| docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md | 878838aedd5740b9abe819e287ded7b47fe9220f |
| docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md | 96e118d5f39c91c1ebd0907c41e5a64f7a8ef58c |
| docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/plan.2026-09-13T20-48.md | 9f9151c8d331c5b91d4a09a8265c60eb3f7dee11 |

## Execution Order

Waves are recomputed by longest-path layering over the manifest DAG and were verified against
`scripts/dev_tools/epic_wave_computation.py` at planning time. The graph is acyclic and every
`depends_on` entry resolves.

| wave | features | width |
| --- | --- | --- |
| 0 | 669 (F1), 670 (F3), 671 (F2), 675 (F6) | 4 |
| 1 | 672 (F4), 673 (F5) | 2 |
| 2 | 674 (F7) | 1 |

Maximum wave width is 4. Both wave-1 edges are genuine contract edges: 672 and 673 consume 669's
resolution semantics and its ambiguity reason code, and neither could be specified before that
contract existed. 674's edge set `[670, 671, 672, 673, 675]` is minimal — 669 is reached
transitively through 672 and 673.

## Prerequisites

**P-0 — Re-verify each plan hash before launching its child.** Recompute with
`git hash-object <plan-path>` and compare against the Integrity table above. A mismatch means the
plan changed after clearance, so the recorded preflight measured different bytes than the ones
about to be executed.

**P-1 — The epic owns no GitHub issue, and the integration-to-`main` PR is blocked without one.**
`enforce-pr-author-skill.ps1` validates the per-feature checkpoint with `--require-pr-creation-ready`,
which demands `issue-num`. An epic whose manifest carries only child issue numbers has no truthful
value for that field. Before `epic-orchestrator` reaches the final PR, promote the epic itself from
the main session: `new_potential_entry`, then `potential_to_issue` with `promotion_type: epic` and
`work_mode: full-feature`. `epic-planner` could not do this — it holds no promotion MCP tools and
`gh issue create` is hook-denied.

**P-2 — Do the main-into-integration sync merge BEFORE opening the integration PR.** A
`CONFLICTING` PR receives zero CI checks, and the integration PR is the only one in this epic that
runs the real `ci.yml`.

**P-3 — Merged child worktrees must be removed manually.** `git worktree remove` returns
`PARALLEL_WORKTREE_REMOVAL_BLOCKED`, which demands a parallel-checkpoint `items[]` record that an
epic run cannot legitimately produce. Seven preparation worktrees plus six revision worktrees are
outstanding; F5 measured 48 live worktrees in the repository overall. Writing a synthetic parallel
checkpoint to satisfy the matcher is anti-pattern 1 in the epic manifest and must not be done.

## Execution Amendments

These are binding additions to prepared plans, established during planning but after the affected
child's preflight cleared. They are recorded here rather than by reopening a cleared plan, because
amending a plan after clearance would invalidate the clearance measured against it. Hand each
amendment to the named child in its delegation prompt.

### EA-1 (binding) — verify every wave-0 child's PR base branch explicitly

Applies to children 669, 670, 671, and 675.

`enforce-pr-author-skill.epic-base-branch.ps1` takes `CheckpointPath` defaulting to the relative
`artifacts/orchestration/orchestrator-state.json`, and `Test-EpicBaseBranchOverride` is a no-op
when `epic_mode` is absent or false, or when the checkpoint is unreadable. That is fail-open by
design. In this epic's topology a sibling checkpoint occupying the session root and lacking
`epic_mode` silently skips the base-branch requirement and permits `gh pr create --base main` for
a PR that must target the integration branch.

Child 673 fixes this, but 673 is in wave 1 and every wave-0 child runs first. Do not rely on the
gate. After each wave-0 child opens its PR, confirm with
`gh pr view <n> --json baseRefName` that the base is `epic/worktree-scoped-state-resolution-integration`.

### EA-2 (binding) — child 673's reproduction hard-halt must not be bypassed

Applies to child 673.

Defects 3.2 and 3.4 were never reproduced during preparation. Two independent attempts were
blocked: `task-researcher` has no command-execution tool, and the worktree isolation guard refuses
any `pwsh` launch. The mechanism rests on a complete static trace, which is weaker than
observation, and the artifacts say so rather than softening it.

The plan therefore carries reproduction as its first executable phase with a hard halt: if the
predicted `allow` is not observed, no hook file may be edited. That halt is the only thing
standing between a static trace and a behavioural change to a fail-closed gate. Do not let a child
proceed past it on the grounds that the trace is convincing.

The established working execution route is (a') — a hard-coded scratchpad `.sh` file invoked as
bare `sh`, which then launches the absolute PowerShell 7 path. Route (b), a Pester-expressed
invocation through the MCP tool, was struck from the plan: the MCP tool captures no child stdout,
so it cannot produce the probe output the acceptance demands and cannot host a scratchpad fixture.

### EA-3 (binding) — child 675 must run Phase 5 before Phase 6

Applies to child 675.

Five existing Jest suites pass today only because the diff they compute is empty. Phase 5 repairs
those suites; Phase 6 wires the empty-diff guard. Reordering turns five vacuous passes into five
failures. This is the same defect class as the epic's own subject — a gate that cannot fail —
occurring in the test suite rather than in a hook.

### EA-4 (binding) — the PoshQC MCP tools return no captured script output

Applies to children 669, 670, 671, 672, and 673.

`extensions/drm-copilot/src/repo-automation-service.ts:355-379` composes the `summary` before the
child process runs and passes no `stdoutArtifactPattern`, unlike `newPotentialEntry` at lines
225-236. Child output goes to the VS Code extension output channel.

Every affected plan has been revised to derive its asserted values from readable sources:
`artifacts/pester/pester-junit.xml` for counts and per-node results, `artifacts/pester/powershell-coverage.xml`
for coverage keyed on the parent `package` directory, a direct `Invoke-ScriptAnalyzer` for
diagnostic records, and `Get-FileHash` or `git status --porcelain` pairs for write-mode tools.

Two traps inside that remedy, both found after the audit and both already handled in the plans —
carry them if any further plan text is written:

- `Invoke-PoshQCAnalyze` throws on a non-zero count and returns nothing, so a bare "count is 0"
  assertion has no observable. Anchor to the zero-branch literal at `PoshQC.Analyzer.psm1:185`,
  which the line-183 throw pre-empts.
- Pester emits one `testcase` node per `-ForEach` row, so a "matches exactly one node" rule fails
  against a correct implementation for any parameterised test. Fix expected node counts per
  identifier.
- `<testsuite errors="0">` is a literal constant Pester writes; asserting it verifies nothing.

### EA-5 (binding) — epic-child PRs receive no CI; dispatch it explicitly

Applies to all children.

`.github/workflows/ci.yml` triggers only on pushes and pull requests targeting `main` and
`development`, so a PR based on the integration branch triggers no CI run. This is the expected
state for every epic child, not an incident, and it must not be read as a failure or as grounds to
skip the S9 gate.

Dispatch the pipeline against the feature branch and read the result:

```
gh workflow run ci.yml --ref <feature-branch>
gh run list --workflow=ci.yml --branch <feature-branch> --limit 1 --json databaseId,status,headSha
gh run view <id> --json jobs -q '[.jobs[]|select(.conclusion!="success")]|length'
```

Confirm the run's `headSha` equals the PR's `headRefOid` before recording `ci_gate`; the dispatch
resolves `--ref` to the remote branch tip, so an unpushed commit would silently measure the wrong
tree.

### EA-6 (binding) — child 674 must confirm payload freshness before the push-down

Applies to child 674.

`push_down_claude_customizations` serves the **installed** extension's bundled payload, not the
repository tree. Running it against a stale install publishes the old files and overwrites any
working destination fix with the superseded version — the verification step would actively undo
the fix it was meant to confirm.

674's first verification action is a grep for a changed literal under the installed extension's
`resources/claude-customizations/.claude/hooks/`. A stale result means the push-down verified
nothing and must not be reported as passing. The install command's exit code is explicitly
disclaimed as evidence; the freshness grep is the reload-completion signal.

Both of 674's human-interaction requirements are resolved as runbook-backed `exception` with
non-empty `runbook_path`, and both runbooks are committed in its feature folder. HI-2's resolution
rests on a verified finding: `mcpDidChangeEmitter` is created and wired yet never fired anywhere
in `src/`, so an install that exits 0 does not make the running window's MCP server serve the new
payload, and no safe automated non-disruptive reload path exists in this repository.

## Preparation Notes

Four PowerShell plans were audited for acceptance conditions that no tree state can satisfy. All
four had cleared `atomic-executor` preflight; three carried the defect and were revised (671: 8
tasks; 673: 12 tasks and one route ambiguity; 672: 5 tasks and two ambiguities). Only 670 was
clean, and the differentiator was that it wrote a governing derivation paragraph naming a readable
source and the tasks it governs.

This class is invisible to both preflight and the plan validator, as
`.claude/skills/atomic-plan-contract/SKILL.md` states directly: "Check that the task-ordering does
not make the condition unsatisfiable. No rule covers this." Treat a cleared preflight as evidence
that the plan obeys the rules, not as evidence that its gates can fail.

Child 673 additionally reported that each of its four confirming rounds found a fresh instance of
one of two recurring defect classes, and advised against reading its final clean sweep as stronger
than "no further defect found by a full pass."

Eleven corrections to the original briefing are recorded in the epic manifest, including two where
the planner's own assertion was wrong: `wc -l` undercounts files with no trailing newline by one
against the `(Get-Content).Count` measure the 500-line cap uses, and `--squash` is out of the merge
gate's trigger scope rather than denied by it.
