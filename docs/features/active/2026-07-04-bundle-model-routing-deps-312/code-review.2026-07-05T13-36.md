# Code Review: bundle-model-routing-deps (#312)

**Review Date:** 2026-07-05
**Base Branch:** `main` (merge-base `fe62df7bb6ab4b6dbd6ad362c2a87851933ba0b6`)
**Head:** `457ae0289c426004adaf9b3a349540e8684892c5`
**Scope:** full feature-vs-base branch diff

## Executive Summary

The change is well-scoped and cleanly implemented. It adds a `.claude`-resident PowerShell module (`ModelRouting.psm1`) with two pure functions that faithfully port the existing Python model-routing formulas, byte-mirrors the module into the bundle tree, lists it in the `core` pack manifest, repoints the `orchestrate`/`epic-orchestrate` skill runnable-reference citations to the PowerShell functions, and pins the module's constants to `config/orchestration-routing.json` via a static parity test. The reviewer confirmed the port matches the Python references branch-for-branch by direct source comparison.

Code quality is high. The module uses advanced-function conventions (`CmdletBinding`, `OutputType`, mandatory parameters, comment-based help), embeds constants at module scope with intent comments, performs no runtime I/O, and fails fast on an out-of-table band. PSScriptAnalyzer reports zero findings across all five new files, the 41 new Pester tests pass, and the module reaches 100% command coverage. Byte-mirror parity is exact for the module and both skill files.

No blocking or major findings. Two minor, non-blocking observations are recorded below for awareness; neither requires remediation. The two out-of-plan edits (`.gitignore`, `pester.runsettings.psd1`) are mechanically necessary and correctly disclosed in the scope-guard evidence.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | `.claude/lib/model-routing/ModelRouting.psm1` | `Get-ComplexityFloor` (lines 107-123) | The function treats every non-empty `$SignalsPresent` element as a triggered floor signal and always returns `C3`; individual signal names are not inspected. | No change required. Optionally note in the `.PARAMETER` help that all supplied names are assumed `[floor]`-flagged. | This is a faithful port of the Python `compute_complexity_floor` contract: the caller supplies only `[floor]`-flagged signals, so any non-empty set yields the uniform candidate band `C3`. Behavior matches the reference. | `scripts/dev_tools/compute_complexity_floor.py` docstring and body; existing help already states the input is "signals flagged [floor]". |
| Info | `.claude/lib/model-routing/ModelRouting.psm1` | `Resolve-DelegationModel` (lines 175-187) | An out-of-table band only throws when the preferred-overlay branch does not match; an out-of-table band combined with a matched overlay (agent in overlay set, band `C3`) never reaches the base-table lookup. | No change required. | The overlay only matches `Band -eq 'C3'`, which is always a valid table key, so an out-of-table band can never satisfy the overlay branch. The throw guard is reachable for every genuinely out-of-table band. Matches the Python control flow exactly. | Reviewer control-flow inspection; `Resolve-DelegationModel.Tests.ps1` out-of-table negative case passes. |
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CoveragePercentTarget = 0` (pre-existing) | The repo Pester config does not fail the run on a coverage percentage; the module is added to the coverage `Path` allowlist but no numeric gate enforces it in this config. | No change required; gate enforcement is external to this file. | The 0 target is pre-existing repository behavior, not introduced by this change. Coverage is enforced by review and CI, and the module is at 100%. | diff of `pester.runsettings.psd1`; reviewer coverage re-run. |

## Detailed Notes

### Correctness and parity

The PowerShell ports are behaviorally identical to the Python references across the shared cases. `Resolve-DelegationModel` mirrors `resolve_delegation_model` line-for-line: the overlay condition (`FablePolicy == preferred AND agent in overlay set AND band == C3`), the disabled-mode fable-cell clamp to `opus` with `clamped_from = fable` / `clamp_reason = fable_disabled`, and the no-clamp verbatim return all match. `Get-ComplexityFloor` reproduces the empty-input guard, the uniform `C3` candidate, and the `C3` ceiling clamp. The reviewer independently exercised the full 41-test suite; all pass.

### Design and readability

The module follows repository PowerShell standards: advanced functions, `Set-StrictMode -Version Latest`, module-scope constants with meta-what intent comments, comment-based help on the module and both functions, and explicit fail-fast (`throw`) rather than a silent wrong return. The functions are pure with no runtime file read, preserving the self-contained property required by the spec's invariants. The parity test isolates the single config-read concern from the runtime functions.

### Tests

Tests are structured with `Describe`/`Context`/`It`, one behavior per `It`, explicit Arrange-Act-Assert comments, `-ForEach` matrices for boundary cases, and dedicated determinism and order-independence checks. They read no temp files and start no external process. Test location (`tests/scripts/claude-lib/model-routing/`) correctly mirrors the source location (`.claude/lib/model-routing/`) per the spec mapping; no colocation in the source tree.

### Delivery mechanics

Byte-mirror parity is exact (`cmp` identical for the module and both skill files), the `core.json` manifest lists the module path exactly once, and the `.gitignore` negation exception makes the delivered module trackable. These are the mechanically required steps for the `.claude`-only push-down to deliver a self-contained skill, and each is covered by a test (`ModelRouting.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py`) or by disclosed evidence.

## Verdict

Approve. No blocking or major findings; the three Info items are observations, not defects.
