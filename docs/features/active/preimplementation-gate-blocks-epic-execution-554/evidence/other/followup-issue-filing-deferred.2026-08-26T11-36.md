# POSTING BLOCKED — Follow-Up Issue Filing Deferred to a Maintainer Action Outside This Branch

Timestamp: 2026-08-26T11-36

PostedAs: not posted

Subject: the epic kickoff contract gap of decision D3, drafted at
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/other/followup-epic-kickoff-contract-gap.2026-08-26T11-36.md`

---

## POSTING BLOCKED

The follow-up issue was **not** filed from this branch. `gh issue create` was **not** run, and the
MCP promotion-lifecycle path was **not** invoked. Both abstentions are deliberate, and the two
reasons are exactly the two the final acceptance criterion of `spec.md` states.

### Reason 1 — `gh issue create` is denied by a PreToolUse hook in this repository

The direct route is unavailable. A `PreToolUse` hook denies `gh issue create` outright, so the
command cannot be executed from an agent session in this repository regardless of intent. Running it
to observe the denial would produce no information not already recorded here, and the executing plan
task (P5-T8) explicitly forbids running it.

### Reason 2 — the sanctioned MCP promotion path writes under `docs/features/potential/`, which is deliberately not in the declared blast radius

The sanctioned alternative to `gh issue create` in this repository is the MCP promotion-lifecycle
path, which is not merely an API call: it **writes repository files** under
`docs/features/potential/`. Those paths are deliberately absent from the `## DECLARED BLAST RADIUS`
section of `spec.md`.

Invoking it from this branch would therefore add one or more `docs/features/potential/` paths to the
branch diff, and the P5-T3 undeclared-path check would report them as UNDECLARED. That check is an
acceptance criterion of this feature. Filing the issue from this branch would make a passing
criterion fail, and widening the radius to accommodate the write is expressly prohibited by the
plan's own execution note: "If any task appears to require writing a file outside the spec's
declared blast radius, stop and report blocked rather than widening the radius."

## Verification that neither route was taken

```powershell
git diff --name-only origin/main...HEAD | Select-String -Pattern '^docs/features/potential/'
git status --porcelain | Select-String -Pattern 'docs/features/potential/'
```

| Check | Result |
| --- | --- |
| `docs/features/potential/` paths in the branch diff against `origin/main...HEAD` | **0** |
| `docs/features/potential/` paths in the working tree (`git status --porcelain`) | **0** |

The second check is recorded alongside the first because a committed-diff check alone would not
observe an uncommitted promotion write sitting in the working tree. Neither is present.

## What satisfies the acceptance criterion

The spec's final acceptance criterion states its own satisfaction condition explicitly:

> A follow-up record for the epic kickoff contract gap described in decision D3 is written under
> `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/other/`, stating
> the gap, the recommended contract amendment, and the reason it is out of scope here. Filing the
> GitHub issue itself is a maintainer action outside this branch ... **This criterion is satisfied
> by the evidence record; the issue number is appended later if and when one exists.**

The evidence record exists at
`evidence/other/followup-epic-kickoff-contract-gap.2026-08-26T11-36.md` and carries all three
required elements: the gap, the recommended contract amendment (two alternatives, with a preference
stated), and the reason it is out of scope for issue #554.

## Maintainer action required after merge

1. File the drafted issue against `drmoisan/drm-copilot` using the title and body in the companion
   draft artifact.
2. Append the resulting issue number to that draft's `## Related` section, and to the
   `## Rollout & Follow-up` section of `spec.md` if the feature folder is still active.

Neither step is performable from this branch, and neither is a precondition for merging issue #554.
