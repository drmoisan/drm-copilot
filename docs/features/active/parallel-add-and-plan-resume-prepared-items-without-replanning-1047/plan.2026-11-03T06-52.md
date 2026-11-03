# parallel-add-and-plan-resume-prepared-items-without-replanning - Plan

- **Issue:** #1047
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T06-52
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (from `issue.md`)
- **Requirements sources:** `spec.md` `## Acceptance Criteria` (AC-01 to AC-21, numbered in order) and `user-story.md` `## Acceptance Criteria` (mapped in `## AC Traceability`)
- **Design baseline:** `research/research.2026-11-03T12-30.md` `## Recommended Design`; owner decisions in `docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md`

## Required References

- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists, so tiers apply; the new library is T3).
- Tool routes, launchers, command-text restrictions, the PoshQC result limits, the CI shape, the contract tests that pin mirrored files, and the isolation-check list are owned by `.claude/skills/execution-environment/SKILL.md`; this plan references that skill and does not restate it.
- `<FEATURE>` is `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`. Evidence goes only to `<FEATURE>/evidence/<kind>/`, named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- `SCRATCH` is `<session scratchpad>/issue-1047/`; every scratch file, launcher, and staged copy lives under it, and artifacts record the token `SCRATCH`, never a host path.
- Pester pass and fail counts come from `artifacts/pester/pester-junit.xml`, and per-file line coverage from `artifacts/pester/powershell-coverage.xml`, both written by a branch-current `Invoke-PoshQCTest` run. An MCP PoshQC result is never the source of a count, a percentage, or a finding.
- Scope comparisons use the merge base of `origin/main` and `HEAD`.

## Design Summary

- `ParallelAdmission.psm1` holds pure functions for the closed-run guard, stage inference, receipt selection, the staleness verdict, band resolution, and the admission decision. It imports `.claude/lib/blast-radius/BlastRadius.psm1` (`Get-PlanPaths`) and `.claude/lib/blast-radius/BlastRadiusGlob.psm1` (`Test-EntryOverlap`) through `$PSScriptRoot` with `-ErrorAction Stop`.
- `ParallelAdmissionPrecedence.psm1` holds pure functions for precedence validation, the precedence lift, the cohort-table check, active-entry resolution, and the scheduling record.
- `Invoke-ParallelAdmission.ps1` is the CLI. Its subcommands are `guard-run`, `assess`, `order-cohorts`, `test-cohorts`, and `record`. Its seams are `Invoke-ParallelAdmissionGit` (all git calls), `Read-ParallelAdmissionJsonText` (all file reads), and `Get-ParallelAdmissionUtcNow` (the clock). It uses System.Text.Json conversion helpers, as the `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` precedent does. Exit codes: 0 prints one JSON object; 1 prints one stderr line `PARALLEL_ADMISSION_REJECTED: <code>: <detail>`; 2 is a usage error. It loads its functions without running when dot-sourced. No new file contains the token `observed_resolution`.
- Spec placeholders are lines of `docs/features/templates/feature/spec.md` that are non-blank and start with none of `#`, `-`, `|`. Placeholder plan tasks are task lines equal to a task line of `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`. Both templates are read by ref from the `-Main` ref.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policies in the `policy-compliance-order` order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/parallel-orchestration.md`, and `.claude/skills/execution-environment/SKILL.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and every file above listed.
- [x] [P0-T2] Record the scope baseline in `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/scope-baseline.<timestamp>.md`: the merge-base `git diff --name-only --no-renames` and `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/baseline/scope-baseline.<timestamp>.md` lists only paths under `<FEATURE>/` and the promoted lifecycle record `docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md` (plus `.claude/settings.local.json` if it is still locally modified).
- [x] [P0-T3] Capture the Pester baseline with coverage. Scope: `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`, `enforce-parallel-cohort-barrier.Payload.Tests.ps1`, `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1`, and `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md` records passed and failed counts read from the JUnit file, plus the numeric line coverage of `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` read from the coverage XML.
- [x] [P0-T4] Capture the PowerShell static baseline for `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`: a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and an `Invoke-Formatter` comparison.
  - Acceptance: `<FEATURE>/evidence/baseline/poshqc-static-baseline.<timestamp>.md` records the analyzer finding count and whether formatting would change the file.
- [x] [P0-T5] Capture the serial pytest baseline of the contract set under `tests/scripts/dev_tools/` (`## Contract Test Set`).
  - Acceptance: `<FEATURE>/evidence/baseline/pytest-contracts-baseline.<timestamp>.md` records passed, failed, and skipped counts. No production Python changes in this feature, so Python coverage is not measured; the artifact states that reason.
- [x] [P0-T6] Capture the Black check, Ruff, and Pyright baselines for `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
  - Acceptance: three artifacts under `<FEATURE>/evidence/baseline/` (`black-baseline`, `ruff-baseline`, `pyright-baseline`, each `.<timestamp>.md`) record each exit code and the printed summary line.
- [x] [P0-T7] Capture the tier-classification baseline by running `scripts/dev_tools/check_quality_tiers.py` in module form.
  - Acceptance: `<FEATURE>/evidence/baseline/quality-tiers-baseline.<timestamp>.md` records exit 0 and the discovered-project count it prints.

### Phase 1 — Admission Core Module

- [x] [P1-T1] Create `.claude/lib/parallel-admission/ParallelAdmission.psm1` following the `ClaudeLibModuleConvention.Tests.ps1` conventions: the help block contains `imports its siblings with -ErrorAction Stop`, `Set-StrictMode -Version Latest` is followed by `$ErrorActionPreference = 'Stop'`, and every column-0 `Import-Module` carries `-ErrorAction Stop`. Add `Test-ParallelAdmissionRunOpen -ManifestMode -Checkpoint`. It returns open only when the manifest mode and the checkpoint `mode` are both `open` and no `mutations[].op` equals `close`. A missing or unreadable mode fails closed with a detail string. Add Describe `Test-ParallelAdmissionRunOpen` to `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1`, covering: manifest closed; checkpoint closed; a close mutation; disagreeing modes; a missing checkpoint mode; and open/open with no close.
  - Acceptance: that Describe passes with zero failures in the JUnit file.
- [x] [P1-T2] In `.claude/lib/parallel-admission/ParallelAdmission.psm1`, add `Get-ParallelAdmissionInferredStage -TreePath -FileText -CommitTime -SpecPlaceholderLine -PlanTemplateTaskLine -FeatureFolder`. It infers `none`, `research`, `spec`, `plan`, or `cleared` by the `spec.md` `## Data & State` stage-inference rules and the `## Design Summary` placeholder definitions. `cleared` requires an evidence file whose name contains `preflight` and whose text contains `PREFLIGHT: ALL CLEAR`, with a commit time at or after the plan's (D4). It returns the stage and the `research_path`, `spec_path`, and `plan_path` it found. Add a Describe with one case per row, plus: an empty research file; a template-placeholder spec; a placeholder-only plan; the greatest `plan.*.md` chosen; and preflight evidence older than the plan capped at `plan`.
  - Acceptance: that Describe passes with zero failures.
