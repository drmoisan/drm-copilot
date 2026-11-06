Timestamp: 2026-11-05T05-44
Command: Read current authority resolver and run SCRATCH/issue-1082-diagnose-attestation.sh, then the full 27-file targeted native gate.
EXIT_CODE: 0
Output Summary:

The historical failing diagnostic returned Pester 6 NoMockFound for Test-Path -LiteralPath USERPROFILE/.codex/authority/epic-entry/343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf/s-786. Get-CodexAuthorityStateRoot validates the resolved authority path before constructing the transcript-keyed filename. The entrypoint fixtures had only mocked the attestation filename and had implicitly used real path canonicalization under Pester 5.

The two fixture cases now mock Get-CodexAuthorityStateRoot only when SessionId equals s-786, returning /synthetic-root/state. They retain real transcript-key generation, path construction, selected Test-Path/Get-Content fakes, exit-code-zero assertions and profile/provenance assertions. No user state is read, and no environment variable is overridden. Dedicated authority-store tests remain selected by the complete suite.

Representative proof: Pester 6.2.0, two selected cases passed, zero failed (25 unrelated cases not selected in this diagnostic). The subsequent acceptance run uses all 27 affected files without a test-name filter: 780 discovered, 780 passed, zero failed/skipped/not-run, exit 0. Formatting 42 files and analysis 42 files returned zero findings before that complete targeted run.

Evidence: powershell-fixture-format-final.2026-11-05T05-40.md, powershell-fixture-analyze-final.2026-11-05T05-40.md, powershell-fixture-targeted-final.2026-11-05T05-41.md; diagnostic raw output SCRATCH/issue-1082-pester6-attestation-stderr-diagnostic.log and SCRATCH/issue-1082-pester6-attestation-seam-proof.log.