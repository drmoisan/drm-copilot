# P14-T13 File size under the tiered policy

Timestamp: 2026-10-29T12-49
Task: [P14-T13] Re-run repository and publication contracts under the tiered file-size policy, discharging [P13-T6].
Command: FileSizePolicy.RepoGate.Tests.ps1 result from the P14-T8 JUnit file (`p14-powershell-junit.2026-10-29T12-14.xml`) and from the contract Pester run above; git diff --name-only --diff-filter=AM <merge base of origin/main and HEAD> HEAD into SCRATCH/t13-branch-files.txt with git status --porcelain recorded beside it; poetry run python SCRATCH/issue-980-p14t13-lines.py SCRATCH/t13-branch-files.txt (logical lines, as `wc -l` plus one for an unterminated final line)
EXIT_CODE: 0 (RepoGate: 5 tests, 0 failures in P14-T8 and passing again in the contract run), 0 (line scan)
Output Summary: `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes against `config/file-size-baseline.json`, which has no entries after the P14-T8 correction, so no baselined legacy file exists to grow. The branch diff lists 8318 added or modified paths (porcelain status empty), of which 699 are production, test or reusable script files: 0 above 800 logical lines (hard), 0 from 700 to 800 (advisory Warning; none to list), 0 from 501 to 699, 0 fixtures above 500. The four Phase 14 code files are at or below 500: `catalog.py` 399, `test_catalog.py` 353, `test_schema_validation.py` 421, `test_execution_environment_brief_contracts.py` 477. Markdown is exempt.
Run window 2026-10-29T12-46 to 12-49 UTC on the final tree (`git status --porcelain` empty at start and end).
Result: PASS
