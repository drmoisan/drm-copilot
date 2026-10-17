# Clean single pass confirmation (P2-T9)

Timestamp: 2026-10-16T03-22

Command: sh SCRATCH/issue-930/P2-T9.sh (INLINE-HASH catalogue entry: Get-FileHash -Algorithm SHA256 on the module then the Invoke test file)

EXIT_CODE: 0

Output Summary:
- Module SHA256: E59E48018464339361D4A520863BDCCA9EEF44468CE50590CD3A9DB02972355B
- Invoke test file SHA256: EC3BE030E512F09648F0B5BC1500AECAF410D9747A5A8D03E1B4F002E5DA2B54
- Both equal the after-observation hashes in format-check.2026-10-16T02-54.md; no step in P2-T1 through P2-T8 of this pass changed either file.
