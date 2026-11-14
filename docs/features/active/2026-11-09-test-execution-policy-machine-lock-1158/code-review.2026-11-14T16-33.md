# Code Review: Test-execution policy and machine test-suite lock (#1158), review at the PR #1184 head

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Feature Folder Selection Rule:** the only feature folder carrying issue #1158; no version subfolder
**Base Branch:** `main` (merge base `add7d747886ce893356b63de2941435f2895b345`; `origin/main` fetched and unchanged)
**Head Branch:** `feature/test-execution-policy-machine-lock-1158` at `9262895e3b135d1daee942f3239fe9b926a127ef` (PR #1184)
**Review Type:** Review at the live pull-request head after the S9 check-off; scope is the full branch diff

---

## Executive Summary

The branch introduces a test-execution policy: local runs exclude the integration and golden lanes, at most one test suite runs per machine (per user) under an OS advisory file lock, and suites run only through a recognizable launcher enforced by a PreToolUse hook in the Claude and Codex runtimes. The change set is 370 files (25612 insertions, 510 deletions).

The previous review (`code-review.2026-11-14T15-47.md`, head `6a6a85a23`) found no blocking issue. The three commits since then change documentation only: the previous review records, the `Merge commit:` line of ledger entry `0012` (now `pending (PR #1184)`), a stage-timing record, the S9 CI check-off record, and the spec Definition of Done line 348 check-off. The reviewer confirmed with `git diff --name-only 6a6a85a23..9262895e3` that no production, test, configuration or script file changed. The full CI run 43613054239 on `171fa263c` (code identical to the reviewed head) concluded success on every job, which closes the risk the previous review listed first (pending Linux hook-suite and CI integration-lane results).

**What changed (since the previous review):**
Documentation records only; see above.

**Top 3 risks:**
1. On Windows, two spellings of one test path that differ only in letter case resolve to two entries in a scoped run (informational; operator input error).
2. The hook remains a policy-level control: unspecified forms (`watch`, `ionice`, `pnpm`, `yarn`, `make`, `tox`, `nox`) pass, as disclosed in the spec.
3. The MCP test template stays outside the Pester coverage roots (pre-existing configuration; exercised by `PoshQC.McpTemplateLock.Tests.ps1`).

**PR readiness recommendation:** **Ready** — no blocking finding; CI green on the PR head and `CLEAN` merge state.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md` | Definition of Done, line 348 | Pending-CI criterion of the previous review. Now checked off at S9 against the full CI run. | None. | The check-off follows the CI-Dependent Criteria rule (owner: the item's orchestrator run, after CI success). | `evidence/qa-gates/ci-dependent-ac-checkoff.2026-11-14T16-26.md`; reviewer `gh run view 43613054239`: `pull_request`, head `171fa263c`, conclusion `success`, 23 jobs success. |
| Info | `docs/engineering/process-reductions/0012-local-lane-exclusion.md` | `Merge commit:` line | The line changed from `pending (PR #1158)` to `pending (PR #1184)`; the earlier text named the issue number as the PR number. | None. | The correction makes the entry name the real PR; the README row keeps issue #1158; the ledger chain suites ran green in CI on `171fa263c`, which contains this change. | `git show 171fa263c`; CI run 43613054239 success. |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Resolve-PoshQCParallelTestFile` | Carried from the previous review: on Windows, the ordinal `SortedSet` keeps two spellings of one file that differ only in letter case as two entries. | No change required for this item. If case-variant input is observed, de-duplicate with `OrdinalIgnoreCase` on Windows or normalize each entry to its on-disk casing. | Operator spelling error; never a silent pass of a smaller selection. | Previous review's real-process probe; module unchanged since. |
| Info | `.agents/skills/python/SKILL.md`, `.agents/skills/typescript/SKILL.md`; `.github/agents/commentary-remediation.agent.md`, `.github/agents/staged-review.agent.md`, `.github/prompts/remediate-comments.prompt.md` | test command lines | Carried: these surfaces still name direct test commands. None is in the branch diff. | No change required for this item. | Spec D23 leaves the policy-mirror skills unedited by design; the `.github` agents and prompts serve Copilot, which runs neither hook twin. | Previous review `git grep`; files unchanged since. |
| Info | `.claude/hooks/test-execution-command-form.ps1` | `$script:TestExecutionPrefixTable`, `Get-TestExecutionRunnerMatch` | Carried: unspecified prefixes and runners pass (`watch`, `ionice`, `pnpm test`, `yarn test`, `make test`, `tox`, `nox`). | No change required for this item. | The spec lists the prefix and runner words explicitly and discloses the policy-level scope. | First-review real-process probe; no hook code changed since. |
| Info | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` | whole file | Carried: the MCP test template is outside the Pester coverage roots. | No change required for this item. | The coverage-root configuration predates the branch; `PoshQC.McpTemplateLock.Tests.ps1` exercises both templates. | `artifacts/pester/powershell-coverage.xml` has no entry for the template path. |

No covered file in the branch diff is at or above 700 logical lines (reviewer count over 80 added or modified covered files; largest `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`, 689), so there is no file-size Warning row; `config/file-size-baseline.json` is not in the diff.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- `classify_launcher_exit` runs before every early return (D28), and `run_fix_all` holds one shared `suite_lock` around the four launcher test steps. No Python file changed since the previous review.

#### Typing and API notes
- Pyright clean locally and in CI on Python 3.11, 3.12 and 3.13.

#### Error handling and logging
- `LauncherRefusedError` distinguishes a launcher refusal (exit 75) from a test failure.

### TypeScript implementation audit (if applicable)

#### What changed well
- N/A: no TypeScript file in the branch diff. The extension and root TypeScript suites passed in CI on Windows and Linux.

#### Type safety and maintainability
- N/A.

#### Error handling and logging
- N/A.

### PowerShell implementation audit (if applicable)

#### What changed well
- The lock decision is a pure state model separate from the lock I/O helper; the hook entry composes pure helpers.
- Every scoped shard receives the resolved file list, never the raw input, and the worker count is capped at the file count.
- The hook suites passed on Linux in CI (`poshqc / PowerShell hook suites (Linux)`), which the previous review could not confirm.

#### API and safety notes
- Module-private resolvers are not exported; shard paths are single-quoted with doubled `'`.

#### Error handling and logging
- Busy lock exits 75 with the holder description; a zero-file scoped run returns `ExitCode` 1 with the given paths logged.

### C# implementation audit (if applicable)

#### What changed well
- N/A: no C# file in the branch diff.

#### Type safety and API notes
- N/A.

#### Error handling and logging
- N/A.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`, `pytest-suite.2026-11-14T15-28.md`, `jest-extension-suite.2026-11-14T15-28.md`, `powershell-static.2026-11-14T15-29.md`, `bats-suite.2026-11-14T10-59.md`
- `evidence/qa-gates/coverage-comparison.2026-11-14T15-30.md`, `evidence/qa-gates/self-review.2026-11-14T15-32.md`
- `evidence/qa-gates/ci-dependent-ac-checkoff.2026-11-14T16-26.md` and `evidence/other/stage-timing.2026-11-14T16-26.json` (new since the previous review)
- CI runs 43613054239 (full, `171fa263c`) and 43615712466 (docs-only, `9262895e3`), read with `gh pr checks 1184` and `gh run view`

### Quality assessment prompts
- The CI run executed the integration and golden lanes that local gates exclude; all passed, so the local exclusion did not hide a failure at this head.
- The S9 record carries `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, and its head and run id match the reviewer's `gh run view` output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Leak scan 0 failures; CI `security-scan` success. |
| No unsafe subprocess or command construction | ✅ PASS | Shard paths quoted; launcher arguments passed as arrays. |
| Input validation at boundaries | ✅ PASS | Policy keys validated with defaults; blank, absent and non-test paths dropped. |
| Error handling remains explicit | ✅ PASS | Exit 75 for a busy lock; classified launcher exits in Python callers. |
| Configuration / path handling is safe | ✅ PASS | The lock directory lives outside every worktree; scoped paths resolved against the root. |

---

## Research Log

- `git fetch origin main`; `git rev-parse origin/main` equals the merge base.
- `git diff --stat 6a6a85a23..HEAD` and `git diff --name-only 6a6a85a23..171fa263c`: documentation records only.
- `gh pr checks 1184`; `gh pr view 1184` (`MERGEABLE`, `CLEAN`, head `9262895e3`); `gh run view` for runs 43613054239 and 43615712466, including the job list and the Python 3.13 step list.
- Logical line counts (`awk 'END{print NR}'`) of all 80 added or modified covered files.
- `git diff --name-status --diff-filter=MDR` over the evidence folder: no entry.
- `validate_evidence_locations.py --root <worktree>` (exit 0) and `check_quality_tiers` (OK, 35 entries).
- Read of the process-reductions README row for entry `0012`.

---

## Verdict

**Ready.** No blocking finding exists. The Info rows require no change for merge. CI is green on the PR head and the code at the head passed the full CI run.
