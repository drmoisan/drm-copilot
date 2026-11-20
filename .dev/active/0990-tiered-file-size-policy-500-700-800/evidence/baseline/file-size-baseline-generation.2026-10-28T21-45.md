# File-Size Baseline Generation

Timestamp: 2026-10-28T21-45
Command: (sh launcher under SCRATCH, PowerShell 7.6) run 1: scripts/ci/New-FileSizeBaseline.ps1 -Ref a7a928d59fd52610c1a627448c8fffac106b23c5 -OutputPath config/file-size-baseline.json; run 2: scripts/ci/New-FileSizeBaseline.ps1 -Ref a7a928d59fd52610c1a627448c8fffac106b23c5 -OutputPath SCRATCH/issue-990-baseline-second.json; sha256sum of both outputs
EXIT_CODE: 0
Output Summary:
- Ref: a7a928d59fd52610c1a627448c8fffac106b23c5 (MERGE_BASE recorded in [P0-T2]; the merge base of origin/main and HEAD).
- Run 1 exit 0 (`Wrote config/file-size-baseline.json with 1 entries`); run 2 exit 0 (`Wrote SCRATCH/issue-990-baseline-second.json with 1 entries`).
- SHA256 run 1 (config/file-size-baseline.json): 8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea
- SHA256 run 2 (SCRATCH/issue-990-baseline-second.json): 8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea (equal; byte-identical).
- Generated entries (path and recorded logical line count):
  - `scripts/dev_tools/agentic_sync.py`: 819
- Covered tracked files at the ref: 2123 (extension allowlist; the generator additionally drops excluded directory segments).
- Independent cross-check: `wc -l` over the covered tracked files lists the same single file above 800. The boundary file `extensions/drm-copilot/test/extension.workflow-commands.test.ts` has 800 newline characters and ends with a terminator, so its logical count is 800 and it is correctly not baselined (800 passes the hard limit).
- Note: the spec's expectation of many legacy files above 800 is not borne out by the tree at the ref; per decision 3 the generator output is the authoritative baseline content.
