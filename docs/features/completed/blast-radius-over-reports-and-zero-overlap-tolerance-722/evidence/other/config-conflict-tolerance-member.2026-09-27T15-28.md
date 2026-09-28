# conflict_tolerance Member in Both Config Copies (P3-T2, P3-T3)

Timestamp: 2026-09-27T15-28
Command: poetry run python SCRATCH/config-member-check.py
EXIT_CODE: 0
Output Summary: Both config copies parse as JSON, carry conflict_tolerance immediately after mergeable_paths (top-level key order matches the Part A order of block B20), and the member equals block B2 in each copy. The two members are equal to each other, and the strict reader accepts each one (tolerance_percent 100).

## Printed output

```text
CONFIG self-hosted parses=True key_order=['version', 'shared_surfaces', 'shared_surface_globs', 'mandate_reads', 'mergeable_paths', 'conflict_tolerance', 'modules', 'over_breadth_fraction'] member_after_mergeable=True equals_B2=True reader_tolerance=100
CONFIG bundled parses=True key_order=['version', 'shared_surfaces', 'shared_surface_globs', 'mandate_reads', 'mergeable_paths', 'conflict_tolerance', 'modules', 'over_breadth_fraction'] member_after_mergeable=True equals_B2=True reader_tolerance=100
CONFIG copies_equal=True
```

The two edits are textually identical (the same eleven inserted lines at the same position in each
file). self-hosted is config/blast-radius.json; bundled is
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
