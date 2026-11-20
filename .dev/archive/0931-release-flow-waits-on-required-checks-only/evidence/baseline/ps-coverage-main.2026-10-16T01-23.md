# PowerShell Per-File Coverage Baseline (Issue #931)

Timestamp: 2026-10-16T01-23
Command: gh run download 38730332356 -n poshqc-test-results -D SCRATCH/931/baseline-coverage
EXIT_CODE: 0
Output Summary: Baseline line coverage of scripts/dev-tools/Invoke-FullReleaseFlow.ps1 on main (RUN_ID 38730332356) is 94.26% (115 covered of 122 valid lines).

RUN_ID: 38730332356
RUN_SHA: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99
Artifact name: poshqc-test-results
Producing job: `poshqc / PowerShell QC` (`windows-latest`)
Downloaded files (read with the Read and Grep tools only): `SCRATCH/931/baseline-coverage/pester-junit.xml`, `SCRATCH/931/baseline-coverage/powershell-coverage.xml`, `SCRATCH/931/baseline-coverage/powershell-coverage.koverage.xml`

## Schema observed

`powershell-coverage.xml` is JaCoCo-style XML. Each script is a `<class>` element carrying per-method `<method>` elements and class-level `<counter>` elements of types `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS`, each with `missed` and `covered` attributes.

Entry located with Grep at line 24767 of the downloaded file:

```
<class name="<ci-runner-checkout>/scripts/dev-tools/Invoke-FullReleaseFlow" sourcefilename="Invoke-FullReleaseFlow.ps1">
```

Class-level counters (lines 24818-24821):

```
<counter type="INSTRUCTION" missed="10" covered="155" />
<counter type="LINE" missed="7" covered="115" />
<counter type="METHOD" missed="4" covered="6" />
<counter type="CLASS" missed="0" covered="1" />
```

Per-method LINE counters of note: `Wait-ForPullRequestChecks` missed 0, covered 26; uncovered methods are the wrapper seams `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-ChildPowerShellScript` (2 lines each) and `Invoke-Sleep` (1 line), which tests mock.

## Derived values

- covered lines: 115
- valid lines: 122 (covered 115 + missed 7)
- percent: 115 / 122 x 100 = 94.26
