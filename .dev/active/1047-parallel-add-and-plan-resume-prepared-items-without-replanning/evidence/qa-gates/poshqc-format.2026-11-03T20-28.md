# PowerShell Format Gate (loop pass 3)

Timestamp: 2026-11-03T20-28
Task: [P6-T1]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-static.ps1 -Apply: per file, Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 with the result written back only when it differs, and SHA256 before and after
EXIT_CODE: 0
Output Summary: 5 of 5 files unchanged (SHA256 before equals after; FORMAT_WOULD_CHANGE=False for each).

Loop history: pass 1 failed at [P6-T2] (two analyzer findings, fixed). Pass 2 completed [P6-T1] to [P6-T12], but [P6-T13] found Invoke-ParallelAdmission.ps1 at 95.18% line coverage, below its 96.15% baseline: the stream split added to the mocked seam Invoke-ParallelAdmissionGit had three more executable lines. The seam was reduced to two executable statements with the same behavior (probed against a real git process: exit 128 with stderr "fatal: invalid object name 'nope'.", exit 0 with stdout only), the bundle copy was refreshed, and the loop restarted at [P6-T1]; this record is pass 3.

| File | SHA256 before | SHA256 after | Changed |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 7F0A6920239DB6B623A641F075D4CEB7D0776F686CAA9AF6AA87CACB7A21090A | 7F0A6920239DB6B623A641F075D4CEB7D0776F686CAA9AF6AA87CACB7A21090A | no |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | C6AC782780F6058EDACF165E30576DE11714D7EE06BA2DF3684DD8FAC282A1E0 | C6AC782780F6058EDACF165E30576DE11714D7EE06BA2DF3684DD8FAC282A1E0 | no |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 2C5F1CBB232DD110429549352E3B5CD897BF37082E7C7C1C31B02007B15F070C | 2C5F1CBB232DD110429549352E3B5CD897BF37082E7C7C1C31B02007B15F070C | no |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 21CE00A0991C792093B31744B621498F21EB87548A3CAC12C239A753F3DFD40D | 21CE00A0991C792093B31744B621498F21EB87548A3CAC12C239A753F3DFD40D | no |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 605D7D8C5D1E05677B014A4962309CD36C9FD338AD0F73E244A79C72D2CB0962 | 605D7D8C5D1E05677B014A4962309CD36C9FD338AD0F73E244A79C72D2CB0962 | no |
