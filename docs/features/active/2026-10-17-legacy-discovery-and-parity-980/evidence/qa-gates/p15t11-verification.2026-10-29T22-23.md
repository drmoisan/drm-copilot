# P15-T11 verification — documented Copilot hook configuration shape

Timestamp: 2026-10-29T22-23
Command: sh SCRATCH/issue-980-p15-pssa.sh <3 files>; npx prettier --check .github/hooks/discovery.json tests/fixtures/codex_native_converter/native_surfaces/.github/hooks/discovery.json; poetry run pytest -q --no-cov tests/scripts/dev_tools/test_discovery_publication_contracts.py tests/scripts/dev_tools/codex_native_converter/test_{classifier,mapping,inventory,end_to_end,rewrites}.py; sh SCRATCH/issue-980-p15-mirror.sh; sh SCRATCH/issue-980-pester.sh <6 suites>; cmp .github/hooks/discovery.json extensions/drm-copilot/resources/customizations/.github/hooks/discovery.json
EXIT_CODE: 0
Output Summary:
- Static stages: 3 PowerShell files, 0 reformatted, 0 PSScriptAnalyzer findings. Prettier: both JSON files use the project style.
- Pester (DiscoveryCapability, DiscoveryStartRecord.Seams, the three host discovery-capability suites, Test-DiscoveryHostCapability.Entry): 82 total, 82 passed, 0 failed. The new library case reads a hook command from `powershell`, then `bash`, then the legacy `command` key, skips a blank `powershell` value, and yields no entry when no handler key is present; the Copilot suite asserts `"version": 1`, no `windows` key, exactly the keys `bash`, `powershell`, `timeout`, `type` on each of the four entries, and that `Get-DiscoveryHostRegistration` resolves all four handlers from the file.
- Python: 73 passed, 1 failed. `test_roles_carry_stop_and_tool_controls_on_every_host` (the test this task names) passes; the five converter modules pass unchanged over the reshaped fixture. The failing test is `test_native_hooks_and_helpers_are_published_and_listed`, whose `SHARED_HELPERS` list does not match the tracked contents of extensions/drm-copilot/resources/lib/discovery-validation/: the directory additionally holds the modules P15-T4, P15-T5 and P15-T8 added (DiscoveryToolRouting, DiscoveryRootGrant, DiscoveryObservation) and a copy of the Claude-only DiscoveryValidation.psm1 that the Phase 15 mirror helper placed there in an earlier task. Set R assigns that enumeration update to P15-T22, which names this suite, adds the new modules to the pack manifests and decides the Claude-only copy (list it as shared or remove it from the bundle lib). The failure is independent of this task's change: the registration file is not read by that test, and the same four names were present before this task.
- Key counts: .github/hooks/discovery.json has `"version": 1` once and `"windows"` zero times; the converter fixture has `"version": 1` once, `"powershell"` once, `"bash"` once and `"windows"` zero times.
- Bundle: `cmp` of .github/hooks/discovery.json against extensions/drm-copilot/resources/customizations/.github/hooks/discovery.json exits 0 (byte-identical); the DiscoveryCapability.psm1 mirrors were refreshed by the same copy.

## Changes in this task

- .github/hooks/discovery.json: top-level `"version": 1`; each of the four entries carries `type`, `powershell`, `bash` (both `pwsh -NoProfile -File .github/hooks/<handler>.ps1`) and `timeout`; the `windows` and `command` keys are removed.
- tests/fixtures/codex_native_converter/native_surfaces/.github/hooks/discovery.json: the same shape for its single PreToolUse entry.
- CL/DiscoveryCapability.psm1 `Get-DiscoveryHostRegistration`: a JSON hook object names its handler through `powershell`, `bash` or `command`, read in that order (first non-blank wins); the docstring states both shapes.
- tests/scripts/copilot-hooks/discovery-capability.Tests.ps1: the registration case asserts the version-1 shape (replacing the `windows` variant assertion).
- tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1: new precedence case for the three handler keys.
- extensions/drm-copilot/resources/customizations/.github/hooks/discovery.json and the DiscoveryCapability.psm1 mirrors: refreshed copies.

## Execution decisions

- The fixture's command text was aligned to the repository's (`pwsh -NoProfile -File ...`) and given `timeout` 30 so the fixture is the same shape as the published file; the converter does not read these values (confirmed by searching both converters for hook JSON parsing), and its five suites pass unchanged.
- The `windows` legacy key is not read by the registration parser; a file that carries only `command` still parses (legacy case covered), so a consumer that has not yet adopted the documented shape keeps working.
