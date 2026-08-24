# Remediation Inputs: planner-hook-em-dash-mismatch-357 (#357)

**Entry Timestamp:** 2026-07-17T18-00
**Remediation Cycle:** 3
**Trigger:** S9 CI-Failure Handling (required check failure on PR #358)

**Failing check:** `quality-checks7 / Code Quality & Tests (3.10)`
**Failing job URL:** https://github.com/drmoisan/drm-copilot/actions/runs/29595581077/job/87935042589
**PR head SHA at failure:** 5d1431ae02939c372b34a5cbe33985fd8754d871

**Failing test:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

```
AssertionError: Bundle content differs from repo for: .claude/hooks/validate-planner-output.ps1
assert '<#\n.SYNOPSI...}\n\nexit 0\n' == '﻿<#\n.S...}\n\nexit 0\n'
```

## Trigger condition met

This repository maintains a bundled mirror of every `.claude/` runtime file under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and a repo-hygiene test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) enforces byte-identical parity between the two trees. `.claude/hooks/validate-planner-output.ps1` was modified across S5 (em-dash regex fix) and remediation cycle 2 (a PSObject strict-mode fix plus a UTF-8 BOM added by the PoshQC formatter once the file gained a non-ASCII em-dash character). The bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` was never updated to match, so it still has the pre-fix ASCII-hyphen regex, the pre-fix `-contains` strict-mode-unsafe check, and no BOM.

This is the same class of dual-copy-drift defect this feature has already fixed twice for the PoshQC Pester settings files (`scripts/powershell/...` vs `extensions/drm-copilot/resources/powershell/...`), now surfacing for a third paired-copy location this feature's fix touched.

Both prior remediation cycles' "Do Not Do" lists explicitly excluded this vendored copy from scope, on the assumption it was a separate, non-blocking Informational finding (per the original feature-review's code-review artifact). That assumption was incorrect: this file IS covered by a repo-enforced parity contract, and the exclusion is what caused this CI failure. This cycle corrects that scoping error.

## Enumerated Fix List

1. **Sync the bundled mirror to match the canonical repo copy exactly (byte-for-byte, including the UTF-8 BOM).**
   - File: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`
   - Expected behavior: Byte-identical to `.claude/hooks/validate-planner-output.ps1` (em-dash phase-heading regex and error message, the `.DESCRIPTION` docstring's em-dash reference, the strict-mode-safe `$null -ne $payload.PSObject.Properties['output']` check, and the leading UTF-8 BOM).
   - Verification command: `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`; must pass. Also re-run `python -m pytest -q` (full suite) to confirm no other file in this feature's diff has the same drift.

2. **Re-run the full toolchain and confirm no regression.**
   - Files: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` only.
   - Expected behavior: PoshQC format/analyze/test still pass for the canonical `.claude/hooks/validate-planner-output.ps1` and its test file (unchanged this cycle); the Python quality-checks test suite (matching the failing CI job) passes locally.
   - Verification command: `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.

## Do Not Do

- Do not modify `.claude/hooks/validate-planner-output.ps1` itself (already correct); only the bundled mirror needs to change.
- Do not modify any other file in the bundled `extensions/drm-copilot/resources/claude-customizations/` tree.
- Do not widen the change budget beyond this one bundled-mirror file.
- Do not run `mcp__drm-copilot__push_down_claude_customizations` (that tool copies the bundle INTO a workspace — the opposite direction from what this fix needs) or `mcp__drm-copilot__run_codex_native_converter`.

## Pointer to Audit Artifacts

- This finding was discovered by S9 CI-failure handling, not by `feature-review`; no policy-audit/code-review/feature-audit artifacts precede this file for this cycle. The prior cycle's clean artifacts remain: `docs/features/active/planner-hook-em-dash-mismatch-357/{policy-audit,code-review,feature-audit}.2026-07-17T17-15.md`.

## Handoff Note

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, plan authoring for this remediation cycle is the responsibility of `atomic-planner`, delegated by the orchestrator. The orchestrator should route this file's enumerated fix list to `atomic-planner` to produce `remediation-plan.2026-07-17T18-00.md`, then proceed through the standard preflight -> execution -> reaudit chain.
