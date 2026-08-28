# Remediation Plan — issue #554, remediation cycle 2

- **Issue:** #554
- **Remediation cycle:** 2
- **Cycle timestamp:** `2026-08-28T00-30`
- **Work Mode:** `full-bug` (resolved from `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md`, `- Work Mode: full-bug`)
- **Acceptance-criteria source:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, exclusively
- **Findings source:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-inputs.2026-08-28T00-30.md`
- **Supporting detail:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-28T00-30.md`
- **Branch:** `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `540988b3`; fixed cycle-1 comparison anchor `1e991b86`, which is still an ancestor of `HEAD`. This branch has since merged `origin/main`, so `git merge-base HEAD origin/main` now resolves to `c62af7a7`; that value is **not** the comparison anchor and no task in this plan uses it as one.
- **Working directory:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`. This is an adopted worktree, not the session root. Every path below is relative to that worktree root.

## Purpose

Close the single Blocking finding **B5** of remediation cycle 2. B5 has two components:

1. **A two-line coverage gap.** Lines 197 and 206 of
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — the non-`orchestrator`
   `return $false` branch and the all-conjuncts-hold `return $true` of
   `Test-PreparationModeDelegation` — are uncovered. Both were **covered at the merge base**
   `1e991b86` through merge-base line 213 inside `Test-ImplementationDelegation`, which called the
   predicate. This branch removed that call site, orphaning the function on both surfaces. This is
   the same defect class as cycle-1 finding B2, on the other surface, at two lines instead of ten.
2. **Three propagated statements of a false fact.** Three locations assert that Codex lines 197 and
   206 were uncovered at the merge base. They were covered.

The remediation is **test-only and documentation-only**: zero production files change.

Decision D5 raises no obstacle to component 1. `Test-PreparationModeDelegation` takes a
`[pscustomobject]` and returns a `[bool]`, constructs no `Agent` envelope, claims no transport, and
is already called directly by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

## Evidence-Path Convention (non-overridable)

Every artifact this plan produces resolves to
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/` per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Phase 0 artifacts use the
`remediation-baseline` kind; every later artifact uses the `qa-gates` kind. No artifact is written
under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, or any
other non-canonical path.

The calling agent supplied **no** non-canonical evidence path, so no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is required for this cycle.

**Filename determinism.** Every evidence artifact produced by this cycle carries the cycle timestamp
`2026-08-28T00-30`, matching this plan's filename and the filenames of the cycle-2 audit inputs.
Phase 1 through Phase 3 artifacts carry the `r2-` prefix so they are never confused with the cycle-1
`r1-` set. Filenames are therefore fixed by this plan and every acceptance condition below names a
concrete path with no placeholder in it.

Every command-bearing task writes an artifact carrying, at minimum, the four fields `Timestamp:`,
`Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Measured Preconditions (recorded, then re-measured at Phase 0)

| Fact | Value measured while authoring this plan | Re-measured at |
| --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` line count | **302** of 500; **198 lines of headroom** | [P0-T8] |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` line count | **154** of 500; **346 lines of headroom** | [P0-T8] |
| Files matching `.claude/state/powershell-batch-budget.*.json` | **0** present | [P1-T1] |

The Codex suite's 198 lines of headroom comfortably accommodate the roughly 24 lines the two cases
of Phase 1 require, so **no new test file is needed and none is created**. Had the headroom been
insufficient, this plan would have reported the task blocked rather than inventing a sibling file;
that contingency did not arise. [P0-T8] re-measures both counts so the decision rests on a captured
measurement rather than on this paragraph.

## Change Budget

`.claude/rules/powershell.md` caps a batch at **3 production and 3 test PowerShell files**. This
remediation writes:

| Kind | Count | Files |
| --- | --- | --- |
| Production `.ps1` | **0** | none |
| Test `.ps1` | **2** | both edited, both created by this branch — enumerated below |

Zero production files and two test files fit inside a single batch. The counter at
`.claude/state/powershell-batch-budget.*.json` is reset once, at [P1-T1], before the batch begins,
exactly as cycle 1 did at its batch boundary. No second reset is required because the batch never
reaches either cap.

## Files Written By This Plan

**Test files (2), both created by this branch and therefore not pre-existing suites:**

1. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` — **edited** (B5 component 1, two `It` blocks).
2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` — **edited** (B5 component 2, one comment block corrected in place).

**Documents (2 appended, both retained-as-superseded):**

3. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md` — one appended correction notice.
4. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` — one appended correction notice.

**Evidence artifacts** under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/`, including the
re-issued `evidence/qa-gates/coverage-delta.2026-08-28T00-30.md`.

**`spec.md` is not written by this plan at all.** No criterion text is amended, no checkbox changes,
and no blast-radius entry is added, because statement `(e)` of the `## DECLARED BLAST RADIUS` section
already forward-declares any later cycle's root-level artifact set and the six `evidence/` directory
prefixes are already declared. [P3-T14] verifies that rather than assuming it, and [P3-T15] carries
the additive amendment that would be required only if that verification found an undeclared path.

## Correction Approach — appended notice versus in-place rewrite

The three sites of the false factual claim are corrected by two different methods, and the choice is
stated per site so that the audit trail is deliberate rather than incidental.

