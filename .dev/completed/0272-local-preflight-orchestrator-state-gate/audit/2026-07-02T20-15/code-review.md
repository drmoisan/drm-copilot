# Code Review: local-preflight-orchestrator-state-gate (#272)

**Review Date:** 2026-07-02
**Reviewer:** feature-review (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272`
**Feature Folder Selection Rule:** Only active feature folder present; suffix `-272` matches the canonical issue number for this delegation.
**Base Branch:** `main` (merge-base `b1b55c3ddbb38c6f49a0e5e9d2c757ca70ae13f7`)
**Head Branch:** `bug/local-preflight-orchestrator-state-gate-272` (`baf137f`)
**Review Type:** Initial review

---

## Executive Summary

The change deletes the non-functional CI-based orchestrator-state validation gate and replaces it with an in-hook preflight check inside `.claude/hooks/enforce-pr-author-skill.ps1` (and its `.claude`/Codex bundled mirrors). The new `Invoke-OrchestratorStatePreflight` function reuses the already-proven `[scriptblock] $Invoker` seam pattern from `validate-orchestrator-output.ps1`, and the new `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` decision branch is inserted at the documented point in `Get-PrAuthorBypassReason` without disturbing the existing Case A/B/C/receipt-check ordering. Documentation across `orchestrate/SKILL.md`, `orchestrator.md`, `pr-author.md`, and `CLAUDE.md` is updated consistently and correctly.

**What changed:**
- Deleted 4 workflow files (2 root + 2 bundled mirrors) implementing the non-functional CI gate.
- Added `Invoke-OrchestratorStatePreflight` (new function, ~35 lines) and one new early-return branch to `Get-PrAuthorBypassReason` in the primary hook and its two bundled mirrors (byte-identical `.claude` mirror; header-preserving, one-line-divergent Codex mirror, matching a documented converter behavior).
- Extended the existing Pester suite with passing-preflight mocks in 10 contexts, and added a new 129-line sibling test file with 7 new tests (4 direct-seam unit tests, 2 mocked-wrapper block tests, 1 real-subprocess end-to-end test).
- Updated 4 documentation files to describe the new local enforcement mechanism.
- Extended `pester.runsettings.psd1` (root + bundled mirror) to add the changed hook to the coverage measurement allowlist.

**Top 3 risks:**
1. The mandatory PowerShell coverage artifact at the canonical path (`artifacts/pester/powershell-coverage.xml`) does not contain any data for the changed file and reports 0% for every file it does list — the claimed 88.49%/85.7% coverage figures are not independently verifiable from a machine-readable artifact.
2. Two documentation surfaces outside this PR's file list (`README.md`, `.agents/skills/orchestrate/SKILL.md`) still describe the deleted CI gate as active, directly undermining the issue's "no CI-enforcement claim" intent for those surfaces.
3. The new real-subprocess end-to-end Pester test's pass/fail outcome depends on the real, mutable `artifacts/orchestration/orchestrator-state.json` checkpoint's current completeness — a determinism risk that happens to hold today but is not structurally guaranteed.

**PR readiness recommendation:** **Conditional Go** — the hook logic, mirror-parity, and documentation-of-record changes are sound and independently verifiable; readiness is conditional on regenerating a corroborating canonical coverage artifact and correcting (or explicitly deferring, with a tracked follow-up) the two stale CI-enforcement doc references.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `artifacts/pester/powershell-coverage.xml` | whole file | Canonical PowerShell coverage artifact contains no `<class>` entry for `.claude/hooks/enforce-pr-author-skill.ps1` and reports `covered="0"` for every one of its 9 listed classes, indicating a stale run using the pre-edit `CodeCoverage.Path` allowlist. | Regenerate the artifact via a Pester run that picks up the repo-tracked `pester.runsettings.psd1` edit (fix or bypass the stale bundled-extension config identified in `evidence/baseline/poshqc-test-baseline.md`'s Infrastructure Note), so the canonical artifact corroborates the claimed coverage numbers. | The repo's own review contract treats coverage artifacts as mandatory, machine-checkable evidence, not narrative claims; an uncorroborated number cannot support a PASS verdict. | Direct parse of `artifacts/pester/powershell-coverage.xml` (9 classes, all `covered="0"`, no `enforce-pr-author-skill` match); file mtime `2026-07-02 19:13:52`, predating the "final" coverage claim timestamp `2026-07-02T19:28`. |
| Major | `README.md` | line 390 | Still lists `validate-orchestrator-state.yml` as an existing CI workflow under "CI and release workflows," even though this PR deletes that file. | Remove or update the `README.md` bullet describing `validate-orchestrator-state.yml` as part of this PR, or explicitly track it as an immediate fast-follow if intentionally deferred. | A README that documents a deleted workflow as active is a factual regression introduced by this PR's own deletions. | `grep -n "validate-orchestrator-state" README.md` → line 390. |
| Major | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` | line 144 | Asserts "The repository CI gate `Orchestrator State Gate` runs the same validator when a checkpoint is present," directly contrary to this issue's root-cause finding (the CI gate is a structural no-op and is being deleted). | Update or remove this claim for the `.agents` ecosystem surface, consistent with the correction already applied to `orchestrate/SKILL.md`, `orchestrator.md`, and `pr-author.md`. | This file was not in spec.md's file list and is a pre-existing gap, but it directly contradicts the intent of the fix for a third agent-ecosystem surface that a reader could reasonably rely on. | `grep -n "Orchestrator State Gate" extensions/.../\.agents/skills/orchestrate/SKILL.md` → line 144. |
| Minor | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | lines 93-127 (`'script entrypoint (end-to-end)'` context) | The new end-to-end test's pass/fail outcome depends on the real, mutable `artifacts/orchestration/orchestrator-state.json` checkpoint currently failing `--require-complete`. If a complete, passing checkpoint exists at test-run time (e.g., mid-orchestration-session), this specific `It` would fail unexpectedly. | Consider a lightweight fixture/override for the checkpoint path in this specific test (there is already a `-CheckpointPath` parameter on `Invoke-OrchestratorStatePreflight` that could point at a deliberately-nonexistent, non-temp-file path such as a sibling of the hook script itself, mirroring the existing "real seam, stand-in existing file" pattern used elsewhere in this file), or explicitly document this as an accepted, monitored risk. | Coupling a test's outcome to mutable, shared repository state (rather than a controlled path) violates the repo's Determinism/External-Dependencies test principles, even though the coupling is currently benign. | `implementation-deviations.md` #4 (self-disclosed); test file content (reviewed directly). |
| Info | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | whole file | File is now exactly 500 lines (3-line header + 497-line body), at the literal cap with zero headroom. | No action required now; flag for the next change to this file that a split will likely be needed immediately. | `.claude/rules/general-code-change.md`'s 500-line cap is a hard "must not exceed" rule; 500 does not exceed 500, but leaves no margin. | `wc -l` confirms 500 lines. |
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (+ bundled mirror) | `CodeCoverage.Path` | The coverage allowlist remains a fixed 10-file list, not full-repo coverage; this is a pre-existing repo-wide pattern (not introduced by this PR, which only adds itself to the existing list) but is worth noting against `general-unit-test.md`'s "no production file may be excluded from coverage measurement" clause. | No action required for this PR; track as a pre-existing, systemic follow-up if not already tracked. | Informational — does not block this feature, since the pattern predates this PR and this PR moves toward, not away from, compliance. | Direct read of `pester.runsettings.psd1`; `git diff` confirms only a 3-line addition by this PR. |

No Blocker findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The new `Invoke-OrchestratorStatePreflight` function reuses the exact `[scriptblock] $Invoker` seam and `[pscustomobject]@{ ExitCode; Output }` return shape already proven in `Invoke-RoutingContractValidation` (`validate-orchestrator-output.ps1`), rather than inventing a new dependency-injection pattern — directly satisfying both spec.md's explicit design mandate and the repo's "smallest seam" design-seam ordering.
- The new decision branch is inserted at exactly the documented point (after Case C, before the five receipt checks) without reordering or altering any existing Case A/B/C/receipt-check logic; this is independently confirmed by this review's own diff inspection, and matches the AC #9 requirement that the hook's `exit 0`/JSON-`permissionDecision` contract remains unchanged for all existing cases.
- Defensive property-existence checks (`$result.PSObject.Properties.Name -contains 'ExitCode'`/`'Output'`) before casting avoid unhandled exceptions if a caller's `$Invoker` returns an unexpected shape — a small but meaningful robustness choice not strictly required by the spec.
- The 500-line file-size pressure was handled correctly: rather than silently exceeding the cap, the implementation trimmed comment verbosity first (per spec's own mitigation guidance) and only split the growing test file into a sibling file once trimming was exhausted, matching the established `PoshQC.Tests.ps1`/`PoshQC.Comprehensive.Tests.ps1` split precedent.

#### API and safety notes

- `Invoke-OrchestratorStatePreflight` is `[CmdletBinding()]`-decorated with `[OutputType([hashtable])]` and named, defaulted parameters (`$CheckpointPath`, `$Invoker`), consistent with the "advanced functions" and "prefer keyword-style parameters with defaults" repo conventions.
- No new global mutable state is introduced; `$script:OrchestratorStateCheckpointPath` follows the exact pattern already established by `$script:PrContextArtifactPath` in the same file.
- The subprocess invocation (`python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state $Path --require-complete`) uses parameterized argument passing, not string interpolation into a shell command line — no command-injection surface introduced.

#### Error handling and logging

- The hook's existing `try/catch` → `exit 1` path remains reserved exclusively for malformed `CLAUDE_TOOL_INPUT`, unchanged by this feature; a missing or invalid checkpoint is correctly treated as a policy decision (`deny` via JSON), not a hook error, matching spec's explicit boundary requirement.
- The block-reason text summarizes the validator's own stderr/stdout for operator diagnosis (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary>`), consistent with the existing five receipt-check reason codes' diagnostic style.

---

## Test Quality Audit

Toolchain-stage evidence (format, lint, test-pass) is documented with `Timestamp:`/`Command:`/`EXIT_CODE:`/`Output Summary:` in every `evidence/qa-gates/*.md` and `evidence/regression-testing/*.md` file inspected, and the 53-passed/0-failed test claim is independently corroborated by this review via `artifacts/pester/pester-junit.xml` (`tests="53"`, matching test names for both the pre-existing and new test files). The coverage-percentage claims in the same evidence set are not independently corroborated — see Findings Table (Major).

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` — new sibling suite; read in full. All 4 outcome branches of `Invoke-OrchestratorStatePreflight` are directly seam-tested; both new hook-level block scenarios are mocked-wrapper tested; one real-subprocess end-to-end test exercises the full stack.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` diff — confirmed only additive `Mock -CommandName Invoke-OrchestratorStatePreflight` lines were inserted into 10 `BeforeEach` blocks; no existing assertion text was altered.
- `artifacts/pester/pester-junit.xml` — independently parsed by this review; confirms `tests="53"` and lists all 7 new test names under the correct file.
- `evidence/regression-testing/phase2-expect-fail-run.md` — confirms the required fail-before evidence (2 new tests failing against the unmodified hook with `CommandNotFoundException: Could not find Command Invoke-OrchestratorStatePreflight`, 46 pre-existing tests still passing).
- `artifacts/pester/powershell-coverage.xml` — inspected directly; does not corroborate the coverage claims (see Findings Table).

### Quality assessment prompts

- **Determinism:** Mocked-seam and direct-seam tests are fully deterministic. The new end-to-end test is coupled to mutable repository state (see Findings Table, Minor).
- **Isolation:** Each new `It` targets a single function or a single decision branch; no test asserts on more than one behavior.
- **Speed:** No evidence of slow tests; 53 tests reported passing in a single Pester run.
- **Diagnostics:** `Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'` and similar assertions produce specific, actionable failure output; inline comments explain non-obvious seam/mocking choices for future maintainers.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No secrets, tokens, or credentials introduced; reviewed full diff of the hook and its mirrors. |
| No unsafe subprocess or command construction | ✅ PASS | `& python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state $Path --require-complete 2>&1` uses parameterized invocation, not string-built shell commands; `$Path` is a repo-relative constant, not attacker-controlled input. |
| Input validation at boundaries | ✅ PASS | The new function does not parse untrusted external input beyond the pre-existing `CLAUDE_TOOL_INPUT` handling (unchanged); defensive property checks guard against unexpected `$Invoker` return shapes. |
| Error handling remains explicit | ✅ PASS | Missing/invalid checkpoint is explicitly modeled as `HasErrors = $true` with a diagnostic `ErrorText`, not swallowed or silently defaulted to allow. |
| Configuration / path handling is safe | ✅ PASS | `$script:OrchestratorStateCheckpointPath` is a fixed, repo-relative constant; no path concatenation from untrusted input, no path-traversal surface. |

---

## Research Log

No external research was required for this review. All findings are grounded in direct inspection of the branch diff (`git diff b1b55c3ddbb38c6f49a0e5e9d2c757ca70ae13f7..HEAD`), the feature's own evidence artifacts under `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/`, and canonical toolchain artifacts under `artifacts/pester/`.

---

## Verdict

The hook logic, mirror-parity handling, and the four AC-named documentation updates are implemented correctly and are independently verifiable by direct inspection — this is a well-scoped, well-tested change at the code level. The change is not yet ready for the normal PR flow as-is because the mandatory coverage-artifact verification cannot be completed from canonical evidence, and two documentation surfaces outside the PR's own file list continue to make the exact kind of false CI-enforcement claim this issue exists to eliminate. Both gaps are addressable without touching the core hook logic: regenerate the coverage artifact with a correctly-configured Pester run, and correct (or explicitly, trackedly defer) the two stale documentation references. Once those two items are resolved, this reviewer would expect a **Go** recommendation on re-review.
