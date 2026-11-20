# Code Review: orchestrator-completion-hook-false-block (#413)

**Review Date:** 2026-07-25
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413`
**Feature Folder Selection Rule:** Single active feature folder whose suffix matches the issue number (413) in the branch name.
**Base Branch:** `main` (merge-base `72126592`)
**Head Branch:** `bug/orchestrator-completion-hook-false-block-413` (head `60994855`)
**Review Type:** Initial review

**Template source note:** Created from the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` — the exact file the MCP `code-review-template` selector resolves — because the MCP tool surface is unavailable in this delegated environment.

---

## Executive Summary

This branch fixes a broken-closed completion gate. `Invoke-RoutingContractValidation` in `.claude/hooks/validate-orchestrator-output.ps1` previously computed `$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))`. Because the default invoker captures the Python validator with `2>&1` and the validator prints `orchestrator-state validation passed: <path>` to stdout on a clean pass, the second disjunct fired on every success and the hook blocked every DONE claim with the validator's own success line quoted as the error. The fix keys the decision on the exit code alone, carries `ErrorText` through unchanged, corrects the `.DESCRIPTION` docstring and inline comment, and resyncs the bundled pushed-down copy byte-identically. The test file replaces the one test that asserted the defect and adds unit-level and end-to-end ALLOW regressions plus an exit-2 fail-closed regression.

The scope is small (three code/test files, +68/-9 across them) and the implementation quality is high: the fix converges on the pattern already used by `Invoke-OrchestratorStatePreflight`, every seam and return contract is preserved, and the safety-critical claim (exit code is a complete failure discriminator) was verified by this reviewer against the validator source rather than accepted from the spec.

**What changed:**
- `.claude/hooks/validate-orchestrator-output.ps1`: decision line 232 now `$hasErrors = ($exitCode -ne 0)`; docstring lines 167-176 and comment lines 228-231 corrected.
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`: byte-identical resync (SHA-256 `5e4bfa47…3183b` on both copies, reviewer-verified).
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`: +40/-3; defect-asserting test replaced with an exit-2 fail-closed test; two new issue-413 ALLOW regressions.

**Does the fix weaken the gate? No — verified, not assumed.** `scripts/dev_tools/validate_orchestration_artifacts.py` `main()` (lines 344-352) has exactly two terminal paths: errors are each printed to `sys.stderr` and the function returns 1; otherwise the success line is printed to stdout and the function returns 0. There is no path that emits error text with exit 0. Argparse misuse exits 2; an unhandled exception (e.g., `OSError` from `_read_text`) propagates and the process exits non-zero with a stderr traceback. Every abnormal outcome is therefore non-zero, and the fixed decision blocks on every non-zero exit — confirmed by the new exit-2 unit test and by this reviewer's live run against the mid-run checkpoint (exit 1, `ROUTING_CONTRACT_BLOCKED:` with validator stderr carried in the message). The removed disjunct provided no real defense in depth: the only input it ever fired on in practice was the success line, which inverted the gate.

**Block-reason discrimination verified.** The `model_routing_receipts|complexity_assessments` regex in `Invoke-OrchestratorOutputValidation` (lines 330-333) is textually unchanged; it evaluates only when `HasErrors` is true, where `ErrorText` contains the validator's stderr lines exactly as before. `validate-orchestrator-output.model-routing.Tests.ps1` passes unmodified (reviewer re-run).

**Portable fallback verified fail-closed.** `Test-OrchestratorStateCompletionReadiness` returns `@{ ExitCode = 0; Output = '' }` on success (line 240) and `ExitCode = 1` on both error paths (lines 227, 237); the module is untouched by the diff and its 7 tests pass (reviewer re-run). Exit-code-only discrimination is therefore complete for both invoker branches.

**Top 3 risks:**
1. A future Python-validator regression that printed errors while exiting 0 would no longer be caught by the hook. This failure mode does not exist in the current CLI, the Python test suite pins return codes, and the residual risk was explicitly accepted in the spec — consistent with the already-accepted posture of `Invoke-OrchestratorStatePreflight`.
2. Bundled-copy drift. Mitigated by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (reviewer re-run, 7/7 pass) which fails on any byte difference.
3. The PowerShell toolchain emits no branch-coverage metric, so the 75% branch gate is unmeasurable for this and every PowerShell change (pre-existing toolchain limitation, adjudicated in the policy audit; non-blocking follow-up recommended).

