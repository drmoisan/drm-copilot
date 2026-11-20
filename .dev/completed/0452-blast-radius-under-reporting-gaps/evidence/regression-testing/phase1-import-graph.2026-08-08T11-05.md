# Phase 1 — Python Import Graph After the Structural Split

Timestamp: 2026-08-08T11-05
Task: [P1-T8]

Command: `poetry run python <scratchpad>/import_graph.py`

The script parses each of the five modules with `ast`, records every `ImportFrom` whose module
resolves to another module in the set, classifies each edge as `runtime` or `TYPE_CHECKING` by
column offset, and runs three-colour depth-first cycle detection over the runtime edges only. A
`TYPE_CHECKING` edge imposes no runtime import ordering and therefore cannot create an import
cycle.

EXIT_CODE: 0

## Raw output

```
_blast_radius_extraction -> (no _blast_radius_* sibling imports)
_blast_radius_glob -> (no _blast_radius_* sibling imports)
_blast_radius_validation -> [('_blast_radius_extraction', ['extract_plan_paths'], 'runtime'), ('_blast_radius_glob', ['concrete_entries', 'is_path_subsumed', 'matches_glob'], 'runtime'), ('compute_blast_radius', ['BlastRadius'], 'TYPE_CHECKING')]
_blast_radius_conflicts -> [('_blast_radius_glob', ['_entries_overlap'], 'runtime'), ('_blast_radius_validation', ['require_mapping', 'require_text'], 'runtime'), ('compute_blast_radius', ['BlastRadius'], 'TYPE_CHECKING')]
compute_blast_radius -> [('_blast_radius_conflicts', ['ConflictReason', 'ConflictResult', 'conflicts'], 'runtime'), ('_blast_radius_extraction', ['extract_contract_identifiers', 'extract_paths_from_lines', 'extract_plan_paths', 'normalize_lines'], 'runtime'), ('_blast_radius_glob', ['concrete_entries'], 'runtime'), ('_blast_radius_validation', ['RadiusFinding', 'require_str_tuple', 'require_text', 'resolve_modules', 'resolve_shared_surfaces', 'validate_blast_radius'], 'runtime')]

runtime edges: {'_blast_radius_extraction': [], '_blast_radius_glob': [], '_blast_radius_validation': ['_blast_radius_extraction', '_blast_radius_glob'], '_blast_radius_conflicts': ['_blast_radius_glob', '_blast_radius_validation'], 'compute_blast_radius': ['_blast_radius_conflicts', '_blast_radius_extraction', '_blast_radius_glob', '_blast_radius_validation']}
cycles found: NONE
```

## Output Summary — per-module `_blast_radius_*` imports

| Module | Runtime `_blast_radius_*` imports | Names imported | Required by spec invariant 6 |
| --- | --- | --- | --- |
| `_blast_radius_extraction` | none | — | `extraction` (no deps) — MATCHES |
| `_blast_radius_glob` | none | — | `glob` (no deps) — MATCHES |
| `_blast_radius_validation` | `_blast_radius_extraction`, `_blast_radius_glob` | `extract_plan_paths`; `concrete_entries`, `is_path_subsumed`, `matches_glob` | `validation` (extraction, glob) — MATCHES |
| `_blast_radius_conflicts` | `_blast_radius_glob`, `_blast_radius_validation` | `_entries_overlap`; `require_mapping`, `require_text` | `conflicts` (glob, validation) — MATCHES |
| `compute_blast_radius` | all four siblings | see raw output | `compute_blast_radius` (all) — MATCHES |

Two `TYPE_CHECKING`-only edges exist and are pre-existing: `_blast_radius_validation` and
`_blast_radius_conflicts` each import `BlastRadius` from `compute_blast_radius` inside an
`if TYPE_CHECKING:` block. These are annotation-only under `from __future__ import annotations`
and create no runtime import, which is why the facade can import both modules without recursion.

Output Summary: The post-split import graph is exactly the order the spec's invariant 6 requires —
`extraction` (no `_blast_radius_*` deps), `glob` (no `_blast_radius_*` deps), `validation`
(imports extraction and glob), `conflicts` (imports glob and validation), `compute_blast_radius`
(imports all four). Three-colour depth-first cycle detection over the runtime edge set reports
`cycles found: NONE`. No cycle exists.
