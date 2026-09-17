# Phase 1 PoshQC Run-Settings Parity — Issue #670

Timestamp: 2026-09-17T08-04
Task: [P1-T5]
Command: poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 0

## Edit applied

`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` was byte-identical to the HEAD copy of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` before the edit (`cmp` exit 0). The edited repository copy (new `CodeCoverage.Path` entry `'.claude/hooks/enforce-epic-merge-gate-authorization.ps1'` plus its issue #670 comment, placed after `'.claude/hooks/enforce-epic-merge-gate.ps1'`) was then copied over the bundled copy, so the two files carry the identical edit.

Output Summary:
- `1 passed in 0.04s`
- PASSED `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`
