Timestamp: 2026-08-25T17-36
Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Expected failure observed: 1 failed in 0.08s. CI job `97971527109` failed for this same source-to-mirror parity condition. The test only reads checked-in files; no files were modified.

## Failure Diagnosis

`test_poshqc_bundled_module_files_match_repo_root_sources` asserted that the source and bundled `pester.runsettings.psd1` files have identical text. The extension mirror lacks the Issue #552 coverage-path entry:

```text
# Issue #552 validates start-time routing attestation coverage for this hook.
'.codex/hooks/record-subagent-routing-attestation.ps1'
```

The differing pair is:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

## Test Output

```text
1 failed: tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources
AssertionError at tests/scripts/dev_tools/test_poshqc_bundled_parity.py:81
Skipping 15069 identical leading characters; the source contains the Issue #552 coverage-path entry that the mirror lacks.
```
