# Remediation Cycle 1 - Bundled Copy Identity (P0-T11)

Timestamp: 2026-10-16T11-25
Command: sh SCRATCH/issue-953-r1-p0-t11.sh (pwsh -NoProfile -Command: foreach ($n in 'PoshQC.Testing.psm1', 'PoshQC.psm1') { (Get-FileHash -Algorithm SHA256 -LiteralPath "scripts/powershell/PoshQC/$n").Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath "extensions/drm-copilot/resources/powershell/PoshQC/$n").Hash })
EXIT_CODE: 0
Output Summary: Both repo/bundled pairs are byte-identical.
PoshQC.Testing.psm1 repo=A898747A299FF47D545547E45733248FF741A79966E5E90413570066E86108F3 bundled=A898747A299FF47D545547E45733248FF741A79966E5E90413570066E86108F3
PoshQC.psm1 repo=CE9D8565CF915841A0C435DC52FAEFA8A4EAE08109736F6801C1E05945BAD834 bundled=CE9D8565CF915841A0C435DC52FAEFA8A4EAE08109736F6801C1E05945BAD834

PAIR_1_EQUAL: YES
PAIR_2_EQUAL: YES
