# Feature Audit: policy-file-consistency-mstest-pester6 (#1106)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106`
**Base Branch:** `origin/main`
**Head Branch:** `chore/policy-file-consistency`
**Work Mode:** `full-feature`
**Audit Type:** Initial feature review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `bad886e304990d26af56d6bcabc9d543518492e9`)
- **Head branch/commit:** `chore/policy-file-consistency` (commit `bd5124f47447099c22731e0ff7d64600eada1e69`)
- **Merge base:** `bad886e304990d26af56d6bcabc9d543518492e9` (equal to the freshly fetched `origin/main` tip, so the branch is current)
- **Evidence sources:**
  - Primary: direct diff `git diff bad886e30 bd5124f47` (98 paths). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree, and the PR-context collector is not in this agent's tool set; recorded as an assumption.
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/` in the feature folder
  - Additional evidence: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, `artifacts/orchestration/orchestrator-state.json`, merge-base CI run 42366932636, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** the audit scope is the full diff against the merge base. Orchestrator decisions D1 to D7 (checkpoint `orchestrator_decisions`, spec `## Scope` and `### Decision record`) and the owner authorization and rulings (checkpoint `owner_decisions`) were applied as the review baseline.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/spec.md` — 14 criteria (S1 to S14)
- `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/user-story.md` — 9 criteria (U1 to U9)

### Acceptance criteria

- S1. No rule, instruction, agent, skill, prompt, template, README, or bundle copy names xUnit as the C# test framework; the prohibition and the generic CI list keep the word.
- S2. Every C# surface names MSTest and uses MSTest idioms.
- S3. Each C# profile names one runner and command set.
- S4. The spec records why one runner for every C# surface was not chosen.
- S5. No surface states Pester v5 or v5.x as the supported version; historical references unchanged.
- S6. No approved or emitted command carries `--cov=src/lexile_corpus_tuner`; former sites target `--cov=scripts/dev_tools`; dead per-file-ignore removed; `test_qc_runner.py` asserts the new argv.
- S7. The PR description states the D3 Python behavior change.
- S8. Other-project example text is replaced in the D4 surfaces and bundles; `clean_devcontainer.py` names and `LEXILE_TK_SCALE` unchanged.
- S9. Every changed mirror and bundle copy is byte-identical; generated Codex variants match the generator; Q4 parity and contract tests pass.
- S10. The `>= 90%` rule, the 85%/75% thresholds, and parallel-only wording are byte-unchanged; same-line edits change only the named token.
- S11. The owner authorization is recorded in the orchestrator checkpoint and the PR body.
- S12. The guard test exists, passes, and its helper test fails on reintroduced text.
- S13. The Pester and pytest gates pass with zero failures and no coverage drop on changed lines.
- S14. Each changed Python file meets 85% line and 75% branch coverage from the gate run.
- U1. Any C# surface tells an agent to use MSTest; none names xUnit as the framework.
- U2. Each C# surface has one runner and command set for its profile.
- U3. Any PowerShell surface states Pester v6.
- U4. No approved or emitted Python coverage command, VS Code task, or atomic-executor argv carries the stray path.
- U5. Policy surfaces and bundles use neutral example names.
- U6. Bundles are identical to canonical sources; generator `--check`, parity, and contract tests pass.
- U7. The `>= 90%` rule, the thresholds, and the parallel-only wording are byte-unchanged.
- U8. Reintroducing a forbidden phrase makes the guard fail; it passes with the change.
- U9. Both gates pass with zero failures, no changed-line coverage drop, and each changed Python file at 85%/75% or higher.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|-------------------------|-------|
| S1 | No surface names xUnit as the framework | PASS | `git grep -i xunit` over all policy roots and bundles at head returns only the two D6 lines (and their bundle copies) | `git grep -n -i xunit -- .claude .github .agents .codex docs/features/templates README.md extensions/drm-copilot/resources` | Legacy `-variants` trees were excluded from the search per the spec invariant |
| S2 | MSTest named with MSTest idioms | PASS | Word diff of `.claude/rules/csharp.md`: `[TestClass]`/`[TestMethod]`, `[DataRow]`, `[ClassInitialize]`, MSTest `Assert`, `Verify.MSTest`; `tdd-red` `[DataRow]`; no `[Fact]`, `[Theory]`, `InlineData`, `IClassFixture`, or `Verify.Xunit` remains | `git diff --word-diff=plain` and `git grep` at head | |
| S3 | One runner per profile | PASS | `dotnet test` appears only in the modern Claude pack; `csharp-atomic-executor` agent and TOML name `msbuild` and `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`, verbatim from `csharp-unit-test.instructions.md` section 3; `.agents/skills/csharp` names `vstest.console.exe` | `git grep -n "dotnet test" -- .github .codex .agents` (no match) | Modern pack also names the MSTest package set |
| S4 | D1 decision record | PASS | `spec.md` `### Decision record: one runner per profile (D1)`; checkpoint `orchestrator_decisions` D1 | Read | |
| S5 | Pester v6 as supported version | PASS | No `Pester (v5`, `Pester v5`, or `Pester 5` in any policy root or bundle at head; the CHANGELOG and test-file references are not in the diff | `git grep -n -E "Pester \(v5|Pester v5|Pester 5"` over policy roots | Test comments untouched, per invariant |
| S6 | Stray coverage path removed | PASS | No match for the path in policy roots, bundles, `scripts/dev_tools`, or `.vscode/tasks.json`; `FULL_TEST` uses `--cov=scripts/dev_tools`; `pyproject.toml` entry removed; `test_qc_runner.py` asserts the new argv | `git grep`; reviewer pytest run of the three changed files (debugging only); gate `test_qc_runner.py` 24 passed | |
| S7 | PR description states the D3 change | PENDING | Text prepared in `evidence/other/pr-body-notes.2026-11-07T15-26.md` `## D3 Python behavior change` | `gh pr list --head chore/policy-file-consistency` returned `[]` | Pending pr-author; not a finding |
| S8 | Neutral example names | PASS | No `lexile` or `gutenberg` in any policy root or bundle; `clean_devcontainer.py` names and `LEXILE_TK_SCALE` unchanged | `git grep -n -i -E "lexile|gutenberg"` | Two non-D4 strings remain (code-review Info row) |
| S9 | Byte-identical mirrors, generator, contract tests | PASS | 29 of 29 pairs equal by `cmp`; generator `--check` exit 0 (re-run by this review); Q4 suites pass in the gate | `cmp`; `generate_codex_agent_variants --check` | |
| S10 | Protected wording byte-unchanged | PASS | No changed line outside the feature folder contains `>= 90%`, `85%`, or `75%`; the only changed lines with parallel wording change `v5` to `v6` only | `git diff -U0` filtered for protected tokens; word diff | |
| S11 | Owner authorization in checkpoint and PR body | PENDING | Checkpoint `owner_decisions[0]` confirmed by this review; PR-body text prepared in `evidence/other/pr-body-notes.2026-11-07T15-26.md` | Read of `artifacts/orchestration/orchestrator-state.json` | Checkpoint part PASS; PR-body part pending pr-author |
| S12 | Guard exists, passes, can fail | PASS | 18 `PTN-` rows pass in the gate; the extracted scan function reports 8, 1, 1, 2, 2, 2 hits on merge-base text of six changed files and 0 on HEAD text | Pester gate; reviewer AST probe | |
| S13 | Gates pass, no changed-line drop | PASS | Pester 15571 tests, 0 failed; pytest 16204 tests, 0 failures; changed lines executed | Gate evidence; `artifacts/python/lcov.info` | |
| S14 | Changed Python files at 85%/75% | PASS | `qc_runner` 93.20%/77.78%; `qc_toolchain` 100%/no branches; `cli_preflight` 100%/98.72%; `prompt_builder` 100%/100%; `fix_all_branches_extra` 100%/100% | Parsed `artifacts/python/lcov.info` | |
| U1 | MSTest on every C# surface | PASS | Same as S1 and S2 | As S1, S2 | |
| U2 | One runner per profile | PASS | Same as S3 | As S3 | |
| U3 | Pester v6 on PowerShell surfaces | PASS | Same as S5 | As S5 | |
| U4 | No stray path in commands, tasks, or argv | PASS | Same as S6 | As S6 | |
| U5 | Neutral example names | PASS | Same as S8 | As S8 | |
| U6 | Bundles identical, generator and contract tests pass | PASS | Same as S9 | As S9 | |
| U7 | Protected wording unchanged | PASS | Same as S10 | As S10 | |
| U8 | Guard fails on reintroduced text, passes otherwise | PASS | Same as S12 | As S12 | |
| U9 | Gates pass and coverage thresholds met | PASS | Same as S13 and S14; repo-wide Python at least 96.94% lines and 92.83% branches (policy audit Section 1.2.1) | As S13, S14 | |

