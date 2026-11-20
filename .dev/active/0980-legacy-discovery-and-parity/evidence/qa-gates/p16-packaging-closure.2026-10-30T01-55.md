# P16-T8 Packaging closure

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --check; poetry run python -I SCRATCH/issue-980-p10t2-inspect.py; poetry run python -I SCRATCH/issue-980-p10t3-inspect-wheel.py
EXIT_CODE: 0 (wheel check), 0 (host packages, DEFECTS=0), 0 (wheel, DEFECTS=0)
Output Summary: The committed `_build_manifest.json` is current (`build_manifest_changed: false`, build `3396ea3ba30a68d644ca8d2e020a21f3d3daaf09eddd162d875445291be716fc`). The P16-T6 VSIX (809 entries, 58 required entries present, 0 Python entries, SHA-256 `c9eda59d…`) and npm tarball 1.1.23 (803 entries, 58 required present, 0 Python entries, SHA-256 `6c04864e…`) have zero closure defects, and neither standalone bundle requires `vscode`. The wheel holds 140 runtime modules equal to the source set, 42 resources (v1 7, v2 29, templates 6) with resource manifest `887c4b62…`, 184 build-manifest files with 0 mismatches and 0 RECORD digest mismatches.
Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
