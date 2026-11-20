# Code Review: Test-execution policy and machine test-suite lock (#1158), re-audit after remediation cycle 1

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Feature Folder Selection Rule:** the only feature folder carrying issue #1158; no version subfolder
**Base Branch:** `main` (merge base `add7d747886ce893356b63de2941435f2895b345`; `origin/main` fetched and unchanged)
**Head Branch:** `feature/test-execution-policy-machine-lock-1158` at `6a6a85a23701f4413349fad33f59663e09314757` (no pull request yet)
**Review Type:** Re-audit at the exit of remediation cycle 1; scope is the full branch diff

---

## Executive Summary

The branch introduces a test-execution policy: local runs exclude the integration and golden lanes, at most one test suite runs per machine (per user) under an OS advisory file lock, and suites run only through a recognizable launcher enforced by a PreToolUse hook in the Claude and Codex runtimes. The change set is 364 files. Remediation cycle 1 changed 81 files: the scoped parallel Pester entry in `PoshQC.Parallel.psm1` (with its bundle copy and README), a new 12-case Pester suite, launcher and hook test rows, the instruction text of the atomic executor, `python-qa-gate`, the Copilot Python executor, the test-execution-policy skill, the execution-environment brief and the atomic-plan-contract (every copy and Codex variant), regenerated ledger records of entries `0001`, `0006` and `0011`, the user-story AC4 and spec entry-number text, and new evidence records.

Both blocking findings of the first review are resolved. F1: every instruction copy now names the launcher suites, and new `PGW-LAUNCHER-*` rows forbid the direct forms; the task-check record shows those rows failing on the pre-edit text. F2: user-story AC4 matches spec D31 branch B and is checked off against passing Registration, guard-completeness, no-Python and pack-manifest tests. The coordinator item C1 is delivered as a minimal optional parameter plus seam, with the launcher reaching it unchanged.

**What changed (cycle 1):**
`Invoke-PoshQCParallelTest -TestPath` and the `-ResolveTestFile` seam (default `Resolve-PoshQCParallelTestFile`), `Get-PoshQCParallelShardArgument -TestPath` emitting `-ScanFolders @(...)`, launcher-route instruction text, scoped Pester policy text, and wording rows.

**Top 3 risks:**
1. Linux CI results for the hook suites and the CI integration lanes are pending; no pull request exists yet.
2. On Windows, two spellings of one test path that differ only in letter case resolve to two entries in a scoped run (informational; operator input error).
3. The hook remains a policy-level control: unspecified forms (`watch`, `ionice`, `pnpm`, `yarn`, `make`, `tox`, `nox`) pass, as disclosed in the spec.