- [x] [P1-T3] In `.claude/lib/parallel-admission/ParallelAdmission.psm1`, add `Select-ParallelAdmissionReceipt -ReceiptPath` (returns the lexicographically greatest `preparation-receipt.*.json` path) and `Resolve-ParallelAdmissionStage -Receipt -InferredStage -CurrentPlanHash`. A receipt takes precedence over inference, and a receipt whose `plan_hash` differs from `-CurrentPlanHash` downgrades the stage to `plan`. Add a Describe covering: selection among three names; no receipt (inference used); a matching hash (receipt stage kept); and a mismatched hash (`plan`).
  - Acceptance: that Describe passes with zero failures.
- [x] [P1-T4] In `.claude/lib/parallel-admission/ParallelAdmission.psm1`, add `Get-ParallelAdmissionCitedPath -PlanText -DeclaredPath -FeatureFolder` and `Get-ParallelAdmissionStaleness -CitedPath -ChangedPath -PresentAtBase -PresentAtMain -BaseIsAncestor`. Cited paths are the `Get-PlanPaths` output plus the declared paths, minus `<FeatureFolder>/**`. A hit is an exact match or `Test-EntryOverlap`. The verdict is `premise_falsified` when a concrete cited path is present at the base and absent on main, `stale` when there are hits or the base is not an ancestor, and otherwise `fresh`. The result carries `changed_cited_paths` and `removed_cited_paths`. Add a Describe covering: no overlap gives `fresh`; a glob overlap gives `stale`; an exact match gives `stale`; a removed path gives `premise_falsified`; a non-ancestor base gives `stale`; a feature-folder change is ignored; and a path the plan creates (absent at the base) is not counted as removed.
  - Acceptance: that Describe passes with zero failures.
- [x] [P1-T5] In `.claude/lib/parallel-admission/ParallelAdmission.psm1`, add `Resolve-ParallelAdmissionBand -CallerBand -PlannerBand` and `Get-ParallelAdmissionDecision -Stage -Verdict -PreflightCleared`.
  - Band: `-CallerBand` gives source `caller`, else `-PlannerBand` gives `planner_checkpoint`, else value null with source `assessment`. A value outside C1 to C4 throws.
  - Decision: returns `resume_stage` and `next_action` per the `spec.md` verdict-to-action table. Only `cleared`+`fresh` yields `admit_prepared`. A never-cleared `plan` resumes at `preflight` even when fresh (D3). `none` yields `full_preparation`.
  - Add Describes for each band source and invalid input, and for every table row.
  - Acceptance: both Describes pass with zero failures.
- [x] [P1-T6] Verify the module: `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes and `ParallelAdmission.psm1` has at most 700 logical lines.
  - Acceptance: the convention suite has zero failures in the JUnit file, and the recorded line count is at most 700 (`<FEATURE>/evidence/other/module-size.<timestamp>.md`).

### Phase 2 — Precedence and Scheduling-Record Module

- [x] [P2-T1] Create `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` with the same conventions. Add `Test-ParallelPrecedenceInput -Entry -ItemKey`, which throws a message starting with `precedence_unknown_item` for an unresolved key and with `precedence_cycle` for a self-pair or a cycle. Add `ConvertTo-ParallelPrecedenceEdge`, which returns normalized `a:b` separating edges. Add Describes to `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` covering: an unknown key; a self-pair; a two-node cycle; a three-node cycle; an acyclic chain; and normalization.
  - Acceptance: those Describes pass with zero failures.
- [x] [P2-T2] In `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, add `Invoke-ParallelPrecedenceLift -Cohort -Edge -Precedence -Pinned -Floor`. It visits items in topological order (ties by ascending key) and moves an unstarted `after` item to the smallest index above every `before` index that no conflict neighbor holds. Pinned items never move, unstarted items move only upward, and the result keeps every cohort an independent set. Add a Describe covering: an already-satisfied table unchanged; a single lift; a lift past a conflict neighbor; a pinned `before` item; a pinned `after` item unchanged; a chain; independence preserved; and a second application changing nothing.
  - Acceptance: that Describe passes with zero failures.
- [x] [P2-T3] In `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, add `Get-ParallelActivePrecedence -Precedence -Item` and `Test-ParallelPrecedenceCohortTable -Checkpoint`.
  - An entry is inactive when its `before` item has `merge_status` `merged` or `worktree_removed`, or `state` `withdrawn`. A `blocked` predecessor holds (D6).
  - A combined item inherits the union of its members' entries (through `combined_issue_nums`), and a pair inside one combination is dropped.
  - The table check fails with `precedence_violated` when a current-generation cohort places an `after` item at or before an active `before` item.
  - Add Describes for each predecessor state, the combination rules, a satisfying table, and a violating table.
  - Acceptance: those Describes pass with zero failures.
- [x] [P2-T4] In `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, add `New-ParallelSchedulingRecord -Slug -Edge -ToleratedOverlap -Precedence -Item` and `Get-ParallelSchedulingRecordReuse -Record -IssueNum -CurrentPlanHash`.
  - The record carries exactly `schema_version`, `parallel_slug`, `edges`, `tolerated_overlaps`, `precedence`, and `items`, and each item carries `issue_num`, `branch_name`, `plan_path`, `plan_hash`, `base_commit`, `preparation_status`, and `complexity_band`.
  - Tolerated overlaps are projected to `a`, `b`, `reasons`, `cost`, and `benefit`.
  - Reuse returns the item's recorded edges only when its recorded `plan_hash` equals `-CurrentPlanHash`, and otherwise returns a recompute marker.
  - Add Describes for record keys, projection, deterministic key order, a reuse match, a hash mismatch, and an unknown item.
  - Acceptance: those Describes pass with zero failures.
