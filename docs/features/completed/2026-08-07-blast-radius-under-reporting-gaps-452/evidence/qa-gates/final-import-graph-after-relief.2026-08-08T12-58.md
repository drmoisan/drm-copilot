# Final import-graph verification after the second structural relief ([P11-T12])

Timestamp: 2026-08-08T12-58

Command:
```
grep -n "^from scripts.dev_tools._blast_radius_" scripts/dev_tools/_blast_radius_extraction.py scripts/dev_tools/_blast_radius_glob.py scripts/dev_tools/_blast_radius_thresholds.py scripts/dev_tools/_blast_radius_validation.py scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/compute_blast_radius.py
grep -n "config_over_breadth_fraction\|_blast_radius_thresholds" scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/compute_blast_radius.py
poetry run python -c "import scripts.dev_tools.compute_blast_radius as m; print('__all__ =', m.__all__)"
```

EXIT_CODE: 0

## Output Summary

The second structural relief moved `CONFIG_OVER_BREADTH_FRACTION` and
`config_over_breadth_fraction` into the new leaf module
`scripts/dev_tools/_blast_radius_thresholds.py`. The blast-radius import graph
after the relief is recorded below. Every clause asserted by the completed
[P1-T7] and [P1-T8] and by the already-checked acceptance criterion at
`spec.md` line 662 remains literally true.

### Per-module `_blast_radius_*` imports

| Module | `_blast_radius_*` imports (statement lines) |
| --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | none |
| `scripts/dev_tools/_blast_radius_glob.py` | none |
| `scripts/dev_tools/_blast_radius_thresholds.py` | none |
| `scripts/dev_tools/_blast_radius_validation.py` | `_blast_radius_extraction` (:30), `_blast_radius_glob` (:31), `_blast_radius_thresholds` (:36) |
| `scripts/dev_tools/_blast_radius_conflicts.py` | `_blast_radius_glob` (:31), `_blast_radius_validation` (:32) |
| `scripts/dev_tools/compute_blast_radius.py` | `_blast_radius_conflicts` (:35), `_blast_radius_extraction` (:40), `_blast_radius_glob` (:46), `_blast_radius_validation` (:47) |

The three docstring mentions of sibling module paths in
`_blast_radius_extraction.py:14`, `_blast_radius_glob.py:16-18`, and
`_blast_radius_thresholds.py:7,14,18` are prose references inside module
docstrings, not import statements; the anchored `^from scripts.dev_tools._blast_radius_`
pattern returns no hit for any of the three leaf modules.

### Required clauses, each verified

1. `_blast_radius_extraction`, `_blast_radius_glob`, and `_blast_radius_thresholds`
   each import no `_blast_radius_*` sibling. VERIFIED — zero matching import
   statements in all three files.
2. `_blast_radius_validation` imports `_blast_radius_extraction`,
   `_blast_radius_glob`, and `_blast_radius_thresholds`. VERIFIED — lines 30, 31,
   and 36. The `_blast_radius_thresholds` import names exactly
   `config_over_breadth_fraction`; `CONFIG_OVER_BREADTH_FRACTION` is deliberately
   not imported because its only references travelled inside the relocated
   function body.
3. `_blast_radius_conflicts` still imports `_blast_radius_glob` and
   `_blast_radius_validation`. VERIFIED — lines 31 and 32, unchanged by the
   relief. This is the clause the rejected `config_*` cluster relief would have
   falsified, because relocating `config_string_list`, `config_root_surfaces`,
   and `config_modules` would have dragged `require_mapping` and `require_text`
   out of `_blast_radius_validation`, leaving `_blast_radius_conflicts` importing
   nothing from it.
4. `compute_blast_radius` still imports the same four siblings under the same
   names. VERIFIED — `_blast_radius_conflicts` (:35), `_blast_radius_extraction`
   (:40), `_blast_radius_glob` (:46), `_blast_radius_validation` (:47). The
   facade does not import `_blast_radius_thresholds`, which is why it required
   no edit.
5. `grep -n "config_over_breadth_fraction\|_blast_radius_thresholds" scripts/dev_tools/_blast_radius_conflicts.py scripts/dev_tools/compute_blast_radius.py`
   returns no hit (grep exit status 1, no matching lines), proving neither file
   required an edit for this relief.
6. The `__all__` of `scripts/dev_tools/compute_blast_radius.py` still names
   exactly the nine members pinned at [P1-T7]: `BlastRadius`, `ConflictReason`,
   `ConflictResult`, `RadiusFinding`, `conflicts`, `derive_blast_radius`,
   `extract_plan_paths`, `radius_from_observed_paths`, `validate_blast_radius`.
   VERIFIED by runtime import — length 9, membership identical.

### Acyclicity

The directed edge set is:

```
_blast_radius_extraction  -> {}
_blast_radius_glob        -> {}
_blast_radius_thresholds  -> {}
_blast_radius_validation  -> {extraction, glob, thresholds}
_blast_radius_conflicts   -> {glob, validation}
compute_blast_radius      -> {conflicts, extraction, glob, validation}
```

A topological order exists — `extraction`, `glob`, `thresholds`, `validation`,
`conflicts`, `compute_blast_radius` — in which every module appears after all of
its dependencies. NO CYCLE EXISTS. The relief added one leaf and no edge into
any pre-existing leaf.

### `spec.md` line 662 remains literally true

The criterion's import-graph clause reads: "`extraction` and `glob` import no
sibling; `validation` imports `extraction` and `glob`; `conflicts` imports
`glob` and `validation`". All three sub-clauses hold after the relief:
`extraction` and `glob` still import no sibling (clause 1 above), `validation`
still imports `extraction` and `glob` (clause 2 above, now additionally
importing `thresholds`, which the criterion does not exclude), and `conflicts`
still imports `glob` and `validation` (clause 3 above). The criterion's symbol
clause is likewise untouched: all eight named symbols
(`_glob_to_regex_text`, `matches_glob`, `is_path_subsumed`, `GLOB_WILDCARDS`,
`is_glob_entry`, `concrete_entries`, `_literal_prefix`, `_entries_overlap`)
remain in `scripts/dev_tools/_blast_radius_glob.py`, which this relief did not
touch. No `spec.md` amendment is required by this delta.
