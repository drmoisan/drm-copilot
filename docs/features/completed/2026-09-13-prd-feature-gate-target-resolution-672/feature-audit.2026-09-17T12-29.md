# Feature Audit — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T12-29
- Work mode: `full-bug`
- Acceptance-criteria source: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` only

## Scope and Baseline

- Base branch: `epic/worktree-scoped-state-resolution-integration`
- Merge base: `d039e89b2b2569151e9170e1bbefb9f974419f87`
- Head: `03dfdc84fa7fd6107545d4b52f34247961d306f5`
- Range audited: `d039e89b..03dfdc84`, 50 files, 2709 insertions, 455 deletions
- Languages with changed files: PowerShell only. Extensions in the diff: 40 `.md`, 7 `.ps1`, 2 `.psd1`, 1 `.json`.
- PR context artifacts: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-09-17 16:17:37 UTC against the base above. Both were current for the audited head SHA; no regeneration was required.
- Work-mode resolution: `issue.md` carries the marker `- Work Mode: full-bug`, so `spec.md` is the sole acceptance-criteria source and `user-story.md` is neither expected nor present.

Delivered surface:

| Change | Path |
|---|---|
| Modified production hook | `.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| Added production sibling | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| Bundled mirrors of both | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` |
| Pack-manifest registration | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` |
| Coverage-path registration | both copies of `PoshQC/settings/pester.runsettings.psd1` |
| Added test suite | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` |
| Modified test suites | `enforce-prd-feature-before-planner.Tests.ps1`, `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` |
| Requirement and plan documents | `spec.md` (checkbox state only), `plan.2026-09-13T20-47.md` |
| Evidence | 36 artifacts under `evidence/{baseline,other,qa-gates,regression-testing}/` |

Baseline integrity check: a normalised diff of `spec.md` between the merge base and the head, with checkbox
state neutralised, returns zero differences. No acceptance-criterion text was added, removed, reworded, or
weakened during execution.

## Acceptance Criteria Inventory

- Source file: `spec.md`, section `## Acceptance Criteria` (lines 600-669)
- Total acceptance criteria: 38
- Checked in the source file at review time: 37
- Unchecked in the source file at review time: 1 (criterion 37)

Criteria are numbered below in source order.

## Acceptance Criteria Evaluation

### The three-way distinction

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | State 1 — target resolved, required document present, ALLOW; probe composed against the target root | PASS | `TargetResolution.Tests.ps1` case `allows when the target root holds the required document`: session root is the coordinating root, existence mock answers true only for `/synthetic-worktrees/item-worktree/.../spec.md`. Passes at head; failed at the pre-change hook per `evidence/regression-testing/fail-before.2026-09-17T11-20.md` row 1. |
| 2 | State 2 — document genuinely absent, DENY with the existing reason, `PRD_FEATURE_BLOCKED:` retained | PASS | Case `denies with the missing-document reason when the document is absent under the target root` asserts the prefix, the resolved-folder lead, `is missing: spec.md`, `work mode: full-bug`, and `invoke the prd-feature subagent`. Reason text differs from base only in the resolved-folder value. |
| 3 | State 3 — target not resolvable, DENY with F1's ambiguity code, greppable as a single literal, distinct from the other two reasons | PASS | Cases `denies with the ambiguity code when the target cannot be resolved` and `emits an ambiguity code distinct from the missing-document and marker reasons`. The latter asserts a match count of exactly 1 and asserts the reason is not like `*is missing:*` or `*work mode could not be determined*`. Code is read from `Get-WorktreeResolutionAmbiguityReasonCode`, not restated. |