| Site | Method | Why |
| --- | --- | --- |
| `policy-audit.2026-08-27T22-47.md` (line 173 and its derived-baseline figure at line 181) | **Appended, clearly-marked, dated correction notice.** The original text is left byte-untouched. | This is a superseded evidence artifact. Rewriting it would erase what the cycle-1 reviewer believed and when, which is precisely the audit information a review record exists to preserve. The cycle-1 reviewer has already stated the correction in `policy-audit.2026-08-28T00-30.md`; the task here is to stop the superseded artifact standing silently, not to revise history. |
| `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` (lines 100-102) | **Appended, clearly-marked, dated correction notice.** The original text is left byte-untouched. | Same reasoning. This artifact is additionally the auditable justification for an acceptance-criterion check-off, so the sequence of belief and correction is load-bearing. The notice explicitly upholds the artifact's verdict; only the third argument's second half is withdrawn. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` line 82 | **In-place rewrite of the comment block.** | This is live source, not an evidence artifact. A source comment has no audit-trail function and its only job is to be true for a reader of the current file; appending a contradicting notice below a false comment would leave the false statement standing in the file. The file is editable: this branch created it. The git history preserves the superseded text. |

## Prohibitions Binding On Every Task

A task that appears to require any of the following means this plan is wrong. Stop and report the
task **blocked**; do not perform it.

1. **No production `.ps1` file may be edited.** The four gate-hook copies, the four modes-sibling
   copies, and both `extensions/drm-copilot/resources/` mirror trees stay byte-identical to their
   current state. The four `-helpers.ps1` copies stay byte-untouched.
2. **No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, and not
   `.github/copilot-instructions.md`.**
3. **No pre-existing test suite may be edited.** The six pre-existing suites must keep passing
   unmodified: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`,
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`,
   `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`,
   `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`,
   `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, and
   `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Only the two suites this
   branch created are editable.
4. **Issue #555 stays out of scope.** The fifteen-line Codex epic/parallel decision branch at
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 426-443 is a recorded,
   accepted shipping exception. It is not covered, and no `Agent` envelope is fabricated on the
   Codex side. After B5 closes, that file reaches **84.57 percent**, still below the 85 percent
   uniform threshold, so the named exception persists and must be preserved by name, line range, and
   #555 linkage in the re-issued coverage-delta artifact at [P3-T7].
5. **No acceptance-criterion text in `spec.md` is amended and no checkbox is changed.** All 35
   criteria are checked and all 35 evaluate PASS. The cycle-1 reviewer confirmed B5 concerns
   **unchanged** lines and unseats no criterion. [P3-T13] verifies `spec.md` is byte-untouched by
   this cycle.
6. **`[P6-T6]` in `plan.2026-08-26T08-40.md` stays unchecked.** Both reviewers ruled that the honest
   disposition. No task checks it, rewords it, or deletes it. [P3-T13] verifies it is still
   unchecked.
7. **B5 is closed test-only.** The production-side alternative — deleting the orphaned
   `Test-PreparationModeDelegation` and `$script:PreparationModeMarkers` from all four hook copies —
   is explicitly not taken. It would touch production, contradict the spec's "Not modified" list,
   and break the passing Codex legacy-contract test. It is recorded as non-blocking item N9 for a
   follow-up refactor.

## Determinism Constraints On The Test Work

Literal string fixtures only. No temporary file, no filesystem write, no wall-clock read, no network
call, no external process, and no `Mock`. Each new case calls a pure predicate with a
`[pscustomobject]` built in the case body.

## Recorded Non-Additions

`remediation-inputs.2026-08-28T00-30.md` names two further cases and one assertion as *recommended
for symmetry* rather than required. This plan **does not add them**, and the omission is recorded so
it is a decision rather than an oversight:

- `-ToolInput $null` returns `$false`, and an `orchestrator` with only one marker returns `$false`.
  Both branches are **already covered on the Codex surface** by the two surviving direct callers in
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, so neither case closes a line.
  Adding them would enlarge a scope the caller fixed at two `It` blocks without changing any
  measured outcome.
- The marker-parity assertion `Compare-Object $script:PreparationModeMarkers $preparationRow.Markers`
  is pinned on the Claude surface by the classifier suite. Mirroring it on the Codex surface is a
  genuine improvement but is not required to close B5, and the same scope argument applies.

Both are recorded as optional follow-ups alongside non-blocking item N9, which proposes removing the
orphaned function outright and would make all four cases moot.

---

### Phase 0 — Policy Reads and Remediation Baseline

- [x] [P0-T1] Read the policy files in this exact order and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-instructions-read.2026-08-28T00-30.md`: (1) `CLAUDE.md`, (2) `.claude/rules/general-code-change.md`, (3) `.claude/rules/general-unit-test.md`, (4) `.claude/rules/powershell.md`, (5) `.claude/rules/quality-tiers.md`, (6) `.claude/rules/plan-acceptance-gates.md`, (7) `.claude/rules/tonality.md`. Acceptance: the artifact exists and carries a `Timestamp:` field, a `Policy Order:` field, and an ordered list naming all seven file paths above.
- [x] [P0-T2] Read the three requirement and finding sources — `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, `remediation-inputs.2026-08-28T00-30.md`, and `policy-audit.2026-08-28T00-30.md` in the same folder — and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-requirements-sources.2026-08-28T00-30.md`. Acceptance: the artifact records `Work Mode: full-bug`, names `spec.md` as the sole acceptance-criteria source, records the count of checked acceptance criteria in `spec.md` as the integer 35 and the count of unchecked criteria as the integer 0, and lists B5 as the single Blocking finding with its two components.
- [x] [P0-T3] Capture the revision anchors with `git rev-parse HEAD`, `git merge-base HEAD origin/main`, and `git merge-base --is-ancestor 1e991b86d78e4f979922b79268f19ca0e5ab19e3 HEAD`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-revision-anchors.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 for all three commands; the artifact records the full 40-character branch-head SHA; it records the fixed cycle-1 comparison anchor `1e991b86d78e4f979922b79268f19ca0e5ab19e3` together with the outcome of the `git merge-base --is-ancestor` check confirming that anchor is still an ancestor of `HEAD`, so the changed-line sets stay directly comparable with cycle 1; and it records, in a separately headed statement, that `git merge-base HEAD origin/main` now resolves to `c62af7a71eb2dbc8c8086c9cbf1c30c22551590a` because this branch merged `origin/main`, and that this value is **not** the comparison anchor. The anchor is pinned as the constant `1e991b86d78e4f979922b79268f19ca0e5ab19e3` and verified by ancestry; it is never recomputed from `git merge-base`, because the merge moved the merge base while leaving the anchor valid. Every later task that needs the comparison anchor — `[P3-T7]` item 6 in particular, whose 9-and-25 uncovered-changed-line counts are computed against it — reads the pinned constant, not the `git merge-base` result.
- [x] [P0-T4] Run the PowerShell formatting stage against the worktree root and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-format.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the reformatted-file count as an integer, established from a `git status --porcelain` listing taken immediately after the run. Where a path is read from that listing, strip the **three-character status-and-separator prefix**: the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3. Stripping only two characters leaves a leading space on every path.
- [x] [P0-T5] Run the PowerShell analyze stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCAnalyze -Root (Get-Location).Path`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-analyze.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the total analyzer finding count as an integer. The stage prints no count on a clean run: `Invoke-PoshQCAnalyze` throws `PSScriptAnalyzer reported N issue(s).` when findings exist and returns silently when none do, so a clean run is recorded as the integer 0 and a non-clean run is recorded as the N the thrown message names. The acceptance is therefore falsifiable by the stage's own outcome and does not assert over output the success path never emits.
- [x] [P0-T6] Run the coverage-bearing baseline test stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-poshqc-test-coverage.2026-08-28T00-30.md`. This is the self-hosted invocation, not the MCP test runner, because the MCP runner reads its settings from the installed extension and would ignore the two `CodeCoverage.Path` entries this feature registered. Acceptance: `EXIT_CODE:` is 0, the recorded failed-test count is the integer 0, and `Output Summary:` records the numeric total case count, the numeric passed-test count, and the numeric repository-wide LINE coverage percentage read from the LINE counter at the report root of `artifacts/pester/powershell-coverage.xml`, with that value at or above 85. The Pester console headline is instruction coverage and must not be recorded as the line figure. Pester measures no branch coverage, so no branch figure is recorded and none is required.
- [x] [P0-T7] From the `artifacts/pester/powershell-coverage.xml` produced by [P0-T6], build the baseline uncovered-line inventory for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-codex-gate-uncovered.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the artifact records the file's covered count, missed count, and total as integers, and its line-coverage percentage as a numeric value; it records the explicit list of uncovered line numbers; it states per line that **197 is uncovered** and that **206 is uncovered**, each backed by the line element's coverage attribute read from the report; and it records the baseline missed count as the integer 27.
- [x] [P0-T8] Record the current line counts and 500-line-cap headroom for the two branch-created suites with `(@(Get-Content -LiteralPath 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1')).Count` and `(@(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1')).Count`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/remediation-baseline/phase0-test-suite-line-counts.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; both counts are recorded as integers with their headroom against 500; the Codex count is recorded as the integer 302; and the artifact states that the Codex suite has room for the approximately 24 lines the two Phase 1 cases require. **If the Codex count leaves fewer than 24 lines of headroom, stop and report blocked; do not create a new test file.**

