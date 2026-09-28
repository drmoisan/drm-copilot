# Preflight delta — second pass (Issue #673)

- Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, second pass, 2026-09-19
- Plan of record validated: `plan.2026-09-19T09-00.md` (revised in place after the first delta)
- Verdict: **PREFLIGHT: REVISIONS REQUIRED**
- **CONVERGENCE: NO FURTHER ROUNDS EXPECTED** — every defect below is localized and carries an exact delta.
- Nothing was created, modified, or deleted by the preflight pass. The plan validator exits 0 with no G1–G9 warning.

Revise `plan.2026-09-19T09-00.md` in place again. Address every blocking finding and every drift item.

## Confirmed correct this pass — do not re-derive

- **Finding 1's fix holds.** The `:393` conjunct is present; `:379-382` is the probe-anchoring conditional. The pinned row is at `FolderResolution.Tests.ps1:338-349`. Under [P9-T7]'s `SessionRoot` blanket mock the row yields one candidate, no checkpoint read, `probeFolder -eq $folderNormalized`, the conjunct false, and falls through to the work-mode branch — what the row asserts. DD-8a's reasoning holds and the two-hunk acceptance leaves the row byte-unchanged.
- **[P9-T5]'s enumerated numbers and surviving counts are right.** Nine mocks pre-edit, five invocation assertions, step 1 removes four, leaving the seven and three named; "exactly ten" is arithmetically correct. The three `-Envelope $null` arguments are at `:184`, `:194`, `:205`.
- **Findings 6 and 7 are correctly closed.** `/artifacts` is root-anchored. The three cwd-relative reads are at `helpers:154`, `:177`, `:205` via `enforce-pr-author-skill.ps1:137-141`; both location values must be set because `Get-PrBodyFileBytes` uses `ReadAllBytes`. Both §4.1 defaults exist and the pr-author default carries all three artifact files. Rows 7 and 8 are distinct and each justified. No row depends on the gitignored tree.
- **New material verified:** binding rule 5 is honoured throughout; the plan scores zero against all three path matchers. DD-5's load-bearing claim is exact — `TargetResolution.Tests.ps1:186` asserts zero invocations for empty text and `:268-270` is the early return.
- **All other re-derived citations matched**, including the [P0-T5] size table, `core.json`, `pester.runsettings.psd1`, the six production files in `CodeCoverage.Path`, both F1 modules, the nine `Test-EpicBaseBranchOverride` call sites, the three drive-letter literals in the pr-author target-resolution suite, the skill sections and both frozen digests, and both specs' criteria counts. Task identifiers are sequential across all twelve phases.

## Blocking findings

### B1 — [P9-T4] forbids the edit its own acceptance requires

Assumes the `:393` guard is not edited, while also requiring `Get-PrdFeatureAmbiguityDecision` to occur nowhere in the file. That function has four call sites: `:338`, `:347`, `:360`, `:394`. `:394` is the `return` inside the `:393` guard, and DD-5 deletes the definition at `:203-231`. §2.7.4 compounds it by describing `:393-395` as a path that "keeps the ambiguity code", and the surviving row `denies with the ambiguity reason when the folder is absent from the target root` (`TargetResolution.Tests.ps1:481-496`, asserting at `:495`) requires that code still to be emitted there.

Fix: narrow the unedited claim to the `if` condition on `:393` alone, and add to [P9-T4]'s edit list that `:394` becomes `Get-PrdFeatureTargetDecision -ReasonCode (Get-WorktreeResolutionAmbiguityReasonCode) -Detail (<the existing detail expression, unchanged>)`. Amend §2.7.4 to say the reason code is preserved while the decision helper changes.

### B2 — [P9-T5] step 2: the renamed zero-candidate row fails its own assertion

Repointing the mock at `:291` and flipping its status to `NoTarget` is not sufficient. The row asserts against `$script:AmbiguityCode` at `:300`, and that variable (`:119`) is the only reason-code variable the file defines. After the change the reason carries the no-target code, so the row denies correctly and the assertion fails.

Fix: add a step defining `$script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode` in the `BeforeAll` beside `:119`, and change `:300` to assert against it.

### B3 — [P9-T5] step 7: residual assertions contradict the required `allow`

The row at `:384-402` asserts `deny` (`:398`), the ambiguity code (`:399`), a `-Not -BeLike` on the other folder (`:400`), and `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly` (`:401`). An `allow` verdict requires the prerequisite probe to run, so `:401` is directly contradicted.

Fix: state in step 7 that `:398-401` are replaced by the allow assertion plus the captured-path assertion, and that the zero-probe assertion is removed because the allow path necessarily probes.

### B4 — [P6-T2] helper copy range is wrong and yields unbalanced braces

The plan cites the helpers as `:34-69` and claims the second "closes at `:69` and not `:68`". `Set-CheckpointFixture` closes at `:68`; `:69` closes the enclosing `BeforeAll`. Reproducing `:34-69` inside a new `BeforeAll` copies that extra closing brace and the new file will not parse.

