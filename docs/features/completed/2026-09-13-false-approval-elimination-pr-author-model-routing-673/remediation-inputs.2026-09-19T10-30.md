# Preflight delta — plan revision 4 (Issue #673)

- Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, 2026-09-19
- Plan of record validated: `plan.2026-09-19T09-00.md` (revision 4)
- Verdict: **PREFLIGHT: REVISIONS REQUIRED**
- Branch validated: `bug/false-approval-elimination-673` at `c50f82c2`; merge base with `origin/main` `b7c11616`
- Nothing was created, modified, or deleted by the preflight pass.
- The plan validator exits 0 with no G1–G9 warning; every defect below is outside what that validator can decide.

Revise `plan.2026-09-19T09-00.md` in place rather than creating another sibling revision.

## Blocking findings

### 1. [P9-T4] dropping the `:393` conjunct breaks a pinned test

Plan assumes dropping `-and $probeFolder -ne $folderNormalized` at `:393` is compatible with §2.7.3 and with [P9-T7]'s "exactly two changed hunks, no deleted `It` line".

Tree shows `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1:337-348` is `It 'denies with the indeterminate-marker reason when issue.md is unreadable'`, mocking `Get-PrdFeatureIssueContent` and `Get-PrdFeatureCheckpointFolder` to `$null` and asserting `Should -Match 'could not be determined'`. After [P9-T7]'s blanket mock returns `SessionRoot`, DD-8 leaves `$probeFolder -eq $folderNormalized`; with the conjunct removed, `if ($null -eq $issueContent)` fires first and the gate returns the ambiguity-code resolution deny. The row fails, taking [P9-T12] and [P11-T4] with it, and [P9-T7] forbids editing that row.

Fix: delete the clause "and drop the `-and $probeFolder -ne $folderNormalized` conjunct at `:393`" from [P9-T4]. Keeping the conjunct preserves §2.7.3, §2.7.4's folder-absent-under-target wording, and AC-37.

### 2. [P9-T6] acceptance conditions are mutually unsatisfiable

Plan assumes editing only `:13` and `:208` of `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` yields "exactly two changed hunks; the file contains no drive-letter path".

Tree shows three drive-letter literals: `:204`, `:208`, `:293`. Editing only `:13` and `:208` leaves two, and [P10-T9] applies the [P0-T16] matcher to every file in the diff requiring count 0, so AC-38 fails. Fixing all three yields at least three hunks.

Fix: extend [P9-T6] to replace the literals at `:204` and `:293` with `/synthetic-worktrees/...` spellings, and change the acceptance to "exactly three changed hunks and no deleted `It` line".

### 3. [P9-T5] mock enumeration is incomplete

Plan lists `Mock -CommandName Resolve-WorktreeCallTarget` at `:264`, `:279`, `:291`, `:407`.

Tree shows nine mocks in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` — `:182`, `:190`, `:201`, `:212`, `:226`, `:264`, `:279`, `:291`, `:407` — plus five `Should -Invoke` assertions at `:186`, `:197`, `:208`, `:222`, `:235`. Only `:212`/`:226` and `:222`/`:235` are removed by the task's own row deletions, so `:182`, `:186`, `:190`, `:197`, `:201`, `:208` survive and fail the task's own acceptance.

Fix: state the full set — mocks at `:182`, `:190`, `:201`, `:264`, `:279`, `:291`, `:407`; invocation assertions at `:186`, `:197`, `:208` — with the status each retains.

### 4. [P9-T5] three derivation-seam rows still pass `-Envelope`, which DD-4 removes

Rows at `:181`, `:189`, `:200` call `Get-PrdFeatureCallTarget -Envelope $null -ToolInput ...` at `:184`, `:194`, `:205`. DD-4 and [P9-T4] drop the `-Envelope` parameter, so those calls become parameter-binding errors.

Fix: add "remove the `-Envelope $null` argument at `:184`, `:194`, `:205`" to [P9-T5], and add "the file contains no `-Envelope`" to its acceptance.

### 5. [P9-T5] the unresolved-tie row cannot reach the branch it asserts

Plan repoints `:407` with `Status` `NoTarget` and asserts the deny comes from DD-7's tie branch. DD-5 widens the `:337` check to deny on `NoTarget` *before* `Find-PrdFeatureFolderCandidate` runs, so the tie branch is unreachable.

Fix: specify that `:407` returns a resolved status (`SessionRoot` with a synthetic `WorktreeRoot`) so the multi-candidate tie branch is reached with `Get-PrdFeatureCheckpointFolder` mocked to `$null`.

### 6. §7 pr-author row 7 cannot reach the check it exercises

The substitute fail-before row for AC-12 states no working directory. `Test-EpicBaseBranchOverride` is check 6 of `Test-PrAuthorReceiptVerification` (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:211`), reached only after checks 1–5 read `artifacts/pr_body_1.receipt.json`, `artifacts/pr_body_1.md`, and the last-write time of `artifacts/pr_context.summary.txt`, all resolved against the process working directory. §4.1 gives `pr-author/item-own-epic-mode` no artifact files and `artifacts/` is gitignored (`.gitignore:6`), so on a clean checkout the row fails at check 2 both before and after the fix. RS-5 makes this row the only direct fail-before/pass-after evidence for AC-12's binding-2 half; [P4-T5], [P5-T8], [P7-T6], [P7-T7] all read it.

