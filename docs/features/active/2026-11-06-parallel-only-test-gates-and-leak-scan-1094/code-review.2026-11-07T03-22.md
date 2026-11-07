# Code Review: parallel-only-test-gates-and-leak-scan (#1094)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
**Head Branch:** `feature/parallel-only-test-gates-and-leak-scan-1094` (`f59b9caab5344611ee11008dc2af5bd3fb924fb5`)
**Review Type:** Initial review

---

## Executive Summary

The branch changes 248 files: 219 modified and 29 added. It replaces the repeated serial and shuffled test runs with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, across skills, agents, prompts, and templates in every mirror. It adds one Pester contract suite and changes five Python contract test modules. No production code changes. The review inspected the diff, `artifacts/pr_context.summary.txt`, the gate evidence, the coverage artifacts, and re-ran the static Python tools at head.

The brief, plan contract, QA gate skills, review workflow, and policy-audit template are consistent and mirrored. The wording sweep is the weak point: its token list misses three phrasings, so a before-and-after coverage requirement and required per-batch focused runs survive in agents that this branch edited. The Python coverage artifact is also below threshold because of a worktree measurement defect.

**What changed:**
`## Test Isolation Checks`, `## Test Runtime`, `## CI-Only Failure Classes`, and `## PowerShell Route and PoshQC MCP Limits` in the `execution-environment` brief state the parallel gates. `atomic-plan-contract` limits baselines to static tools. The policy-audit template records its retained baseline fields as `N/A - no pre-change run`. New contract tests pin this text.

**Top 3 risks:**
1. Agents following `powershell-typed-engineer`, `csharp-typed-engineer`, or `pytest-unit-test-coding` still receive a coverage comparison requirement that cannot be met without a pre-change run.
2. Required after-each-batch targeted test runs keep the repeated-run cost the owner removed.
3. Until #1096 lands, no check detects a leak, as the spec records.

**PR readiness recommendation:** **Needs Revision** — four blocking findings remain, all remediable with text, test, and measurement work and no production change.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.github/agents/pytest-unit-test-coding.agent.md`, `.github/agents/Powershell DI Unit Test Engineer.agent.md`, and bundle copies | Phase C batch bullets; objective list; `## 4) Quality gates (hard stop)` | RF-1: `Confirm coverage does not regress for touched files.` and `Coverage does not regress for any file you touch` remain. `Any failure in the single gate run compared to baseline` was written by this branch. | State the coverage rule from the single gate run, drop `compared to baseline`, and apply to all eight files. | Spec `### 1` removes every before-and-after comparison of test or coverage figures. | Grep at head; the same lines exist at `origin/main`, except the DI line, which is in the branch diff. |
| Major | `.claude/agents/{powershell,python,csharp}-typed-engineer.md`, `.codex/agents/*-typed-engineer.toml`, `.github/agents/{powershell,csharp,python}-typed-engineer.agent.md`, `.github/agents/python-execution-only-typed.agent.md`, `.github/agents/pytest-unit-test-coding.agent.md`, `.github/agents/Powershell DI Unit Test Engineer.agent.md`, and bundle copies | `Implement in batches` step; `### Iteration runs (required after each batch)`; `## Phase C` | RF-2: agent text requires targeted Pester, Pytest, MSTest, or xUnit runs after each batch, plus per-file coverage confirmation. The branch removed the same requirement from the DI agent prompt and left its `Iteration runs` section. | Require static checks per batch only. State that a focused run is for debugging one failure, and that coverage is read from the single gate run. | The brief states that a focused run is debugging only, and that a suite is re-run only after a fix. | Grep at head: 56 files including generated variants and bundles. |
| Major | `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py`; `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts` | New validator tests | RF-3: the contract test exercises the Python validator only. Spec `## Constraints & Risks` names the TypeScript twin, and the criterion names the validators. The TypeScript test file has no `no pre-change` case. | Add a Jest case that passes the same record through `validatePolicyAuditSubstantiveRequirements`, and one that pins the regex reach. | The twin accepts the record only through the same permissive regex, and a change in one runtime would not fail any test. | Grep count 0 in the Jest file. Source reading shows the same regex and `isNaValue` logic. This audit, validated through the MCP tool, is a single run, not a pinned test. |
| Major | `artifacts/python/lcov.info` | Repo-wide totals | RF-4: the artifact reports 49.52% line and 45.29% branch, below 85% and 75%. `packages/discovery-runtime` measures 0% over 140 files because `drm_copilot_discovery` resolves to the main checkout through the shared `.venv`. The self-review recorded PASS. | Re-run the pytest gate after the RF-1 to RF-3 fixes with `PYTHONPATH` naming the worktree `packages/discovery-runtime/src`, and record the totals. | Coverage verdicts come from the artifact. The cause is now verified, but the recorded figure stays below threshold. | `scripts/dev_tools` 94.27% line, 89.10% branch; import probe with and without `PYTHONPATH`. |
| Minor | `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | `$script:SweepToken` | The sweep has no token for `does not regress`, `compared to baseline`, or required targeted runs, which is how RF-1 and RF-2 passed. | Add tokens with the RF-1 and RF-2 fixes, keeping the debugging exception unmatched. | Prevents the same wording from returning. | Replay of the 21 tokens at head: 894 files, 0 hits, while RF-1 text is present. |
| Minor | `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | `test_contract_premortem_test_isolation_states_parallel_gates` | Removed tokens are matched on uncollapsed text, so a token wrapped across lines would not match. The brief test collapses whitespace. | Apply `_collapse`-style normalization. | Keeps both negative tests equally strict. | Diff inspection. |
| Info | `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/` | Gate records | The gates ran before merge commit `f59b9caab`, which brought 89 files from `origin/main`. | No separate action; the remediation re-run and CI cover the merged head. | The evidence describes the tree before the merge. | `git log`; `git diff --stat HEAD^1 HEAD`. |

