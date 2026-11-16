# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix - Plan B (Owner Decisions)

- **Issue:** #1025
- **Parent (optional):** epic #1018, child 1
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15 (scope change S2, spec decision D-R7: `test-execution-policy` joins plan A batch B)
- **Status:** Draft
- **Version:** 2.2 (S2 review against plan A 3.1: no plan B figure, task identifier or citation depends on the skill-set counts or batch sizes, because plan B derives its contract set from the matrix and its survey edits from the plan A records; plan A `## Acceptance Criteria Traceability` cites the current plan B task identifiers). 2.1 (spec 0.6 D-R4 and D-R5 in rules 1, 3 and 9; P1-T3 counters for rules 4 to 8 and `dropped` overrides). 2.0 (refresh: plan A 3.0 task identifiers, spec 0.5 D-R2 parallel-only gates and leak scan, Pester 6, Test Cadence and phase gate, write-time evidence stamps, deferral rows and autonomous approval, consolidated tasks). 1.3 (H2), 1.2 and 1.1 (H1) precede it.
- **Work Mode:** full-feature
- **Requirements sources:** `spec.md` (`## Acceptance Criteria`, `## Owner Stop`), `user-story.md`, `plan.2026-10-30T17-06.md` (plan A: `## Gate Shape`, `## Matrix Bootstrap Rules`, `## Owner Stop (Orchestrator-Owned, After Plan A)`, `## Acceptance Criteria Traceability`)
- **Delegation:** the orchestrator delegates this plan only after plan A is complete and the resume conditions R1 to R4 of plan A `## Owner Stop (Orchestrator-Owned, After Plan A)` hold. Plan A remains the canonical plan path.

## Required References

- Policy order: `policy-compliance-order` skill; PowerShell rules in `.claude/rules/powershell.md` (Pester 6.x).
- Tool routes, launchers, PoshQC MCP limits, CI shape and contract tests: the `execution-environment` skill; this plan does not restate them. Counts and coverage are read from files, never from an MCP result.
- Cadence and gates: `atomic-plan-contract` `## Test Cadence (Mandatory)`. Evidence naming: `evidence-and-timestamp-conventions`; every evidence file is `<name>.<timestamp>.md` stamped with the UTC write time read from the clock, a consumer selects the lexicographically greatest `<name>.*.md`, and evidence is append-only (a re-run writes a new file).

## Definitions

- `<FEATURE>` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`.
- `SCRATCH` is `<session scratchpad>/issue-1025/`. Helper scripts live under it with names starting `issue-1025-`, are throwaway PowerShell, are never committed, and are re-written in this session when absent. Evidence records the token `SCRATCH`, never a host path.
- `MB` is the merge base of `origin/main` and `HEAD`, derived after fetching `origin/main` when the task runs.
- `Approval`: `<FEATURE>/survey/difference-approval.md` as completed at the owner stop, either by the owner or, in autonomous mode, by the executing orchestrator's decision record. Plan B reads both the same way and does not judge origin; R1 is orchestrator-owned.
- Deferral row: an `Approval` `## Owner Overrides` row whose first cell names a runbook (`E1`, `E2`, `E3`, `E4`, `E6` or the runbook file name) and whose decision begins `deferred`. A deferral row is not a feature-id row.
- `Result(Ex)`: the latest `<FEATURE>/evidence/other/<runbook id>-result.*.md` for runbook `Ex`; `Ex` is deferred when `Approval` has a deferral row for it and no result exists.
- `BranchBaseline`: the path set in the latest `<FEATURE>/evidence/baseline/phase0b-branch-snapshot.*.md`, written by Y3.
- `PlanBStart`: the commit recorded under `PlanBStart:` in that artifact (the `git rev-parse HEAD` output at Y3). It is an evidence value only; the plan never quotes it.

## Edit Set (complete)

