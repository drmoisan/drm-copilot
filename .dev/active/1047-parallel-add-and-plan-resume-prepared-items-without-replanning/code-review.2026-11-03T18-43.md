# Code Review: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1047 in the branch name.
**Base Branch:** `main` (resolved `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9`, equal to the merge base)
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `793096c82`
**Review Type:** Initial review (fresh start; the interrupted partial artifacts removed in `a86154da3` were not reused)

---

## Executive Summary

The branch adds a PowerShell admission helper for the parallel surface: `ParallelAdmission.psm1` (closed-run guard, stage inference, receipt selection, staleness verdict, band precedence, admission decision), `ParallelAdmissionPrecedence.psm1` (precedence validation, cohort lift, cohort-table check, durable scheduling record), and `Invoke-ParallelAdmission.ps1` (CLI with five subcommands and three I/O seams). The cohort barrier hook helpers gain a precedence rule. Three skills, one rule, two agents, and `settings.json` are edited to call the helper through a `pwsh -NoProfile -NonInteractive -File` route, and every edited `.claude` file has a byte-equal bundle copy (11 pairs verified with `cmp`). 91 files change, 8585 lines added, 60 removed; 49 of the files are evidence records.

Evidence reviewed: the PR-context summary, the branch diff, the three production files read in full or by function, the hook diff, the Python pin diff, the executor evidence under `evidence/`, and two review re-runs on Linux at HEAD (242/242 Pester, 23/23 bats parity). Implementation quality is good: pure decision logic is separated from I/O, the guard fails closed, rejection lines are stable and machine-parseable, and the tests mock only the seams and write no files. The two blocking items are coverage-artifact absences recorded in the policy audit, not code defects.

**What changed:**
New `.claude/lib/parallel-admission/` (1715 logical lines) with five Pester suites (1640 lines) and five fixtures; a 50-line addition to `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`; skill and rule text for intake assessment, resume and receipt lines, precedence flags, the durable record, the plan-hash kickoff sentence, and the turn-gap re-delegation rule; two fragment-pin tuples in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; one `quality-tiers.yml` entry.

**Top 3 risks:**
1. The re-seed edge-reuse rule is applied from skill prose (`git show` plus a manual hash comparison) although a tested helper function for it exists but is not exposed as a subcommand.
2. `assess` performs `git fetch --quiet origin`, a ref and object-store write plus a network call, while the script header states that no git write is made; a fetch failure turns every `assess` into an exit-1 failure.
3. The Layer 2 Python orchestrator-state validator does not check `precedence[]` (documented gap D2); precedence enforcement depends on the helper and the Layer 1 hook only, and the hook change is visible to isolated subagents only after merge.

