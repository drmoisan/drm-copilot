# P5-T2 to P5-T6 Bundled Mirror Copies

Timestamp: 2026-10-02T08-50
Command: for each pair, git -C <ROOT> show HEAD:<source> > <ROOT>/<mirror> (HEAD = 9b5aa44e, which contains all five committed sources); then git -C <ROOT> hash-object <source> <mirror>; then cmp <ROOT>/<source> <ROOT>/<mirror>
EXIT_CODE: 0
Output Summary: five mirror files produced as byte copies of the committed source blobs (deviation DEV-P5-MIRROR replaces `Copy-Item` in a `pwsh` child and rule HS). For every pair the two `git hash-object` values are equal and `cmp` reported no difference. P5-T2 to P5-T6 acceptance (equal hashes) is met.

| Task | Source | Mirror | Source hash-object | Mirror hash-object | Equal |
| --- | --- | --- | --- | --- | --- |
| P5-T2 | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1` | `23cd722f1f40485413c57246269d8816c765bfc1` | `23cd722f1f40485413c57246269d8816c765bfc1` | yes |
| P5-T3 | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | `8a3d6acfc8c1e74145651d53305a5d8178ee0db1` | `8a3d6acfc8c1e74145651d53305a5d8178ee0db1` | yes |
| P5-T4 | `scripts/powershell/PoshQC/PoshQC.psm1` | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` | `2ce1628f21cc3faa0bd0aa02b95054cf3db09614` | `2ce1628f21cc3faa0bd0aa02b95054cf3db09614` | yes |
| P5-T5 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8` | `b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8` | yes |
| P5-T6 | `scripts/powershell/PoshQC/README.md` | `extensions/drm-copilot/resources/powershell/PoshQC/README.md` | `7f035c3f12926e8fd4f302000386f2ffcdf203bf` | `7f035c3f12926e8fd4f302000386f2ffcdf203bf` | yes |