### All three current conflation sites are addressed

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 4 | Unconditional post-prompt checkpoint fallback removed; consulted only when the call has no target and the session root is the derived target | PASS | Hook lines 327-336: the fallback is guarded by `Test-PrdFeatureSessionRootTarget`, and a non-session-root target returns the ambiguity deny. Case `denies rather than validating against a sibling session checkpoint` asserts deny, asserts the ambiguity code, asserts the sibling folder name does not appear in the reason, and asserts zero existence probes. |
| 5 | Positional tie-break removed; unresolved tie denies with the ambiguity code | PASS | `Find-PrdFeatureFolderFromPrompt` returns `$null` on an unresolved multi-candidate tie; hook lines 321-323 convert that to the ambiguity deny. Cases `denies rather than selecting the earliest candidate on an unresolved tie` and the two re-specified `FolderResolution` cases. The two former earliest-candidate cases were re-specified, not deleted. |
| 6 | Missing/malformed-marker branch reached only when the folder exists under the resolved target root | **PARTIAL** | The guard at hook line 368 is conditioned on `$probeFolder -ne $folderNormalized`, so it fires only when the derived target is `OtherWorktree`. Case `denies with the ambiguity reason when the folder is absent from the target root` passes for that shape. For a repo-relative citation no target is derived, `$probeFolder -eq $folderNormalized`, and a folder absent from the session root still produces the marker-is-broken reason together with its remedy to edit `issue.md`. Confirmed by direct execution (review diagnostic D2). |

### False-approval guards

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 7 | Ambiguity branch denies before any document probe; zero-invocation count asserted | PASS | Case `runs no existence probe on the ambiguity branch` asserts `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly`. Hook line 312 returns before line 316. |
| 8 | Allow rows assert an exact positive invocation count matching the row's work mode | PASS | `probes once on a full-bug allow row` asserts `-Times 1 -Exactly`; `probes twice on a full-feature allow row` asserts `-Times 2 -Exactly`; the four `-ForEach` work-mode rows each assert their own `ExpectedProbes` value (2, 1, 0, 2). |
| 9 | Every matrix row uses the same resolved-target root and differs only in the existence mock; no blanket always-true mock | PASS | Every `Get-PrdFeatureFileExistence` mock in the new suite is an equality or `-in` test against a fully composed path. The one pre-existing blanket `{ $true }` mock in `enforce-prd-feature-before-planner.Tests.ps1` was replaced with a two-path `-in` mock in this change set. |

### Mandatory test-matrix rows

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 10 | Row — own folder named, cwd modelled as the session root: allow; the defect's direct proof | **PARTIAL** | Delivered as case `allows when the target root holds the required document`, which names the folder as an absolute composed path. That row passes and did fail against the pre-change hook. No delivered row names the folder in repo-relative form with the session root distinct from the target, and by direct execution that shape still denies (review diagnostic D2). Under the reading that "own folder named" means the repo-relative form used by the originating run — the reading that keeps this criterion distinct from criterion 12 — the row is not delivered. |
| 11 | Row — own folder named, cwd modelled as the item worktree: allow, unchanged, retained as a regression guard | PASS | Case `allows when the modelled cwd is the item worktree`, with no injected target and no absolute token, asserts allow. Recorded as passing against the pre-change hook in the fail-before evidence (row 2). |
| 12 | Row — absolute path to the own feature folder: allow for both modelled cwd values | PASS | Case `allows an absolute path to the target feature folder` with `-ForEach $AbsolutePathCases`, two rows: coordinating-session cwd with an `OtherWorktree` target and composed probe path, and item-worktree cwd with a `SessionRoot` target and bare repo-relative probe path. |
| 13 | Row — sibling item's checkpoint is the only state present: deny with the ambiguity code; never allow | PASS | Case `denies rather than validating against a sibling session checkpoint`. Additionally asserts the sibling folder value is absent from the reason and that no existence probe ran. |
| 14 | Row — required document genuinely absent under the resolved target root: deny with the existing reason, unchanged | PASS | Case `denies with the missing-document reason when the document is absent under the target root`; four separate assertions pin the reason's shape. |
| 15 | Rows — each work mode against its required document set, unchanged semantics | PASS | Case `resolves the required document set for each work mode` with `-ForEach $WorkModeCases`: `full-feature` 2 probes, `full-bug` 1, `minor-audit` 0, legacy `full` 2. Each row allows and asserts its exact probe count. |

