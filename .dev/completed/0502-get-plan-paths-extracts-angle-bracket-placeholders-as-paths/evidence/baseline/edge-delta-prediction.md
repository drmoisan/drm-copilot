# Baseline — Pre-Registered Edge-Count Delta — [P0-T15]

Timestamp: 2026-08-23T01-12

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T15]
State captured: PRE-CHANGE baseline, written before any implementation task ran

## Pre-registered value

**53.**

This number is fixed here, before any code change and before the after-measurement is run. It is
copied from the AC-19 pre-registration section of the plan of record, which fixed it during
planning.

## What the number is

It is the exact count of item pairs in the 58-plan corpus that share at least one
classifier-accepted placeholder path token, enumerated by exact token identity. Because
`path_overlap` requires string-level agreement between two radii, a placeholder-induced edge can
exist only between two items that cite the identical token, so the pair set is fully determined by
the token-to-file map.

## Pre-registration table, copied from the plan of record

| Shared token | Items | Pairs | Contribution |
| --- | --- | --- | --- |
| phase0 evidence artifact | 334, 344 (the untimestamped plan), 369, 396, 413, 423, 442, 462, 479 | C(9,2) = 36 | 36 |
| feature spec document | 334, 369, 413, 423, 442, 462, 479, 491 | C(8,2) = 28 | 28 |
| overlap of the two sets above | 334, 369, 413, 423, 442, 462, 479 | C(7,2) = 21 | −21 (double-counted) |
| feature issue document | 479, 491 | 1 | 0 (subset of the spec-document pairs) |
| feature user-story document | 442, 462, 491 | 3 | 0 (subset of the spec-document pairs) |
| eight further shared evidence-artifact tokens between 344 and 442 | 344, 442 | 1 | 0 (subset of the phase0 pairs) |
| PowerShell batch-budget state file | 440, 475, 491, 501 | 6 | 6 |
| skill document template | repo-housekeeping-audit, 367, 372 | 3 | 3 |
| agent document template | repo-housekeeping-audit, 372 | 1 | 0 (subset of the skill-document pairs) |
| parallel manifest and kickoff documents | 441, 443 | 1 | 1 |
| **Total pre-registered pair count** | | | **53** |

The token texts themselves are not reproduced inline here. They are recorded in a fenced block in
the plan of record's token-hygiene contract and in the two marker-probe baselines, which is
sufficient for the after-measurement and avoids injecting a placeholder shape into an inline-code
span.

## One-sided upper bound — Blocking if exceeded

The actual edge-count delta must be **at or below 53**. A delta above 53 means the fix removed an
edge that no shared placeholder token accounts for — that is, a real path was dropped. This is the
pair-level positive control and it fails loudly. A delta above 53 is a Blocking defect and halts
Phase 7.

The bound is one-sided by construction. A delta *below* 53 is not a failure on its own, but every
unit of shortfall must be attributed to a named surviving pair; none may be absorbed as success.

## Exact conservation identity

```text
delta_actual + |S| = |P_measured|
```

where:

- `delta_actual` is the measured before-minus-after edge-count difference,
- `S` is the subset of the pair set that still conflicts after the fix,
- `P_measured` is the executor's own measurement of the pair set.

Every member of `S` must be itemized with its surviving reason kind and detail. The identity must
balance exactly.

## Deviation handling for the measured pair set

If `P_measured` exceeds 53, each additional pair must be itemized and shown to be induced by a
shared placeholder token. That localizes the deviation to the one residual class the plan's
enumeration did not exhaustively cover — two plans citing the same third feature folder's evidence
path with a placeholder timestamp — rather than to the fix.

## Sub-prediction

All 36 pairs among the nine-item phase0 set lose their placeholder-derived `path_overlap` reason.
Any pair among those 36 that remains in the edge set must show a non-placeholder reason.

## Priority-in-time witness

The two recordings below are what make the "written before" claim observable. Without them,
priority in time would be asserted rather than evidenced, and a condition that cannot be checked
is not a gate.

Command: `git rev-parse HEAD`

```text
e74e6b0fef76ba6899058e4452a185324b0f8145
```

Command: `git status --porcelain -- scripts .claude extensions/drm-copilot/resources`

```text
```

EXIT_CODE: 0

The status output is **empty**: no file under any of the three locations this item edits has been
modified at the moment this prediction was fixed.

The pathspec spans all three locations deliberately, not just the two repository-root trees. The
bundled mirrors that [P4-T2] and [P6-T2] change live under the extension resources tree, and a
witness that could not see them would leave part of the implementation outside the very claim it
exists to support:

- `scripts` — the Python leaf module and the extraction module ([P2-T1] through [P2-T4]), and the
  repository Pester runsettings ([P4-T4]).
- `.claude` — the PowerShell leaf module and the extraction module ([P3-T1] through [P3-T3]), and
  the amended rule file ([P6-T1]).
- `extensions/drm-copilot/resources` — the bundled module mirror ([P4-T1]), the bundled extraction
  mirror ([P4-T2]), the bundled pack manifest ([P4-T3]), the bundled runsettings ([P4-T5]), and the
  bundled rule file ([P6-T2]).

## Output Summary

The pre-registered edge-count delta of 53 is fixed at commit
`e74e6b0fef76ba6899058e4452a185324b0f8145` with a clean working tree across all three locations
this item edits. The one-sided upper bound and the exact conservation identity are recorded above.
The prediction was therefore fixed before the implementation began, not after the measurement was
seen.
