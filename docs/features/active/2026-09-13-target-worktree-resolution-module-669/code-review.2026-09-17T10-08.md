# Code Review: Target Worktree Resolution Module (#669) — Re-audit after Remediation Cycle 1

---

**Review Date:** 2026-09-17
**Reviewer:** feature-review agent (Claude Opus 5)
**Feature Folder:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669`
**Feature Folder Selection Rule:** supplied by the caller. It is the only active folder whose scoping documents changed on the branch, and its `-669` suffix matches the branch name.
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` (tip `590b26abd1b25948b0590b060da324ba567bf707`; merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
**Head Branch:** `feature/2026-09-13-target-worktree-resolution-module-669` (`a5e2bf73e49c4427bc7f379cb690dc677306d910`)
**Review Type:** Re-audit after remediation cycle 1 (prior review: `code-review.2026-09-17T08-59.md` at head `8f82ffbf`)

---

## Executive Summary

The branch adds `.claude/lib/worktree-resolution/`, the repository's first worktree and call-target resolution primitive, as two PowerShell modules (480 and 341 lines). It also adds byte-identical bundle mirrors, `core.json` and `CodeCoverage.Path` registrations, and three Pester suites (106 tests). The full diff has 81 files, and 10 of them are outside `docs/`. No hook, MCP tool, or other consumer changes.

Since the prior review, three commits were added (`4a34fbe1`, `a3ab38b1`, `a5e2bf73`). All three touch only paths under the feature folder. The code reviewed in cycle 1 is therefore unchanged, and this reviewer re-confirmed that with `git diff --name-only 8f82ffbf..a5e2bf73` and with SHA-256 comparisons of the modules and mirrors.

The cycle-1 Blocker (R1) is resolved. The canonical `artifacts/pester/powershell-coverage.xml` now comes from an unscoped self-hosted run. Its report-level LINE counter is 9155/9579 = 95.57%, and it includes the `worktree-resolution` package at 98.59% and 100.00%. This reviewer recomputed every figure from the XML and confirmed that the committed evidence copies are byte-identical to the canonical files.

**What changed (full branch):**
- `WorktreeResolution.psm1`: seams (`Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Get-WorktreeResolutionDirectoryChildName`), separator normalisation, `.git` root-marker test, bounded upward ascent, worktree enumeration through `gitdir`/`commondir` with the main checkout included, repo-relative normalisation with Ruling A, and the `TARGET_WORKTREE_AMBIGUOUS` accessor.
- `WorktreeTargetResolution.psm1`: the result factory with enforced invariants, three regex signal extractors, `Resolve-WorktreeCallTarget` (four states; Ruling B disagreement returns Ambiguous), and `Join-WorktreeResolutionPath`.
- Registration in `core.json` and in both `pester.runsettings.psd1` copies, which are text-identical.
- Cycle 1: 11 evidence files under `evidence/remediation-baseline/`, `evidence/qa-gates/`, and `evidence/other/`, and task check-offs in `remediation-plan.2026-09-17T09-10.md`.

**Top 3 risks:**
1. An absolute path is placed by its nearest enclosing `.git` without checking that the root is a candidate worktree or that the path exists. A token under a removed nested worktree therefore resolves to the main checkout. This is carried forward from cycle 1 as an input for F4, and no F4 document on this branch records it yet.
2. `-Text` scanning reads a Branch signal from any `...branch: <name>` prose and a FilePath signal from any absolute path with an extension. Under Ruling B, a whole delegation prompt can therefore fail closed to `Ambiguous`. This is also carried forward as an F4 input.
3. The repository-wide PoshQC test stage still exits 2 because of two pre-existing failures outside this scope. The R1 run shows the same two failures and no others.

**PR readiness recommendation:** **Ready** — No Blocker remains. The two Major findings concern how F4 will consume the contract. They do not violate any F1 acceptance criterion or any policy rule that blocks this PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (resolved Blocker R1) | `artifacts/pester/powershell-coverage.xml` | report-level `counter[@type='LINE']` | Resolved. The artifact is now the output of `Invoke-PoshQCTest -Root (Get-Location).Path` with no `-ScanFolders` (report name `Pester (09/17/2026 09:58:10)`). Report LINE covered=9155, missed=424 (95.57%). The package ending `worktree-resolution` holds `WorktreeResolution.psm1` 140/2 (98.59%) and `WorktreeTargetResolution.psm1` 101/0 (100.00%). | None required. | Meets the 85% repo-wide and per-file thresholds with a measurement rather than an estimate, as R1 required. | Reviewer parse of the canonical XML and of `evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml`; both SHA-256 `4B230FCA79A6...6BA4DFC`; `evidence/qa-gates/r1-coverage-delta.2026-09-17T09-10.md`. |
| Major | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | `Get-WorktreeResolutionSignalCandidate`, lines 215-222; with `WorktreeResolution.psm1` lines 444-450 | Carried forward. An absolute signal resolves to the nearest ancestor with a `.git` marker. The code does not check that this root is in `Get-WorktreeResolutionWorktreeRoot -SessionRoot`, and it does not check that the path exists. For `C:/repo/.claude/worktrees/<removed>/docs/features/active/x`, the ascent passes the absent `<removed>/.git` and returns `C:/repo`. | Before F4 consumes the resolver, treat an absolute signal as resolved only when the located root is in the session's candidate set and the named path exists; otherwise return `Ambiguous`. Add matrix rows for a removed nested worktree and a foreign repository. Record this in F4's inputs, since no F4 document on this branch mentions it. | The epic's purpose is to remove false approval. The spec says every unlocatable case should deny rather than guess. | Static reading of `Find-WorktreeResolutionRoot` and `Get-WorktreeResolutionSignalCandidate`; grep of `docs/` finds the finding only in this feature's review artifacts. Not executed: this reviewer's shell guard refuses PowerShell 7 invocation. |
| Major | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | `$script:BranchPattern` line 61; `$script:FilePathPattern` line 57; signal assembly lines 268-274 | Carried forward. `(?i)\bbranch:\s*` matches "Base branch: main" and "Resolved base branch: origin/epic/...". The FilePath pattern matches any absolute path with an extension. Under Ruling B, any such signal that disagrees with the feature-folder token, or that places nowhere, makes the result `Ambiguous`. | Record in F4's inputs that `-Text` should not be the only input for whole prompts. Either pass explicit `-Branch`/`-FilePath` values, or add an option that limits `-Text` scanning to the feature-folder signal. Add tests with realistic orchestrator delegation prompts. | The denial is fail-closed, but it recreates the "false denial" failure mode the user story names. | Regex text at lines 57 and 61. The colon form of branch prose is not covered by a test. |
| Minor | `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | lines 94 and 111 | Carried forward. The read and enumeration seams use `-ErrorAction SilentlyContinue`, so an access-denied or I/O error is reported the same way as an absent path. | Keep the fail-closed outcome, but surface the suppressed error (for example in the calling result's `Detail`) or document the choice in the seam help. | Repository policy prohibits silently ignoring errors. | `.claude/rules/general-code-change.md` "Error Handling and Logging"; `.claude/rules/powershell.md`. |
| Minor | `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | `Get-WorktreeResolutionWorktreeRoot`, lines 371-397 | Carried forward. Enumeration returns roots for prunable worktrees, where the admin `gitdir` names a `.git` file that no longer exists. A branch signal can therefore resolve to a directory that is not on disk. | Skip an entry when the seam reports `None` for `<root>/.git`. Add a test row for a prunable admin entry. | A consumer's later `Test-Path` would deny, so the effect is limited. | Static reading; the enumeration tests model only live worktrees plus one orphan without a `gitdir` file. |
| Minor | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/scope-boundary.2026-09-13T22-00.md` | Command line; also `changed-file-inventory...md` and `evidence/baseline/baseline-merge-base...md` | Carried forward. The original evidence records `d93e2916` as the merge base rather than the resolved PR base `79fd5a95`. The cycle-1 evidence (`baseline-merge-base.r1...md`) uses `79fd5a95`. | Record the resolved epic-integration merge base in future baseline evidence for epic-child features. | The conclusions still hold: `d93e2916` is an ancestor of `79fd5a95`, and no code path differs between them (cycle-1 reviewer check). | `evidence/remediation-baseline/baseline-merge-base.r1.2026-09-17T09-10.md`. |
| Minor | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md` | Policy compliance criterion 5 | Carried forward. The repository-wide PoshQC test stage exits 2 in the baseline, final, and R1 runs because of `enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`. The criterion was checked under the plan's baseline-relative definition. | Track the two pre-existing failures as their own issue. | The literal wording and the evidence differ. The difference is not attributable to this branch. | `evidence/qa-gates/r1-failure-set-verification.2026-09-17T09-10.md`; reviewer JUnit status count 4642 passed, 2 failed, 9 skipped. |
| Info | `.codex/hooks/record-subagent-routing-attestation.ps1` | coverage row in `artifacts/pester/powershell-coverage.xml` | New observation. Three pre-existing files are below 85% line coverage in the repo-wide report: `record-subagent-routing-attestation.ps1` (103/192), `scripts/dev-tools/new-claude-worktree-session.ps1` (46/75), and one of the two `.codex/hooks/enforce-completion-helpers.ps1` rows (33/43). | Track these files in a separate issue; they are outside this feature. | Their counters are identical to the MCP baseline capture, and this branch changes no file under `.codex`, `.claude/hooks`, or `scripts/dev-tools`. | `lowfiles_669.py` comparison of the baseline and R1 XML; empty `git diff --name-only 79fd5a95..HEAD -- .codex scripts/dev-tools .claude/hooks`. |
| Info | `artifacts/pester/powershell-coverage.koverage.xml` | file timestamp | New observation. This file still has its 08:42 timestamp, so the R1 run did not rewrite it, although the remediation plan said it would be overwritten. | None for this PR. If a future gate reads this file, confirm which run writes it. | No review or evidence step reads this file. | `ls -la artifacts/pester/`. |
| Info | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | line 27; `Export-ModuleMember` lines 335-341 | Carried forward. File 2 imports File 1 without `-Global` and does not re-export it. The spec's API table lists `Join-WorktreeResolutionPath` under File 1, but it lives in File 2. | Tell F4 and F5 to import both modules, and update the spec's API table. | This avoids a command-not-found error when the contract is first consumed. | Both suites import File 1 explicitly before File 2. |
| Nit | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | line 285 | Carried forward. The per-signal Ambiguous `Detail` gives the candidate count but not the candidate roots. | Append the candidate roots when the count is 2 or more, as the disagreement branch already does. | This gives an operator more to act on in a deny message. | Spec "The four states, with exact field values", row 4. |
| Info | `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/` | eight `*.xml` files | Extended. Cycle 1 added two more full captures (14,984 and 7,215 lines). The branch now carries about 95,000 lines of captured XML. | Consider committing extracted rows and hashes instead of full captures in future plans. | This adds review and repository-size cost without changing the result. | `git diff --stat 79fd5a95...HEAD`. |
| Info | `artifacts/pr_context.summary.txt` | "Auto-close issues (author asserted)"; "Changed files overview" | Carried forward. The parser lists `#SHA-256` as an author-asserted close reference alongside `#669`. It also groups `.psm1` modules under "Docs/templates/agents/tooling". | Make sure the PR body uses closing keywords only for `#669`. | This prevents a false issue reference in the PR metadata. | PR context summary regenerated 2026-09-17 14:05:14 UTC at head `a5e2bf73`. |
| Info | `evidence/qa-gates/mcp-coverage-path-determination.2026-09-13T22-00.md` | n/a | Carried forward. The MCP PoshQC runner reads the installed extension's runsettings, so its denominator leaves out the two new modules until the extension is rebuilt. The R1 self-hosted run supplies the in-repo measurement. | Confirm on the PR's CI run that the in-repo runsettings include both modules. | CI is the independent confirmation of the local self-hosted result. | The R1 coverage XML has the `worktree-resolution` package; the MCP XML does not. |

No Blocker findings. Two Major findings are advisory inputs for F4.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Every filesystem touch goes through three exported seams (`WorktreeResolution.psm1:57-112`). The Pester suites therefore model main-checkout, nested, sibling, bare, relative-pointer, and orphan topologies without temporary files.
- Result objects are built by exactly one constructor each (`ConvertTo-WorktreeResolutionNormalizationResult`, `New-WorktreeResolutionTargetResult`). Each constructor enforces the contract invariants.
- The ascent is bounded by the drive or filesystem root and by `MaximumDepth`, and it refuses relative input.
- Enumeration follows the verified `gitdir`/`commondir` layout, resolves relative pointers, collapses `..`, deduplicates case-insensitively, and handles bare repositories.
- The feature-folder extractor keeps any absolute prefix, and a regex lookbehind stops matches that start inside another word.
- The disagreement check runs over every present signal before the precedence-first signal is chosen for reporting, which matches Ruling B.
- Cycle 1 followed the remediation constraints. It made no code change, used no scan-folder narrowing, copied the run output into evidence before any later run could overwrite it, and hash-checked the copies.

#### API and safety notes

- All 15 exported functions are advanced functions with `OutputType`. Validation attributes enforce the closed `Status` and `Signal` sets and the non-blank fields.
- The one analyzer suppression (`PSUseShouldProcessForStateChangingFunctions` on the pure factory) is scoped and justified.
- No subprocess, `Invoke-Expression`, `$env:`, clock, or network use. `orchestrator-state` and `checkpoint` do not appear in either module.
- `Get-Location` is read only when `-SessionRoot` is omitted.

#### Error handling and logging

- Module scope uses `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`, and the sibling import uses `-ErrorAction Stop`.
- Contract violations throw with specific messages.
- The read seams suppress errors to a `$null` or empty result (Minor finding above). No logging is emitted, which the spec requires.

---

## Test Quality Audit

In the repo-wide R1 run, all 106 tests in the three suites pass: 7 manifest, 48 locator, and 51 resolver. This reviewer counted `testcase` statuses in `evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml`. Per-file line coverage is 98.59% and 100.00%. The two uncovered lines (`WorktreeResolution.psm1:189`, `:206`) are defensive returns. The 12-row required matrix and all six documented Ambiguous sub-cases are present as table-driven rows.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` — seams, normalisation, root marker, ascent limits, enumeration topologies, Rulings A and C, reason-code pinning. Gap: no row for a prunable or removed worktree.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1` — factory invariants, extractors, required matrix, Ambiguous sub-cases, NoTarget without seam calls, Ruling B agreement and disagreement, deny-reason concatenation. Gap: no realistic multi-line delegation prompt.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` — `-Contain`, exactly-once, on-disk coverage, SHA-256 mirror identity with a `Test-Path` guard.
- `evidence/qa-gates/repo-wide-poshqc-run.2026-09-17T09-10.md` — command without `-ScanFolders`, exit code 2, Pester summary `Tests Passed: 4642, Failed: 2, Skipped: 9`, and post-run timestamps later than the pre-run values in `baseline-artifact-timestamps.r1...md`.
- `evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md` and `r1-coverage-delta.2026-09-17T09-10.md` — report and per-file counters. This reviewer's recomputation matches them.
- `evidence/qa-gates/r1-failure-set-verification.2026-09-17T09-10.md` — the failing set equals the two baseline names.
- `evidence/qa-gates/r1-tree-confirmation.2026-09-17T09-10.md` — no path outside the feature folder changed during cycle 1.
- `evidence/other/repo-wide-copy-verification.r1.2026-09-17T09-10.md` — the recorded hashes match this reviewer's recomputation.

### Quality assessment prompts

- **Determinism:** topologies are in-memory hashtables behind module-scoped mocks. The suites give the same results in the scoped run and in the repo-wide run.
- **Isolation:** one behaviour per `It`; `-ForEach` rows are labelled.
- **Speed:** the new suites add in-memory work only.
- **Diagnostics:** `Should -BeExactly` against literals, and `-Because` on the manifest and mirror assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of both modules and suites (unchanged since cycle 1). |
| No unsafe subprocess or command construction | PASS | No process start, `Invoke-Expression`, or `&` on dynamic input. |
| Input validation at boundaries | PASS | `ValidateSet`, `ValidatePattern`, `ValidateRange`, and the relative-input refusal in the ascent. |
| Error handling remains explicit | PARTIAL | Contract violations throw, but the read seams suppress I/O errors (Minor finding). |
| Configuration / path handling is safe | PARTIAL | `-LiteralPath` is used throughout and no string-prefix containment is used. Absolute-path placement does not check candidate membership or existence (Major finding). |
| Registration and mirror integrity | PASS | `core.json` has 172 unique entries, including both modules. Mirror SHA-256 values match (`e5c1c03c0c97...`, `ede6ad1659e7...`). The runsettings copies are byte-identical. |
| Evidence integrity | PASS | Canonical and committed XML copies have identical SHA-256 values, and the recorded counters match this reviewer's parse. |

---

## Research Log

No external research was required. The findings come from the branch diff, the two modules, the three suites, the feature-folder evidence, and XML artifacts parsed with check-only commands.

---

## Verdict

The code meets the F1 contract as specified, is well tested, and changes no consumer. The cycle-1 Blocker is resolved: repo-wide PowerShell coverage, measured with both new modules in the denominator, is 95.57%. The branch is ready for PR flow into `epic/worktree-scoped-state-resolution-integration`.

The two Major findings are about how F4 will use `Resolve-WorktreeCallTarget`: absolute-path placement has no candidate or existence check, and free-text extraction of branch and file-path signals is broad. Record both in F4's inputs, or address them in an F1 follow-up, before F4 wires the resolver into `enforce-prd-feature-before-planner.ps1`.
