# 2026-09-06-cleanup-worktrees-sanctioned-removal-manifest (User Story)

- **Issue:** #635
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child D; gaps 3 and 9a)
- **Work Mode:** `full-bug`
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07
- **Status:** Ready for planning
- **Version:** 1.0

## Why This Document Exists for a `full-bug` Feature

This feature's work mode is `full-bug`, where `user-story.md` is normally absent. It is required
here for one concrete reason.

`scripts/dev_tools/epic_planner_readiness.py:187` iterates
`for name in ("issue.md", "spec.md", "user-story.md")` and calls `_read_required` for each name
against every prepared epic child's `feature_folder`, appending an error when a file is missing.
Because this feature folder is registered as an epic child of
`cleanup-merged-worktrees-hardening`, the epic planner's execution-readiness gate cannot clear this
child while `user-story.md` is absent, regardless of work mode.

## This Document Carries No Acceptance Criteria

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, the AC source resolution table maps
work mode `full-bug` to **`spec.md` only**. `spec.md` is therefore the sole authoritative
acceptance-criteria source for this feature, and it is where every criterion is tracked and checked
off.

This document deliberately contains no acceptance-criteria checkboxes and no
`## Acceptance Criteria` heading. It carries narrative and non-functional context only. Adding
checkboxes here would create a second, non-authoritative AC surface that the tracking protocol does
not read, and would violate the protocol's "no phantom criteria" rule.

## Narrative

### The operator's position today

An engineer finishes a `/cleanup-merged-worktrees` run on a large checkout. The deterministic
script has done its work: branches are classified, merged worktrees are removed, and what remains
is the residue the script correctly refuses to touch — worktrees whose branches are `NOT_MERGED` or
`HAS_UNIQUE_RESIDUALS`, holding content the script cannot judge.

The engineer then runs the skill's Dirty Worktree Triage Procedure. That procedure exists precisely
to resolve this residue: it prescribes seven read-only investigation steps, a five-way content
classification, and a `SAFE_TO_DELETE` or `PRESERVE` verdict with justification citing specific
files or commit SHAs. The engineer completes it. The verdict is recorded. The justification is
written down.

And then the removal is denied.

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denies with
`EPIC_WORKTREE_REMOVAL_BLOCKED`, because no epic checkpoint records the path.
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denies with
`PARALLEL_WORKTREE_REMOVAL_BLOCKED`, because no parallel checkpoint records it either. Neither hook
is malfunctioning. Both were written for orchestration surfaces where every legitimate removal
target is already in a checkpoint, and the `cleanup-merged-worktrees` skill removes worktrees that
no orchestration checkpoint ever recorded. The skill falls into the gates' fail-closed default with
no route out.

During the 2026-09-06 run on the TaskMaster checkout — 45 branches classified, 7 worktrees removed,
30 detached worktrees invisible to apply mode, 14 dirty worktrees blocked — the only way to complete
the removals was to write them into a shell script file and invoke `bash <file>`. Neither hook
inspects file contents, so both allowed it.

### Why that outcome is worse than either a clean allow or a clean deny

The workaround does not suppress the gate for one justified removal. It suppresses the gate for
**every** removal in the file, including any the triage never covered. The gate's protective value
is lost precisely in the runs where it was intended to apply, and the loss is invisible in the
transcript: the tool call reads `bash <file>` and the hooks record an allow.

A gate that is easy to bypass and that an honest operator is forced to bypass trains the operator
to bypass it. That is the failure this child addresses.

### What changes

The skill gains the ability to write down what it already knows. Its triage already produces a
per-worktree verdict, a branch state, and a justification; the fix records those into
`artifacts/orchestration/cleanup-worktrees-manifest.json`, and both gates gain a branch that
authorizes a removal whose target that manifest covers with a `SAFE_TO_DELETE` disposition, a
non-empty evidence string, a verdict that does not itself imply preservation, and a branch state
the deterministic script deliberately excludes.

The removal stays a single, individually confirmed tool call. The manifest authorizes; it does not
execute.

Two things deliberately do not change. A removal that no manifest record covers is still denied
with the existing reason code. A removal whose target any epic or parallel checkpoint records is
still denied by those gates regardless of what the manifest says — the manifest is a route around a
gap in coverage, never an override of a checkpoint that says a path is unsafe.

### What is honestly still open

The `bash <file>` indirection is not closed by this change and is not claimed to be. No hook
inspects file contents. The manifest is written by the same agent that issues the removal, into a
gitignored directory. Both are policy-level integrity mechanisms with the posture
`.claude/hooks/enforce-pr-author-skill.ps1:35-41` already states for its receipt check: they
prevent accidental bypass and require a deliberate, documented act to circumvent. They are not
cryptographic or security boundaries. The specification records this and requires the skill text to
say it plainly, so a later reader does not mistake the manifest for a stronger guarantee than it is.

### The second, smaller defect

`.claude/skills/cleanup-merged-worktrees/SKILL.md:104` hard-codes `<N> = 396` for the `pr-author`
body-file and receipt contract. Every run therefore writes `artifacts/pr_body_396.md` and its
receipt, overwriting the previous run's artifacts and asserting a provenance that is false for every
run after the one that produced it.

