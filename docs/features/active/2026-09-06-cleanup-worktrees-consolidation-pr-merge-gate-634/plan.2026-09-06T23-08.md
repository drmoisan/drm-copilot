# 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (Plan)

- **Issue:** #634
- **Parent:** epic `cleanup-merged-worktrees-hardening`, child G (gap 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-08
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** `full-bug`
- **Branch:** `bug/cleanup-worktrees-consolidation-pr-merge-gate-634`, branched from `origin/epic/cleanup-merged-worktrees-hardening-integration`

## Requirements source

`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md` is the sole
acceptance-criteria source, per the `full-bug` row of the AC-source table in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. It carries fifteen criteria, AC-1 through
AC-15, under its `## Acceptance Criteria` heading. `user-story.md` exists in the folder for a
mechanical readiness reason recorded in that file and carries no acceptance criteria; no task in this
plan tracks delivery against it.

## Decision already taken; not reopened here

`spec.md` `## Decision` selects **Option A** — document the consolidation merge as a human-performed
step — and rejects Option B, the fourth checkpoint shape in `.claude/hooks/enforce-epic-merge-gate.ps1`.
This plan delivers Option A only. No task in this plan modifies any hook, any PowerShell file, any
test file, or any permission allow-list.

## Change surface

Exactly two files change, and they must remain byte-identical to each other:

1. `.claude/skills/cleanup-merged-worktrees/SKILL.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`

The five edits, labelled (a) through (e), are specified in `spec.md` `## Proposed Fix`. Phase 1
carries one task per edit plus one mirror task.

## Language-toolchain applicability, stated with its reason

The change is Markdown prose only. No Python, PowerShell, TypeScript, C#, or bash production or test
file is created, modified, or deleted. Three consequences follow, each stated rather than left as a
silent omission:

1. **No coverage baseline task, no coverage delta task, and no acceptance condition demanding a
   numeric coverage percentage appears anywhere in this plan.** The coverage thresholds in
   `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` attach to changed
   production source lines in a coverage language. This feature changes none, so no file enters or
   leaves any coverage denominator. Independently, the project `addopts` value in `pyproject.toml`
   supplies `--cov-report=lcov:artifacts/python/lcov.info` and no `--cov` target, so a pytest run
   that passes no `--cov` argument collects no coverage data at all. A coverage figure asserted here
   would have no source and the gate could not fail honestly. `spec.md` `## Test Strategy` states the
   same conclusion.
2. **No PoshQC format task, no PSScriptAnalyzer task, and no Pester task appears.** No `.ps1` or
   `.psm1` file is changed, so there is nothing for those stages to act on.
3. **No formatter, linter, or type-checker task appears.** Markdown is exempt from the 500-line file
   cap under `.claude/rules/general-code-change.md`, and no repository formatter, linter, or type
   checker takes a Markdown skill document as input.

The verification surface that does apply is exactly two items: the push-down parity pytest
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
and the `docs-validation / Documentation Validation` required check. The first is executable inside
this plan. The second is not; see the AC-15 deferral below.

## AC-15 is deferred out of the executable phases, with its reason

AC-15 requires the `docs-validation / Documentation Validation` required check to report a `success`
conclusion on this feature's pull request. No pull request exists at any point during atomic
execution: pull-request authoring, CI monitoring, and merge are performed later by
`epic-orchestrator` and are out of this plan's scope. An acceptance condition that cannot be
satisfied when its task runs is a defect, so AC-15 is recorded as a post-pull-request CI gate rather
than authored as a Phase 2 or Phase 3 command task. Phase 3 records the deferral in evidence and
leaves the AC-15 checkbox in `spec.md` unchecked at the end of execution.

## Fail-before evidence is an exception dossier, not a failing run

The defect is an omission in prose. No test can be made to fail before the change and pass after it,
so no `[expect-fail]` task appears. Phase 2 writes a fail-before exception dossier under
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/regression-testing/`
carrying `WhyFailingRunImpossible:` and an alternative-proof section, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. The alternative proof is the Phase 0
baseline: all nine tokens asserted by AC-1 through AC-7 are absent from
`.claude/skills/cleanup-merged-worktrees/SKILL.md` before the change, so those seven criteria
genuinely fail before and pass after.

## Asserted tokens, quoted verbatim for the executor

Each token below is a single-line, non-interpolated fixed string that Phase 1 introduces into
`.claude/skills/cleanup-merged-worktrees/SKILL.md` and Phase 2 asserts. None of them exists in that
file today. They are quoted here, outside every command span, so the quotation is the executor's
instruction:

- `human-performed`
- `EPIC_MERGE_GATE_BLOCKED`
- `settings.json`
- `permissions.allow`
- `strict_required_status_checks_policy`
- `unbounded`
- `epic_mode`
- `step9_status`
- `enforce-epic-merge-gate.ps1`

Two placement constraints follow from the wording of the criteria and must be honoured by the Phase 1
edits. AC-1 requires that **every** match line for `human-performed` lie within the End-to-End
Workflow step 5 item, so that token must not appear in `## Prohibited Shortcuts` or
`## Cross-References`. AC-6 requires that **every** match line for `epic_mode` and for `step9_status`
lie within `## Prohibited Shortcuts`, so neither token may appear in step 5 or elsewhere. AC-2
through AC-5 and AC-7 use at-least-one-match semantics and impose no such exclusivity.

## Evidence location

All evidence artifacts resolve under
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/`, in the
sub-paths `baseline/`, `regression-testing/`, and `qa-gates/`, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Nothing is written to
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical location.
The calling agent supplied canonical paths only, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record
was required.

Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
Where the passing outcome of a command is a non-zero exit code, the artifact additionally carries
`ExpectedExitCode:` with that integer, and that artifact records that one gate only, because the
expectation field is per-file. Use one ISO-8601 `yyyy-MM-ddTHH-mm` timestamp captured at the start of
execution for every artifact filename in a phase.

**Fail-closed evidence rule.** If any required baseline artifact or QA artifact named below is
missing, or is present with an incomplete field set, the outcome is BLOCKED or INCOMPLETE, never
PASS, and the corresponding plan checkbox stays unchecked.

## Out-of-scope files owned by other children

No task in this plan writes to any of the following. AC-9, AC-10, and AC-11 assert that they carry no
diff.

- `.claude/hooks/enforce-epic-merge-gate.ps1` and
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` — child E (#545).
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — child D.
- `scripts/bash/cleanup_worktrees_*_lib.sh` and `scripts/bash/cleanup-worktrees.sh` — children A
  (#630), B, C, and F.
- `.claude/settings.json` — permission widening is out of scope per `spec.md` R3.
- `artifacts/orchestration/cleanup-worktrees-state.json` — not created; AC-12 asserts the name is
  absent from `.claude`, `scripts`, `tests`, and `extensions`. No evidence artifact, agent-memory
  file, or scratch file written by this plan may place that token under any of those four roots.

### Phase 0 — Policy Reading, Rebase, and Pre-Change Baseline Capture

- [ ] [P0-T1] Read the repository policy files in the order enumerated below and write the Phase 0 policy-read artifact.
  - Read, in this order: `CLAUDE.md`; `.claude/rules/tonality.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`. This enumerated order is the authoritative order for this task. It is the baseline order of `.claude/skills/policy-compliance-order/SKILL.md` with two additions, each stated with its reason: tonality is read second because `CLAUDE.md`'s own Policy Compliance Reading Order places tone policy first, and `quality-tiers.md` is read last because `general-code-change.md` defers the tier definitions to it.
  - No language-scoped rule file under `.claude/rules/` is read, because no file in a scoped language is changed. Record that determination and its reason in the artifact rather than omitting the step.
  - Artifact: `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/baseline/phase0-instructions-read.md`, carrying `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: the artifact exists at that exact path, and its `Policy Order:` field records the order actually read, which is the five files enumerated above in that order.

- [ ] [P0-T2] Read the four requirement sources and record the acceptance-criteria inventory as a baseline artifact.
  - Read in full: `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/issue.md`; `.../spec.md`; `.../user-story.md`; `.../research/2026-09-06T23-15-cleanup-worktrees-consolidation-pr-merge-gate-research.md`.
  - Artifact: `.../evidence/baseline/ac-inventory.<timestamp>.md`, carrying `Timestamp:` and one line per criterion for AC-1 through AC-15, each line reproducing that criterion's identifier and its stated assertion from `spec.md`.
  - Acceptance: the artifact contains exactly fifteen criterion lines, identified AC-1 through AC-15 with no gap and no duplicate, and records that `spec.md` is the sole acceptance-criteria source under `full-bug`.

- [ ] [P0-T3] Fetch the integration ref this branch is measured against.
  - Command: `git fetch origin epic/cleanup-merged-worktrees-hardening-integration`
  - Artifact: `.../evidence/baseline/fetch-integration-ref.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0`, and `git rev-parse origin/epic/cleanup-merged-worktrees-hardening-integration` prints a 40-character object name that the artifact records verbatim under `Output Summary:`. The exit code alone is not the acceptance condition, because a fetch that transferred nothing also exits 0; the recorded object name is what distinguishes the states.

- [ ] [P0-T4] Rebase this branch onto the fetched integration ref before any no-diff assertion is executed, and record the result as baseline evidence.
  - Reason, stated so the rebase is not read as optional housekeeping: `epic.md` assigns this child to wave 1 on a dependency edge derived from Option B's hook edit, and `spec.md` `### R5` and `### Dependencies or blocked work` retire that edge for Option A, placing this child in wave 0 with no dependency on issue #545. The rebase is therefore not conditioned on any sibling child having merged. It is required because `epic/cleanup-merged-worktrees-hardening-integration` is the ref that AC-9, AC-10, AC-11, `[P0-T8]`, and `[P3-T2]` all measure against, and other children of this epic fan in to it while this feature executes. `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- <path>` compares the worktree against the ref, so any change that lands on the ref after this branch was created is reported as a difference on this side and the no-diff assertions fail for a reason unrelated to this feature's work. The rebase must therefore precede Phase 2.
  - Command: `git rebase origin/epic/cleanup-merged-worktrees-hardening-integration`
  - Command: `git merge-base --is-ancestor origin/epic/cleanup-merged-worktrees-hardening-integration HEAD`
  - Artifact: `.../evidence/baseline/rebase-onto-integration.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and the verbatim stdout and stderr of the rebase under `Output Summary:`.
  - Acceptance: the ancestry command exits 0, which is the assertion that decides this task. The rebase command's own output is recorded verbatim rather than asserted over, because its success text differs between an applied rebase and an already-current branch.
  - Halt condition: if the rebase reports a conflict, record the conflicting paths and the non-zero exit code in the artifact, stop, and report blocked. Do not resolve a conflict in a file this feature does not own and do not continue to Phase 1.

- [ ] [P0-T5] Capture the pre-change absence of all nine asserted tokens from the skill document; this is the alternative proof consumed by the Phase 2 fail-before dossier.
  - Command: `rg -F -n -e "human-performed" -e "EPIC_MERGE_GATE_BLOCKED" -e "settings.json" -e "permissions.allow" -e "strict_required_status_checks_policy" -e "unbounded" -e "epic_mode" -e "step9_status" -e "enforce-epic-merge-gate.ps1" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/baseline/token-absence-before.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:`. This artifact records this one gate only, because `ExpectedExitCode:` is a per-file field.
  - Acceptance: the command exits 1 and prints no match lines, which is `rg`'s no-match outcome. The `Output Summary:` states that zero match lines were printed and names all nine tokens as absent. If any token is already present, stop and report blocked, because the fail-before proof for the corresponding criterion would not hold.

- [ ] [P0-T6] Capture the pre-change baseline of the push-down parity test that observes this change.
  - Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`
  - Artifact: `.../evidence/baseline/push-down-parity-before.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0`, and the `Output Summary:` reproduces the terminal summary line, which reports `1 passed` for this single selected node. No coverage value is recorded, because the command passes no `--cov` argument and the project `addopts` value supplies a reporter without a target, so no coverage data is collected.

- [ ] [P0-T7] Record the reasoned determination that no coverage baseline and no language toolchain baseline is captured for this feature.
  - Artifact: `.../evidence/baseline/coverage-and-toolchain-not-applicable.<timestamp>.md` with `Timestamp:` and a written determination.
  - Content required: the statement that the change is Markdown only; that no Python, PowerShell, TypeScript, C#, or bash production or test file is changed; that coverage thresholds attach to changed production source lines in a coverage language and none exist here; that `pyproject.toml` `addopts` carries `--cov-report=lcov:artifacts/python/lcov.info` and no `--cov` target, so a coverage percentage asserted from a plain pytest run would have no source; and that Markdown is exempt from the 500-line cap under `.claude/rules/general-code-change.md`.
  - Acceptance: the artifact exists and states all five points above. This task records a determination and runs no command, so it carries no `EXIT_CODE:` field.

- [ ] [P0-T8] Capture the post-rebase, pre-change no-diff baseline for the out-of-scope surfaces, so any later difference is attributable to this feature's work.
  - Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks .claude/settings.json scripts/bash tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`
  - Command: `git status --porcelain -- .claude/hooks .claude/settings.json scripts/bash tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`
  - Artifact: `.../evidence/baseline/out-of-scope-nodiff-before.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:`.
  - Acceptance: both commands exit 0 and print no output. The `Output Summary:` states that both produced zero output lines. The status command is present because an anchored diff enumerates tracked changes only and cannot observe an untracked file created under those paths.

### Phase 1 — Skill Document Edits and Byte-Identical Bundle Mirror

- [ ] [P1-T1] Apply edit (a) to the End-to-End Workflow step 5 item in `.claude/skills/cleanup-merged-worktrees/SKILL.md`: name the human as the actor performing the consolidation merge and state that the merge occurs outside the agent session.
  - Scope: the step 5 heading and its first sentence. Step 5 currently begins `5. **Wait for merge and verify git-natively.**` and its body is already passive, so this edit completes an under-specified sentence rather than retracting a claim.
  - Required token, quoted verbatim: `human-performed`. It must appear inside the step 5 item and nowhere else in the file, because AC-1 requires every match line to lie within step 5.
  - Acceptance: `rg -F -n "human-performed" .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 0, prints at least one match line, and every printed line number falls inside the step 5 item.

- [ ] [P1-T2] Apply edit (b) to the step 5 body: state why the merge is human-performed, naming the three blockers recorded in `spec.md` R3.
  - Content required: that `gh pr merge` is absent from this skill's `allowed-tools`; that the project permission allow-list carries no `gh` entry; and that the merge gate denies the command with its deny reason.
  - Required tokens, quoted verbatim: `EPIC_MERGE_GATE_BLOCKED`, `settings.json`, and `permissions.allow`. All three must appear inside the step 5 item.
  - Acceptance: `rg -F -n -e "EPIC_MERGE_GATE_BLOCKED" -e "settings.json" -e "permissions.allow" .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 0 and prints, for each of the three tokens, at least one match line whose line number falls inside the step 5 item.

- [ ] [P1-T3] Apply edit (c) to the step 5 body: state what the agent does at the handoff boundary and that it then stops.
  - Content required: that the agent reports the consolidation pull request's URL or number to the operator and stops; that the ruleset on `main` sets the strict required-status-checks policy, so the branch must be up to date with `main` before the merge becomes available to the operator; and that the wait for the merge is not bounded within a session.
  - Required tokens, quoted verbatim: `strict_required_status_checks_policy` and `unbounded`. Both must appear inside the step 5 item.
  - Acceptance: `rg -F -n -e "strict_required_status_checks_policy" -e "unbounded" .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 0 and prints, for each of the two tokens, at least one match line whose line number falls inside the step 5 item.

- [ ] [P1-T4] Apply edit (d): add one entry to the `## Prohibited Shortcuts` section of the same file, written in the same register as the existing `gh pr create` prohibition.
  - Content required: that the skill never issues the consolidation merge command, and never writes or edits an orchestration checkpoint in order to satisfy `.claude/hooks/enforce-epic-merge-gate.ps1`. The entry names the specific evasion it forecloses: writing an `artifacts/orchestration/orchestrator-state.json` whose child-feature fields the gate's first accept shape would honour for any pull-request number.
  - Required tokens, quoted verbatim: `epic_mode` and `step9_status`. Both must appear inside `## Prohibited Shortcuts` and nowhere else in the file, because AC-6 requires every match line to lie within that section.
  - Acceptance: `rg -F -n -e "epic_mode" -e "step9_status" .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 0, prints at least one match line for each token, and every printed line number falls inside the `## Prohibited Shortcuts` section.

- [ ] [P1-T5] Apply edit (e): add one entry to the `## Cross-References` section of the same file.
  - Content required: name the merge gate, state its role as a PreToolUse gate on the merge command backed by orchestration checkpoints, and state why a cleanup run satisfies none of its three shapes, namely that a cleanup run is neither a per-feature orchestration, nor an epic integration, nor a parallel run, so it writes none of the three checkpoints the gate reads.
  - Required token, quoted verbatim: `enforce-epic-merge-gate.ps1`. At least one match must lie inside `## Cross-References`; AC-7 uses at-least-one-match semantics, so occurrences elsewhere in the file are permitted. The token `human-performed` must not be used in this entry.
  - Acceptance: `rg -F -n "enforce-epic-merge-gate.ps1" .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 0 and prints at least one match line whose line number falls inside the `## Cross-References` section.

- [ ] [P1-T6] Mirror the edited file byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  - Method: copy the complete post-edit contents of `.claude/skills/cleanup-merged-worktrees/SKILL.md` over the bundle copy. Do not re-apply the five edits independently to the mirror; independent re-application is how the two copies drift.
  - Command: `git status --porcelain -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Acceptance: the status command lists both paths as modified, and `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"` exits 0 with a terminal summary line reporting `1 passed`. The status span is present because it is the observation that distinguishes an applied mirror from an unwritten one; the test alone also passes when neither file was edited.

### Phase 2 — Acceptance-Criteria Verification, Evidence Capture, and Check-Off

Each task in this phase runs its assertion, writes its evidence artifact, and only then changes
`- [ ] AC-N` to `- [x] AC-N` in
`docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md`, altering
the criterion text in no way. If an assertion does not pass, leave the checkbox unchecked and report
the gap.

- [ ] [P2-T1] Verify AC-1 and check it off in `spec.md`.
  - Command: `rg -F -n "human-performed" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-01-human-performed.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0`, at least one match line printed, and every printed line number falls inside the End-to-End Workflow step 5 item. The artifact records the step 5 item's current start and end line numbers so the containment claim is independently checkable. AC-1 is then checked off.

- [ ] [P2-T2] Verify AC-2 and check it off in `spec.md`.
  - Command: `rg -F -n "EPIC_MERGE_GATE_BLOCKED" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-02-deny-reason.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0` and at least one printed match line whose line number falls inside the step 5 item. AC-2 is then checked off.

- [ ] [P2-T3] Verify AC-3 and check it off in `spec.md`.
  - Command: `rg -F -n "permissions.allow" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Command: `rg -F -n "settings.json" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-03-permission-blocker.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:` reproducing every printed match line from both runs.
  - Acceptance: both commands exit 0, and each prints at least one match line whose line number falls inside the step 5 item. AC-3 is then checked off.

- [ ] [P2-T4] Verify AC-4 and check it off in `spec.md`.
  - Command: `rg -F -n "strict_required_status_checks_policy" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-04-strict-checks-policy.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0` and at least one printed match line whose line number falls inside the step 5 item. AC-4 is then checked off.

- [ ] [P2-T5] Verify AC-5 and check it off in `spec.md`.
  - Command: `rg -F -n "unbounded" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-05-unbounded-wait.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0` and at least one printed match line whose line number falls inside the step 5 item. AC-5 is then checked off.

- [ ] [P2-T6] Verify AC-6 and check it off in `spec.md`.
  - Command: `rg -F -n "epic_mode" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Command: `rg -F -n "step9_status" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-06-checkpoint-evasion-forbidden.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:` reproducing every printed match line from both runs.
  - Acceptance: both commands exit 0, each prints at least one match line, and every printed line number from both runs falls inside the `## Prohibited Shortcuts` section. The artifact records that section's current start and end line numbers. AC-6 is then checked off.

- [ ] [P2-T7] Verify AC-7 and check it off in `spec.md`.
  - Command: `rg -F -n "enforce-epic-merge-gate.ps1" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/ac-07-cross-reference.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0` and at least one printed match line whose line number falls inside the `## Cross-References` section. The artifact records that section's current start and end line numbers. AC-7 is then checked off.

- [ ] [P2-T8] Verify AC-8 and check it off in `spec.md`.
  - Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`
  - Artifact: `.../evidence/qa-gates/ac-08-push-down-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing the terminal summary line verbatim.
  - Acceptance: `EXIT_CODE: 0` and a terminal summary line reporting `1 passed`. No coverage value is recorded or demanded, for the reason stated in the plan preamble. AC-8 is then checked off.

- [ ] [P2-T9] Verify AC-9 and check it off in `spec.md`.
  - Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-epic-merge-gate.ps1`
  - Command: `git status --porcelain -- .claude/hooks/enforce-epic-merge-gate.ps1`
  - Artifact: `.../evidence/qa-gates/ac-09-merge-gate-hook-nodiff.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:`.
  - Acceptance: both commands exit 0 and print zero output lines; the `Output Summary:` states the zero-line result for each. The status span is present because an anchored diff cannot observe an untracked path. AC-9 is then checked off.

- [ ] [P2-T10] Verify AC-10 and check it off in `spec.md`.
  - Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`
  - Command: `git status --porcelain -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`
  - Artifact: `.../evidence/qa-gates/ac-10-merge-gate-tests-nodiff.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:`.
  - Acceptance: both commands exit 0 and print zero output lines; the `Output Summary:` states the zero-line result for each. AC-10 is then checked off.

- [ ] [P2-T11] Verify AC-11 and check it off in `spec.md`.
  - Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks .claude/settings.json scripts/bash`
  - Command: `git status --porcelain -- .claude/hooks .claude/settings.json scripts/bash`
  - Artifact: `.../evidence/qa-gates/ac-11-out-of-scope-nodiff.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:`.
  - Acceptance: both commands exit 0 and print zero output lines; the `Output Summary:` states the zero-line result for each, and names the Phase 0 baseline artifact `out-of-scope-nodiff-before.<timestamp>.md` as the pre-change comparison point. AC-11 is then checked off.

- [ ] [P2-T12] Verify AC-12 and check it off in `spec.md`.
  - Command: `rg -F -n "cleanup-worktrees-state" .claude scripts tests extensions`
  - Artifact: `.../evidence/qa-gates/ac-12-no-cleanup-checkpoint.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:`. This artifact records this one gate only, because `ExpectedExitCode:` is a per-file field.
  - Acceptance: the command exits 1 and prints zero match lines, which is `rg`'s no-match outcome, and the `Output Summary:` states the zero-line result. AC-12 is then checked off.

- [ ] [P2-T13] Write the fail-before exception dossier, then verify AC-13 and check it off in `spec.md`.
  - Artifact: `.../evidence/regression-testing/fail-before-exception.<timestamp>.md`, carrying `Timestamp:`, a `WhyFailingRunImpossible:` section, and an alternative-proof section.
  - `WhyFailingRunImpossible:` content required: the defect is an omission in prose; there is no assertion in the repository that fails on it today; and a fabricated failing run is prohibited by `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Alternative-proof content required: cite the Phase 0 artifact `token-absence-before.<timestamp>.md`, which records that all nine tokens were absent from `.claude/skills/cleanup-merged-worktrees/SKILL.md` before the change, and pair it with the Phase 2 artifacts for AC-1 through AC-7, which record the same tokens present after it. State explicitly that those seven criteria therefore fail before and pass after.
  - Command: `rg -F -n "WhyFailingRunImpossible" docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/regression-testing`
  - Acceptance: a file matching `fail-before-exception.*.md` exists in that directory, and the command exits 0 printing at least one match line. AC-13 is then checked off.

- [ ] [P2-T14] Write the manual read-through record, then verify AC-14 and check it off in `spec.md`.
  - Artifact: `.../evidence/qa-gates/manual-read-through.<timestamp>.md`, carrying `Timestamp:` and the read-through record.
  - Filename literal this task creates, quoted here outside every command span so the quotation is the executor's instruction rather than a paraphrase: the record is written into `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/qa-gates/` under the filename stem `manual-read-through`, followed by a dot, the ISO-8601 `yyyy-MM-ddTHH-mm` timestamp used for this phase, and the `.md` extension. The glob literal the second command matches against is `manual-read-through.*.md`, and the file this task writes must be a file that the glob literal `manual-read-through.*.md` matches. No other artifact named in this plan uses the filename stem `manual-read-through`, so that glob selects this task's own record and nothing else. If the written filename does not carry the stem `manual-read-through`, the second command prints no match line and this task fails.
  - Content required: a statement, written after reading the post-edit step 5 item end to end, that step 5 now names its actor, states why the merge is human-performed, and states what the agent does at the handoff boundary; and a statement that the push-down parity test passed, citing the AC-8 artifact by filename. The record must contain the token `human-performed`.
  - Command: `rg -F -n "human-performed" docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/qa-gates`
  - Command: `rg -F -n --glob "manual-read-through.*.md" "human-performed" docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/evidence/qa-gates`
  - Acceptance: both commands exit 0 and each prints at least one match line. The second command is present because the first is directory-scoped: by the time this task runs, the AC-1 artifact already reproduces match lines carrying `human-performed`, so the first command succeeds whether or not this task's own record was written. Only the glob-scoped command observes the artifact this task creates. The first command is retained unchanged because it is the assertion AC-14 states. AC-14 is then checked off.

- [ ] [P2-T15] Verify that step 5's existing git-native verification is preserved unchanged.
  - Reason: `spec.md` `## Proposed Fix` lists the ancestry check as an invariant to preserve, because it remains the unlock condition for step 6. The Phase 1 edits rewrite the surrounding prose of the same list item, which is where an invariant of this kind is lost.
  - Command: `rg -F -n -e "--is-ancestor" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Artifact: `.../evidence/qa-gates/step5-ancestry-invariant.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing every printed match line verbatim.
  - Acceptance: `EXIT_CODE: 0`, at least one printed match line inside the step 5 item, and the printed line still names the `documentationandmemories` branch and `main` as the two ancestry operands. This task carries no acceptance criterion of its own; it guards an invariant `spec.md` states.

### Phase 3 — Final QA Gate, Scope Boundary, and Deferral Records

- [ ] [P3-T1] Re-run the push-down parity test as the closing QA gate, after every Phase 1 edit and every Phase 2 evidence write.
  - Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`
  - Artifact: `.../evidence/qa-gates/final-push-down-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reproducing the terminal summary line verbatim.
  - Acceptance: `EXIT_CODE: 0` and a terminal summary line reporting `1 passed`. This task is unconditional; `SKIPPED` is not a valid outcome for it.

- [ ] [P3-T2] Verify the complete changed-path set against the integration ref and record it as the scope-boundary gate.
  - Command: `git status --porcelain`
  - Command: `git diff --name-status origin/epic/cleanup-merged-worktrees-hardening-integration`
  - Artifact: `.../evidence/qa-gates/final-scope-boundary.<timestamp>.md` with `Timestamp:`, both `Command:` values, both `EXIT_CODE:` values, and `Output Summary:` reproducing the full path list from both runs.
  - Acceptance: the union of the paths reported by the two commands is a subset of exactly these four groups, with no fifth group present: `.claude/skills/cleanup-merged-worktrees/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`; `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/` and any path beneath it; and `docs/features/potential/promoted/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate.md`. The fourth group is this feature's promotion lifecycle record. It is untracked in this worktree and forms part of this feature's change set, in the same way the sibling child carried `docs/features/potential/promoted/2026-09-06-collect-pr-context-omits-claude-tree.md` with its own work; an acceptance condition that omitted it would fail for a reason unrelated to this feature's edits. `git status --porcelain` collapses an untracked directory into a single entry with a trailing slash, so the third group is satisfied by the entry `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/` as well as by individual paths beneath it. The porcelain span is present because a name-listing diff enumerates tracked changes only and cannot report the evidence files this plan creates.

- [ ] [P3-T3] Record the final QA-scope determination as an evidence artifact.
  - Artifact: `.../evidence/qa-gates/final-qa-scope-determination.<timestamp>.md` with `Timestamp:` and a written determination.
  - Content required: that no formatting, linting, or type-checking stage was run and why, namely that no file in a language served by those stages was changed; that no Pester, PoshQC, or PSScriptAnalyzer stage was run and why, namely that no `.ps1` or `.psm1` file was changed; that no coverage figure was captured and why, restating the two independent reasons recorded in the Phase 0 determination artifact; and that the applied QA gate is the push-down parity test recorded in `final-push-down-parity.<timestamp>.md`.
  - Acceptance: the artifact exists and states all four points above, each with its reason. This task records a determination and runs no command, so it carries no `EXIT_CODE:` field.

- [ ] [P3-T4] Record the AC-15 deferral and leave the AC-15 checkbox in `spec.md` unchecked.
  - Artifact: `.../evidence/qa-gates/ac-15-deferred.<timestamp>.md` with `Timestamp:` and the deferral record.
  - Content required: that AC-15 requires the `docs-validation / Documentation Validation` required check to report a `success` conclusion on this feature's pull request; that no pull request exists during atomic execution because pull-request authoring, CI monitoring, and merge are performed later by `epic-orchestrator`; and that AC-15 is therefore satisfied at the post-pull-request CI gate and not inside this plan.
  - Acceptance: the artifact exists and states all three points, and the AC-15 line in `spec.md` still reads `- [ ]`. Marking AC-15 `- [x]` during execution is a defect.

- [ ] [P3-T5] Write the acceptance-criteria status summary required by `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  - Determination, recorded rather than left as a silent omission: the tracking skill's `## AC Identification` section directs generated-document summaries to call `.claude/lib/requirements/GeneratedDocumentCounters.psm1` with `Acceptance Criteria` as the named section. That module was read during planning. It exports exactly one function, `Get-NamedSectionCheckboxCount`, which returns a single integer and matches checked and unchecked items with the same pattern, so `- [ ]` and `- [x]` are counted alike. It can therefore supply only the total-items field of the four-field summary shape the skill defines; it cannot report how many criteria are checked, how many remain, or which criterion remains. The function also takes the document text rather than a path, so calling it would require a wrapper command whose success-case output has not been observed during planning, and the plan contract prohibits asserting over output that has not been observed on a successful run. The search below is therefore retained as the inventory source for this task, because it reports the checkbox state of each criterion individually and so yields all four fields. This is a recorded determination about which inventory mechanism this task uses; it is not a finding against the module or against the tracking skill.
  - Command: `rg -n "^- \[[ x]\] AC-[0-9]+" docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md`
  - Artifact: `.../evidence/qa-gates/ac-status-summary.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reproducing every printed line verbatim.
  - Acceptance: the command exits 0; the printed lines show fourteen criteria checked, AC-1 through AC-14, and exactly one unchecked, AC-15; and the artifact records the summary in the shape the tracking skill defines, naming `spec.md` as the source, `15` as the total, `14` as checked, `1` as remaining, and AC-15 as the remaining item with its deferral reason.

## Out of this plan's scope

Pull-request authoring, CI monitoring, and merge are executed later by `epic-orchestrator`. No task in
this plan opens a pull request, pushes a branch, monitors a check, or issues a merge command.
