# Policy Audit (issue #736)

- Feature folder: `docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736`
- Branch: `bug/completion-consistency-codex-copy-and-fail-open-divergence-exec-736`
- Base: `origin/epic/enforcement-hook-precision-integration` (three-dot diff `base...HEAD`, 6 commits)
- Work mode: full-bug (AC source: `spec.md`)
- Reviewed: 2026-10-08

## Rejected Scope Narrowing

None. The caller prompt requested the full branch diff against the epic base, which matches the scope invariant. No narrowing was attempted.

## Assumptions and Method

- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in this worktree. Scope was derived directly from `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD` (8 hook and mirror files, 10 test files, and otherwise feature-folder spec, plan, and evidence files only). Recorded as an assumption, not a defect.
- The reviewer re-ran the changed Pester suites once in this worktree (the `enforce-completion-consistency*.Tests.ps1` family, the four new Codex suites, `codex-pretooluse-transport.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1`) with coverage on the four changed production files. Result: PASSED=284, FAILED=0, SKIPPED=0; combined coverage 93.53%. The reviewer wrote the coverage output to the session scratchpad only, not to the repository.
- Only PowerShell files changed. No Python, TypeScript, or C# files changed, so those languages have zero changed files on the branch.

## Verdict Summary

| # | Policy area | Verdict |
|---|---|---|
| 1 | Evidence Location Compliance | PASS |
| 2 | 500-line file cap | PASS |
| 3 | No Python in hooks | PASS |
| 4 | Mirror parity (4 bundled mirrors, helper pair) | PASS |
| 5 | Tonality | PASS |
| 6 | Test policy (no temp files, cwd independence, location, AAA, determinism) | PASS |
| 7 | Coverage, changed files (PowerShell) | PASS |
| 8 | Coverage, repo-wide PowerShell | FAIL (pre-existing, not attributable to this branch) |
| 9 | Coverage exclusion policy | PASS |
| 10 | Module rigor tier obligations (T3) | PASS |
| 11 | Toolchain loop evidence | PASS (with documented baseline failures) |
| 12 | Fail-closed error handling | PASS |
| 13 | Branch naming per plan | PARTIAL (non-blocking, documented deviation) |

Blocking findings in this artifact: FAIL = 1 (row 8, repo-wide coverage; pre-existing), blocking PARTIAL = 0.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` was run; it exited 0 with no output.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence files in the diff sit under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose. Verdict: PASS.

## 500-line cap (general-code-change.md)

Measured with `wc -l`:

| File | Lines |
|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 465 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 486 |
| `.claude/hooks/enforce-completion-helpers.ps1` | 268 |
| `.codex/hooks/enforce-completion-helpers.ps1` | 268 |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 491 (spec limit 491, not grown) |
| `...EditTarget.Tests.ps1` | 231 |
| `...DefaultReader.Tests.ps1` | 152 |
| `...EditSemantics.Tests.ps1` | 283 |
| `...FailClosed.Tests.ps1` | 240 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 450 (was 492; shrank) |
| `...enforce-completion-consistency-default-reader.Tests.ps1` | 153 |
| `...-edit-semantics.Tests.ps1` | 284 |
| `...-edit-target.Tests.ps1` | 279 |
| `...-fail-closed.Tests.ps1` | 239 |

All within 500. Verdict: PASS. Note: `.codex/hooks/enforce-completion-consistency.ps1` at 486 has 14 lines of headroom.

## No Python in hooks

- Grep of the changed helper and hook files for `python` and `.py` returned zero matches.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passed in the reviewer's run.
- No `.py` file is in the branch diff. Verdict: PASS.

## Mirror parity

SHA-256 computed by the reviewer:

| Pair | Hash (prefix) | Identical |
|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` vs bundled mirror | `14793bd5...` | Yes |
| `.claude/hooks/enforce-completion-helpers.ps1` vs bundled mirror | `94b891d2...` | Yes |
| `.codex/hooks/enforce-completion-consistency.ps1` vs bundled mirror | `57692cbe...` | Yes |
| `.codex/hooks/enforce-completion-helpers.ps1` vs bundled mirror | `94b891d2...` | Yes |

The two helper files are byte-identical to each other (same hash). The executor's `p5-mirror-identity.md` and `p5-loop-outcome.md` hashes match. The `enforce-completion-consistency-codex.Tests.ps1` SHA suite passed in the reviewer's run. The two Python bundle-parity tests were recorded as passing locally by the executor (`p5-pytest-*-parity.md`); the reviewer did not re-run them, and CI confirmation remains with the orchestrator (see AC-14 in the feature audit). Verdict: PASS.

## Tonality

Grep for hyperbole terms (perfect, flawless, amazing, robust, seamless, and similar) over the changed hooks, the changed tests, and the feature folder returned no matches. Header and test comments are factual. Verdict: PASS.

## Unit test policy

