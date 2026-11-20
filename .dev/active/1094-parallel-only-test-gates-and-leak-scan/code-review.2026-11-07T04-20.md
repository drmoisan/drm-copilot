# Code Review: parallel-only-test-gates-and-leak-scan (#1094)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094` (`2c5c12a0885f2ff1e45e78a18919e5a179c4584a`)
**Review Type:** Re-review after the remediation of RF-1 to RF-4

---

## Executive Summary

The branch changes 282 paths: 226 modified and 56 added. It replaces the repeated serial and shuffled test runs with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, across skills, agents, prompts, and templates in every mirror. It adds one Pester contract suite, changes five Python contract test modules, and adds two Jest cases. No production code changes.

The four prior blocking findings are closed. This review did not rely on the branch's sweep tokens for that conclusion: it replayed the tokens against base and head, parsed each coverage artifact, and searched the surfaces separately for verb-and-test phrasing and coverage comparison phrasing. That search found one passage of the RF-2 class that no prior pass reached.

**What changed since the prior review:**
Per-batch steps in the typed-engineer and test-writing agents keep static tools only and carry the debugging statement. Coverage comparisons became the threshold rule. The sweep grew from 21 to 33 tokens. Two Jest cases pin the `N/A - no pre-change run` record. The pytest gate was re-run so that the discovery package resolves inside the worktree.

**Top 3 risks:**
1. A reader of `staged-review.agent.md` still receives a subset run as a required review step, with its output recorded as evidence (RF-5).
2. Token sweeps match known phrasing only. RF-1, RF-2, and RF-5 each survived because the wording differed from the token list, so a paraphrase can return without failing a test.
3. Until #1096 lands, no check detects a leak, as the spec records.

**PR readiness recommendation:** **Needs Revision** — one blocking finding remains, resolved by a text edit to two files and one sweep token.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.github/agents/staged-review.agent.md`, and its copy under `extensions/drm-copilot/resources/customizations/.github/agents/` | Phase D, step `4) Tests`, and the `Rules:` list below it | RF-5 (blocking): the review step states `Run the smallest applicable subset covering staged changes first (repo-specific)`, then `Then run the repo-required full test suite if policy requires it or if failures were found`. The next rule directs that outputs are referenced in `PolicyAudit.md` evidence fields. | Replace step 4 with the parallel gates, once each, and the debugging statement. Add `smallest applicable subset` to `$script:SweepToken` and update the `PGW-SWEEP-HELPER` count to 34. | Spec `### 1` states that a focused run is never a gate or evidence, and directs an update to any other reviewer text. The branch removed the sibling wording `smallest relevant subset` from `feature-review-workflow` and pinned its absence. The passage also makes the full suite conditional, so a staged review can rest on the subset alone. | Text search at head: these two files are the only hits across `.claude`, `.github`, `.agents`, `.codex`, the templates, and the bundles. Neither file is in the branch diff, and neither is in research table A3. |
| Minor | `.github/agents/tdd-green.agent.md`, `.github/agents/tdd-red.agent.md`, and bundle copies | `## Execution Guidelines`, steps 2 and 5 | `Run the failing test` and `Run the test to confirm it fails` remain as workflow steps. They name no serial command and act as neither a gate nor recorded evidence, so they are consistent with debugging use. The branch edited the sibling `tdd-refactor` agent and left these two. | Add the debugging statement during the RF-5 edit, so all three TDD agents read alike. Not required for this item. | Consistency across the three agents. | Text search at head. |
| Minor | `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, and its bundle copy | `[P4-T1]` | `Re-run repro and regression test to confirm expected behavior` sits in the verification phase, ahead of the gate task `[P4-T2]`. Read literally, a planner could cite that run as evidence. | Reword to re-run the repro only, and leave the test result to the gate in `[P4-T2]`. Not required for this item. | Keeps the plan template aligned with the rule that focused runs are not evidence. | Read at head. |
| Info | `.github/agents/5.1-Beast-adjusted.agent.md` | Line in the sample phrases block | `"I will run the tests now to verify the change."` is a sample of agent narration, not a requirement. | No action. | Recorded so that a later sweep does not treat it as a new finding. | Read at head. |
| Info | `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | `test_contract_premortem_test_isolation_states_parallel_gates` | The prior review's Minor finding, that removed tokens are matched on uncollapsed text, was inaccurate. `_read` already returns whitespace-collapsed text. | No action; closed. | Correction of a prior finding. | `_read` body at head. |

