# Code Review: ci.yml epic/** pull_request trigger and S9 epic-child rule (#658)

---

**Review Date:** 2026-10-08 (artifact timestamp `2026-10-08T02-50` supplied by the delegating orchestrator)
**Reviewer:** feature-review agent, pass 1
**Feature Folder:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix `658` matches the branch name.
**Base Branch:** `origin/main` (merge-base `08ee030d9584bf15882fbb3654c8e38f34c7c359`)
**Head Branch:** `bug/epic-child-prs-trigger-no-ci-658` (head `9686d975d85250814aba7e149ee6ac0cfeda562a`)
**Review Type:** Initial review

---

## Executive Summary

The branch closes the CI trigger gap for epic child PRs. `.github/workflows/ci.yml` line 7 now lists `"epic/**"` in the `pull_request` branch filter, so a PR whose base is `epic/<slug>-integration` runs the same nine CI jobs as a PR into `main`. The `push` filter is unchanged. `.github/workflows/README.md` gains a `## Triggers` section that documents the trigger set and the reason for `epic/**`. The orchestrate skill's S9 step 2 gains an epic-child rule: an empty check list is not green, and at least one `CI` check must be observed and every observed `CI` check must succeed. The bundle mirror is byte-identical. A new two-test Pester suite asserts both trigger invariants. It was observed failing on the pre-fix file and passing on the fixed file.

The review covered the full branch diff (50 files, of which 5 are production or test files), the 44 evidence files, and the CI citations for internal consistency. It also ran check-only commands: actionlint, `cmp`, 39 pytest consumer tests, and the evidence-location validator. Implementation quality is good. The change is minimal, correctly quoted YAML, and the test is hermetic and well documented.

**What changed:**
- `.github/workflows/ci.yml:7`: `branches: [main, development]` becomes `branches: [main, development, "epic/**"]`.
- `.github/workflows/README.md:8-16`: new `## Triggers` section.
- `.claude/skills/orchestrate/SKILL.md:291`: new epic-child rule paragraph between S9 step 2 (line 289) and step 3 (line 293). The bundle mirror is identical.
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (new, 174 lines): `Get-CiTriggerBranchList` helper and two `It` blocks.

**Top 3 risks:**
1. The S9 epic-child rule is enforced only by prose. `Invoke-CiGateParser.ps1` still returns `success` for an empty check set, so an orchestrator that runs S9 mechanically can still accept a vacuous green (CR-1).
2. No green CI run is recorded at the current branch head. The recorded run is on `8a1b9b8b`, and the head is the documentation-only commit `9686d975` (CR-2). AC-7 is checked in `issue.md` ahead of that record.
3. The new trigger has not yet been exercised by an actual `pull_request` event into an `epic/**` branch (CR-6). Its correctness rests on GitHub's documented glob semantics and the text-level test.