- Edit: `config/harness-parity-matrix.json`.
- Create or delete: `.agents/skills/<name>/references/standard.md` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`, only for names listed in the P1-T4 artifact; revise only the reviewed names listed there.
- Edit: `<FEATURE>/survey/skill-survey.md`, `<FEATURE>/survey/batch-*.md`, `<FEATURE>/survey/single-ecosystem.md`. New: `<FEATURE>/evidence/**`.
- Check-off edits only: this plan file, `<FEATURE>/spec.md`, `<FEATURE>/user-story.md`.
- Not edited but already changed on the branch: every path in `BranchBaseline`.

## Excluded Paths (must never be edited)

- Every path in plan A `## Excluded Paths` (including every `SKILL.md`, pack manifest, the execution-environment brief copies, the process-reduction ledger and `artifacts/orchestration/orchestrator-state.json`; no task writes the checkpoint).
- `quality-tiers.yml`, `scripts/harness/**`, `tests/scripts/harness/**`, `config/harness-parity-matrix.schema.json`, `<FEATURE>/runbooks/**`, `<FEATURE>/survey/difference-approval.md` and `plan.2026-10-30T17-06.md`. A defect found in a module, test or schema is a re-planning stop, not a plan B edit.

## Language Classification

Owner rule (H1): no new Python; PowerShell is the baseline; TypeScript only for MCP tools and extension commands. No artifact uses the E2 exception. OWNER QUESTION: none.

| Artifact | Language | Where it runs | Permitting clause |
| --- | --- | --- | --- |
| `config/harness-parity-matrix.json` (edit) | JSON data | read by the Pester gate and by children 3 to 6 | data |
| contracts and bundle copies (create, revise, delete); survey and evidence files | Markdown | bundle payload (no manifest entry) or repo-only | documentation |
| `SCRATCH/issue-1025-matrix-decisions.ps1`, `SCRATCH/issue-1025-matrix-results.ps1`, `SCRATCH/issue-1025-contracts-post-decision.ps1`, `SCRATCH/issue-1025-diff-reconcile.ps1` and their `sh` launchers | PowerShell 7, POSIX `sh` | session only, never committed | PowerShell baseline |
| `scripts/harness/*.psm1`, `tests/scripts/harness/*.Tests.ps1` (run only) | PowerShell 7, Pester 6 | repo-only CI and local gates | classified in plan A |
| existing Python contract set of plan A `## Gate Shape`, generator `--check`, tier check (run only) | Python (existing) | repo-only CI and local | called, not edited |

No production PowerShell file is created or edited, so the batch budget is not consumed.

## Gate Shape

- Task check (after every task, not a gate): as plan A `## Gate Shape`. A matrix edit selects `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; a contract or bundle-copy change selects the Python contract set of plan A `## Gate Shape` and the three sweep suites named there (`parallel-gate-wording`, `test-cadence-wording`, `policy-toolchain-naming`). Evidence `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`.
- Phase gate and final loop: stages and pass condition of plan A `## Gate Shape`, compared with plan B's baselines `pwsh-format-baseline-b`, `pssa-baseline-b` and `pester-baseline-b` (no test fails that did not fail in `pester-baseline-b`, compared per test file; no PSSA finding beyond `pssa-baseline-b`; every contract command exits 0). Coverage source: plan A `## Gate Shape` coverage-source rule, recorded per artifact.
- Test isolation (D-R2): the unit stage is one `Invoke-PoshQCParallelTest` run; `Invoke-PoshQCLeakScan` runs at P0-T2 and P2-T2. No serial, single-process, shuffled or reversed run is a gate; integration and golden suites run in CI only.

## Executor Entry Checks (Before [P0-T1])

The executor runs Y1 to Y3 before checking any task. If any fails, it checks no task and returns `BLOCKED at preflight (before [P0-T1])` naming each failing row.

- Y1: the latest `pre-stop-readiness.*.md` reads `PreStop: READY`; the latest `owner-stop.*.md` lists six requirements, one `halt` and five `exception` entries with non-empty `runbook_path`; the latest `resume-check.*.md` reads `Resume: READY`; `git merge-base --is-ancestor origin/main HEAD` exits 0; plan A has no unchecked task; `git status --porcelain` lists no path in `## Excluded Paths`. Artifact `<FEATURE>/evidence/baseline/phase0b-preconditions.<timestamp>.md` ending `Preconditions: PASS`.
- Y2: re-derive every entry of `## Citations Re-Checked at Phase 0` against `HEAD` (tracked path; each symbol, heading or test name has a fixed-string match, a hyphen-leading pattern passed through `-e`; a `file presence` entry by tracking alone). Artifact `<FEATURE>/evidence/baseline/phase0b-citations.<timestamp>.md` ending `Citations: PASS` only when every row is `PRESENT`.
- Y3: the sorted, de-duplicated union of `git diff --name-only MB...HEAD` and the paths of `git status --porcelain`, and the output of `git rev-parse HEAD`. Artifact `<FEATURE>/evidence/baseline/phase0b-branch-snapshot.<timestamp>.md` with the three commands, `BranchBaseline:` and a line beginning `PlanBStart:`.

## Decision Application Rules

Applied by P1-T2 and P1-T3 in this order; values not named stay as plan A wrote them. Rules 4 to 8 apply only to a runbook with `Result(Ex)`; a deferred runbook changes no value, and its dependent entries stay `provisional` with `decision_ref` naming the runbook (rule 9, spec `## Owner Stop`), except an entry overridden to `dropped` (D-R4) and an overridden `copilot:agent:*` entry under a deferred E3 (H2), which rule 9 does not hold back for that runbook.

Terms used by rules 4 to 9 and by the P1-T3 counters: `PlanAMatrix` is `config/harness-parity-matrix.json` at the `PlanBStart` commit, read with `git show` (plan A's matrix, committed before the owner stop). An entry's runbook is the runbook whose path its `PlanAMatrix` `decision_ref` names, as plan A `## Matrix Bootstrap Rules` assigns it; an entry with no runbook path there has no runbook. A result value is the text after `<field>:` on the first line of `Result(Ex)` that begins with that field label, trimmed; `yes` is compared ordinally. An absent field equals only an absent field.

0. Identifiers: every `id` in these rules, in `Approval` `## Disposition Proposals` and `## Owner Overrides`, and in the scratch scripts is the encoded form of spec `### Parity Matrix: Identifier Encoding`. A rule selects entries by an exact `id` copied from `config/harness-parity-matrix.json`, by the fields `ecosystem`, `kind` and `name` (written `<ecosystem>:<kind>:*`), or by the runbook path in the `PlanAMatrix` `decision_ref` (rules 4, 7 and 9); it never decodes, re-encodes or re-derives an `id`, and never matches a substring of an `id` beyond the `<ecosystem>:<kind>:` prefix. A feature-id row that names no exact matrix `id` counts in `UnmatchedApprovalIds`; Diff ID rows and deferral rows are not counted; a non-zero count stops P1-T2 for re-planning.
1. Approved disposition: for an entry or skill listed in `## Disposition Proposals` or a feature-id row of `## Owner Overrides`, the decision in `Approval` (an empty answer accepts the proposal); for every other entry, the plan A disposition (approved in bulk by `Approval-Status`). An entry selected by a feature-id override row is an overridden entry. Precedence (H2): the decision on an overridden entry takes precedence over every later rule that sets a disposition, including the E3 result in rule 6; no later rule changes the `disposition`, `reason`, `target_paths` or `generated_from` that rules 1 to 3 gave it, no rule from 4 to 8 changes its `decision_status` or `decision_ref`, and rule 9 sets them (keeping the rule 3 `decision_ref` of a `dropped` override). The `consumers` and `notes` changes of rules 4 to 8 still apply to it.
2. Single-ecosystem skill approved `shared`: Claude-only `claude:skill:<name>` gets `shared`, `target_paths` `[.agents/skills/<name>/SKILL.md]`, `owner_child` 3 and no contract (plan A F2); Codex-only `codex:skill:<name>` gets `shared`, `target_paths` `[.claude/skills/<name>/SKILL.md]`, `owner_child` 3, and a contract in P1-T4. Approved `native`: unchanged. The `proposed:` note becomes `approved: <disposition>`.
3. Override to `dropped`: `reason` is the trimmed override note, or `Retired by owner override recorded in survey/difference-approval.md` when the note is empty after trimming (D-R5); `decision_ref` `#1025:survey/difference-approval.md#owner-overrides`, `target_paths` and `generated_from` removed. Override to `native` (H2): `target_paths` and `generated_from` removed (spec `### Disposition Semantics`), so the entry never carries a `pending-source:<kind>` placeholder; `reason` becomes the override note, or is removed when the note is empty; `decision_ref` is left for rule 9.
3a. Override without a derivation rule: an override row that sets `generated` on any entry, or `shared` on an entry other than those of rule 2, counts in `OverridesWithoutRule` when its value differs from the plan A disposition. Overrides to `native` or `dropped` are never counted. P1-T2 computes the count before writing; a non-zero count stops P1-T2 for re-planning with the matrix unchanged.
4. E1 recorded: entries whose runbook is E1 (selected through `PlanAMatrix`, so an entry rule 3 overrode to `dropped` is still selected) get `notes` `E1: VSCode-Entries <n>, CLI-Entries <n>`.
5. E2 recorded: `skill-frontmatter-field` entries get `notes` `E2: Codex-Lists-Skill <value>, Codex-Warning-Fields <value>`.
6. E3 recorded: when `CLI-Lists-Claude-Agent` and `Cloud-Lists-Claude-Agent` are both `yes`, every `copilot:agent:*` entry that is not overridden becomes `dropped` with `reason` `E3 result: the Copilot CLI and cloud agent read .claude/agents`, `decision_ref` `#1025:evidence/other/<Result(E3) file name>`, and no `target_paths` or `generated_from`; otherwise it keeps its plan A fields (spec `### Owner Approval Artifact` lists no `copilot:agent:*` entry in `## Disposition Proposals`, so rules 1 to 3 leave a non-overridden one as plan A wrote it). An overridden `copilot:agent:*` entry keeps the fields from rules 1 to 3 whatever the E3 result (H2). `claude:agent:*` `consumers` gain `copilot-cli` when `CLI-Lists-Claude-Agent` is `yes` and `copilot-cloud` when `Cloud-Lists-Claude-Agent` is `yes`.
7. E4 recorded: entries whose runbook is E4 get `notes` `E4: Workspace-Settings-Honored <value>`.
8. E6 recorded: `claude:path-scoped-rule:*` `consumers` include `copilot-vscode` only when `VSCode-References-Both-Rules` is `yes`; `claude:instructions:CLAUDE.md` `consumers` include `copilot-cli` only when `CLI-Lists-CLAUDE-md` is `yes`.
9. Settlement: an entry is settled when rule 1 gave it an approved disposition, its runbook (if any) has `Result(Ex)`, and its `generated_from` does not begin `pending-source:`. Exceptions to the runbook condition: for an overridden `copilot:agent:*` entry the E3 runbook is not a condition (H2); an entry overridden to `dropped` has no runbook condition and no `generated_from`, so it is always settled (D-R4); an entry overridden to `native` has no `generated_from`, so it stays `provisional` only when its runbook is deferred and is not E3. A settled entry gets `decision_status` `approved` and loses `decision_ref` unless `dropped`; a settled `dropped` entry keeps its current `decision_ref` (for an override, `#1025:survey/difference-approval.md#owner-overrides` from rule 3). An unsettled entry stays `provisional`: with a deferred runbook its `decision_ref` stays the runbook path; with `pending-source:` and a recorded result it becomes `#1025:evidence/other/<Result(Ex) file name>`; otherwise it is unchanged.

### Phase 0 — Resume Record and Baselines

- [x] [P0-T1] Write `<FEATURE>/evidence/baseline/phase0b-resume.<timestamp>.md` from the latest `owner-stop.*.md`, `resume-check.*.md`, `phase0b-preconditions.*.md`, `phase0b-citations.*.md` and `<FEATURE>/survey/difference-approval.md`: the stop's `blocked_reason`, its six requirements, the approval fields as written, the count of disputed cases with a non-empty `Owner-Decision`, the Q1 to Q8 answers or accepted defaults, and for each of E1, E2, E3, E4 and E6 either the `Result(Ex)` file name or `deferred`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0b-resume.<timestamp>.md` records `blocked_reason: human_decision_required`, six requirements with five non-empty `runbook_path` values, `Approval-Status` `approved` or `approved-with-overrides`, disputed cases decided equal to disputed cases listed, eight question rows and five runbook rows, and ends `ResumeGate: PASS`.
- [x] [P0-T2] Capture the `Phase 0 baseline` of the Pester gate over `tests/scripts`: one parallel Pester gate run with coverage (`## Gate Shape` coverage source) and one `Invoke-PoshQCLeakScan` run.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-baseline-b.<timestamp>.md` carries `Timestamp:`, `Command:`, `EXIT_CODE:` (the returned `ExitCode`) and `Output Summary:` with numeric passed and failed counts, the names of any failing test files, repo-wide line coverage, the coverage source used, and the line coverage of `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1`; `<FEATURE>/evidence/baseline/leak-scan-baseline-b.<timestamp>.md` carries the four fields and the finding count.
- [x] [P0-T3] Capture the PowerShell static baseline over `scripts` and `tests/scripts`: a check-only format run and a PSSA run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `<FEATURE>/evidence/baseline/pwsh-format-baseline-b.<timestamp>.md` and `<FEATURE>/evidence/baseline/pssa-baseline-b.<timestamp>.md` each carry the four fields; the format artifact records the would-change file count and that `git status --porcelain` was identical before and after; the PSSA artifact records the numeric finding count.
- [x] [P0-T4] Capture the contract-check baseline in `<FEATURE>/evidence/baseline/contract-checks-baseline-b.<timestamp>.md`: the Python contract set, `scripts/dev_tools/generate_codex_agent_variants.py` with `--check` and the tier check `scripts/dev_tools/check_quality_tiers.py` (plan A `## Gate Shape`).
  - Acceptance: `<FEATURE>/evidence/baseline/contract-checks-baseline-b.<timestamp>.md` carries the four fields per command, numeric passed and failed counts per module, and for the tier check `EXIT_CODE: 0`, a line beginning `quality-tiers: OK (` and no line beginning `QT0`.

### Phase 1 — Apply Owner Decisions and Runbook Results

- [x] [P1-T1] Apply every disputed-case `Owner-Decision` and every Diff ID override in `Approval` to the batch records (class, port direction, rationale), and every single-ecosystem disposition decision to `<FEATURE>/survey/single-ecosystem.md` and the `Proposed disposition` column of `<FEATURE>/survey/skill-survey.md`, leaving Diff IDs unchanged; then run `SCRATCH/issue-1025-diff-reconcile.ps1` (plan A P3-T9 counts, re-written if absent).
  - Acceptance: `<FEATURE>/evidence/other/owner-decisions-applied.<timestamp>.md` lists each decision with the record it changed, and the reconciliation run has `EXIT_CODE: 0` with `Missing`, `Duplicated`, `Unknown`, `InvalidClass`, `InvalidPortDirection`, `SequenceGaps`, `RecordsWithoutTable` and `BrokenRecordLinks` each 0.
- [x] [P1-T2] Apply `## Decision Application Rules` rules 0 to 3a to `config/harness-parity-matrix.json` with `SCRATCH/issue-1025-matrix-decisions.ps1`, keeping `features` sorted by `id`. The script computes `UnmatchedApprovalIds` and `OverridesWithoutRule` first and writes no change when either is non-zero, and it exits 1 when any counter below is non-zero. The task check's RepoGate run may fail the It `every shared codex skill has a conforming contract` only for Codex-only names that P1-T4 will create; every other It passes.
  - Acceptance: `<FEATURE>/evidence/other/matrix-dispositions-applied.<timestamp>.md` has `EXIT_CODE: 0`, lists each changed `id` with old and new disposition, and records `UnmatchedApprovalIds: 0`, `OverridesWithoutRule: 0`, the count of entries overridden to `native`, `NativeOverrideWithTargets: 0` (no such entry carries `target_paths` or `generated_from`), and `Violations: 0` from `Get-HarnessParityMatrixViolation` against the live inventory.
- [x] [P1-T3] Apply rules 4 to 9 to `config/harness-parity-matrix.json` with `SCRATCH/issue-1025-matrix-results.ps1`, leaving every overridden entry's disposition fields as rules 1 to 3 set them (H2); the script reads `PlanAMatrix`, the latest `Result(Ex)` files and `Approval`, and exits 1 when `Violations` or any of the ten counters below is non-zero. The task check's RepoGate expectation is that of P1-T2.
  - Acceptance: `<FEATURE>/evidence/other/matrix-violations-post-decision.<timestamp>.md` has `EXIT_CODE: 0`, `Violations: 0` against the live inventory, the counts of `approved` and `provisional` entries and of `provisional` entries per reason (`deferred runbook`, `pending-source`), and ten counters, each 0, counted over the written matrix with the terms of `## Decision Application Rules` (an overridden entry has a feature-id row in `## Owner Overrides`; each counter counts entries):
    - `UnsettledWithoutReason` (a `provisional` entry with neither a deferred runbook that rule 9 holds it back for nor a `generated_from` beginning `pending-source:`); `SettledNotApproved` (an entry meeting rule 9 that is not `approved`).
    - `DeferredRefMismatch`: an entry whose runbook is deferred that is not `provisional` with `decision_ref` equal to its `PlanAMatrix` `decision_ref`, excluding an entry overridden to `dropped` (D-R4) and an overridden `copilot:agent:*` entry whose deferred runbook is E3 (H2).
    - `OverrideDispositionMismatch`: an overridden entry whose `disposition` differs from its override value after rule 6.
    - `NativeOverrideWithTargets` and `NativeOverrideUnsettled`: an entry overridden to `native` that carries `target_paths` or `generated_from`, or that is neither `approved` nor `provisional` with `decision_ref` naming a deferred runbook other than E3.
    - `DroppedOverrideMismatch`: an entry overridden to `dropped` that is not `dropped` and `approved` with `decision_ref` `#1025:survey/difference-approval.md#owner-overrides`, no `target_paths` or `generated_from`, and `reason` equal to its trimmed override note, or to the rule 3 fixed reason when the note is empty (D-R4, D-R5).
    - `E3DispositionMismatch`: a non-overridden `copilot:agent:*` entry that, when `Result(E3)` exists with `CLI-Lists-Claude-Agent` and `Cloud-Lists-Claude-Agent` both `yes`, is not `dropped` and `approved` with the rule 6 `reason`, `decision_ref` `#1025:evidence/other/<Result(E3) file name>` and no `target_paths` or `generated_from`, or, in every other case (E3 deferred, or either value not `yes`), has a `disposition`, `reason`, `target_paths` or `generated_from` different from its `PlanAMatrix` value.
    - `ConsumersMismatch`: a `claude:agent:*`, `claude:path-scoped-rule:*` or `claude:instructions:CLAUDE.md` entry, overridden or not, whose `consumers` hold a duplicate or, compared as a set, differ from the expected set. The expected set is the `PlanAMatrix` `consumers` when the runbook that rules 6 and 8 read for it (E3 for an agent, E6 for the other two) is deferred; otherwise, for an agent, that set plus `copilot-cli` when `CLI-Lists-Claude-Agent` is `yes` and `copilot-cloud` when `Cloud-Lists-Claude-Agent` is `yes`; for a path-scoped rule, that set without `copilot-vscode`, plus `copilot-vscode` when `VSCode-References-Both-Rules` is `yes`; for `CLAUDE.md`, that set without `copilot-cli`, plus `copilot-cli` when `CLI-Lists-CLAUDE-md` is `yes`.
    - `NotesMismatch`: an entry selected by rule 4 (entries whose runbook is E1; reads E1), rule 5 (`kind` `skill-frontmatter-field`; reads E2) or rule 7 (entries whose runbook is E4; reads E4) whose `notes` differ, by ordinal comparison, from the rule's `notes` text with each placeholder replaced by the result value of the field it follows when the runbook the rule reads has `Result(Ex)`, or from its `PlanAMatrix` `notes` when that runbook is deferred.
- [x] [P1-T4] With `SCRATCH/issue-1025-contracts-post-decision.ps1`: create a contract for every Codex-only name approved `shared` (from its `.agents/skills/<name>/SKILL.md` and survey record, under the content rules of plan A `### Phase 3 — Matrix, Contracts, Approval Artifact and Repository Gate`), delete the contract of every `codex:skill` name moved off `shared`, review the contract of every name with a disputed-case decision or Diff ID override and revise it where the decision changes a stated objective or behavior, then copy, overwrite or delete each bundle copy byte for byte, removing a `references/` folder that a deletion leaves empty in either tree. The script exits 1 when any counter below is non-zero. An empty set is recorded as `none`.
  - Acceptance: `<FEATURE>/evidence/other/contracts-post-decision.<timestamp>.md` has `EXIT_CODE: 0`, lists created, revised, unchanged-with-reason and deleted paths, and records `Violations: 0` from `Get-HarnessSkillContractViolation` over created and revised files, `ContractSetMismatch: 0` (the on-disk `.agents/skills/*/references/standard.md` set equals the `Get-HarnessSkillContractRequiredSet` set of the current matrix) and `BundleMismatch: 0` (each contract has a byte-identical bundle copy and no bundle copy lacks its contract); the task check records 0 failed for the Python contract set, the three sweep suites and the RepoGate suite.
- [x] [P1-T5] [phase-gate] Run the phase gate of `## Gate Shape`, writing `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` meets the `## Gate Shape` pass condition, and its JUnit record lists the Its of `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` with none failed (the `Test-Json` It skipped below 7.4).

