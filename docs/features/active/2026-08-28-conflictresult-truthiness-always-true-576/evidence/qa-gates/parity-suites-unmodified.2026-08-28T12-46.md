# Parity Suites and Frozen Key-Set Assertion Survived — [P6-T12]

Timestamp: 2026-08-28T12-46

Command: `git diff --stat origin/main -- tests/scripts/dev_tools tests/scripts/claude-lib`, then `git diff origin/main -- tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`

EXIT_CODE: 0

## Anchored Stat Listing

```
 .../blast-radius/BlastRadius.Conflict.Tests.ps1    | 33 +++++++++++++++++
 .../dev_tools/test_blast_radius_conflicts.py       | 42 ++++++++++++++++++++++
 .../dev_tools/test_blast_radius_invariants.py      | 10 ++++++
 3 files changed, 85 insertions(+)
```

Three files changed, 85 insertions, zero deletions. The `--stat` renderer abbreviates the leading
path segments, so the same anchored span was additionally listed by full path:

```
$ git diff --name-only origin/main -- tests/scripts/dev_tools tests/scripts/claude-lib
tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
tests/scripts/dev_tools/test_blast_radius_conflicts.py
tests/scripts/dev_tools/test_blast_radius_invariants.py
```

Exit code 0. Exactly three paths, which are exactly the three test files of the plan's declared test
scope.

| Check | Result |
| --- | --- |
| Names exactly the three declared test files | Yes; three rows, and the summary reads `3 files changed`. |
| Does not name the Python parity suite test_blast_radius_parity.py under tests/scripts/dev_tools | Yes; absent from both listings. |
| Does not name the PowerShell parity suite BlastRadius.Parity.Tests.ps1 under tests/scripts/claude-lib/blast-radius | Yes; absent from both listings. |

## Anchored Content Diff of the Pester Conflict File

```diff
@@ -83,6 +83,39 @@ Describe 'Test-BlastRadiusConflict result shape' {
             { Test-BlastRadiusConflict -RadiusA (Get-TestRadius) -RadiusB (Get-TestRadius) `
                     -Config 'not-a-mapping' } | Should -Throw '*must be a mapping*'
         }
+
+        It 'is unconditionally truthy even when its conflict key is false' {
...
+        It 'documents the truthiness divergence in its comment-based help' {
...
     }
 }
```

One hunk, starting at line 83, adding 33 lines and removing none. The hunk begins after the closing
brace of the pre-existing `It 'throws when the truth table is not a mapping'` and adds two new `It`
blocks inside the same `Context`.

The existing `It 'returns the conflict verdict and a reasons collection'` occupies lines 56 to 67 of
the pre-change file, entirely above the single hunk's start at line 83. It therefore appears nowhere
in the diff: no line inside it is added, removed, or modified. That `It` carries the frozen two-key
result-shape assertion
`@($result.Keys | Sort-Object) | Should -Be @('conflict', 'reasons')`, which is unchanged.

## Both Parity Files Reported Passed

| Suite | Run | Evidence |
| --- | --- | --- |
| PowerShell parity suite BlastRadius.Parity.Tests.ps1 under tests/scripts/claude-lib/blast-radius | [P6-T8] | 76 `testcase` elements in the Pester JUnit XML under artifacts/pester carry `classname` naming that file; all 76 read `status` `Passed`, and 0 read anything else. The run's `Tests Passed:` line reports `Failed: 0` overall. |
| Python parity suite test_blast_radius_parity.py under tests/scripts/dev_tools | [P6-T4] | The judged full-suite run reports 4209 passed, 0 failed, 5 skipped at exit code 0, with no `FAILED` row in the short test summary. Every test in the Python parity suite is inside that green run. |

Neither file was modified, and both passed unchanged. The shared JSON fixture corpus under
tests/fixtures/blast_radius was not extended: it appears in neither anchored listing. Truthiness is a
property on which the two runtimes provably cannot agree — the Python `ConflictResult` now projects to
its verdict while the PowerShell hashtable is unconditionally truthy — so a parity assertion on it
would assert a falsehood. The divergence is instead recorded in the module comment-based help and
pinned by the two `It` blocks added here.

Output Summary: `EXIT_CODE: 0`. The anchored stat listing over `tests/scripts/dev_tools` and
`tests/scripts/claude-lib` names exactly the three test files in the declared test scope, with 85
insertions and no deletions, and names neither the Python parity suite test_blast_radius_parity.py
under tests/scripts/dev_tools nor the PowerShell parity suite BlastRadius.Parity.Tests.ps1 under
tests/scripts/claude-lib/blast-radius. The anchored content diff of the Pester conflict file is a
single additive hunk beginning at line 83, so no changed line appears inside the existing
`It 'returns the conflict verdict and a reasons collection'`, which spans lines 56 to 67 and carries
the frozen two-key assertion. Both parity files were reported passed: 76 of 76 `Passed` in the
[P6-T8] PowerShell run and inside the zero-failure [P6-T4] Python run. This task discharges AC8 and
AC20.
