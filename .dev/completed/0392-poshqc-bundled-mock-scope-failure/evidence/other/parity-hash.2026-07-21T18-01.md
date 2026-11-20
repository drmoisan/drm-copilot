# Parity Hash — PoshQC.Testing.psm1 (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `Get-FileHash -Algorithm SHA256` on repo-root and bundled `PoshQC.Testing.psm1` after `cp` mirror.
EXIT_CODE: 0
Output Summary:
- Initial mirror hash (before removal-path correction): `3B8B4B1DE25A300FE48AE0473245DD1F5A18268AF191BAA3E9F9A010E1F5CA65` (both copies equal).
- Correction (P3-T1 unit test uncovered): the research-sketched `finally` used `Remove-Item -Path 'function:global:Invoke-PoshQCPesterRun'`, which is silently a no-op (the `global:` scope qualifier is honored by `New-Item` but not by `Remove-Item` on the function provider), leaving the trampoline leaked. Changed to `Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun'`, which removes the global function.
- Final mirror hash (after correction): `248CDFC8F5A4DD2C3B9D187E9F0DFBBFBD79F1797F0A48DD7C62F5BDF51EB93E`
  - Repo-root `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: `248CDFC8F5A4DD2C3B9D187E9F0DFBBFBD79F1797F0A48DD7C62F5BDF51EB93E`
  - Bundled `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`: `248CDFC8F5A4DD2C3B9D187E9F0DFBBFBD79F1797F0A48DD7C62F5BDF51EB93E`
- EQUAL = True. Byte-identical parity confirmed for the final content.