- [x] [P2-T5] Verify `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` against `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and the 700-line advisory tier.
  - Acceptance: zero convention failures, and a line count of at most 700 is recorded in `module-size.<timestamp>.md`.

### Phase 3 — CLI Entry Script and Integration Fixtures

- [x] [P3-T1] Create `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`.
  - It has no `Mandatory` parameter, the three seams, the JSON conversion helpers, the outcome record, subcommand dispatch, and the guarded entry-point body.
  - Usage errors exit 2: an unknown or missing subcommand, a missing required option, a `-Band` outside C1 to C4, and an unrecognized `-` argument.
  - Add Describes `Parameter surface` and `Usage errors` to `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`. The suite dot-sources the script and mocks the seams.
  - Acceptance: both Describes pass with zero failures.
- [x] [P3-T2] In `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, implement `guard-run -CheckpointPath -ManifestMode` over `Test-ParallelAdmissionRunOpen`. An open run exits 0 with a JSON object; a closed or unknowable run exits 1 with stderr starting `PARALLEL_ADMISSION_REJECTED: run_closed:`. Add Describe `guard-run` with the guard matrix and an unreadable-checkpoint case (seam throws), which also exits 1.
  - Acceptance: that Describe passes with zero failures, and no case's output contains `PARALLEL_MUTATION_REJECTED`.
- [x] [P3-T3] Implement `assess -Branch -FeatureFolder -Receipt -Band -PlannerCheckpointPath -Main` (default `origin/main`).
  - All git reads are by ref through `Invoke-ParallelAdmissionGit`: fetch, `ls-tree -r --name-only`, `show`, `log -1 --format=%ct`, `merge-base`, `merge-base --is-ancestor`, `diff --name-only --no-renames`, `cat-file -e`, and `rev-parse <branch>:<plan_path>`.
  - It prints the `spec.md` `## API / CLI Surface` keys, with `plan_hash` equal to the mocked `rev-parse` output and `base_commit` taken from the receipt or else the merge base.
  - Add Describe `assess` covering: the JSON key set; hash recording; receipt-sourced base; merge-base fallback; each `next_action`; and a band source from the planner checkpoint (read seam).
  - Acceptance: that Describe passes with zero failures.
- [x] [P3-T4] In `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, implement `order-cohorts`, `test-cohorts -CheckpointPath`, and `record -RunFolder -Entry`.
  - The rejections exit 1 with stderr starting `PARALLEL_ADMISSION_REJECTED: precedence_cycle:`, `PARALLEL_ADMISSION_REJECTED: precedence_unknown_item:`, or `PARALLEL_ADMISSION_REJECTED: precedence_violated:`.
  - `record` prints content only, and the Pester case asserts that `Invoke-ParallelAdmissionGit` is invoked zero times.
  - Add one Describe per subcommand.
  - Acceptance: those Describes pass with zero failures.
- [x] [P3-T5] Create committed LF fixtures under `tests/fixtures/parallel_admission/` for slug `admission-seed`, items 1101 and 1102, with precedence 1102 after 1101 and no conflict edge:
  - `seed-parallel.md`: a manifest in the block-YAML subset.
  - `seed-planner-state.json`: ready under P6 to P10, with `preparation_status: prepared`, `plan_hash`, `base_commit`, `precedence`, and cohorts `[[1101],[1102]]`. `model_routing_receipt` values are taken from `Resolve-DelegationModel -Agent orchestrator -Band C2 -FablePolicy disabled`.
  - `seed-orchestrator-state.json`: invariants 1 to 19, with items carrying `preparation_status: cleared`, `plan_hash`, `base_commit`, and `band_source`, plus top-level `precedence`.
  - `seed-scheduling-record.json`.
  - `closed-orchestrator-state.json`: `mode: closed`.
  - Acceptance: the five files exist, hold no drive letter or backslash path, and are listed in `git status --porcelain`.
- [x] [P3-T6] Create `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` with three Describes. Each drives the CLI functions with in-memory branch trees behind a mocked `Invoke-ParallelAdmissionGit` and reads the committed fixtures as text.
  - `Seed from prepared items`: both items assess `cleared`+`fresh` with `admit_prepared`. `order-cohorts` output equals the fixture cohorts. `test-cohorts` exits 0 on `seed-orchestrator-state.json` and 1 on an in-memory swapped-cohort copy. `record` output equals `seed-scheduling-record.json`. A mocked `git show origin/parallel/admission-seed-plan:docs/features/parallel/admission-seed/parallel-scheduling.json` returning that record reuses the edges for a matching hash.
  - `Add a half-prepared item`: research and spec only gives `preparation_status` `spec`, `resume_stage` `plan`, and `next_action` `resume_preparation`.
  - `Add to a closed run`: `guard-run` on `closed-orchestrator-state.json` with `-ManifestMode closed` exits 1 with `PARALLEL_ADMISSION_REJECTED: run_closed:`.
  - Acceptance: the three Describes pass with zero failures.
- [x] [P3-T7] Verify `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`, and `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` against the 700-line advisory tier.
  - Acceptance: each recorded logical line count is at most 700 in `module-size.<timestamp>.md`.

### Phase 4 — Cohort Barrier Precedence (Layer 1)

- [x] [P4-T1] Edit `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`.
  - Add `Get-ParallelCohortBarrierPrecedencePredecessorList`, which returns each `before` key whose `after` equals the target, from a checkpoint `precedence` array.
  - Extend `Test-ParallelCohortBarrierClear` to return `$false` unless each predecessor record has `merge_status` in `$script:AllowedMergeStatuses` or `state` `withdrawn`, failing closed on a missing predecessor record. An absent `precedence` key leaves the decision unchanged.
  - Update the header helper list from five to six.
  - Add Context `precedence predecessors` to `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` with allow cases (merged, worktree_removed, withdrawn, no `precedence` key) and deny cases (`pr_open`, `ci_green`, `blocked_ci_loop_limit`, a missing predecessor record). Fixtures use forward-slash relative paths and in-memory LF JSON.
  - Asserting tests: every existing Context in that file, and the suites `enforce-parallel-cohort-barrier.Payload.Tests.ps1`, `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`, and `hook-dependency-failure.Claude.Tests.ps1`, are unchanged, because their checkpoints carry no `precedence` key. `test_parallel_cohort_barrier_parity.py` is unchanged because it exercises the Python Layer 2 corpus.
  - Acceptance: the new Context passes, and the four cohort-barrier suites report zero failures in the JUnit file.
- [x] [P4-T2] Verify the sizes of `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`.
  - Acceptance: `enforce-parallel-cohort-barrier-helpers.ps1` stays under 500 logical lines and `enforce-parallel-cohort-barrier.Tests.ps1` under 700, both recorded in `module-size.<timestamp>.md`.

### Phase 5 — Skill, Rule, Agent, Settings, and Pin Text

Text constraints for every task in this phase:
- The kickoff line `KICKOFF_LINE` stays byte-identical.
- The step boundaries `2. **Prepare the item.**` and `3. **Compute conflict edges` remain.
- Kickoff element count stays five.
- `parallel-orchestrate/SKILL.md` keeps sixteen `##` headings.
- No `depends_on:` text is added anywhere.
- The rejection-code table in `## Mutation Rejection Signal (issue #1012)` is unchanged.
- `parallel-plan/SKILL.md` gains no occurrence of the word `pinned` (any case) and no `python -m`.
- Parallel-add step 2 and kickoff element 4 gain no `docs/features/active/` path, no mode marker, and no hook issue-number shape.
- Every backticked span added to `parallel-orchestrate/SKILL.md` that contains a space and starts with a lowercase word is covered by a Bash grant in `.claude/agents/parallel-orchestrator.md`.

