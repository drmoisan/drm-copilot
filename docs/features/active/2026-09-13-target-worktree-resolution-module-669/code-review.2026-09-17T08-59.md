# Code Review: Target Worktree Resolution Module (#669)

---

**Review Date:** 2026-09-17
**Reviewer:** feature-review agent (Claude Opus 5)
**Feature Folder:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669`
**Feature Folder Selection Rule:** supplied by the caller. It is the only active folder whose scoping documents changed on the branch, and its `-669` suffix matches the branch name.
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` (merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
**Head Branch:** `feature/2026-09-13-target-worktree-resolution-module-669` (`8f82ffbf091e4b1485219ebd2d3aac6a726f3cfb`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds `.claude/lib/worktree-resolution/`, the repository's first worktree and call-target resolution primitive, as two PowerShell modules (480 and 341 lines). It also adds byte-identical bundle mirrors, `core.json` and `CodeCoverage.Path` registrations, and three Pester suites (106 tests). Of the 65 changed files, 13 are code, configuration, or requirement documents; the rest are evidence. No hook, MCP tool, or other consumer changes. The implementation follows the spec closely: filesystem access goes only through three mockable seams, results are always objects with closed field sets, the `NoTarget` and `Ambiguous` states differ by whether a signal is present, and no run state is read. Coverage is 98.59% and 100.00%, and format and analyze are clean.

**What changed:**
- `WorktreeResolution.psm1`: seams (`Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Get-WorktreeResolutionDirectoryChildName`), separator normalisation, `.git` root-marker test, bounded upward ascent, worktree enumeration through `gitdir`/`commondir` with the main checkout included, repo-relative normalisation with Ruling A, and the `TARGET_WORKTREE_AMBIGUOUS` accessor.
- `WorktreeTargetResolution.psm1`: the result factory with enforced invariants, three regex signal extractors (feature-folder with preserved absolute prefix, absolute file path, branch), `Resolve-WorktreeCallTarget` (four states; Ruling B disagreement returns Ambiguous), and `Join-WorktreeResolutionPath`.
- Registration in `core.json` and in both `pester.runsettings.psd1` copies, which are text-identical.

**Top 3 risks** (after the Blocker on coverage evidence, which is an artifact gap rather than a code risk):
1. An absolute path is placed by its nearest enclosing `.git` without checking that the root is a candidate worktree or that the path exists. A token under a removed nested worktree therefore resolves to the main checkout (`OtherWorktree` or `SessionRoot`) instead of `Ambiguous`. For F4 this is a narrow false-placement route.
2. `-Text` scanning reads a Branch signal from any `...branch: <name>` prose and a FilePath signal from any absolute path with an extension. Ruling B turns any disagreement into `Ambiguous`, so passing a whole delegation prompt (the spec's worked example) can deny calls that should be allowed. The denial fails closed, but F4 must account for it.
3. The repository-wide PoshQC test stage still exits 2 because of two pre-existing failures outside this scope. The single-pass toolchain criterion was satisfied under a baseline-relative reading, not its literal wording.

**PR readiness recommendation:** **Needs Revision** — The code is ready. The one Blocker concerns coverage evidence: the canonical PowerShell coverage artifact came from a scoped run (33.86% repo-wide), and no repo-wide measurement includes the new modules. Producing and recording that run is the only required change. The two Major findings concern how F4 will consume the contract and do not violate any F1 acceptance criterion.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/pester/powershell-coverage.xml` | report-level `counter[@type='LINE']` | This is the canonical PowerShell coverage artifact. It was last written by `Invoke-PoshQCTest -ScanFolders @('tests/scripts/claude-lib')` and reports 3243/9579 = 33.86% lines repo-wide. The only repo-wide run (MCP, 95.48%) used installed-extension settings whose denominator (9336) leaves out the two new modules. No run on the branch measures repo-wide PowerShell coverage with the new code included. | Run the self-hosted PoshQC test stage without `-ScanFolders` (in-repo runsettings), keep the output at `artifacts/pester/powershell-coverage.xml`, and record the report-level LINE counter and both `worktree-resolution` per-file rows under `evidence/qa-gates/`. No code change is expected. | The review contract and the feature-review SubagentStop hook read repo-wide coverage from this path, and the fail-closed rule does not allow an arithmetic estimate (95.57%) in place of a measurement. | Reviewer parse of the artifact (report LINE covered=3243, missed=6336); `evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md` (no `worktree-resolution` package). |
| Major | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | `Get-WorktreeResolutionSignalCandidate`, lines 215-222; with `WorktreeResolution.psm1` lines 444-450 | An absolute signal resolves to the nearest ancestor with a `.git` marker, with no check that the root is in `Get-WorktreeResolutionWorktreeRoot -SessionRoot` and no check that the path exists. For `C:/repo/.claude/worktrees/<removed>/docs/features/active/x`, the ascent passes the absent `<removed>/.git` and returns `C:/repo`, so the call resolves to the main checkout. An absolute path into an unrelated repository resolves to `OtherWorktree` in the same way. | Before F4 consumes the resolver, treat an absolute signal as resolved only when the located root is a member of the session's candidate set and the named path exists (seam probe is not `None`); otherwise return `Ambiguous`. Add matrix rows for a removed nested worktree and a foreign repository. | The epic's purpose is to remove false approval. The spec states that "every unlocatable case" should deny "rather than guessing". A consumer that composes `Join-WorktreeResolutionPath -WorktreeRoot <main> -RepoRelativePath docs/features/active/x/...` would read main-checkout state for an item whose worktree no longer exists. | Static reading of `Find-WorktreeResolutionRoot` (lines 278-288) and `Get-WorktreeResolutionSignalCandidate`. Not executed: this reviewer's shell guard refuses PowerShell 7 invocation. No existing test covers the case; the closest, "ascends several levels to the nearest root", uses an existing worktree. |
| Major | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | `$script:BranchPattern` line 61; `$script:FilePathPattern` line 57; signal assembly lines 268-274 | Free-text scanning is broader than delegation prompts tolerate. `(?i)\bbranch:\s*` matches "Base branch: main" and "Resolved base branch: origin/epic/..." (the first occurrence wins). The FilePath pattern matches any absolute path with an extension, such as a memory file under `C:/Users/<u>/.claude/projects/...` or an evidence file in another worktree. Under Ruling B, any such signal that disagrees with the feature-folder token makes the result `Ambiguous`, and one that places nowhere does too. | Record in F4's inputs that `-Text` should not be the only input for whole prompts. Either pass explicit `-Branch`/`-FilePath` values, or add an F1 option that limits `-Text` scanning to the feature-folder signal. Add tests that use realistic orchestrator delegation prompts containing base-branch lines and unrelated absolute paths. | The resulting denial is fail-closed, but it recreates the "false denial" failure mode the user story names, and Scenario A's allow case depends on the whole-prompt call shown in the spec's worked example. | Regex text at lines 57 and 61. Test "returns null ... prose naming no branch" uses "the feature branch is ready" (no colon), so the colon form is untested. |
| Minor | `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | lines 94 and 111 | The read and enumeration seams use `-ErrorAction SilentlyContinue`. An access-denied or I/O error is reported the same way as an absent file or directory. | Keep the fail-closed outcome, but record the suppressed error, for example in the calling result's `Detail`, or document the choice in the seam help. | Repository policy prohibits silently ignoring errors. The current behaviour denies safely, but an operator cannot tell a permissions problem from a missing worktree. | `.claude/rules/general-code-change.md` "Error Handling and Logging"; `.claude/rules/powershell.md` "avoid silent catch-alls". |
| Minor | `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | `Get-WorktreeResolutionWorktreeRoot`, lines 371-397 | Enumeration returns roots for prunable worktrees, where the admin `gitdir` names a `.git` file that no longer exists. The branch filter reads the admin `HEAD`, so a branch signal can resolve to a directory that is not on disk. | Skip an entry when the seam reports `None` for `<root>/.git`. Add a test row for a prunable admin entry. | A branch match on a stale admin entry produces `OtherWorktree` for a missing directory. A consumer's later `Test-Path` would deny, so the effect is limited. | Static reading; the enumeration tests model only live worktrees plus one orphan without a `gitdir` file. |
| Minor | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/scope-boundary.2026-09-13T22-00.md` | Command line; also `changed-file-inventory...md` and `evidence/baseline/baseline-merge-base...md` | The recorded merge base is `d93e2916` (a `main` merge commit), not the resolved PR base `79fd5a95` from which the branch forked (the parent of `f0730a01`). | Record the resolved epic-integration merge base in future baseline evidence for epic-child features. | Evidence should name the base the PR is reviewed against. The conclusions still hold: `d93e2916` is an ancestor of `79fd5a95`, and no path under `.claude`, `.codex`, `extensions`, `scripts`, or `tests` differs between them. | `git merge-base --is-ancestor d93e2916 79fd5a95` (exit 0); `git diff --name-only d93e2916 79fd5a95 -- .claude .codex extensions scripts tests` (empty). |
| Minor | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md` | Policy compliance criterion 5 | The repository-wide PoshQC test stage exited 2 (`ok: false`) in both the baseline and final runs because of `enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`. The criterion says "with no stage failing" and was checked under the plan's baseline-relative definition. | Track the two pre-existing failures as their own issue. For future criteria, state the baseline-relative definition in the criterion text. | The literal wording and the evidence differ. The difference is not attributable to this branch: the failure sets are identical, and the branch changes no hook. | `evidence/other/baseline-pester-junit.2026-09-13T22-00.xml` and `final-pester-junit.2026-09-13T22-00.xml`, compared by this reviewer. |
| Info | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | line 27; `Export-ModuleMember` lines 335-341 | File 2 imports File 1 without `-Global` and does not re-export it. A caller that imports only `WorktreeTargetResolution.psm1` most likely cannot call `ConvertTo-WorktreeResolutionRepoRelativePath` or `Get-WorktreeResolutionAmbiguityReasonCode`. The spec's API table also lists `Join-WorktreeResolutionPath` under File 1, but it lives in File 2, as the line-budget note permits. | Tell F4 and F5 to import both modules, and update the spec's API table to show where `Join-WorktreeResolutionPath` lives. | This avoids a command-not-found error when the contract is first consumed. | Both suites import File 1 explicitly before File 2. Import scoping was inferred from PowerShell module semantics, not executed. |
| Nit | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | line 285 | The per-signal Ambiguous `Detail` gives the candidate count but not the candidate roots. The spec's four-state table says Detail names "the signal value and the candidate set". | Append the candidate roots when the count is 2 or more, as the disagreement branch at line 296 already does. | This gives an operator more to act on in a deny message. The `Candidates` field already carries the roots. | Spec "The four states, with exact field values", row 4. |
| Info | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/` | six `*.xml` files | Full Pester JUnit and coverage captures total about 73,000 lines, most of the 77,348 inserted lines. | Consider whether future plans should commit extracted rows and hashes instead of full captures. | This adds review and repository-size cost without changing the result. | `git diff --stat 79fd5a95..HEAD`. |
| Info | `artifacts/pr_context.summary.txt` | "Auto-close issues (author asserted)" | The PR-context parser lists `#SHA-256` as an author-asserted close reference alongside `#669`. | Make sure the PR body references only `#669` in closing keywords. | This prevents a false issue reference in the PR metadata. | PR context summary lines 38-40. |
| Info | `evidence/qa-gates/mcp-coverage-path-determination.2026-09-13T22-00.md` | n/a | Ruling D reproduced: the MCP PoshQC runner reads the installed extension's runsettings, so its repository-wide denominator omits the two new modules until the extension is rebuilt. | Confirm on the PR's CI run that the in-repo runsettings include both modules in the coverage report. | The per-file coverage used for this review came from the self-hosted run, which reads the in-repo settings. | The final MCP coverage XML has no `worktree-resolution` package; the self-hosted XML does. |

One Blocker finding, on coverage evidence only. Two Major findings are advisory inputs for F4.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Every filesystem touch goes through three exported seams (`WorktreeResolution.psm1:57-112`). This allows the Pester suites to model main-checkout, nested, sibling, bare, relative-pointer, and orphan topologies with no temporary files.
- Result objects are built by exactly one constructor each (`ConvertTo-WorktreeResolutionNormalizationResult`, `New-WorktreeResolutionTargetResult`). Each constructor enforces the contract invariants: `ReasonCode` is set if and only if the result is unresolved or ambiguous, `Candidates` is always a `string[]`, and `WorktreeRoot` is set only for resolved states.
- The ascent is bounded by both the drive or filesystem root and `MaximumDepth`, and it refuses relative input rather than resolving it against the current directory (`Find-WorktreeResolutionRoot`, lines 278-281).
- Enumeration follows the verified `gitdir`/`commondir` layout, resolves relative pointers, collapses `..`, deduplicates case-insensitively, and includes the main checkout only when the common directory is a `.git` directory, which handles bare repositories correctly.
- The feature-folder extractor keeps any absolute prefix (the correction to the epic's F4 characterisation), and a regex lookbehind stops matches starting inside another word (`foo-docs/...`).
- The disagreement check runs over every present signal before the precedence-first signal is chosen for reporting (lines 280-297), which matches Ruling B.

#### API and safety notes

- All 15 exported functions are advanced functions with `OutputType`. Validation attributes enforce the closed `Status` and `Signal` sets and the non-blank fields.
- The one analyzer suppression (`PSUseShouldProcessForStateChangingFunctions` on the pure factory) is scoped and justified.
- No subprocess, `Invoke-Expression`, `$env:`, clock, or network use was found; a grep of both modules for these tokens found none. `orchestrator-state` and `checkpoint` do not appear in either module.
- `Get-Location` is read only when `-SessionRoot` is omitted, and the result is passed through the locator.

#### Error handling and logging

- Module scope uses `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`, and the sibling import uses `-ErrorAction Stop`.
- Contract violations (`resolved Status without WorktreeRoot`, relative `WorktreeRoot` in the join) throw with specific messages.
- The read seams suppress errors to a `$null` or empty result (Minor finding above). No logging is emitted, which the spec requires.

---

## Test Quality Audit

The three suites contain 106 tests, all passing in the final JUnit capture (7 manifest, 48 locator, 51 resolver). Per-file line coverage is 98.59% and 100.00%, re-read by this reviewer from `artifacts/pester/powershell-coverage.xml` in the `worktree-resolution` package. The two uncovered lines (`WorktreeResolution.psm1:189`, `:206`) are defensive returns. The 12-row required matrix and all six documented Ambiguous sub-cases are present as table-driven rows.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` — seams, normalisation, root marker, ascent limits, enumeration topologies, Rulings A and C, reason-code pinning. Gap: no row for a prunable or removed worktree.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1` — factory invariants, extractors, required matrix, Ambiguous sub-cases, NoTarget without seam calls, Ruling B agreement and disagreement, deny-reason concatenation. Gap: no realistic multi-line delegation prompt containing base-branch lines or unrelated absolute paths.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` — follows `DiscoveryValidation.Manifest.Tests.ps1`: `-Contain`, exactly-once, on-disk coverage, SHA-256 mirror identity with a `Test-Path` guard.
- `evidence/other/final-pester-junit.2026-09-13T22-00.xml` — 4653 tests, 2 failures, both also present in `baseline-pester-junit.2026-09-13T22-00.xml`.
- `evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md` — scoped run, 1490 passed, per-file LINE counters.
- `evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md` — 33 passed after the final repair, with both modules in the scan scope.

### Quality assessment prompts

- **Determinism:** topologies are in-memory hashtables behind module-scoped mocks. There is no clock, randomness, process, or temporary file. The only real reads are of tracked repository files.
- **Isolation:** one behaviour per `It`; `-ForEach` rows are labelled.
- **Speed:** 1490 scoped tests in 36.71 s; the new suites add in-memory work only.
- **Diagnostics:** `Should -BeExactly` against literals, and `-Because` on the manifest and mirror assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of both modules and suites. |
| No unsafe subprocess or command construction | PASS | No process start, `Invoke-Expression`, or `&` on dynamic input; grep of both modules. |
| Input validation at boundaries | PASS | `ValidateSet`, `ValidatePattern`, `ValidateRange`, and the relative-input refusal in the ascent. |
| Error handling remains explicit | PARTIAL | Contract violations throw, but the read seams suppress I/O errors (Minor finding). |
| Configuration / path handling is safe | PARTIAL | `-LiteralPath` is used throughout and no string-prefix containment is used. Absolute-path placement does not check candidate membership or existence (Major finding). |
| Registration and mirror integrity | PASS | `core.json` has 172 unique entries, including both modules. Mirror SHA-256 and git blob ids are identical. The runsettings copies are byte-identical. |

---

## Research Log

No external research was required. All findings come from inspecting the branch diff, the two modules, the three suites, the feature-folder evidence, and XML artifacts parsed with check-only commands.

---

## Verdict

The code meets the F1 contract as specified, is well tested, and changes no consumer. The branch is ready for PR flow into `epic/worktree-scoped-state-resolution-integration` once one piece of evidence is fixed. The canonical PowerShell coverage artifact currently comes from a scoped run, so a repo-wide self-hosted PoshQC test run that includes the two new modules must be produced and recorded (Blocker; remediation item R1). No code change is expected for that item.

The two Major findings concern how F4 will use `Resolve-WorktreeCallTarget`: absolute-path placement without a candidate or existence check, and free-text extraction of branch and file-path signals. Resolve both, in an F1 follow-up or as explicit F4 inputs, before F4 wires the resolver into `enforce-prd-feature-before-planner.ps1`. The first can resolve a stale path to the main checkout. The second can deny delegation prompts that should be allowed.
