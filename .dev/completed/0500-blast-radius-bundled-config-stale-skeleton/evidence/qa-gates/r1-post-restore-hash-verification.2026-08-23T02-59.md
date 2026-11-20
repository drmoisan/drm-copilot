Timestamp: 2026-08-23T02-59 (UTC)
Command: git checkout -- config/blast-radius.json extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json (JSON files, no in-cycle work); manual removal of the invented_key line from blast_radius_parity_test_support.py and BlastRadius.KeyPartition.Tests.ps1 (files carrying in-cycle work); Get-FileHash rerun on both.
EXIT_CODE: 0
Output Summary: Restore verified against the P1-T7 pre-perturbation hashes, not git checkout --, for the two files carrying in-cycle work.

Before (P1-T7) / After (P1-T9) hash pairs:
tests/scripts/dev_tools/blast_radius_parity_test_support.py
  Before: 888CEB51002E9C501E7FC6122028349D7FE629C8E3F501F966E40BF2730FEE12
  After:  888CEB51002E9C501E7FC6122028349D7FE629C8E3F501F966E40BF2730FEE12
  Match: yes

tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
  Before: 2F4E5EAD83DF4151740E32770DAFFBDAE4569D65352DB6126CFA3BABF0480C2E
  After:  2F4E5EAD83DF4151740E32770DAFFBDAE4569D65352DB6126CFA3BABF0480C2E
  Match: yes

git status --short for config/blast-radius.json and its bundled copy: no output (clean).
Rerun of the Python node ID: 1 passed, EXIT_CODE 0.
Rerun of the identical filtered Pester configuration: Passed=1 Failed=0.
