# P4 Schema File-Set Contract - Issue #1021

Timestamp: 2026-11-03T23-21
Task: [P4-T7]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1 issue-1021-p4-contract.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`); `git diff --unified=0 MERGE_BASE -- tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`
EXIT_CODE: 0
Output Summary: TOTAL=49 PASSED=49 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. The diff changes lines inside `keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs` only. CI: CI-PESTER.

## Change

In test `keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs`, the exact-count assertion on `$canonicalNames` (eight files) is replaced by set equality of `$canonicalNames` with the `Get-DocsSchemaName` names, each suffixed `.schema.json` and ordinal-sorted. The `$runtimeNames` equality and the byte-identity loop are unchanged; no other test in the file changes.

Reason: the exact count was the only assertion that the ninth schema `schemas/docs/v1/page-metadata.schema.json` ([P1-T1]) breaks (`1020-test-dispositions`). Equality with the schema registry still fails for an unregistered or missing schema file and needs no further edit when a sibling child registers a schema.

## Diff (MERGE_BASE derivation of `origin/epic/documentation-estate-tooling-integration` and `HEAD`)

```text
@@ -267,0 +268,3 @@ Describe 'Runtime copies, parity and references' {
+        $schemaNames = Get-DocsSchemaName
+        [string[]] $registeredNames = @($schemaNames | ForEach-Object { "$_.schema.json" })
+        [Array]::Sort($registeredNames, [System.StringComparer]::Ordinal)
@@ -270 +273 @@ Describe 'Runtime copies, parity and references' {
-        $canonicalNames.Count | Should -Be 8
+        $canonicalNames | Should -Be $registeredNames
```

Both hunks lie inside the `It` block that starts with the test name above (the hunk headers name the enclosing `Describe`, and the `It` line is the line before the `# Arrange` comment of this block).

## Sibling tests (re-run, unchanged)

`returns no composition finding` and `references only docs common definitions or local definitions from every docs schema` iterate the committed set and therefore cover `page-metadata`; they pass. The `-ForEach` kind lists of `validates the <_> example with Test-Json True and no Test-DocsArtifactText finding` and the rejection cases do not name `page-metadata`.
