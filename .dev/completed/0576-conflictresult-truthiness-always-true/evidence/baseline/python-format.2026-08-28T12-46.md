# Python Formatting Baseline — [P0-T3]

Timestamp: 2026-08-28T12-46

Command: `poetry run black --check .`

EXIT_CODE: 0

## Verbatim Summary Lines

```
All done!
455 files would be left unchanged.
```

The `--check` flag makes this a read-only invocation, so the baseline observes any pre-existing
formatting drift rather than silently repairing it. No file was rewritten by this command.

Output Summary: `EXIT_CODE: 0`. The verbatim summary line reports that `455 files` `would be left
unchanged`. No line reporting a file that `would be reformatted` is present in the output; the
reformatted count is absent entirely, which is Black's clean-run rendering. The Python tree is
format-clean at baseline.
