# Baseline — Python formatting (Black, non-mutating check form)

Timestamp: 2026-08-20T09-53

Task: [P0-T7]

Command: poetry run black --check .
EXIT_CODE: 0

## Why the check form is load-bearing

A baseline measures; it does not write. The mutating form `poetry run black .` could reformat files
and pollute the diff-based gates at [P5-T6], [P6-T8], [P7-T8], [P7-T12], and [P8-T11], each of which
counts changed lines against the merge-base. The mutating form is used ONLY in the Phase 8 final QC
loop, where rewriting files is the intended behavior.

## Result

```
All done!
425 files would be left unchanged.
```

- Files that would be reformatted: 0
- Files that would be left unchanged: 425
- Files modified by this task: 0

Output Summary: Black `--check` passes at baseline with exit code 0. 0 files would be reformatted,
425 files would be left unchanged. No file was modified by this task.