No file reaches the 700-line advisory tier: the largest changed file has 580 logical lines.

---

## Prior Finding Disposition

| Finding | Status | Verification by this review |
|---|---|---|
| RF-1 | Closed | The four comparison tokens hit 6, 16, 2, and 2 files at the merge base and 0 at head, over 902 surface files with whitespace collapsed. |
| RF-2 | Closed | The targeted-run tokens hit 2 to 18 files at the merge base and 0 at head. Step text read in the Claude, Codex, and Copilot agents. The Codex generator `--check` exits 0. |
| RF-3 | Closed | Two Jest cases read in the diff; the second asserts both acceptance and rejection. The validator source is unchanged. Both cases passed in the Jest gate, per its evidence. |
| RF-4 | Closed | `artifacts/python/lcov.info` parsed: 96.71% line, 93.66% branch; `packages/discovery-runtime` 99.41% line over 140 files. |
| Sweep tokens (Minor) | Closed | 33 tokens, and the helper count assertion equals 33. RF-5 shows that the list is still incomplete. |
| Gates predate merge (Info) | Closed | All gates postdate the last change outside the feature folder. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_section` gained an optional path, so every brief copy is checked without a second helper.
- The worktree filter tests parts relative to `REPO_ROOT`, with the exclusion set and copy count unchanged.
- `test_validate_policy_audit_text_accepts_no_pre_change_run_record` asserts that each replacement applies, so a stale fixture cannot pass vacuously.

#### Typing and API notes

- No new public Python API surface was added. Pyright reports 0 errors at head.

#### Error handling and logging

- Not applicable; test code only.

### PowerShell implementation audit

#### What changed well

- The suite is table-driven, reads files in place, and writes nothing.
- The 12 added tokens match no debugging statement and no retained policy-audit anchor, as the green gate shows.

#### API and safety notes

- Helpers use `CmdletBinding`, `OutputType`, and mandatory parameters. Analyzer findings are 0 at head.

#### Error handling and logging

- Not applicable; a missing surface fails the read and therefore the test.

### TypeScript implementation audit

#### What changed well

- `replaceRequired` throws on stale fixture text, which matches the Python test's guard.
- The second case pins the permissive regex from both sides, by asserting acceptance with a later percentage and rejection without one.

#### API and safety notes

- No production TypeScript changed. Prettier, ESLint, and `npm run typecheck` are clean at head.

#### Error handling and logging

- Not applicable; test code only.

---

## Test Quality Audit

All three gates report zero failures. No suite was re-run by this review. Coverage figures were parsed from existing artifacts.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14510 tests, 0 failures, 0 errors, 10 disabled, 48 `PGW-` testcases; matches the evidence record.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23248 covered, 1519 missed (93.87%).
- `artifacts/python/lcov.info` — 33367 lines, 32270 hit; 12516 branches, 11722 hit; matches the evidence record.
- `coverage/lcov.info` — 68978 lines, 67752 hit; 10737 branches, 10031 hit; matches the evidence record.
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/self-review.2026-11-07T04-09.md` — its coverage figures match the artifacts. It does not address `staged-review.agent.md`.

### Quality assessment prompts

- **Determinism:** the tests read committed text or in-memory fixtures and use no clock, randomness, or network.
- **Isolation:** one file per row and one concern per test.
- **Speed:** the Pester gate took 392.79 s and the pytest gate 168.32 s.
- **Diagnostics:** failures name the copy and the offending tokens.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff holds text and test code only. |
| No unsafe subprocess or command construction | ✅ PASS | The added tests start no process. |
| Input validation at boundaries | N/A | No production boundary changed. |
| Error handling remains explicit | ✅ PASS | No handler added. |
| Configuration / path handling is safe | ✅ PASS | Paths derive from `$PSScriptRoot` and `REPO_ROOT`. The scope check records 0 files with changed tool-entry lines. |

---

## Research Log

No external research was required. The repository and the spec were sufficient.

---

## Verdict

The branch is not ready for a PR. The prior findings are resolved and the toolchain is clean. The remaining work is one passage in one agent, its bundle copy, and one sweep token.
