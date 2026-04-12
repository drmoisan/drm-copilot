# Feature Audit: bundle-sync-agents-113

**Audit Date:** 2026-04-04  
**Reviewer:** feature_code_review_agent  
**Base Branch:** origin/development @ 426b92cf  
**Head Branch:** feature/bundle-sync-agents-113 @ f6ad146e  
**Feature Folder:** `docs/features/active/2026-03-21-bundle-sync-agents-113`

---

## 1. Scope and Baseline

**Base branch:** `development`

**Evidence sources:**
- PR context summary: `artifacts/pr_context.summary.txt` (refreshed 2026-04-04T15-55 UTC)
- PR context appendix: `artifacts/pr_context.appendix.txt` (same timestamp)
- Feature evidence: `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/`

**Work Mode:** `full-feature` (per `issue.md` → `- Work Mode: full-feature`)  
**AC source files (per work mode):** `spec.md` and `user-story.md`

**Acceptance criteria used:** Both `spec.md` ("Definition of Done") and `user-story.md` ("Acceptance Criteria") contain the same five AC items (verbatim match confirmed). The five criteria below are the authoritative checklist.

---

## 2. Acceptance Criteria Inventory

Source: `user-story.md` §Acceptance Criteria and `spec.md` §Definition of Done (criteria are identical in both files).

| ID | Criterion | Source File(s) |
|----|-----------|----------------|
| AC-1 | The extension contributes a new command for syncing `AGENTS.md`, and invoking it runs the bundled sync workflow against the open workspace root rather than the extension installation directory. | `user-story.md`, `spec.md` |
| AC-2 | The bundled sync workflow reads `.github/copilot-instructions.md` and discovers instruction sources under `.github/` from the destination workspace instead of depending on a hard-coded section-definition array. | `user-story.md`, `spec.md` |
| AC-3 | The generated `AGENTS.md` includes the canonical repository instructions plus the discovered instruction bodies in a deterministic order, strips YAML frontmatter from source files, and produces identical output on repeated runs when inputs have not changed. | `user-story.md`, `spec.md` |
| AC-4 | If the destination workspace is missing required source files such as `.github/copilot-instructions.md` or has no discoverable instruction files, the command fails with an actionable error message instead of generating partial or misleading output. | `user-story.md`, `spec.md` |
| AC-5 | Adding a new instruction file under the supported `.github/` discovery scope causes the next sync run to include it automatically without requiring a code change to the sync script. | `user-story.md`, `spec.md` |

---

## 3. Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification Command(s) | Notes |
|-----------|--------|----------|------------------------|-------|
| **AC-1**: New extension command runs bundled workflow against open workspace root | ✅ PASS | (1) `extension.ts` diff: `vscode.commands.registerCommand("drmCopilotExtension.syncAgentsFromInstructions", ...)` calls `executeBundledScript` with `bundledRelativePath: "resources/templates/sync-agents-from-instructions.ps1"` and `args: ["-RepoRoot", getWorkspaceRoot()]`. (2) `package.json` diff: command `drmCopilotExtension.syncAgentsFromInstructions` contributed with title "drm-copilot: Sync AGENTS.md from Instructions". (3) Registration test passes: `evidence/other/extension-sync-agents-green.2026-04-04T11-30.md` — `activate registers drmCopilotExtension.syncAgentsFromInstructions`: PASS. (4) Execution routing test passes: `syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root`: PASS. | `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/extension.integration.test.ts --testNamePattern="syncAgentsFromInstructions"` | Command is registered and routed to the bundled template at workspace root. |
| **AC-2**: Discovery-based: reads `copilot-instructions.md`, no hardcoded array | ✅ PASS | (1) `sync-agents-from-instructions.ps1` diff: `$sections` hardcoded array completely removed. `Get-DiscoveredInstructionFile` introduced: `Test-Path` check on `copilot-instructions.md` + `Get-ChildItem -Filter '*.instructions.md' -Recurse`. (2) `Get-AgentContent` now calls `Get-DiscoveredInstructionFile` instead of iterating `$sections`. (3) Pester scenarios confirm discovery behavior: `evidence/other/powershell-sync-discovery-green.2026-04-03T16-08.md`. (4) Bundled template is identical to root script: `evidence/qa-gates/bundle-sync-agents-summary.2026-04-04T11-55.md`. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"` | Hardcoded array fully replaced. Discovery confirmed by Pester and delivery summary. |
| **AC-3**: Deterministic order, frontmatter stripped, idempotent | ✅ PASS | (1) Deterministic sort: `[System.Array]::Sort($sortedRelativePaths, [System.StringComparer]::Ordinal)` — platform-independent ordinal sort. Pester scenario: `sync-agents-deterministic-order-red` (fail-before) → passes in `powershell-sync-discovery-green`. (2) Frontmatter stripping: `Get-InstructionFileData` applies `$frontMatterPattern` regex; stripped body stored in `.Body`. `Get-InstructionsBody` also strips for copilot-instructions.md. Pester confirms empty-file handling and stripping. (3) Idempotent: dedicated Pester scenario `sync-agents-idempotent-red` → passes. Ordinal-sorted relative paths produce same order on repeated runs. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -TestName '*idempotent*', '*deterministic*'"` | All three sub-criteria confirmed by Pester. |
| **AC-4**: Fails with actionable error when required inputs missing | ✅ PASS | (1) Missing `copilot-instructions.md`: `Get-DiscoveredInstructionFile` throws `"Required AGENTS preamble file not found: <path>"`. Pester regression scenario `sync-agents-missing-preamble-red` confirmed this error. (2) Zero discovered instruction files: `throw "No supported instruction files were discovered under <githubRoot>"`. Pester scenario `sync-agents-no-discovery-red` confirmed. (3) Error is surfaced through the extension's `executeBundledScript` output path — PowerShell errors propagate to the VS Code output channel. (4) No partial `AGENTS.md` written: discovery failure throws before `Get-AgentContent` writes. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -TestName '*missing-preamble*', '*no-discovery*'"` | Fail-fast behavior confirmed. Error messages include the specific path that was missing. |
| **AC-5**: New instruction file included automatically without code change | ✅ PASS | `Get-DiscoveredInstructionFile` uses `Get-ChildItem -Filter '*.instructions.md' -Recurse` — any new file matching the pattern is included on the next run. Pester scenario `sync-agents-auto-include-red` (fail-before) → confirmed passing in `powershell-sync-discovery-green`. No array definition or explicitly registered file name is required. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -TestName '*auto-include*'"` | Discovery is fully dynamic. |