Research established that the receipt contract is self-referential — the hook captures `<N>` from
the command line and compares it only against that captured value, so a freshly written `396` pair
passes every check. The fix is therefore a skill-text edit, not a hook change: use the issue number
the run executes under when one exists, and when none exists, say plainly that `<N>` is an arbitrary
run-scoped identifier and not a PR number. The value of the fix is audit-trail integrity, not
unblocking a failing gate.

## Personas and Their Interests

| Persona | Interest | How this change serves it |
| --- | --- | --- |
| Cleanup operator (human or agent running `/cleanup-merged-worktrees`) | Complete a run without hand-written scripts or hook workarounds | A sanctioned per-worktree removal path for verdicts the triage has already justified |
| Enforcement reviewer | The gates continue to protect epic and parallel worktrees | The checkpoint-exclusion condition, pinned by narrow-scope deny tests that fail if acceptance is written too broadly |
| Auditor reading a transcript after the fact | Reconstruct why each removal was permitted | Every authorizing record carries a non-empty `evidence` string, a verdict, a branch state, and a `run_id` |
| Sibling child F (#904) implementer | A stable contract for `PRESERVE` file staging | `preserved_files[]` specified normatively, as a sibling array the hooks never read |
| Epic planner | Correct dependency edges and no fan-in conflicts | The #545 scope contradiction is recorded and escalated; the design composes with either resolution and touches no bash file |

## Non-Functional Context

### Enforcement posture

The change widens an enforcement allow-side. Every element of the design is built to widen it no
further than the evidence supports:

- The authorized branch-state set is exactly `NOT_MERGED` and `HAS_UNIQUE_RESIDUALS` — the two
  states `SKILL.md:239-245` permanently forbids adding to the script's apply-mode allowlist, and
  therefore the durable residual the manifest exists to serve. `PROTECTED_CURRENT` is never
  authorized under any disposition.
- The authorized disposition set has exactly one member.
- The authorizing key is `removal_disposition`, deliberately distinct from `merge_status`, so a
  cleanup verdict can never be read as an orchestration merge fact and a test can assert the
  existing branches were not widened.
- Any path recorded in an epic or parallel checkpoint is excluded from manifest authorization
  entirely, regardless of that record's status.

### Auditability

A manifest record without evidence is a bare allowlist entry. The predicate requires `evidence` to
be present and non-empty for exactly that reason: it is the field that makes the record an
auditable verdict. `run_id` and `generated_at` let a reviewer correlate a removal with the run that
authorized it.

### Determinism and testability

The manifest read boundary and the clock boundary are both injectable seams. This is required by
the adapter-seam rule in `.claude/rules/powershell.md` and the Determinism Infrastructure rule in
`.claude/rules/general-unit-test.md`, and it is what makes the freshness bound testable without
reading a wall clock or writing a temporary file. No test added by this work creates a temporary
file.

### Staleness

`artifacts/` is gitignored, so a manifest persists after the run that wrote it ends. The epic gate
already documents this residual class for the parallel checkpoint and argues it is implausible
there because parallel worktree paths carry a session or timestamp component. That argument does
not transfer: cleanup targets are ordinary long-lived worktree paths and are materially more
re-matchable. The 24-hour freshness bound exists because the existing argument must not be carried
across unexamined.

### Delivery and parity

Every `.claude/**` edit is mirrored into
`extensions/drm-copilot/resources/claude-customizations/.claude/**` in the same change. The
push-down parity test's scoped root is the whole `.claude` tree, so the new module file is covered.
The new module also lands in both `CodeCoverage.Path` lists and in the core pack manifest, and it
falls automatically within the scan scope of the no-Python enforcement-hook guard. Coverage is
confirmed through the self-hosted PoshQC invocation rather than the MCP runner, because the MCP
runner reads the installed extension's settings and can silently ignore a newly added coverage
entry.

### Scope discipline

Three known adjacent defects are recorded rather than fixed, each with its reason: the Codex-side
hook is not registered in the Claude hook conjunction; the `git reset --hard` block lives in a
different hook with a different reason code and is side-stepped by sibling child C; and the
stale five-versus-six receipt-check docstring is an in-repo documentation discrepancy outside this
child's surface. No new GitHub issue is opened from this preparation run.

## Definition of Done

Done is defined by the acceptance criteria in
`docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/spec.md`, which
is the sole AC source for this `full-bug` feature. In narrative terms, the work is complete when:

1. An operator holding a `SAFE_TO_DELETE` verdict on a `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`
   worktree can issue `git worktree remove <path>` as a single Bash tool call and have both gates
   allow it, with the authorizing evidence recorded in the manifest.
2. The same command targeting a path any epic or parallel checkpoint records still denies with its
   existing reason code, and the tests that would catch a too-broad acceptance are in place and
   passing.
3. The skill text instructs the removal it now permits, grants the matching tool, states the
   accepted residual honestly, and no longer asserts `396` as a provenance it cannot know.
4. The manifest contract is specified completely enough that sibling child F can implement against
   it without reading hook source.

## Related Documents

- `issue.md` — the reported defect and its environment.
- `spec.md` — the authoritative design, the normative manifest contract, the allow predicate, and
  the acceptance criteria.
- `research/2026-09-07-sanctioned-removal-manifest-research.md` — the primary evidence base.
- `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` — epic scope, wave assignment,
  and shared design constraints.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md` — the AC source resolution rule this
  document defers to.
