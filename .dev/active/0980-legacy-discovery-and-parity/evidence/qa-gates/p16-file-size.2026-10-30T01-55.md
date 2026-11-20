# P16-T8 File size under the tiered policy

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: FileSizePolicy.RepoGate.Tests.ps1 result from the P16-T3 JUnit copy (`p16-powershell-junit.2026-10-30T01-29.xml`: 5 tests, 0 failures) and from the contract Pester run above; git diff --name-only --diff-filter=AM <merge base of origin/main and HEAD> HEAD into SCRATCH/t16-branch-files.txt with git status --porcelain recorded beside it; poetry run python SCRATCH/issue-980-p16t8-lines.py SCRATCH/t16-branch-files.txt (logical lines, as `wc -l` plus one for an unterminated final line)
EXIT_CODE: 0 (RepoGate: 5 tests, 0 failures in P16-T3 and passing again in the contract run), 0 (line scan)
Output Summary: `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes against `config/file-size-baseline.json` (no entries), so no baselined legacy file exists to grow. The branch diff lists 8452 added or modified paths (porcelain status empty), of which 724 are production, test or reusable script files: 0 above 800 logical lines (hard), 0 from 700 to 800 (advisory Warning; none to list, as expected), 1 from 501 to 699 (`extensions/drm-copilot/jest.config.cjs` at 531 logical lines, the user-directed P15-T20 threshold entries recorded in `other/p15-jest-thresholds.2026-10-30T00-17.md`; below the 700 advisory tier), 0 fixtures above 500. Every Phase 15 production and test file is at or below 500 logical lines. Markdown is exempt.
Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
