# P14-T13 Packaging closure

Timestamp: 2026-10-29T12-49
Task: [P14-T13] Re-run repository and publication contracts under the tiered file-size policy, discharging [P13-T6].
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --check; poetry run python -I SCRATCH/issue-980-p10t2-inspect.py; poetry run python -I SCRATCH/issue-980-p10t3-inspect-wheel.py
EXIT_CODE: 0 (wheel check), 0 (host packages, DEFECTS=0), 0 (wheel, DEFECTS=0)
Output Summary: The committed `_build_manifest.json` is current (`build_manifest_changed: false`, `changed_paths: []`, build `dc7bff83fb56a7867826bae2adcd54e295beacd5b87cbfe31eaac051c764522d`). The P14-T12 VSIX (800 entries, 58 required entries present, 0 Python entries, SHA-256 `efe92788…`) and npm tarball (794 entries, 58 required present, 0 Python entries, SHA-256 `ca38e6fb…`) have zero closure defects, and neither standalone bundle requires `vscode`. The wheel holds 139 runtime modules equal to the source set, 40 resources (v1 7, v2 27, templates 6) with resource manifest `64574adb…`, 181 build-manifest files with 0 mismatches and 0 RECORD digest mismatches.
Run window 2026-10-29T12-46 to 12-49 UTC on the final tree (`git status --porcelain` empty at start and end).
Result: PASS
