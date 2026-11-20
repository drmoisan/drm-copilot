# Task Check [P2-T9]

Timestamp: 2026-11-19T11-01
Command: sh SCRATCH/issue-1049-bundle-copy.sh (exit 0)
EXIT_CODE: 0
Output Summary: Changed files: extensions/drm-copilot/resources/powershell/PoshQC/{PoshQC.VendoredCoverage.psm1 (new), PoshQC.Coverage.psm1, PoshQC.Testing.psm1, PoshQC.psm1, PoshQC.psd1, README.md}; evidence/qa-gates/poshqc-bundle-copy.2026-11-19T11-01.md. Result: six SHA-256 pairs EQUAL, so the bundle copies carry the same format and analyzer state as the repo-root files checked in [P2-T1] to [P2-T4]. Selection rule: the contract test that reads the bundle copies is tests/scripts/dev_tools/test_poshqc_bundled_parity.py; its path tuple gains the new submodule in [P2-T10], whose task check runs it.
