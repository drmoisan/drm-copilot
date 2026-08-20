# Final QC — Python formatting (Black, write form)

Timestamp: 2026-08-20T09-53

Task: [P8-T1]

Command: poetry run black .
EXIT_CODE: 0

## Loop restart recorded

This artifact records the FINAL uninterrupted pass. An earlier pass reached [P8-T3] and failed:
Pyright reported one `reportPrivateUsage` error for the module-private collector renderer imported by
`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`. That was fixed (the import moved
into a documented helper with a line-scoped suppression), which modified a file, so the loop restarted
at [P8-T1] as the toolchain rule requires. The results below are from the restarted pass.

## Result

```
All done!
428 files left unchanged.
```

- Files reformatted: 0
- Files left unchanged: 428 (three more than the 425 at baseline: the new
  `tests/scripts/dev_tools/pr_context/__init__.py`, the new
  `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`, and the new
  `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`)

No file was modified by this run, so the loop proceeds to linting. This is the mutating write form,
used only in the final QC loop; the Phase 0 baseline used the non-mutating `--check` form so it could
not pollute the diff-based gates.

Output Summary: Black passes with exit code 0 in the write form — 0 files reformatted, 428 files left
unchanged, no file modified. This is the final uninterrupted pass after one restart caused by the
Pyright failure described above.
