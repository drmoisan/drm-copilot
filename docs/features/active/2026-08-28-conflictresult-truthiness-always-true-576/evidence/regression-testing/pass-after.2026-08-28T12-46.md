# Pass-After Regression Evidence — [P2-T2]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py::test_bool_is_false_for_a_disjoint_pair`

EXIT_CODE: 0

This run was taken after [P2-T1] added `__bool__` to `ConflictResult` in
`scripts/dev_tools/_blast_radius_conflicts.py`. The test node ID and the test body are byte-identical
to the ones that produced `EXIT_CODE: 1` in the fail-before artifact
`fail-before.2026-08-28T12-46.md`; only the production module changed between the two runs.

## Verbatim Result

```
tests\scripts\dev_tools\test_blast_radius_conflicts.py .                 [100%]

============================== 1 passed in 0.06s ==============================
```

Output Summary: `EXIT_CODE: 0` and `1 passed`. The single collected item passed. The same node ID
reported `1 failed` at exit code 1 before the production change, so the pair of artifacts establishes
fail-before and pass-after for the boolean-projection defect. The boolean projection of the relation's
result for two provably disjoint radii now reads `False`, agreeing with the explicit `conflict` field.
