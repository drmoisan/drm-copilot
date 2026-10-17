# Plan trivial fixes (issue #962)

Timestamp: 2026-10-16T23-15
Command: Edit tool on docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md (one edit per entry below)
EXIT_CODE: 0
Output Summary: Trivial plan defects found during execution after the origin/main merge (4e82b3a3c, which brought in #953) were corrected in place under the coordinator instruction. Each entry records the task, the old text, the new text, and the reason.

## Fix 1

- Task: P0-T2
- Old text: `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` (the untracked evidence folder, which exists because P0-T1 wrote its artifact first)
- New text: `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` or `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/baseline/` (the untracked evidence folder or, when `evidence/other/` is already tracked, its untracked `baseline/` subfolder, which exists because P0-T1 wrote its artifact first)
- Reason: the pre-mortem commit bc67ae0fc tracks `evidence/other/pre-mortem.2026-10-16T23-12.md`, so git reports the untracked `evidence/baseline/` subfolder rather than the whole `evidence/` folder.

## Fix 2

- Recorded: 2026-10-17T00-09 (rule 17 RI-2 re-run of P0-T9)
- Task: P0-T9 (B6 block check)
- Old text: `In the sharded shape B6 passes only when the CR output carries one line beginning `EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=`, one line beginning `EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=`, and no `EDIT-TARGET-A4-CANDIDATE:` or `EDIT-TARGET-A4C-CANDIDATE:` line.`
- New text: the same sentence followed by: `On a rule 17 re-run after A4 was applied by P4-T6 and kept by a conflict-free merge, B6 also passes when both counts are 0 and the only candidate lines are one EDIT-TARGET-A4-CANDIDATE line whose text is the A4 replacement line and one EDIT-TARGET-A4C-CANDIDATE line whose text is the A4C replacement line of section 7 (A4 already applied).`
- Reason: P0-T9 is re-run by rule 17 RI-2 on a tree where A4 and A4C were already applied in P4-T6. The merge of origin/main b8fcd7790 did not touch tests/scripts/workflows/PoshQcWorkflow.Tests.ps1, so the pre-A4 target text is absent by construction and the observed candidates are exactly the section 7 replacement texts (lines 85 and 51). The pre-edit-only wording would report B6=fail for the intended state.

## Fix 3

- Recorded: 2026-10-17T00-09 (rule 17 RI-2 re-run of P0-T9)
- Task: P6-T5
- Old text: `run `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<LIST-NEW-TESTS>,<LIST-EXISTING-SUITES>" -NamePatternList "<PATTERNS-UNIT>,<PATTERNS-WORKFLOW>,<PATTERNS-PARSER>"` in one invocation`
- New text: the same text followed by `(a path that appears in both lists is passed once; after the post-Phase-1 re-run of CR-INVENTORY, LIST-EXISTING-SUITES also contains tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1)`
- Reason (Fix 3): CR-INVENTORY lists every tests/scripts/workflows/*.Tests.ps1 present at run time. At plan revision time the new W suite did not exist; on the rule 17 re-run it does, so the comma-joined path list would name it twice and double-count its NAMED totals against the section 8 figures.

## Fix 4

- Recorded: 2026-10-17T00-12 (rule 17 RI-3 re-run of P4-T6)
- Task: P4-T6 (when re-run by rule 17 RI-3)
- Old text: `git diff --numstat HEAD -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (in the sharded done-when: prints one line reading `2`, a tab, `2`, a tab, and the path)
- New text: `git diff --numstat HEAD -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, or, on a rule 17 re-run after the P4-T6 edits are committed, `git diff --numstat origin/main -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (same expected line)
- Reason: the A4 edit was committed in P4-T16 before rule 17 was entered, so the HEAD-anchored diff prints nothing on the re-run; the origin/main-anchored diff observes the same two changed lines that the condition asserts.

## Fix 5

- Recorded: 2026-10-17T00-21 (P6-T10, QA pass 2)
- Task: P6-T10 (CR-SCOPE -AllowedList)
- Old text: `-AllowedList ".github/workflows/ci.yml,...,tests/shell/test_shell_qc_commands.bats"` (twenty paths)
- New text: the same list followed by `,docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md` (twenty-one paths), with the note that this entry is the pre-execution promotion lifecycle record and is not a write of this plan
- Reason: CR-SCOPE compares `git diff --name-only origin/main...HEAD` with the allowed list. The promotion lifecycle record docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md was added by the feature-initialization commit d7b975636 (the same commit that added issue.md, before planning) and has not changed since (`git log` lists only d7b975636 for the path). It is outside the feature folder, so the check reported SCOPE-OUTSIDE-WRITE-SET: 1 although the plan never writes it. The same correction was made on the #952 branch (commit 1b6149df1, "account for the pre-execution lifecycle record in the P8-T13 scope check").
