# Named-Form Decisions - Issue 1034 Remediation Cycle 4 (P1-T4)

Timestamp: 2026-11-07T14-25
Command: sh SCRATCH/issue-1034-c4-driver.sh p1t4 (PowerShell 7 runs SCRATCH/issue-1034-c4-driver.ps1, which dot-sources the branch HOOK, replaces Get-DocsCompleteGateRepositoryRoot, Get-DocsCompleteGateFileText (enabled profile, no receipt) and Invoke-DocsOnlyGhExe (a recorder that counts calls and returns exit code 1), then drives Invoke-DocsCompleteGateDecision once per row; the script exits 1 when any row fails its expectation)
EXIT_CODE: 0
Output Summary: PASS. R1 to R9 each allow with 0 recorded lookups; the three quoted-mention controls allow with 0 lookups; the two plain controls each record 1 lookup (and deny PR_UNRESOLVED because the recorder returns exit code 1). R3 writes the N19 error text "Cannot bind argument to parameter 'Word' because it is null." twice on the error stream and still allows. No form was removed from the limit texts. Nothing under tests/ uses the driver.

`<NL>` is a line feed, passed through PowerShell double-quoted escapes.

| ID | Command | Decision | Lookups | Error stream | Expectation met |
|---|---|---|---|---|---|
| R1 | `# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status` | allow | 0 | none | yes |
| R2 | `# a<<b<NL>gh pr merge 12<NL>b` | allow | 0 | none | yes |
| R3 | `x=$((1<<4))<NL>gh pr merge 12<NL>4` | allow | 0 | `Cannot bind argument to parameter 'Word' because it is null.` (twice; N19) | yes |
| R4 | `echo "$(git log -1 --format="%h"; gh pr merge 12)"` | allow | 0 | none | yes |
| R5 | `$'g\x68' pr merge 12` | allow | 0 | none | yes |
| R6 | `printf 'pr\nmerge\n12\n' \| xargs gh` | allow | 0 | none | yes |
| R7 | `alias m='gh pr merge 12'<NL>m` | allow | 0 | none | yes |
| R8 | `echo Z2ggcHIgbWVyZ2UgMTI= \| base64 -d \| sh` | allow | 0 | none | yes |
| R9 | `gh api repos/o/r/merges -f base=main -f head=x` | allow | 0 | none | yes |
| C1 | `git commit -m 'gh pr merge 12'` | allow | 0 | none | yes |
| C2 | `echo "gh pr merge 12"` | allow | 0 | none | yes |
| C3 | `git log --grep='gh pr merge'` | allow | 0 | none | yes |
| C4 | `gh pr merge 12 # note` | deny `PR_UNRESOLVED` | 1 | none | yes |
| C5 | `gh pr merge 34 # it's` | deny `PR_UNRESOLVED` | 1 | none | yes |

Row results are also written to SCRATCH/issue-1034-c4-driver-p1t4.json. A preflight run of the same driver against the pre-edit HOOK gave identical decisions and lookup counts, which is consistent with a cycle that changes comment-based help only.
