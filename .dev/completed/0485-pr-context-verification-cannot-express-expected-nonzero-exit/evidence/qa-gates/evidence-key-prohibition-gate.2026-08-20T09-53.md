# Gate — SC7 held across the whole evidence set

Timestamp: 2026-08-20T09-53

Task: [P9-T5]

Command: git grep --untracked -n -E "^[[:space:]]*ExpectedExitCode[[:space:]]*:" -- "docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence"
EXIT_CODE: 1

## The passing condition for this gate is a non-zero exit

The search returned ZERO matches over this feature's entire `evidence` tree, and a search with zero
matches exits `1`. Exit code `1` is therefore the PASSING condition here, stated in prose because SC7
forbids this artifact from declaring the expectation with the new key.

## Both properties of the command that make the gate discriminating

**`--untracked` is load-bearing.** The evidence artifacts this gate searches are newly created and
UNTRACKED when the gate runs. A search of tracked content alone would not see them, so the gate could
not fail no matter what the artifacts contained. `--untracked` searches tracked and untracked files
both, so the gate is correct whether or not the feature documents have already been committed.

**The pattern is anchored to the PARSEABLE key form**, `^[[:space:]]*ExpectedExitCode[[:space:]]*:`.
That is exactly what the parser reads as a key: the text before the first colon, stripped, equal to
the bare token (`scripts/dev_tools/pr_context/verification_evidence.py:125-128`). A bare-token search
would falsely match the artifacts that are REQUIRED to name the token in prose — [P0-T6]'s
`evidence/other/evidence-authoring-constraint.2026-08-20T09-53.md` and [P7-T6]'s
`evidence/other/additive-corpus-parity.2026-08-20T09-53.md` among them. A companion count confirms
the distinction is real rather than theoretical: **5 evidence files DO name the token** in prose or
inside backticks, and the anchored search still returns zero, so the anchoring is what makes the gate
both satisfiable and meaningful.

## What the absence establishes

No evidence artifact produced by this plan carries a parseable expectation key line. This matters
because this feature's own `evidence/qa-gates/**`, `evidence/regression-testing/**`, and
`evidence/other/**` artifacts are inside the corpus `CANONICAL_GLOBS` discovers, and an artifact
carrying the key would produce a rendered-row difference that would falsify the AC9 zero-difference
assertion against this feature's own run.

Output Summary: Zero matches for the anchored parseable key form across this feature's entire
`evidence` tree; the search exits `1` on zero matches, which is this gate's passing condition. The
`--untracked` flag and the anchored pattern are both recorded above, together with the count of 5
evidence files that name the token in prose without matching the anchored form — evidence that the
gate discriminates rather than passing vacuously.
