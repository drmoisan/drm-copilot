# Coverage-Invariance Proof (spec AC 4, issue #409)

Timestamp: 2026-07-25T11-32

Command: `pwsh -NoLogo -NoProfile -Command "<extract-and-compare>"` — a single invocation that loads both preserved coverage XMLs, extracts the distinct per-file entry set from each as sorted-unique `<package name>/<sourcefile name>` pairs, compares them with `Compare-Object`, and computes both report-level covered percentages:

```powershell
$base = [xml](Get-Content -Raw docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml)
$post = [xml](Get-Content -Raw docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml)
function Get-EntrySet($doc) { @($doc.report.package | ForEach-Object { $p = $_.name; @($_.sourcefile) | ForEach-Object { "$p/$($_.name)" } }) | Sort-Object -Unique }
$b = Get-EntrySet $base; $p = Get-EntrySet $post
Compare-Object -ReferenceObject $b -DifferenceObject $p
```

EXIT_CODE: 0

Inputs (both produced by the identical direct repo-root module invocation, so the comparison isolates the code change):
- Baseline: `evidence/baseline/powershell-coverage.baseline.xml` — task [P0-T5], pre-fix module blob `53756b61a31c0a90b11e51e96f099fb6375c0af4`.
- Post-change: `evidence/qa-gates/powershell-coverage.post-change.xml` — task [P4-T4], fixed module blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`.

Output Summary:
- **Identical-set assertion: PASS.** `Compare-Object` returned `$null` (no difference objects), i.e. `SETS_IDENTICAL=True`. No file was added to or dropped from coverage measurement.
- File counts: baseline **31**, post-change **31**.
- Covered percent, command/instruction: baseline **89.64%**, post-change **89.68%** — `post >= baseline` is **True**. No coverage reduction.
- Covered percent, line: baseline **90.19%**, post-change **90.22%** — `post >= baseline` is **True**. No coverage reduction.
- **Prune-message count = 0 from the [P4-T4] fixed-module run.** Verified in that task by `grep -c "Pruned nonexistent code coverage path:"` against the captured run log; the disable-message count was also 0.
- Changed-file detail (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`): LINE moved from covered 195 / missed 0 to covered 202 / missed 0 (100.00% both before and after); INSTRUCTION moved from covered 263 / missed 4 to covered 276 / missed 4 (98.50% to 98.57%). The missed counts did not increase, so there is no regression on changed lines.

Conclusion: behavior is unchanged when every configured coverage path exists. The measured per-file coverage set is byte-for-byte the same 31 entries before and after the fix, the covered percent is equal or better on both counters, and the fixed module emitted zero prune messages against this repository.
