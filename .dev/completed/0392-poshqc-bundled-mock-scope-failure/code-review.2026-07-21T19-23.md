# Code Review: PoshQC Bundled Mock-Scope Failure Fix (#392)

**Review Date:** 2026-07-21
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/`
**Feature Folder Selection Rule:** Supplied by the caller; confirmed as the only active feature folder in the branch diff and its suffix matches issue #392.
**Base Branch:** `main` (merge-base `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`)
**Head Branch:** `drm-copilot-wt-2026-07-21T17-18` @ `92bf1f29659da829e4cbf4d0bcc4af2182d87b06`
**Review Type:** Initial review

**Template source note:** MCP tools are unavailable in this session; the `code-review-template` asset was read directly from its bundled source file `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, the same file the resolver returns.

---

## Executive Summary

This branch fixes issue #392: 31 Pester failures (`RuntimeException: Mock data are not setup for this scope`) that occurred only when the PoshQC suite ran through the bundled entry point. The confirmed root cause (spec.md experiments E1-E4) is that the bundled path hosted the `Invoke-Pester` run inside the imported PoshQC module's session state. The fix is confined to the two default seam scriptblocks of `Invoke-PoshQCTest` in `PoshQC.Testing.psm1` (and its byte-identical bundled mirror): `$EnsureModule` now imports with `-Global`, and `$InvokePester` installs a temporary unbound global trampoline function around the Pester call with try/finally removal. Supporting changes: the changed module was added to the Pester coverage measurement set, a 3-test regression file was added, and 3 pre-existing Koverage tests received an explicit injected `-InvokePester` stub so their module-scope mocks continue to intercept.

Evidence reviewed: the full branch diff (`artifacts/pr_context.appendix.txt`), 20 executor evidence artifacts, and independent reviewer re-runs of the formatter (0 diffs), analyzer (0 findings), full suite (1332 passed / 0 failed / 9 skipped, exit 0), and the previously failing bundled-manifest reproduction (now 0 failed, no trampoline leak). Implementation quality is high: the change is minimal, well-commented on the non-obvious points, backward compatible for all injected-seam callers, and regression-tested against the exact default scriptblocks via AST extraction.

**What changed:**
6 code files: 2 production files x 2 parity mirrors (`PoshQC.Testing.psm1` seam defaults; `pester.runsettings.psd1` coverage path addition), 1 new test file (100 lines, 3 tests), 1 existing test file (+3/-3 seam injections). Plus 32 feature-folder Markdown docs/evidence files.

**Top 3 risks:**
1. Modified-file line coverage (76.41% for `PoshQC.Testing.psm1`) is below the 85% policy floor — the only merge blocker; the uncovered lines are pre-existing seam bodies newly added to measurement, not the fix itself.
2. The MCP `run_poshqc_test`/`run_poshqc_suite` gates will keep reporting the pre-fix failures until the extension is repackaged from merged main (stale bundled snapshot in the installed extension); post-merge verification is required.
3. The trampoline installs a temporary global function; a crash between `New-Item` and `finally` in a persistent host would leave it defined. The try/finally plus the leak-asserting regression test and the reviewer-observed `TRAMPOLINE-LEAK: False` make this residual risk low.

