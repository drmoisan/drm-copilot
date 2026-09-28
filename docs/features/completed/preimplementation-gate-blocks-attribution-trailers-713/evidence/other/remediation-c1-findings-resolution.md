# Remediation Cycle 1 - Findings Resolution ([P4-T9])

Timestamp: 2026-09-27T05-28

Source: `remediation-inputs.2026-09-27T05-05.md` (F1 = CR-1, F2 = CR-3 of `code-review.2026-09-27T04-30.md`).

## F1 (CR-1)

Status: RESOLVED

Design: R1 (any typographic quote U+2018 to U+201E makes the line unresolvable)

Evidence: `evidence/regression-testing/remediation-c1-fail-before-typographic-quotes.md` (EXIT_CODE 1, ExpectedExitCode 1; the three section-4 rows fail on both runtimes against the helpers at head), `evidence/regression-testing/remediation-c1-pass-after-typographic-quotes.md` (74 passed, 0 failed), and `evidence/qa-gates/remediation-c1-final-pester-full.md` (AttributionTrailer `tests=74 failures=0 errors=0`). The allow row `admits a single-quoted subject containing a dollar sign and a command substitution` is retained unchanged and passes on both runtimes, so straight single quotes still keep `$` and `$(...)` literal.

## F2 (CR-3)

Status: RESOLVED

Change: the `Test-ExemptOrchestrationStagingCommand` row-12 comment now reads:

```text
    # Row 12: `$` or backtick outside single quotes, `<`, `>`, or `#` outside quotes, any
    # typographic quote, and unmodelled backslash escapes make the operand list untrustworthy.
```

Evidence: evidence/qa-gates/remediation-c1-canonical-edit-checks.md (N10 and N11 each count=1 region=Test-ExemptOrchestrationStagingCommand; O10 and O11 count=0)
