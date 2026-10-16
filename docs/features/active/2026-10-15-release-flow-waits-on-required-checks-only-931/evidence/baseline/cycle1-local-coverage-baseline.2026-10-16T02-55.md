# Cycle 1 Local Script Line-Coverage Baseline (Issue #931)

Timestamp: 2026-10-16T02-55
Scope: the three local numbers are scoped-run values from the cycle1-ps-test call (scan_folders = ["tests/scripts/dev-tools"]). The CI floor is a full-suite value, so the comparison with it is a cross-check; the no-regression comparison in P2-T4 is scoped to scoped.

Schema observed: JaCoCo-style XML. The script is a `<class ... sourcefilename="Invoke-FullReleaseFlow.ps1">` element under the `scripts/dev-tools` package with per-method `<method>` elements and class-level `<counter>` elements (INSTRUCTION, LINE, METHOD, CLASS) with `missed` and `covered` attributes. Class element at line 17816; class-level counters at lines 17877-17880 of artifacts/pester/powershell-coverage.xml.

Class-level counters:
- INSTRUCTION missed=11 covered=203
- LINE missed=7 covered=153
- METHOD missed=4 covered=8
- CLASS missed=0 covered=1

Per-method note: Get-CheckSetVerdict LINE missed=0 covered=16, INSTRUCTION missed=1 covered=32.

covered: 153
valid: 160 (covered 153 + missed 7)
percent: 153 / 160 x 100 = 95.63
COVERAGE_WRITTEN: 2026-10-16T02-54 (date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M)
CALL_TS: 2026-10-16T02-52 (COVERAGE_WRITTEN >= CALL_TS: true)
CI floor percent: 94.26 (greatest ps-coverage-main.*.md, main-branch CI value: 115 covered of 122 valid)
Local percent 95.63 >= CI floor 94.26: true

Output Summary: local scoped line coverage of Invoke-FullReleaseFlow.ps1 is 95.63% (153 of 160 lines).
