Timestamp: 2026-08-22T13-41
Command: python -c "import json;p='extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));del d['shared_surfaces'];open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))" ; then a filtered Invoke-Pester run against tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 with Filter.FullName = '*requires a populated shared-surface list and module map in both copies*' ; and in the same perturbed state, poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_the_gate_compares_non_empty_collections
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PowerShell: $result.PassedCount = 0, $result.FailedCount = 1. Failure message:
"Expected $null or empty, but got 'bundled shared_surfaces: shared_surfaces key absent'." This is
the absent-key state the pre-repair floor's @($config[$key]).Count -gt 0 idiom could not detect
(@($null).Count is 1 in PowerShell), so this demonstrates the repair fails where the old floor
wrongly passed. Python companion: 1 failed. AssertionError:
"extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json shared_surfaces
must be non-empty for the gate to discriminate." (assert ()). Confirms the Python floor responds
to the same absent-key input the same way.
