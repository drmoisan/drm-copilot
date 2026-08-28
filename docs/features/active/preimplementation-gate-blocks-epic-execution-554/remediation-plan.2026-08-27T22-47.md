# Remediation Plan — issue #554, remediation cycle 1

- **Issue:** #554
- **Remediation cycle:** 1
- **Cycle timestamp:** `2026-08-27T22-47`
- **Work Mode:** `full-bug` (resolved from `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md` line 4, `- Work Mode: full-bug`)
- **Acceptance-criteria source:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, exclusively
- **Findings source:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-inputs.2026-08-27T22-47.md`
- **Supporting detail:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md`, `docs/features/active/preimplementation-gate-blocks-epic-execution-554/code-review.2026-08-27T22-47.md`
- **Working directory:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`. Every path below is relative to that worktree root.

## Purpose

Close the four Blocking findings R1 through R4 of remediation cycle 1. All four are coverage
findings and all four are closable by adding Pester `It` blocks. The remediation is **test-only**:
zero production files change.

## Evidence-Path Convention (non-overridable)

Every artifact this plan produces resolves to
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/` per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Phase 0 artifacts use the
`remediation-baseline` kind; every later artifact uses the `qa-gates` kind. No artifact is written
under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical
path.

**Filename determinism.** Every evidence artifact produced by this remediation cycle carries the
cycle timestamp `2026-08-27T22-47`, which is the identifier of remediation cycle 1 and matches this
plan's filename and the filenames of the three cycle-1 audit inputs. Filenames are therefore fixed
by this plan, and every acceptance condition below names a concrete path with no placeholder in it.
Phase 3 QC artifacts carry the `r1-` prefix so they are not confused with the pre-remediation
`final-*` set of `2026-08-27T22-24` through `2026-08-27T22-42`.

Every command-bearing task writes an artifact carrying, at minimum, the four fields `Timestamp:`,
`Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Change Budget (decision D6)

`.claude/rules/powershell.md` caps a batch at **3 production and 3 test PowerShell files**. This
remediation writes:

| Kind | Count | Files |
| --- | --- | --- |
| Production `.ps1` | **0** | none |
| Test `.ps1` | **2** | one edited, one created — enumerated below |

Zero production files and two test files fit inside a single batch. The counter at
`.claude/state/powershell-batch-budget.*.json` is reset once, at [P1-T1], before the batch begins,
exactly as the execution plan did at each of its batch boundaries. No second reset is required
because the batch never reaches either cap.

## Files Written By This Plan

**Test files (2):**

1. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` — **edited** (R1, R3). Added by this branch; not a pre-existing suite.
2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` — **created** (R2, R4). New sibling suite; see the scope note below.

**Documents:**

3. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` — two edits and no others: an amendment to the `## DECLARED BLAST RADIUS` section at [P3-T14], and checkbox state at [P3-T15]. The amendment is additive apart from **two numeral corrections** — `five` to `six` in the directory-prefix paragraph and `Four statements` to `Five statements` in the lettered-statement preamble — which are made only because the additive insertions falsify those two counts. **No criterion text is amended, and no pre-existing blast-radius entry is removed, narrowed, or reworded.**
4. Evidence artifacts under `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/`.

## Scope Note — why the Claude-side cases go in a new sibling suite

