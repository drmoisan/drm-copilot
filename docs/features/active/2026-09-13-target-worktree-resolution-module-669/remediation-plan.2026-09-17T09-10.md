# 2026-09-13-target-worktree-resolution-module — Remediation Plan (R1, cycle 1)

- **Issue:** #669
- **Feature folder:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669`
- **Owner:** drmoisan
- **Last Updated:** 2026-09-17T09-10
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** `full-feature` (carried over from `plan.2026-09-13T20-45.md`; unchanged). AC sources remain `spec.md` and `user-story.md`. All 51 criteria are already checked and this plan does not alter, uncheck, or re-check any of them.
- **Remediation cycle:** R1, loop 1.
- **Primary input:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669/remediation-inputs.2026-09-17T08-59.md`, blocking finding R1.
- **Context artifacts:** `policy-audit.2026-09-17T08-59.md`, `code-review.2026-09-17T08-59.md`, `feature-audit.2026-09-17T08-59.md` (non-blocking findings recorded there are out of scope for this cycle).
- **Prior plan (conventions reference):** `plan.2026-09-13T20-45.md`.

## Required References

- Standing instructions: `CLAUDE.md`
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- Module rigor tiers: `.claude/rules/quality-tiers.md`
- PowerShell standards: `.claude/rules/powershell.md`
- Tonality: `.claude/rules/tonality.md`
- Plan acceptance gates: `.claude/rules/plan-acceptance-gates.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope (non-negotiable)

This plan closes **R1 only**: an evidence gap in repo-wide PowerShell line-coverage measurement. R1 is not a
code defect. No `.psm1`, `.psd1`, or `.json` production or test file is created, edited, or deleted by this
plan. The only writes this plan performs are: the two `Copy-Item` operations named in `[P1-T2]`, into this
feature's evidence folder, and Markdown/XML evidence artifacts under
`docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/<kind>/`.
`[P1-T1]`'s self-hosted test invocation additionally overwrites `artifacts/pester/powershell-coverage.xml`,
`artifacts/pester/pester-junit.xml`, and `artifacts/pester/powershell-coverage.koverage.xml` in place, per the
remediation input's own required action ("leave the resulting `artifacts/pester/powershell-coverage.xml` in
place"). `artifacts/` is repository-ignored (`.gitignore:6`), so this expected side effect adds no tracked
file, and the plan writes no path outside this feature's evidence folder other than the three ignored `artifacts/pester/` files named above.

The non-blocking findings recorded in `remediation-inputs.2026-09-17T08-59.md` (absolute-path candidate-set
membership, `-Text` scanning ambiguity, silent read-error suppression, prunable-worktree enumeration, the
`d93e2916` citation note, and the baseline-relative single-pass reading) are explicitly out of scope for this
cycle and are not referenced by any task below.

### Do-Not-Do List (verbatim from the remediation inputs)

- Do not modify `.claude/lib/worktree-resolution/*.psm1`, the bundle mirrors, `core.json`, or either
  runsettings copy.
- Do not add `-ScanFolders`, exclusions, or any narrowing to the R1 test run, and do not add any
  `CodeCoverage.Path` exclusion.
- Do not substitute the MCP runner's figure or the arithmetic estimate for the self-hosted repo-wide
  measurement.
- Do not edit any file under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/src/`.
- Do not change the text of any acceptance criterion, and do not uncheck or re-check criteria.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not write evidence outside `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/<kind>/`.
- Do not attempt to fix the two pre-existing failing tests in this cycle.

## Diff Anchoring

The merge base is `79fd5a95c00cd99238b69a3195788206ae96f4cd`, taken directly from the resolved base/head
line in `remediation-inputs.2026-09-17T08-59.md`. `[P0-T2]` confirms this SHA is an ancestor of `HEAD` rather
than recomputing it. Every later `<MERGE_BASE_SHA>` in this plan referring to that ancestry check is that
literal value. `[P2-T3]` does not use `<MERGE_BASE_SHA>`; it uses `<PRE-CYCLE-HEAD-SHA>`, defined next.

`<PRE-CYCLE-HEAD-SHA>` is `4a34fbe165d3edd2b362182ce9dc561c43ec783b`, the branch tip immediately before this
remediation cycle began (the commit that added this cycle's review artifacts). `[P2-T3]`'s `git diff
--name-only` is anchored to `<PRE-CYCLE-HEAD-SHA>` rather than to the epic merge-base SHA: the merge-base SHA
predates the entire feature branch, so a diff against it always lists this feature's own ten already-committed
files (`.claude/lib/worktree-resolution/*.psm1`, their bundle mirrors, `core.json`, both `pester.runsettings.psd1`
copies, and the three `tests/scripts/claude-lib/worktree-resolution/*.Tests.ps1` files), regardless of what this
plan's tasks change. The orchestrator commits this plan file on top of `<PRE-CYCLE-HEAD-SHA>` before execution
begins, so this plan file itself appears in the `[P2-T3]` diff under the `docs/features/` prefix; the existing
filter in `[P2-T3]` that removes `docs/features/`-prefixed lines removes it along with the rest of this
feature's evidence paths.

`[P2-T3]`'s `git diff` is paired with a `git status --porcelain -uall` span in the same task, per the
wrap-tolerant assertion rules, so untracked evidence paths this plan creates remain visible.

`docs/features/epics/worktree-scoped-state-resolution/epic-status.md` was observed as an untracked path in a
different checkout's `git status` output; it is absent from this workspace root as of this plan's preflight
check (`git status --porcelain -uall` here shows only this plan file, and the path does not exist on disk).
This plan does not create or modify that path whether or not it is present in the executing worktree.
`[P0-T2]` and `[P2-T3]` name it explicitly, conditioned on `if present`, so no task fails if it remains absent
for the entire remediation cycle.

## Evidence Conventions (non-overridable)

All evidence resolves under
`docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/<kind>/`, where `<kind>` is
one of `baseline`, `remediation-baseline`, `regression-testing`, `qa-gates`, `issue-updates`, or `other`, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/qa-gates/`, `artifacts/evidence/`, or `artifacts/coverage/` path is used by this plan. This plan
was not supplied a non-canonical evidence path by its caller, so no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.

`evidence/remediation-baseline/` is used for this cycle's Phase 0 records, distinguishing them from the
original feature's `evidence/baseline/` records, which this plan reads but does not overwrite.

The timestamp component of every artifact filename this plan creates is pinned to `2026-09-17T09-10`, so
acceptance conditions can name exact paths. The `Timestamp:` field **inside** each artifact records the real
clock value at run time. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and
`Output Summary:`.

## Coverage XML Reading Semantics (established by the prior plan; not re-derived here)

`evidence/qa-gates/coverage-xml-structure.2026-09-13T22-00.md`, produced by `[P0-T8]` of
`plan.2026-09-13T20-45.md`, recorded the observed JaCoCo-style structure of
`artifacts/pester/powershell-coverage.xml`: root element `report`; per-directory grouping element
`report/package`, whose `name` attribute carries the full absolute forward-slash directory path; per-file
element `report/package/sourcefile`, whose `name` attribute carries the bare file name; line counters are
`counter` elements with `type="LINE"` and integer `covered`/`missed` attributes, present at `report`,
`package`, and `sourcefile` level. This plan's tasks that read that file use those semantics unmodified:
`package/@name` is matched by a `-like '*worktree-resolution'` suffix test, and `sourcefile/@name` is matched
by bare-name equality against `WorktreeResolution.psm1` and `WorktreeTargetResolution.psm1`.

`evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`, produced by `[P0-T6]` of the same plan,
recorded the observed JUnit structure of `artifacts/pester/pester-junit.xml`: a failing test is a `testcase`
element with `status="Failed"`, a `classname` attribute holding the test file's path, and a `name` attribute
holding the test's full name. This plan's tasks that read the JUnit file use that structure unmodified.

## Run-Exit Termination Handling

`pester.runsettings.psd1` sets `Run.Exit = $true`. The repo-wide scan set (`scripts`, `tests/powershell`,
`tests/scripts`) includes the two files carrying the two pre-existing failing tests recorded in
`evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`
(`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`), so the repo-wide self-hosted run in
`[P1-T1]` is expected to terminate its own host process once it completes. That termination is expected and
is not, by itself, a failure of this plan. Because a terminated session may not print the final replayed
summary block, `[P1-T1]`'s acceptance condition is anchored to file `LastWriteTime` values rather than to
captured console output, per the observed-success-output requirement in the atomic-plan-contract skill.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy reading and baseline state capture

- [ ] [P0-T1] Read the required policy files in order and record the read
  - Read, in this order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/powershell.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/remediation-baseline/phase0-instructions-read.r1.2026-09-17T09-10.md` exists and contains a `Timestamp:` field, a `Policy Order:` field, and one bullet per file above naming its repository-relative path.

- [ ] [P0-T2] Confirm the remediation base SHA is an ancestor of `HEAD` and record the pre-run worktree state
  - Run `git merge-base --is-ancestor 79fd5a95c00cd99238b69a3195788206ae96f4cd HEAD` and `git status --porcelain -uall`. `-uall` is required so the untracked evidence paths this plan creates are visible rather than collapsed to a single directory entry.
  - Acceptance: `evidence/remediation-baseline/baseline-merge-base.r1.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded `EXIT_CODE:` for the ancestry check is `0`; and the complete `git status --porcelain -uall` output is recorded verbatim, or the literal `none` when it is empty, with the pre-existing untracked path `docs/features/epics/worktree-scoped-state-resolution/epic-status.md` named explicitly if present. The `<MERGE_BASE_SHA>` used by this ancestry check is `79fd5a95c00cd99238b69a3195788206ae96f4cd`; per the Diff Anchoring section above, `[P2-T3]` uses `<PRE-CYCLE-HEAD-SHA>` (`4a34fbe165d3edd2b362182ce9dc561c43ec783b`) instead, not this SHA.

- [ ] [P0-T3] Record the pre-run last-write timestamps of the two canonical PoshQC run-output files
  - Run `(Get-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml').LastWriteTime` and `(Get-Item -LiteralPath 'artifacts/pester/pester-junit.xml').LastWriteTime`.
  - Acceptance: `evidence/remediation-baseline/baseline-artifact-timestamps.r1.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records both `LastWriteTime` values verbatim. `[P1-T1]` compares its own post-run values against these two.

### Phase 1 — Repo-wide run, evidence capture, and extraction

- [ ] [P1-T1] Run the repo-wide self-hosted PoshQC test invocation with no scan-folder restriction
  - Run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path`. Supplying no `-ScanFolders` argument makes `Invoke-PoshQCTest` resolve `$effectiveScanFolders` from `Get-PoshQCScanConfigFolder` (`PoshQC.Testing.psm1:305-312`), which reads `config/poshqc-scan.json` and returns its three-entry `scanFolders` array (`scripts`, `tests/powershell`, `tests/scripts`; `PoshQC.ScanConfig.psm1:37,52-61`, `config/poshqc-scan.json:4`) — the same repo-wide scan set the MCP tool resolves when `scan_folders` is omitted, and the set that reaches `tests/scripts/claude-lib/worktree-resolution/` as well as the two files carrying the pre-existing failures. `Resolve-PoshQCScanFolder` then resolves that set to absolute paths and overwrites `$config.Run.Path` with it (`PoshQC.Testing.psm1:313-318`). Do not add `-ScanFolders` or any other narrowing argument.
  - Per the Run-Exit Termination Handling section above, the host process is expected to terminate once this run completes, because two pre-existing failures are in scope. That termination is expected and is not a failure of this task.
  - Acceptance: `evidence/qa-gates/repo-wide-poshqc-run.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. `EXIT_CODE:` records the numeric value observed, or the literal `SESSION-TERMINATED` when the host process ended before an exit code was returned to the calling tool. `Output Summary:` records the verbatim `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}` line when it printed before termination, or an explicit statement that it did not print — this artifact does not assert on the replayed summary block (`PoshQC.Testing.psm1:454-456`), which is not printed by this invocation pattern. The artifact additionally records that `(Get-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml').LastWriteTime` and `(Get-Item -LiteralPath 'artifacts/pester/pester-junit.xml').LastWriteTime` — read in a fresh tool session if this run terminated the prior one — are each later than the corresponding value recorded by `[P0-T3]`. A `SESSION-TERMINATED` or nonzero `EXIT_CODE:` value is not itself a failure of this task; a `LastWriteTime` that is not later than the `[P0-T3]` value is.

- [ ] [P1-T2] Copy the two produced run-output files into feature evidence before any later run overwrites them
  - Run, immediately after `[P1-T1]` and before any other PoshQC test invocation (MCP or self-hosted) executes: `Copy-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml' -Force` and `Copy-Item -LiteralPath 'artifacts/pester/pester-junit.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml' -Force`.
  - Acceptance: both destination files exist; `evidence/other/repo-wide-copy-verification.r1.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; and, for each of the two source/destination pairs, `(Get-FileHash -Algorithm SHA256 -LiteralPath <destination>).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath <source>).Hash` evaluates to `True`, with both hash values recorded verbatim.

- [ ] [P1-T3] Extract the JUnit run counts and failing-test set from the copied file
  - Read `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml` as XML. Record the root `testsuites` element's `tests`, `failures`, `errors`, and `disabled` attributes, and, for every `testcase` element carrying `status="Failed"`, its `classname` and `name` attributes, using the element and attribute names recorded at `evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`.
  - Acceptance: `evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md` exists (created by this task) with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; records the four `testsuites` attribute values; records one line per failing test in the form `<classname> | <name>`, or the literal `none`; and records, for each failing test found, whether its file name (the last path segment of `classname`) matches `enforce-pr-author-skill.Tests.ps1` or `codex-pretooluse-integration.Tests.ps1` — the two baseline failure names carried forward from `remediation-inputs.2026-09-17T08-59.md` — or is a name outside that set.

- [ ] [P1-T4] Extract the report-level LINE coverage counter and the two `worktree-resolution` per-file LINE rows from the copied coverage XML
  - Read `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml` as XML. Record the report-level `counter` element with `type="LINE"` (its `covered` and `missed` attributes), and compute the percentage as `100 * covered / (covered + missed)` rounded to two decimals. Then, per the Coverage XML Reading Semantics section above, locate the `package` element whose `name` ends with `worktree-resolution`, and within it the two `sourcefile` elements named `WorktreeResolution.psm1` and `WorktreeTargetResolution.psm1`, recording each one's `counter[@type='LINE']` `covered` and `missed` attributes and the computed percentage.
  - Acceptance: `evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md` (the same file `[P1-T3]` created) additionally records: the report-level covered, missed, and percentage values; and, for each of `WorktreeResolution.psm1` and `WorktreeTargetResolution.psm1`, its covered, missed, and percentage values, each read from inside the `package` element whose `name` ends with `worktree-resolution`.

### Phase 2 — Threshold verification and final tree check

- [ ] [P2-T1] Write the repo-wide coverage delta and threshold-verification artifact
  - Run `Get-Content -LiteralPath 'evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md'` and `Get-Content -LiteralPath 'evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md'`. Read from the first the prior repo-wide baseline LINE coverage (covered=8914, missed=422, percentage=95.48, measured without the two new modules in the denominator), and from the second the repo-wide LINE coverage and the two per-module LINE percentages recorded by `[P1-T4]`.
  - Acceptance: `evidence/qa-gates/r1-coverage-delta.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; records the prior baseline percentage, the new repo-wide percentage, and the two per-module percentages as numbers; records the signed delta between the prior baseline percentage and the new repo-wide percentage; states `PASS` when the new repo-wide percentage is at or above `85.00` and `FAIL` otherwise; and states `PASS` when each of the two per-module percentages is at or above `85.00` and `FAIL` otherwise. Every stated `PASS` or `FAIL` uses the literal numeric value recorded by `[P1-T4]`, not an estimate. A `FAIL` result is reported as found, per the remediation-inputs' closure instruction, rather than remedied by narrowing or re-running the scan.

- [ ] [P2-T2] Verify the failing-test set is a subset of the baseline failure set
  - Run `Get-Content -LiteralPath 'evidence/qa-gates/repo-wide-powershell-coverage.2026-09-17T09-10.md'` and read from it the failing-test lines recorded by `[P1-T3]`.
  - Acceptance: `evidence/qa-gates/r1-failure-set-verification.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; states `PASS` when every failing test recorded by `[P1-T3]` matches one of the two baseline names (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`) and no other failing test is present, and `FAIL` otherwise, naming any failing test outside that set.

- [ ] [P2-T3] Confirm no file outside this feature's evidence folder and the remediation plan itself changed
  - Run `git diff --name-only 4a34fbe165d3edd2b362182ce9dc561c43ec783b` and `git status --porcelain -uall`. This diff is anchored to `<PRE-CYCLE-HEAD-SHA>` (`4a34fbe165d3edd2b362182ce9dc561c43ec783b`), not to the epic merge-base SHA used by `[P0-T2]`; see the Diff Anchoring section above for why. `git diff --name-only` prints one bare repository-relative path per line; `git status --porcelain -uall` prints a two-character status code, one space, then the same form of path (a rename prints `old -> new`, not expected here since no path is renamed). From each listing, remove every line whose path portion (the whole line for the diff listing; the text after the two-character status code and the following space for the porcelain listing) begins with `docs/features/`.
  - Acceptance: `evidence/qa-gates/r1-tree-confirmation.2026-09-17T09-10.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; records both raw listings verbatim; records the filtered remainder of each listing as the literal `none`; and separately lists every `docs/features/`-prefixed path present in the raw listings, confirming each one is either `docs/features/active/2026-09-13-target-worktree-resolution-module-669/remediation-plan.2026-09-17T09-10.md`, a path under `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/`, or the untracked path `docs/features/epics/worktree-scoped-state-resolution/epic-status.md` if present (this path is absent as of this plan's preflight check and no task depends on its presence).
