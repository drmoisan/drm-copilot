# Fail-Before Exception Dossier (D13)

Timestamp: 2026-09-27T03-34
Case: admits an inline angle-bracket attribution in a double-quoted subject
WhyFailingRunImpossible: issue #663 (PR #700) already rejects < and > only outside quotes, so the unmodified helpers admit a quoted Co-Authored-By: Name <email> text and no failing run exists on this base.

## Alternative Proof

Source: `evidence/regression-testing/fail-before-attribution-trailer.md` (the [P1-T5] run against the unmodified helpers). On that run the following names end a `PASSED:` line for both runtimes, which shows each is a pass-before pin rather than a fail-before case:

- Line 43: `PASSED: preimplementation gate attribution trailers (claude).admits an inline angle-bracket attribution in a double-quoted subject`
- Line 67: `PASSED: preimplementation gate attribution trailers (codex).admits an inline angle-bracket attribution in a double-quoted subject`
- Line 40: `PASSED: preimplementation gate attribution trailers (claude).admits a multi-message form with both trailers in one single-quoted paragraph`
- Line 64: `PASSED: preimplementation gate attribution trailers (codex).admits a multi-message form with both trailers in one single-quoted paragraph`
- Line 41: `PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a single-quoted message`
- Line 65: `PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a single-quoted message`
- Line 42: `PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a double-quoted message`
- Line 66: `PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a double-quoted message`

These tests pin existing behaviour that the change must preserve; the [P2-T4] pass-after run confirms they still pass after the fix.