- [x] [P5-T1] Edit `.claude/rules/parallel-orchestration.md`.
  - Add `## Prepared-Item Admission (issue #1047)` between `## F3 Scope Boundary — kickoff contract deferred to F4` and `## Blast-Radius Contention Doctrine (issue #489)`. It declares:
    - the tolerated item fields `preparation_status` (`none|research|spec|plan|cleared`), `plan_hash`, `base_commit`, and `band_source`, and that the planner ready value `prepared` corresponds to `cleared` (D1);
    - the top-level `precedence[]` `{before, after, source, recorded_at}`, with `source` `operator` (D5), as a separating input that is not a `depends_on` key;
    - the receipt path and shape (D8), and the durable record `docs/features/parallel/<slug>/parallel-scheduling.json`;
    - the admission output signal `PARALLEL_ADMISSION_REJECTED` and its four codes, as a separate signal from the mutation rejection signal;
    - the D2 gap: the Python orchestrator-state validator does not check precedence.
  - Amend invariant 10's ordering sentence to name that section.
  - Asserting tests: `test_parallel_mutation_rejection_signal_contracts.py` and `validate-orchestrator-output.MutationRejection.Tests.ps1` are unchanged, because the scan is section-scoped and the section neighbors are unchanged. `test_parallel_complexity_routing_contracts.py::test_parallel_orchestration_rule_defines_p10`, `test_parallel_issue_combination_contracts.py` rule cases, and `test_epic_bounded_child_return_contract.py` are unchanged, because their fragments are kept.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T2] Edit `.claude/skills/parallel-add/SKILL.md` `## Prerequisites`, `## Constraints`, and `argument-hint`.
  - Add a bullet after the run-existence bullets that runs `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 guard-run`, with `-ManifestMode` taken from `validate-parallel-manifest.sh --print-mode`. On exit 1 it stops with the helper's stderr line, changes no state, and emits no mutation rejection signal.
  - Replace the `items[]` clause of the `## Constraints` "No field and no enum member" sentence with a statement that the only added item fields are the four tolerated fields declared in the new rule section. Keep `complexity_band` and `existing scheduling field`.
  - Add `[--after <earlier>] [--band <Cn>]` to `argument-hint`, and state in the `$ARGUMENTS` bullet that `--after` and `--band` flags are not items, so the multi-item rejection applies to positional items only (`spec.md` `## Inputs / Outputs`).
  - Asserting tests (all unchanged, fragments retained): `test_parallel_mutation_rejection_signal_contracts.py` (Prerequisites emits only `run_not_started`), `test_parallel_planner_surface_contracts.py::test_parallel_intake_requires_consolidation_before_execution`, and `test_parallel_complexity_routing_contracts.py::test_parallel_add_requires_complexity_assessment`.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T3] Edit `.claude/skills/parallel-add/SKILL.md` `## Procedure`.
  - Step 2 first runs `assess` for the item's pushed branch and feature folder.
    - `admit_prepared` skips the child and records `preparation_status`, `plan_hash`, `base_commit`, `complexity_band`, and `band_source`.
    - Otherwise step 2 delegates the unchanged `route_id: preparation` child on the item's pushed branch. It appends the resume line `Preparation resume: stage <stage>. Existing artifacts: <paths>. Do not repeat a completed stage; supersede with new timestamped files.`, with artifact paths relative to the feature folder. A stale item resumes at preflight with the overlapping paths as findings, under the single-pass rule of `.claude/skills/orchestrate/SKILL.md` `## Delegation Model`. A contract change found by that preflight resumes at `plan`. The band source order is `--band`, then the planner checkpoint, then `## Complexity Assessment`.
  - Step 3 records each `--after` pair as a top-level `precedence[]` entry `{before, after, source, recorded_at}` with `source` `operator` (AC-13), and adds the precedence pairs as separating edges.
  - Step 4 forces `defer_and_recolor` for a candidate with an active unmerged predecessor.
  - Step 5 runs `order-cohorts` and then `test-cohorts` before writing.
  - A new step 8 rewrites the scheduling record through `record` and commits it with a pathspec under `docs/features/parallel/`.
  - Asserting tests (unchanged, fragments retained): `test_parallel_issue_adoption_skill_contracts.py` step-2 cases, `test_parallel_complexity_routing_contracts.py` step-2 cases, and `test_parallel_issue_combination_contracts.py::test_parallel_add_reports_without_combining`.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T4] Edit `.claude/skills/parallel-plan/SKILL.md` intro, `## Item Intake`, and `## Preparation Fan-Out`.
  - Intro: amend "no operator-supplied ordering" to allow the optional `--after <later>:<earlier>` flags, keeping "The operator is never asked for ordering edges".
  - Item Intake: `assess` runs for every item, and fan-out takes only items whose `next_action` is not `admit_prepared`. `topology_receipt` is recorded as not applicable for admitted items.
  - Fan-Out: the waves cover only the incomplete items. A resumed item runs on its pushed branch, as `## Issue Combination` step 3 does. The resume line is quoted once as a blockquote after the issue-adoption line, with a `**Preparation-resume line.**` paragraph stating its properties. Add the receipt-write instruction line `Preparation receipt: before the commit, write <feature folder>/evidence/other/preparation-receipt.<yyyy-MM-ddTHH-mm>.json with schema_version, stage, research_path, spec_path, plan_path, plan_hash, base_commit, preflight_status, and recorded_at.` as its own blockquote line.
  - Add `[--after <later>:<earlier> ...]` to `argument-hint`.
  - Asserting tests (unchanged, fragments retained): `test_parallel_issue_adoption_skill_contracts.py` (kickoff line, one adoption line), `test_parallel_planner_surface_contracts.py` (kickoff-line extraction, `depends_on` prohibitions), and `test_parallel_planner_no_scratch_worktree_contracts.py` (fan-out, intake, and kickoff fragments, no `pinned`).
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T5] Edit `.claude/skills/parallel-plan/SKILL.md` `### Seeding procedure`, `### Recomputation parity (planner-owned check)`, `## Checkpoint Persistence`, and `## Kickoff Artifact`.
  - Seeding: precedence pairs are added as separating edges; `order-cohorts` runs with no pinning option (the skill text states this without the word `pinned` in any case, which `test_parallel_planner_no_scratch_worktree_contracts.py::test_skill_contains_no_pinned_word_and_no_forbidden_fragments` rejects); and the scheduling record is built with `record` and committed on `parallel/<slug>-plan`. A re-seed reads the record by ref and reuses an item's edges only on a matching `plan_hash`.
  - Recomputation parity: the step recomputes through `compute-cohorts.sh` plus `order-cohorts` and then runs `test-cohorts`, keeping "Planner invariant P5 in `.claude/rules/parallel-orchestration.md`" and "deliberately absent from the".
  - Checkpoint Persistence: the per-item list adds `plan_hash` and `base_commit`, the top level adds `precedence[]`, and the ordering sentence is amended without `depends_on:`. The readiness paragraph keeps `(P10)`.
  - Kickoff Artifact: prose after the template states that `## Integrity` rows carry each item's `assess` `plan_hash`. The fenced template is unchanged.
  - Asserting tests (unchanged): `test_parallel_kickoff_template_seam.py`, `test_parallel_planner_surface_contracts_landed.py`, `test_parallel_issue_combination_contracts.py` (section order), and `test_skill_bundle_contract_repo.py`.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T6] Edit `.claude/skills/parallel-orchestrate/SKILL.md`. No `##` heading is added.
  - Element 4 adds, inside its indented text, exactly this sentence (quoted here between double quotes; its inner backticks are literal): "The prompt also carries the item's admitted plan hash as `plan-hash: <hex>` and instructs the child, before any other step, to run `git rev-parse HEAD:<plan-path>` and to stop with `blocked_reason: premise_falsified` when the printed hash differs from `<hex>`."
  - `## Cohort Barrier and Max-Concurrency Slot Filling` adds a `**Precedence.**` paragraph: active predecessors must be `merged` or `worktree_removed`, `withdrawn` releases, `blocked` holds, Layer 1 enforces through `Test-ParallelCohortBarrierClear`, and Layer 2 does not check precedence.
  - `## Per-Item Merge to Main (Merge-on-Green)` step 2 adds the turn-gap paragraph. It reads the child checkpoint located by `git worktree list --porcelain`. When `step9_status` is not `passed` or `blocked_reason` is `awaiting_ci`, it says to "keep `merge_status: pr_open` and treat the item as not done", poll `gh pr checks` through the step 2 parser to a terminal conclusion, and "re-delegate the child once to resume at the CI green gate" by the `## Per-Item Merge-Conflict Handling` mechanism, counting toward `remediation_loop`. It records `ci_green` only after that run reports `passed`.
  - `## Parallel-Level Checkpoint` replaces the "one declared optional item field" sentence with the declared list `mergeable_conflicts_resolved`, `preparation_status`, `plan_hash`, `base_commit`, and `band_source`, plus top-level `precedence[]`.
  - Asserting tests (unchanged, fragments retained): `test_parallel_orchestrator_surface_contracts.py` heading and section cases, `test_parallel_orchestrator_permission_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py` element-4 and five-element cases, `enforce-parallel-drift-gate.Tests.ps1` marker binding, `test_ci_gate_all_checks_contracts.py`, `test_completion_gate_documentation_contracts.py`, and `test_orchestrator_state_remediation_docs.py`.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T7] Edit `.claude/agents/parallel-planner.md` and `.claude/agents/parallel-orchestrator.md`, adding the `tools:` entry `"Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)"` to each. Edit `.claude/settings.json`, adding the same allow entry.
  - Planner agent `## Checkpoint Persistence`: add `plan_hash`, `base_commit`, and `precedence[]`.
  - Orchestrator agent `## Checkpoint Persistence`: add the four item fields and `precedence[]`, and amend the "one declared optional item field" sentence to the declared list.
  - The planner `## Completion Requirements` keeps eight numbered items.
  - Asserting tests (unchanged): `test_parallel_planner_surface_contracts.py` frontmatter cases (no `docs/features/active` scope), `test_parallel_orchestrator_surface_contracts.py` (nine agent headings, one pr-author grant), `test_parallel_planner_no_scratch_worktree_contracts.py` item 8, `test_parallel_complexity_routing_contracts.py` agent cases, `validate-orchestrator-output-resolution.Tests.ps1` S2-6, and `parallel-orchestrate-run-closing.Tests.ps1`.
  - Acceptance: those tests pass in the P6-T6 run.
