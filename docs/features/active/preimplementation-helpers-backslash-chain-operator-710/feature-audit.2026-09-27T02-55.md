# Feature Audit: Preimplementation Gate Helpers Backslash Chain Operator (#710)

---

**Audit Date:** 2026-09-27
**Feature Folder:** `docs/features/active/preimplementation-helpers-backslash-chain-operator-710`
**Base Branch:** `main`
**Head Branch:** `bug/preimplementation-helpers-backslash-chain-operator-710`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`, resolved `origin/main` (commit `2dce111ef7cb6cf6326db6e661223e59c85e4bec`)
- **Head branch/commit:** `bug/preimplementation-helpers-backslash-chain-operator-710` (commit `e5c7a223460a302042840e45192ba6a78924df48`; pushed, remote ref matches)
- **Merge base:** `2dce111ef7cb6cf6326db6e661223e59c85e4bec`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-27 06:51:38 UTC at head `e5c7a223`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`; reviewer reruns and probes recorded in `code-review.2026-09-27T02-55.md` and `policy-audit.2026-09-27T02-55.md` Appendix B
- **Feature folder used:** `docs/features/active/preimplementation-helpers-backslash-chain-operator-710`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: full-bug`; per the acceptance-criteria tracking rules, `spec.md` is the only AC source. The checkbox list in `issue.md` is not authoritative for this mode.
- **Scope note:** Full branch diff `2dce111e...e5c7a223` (52 files: 4 helper copies, 1 new test, 47 feature-folder documents). No scope narrowing was supplied or applied. The PR-context artifacts were current and were not regenerated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md` — only source

### Acceptance criteria