Fix: cite the helpers as `:34-68`, and replace the parenthetical with the correct statement that `:69` closes the source's `BeforeAll` and is not copied.

### B5 — [P10-T5] checks for a path a phase before it is touched

[P10-T5] asserts that the diff lists all nine paths §2.7.6 names. The ninth is the #672 spec, which is not modified until [P11-T9], one phase later. Eight of nine are in the diff after [P9-T13]; the ninth cannot be.

Fix: either assert eight paths at [P10-T5] and add the ninth to [P11-T9]'s or [P11-T10]'s acceptance, or move the #672 closure before Phase 10. §10's traceability row for the AC-37 replacement must follow whichever is chosen.

### B6 — empty-porcelain acceptance conditions are unsatisfiable where they sit

[P10-T5], [P10-T6] and [P10-T9] each require `git status --porcelain` to be empty, but by then [P10-T1] through [P10-T4] have written evidence artifacts under the feature folder with no intervening commit, so the output cannot be empty. The same class recurs in the commit tasks [P1-T6], [P4-T7], [P7-T8], [P8-T9], [P9-T13] and [P11-T10]: each commits and then appends to `evidence/other/r3-commits.md`, after which it asserts a clean porcelain over a scope containing that very file. [P11-T10] additionally leaves that append uncommitted at plan end, so it would never reach the branch.

Fix: adopt [P10-T2]'s formulation — "lists no path outside the feature folder" — for [P10-T5], [P10-T6] and [P10-T9]; and in each commit task state that the porcelain observation is taken immediately after the commit and before the `r3-commits.md` append, with [P11-T10] amending or adding a final commit so the last append is committed.

## Drift items

### D1 — [P2-T4] all four entry line pairs are off by one

The enclosing blocks (`:27-30`, `:34-37`, `:45-48`, `:72-75`) are right; the path entries are at `:28-29`, `:35-36`, `:46-47`, `:73-74`, because `:27`, `:34`, `:45`, `:72` are the `@(` opener lines. The acceptance counts (1/4/1) still hold, so this is guidance drift rather than an unsatisfiable condition.

### D2 — [P9-T5] step 4 misattributes the session-root supply, with two knock-on risks

The step says the new row asserts that `Get-PrdFeatureCallTarget` passes `(Get-Location).Path` through to the seam. Per DD-4 that function passes only `-Text`; `Resolve-PrdFeatureWorktreeTarget` supplies `-SessionRoot (Get-Location).Path` to `Resolve-WorktreeItemTarget`. Consequences: (a) mocking the seam to capture a `-SessionRoot` it never receives writes an unsatisfiable assertion, and naming the seam a second time breaks the "exactly ten occurrences" acceptance; (b) comparing a captured value against a live `(Get-Location).Path` derives a path from the current directory, which is exactly what the #672 criterion [P11-T9] checks off forbids — and [P10-T7]'s counted tokens for the two prd suites (`Set-Location`, `CurrentDirectory`, non-exempt `Resolve-Path`, `git`) would not catch it.

Fix: name the mechanism (mock `Resolve-WorktreeItemTarget` and assert the captured `-SessionRoot`, or assert over the seam's script block rather than a live location read), confirm the ten-occurrence count under that mechanism, and add `Get-Location` to [P10-T7]'s counted set for the two prd suites.

### D3 — [P4-T3]/[P4-T4] overflow split names an empty set

The contingency moves "the rows that use no fixture" into a sibling file, but §4's rule requires every pr-author and model-routing row to run inside `Invoke-WorktreeResolutionFixtureCall` with an explicit `-WorkingDirectory`, so no such row exists.

Fix: name the movable set by row number (rows 8 to 17 for pr-author, the corresponding set for model-routing) and state that moved rows keep their working directory.

### D4 — [P9-T5] step 1 holds two pre-edit ranges in one step

The shifted-number caution is scoped to "between steps", but step 1 deletes `:168-179` and `:211-236` in one step; deleting the lower range first invalidates the upper.

Fix: state that both are pre-edit coordinates to be applied highest-range-first, or re-derived after the first deletion.

### D5 — [P9-T5] step 1 leaves a stale comment

The `Context` comment at `:165-166` describes "the two parent-side functions the decision path calls"; after the three `Test-PrdFeatureSessionRootTarget` rows are deleted only one remains. Step 8 updates only the determinism statement at `:17-25`.

Fix: add the `:165-166` comment to step 8.

### D6 — §7 model-routing row 3 name misdescribes its input

The row is named "… when the only signal is a repository-relative feature folder", but the prompt it pins (`evidence/baseline/repro-3-4-control-pair.md:28`) carries a repo-relative *file path* to a `spec.md` beneath a feature folder, not a folder. RS-3 repeats the description. The verdict is the same under §2.2 row 2, so this is naming only — but the name is asserted verbatim in three artifacts.

Fix: rename to "… a repository-relative path", or substitute a folder-only prompt and restate RS-3.