**PR readiness recommendation:** **Go** — all findings are informational; the fix is minimal, pattern-consistent, independently re-verified end-to-end in both directions, and loses no real enforcement.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` | Coverage instrumentation is an opt-in allowlist rather than a full production glob; the bundled hook mirror under `extensions/` is not instrumented (it is covered transitively via byte parity with the instrumented repo copy). | No action for this branch; the changed hook is instrumented. Consider a follow-up to move toward glob-based instrumentation. | Pre-existing repo-wide configuration, unchanged by this diff; noted for transparency against the coverage-exclusion policy's intent. | File inspected; `git diff 72126592..HEAD` shows no change to it. |
| Info | `artifacts/pester/powershell-coverage.xml` | report counters | Pester CoverageGutters/JaCoCo output contains no BRANCH counter (INSTRUCTION/LINE/METHOD/CLASS only; per-line `mb`/`cb` uniformly zero), so the 75% branch gate is unmeasurable for PowerShell. | File a non-blocking tooling issue to evaluate a branch-capable coverage path. | Pre-existing toolchain limitation with repository precedent (#272); adjudicated as an accepted exception in the policy audit. | Reviewer `grep`/parse of the XML: 0 BRANCH counters. |
| Info | `docs/features/potential/promoted/2026-07-25-orchestrator-completion-hook-false-block.md` | n/a | The branch adds the promotion record outside the three Files-In-Scope code files and the feature folder. | None — this is the standard feature-promotion lifecycle artifact, added in the docs commit `a587c0c6` before execution began. | Transparency for the AC13 "no unintended changes" evaluation; it is intended lifecycle content, not scope creep. | `git diff --name-status 72126592..HEAD`; `evidence/qa-gates/diff-scope-audit.2026-07-25T17-36.md`. |

No Blockers, Major, Minor, or Nit findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is the minimal correct change: one boolean expression, with the documentation (docstring and inline comment) corrected in the same hunk so the code and its stated contract cannot drift apart.
- The corrected docstring explains *why* output text must not influence the decision (the 2>&1 capture folds the stdout success line into `Output`), which prevents a future maintainer from "hardening" the decision back into the defect.
- Convergence on the established repository pattern (`Invoke-OrchestratorStatePreflight` uses the identical shape, with a test locking in that an exit-0 success line does not block) rather than inventing a new mechanism such as success-line string matching.
- The bundled resync was done byte-for-byte and is locked by an existing parity pytest, so the two copies cannot silently diverge.

#### API and safety notes

- The `$Invoker` seam signature (`param($Path, $Type)` returning `ExitCode`/`Output`) and the `{ HasErrors, ErrorText }` return contract are unchanged; every existing seam-injecting test compiles and passes unmodified.
- Fail-closed direction preserved and strengthened in the test suite: non-zero exit blocks (existing test), exit 2 blocks (new test), and the defensive defaults (`$exitCode = 0` only when the result object actually carries an `ExitCode` property) are unchanged.
- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` remain in force at script scope.

#### Error handling and logging

- On genuine failure, `ErrorText` carries the validator's combined captured output unchanged, so the `MODEL_ROUTING_BLOCKED:`/`ROUTING_CONTRACT_BLOCKED:` message content is byte-equivalent to the pre-fix behavior — confirmed live by this reviewer (the block message quoted all twelve validator stderr lines verbatim).
- No error is silently swallowed: the only behavioral delta is that a clean validator pass no longer blocks.

---

## Test Quality Audit

The test delta is precisely scoped to the defect: the one test that asserted the wrong behavior was replaced in place (preserving file-size headroom), and the replacement suite pins the corrected behavior at both the unit seam and the end-to-end entry point, plus the previously untested exit-2 boundary.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` — 486 lines (cap 500); new tests use AAA structure with rationale comments; reviewer re-run passes.
- `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` — unmodified; locks block-reason discrimination; reviewer re-run passes.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` — unmodified; locks portable-fallback fail-closed behavior; reviewer re-run passes.
- `evidence/regression-testing/fail-before.2026-07-25T17-14.md` — genuine fail-before proof: exactly the two new ALLOW tests failed against the unfixed hook (25 passed / 2 failed), with an honest note that the Pester invocation form returns process exit 0 and the run summary is the authoritative signal.
- `evidence/regression-testing/pass-after.2026-07-25T17-17.md` — 27/27 after the fix.
- `evidence/qa-gates/hook-e2e-allow.2026-07-25T17-19.md` — end-to-end ALLOW through the real subprocess seam, plus an old-vs-new decision measurement (`OLD_hasErrors=True` / `NEW_hasErrors=False`) against real validator output; reviewer reproduced the hook run (exit 0).
- `evidence/qa-gates/hook-e2e-live-checkpoint.2026-07-25T17-36.md` — live-path fail-closed demonstration; reviewer reproduced (exit 1, `ROUTING_CONTRACT_BLOCKED:`).

### Quality assessment prompts

- **Determinism:** All stubs are in-memory scriptblocks; checkpoint content injected via `Get-CheckpointFileContent` mock; no temp files, clocks, or RNG.
- **Isolation:** Unit-level decision tests target `Invoke-RoutingContractValidation` alone; end-to-end tests target `Invoke-OrchestratorOutputValidation` with only the routing seam stubbed.
- **Speed:** 40 tests across the three affected files complete in 2.15s (reviewer-measured).
- **Diagnostics:** `Should` assertions yield expected-vs-actual output; the fail-before artifact demonstrates the failure messages identify the exact asserting line.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected; no credentials, tokens, or secret-bearing paths. |
| No unsafe subprocess or command construction | PASS | The subprocess invocation is unchanged; arguments are fixed strings plus the checkpoint path parameter — no string-interpolated command construction was added. |
| Input validation at boundaries | PASS | Payload/checkpoint validation chain in `Invoke-OrchestratorOutputValidation` unchanged; defensive property-existence checks on the invoker result retained. |
| Error handling remains explicit | PASS | Every non-zero exit blocks; block messages carry validator stderr verbatim; no catch-all added. |
| Configuration / path handling is safe | PASS | `-CheckpointPath` handling unchanged; `Test-Path -LiteralPath` used at the file boundary. |

---

## Research Log

No external research was required. All verification was performed against repository sources: the Python validator CLI (`scripts/dev_tools/validate_orchestration_artifacts.py`), the portable fallback module, the coverage XML, the diff, and live execution of the hook in both directions.

---

## Verdict

The change is ready for the normal PR flow. It is a minimal, well-documented, pattern-consistent fix to a broken-closed gate; the safety-critical discriminator claim was independently verified against the validator source; fail-closed behavior, block-reason discrimination, the seam contract, the portable fallback, and bundle byte parity were all independently re-verified by this reviewer. The three findings are informational and none requires action on this branch. This conclusion is consistent with the Findings Table and the **Go** recommendation above.