- [x] [P5-T8] Edit `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. Add the `KICKOFF_PLAN_HASH_FRAGMENTS` tuple (`` `plan-hash: <hex>` ``, `` before any other step, to run `git rev-parse HEAD:<plan-path>` ``, and `` `blocked_reason: premise_falsified` ``) and the `MERGE_ON_GREEN_TURN_GAP_FRAGMENTS` tuple (`` keep `merge_status: pr_open` and treat the item as not done ``, `re-delegate the child once to resume at the CI green gate`, `` `step9_status` ``, and `` `awaiting_ci` ``). Add the cases `kickoff-plan-hash-verification` (heading `KICKOFF_HEADING`) and `merge-on-green-turn-gap-redelegation` (heading `MERGE_ON_GREEN_HEADING`) to `SECTION_OBLIGATION_CASES`.
  - Asserting test: `test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_section_states_its_required_obligations` is updated and gains two parametrized cases; all other consumers of the module are unchanged.
  - Acceptance: the two new node IDs pass in the P6-T6 run.

### Phase 6 — Mirrors, Manifests, Classification, and Contract Runs

- [x] [P6-T1] Add `.claude/lib/parallel-admission/ParallelAdmission.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, and `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` once each to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths`, after the `parallel-drift` entries.
  - Acceptance: each path occurs exactly once in `paths`.
- [x] [P6-T2] Create byte-equal bundle copies of the three lib files under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/`.
  - Acceptance: the SHA256 of each copy equals its primary, recorded in `<FEATURE>/evidence/other/mirror-hashes.<timestamp>.md`.
