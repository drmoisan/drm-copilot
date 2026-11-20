# Task Check P1-T7

Timestamp: 2026-11-14T07-38
Command: git archive of the merge base of origin/main and HEAD (selected paths) extracted to SCRATCH/mb-p1t7 with the new test file placed in its tests/scripts/claude-runtime/, run by pwsh SCRATCH/issue-1173-mbrun.ps1; sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p1t7.txt p1t7 / p1t7b; sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p1t7.txt; pwsh SCRATCH/issue-1173-leak.ps1 (Invoke-PoshQCLeakScan -Root); sh SCRATCH/issue-1173-pymirror.sh
EXIT_CODE: 0
Output Summary:
- New file: tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1 (dot-sources DocsAuthoringRoles.Helpers.ps1; section-scoped per `## ` heading; whitespace-normalized ordinal Contains; Codex text through Get-DocsCodexEmbeddedText; AfterAll removes Get-DocsWorkflowSectionText and every helper function). 36 rows: `inventory -Write` before the docs-inventory-surface link in `## Dispatch Order` (6 documentation-workflow copies); "the root persists the snapshot" in `## Steps` (6 docs-inventory-surface copies); "value for relative form only" in `## Hook Execution Context` (6 brief copies); the B12 tokens (the four words, "may be refused by the runtime", and "root step" for docs-plan-ia or "the root writes it" for docs-author-page and docs-author) in `## Steps` of the 12 skill copies and `## Write Scope` of the 6 docs-author copies.
- Fail-before against the merge-base copy: 0 passed, 36 failed (every B1 and B12 row).
- First worktree run: exit 6; the six `## Dispatch Order` rows failed because the P1-T3 step text named the command `-Command inventory -Profile ... -Write` without the contiguous literal `inventory -Write` that P1-T3 requires. Fix within P1-T3 scope: the step label in the six documentation-workflow copies now reads "Root `inventory -Write` step (root)"; each copy has one such line; host and bundle pairs stay byte-identical.
- Second worktree run (WorkflowText, Skills, Mirrors, CommitStage): exit 0, 239 passed, 0 failed. Push-down resource contracts: 23 passed.
- Static (new file): format drift 0, PSScriptAnalyzer findings 0. Leak scan: 791 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.
