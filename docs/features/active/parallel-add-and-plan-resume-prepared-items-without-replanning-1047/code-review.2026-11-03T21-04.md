# Code Review: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1047 in the branch name.
**Base Branch:** `main` (resolved `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9`, equal to the merge base)
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `49c54e3de`
**Review Type:** Remediation re-audit after cycle 1 (previous set `*.2026-11-03T18-43.md`)

---

## Executive Summary

Cycle 1 (commit `49c54e3de`) resolves the two coverage-artifact findings and the three Minor findings of the previous review:

- M1: `Get-ParallelAdmissionRecordedEdge` is exposed as the `reuse-edges` subcommand (`-Slug`, `-IssueNum`, `-PlanHash`, optional `-Ref`), and `.claude/skills/parallel-plan/SKILL.md` step 7 and the rule now point at it instead of a manual `git show` and hash comparison.
- M2: the script header and the `assess` description state that `assess` runs `git fetch --quiet origin`, updates remote-tracking refs and the object store, and needs network access.
- M3: `Invoke-ParallelAdmissionGit` captures stderr through `2>&1` and splits it by `ErrorRecord` type; `Invoke-ParallelAdmissionGitChecked` names the first non-blank stderr line in its thrown message.
- Structure: the four pure JSON functions moved unchanged into `ParallelAdmissionJson.psm1`, which reduces the script from 699 to 621 logical lines; the bundle copy and `pack-manifests/core.json` entry were added.

Evidence reviewed: the PR-context summary (generated 2026-11-03 21:04 UTC for head `49c54e3d`), the cycle 1 diff, both canonical coverage artifacts (parsed by this review), the cycle evidence under `evidence/`, a review re-run of the touched suites (282/282) and `FileSizePolicy.RepoGate.Tests.ps1` (5/5), PSScriptAnalyzer and formatter re-checks (0 findings, 0 differences), and a read-only probe of the real git seam and the `reuse-edges` CLI.

**What changed:**
Cycle 1 adds 141 lines (`ParallelAdmissionJson.psm1`), removes net 78 lines from `Invoke-ParallelAdmission.ps1`, adds a 129-line JSON suite and 21 CLI tests and one integration scenario, updates the skill, the rule, and the spec `## API / CLI Surface` table, and adds one pack-manifest entry.

**Top 3 risks:**
1. `-Ref`, `-Branch`, and `-Main` reach git as positional arguments without a leading-dash check; an option-shaped value would be parsed by git as an option. The review's probe with `-Ref --output=<path>` produced no file and returned `record_missing`, and callers are agent forks using skill-given commands, so the exposure is low.
2. `reuse-edges` intentionally runs no fetch, so it reads whatever `origin/parallel/<slug>-plan` the last fetch left; the skill sequences it after `assess`, which fetches. A caller that skips `assess` could read a stale record.
3. The Layer 2 Python orchestrator-state validator still does not check `precedence[]` (documented gap D2, unchanged).

