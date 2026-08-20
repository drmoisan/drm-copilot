# Baseline — PoshQC bundled-runsettings parity suite, issue #491

Timestamp: 2026-08-19T10-30

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output Summary: `1 passed in 0.04s`. Baseline green: the repo copy
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and the bundled copy
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` are
byte-identical today. The P3-T6 edit must be mirrored by P3-T7 to keep this green.
