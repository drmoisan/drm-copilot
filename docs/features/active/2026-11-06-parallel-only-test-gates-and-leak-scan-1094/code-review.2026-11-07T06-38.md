# Code Review: parallel-only-test-gates-and-leak-scan (#1094)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/main` (merge base `51d3886485956df68a68a38e920c7c3687ec4462`)
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094` (`3c842ab7f9dce9aca98b47866e69b54047b734a7`)
**Review Type:** Re-review after the remediation of RF-6 and the process-reduction ledger addendum

---

## Executive Summary

Outside the feature folder the branch changes 242 paths: 237 modified and 5 added. It replaces the repeated serial and shuffled test runs with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run across skills, agents, prompts, and templates in every mirror. It changes one rule in the two coverage stop hooks, adds two Pester suites, changes four Python contract test modules and one Jest file, and adds ledger entry 0001.

RF-6 is closed. `Get-CoverageNarrowingLine` accepts the `N/A - no pre-change run` record in the three positions the template prescribes, and every other narrowing form stays rejected. The rule is byte-identical in both hooks. This review did not rely on the suite alone: it called the rule directly on the suite's cases, evaluated 14 reverted mutants, and ran both real hooks on the policy audit of this review.

Ledger entry 0001 passes the repository checker, and its stored patch restores the merge base for all 238 reduction paths.

**What changed since the prior review:**
The hook rule and its parity suite, the spec's record of the hook change, the merge of `origin/main` (ledger module, ledger README, and the ledger rule in the `feature-review-workflow` copies), and the ledger entry.

**Top 3 risks:**
1. Until #1096 lands, no check detects a leak, as the spec records.
2. No test run has covered the merged tree. CI on the PR head is that run, and it is the first run of `PRL-REAL-LEDGER-AGREES` against a real entry.
3. The ledger entry names a PR number that belongs to another open PR until it is corrected.

**PR readiness recommendation:** **Ready** — no blocking finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` | `## Summary`, `Merge commit:` line | The line reads `pending (PR #1101)`. `#1101` is an open PR of another branch, `Stage B: stage timing (#1097)`, head `feature/reduce-feature-cycle-time`. The number is provisional by design, but it cannot be right for this branch. | After this branch's PR opens, replace the number in a commit holding only the entry, with `reduction: 0001` in its subject, before the S9 gate. | A revert months later uses this line to find the merge. Left as it is, it points to an unrelated PR. The checker accepts any number, so no gate catches it. | `gh pr view 1101` returned that title, head, and an open state. `gh pr list --head` for this branch returned no PR. That PR's file list has no ledger file and no overlap with this branch's skills or hooks. |
| Minor | `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` | `$rejectTable` | Two guards of `Get-CoverageNarrowingLine` have no discriminating row. Removing the `(?<![\w/-])` lookbehind or the `(?<!:\s*)` guard changes no result across the suite's line cases. | Add two `FRN-REJECT` rows: `- Python: Baseline: N/A - no pre-change run -> Post-Change: N/A. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS.` and ``- Python post-change coverage: `N/A - no pre-change run` ``. | The Codex hook description states the colon rule, so it is intended behavior. Both guards work at head, and line coverage is complete, so the gap is limited to a later edit removing a guard unnoticed. | Direct-call mutant probe: 12 of 14 mutants changed a result. On the unmodified rule both proposed lines are reported as narrowing. |
| Info | Branch history | `20e1cb1cc` | The reduction spans the branch's earlier commits, so it is not its own commit as `### Process-reduction ledger` describes. The token commit holds the record only. | No action. | The rule reached the branch through `5483ba240`, after the last code commit `9c4049cb8`. The entry's `## Summary` states this. The rule's Blocking condition is a reduction with no entry. | `git log` of the branch; `dfbb071d5` on `main`. |
| Info | `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1` | `Get-CoverageNarrowingLine` | The function is copied into both hooks, and a backticked record in prose is accepted on a coverage line, for example ``Python coverage is `N/A - no pre-change run` for this branch``. | No action. Consider a shared file if a third surface needs the rule. | The surfaces ship separately, and `FRN-PARITY` pins equal text. The backtick form exists so audits can quote the record. The verdict and repo-wide figure checks still apply to such a line. | Definition text read at head; direct-call probe. |
| Info | `user-story.md` | `## Problem / Why`, last paragraph | The text still says the item is text and contract tests only. Spec `## Constraints & Risks` supersedes that wording for `## Overview`, `### 2. Out of scope`, and `## Implementation Strategy`, and does not name the user story. | Update the sentence when the file is next edited. | A reader of the story alone does not learn of the hook change. No criterion depends on it. | Read at head. |
| Info | `README.md` | The Python and PowerShell toolchain lists | The lists name `poetry run pytest --cov ...`, `mcp__drm-copilot__run_poshqc_test`, and `Invoke-PoshQCTest`. README text is outside criterion 1. | Consider updating it with the #1096 serial command edits. | Carried from the prior review. | Text search at head in the prior review; the file is not in the diff since. |
| Info | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, and its copies | `### Baseline Evidence Output Summary (Required)` | The example list cites `767 passed` and `coverage total` as baseline result signals. It is an example, not a requirement. | Trim the example when the file is next edited. | Carried from the prior review. | Read in the prior review; the file is not in the branch diff. |