- [x] [P6-T3] Copy the final text of every edited `.claude` file to its bundle path under `extensions/drm-copilot/resources/claude-customizations/`. The files are the three skills, the rule, the two agents, `.claude/settings.json`, and `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`.
  - Acceptance: every pair's SHA256 matches in `mirror-hashes.<timestamp>.md`.
- [x] [P6-T4] Create `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1`, modeled on `ParallelDrift.Manifest.Tests.ps1`: disk discovery, core.json membership, entry script listed once, bundle counterpart present, and byte identity.
  - Acceptance: the suite passes with zero failures.
- [x] [P6-T5] Add `.claude/lib/parallel-admission` with tier `T3` and the rationale "Runtime library shipped in the `.claude` bundle" to `quality-tiers.yml`, after `.claude/lib/parallel-drift`. Run `scripts/dev_tools/check_quality_tiers.py` in module form. Precondition: the three `.claude/lib/parallel-admission/` files are in the git index (staged with a pathspec or committed), because project discovery reads `git ls-files` and an untracked directory leaves the new entry stale (QT007).
  - Asserting tests (unchanged): `test_quality_tiers_contract_classification.py`, which checks a subset and restricts T1 and T2 only.
  - Acceptance: exit 0, with the discovered-project count one above the P0-T7 baseline, recorded in `<FEATURE>/evidence/other/quality-tiers.<timestamp>.md`.
- [x] [P6-T6] Run the `## Contract Test Set` under `tests/scripts/dev_tools/` serially with `--strict-markers`.
  - Acceptance: zero failures, with the counts recorded in `<FEATURE>/evidence/qa-gates/pytest-contracts.<timestamp>.md`.

### Phase 7 — Integration Scenario Evidence

- [ ] [P7-T1] Record the seed scenario. Inputs: the `Seed from prepared items` Describe counts, and the branch-current exit codes of `validate-parallel-manifest.sh` on `tests/fixtures/parallel_admission/seed-parallel.md`, `scripts/dev_tools/validate_orchestration_artifacts.py` `parallel-planner-state --require-ready-for-execution` on `seed-planner-state.json`, and `parallel-orchestrator-state` on `seed-orchestrator-state.json`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/integration-seed.<timestamp>.md` records zero Describe failures and exit 0 for each validator, and is marked as local evidence with no network or GitHub mutation.
- [ ] [P7-T2] Record the half-prepared scenario from the `Add a half-prepared item` Describe of `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1`.
  - Acceptance: `integration-half-prepared.<timestamp>.md` under `evidence/regression-testing/` records zero failures and the asserted `resume_stage`.
- [ ] [P7-T3] Record the closed-run scenario from the `Add to a closed run` Describe of `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1`.
  - Acceptance: `integration-closed-run.<timestamp>.md` under `evidence/regression-testing/` records zero failures and the asserted stderr prefix `PARALLEL_ADMISSION_REJECTED: run_closed:`.

### Phase 8 — Final QA Loop and Self-Review

Restart at P8-T1 whenever a task fails or changes a file.

- [ ] [P8-T1] Format every new or edited `.ps1` and `.psm1` file (the three under `.claude/lib/parallel-admission/`, `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`, and the new and edited test files) with `Invoke-Formatter` and the PoshQC settings.
  - Acceptance: a before-and-after SHA256 comparison shows no file changed, recorded in `<FEATURE>/evidence/qa-gates/poshqc-format.<timestamp>.md`.
- [ ] [P8-T2] Run `Invoke-ScriptAnalyzer` directly with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the same files.
  - Acceptance: zero findings, recorded in `poshqc-analyze.<timestamp>.md` under `evidence/qa-gates/`.
- [ ] [P8-T3] Run a branch-current `Invoke-PoshQCTest` over `tests/scripts/claude-lib/parallel-admission`, the four cohort-barrier suites, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: zero failures in the JUnit file. Line coverage of at least 85% for `ParallelAdmission.psm1`, `ParallelAdmissionPrecedence.psm1`, and `Invoke-ParallelAdmission.ps1`, and coverage of the helpers file at or above its P0-T3 baseline, all read from the coverage XML and recorded in `pester-coverage.<timestamp>.md` under `evidence/qa-gates/`.
- [ ] [P8-T4] Write the coverage comparison for `.claude/lib/parallel-admission/` and `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists baseline, post-change, and new-file figures, and states the outcome as remediation-required if any value is missing or below threshold.
- [ ] [P8-T5] Run the Black check on `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
  - Acceptance: exit 0, and the printed line contains `would be left unchanged` (`black-final.<timestamp>.md` under `evidence/qa-gates/`).
- [ ] [P8-T6] Run Ruff on `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
  - Acceptance: exit 0 with `All checks passed!` (`ruff-final.<timestamp>.md`).
