# Code Review: ci.yml epic/** pull_request trigger and S9 epic-child rule (#658)

---

**Review Date:** 2026-10-08 (artifact timestamp `2026-10-08T03-15` supplied by the delegating orchestrator)
**Reviewer:** feature-review agent, pass 2
**Feature Folder:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix `658` matches the branch name.
**Base Branch:** `origin/main` (merge-base `08ee030d9584bf15882fbb3654c8e38f34c7c359`)
**Head Branch:** `bug/epic-child-prs-trigger-no-ci-658` (head `54d4ee3ab799b1b7bd6ef5cccfdb8420eaa7c60c`)
**Review Type:** Re-review (pass 2) after the AWAITING_CI wait branch. Prior review: `code-review.2026-10-08T02-50.md`.

---

## Executive Summary

No production or test file changed after pass 1. `git diff --name-only 9686d975 HEAD` lists only feature-folder paths: the pass-1 review artifacts (commit `dd3fc879`), the new evidence `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md`, and an `ac-status-summary` pointer update (commit `54d4ee3a`). This review re-read the five production and test files at `54d4ee3a` and confirmed the pass-1 implementation assessment. `ci.yml` line 7 lists `"epic/**"` and line 5 (`push`) is unchanged. The README `## Triggers` section is accurate. The S9 epic-child paragraph is at `orchestrate/SKILL.md` line 291. The mirror is byte-identical. The two-test Pester suite is hermetic.

The pass-1 Blocker CR-2 (no green CI run at the branch head) is closed. CI run 37719545156 on `dd3fc879` was verified directly by this review with `gh run view`: workflow `CI`, event `workflow_dispatch`, conclusion `success`, 17 of 17 jobs `success`. `dd3fc879` contains every non-feature-folder change, and the only later commit (`54d4ee3a`) touches only feature-folder paths. Under the orchestrator ruling for this pass, the final-head match is owned by the S9 CI gate (`orchestrate/SKILL.md` lines 295, 298, 300). No PR exists yet, so S9 has not run.

**What changed (branch total, unchanged since pass 1):**
- `.github/workflows/ci.yml:7`: `branches: [main, development]` becomes `branches: [main, development, "epic/**"]`.
- `.github/workflows/README.md:8-16`: new `## Triggers` section.
- `.claude/skills/orchestrate/SKILL.md:291`: epic-child rule paragraph; bundle mirror identical.
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (new, 174 lines).

**Top 3 risks:**
1. The S9 epic-child rule is still enforced only by prose. `Invoke-CiGateParser.ps1` returns `success` for an empty check set (CR-1, Non-blocking, out of scope).
2. The `epic/**` trigger has not yet been exercised by a real `pull_request` event into an `epic/**` branch (CR-6).
3. The final-head CI match now depends on the orchestrator completing S9 before DONE and merge. That is a process dependency, not a code defect (CR-10).

