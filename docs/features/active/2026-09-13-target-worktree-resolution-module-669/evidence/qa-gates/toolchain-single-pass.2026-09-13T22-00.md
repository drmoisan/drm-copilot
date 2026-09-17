# Toolchain Single-Pass Confirmation

Timestamp: 2026-09-17T08:43:30-04:00
Command: comparison of the Timestamp fields of evidence/qa-gates/final-poshqc-format.2026-09-13T22-00.md, evidence/qa-gates/final-poshqc-analyze.2026-09-13T22-00.md, and evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md, and of the format stage's listings and hash sets (no new command executed)
EXIT_CODE: 0
Output Summary: The governing pass (loop iteration 2) ran format (08:34:23) -> analyze (08:35:23) -> test (08:40:15); the timestamps are non-decreasing in that order. No stage reported a failure beyond the [P0-T6] baseline failure set: format ok=true; analyze ok=true with no findings; the MCP test stage reported exactly the two baseline failures. The format stage's after-listing is identical to its before-listing (no Pre-existing drift paths to restore), and all ten Scope Boundary hashes are unchanged across it. No Scope-Boundary drift rewrite occurred, so no parity re-verification was needed.

| Stage | Artifact | Timestamp | Result |
| --- | --- | --- | --- |
| format | final-poshqc-format.2026-09-13T22-00.md | 2026-09-17T08:34:23-04:00 | ok=true; listings identical; 10/10 hashes unchanged |
| analyze | final-poshqc-analyze.2026-09-13T22-00.md | 2026-09-17T08:35:23-04:00 | ok=true; "PSScriptAnalyzer passed: no findings under ..."; no file modified |
| test | final-poshqc-test-mcp.2026-09-13T22-00.md | 2026-09-17T08:40:15-04:00 | ok=false with failures=2, both in the [P0-T6] Baseline failure set; no new failure |

Order check: 08:34:23 <= 08:35:23 <= 08:40:15 — non-decreasing in the order format, analyze, test.

Loop history: iteration 1 (format 08:31:24 clean; analyze 08:32:24 failed with 26 findings on new files)
was repaired and the loop restarted at [P4-T2]. Iteration 2 is the single clean pass recorded above; no
stage in iteration 2 failed beyond the baseline or modified a file.

Note on the test stage: the MCP result is `ok: false` in both the baseline and the final run because of the
same two pre-existing failures outside this feature's scope; the plan gate for this stage is "no failure
beyond the baseline failure set", which holds.