- [ ] [P8-T7] Run Pyright on `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
  - Acceptance: exit 0 with `0 errors` (`pyright-final.<timestamp>.md`).
- [ ] [P8-T8] Run `-n auto` over the `## Contract Test Set` under `tests/scripts/dev_tools/` with `--strict-markers`.
  - Acceptance: zero failures (`<FEATURE>/evidence/regression-testing/pytest-n-auto.<timestamp>.md`).
- [ ] [P8-T9] Run the node IDs of `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, the only test module whose pins changed, in reversed order in one process.
  - Acceptance: zero failures, with the reversed node order recorded (`python-reversed.<timestamp>.md` under `evidence/regression-testing/`).
- [ ] [P8-T10] Run the touched Pester files in one process in a seeded shuffled file order, with seeds 11, 23, and 47. The touched files are the five suites under `tests/scripts/claude-lib/parallel-admission/` and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`.
  - Acceptance: zero failures per seed, with each seed and file order recorded (`pester-shuffle.<timestamp>.md` under `evidence/regression-testing/`).
- [ ] [P8-T11] Run the concurrent-shard Pester run through `Invoke-PoshQCParallelTest` over `tests/scripts`.
  - Acceptance: zero failures (`pester-parallel-shards.<timestamp>.md` under `evidence/regression-testing/`).
- [ ] [P8-T12] Run a fresh single-process Pester run over `tests/scripts`, which is the CI shape.
  - Acceptance: zero failures in the JUnit file (`pester-full.<timestamp>.md` under `evidence/regression-testing/`).
- [ ] [P8-T13] Record the scope and gate-intent evidence for `.claude/lib/bash/`, `tests/shell/`, and every changed path: the merge-base `git diff --name-only --no-renames` plus `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/scope-diff.<timestamp>.md` shows:
    - no `.ts` path and no added `.py` path;
    - exactly one modified `.py` path, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`;
    - no path under `.claude/lib/bash/`, `tests/shell/`, or `.claude/skills/orchestrate/`.
  - It records `test_parallel_mutation_run_bash_parity.py` passing in the P6-T6 run, and lists the bats parity and Linux hook-suite results as CI-dependent items checked at S9 (`shell-coverage / Shell Coverage (Bats + kcov)`, `poshqc / PowerShell hook suites (Linux)`).
- [ ] [P8-T14] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the merge-base branch diff.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` holds one PASS, FAIL, or N/A row per checklist item and no FAIL row. A FAIL is fixed, the loop restarts at P8-T1, and the self-review is rewritten.

## Contract Test Set

`tests/scripts/dev_tools/`:

