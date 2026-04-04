# Feature Audit: bundle-sync-agents-113 (Post-Remediation)

**Timestamp:** 2026-04-04T17-00
**Feature Folder:** `docs/features/active/2026-03-21-bundle-sync-agents-113`
**Base Branch:** `development`
**Head Branch:** `feature/bundle-sync-agents-113`
**Audit Type:** Post-remediation acceptance criteria verification

---

## 1. Scope and Baseline

**Base branch:** `development` (commit `426b92cfcd84fd66c53097bfa9622baec7bf16e6`)
**Head commit:** `f6ad146ead12f2ea032ac9968fb64bb60d054517`

**Evidence sources:**
- Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-04-04T17-00)
- Secondary: `artifacts/pr_context.appendix.txt`

**Feature folder:** `docs/features/active/2026-03-21-bundle-sync-agents-113/`
(selected: suffix matches issue number 113 in branch name; most material scoping-doc changes)

**Work Mode:** `full-feature` (from `issue.md`: `- Work Mode: full-feature`)

**AC source files (per `full-feature` mode):**
- `docs/features/active/2026-03-21-bundle-sync-agents-113/user-story.md` (primary)
- `docs/features/active/2026-03-21-bundle-sync-agents-113/spec.md` (secondary — contains one plan-level AC checkbox)

---

## 2. Acceptance Criteria Inventory

Extracted from `user-story.md` (authoritative for `full-feature`):

1. The extension contributes a new command for syncing `AGENTS.md`, and invoking it runs the bundled sync workflow against the open workspace root rather than the extension installation directory.
2. The bundled sync workflow reads `.github/copilot-instructions.md` and discovers instruction sources under `.github/` from the destination workspace instead of depending on a hard-coded section-definition array.
3. The generated `AGENTS.md` includes the canonical repository instructions plus the discovered instruction bodies in a deterministic order, strips YAML frontmatter from source files, and produces identical output on repeated runs when inputs have not changed.
4. If the destination workspace is missing required source files such as `.github/copilot-instructions.md` or has no discoverable instruction files, the command fails with an actionable error message instead of generating partial or misleading output.
5. Adding a new instruction file under the supported `.github/` discovery scope causes the next sync run to include it automatically without requiring a code change to the sync script.

---

## 3. Acceptance Criteria Evaluation Table

| # | Criterion (abbreviated) | Status | Evidence | Verification Commands | Notes |
|---|------------------------|--------|----------|----------------------|-------|
| AC-1 | Extension contributes `syncAgentsFromInstructions` and runs against open workspace root | ✅ PASS | `extension-sync-agents-execution-red.2026-04-03T16-08.md` (fail-before); `extension-sync-agents-green.2026-04-04T11-30.md` (pass-after). PR context summary shows all 5 spec ACs marked [x]. | `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/extension.integration.test.ts --testNamePattern="syncAgentsFromInstructions"` | Extension command registered and integration test verifies it runs the bundled PowerShell template against the workspace root. Test result: pass. |
| AC-2 | Bundled sync reads `.github/copilot-instructions.md` and discovers `*.instructions.md` files (not hard-coded list) | ✅ PASS | `sync-agents-auto-include-red.2026-04-03T16-08.md` (fail-before); `powershell-sync-discovery-green.2026-04-03T16-08.md` (pass-after). | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` | Pester tests verify discovery of `.github/copilot-instructions.md` and `*.instructions.md`. PSScriptAnalyzer passes. Result: 232 passed. |
| AC-3 | Generated `AGENTS.md` is canonical instructions + discovered bodies, deterministic, idempotent | ✅ PASS | `sync-agents-idempotent-red.2026-04-03T16-08.md` (fail-before); `sync-agents-deterministic-order-red.2026-04-03T16-08.md` (fail-before); `powershell-sync-discovery-green.2026-04-03T16-08.md` (pass-after). | Pester suite above | Tests cover deterministic ordering and idempotency. YAML frontmatter stripping tested. Result: all pass. |
| AC-4 | Missing `.github/copilot-instructions.md` or no discoverable files causes actionable failure | ✅ PASS | `sync-agents-missing-preamble-red.2026-04-03T16-08.md` (fail-before); `sync-agents-no-discovery-red.2026-04-03T16-08.md` (fail-before); `powershell-sync-discovery-green.2026-04-03T16-08.md` (pass-after). | Pester suite above | Guard conditions tested: missing preamble and no discoverable files both surface actionable errors. No partial output produced. |
| AC-5 | Adding a new instruction file causes automatic inclusion on next sync run | ✅ PASS | `sync-agents-auto-include-red.2026-04-03T16-08.md` (fail-before); `powershell-sync-discovery-green.2026-04-03T16-08.md` (pass-after). | Pester suite above | Auto-include test verifies that a new `*.instructions.md` file dropped into `.github/` is picked up without any code change. Result: pass. |

---

## 4. Summary

**Overall feature readiness: PASS**

All five acceptance criteria are satisfied with fail-before and pass-after evidence:
- Nine regression-testing artifacts document the fail-before state at the start of execution.
- Three pass-after artifacts document the pass state following implementation.
- All toolchain checks across TypeScript, Python, and PowerShell are clean as verified
  by live re-execution on 2026-04-04.
- Bundled copy parity between repo-root and extension-bundled scripts is confirmed identical.
- Rewrite catalog updated with `syncAgentsFromInstructions` entry.

**Top gaps preventing PASS:** None.

**Recommended follow-up (informational only, not blocking):**
- Open the pull request against `development`.
- Confirm CI pipeline passes on the PR (CI status unavailable locally; no PR created yet).
- Consider the 461-line headroom note for `test_push_down_copilot_customizations_rewrites.py`
  when planning future rewrite-catalog additions (see code-review N2).

---

## 5. Acceptance Criteria Check-Off

All five ACs evaluated as **PASS** and already marked `[x]` in `user-story.md` (confirmed from
PR context summary which shows all ACs with `[x]`). No changes required to AC source files.

### AC Status Summary

| Source File | Total ACs | Verified [x] | Unverified [ ] | Newly checked off |
|-------------|-----------|-------------|----------------|-------------------|
| `user-story.md` | 5 | 5 | 0 | 0 (already checked) |
| `spec.md` | 1 (plan-level) | 1 | 0 | 0 (already checked) |
| `issue.md` | 5 (early draft) | 0 | 5 | N/A — not an AC source for `full-feature` |

Note: `issue.md` contains "early draft" AC items that pre-date spec authoring. For work mode
`full-feature`, `issue.md` is not the authoritative AC source (`user-story.md` and `spec.md`
are). The `issue.md` items are intentionally left in their original draft state.
