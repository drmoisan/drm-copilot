# P4-T7 shared-contract candidate review

Timestamp: 2026-10-19T10-07
Published UTC: 2026-10-19T10:07:56.550507+00:00
Command: `poetry run python SCRATCH/issue-980-p4t7-shared-review.py`
EXIT_CODE: 0

## Output Summary:

SCOPED_SHARED_REPAIR_REQUIRED. This is the frozen shared subset of the single P4-T7 review; task acceptance remains pending.

The [structured review](p4t7-executor-shared-review.2026-10-19T10-07.json) binds both source/test files to checked WIP `1dd386135f0f52c247d7b85ccd766cbc63ebaf4d`, the 09:56 freeze/contract and the bounded 10:05 reproductions. The retained ordered focused loop has 152 passes, 221/221 statements, 108/108 branches and 22 fully covered ranges. No worker or predecessor suite was rerun.

- **P4T7-SR1 (high)**: Nested version regex repetitions overlap on hyphen characters, so the 256-character length guard does not bound matching work. Replace ambiguous backtracking in both literal and constraint classification with bounded deterministic scanning or a demonstrably linear finite grammar. Preserve supported exact versions, prereleases, constraints and redaction. Add deterministic work/regression assertions for adversarial short values and maximum accepted lengths.
- **P4T7-SR2 (medium)**: The prospective check uses character count, then allocates the complete UTF-8 bytes before checking their byte cost. Determine bounded UTF-8 byte cost without first allocating the oversized encoding, including remaining aggregate capacity and surrogate rejection. Preserve valid exact-capacity ASCII/BMP/astral inputs; add a counted allocation-boundary assertion rather than timing checks.
- **P4T7-SR3 (medium)**: Wildcard version components are reported as literal exact declarations. Classify wildcard components as constraints and retain actual exact-version/prerelease controls. Neither category may assert installed or evaluated resolution.
- **P4T7-SR4 (medium)**: Presence-only docstring checks do not satisfy the mandatory contract documentation requirements. Complete concise purpose, typed parameters, return/raises/side-effect contracts and non-obvious class lifecycle/invariants in the owned shared subset. Preserve intent comments and the 500-line limit; obtain coordinator authorization before any cohesive helper split.

No shared behavioral probe or evidence discrepancy remains open. Preserve the immutable original finding/probe artifacts; repairs require coordinator release. Mutable parser and integration scopes have not been reviewed and will join this same task review after their freezes.

Current phase: Phase 4. P4-T7 remains unchecked. Next tasks after it: P4-T8, P4-T9, P5-T1, P5-T2 and P5-T3.