**PR readiness recommendation:** **Ready** — no blocking finding; CI on the pull-request head is pending.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `.claude/agents/atomic-executor.md` and copies; `python-qa-gate` copies; `.github/agents/python-atomic-executor.agent.md` and copy | `## Toolchain Commands`; `## Toolchain Execution Sequence` step 4; `### 7.1` step 4 | F1 of the first review: direct `poetry run pytest` instructions. Now replaced with the launcher `pytest` suite (and the launcher `pester` suite for the PowerShell bullet) in all 18 copies and Codex variants. | None. | The hook denies the direct form; the instructions now match it. | `git diff c03f350da..6a6a85a23`; `PGW-LAUNCHER-*` rows (14) pass in `phase-gate.P2.2026-11-14T15-00.md` and failed on the pre-edit text (`task-check.P2-T1.2026-11-14T13-54.md`, `task-check.P2-T2.2026-11-14T14-05.md`); reviewer search of the agent and skill surfaces found no remaining F1 line. |
| Resolved | `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/user-story.md` | AC4 bullet (line 66) | F2 of the first review: criterion not aligned with spec D31. Now rewritten to registry membership and the timeout-sum rule, and checked. | None. | The text change was authorized by ORCH-D7 and the delivered registration satisfies it. | Reviewer read of the four `pretooluse-dispatch.json` copies: one group per registry with matcher `Bash\|mcp__drm-copilot__run_poshqc_test\|mcp__drm-copilot__run_poshqc_suite` (Codex form anchored), no hook entry in either `settings.json` or `config.toml`; `ac4-registration-closure.2026-11-14T15-31.md`. |
| Resolved | `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md` | AC5 ledger bullet; D30 | Minor note of the first review: entry `0011` named where `0012` was delivered. Now names `0012`. | None. | Text matches the delivered entry. | `git diff` of `spec.md` (2 lines replaced in place). |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Resolve-PoshQCParallelTestFile` | On Windows, the ordinal `SortedSet` keeps two spellings of one file that differ only in letter case (`tests/scripts/powershell/PoshQC/...` and `tests/scripts/powershell/poshqc/...`) as two entries, so each would be handed to the shards. The downstream effect (a completeness failure, `ExitCode` 1, or the file running twice) was not exercised by the reviewer because no suite was run. | No change required for this item. If case-variant input is observed, de-duplicate with `OrdinalIgnoreCase` on Windows or normalize each entry to its on-disk casing. | The input is an operator spelling error; the plan's uniqueness rule (a folder plus a file inside it) holds and is tested (PS08, PS10). The result is never a silent pass of a smaller selection. | Reviewer real-process probe of the worktree module (`Resolve-PoshQCParallelTestFile -TestPath` with both spellings returned two entries). |
| Info | `.agents/skills/python/SKILL.md`, `.agents/skills/typescript/SKILL.md`; `.github/agents/commentary-remediation.agent.md`, `.github/agents/staged-review.agent.md`, `.github/prompts/remediate-comments.prompt.md` | test command lines | These surfaces still name direct test commands (`poetry run pytest --cov`, `npm run test:unit`, `poetry run pytest -n auto`). None is in the branch diff. | No change required for this item. | Spec D23 leaves the policy-mirror skills unedited by design and has the brief state that the launcher governs; the `.github` agents and prompts serve Copilot, which runs neither hook twin. | Reviewer `git grep` of `.claude/agents`, `.claude/skills`, `.agents`, `.github/agents`, `.github/skills`, `.github/prompts`, `.codex/agents` at the reviewed head. |
| Info | `.claude/hooks/test-execution-command-form.ps1` | `$script:TestExecutionPrefixTable`, `Get-TestExecutionRunnerMatch` | Carried from the first review: unspecified prefixes and runners pass (`watch`, `ionice`, `pnpm test`, `yarn test`, `make test`, `tox`, `nox`). | No change required for this item. | The spec lists the prefix and runner words explicitly and discloses the policy-level scope. | First-review real-process probe; no hook code changed in cycle 1. |
| Info | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` | whole file | Carried from the first review: the MCP test template is outside the Pester coverage roots. | No change required for this item. | The coverage-root configuration predates the branch; `PoshQC.McpTemplateLock.Tests.ps1` exercises both templates. | `artifacts/pester/powershell-coverage.xml` has no entry for the template path. |

No covered file in the branch diff is at or above 700 logical lines (largest `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`, 689), so there is no file-size Warning row; `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- No Python file changed in cycle 1. The first-review assessment stands: `classify_launcher_exit` runs before every early return (D28), and `run_fix_all` holds one shared `suite_lock` around the four launcher test steps.

#### Typing and API notes
- Unchanged; pyright clean in `phase-gate.P2.2026-11-14T15-00.md`.

#### Error handling and logging
- Unchanged.

### TypeScript implementation audit (if applicable)

#### What changed well
- N/A: no TypeScript file in the branch diff. The extension Jest suite ran as a regression gate (5616 passed).

#### Type safety and maintainability
- N/A.

#### Error handling and logging
- N/A.

### PowerShell implementation audit (if applicable)

#### What changed well
- Every shard receives the resolved file list, never the raw input, which prevents a folder plus a file inside it from being enumerated twice and failing the completeness check; PS03 and PS08 discriminate this (a raw-input shard binding would differ from the asserted list).
- The worker count is capped at the file count before any shard starts, so `Select-PoshQCShardTestFile` never receives an empty shard.
- With `-TestPath` omitted, the command text, worker count and seam calls are unchanged (PS02, PS07), so existing callers and the full gate are unaffected.
- The launcher reaches `-TestPath` with no code change because `Invoke-PesterSuite.ps1` reads the declared parameter names; the hook's lane check applies to the scoped list.
- Lane suffixes are dropped by the existing `Select-PoshQCLaneTestFile`, so the scoped and full routes share one rule.

#### API and safety notes
- `Resolve-PoshQCParallelTestFile` is module-private (not in the export list) and is reached only through the `ResolveTestFile` default.
- The shard text quotes each path with the existing `$quote` helper; PS01 proves a path containing `'` parses and binds as an array constant.

