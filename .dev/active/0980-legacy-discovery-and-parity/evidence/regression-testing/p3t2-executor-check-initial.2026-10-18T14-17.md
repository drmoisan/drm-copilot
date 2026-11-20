# P3-T2 final verifier comparator diagnostic

Timestamp: 2026-10-18T14-17
Command: `poetry run python SCRATCH/issue-980-verify-p3t2.py 2026-10-18T14-12`
EXIT_CODE: 1
Output Summary: The verifier reached its suppression comparison after the staged-byte, accepted-path preservation, resource, raw coverage, callable coverage, native integration and ordered-receipt checks. Exact old/new suppression-list equality rejected removal of an inherited suppression in an existing CLI test. No task acceptance or final verifier JSON was produced by this failed invocation.

The failure was observed at 2026-10-18T14-15:26 UTC; this receipt uses its actual later write timestamp.

```text
File "SCRATCH/issue-980-verify-p3t2.py", line 160
    assert old_lines == new_lines, name
AssertionError: tests/scripts/dev_tools/discovery/test_init_cli.py
```

Inspection of the exact diff against acceptance baseline `a74cb240a7698c1454a8e6018ac23862cd91dab0` shows removal of `# noqa: ARG001` from the callback in `test_main_honors_template_root_override`. No directive was added in that diff. The SCRATCH verifier is corrected to allow removal while requiring every retained full suppression line to occur in the baseline with at least the same multiplicity. Added or altered suppression lines remain failures. Production, tests, templates and generated resources are unchanged; no product gate is rerun for this verifier correction.
