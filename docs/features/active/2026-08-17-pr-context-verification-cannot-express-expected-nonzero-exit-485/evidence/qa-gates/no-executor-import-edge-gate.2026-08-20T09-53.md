# Gate — no import edge to the atomic-executor QC path (Invariant G, AC18)

Timestamp: 2026-08-20T09-53

Task: [P7-T10]

Command: git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context
EXIT_CODE: 1

## The passing condition for this gate is a non-zero exit

The search produced NO output and returned ZERO matches. A search with zero matches exits `1`, so
exit code `1` is the PASSING condition for this gate, not a failure. The observed code is recorded
faithfully above rather than declared with the new evidence key, because plan constraint SC7 forbids
this artifact — which sits inside the corpus the AC9 zero-difference assertion covers — from carrying
a parseable expectation key line.

## What the absence establishes

Neither `qc_runner_expectations` nor `pytest_expectations` is referenced anywhere under
`scripts/dev_tools/pr_context` or `extensions/drm-copilot/src/lib/pr-context` after this change. The
executor QC path was not imported, copied, or adapted (plan constraint SC4, spec Invariant G).

The fix instead adds one optional integer field to the evidence schema and one pure two-argument
helper per runtime. That is a different mechanism from the executor's set-of-node-id-refs tolerance
model, and it keeps `parse_verification_evidence_markdown` free of the `subprocess` dependency that
`qc_runner_expectations` carries, preserving that function's `Side Effects:` / `None.` contract
(verified separately at [P2-T8]).

Output Summary: Zero matches for `qc_runner_expectations` and `pytest_expectations` under both
pr-context trees; the search exits `1` on zero matches, which is this gate's passing condition.
Invariant G holds: no import edge to the atomic-executor QC path exists after the change.