Fix: state "cwd `pr-author/session-root`" in the row (§4.1 already gives that root the three artifact files), or add the three artifact files to `pr-author/item-own-epic-mode` in §4.1 and [P3-T1].

### 7. pr-author rows depend on an untracked `artifacts/` tree — green locally, red on a clean checkout

`.gitignore:6` ignores `/artifacts` and `git ls-files artifacts/` returns nothing. `Get-PrContextArtifactExistence` probes `artifacts/pr_context.summary.txt` (`.claude/hooks/enforce-pr-author-skill.ps1:48`) relative to the process directory. That file exists in the development worktree but not in CI, where the hook returns the Case C `PR_CONTEXT_MISSING` deny (`helpers:307-310`) and the asserted no-target code never appears. Row 8 is explicit that it uses "no fixture, no mock". The exposure applies to every pr-author row whose working directory §7 leaves unstated: rows 2, 4, 5, 6, 7, 8, 10–17.

Fix: state in §4 that every pr-author matrix row runs inside `Invoke-WorktreeResolutionFixtureCall` with a committed fixture root carrying `artifacts/pr_context.summary.txt`, and name the root per row; or, for rows whose subject is not artifact presence, permit a `Get-PrContextArtifactExistence` mock and say so, narrowing row 8's "no mock" clause to the resolver and the checkpoint readers.

### 8. AC-37 and §7 identity row 13 assert something DD-4 contradicts

AC-37 and the row name claim the gate passes no feature-folder path or file path to the resolver. DD-4 assembles the prompt and description text "exactly as today" (`.claude/hooks/enforce-prd-feature-before-planner.ps1:265-267`) and hands the whole string to `Resolve-WorktreeItemTarget -Text`, so any folder or file token in the prompt is passed. §2.3's actual guarantee is that the resolver *ignores* path signals for worktree selection.

Fix: restate the AC-37 clause and the row name as "no feature-folder path and no file path selects the worktree; the resolver reads no path signal", matching §2.3 and §2.2 row 2.

### 9. [P8-T4] cited insertion point is not the end of the named section

`.claude/skills/epic-orchestrate/SKILL.md` has `## Epic-Level Checkpoint` at `:278` and the next `## ` heading at `:301`; the section's final paragraph runs `:295-299`. Appending after `:293` inserts mid-section.

Fix: change the parenthetical to "after the paragraph ending at `:299`".

## Non-blocking drift to correct in the same revision

- **RS-12 vs [P9-T4]/[P10-T3].** RS-12 requires `-ErrorAction Stop` on every entry hook import; [P9-T4] keeps the unguarded `-Force`-only form at `.claude/hooks/enforce-prd-feature-before-planner.ps1:108`, and [P10-T3] accepts either. Align RS-12 with the per-file convention.
- **[P8-T5].** "replace the digest at `:130`" and "add to the comment block at `:105-122`" are order-dependent, and "the digest at `:126` is unchanged" stops resolving once the paragraph is inserted. Identify both digests by the path string above them, not by line number.
- **[P9-T7].** After `-Target $target` is replaced at `:105`, the `$target` hashtable at `:98-102` becomes an unused assignment. `Invoke-PoshQCAnalyze` runs at Information severity too (`PoshQC.Analyzer.psm1:101`), so `PSUseDeclaredVarsMoreThanAssignments` would fail [P11-T2]. Delete `:98-102`; it merges into the same hunk.
- **[P6-T2].** `Set-CheckpointFixture` closes at `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:69`, not `:68`; cite `:34-69`.
- **[P2-T4].** The literal entries are at `:27-28`, `:34-35`, `:45-46`, `:72-73` of `WorktreeResolution.Manifest.Tests.ps1`; the plan's ranges are the enclosing blocks.
- **[P1-T1].** The refresh list supplies new lines for five of six existing binding-table rows; the `module path` row has no stated replacement. With eight rows carrying two citations each, "the artifact quotes eight source lines" understates the count.
- **RS-8.** `enforce-pr-author-skill.epic-base-branch.Tests.ps1:48` is described as inside AC-19's protected rows; AC-19 protects `:22-42`, so `:48` is outside it.
- **§7 preamble** for `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` says "all seven names below"; the list carries eight bullets and [P7-T4] authors seven.

## Confirmed correct — do not re-derive

Line counts (312, 340, 115, 180, 500, 347, 499, 509, 456, 320, 499, 454, 446) and every §1.2, §1.3, §2.6, §2.7 and [P0-T5] citation in the F1 modules, the three pr-author hook files, the model-routing gate, and the two prd gate files. The §5 derivation values. The fixture approach (committed fixtures can stand in for worktree roots with no temporary file and no working-directory change; the in-process pattern is authorised by the spec). The fixture-name collision precondition and [P1-T4] ordering. Pester name uniqueness and the expansion counts. The batch-budget schedule (B1–B8 all within the 3+3 cap). Both issue specs, including the two unchecked criteria at `:655` and `:668` of the #672 spec and the AC-1..AC-33 inventory. Evidence locations.

## Convergence note

Findings 1–5 all land in Phase 9, and remediating them shifts line numbers across `enforce-prd-feature-before-planner.Tests.ps1`, `.FolderResolution.Tests.ps1` and `.TargetResolution.Tests.ps1`, so the revision must re-derive its own sibling citations in those three files. Finding 7 additionally requires new construction text for up to fourteen named pr-author rows.
