Timestamp: 2026-08-28T17-11

# Feature Audit — issue #575 (release-poll-budgets-unpinned-and-isolation-evidence-proxy-level)

Branch: `bug/release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575-r2`
Work mode: `full-bug` — AC source is `spec.md` only (`user-story.md` intentionally absent, confirmed
by `plan.2026-08-28T09-30.md:9`).
Diff scope: `git diff origin/main` (see policy-audit for the local-`main`-staleness resolution).

## AC-by-AC Verification

| AC | Text (summary) | Verdict | Evidence |
| --- | --- | --- | --- |
| AC1 | New test file exists, dot-sources `Invoke-ReleaseTagPush.ps1`, contains no `Mock -CommandName Invoke-TagPublishVerification` | **PASS** | Read full file (79 lines); `BeforeAll` dot-sources at line 10; grep for the mock string returns no match. |
| AC2 | `It` test asserts check (a) forwarding of `IntervalSeconds 10`/`MaxAttempts 18` to `Wait-ForWorkflowRun` via `-ParameterFilter` | **PASS** | Lines 43-50; cross-checked against `Invoke-ReleaseVerification.ps1:353-354` defaults and `:362-366` forwarding call. |
| AC3 | `It` test asserts check (b) forwarding of `IntervalSeconds 20`/`MaxAttempts 60` to `Test-PublishStepConclusion` via `-ParameterFilter` | **PASS** | Lines 52-60; cross-checked against `:355-356` defaults and `:372-377` forwarding call. |
| AC4 | `It` test asserts exactly 41 `Invoke-NpmExe` calls and 39 `Invoke-Sleep` calls at `$Seconds -eq 15` for check (c) | **PASS** | Lines 62-77; arithmetic independently verified against the real check-(c) loop (`:387-392`, `NpmMaxAttempts=40`) plus one pre-push-guard call (`Invoke-ReleaseTagPush.ps1:198`). |
| AC5 | Sibling `Invoke-ReleaseTagPush.Tests.ps1` (21 `It` blocks) still passes with zero own-assertion changes | **PASS** | `git diff origin/main -- tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` — empty (byte-identical); evidence `existing-suite-unmodified-green.2026-08-28T20-58.md` records TotalCount 21/PassedCount 21/FailedCount 0. |
| AC6 | New file <= 500 lines; no other new file exceeds 500 lines | **PASS** | `wc -l` = 79. Only other new non-Markdown file in the diff is the same file; all other additions are Markdown (feature docs/evidence, exempt from the cap per `general-code-change.md`). |
| AC7 | PoshQC format completes with zero auto-fixes against every changed/added file | **PASS** | `evidence/qa-gates/final-format.2026-08-28T21-15.md` — exit 0, 422/422 files "Already formatted," including the new test file explicitly named in the output. |
| AC8 | PSScriptAnalyzer reports zero findings against every changed/added file | **PASS** | `evidence/qa-gates/final-analyze.2026-08-28T21-17.md` — exit 0, "PSScriptAnalyzer passed: no findings," repo-wide scan includes the new file. |
| AC9 | Complete repository Pester suite passes with zero failed tests | **PASS** | `evidence/qa-gates/final-test-coverage.2026-08-28T21-25.md` — 3840 passed, 0 failed, 9 skipped (skip count unchanged from baseline). |
| AC10 | `Invoke-ReleaseTagPush.ps1` line coverage >= 85%, no reduction from pre-fix | **PASS** | Independently re-derived from `artifacts/pester/powershell-coverage.xml` sourcefile counter: 75/77 = 97.40%, identical to the recorded P0-T8 baseline (also 97.40%). Zero regression. |
| AC11 | #526 spec.md carries a new section headed exactly `## Correction — 2026-08-28 (issue #575)`, appended after AC21's location | **PASS** | `git diff origin/main -- docs/features/active/.../526/spec.md` shows the exact heading text as a pure addition after the file's prior final line. |
| AC12 | Correction states the original claim, the mechanism actually verified, and contains the literal token `#575` | **PASS** | Read the appended section directly; contains "no network access available," "proxy-aware network clients ... redirected to an unreachable discard endpoint; a raw socket is not blocked by this mechanism" (near-verbatim), and the literal heading token `(issue #575)` plus body reference to "issue #575." |
| AC13 | AC21 line (417) byte-for-byte identical before/after; checkbox remains `[x]` | **PASS** | Read line 417 post-change directly: `- [x] AC21 — The complete Pester suite passes with no network access available...` — matches the pre-existing text quoted in the correction section and in the #526 feature-audit verbatim. |
| AC14 | New evidence artifact exists under this feature's `evidence/qa-gates/`, recording the corrected proxy-level claim | **PASS** | `evidence/qa-gates/proxy-level-isolation-correction.2026-08-28T21-05.md` exists and states the corrected claim. |
| AC15 | Evidence artifact records the raw-socket probe reproduction and result, and separately reaffirms clause 2 (no real `npm`/`gh`/`git` invocation) | **PASS** | Same artifact: P2-T1 records the `TcpClient` probe command and `RAW_SOCKET_CONNECTED=True` result; P2-T2 records a `git grep` across all four release-verification test files with zero matches, reaffirming clause 2. |
| AC16 | "Rollout & Follow-up" records the `Test-PublishStepConclusion` default-parameter mismatch as an explicit out-of-scope follow-up | **PASS** | `spec.md:194` — follow-up item present, states the mismatch, its inertness today, and its out-of-scope disposition. |
| AC17 | Diff modifies no line of `Invoke-ReleaseVerification.ps1`, `Invoke-ReleaseVerificationHelpers.ps1`, or `publish-mcp-npm.yml` | **PASS** | Independently re-ran `git diff origin/main --name-only -- <the three paths>` — empty output. Cross-checked against the feature's own evidence (`diff-scope-verification.2026-08-28T21-30.md`), which used local `main` and agrees for these three specific paths. |

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/spec.md`
- Total AC items: 17
- Checked off (delivered) prior to this review: 17
- Checked off (delivered) confirmed by this review: 17
- Remaining (unchecked): 0

All 17 AC checkboxes were already `[x]` in the branch, and this audit independently re-verified each
one against the diff and, where applicable, against the raw production source or raw coverage XML
rather than accepting the checkbox or the cited evidence artifact's prose at face value. No AC was
found to be checked without backing verification.

## Additional Baseline-vs-Delta Cross-Check

- Test count delta: baseline (P0-T8) 3837 passed / final (P3-T3) 3840 passed = +3, matching exactly
  the three new `It` blocks added by Gap 1. Consistent with a coverage-neutral, test-only addition.
- Repo-wide line coverage: unchanged at 94.72% (7236/7639) between baseline and final, independently
  re-derived from the raw coverage XML in both cases (see policy-audit and code-review for the raw
  XML re-derivation).

## Out-of-Scope / Non-Goal Confirmation

- No shipped budget value changed in `Invoke-ReleaseVerification.ps1` (file untouched, AC17).
- No production `.ps1` file under `scripts/dev-tools/` changed at all (Gap 1 is test-only).
- `.github/workflows/publish-mcp-npm.yml` untouched (AC17).
- `quality-tiers.yml` remains absent at repo root — a pre-existing condition explicitly flagged as
  investigated-and-excluded in `spec.md`'s "Explicitly excluded systems" section; not introduced by
  this branch.

## Overall Feature Audit Verdict

**PASS.** 17 of 17 AC items verified PASS with independent evidence re-derivation (not solely reliance
on the feature's own evidence-artifact prose). Zero Blocking findings, zero Partial or Fail findings.