- Location: all new suites are under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, mirroring the production tree. No colocation.
- Temporary files: grep over the new suites for `New-TemporaryFile`, `$env:TEMP`, `TestDrive`, `Set-Location`, `Push-Location`, `Start-Sleep` returned no matches. Matches for `orchestration/orchestrator-state.json` are string constants passed to an injected reader or committed fixture paths resolved from `$PSScriptRoot`; none reads the live gitignored checkpoint.
- Default-reader suites use committed fixtures (`tests/fixtures/worktree-resolution/...`) and include a precondition `It` on fixture tokens.
- Tests use Arrange/Act/Assert structure with descriptive names. No wall-clock dependence.
- The reviewer's run was executed from the repository root; the executor evidence (`P4-T2`) records passes from two directories. Verdict: PASS.

## Coverage verification (PowerShell; artifact `artifacts/pester/powershell-coverage.xml`)

Per-file line coverage, read by `package` path. The executor artifact and the reviewer's independent run agree exactly.

| File | Status | Covered/Missed | Line % | Baseline % | Threshold 85 |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | Modified | 132 / 9 | 93.62 | 92.13 | PASS |
| `.claude/hooks/enforce-completion-helpers.ps1` | Modified | 65 / 2 | 97.01 | 93.02 | PASS |
| `.codex/hooks/enforce-completion-consistency.ps1` | Modified | 148 / 0 (executor); 139 / 9 (reviewer partial run) | 100 (executor) | 100 | PASS |
| `.codex/hooks/enforce-completion-helpers.ps1` | Modified | 59 / 8 | 88.06 | 79.07 | PASS |

- The reviewer's subset run measured `.codex/hooks/enforce-completion-consistency.ps1` at 139/148 = 93.92%, because that run omitted the subprocess/integration suites that execute the entrypoint lines. Both values exceed 85. The executor's full-run artifact shows 100%.
- No file is new; all four production files are modified. No coverage regression: every delta is zero or positive. `p5-changed-lines.md` records all executable changed lines covered.
- PowerShell has no branch metric; no branch threshold applies.
- Verdict for changed files: PASS.

### Repo-wide PowerShell coverage

The artifact report-level LINE counter is covered=8966, missed=6846, giving 56.70%. This is below the 80% and 85% thresholds.

- Verdict: FAIL, recorded as required for a repo-wide figure under 80%.
- Attribution: pre-existing and not attributable to this branch. The four changed files all improved or held their coverage, and the change adds no uncovered production files. The baseline repo-wide figure was not captured in the executor's evidence (only per-file figures), so a repo-wide before/after delta is UNVERIFIED; the per-file deltas imply the branch did not lower it.
- Disposition: listed in `remediation-inputs.2026-10-08T22-30.md` as a pre-existing repo-level item for orchestrator disposition. It cannot be remediated within the scope of this bug fix.

Other languages: zero changed files (Python, TypeScript, C#); coverage verdicts not applicable.

## Coverage Exclusion Policy

No change to coverage configuration files appears in the branch diff. No production path was added to an `exclude` list. Verdict: PASS.

## Module rigor tier

`quality-tiers.yml` classifies `.claude/hooks` and `.codex/hooks` as T3. T3 requires no property-based tests, no mutation tests, and no golden tests. The new pure helpers do not trigger the T1/T2 property-test obligation. Verdict: PASS (the spec risk about an unread tier classification is resolved).

## Toolchain loop evidence

- Format: `p5-format.md` EXIT 0, 14 files unchanged after the route step.
- Analyze: `p5-analyze.md` EXIT 0, `PSSA_FINDINGS=0` for 14 files.
- Type check: not applicable to PowerShell.
- Tests: `p5-pester-run.md` EXIT 2, attributed to two baseline failures (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`) present in the Phase 0 baseline (Passed 3413, Failed 2). Both are outside the eight completion-consistency suites listed in AC-18. The reviewer did not re-run the full repository suite; the reviewer's run of the in-scope suites had zero failures.
- Loop converged in two passes with identical final-pass hashes (`p5-loop-outcome.md`).
- Verdict: PASS. The exit code 2 is a documented, pre-existing condition, not a regression from this branch.

## Fail-closed error handling (general-code-change.md)

Both hooks convert reader exceptions to a structured deny (`checkpoint-unreadable`) via a narrow `try/catch` around the reader call only; the catch returns a specific cause and does not swallow silently. All unresolved, missing, empty, ambiguous, and empty-Write states deny. The checkpoint-path gate remains before the reader, so non-checkpoint targets are not newly denied. Verdict: PASS.

## Plan branch-name deviation

The plan named a branch without the `-exec-` suffix; the working branch carries `-exec-736`. The executor documented the deviation. It affects no artifact path or code. Verdict: PARTIAL (non-blocking; documentation of the deviation exists in the executor notes).

## Counts

- FAIL: 1 (repo-wide PowerShell coverage, pre-existing, non-attributable)
- Blocking PARTIAL: 0
- Non-blocking PARTIAL: 1 (branch-name deviation)