---

### Phase 1 — Batch-Budget Reset and the Two Codex Coverage Cases (B5, component 1)

All edits in this phase target
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`,
which this branch created and which is therefore not a pre-existing suite. Both new cases call
`Test-PreparationModeDelegation`, which takes a `[pscustomobject]` and returns a `[bool]`. No `Agent`
envelope is constructed and no transport is claimed, so decision D5's prohibition is not engaged;
these are the same category as the suite's existing `classifier parity` cases, which already pass a
flat `[pscustomobject]` to `Test-ImplementationDelegation`.

Both cases are inserted as a new `Context` placed immediately after the closing brace of the existing
`Context 'classifier parity through the mapped flat tool_input the Codex seam consumes'` and
immediately before the existing `Context 'the recorded Agent-transport gap (decision D5,
deliverable ii)'`.

- [x] [P1-T1] Reset the PowerShell per-batch budget counter by deleting every file matching `.claude/state/powershell-batch-budget.*.json` with `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Remove-Item -Force`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-batch-budget-reset.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0, the artifact records the before-count and after-count as integers, and a re-enumeration taken after the deletion reports the after-count as the integer 0.
- [x] [P1-T2] Insert the new `Context` and its first `It` into the Codex suite at the placement described above, reproducing the fenced block below byte-for-byte apart from the file's existing four-space indentation base. The case closes line **197** of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, the non-`orchestrator` `return $false`; both preparation markers are present in the fixture so that only the subagent-type check can produce the false. Acceptance: the file defines exactly one `It` named `returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface`; the file contains exactly one `Context` named `the preparation-mode delegation predicate on the Codex surface`; and the file's total `It` count rises by exactly one.

  ```powershell
  Context 'the preparation-mode delegation predicate on the Codex surface' {
      # Cycle-2 finding B5, the Codex twin of cycle-1 finding R2. Lines 197 and 206 of
      # .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 were COVERED at the
      # merge base 1e991b86, through Test-ImplementationDelegation's call to this predicate
      # at merge-base line 213. This branch removed that call site, orphaning the function
      # on BOTH surfaces. The two surviving direct callers in
      # tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 supply a null payload
      # and an orchestrator payload carrying one marker, so they reach only the null branch
      # and the marker-loop return. These two cases close the residual.
      #
      # Decision D5 is not engaged: the predicate takes a [pscustomobject] and returns a
      # [bool], constructs no Agent envelope, and claims no transport. It is the same
      # category as the classifier parity cases above.

      It 'returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface' {
          # Second conjunct, closing line 197. Both markers are present, with their trailing
          # periods, so only the subagent-type check can produce the false.
          $toolInput = [pscustomobject]@{ subagent_type = 'task-researcher'; prompt = 'Preparation mode: true. route_id: preparation. Promote only.' }
          Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeFalse
      }
  }
  ```

