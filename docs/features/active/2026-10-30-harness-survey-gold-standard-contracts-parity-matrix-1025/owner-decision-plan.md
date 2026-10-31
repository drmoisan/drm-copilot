# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix - Plan B (Owner Decisions)

- **Issue:** #1025
- **Parent (optional):** epic #1018, child 1
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31 (coordinator decision H2 revision)
- **Status:** Draft
- **Version:** 1.3 (H2: an owner override takes precedence over the E3 result in rule 6; an override to `native` drops `target_paths` and `generated_from` and settles under rule 9). 1.2 (preflight round 1: excluded-path check anchored on `PlanBStart`; `OverridesWithoutRule` stop count). 1.1 (H1: identifier-based matching rule, language classification, consistency with plan A's tier check and new spec criterion)
- **Work Mode:** full-feature
- **Requirements sources:** `spec.md` (`## Acceptance Criteria`, `## Owner Stop`), `user-story.md`, `plan.2026-10-30T17-06.md` (plan A: `## Matrix Bootstrap Rules`, `## Owner Stop (Orchestrator-Owned, After Plan A)`, `## Acceptance Criteria Traceability`)
- **Delegation:** the orchestrator delegates this plan only after plan A is complete and the owner stop's resume conditions R1 to R4 hold. Plan A remains the canonical plan path; this plan carries the post-decision work.

## Required References

- Policy order: `policy-compliance-order` skill. PowerShell policies: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`.
- Tool routes, launchers, PoshQC MCP limits and contract tests: the `execution-environment` skill; this plan does not restate them.
- Evidence naming: `evidence-and-timestamp-conventions` skill; a consumer selects the lexicographically greatest `<name>.*.md`.

## Definitions

- `<FEATURE>` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`.
- `SCRATCH` is `<session scratchpad>/issue-1025/`. Helper scripts live under `SCRATCH` with names starting `issue-1025-`, are throwaway PowerShell, are never committed, and are re-written in this session when absent. Evidence records the token `SCRATCH`, never a host path.
- `MB` is the merge base of `origin/main` and `HEAD`, derived after fetching `origin/main` when the task runs.
- `Approval`: `<FEATURE>/survey/difference-approval.md` as completed by the owner.
- `Result(Ex)`: the latest `<FEATURE>/evidence/other/<runbook id>-result.*.md` for runbook `Ex`; `Ex` is deferred when `Approval` `## Owner Overrides` has a deferral row for it and no result exists.
- `BranchBaseline`: the path set in the latest `<FEATURE>/evidence/baseline/phase0b-branch-snapshot.*.md`, written by entry check Y3.
- `PlanBStart`: the commit recorded under `PlanBStart:` in the latest `<FEATURE>/evidence/baseline/phase0b-branch-snapshot.*.md` (the output of `git rev-parse HEAD` at Y3, before any plan B task). It is an evidence value only; the plan never quotes it. Paths changed since `PlanBStart` are plan B's changes; paths changed since `MB` include plan A's outputs.

## Edit Set (complete)

- Edit: `config/harness-parity-matrix.json`.
- Create, edit or delete: `.agents/skills/<name>/references/standard.md` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`, only for names listed in the P1-T4 artifact.
- Edit: `<FEATURE>/survey/skill-survey.md`, `<FEATURE>/survey/batch-*.md`, `<FEATURE>/survey/single-ecosystem.md`.
- New: `<FEATURE>/evidence/**`.
- Check-off edits only: this plan file, `<FEATURE>/spec.md`, `<FEATURE>/user-story.md`.
- Not edited but already changed on the branch: every path in `BranchBaseline`.

## Excluded Paths (must never be edited)

- Every path in plan A `## Excluded Paths`.
- `quality-tiers.yml` (classified by plan A P4-T9), `scripts/harness/**`, `tests/scripts/harness/**`, `config/harness-parity-matrix.schema.json`, `<FEATURE>/runbooks/**`, `<FEATURE>/survey/difference-approval.md` (owner-edited) and `plan.2026-10-30T17-06.md`. A defect found in a module, test or schema is a re-planning stop, not a plan B edit.

## Language Choices

| Choice | Where | Cost | Risk and mitigation |
| --- | --- | --- | --- |
| PowerShell 7 + Pester 5 (run only) | the four `tests/scripts/harness/*.Tests.ps1` suites and the three `scripts/harness/*.psm1` modules from plan A | No production PowerShell file is created or edited, so the batch budget is not consumed. | Module behavior is fixed by plan A's tests; P2-T3 re-runs them with coverage. |
| JSON (edit) | `config/harness-parity-matrix.json` against the Draft 2020-12 schema from plan A | No new dependency. | Structural validation through `Get-HarnessParityMatrixViolation` and the repository gate. |
| Throwaway PowerShell under `SCRATCH` | matrix update, reconciliation, bundle copy | None committed. | P2-T8 asserts no path outside the edit set and `BranchBaseline`. |
| Existing Python, run only | the five test modules, the generator `--check` and the tier-classification check named in plan A `## Language Choices` | No new `.py` file (owner directive). | P2-T6 asserts zero added `.py` files against `MB`. |

## Language Classification

Owner language rule (H1), as stated in plan A `## Language Classification`. Every artifact this plan creates, edits, deletes or runs:

| Artifact | Language | Where it runs | Permitting clause |
| --- | --- | --- | --- |
| `config/harness-parity-matrix.json` (edit) | JSON data | repo-only; read by the Pester gate and by children 3 to 6 | data, no executable code |
| `.agents/skills/<name>/references/standard.md` and bundle copies (create, revise, delete) | Markdown | bundle payload (no pack-manifest entry) | documentation, no executable code |
| `<FEATURE>/survey/skill-survey.md`, `<FEATURE>/survey/batch-*.md`, `<FEATURE>/survey/single-ecosystem.md`, `<FEATURE>/evidence/**` | Markdown | repo-only | documentation |
| `SCRATCH/issue-1025-matrix-decisions.ps1`, `SCRATCH/issue-1025-matrix-results.ps1`, `SCRATCH/issue-1025-copy-contracts.ps1`, `SCRATCH/issue-1025-diff-reconcile.ps1`, and any other `SCRATCH/issue-1025-*.ps1` helper (for example the P1-T4 contract check) | PowerShell 7 | session-only, never committed | PowerShell baseline; no new Python |
| `SCRATCH/issue-1025-*.sh` launchers for the PowerShell runs (route owned by the `execution-environment` skill) | POSIX `sh` | session-only, never committed | bash-family launcher, not pushed down; no new Python |
| `scripts/harness/*.psm1` and `tests/scripts/harness/*.Tests.ps1` (run only) | PowerShell 7, Pester 5 | repo-only CI and local | PowerShell baseline (classified in plan A) |
| Existing Python (five test modules, generator `--check`, tier check; run only) | Python (existing) | repo-only CI and local | existing Python tolerated: called, not edited |

OWNER QUESTION: none. No artifact needs the E2 exception.

## Execution Preconditions (Orchestrator-Checked)

- Plan A is complete: every task in `plan.2026-10-30T17-06.md` is checked and the latest `pre-stop-readiness.*.md` reads `PreStop: READY`.
- The owner stop was recorded per plan A `## Owner Stop (Orchestrator-Owned, After Plan A)` and the latest `<FEATURE>/evidence/other/owner-stop.*.md` is committed.
- Resume conditions R1 to R4 hold, and the latest `<FEATURE>/evidence/other/resume-check.*.md` reads `Resume: READY` and is committed. A newly inventoried feature or skill name (R4 failure) is a re-planning stop; plan B is not delegated.
- The branch contains `origin/main` (`git merge-base --is-ancestor origin/main HEAD` exits 0).
- The owner's `Approval` edits are committed, so entry check Y1 finds no path in `## Excluded Paths` in `git status --porcelain`.

## Executor Entry Checks (Before [P0-T1])

The executor runs Y1 to Y3 before checking any task. If any check fails, it checks no task and returns `BLOCKED at preflight (before [P0-T1])` with a plan delta naming each failing row.

- Y1: the latest `pre-stop-readiness.*.md` reads `PreStop: READY`; the latest `owner-stop.*.md` lists six requirements, one `halt` and five `exception` entries with non-empty `runbook_path`; the latest `resume-check.*.md` reads `Resume: READY`; `git merge-base --is-ancestor origin/main HEAD` exits 0; plan A has no unchecked task; `git status --porcelain` lists no path in `## Excluded Paths` (the owner's `Approval` edits are committed before `PlanBStart` is recorded). Artifact: `<FEATURE>/evidence/baseline/phase0b-preconditions.<timestamp>.md` ending `Preconditions: PASS`.
- Y2: re-derive every entry in `## Citations Re-Checked at Phase 0` against `HEAD` (tracked path by `git ls-files --error-unmatch`; symbol or heading by `git grep -n -F`, passing a hyphen-leading pattern through `-e`). Artifact: `<FEATURE>/evidence/baseline/phase0b-citations.<timestamp>.md` ending `Citations: PASS` only when every row is `PRESENT`.
- Y3: record `git diff --name-only MB...HEAD` and the paths of `git status --porcelain` as one sorted, de-duplicated list, and record the output of `git rev-parse HEAD`. Artifact: `<FEATURE>/evidence/baseline/phase0b-branch-snapshot.<timestamp>.md` with the three commands, the list under `BranchBaseline:`, and a line beginning `PlanBStart:` carrying the `git rev-parse HEAD` output.

## Decision Application Rules

Applied by P1-T2 and P1-T3 in this order; values not named stay as plan A wrote them.

0. Identifiers: every `id` in these rules, in `Approval` `## Disposition Proposals` and `## Owner Overrides`, and in the scratch scripts is the encoded form of spec `### Parity Matrix: Identifier Encoding` (for example a hook registration declared in both `.claude/settings.json` and agent frontmatter appears as two ids ending `~.claude%2Fsettings.json` and `~.claude%2Fagents%2F<agent>.md`). A rule selects entries either by an exact `id` string copied from `config/harness-parity-matrix.json` or by the entry fields `ecosystem`, `kind` and `name` (written below as `<ecosystem>:<kind>:*`), or by the runbook path in its `decision_ref` (rules 4, 7 and 9); it never decodes, re-encodes or re-derives an `id`, and it never matches on a substring of an `id` beyond the `<ecosystem>:<kind>:` prefix. An `Approval` row naming a feature id that is not an exact `id` in the matrix is counted as `UnmatchedApprovalIds`; a non-zero count stops P1-T2 for re-planning.
1. Approved disposition: for an entry or skill listed in `Approval` `## Disposition Proposals` or `## Owner Overrides`, the owner's decision (an empty answer accepts the proposal); for every other entry, the plan A disposition (approved in bulk by `Approval-Status`). An entry selected by an `## Owner Overrides` row is an overridden entry. Precedence (H2): the owner's decision on an overridden entry takes precedence over every later rule that sets a disposition, including the E3 result in rule 6, for `copilot:agent:*` entries and generally; no later rule changes the `disposition`, `reason`, `decision_ref`, `target_paths` or `generated_from` that rules 1 to 3 gave an overridden entry. The `consumers` and `notes` changes of rules 4 to 8 still apply to it.
2. Single-ecosystem skill approved `shared`: Claude-only `claude:skill:<name>` gets `shared`, `target_paths` `[.agents/skills/<name>/SKILL.md]`, `owner_child` 3 (no contract, F2); Codex-only `codex:skill:<name>` gets `shared`, `target_paths` `[.claude/skills/<name>/SKILL.md]`, `owner_child` 3, and a contract in P1-T4. Approved `native`: unchanged. The `proposed:` note becomes `approved: <disposition>`.
3. Override to `dropped`: `reason` from the override note, `decision_ref` `#1025:survey/difference-approval.md#owner-overrides`, `target_paths` and `generated_from` removed. Override to `native` (H2): `target_paths` and `generated_from` removed, because they have no meaning for a `native` entry (spec `### Disposition Semantics`), so the entry never carries a `pending-source:<kind>` placeholder and rule 9 can settle it; `reason` becomes the override note, or is removed when the note is empty (a plan A `E3 pending` reason no longer applies); `decision_ref` is left for rule 9.
3a. Override without a derivation rule: no rule derives `target_paths` or `generated_from` for an `## Owner Overrides` row that sets `generated` on any entry, or `shared` on any entry other than a Claude-only `claude:skill:<name>` or a Codex-only `codex:skill:<name>` (rule 2), because the spec gives no single source or mirror target for such an entry. `OverridesWithoutRule` counts every such row whose value differs from the entry's plan A disposition (a row equal to it keeps the fields plan A wrote). An override to `native` or `dropped` is never counted, because rule 3 derives its fields. P1-T2 computes the count before writing the matrix; a non-zero count stops P1-T2 for re-planning with the matrix unchanged.
4. E1 recorded: entries whose `decision_ref` names the E1 runbook get `notes` `E1: VSCode-Entries <n>, CLI-Entries <n>`.
5. E2 recorded: `skill-frontmatter-field` entries get `notes` `E2: Codex-Lists-Skill <value>, Codex-Warning-Fields <value>`.
6. E3 recorded: when `CLI-Lists-Claude-Agent` and `Cloud-Lists-Claude-Agent` are both `yes`, every `copilot:agent:*` entry that is not overridden becomes `dropped` with `reason` `E3 result: the Copilot CLI and cloud agent read .claude/agents`, `decision_ref` `#1025:evidence/other/<Result(E3) file name>`, and no `target_paths` or `generated_from`; otherwise it keeps its plan A disposition and fields. An overridden `copilot:agent:*` entry keeps the disposition and fields from rules 1 to 3 whatever the E3 result (rule 1 precedence, H2). `claude:agent:*` `consumers` gain `copilot-cli` when `CLI-Lists-Claude-Agent` is `yes` and `copilot-cloud` when `Cloud-Lists-Claude-Agent` is `yes`.
7. E4 recorded: entries whose `decision_ref` names the E4 runbook get `notes` `E4: Workspace-Settings-Honored <value>`.
8. E6 recorded: `claude:path-scoped-rule:*` `consumers` include `copilot-vscode` only when `VSCode-References-Both-Rules` is `yes`; `claude:instructions:CLAUDE.md` `consumers` include `copilot-cli` only when `CLI-Lists-CLAUDE-md` is `yes`.
9. Settlement: an entry is settled when rule 1 gave it an approved disposition, the runbook its `decision_ref` names (if any) has `Result(Ex)`, and its `generated_from` does not begin `pending-source:`. For an overridden `copilot:agent:*` entry the E3 runbook is not a condition, because rule 1 takes precedence over the E3 result (H2); an entry overridden to `native` has no `generated_from` (rule 3), so it is never unsettled for reason `pending-source` and stays `provisional` only when its `decision_ref` names a deferred runbook other than E3. A settled entry gets `decision_status` `approved` and loses `decision_ref` unless `dropped`. An unsettled entry stays `provisional`: with a deferred runbook its `decision_ref` stays the runbook path; with `pending-source:` and a recorded result it becomes `#1025:evidence/other/<Result(Ex) file name>`; otherwise it is unchanged.

### Phase 0 — Policy Reads, Resume Record and Baselines

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, then the `execution-environment` skill.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0b-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and one line per file read, in the order above.
- [ ] [P0-T2] Write the resume record from the latest `owner-stop.*.md`, `resume-check.*.md`, `phase0b-preconditions.*.md`, `phase0b-citations.*.md` and `Approval`: the stop's `blocked_reason`, its six requirements, the approval fields, the count of disputed cases with a non-empty `Owner-Decision`, the Q1 to Q8 answers or accepted defaults, and for each of E1, E2, E3, E4 and E6 either the `Result(Ex)` file name or `deferred`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0b-resume.<timestamp>.md` records `blocked_reason: human_decision_required`, six requirements with five non-empty `runbook_path` values, `Approval-Status` `approved` or `approved-with-overrides`, disputed cases decided equal to disputed cases listed, eight question rows and five runbook rows, and ends `ResumeGate: PASS`.
- [ ] [P0-T3] Capture the harness baseline: a branch-current run of the four `tests/scripts/harness` suites with coverage over `scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0b-pester-harness.<timestamp>.md` has `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` with numeric passed and failed counts and the three per-file line-coverage values from `artifacts/pester/powershell-coverage.xml`.
- [ ] [P0-T4] Capture the Python contract-test baseline: the five test modules, the generator `--check` and the tier-classification check named in plan A `## Language Choices`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0b-python-contracts.<timestamp>.md` has the four command-step fields per command, numeric passed and failed counts, and for the tier check `EXIT_CODE: 0` with a line beginning `quality-tiers: OK (` and no line beginning `QT0`.

### Phase 1 — Apply Owner Decisions and Runbook Results

- [ ] [P1-T1] Apply every disputed-case `Owner-Decision` and every Diff ID override in `Approval` to the batch records (class, port direction, rationale) and every single-ecosystem disposition decision to `<FEATURE>/survey/single-ecosystem.md` and the `Proposed disposition` column of `<FEATURE>/survey/skill-survey.md`, leaving Diff IDs unchanged; then re-write if absent and run `SCRATCH/issue-1025-diff-reconcile.ps1` with the plan A P7-T2 counts.
  - Acceptance: `<FEATURE>/evidence/other/owner-decisions-applied.<timestamp>.md` lists each decision with the record it changed, and the reconciliation output in it reads `Missing: 0`, `Duplicated: 0`, `Unknown: 0`, `InvalidClass: 0`, `SequenceGaps: 0`, `RecordsWithoutTable: 0` and `BrokenRecordLinks: 0`.
- [ ] [P1-T2] Apply `## Decision Application Rules` rules 1 to 3a to `config/harness-parity-matrix.json` from `SCRATCH/issue-1025-matrix-decisions.ps1`, keeping `features` sorted by `id`; the script computes `UnmatchedApprovalIds` and `OverridesWithoutRule` first and writes no matrix change when either is non-zero.
  - Acceptance: `<FEATURE>/evidence/other/matrix-dispositions-applied.<timestamp>.md` lists each changed `id` with old and new disposition, records `UnmatchedApprovalIds: 0` (rule 0), `OverridesWithoutRule: 0` (rule 3a, native and dropped overrides not counted), the count of entries overridden to `native` and `NativeOverrideWithTargets: 0` (no entry overridden to `native` carries `target_paths` or `generated_from`, rule 3), and `Get-HarnessParityMatrixViolation` against the live inventory records `Violations: 0`.
- [ ] [P1-T3] Apply rules 4 to 9 to `config/harness-parity-matrix.json` from `SCRATCH/issue-1025-matrix-results.ps1`, leaving every overridden entry's disposition fields as rules 1 to 3 set them (rule 1 precedence over rule 6, H2).
  - Acceptance: `<FEATURE>/evidence/other/matrix-violations-post-decision.<timestamp>.md` records `Violations: 0` against the live inventory, the counts of `approved` and `provisional` entries, the count of `provisional` entries per reason (`deferred runbook`, `pending-source`), `UnsettledWithoutReason: 0`, `OverrideDispositionMismatch: 0` (every overridden entry's `disposition` equals its `## Owner Overrides` value after rule 6), `NativeOverrideWithTargets: 0`, and `NativeOverrideUnsettled: 0` (every entry overridden to `native` is `approved`, or `provisional` with a `decision_ref` naming a deferred runbook other than E3; none is `provisional` for reason `pending-source`).
- [ ] [P1-T4] Create a contract for every Codex-only name approved `shared` (from its `.agents/skills/<name>/SKILL.md` and survey record), delete the contract of every `codex:skill` name moved off `shared`, and review the contract of every name that has a disputed-case decision or Diff ID override, revising it where the decision changes a stated objective or behavior. An empty set is recorded as `none`.
  - Acceptance: `<FEATURE>/evidence/other/contracts-post-decision.<timestamp>.md` lists created, revised, unchanged-with-reason and deleted paths, and `Violations: 0` from `Get-HarnessSkillContractViolation` over the created and revised files.
- [ ] [P1-T5] Synchronize the bundle copies for every path in the P1-T4 artifact (copy, overwrite or delete) with `SCRATCH/issue-1025-copy-contracts.ps1`, then run the three contract tests named in plan A `### Phase 6 — Contracts and Bundle Copies for the Shared Set`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/bundle-parity-post-decision.<timestamp>.md` records 3 passed, 0 failed.
- [ ] [P1-T6] Run `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` branch-current.
  - Acceptance: `<FEATURE>/evidence/qa-gates/repo-gate-post-decision.<timestamp>.md` records 0 failed and 5 or 6 passed from the JUnit file.

### Phase 2 — Final QA Loop and Self-Review

- [ ] [P2-T1] Run PowerShell formatting over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-format-b.<timestamp>.md` has the four command-step fields and every file prints `Already formatted:` with none printing `Formatted:`, each file recorded by its repository-relative path (the formatter prints absolute paths, which evidence never records); a rewrite is a re-planning stop because these paths are excluded.
- [ ] [P2-T2] Run PSSA with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pssa-b.<timestamp>.md` records 0 findings.
- [ ] [P2-T3] Run the four harness suites branch-current with coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pester-harness-b.<timestamp>.md` records 0 failed from `artifacts/pester/pester-junit.xml` and per-file line coverage of 85% or more for `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1`, each not below its P0-T3 value.
- [ ] [P2-T4] Run the Python contract set from P0-T4 again.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-python-contracts-b.<timestamp>.md` records 0 failed, the generator `--check` exit 0, and the tier check `EXIT_CODE: 0` with no line beginning `QT0`.
- [ ] [P2-T5] Run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size-b.<timestamp>.md` records 0 failed for the It block `reports zero ratchet violations against config/file-size-baseline.json`.
- [ ] [P2-T6] List added files with `git diff --name-only --diff-filter=A MB` and the untracked set with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/no-new-python-b.<timestamp>.md` records both outputs and `AddedPy: 0`.
- [ ] [P2-T7] Check off in `<FEATURE>/spec.md` every acceptance criterion except `Required CI check`, and in `<FEATURE>/user-story.md` every criterion except the one beginning `The completeness gate fails on` (CI-dependent, checked off by the orchestrator at S9), citing plan A and plan B evidence; criteria already checked by plan A stay checked.
  - Acceptance: `spec.md` has exactly 25 checked criteria and one unchecked (`Required CI check`); `user-story.md` has exactly 16 checked and one unchecked.
- [ ] [P2-T8] List plan B's changed files with `git diff --name-only PlanBStart`, the branch's changed files with `git diff --name-only MB`, and the untracked and modified set with `git status --porcelain`; compare plan B's paths with `## Excluded Paths`, the branch's paths with spec `### Excluded paths (must not be edited by this child)`, and the branch's paths with `## Edit Set` and `BranchBaseline`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/excluded-paths-b.<timestamp>.md` records the `PlanBStart` value from the latest `phase0b-branch-snapshot.*.md`, the three outputs, `ExcludedTouched: 0` (plan B `## Excluded Paths` matches among the `git diff --name-only PlanBStart` paths plus the `git status --porcelain` paths), `SpecExcludedTouched: 0` (spec `### Excluded paths (must not be edited by this child)` matches among the `git diff --name-only MB` paths plus the `git status --porcelain` paths, supporting SPEC-AC-25), and `OutsideEditSet: 0`, where `OutsideEditSet` counts paths in neither `## Edit Set` nor `BranchBaseline`.
- [ ] [P2-T9] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`, citing plan A and plan B evidence for each row.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P2-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

| AC (spec unless noted) | Plan B tasks | Earlier work |
| --- | --- | --- |
| SPEC-AC-04 Per-skill records | P1-T1 | plan A Phase 2, P7-T2 |
| SPEC-AC-05 Classification and approval artifact | P1-T1 | plan A P7-T1, P7-T2 |
| SPEC-AC-06 Owner decision recorded | P0-T2, P1-T1 | orchestrator R1 |
| SPEC-AC-08 Matrix | P1-T2, P1-T3, P1-T6 | plan A Phase 5 |
| SPEC-AC-09 Contracts | P1-T4, P1-T6 | plan A Phase 6 |
| SPEC-AC-10 Bundle copies | P1-T5, P2-T4 | plan A Phase 6 |
| SPEC-AC-12 Pass case | P1-T6 | plan A P4-T5, P8-T1 |
| SPEC-AC-16 Coverage | P2-T3 | plan A P9-T3, P9-T5 |
| SPEC-AC-21 Runbook results | P1-T3 | orchestrator R2 |
| SPEC-AC-22 Owner stop recorded | P0-T2 | orchestrator owner stop |
| SPEC-AC-23 No new Python | P2-T6 | plan A P9-T9 |
| SPEC-AC-24 File size | P2-T5 | plan A P9-T8 |
| SPEC-AC-25 Excluded paths untouched | P2-T8 | plan A P9-T12 |
| SPEC-AC-26 Tier classification | P0-T4, P2-T4 (re-run) | plan A P4-T9, P9-T7 (checked off by plan A) |
| US-AC-CP Copilot entries approved or provisional with issue-keyed `decision_ref` (user-story) | P1-T3, P1-T6 | plan A Phase 5 |
| SPEC-AC-15 Required CI check | — | orchestrator S9 on `poshqc / PowerShell QC` |

## Citations Re-Checked at Phase 0

- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` | `committed matrix has no violation against the live inventory`
- `scripts/harness/HarnessParityMatrix.psm1` | `Get-HarnessParityMatrixViolation`
- `scripts/harness/HarnessSkillContract.psm1` | `Get-HarnessSkillContractViolation`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | `## Owner Overrides`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md` | `## Matrix Bootstrap Rules`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` | `### Excluded paths (must not be edited by this child)`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | `test_all_repo_agent_skills_are_bundled_and_identical`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | `test_pushed_roots_carry_no_hard_coded_solution_file`
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | `reports zero ratchet violations against config/file-size-baseline.json`
- `scripts/dev_tools/generate_codex_agent_variants.py` | `--check`
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` | file presence

## Pre-Mortem

- Review checklists: an owner override with no derivation rule stops P1-T2 through `OverridesWithoutRule` (rule 3a) before the matrix is written, so no unreviewable matrix state reaches the gate; an override to `native` drops `target_paths` and `generated_from` (rule 3) and takes precedence over the E3 result (rule 1, H2), and P1-T2 and P1-T3 count both outcomes, because the schema does not forbid those fields on a `native` entry and `Violations: 0` alone would not detect them. The self-review (P2-T9) walks all three templates against the full branch diff, citing plan A evidence for unchanged areas and plan B evidence (P2-T3 to P2-T8) for the decision changes.
- Coverage: no production file changes in plan B; P2-T3 re-reads per-file line coverage from `artifacts/pester/powershell-coverage.xml` and asserts 85% or more and no reduction from P0-T3.
- Mirror parity: every created, revised or deleted contract is synchronized with its bundle copy and the resource-contract tests run (P1-T5); no pack manifest or `SKILL.md` is edited; no execution-environment brief fact changes, so no brief-update task is needed.
- File size: plan B edits JSON and Markdown only, both exempt; P2-T5 confirms the repository gate still passes.
- Test isolation: not applicable to new runs, because plan B adds and changes no test file and no production code; the seeded shuffled runs of plan A (P9-T6, seeds 1025, 2051 and 3077) cover the suites, and P2-T3 re-runs them against the edited matrix.
- CI-only behavior: the repository gate reads the committed matrix and live tree only; R4 re-runs it after the `origin/main` sync, so an upstream inventory change stops before plan B rather than failing in CI. Encoded ids are ASCII and sorted ordinally, so the re-sorted matrix is identical on every runner. The `tier-classification` step in the four `quality-checks7` contexts is re-run locally at P0-T4 and P2-T4 because an upstream project added during the sync would fail it in CI.
- Evidence: every artifact is under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp and the four command-step fields where a command is recorded; plan B artifact names carry a `phase0b-` prefix or `-b` suffix where plan A wrote the same kind, so the latest-file rule never selects a plan A file for a plan B acceptance. The excluded-path check (P2-T8) is anchored on `PlanBStart`, recorded at Y3 as an evidence value, so plan A's outputs on the branch are not counted as plan B edits, while `SpecExcludedTouched` still checks the whole branch against `MB`. The one shared name is `self-review`, which the plan contract fixes; plan B writes it after plan A, so the latest `self-review.*.md` is plan B's.

## Test Plan

- Unit and integration (run only): the four `tests/scripts/harness` suites; the existing Python resource-contract tests.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/phase0b-pester-harness.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/final-pester-harness-b.<timestamp>.md`.
