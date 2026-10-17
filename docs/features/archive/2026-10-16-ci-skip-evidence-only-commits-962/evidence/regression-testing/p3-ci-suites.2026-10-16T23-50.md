# tests/scripts/ci suites pass (P3-T1, P3-T2)

Timestamp: 2026-10-16T23-50
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1" -NamePatternList "*(AC-1)*,*(AC-2)*,*(AC-3)*,*(AC-4)*,*(AC-5)*,*(AC-6)*,*(AC-7)*,*(AC-8)*,*(AC-9)*,*(AC-10)*,*(AC-11)*,*(AC-12)*,*(AC-13)*,*(AC-14)*,*(AC-15)*,*(AC-16)*,*(AC-17)*"
EXIT_CODE: 0
Output Summary: scripts/ci/Invoke-CiChangeScope.ps1 written (F9 to F12, dot-source guard last). TOTAL Passed=107 Failed=0; every NAMED line Failed=0 with the section 8 totals (AC-1 8, AC-2 3, AC-3 4, AC-4 2, AC-5 5, AC-6 8, AC-7 3, AC-8 5, AC-9 3, AC-10 2, AC-11 7, AC-12 6, AC-13 13, AC-14 8, AC-15 24, AC-16 3, AC-17 3); EXIT_CODE_COMPUTED: 0. Micro-action checks on the entry script: cr-format -Write FORMAT-CLEAN, cr-pssa PSSA-TOTAL: 0. CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/ci/CiChangeScope.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | Result=Passed
SUITE: tests/scripts/ci/CiChangeScope.Tests.ps1 | Passed=54 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Passed=23 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | Passed=30 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-1)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-2)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-3)* | Passed=4 | Failed=0 | Total=4
NAMED: *(AC-4)* | Passed=2 | Failed=0 | Total=2
NAMED: *(AC-5)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-6)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-7)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-8)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-9)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-10)* | Passed=2 | Failed=0 | Total=2
NAMED: *(AC-11)* | Passed=7 | Failed=0 | Total=7
NAMED: *(AC-12)* | Passed=6 | Failed=0 | Total=6
NAMED: *(AC-13)* | Passed=13 | Failed=0 | Total=13
NAMED: *(AC-14)* | Passed=8 | Failed=0 | Total=8
NAMED: *(AC-15)* | Passed=24 | Failed=0 | Total=24
NAMED: *(AC-16)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-17)* | Passed=3 | Failed=0 | Total=3
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | parses the committed allowlist with version 1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | starts every include prefix with docs/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/features/templates/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/engineering/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/discovery/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | lists docs/features/templates/ as an exclude prefix (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | lists docs/features/potential/template.md as an exclude prefix (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .py (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .ps1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .psm1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .psd1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .sh (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .bats (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .ts (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .tsx (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .js (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .mjs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .cjs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .cs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .yml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .yaml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .toml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | configures exactly the D3 include prefixes and extensions (AC-15)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for merge_group (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for push (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for workflow_dispatch (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns nothing for a same-repository pull_request (AC-1)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a different head repository (AC-2)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a blank head repository (AC-2)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig parses a valid config and lower-cases the extensions (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects malformed JSON (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects empty text (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects version 2 (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects missing include_prefixes (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects empty include_prefixes (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiDocsOnlyPathConfig rejects extension without a dot (AC-14)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/a.md (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/completed/x/evidence/b.txt (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/potential/x/c.log (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/research/d.json (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/e.xml (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath accepts docs/features/active/x/evidence/RUN.MD (AC-12)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/templates/README.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/potential/template.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/engineering/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/discovery/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.ps1 (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.py (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/a.yml (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/../../scripts/a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs\features\active\x\a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects /docs/features/active/a.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects Docs/features/active/x.md (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects config/ci-docs-only-paths.json (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiDocsOnlyPath rejects docs/features/active/x/noextension (AC-13)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList splits a NUL-terminated list (AC-8)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList returns an empty valid list for empty text (AC-9)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | ConvertFrom-CiNulPathList marks text without a trailing NUL invalid (AC-8)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision returns EMPTY_DIFF for no paths (AC-9)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision names the first non-allowlisted path of a mixed set (AC-10)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Get-CiChangeScopePathDecision returns nothing when every path is allowlisted (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes the current run (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes runs from a foreign head repository (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates orders unsorted runs by run_number descending (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates excludes runs whose conclusion is not success (AC-5)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID for malformed JSON (AC-3)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID when workflow_runs is missing (AC-3)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns true when CI full run concluded success (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded skipped (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded failure (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when CI full run concluded cancelled (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker returns false when no CI full run job exists (AC-6)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | Test-CiFullRunMarker throws CI_JOB_LIST_INVALID for malformed JSON (AC-4)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision renders code=false with the DOCS_ONLY_SINCE reason and base (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision renders code=true with base none (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | New-CiChangeScopeDecision throws when code is false without a DOCS_ONLY_SINCE reason (AC-11)
ROW: Passed | tests/scripts/ci/CiChangeScope.Tests.ps1 | CiChangeScope.psm1 defines only the eight pure functions and calls no git, gh, file, or network command (AC-17)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true EVENT_NOT_PULL_REQUEST for merge_group without calling either invoker (AC-1)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true EVENT_NOT_PULL_REQUEST for push without calling either invoker (AC-1)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true EVENT_NOT_PULL_REQUEST for workflow_dispatch without calling either invoker (AC-1)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true FORK_PULL_REQUEST for a fork pull request without calling either invoker (AC-2)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true RUN_LIST_FAILED when the run-list call exits non-zero (AC-3)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true RUN_LIST_FAILED when the run list is not valid JSON (AC-3)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true JOB_LIST_FAILED when a jobs call fails (AC-4)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true NO_FULL_GREEN_RUN when the only successful run skipped CI full run (AC-6)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true NO_FULL_GREEN_RUN when the run list is empty (AC-6)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | uses the older qualifying run as the base when the newer run has no full-run marker (AC-6)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | never uses the current run as the base (AC-5)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true BASE_NOT_PRESENT when git cat-file fails (AC-7)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true BASE_NOT_ANCESTOR when merge-base exits 1 (AC-7)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true ANCESTRY_CHECK_FAILED when merge-base exits 128 (AC-7)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | passes --name-only, -z, --no-renames, --no-color, --no-ext-diff, --no-relative, and both SHAs to git diff (AC-8)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true DIFF_FAILED when git diff exits non-zero (AC-8)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true DIFF_FAILED when the diff output does not end in NUL (AC-8)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true EMPTY_DIFF for an empty diff (AC-9)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true NON_ALLOWLISTED_PATH for a mixed diff (AC-10)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=false and logs DOCS_ONLY_SINCE with the base for a docs-only diff (AC-11)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true UNEXPECTED_ERROR and a warning for an invalid config (AC-14)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true UNEXPECTED_ERROR and a warning without throwing when an invoker throws (AC-16)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | writes code=true UNEXPECTED_ERROR when HEAD_SHA is blank on a pull_request event (AC-16)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | declares the GhInvoker, GitInvoker, and OutputWriter seams and a dot-source guard (AC-17)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | reads the six context values through the injected variable reader (AC-17)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | default writer appends Output and Summary text to the GITHUB_OUTPUT and GITHUB_STEP_SUMMARY paths (AC-11)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | default writer prefixes Warning text with ::warning:: on the information stream (AC-16)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | reads the committed allowlist when no ConfigJson is supplied (AC-15)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | uses the default writer when no OutputWriter is supplied (AC-1)
ROW: Passed | tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | default writer sends Output text to the information stream when GITHUB_OUTPUT is unset (AC-11)
TOTAL: Passed=107 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