- [x] [P1-T3] Add the second `It` inside the same `Context 'the preparation-mode delegation predicate on the Codex surface'`, immediately after the `It` added by [P1-T2], reproducing the fenced block below byte-for-byte apart from the file's existing indentation base. The case closes line **206**, the all-conjuncts-hold `return $true`. Acceptance: the file defines exactly one `It` named `returns true for an orchestrator carrying both preparation markers on the Codex surface`; it sits inside the same `Context` as the [P1-T2] case; and the file's total `It` count rises by exactly one relative to its post-[P1-T2] value, for a net rise of exactly two over the [P0-T8] state.

  ```powershell
  It 'returns true for an orchestrator carrying both preparation markers on the Codex surface' {
      # All three conjuncts hold, closing line 206. The marker set is
      # @('Preparation mode: true.', 'route_id: preparation.') and both members carry their
      # trailing period, so the containment loop completes without returning.
      $toolInput = [pscustomobject]@{ subagent_type = 'orchestrator'; prompt = 'Preparation mode: true. route_id: preparation. Promote only.' }
      Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeTrue
  }
  ```

- [x] [P1-T4] Run the Codex suite alone with `Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 -Output Detailed` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-codex-suite-run.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the failed-test count is the integer 0; the total case count for the suite is the integer 55, which is the 53 cases the cycle-1 exit audit recorded plus the two added by [P1-T2] and [P1-T3]; and `Output Summary:` lists both new `It` names with result Passed.
- [x] [P1-T5] Record the post-edit line count of the Codex suite with `(@(Get-Content -LiteralPath 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1')).Count` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-codex-suite-line-count.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0, the recorded count is an integer at or below 500, and the artifact records the delta from the [P0-T8] count of 302.

---

### Phase 2 — Correcting the Three False Factual Statements (B5, component 2)

Each of the three locations asserts that Codex lines 197 and 206 were uncovered at the merge base.
They were covered. The two evidence artifacts receive an **appended, clearly-marked, dated
correction notice** and their original text is left byte-untouched; the source comment is
**rewritten in place**. The reasoning for each method is fixed in the "Correction Approach" section
above and is not left to executor discretion.

**How byte-untouchedness is verified, for both appended notices.** The check is stated count-free: the
prior text read from `git show HEAD:` must be a byte-exact **prefix** of the post-append file, and the
remainder after that prefix must be exactly the appended block. A prefix comparison covers the entire
prior file at every byte position, whereas a comparison of the file's first N lines covers only the
first N and leaves everything past line N unverified. It also cannot drift: no line count appears in
either acceptance condition, so neither condition is invalidated if an artifact is appended to before
its task runs. The appended-notice method is chosen in the "Correction Approach" table precisely
because the original text is left byte-untouched, and this is the check that establishes it.

