# Final QA Loop — Stage 4 — Bundled PoshQC Runsettings Parity

Timestamp: 2026-08-26T04-19

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-19`. Same convention as Phases 0 through 3.

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

## Output Summary

- Tests passed: **1**
- Tests failed: 0
- Result line: `1 passed in 0.03s`
- Exit code: 0

### The named test

**`test_poshqc_bundled_module_files_match_repo_root_sources` — passed.**

Confirmed by name from a `-v` re-run of the same file:

```text
tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources PASSED [100%]
```

This test is the gate on the Phase 1 pair of edits P1-T6 and P1-T7, which registered
`scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` in the `CodeCoverage.Path` allow-list of
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and applied the byte-identical edit to
the bundled mirror at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Its passing
result confirms the two copies remain in parity after this cycle's changes.

The stage changed no file on disk. The loop proceeds to stage 5 (`P7-T5`, actionlint) without a
restart. This is loop iteration 1.
