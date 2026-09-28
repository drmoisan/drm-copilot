# Feature Audit — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T15-01
- Review cycle: 2 (re-audit after the cycle-1 remediation)
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`

## Scope and Baseline

- Base branch: `epic/worktree-scoped-state-resolution-integration`, resolved to the remote-tracking ref `origin/epic/worktree-scoped-state-resolution-integration`
- Merge base: `d039e89b2b2569151e9170e1bbefb9f974419f87`, confirmed an ancestor of the head
- Head: `d6e5adb959b8e74d8acbf3278501bf75b07fac8e` on `feature/2026-09-13-prd-feature-gate-target-resolution-672`
- Commits in range: 16, of which the last five are the remediation phases 0 through 4
- Diff scope: 89 files. Code and settings: 2 repository hook files, 2 bundled mirror files, 1 pack manifest, 2 `pester.runsettings.psd1` copies, 3 Pester suites. Documents: 80 markdown files, comprising `spec.md`, the plan, the cycle-1 review artifacts, the remediation plan, and 66 evidence artifacts.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-09-17 18:48:57 UTC against head `d6e5adb9`, which matches the current head. The artifacts are current and were not regenerated.
- This is a feature-versus-base audit over the full branch diff. No caller instruction narrowed the scope, and none was accepted.

Work mode and acceptance-criteria source. `issue.md` line 12 carries `- Work Mode: full-bug`. Under the
work-mode contract that makes `spec.md` the sole acceptance-criteria source; `user-story.md` is neither
required nor present, and `issue.md` checkbox sections are not acceptance criteria for this mode.

Baseline for the remediation delta. Coverage and test figures are compared against two baselines: the
pre-branch baseline in `evidence/baseline/` at 2026-09-17T10-34, and the pre-remediation baseline in
`evidence/remediation-baseline/` at 2026-09-17T13-56. Both are cited where a comparison is made.

## Acceptance Criteria Inventory

- Source file: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, section `## Acceptance Criteria`, lines 600 to 669
- Total criteria: 38, all in markdown checkbox form
- Grouped as the spec groups them: the three-way distinction (3), conflation sites addressed (3), false-approval guards (3), mandatory test-matrix rows (6), must not regress (8), F1 consumption (2), helpers extraction and the file-size cap (5), bundled mirroring and delivery registration (4), toolchain and coverage (4)
- State on arrival at this review: 37 checked, 1 unchecked (criterion 37)
- Criterion text integrity: the full `git diff` of `spec.md` from the merge base to the head changes checkbox state only. No criterion text was altered, added, or removed anywhere on this branch, and no criterion was re-worded to match what was delivered.

## Acceptance Criteria Evaluation

Criterion numbers are the source order of the checkbox items in `spec.md` lines 608 to 669.