**PR readiness recommendation:** **Needs Revision** - the code is ready, but the policy audit records two blocking coverage-artifact absences that must be cleared by regenerating the canonical coverage artifacts.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical PowerShell coverage artifact is absent from the item worktree; the per-file figures in the evidence records cannot be verified, and no repo-wide PowerShell figure is recorded. | Run `mcp__drm-copilot__run_poshqc_test` (or `Invoke-PoshQCTest -ScanFolders tests/scripts` with default settings) at HEAD so that the artifact exists, then re-run the review. | The review contract treats an absent artifact for a language with changed files as FAIL. | `ls artifacts/` lists only `orchestration/` and the PR-context files; `policy-audit.2026-11-03T18-43.md` section 1.2.1 |
| Blocker | `artifacts/python/lcov.info` | n/a | The canonical Python coverage artifact is absent; repo-wide Python line and branch coverage cannot be read. | Run `poetry run pytest --cov -n auto` at HEAD so that the artifact exists, then re-run the review. | Same contract rule; Python has one changed file on the branch. | `pyproject.toml` addopts carry `--cov-report=lcov:artifacts/python/lcov.info` but no `--cov`, so the recorded `-n auto` run produced no artifact |
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 632-649 (`Get-ParallelAdmissionRecordedEdge`) | The function that reads the committed scheduling record by ref and applies the reuse rule is tested (unit line 529, integration lines 145 and 154) but no subcommand calls it; `.claude/skills/parallel-plan/SKILL.md` `### Seeding procedure` step 7 tells the planner to run `git show` and compare hashes itself. | Expose it as a subcommand (for example `reuse-edges -Slug -IssueNum -PlanHash`) and point the skill at it, or remove it and keep the rule in `ParallelAdmissionPrecedence.psm1` only. | The feature's stated aim is to move gate decisions from prose to code; this one remains prose while dead code carries the same logic. | `grep -rn Get-ParallelAdmissionRecordedEdge .claude tests` shows only the definition and test call sites |
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 11-13, 61, 488 | The header says "No file and no git write is made" and the seam synopsis says "read-only git command", but `assess` runs `git fetch --quiet origin`, which updates remote-tracking refs and objects and needs network access. | Amend the header and synopsis to state that `assess` fetches `origin`, or move the fetch to the calling skill and keep the helper read-only. | Accurate side-effect documentation matters for a helper granted through a `Bash(...)` permission rule. | Line 488 of the file |
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | line 67 | `Invoke-ParallelAdmissionGit` discards git stderr (`2>$null`); a failure surfaces only as "git ... exited N". | Capture stderr into the result object and include its first line in the thrown message of `Invoke-ParallelAdmissionGitChecked`. | The operator sees the helper's single stderr line; the git reason (unknown ref, network failure) is lost. | Lines 67 and 374 |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | whole file | 699 logical lines, one below the 700-line advisory tier; no Warning applies. | Place further subcommands in a sibling module rather than in this script. | The next addition would cross the advisory tier. | `awk 'END{print NR}'` |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 516-522 | When the stage is `plan` or `cleared` but no plan path resolves, no staleness verdict is computed and `Get-ParallelAdmissionDecision` throws, so `assess` exits 1 with the failure prefix. | No change required; the behavior is fail-closed. A dedicated detail message would aid diagnosis. | Recorded for reviewers of later changes. | Code inspection |
| Info | `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` | lines 219-265, 328-341 | The precedence rule treats a missing predecessor record as not clear (fail closed), releases on `state: withdrawn`, and holds on `blocked`, matching spec D6. | None. | Confirms the AC behavior at the code level. | Hook diff; 62/62 hook tests on Linux (`evidence/regression-testing/review-linux-reruns.2026-11-03T18-43.md`) |
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | lines 223-229, 248-255, 330-349 | Two fragment tuples and two obligation cases are added; no pytest marker is introduced, so `--strict-markers` needs no registration. | None. | Responds to the caller question about marker registration after the main change to addopts. | Python diff; `pytest-strict-markers-nauto.2026-11-03T18-42.md` (16063 passed, 6 skipped) |
| Info | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` | n/a | The issue 1027 change on main alters only the `--preserve` staging path. The branch does not edit any cleanup file, and its only cleanup reference (`parallel-orchestrate/SKILL.md` line 666 and the agent permission) is unchanged and does not use `--preserve`. | None. | Responds to the caller question about interaction with the cleanup-script change. | `git diff --name-only ac6f6b6db HEAD -- .claude` lists only cleanup-merged-worktrees files |

Two Blocker findings, both coverage-artifact absences; no Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The pins protect exactly the two new sentences the spec requires (plan-hash verification in kickoff element 4 and the turn-gap re-delegation rule) and reuse the existing `SECTION_OBLIGATION_CASES` mechanism.

#### Typing and API notes

- New constants are annotated `tuple[str, ...]`. No new public Python API surface was added.

#### Error handling and logging

- Not applicable; the change adds data only.

### PowerShell implementation audit

#### What changed well

- I/O is confined to three seams (`Invoke-ParallelAdmissionGit`, `Read-ParallelAdmissionJsonText`, `Get-ParallelAdmissionUtcNow`); the two modules are pure and reach 100% recorded line coverage under mocks.
- JSON is parsed with `System.Text.Json` into ordinal hashtables and written with ordinally sorted keys and LF line endings, so output is byte-stable across hosts.
- Usage validation runs before any read and exits 2; rule rejections exit 1 with one `PARALLEL_ADMISSION_REJECTED: <code>: <detail>` line; `guard-run` treats an unreadable checkpoint as closed.
- The staleness check ignores the item's own feature folder, uses `Test-EntryOverlap` from the existing blast-radius library, and returns sorted, ordinal path sets.

#### API and safety notes

- Every function has `[CmdletBinding()]`, `[OutputType()]`, and comment-based help; verbs are approved. One justified analyzer suppression (`PSUseLiteralInitializerForHashtable`) is present for ordinal JSON keys.
- No `Invoke-Expression`; git arguments are passed as an array to `& git @GitArgs`, so no command string is constructed.
- No ShouldProcess is needed: the helper writes no file; `record` prints content for the caller to write.

#### Error handling and logging

- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` in all three files. One catch in `Invoke-ParallelAdmissionCli` maps exceptions to exit 1 with a prefix and never swallows them silently. Git stderr is discarded (Minor finding above).

