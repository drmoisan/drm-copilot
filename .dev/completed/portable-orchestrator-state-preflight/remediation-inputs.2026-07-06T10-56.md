# Remediation Inputs — portable-orchestrator-state-preflight

- **Issue:** none
- **Timestamp:** 2026-07-06T10-56
- **Reviewed range:** `75eac1a..12f259a`
- **Source artifacts:**
  - `docs/features/active/portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md`
  - `docs/features/active/portable-orchestrator-state-preflight/code-review.2026-07-06T10-56.md`
  - `docs/features/active/portable-orchestrator-state-preflight/feature-audit.2026-07-06T10-56.md`

## Blocking Findings (remediation required)

### R-1 — File exceeds the 500-line hard limit

- **Severity:** Blocking
- **Policy:** `.claude/rules/general-code-change.md` — File Size Limit ("No production code, test code, or reusable script file may exceed 500 lines").
- **File:** `.claude/hooks/enforce-pr-author-skill.ps1`
- **Observed:** 553 lines. Baseline (`75eac1a`) was 508 lines (already over the limit); this change added net +45 lines (numstat `50 5`), worsening the overage.
- **Required action:** Reduce the file below 500 lines. Recommended approach that also resolves R-2: extract the shared capability-detection probe `Test-PythonOrchestratorValidatorAvailable` (and, if further reduction is needed, the preflight helper block) into `.claude/lib/orchestrator-state/OrchestratorState.psm1` (or a small shared lib module) and import it in the hook. The extracted module must remain listed in `core.json` so push-down still ships it.
- **Constraints:** Preserve the injectable `$Invoker` seam, the fail-closed contract, and the exact block-reason string `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`. Re-run the PowerShell toolchain (format → analyze → Pester with coverage) and confirm no coverage regression on the changed files.
- **Acceptance criterion affected:** AC7 (feature-review clean of blocking findings) — currently FAIL.

### R-1b — Bundle snapshot not mirrored; push-down still ships the broken/old hooks (orchestrator-discovered)

- **Severity:** Blocking
- **Policy / contract:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` requires byte-identical parity between repo-root `.claude/**` and the bundled snapshot `extensions/drm-copilot/resources/claude-customizations/.claude/**` (agent-memory and the legacy variant subtree excepted).
- **Discovered by:** orchestrator, during R1 planning (planner Open Question #1), confirmed by running the test.
- **Observed:** This feature modified `.claude/hooks/enforce-pr-author-skill.ps1` and `.claude/hooks/validate-orchestrator-output.ps1` and added `.claude/lib/orchestrator-state/OrchestratorState.psm1` and `OrchestratorStateCompletion.psm1`, but did NOT mirror them into the bundle. The bundled `enforce-pr-author-skill.ps1` is still the old 508-line version and the new `.claude/lib/orchestrator-state/` module is absent from the bundle. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` FAILS (`Bundle content differs from repo for: .claude\hooks\enforce-pr-author-skill.ps1`).
- **Impact (root of the original problem):** The VS Code extension's push-down command ships from the bundled snapshot, so consumer repos (e.g. TaskMaster) would continue to receive the broken, non-portable hooks even after this fix — the feature does not achieve its purpose until the bundle is mirrored.
- **Required action:** After the R-1 file-size fix is finalized on the live `.claude/`, mirror the FINAL content of the two hooks and the two new `.claude/lib/orchestrator-state/*.psm1` modules byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/**`. Confirm `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes and the PowerShell toolchain remains green.
- **Process note:** the cycle-0 feature-review scoped to PowerShell for the hook changes and did not run the Python resource-contract parity test that governs `.claude/**` changes; the re-audit must include it.

### R-1c — Modified test file exceeds the 500-line limit (orchestrator-discovered, same class as R-1)

- **Severity:** Blocking
- **Policy:** `.claude/rules/general-code-change.md` — File Size Limit (applies to test code).
- **File:** `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`
- **Observed:** 552 lines. Pre-existing overage (513 lines at `main` and at base `75eac1a`), worsened by this feature's edits (513 → 545 in the original feature, → 552 in cycle 1). Same worsened-pre-existing-overage class the reviewer treated as Blocking for R-1.
- **Required action:** Split the file below 500 lines (e.g. extract cohesive `Describe`/`Context` groups into a sibling `*.Tests.ps1`), preserving all tests and behavior. Test files are under `tests/`, NOT `.claude/**`, so there is no bundle-mirror implication. Re-run the PowerShell toolchain; keep the Python parity test green.
- **Handled:** within remediation cycle 1 (same file-size class as R-1), to avoid a predictable low-value additional cycle.

## Non-Blocking Findings (recommended, not required to unblock)

### R-2 — Duplicated capability probe across both hooks

- **Severity:** Low
- **File(s):** `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/validate-orchestrator-output.ps1`
- **Finding:** `Test-PythonOrchestratorValidatorAvailable` is duplicated verbatim (~28 lines each).
- **Recommended action:** Extract to the portable lib module and import in both hooks (addresses R-1 as well). If hook self-containment on push-down is a hard constraint, document that rationale in-file instead.

### R-3 — New modules absent from the canonical coverage artifact

- **Severity:** Low
- **File:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` / `artifacts/pester/powershell-coverage.xml`
- **Finding:** The two new modules are listed in `CodeCoverage.Path` but did not appear in the canonical `powershell-coverage.xml` from the inspected run; their 100% coverage is proven only by the scoped `orchestrator-state-coverage.xml`.
- **Recommended action:** Ensure the next full PoshQC test run emits both modules into the canonical coverage artifact so a single artifact carries the full production denominator (`general-unit-test.md` coverage-exclusion policy).

### R-4 — Completion-gate parity depth (documented Non-Goal)

- **Severity:** Medium (informational; no code change required)
- **File:** `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`
- **Finding:** The portable completion gate performs base-presence + model-routing existence checks only, not the Python `--require-complete` deep completion/CI/phase/per-receipt checks. Consumer-repo completion enforcement is therefore presence-level.
- **Disposition:** Accepted per `spec.md` Non-Goals (Option A). No action required; keep the in-module scope documentation.

## Handoff Notes

- One Blocking item (R-1) gates PR readiness. R-1 and R-2 are best resolved together by extracting the shared probe into the portable lib module.
- All functional acceptance criteria (AC1–AC6) PASS; coverage and toolchain evidence are complete and independently verified from `artifacts/pester/*`.
- The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the diff), so no green-run evidence is required.
