# Fail-Before Exception Dossier — pr-author R2 (issue #673)

Timestamp: 2026-09-19T18-23

WhyFailingRunImpossible: The pr-author sibling-only row already denies on this tree, so no failing run of it can be produced. Issue #687, commit `f62c85abd62d05c828751fcc6353310db49f02f5`, added the no-target deny to the pr-author gate before this plan's first task ran. `[P4-T5]` confirms the row's status is Passed against the unmodified hooks, and `evidence/other/r3-current-tree-facts.md` records `.claude/hooks/enforce-pr-author-skill-helpers.ps1:61` already calling a target resolver. Producing a genuine failing run would require reverting #687, which this plan does not do and which would invalidate every other row measured against the current tree.

## Scope of the exception

This dossier covers exactly one row: `pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present`. It does **not** cover the model-routing half of AC-12, which is observed directly: three model-routing rows fail against the unmodified hook in `[P4-T5]` and pass in `[P7-T6]`. Nor does it cover binding 2, for which a substitute failing row exists, named below.

## Alternative proof

Three independent records stand in place of a failing run.

### 1. The archived pre-#687 allow

`evidence/baseline/repro-3-2-control-pair.md` archives the reproduction of defect 3.2 recorded before #687 landed: the same gated action, issued from a session root holding a sibling item's ready checkpoint, returned `permissionDecision` `allow`. `[P1-T5]` verified that every `permissionDecision` value and every reason-code token in that artifact is unchanged from `git show HEAD:<path>` after host-token redaction, so the archived decision is the original one. That allow is the behaviour the row now asserts against, and it is what the row would have caught had the row existed then.

### 2. The reproduction verdict

`evidence/baseline/repro-verdict.md` carries exactly one `REPRODUCTION: CONFIRMED` line, and `evidence/other/r3-reproduction-evidence-audit.md` records that the commit adding it, `59b08af5805abaed61f32b14f9f82f8ff58e0a13`, precedes every hook edit on this branch — `git log` over `.claude/hooks` since `F5_BASE_SHA` returns `none`. The defect is therefore confirmed by observation rather than inferred from a test that cannot fail.

### 3. The substitute failing row for binding 2

`pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present` **allows** against the unmodified hooks and must **deny** after the fix. `[P4-T5]` records its status as Failed. That row is the direct fail-before evidence for the second pr-author binding, which #687 did not address: `Test-EpicBaseBranchOverride` takes no checkpoint path today, so check 6 reads the session root's checkpoint whatever binding 1 resolved. The pr-author family therefore does carry a genuinely failing row; it is this one rather than R2.

## Negative-claim auditability

SearchScope: `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/regression-testing/` and `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/`
SearchPatterns: `fail-before-exception.*.md`, `repro-*.md`
SearchResult: this dossier; `evidence/baseline/repro-3-2-control-pair.md`; `evidence/baseline/repro-3-4-control-pair.md`; `evidence/baseline/repro-fixture-manifest.md`; `evidence/baseline/repro-verdict.md`

EXIT_CODE: 0

Output Summary: A failing run of the pr-author sibling-only row is structurally impossible on this tree, because #687 added the deny it asserts before this plan began. Three records stand in its place: the archived pre-#687 `allow`, the confirmed reproduction verdict whose commit precedes every hook edit, and a substitute row for binding 2 that does fail before the fix and is required to pass after it. The model-routing half of AC-12 needs no exception and is observed directly.