| # | Line | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|---|
| 1 | 608 | State 1 — target resolved, document present, allow | PASS | Suite row `allows when the target root holds the required document`, with the existence mock answering only for the path composed under the target root. Confirmed end to end by execution row E3, which allowed against the real filesystem from a coordinating session root. |
| 2 | 609 | State 2 — document genuinely absent, deny with the existing reason | PASS | Suite row `denies with the missing-document reason when the document is absent under the target root` asserts the `PRD_FEATURE_BLOCKED:` prefix, the resolved folder leading the reason, the missing list, the work mode, and the existing remedy. |
| 3 | 610 | State 3 — deny with the ambiguity reason code, greppable as a single literal, no silent checkpoint fallback | PASS | Suite row `emits an ambiguity code distinct from the missing-document and marker reasons` asserts a regex match count of exactly 1 for the code and the absence of both competing reasons. The code is read from the resolution module, not restated. |
| 4 | 614 | Unconditional post-prompt checkpoint fallback removed | PASS | `Test-PrdFeatureSessionRootTarget` gates the checkpoint, and suite row `denies rather than validating against a sibling session checkpoint` asserts the deny does not name the sibling folder and that no existence probe runs. |
| 5 | 615 | Positional tie-break removed | PASS | Suite row `denies rather than selecting the earliest candidate on an unresolved tie` asserts the ambiguity code and the `cites 2 feature folders` clause. The two former earliest-candidate rows in the `FolderResolution` suite were re-specified to assert denial. |
| 6 | 616 | Marker branch reached only when the folder exists under the resolved root | PASS | Closed this cycle on executed evidence. Execution row E1 (repo-relative citation, folder in no worktree) now denies with `TARGET_WORKTREE_AMBIGUOUS` where the pre-change hook denied with the marker reason. Execution row E5 (absolute citation, folder absent under the target) denies with the folder-absent ambiguity reason. Both assert `Should -Not -BeLike '*work mode could not be determined*'` in the suite as well. |
| 7 | 620 | Ambiguity deny returns before any document probe | PASS | Suite row `runs no existence probe on the ambiguity branch` asserts `Should -Invoke Get-PrdFeatureFileExistence -Times 0 -Exactly`. The branch sits above the candidate scan in the decision function. |
| 8 | 621 | Allow rows assert exact positive probe counts per work mode | PASS | `probes once on a full-bug allow row` (1), `probes twice on a full-feature allow row` (2), and the four work-mode rows with `ExpectedProbes` of 2, 1, 0, and 2. |
| 9 | 622 | Same resolved root across rows; no blanket always-true existence mock | PASS | Every existence mock is keyed on the fully composed path. The one pre-existing blanket `{ $true }` mock in `enforce-prd-feature-before-planner.Tests.ps1` was replaced with a two-path keyed mock in this change set. |
| 10 | 626 | Row — own folder named, cwd modelled as the session root, allow | PASS | Suite row `allows a repo-relative citation placed in the item worktree` models the session root as a coordinating worktree, the target as the item worktree, and asserts `allow` with exactly one probe. The composition path this row depends on was confirmed end to end by execution rows E3 and E6. Qualification recorded below the table. |
| 11 | 627 | Row — own folder named, cwd modelled as the item worktree, allow, unchanged | PASS | Suite row `allows when the modelled cwd is the item worktree`, retained as a regression guard and passing. |
| 12 | 628 | Row — absolute path to the own folder, allow, for both modelled cwd values | PASS | The `-ForEach $AbsolutePathCases` row runs twice, once per modelled cwd, with the probe folder composed differently in each. Confirmed end to end by execution rows E3 (coordinating cwd) and E6 (item cwd), both `allow`. |
| 13 | 629 | Row — sibling checkpoint is the only state present, deny with the ambiguity code, never allow | PASS | Suite row `denies rather than validating against a sibling session checkpoint`, which additionally asserts the sibling folder does not appear in the reason. |
| 14 | 630 | Row — document genuinely absent under the resolved root, deny with the existing reason unchanged | PASS | Same row as criterion 2; the reason text differs from the base-branch form only in the resolved-folder value. |
| 15 | 631 | Rows — each work mode against its required document set | PASS | Four `-ForEach $WorkModeCases` rows covering `full-feature`, `full-bug`, `minor-audit`, and legacy `full`, each asserting `allow` and its exact probe count. |
| 16 | 635 | The gate still denies when a required document is genuinely absent | PASS | Criterion 2's row, plus the untouched `block message` and `preserved gate behavior` Context blocks in the `FolderResolution` suite. |
| 17 | 636 | Pre-implementation gate not weakened; no matching file modified; suites pass unmodified | PASS | No path matching `enforce-orchestration-preimplementation-gate*` appears in the 89-file diff. The 17-suite batch reports 556 nodes with 0 failures in the repository-wide run. |
| 18 | 637 | Epic merge gate matcher not widened; file not modified; suites pass unmodified | PASS | No path matching `enforce-epic-merge-gate*` appears in the diff. Its four Claude suites and three Codex suites are inside the 556-node, zero-failure batch. |
| 19 | 638 | Epic and standalone topologies unchanged when cwd and target coincide; checkpoint-fallback case amended, not deleted | PASS | The diff shows the existing case renamed to `allows the session-root fallback when the derived target is the session root` with a keyed existence mock replacing a blanket one. Execution row E6 confirms the coinciding-root allow against the real filesystem. |
| 20 | 639 | The #518 fix survives; the truncation and preserved-gate-behaviour Context blocks pass byte-unmodified | PASS | The `FolderResolution` diff touches only `BeforeAll` and the `deterministic selection among two feature folders` Context. The `folder resolution by four-segment truncation` block at line 31 and the `preserved gate behavior` block at line 238 are outside every diff hunk. The depth-collapsing expression is carried unmodified in `ConvertTo-PrdFeatureFolderToken`. |
| 21 | 640 | Multi-candidate rule remains distinguishable from earliest-occurrence; the later-occurring case re-specified, not deleted | PASS | The case is retained and renamed `prefers the derived target when it occurs later in the prompt`, still asserting the later-occurring, shorter-slug candidate wins. |
| 22 | 641 | Work-mode marker semantics preserved exactly | PASS | `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` are byte-identical to their base-branch forms, confirmed by diffing the extracted base file against the delivered sibling. The `default` arm returns `spec.md` alone, and the indeterminate-marker branch still runs no required-file probe. |
| 23 | 642 | Mock seams, dot-source guard, and payload shapes unchanged; the contract suite passes unedited | PASS | The three seam functions remain in the parent with unchanged signatures. `PreToolUseSchema.Contract.Tests.ps1` reports 15 nodes with 0 failures and appears in no diff hunk. |
| 24 | 646 | F1 consumption through the established import form; no local re-implementation | PASS | Both imports use `Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force`. String scans return 0 occurrences of `git worktree`, `Get-Location`, `$PWD`, `Resolve-Path`, and any ambiguity-code literal across both production files, against a control of 2 occurrences of the literal in the resolution module. The cycle-1 R3 concern about a local eligibility decision is resolved: the predicate that held it was deleted. |
| 25 | 647 | Every F1 symbol resolves against the merged source; no guessed identifier; import fails closed | PASS | The strongest available evidence is run-time: six executions of the hook as a child process completed and emitted well-formed decisions, which requires every imported symbol to have resolved. Both module files are present at the merge base. |
| 26 | 651 | The sibling exists and holds the four named functions; the three seams remain in the parent; help block present; no parameter block, requires directive, or entrypoint | PASS | The sibling declares `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`, `Find-PrdFeatureFolderFromPrompt`, and `Get-PrdFeatureMissingFile`, plus three further pure helpers. The parent retains the three seams. Scans for a file-scope `param(`, `#Requires`, and an entrypoint return 0. The parent dot-sources the sibling at file scope, line 109. |
| 27 | 652 | The two moved functions carry no behavioural edit | PASS | `diff -u` of the base hook's lines 120-187 against the sibling's lines 29-96 reports zero differences. |
| 28 | 653 | Every production and test file at or under the 500-line cap | PASS | Measured on the delivered files: 456, 320, 456, 320, 446, 454, and 499. The 499-line figure for the new suite was confirmed two ways, by line count and by newline count. |
| 29 | 654 | A cross-file mock smoke case proves mock visibility across the dot-source boundary, run before the remainder of the extraction was committed | PASS | The case `observes a test-scope mock across the dot-source boundary` exists and passes. The ordering claim rests on `evidence/regression-testing/cross-file-mock-smoke.2026-09-17T10-55.md` and the commit sequence rather than on after-the-fact reproduction; accepted on the evidence as exception E2. |
| 30 | 655 | The new suite creates no temporary file, changes no working directory, and derives no absolute path from the environment, the current directory, the script file location, or a source-control query | PARTIAL | Three of the four clauses hold in full: no temporary file or directory is created, the working directory is never changed, and no path is derived from the environment or from a source-control query. The fourth clause does not: lines 99, 100, 109, and 110 each derive an absolute path from `$PSScriptRoot`, which is the script file location. The criterion's stated intent — that no modelled root, cwd, or feature-folder value come from ambient state — is satisfied in full, and the four derivations are necessary and correct. The literal clause is nonetheless contradicted, so the criterion cannot stand as delivered. Reverted to unchecked by this review; the wording decision is routed to the spec owner. |
| 31 | 659 | Both hook files have text-identical bundled counterparts; the push-down resource-contract test passes | PASS | SHA-256 equality holds for both pairs. `test_push_down_claude_resource_contracts.py` passes within the 17-test delivery run. |
| 32 | 660 | The sibling's path appears exactly once in the `paths` array of `core.json`; the manifest-completeness test passes | PASS | Occurrence count is 1, in correct alphabetical position. `test_push_down_claude_pack_manifest_completeness.py` passes. |
| 33 | 661 | The sibling is added to `CodeCoverage.Path` in both `pester.runsettings.psd1` copies; the parity test passes | PASS | Occurrence count is 1 in each copy, added as an identical 4-line block with a rationale comment. `test_poshqc_bundled_parity.py` passes. |
| 34 | 662 | No Codex mirror is added or expected | PASS | `.codex/hooks/enforce-prd-feature-before-planner.ps1` does not exist, and no `.codex/` path appears in the diff. |
| 35 | 666 | No Python in the enforcement path; the no-Python guard suite passes | PASS | Both delivered files are PowerShell. `enforcement-hooks-no-python-invocation.Tests.ps1` contributes 28 nodes to the repository-wide run and none is in the 2-member failure set. |
| 36 | 667 | Line coverage at or above 85 percent for both production files, read per file, neither excluded | PASS | `.claude/hooks/enforce-prd-feature-before-planner.ps1` at 88 of 97, 90.72 percent. `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` at 60 of 62, 96.77 percent. Each `sourcefile` node matched exactly once, keyed on the parent package directory, so no bundled mirror contaminates either figure. Neither file is excluded; `CodeCoverage.Path` registers both. |
| 37 | 668 | The PowerShell toolchain completes with zero format drift, zero analyzer findings, and zero test failures in a single pass | FAIL | Two of the three conditions hold and were independently re-measured: zero formatter drift across all 7 changed files and zero analyzer findings across all 7. The third does not: the repository-wide JUnit report carries `failures="2"`. Both failures are the pre-existing environment-coupled pair, `errors` is 0, and neither failing suite nor its subject appears in the change set. The criterion's literal condition is unmet, so it remains FAIL and unchecked, carried as accepted exception E1 rather than as a defect of this branch. |
| 38 | 669 | The new suite is placed at the specified path and its header records the placement decision and the determinism statement | PASS | The file is at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. Its header carries both a placement rationale, citing the sibling suites' headroom against the cap and the `enforce-parallel-cohort-barrier.Payload.Tests.ps1` precedent, and a determinism statement. The determinism statement's own over-broad clause is recorded separately as code-review finding N2; the criterion requires the statement to be present, and it is. |