---

## Test Quality Audit

The touched suites were re-run by the review on Linux at HEAD with coverage disabled: 242 tests, 0 failures. The six bash parity suites were re-run: 23 tests, 0 failures. Executor evidence covers the full Pester suite (13912 tests), the full pytest suite under strict addopts and `-n auto` after the main merge (16063 passed), shuffled and sharded Pester runs, and a reversed-order pytest run.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1` - guard matrix, every inference row including placeholder spec, placeholder plan, and stale preflight evidence; decision table. 56 tests.
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` - unknown key, self-pair, cycle, lift with pinned and floor, cohort-table violation, record content and reuse. 51 tests.
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - usage errors, each subcommand's exit code and output shape. 57 tests.
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` - seed, half-prepared, and closed-run scenarios against committed fixtures with git mocked. 11 tests. These are scenario tests over mocks, not live-git integration tests; this matches the no-temporary-files rule.
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` - 62 tests including the precedence predecessor context.
- `evidence/regression-testing/review-linux-reruns.2026-11-03T18-43.md` - review re-run record.
- `evidence/qa-gates/pester-coverage.2026-11-03T13-52.md` - recorded per-file coverage; the cited artifact is no longer present.

### Quality assessment prompts

- **Determinism:** git, file, and clock are mocked; no `Get-Date`, `Start-Sleep`, or global state in the suites.
- **Isolation:** one behavior per It; Describe per function.
- **Speed:** 242 tests in one process in under two minutes.
- **Diagnostics:** assertions compare exact rejection lines and JSON fields.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no tokens, keys, or host paths. |
| No unsafe subprocess or command construction | ✅ PASS | `& git @GitArgs` with an argument array; option values are validated by regex before use (`^[0-9]+:[0-9]+$`, `^docs/features/parallel/[^/\s]+/?$`). |
| Input validation at boundaries | ✅ PASS | `Get-ParallelAdmissionUsageError` validates every option before any read. |
| Error handling remains explicit | ✅ PASS | Fail-closed guard; prefixed stderr lines; exit codes 0, 1, 2. |
| Configuration / path handling is safe | ✅ PASS | Reads are by git ref; the only filesystem read is the checkpoint or planner checkpoint path supplied by the caller. The permission rule is scoped to the exact script path. |

---

## Research Log

No external research was required. All findings derive from the branch diff, repository rules, and local re-runs.

---

## Verdict

The implementation is well structured, tested in isolation, and consistent with the spec decisions; three Minor findings concern an unexposed reuse function, a header that understates the `git fetch` side effect, and discarded git stderr. None of them blocks the PR.

The review is not ready for PR flow until the two Blocker findings are cleared: regenerate `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info` at the branch head in the item worktree and re-run the review.