**PR readiness recommendation:** **Blocked** (awaiting CI). The code is ready. The only Blocker is the `modified-workflow-needs-green-run` evidence for the final head, which a green CI run on the PR head resolves without any code change.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker (Blocking; Remediability: awaiting_ci) | `.github/workflows/ci.yml` | branch head `9686d975` | CR-2: The `modified-workflow-needs-green-run` rule requires a green run whose head SHA equals the current branch head. The only recorded green run, 37717224700, is on `8a1b9b8b`. AC-7 was checked off early under DEV-AC7-EARLY. | After the PR to `main` is opened (or refreshed), record the CI run on the final PR head with run id, head SHA, and conclusion `success`. A `workflow_dispatch` run on that head also qualifies. | `.claude/skills/feature-review-workflow/SKILL.md` (modified-workflow-needs-green-run) is SHA-exact. The intervening commit is documentation-only (`git diff --name-only 8a1b9b8b HEAD`), so the risk is low but the evidence is not yet at the head. | `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-30.md`; `git rev-parse HEAD` = `9686d975...` |
| Major (Non-blocking; out of scope per issue.md line 28) | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | lines 22-23, 130-133 | CR-1: The parser maps an empty check set to `success`. The new S9 paragraph (`orchestrate/SKILL.md:291`) forbids that outcome for epic children, but S9 steps 3 and 5 still derive `step9_status: passed` from the parser output. The rule therefore depends on the orchestrator applying prose. | File a follow-up issue to add an opt-in parser guard, for example `-RequireWorkflow CI` or `-RejectEmpty`, that yields `failure` or `pending` when no check from the named workflow is present. Have S9 pass that guard when `epic_mode` is true. | A vacuous S9 green is the defect class issue #658 targets. Prose-only enforcement is weaker than the mechanical gate. | `Invoke-CiGateParser.ps1:130-133` (`if ($null -eq $Checks -or $Checks.Count -eq 0) { return 'success' }`) |
| Minor (Non-blocking) | `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/` | Phase 1 and Phase 2 artifacts | CR-3: Evidence timestamps are not host-clock capture times. Artifacts stamped `22-30` to `22-40` are in commit `00798863` (committed 22:16 EDT). Artifacts stamped `22-45` and `22-48` are in `8a1b9b8b` (committed 22:17 EDT). Phase 2 artifacts are stamped in UTC (`02-30`) rather than local time. | Read the timestamp from the host clock at capture (`Get-Date -Format yyyy-MM-ddTHH-mm` or `date +%Y-%m-%dT%H-%M`) and never compose it. No rewrite of the existing files is required. | `evidence-and-timestamp-conventions/SKILL.md:49` requires local host-clock time that is never composed or estimated. Run IDs and SHAs, which carry the substantive verification, are consistent. | `git log --format='%h %ad' --date=iso-strict origin/main..HEAD`; `git show --stat 00798863 8a1b9b8b` |
| Minor (Non-blocking) | `.claude/skills/orchestrate/SKILL.md` | lines 291, 293 | CR-4: The epic-child paragraph tells S9 to run the step 2 query without `--required`. Step 3 still describes the parser's conclusion in terms of "required checks". For an epic child, the parser input becomes all checks, including non-CI workflows such as `publish-extension.yml`. The paragraph requires only that every observed `CI` check succeed, which leaves undefined how a failing non-CI check is treated. | In a follow-up, state whether non-CI checks on an epic child are ignored or must also pass, and align the step 3 wording ("checks in the queried set"). | Ambiguity in a gate definition leads to divergent orchestrator behavior. The current wording is stricter than intended at worst, so the risk is low. | `orchestrate/SKILL.md:289-293` |
| Nit (Non-blocking) | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 116-124, 137-139 | CR-5: The helper's dash-item block-list branch and single-quote stripping are not exercised, because the current `ci.yml` uses flow form with double quotes. | Optional: add an `It` that calls `Get-CiTriggerBranchList` on an inline string array in block-list form with single-quoted items. Inline arrays avoid temporary files. | Untested parsing branches could fail silently if `ci.yml` is later reformatted. The non-empty and `Should -Contain` assertions would still fail closed in that case. | File inspection |
| Info | `.github/workflows/ci.yml` | line 7 | CR-6: The new `epic/**` filter has not been exercised by a real `pull_request` event into an `epic/**` branch. The CI evidence comes from `workflow_dispatch` runs. | Optional: run the issue's integration scenario (a docs-only PR into a throwaway `epic/test-integration` branch), or observe the first epic child PR after merge. | GitHub `branches` filter globs treat `**` as matching across `/`, and quoting is correct. This is a residual-confidence note, not a defect. | `issue.md` "Proposed Fix / Validation Ideas" |
| Info | `.github/workflows/README.md` | lines 3-4 | CR-7: The pre-existing intro says `ci.yml` composes "eight reusable per-stage workflows". `ci.yml` has nine jobs. | Correct in a separate documentation change. The plan correctly kept it out of scope. | Pre-existing drift that this branch did not introduce. | `plan.2026-09-29T20-45.md` Conventions, "Out of scope" |
| Info | branch | n/a | CR-8: `origin/main` advanced to `6c3649b0` (PR #835) after the merge-base. No changed path overlaps, and `git merge-tree --write-tree --name-only HEAD origin/main` is clean. | Update the branch from `main` before opening the PR, per repository practice. | Keeps the PR diff and CI run representative of the merge result. | `git log --oneline 08ee030d..origin/main` |

One Blocker (CR-2, awaiting_ci). No other Blocking findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The suite follows the established workflow-test pattern (`PublishMcpNpmWorkflow.Tests.ps1:19-35`) for isolating the `on:` block. This keeps branch lookups from matching unrelated text elsewhere in the file.
- `Get-CiTriggerBranchList` parses branch-filter semantics in both YAML flow and block forms rather than matching a literal line. The test therefore asserts behavior, not formatting.
- A guard assertion (`$script:triggerLines.Count | Should -BeGreaterThan 0`) prevents a vacuous pass when the trigger block cannot be found.
- The regression property was demonstrated end to end. The suite fails on the pre-fix file at `CiWorkflow.Tests.ps1:161` (CI run 37715960709) and passes on the fixed file (CI run 37717224700).

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([string[]])]`, mandatory parameters, `[AllowEmptyCollection()]`, `[AllowEmptyString()]`, and `[ValidateNotNullOrEmpty()]` are all present. The verb `Get-` is approved.
- The help text documents the array-enumeration behavior, and both call sites wrap the result in `@()`. The analyzer findings on unary-comma returns were resolved this way.
- `Set-StrictMode -Version Latest` is at line 1. There is no global state, no `ShouldProcess` requirement (read-only), and no module import.

#### Error handling and logging

- `Resolve-Path` fails the container when `ci.yml` is absent, which is the correct fail-fast behavior for a test.
- Assertions carry `-Because` text that names issue #658, so a failure message identifies the cause without reading source.

### GitHub Actions / Markdown audit

- `ci.yml`: the change is a single line. `"epic/**"` is double-quoted, as required because `*` is a YAML alias indicator. The `push` filter is unchanged, as the issue required. actionlint 1.7.11 reports no findings (reproduced at `9686d975`). No reusable workflow references `base_ref`, `github.ref`, or `event_name` (searched `.github/workflows/_*.yml`), so no job is silently skipped for an epic base.
- README: the trigger list matches `ci.yml` exactly, and the rationale sentence names `epic/<slug>-integration` and issue #658.
- Orchestrate skill: the paragraph is a continuation of step 2 at three-space indentation and does not renumber the list. The checkpoint field `epic_mode` and the `workflow` JSON field it references both exist in the skill and in `gh pr checks` output. The mirror is byte-identical (`cmp` exit 0), and the bundle-parity contract passes (14 tests).

---

## Test Quality Audit

The evidence chain for the new suite is complete for fail-before and pass-after. All PowerShell execution evidence comes from CI job logs under the operator's Option A rule. This review cannot query GitHub, so it checked those citations for internal consistency: run, job, and head SHA tuples; log-line ordering; and count arithmetic. No inconsistency was found in the substantive values. The timestamp-convention gap is reported separately (CR-3).

### Reviewed test and QA artifacts

- `tests/scripts/workflows/CiWorkflow.Tests.ps1`: verifies both trigger invariants. It is hermetic (grep for temp-file, process, YAML-module, import, and network tokens printed `0`) and 174 lines long.
- `evidence/regression-testing/fail-before-direct.2026-10-07T22-30.md` and `fail-before-poshqc.2026-10-07T22-30.md`: CI run 37715960709 on `632fe595`, which does not modify `ci.yml` (`git show --stat 632fe595`). Exactly one `[-]` line, naming the `pull_request` test. Counts 6520/1 against the 6519/0 baseline.
- `evidence/regression-testing/pass-after-direct.2026-10-08T02-30.md` and `pass-after-poshqc.2026-10-08T02-30.md`: CI run 37717224700 on `8a1b9b8b`, whose parent is fix commit `00798863`. Per-file `[+]` line, zero `[-]` lines, counts 6521/0.
- `evidence/qa-gates/final-poshqc-*.2026-10-08T02-30.md`, `final-sibling-pester.2026-10-08T02-30.md`, and `coverage-comparison.2026-10-08T02-30.md`: one CI job (113116383126) provides format, analyze, test, sibling-suite, and coverage values. Coverage is 84.32% to 84.32% command coverage, with identical denominators.
- `evidence/qa-gates/final-actionlint.2026-10-08T02-30.md`: direct-binary actionlint, exit 0. Reproduced by this review.
- `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-30.md`: green CI run on `8a1b9b8b` with 17 jobs, all `success`. Not at the current head (CR-2).

### Quality assessment prompts

- **Determinism:** pure text parsing of a committed file, with no clock, randomness, network, or process.
- **Isolation:** one invariant per `It`, and shared read-only setup in `BeforeAll`.
- **Speed:** 40 ms for the file in CI (5 ms discovery, 18 ms run).
- **Diagnostics:** the recorded failure message names the missing entry, the actual collection, and the issue number.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of all five changed production and test files. |
| No unsafe subprocess or command construction | PASS | The test launches no process. The workflow change adds no `run:` step. |
| Trigger scope and permissions | PASS | `pull_request` (not `pull_request_target`) is used, so fork PRs into `epic/**` receive the default read-only token. No `permissions` block was widened. |
| Error handling remains explicit | PASS | StrictMode is enabled and `Resolve-Path` fails fast. |
| Configuration / path handling is safe | PASS | The test path is resolved from `$PSScriptRoot` and read with `-LiteralPath`. |
| Gate semantics (S9) | PARTIAL | The rule is correct as text, but the parser does not enforce it mechanically (CR-1, Non-blocking). |

---

## Research Log

No external research was required. The feature folder's research document (`research/2026-09-29T20-50-epic-child-prs-ci-trigger-research.md`) covers the GitHub `branches` filter semantics. This review confirmed the in-repo facts it relies on: there are no `base_ref` or `event_name` conditions in the reusable workflows, and the parser returns `success` on an empty set.

---

## Verdict

The implementation is correct, minimal, and well tested for its scope. The YAML change is properly quoted and leaves the `push` trigger unchanged. The README documents the intent. The skill rule states the required gate behavior, and the mirror is byte-identical. The regression suite demonstrably fails before the fix and passes after it.

The change is not ready to merge until CR-2 is resolved. CR-2 needs a green CI run recorded against the final PR head. No code change is required. CR-1 is the most significant residual design risk. It is outside this issue's declared scope and should be filed as a follow-up so that the S9 epic-child rule becomes mechanically enforced. CR-3 through CR-8 are Non-blocking.
