# Bundled Mirror Byte-Identity — PoshQC.Testing.psm1 (issue #409)

Timestamp: 2026-07-25T11-11

Command: `pwsh -NoLogo -NoProfile -Command "Copy-Item scripts/powershell/PoshQC/PoshQC.Testing.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 -Force; (Get-FileHash scripts/powershell/PoshQC/PoshQC.Testing.psm1).Hash; (Get-FileHash extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1).Hash"`

EXIT_CODE: 0

Output Summary:
- SHA256 of `scripts/powershell/PoshQC/PoshQC.Testing.psm1`:
  `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280`
- SHA256 of `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`:
  `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280`
- **The two hashes are identical.** The bundled mirror is byte-identical to the repo-root source.
- Corroborating check with git object hashing (`git hash-object`): both files hash to blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`. Pre-change both were blob `53756b61a31c0a90b11e51e96f099fb6375c0af4`.
- Production surface remains exactly the two approved files.
