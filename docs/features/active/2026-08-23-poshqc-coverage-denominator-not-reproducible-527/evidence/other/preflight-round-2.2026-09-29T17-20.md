# Preflight Round 2 — Plan for Issue #527

Timestamp: 2026-09-29T17-20
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md (version 1.1)
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: FURTHER ROUNDS LIKELY (one confirming round expected; deltas are prose-only)

## Round-1 defects

All 12 round-1 defects resolved as specified.

## Validator warnings

Plan validator exits 0 with three G7 warnings (P0-T10 twice, P5-T11). All three judged false positives: `ruff check` without `--fix` writes nothing; P5-T11 records porcelain status and HS hashes over all eleven CHANGED_PS paths before and after the call.

## Defects and deltas

A. P2-T2 R4/R5/R6 seam set. D13 lists the full seam set only for R1-R3; R6 as written would start a real nested `Invoke-Pester` and call the default `Convert-PoshQCCoverageToRelative` on a missing file. Delta: append to D13: "Tests R4, R5, and R6 also inject `-EnsureModule { }`, the `-LoadSettings` and `-BuildConfiguration` seams of R1 unless the test text names others, an `-InvokePester` seam that records `$Config` and returns `$null`, a `-CopyCoverage` seam that records its call and writes nothing, and a recording `-Logger`; none of them invokes the real `Invoke-Pester` or `Convert-PoshQCCoverageToRelative`."

B. P6-T41 contradictory required statement in the already-committed branch. Delta: replace "the artifact states that the commit itself is made by the orchestration commit step after this plan;" with "the artifact names which of the two cases applies and, in the untracked case, states that the commit itself is made by the orchestration commit step after this plan;".