- [x] [P2-T1] Append the correction notice below, byte-for-byte, to the end of `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md`, changing no other character of that file. Acceptance: the **whole** prior file is byte-identical to its prior state, verified by the prefix comparison defined in the phase preamble above — read the prior text with `git show HEAD:docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md` and confirm that its full text, from its first byte to its last, is a byte-exact prefix of the post-append file; the remainder of the post-append file after that prefix consists solely of the appended block below, preceded by at most one blank line; and the file no longer asserts anywhere, unqualified, that Codex lines 197 and 206 were uncovered at the merge base. The comparison names no line number, so it covers every line of the prior artifact — including its mirror-pair hashes, its N2 accepted-shipping-exception statement, and its policy-reading-order footer — and cannot be invalidated if the artifact is appended to before this task runs.

  ```text
  ---

  ## Correction Notice — 2026-08-28, remediation cycle 2

  This artifact is SUPERSEDED by `policy-audit.2026-08-28T00-30.md` and is retained above with its
  original text byte-untouched, for audit continuity. One statement of fact in it is incorrect. It is
  corrected here by appended notice rather than by rewriting the text above, so the record shows what
  was believed and when it was corrected.

  **Incorrect, at line 173 and at the derived-baseline figure at line 181.** Line 173 states that the
  Codex copy of `Test-PreparationModeDelegation` retains coverage, "which is why only lines 197 and
  206 are uncovered there". Line 181 derives a Codex baseline of approximately 98.3 percent, 118 of
  120 pre-existing measurable lines covered, on that assumption.

  **Corrected.** Lines 197 and 206 of
  `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` were COVERED at the merge base
  `1e991b86`. Merge-base line 213, inside `Test-ImplementationDelegation`, called
  `Test-PreparationModeDelegation`, and merge-base
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached both the
  non-`orchestrator` return and the all-conjuncts return through that call site. This branch removed
  the call site, orphaning the function on both surfaces, and the two lines lost coverage as a direct
  consequence. **The corrected derived Codex baseline is 120 of 120 pre-existing measurable lines
  covered.**

  This is remediation-cycle-2 finding **B5**, recorded in `remediation-inputs.2026-08-28T00-30.md`
  and in `policy-audit.2026-08-28T00-30.md`. It is closed by the two cases added to
  `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
  in remediation cycle 2.

  Nothing else in this artifact is withdrawn. Its four cycle-1 closure verdicts, its scope-constraint
  table, its mirror-pair hashes, and its accepted-shipping-exception statement all stand.
  ```

- [x] [P2-T2] Append the correction notice below, byte-for-byte, to the end of `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`, changing no other character of that file. Acceptance: the **whole** prior file is byte-identical to its prior state, verified by the same prefix comparison [P2-T1] uses and stated the same count-free way — read the prior text with `git show HEAD:docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` and confirm that its full text is a byte-exact prefix of the post-append file; the remainder of the post-append file after that prefix consists solely of the appended block below, preceded by at most one blank line; the notice states that the artifact's verdict on the acceptance criterion is unchanged and the checkbox stays checked; and the file's original `Timestamp:`, `Command:`, and `EXIT_CODE:` fields remain the first occurrences of those fields so the artifact schema still parses.

  ```text
  ---

  ## Correction Notice — 2026-08-28, remediation cycle 2

  The section above headed "The criterion's own text is satisfied outright" contains one incorrect
  statement of fact, at lines 100 through 102. It is corrected here by appended notice rather than by
  rewriting the text above, so the record shows what was believed and when it was corrected. The
  original text is left byte-untouched.

  **Incorrect.** "its two uncovered pre-existing lines, 197 and 206, were uncovered at the merge base
  as well, which is why the audit's derived-baseline calculation restored only the ten", and "On that
  basis no line that was covered at the merge base is uncovered now."

  **Corrected.** Both lines were COVERED at the merge base `1e991b86`. Merge-base line 213, inside
  `Test-ImplementationDelegation`, called `Test-PreparationModeDelegation`, and merge-base
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached both the
  non-`orchestrator` return and the all-conjuncts return through that call site. This branch removed
  the call site, orphaning the function on both surfaces, and the two lines lost coverage. The
  corrected derived Codex baseline is 120 of 120 pre-existing measurable lines covered. The error
  originated in `policy-audit.2026-08-27T22-47.md` and was faithfully reproduced here; that artifact
  now carries its own correction notice.

  **This loss is remediation-cycle-2 finding B5, and it is CLOSED** by the two cases added to
  `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
  in remediation cycle 2. Lines 197 and 206 are covered.

  **The verdict on the acceptance criterion is UNCHANGED and the checkbox stays checked.** The
  criterion is scoped to *changed* lines and neither 197 nor 206 is a changed line, a reading
  confirmed by `feature-audit.2026-08-28T00-30.md` on the criterion's literal text. Arguments 1 and 2
  of the section above are accepted in full and are untouched by this notice. Only the second half of
  the third argument — the claim about merge-base coverage — is withdrawn.
  ```

- [x] [P2-T3] In `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`, replace the seven-line comment block that currently begins at line 79 with the twelve-line block below, changing no other character of the file. The BEFORE and AFTER fenced blocks are reproduced byte-for-byte apart from the file's existing eight-space indentation base; the `BEFORE:` and `AFTER:` labels are not part of the file text. This is an in-place rewrite rather than an appended notice because the site is live source, whose comment has no audit-trail function and whose only obligation is to be true for a reader of the current file. Acceptance: the file no longer contains the phrase asserting that the Codex copy kept coverage without qualification; it contains the word `PARTIAL` in the replacement block; the file's `It` count is unchanged at 7; and no line outside the replaced block differs from `git show HEAD:tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`.

  BEFORE, the seven lines to be replaced:

  ```powershell
  # Finding R2. Test-PreparationModeDelegation lost its only production call site
  # when this branch replaced Test-ImplementationDelegation, so its body became
  # uncovered on the Claude surface while the Codex copy kept coverage from
  # tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1. The function
  # is deliberately retained: spec.md lists it under "Not modified", and removing
  # it would break that passing Codex legacy-contract test. These four cases
  # restore coverage of all three conjuncts.
  ```

  AFTER, the twelve lines that replace them:

  ```powershell
  # Finding R2. Test-PreparationModeDelegation lost its only production call site
  # when this branch replaced Test-ImplementationDelegation, so its body became
  # uncovered on BOTH surfaces. The Codex copy kept only PARTIAL coverage from
  # tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1: its two
  # surviving direct callers reach the null branch and the marker-loop return,
  # but neither the non-orchestrator return nor the all-conjuncts return, both of
  # which were covered at the merge base through the removed call site. That
  # residual is cycle-2 finding B5 and is closed by the two cases in
  # tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1.
  # The function is deliberately retained: spec.md lists it under "Not modified",
  # and removing it would break that passing Codex legacy-contract test. These
  # four cases restore coverage of all three conjuncts.
  ```

- [x] [P2-T4] Run the Claude classifier suite alone with `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 -Output Detailed` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-claude-classifier-suite-run.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0, the failed-test count is the integer 0, and the total case count for the suite is the integer 7 — unchanged by the comment-only edit of [P2-T3].
- [x] [P2-T5] Record the post-edit line count of the Claude classifier suite with `(@(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1')).Count` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-claude-classifier-line-count.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0, the recorded count is an integer at or below 500, and the artifact records the delta from the [P0-T8] count of 154.

---

### Phase 3 — Final PowerShell QC Loop, Coverage Verification, and Closeout

Tasks [P3-T1] through [P3-T4] are the mandatory PowerShell toolchain loop in the order **format,
analyze, test**. Type checking is not applicable to PowerShell per `.claude/rules/powershell.md` and
is recorded rather than run. **If any of those stages fails, or changes any file on disk, restart
the loop at [P3-T1]** and record the new iteration number in each re-issued artifact. The loop is
complete only when format, analyze, and test all pass in a single uninterrupted pass in which no
stage changed a file.