### Must not regress

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 16 | The gate still denies when a required document is genuinely absent | PASS | Criterion 14's case, plus the pre-existing missing-document cases in `enforce-prd-feature-before-planner.Tests.ps1` (47 of 47 pass). |
| 17 | Pre-implementation gate not weakened; no `enforce-orchestration-preimplementation-gate*` file modified; its suites pass unmodified | PASS | `git diff --name-only` restricted to that pathspec returns empty. 10 Claude and Codex suites for that gate were re-run as part of a 17-suite batch: 556 total, 556 passed, 0 failed. |
| 18 | Epic merge gate matcher not widened; `enforce-epic-merge-gate.ps1` not modified; its suites pass unmodified | PASS | Same empty diff result and same 556-test green batch, which includes 4 Claude and 3 Codex epic-merge-gate suites. |
| 19 | Epic and standalone topologies unchanged when cwd and target coincide; the existing checkpoint-fallback case amended, not deleted | PASS | The case was renamed to `allows the session-root fallback when the derived target is the session root` and retained; its blanket existence mock was tightened to a path-keyed one. `Test-PrdFeatureSessionRootTarget` returns true for `NoTarget`, `SessionRoot`, and `$null`, so the fallback still applies in the single-worktree topology. |
| 20 | The #518 depth-insensitivity fix survives; the truncation and preserved-gate-behaviour `Context` blocks pass byte-unmodified; four pinned prompt forms unchanged | PASS | The branch diff of `FolderResolution.Tests.ps1` touches only the `BeforeAll` block (comment plus an added dot-source) and the `deterministic selection among two feature folders` `Context`. The `folder resolution by four-segment truncation` `Context` (line 30) and the `preserved gate behavior` `Context` (line 237) are untouched, and the suite passes 25 of 25. |
| 21 | Multi-candidate selection remains distinguishable from plain earliest-occurrence; the later-occurring-preferred case re-specified, not deleted | PASS | Case `prefers the derived target when it occurs later in the prompt` retains the later-occurrence shape and the shorter-slug construction that defeats a length-ordered rule, with the disambiguator changed from the checkpoint to the derived target. |
| 22 | Work-mode marker semantics preserved exactly; `default` arm returns `spec.md` alone; indeterminate branch runs no probe; no fail-closed-to-`full-feature` introduced | PASS | `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` diff to a single trailing blank line against their base-branch originals. The indeterminate branch at hook lines 381-393 returns before `Get-PrdFeatureRequiredFile` is called. |
| 23 | Mock seam names and signatures, dot-source guard, and PreToolUse payload shapes unchanged; `PreToolUseSchema.Contract.Tests.ps1` passes unedited | PASS | All three seams retain their names and parameter names. The guard at hook lines 423-425 is unchanged. The contract suite is absent from the branch diff and passes 15 of 15. |

### F1 consumption

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 24 | Target derivation, path normalisation, and the ambiguity code consumed from F1 through the established `Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force` form; no worktree-discovery logic and no local ambiguity code literal in either file | PASS | Both imports use the prescribed form (hook line 83, helpers line 21). A string scan of both delivered files for `git worktree`, `Get-Location`, `$PWD`, `Resolve-Path`, and any `TARGET_WORKTREE` literal returns zero occurrences. See finding M2 in the code review for a narrowing of F1's input contract that does not violate this criterion's literal terms. |
| 25 | Every F1 symbol resolves against F1's merged source on the integration branch; no guessed identifier; the import fails the gate closed | PASS | Four symbols are referenced: `Get-WorktreeResolutionAmbiguityReasonCode`, `Resolve-WorktreeCallTarget`, `Join-WorktreeResolutionPath`, `ConvertTo-WorktreeResolutionRepoRelativePath`. All four are defined and exported by the two modules, and `git ls-tree` confirms both modules exist at the merge base `d039e89b`. The four `Status` values the hook tests (`NoTarget`, `SessionRoot`, `OtherWorktree`, `Ambiguous`) match the `ValidateSet` on `New-WorktreeResolutionTargetResult`; `SignalValue`, `WorktreeRoot`, and `Detail` are all real members of the returned object. Both imports are unguarded, with a comment stating the fail-closed rationale. |

