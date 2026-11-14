# Comment-Only Proof - Issue 1019, Remediation Cycle 1

Timestamp: 2026-11-06T19-11
Command: sh SCRATCH/issue-1019-rc1-p2-t2.sh (pwsh -NoProfile -File SCRATCH/issue-1019-comment-proof.ps1 -Left SCRATCH/prior/issue-1019-module-prior.psm1 -Right MODULE; negative control with -Right SCRATCH/unfixed/.claude/lib/docs/DocsPythonTokens.psm1)
EXIT_CODE: 0
Output Summary: PRIOR MODULE and the final MODULE have identical non-comment token sequences (2229 tokens compared by Kind, TokenFlags, and Text; 0 differences; 0 parse errors in both). The negative control against the unfixed module reports 2087 differences and exits 1, so the comparison can fail. The differential and scaling artifacts remain valid for the final hash.

## Hashes

| File | SHA-256 |
| --- | --- |
| `PRIOR MODULE` (`PRIOR HASH`) | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` |
| Final `MODULE` | `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702` |
| Unfixed module (negative control) | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` |

## Token Counts

| Comparison | File | All tokens | Comment tokens | Non-comment tokens | Parse errors |
| --- | --- | --- | --- | --- | --- |
| Proof | `PRIOR MODULE` | 2237 | 8 | 2229 | 0 |
| Proof | Final `MODULE` | 2237 | 8 | 2229 | 0 |
| Control | `PRIOR MODULE` | 2237 | 8 | 2229 | 0 |
| Control | Unfixed module | 1980 | 3 | 1977 | 0 |

## Result

| Comparison | Differences | Result | Exit code |
| --- | --- | --- | --- |
| `PRIOR MODULE` against final `MODULE` | 0 | identical | 0 |
| `PRIOR MODULE` against unfixed module (negative control) | 2087; first at index 56 (`$script:DocsPythonTokenWindowSize` against `$script:DocsPythonKeywordList`) | different | 1 |

## Validity of Earlier Hash-Bound Artifacts

The final `MODULE` differs from `PRIOR MODULE` only in comment tokens, so the PowerShell parser produces the same executable token sequence for both. `evidence/regression-testing/differential.2026-11-06T18-33.md` and `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`, measured at `PRIOR HASH`, therefore remain valid for the final hash `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`. They were not re-run.