#### Error handling and logging
- A scoped run that resolves no file logs the given paths and returns `ExitCode` 1 without starting a shard (PS06).

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
- `evidence/qa-gates/pester-suite.2026-11-14T15-28.md` (26420 tests, 0 failures) and `artifacts/pester/powershell-coverage.xml`, parsed by the reviewer (`PoshQC.Parallel.psm1` 173/177; missed lines are the unchanged default process-start body)
- `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`, `jest-extension-suite.2026-11-14T15-28.md`, `powershell-static.2026-11-14T15-29.md`
- `evidence/qa-gates/phase-gate.P1.2026-11-14T13-44.md`, `phase-gate.P2.2026-11-14T15-00.md`
- `evidence/qa-gates/coverage-comparison.2026-11-14T15-30.md`, `evidence/other/lane-deviation.2026-11-14T15-30.md`, `evidence/other/ac4-registration-closure.2026-11-14T15-31.md`
- `evidence/other/scoped-pester-proof.2026-11-14T13-19.md` (real launcher run, `workers=2`, 32 of 32 cases passed)
- `evidence/other/task-check.P1-T1` to `P2-T6` records, including the recorded red runs of the new wording rows
- `evidence/other/ledger-regions.2026-11-14T12-51.md` and `evidence/qa-gates/self-review.2026-11-14T15-32.md`

### Quality assessment prompts
- The scoped suite asserts through AST binding of the shard command text, not substring matching, so a quoting or ordering defect fails the test.
- The new wording rows close the gap noted in the first review (no test forbade direct runner text outside the tool list).
- The scoped launcher proof is a real-process run, which complements the seam-level tests.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Leak scan 0 failures; no credentials added. |
| No unsafe subprocess or command construction | ✅ PASS | Shard paths are single-quoted with doubled `'`; PS01 parses the result. |
| Input validation at boundaries | ✅ PASS | Blank, absent and non-test paths are dropped; a zero-file selection fails explicitly. |
| Error handling remains explicit | ✅ PASS | Zero-file scoped run returns `ExitCode` 1 with the paths logged. |
| Configuration / path handling is safe | ✅ PASS | Paths are resolved against the root and emitted root-relative; a path leaving and re-entering the root resolves correctly (reviewer probe). |

---

## Research Log

- `git fetch origin main`; `git rev-parse origin/main` equals the merge base.
- `git diff c03f350da..6a6a85a23` for the PoshQC module, tests, instruction surfaces, spec and user story; `git diff --diff-filter=MDR` on the evidence folder (no edited or deleted evidence).
- Coverage XML parsed for `PoshQC.Parallel.psm1` per-line counters and the root counter.
- `md5sum` across every mirror set touched in cycle 1.
- Real-process probe of `Resolve-PoshQCParallelTestFile` through the worktree module (no suite run).
- Reads of the four `pretooluse-dispatch.json` copies, both `settings.json` copies and both `config.toml` copies.
- `git grep` of the agent and skill surfaces for direct runner commands.
- Logical line counts of every added or modified covered file.
- `validate_evidence_locations.py --root <worktree>` (exit 0) and `check_quality_tiers` (OK, 35 entries).
- `gh pr list` for the branch: no pull request; remote branch at the reviewed head.

---

## Verdict

**Ready for PR.** No blocking finding remains. F1 and F2 of the first review are resolved and C1 is delivered. The Info rows require no change for merge. Spec S348 stays pending until CI runs on the pull-request head.