### Helpers extraction and the file-size cap

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 26 | The sibling exists and holds the four named functions; the three seams remain in the parent; the sibling carries comment-based help and has no `param()`, no `#Requires`, and no entrypoint; the parent dot-sources it at file scope | PASS | The sibling holds `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`, `Find-PrdFeatureFolderFromPrompt`, and `Get-PrdFeatureMissingFile`, plus three new helpers. It opens with a comment-based-help block and contains no `param()` block, no `#Requires`, and no entrypoint. The parent dot-sources it at line 84. See the minor code-review finding on the sibling's description of itself as declaration-only. |
| 27 | `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` moved without any behavioural edit | PASS | `diff` of base-branch lines 120-188 against helpers lines 23-90 reports one difference: a trailing blank line at the extraction boundary. No code, comment, regex, or switch arm changed. |
| 28 | Every production and test file in the change set is at or under 500 lines | PASS | Maximum delivered value is 454 (`TargetResolution.Tests.ps1`). Parent hook 431, sibling 314, mirrors 431 and 314, `Tests.ps1` 445, `FolderResolution.Tests.ps1` 453, both settings files 306. |
| 29 | A cross-file mock smoke case proves a test-scope mock is observed across the dot-source boundary, run before the remainder of the extraction is committed | PASS | Case `observes a test-scope mock across the dot-source boundary` exists and passes; it mocks `Get-PrdFeatureCheckpointFolder` (defined in the parent) and calls `Find-PrdFeatureFolderFromPrompt` (defined in the sibling), asserting zero invocations. The ordering clause is attested by `evidence/regression-testing/cross-file-mock-smoke.2026-09-17T10-55.md` and the commit sequence rather than being independently reproducible after the fact. |
| 30 | The new suite creates no temporary file or directory, does not change the process working directory, derives no absolute path from the environment, current directory, script location, or source control; synthetic roots are bare string literals; cwd is supplied as data | PASS | Grep for `Start-Sleep`, `New-TemporaryFile`, `TestDrive`, `Set-Location`, `Push-Location`, `$env:TEMP`, `Get-Date`, and `New-Guid` across all three suites returns zero matches. Synthetic roots are the bare literals `/synthetic-worktrees/coordinating-session` and `/synthetic-worktrees/item-worktree`; cwd is carried on the injected target's `SessionRoot` member. Recorded caveat: the suite does derive the paths of the files under test from `$PSScriptRoot` (lines 99-110), which the criterion's literal wording excludes but its following sentence plainly does not intend. See the minor code-review finding. |