- [x] [P3-T1] Run the PowerShell formatting stage against the worktree root and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-final-poshqc-format.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` records the reformatted-file count as the integer 0, established from a `git status --porcelain` listing taken immediately after the run that names no `.ps1` file the stage rewrote. Each line's **three-character status-and-separator prefix** — the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3 — is stripped before the path is read; stripping only two characters leaves a leading space on every path and would break any extension or path test applied to it. A non-zero count restarts the loop at this task.
- [x] [P3-T2] Run the PowerShell analyze stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCAnalyze -Root (Get-Location).Path`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-final-poshqc-analyze.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 and the recorded total finding count is the integer 0, derived the way [P0-T5] records it — the stage returns silently on a clean run and throws `PSScriptAnalyzer reported N issue(s).` otherwise, so the zero is the stage's own outcome rather than a number read from a table it does not print. A non-zero count, or any file changed by the stage, restarts the loop at [P3-T1].
- [x] [P3-T3] Record that the type-checking stage is not applicable to PowerShell in `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-final-typecheck-not-applicable.2026-08-28T00-30.md`, citing `.claude/rules/powershell.md`. Acceptance: the artifact exists, carries `Timestamp:` and `Output Summary:`, cites the rule file by path, and records `EXIT_CODE: 0` with `Command:` stating that no type-check command exists for this language.
- [x] [P3-T4] Run the coverage-bearing final test stage with `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` followed by `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-final-poshqc-test-coverage.2026-08-28T00-30.md`. This is the self-hosted invocation, not the MCP test runner, for the reason recorded at [P0-T6]. Acceptance: `EXIT_CODE:` is 0; the recorded failed-test count is the integer 0; the recorded total case count exceeds the [P0-T6] baseline total by exactly 2, the two cases of [P1-T2] and [P1-T3]; and `Output Summary:` records the numeric repository-wide LINE coverage read from the LINE counter at the report root of `artifacts/pester/powershell-coverage.xml`, with that value at or above 85 and at or above the [P0-T6] baseline value. A failure restarts the loop at [P3-T1].
- [x] [P3-T5] Confirm the single-pass property of the loop and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-final-single-pass-confirmation.2026-08-28T00-30.md`. Acceptance: the artifact records the loop iteration number of the passing pass, records the four artifact paths of [P3-T1] through [P3-T4] in monotonic capture order, and states that no stage in that pass failed and no stage changed a file.
- [x] [P3-T6] From the `artifacts/pester/powershell-coverage.xml` produced by [P3-T4], probe `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **per line** and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-codex-gate-coverage-probe.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the artifact records, as an explicit per-line row, the coverage attribute the report emits for **line 197** and for **line 206**, and both rows show a covered count greater than zero; the artifact records the file's full missed-line set and that set is exactly the 25 members `292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443`; the recorded covered count is the integer 137, the missed count the integer 25, and the total the integer 162; and the recorded file line-coverage figure is numerically 84.57 rounded to two decimal places, with its movement from the [P0-T7] baseline of 83.33 recorded. The artifact must state that the residual is wholly the accepted issue #555 exception at lines 426-443 plus the group-1 and group-2 residuals, and that no line of it is unattributed.
- [x] [P3-T7] Write the re-issued coverage-delta artifact at `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/coverage-delta.2026-08-28T00-30.md`, superseding `coverage-delta.2026-08-27T22-47.md`, which is **retained unaltered**. The superseded artifact receives no correction notice: its statement that "zero uncovered added lines are unattributed" is true as worded, and the defect was the omission of the two uncovered **pre-existing** lines, which this re-issue supplies. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and satisfies every one of the following six conditions.
  1. **The pre-existing-line disclosure, new in this issue.** A subsection reconciling the file's full missed set rather than only its changed lines: it names Codex lines 197 and 206, records that both were **covered at the merge base** `1e991b86` through merge-base line 213 inside `Test-ImplementationDelegation`, records that this branch removed that call site and orphaned `Test-PreparationModeDelegation` on both surfaces, records that the loss is finding **B5**, and records that B5 is closed by the two cases of [P1-T2] and [P1-T3]. It must state that the file's full missed set of 27 at cycle-1 exit therefore partitions into 25 changed lines plus this pre-existing pair, and that after B5 the missed set is exactly the 25.
  2. **Group 1, named exception — the injected read seams (16 measurable lines).** `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` bodies on both surfaces, at `.claude/…gate.ps1` lines 266-270 and 278-282 and `.codex/…gate.ps1` lines 292-296 and 304-308. Reason: real filesystem I/O; the injection seam exists so the decision logic is testable without touching the filesystem, and covering these would additionally make several allow assertions pass vacuously against the live checkpoint. Status: unchanged, all 16 remain uncovered and accepted.
  3. **Group 2, named exception — two distinct causes, 3 measurable lines.** `.claude/…gate.ps1` line 408 is the non-injected `else` arm of the mode-checkpoint selector, same seam and same reason as group 1. `.codex/…gate.ps1` lines 421-422 are the `declared-checkpoint-path` deny return, uncovered for the decision-D5 transport reason. Status: unchanged, all 3 remain uncovered and accepted.
  4. **Group 4, named exception — the debug-only catch (4 measurable lines).** `Get-OrchestrationModeProperty` at lines 94-95 of both `-modes.ps1` copies. Reason: the catch fires only when `PSObject.Properties` itself throws, which no JSON-derived object produces. Status: unchanged.
  5. **The one shipping exception, tied to issue #555, preserved by name, line range, and linkage.** The epic/parallel decision branch at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **lines 426 through 443, 15 measurable lines**, enumerated as `426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443`. Reason: driving the branch requires constructing a delegation payload for the Codex decision function, which decision D5 prohibits because `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name. Linkage: **issue #555** owns the transport gap and is explicitly out of scope for issue #554. The artifact must record that the file ships at **84.57 percent**, still below the 85 percent uniform threshold, that the shortfall is wholly owned by this fifteen-line exception, that the exception therefore **persists after B5 closes**, that it is stated as its own named exception and **not absorbed into an aggregate**, and that it **must be disclosed in the pull-request description**.
  6. **Post-B5 numbers.** The cycle-1-exit and post-B5 repository-wide LINE coverage figures from [P0-T6] and [P3-T4]; the four per-file figures with `.codex/…gate.ps1` moving from 83.33 to **84.57** and the other three unchanged at 88.00, 98.48, and 98.48; and the post-B5 count of uncovered changed lines in each of the two modified hooks, which is unchanged at 9 and 25 because B5 concerns pre-existing lines only. All values numeric, all computed against the **fixed cycle-1 comparison anchor** `1e991b86d78e4f979922b79268f19ca0e5ab19e3` pinned and ancestry-verified at [P0-T3] — never against the current `git merge-base HEAD origin/main` value `c62af7a71eb2dbc8c8086c9cbf1c30c22551590a`, which the merge of `origin/main` moved and which would silently change these two counts.
