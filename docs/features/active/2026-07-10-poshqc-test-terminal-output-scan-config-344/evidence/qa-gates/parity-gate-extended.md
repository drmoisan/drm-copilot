# QA Gate — Extended PoshQC Bundled Parity

- Timestamp: 2026-07-10T18-05
- Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
- EXIT_CODE: 0

## Output Summary

`test_poshqc_bundled_module_files_match_repo_root_sources` passed. `POSHQC_PARITY_PATHS` now locks eight workspace/bundled file pairs to exact byte parity:

1. `PoshQC.psm1`
2. `PoshQC.FileDiscovery.psm1`
3. `PoshQC.Analyzer.psm1`
4. `PoshQC.Testing.psm1`
5. `PoshQC.ScanConfig.psm1` (new, Capability 3)
6. `PoshQC.psd1` (newly locked; bundled `RequiredModules` block removed by resync)
7. `settings/pester.runsettings.psd1` (newly locked; bundled undocumented `CodeCoverage.ExcludedPath` block removed, workspace coverage `Path` list adopted)
8. `settings/pssa.settings.psd1` (newly locked; already byte-identical at baseline per `pssa-settings-diff.md`)

The test iterates over all eight pairs and asserts byte parity; drift in any one bundled file fails the gate.

## FR2.5 Residual Limitation

The *installed* extension converges on the reconciled bundled resources only at the next packaged release. In-repo drift is closed immediately by this extended parity gate. This limitation must be carried into the PR description.