### Bundled-payload mirroring and delivery registration

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 31 | Both hook files have text-identical counterparts under the bundled payload; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes | PASS | SHA-256 equality verified for both pairs: `09E30DC7...E315` for the parent and `EF5C6486...FB24` for the sibling. `poetry run pytest` over the three delivery modules: 17 passed, 0 failed, exit 0. |
| 32 | The sibling's path appears exactly once in the `paths` array of `core.json`; `test_push_down_claude_pack_manifest_completeness.py` passes | PASS | The `core.json` diff is a single added line in correct alphabetical position; a scan of the file finds one occurrence. Covered by the same green pytest run. |
| 33 | The sibling is added to `CodeCoverage.Path` in both copies of `pester.runsettings.psd1`; `test_poshqc_bundled_parity.py` passes | PASS | `git diff` shows the identical 4-line addition in `scripts/powershell/PoshQC/settings/` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/`. Covered by the same green pytest run. |
| 34 | No Codex mirror is added or expected | PASS | A case-insensitive listing of `.codex/hooks/` for `prd` returns zero entries, and the branch diff contains no `.codex/` path. |

### Toolchain and coverage

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 35 | No Python in the enforcement path; the hook and sibling are PowerShell only; `enforcement-hooks-no-python-invocation.Tests.ps1` passes | PASS | Suite re-run: 27 total, 27 passed, 0 failed. Neither delivered file references a Python interpreter. |
| 36 | Line coverage at or above 85 percent for both delivered files, read per file from the Pester coverage report, neither file excluded from measurement | PASS | Independently re-parsed from `artifacts/pester/powershell-coverage.xml`: sibling 93.55 percent (58 of 62), parent 90.91 percent (90 of 99). Both files are named in `CodeCoverage.Path`, so neither is excluded. |
| 37 | The PowerShell toolchain completes with zero format drift, zero analyzer findings, and zero test failures in a single pass | **FAIL** | Format drift 0 and analyzer findings 0, both independently re-verified. Test failures are 2, read from the `testsuites` element of `artifacts/pester/pester-junit.xml` (tests 4758, failures 2, errors 0). Both failures are pre-existing and environment-coupled, traced in section 6.1 of the policy audit; neither failing suite nor its subject appears in the branch diff. This criterion is correctly left unchecked in `spec.md`. |
| 38 | The new suite is placed at the named path and its header records the placement decision and the determinism statement | PASS | File exists at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. Its comment-based help carries a `Placement decision.` paragraph citing the 500-line cap and the `enforce-parallel-cohort-barrier.Payload.Tests.ps1` precedent, and a `Determinism statement.` paragraph. |

## Summary

| Verdict | Count | Criteria |
|---|---|---|
| PASS | 35 | 1-5, 7-9, 11-28, 29-36, 38 |
| PARTIAL | 2 | 6, 10 |
| FAIL | 1 | 37 |
| UNVERIFIED | 0 | — |
| **Total** | **38** | |

The feature delivers its structural obligations completely: the extraction, the F1 consumption, the
bundled mirroring, the three delivery registrations, the file-size cap, the coverage thresholds, and the
must-not-regress guarantees are all met and independently verified. The behavioural repair is delivered for
absolute path citations and for the three ambiguity states, and the two false-approval conflation sites
that the spec identified — the unconditional checkpoint fallback and the positional tie-break — are both
closed with tests that would fail if they reopened.

The gap is the third conflation site. Criterion 6's guard is armed only when the derived target is another
worktree, which requires the call to carry an absolutely-placed path token. For the repo-relative citation
shape that the originating run actually used, the gate still denies and still emits the marker-is-broken
reason with its remedy to edit `issue.md`. Criterion 10 is graded PARTIAL for the same reason: the row it
names is delivered only in its absolute form, which duplicates criterion 12 rather than adding the
repo-relative proof the issue's decision matrix calls for.

Criterion 37 fails for causes outside this branch. The determination that the two failures are pre-existing
rather than introduced was made independently of the executor's report, from four lines of evidence set out
in the policy audit, and it agrees with the executor's conclusion.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`
- Total AC items: 38
- Checked off (delivered): 37
- Remaining (unchecked): 1
- Items remaining: criterion 37, "The PowerShell toolchain (`run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test`) completes with zero format drift, zero analyzer findings, and zero test failures in a single pass, restarting from the first step after any failure or auto-fix."

## Acceptance Criteria Check-off

No checkbox state was changed by this review.

- Criteria evaluated PASS (35) are already marked `- [x]` in `spec.md`. No check-off action was required.
- Criterion 37, evaluated FAIL, is already marked `- [ ]`. It correctly remains unchecked.
- Criteria 6 and 10, evaluated PARTIAL, are currently marked `- [x]`. This review did not revert them. The
  PARTIAL grade turns on how "the missing/malformed-marker branch is reached only when the feature folder
  does exist under the resolved target root" and "own folder named" should be read for the repo-relative
  citation form, which is a scope question for the maintainer rather than a clerical one. Reverting the
  marks would also erase the executor's evidence trail. The recommended action is recorded in
  `remediation-inputs.2026-09-17T12-29.md`: if finding B1 is accepted as in scope, revert criteria 6 and 10
  to `- [ ]` and re-deliver; if the repo-relative form is ruled out of scope, amend the wording of both
  criteria to say so explicitly and leave them checked.

Related artifacts:

- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/policy-audit.2026-09-17T12-29.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/code-review.2026-09-17T12-29.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/remediation-inputs.2026-09-17T12-29.md`