---

## Summary

- 21 of 23 criteria evaluate as PASS. S7 and S11 are pending until the PR exists, because they depend on the PR body. Their text is prepared in `evidence/other/pr-body-notes.2026-11-07T15-26.md`. They are not findings and carry no remediation entry.
- No criterion is FAIL, PARTIAL, or UNVERIFIED.
- No blocking finding exists, so no `remediation-inputs` file was written for this review.
- Non-blocking items (one file-size Warning, three Minor, and three Info rows) are in `code-review.2026-11-07T15-31.md`.
- Recommendation: proceed to pr-author. The PR body must include the owner authorization and the D3 behavior change, after which S7 and S11 can be checked off.

---

## Acceptance Criteria Check-off

All PASS items were already checked off in the source files by the executor (P5-T6), and this review confirmed each one. No item was newly checked off by this review. S7 and S11 stay unchecked as pending.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/spec.md`, `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/user-story.md`
- Total AC items: 23 (spec 14, user story 9)
- Checked off (delivered): 21 (spec 12, user story 9)
- Remaining (unchecked): 2
- Items remaining:
  - spec.md: "The PR description states the D3 Python behavior change (coverage now targets an existing package)." (pending pr-author)
  - spec.md: "The owner authorization for editing canonical policy files is recorded in the orchestrator checkpoint and the PR body." (pending pr-author; checkpoint part verified)
