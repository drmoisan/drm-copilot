# Code Review: orchestration-state-contract-divergences (#412) — Re-review R4 (post remediation cycle 1)

---

**Review Date:** 2026-07-25
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412`
**Feature Folder Selection Rule:** Sole active feature folder whose suffix matches the issue number (412) in the branch name; also the folder holding all changed scoping docs.
**Base Branch:** `main` (merge base `009808510363081d0db7684f7b555f2ded4b0b7c`, tip of `origin/main`)
**Head Branch:** `bug/orchestration-state-contract-divergences-412` (head `bfb73c75fafde8c1896f954f29473e1d23f12213`, seven commits)
**Review Type:** Re-review after remediation cycle 1 (`remediation-inputs.2026-07-25T19-30.md` / `remediation-plan.2026-07-25T19-30.md`); scope is the full branch diff, not the remediation delta
**Prior Review:** `code-review.2026-07-25T19-14.md` (Go; 0 Blocking, 1 Major CR-1, 1 Minor CR-2, 3 Info)

---

## Executive Summary

This re-review confirms that remediation cycle 1 closed the single substantive finding from the prior review and introduced no regressions. The prior Major finding CR-1 — the PowerShell portable PR-creation-readiness gate failing open on `step6_status: "blocked_remediation_loop_limit"`, elevated to Blocking by the orchestrator on self-introduced-fail-open grounds — is **confirmed closed**. The readiness loop in `Get-OrchestratorStatePrCreationReadinessError` now tests membership in `@('pending', 'blocked', 'blocked_remediation_loop_limit')`, matching the Python gate's `PR_CREATION_BLOCKING_STEP_STATUS` set element-for-element, and the function's `.DESCRIPTION` was corrected to state the actual blocked set (resolving the docstring contradiction called out in the remediation inputs).

Closure was verified by this reviewer with independent behavioral probes, not only by reading the diff: `Test-OrchestratorStatePrCreationReadiness` on a checkpoint recording a halted remediation loop returns ExitCode 1 with output byte-identical to the Python gate's error string (`Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.`), on both the root module and the resources byte mirror; the probe output contains no base-presence error, proving `blocked_remediation_loop_limit` remains plain-valid on `step6_status` (no regression of the divergence-1 fix); `pending` and `blocked` still block; a clean checkpoint passes. The remediation's non-documentation surface is exactly the three files authorized by the remediation inputs (`OrchestratorState.psm1`, its byte mirror, `OrchestratorState.Tests.ps1`); zero Python and zero TypeScript files changed in the cycle; `$script:VALID_STEP_STATUS` and `$script:STEP_SPECIFIC_EXTRA_STATUS` are untouched by the remediation diff; both mirror pairs compare byte-identical; and the module dropped from 498 to 497 lines, easing (marginally) the prior Minor finding CR-2.

The whole-branch audit was re-executed: PSScriptAnalyzer 0 findings and formatter idempotence on all 7 changed PowerShell files, direct Pester 105/105 (changed suites plus the unmodified epic-merge-gate regression witness), targeted pytest 94/94 with Black/Ruff/Pyright clean, ESLint/Prettier/TSC clean, and the full Jest suite 168 suites / 2035 tests green under the documented dot-directory `--testMatch` override. Coverage evidence at the post-remediation HEAD shows no regression anywhere; the one command added by the remediation membership test is itself covered by the new Pester case (`OrchestratorState.psm1` commands 96.64% → 96.67%).

**Findings delta versus prior review:** CR-1 closed. CR-2 remains Minor (497/500 lines — headroom improved by one line but still near the limit). CR-3, CR-4, CR-5 remain Info, all pre-existing or environmental, dispositioned in the remediation inputs as out of scope for this branch.

**PR readiness recommendation:** **Go** — zero Blocking, zero Major. All acceptance-criteria-bearing behavior is delivered and verified; the sole open spec criterion (PR-body statement) is structurally satisfiable only at PR authoring and its text is prepared.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Closed (was Major, elevated Blocking) | `.claude/lib/orchestrator-state/OrchestratorState.psm1` (+ resources byte mirror) | `Get-OrchestratorStatePrCreationReadinessError`, lines 314–321 | CR-1 CLOSED: the readiness loop now blocks `@('pending', 'blocked', 'blocked_remediation_loop_limit')` on steps 5–8, matching `PR_CREATION_BLOCKING_STEP_STATUS` in `_orchestrator_state_pr_creation_readiness.py` (lines 63–67) element-for-element; the `.DESCRIPTION` states the blocked set accurately; a Pester case asserts rejection via the public entry point while plain acceptance is separately pinned. | None. Confirmed closed. | The pushed-down consumer readiness path no longer fails open on the state this branch made representable; PS and PY produce byte-identical error strings (reviewer probe). | Reviewer probes: PS root ExitCode 1 / PY `['Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.']` — identical strings; mirror probe identical; `pending`/`blocked`/`completed` → 1/1/0. Fail-before/pass-after evidence: `evidence/regression-testing/remediation1-fail-open-probe-before.md`, `remediation1-fail-open-probe-after.md`, `remediation1-new-test-expect-fail.md`, `remediation1-new-test-pass-after.md`. |
| Minor | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | whole file | CR-2: File is at 497 of the 500-line limit (was 498; the remediation's `.DESCRIPTION` reflow net-removed one line). The next edit of any size will still force a split under time pressure. | When a future change touches this module, extract the readiness/preflight helpers into a sibling module in the same change (mirroring the Python side's `_orchestrator_state_step_status.py` split at the 500-line boundary). | Proactive structure work is cheaper than a forced split inside an unrelated fix. Not a policy violation (limit not exceeded). | `wc -l` = 497 (reviewer, this session) |
| Info | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | `Get-OrchestratorStateBasePresenceError` and the new readiness membership test | CR-3: PowerShell `-contains` comparisons are case-insensitive by default, so the portable module accepts e.g. `PASSED`/`BLOCKED_REMEDIATION_LOOP_LIMIT` where Python and TypeScript reject them. The remediation's array `-contains` inherits this pre-existing module-wide convention; the branch does not widen the difference (case-insensitive matching in the readiness gate is fail-closed — it blocks more, not less). | No action for this branch. If exact-case parity is ever required in the portable path, switch to `-cnotcontains`/`-ccontains` module-wide in one change. | Cross-language strictness difference exists in the fallback path only; the Python validator is authoritative where it ships. Dispositioned out of scope in `remediation-inputs.2026-07-25T19-30.md`. | Module inspection; pre-existing pattern for `$script:VALID_STEP_STATUS` |
| Info | `extensions/drm-copilot/test/**` | n/a | CR-4: `.claude/rules/typescript.md` names Vitest as the unit-test framework, but the extension's entire pre-existing suite (168 files) is Jest, and the changed tests correctly follow the established Jest convention. | Pre-existing repo-level rule/practice inconsistency; resolve at the rules level, not in this branch (rule files must not be modified). | Recorded so the inconsistency stays on record; unchanged from the prior review. | `extensions/drm-copilot/package.json` (`run-jest.cjs`); rule file `.claude/rules/typescript.md` |
| Info | `extensions/drm-copilot/jest.config.cjs` | `testMatch` | CR-5: Environmental only — in this dot-directory worktree the configured `testMatch` glob matches nothing (`No tests found`, exit 1); the `--testMatch "**/test/**/*.test.ts"` override discovers all 168 suites, which pass (2035/2035, reviewer full re-run this session). Config deliberately unmodified; CI checkouts are unaffected. | No action. Evidence artifacts record both invocations with real exit codes. | Prevents mis-reporting an environmental failure as a branch defect. | Reviewer full override run this session: 168 suites / 2035 tests, exit 0 |