- [x] [P3-T8] Verify that none of the three corrected locations still asserts the false claim, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-false-claim-corrections.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the artifact records, for each of the three paths — `policy-audit.2026-08-27T22-47.md`, `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` — the correction method applied, the task that applied it, and a quotation of the corrected statement as it now stands; it records that the two evidence artifacts retain their original text byte-for-byte with the correction appended; and it records that the source comment was rewritten in place with the git history preserving the superseded text.
- [x] [P3-T9] Verify that the six pre-existing suites are unmodified and passing, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-preexisting-suites.2026-08-28T00-30.md`. The six are those enumerated in prohibition 3 above. Acceptance: `EXIT_CODE:` is 0; a `git diff --name-only HEAD` listing names none of the six; a `git status --porcelain` listing, taken in the same step and with each line's **three-character status-and-separator prefix** stripped before the path is read, likewise names none of the six; and the [P3-T4] run reports zero failures in all six. The prefix is three characters, not two: the short format is the two-character `XY` status field at positions 0 and 1 followed by a single separator space at position 2, with the path beginning at position 3. Stripping only two characters leaves a leading space on every path, which would make each equality test against a path fail and would let a deleted-and-recreated suite appearing as an untracked `?? tests/…` line pass this check unnoticed. The porcelain companion is required because a name-listing diff enumerates tracked changes only and can never report an untracked path, so a suite removed and recreated as an untracked file would be invisible to the diff alone.
- [x] [P3-T10] Verify the test-only scope invariant and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-no-production-change.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0, and the union of a `git diff --name-only HEAD` listing, a `git status --porcelain` listing, and a `git ls-files --others --exclude-standard` listing contains exactly two paths ending in `.ps1` — the Codex mode-resolution suite edited in Phase 1 and the Claude classifier suite edited in Phase 2 — and contains no path under `.claude/hooks/`, no path under `.codex/hooks/`, and no path under `extensions/drm-copilot/resources/`. Each porcelain line's **three-character status-and-separator prefix** — the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3 — is stripped before its path enters the union, and the union is **deduplicated across the three listings** before its membership is evaluated, so a path reported by more than one listing contributes exactly one member. Stripping only two characters would leave a leading space on every porcelain path, so each edited suite would enter the union twice as two distinct strings ending in `.ps1` — once unprefixed from the diff and once space-prefixed from the porcelain listing — and the count of four would falsify an acceptance condition that demands exactly two. The two untracked-visible listings are part of the union because no task in this plan stages or commits anything; the two-dot diff against `HEAD` already observes uncommitted working-tree changes to tracked files but never reports an untracked path, so a path this plan creates is invisible to the diff alone and only the porcelain and untracked listings can observe it. The artifact must state explicitly that the four `-helpers.ps1` copies are byte-untouched.
- [x] [P3-T11] Verify the policy-path invariant and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-policy-paths-untouched.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0 and the union of a `git diff --name-only origin/main...HEAD` listing, a `git diff --name-only HEAD` listing, a `git status --porcelain` listing, and a `git ls-files --others --exclude-standard` listing contains no path beginning with `.claude/rules/`, no path beginning with `.claude/skills/`, and no path beginning with `.github/`. Each porcelain line's **three-character status-and-separator prefix** — the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3 — is stripped before its path enters the union, and the union is **deduplicated across the four listings** before the prefix tests are applied. Stripping only two characters would leave a leading space on every porcelain path, so a newly created `.claude/rules/` file would enter the union as ` .claude/rules/…`, which does not begin with `.claude/rules/` and would pass this check; no redundant clause sits behind that one, so the strip width is load-bearing. The porcelain and untracked listings are required because neither name-listing diff can report an untracked path, so a newly created policy-tree file would be invisible to the two diffs alone.
- [x] [P3-T12] Re-verify the four mirrored production pairs with `Get-FileHash -Algorithm SHA256` and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-mirror-pair-hashes.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the artifact records four pair hashes; each pair's two hashes are equal; and each of the four hashes equals the value recorded in `policy-audit.2026-08-28T00-30.md`, namely `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` for the Claude gate hook, `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` for the Claude modes sibling, `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` for the Codex gate hook, and `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` for the Codex modes sibling, confirming that this remediation changed no production byte.
- [x] [P3-T13] Verify that `spec.md` is byte-untouched by this cycle and that `[P6-T6]` remains unchecked, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-spec-and-plan-untouched.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; `git diff --name-only HEAD -- docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` produces empty output; the artifact records the count of checked acceptance criteria in `spec.md` as the integer 35 and the count of unchecked criteria as the integer 0; `git diff --name-only HEAD -- docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md` produces empty output; a `git status --porcelain` listing, with each line's **three-character status-and-separator prefix** stripped before the path is read — the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3 — names neither of those two paths, which is the observation the two name-listing diffs cannot make because a name-listing diff never reports an untracked path; and the artifact records that the `[P6-T6]` task line in that plan is still an unchecked checkbox, quoting the line. **No criterion text may be amended and no checkbox may be changed under any outcome.**
- [x] [P3-T14] Verify blast-radius conformance and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-blast-radius-conformance.2026-08-28T00-30.md`. Acceptance: `EXIT_CODE:` is 0; the artifact records the **union** of `git diff --name-only origin/main...HEAD`, `git diff --name-only HEAD`, `git status --porcelain`, and `git ls-files --others --exclude-standard`, and, for every path in that union, the `## DECLARED BLAST RADIUS` entry or directory prefix of `spec.md` that covers it, with a per-path DECLARED or UNDECLARED verdict and an explicit count of UNDECLARED paths. Each porcelain line's **three-character status-and-separator prefix** — the two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2, with the path beginning at position 3 — is stripped before its path enters the union, and the union is **deduplicated across the four listings** before the per-path verdicts are assigned, so a path reported by more than one listing receives exactly one verdict and the UNDECLARED count is unambiguous. Stripping only two characters would leave a leading space on every porcelain path; each such space-prefixed duplicate would match no declared entry or directory prefix, the UNDECLARED count would be non-zero for paths that are in fact declared, and [P3-T15] would be misrouted down its amendment branch into an edit to `spec.md` that prohibition 5 and [P3-T13] both forbid. The four-way union is required because no task in this plan stages or commits anything, and because a name-listing diff never reports an untracked path: a three-dot listing alone cannot observe the untracked and unstaged paths this cycle writes, so every verdict for them would be vacuous. The artifact must state, per path, which of the following covers it: statement `(e)` for the cycle-2 root-level `policy-audit`, `code-review`, `feature-audit`, `remediation-inputs`, and `remediation-plan` files; the `evidence/qa-gates/` prefix for the Phase 1 through Phase 3 artifacts; the `evidence/remediation-baseline/` prefix for the Phase 0 artifacts; and the `### Tests — new` entries for the two edited suites. The artifact must record whether the count of UNDECLARED paths is the integer 0.
- [x] [P3-T15] If [P3-T14] recorded an UNDECLARED count greater than zero, append an **additive** amendment to the `## DECLARED BLAST RADIUS` section of `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` declaring each undeclared path by its exact normalized path, plus one dated note recording the addition, and write `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-blast-radius-amendment.2026-08-28T00-30.md` recording the amendment and a re-run of the [P3-T14] union with a zero UNDECLARED count. **This task carries an explicit authorized skip branch:** if [P3-T14] recorded the UNDECLARED count as the integer 0, write the same artifact recording `EXIT_CODE: 0`, `Command:` stating that no amendment was required, and an `Output Summary:` of `NOT REQUIRED` that cites the [P3-T14] artifact path and its zero count; make no edit to `spec.md`. Acceptance: exactly one of the two branches is recorded in the artifact, the branch taken is justified by the [P3-T14] UNDECLARED count quoted in the artifact, and under either branch no acceptance criterion, no checkbox, and no pre-existing blast-radius entry is removed, narrowed, or reworded. Narrowing a declared radius to suppress a conflict edge is prohibited by `.claude/rules/parallel-orchestration.md`.
- [x] [P3-T16] Write the remediation closeout summary at `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/r2-remediation-closeout.2026-08-28T00-30.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; records a disposition line for **B5** naming both components, the closing task IDs, and the evidence artifacts that prove closure; records that zero production files changed and that exactly two test files and two evidence documents were written; records the post-B5 Codex gate figure of **84.57 percent** with its missed count of 25; records that the **issue #555** exception at lines 426-443 persists, is preserved by name, line range, and linkage in `coverage-delta.2026-08-28T00-30.md`, and must be disclosed in the pull-request description; records that all 35 acceptance criteria remain checked and none was amended; records that `[P6-T6]` in `plan.2026-08-26T08-40.md` remains unchecked by design; and records the two symmetry cases and the marker-parity assertion listed under "Recorded Non-Additions" as optional follow-ups alongside non-blocking item N9.

---

## Task-Count Summary

| Phase | Tasks | Purpose |
| --- | --- | --- |
| 0 | 8 | Policy reads, remediation baseline, per-line uncovered probe, suite line counts |
| 1 | 5 | Batch-budget reset, the two Codex coverage cases, suite run, line count |
| 2 | 5 | The three false-statement corrections, classifier suite run, line count |
| 3 | 16 | Final QC loop, per-line coverage verification, re-issued coverage-delta, scope invariants, blast-radius conformance, closeout |
| **Total** | **34** | |

## Non-Blocking Items Carried Forward, Not Actioned Here

| ID | Item | Disposition |
| --- | --- | --- |
| N3 | `Find-OrchestrationDelegationIssueNumber` returns the first bare-hash match, making a two-hash prompt order-dependent | Follow-up issue |
| N5 | Codex pack manifest omits `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; pre-existing at the merge base | Separate follow-up issue |
| N7 | `.codex/…gate.ps1` at 495 of 500 lines and `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 494 | Note for the next change to either file |
| N9 | `Test-PreparationModeDelegation` is dead code on both surfaces, and the preparation-marker rule has two independent implementations in one file | Follow-up refactor; out of scope because `spec.md` lists the function under "Not modified" |