- Parallel surface contracts: `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_orchestrator_permission_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py`, `test_parallel_complexity_routing_contracts.py`, `test_parallel_planner_surface_contracts.py`, `test_parallel_planner_surface_contracts_landed.py`, `test_parallel_planner_no_scratch_worktree_contracts.py`, `test_parallel_mutation_rejection_signal_contracts.py`, `test_parallel_issue_combination_contracts.py`, `test_parallel_kickoff_template_seam.py`.
- Parity: `test_parallel_mutation_run_bash_parity.py`, `test_parallel_cohort_barrier_parity.py`.
- Bundle and documentation contracts: `test_skill_bundle_contract_repo.py`, `test_orchestrator_state_remediation_docs.py`, `test_ci_gate_all_checks_contracts.py`, `test_completion_gate_documentation_contracts.py`, `test_epic_bounded_child_return_contract.py`, `test_claude_rules_frontmatter.py`.
- Push-down contracts: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_customizations.py`.
- Tier classification: `test_quality_tiers_contract_classification.py`.

## AC Traceability

| AC | Implementation | Tests | Evidence |
| --- | --- | --- | --- |
| AC-01 Language | P1-T1, P2-T1, P3-T1 | P8-T13 diff | `scope-diff` |
| AC-02 Stage record | P1-T2, P5-T1, P5-T3 | P1-T2 Describe, P7-T1 validators | `integration-seed` |
| AC-03 Receipt | P1-T3, P5-T4 | P1-T3 Describe, adoption contract | `pytest-contracts` |
| AC-04 Inference | P1-T2 | P1-T2 Describe | `pester-coverage` |
| AC-05 Resume | P1-T5, P5-T3, P5-T4 | P1-T5, P3-T6 half-prepared | `integration-half-prepared` |
| AC-06 Fresh skip | P1-T4, P1-T5 | P1-T4, P3-T6 seed | `integration-seed` |
| AC-07 Stale path | P1-T5, P5-T3 | P1-T5 table cases | `pester-coverage` |
| AC-08 Premise falsified | P1-T4, P5-T3 | P1-T4 removed/non-ancestor | `pester-coverage` |
| AC-09 Plan hash | P3-T3, P5-T5, P5-T6, P5-T8 | P3-T3, surface pin | `pytest-contracts` |
| AC-10 Closed-run guard | P1-T1, P3-T2, P5-T2 | P3-T2, P3-T6 closed run | `integration-closed-run` |
| AC-11 Shared intake and seeding | P5-T3, P5-T4, P3-T5 | P3-T6 seed, P7-T1 validators | `integration-seed` |
| AC-12 Band | P1-T5, P3-T3 | P1-T5 band Describe, routing contract | `pester-coverage` |
| AC-13 Precedence input | P2-T1, P2-T2, P5-T3 | P2-T1, P2-T2, planner contract | `pester-coverage` |
| AC-14 Precedence rejection and barrier | P2-T3, P3-T4, P4-T1 | P2-T3, P4-T1, Linux hook job at S9 | `pester-coverage` |
| AC-15 Durable edges | P2-T4, P5-T3, P5-T5 | P2-T4, P3-T6 re-seed | `integration-seed` |
| AC-16 Turn gap | P5-T6, P5-T8 | surface pin | `pytest-contracts` |
| AC-17 Declared fields and permissions | P5-T2, P5-T6, P5-T7 | permission, planner, and frontmatter contracts | `pytest-contracts` |
| AC-18 Mirrors | P6-T1 to P6-T4 | push-down contracts, Manifest suite | `mirror-hashes` |
| AC-19 Coverage | P1 to P3 seams | P8-T3 | `pester-coverage`, `coverage-delta` |
| AC-20 Order independence | all suites | P8-T8 to P8-T12 | `pester-shuffle`, `pytest-n-auto`, `python-reversed` |
| AC-21 Gate intent | P5-T2 to P5-T6 | bash parity, bats at S9 | `scope-diff`, `self-review` |

User-story criteria map to spec criteria:

| User-story criterion | Spec criteria |
| --- | --- |
| Admit without repeating a stage | AC-02, AC-05 |
| Fresh admission | AC-06 |
| Changed cited files | AC-07, AC-08 |
| Receipt and hash | AC-03, AC-09 |
| Closed run | AC-10 |
| Seeding | AC-11 |
| Band | AC-12 |
| Precedence | AC-13, AC-14 |
| Durable edges | AC-15 |
| Turn gap | AC-16 |
| Language and mirrors | AC-01, AC-18 |

## Pre-Mortem

- Review checklists: A reviewer could flag the new item fields against the "No field" sentences of parallel-add `## Constraints`, the parallel-orchestrate `## Parallel-Level Checkpoint`, and the orchestrator agent. P5-T2, P5-T6, and P5-T7 amend all three, and P5-T1 declares the fields. The System.Text.Json helpers repeat the drift-script precedent, because `.claude/lib` holds no shared JSON module and editing `parallel-drift` is out of scope; the self-review records this. The rule edit is spec-mandated schema text, not a policy-order file.
- Coverage: All git, file, and clock access sits in the three seams, so the pure modules are fully reachable under mocks. P8-T3 reads per-file line coverage (at least 85%) from the coverage XML, and P8-T4 compares the helpers file against its P0-T3 baseline. The guarded entry body is the only expected uncovered region.
- Mirror parity: P6-T1 to P6-T4 cover core.json, the eight edited bundle copies, the three new copies, and the Manifest suite. The P6-T6 run covers the resource, completeness, dependency-closure, and frontmatter contracts. There are no `.agents`, `.codex`, or `.github` twins: `test_push_down_codex_and_agents_customizations.py` asserts their absence. Execution-environment brief: re-checked against this task list. No CI job, required context, tool route of `atomic-executor`, `atomic-planner`, `task-researcher`, or `orchestrator`, hook named in the brief, or batch-budget rule changes. The new grants belong to `parallel-planner` and `parallel-orchestrator`, which the brief does not describe, so no brief-update task is needed.
- File size: The precedence logic is split into its own module. P1-T6, P2-T5, P3-T7, and P4-T2 record line counts against the 500- and 700-line tiers. `ClaudeLibModuleConvention.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1` (P8-T3) enforce the 800-line hard limit.
- Test isolation: Suites import modules with `-Force` in `BeforeAll`, remove them in `AfterAll`, scope mocks with `-ModuleName`, and create no temporary files. The isolation runs are:
  - P8-T10: a seeded shuffled file-order Pester run with seeds 11, 23, and 47, each seed and its file order recorded;
  - P8-T9: a reversed-order run of the changed Python test module `test_parallel_orchestrator_surface_contracts.py`;
  - P8-T11: a concurrent-shard run through `Invoke-PoshQCParallelTest`;
  - P8-T8: a `pytest -n auto` run;
  - P8-T12: a fresh single-process run over `tests/scripts`.
  - A seeded shuffled Jest run is not applicable, because no TypeScript changes.
- CI-only behavior: The hook suite also runs in `poshqc / PowerShell hook suites (Linux)`, so its fixtures use `Join-Path`, forward-slash relative paths, exact file-name case, and in-memory LF text. Committed fixtures avoid drive letters. No test reads gitignored `artifacts/` state or diffs against `origin/main`, and no bats file changes.
- Evidence: Every artifact uses `<FEATURE>/evidence/<kind>/` with write-time UTC stamps and the four required fields. Counts come from the JUnit file and coverage from the XML, never from MCP results. No artifact records a host path. Integration evidence is local and performs no network or GitHub mutation. The bats and Linux hook-suite results are recorded as CI-dependent items for S9.

## Size Justification

- The plan has 58 tasks, which is above the 40-task guideline (it stays under 400 lines), because spec decision D7 delivers one item: three new PowerShell production files, a hook change, three skills, a rule, two agents, settings, eleven bundle copies, a tier entry, fixtures, three integration scenarios, and a full QA loop with five isolation runs.
- Splitting would break D7, and merging tasks would join outcomes that fail independently.

## Open Questions / Notes

- AC-01 states that the change edits no existing `.py` file, while AC-09 and AC-16 require fragment pins in `test_parallel_orchestrator_surface_contracts.py`, whose pins live in `parallel_orchestrator_surface_expectations.py`. This plan applies the delegation rule that permits pin edits to existing contract tests. AC-01 is verified as no production `.py` or `.ts` change, with that test-support module as the only `.py` path (P8-T13).
- The resume-line artifact paths are written relative to the feature folder, so the preparation prompt carries no active feature-folder path, consistent with the issue-adoption line properties.
- Q14 remains non-blocking per `spec.md`.