### Phase 2 — Final QA Loop and Self-Review

- [ ] [P2-T1] Run the final PowerShell static steps over `scripts` and `tests/scripts`: check-only format and PSSA; type check not applicable.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-qc-static-powershell-b.<timestamp>.md` records each step's command, exit code and finding count: no would-change file beyond `pwsh-format-baseline-b`, `git status --porcelain` identical before and after, no PSSA finding beyond `pssa-baseline-b`, and 0 findings under `scripts/harness` and `tests/scripts/harness`; any rewrite or new finding restarts the loop here, and one under an excluded path is a re-planning stop.
- [ ] [P2-T2] Run the final Pester gate over `tests/scripts` (`## Gate Shape` coverage source): one parallel Pester gate run with coverage and one `Invoke-PoshQCLeakScan` run.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pester-b.<timestamp>.md` records `EXIT_CODE:` from the returned `ExitCode`, passed and failed counts, no failing test file absent from `pester-baseline-b`, the four `tests/scripts/harness` files with 0 failed, the It `reports zero ratchet violations against config/file-size-baseline.json` as passed, repo-wide line coverage and the per-file coverage of the three harness modules; `<FEATURE>/evidence/qa-gates/final-leak-scan-b.<timestamp>.md` records 0 findings.
- [ ] [P2-T3] Write `<FEATURE>/evidence/qa-gates/coverage-delta-b.<timestamp>.md` from the latest `pester-baseline-b.*.md` and `final-pester-b.*.md`.
  - Acceptance: the artifact records the baseline and post-change figures, `ChangedProductionFiles: 0` (no `.ps1` or `.psm1` production file changed since `PlanBStart`), `RepoWideNoDrop: true`, and for each of the three harness modules a value of 85% or more and not below its `Phase 0 baseline` value (`HarnessModulesNoDrop: true`).
