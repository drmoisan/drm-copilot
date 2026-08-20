# Durable decision — no evidence artifact produced by this plan may carry the new expectation key

Timestamp: 2026-08-20T09-53

Task: [P0-T6] (records plan standing constraint SC7)

Command: not applicable — this artifact records a decision, not a command result
EXIT_CODE: 0

## The prohibition

No evidence artifact produced by this plan may contain a PARSEABLE expectation key line — that is, a
line whose text before the first colon strips to exactly the token `ExpectedExitCode`
(`scripts/dev_tools/pr_context/verification_evidence.py:105-107`), equivalently a line matching the
anchored pattern `^[[:space:]]*ExpectedExitCode[[:space:]]*:`.

Naming the token inside prose or inside backticks is NOT a violation, because the parser never reads
such a line as a key: the text before the first colon of a backticked mention retains the backtick
and therefore never strips to the bare token. This artifact and the parity artifact written at
[P7-T6] are both REQUIRED to name the token in prose, and the two gates that enforce this
prohibition ([P7-T5] and [P9-T5]) are anchored to the key form precisely so they do not falsely
match that prose.

## The reason

This feature's own artifacts under `evidence/other/**` and `evidence/qa-gates/**` are inside the
corpus discovered by `CANONICAL_GLOBS` (`verification_evidence.py:23-27`:
`evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md`). An
artifact of this feature that carried the new key as a parseable line would therefore produce a
rendered-row difference between the pre-change reference and the post-change output, and would
falsify the AC9 zero-difference assertion against this feature's own run. The prohibition keeps the
additive proof self-consistent.

## Consequence for gates whose acceptance condition is a non-zero exit

Several gates in this plan ([P2-T8], [P7-T5], [P7-T10], [P9-T5]) pass when a search returns zero
matches, which exits `1`. Those artifacts record the observed code faithfully in `EXIT_CODE:` and
explain the expectation in prose inside `Output Summary:`. They do NOT declare the expectation with
the new key. This is the very reporting limitation the feature fixes, and this plan accepts it for
its own artifacts so that the additive proof stays falsifiable.

Output Summary: SC7 recorded as a durable decision. The prohibition is on a parseable
expectation-key LINE (text before the first colon stripping to the bare token), not on naming the
token in prose. The reason is that this feature's own `evidence/other/**` and `evidence/qa-gates/**`
artifacts sit inside the `CANONICAL_GLOBS` corpus over which AC9 asserts zero rendered-row
differences. Expected-non-zero gates in this plan record the observed exit code and explain the
expectation in prose instead.