The remediation directive names
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
as the Claude-side edit target for R2 and R4. **That file cannot take them.** It stands at 494 lines
against the 500-line cap in `.claude/rules/general-code-change.md` ("No production code, test code,
or reusable script file may exceed 500 lines"), leaving six lines of headroom. R2 requires a context
of four cases plus a marker-set parity assertion and R4 requires two cases; together they are
approximately fifty lines. Even R4's single smallest case does not fit.

The resolution follows the precedent the spec itself set for exactly this situation. Its Test
Strategy states that new Claude-side cases go in a **new sibling suite** because
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` was at 461 of
500 lines and "must not grow". The same reasoning applies one level down, so the R2 and R4 cases go
in a second new Claude-side sibling,
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`.

Consequences, stated so the deviation is auditable rather than assumed:

- The count of test files written stays at **two**, so the batch budget is unaffected.
- The count of production files written stays at **zero**.
- No pre-existing suite is edited; the named mode-resolution suite is left byte-untouched, which is
  a stronger outcome than the directive required.
- Pester discovers the new file without registration: `Run.Path` in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is the directory list
  `scripts`, `tests/powershell`, `tests/scripts`. `CodeCoverage.Path` is a **production**-file
  allow-list and takes no test-file entry, so neither settings file changes and their pinned text
  parity is preserved.
- The alternative — compressing comments in the 494-line suite to free fifty lines — is rejected. It
  would churn a file that has already been reviewed, degrade documentation the repository requires,
  and risk a format or analyze restart, all to avoid an additive file that costs nothing.

[P0-T8] measures and records the 494-line figure so this decision rests on a captured measurement
rather than on this paragraph.

## Prohibitions Binding On Every Task

A task that appears to require any of the following means this plan is wrong. Stop and report the
task blocked; do not perform it.

1. **No production `.ps1` file may be edited.** The four gate-hook copies, the four modes-sibling
   copies, and the two extension-resource mirror trees stay byte-identical to their current state.
   The four `-helpers.ps1` copies stay byte-untouched.
2. **No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, and not
   `.github/copilot-instructions.md`.**
3. **No pre-existing test suite may be edited.** The six pre-existing suites must keep passing
   unmodified: the four named in the spec's Test Strategy, plus
   `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` and
   `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
4. **Issue #555 is out of scope.** The fifteen-line Codex epic/parallel decision branch at
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 426-443 is a genuinely
   D5-constrained residual. It is **recorded** as a named exception with its line range and its #555
   linkage at [P3-T9]. It is not covered, and no `Agent` envelope is fabricated on the Codex side.
5. **No acceptance-criterion text in `spec.md` is amended.** [P3-T15] may change one checkbox
   character and nothing else. [P3-T14] may make additive entries, one dated note, and the two
   numeral corrections fixed verbatim as its insertion 5 in the `## DECLARED BLAST RADIUS` section
   of the same file, and nothing else; it must not touch any acceptance criterion, must not change
   any checkbox, and must not remove, narrow, or reword any pre-existing blast-radius entry. The two
   numeral corrections change `five` to `six` and `Four statements` to `Five statements` and change
   nothing else; a numeral correction is not a narrowing, because it enlarges the stated count to
   match the enlarged list. Narrowing a declared radius to suppress a conflict edge is
   prohibited by `.claude/rules/parallel-orchestration.md`.
6. **R2 is closed test-only.** The production-side alternative — deleting the orphaned
   `Test-PreparationModeDelegation` and `$script:PreparationModeMarkers` from all four hook copies —
   is explicitly not taken. It would touch production, contradict the spec's "Not modified" list,
   and break the passing Codex legacy-contract test at
   `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lines 249-250.

## Determinism Constraints On The Test Work

Literal string fixtures only. No temporary file, no filesystem write, no wall-clock read, no network
call, no external process, and no `Mock`. Every new case calls a pure function with a constructed
string or a `[pscustomobject]` built in the case body, or calls the decision function with its
injection parameters bound.

---

### Phase 0 — Policy Reads and Remediation Baseline

- [x] [P0-T1] Read the policy files in this exact order and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-instructions-read.2026-08-27T22-47.md`: (1) `CLAUDE.md`, (2) `.claude/rules/general-code-change.md`, (3) `.claude/rules/general-unit-test.md`, (4) `.claude/rules/powershell.md`, (5) `.claude/rules/quality-tiers.md`, (6) `.claude/rules/plan-acceptance-gates.md`. Acceptance: the artifact exists and carries a `Timestamp:` field, a `Policy Order:` field, and an ordered list naming all six file paths above.
- [x] [P0-T2] Read the four requirement and finding sources — `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, `remediation-inputs.2026-08-27T22-47.md`, `policy-audit.2026-08-27T22-47.md`, and `code-review.2026-08-27T22-47.md` in the same folder — and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-requirements-sources.2026-08-27T22-47.md`. Acceptance: the artifact records `Work Mode: full-bug`, names `spec.md` as the sole acceptance-criteria source, quotes the single unchecked acceptance criterion verbatim, and lists the four Blocking findings R1 through R4 by identifier.
- [x] [P0-T3] Capture the revision anchors with `git rev-parse HEAD` and `git merge-base HEAD 1e991b86d78e4f979922b79268f19ca0e5ab19e3`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-revision-anchors.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the artifact records the full 40-character branch-head SHA, and it records that the merge base resolves to `1e991b86d78e4f979922b79268f19ca0e5ab19e3` — the same merge base the pre-remediation coverage-delta artifact used, so the changed-line sets remain comparable.
- [x] [P0-T4] Run the PowerShell formatting stage against the worktree root and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-format.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the reformatted-file count as an integer, established from a `git status --porcelain` listing taken immediately after the run.
- [x] [P0-T5] Run the PowerShell analyze stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCAnalyze -Root (Get-Location).Path`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-analyze.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the total analyzer finding count as an integer.
- [x] [P0-T6] Run the coverage-bearing baseline test stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-test-coverage.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the recorded failed-test count is the integer 0, and `Output Summary:` records the numeric passed-test count and the numeric repository-wide LINE coverage percentage read from the LINE counter at the report root of `artifacts/pester/powershell-coverage.xml`. The Pester headline is instruction coverage and must not be recorded as the line figure. Pester measures no branch coverage, so no branch figure is recorded and none is required.
- [x] [P0-T7] From the same `artifacts/pester/powershell-coverage.xml` produced by [P0-T6], build the per-file uncovered-line inventory for the four production files of this change and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-uncovered-inventory.2026-08-27T22-47.md`. Acceptance: the artifact records, for each of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, the covered count, the missed count, and the explicit list of uncovered line numbers; and it states for each of the four remediation targets whether the target lines are currently uncovered — `.codex/…-modes.ps1` line 197 and the bodies of `Find-OrchestrationDelegationTargetFolder` and `Find-OrchestrationDelegationIssueNumber` (R1); `.claude/…gate.ps1` lines 170 through 185 (R2); `.codex/…gate.ps1` lines 352 and 353 (R3); `.claude/…gate.ps1` line 210 (R4).
- [x] [P0-T8] Record the current line counts and 500-line-cap headroom for the two mode-resolution suites with `(@(Get-Content -LiteralPath $f)).Count` over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-test-suite-line-counts.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, both counts are recorded as integers with their headroom against 500, and the artifact states whether the Claude suite has room for the approximately fifty lines R2 and R4 require. This measurement is the evidence for the Scope Note above.

---

### Phase 1 — Batch-Budget Reset and the Codex Coverage Cases (R1, R3)

All edits in this phase target
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`,
which was added by this branch and is therefore not a pre-existing suite. Every new case calls a
function that takes a `[string]` and returns a `[string]`. No `Agent` envelope is constructed and no
transport is claimed, so decision D5's prohibition is not engaged; these are the same category as
the suite's existing `mode resolution parity` cases.

- [x] [P1-T1] Reset the PowerShell per-batch budget counter by deleting every file matching `.claude/state/powershell-batch-budget.*.json` with `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' | Remove-Item -Force`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-batch-budget-reset.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the artifact records the before-count and after-count as integers, and the after-count is the integer 0.
- [x] [P1-T2] In the `Context 'mode resolution parity'` of the Codex suite, add one `It` named `returns an empty checkpoint path for a mode name that is not in the table` whose body asserts `Get-OrchestrationDelegationCheckpointPath -Mode 'invented-mode' | Should -Be ''`. This is the Codex counterpart of the Claude case at line 187 of the Claude mode-resolution suite and covers the unknown-mode `return ''` at line 197 of `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`. Acceptance: the Codex suite defines exactly one `It` with that name and the file's `It` count rises by one.
- [x] [P1-T3] Add a new `Context 'target folder resolution parity'` to the Codex suite holding four `It` blocks that call `Find-OrchestrationDelegationTargetFolder` with literal prompts: `returns nothing for a prompt carrying no feature-folder token` asserting `Should -BeNullOrEmpty`; `returns the parent basename for a token ending in a Markdown file` asserting the result `Should -Be 'child-b-301'` for a prompt naming a plan file inside `docs/features/active/child-b-301`; `returns the basename for a bare directory token` asserting `Should -Be 'child-b-301'` for a prompt whose token carries no trailing punctuation; and `returns the basename for a token followed by sentence punctuation` asserting `Should -Be 'child-b-301'` for a prompt whose token is followed by a period, which exercises the trailing-punctuation strip. Acceptance: the Codex suite defines exactly one `It` with each of those four names and the file's `It` count rises by four.
- [x] [P1-T4] Add to the same `Context 'target folder resolution parity'` three `It` blocks that call `Find-OrchestrationDelegationIssueNumber` with literal prompts: `returns nothing for a prompt carrying no issue number` asserting `Should -BeNullOrEmpty`; `returns the numeric string for a keyed issue number` asserting `Should -Be '301'` for the keyed form; and `returns the numeric string for a bare-hash issue number` asserting `Should -Be '301'` for the bare-hash form. These mirror the Claude cases at lines 233 through 242 of the Claude mode-resolution suite. Acceptance: the Codex suite defines exactly one `It` with each of those three names and the file's `It` count rises by three.
- [x] [P1-T5] Add a new `Context 'the mode deny-reason builder'` to the Codex suite holding two `It` blocks that call `Get-OrchestrationModeDenyReason`, closing R3 against lines 352 and 353 of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`. The first, named `builds an epic deny reason naming the epic checkpoint and the failed predicate`, calls it with `-Mode 'epic' -Failure 'target-record'` and asserts the returned string satisfies three conditions: `Should -BeLike 'PREIMPLEMENTATION_GATE_BLOCKED:*'`, `Should -BeLike '*artifacts/orchestration/epic-orchestrator-state.json*'`, and `Should -BeLike "*'target-record'*"`. The second, named `builds a parallel deny reason naming the parallel checkpoint and the failed predicate`, calls it with `-Mode 'parallel' -Failure 'items'` and asserts the same prefix condition plus `Should -BeLike '*artifacts/orchestration/parallel-orchestrator-state.json*'` and `Should -BeLike "*'items'*"`. Acceptance: the Codex suite defines exactly one `It` with each of those two names and the file's `It` count rises by two.
- [x] [P1-T6] Run the Codex suite alone with `Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 -Output Detailed` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-suite-run.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the failed-test count is the integer 0, and `Output Summary:` lists all ten `It` names added by [P1-T2] through [P1-T5] with result Passed.
- [x] [P1-T7] Record the post-edit line count of the Codex suite with `(@(Get-Content -LiteralPath 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1')).Count` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-suite-line-count.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and the recorded count is an integer at or below 500.

---

### Phase 2 — The Claude Classifier Coverage Cases (R2, R4)

All work in this phase targets the new file
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`. The
existing Claude mode-resolution suite is left byte-untouched, for the reason recorded in the Scope
Note.

- [x] [P2-T1] Create `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` with the repository's standard `#Requires` lines, a comment-based header stating that the suite covers the classifier and preparation-mode functions of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` for issue #554 remediation cycle 1 and that it is a new sibling because the mode-resolution suite has no headroom under the 500-line cap, a single `Describe`, and a `BeforeAll` that dot-sources `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` through `$PSScriptRoot`-relative `Resolve-Path` calls. In that file add a `Context 'the preparation-mode delegation predicate'` holding four `It` blocks that call `Test-PreparationModeDelegation` directly, closing R2 against lines 170 through 185: `returns false for a null tool input` asserting `Test-PreparationModeDelegation -ToolInput $null | Should -BeFalse`, which is the null-tolerance contract the spec pins at decision D2; `returns false for a non-orchestrator subagent type carrying both preparation markers` asserting `Should -BeFalse` for a `[pscustomobject]` whose `subagent_type` is `task-researcher` and whose `prompt` carries both markers; `returns false for an orchestrator carrying only one preparation marker` asserting `Should -BeFalse`; and `returns true for an orchestrator carrying both preparation markers` asserting `Should -BeTrue`. Acceptance: the file exists, defines exactly one `It` with each of those four names, and contains no `Mock`, no temporary-file creation, and no filesystem write.
- [x] [P2-T2] Add to the same file a `Context 'the duplicated preparation-marker rule'` holding one `It` named `pins the preparation marker set equal to the preparation row of the mode table`, which selects the row whose `Mode` is `preparation` from `$script:OrchestrationDelegationModeTable` and asserts `Compare-Object $script:PreparationModeMarkers $preparationRow.Markers | Should -BeNullOrEmpty`. This closes the secondary concern recorded with R2: retaining the orphaned function leaves the preparation-marker rule with two independent implementations in the same file and nothing enforcing that they stay in step. Acceptance: the file defines exactly one `It` with that name and its body references both `$script:PreparationModeMarkers` and `$script:OrchestrationDelegationModeTable`.
- [x] [P2-T3] Add to the same file a `Context 'the classifier allow branch for a non-orchestrator agent'` holding one `It` named `does not classify a non-orchestrator agent as an implementation delegation`, which builds a `[pscustomobject]` whose `subagent_type` is `task-researcher` and whose `prompt` contains both legacy free-text tokens, and asserts `Test-ImplementationDelegation -ToolInput $toolInput | Should -BeFalse`. This closes R4 against line 210 of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, the one uncovered added line the four-group characterization did not account for; including the legacy tokens in the prompt also documents the Fault-1 fix in the widening direction. Acceptance: the file defines exactly one `It` with that name.
- [x] [P2-T4] Add to the same `Context` one further `It` named `allows a non-orchestrator delegation against an unready single-feature checkpoint`, which passes a full `Agent` delegation envelope whose `subagent_type` is `task-researcher` to `Invoke-OrchestrationPreimplementationGateDecision` together with an explicitly bound unready single-feature `-CheckpointRaw` value, and asserts `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`. The checkpoint must be bound explicitly: an unbound value falls through to the on-disk checkpoint, which is ready during an orchestrated run, and the assertion would pass vacuously. This closes the non-blocking gap N4 by asserting the spec-sanctioned permissive widening at the decision level rather than leaving it implicit. Acceptance: the file defines exactly one `It` with that name and its body binds `-CheckpointRaw` explicitly.
- [x] [P2-T5] Run the new suite alone with `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 -Output Detailed` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-claude-classifier-suite-run.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the failed-test count is the integer 0, and `Output Summary:` lists all seven `It` names added by [P2-T1] through [P2-T4] with result Passed.
- [x] [P2-T6] Record the line count of the new suite with `(@(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1')).Count` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-claude-classifier-line-count.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and the recorded count is an integer at or below 500.

---

### Phase 3 — Final PowerShell QC Loop, Coverage Verification, and Closeout

Tasks [P3-T1] through [P3-T4] are the mandatory PowerShell toolchain loop in the order format,
analyze, test. Type checking is not applicable to PowerShell and is recorded rather than run.
**If any of those stages fails, or changes any file on disk, restart the loop at [P3-T1]** and
record the new iteration number in each re-issued artifact. The loop is complete only when format,
analyze, and test all pass in a single uninterrupted pass in which no stage changed a file.

- [ ] [P3-T1] Run the PowerShell formatting stage against the worktree root and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-final-poshqc-format.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the reformatted-file count as the integer 0, established from a `git status --porcelain` listing taken immediately after the run that names no `.ps1` file the stage rewrote. A non-zero count restarts the loop at this task.
- [ ] [P3-T2] Run the PowerShell analyze stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCAnalyze -Root (Get-Location).Path`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-final-poshqc-analyze.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and the recorded total finding count is the integer 0. A non-zero count, or any file changed by the stage, restarts the loop at [P3-T1].
- [ ] [P3-T3] Record that the type-checking stage is not applicable to PowerShell in `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-final-typecheck-not-applicable.2026-08-27T22-47.md`, citing `.claude/rules/powershell.md`. Acceptance: the artifact exists, carries `Timestamp:` and `Output Summary:`, cites the rule file by path, and records `EXIT_CODE: 0` with `Command:` stating that no type-check command exists for this language.
- [ ] [P3-T4] Run the coverage-bearing final test stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-final-poshqc-test-coverage.2026-08-27T22-47.md`. This is the self-hosted invocation, not the MCP test runner, because the MCP runner reads its settings from the installed extension and would ignore the two `CodeCoverage.Path` entries this feature registered. Acceptance: `EXIT_CODE:` is 0, the recorded failed-test count is the integer 0, the recorded passed-test count exceeds the [P0-T6] baseline passed count by at least 17 — the ten cases of Phase 1 plus the seven of Phase 2 — and `Output Summary:` records the numeric repository-wide LINE coverage read from the LINE counter at the report root of `artifacts/pester/powershell-coverage.xml`, with that value at or above 85. A failure restarts the loop at [P3-T1].
- [ ] [P3-T5] Confirm the single-pass property of the loop and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-final-single-pass-confirmation.2026-08-27T22-47.md`. Acceptance: the artifact records the loop iteration number of the passing pass, records the four artifact paths of [P3-T1] through [P3-T4] in monotonic capture order, and states that no stage in that pass failed and no stage changed a file.
- [ ] [P3-T6] From the `artifacts/pester/powershell-coverage.xml` produced by [P3-T4], verify the R1 outcome for `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-modes-coverage.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the artifact records the file's covered and missed line counts as integers, the missed count is the integer 2, and the two remaining uncovered lines are the `Write-Debug` catch at lines 94 and 95, which is the accepted residual. Line 197 and the bodies of `Find-OrchestrationDelegationTargetFolder` and `Find-OrchestrationDelegationIssueNumber` are recorded as covered.
- [ ] [P3-T7] From the same report, verify the R2 and R4 outcomes for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-claude-gate-coverage.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, every line from 170 through 185 that the report emits a line element for is recorded as covered, line 210 is recorded as covered, and the artifact records the file's line-coverage percentage as a numeric value together with its movement from the [P0-T7] baseline.
- [ ] [P3-T8] From the same report, verify the R3 outcome for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-codex-gate-coverage.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, lines 352 and 353 are recorded as covered, the artifact records the file's line-coverage percentage as a numeric value, and it records the remaining uncovered line numbers so the residual set is explicit.
- [ ] [P3-T9] Write the re-issued coverage-delta artifact at `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/coverage-delta.2026-08-27T22-47.md`, superseding `coverage-delta.2026-08-27T22-36.md`, which is retained. It must satisfy all six conditions below. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and satisfies every one of the following.
  1. **Corrected per-group counts.** The four-group characterization of the 63 uncovered added lines is restated with the corrected measurable-line counts **16 / 3 / 39 / 4**, replacing the previously stated 18 / 3 / 40 / 2. The total of 63 was correct and is unchanged. The artifact must state that the four corrected group counts sum to 62 and that the remaining single line is `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 210, which the earlier four-group characterization did not account for and which R4 has now closed. That reconciliation is what makes 62 plus 1 equal the correct total of 63.
  2. **Group 1, named exception — the injected read seams (16 measurable lines).** `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` bodies on both surfaces, at `.claude/…gate.ps1` lines 266-270 and 278-282 and `.codex/…gate.ps1` lines 292-296 and 304-308. Reason: real filesystem I/O. The injection seam exists so the decision logic is testable without touching the filesystem, as `.claude/rules/general-unit-test.md` requires; covering these would require reading the live checkpoint, which would additionally make several allow assertions pass vacuously.
  3. **Group 2, named exception — two distinct causes, 3 measurable lines.** `.claude/…gate.ps1` line 408 is the non-injected `else` arm of the mode-checkpoint selector (`} elseif ($isEpic) { Get-EpicCheckpointContent } else { Get-ParallelCheckpointContent }`): same seam, same reason as group 1, because every Claude decision-level case binds its injection parameter. `.codex/…gate.ps1` lines 421-422 are **not** that arm — they are the `declared-checkpoint-path` deny return. The Codex non-injected `else` arm is line 430, already counted inside the 426-443 residual of condition 5. Lines 421-422 are uncovered for the decision-D5 transport reason, the same reason as group 3, because no Codex case can reach `Invoke-OrchestrationPreimplementationGateDecision`'s mode branches. The group membership and the count of 3 are unchanged; only the stated cause is corrected. The superseded coverage-delta artifact carries the incorrect cause in two places — its Group 2 heading at line 102, which names the group "the non-injected fallback branch", and its cause sentence at line 110, which states that the lines are "the `else` arm of the same injection seam and is uncovered for the identical reason". Its line 104 is the line list and is accurate. This artifact corrects both the heading and the cause sentence.
  4. **Group 4, named exception — the debug-only catch (4 measurable lines).** `Get-OrchestrationModeProperty` at lines 94-95 of both `-modes.ps1` copies. Reason: the catch fires only when `PSObject.Properties` itself throws, which no JSON-derived object produces.
  5. **The one shipping exception, tied to issue #555.** The residual of former group 3 after R1 and R3 is exactly the epic/parallel decision branch at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **lines 426 through 443, 15 measurable lines**. It must be stated by name, with that line range, with the reason that driving it requires constructing a delegation payload for the Codex decision function, which decision D5 prohibits because `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name; and with an explicit linkage to **issue #555**, which owns the transport gap. It must be stated as its own named exception and must not be absorbed into an aggregate. The artifact must state the resulting file-level line-coverage figure for that file and that it is the one coverage exception this feature ships with.
  6. **Post-remediation numbers.** Baseline repository-wide line coverage from [P0-T6], post-remediation repository-wide line coverage from [P3-T4], the four per-file figures, and the post-remediation count of uncovered changed lines in each of the two modified hooks, all as numeric values, computed against the merge base recorded at [P0-T3].
- [ ] [P3-T10] Verify that the six pre-existing suites are unmodified and passing, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-preexisting-suites.2026-08-27T22-47.md`. The six are `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Acceptance: `EXIT_CODE:` is 0, a `git diff --name-only` listing against the branch head recorded at [P0-T3] names none of the six, and the [P3-T4] run reports zero failures in all six.
- [ ] [P3-T11] Verify the test-only scope invariant and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-no-production-change.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, and the union of a `git diff --name-only` listing against the branch head recorded at [P0-T3] and a `git ls-files --others --exclude-standard` listing contains exactly two paths ending in `.ps1` — the Codex mode-resolution suite edited in Phase 1 and the Claude classifier suite created in Phase 2 — and contains no path under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/resources/`. The untracked listing is part of the union because no task in this plan stages or commits anything, so the Claude classifier suite created in Phase 2 is untracked at this point and a diff listing alone would not name it; the two-dot diff against the branch head already observes uncommitted working-tree changes to tracked files, so only the untracked set has to be added. The artifact must state explicitly that the four `-helpers.ps1` copies are byte-untouched and that the pre-existing Claude mode-resolution suite is byte-untouched.
- [ ] [P3-T12] Verify the policy-path invariant and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-policy-paths-untouched.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0 and the union of a `git diff --name-only` listing against the merge base recorded at [P0-T3] and a `git ls-files --others --exclude-standard` listing contains no path beginning with `.claude/rules/`, no path beginning with `.claude/skills/`, and no path beginning with `.github/`. The untracked listing is part of the union so that a newly created, never-staged file under one of those three prefixes is observed; the two-dot diff against the merge base already observes uncommitted working-tree changes to tracked files, so only the untracked set has to be added.
- [ ] [P3-T13] Re-verify the four mirrored production pairs with `Get-FileHash -Algorithm SHA256` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-mirror-pair-hashes.2026-08-27T22-47.md`. Acceptance: `EXIT_CODE:` is 0, the artifact records four pair hashes, each pair's two hashes are equal, and each of the four hashes equals the value recorded in the pre-remediation artifact `final-mirror-pair-hashes.2026-08-27T22-42.md`, confirming that this remediation changed no production byte.
- [ ] [P3-T14] Amend the `## DECLARED BLAST RADIUS` section of `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` so that the section names every path this branch writes, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-blast-radius-amendment.2026-08-27T22-47.md`. The amendment is **additive apart from two numeral corrections** and consists of exactly the five insertions whose verbatim text is fixed in the fenced blocks below this task; nothing about the wording is left to executor discretion. Insertion 1 appends one bullet to the end of the existing `### Tests — new` list. Insertion 2 appends five bullets to the existing `### Feature documents and evidence` list, immediately after its `plan.2026-08-26T08-40.md` bullet and before its `research/` bullet. Insertion 3 appends one lettered statement and one dated note at the end of the section, immediately after the existing `(d)` paragraph and before the section's closing horizontal rule. Insertion 4 appends one bullet to the same `### Feature documents and evidence` list, immediately after its `evidence/baseline/` bullet, declaring the `evidence/remediation-baseline/` directory prefix that all eight Phase 0 artifacts of this plan are written under; the section as it stands declares five `evidence/` prefixes and does not declare that one, so without insertion 4 the zero-UNDECLARED condition below cannot be satisfied. Insertion 5 makes exactly two numeral corrections and no others, because insertions 3 and 4 falsify two count statements in the section: in the directory-prefix paragraph `five` becomes `six`, since insertion 4 raises the `evidence/` entry count from five to six; and in the lettered-statement preamble `Four statements about this list` becomes `Five statements about this list`, since insertion 3 adds statement `(e)`. Neither correction removes, narrows, or rewords any entry, and neither touches any other word of either sentence. Acceptance: `EXIT_CODE:` is 0; the artifact records the union of `git diff --name-only origin/main...HEAD`, `git diff --name-only HEAD`, and `git ls-files --others --exclude-standard`, and, for every path in that union, the blast-radius entry or directory prefix that covers it, with **zero** paths carrying an UNDECLARED verdict — the union is required because no task in this plan stages or commits anything, so a three-dot listing alone would exclude precisely the untracked and unstaged paths these insertions exist to declare and the verdict would be vacuous for all of them; the artifact confirms that the section's pre-existing entries — the four `### ` sub-lists as they stood, the directory-prefix paragraph, and the lettered statements `(a)` through `(d)` — are byte-identical to their pre-amendment text **except for the two numeral corrections of insertion 5**, with none removed, narrowed, or reworded, and with no other character of any pre-existing entry changed; and the artifact confirms that no line under the `## Acceptance Criteria` heading of `spec.md` changed and that no checkbox character in the file changed, evidenced by `git diff HEAD -- docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` — the working-tree-against-`HEAD` base, not a base against `origin/main`, because `spec.md` is an added file relative to `origin/main` and every one of its lines would be an addition under that base — whose only hunks fall inside the `## DECLARED BLAST RADIUS` section.

  Insertion 1, appended as the third bullet of `### Tests — new`:

  ```text
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`
  ```

  Insertion 2, appended to `### Feature documents and evidence` in this order:

  ```text
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/code-review.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/feature-audit.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-inputs.2026-08-27T22-47.md`
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-plan.2026-08-27T22-47.md`
  ```

  Insertion 3, appended at the end of the section as two paragraphs, reproduced byte-for-byte:

  ```text
  **(e)** Root-level review and remediation artifacts of this feature folder are in this radius:
  the timestamp-bearing `policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`, and
  `remediation-plan` Markdown files written directly under
  `docs/features/active/preimplementation-gate-blocks-epic-execution-554/`. The five concrete
  cycle-1 files are enumerated above; this rule covers any later cycle's set, which differs from
  the cycle-1 set only in its timestamp.

  **Amendment, 2026-08-27.** Three additions and two numeral corrections were made to this section
  after the cycle-1 review. The classifier test suite was added because the named Claude-side edit
  target
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
  stood at 494 lines against the 500-line cap in `.claude/rules/general-code-change.md`, leaving six
  lines of headroom against the roughly fifty lines the remaining cases require, so those cases went
  into a new sibling suite. The five root-level artifacts were added because a `full-bug`
  review-and-remediation cycle necessarily produces them. The
  `evidence/remediation-baseline/` prefix was added because the remediation cycle writes its Phase 0
  baseline artifacts there and the section previously declared only the five other `evidence/`
  prefixes. All three are genuine writes, and
  `.claude/rules/parallel-orchestration.md` states that the planner remains obliged to enumerate a
  genuine write explicitly and to append that exact path to the declared radius after normalization.
  The two numeral corrections are consequences of those additions and nothing else: the `evidence/`
  entry count reads six rather than five, and this list of lettered statements reads five rather than
  four. Apart from those two numerals the amendment is additive: no pre-existing entry is removed,
  narrowed, or reworded, and no acceptance criterion and no checkbox is touched. Narrowing a radius
  to suppress a conflict edge is prohibited by the same rule file.
  ```

  Insertion 4, appended to `### Feature documents and evidence` immediately after its
  `evidence/baseline/` bullet:

  ```text
  - `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/`
  ```

  Insertion 5, exactly two numeral corrections and no others. Each pair below gives the exact
  existing line and its replacement; the `BEFORE:` and `AFTER:` labels are not part of the file text
  and every other character of each line is unchanged:

  ```text
  BEFORE: The `research/` entry and the five `evidence/` entries are directory prefixes, not files; the
  AFTER:  The `research/` entry and the six `evidence/` entries are directory prefixes, not files; the

  BEFORE: Four statements about this list, made explicitly because a parent process computes conflict edges
  AFTER:  Five statements about this list, made explicitly because a parent process computes conflict edges
  ```
- [ ] [P3-T15] Re-evaluate the single unchecked acceptance criterion in `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` — the criterion reading that line coverage across the PowerShell suite remains at or above 85 percent and that no changed line in either modified hook loses coverage — against the evidence produced by [P3-T4], [P3-T7], [P3-T8], and [P3-T9], and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`. Check the box **only** if both clauses are genuinely satisfied: the repository-wide line-coverage value is at or above 85, and the `.claude` modified hook carries no uncovered changed line outside the accepted read-seam residual while the `.codex` modified hook's remaining uncovered changed lines are confined to the named issue #555 exception recorded at [P3-T9] condition 5. If that judgement does not hold, leave the box unchecked and record the residual as an escalated shipping exception. Acceptance: the artifact states the verdict, cites the numeric evidence for each clause, records whether the checkbox was changed, and confirms that the criterion's text is byte-identical to its pre-remediation text. **No criterion text may be amended under any outcome.**
- [ ] [P3-T16] Write the remediation closeout summary at `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-remediation-closeout.2026-08-27T22-47.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; records a per-finding disposition line for each of R1, R2, R3, and R4 naming the closing task IDs and the evidence artifact that proves closure; records the accepted residuals by group with the corrected counts 16 / 3 / 39 / 4 and the reconciling line 210; records the issue #555 exception with its line range 426-443; states that zero production files changed; and states the Scope Note deviation, namely that the Claude-side cases were placed in the new sibling suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` because the named target file stood at the line count [P0-T8] recorded, with six lines of headroom against the 500-line cap.

---

## Task-Count Summary

| Phase | Tasks | Purpose |
| --- | --- | --- |
| 0 | 8 | Policy reads and remediation baseline |
| 1 | 7 | Budget reset, R1 and R3 on the Codex suite |
| 2 | 6 | R2 and R4 on the new Claude classifier suite |
| 3 | 16 | Final QC loop, coverage verification, re-issued coverage-delta, scope invariants, blast-radius amendment, criterion re-evaluation |
| **Total** | **37** | |
