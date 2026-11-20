# Pytest Bundle Parity Baseline — Remediation Cycle 3 [expect-fail]

**Timestamp:** 2026-07-17T18-06

**Command:** `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

**EXIT_CODE:** 1

**Output Summary:**
1 failed in 0.06s. Failure is `AssertionError: Bundle content differs from repo for: .claude\hooks\validate-planner-output.ps1`, with the diff showing the repo copy carries a leading `﻿` (UTF-8 BOM) that the bundled mirror lacks (`assert '<#\n.SYNOPSI...}\n\nexit 0\n' == '﻿<#\n.S...}\n\nexit 0\n'`). This confirms the pre-fix state: the bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` has not been synced with the canonical `.claude/hooks/validate-planner-output.ps1`. This failure is expected for this baseline task and will be resolved by the Phase 1 byte-for-byte copy.