- [ ] [P2-T4] Run the final contract checks into `<FEATURE>/evidence/qa-gates/final-contract-checks-b.<timestamp>.md`: the Python contract set, `scripts/dev_tools/generate_codex_agent_variants.py` with `--check` and the tier check `scripts/dev_tools/check_quality_tiers.py` (plan A `## Gate Shape`).
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-contract-checks-b.<timestamp>.md` records 0 failed per module (including `test_push_down_codex_and_agents_resource_contracts.py` and `test_push_down_issue_824_follow_ups.py`), generator exit 0, and the tier check `EXIT_CODE: 0` with no line beginning `QT0`.
- [ ] [P2-T5] Write `<FEATURE>/evidence/qa-gates/no-new-python-b.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/excluded-paths-b.<timestamp>.md`: list added files with `git diff --name-only --diff-filter=A MB`, plan B's changed files with `git diff --name-only PlanBStart`, the branch's changed files with `git diff --name-only MB`, and the untracked and modified set with `git status --porcelain`; compare plan B's paths with `## Excluded Paths`, the branch's paths with spec `### Excluded paths (must not be edited by this child)`, and the branch's paths with `## Edit Set` and `BranchBaseline`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/no-new-python-b.<timestamp>.md` records the added list and `AddedPy: 0`; `<FEATURE>/evidence/qa-gates/excluded-paths-b.<timestamp>.md` records the `PlanBStart` value from the latest `phase0b-branch-snapshot.*.md`, the outputs, `ExcludedTouched: 0` (plan B paths plus porcelain paths), `SpecExcludedTouched: 0` (branch paths plus porcelain paths) and `OutsideEditSet: 0` (paths in neither `## Edit Set` nor `BranchBaseline`).
- [ ] [P2-T6] Check off in `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` every acceptance criterion except `Required CI check`, and in `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/user-story.md` every criterion except the one beginning `The completeness gate fails on` (CI-dependent, checked off by the orchestrator at S9), citing plan A and plan B evidence; criteria checked by plan A stay checked.
  - Acceptance: `spec.md` has exactly 25 checked criteria and one unchecked (`Required CI check`); `user-story.md` has exactly 16 checked and one unchecked.
