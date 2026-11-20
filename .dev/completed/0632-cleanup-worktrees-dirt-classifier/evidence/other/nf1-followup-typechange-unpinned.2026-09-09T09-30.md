# NF-1 — the `T` member of the content-bearing class is unpinned (follow-up, non-blocking)

Timestamp: 2026-09-09T09-30
Raised by: `feature-review`, cycle 3 exit reaudit
Disposition: NON-BLOCKING. Recorded here because the remediation cap is exhausted and this cycle
merges, so the finding needs a durable home rather than living only in a review artifact.

## The finding

`sed 's/== \[MARCTU\]/== [MARCU]/'` applied to `scripts/bash/cleanup_worktrees_dirt_lib.sh` leaves
the full bats suite green at `1..15` on the scratch copy. No checked-in scenario carries a `T`
(typechange) in either porcelain column, so the `T` member of the two-content-bearing-columns class
is present in the source but not held by any assertion.

## Why it is not blocking

The shipped code is correct. `T` is in the class, so a typechange entry with a second
content-bearing column already fails closed and resolves `UNIQUE`. There is no data-loss path in
the merged tree — the exposure is future-regression only: a later edit could drop `T` from the
class and no test would object.

The reviewer weighed this explicitly against the instruction not to inflate a finding to stop a
merge, and against the opposite instruction not to suppress one to permit it. Its judgment, which
the orchestrator accepts: the practical reachability of a typechange entry on this platform is low,
the gate's own comment already disclaims completeness over within-class variants, and the correct
response is a follow-up rather than a fourth cycle that the cap does not allow.

The three other members verified as load-bearing by mutation probe are `M`, `U`, and the exclusion
of the space column. `A`, `R`, `C` and `T` are held by the class literal alone; `T` is called out
here because it is the only one with no reachable entry in any checked-in scenario.

## Recommended follow-up

Add a `TT` or `MT` entry to `tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta/`
so that narrowing the class flips a test. The fixture already exists and already carries the `MM`,
`M `, and `UU` entries, so this is one status line plus the matching probe fixtures.

Verification that the follow-up worked is the same probe the reviewer ran: narrow the class to
`[MARCU]` on a scratch copy and confirm at least one test reports `not ok`.

## A related accuracy note, not a finding

The `UU` test comment claims that "two index-side blobs that are in no commit sit behind it". In an
ordinary merge conflict, stages 2 and 3 come from `HEAD` and `MERGE_HEAD`, so they are generally
reachable from a commit. The comment's justification is therefore stronger than the general case
supports. The behaviour it describes is unaffected and errs toward `UNIQUE`, which is the safe
direction, so this is a comment-accuracy item rather than a defect.