No file reaches the 700-line advisory tier: the largest changed covered file has 580 logical lines.

---

## Prior Finding Disposition

| Finding | Status | Verification by this review |
|---|---|---|
| RF-1 to RF-5 | Closed | 0 hits for the 38 sweep tokens over 894 surface files at head, by a separate search. None of those surfaces changed since the prior review except the six `feature-review-workflow` copies, which gained the ledger rule through the merge. |
| RF-6 | Closed | Both hooks and bundle copies read and compared; the suite's 30 line cases and 2 section cases called directly with 0 wrong results; 14 mutants evaluated; real hook runs on `policy-audit.2026-11-07T06-38.md` exit 0 on both surfaces. |
| Ledger entry absent | Closed | Checker valid, patch reversible, file list complete, token commit holds the three files. |
| `Run all tests` in `tdd-green.agent.md` (Info) | No action | Unchanged; names no serial command. |
| `staged-review.agent.md` names two gates (Info) | No action | Unchanged. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed since the prior review. `test_discovery_documentation_contracts.py` left the branch diff because `main` holds the same worktree filter after the merge.

#### Typing and API notes

- No new public Python API surface was added. Pyright exits 0 at head.

#### Error handling and logging

- Not applicable; test code only.

### PowerShell implementation audit

#### What changed well

- The record is removed only in its three prescribed positions, so the existing narrowing pattern stays unchanged and `\bN/A\b` stays in it.
- The `Change: N/A` and `New/changed-code coverage` removals are gated on the original line carrying the record, and the mutant probe confirms that gate is pinned.
- Codex alignment, including the rejected-section skip and the `.NET` label correction, follows from the requirement that both hooks behave the same. `\.NET` passed through `[regex]::Escape` did not match `.NET`.

#### API and safety notes

- `CmdletBinding`, `OutputType`, and mandatory parameters are present. Analyzer findings are 0 and `Invoke-Formatter` output is identical for all 7 files.

#### Error handling and logging

- The rule fails closed: a line outside the allow-list stays reported.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed since the prior review. Prettier, ESLint, and `npm run typecheck` are clean at head.

#### API and safety notes

- No production TypeScript changed.

#### Error handling and logging

- Not applicable; test code only.

---

## Test Quality Audit

All three gates report zero failures. No suite was run by this review. Coverage figures were parsed from existing artifacts, and the mutant and rule probes were direct calls, not test runs.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14584 tests, 0 failures, 0 errors, 10 disabled; matches the evidence record.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23275 covered, 1519 missed (93.87%); rules file 98 of 99, Codex hook 163 of 163.
- `artifacts/python/lcov.info` — 33367 lines, 32270 hit; 12516 branches, 11722 hit; matches the evidence record.
- `coverage/lcov.info` — 68978 lines, 67752 hit; 10737 branches, 10031 hit; matches the evidence record.
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/ledger-check.2026-11-07T06-25.md` — confirmed by a separate checker call and patch application.
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/self-review.2026-11-07T06-27.md` — it states the merge caveat and the provisional PR number.

### Quality assessment prompts

- **Determinism:** the tests read committed text or in-memory fixtures and use no clock, randomness, or network.
- **Isolation:** one case per row, and each hook is dot-sourced in its own child scope.
- **Speed:** the Pester gate took 317.45 s and the pytest gate 177.80 s.
- **Diagnostics:** failures name the surface and the reported reason.
- **Gap:** two regular-expression guards have no discriminating row, as the Findings Table states.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff holds text, tests, and one string rule. The stored patch holds no host path: a search for the user path forms returned 0. |
| No unsafe subprocess or command construction | ✅ PASS | The added code starts no process. |
| Input validation at boundaries | ✅ PASS | The rule reads audit text as data and evaluates none of it. |
| Error handling remains explicit | ✅ PASS | No handler added. |
| Configuration / path handling is safe | ✅ PASS | Paths derive from `$PSScriptRoot` and `REPO_ROOT`. Tool-entry lines were unchanged per `scope-check.2026-11-07T06-03.md`. |

---

## Research Log

No external research was required. The repository and the spec were sufficient.

---

## Verdict

The branch is ready for a PR. All 14 locally verifiable criteria pass, the toolchain is clean, and no blocking finding remains. Correct the PR number in the ledger entry once the PR exists, before the S9 gate.
