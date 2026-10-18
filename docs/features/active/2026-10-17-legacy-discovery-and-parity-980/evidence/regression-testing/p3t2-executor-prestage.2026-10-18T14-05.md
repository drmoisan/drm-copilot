# P3-T2 independent raw coverage and scope verification

Timestamp: 2026-10-18T14-05

Command: `poetry run python SCRATCH/issue-980-verify-p3t2.py 2026-10-18T14-03 --prestage`

EXIT_CODE: 0

## Output Summary

The independent checker confirms the exact 18 authored and seven generated task paths against acceptance baseline `a74cb240a7698c1454a8e6018ac23862cd91dab0`, including both WIP commits. Current SHA-256 and Git object values match the specialist's measured audit. The other 215 accepted paths and all 24 frozen v1/export paths remain unchanged. The full 39-resource manifest matches canonical bytes, lengths and hashes. Maximum physical file length is 481.

Raw coverage independently recomputes to 451/456 executable lines and 141/146 branch arcs. All 42 callable/class AST ranges meet the required 90%; the minimum is 94.444444%. The four module line results are 134/136, 137/140, 178/178 and 2/2. The changed thin adapter retains its accepted 100% line coverage. Required docstrings, Python 3.10 parsing and absence of checkout-script imports in the new runtime modules pass.

The completed 92-case pass-14 run took 738.59 seconds under coverage. Its composed workflow cases include partial/repeat recovery at 228.03 seconds, combined first publication at 175.66 seconds, and existing-graph preservation at 95.20 seconds. These are measured end-to-end memory-I/O workflow checks, not a claim of fast isolated-unit execution. Native per-operation latency remains pending the already-required integration smoke.

This is a prestaging verification only. It does not claim final staged-byte consistency, reverse-order success, contract/native integration completion, task acceptance, or AC checkoff. The retained 14 semantic cases are separately bound through the exact executable AST comparison in [the comment-binding receipt](p3t2-executor-comment-binding.2026-10-18T13-48.md). No expensive workflow probe was repeated.

[Machine-readable proof](p3t2-executor-prestage.2026-10-18T14-05.json) records every path, hash, raw coverage summary and callable range. Git reported normal CRLF-to-LF index conversion warnings for inherited test files; raw working-file hashes and Git object identities are recorded separately.
