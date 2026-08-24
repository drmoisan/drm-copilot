# Code Review: Codex PreToolUse Hook Transport Repair (#415) — Cycle-2 Re-Audit (R4)

**Review Date:** 2026-07-26
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415`
**Base Branch:** `main` (merge-base `5f24e0f6bc85f03303826746409935bb9ab94e1b` = current `origin/main`; the branch was rebased after `main` advanced 21 commits for issues #421, #422, #423, #426)
**Head Branch:** `bug/codex-pretooluse-hook-transport-415` (`d44a26ad85c0b542f51241e46a626f11585dc8ee`)
**Review Type:** Re-review after remediation cycle 2 (CI-failure finding C1, adjacent finding A1 per RD-1, sweep S1, coverage obligation R-COV)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `code-review-template` resolves; the MCP resolver tool was unavailable in this session).

---

## Executive Summary

The cycle-1 clean re-audit (`code-review.2026-07-26T13-42.md`) approved the branch with zero blockers; a subsequent CI run against that head failed one test — the branch's own config-driven integration case — because `enforce-epic-child-worktree-binding.ps1` threw a null-method exception on the detached HEAD GitHub Actions checks out for PR merge refs. Cycle 2 fixed that defect (C1), made the adjacent detached-HEAD push behavior in `enforce-epic-planning-only.ps1` deliberate per recorded decision RD-1 (A1), swept `.codex` for the defect class (S1), and brought both changed hooks into the coverage denominator (R-COV).

This re-review examined the cycle-2 delta (`21fc8c3b..d44a26ad`) hunk-by-hunk within the same full feature-vs-base scope and independently re-verified every executor claim.

**The C1 fix is minimal and correct.** `Get-CodexChildGuardLiveBranch` guards both failure modes — git exiting non-zero AND git succeeding with null/whitespace output — and returns `''` for both, which is exactly what the pre-existing `$LASTEXITCODE -ne 0` path already produced. The entrypoint passes the already-trimmed value, eliminating the throwing `.Trim()`. The decision call site is otherwise unchanged.

**The A1 fix implements RD-1 exactly as recorded, and the two behavior changes are transport corrections, not policy changes.** Verified mechanically: `git diff main...21fc8c3b -- <both hooks>` is empty, so the cycle-2 hunks are the entire branch change to these files, and they touch only the two new helper functions and the entrypoint call site. `Invoke-EpicPlanningOnlyDecision` and `Test-EpicPlanningBashAllowed` are byte-identical to `main`. The preparation-mode deny for an empty branch comes from the pre-existing `IsNullOrWhiteSpace($CurrentBranch)` check at line 150 (the push allowance is simply withheld, falling to the existing deny envelope); the dormant-mode allow comes from the pre-existing no-checkpoint guard at line 171. Genuine git failure keeps the pre-existing `EPIC_PLANNING_ONLY_BLOCKED` throw and exit 2. The prior behavior — exit 2 for a legitimate repository state — violated the spec's own transport contract (exit 2 is reserved for malformed or missing required Codex stdin); the new behavior applies the hook's existing policy to the resolved state. Both RD-1 outcomes are pinned by committed decision-layer tests.

**Independent verification performed by this review at HEAD `d44a26ad`:**
- Created a detached worktree at the committed head and piped the CI-shaped benign payload into the worktree-binding hook and the push payload into the planning-only hook: both **exit 0 with empty stdout and empty stderr** (versus exit 2 before the fix). This reproduces the executor's pass-after probe at the final committed content, with no overlay step.
- Re-ran all 10 Pester suites under `tests/scripts/codex-hooks/`: 476/476 pass (67.3s), including the config-driven integration matrix that failed in CI and the 43 new cycle-2 tests (also run in isolation: 43/43, ~1.4s).
- Re-executed the S1 sweep greps and reproduced the executor's hit inventory exactly (4 + 7 pattern hits, 8 distinct `& git` sites); spot-verified the SAFE justifications against current source, including the `Get-CodexChildGitScalar` advisory (count/whitespace check precedes `.Trim()`; launch scripts are not registered hooks).
- Parsed `artifacts/pester/powershell-coverage.xml`: repo-wide 3148/3337 = 94.34% across 41 files; worktree-binding 153/160 = 95.62%; planning-only 126/135 = 93.33%; missed-line sets match the per-line justifications in `per-file-coverage-final.2026-07-26T15-17.md` exactly; the +295/+279 denominator/numerator growth reconciles to the two newly measured files with zero previously covered lines lost.
- Verified root/bundle `.codex` byte-identity file-by-file (0 hash differences), runsettings byte-parity, config.toml zero-diff with 5 / 5 / 8 handler blocks, all changed files ≤ 500 lines, zero removed test lines in cycle 2, zero suppressions, and the parity pytests (9/9).

**Test-quality assessment of the cycle-2 suites: high.** Wrapper-seam mocks with exact signature parity and explicit `$global:LASTEXITCODE` make the detached-HEAD condition deterministic on any checkout; in-process entrypoint cases restore console readers and the full `CODEX_EPIC_CHILD_*` environment in `finally`; entrypoint assertions are deliberately environment-agnostic so they hold on both named-branch and detached checkouts (which is what lets CI itself exercise the detached arm); the push payload is kept out of the entrypoint on determinism grounds and locked at the decision layer instead — a sound trade recorded in the plan.

**PR readiness recommendation: Go.** Zero Blockers, zero Majors. Findings below are informational.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.codex/hooks/enforce-epic-planning-only.ps1` | entrypoint push path | RD-1's dormant-mode outcome means a `git push` on a detached HEAD is now allowed when no preparation checkpoint exists (previously exit 2). This is a deliberate behavior change and is correct: exit 2 never functioned as a deny (a hook error is not a policy decision), the hook's dormant contract is a no-op, and the preparation-mode deny is preserved and test-pinned. | None required. If a future policy wants pushes gated outside preparation mode, that is a new requirement, not a regression of this fix. | The decision layer is byte-identical to `main`; the reviewer traced both outcomes through the unmodified `Invoke-EpicPlanningOnlyDecision`/`Test-EpicPlanningBashAllowed` and confirmed the committed RD-1b test locks the deny reason verbatim. | `codex-detached-head-transport.Tests.ps1` RD-1b cases; reviewer detached-worktree push probe (exit 0, empty output, no checkpoint present); `remediation-plan.2026-07-26T18-10.md` RD-1 |
| Info | `tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1`, `codex-planning-only-hook.Tests.ps1` | file placement | `[P5-T1]` placed the coverage-closure cases in 2 new files without first filling the existing transport suite, whose plan-stated placement preference was "existing file first, then up to 2 new files." Headroom arithmetic verified: 344 lines used, 156 free, ~450 needed — new files were unavoidable, and keeping each hook's closure suite coherent in a single file is the better structure. | None. | Within the plan's explicit ≤ 2-new-file authorization; both files ≤ 500 lines; all cases pass; suites mirror production naming. | Reviewer line counts (353, 143); `remediation2-scope-verification.2026-07-26T15-17.md` budget table |
| Info | `.codex/scripts/epic-child-launch-runtime.ps1` | `Get-CodexChildGitScalar` (lines 29-37) | Advisory carried from the S1 sweep, not acted on: on a detached HEAD this function throws a deliberate fail-closed `EPIC_CHILD_LAUNCH_BLOCKED ... did not return one value.` message. Reviewer verified the reasoning: the count/whitespace guard runs before `.Trim()` (no null-method exception is possible), the file is a launch/resume script rather than a registered `PreToolUse` hook (no `.codex/config.toml` command references it), and epic-child launches bind to named branches by design. | Out of scope for this fix. If detached-HEAD launches ever become a supported flow, revisit under a dedicated issue. | The swept defect class is null-method throws or `$LASTEXITCODE`-only guards ahead of method calls; this site is neither. Expanding scope here would have violated the plan's no-silent-scope-expansion rule. | `evidence/other/git-empty-output-sweep.2026-07-26T15-17.md` advisory section; reviewer source read of lines 29-37; reviewer grep of `config.toml` |
| Info | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` | Carried forward: the MCP `run_poshqc_test` convenience path measures the stale bundled runsettings until the next server release; the authoritative measurement is `Invoke-PoshQCTest -Root <repo>`, which is command-for-command the CI path. Cycle 2 followed the RD-5 dual-path protocol correctly (MCP loop stage mandatory, coverage claims cite only the local XML). | Confirm the republished bundle carries the corrected measured set at the next release (parity contract already enforces text parity). | Verified in cycle 1 against `_poshqc.yml:38-42` and `PoshQC.psm1:3`; nothing changed in cycle 2 that affects the adjudication. | `policy-audit.2026-07-26T13-42.md` Section 2.5; `remediation-plan.2026-07-26T18-10.md` C2/RD-5 |

The cycle-1 Info items (shared-parser `hook_event_name` hardening; checkpoint-monotonic dead branch at lines 260-261) remain recorded as deferred follow-ups in `evidence/other/remediation-followups.2026-07-26T11-41.md` and are unchanged. No Blocker, Major, or Minor findings.

---

## Implementation Audit

### Cycle-2 production delta (hunk-by-hunk)

- **`enforce-epic-child-worktree-binding.ps1` (+12/−7 net):** one new function above the dot-source guard (`Get-CodexChildGuardLiveBranch`, `[CmdletBinding()]`/`[OutputType([string])]`/mandatory typed parameter, reusing the existing `Invoke-CodexChildGuardGit` seam and preserving its `2>&1` stream semantics); entrypoint replaces the four-line cast-and-guard block with one resolver call and drops the `.Trim()` from the decision call. No other lines touched.
- **`enforce-epic-planning-only.ps1` (+22/−6 net):** wrapper `Invoke-EpicPlanningGit` (exact repo-standard seam shape, preserving the original `2>$null` stream semantics) and resolver `Get-EpicPlanningCurrentBranch` (git failure → the pre-existing throw text, verbatim; empty successful output → `''`; otherwise trimmed) above the guard; entrypoint replaces the five-line block with one resolver call. The staged-paths block (lines 288-291) is deliberately untouched — reviewer confirmed it is transport-safe (`@(...)` array wrap; the decision layer already denies an empty staged set).
- **Runsettings pair (+6/−0 each):** two `CodeCoverage.Path` entries with an attribution comment, in the same additive style as every prior remediation block (#275 through #415 cycle 1); byte-identical copies; nothing removed; `CoveragePercentTarget` unchanged at 0.
- **Bundle mirrors:** byte-identical to their roots (hash-verified within the full-tree comparison).

### Constraint verification (all reviewer-executed, not accepted from evidence)

| Constraint | Result |
|---|---|
| No `.claude/` path created/modified/deleted (branch diff + working tree) | HOLDS — `git diff main...HEAD -- .claude/` empty; `git status --porcelain` empty |
| `.codex/config.toml` unmodified; 5 / 5 / 8 handler blocks | HOLDS — zero diff at every range; direct read of the three matcher groups |
| No decision-function change beyond RD-1 entrypoint outcomes | HOLDS — cycle-2 hunks confined to new helpers + call sites; both hooks unchanged before cycle 2 |
| Root `.codex/` ↔ bundle byte-identity; runsettings byte-identity | HOLDS — identical file sets, 0 hash differences; `git diff --no-index` on the runsettings pair exits 0 |
| No temp files in tests | HOLDS — grep across branch-changed tests: no temp-file API |
| ≤ 500 lines per file (`Get-Content .Count`) | HOLDS — max 489 on the branch; cycle-2 files 334/310/344/353/143 |
| Coverage config additive-only; no weakened assertion; no suppression | HOLDS — runsettings diff +6/−0 per copy; 0 removed test lines in cycle 2; no `SuppressMessage` in the delta |
| Integration test intact | HOLDS — byte-unchanged in cycle 2, no skip markers, passes in reviewer re-run |

---

## Test Quality Audit

- **Determinism:** The CI-only failure condition (git success + empty output) is reproduced deterministically at the seam by mock, not by environment manipulation; entrypoint cases assert transport outcomes that hold in every checkout state. No clocks, randomness, sleeps, network, or temp files.
- **Mock discipline:** Executables are never mocked; the wrapper seams are, with exact named-parameter parity and explicit `$global:LASTEXITCODE`, matching `.claude/rules/powershell.md` mocking rules 1–3. `Should -Invoke ... -ParameterFilter` pins the full argument vector (`-C <root> branch --show-current`).
- **Assertion strength:** RD-1a pins the exact transport-blocked message; RD-1b pins the deny envelope's `permissionDecision` and reason text; the C1 entrypoint case additionally asserts stderr does not contain the historical null-method message.
- **Coverage honesty:** Both hooks pass the 85% gate raw; no residual computation, no exclusions; all 16 uncovered lines itemized with per-line reasons that the reviewer matched one-for-one against the XML's missed-line numbers and the current source.
- **Hygiene:** Console readers and environment restored in `finally`; fixtures are in-memory objects; the worktree probes that do touch the filesystem are non-committed evidence probes outside the repository, per plan convention C4, and were replicated (and cleaned up) by this reviewer.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Cycle-2 diff contains hook logic, settings paths, tests, and evidence only. |
| No unsafe subprocess or command construction | ✅ PASS | Git invocations remain splatted argument arrays through wrapper seams; no string interpolation into a shell. |
| Fail-closed behavior preserved where it matters | ✅ PASS | Genuine git failure still exits 2 in the planning-only hook (RD-1a, test-pinned); checkpoint fail-closed denies untouched (decision functions byte-identical). |
| No new attack surface | ✅ PASS | No new inputs, no new environment reads, no registration changes. |
| Coverage-gate integrity | ✅ PASS | Additive-only measured-set change; thresholds and denominators untouched; parity contract binds the bundled copy. |

---

## Research Log

No external research was required. Conclusions derive from: the branch diff (`5f24e0f6..d44a26ad`) and the cycle-2 delta (`21fc8c3b..d44a26ad`), `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`, direct source inspection of both hooks and all three cycle-2 suites, direct parsing of both coverage artifacts, re-execution of the sweep greps, the reviewer's own detached-worktree probes at HEAD, the 476-test Pester re-run, the 9-test pytest parity re-run, and the executor's cycle-2 evidence tree.

---

## Verdict

Cycle 2 is exactly what the remediation inputs prescribed: a two-hook transport fix with the adjacent behavior made deliberate and recorded, a clean sweep, and honest coverage measurement of the changed surface — with zero policy movement, zero constraint violations, and every claim independently reproduced, including the fix itself in an actual detached-HEAD worktree at the committed head. **Blocking findings: 0. Recommendation: Go.**
