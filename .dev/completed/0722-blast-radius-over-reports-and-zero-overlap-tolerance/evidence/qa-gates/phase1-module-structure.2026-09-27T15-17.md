# Phase 1 Module Structure Checks (P1-T7, P1-T8, P1-T10, P1-T11)

Timestamp: 2026-09-27T15-17
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 scripts/dev_tools/_blast_radius_scheduling.py scripts/dev_tools/compute_blast_radius.py tests/scripts/dev_tools/test_blast_radius_scheduling.py tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py; PYTHONPATH=. poetry run python SCRATCH/sched-import-check.py
EXIT_CODE: 0
Output Summary: All four Phase 1 Python files are at most 500 lines after black (495, 451, 428, 197). Importing the scheduling module does not load compute_blast_radius; its runtime imports are the conflicts, glob, guards, and mergeable modules, and the only module importing it is compute_blast_radius.py (cycle list empty). The facade's conflicts name is still the relation object of the conflicts module, and every public scheduling name is re-exported and listed in the facade's public name list.

## Line counts (A4)

```text
scripts/dev_tools/_blast_radius_scheduling.py LineCount=495
scripts/dev_tools/compute_blast_radius.py LineCount=451
tests/scripts/dev_tools/test_blast_radius_scheduling.py LineCount=428
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py LineCount=197
```

## Import and re-export check (SCRATCH/sched-import-check.py)

```text
RUNTIME facade_loaded_by_scheduling_import=False
RUNTIME-IMPORTS ['__future__', 'dataclasses', 'types', 'typing', 'scripts.dev_tools._blast_radius_conflicts', 'scripts.dev_tools._blast_radius_glob', 'scripts.dev_tools._blast_radius_guards', 'scripts.dev_tools._blast_radius_mergeable']
IMPORTERS-OF-SCHEDULING ['compute_blast_radius.py']
CYCLE []
FACADE conflicts_is_relation=True
FACADE reexport_missing=[] all_listed=True
```

The scheduling module names BlastRadius and ConflictResult for annotations only, inside its
TYPE_CHECKING block (the pattern the conflicts module already uses); that block does not execute at
runtime, as the first line above shows.

## Facade diff against BASE_SHA

git diff beae3f021674e64fa6662097fe48a332d8da62b8 -- scripts/dev_tools/compute_blast_radius.py shows
two hunks only: one added import block from the scheduling module and fourteen added entries in the
public name list. The conflicts import from the conflicts module and the conflicts entry of the
public name list are unchanged.

## Implementation notes (block B12)

- The pair decision states the tolerance-0 case explicitly (edge when tolerance_percent is 0 and the
  relation reports a conflict), in addition to the integer inequality, so the edge flag equals the
  conflict verdict at tolerance 0 even for an injected relation (B12: "When tolerance_percent is 0,
  the edge flag equals the conflict verdict"). For the unchanged relation this is equivalent to the
  inequality, because every non-hard conflict has cost of at least 1.
- "The concrete overlapping path" of the append-only rule is read as: any wildcard-free entry of the
  overlapping pair that matches append_only_paths under the mergeable matcher. A listed directory
  against a changelog inside it therefore costs append_only.
- The reader requires exactly the five members of B2 and exactly the four weight names and four band
  names; an unknown or missing name is rejected with an error naming conflict_tolerance.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
