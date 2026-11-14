# Stage J Cycle 1 Baseline Read and Ledger-Region Check (P0-T2)

Timestamp: 2026-11-08T23-46
Command: read of evidence/baseline/stage-j-powershell-test.2026-11-08T22-10.md, stage-j-python-test.2026-11-08T22-10.md, stage-j-powershell-static.2026-11-08T22-11.md and evidence/qa-gates/stage-j-powershell-test.2026-11-08T23-21.md; content search (ripgrep, regex ReviewVerdictEligibility|Invoke-ReviewVerdictStatus|review-verdict|quality-tiers\.yml) over docs/engineering/process-reductions/ (entries and patches/)
EXIT_CODE: 0
Output Summary:
  Python baseline (Phase 0): 16590 passed, 6 skipped, 0 failed; line 97.11% (34334 of 35355); branch 94.37% (12668 of 13424).
  PowerShell baseline (Phase 0): 20818 testcases, 20808 passed, 0 failed, 10 skipped; repo-wide line coverage 95.7% (36608 of 38252).
  PowerShell static baseline: format 0 files needing format; analyzer 0 findings.
  Per-file reference (stage J final gate, because the two files did not exist at Phase 0): .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 100% (194 of 194 lines); .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1 97.87% (46 of 47 lines). Stage J final gate repo-wide: 95.73% (36848 of 38493), 20992 testcases, 0 failed.
  Ledger-region check: 8 hits, all in docs/engineering/process-reductions/patches/, none in a ledger entry file. Every hit is a diff context line (leading space) carrying the prose of a `quality-tiers.yml` sentence inside a hunk for another file: 0001-parallel-only-test-gates.patch (4 hits), 0006-test-suite-baseline-restored.patch (2 hits), 0009-less-evidence.patch (2 hits). No hit for ReviewVerdictEligibility, Invoke-ReviewVerdictStatus or review-verdict. No hunk file header and no revert-block target is any of the three paths (quality-tiers.yml, ReviewVerdictEligibility.psm1, Invoke-ReviewVerdictStatus.ps1). Result: no recorded region edits the three paths; the run continues.
  The origin/main merge (release 1.2.1, orchestrator stop hook change) was a clean plain merge that touched the orchestrate skill and execution-environment brief copies; the chain validity is read in P3-T2 through ProcessReductionChain.Ledger.Tests.ps1.
