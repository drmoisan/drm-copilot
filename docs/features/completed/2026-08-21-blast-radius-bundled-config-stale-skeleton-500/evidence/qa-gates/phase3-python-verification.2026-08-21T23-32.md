# Phase 3 Python verification (Issue #500)

Timestamp: 2026-08-21T23:32:00Z
Issue: #500
Task: [P3-T7]

Command:

```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py tests/scripts/dev_tools/test_blast_radius_mandate_reads.py tests/scripts/dev_tools/test_blast_radius_invariants.py
```

(working directory: worktree root)

EXIT_CODE: 0

Output Summary:

```
collected 95 items
tests\scripts\dev_tools\test_blast_radius_config.py .................... [ 21%]
............                                                             [ 33%]
tests\scripts\dev_tools\test_blast_radius_mandate_reads.py .........     [ 43%]
tests\scripts\dev_tools\test_blast_radius_invariants.py ................ [ 60%]
......................................                                   [100%]

95 passed in 0.14s
```

- passed: **95**
- failed: **0**

No pre-existing Python assertion regressed on the corrected data. The three suites read both
committed truth tables directly, so they exercise the Phase 3 edits: the six-entry portable
`shared_surfaces` set and the single-module `modules` map in the bundled copy, and the four appended
`mandate_reads` entries in both copies.

`tests/scripts/dev_tools/test_blast_radius_config.py` was not edited by this plan and remains at
499 lines.