Open findings: **0 Blocking, 0 Major, 1 Minor, 3 Info.**

---

## Remediation Cycle 1 Verification Detail

Every constraint in `remediation-inputs.2026-07-25T19-30.md` was checked:

1. **Blocked-set extension with byte-identical message** — DELIVERED. The message uses the existing interpolation `"Checkpoint PR-creation readiness validation failed: $key is $($field.Value)."`; probe output matches the Python string byte-for-byte.
2. **`.DESCRIPTION` accuracy** — DELIVERED. Now reads "steps 5-8 must not be pending, blocked, or blocked_remediation_loop_limit".
3. **Byte mirror in the same batch** — DELIVERED. `cmp` exit 0 on both pairs; `test_push_down_claude_resource_contracts.py` (unmodified) green in the reviewer's 94/94 run and the executor's 2123/2123 run.
4. **Pester coverage** — DELIVERED. `returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit` (readiness rejection through the public entry point, `Should -BeLike` on the exact message) plus the pre-existing plain-mode acceptance case `accepts step6_status value blocked_remediation_loop_limit` and the non-owning-key matrix including the value; `pending`/`blocked` rejection cases pre-existed and still pass.
5. **File budget and 500-line cap** — RESPECTED. 2 production files + 1 test file; module at 497/500.
6. **Constants frozen** — RESPECTED. The `81f3df3f..HEAD` diff on the module contains only the readiness-function hunks; `$script:VALID_STEP_STATUS` (8 members) and `$script:STEP_SPECIFIC_EXTRA_STATUS` (step6: 1 value, step9: 3 values) are byte-unchanged.
7. **Do-not-modify list** — RESPECTED. `git diff --name-only 81f3df3f..HEAD` contains no Python, no TypeScript, no config, no hook, no rule, no skill, and no `jest.config.cjs` entries; the whole-branch diff was separately re-verified to leave the full deliberately-unchanged set at zero diff against the merge base.

