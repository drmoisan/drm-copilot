# [P11-T10] Final QA — file sizes: BLOCKED, 500-line limit exceeded

Timestamp: 2026-08-08T16-35
Task: [P11-T10]
Status: **BLOCKED — acceptance criteria not met**

Command:

```
wc -l scripts/dev_tools/_blast_radius_extraction.py scripts/dev_tools/_blast_radius_validation.py \
      scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/_blast_radius_glob.py \
      scripts/dev_tools/compute_blast_radius.py .claude/lib/blast-radius/*.psm1 \
      extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/*.psm1
wc -l <every added or modified test file>
```

EXIT_CODE: 0

## Output Summary

### Python production modules

| Path | Lines | <= 500 |
| --- | ---: | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 419 | yes |
| **`scripts/dev_tools/_blast_radius_validation.py`** | **510** | **NO — exceeds by 10** |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 226 | yes |
| `scripts/dev_tools/_blast_radius_glob.py` | 316 | yes |
| `scripts/dev_tools/compute_blast_radius.py` | 333 | yes |

### PowerShell production modules

| Path | Lines | <= 500 |
| --- | ---: | --- |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 379 | yes |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 491 | yes |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 490 | yes |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 429 | yes |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 366 | yes |

### Bundled mirrors

| Path | Lines | <= 500 |
| --- | ---: | --- |
| `extensions/.../BlastRadius.psm1` | 379 | yes |
| `extensions/.../BlastRadiusConfig.psm1` | 491 | yes |
| `extensions/.../BlastRadiusExtraction.psm1` | 490 | yes |
| `extensions/.../BlastRadiusGlob.psm1` | 429 | yes |
| `extensions/.../BlastRadiusValidation.psm1` | 366 | yes |

### Added or modified test files

| Path | Lines | <= 500 |
| --- | ---: | --- |
| `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | 329 | yes |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | 455 | yes |
| `tests/scripts/dev_tools/test_blast_radius_validation.py` | 270 | yes |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 245 | yes |
| `tests/scripts/dev_tools/test_blast_radius_invariants.py` | 268 | yes |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | 465 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | 401 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` | 453 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | 449 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | 342 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | 395 | yes |

Files at or below 500: **30 of 31**. Files exceeding 500: **1**.

## The blocking condition

`scripts/dev_tools/_blast_radius_validation.py` is **510 lines**, exceeding the 500-line limit by
10. This violates:

- Plan Hard Constraint 6 — "No production, test, or reusable script file may exceed 500 lines."
- `.claude/rules/general-code-change.md`, File Size Limit.
- `spec.md` acceptance criterion at line 664.

[P11-T10]'s acceptance requires that the summary list every path with its line count **and that all
are at or below 500**. That condition is false, so the task cannot be checked off.

## How the file crossed the limit

| Point in the plan | Lines | Source |
| --- | ---: | --- |
| Baseline `HEAD` ([P0-T12]) | 497 | `git show HEAD:...` |
| After the Phase 1 structural split ([P1-T10]) | 465 | `phase1-file-sizes.2026-08-08T11-05.md` |
| Now, after Phase 3 | **510** | this run |

`git diff --numstat` reports `49` insertions and `36` deletions against `HEAD`, a net `+13` on the
baseline 497.

Phase 1 removed 32 lines from this module by relocating `GLOB_WILDCARDS`, `is_glob_entry`, and
`concrete_entries` into `scripts/dev_tools/_blast_radius_glob.py` ([P1-T5]), leaving 35 lines of
headroom. Phase 3 then added `config_root_surfaces` ([P3-T3]) at lines 194-229 — 36 lines with its
Google-style docstring and the two blank separator lines — consuming all 35 lines of headroom and
overrunning by one, with the remaining overrun coming from the import-block changes.

The structural relief allocated by Phase 1 was therefore under-provisioned for the Phase 3
addition by 10 lines. No task between [P1-T10] and [P11-T10] re-measures this file, so the overrun
was not observable until this task.

## Why this is not remediated here

Bringing the file under 500 requires relocating one or more functions out of
`scripts/dev_tools/_blast_radius_validation.py` and updating every import site — a
behaviour-preserving structural change to a production module. That is a new independent outcome
not described by any task in the approved plan, and Phase 1, the phase that exists specifically to
allocate structural relief, is complete and checked off. Choosing which symbols move and where
they land is a planning decision with consequences for the import-graph acyclicity assertion at
[P1-T8] and for the `__all__` re-export surface pinned at [P1-T7].

Execution stops at [P11-T10] pending a plan revision. [P11-T10] remains unchecked, and the
`spec.md` line 664 acceptance criterion remains unchecked.

## State of the rest of the change set

Every other measured file is within the limit. Two PowerShell modules are close and should be
noted for any future relief allocation: `BlastRadiusConfig.psm1` at 491 (9 lines of headroom) and
`BlastRadiusExtraction.psm1` at 490 (10 lines of headroom).
