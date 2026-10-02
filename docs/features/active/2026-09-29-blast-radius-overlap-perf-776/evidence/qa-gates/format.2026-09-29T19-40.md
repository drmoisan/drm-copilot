# Format Gate (P2-T1)

Timestamp: 2026-09-29T19-40
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1; mcp__drm-copilot__run_poshqc_format (workspace_root REPO, scan_folders [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]); the same A5 command; git status --porcelain -- .claude/lib/blast-radius tests/scripts/claude-lib/blast-radius
EXIT_CODE: 0
Output Summary:
- Hashes before and after the MCP format call are identical:
  - GLOB D45805B91BD6F7F9BD79366687B2A08A4D291C47A7A951C3EE300DD4982411AE
  - CONFLICT E66D04D147C844CC09BB94456B38FFFDAF0C6A67A9B965A60DF001824347196D
  - TEST-CACHE DE9C0580AFA2685B83EC56AE5EEE7173D809A0E8766EC1CEBE0583550CD9C205
  - TEST-OVERLAP 8D3E67D2F6B0A35257596DD9DF49D491B93C6ECA12788A5AFCA9492B095092A8
- MCP result: {"ok":true,"tool":"run_poshqc_format","summary":"Ran bundled PoshQC format against 'REPO' with 2 selected scan folder(s)."}
- git status --porcelain lists only the four in-scope files: ` M` for BlastRadiusConflict.psm1 and BlastRadiusGlob.psm1, `??` for BlastRadiusConflict.PathOverlap.Tests.ps1 and BlastRadiusGlob.RegexCache.Tests.ps1.
- The formatter changed no file.
- Result: PASS.
