# Preflight findings — cycle 2

- Timestamp: 2026-08-24T00-45
- Plan under validation: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md` (Version 1.1)
- Validator: `atomic-executor`, directive `PREFLIGHT VALIDATION ONLY`
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Blocking findings: 4 (R9 through R12). Minor findings: 2 (R13, R14).
- No plan task was executed and no file in the worktree was created, modified, or deleted during preflight.

## Cycle-1 findings — verification result

| Finding | Disposition |
| --- | --- |
| R1 | Closed in substance. The Phase 4 gates use the working-tree form, each asserts a non-empty derived list naming the four expected files, P6-T2 is the committed form, Phase 6 is seven contiguous tasks, Trap 4 exists. Porcelain-derivation instructions are correct as far as they go. Residual gap recorded as R13. |
| R2 | Closed. Premises re-verified: the file is tracked, is not ignored, the coverage data file is redirected under the ignored artifacts tree, and no XML output override exists. Restore and confirmation present at all three tasks; the not-an-eighth-entry paragraph is present; P6-T1 carries the recovery instruction. |
| R3 | Partially closed. The AC-12 and AC-17 deferral, the P6-T7 finalizer, and the commit boundary are correct, and the declared non-empty terminal status contradicts nothing, because every clean-tree and scope gate runs strictly before the first post-commit write. The same defect survives for AC-14 and AC-15 — recorded as R9. |
| R4 | Closed in intent, but the fix does not work on this platform — recorded as R11. |
| R5 | Closed. |
| R6 | Closed. The plan's self-description matches the validator run exactly. |
| R7 | Closed in substance; minor imprecision recorded as R14. |
| R8 | Closed. Premise re-verified in the shared test fixtures: `Path.read_text`, `write_text`, `exists`, `is_file` and `Path.open` are patched; builtin `open` is not intercepted. |
| Advisory | Applied at the Phase 0 and Phase 4 type-check tasks. |

Structure re-checked: per-phase IDs are contiguous and sequential (Phase 0 has 9, Phase 1 has 7, Phase 2 has 5, Phase 3 has 10, Phase 4 has 12, Phase 5 has 3, Phase 6 has 7). Every task cross-reference resolves; no dangling reference survived the Phase 6 renumbering. Test counts reconcile at six workflow-contract tests and nine checker tests. Expect-fail tagging is correct. The No-SKIPPED rule names the right task.

## R9 — BLOCKING. AC-14 and AC-15 are checked off before their stated observable can exist.

This is the identical defect R3 named, left in place for two more criteria. Both criteria state their observable as the committed-diff listing. Verified: `HEAD` and `origin/main` are the same commit, so before the plan's first commit that listing is empty. The plan itself agrees — it calls the new post-commit task the falsifiable form of AC-14 and AC-15 — yet Phase 5 checks both off.

Two consequences: Phase 5 marks two criteria complete before the evidence the plan itself designates for them exists, and the Phase 5 index task's acceptance becomes unsatisfiable if those rows name an artifact Phase 6 has not yet written.

Rescope Phase 5 to fifteen criteria, deferring AC-12, AC-14, AC-15 and AC-17. Mark all four pending in the index, naming the task that will finalize each rather than an artifact path. Extend the Phase 6 finalizer to close all four, requiring the AC-14 and AC-15 rows to name the committed-scope artifact and requiring that artifact to record a passing verdict for its write-set conditions. Update the Phase 5 preamble and the commit-boundary paragraph from two deferred criteria to four.

## R10 — BLOCKING. The write set omits two feature-folder files that the first commit includes.

Verified: the entire feature folder is untracked at `origin/main`. The working-tree listing today contains five paths, two of which fall under none of the seven declared write-set entries — the issue document and the research document. Entry 5 names only the plan file, entry 6 only the spec, entry 7 only the evidence tree. The first commit commits every edit from Phases 1 through 5 and then requires a clean tree, so both files are committed. The Phase 4 write-set gate and the post-commit scope gate then both halt on paths outside the closed write set.

This was invisible in cycle 1 because the gate read an empty committed diff. R1's fix made the gate real and exposed the gap.

For the parallel run's blast-radius computation, both paths are files this work item writes to the branch and were undeclared.

Add both as write-set entries 8 and 9, each annotated as authored upstream of this plan, untracked at `origin/main`, and committed unmodified. Add a paragraph explaining why they appear in both scope gates despite this plan not editing them. Update both gates from seven entries to nine.

## R11 — BLOCKING. The cycle-1 fix hard-blocks the plan on Windows because the two compared paths use different separators.

The environment-provenance task compares the resolved module path against the resolved repository root with a literal prefix test, and its failure verdict is BLOCKED. Verified empirically in this worktree: `git rev-parse --show-toplevel` emits forward slashes, while the module's `__file__` emits the native backslash separator, so the literal prefix test returns false in a correct checkout. That produces a spurious BLOCKED at the plan's second task — precisely the outcome R4 was raised to eliminate.

The normalized comparison returns true. Replace the containment test with a resolved `pathlib` relative-path check performed inside the probe itself, have the probe print the module path, the resolved root and the boolean, and require the printed boolean to be true. State explicitly that the test must never be a literal string-prefix comparison, and record the separator reason inline so a later editor does not simplify it back.

## R12 — BLOCKING. The spec check-off task's third acceptance condition cannot fail.

The task requires that the diff of the spec show only checkbox-state changes. The spec is untracked until the first commit, so a diff of it produces no output whatever the executor did. The condition is satisfied by emptiness — the same class of defect this work item repairs.

Replace the diff condition with a structural one: record the file's total line count before the edit, and require after the edit that the acceptance-criteria section contain exactly nineteen criterion lines of which exactly fifteen are checked and exactly four are unchecked, that the four unchecked lines are the four deferred criteria, and that the total line count is unchanged. Record both counts in the index artifact. State inline why a committed-diff check is deliberately not used.

## R13 — Minor. Trap 4's binding phrase matches no gate, and it omits the quoting case.

Trap 4 binds itself to a phrase no task uses: the Phase 4 gates say "derived path list" and the post-commit gate says "recorded name list". One Phase 4 task also restates only the status-field strip, dropping the rename expansion. Separately, `git status --porcelain` wraps a path containing a space or a non-ASCII byte in double quotes with C-style escapes, which Trap 4 does not mention.

Rewrite Trap 4 to cover the status-field strip, the rename arrow expansion, and the quoted-path unescaping; bind it to the exact phrase the Phase 4 gates use; and state that the post-commit gate reads a bare name list needing none of this handling. Replace the Phase 4 task's inline restatement with a reference to Trap 4.

## R14 — Minor. The evidence-accounting enumeration names tasks that run no command, and its carve-out misses four Phase 6 tasks.

The rule requires the four schema fields of every command-bearing task that names an artifact, then enumerates five tasks that run no command, demanding a command row and an exit-code row for artifacts that have none. Separately the carve-out covers only Phases 1 through 3 and omits four command-bearing Phase 6 tasks that name no artifact of their own.

Split the enumeration into command tasks that name an artifact and record all four fields, and record-only tasks that name an artifact but run no command and record only a timestamp plus the artifact's own content. Extend the carve-out to name the four Phase 6 git-operation tasks and state that their state is consolidated into the post-commit scope artifact and the green-run artifact.

## Write-set boundary — preflight result

With entries 8 and 9 added per R10, the write set is closed and accurate. Re-verified that no task writes the project manifest, anything under the canonical instructions tree, the two bundled mirrors, any of the nine deferred occurrences, or anything under the archive, completed, or potential trees. The JSON coverage reports and the coverage data file are all matched by the ignored artifacts tree and are correctly excluded. The tracked root XML report is written by exactly the three tasks the plan names and is restored by each. The green-run dispatch remains the last branch-head-changing action.