**PR readiness recommendation:** **Ready** for the PR creation gate. No Blocking finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Closed (was Blocker; cleared in pass 2) | `.github/workflows/ci.yml` | branch head | CR-2: Green run at branch head. Run 37719545156 on `dd3fc879` concluded `success` (17/17 jobs). Every non-feature-folder change is in `dd3fc879`, and `54d4ee3a` touches only feature-folder paths. | None for the branch. S9 records the final-head match before DONE. | Orchestrator ruling: in-repo evidence cannot name its own commit's SHA. The three ruling conditions were verified with `git` and `gh`. | `gh run view 37719545156`; `git log 00798863..HEAD -- . ":!<feature folder>"` (empty); `git diff --name-only dd3fc879 HEAD` |
| Major (Non-blocking; out of scope per issue.md line 28; Open) | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | lines 22-23, 130-133 | CR-1: The parser maps an empty check set to `success`, so the S9 epic-child rule at `orchestrate/SKILL.md:291` depends on the orchestrator applying prose. | File a follow-up issue for an opt-in parser guard (for example `-RequireWorkflow CI`), passed by S9 when `epic_mode` is true. | A vacuous S9 green is the defect class issue #658 targets. | File unchanged on the branch (`git diff --stat` lists only five non-feature paths) |
| Minor (Non-blocking; Open) | `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/` | Phase 1, Phase 2, and the new `02-55` artifact | CR-3: Evidence timestamps are not local host-clock capture times. The new artifact is stamped `2026-10-08T02-55 (UTC)`. | Read the timestamp from the host clock at capture time; no rewrite of existing files needed. | `evidence-and-timestamp-conventions/SKILL.md:49`. Run IDs and SHAs are consistent and were verified directly. | `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md` line 3 |
| Minor (Non-blocking; Open) | `.claude/skills/orchestrate/SKILL.md` | lines 291, 293 | CR-4: The epic-child paragraph drops `--required`, while step 3 still describes the parser conclusion in terms of "required checks". The treatment of failing non-CI checks on an epic child is unstated. | In a follow-up, state whether non-CI checks on an epic child are ignored or must pass, and align the step 3 wording. | Gate-definition ambiguity can produce divergent orchestrator behavior. | `orchestrate/SKILL.md:289-293` (re-read at `54d4ee3a`) |
| Nit (Non-blocking; Open) | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 116-124, 137-139 | CR-5: The helper's dash-item block-list branch and single-quote stripping are not exercised. | Optional: add an `It` calling `Get-CiTriggerBranchList` on an inline block-list array with single-quoted items. | Untested parsing branches could misbehave after a reformat. The existing assertions still fail closed. | File inspection at `54d4ee3a` |
| Info (Open) | `.github/workflows/ci.yml` | line 7 | CR-6: The `epic/**` filter has not been exercised by a real `pull_request` event into an `epic/**` branch. All CI evidence comes from `workflow_dispatch` runs. | Observe the first epic child PR after merge, or run the issue's throwaway `epic/test-integration` scenario. | Residual-confidence note; GitHub `**` globs match across `/`. | `gh run list` shows only `workflow_dispatch` runs on the branch |
| Info (Open) | `.github/workflows/README.md` | lines 3-4 | CR-7: The pre-existing intro says "eight reusable per-stage workflows". `ci.yml` has nine jobs. | Correct in a separate documentation change. | Pre-existing drift, not introduced by this branch. | README line 4 |
| Info (Open) | branch | n/a | CR-8: The branch is behind `origin/main` (`6c3649b0`, PR #835, 13 commits). No changed path overlaps. | Update from `main` before opening the PR. S9 then verifies the resulting head. | Keeps the PR diff and CI run representative of the merge result. | `git log --oneline 08ee030d..origin/main`; `git ls-remote origin refs/heads/main` |
| Nit (Non-blocking; new) | `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/other/ac7-deferred-to-pr-time.2026-10-08T02-30.md` | `VerificationRecord:` line | CR-9: The [P2-T17] record still names the superseded run 37717224700 on `8a1b9b8b` as its verification record. `ac-status-summary.2026-10-08T02-30.md` line 22 was updated to the `02-55` record; this file was not. | Optional: when the next evidence commit is made, add a pointer to `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md`. | Two pointer records disagree about which run verifies AC-7. The superseding artifact itself states the supersession, so the impact is limited to traceability. | `git diff --name-only dd3fc879 HEAD` (the deferral record is not in the list) |
| Info (Non-blocking; new) | `.claude/skills/orchestrate/SKILL.md` | lines 295, 298, 300 | CR-10: The final-head CI obligation now rests on S9. No PR exists for the branch (`gh pr list --state all` returns `[]`), so S8 and S9 have not run. | The orchestrator must record `ci_gate.head_sha` equal to the final PR head with `conclusion == success` before DONE and before merge. Re-run S9 after any further commit, including commits of these review artifacts. | Under the applied ruling, S9 is the authority for the final-head match. | `orchestrate/SKILL.md:295` step 5; `:298` re-run after CI-dependent AC commits; `:300` DONE condition |

No Blocking findings remain. CR-2 is closed. All open findings are Non-blocking.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The suite isolates the `on:` block before branch lookups (lines 23-40), following `PublishMcpNpmWorkflow.Tests.ps1`. Unrelated text elsewhere in the file therefore cannot satisfy the assertions.
- `Get-CiTriggerBranchList` parses branch-filter semantics in both flow and block forms, so the test asserts behavior rather than formatting.
- A non-empty guard (`$script:triggerLines.Count | Should -BeGreaterThan 0`) prevents a vacuous pass.
- The regression property is demonstrated across three CI runs: failure on `632fe595` (run 37715960709, conclusion `failure`), pass on `8a1b9b8b` (run 37717224700), and pass on `dd3fc879` (run 37719545156, job 113123796488 log line 1260).

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([string[]])]`, mandatory parameters, `[AllowEmptyCollection()]`, `[AllowEmptyString()]`, and `[ValidateNotNullOrEmpty()]` are present. The verb `Get-` is approved.
- `Set-StrictMode -Version Latest` is at line 1. There is no global state and no module import.

#### Error handling and logging

- `Resolve-Path` fails the container when `ci.yml` is absent.
- Each assertion carries `-Because` text naming issue #658.

### GitHub Actions / Markdown audit

- `ci.yml`: single-line change, correctly quoted. actionlint 1.7.11 produced no output at `54d4ee3a` (this review). The trigger uses `pull_request`, not `pull_request_target`, so fork PRs into `epic/**` receive the default read-only token.
- README: the trigger list matches `ci.yml`, and line 16 states the reason.
- Orchestrate skill: the paragraph continues step 2 at three-space indentation without renumbering. `cmp` against the bundle mirror exits 0, and the bundle-parity contract passes (included in this review's 39-test pytest run).

---

## Test Quality Audit

In pass 1, CI citations could only be checked for internal consistency. In pass 2 this review read them from GitHub directly. Job 113123796488 (`poshqc / PowerShell QC`, run 37719545156, head `dd3fc879`) shows:
- line 811: `Already formatted: ...CiWorkflow.Tests.ps1`
- line 820: `PSScriptAnalyzer passed: no findings`
- line 1260: `[+] ...CiWorkflow.Tests.ps1 40ms (6ms|22ms)`
- line 1265: `Tests Passed: 6521, Failed: 0, Skipped: 10`
- line 1267: `Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.`

The run's `poshqc-test-results` artifact and the baseline run 37645267440's artifact have identical report-level JaCoCo counters (LINE 13,325 covered and 2,413 missed, 84.67%). No PowerShell coverage regression is possible from this branch. The 84.67% repo-wide line figure is below 85% and predates the branch (policy-audit PA-N8).

### Reviewed test and QA artifacts

- `tests/scripts/workflows/CiWorkflow.Tests.ps1`: re-read at `54d4ee3a`; unchanged since `632fe595`.
- `evidence/regression-testing/fail-before-direct.2026-10-07T22-30.md`: run 37715960709, head `632fe595`, conclusion `failure` (confirmed by `gh run list`).
- `evidence/regression-testing/pass-after-poshqc.2026-10-08T02-30.md` and `evidence/qa-gates/final-poshqc-test.2026-10-08T02-30.md`: run 37717224700 values, which run 37719545156 reproduces.
- `evidence/qa-gates/coverage-comparison.2026-10-08T02-30.md`: command-coverage comparison 84.32% to 84.32%. This review supplements it with the line counter.
- `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md`: run 37719545156 on `dd3fc879`, `success`, 17/17. Its head-relationship statement matches `git` (ancestor check, feature-folder-only later commit).
- `evidence/qa-gates/ac-status-summary.2026-10-08T02-30.md`: AC-7 pointer updated to the `02-55` record; `CheckedCount: 7`.

### Quality assessment prompts

- **Determinism:** text parsing of a committed file; no clock, randomness, network, or process.
- **Isolation:** one invariant per `It`; read-only shared setup.
- **Speed:** 40 ms for the file in CI.
- **Diagnostics:** the recorded failure message names the missing entry, the actual collection, and the issue.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of the five production and test files. |
| No unsafe subprocess or command construction | PASS | The test launches no process; no `run:` step was added. |
| Trigger scope and permissions | PASS | `pull_request` (not `pull_request_target`); no `permissions` change. |
| Error handling remains explicit | PASS | StrictMode is enabled; `Resolve-Path` fails fast. |
| Configuration / path handling is safe | PASS | The path is resolved from `$PSScriptRoot` and read with `-LiteralPath`. |
| Gate semantics (S9) | PARTIAL | The rule text is correct, but the parser does not enforce it mechanically (CR-1, Non-blocking). |
| CI green on branch content | PASS | Run 37719545156 on `dd3fc879`; the final-head match is owned by S9 (CR-10). |

---

## Research Log

No external research was required. GitHub Actions state was read with `gh run list`, `gh run view` (run fields and the job log), `gh run download` (coverage XML to the session scratchpad), and `gh pr list`. Repository facts were confirmed with `git` against this worktree only.

---

## Verdict

The implementation is correct, minimal, and well tested for its scope, and no code changed after pass 1. The pass-1 Blocker CR-2 is closed under the orchestrator ruling, with direct `gh` verification of run 37719545156 and `git` verification that the only later commit is feature-folder-only. The branch is ready for the PR creation gate. Before DONE and merge, the orchestrator must still complete S9 against the final PR head (CR-10). CR-1 remains the most significant residual design risk and should be filed as a follow-up. CR-3 through CR-9 are Non-blocking.