No file reaches the 700-line advisory tier: the largest changed file has 580 logical lines.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_section` gained an optional path, so every brief copy is checked without a second helper.
- The worktree filter now tests parts relative to `REPO_ROOT`, with the exclusion set and copy count unchanged.
- `test_validate_policy_audit_text_accepts_no_pre_change_run_record` asserts that each replacement applies, so a stale fixture cannot pass vacuously.

#### Typing and API notes

- No new public Python API surface was added. Pyright reports 0 errors at head.

#### Error handling and logging

- Not applicable; test code only.

### PowerShell implementation audit

#### What changed well

- The suite is table-driven, reads files in place, and writes nothing.
- A replay against `origin/main` text showed all 46 rows would fail there, so each row discriminates.

#### API and safety notes

- Helpers use `CmdletBinding`, `OutputType`, and mandatory parameters. Analyzer findings are 0.

#### Error handling and logging

- Not applicable; a missing surface fails the read and therefore the test.

---

## Test Quality Audit

Both parallel gates report zero failures. No suite was re-run by this review. Coverage figures come from existing artifacts.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14452 tests, 0 failures, 0 errors, 10 disabled, 48 `PGW-` testcases; matches the evidence record.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23175 covered, 1519 missed (93.85%).
- `artifacts/python/lcov.info` — 33367 lines, 16522 hit; 12516 branches, 5669 hit; matches the evidence record.
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/self-review.2026-11-07T03-12.md` — records Python coverage as PASS, which the figures do not support.

### Quality assessment prompts

- **Determinism:** the tests read committed text and use no clock, randomness, or network.
- **Isolation:** one file per row and one concern per Python test.
- **Speed:** the sweep reads 894 files in one test; the Pester gate took 321.78 s overall.
- **Diagnostics:** failures name the copy and the offending tokens.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff holds text and test code only. |
| No unsafe subprocess or command construction | ✅ PASS | The added tests start no process. |
| Input validation at boundaries | N/A | No production boundary changed. |
| Error handling remains explicit | ✅ PASS | No handler added. |
| Configuration / path handling is safe | ✅ PASS | Paths derive from `$PSScriptRoot` and `REPO_ROOT`. No tool-permission entry changed. |

---

## Research Log

No external research was required. The repository, GitHub run 42329060481, and the spec were sufficient.

---

## Verdict

The branch is not ready for a PR. The core change is sound, and the remaining work is limited to agent text, two contract test additions, and one correctly measured gate run. After remediation, one parallel gate run also covers the merge of `origin/main`.
