# P0-T4 Scratch helper scripts A1-A4

Timestamp: 2026-10-03T09-38
Command: Get-FileHash -Algorithm SHA256 -LiteralPath "SCRATCH/cov-derive.ps1", "SCRATCH/issue824-pester.ps1", "SCRATCH/resolver-ast-check.ps1", "SCRATCH/phrase-scan.ps1" | ForEach-Object { $_.Hash }
EXIT_CODE: 0
Output Summary:
- A1 SCRATCH/cov-derive.ps1: 38EF8213FAC81A3A37478B217D9D494B5A1E3652958F6808636778E5CEAF6E7E
- A2 SCRATCH/issue824-pester.ps1: 4ABF31AE80F6219243CA1D7489DC2A162D14FB967B9CCFF0788EF6AC979A7E6C
- A3 SCRATCH/resolver-ast-check.ps1: 0AA6845657BCA73EFC83DB1D5D12BBF86B1B7F7165349196492F5802EF0F8DEC
- A4 SCRATCH/phrase-scan.ps1: 936C49C3BFA5F382281C1AA34D0A5C6355D287FB1CC44BF6DF0C4FBF7B8F5C0B
- All four written verbatim from the plan Appendix with the Write tool. Result: PASS (four hash lines).
