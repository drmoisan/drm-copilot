# Post-fix conflict-graph measurement (Issue #500)

Timestamp: 2026-08-22T00:20:00Z
Issue: #500
Task: [P7-T6]

Command:

```
poetry run python <scratchpad script: derive_blast_radius over every folder under
docs/features/active/ carrying a plan*.md, against config/blast-radius.json, then conflicts() over
all C(n,2) pairs, then a greedy lowest-index cohort colouring>
```

(working directory: worktree root. The script is a throwaway created and deleted within this
session, permitted by the temporary-script exception in `.claude/rules/general-code-change.md`. It
reads committed files and writes nothing.)

EXIT_CODE: 0

Output Summary:

## Post-fix measurement, against the corrected `config/blast-radius.json`

| Metric | Value |
| --- | --- |
| Items | **56** |
| Pairs | 1540 |
| Conflict edges | 1182 |
| **Conflict-graph density** | **76.8%** |
| Cohorts | 31 |
| **Maximum parallel width** | **5** |

Edge reasons, counted per edge (an edge may carry several):
`path_overlap` 1154, `shared_surface_overlap` 305, `module_overlap` 239, `contract_dependency` 141.

Module hit counts across the 56 radii: `config` 15, `poshqc` 15, `schemas` 7, `mcp-server` 6,
`codex-runtime` 4, `powershell-dev-tools` 3, `benchmarks` 2. No module fires for a majority of
items, which is the module-map granularity criterion holding.

## Comparison against the `issue.md:44` baseline

`issue.md:44` records 83.3% density (100 of 120 pairs) and a maximum parallel width of 2 over
**16 items**.

| Measurement | Items | Density | Max parallel width |
| --- | --- | --- | --- |
| `issue.md:44` baseline | 16 | 83.3% | 2 |
| This post-fix measurement | 56 | 76.8% | 5 |

The two rows are **not directly comparable**, and the artifact records that explicitly rather than
presenting the difference as the effect of the fix. The item counts differ by more than a factor of
three: `docs/features/active/` now holds 56 folders carrying a `plan*.md`, against the 16 the issue
measured. Density is a ratio over C(n,2) pairs, so it is sensitive to which items are in the set,
and maximum parallel width grows with the number of mutually non-conflicting items available.

## Controlled comparison over an identical item set

To isolate the effect of the change from the effect of the changed item set, the same 56 items were
re-derived against the **pre-change** `config/blast-radius.json` recovered with
`git show HEAD:config/blast-radius.json`. Everything else — the item set, the derivation, the
relation, and the colouring — is identical.

| Configuration | Items | Edges | Density | Cohorts | Max parallel width |
| --- | --- | --- | --- | --- | --- |
| Pre-change (`HEAD`) | 56 | 1199 | 77.9% | 33 | 5 |
| Post-change (working tree) | 56 | 1182 | 76.8% | 31 | 5 |
| Delta | 0 | **-17** | **-1.1 points** | **-2** | 0 |

Seventeen conflict edges are removed and the cohort count falls from 33 to 31, so a run over this
item set finishes in two fewer barriers. Maximum parallel width is unchanged at 5 for this set.

The module hit counts are identical across both configurations, which is expected: the four appended
`mandate_reads` entries change which citations are harvested rather than which modules exist, and the
`claude-runtime` removal from the **self-hosted** copy had already landed under issue #489. The
17 removed edges are therefore attributable to the `mandate_reads` additions of [P3-T5].

The larger half of this fix is not visible in a self-hosted measurement at all. Causes A and B live
in the published document and in `PAYLOAD_MODULES`, and their effect appears only in a destination
workspace that received the push-down. The PowerShell pass-after artifacts
`evidence/qa-gates/powershell-fail-closed-pass-after.2026-08-22T00-10.md` and
`evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md` measure that half directly
against the bundled table.

## Gating

No numeric improvement target is asserted and none is gated. Per [P7-T6] the measurement is
recorded, not gated.