Qualification on criterion 10, recorded so it is not mistaken for a broader claim. The criterion is written
as a test-matrix row with a modelled cwd, and the delivered row satisfies it: the repo-relative citation is
handed to the derivation unconditionally, and when the derivation places it in one worktree the gate
composes the probe under that root and allows. What the criterion does not assert, and what is not true in
this host's checkout, is that a repo-relative citation reaches that allow in practice. A repo-relative
token resolves only when the cited folder exists under exactly one worktree; scanning all 52 folders under
`docs/features/active/` against a coordinating session root, zero place uniquely, and this feature's own
folder matches 9 worktrees. The first row of the `issue.md` decision matrix therefore now yields a correct
and actionable deny rather than an allow. That is within the contract — `issue.md` Expected Behavior
requires a distinct ambiguity deny when the target cannot be identified, and `spec.md` scope states the
same — and it is a material improvement over the cycle-1 state, in which the same shape denied with a
remedy that would have edited another repository's `issue.md`. It is recorded as code-review finding N4.

## Summary

- Total criteria: 38
- PASS: 36
- PARTIAL: 1 (criterion 30)
- FAIL: 1 (criterion 37, carried as accepted exception E1)
- UNVERIFIED: 0

Every criterion was evaluated against measured evidence. No criterion is left unverified for want of a
tool: the PowerShell toolchain, the coverage and JUnit reports, the delivery tests, the evidence-location
validator, and the delivered hook itself were all exercised during this audit.