---

## 4. Additional Spec Requirements

The spec's "Definition of Done" includes additional items beyond the five core AC checkboxes:

| Requirement | Status | Notes |
|-------------|--------|-------|
| Tests added/updated in `sync-agents-from-instructions.Tests.ps1` | ✅ PASS | Pester suite extended; 7+ scenarios passing. |
| Tests added/updated in `extension.test.ts` and `extension.integration.test.ts` | ✅ PASS | 2 new tests covering registration and execution routing. |
| Rewrite catalog tests updated | ✅ PASS | `test_sync_agents_script_reference_rewrites_to_live_command` added; `test_thinking_beast_mode_bundle_mirror_matches_root_agent` passes. |
| Edge cases covered (missing preamble, zero discovery, deterministic ordering, frontmatter stripping, auto-include) | ✅ PASS | All 5 edge cases have Pester regression tests with fail-before evidence. |
| Documentation updated | ✅ PASS | `README.md` and `extensions/drm-copilot/README.md` both updated. |
| Extension output surfacing success/failure | ✅ PASS | Uses existing `executeBundledScript` path; PowerShell errors propagate to output channel. |
| Toolchain passes for all touched languages | ✅ PASS | Python, TypeScript, PowerShell all clean (independently verified). |
| Existing repo-root PowerShell entrypoint still works | ✅ PASS | Script retains `-RepoRoot` parameter with default path resolution. Direct invocation path unchanged. |

---

## 5. Summary

**Overall feature readiness:** PASS (acceptance criteria) / NEEDS REVISION (policy compliance)

All five acceptance criteria are satisfied with evidence from Pester, Jest, and Python pytest. The feature behavior is complete and correct.

However, the branch cannot be merged in its current state due to two hard policy violations:
- `extensions/drm-copilot/src/extension.ts` is 592 lines (limit: 500)
- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` is 583 lines (limit: 500)

And one Major finding:
- The out-of-scope MCP provider's runtime callbacks are not behaviorally tested

**Top gaps preventing MERGE (not feature gaps):**
1. F1: `extension.ts` 500-line violation
2. F2: Python test file 500-line violation
3. F3: MCP provider callback behavioral coverage

**Recommended follow-up verification steps:**  
After remediation, re-run the full toolchain loop and confirm:
- `extensions/drm-copilot/src/extension.ts` (or split successor files) are under 500 lines each
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py` (new split-off file) has ≥90% coverage
- TypeScript functions coverage recovers above 85% (from 78.26%) once MCP callbacks are tested

---

## 6. Acceptance Criteria Check-Off

Per `acceptance-criteria-tracking` skill rules: criteria evaluated as PASS are checked off in both `spec.md` and `user-story.md`. All five AC items evaluated as PASS.

AC items to check off in both source files:
- `- [ ] The extension contributes a new command for syncing AGENTS.md...` → `- [x]`
- `- [ ] The bundled sync workflow reads .github/copilot-instructions.md...` → `- [x]`
- `- [ ] The generated AGENTS.md includes...deterministic order...strips YAML frontmatter...idempotent...` → `- [x]`
- `- [ ] If the destination workspace is missing required source files...fails with actionable error...` → `- [x]`
- `- [ ] Adding a new instruction file...causes next sync run to include it...` → `- [x]`

**AC Status Summary:**

| Status | Count | Items |
|--------|-------|-------|
| PASS | 5 | AC-1, AC-2, AC-3, AC-4, AC-5 |
| PARTIAL | 0 | — |
| FAIL | 0 | — |
| UNVERIFIED | 0 | — |

All acceptance criteria are satisfied. Policy compliance blockers are tracked in `remediation-inputs.2026-04-04T16-00.md`.
