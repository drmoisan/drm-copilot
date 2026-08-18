# P1-T3 — Executed Before-State Pin (regression evidence)

Timestamp: 2026-08-18T09-07
Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_verification_integrity.py`
EXIT_CODE: 0
Output Summary: 3 passed in 0.27s.

The recorded before-state of the `verification-integrity` run is now pinned against a
COMMITTED fixture (`tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`)
rather than against the gitignored working-tree checkpoint, so the demonstration is
reproducible from a fresh checkout and in CI.

Pinned facts:

- Recorded radius cardinalities (paths, modules, shared_surfaces, contracts):
  485 = (184, 6, 1, 40); 486 = (125, 3, 2, 45); 487 = (140, 4, 1, 10).
- Conflict edges under the embedded `pre_fix_config`, evaluated by the frozen relation
  `scripts/dev_tools/_blast_radius_conflicts.py::conflicts`, are exactly the complete
  K3 triangle: `[(485, 486), (485, 487), (486, 487)]`.
- `compute_cohorts([485, 486, 487], edges)` yields `[[485], [486], [487]]` — three
  single-item cohorts, i.e. fully serial execution.

These assertions hold both before and after the fix: the comparison relation is a frozen
surface for issue #489 and the pre-fix config is embedded in the fixture, so neither input
moves when `config/blast-radius.json` is amended in Phase 2.