- [ ] [P2-T7] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`, citing plan A and plan B evidence for each row.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P2-T1, and a new self-review written.

## Acceptance Criteria Traceability

| AC (spec unless noted) | Plan B tasks | Earlier work |
| --- | --- | --- |
| SPEC-AC-04 Per-skill records | P1-T1 | plan A Phase 1, P3-T9 |
| SPEC-AC-05 Classification and approval artifact | P1-T1 | plan A P3-T8, P3-T9 |
| SPEC-AC-06 Owner decision recorded | P0-T1, P1-T1 | orchestrator R1 |
| SPEC-AC-08 Matrix | P1-T2, P1-T3, P1-T5 | plan A P3-T1, P3-T10 |
| SPEC-AC-09 Contracts | P1-T4, P1-T5 | plan A P3-T2 to P3-T7 |
| SPEC-AC-10 Bundle copies | P1-T4, P2-T4 | plan A P3-T2 to P3-T7 |
| SPEC-AC-12 Pass case | P1-T5, P2-T2 | plan A P2-T3, P3-T10 |
| SPEC-AC-16 Coverage | P2-T2, P2-T3 | plan A P2-T6, P4-T2, P4-T3 |
| SPEC-AC-21 Runbook results | P0-T1, P1-T3 | orchestrator R2 |
| SPEC-AC-22 Owner stop recorded | P0-T1 | orchestrator owner stop |
| SPEC-AC-23 No new Python | P2-T5 | plan A P4-T6 |
| SPEC-AC-24 File size | P2-T2 | plan A P4-T5 |
| SPEC-AC-25 Excluded paths untouched | P2-T5 | plan A P4-T6 |
| SPEC-AC-26 Tier classification | P0-T4, P2-T4 (re-run) | plan A P2-T5 (checked off by plan A) |
| US-AC-CP Copilot entries approved or provisional with issue-keyed `decision_ref` (user-story) | P1-T3, P1-T5 | plan A P3-T1 |
| SPEC-AC-15 Required CI check | — | orchestrator S9 on `poshqc / PowerShell QC` |

SPEC-AC-18 (test isolation) is checked off by plan A; plan B's gates P0-T2, P1-T5 and P2-T2 follow the same D-R2 shape.

## Citations Re-Checked at Phase 0

- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` | `committed matrix has no violation against the live inventory`; `every shared codex skill has a conforming contract`
- `scripts/harness/HarnessParityMatrix.psm1` | `Get-HarnessParityMatrixViolation`
- `scripts/harness/HarnessSkillContract.psm1` | `Get-HarnessSkillContractViolation`; `Get-HarnessSkillContractRequiredSet`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | `## Owner Overrides`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md` | `## Gate Shape`; `## Matrix Bootstrap Rules`; `## Owner Stop (Orchestrator-Owned, After Plan A)`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` | `### Excluded paths (must not be edited by this child)`
- `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCParallelTest`; `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` | `Invoke-PoshQCLeakScan`; `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` | `Merge-PoshQCCoverageReport`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | `test_all_repo_agent_skills_are_bundled_and_identical`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | `test_pushed_roots_carry_no_hard_coded_solution_file`
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | `reports zero ratchet violations against config/file-size-baseline.json`
- `scripts/dev_tools/check_quality_tiers.py` | `quality-tiers: OK`
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md` | file presence

## Pre-Mortem

- Review checklists: an override with no derivation rule stops P1-T2 (rule 3a) before the matrix is written; H2 precedence and the `native` field removal are counted at P1-T2 and P1-T3, because the schema does not forbid those fields on a `native` entry and `Violations: 0` alone would not detect them; D-R4 and D-R5 are counted by `DroppedOverrideMismatch`, and rules 4 to 8 by `E3DispositionMismatch`, `ConsumersMismatch` and `NotesMismatch`, at P1-T3 against `PlanAMatrix`, with and without a deferred runbook; contract removal for names moved off `shared` is counted by `ContractSetMismatch` at P1-T4. Each counting script exits 1 on a non-zero counter, so `EXIT_CODE` carries the acceptance. The self-review (P2-T7) walks all three templates, citing plan A evidence for unchanged areas and plan B evidence (P2-T1 to P2-T5) for the decision changes.
- Coverage: no production file changes in plan B; P2-T2 reads per-file coverage from one parallel gate run and P2-T3 compares it with the `Phase 0 baseline` of P0-T2 (85% floor, no drop).
- Mirror parity: every created, revised or deleted contract is synchronized with its bundle copy in the same task (P1-T4, `BundleMismatch`), and its task check runs the resource-contract tests and the three sweep suites that read every `.md` file under `.agents/skills` and the Codex bundle; no pack manifest or `SKILL.md` is edited; no execution-environment brief fact changes, so no brief-update task exists.
- File size: plan B edits JSON and Markdown only, both exempt; P2-T2 reads the repository file-size It.
- Test isolation: the parallel gates are one `Invoke-PoshQCParallelTest` run each at P0-T2, P1-T5 and P2-T2, re-run only after a fix, plus `Invoke-PoshQCLeakScan` at P0-T2 and P2-T2 (spec D-R2); no `pytest -n auto` or Jest gate applies because no Python or TypeScript file changes (the Python contract modules run as contract checks). Plan B adds and changes no test file; an order dependence found by a gate is a re-planning stop because the harness suites are excluded paths.
- CI-only behavior: the repository gate reads the committed matrix and live tree only; plan A R4 re-runs it after the `origin/main` sync, so an upstream inventory change stops before plan B. Encoded ids are ASCII and sorted ordinally, so the re-sorted matrix is identical on every runner. The `tier-classification` step is re-run at P0-T4 and P2-T4 because an upstream project added during the sync would fail it in CI.
- Evidence: every artifact is under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp read from the clock, append-only, with the four command-step fields where a command is recorded and `SCRATCH` instead of host paths. Plan B names carry a `phase0b-` prefix or `-b` suffix where plan A wrote the same kind; the contract-fixed names `phase-gate.P1`, `task-check.P<N>-T<M>` and `self-review` are shared with plan A, and plan B writes them later, so the latest file is plan B's. The excluded-path check (P2-T5) is anchored on `PlanBStart`, so plan A's outputs are not counted as plan B edits, while `SpecExcludedTouched` checks the whole branch against `MB`. Deferred runbooks and an autonomous approval record need no special path: rules 4 to 9 leave deferred entries `provisional` with the runbook `decision_ref` (except a `dropped` override, D-R4, and an overridden `copilot:agent:*` entry under E3, H2), and P0-T1 records the approval fields as written.

## Test Plan

- Run only: the four `tests/scripts/harness` suites and the rest of `tests/scripts` through the parallel Pester gate; the existing Python contract set, generator `--check` and tier check.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/pester-baseline-b.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/final-pester-b.<timestamp>.md`; delta `<FEATURE>/evidence/qa-gates/coverage-delta-b.<timestamp>.md`.
