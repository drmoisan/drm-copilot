# Task Check [P3-T2]

Timestamp: 2026-11-19T11-34
Command: grep -c vendored-coverage-exemptions.json (2, one per section); grep -c of 80% and 90% (0); git diff --stat HEAD (2 insertions, 0 deletions)
EXIT_CODE: 0
Output Summary: Changed files: scripts/harness-generation/sources/agents/feature-review.md (one sub-bullet under step 2 of ### Verification Procedure in sections coverage-verification and coverage-verification-2). Result: one sub-bullet per section, no numbered step added, no text removed, no 80% or 90%. Selection rule: the contract checks that read this source (-Surface agents -Check, the feature-review copy tests and the ledger chain test) compare it with outputs that [P3-T4] renders, so they run in the [P3-T4] and [P3-T5] task checks and the [P3-T6] gate.
