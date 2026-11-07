# Code Review: parallel-only-test-gates-and-leak-scan (#1094)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094` (`6b8c3640a48e0ea7f1c2c80e8bb89201d8a87164`)
**Review Type:** Re-review after the remediation of RF-5

---

## Executive Summary

The branch changes 303 paths: 232 modified and 71 added. It replaces the repeated serial and shuffled test runs with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, across skills, agents, prompts, and templates in every mirror. It adds one Pester contract suite, changes five Python contract test modules, and adds two Jest cases. No production code changes.

RF-5 and both optional items are closed. This review did not rely on the branch's sweep tokens for that conclusion: it searched the surfaces separately for run, subset, batch, focused, comparison, and baseline phrasing, and read each remaining hit. No passage requires a removed run.

The review then traced the new `N/A - no pre-change run` record through the gates that read a policy audit, and found one defect. The two named policy-audit validators accept the record. The SubagentStop coverage hook does not, which is RF-6.

**What changed since the prior review:**
`staged-review.agent.md` states the parallel gates. The TDD and TypeScript agents carry the debugging statement. Three Copilot passages found by the extended sweep were reworded. The bug template verification steps were reworded. The sweep grew from 33 to 38 tokens, and 8 `PGW-` rows were added.

**Top 3 risks:**
1. After merge, a feature review of a branch that changes PowerShell or TypeScript cannot satisfy both the template and the coverage stop hook, and the hook repeats its block (RF-6).
2. Token sweeps match known phrasing only, so a paraphrase can return without failing a test. Each cycle of this item has found wording outside the token list.
3. Until #1096 lands, no check detects a leak, as the spec records.

**PR readiness recommendation:** **Needs Revision** — one blocking finding remains, in the coverage stop hooks.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and their bundle copies | `Test-LanguageCoverageRow`, the `$narrowingPattern` loop; the same pattern in the Codex hook | RF-6 (blocking): the rule treats `N/A` on a line that also holds a changed-language label and a coverage word as scope narrowing. The branch template and `feature-review-workflow` now prescribe `N/A - no pre-change run` on exactly such lines, so a correctly filled audit is rejected. | Recognize the two sanctioned forms, the `N/A - no pre-change run` record and `Change: N/A` on a comparison line, as non-narrowing, in both hooks and their bundle copies. Keep every other narrowing form rejected. Add a test that runs the rule on the lines the template prescribes. | The review gate and the review template now contradict each other. The block is classed repairable, so it repeats when `stop_hook_active` is true. The required checklist labels leave no compliant wording for PowerShell or TypeScript. This concerns a rejected record, not an absent run. | Real hook from the item worktree on `policy-audit.2026-11-07T04-20.md`: exit 2, and exit 2 again with `stop_hook_active` true. Controls on the rule: a path or numeric value returns Ok; the N/A record returns not Ok, for PowerShell, TypeScript, and Python. The hook is unchanged from the merge base. |
| Info | `.github/agents/tdd-green.agent.md`, and its bundle copy | `## Execution Guidelines`, step 5 | `Run all tests` remains. It names no serial command and no gate, and a full run can be the parallel gate. | No action required. Consider naming the single gate run when the file is next edited. | Consistency with `tdd-refactor`. | Read at head. |
| Info | `.github/agents/staged-review.agent.md`, and its bundle copy | Phase D, step `4) Tests` | The step names the Pester and pytest gates only. A staged TypeScript or C# change has no named test command there. | No action required for this item. | RF-5 specified these two gates; the step says `for the languages in scope`. | Read at head. |
| Info | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, and its copies | `### Baseline Evidence Output Summary (Required)` | The example list cites `767 passed` and `coverage total` as baseline result signals. It is an example, not a requirement, and the file is not in the branch diff. | No action required. Trim the example when the file is next edited. | A reader could infer a test-suite baseline from it. | Read at head. |
| Info | `README.md` | The Python and PowerShell toolchain lists | The lists name `poetry run pytest --cov ...`, `mcp__drm-copilot__run_poshqc_test`, and `Invoke-PoshQCTest`. README text is outside criterion 1, which covers skill, agent, and template text. | No action required for this item. Consider updating it with the #1096 serial command edits. | A reader of the README alone sees the old commands. | Text search at head. |

