# Remediation Inputs: local-preflight-orchestrator-state-gate (#272)

**Timestamp:** 2026-07-02T20-15
**Cycle:** 1 (entry)
**Triggering audit artifacts:**
- `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/policy-audit.md`
- `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md`
- `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/feature-audit.md`

**Work mode:** `full-bug`. AC source: `spec.md` `## Acceptance Criteria`.

---

## Blocking Findings Requiring Remediation

### 1. [Blocking] Canonical PowerShell coverage artifact does not corroborate claimed coverage for the changed file

**File:** `artifacts/pester/powershell-coverage.xml` (and companion `artifacts/pester/powershell-coverage.koverage.xml`)

**Expected behavior:** The canonical PowerShell coverage artifact at the path mandated by `feature-review-workflow`'s Coverage Verification procedure must contain a `<class>` entry for `.claude/hooks/enforce-pr-author-skill.ps1` with numeric line coverage corroborating (or superseding) the values already claimed in the feature's own evidence: 90.99% baseline (101/111 commands, `evidence/baseline/poshqc-test-baseline.md`), 88.49% post-change (123/139 commands, `evidence/qa-gates/final-poshqc-test-coverage.md`), and 85.7% changed-lines coverage (24/28 new commands, `evidence/qa-gates/coverage-delta.md`).

**Current state:** The artifact on disk (mtime `2026-07-02 19:13:52`) contains 9 `<class>` entries, none matching `enforce-pr-author-skill`, and every counter in the file reports `covered="0"`. `evidence/baseline/poshqc-test-baseline.md`'s own "Infrastructure Note" independently confirms the root cause: the `mcp__drm-copilot__run_poshqc_test` MCP tool loads its `pester.runsettings.psd1` from a separately-installed, non-repo-tracked extension package under the local VS Code Insiders server profile, which did not pick up this session's repo-tracked `CodeCoverage.Path` edit (adding `.claude/hooks/enforce-pr-author-skill.ps1`).

**Root cause to fix:** The stale, non-repo-tracked copy of `pester.runsettings.psd1` used internally by the `mcp__drm-copilot__run_poshqc_test` MCP tool does not reflect the repo-tracked `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (and its bundled mirror) at the time this feature's coverage evidence was captured.

**Verification command:**
```powershell
# After ensuring the MCP tool's bundled settings reflect the repo-tracked pester.runsettings.psd1
# (e.g. by restarting/reloading the extension host, or by running Invoke-Pester directly with
# -Configuration pointed at the repo-tracked settings file and its default OutputPath):
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
# or the direct equivalent already used in this feature's own baseline/final evidence:
# Invoke-Pester -Configuration $config   (with $config.CodeCoverage.Path including
#   '.claude/hooks/enforce-pr-author-skill.ps1' and $config.CodeCoverage.OutputPath =
#   'artifacts/pester/powershell-coverage.xml')
```

**Acceptance for this remediation item:** `artifacts/pester/powershell-coverage.xml` contains a `<class name=".../.claude/hooks/enforce-pr-author-skill.ps1">` entry with a `LINE` counter showing line coverage >= 85% (repo's uniform-tier floor per `.claude/rules/quality-tiers.md`) and no regression on the function's changed lines relative to the pre-feature baseline. Re-run this feature-review's Section 5 coverage inspection against the regenerated artifact.

**Evidence pointer:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/policy-audit.md` Section 5 and Section 8 item 1; `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md` Findings Table row 1.

---

## Non-Blocking-Per-AC but Recommended Findings

### 2. [Major] Stale CI-enforcement claims remain in two documentation surfaces outside this PR's file list

**Files:**
- `README.md` line 390 — `## CI and release workflows` bullet: `` `validate-orchestrator-state.yml` — validation of the orchestrator-state checkpoint artifact. `` (the file no longer exists after this PR's deletions).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` line 144 — `## PR Creation Gate` section: "The repository CI gate `Orchestrator State Gate` runs the same validator when a checkpoint is present. Branch protection should require this check for branches that use orchestrated completion."

**Expected behavior:** Neither file should describe the deleted CI gate as an active enforcement mechanism, consistent with the intent of AC #1 (no in-repo workflow-file reference to the deleted gate) and AC #8 (no CI-enforcement claim remains describing this mechanism), even though these two specific files are not named in either AC's literal file scope.

**Recommendation:**
- `README.md`: remove the `validate-orchestrator-state.yml` bullet from the "CI and release workflows" list (the workflow no longer exists).
- `.agents/skills/orchestrate/SKILL.md`: update or remove the "repository CI gate `Orchestrator State Gate`" claim in `## PR Creation Gate`, consistent with the correction already applied to `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, and `.claude/agents/pr-author.md` by this feature. If this file's PR Creation Gate model is intentionally CI-only for its ecosystem (distinct from the Claude/Codex hook-based model), replace the claim with an accurate description rather than removing enforcement language outright.

**Verification command:**
```bash
grep -n "validate-orchestrator-state" README.md
grep -n "Orchestrator State Gate" extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
```
Both should return no matches (or, for the second file, a corrected claim) after remediation.

**Evidence pointer:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/policy-audit.md` Section 2.6 and Section 8 item 2; `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md` Findings Table rows 2-3.

### 3. [Minor] Consider hardening the new end-to-end Pester test against mutable checkpoint state

**File:** `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `'script entrypoint (end-to-end)'` context (lines 93-127).

**Expected behavior:** Test outcomes should not depend on real, mutable, shared repository state that the test does not control.

**Current state:** The test's block-outcome assertion currently passes because the real `artifacts/orchestration/orchestrator-state.json` checkpoint fails `--require-complete` today; this is not structurally guaranteed to remain true (e.g., mid-orchestration-session).

**Recommendation:** Optional for this cycle. If addressed, point `Invoke-OrchestratorStatePreflight`'s `-CheckpointPath` parameter at a deliberately-nonexistent, non-temp-file path (e.g., a sibling filename that is guaranteed absent, following the existing "real seam, stand-in existing file" pattern used elsewhere in this file family) rather than relying on the real checkpoint's current content.

**Evidence pointer:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/policy-audit.md` Section 8 item 3; `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md` Findings Table row 4.

---

## Do Not Do

- Do not weaken or remove the existing five receipt checks, the Case A/B/C precedence, or the hook's `exit 0`/JSON-`permissionDecision` contract while remediating.
- Do not re-run coverage generation by simply lowering the coverage threshold or by adding `enforce-pr-author-skill.ps1` to an `ExcludedPath`/exclude list — the fix is to make the existing allowlist entry actually take effect in the artifact the review process inspects, not to route around measurement.
- Do not remove the `pr_author_preflight` documentation added to `orchestrate/SKILL.md`/`orchestrator.md`/`pr-author.md` while making the `README.md`/`.agents` corrections — those three files are already correct per AC #8.
- Do not delete or rename the real, live `artifacts/orchestration/orchestrator-state.json` checkpoint as part of any remediation verification step — it may belong to a parent orchestration session's own state tracking (the executor's own manual-validation evidence already documents this constraint).
- Do not check AC #11 back to `[x]` in `spec.md` until the regenerated coverage artifact corroborates the claimed numbers; do not check AC #7 until a live orchestrator session has actually recorded `pr_author_preflight`.

---

## Handoff

Per `remediation-handoff-atomic-planner`, this file is authored at cycle entry alongside a corresponding `remediation/2026-07-02T20-15/remediation-plan.md` (to be authored by `atomic-planner`). This feature-review delegation does not author the remediation plan itself; it hands off findings only.
