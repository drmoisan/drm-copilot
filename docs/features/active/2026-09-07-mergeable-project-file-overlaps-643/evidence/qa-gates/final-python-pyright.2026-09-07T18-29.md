# Final QA — Python type checking (Pyright)

Timestamp: 2026-09-07T18-29

Command: `poetry run pyright`

EXIT_CODE: 0

## Output Summary

Verbatim result line:

```text
0 errors, 0 warnings, 0 informations
```

Zero type errors, which meets the uniform "type errors: 0" gate of
`.claude/rules/quality-tiers.md`. The runner additionally printed an advisory that a newer Pyright
build exists (v1.1.409 -> v1.1.411); it is a version notice, not a diagnostic, and the pinned
version is the one the repository's `pyproject.toml` resolves. The exit code was 0.

## Post-final-change re-verification

The PowerShell loop restarted after this artifact was first written, and its iteration-3 fix changed
tracked source under `.claude/lib/` and `tests/`. To keep the [P8-T13] statement true — that every
recorded pass observed the tree after the last source change — this step was re-run at
2026-09-07T19-30 against the final tree. Observed result: `0 errors, 0 warnings, 0 informations`, exit 0.

The re-run required no source change, so no further restart followed it.