No file reaches the 700-line advisory tier: the largest changed file has 580 logical lines.

---

## Prior Finding Disposition

| Finding | Status | Verification by this review |
|---|---|---|
| RF-5 | Closed | Step 4 read in both copies; the copies are equal after line-ending normalization; `smallest applicable subset` hits 2 files at `2c5c12a08` and 0 at head. |
| TDD agents (Minor) | Closed | `debugging only` is present in both agents and their copies, pinned by 4 `PGW-` rows. |
| Bug template `[P4-T1]` (Minor) | Closed | `[P4-T1]` re-runs the repro only, and `[P2-T2]` names the parallel gate. The bundle copy shares the blob. |
| `5.1-Beast-adjusted` sample phrase (Info) | No action | Still a sample of narration, not a requirement. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed in this cycle. The prior review's assessment stands: `_section` gained an optional path, and the worktree filter tests parts relative to `REPO_ROOT` with the exclusion set unchanged.

#### Typing and API notes

- No new public Python API surface was added. Pyright reports 0 errors at head.

#### Error handling and logging

- Not applicable; test code only.

### PowerShell implementation audit

#### What changed well

- The 8 added rows pin the text that a sweep token cannot guard, because the step text stays in place.
- The count assertion in `PGW-SWEEP-HELPER` moved with the token list, from 33 to 38.

#### API and safety notes

- Helpers use `CmdletBinding`, `OutputType`, and mandatory parameters. Analyzer findings are 0 at head, and `Invoke-Formatter` output is identical.

#### Error handling and logging

- Not applicable; a missing surface fails the read and therefore the test.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed in this cycle. Prettier, ESLint, and `npm run typecheck` are clean at head.

#### API and safety notes

- No production TypeScript changed.

#### Error handling and logging

- Not applicable; test code only.

---

## Test Quality Audit

All three gates report zero failures. No suite was re-run by this review. Coverage figures were parsed from existing artifacts.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14518 tests, 0 failures, 0 errors, 10 disabled; 56 `PGW-` testcases, all `Passed`; matches the evidence record.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23248 covered, 1519 missed (93.87%).
- `artifacts/python/lcov.info` — 33367 lines, 32270 hit; 12516 branches, 11722 hit; matches the evidence record.
- `coverage/lcov.info` — 68978 lines, 67752 hit; 10737 branches, 10031 hit; matches the evidence record.
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/self-review.2026-11-07T04-51.md` — it does not address the coverage stop hook.

### Quality assessment prompts

- **Determinism:** the tests read committed text or in-memory fixtures and use no clock, randomness, or network.
- **Isolation:** one file per row and one concern per test.
- **Speed:** the Pester gate took 315.77 s and the pytest gate 162.39 s.
- **Diagnostics:** failures name the copy and the offending tokens.
- **Gap:** the contract tests prove the record against the two validators and not against the hook. A wording test cannot show this; a test must call the rule on the prescribed lines.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff holds text and test code only. |
| No unsafe subprocess or command construction | ✅ PASS | The added tests start no process. |
| Input validation at boundaries | N/A | No production boundary changed. |
| Error handling remains explicit | ✅ PASS | No handler added. |
| Configuration / path handling is safe | ✅ PASS | Paths derive from `$PSScriptRoot` and `REPO_ROOT`. A search of the agent diff returns 0 changed tool-entry lines. |

---

## Research Log

No external research was required. The repository and the spec were sufficient.

---

## Verdict

The branch is not ready for a PR. All 14 locally verifiable criteria pass and the toolchain is clean. The remaining work is RF-6: the coverage stop hooks must accept the record that the branch prescribes.