---

## Implementation Audit (whole branch, re-verified at HEAD)

### Python

- Per-key additive map (`STEP_SPECIFIC_EXTRA_STATUS`) layered on the untouched shared `VALID_STEP_STATUS` literal (re-verified at lines 93–102 of `validate_orchestrator_state.py`); rejection matrices exhaustive; completion blocklist deliberately omits `passed` with an explanatory comment; readiness blocklist carries the halted-loop value with a rationale comment. No `Any`, no suppressions, full docstrings. Pyright clean on all four changed production files (reviewer re-run).
- `compute_complexity_floor` intersects with `FLOOR_SIGNAL_NAMES`; docstrings state no caller-side pre-filtering; zero file-I/O; 133 lines. Truth-table probe (7 cases) matches PowerShell exactly.

### TypeScript

- Untouched by the remediation cycle; re-inspected at HEAD. `STEP_SPECIFIC_EXTRA_STATUS` map (step6/step9), `COMPLETION_BLOCKING_STEP_STATUS` five-member set matching Python exactly, message templates byte-identical (`Checkpoint has invalid ${key}: ${String(value)}`, `Checkpoint completion validation failed: ${key} is ${String(value)}.`). ESLint/Prettier/TSC clean; targeted 34/34 and full 2035/2035 Jest green (reviewer re-runs this session).

### PowerShell

- The remediation edit is minimal and idiomatic: one membership test plus comment/help updates inside the existing fail-closed loop. PSScriptAnalyzer 0 findings; formatter idempotent; both mirrors byte-identical. The public entry point `Test-OrchestratorStatePrCreationReadiness` (consumed by the pushed-down `enforce-pr-author-skill` hook when the Python validator is not importable) now refuses exactly the states the Python gate refuses.

---

## Test Quality Audit

- The remediation test asserts through the public hashtable contract (`ExitCode`/`Output`) rather than the private function, which is the correct seam for the pushed-down consumer behavior being protected, and it isolates the readiness gate by building an otherwise-clean checkpoint so the single mutated field is the only error source.
- Fail-before discipline was maintained in the cycle: `remediation1-new-test-expect-fail.md` records the new test failing (exit 1) against the pre-fix module, and `remediation1-fail-open-probe-before.md` records the pre-fix ExitCode 0 fail-open behavior; the after-artifacts record the inverse. Direct Pester runs use `-PassThru` with an explicit exit branch (a bare `Invoke-Pester` exits 0 even on failures) and avoid `-CI` (which would overwrite the tracked `testResults.xml`).
- Whole-branch test quality is unchanged from the prior review's assessment (exhaustive owning/non-owning matrices in Python and Jest, live-config-driven parity tests in both languages, compatibility-consequence pin, epic-merge-gate regression witness re-run green 30/30 inside this reviewer's 105/105 Pester run).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection (full branch + remediation delta): constants, validation logic, tests, docs only. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess/`Invoke-Expression`/`eval` additions in either cycle. |
| Input validation at boundaries | ✅ PASS | The one fallback-path gap identified in the prior review is now closed; PowerShell readiness parity with the Python gate verified by probe. |
| Error handling remains explicit | ✅ PASS | Non-raising collector contract preserved in all three languages; no silent catches added. |
| Configuration / path handling is safe | ✅ PASS | No runtime file reads added; embedded constants pinned by static parity tests; mirrors byte-identical. |

---

## Research Log

No external research was required. All evidence derives from the branch diff (`main...HEAD` and the remediation delta `81f3df3f..HEAD`), the feature folder (spec, plans, remediation inputs, evidence tree), the regenerated PR-context artifacts, reviewer-executed toolchain runs, and reviewer behavioral probes executed with `PYTHONPATH=. poetry run python` from the worktree root (avoiding the documented stale-installed-package import pitfall) and `pwsh` module imports from the worktree.

---

## Verdict

Remediation cycle 1 is complete and correct: CR-1 is confirmed closed with cross-language byte-identical gate behavior, no plain-mode regression, frozen constants, byte-identical mirrors, and dedicated fail-before/pass-after test evidence. The whole branch remains in the state the prior review assessed, now without the fail-open gap: both divergences fixed exactly as specified, all toolchain gates green at the post-remediation HEAD, coverage at or above every baseline, and the deliberately-unchanged file set verified untouched. Zero Blocking and zero Major findings remain; the one Minor (497/500-line headroom) and three Info items require no action on this branch.

Recommendation: **Go** — proceed to PR authoring; the PR body must include the prepared divergence-2 backward-compatibility statement (`evidence/other/pr-body-backcompat-statement.md`) to satisfy spec AC #24.