**PR readiness recommendation:** **Needs Revision** — no code defect found, but the modified-file coverage floor (85%) is unmet at 76.41%, which is a policy FAIL and remediation trigger.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | whole file (46 uncovered lines: 98, 291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369, 401-403, 410-415, 417-420, 423-424, 427-428, 433-439) | Modified-file line coverage 76.41% (149/195), below the 85% floor for modified files and below the 80% remediation trigger | Add unit tests for the uncovered default seam bodies (Koverage copy/summary/logger seams); keep new test files under 500 lines; mirror-safe (test-only change) | Uniform coverage gate (`.claude/rules/quality-tiers.md`); feature-review workflow step 5 flags FAIL and step 8 triggers remediation | `artifacts/pester/powershell-coverage.xml` per-file counters, reviewer-parsed 2026-07-21T19-23; `evidence/qa-gates/coverage-delta.2026-07-21T18-01.md` |
| Minor | `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | whole file (766 lines) | File exceeds the 500-line limit; pre-existing at the merge base (766 lines there too; this diff is +3/-3 net zero) | Track decomposition as follow-up debt; do not expand this file further | 500-line limit applies to test code; not introduced by this branch, so non-blocking here | `wc -l` at head = 766; `git show 193864d8:<file> | wc -l` = 766 |
| Info | `extensions/drm-copilot` (installed copy in the main repo) | n/a | `mcp__drm-copilot__run_poshqc_test` exits 33 because the installed extension loads a pre-fix bundled `PoshQC.Testing.psm1` snapshot (0 trampoline references) instead of this worktree's fixed copy (3 references) | After merge, repackage the extension from main and re-run the MCP test gate to confirm exit 0 | Environmental staleness, not a branch defect; the authoritative worktree run passes (exit 0, 0 failed) | `evidence/qa-gates/final-test-coverage.2026-07-21T18-01.md`; reviewer `grep -c Invoke-PoshQCPesterRun` on installed vs worktree copies (0 vs 3) |
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 262-280 | Deliberate temporary global function (`Invoke-PoshQCPesterRun`) — an intentional exception to the avoid-global-state rule, required by the root cause (global-session-state hosting) | None; keep the try/finally and the leak-asserting test in place | Justified, documented in code comments, removed in `finally` via the `Function:\` provider path (the `function:global:` path silently no-ops on `Remove-Item`), and leak-tested | Diff hunk; regression test `PoshQC.TestingSeamDefaults.Tests.ps1`; reviewer repro output `TRAMPOLINE-LEAK: False` |

No Blockers. One Major finding (coverage floor) drives the remediation cycle.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix lands at exactly the seam layer the root-cause analysis identified (`Invoke-PoshQCTest` defaults), leaving every injected-seam caller, parameter contract, and downstream artifact shape untouched.
- The trampoline construction is careful about the two subtle PowerShell behaviors involved: `[scriptblock]::Create` produces an unbound scriptblock (so the global function is not bound to the module's session state), and removal uses `Remove-Item -Path 'Function:\...'` because a `function:global:`-qualified path silently no-ops on `Remove-Item`. Both are explained in comments citing issue #392.
- Parity discipline: both changed production files are byte-identical to their bundled mirrors (reviewer-verified with `cmp`), and the Python parity gate passed.
- The coverage-settings addition follows the established per-issue convention already present in `pester.runsettings.psd1` and carries a rationale comment.

#### API and safety notes

- No public API surface change; `Invoke-PoshQCTest`/`Invoke-PoshQCSuite` signatures unchanged. Analyzer: 0 findings on all 6 changed files. Approved verb used for the new global function name.
- `-ErrorAction SilentlyContinue` on the cleanup `Remove-Item` is a narrow idempotency guard on a best-effort teardown, not error suppression on the run path.

#### Error handling and logging

- Throw-on-missing-Pester, throw-on-missing-settings, and unresolved-scan-folder behavior preserved (asserted by the new negative test and the existing suite). No logging surface changed; the `$Logger` seam and summary output are untouched.

---

## Test Quality Audit

Coverage, regression, and end-to-end evidence are all present. The single gap is the per-file coverage floor on the modified module (Major finding above).

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` — 3 focused regression tests; notably extracts the real `$InvokePester` default via the command AST so the assertions exercise the shipped default rather than a re-typed copy; asserts trampoline lifecycle, PassThru integrity, `-Global` import, and the unavailable-module throw. `AfterEach` removes both the trampoline and the stub global `Invoke-Pester`.
- `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (+3/-3) — the 3 Koverage tests now inject a plain `-InvokePester` stub so their module-scope `Mock Invoke-Pester` intercepts as before; every original assertion retained (verified in the diff).
- `evidence/regression-testing/fail-before.e4-bundled.2026-07-21T18-01.md` and `pass-after.*.2026-07-21T18-01.md` — fail-before/pass-after pairing for direct, bundled-narrowed, and full bundled runs.
- Reviewer independent re-runs (2026-07-21T19-23): full suite exit 0 (1332/0/9); bundled-manifest E1b path exit 0 (98/0/7) with `TRAMPOLINE-LEAK: False`.

### Quality assessment prompts

- **Determinism:** No nested real Pester runs, no external processes, no wall-clock/random dependence; module-collision guard makes import state deterministic. Reviewer counts matched executor counts exactly across runs.
- **Isolation:** One seam behavior per `It`; module-scope mocks confined to `InModuleScope PoshQC`.
- **Speed:** New file executes in under 300ms; full suite 45.72s.
- **Diagnostics:** Expected-throw messages are asserted with specific wildcards; boolean assertions target named state (`TrampolinePresentDuringCall`).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: no credentials, tokens, or `.env` content in any changed file. |
| No unsafe subprocess or command construction | PASS | The only dynamic code is `[scriptblock]::Create` over a compile-time constant string; no user input reaches it. No `Invoke-Expression`. |
| Input validation at boundaries | PASS | Existing throws for missing Pester/settings/scan folders preserved and tested. |
| Error handling remains explicit | PASS | try/finally around the Pester call; no new catch-alls on the run path. |
| Configuration / path handling is safe | PASS | Settings change is one additional relative repo path in `CodeCoverage.Path`; test paths resolve from `$PSScriptRoot`. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, the feature-folder evidence artifacts, repository policy files, and reviewer-executed commands in this worktree.

---

## Verdict

The implementation is correct, minimal, and well-evidenced: the reviewer independently reproduced the previously failing bundled path and confirmed it now passes with no global-state leak, the full 1341-test suite is green, analyzer and formatter are clean, and mirror parity holds byte-for-byte. No production-code defect was identified.

The change is not ready for normal PR flow yet because the modified `PoshQC.Testing.psm1` sits at 76.41% line coverage against the 85% modified-file floor (below the 80% remediation trigger). This is a test-addition remediation, not a code fix: cover the pre-existing seam bodies that entered the measured set with this change. Remediation inputs: `remediation-inputs.2026-07-21T19-23.md`; plan target: `remediation-plan.2026-07-21T19-23.md`. After that cycle, the branch should be ready for merge, with a post-merge follow-up to repackage the extension and re-run the MCP test gate.