Cycle-1 finding closure: the one blocking finding is closed on executed evidence, and three of the four
non-blocking findings are closed. The fourth, criterion 30's wording, was deferred by the executor with
reasoning this audit adopts, and it resolves to a PARTIAL verdict plus a routed decision rather than to
remediation work inside this branch.

Delta against cycle 1: criteria 6 and 10 moved from PARTIAL to PASS. Criterion 30 moved from PASS to
PARTIAL on a closer reading of its literal terms. Criterion 37 is unchanged at FAIL with the same accepted
exception. The net count moved from 35 PASS, 2 PARTIAL, 1 FAIL to 36 PASS, 1 PARTIAL, 1 FAIL.

Blocking findings: **0**. Recommendation: **GO** for pull request.

## Acceptance Criteria Check-off

Source file: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`.

Action taken by this review:

- Criteria 1 through 29, 31 through 36, and 38 were already `- [x]` and are confirmed PASS. No change.
- Criterion 30 was `- [x]` and is evaluated PARTIAL. It is reverted to `- [ ]`. Only the checkbox state was
  changed; the criterion text is untouched, per the preserve-text rule in
  `.claude/skills/acceptance-criteria-tracking/SKILL.md`. The gap is documented in this artifact, in
  `policy-audit.2026-09-17T15-01.md` section 8.1, and in `remediation-inputs.2026-09-17T15-01.md`.
- Criterion 37 was already `- [ ]` and is evaluated FAIL. It stays unchecked.

Criteria 6 and 10 were reverted to `- [ ]` by the cycle-1 remediation as that review requested, and were
re-checked by the executor after the new regression rows passed. This audit confirms both independently and
leaves them checked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`
- Total AC items: 38
- Checked off (delivered): 36
- Remaining (unchecked): 2
- Items remaining: criterion 30, the new suite's determinism claim, whose literal clause about the script
  file location is contradicted by four necessary `$PSScriptRoot` derivations and which awaits a spec-owner
  wording decision; and criterion 37, the single-pass zero-failure toolchain requirement, which is unmet
  only because of two pre-existing environment-coupled failures in suites outside this change set.