**PR readiness recommendation:** **Ready** - zero Blocker or Major findings; the remaining items are Minor or Info and do not block the PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 172-217 (`Get-ParallelAdmissionUsageError`), 361-362, 388-393, 416, 535-545 | `-Ref` (new in cycle 1), `-Branch`, and `-Main` are passed to `git show`, `git ls-tree`, `git rev-parse`, `git merge-base`, and `git diff` without rejecting a value that begins with `-`. `-Ref` and the blob reads always carry a `:<path>` suffix; `-Main` also appears as a bare argument of `git diff --name-only --no-renames <base> <main>` (line 362, present since the initial delivery), where an option-shaped value would be parsed as a git option. | Reject a ref-shaped option that begins with `-` in `Get-ParallelAdmissionUsageError` (exit 2), with one usage-error test per option. | Defense in depth for a helper granted through a `Bash(...)` permission rule; the other options are already regex-validated. The skills do not pass `-Main`, so the default `origin/main` applies in the documented flows. | Review probe: `reuse-edges -Slug demo -IssueNum 1047 -PlanHash abc -Ref --output=<scratch>/injected` exited 0 with `record_missing` and created no file |
| Minor | `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md` | `## Acceptance Criteria` first item; design sections | The spec names three helper files; cycle 1 added a fourth PowerShell module, `ParallelAdmissionJson.psm1`, which the spec does not mention outside the remediation plan. | Add the module to the spec's design or architecture description (not to the criterion text, which reviewers and executors must not edit). | Keeps the spec an accurate map of the delivered files. The criterion's verified condition (no `.ts`, no added `.py`, no `.py` outside `tests/`) still holds. | `grep -n ParallelAdmissionJson spec.md` returns no match |
| Info | `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | whole file | 692 logical lines, 8 below the 700-line advisory tier; no Warning applies. | Place further CLI cases in a sibling suite (for example a `reuse-edges` suite) rather than in this file. | The next addition would cross the advisory tier. | `@(Get-Content -LiteralPath).Count` |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 63-75 | The `2>&1` stream split relies on PowerShell 7 not applying `$ErrorActionPreference = 'Stop'` to redirected native stderr; under Windows PowerShell 5.1 the first stderr line would throw. The helper is pwsh-only by design. | None; keep the `pwsh -NoProfile -NonInteractive -File` invocation as the only route. | Recorded for later changes that might widen the host set. | Review probe under pwsh 7: exit 128 with the stderr line captured and no exception |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 73-74, 86, 324, 614-620 | Eight lines are uncovered: the real git call, the real file read, one defensive return in `Get-ParallelAdmissionPlannerItem`, and the guarded entry body. File coverage 96.44%, above its 96.15% baseline. | None. | The seam bodies are mocked by design; the review exercised lines 73-74 directly with real git. | `artifacts/pester/powershell-coverage.xml` |
| Info | Full-tree Pester on this Linux host | `evidence/regression-testing/pester-full.2026-11-03T20-57.md`, `pester-parallel-shards.2026-11-03T20-39.md` | 409 single-process and 89 sharded failures, all in suites the branch does not add or change. No path under the failing suites' trees differs from the merge base, the sharded set fails identically at the merge base, and the PATH leak at `tests/scripts/dev-tools/run-actionlint.Tests.ps1` line 497 exists at the merge base. | File the PATH leak as a separate test-isolation issue; rely on the `windows-latest` CI shards at S9 for the Windows-host suites. | Pre-existing and unrelated to the feature; not a finding against this branch. | `policy-audit.2026-11-03T21-04.md` Section 8 |
| Info | `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` | whole file | The module is pure, follows `ClaudeLibModuleConvention.Tests.ps1` (6/6 at HEAD), exports four functions, and carries the moved analyzer suppression with its justification. | None. | Confirms the structural change. | Review re-run; PSScriptAnalyzer 0 findings |

Zero Blocker and zero Major findings. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in cycle 1; the two fragment-pin tuples from the initial delivery remain and pass.

#### Typing and API notes

- No new Python API surface.

#### Error handling and logging

- Not applicable; data only.

### PowerShell implementation audit

#### What changed well

- `reuse-edges` is a thin wrapper over the already tested `Get-ParallelAdmissionRecordedEdge`, which removes the last decision the skill made in prose; the new non-object record check fails fast with a specific message.
- The stderr capture keeps stdout and stderr separate, so `Output` parsing is unchanged, and the checked wrapper tolerates an older seam double without a `Stderr` property under strict mode.
- The dispatch switch now names `record` explicitly instead of using `default`, so an unexpected subcommand cannot fall through to `record`.
- The JSON move is byte-for-byte for the function bodies, so behavior and the existing tests are unchanged.

#### API and safety notes

- New options `-Slug` (no `/` or whitespace) and `-IssueNum` (positive integer) are validated before any read; `-PlanHash` is not format-checked, and an arbitrary value yields `plan_hash_changed`, which recomputes edges (fail-safe).
- `-Ref` is not validated; see the Minor finding.
- The permission rule `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)` already covers the new subcommand; no settings change was needed.

#### Error handling and logging

- Strict mode and `Stop` in every file; one catch in `Invoke-ParallelAdmissionCli` maps exceptions to exit 1 with the failure prefix; git failures now carry the git reason.

---

## Test Quality Audit

The review re-ran the touched suites on Linux at HEAD with coverage disabled: 282 tests, 0 failures (hook 62, CLI 78, integration 12, manifest 5, admission 56, JSON 12, precedence 51, module convention 6). `FileSizePolicy.RepoGate.Tests.ps1`: 5/5.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1` - case-distinct keys, Int64 and Double mapping, booleans and null, array root not unrolled, timestamp string preserved, ordinal key order at every depth, pscustomobject parity, no carriage return, unserializable-value message.
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - `reuse-edges` usage rows, reuse on a matching hash, record read once by ref from the default and an explicit ref with no fetch, stderr message cases, fetch-once in `assess`, header wording pin.
- `evidence/qa-gates/coverage-delta.2026-11-03T20-57.md` - per-function missed-line table; figures match the artifact read by this review.
- `evidence/regression-testing/pester-shuffle.2026-11-03T20-30.md` - seeds 11, 23, 47.

### Quality assessment prompts

- **Determinism:** git, file, and clock mocked; no wall-clock or sleep in the suites.
- **Isolation:** every suite removes its imported modules, including `ParallelAdmissionJson`, in `AfterAll`.
- **Speed:** 282 tests in 9.4 s.
- **Diagnostics:** assertions compare exact messages and git argument arrays.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no tokens, keys, or host paths. |
| No unsafe subprocess or command construction | ✅ PASS | `& git @GitArgs` with an argument array; no command string is built. Option-shaped ref values are recorded as a Minor finding. |
| Input validation at boundaries | ✅ PASS | New `-Slug` and `-IssueNum` checks; `-Ref` unchecked (Minor). |
| Error handling remains explicit | ✅ PASS | Exit codes 0, 1, 2; prefixed stderr lines; git stderr surfaced. |
| Configuration / path handling is safe | ✅ PASS | `reuse-edges` reads only `docs/features/parallel/<slug>/parallel-scheduling.json` by ref and writes nothing. |

---

## Research Log

No external research was required. Findings derive from the branch diff, repository rules, the canonical coverage artifacts, and local re-runs.

---

## Verdict

Cycle 1 resolves every finding of the previous review. The two remaining Minor findings (unchecked leading dash on ref options, and the spec not naming the new JSON module) and the Info items do not block the PR. The branch is ready for the PR creation gate.
