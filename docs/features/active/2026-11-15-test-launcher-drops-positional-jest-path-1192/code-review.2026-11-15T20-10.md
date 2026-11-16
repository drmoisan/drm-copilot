# Code Review: test launcher drops positional Jest path (#1192)

---

**Review Date:** 2026-11-15
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only feature folder changed on the branch and its suffix matches issue 1192.
**Base Branch:** `main` (resolved `origin/main`, merge base `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`)
**Head Branch:** `bug/test-launcher-jest-positional-path` at `3c42b7be6803f2afbf69c210f352ebf8473e5d93`
**Review Type:** Full review of the branch diff against the merge base

---

## Executive Summary

The fix is minimal and correct. `New-TestExecutionSuiteCommand` computes `$extrasFirst` as a case-sensitive comparison of the runner name with `jest` or `pester`, emits the caller's extras before the lane-exclusion words for those two runners, and keeps the order suite words, exclusions, extras for every other runner. With no extras the output is unchanged. The refusal logic, the worker-reduction checks, and the lock are outside the function and are untouched. The four hook copies share one blob hash, so there is no drift. The new tests discriminate: the fail-before record shows five test names failing against the unmodified builder, while the regression guards for unchanged behavior pass on both sides, as intended. The `jest.config.cjs` comment now matches the seven entries of `jest.docs-coverage.json`.

**Top risks:**
1. CR-1 (informational): the Jest array-option mechanism is inferred, not reproduced live; the tests pin the word order that avoids it.
2. CR-3 (informational): CI jobs for PowerShell shards, Linux hook suites, and Windows are pending at review time.

**PR readiness recommendation:** **Ready for merge after pending CI reports green.** No blocking finding; the stale-report issue (CR-4) was closed by a review-time gate rerun; no code defect was found.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/test-execution-policy.ps1` | `New-TestExecutionSuiteCommand` | CR-1. The Jest array-option cause was inferred from the option definition and not reproduced with a live full Jest run. | No action. | The spec states the inference and the fail-before evidence pins the order rather than the Jest behavior. | `spec.md` Repro and Evidence; `evidence/regression-testing/fail-before.2026-11-15T18-07.md` |
| Info | `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` | whole file | CR-2. The file is 547 logical lines, above the 500-line guidance tier and below the 700-line advisory tier, so no Warning applies. | No action. | The 500-line tier is guidance only. | `awk 'END{print NR}'` count |
| Info | `artifacts/pester/powershell-coverage.xml` | local coverage evidence | CR-4 (resolved in this review). The report was written at 2026-11-15T19:51:16Z, before the merge commit `3c42b7be6` (2026-11-15T20:06:58Z) that brought four PowerShell files from PR #1193 into the branch. The reviewer reran the launcher Pester gate at the head: 26903 tests, 0 failures, hook 173 of 173 lines, report written 2026-11-15T20:27:16Z. | No action. | The stop hook requires a report newer than the newest PowerShell-touching commit; it now is. | `evidence/qa-gates/review-pester-gate.2026-11-15T20-28.md` |
| Info | `.claude/hooks/test-execution-policy.ps1` | CI | CR-3. PowerShell QC shards, the Linux hook suites, Python quality, and Windows extension jobs were pending at review time. | Wait for CI before merge. | Pending CI is awaiting CI and is not a defect. | `gh pr checks 1194` |

No file at or above 700 logical lines exists among the added or modified covered files, so no file-size Warning row applies; the largest is 547.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- One local boolean and two guarded loops; no signature or caller change; the help text explains why the order differs.
- Case-sensitive `-ceq` avoids a case-folded match of the runner name.
- The `ExtraArgument` array is enumerated through `@($ExtraArgument)`, which tolerates `$null` and a single value.

#### API and safety notes

- Lane refusal runs on the extras before the build, so moving extras earlier cannot admit an excluded operand; a launcher-level test pins exit 2 with `TEST_EXECUTION_POLICY_BLOCKED:` and no process start.
- Pester extras such as `-TestPath a b` still start a new key, and the exclusion group follows intact; the order test checks every exclusion word.

#### Error handling and logging

Unchanged. The function still throws when the suite is not defined.

### JavaScript implementation audit

`extensions/drm-copilot/jest.config.cjs` changes one comment from five to seven docs MCP modules, matching `jest.docs-coverage.json`. No executable line changes.

---

## Test Quality Audit

The tests assert exact word order for jest (positional, positional plus flag, none) and pester (`-TestPath`, none), and a regression guard for pytest, dotnet-test, and bats. The launcher cases assert `ArgumentList` order and exit 2 for an integration operand beside a valid run. Fixtures are in-memory policy text and an injected launcher state, so no temp file exists. Both hook copies run each case through the existing copy matrix.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`
- `evidence/regression-testing/fail-before.2026-11-15T18-07.md`
- `evidence/qa-gates/final-pester-gate.2026-11-15T19-51.md`, `final-contracts.2026-11-15T20-05.md`, `final-static-powershell.2026-11-15T19-29.md`, `scope-check.2026-11-15T20-05.md`

### Quality assessment prompts

- **Determinism:** No clock, RNG, or environment write.
- **Isolation:** Seams only; no shared state.
- **Speed:** No process start or sleep.
- **Diagnostics:** Exact-string assertions name the expected word list on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected. |
| No unsafe command construction | PASS | The function returns a word array; no string is joined into a shell command. |
| Input validation at boundaries | PASS | Lane refusal and worker-reduction refusal precede the build and are unchanged. |
| Error handling remains explicit | PASS | Undefined suite still throws. |
| Configuration and path handling is safe | PASS | No absolute path is written into any artifact. |

---

## Research Log

No external research was required. Evidence came from the branch diff, the persisted QA records, the fail-before record, and blob-hash comparison of the four hook copies.

---

## Verdict

The implementation meets the spec's behavior and the repository's design, seam, coverage, and determinism rules. No blocking finding; CI jobs are pending.
