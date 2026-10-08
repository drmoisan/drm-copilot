# Final Mirror Parity (P6-T2)

Timestamp: 2026-10-02T08-45
Command: `git -C <ROOT> hash-object scripts/powershell/PoshQC/<f> extensions/drm-copilot/resources/powershell/PoshQC/<f>` for the six files (DEV-P6-T2; replaces rule HS SHA256 with the git blob hash, which is equal exactly when the bytes are equal).
EXIT_CODE: 0
Output Summary: all six pairs equal.
- Acceptance: all six pairs have equal hash values. Met.

| File | scripts/powershell/PoshQC | extensions/drm-copilot/resources/powershell/PoshQC | Result |
| --- | --- | --- | --- |
| PoshQC.Coverage.psm1 | 23cd722f1f40485413c57246269d8816c765bfc1 | 23cd722f1f40485413c57246269d8816c765bfc1 | EQUAL |
| PoshQC.Testing.psm1 | 8a3d6acfc8c1e74145651d53305a5d8178ee0db1 | 8a3d6acfc8c1e74145651d53305a5d8178ee0db1 | EQUAL |
| PoshQC.psm1 | 2ce1628f21cc3faa0bd0aa02b95054cf3db09614 | 2ce1628f21cc3faa0bd0aa02b95054cf3db09614 | EQUAL |
| PoshQC.psd1 | 99221aea0a01683c4682bcc738935474bd35ab71 | 99221aea0a01683c4682bcc738935474bd35ab71 | EQUAL |
| settings/pester.runsettings.psd1 | b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8 | b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8 | EQUAL |
| README.md | 7f035c3f12926e8fd4f302000386f2ffcdf203bf | 7f035c3f12926e8fd4f302000386f2ffcdf203bf | EQUAL |