1. AC-1: `Split-OrchestrationCommandLine` treats an unquoted backslash-escaped `;`, `&` or `|` as a literal character: `find . -exec cmd {} \; -print`, `a\&b c` and `a\|b c` each return exactly one segment whose text equals the input, verified by the `treats a mid-line escaped semicolon as literal`, `treats an escaped ampersand as literal` and `treats an escaped pipe as literal` tests in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, and those tests fail against the base helper file (fail-before evidence recorded under `evidence/regression/`).
2. AC-2: `Test-ExemptOrchestrationStagingCommand` returns `$true` for `git commit -m fix\;done -- docs/features/active/x/spec.md`, verified by the `exempts a commit whose message contains an escaped semicolon` test in the same file.
3. AC-3: Unescaped chain operators continue to split exactly as before: `a; b`, `a && b`, `a || b`, `a | b` and `a & b` each return two segments, verified by the data-driven `still splits on unescaped <operator>` tests.
4. AC-4: The fix introduces no bypass: `a\\; b` returns two segments, `a\&& b` returns two segments, `'a\'; b` returns two segments, and `Test-ExemptOrchestrationStagingCommand` returns `$false` for `git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md`, verified by the `still splits after an escaped backslash`, `splits on the unescaped ampersand after an escaped one`, `keeps backslash literal inside single quotes` and `does not exempt a chained command after an escaped backslash` tests.
5. AC-5: Quote-state and boundary cases behave per POSIX: `a\\\; b` returns one segment; `"a\"; b"` returns one segment with `Balanced` true; `a\"` and a trailing `a\` return `Balanced` true; backslash-newline returns one segment, verified by the corresponding tests in the same file.
6. AC-6: The fix is applied identically to all four copies: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` have equal SHA256 values recorded under `evidence/qa-gates/`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` pass.
7. AC-7: The helper file's post-edit line count equals its line count measured on the current base immediately before editing and is <= 500, with both counts recorded under `evidence/qa-gates/`; the diff of the canonical file touches only `Split-OrchestrationCommandLine`.
8. AC-8: The regression suite passes under Pester locally and in the CI PoshQC Pester job (`.github/workflows/_poshqc.yml`, `windows-latest`), and by inspection it depends on no gitignored state, no `origin/main` ref, no gate-decision path, and no Windows-only filesystem path.
9. AC-9: Existing suites that reach the helpers stay green: both CommandExemption suites, the EpicScope and TriggerScoping suites, and the Codex trigger-scoping, mode-resolution and mode-routing suites.
10. AC-10: Full PowerShell toolchain passes in a single pass (PoshQC format, PoshQC analyze with 0 findings, Pester), and line coverage for both canonical helper copies is >= 85% with no regression on changed lines, recorded under `evidence/coverage/`.
11. AC-11: The out-of-scope operand gap (`docs/features/active/.\./.\./.\./src/x.ps1`, D7) is recorded as a follow-up to be filed separately, and no edit is made to `Test-ExemptOrchestrationOperand`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 escaped `;`, `&`, `\|` are literal | PASS | Three named tests pass on both surfaces; fail-before shows all three failing on base for both surfaces (`evidence/regression-testing/fail-before-chain-escape.md`). | Reviewer rerun: `sh review-run.sh` (Invoke-Pester over ChainEscape + 4 suites) -> 297 passed, 0 failed | Fail-before evidence is at the canonical `evidence/regression-testing/`, not the non-canonical `evidence/regression/` the AC names; the substance is met. |
| 2 | AC-2 commit with `fix\;done` is exempt | PASS | Test `exempts a commit whose message contains an escaped semicolon` passes; failed on base. | Same reviewer rerun | Under POSIX the shell runs one `git commit`. |
| 3 | AC-3 unescaped operators still split | PASS | Five data-driven rows pass on both surfaces and also passed on base (unchanged behaviour). | Same reviewer rerun; fail-before PASSED lines | |
| 4 | AC-4 no bypass (`\\;`, `\&&`, `'a\'; b`, chained commit) | PASS | Four named tests pass on both surfaces. | Same reviewer rerun | Verified as specified, under POSIX semantics. Code review Finding 1 (Major, non-blocking) records that on a host executing the `Bash` tool through PowerShell, `git commit -m a\; docs/features/active/x/run.ps1 -- docs/features/active/x/spec.md` is now exempt (base: denied). Recommended as a follow-up issue. |
| 5 | AC-5 POSIX quote-state and boundary cases | PASS | Tests for `a\\\; b`, `"a\"; b"`, `a\"`, trailing `a\`, and backslash-newline pass. | Same reviewer rerun | |
| 6 | AC-6 four copies identical; Parity and legacy-codex pass | PASS | SHA256 of all four copies = `ebe15355e3bd95f7cdc8ac64b0bd2f230db88304fc21d8c1e6d7da458f9c6f7a` (recomputed by reviewer); `evidence/qa-gates/mirror-parity-sha256.md`; full run rows Parity tests=2 failures=0, legacy-codex tests=43 failures=0 (`evidence/qa-gates/final-pester-full.md`); reviewer rerun of Parity passed. | `sha256sum <four copies>`; reviewer Pester rerun | |
| 7 | AC-7 line count unchanged, <= 500; hunk confined | PASS | Base 497 (`git show 2dce111e:... \| wc -l`), head 497 for all four copies; `evidence/qa-gates/canonical-edit-checks.md` PRE_EDIT 497 / POST_EDIT 497; hunks at pre-image lines 63, 77, 78, all inside `Split-OrchestrationCommandLine` (`evidence/qa-gates/scope-boundary.md`). | `wc -l`; `git diff -U0 2dce111e...HEAD -- .claude/hooks/...helpers.ps1 \| grep '^@@'` | |
| 8 | AC-8 local and CI PoshQC Pester pass; portability by inspection | UNVERIFIED | Local: full run 5244 JUnit tests, 0 failures, ChainEscape tests=38 failures=0. Inspection: `evidence/qa-gates/test-portability-inspection.md` and reviewer reading of the test file confirm no gitignored state, `origin/main`, gate-decision path, or Windows-only filesystem path. CI: no PR exists and `gh run list --branch ...` returns no runs. | `gh pr list --head <branch> --state all`; `gh run list --branch <branch>`; `git ls-remote origin refs/heads/<branch>` | The local and inspection parts pass. The CI part cannot be observed until a PR into `main` triggers `ci.yml`. To be confirmed at the orchestrator S9 CI gate. |
| 9 | AC-9 related suites green | PASS | Full-run rows, each failures=0 errors=0: Claude CommandExemption (119), Codex command-exemption (119), EpicScope (19), TriggerScoping (19), Codex trigger-scoping (23), Codex mode-resolution (55), Codex mode-routing (11). Reviewer rerun of both CommandExemption suites and EpicScope passed. | `evidence/qa-gates/final-pester-full.md`; reviewer Pester rerun | |
| 10 | AC-10 single-pass toolchain; coverage >= 85%, no regression | PASS | Format 0/530 reformatted; analyze no findings; Pester green (pass 2, `evidence/qa-gates/final-seven-stage-loop.md`). Coverage 97.04% -> 97.08% per canonical copy, changed lines 2 of 2 covered; reviewer re-parsed `artifacts/pester/powershell-coverage.xml` with identical results. | `python -c` JaCoCo parse (policy audit Appendix B) | Coverage evidence is at canonical `evidence/qa-gates/final-coverage-delta.md` and `final-scoped-coverage.md`, not the non-canonical `evidence/coverage/` the AC names; the substance is met. |
| 11 | AC-11 D7 follow-up recorded; operand function untouched | PASS | `evidence/other/follow-up-d7-operand-gap.md`; `git diff 2dce111e...HEAD -- .claude/hooks/...helpers.ps1` contains no `Test-ExemptOrchestrationOperand` change (0 matches in the diff). | `git diff ... \| grep -c Test-ExemptOrchestrationOperand` -> 0 | The follow-up issue has not been filed yet; the AC requires only that it be recorded. |

---

## Summary

**Overall Feature Readiness:** PASS (pending the CI confirmation in AC-8)

**Criteria summary:**
- **PASS:** 10 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria (AC-8, CI portion only)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-8: CI PoshQC Pester job has not run on the branch head because no PR has been opened.
2. None further. Code review Finding 1 (shell-dialect widening on a PowerShell-executed `Bash` tool) does not fail any acceptance criterion as written; it is recorded as a follow-up.

**Recommended follow-up verification steps:**

1. Open the PR into `main` with `Closes #710` (not #510 or #663), wait for `ci.yml` / `_poshqc.yml` on `windows-latest`, and confirm the `enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` suite passes; then check off AC-8.
2. File the D7 operand-gap follow-up (`evidence/other/follow-up-d7-operand-gap.md`) and a follow-up for code review Finding 1 through the MCP promotion route.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

No source-file change was made by this review. AC-1 to AC-7 and AC-9 to AC-11 were already checked in `spec.md` by the executor, and this audit confirms each as PASS. AC-8 is evaluated UNVERIFIED and remains unchecked.

The `issue.md` `## Acceptance Criteria` checkboxes are not authoritative in `full-bug` mode and were left unchanged.

### AC Status Summary

- Source: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC-8: The regression suite passes under Pester locally and in the CI PoshQC Pester job (`.github/workflows/_poshqc.yml`, `windows-latest`), and by inspection it depends on no gitignored state, no `origin/main` ref, no gate-decision path, and no Windows-only filesystem path.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md` | 11 | 10 | 1 | Checkbox-backed; authoritative for `full-bug` |
| `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/issue.md` | 4 | 0 | 4 | Not authoritative in `full-bug` mode |
