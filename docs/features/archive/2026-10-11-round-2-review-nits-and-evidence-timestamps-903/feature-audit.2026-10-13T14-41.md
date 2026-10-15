# Feature Audit: Round-2 review nits and evidence timestamps (#903)

---

**Audit Date:** 2026-10-13
**Feature Folder:** `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`
**Base Branch:** `origin/main`
**Head Branch:** `bug/round-2-review-nits-and-evidence-timestamps-903`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

**Total blocking findings: 1** (FA-1: PowerShell changed-line coverage regression on `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356,370`; see policy-audit PA-1 and code-review CR-A).

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `fd81a43b4`)
- **Head branch/commit:** `bug/round-2-review-nits-and-evidence-timestamps-903` (commit `fcd493fa1`)
- **Merge base:** `fd81a43b4` (equals the `origin/main` tip)
- **Evidence sources:**
  - Primary: `git -C <item worktree> diff origin/main...HEAD` (189 files), read directly by the reviewer
  - Secondary baseline diff: per-file `git diff origin/main...HEAD -- <path>` for every production file
  - Feature evidence: `evidence/baseline/**`, `evidence/regression-testing/**`, `evidence/qa-gates/**`, `evidence/other/**`
  - Additional evidence: CI coverage and junit XML under the gitignored `artifacts/scratch-903/` (runs 38386628228, 38404520141, 38410234897)
- **Feature folder used:** `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only
- **Work mode resolution note:** `issue.md` line 3 states `- Work Mode: minor-audit`. `spec.md` and `user-story.md` are absent by design.
- **Scope note:** `artifacts/pr_context.summary.txt` was not regenerated; the reviewer read the branch diff directly against the resolved base. Final CI run 38410234897 is a `workflow_dispatch` run on `17a6497e4`; `git diff --name-only 17a6497e4 HEAD` lists only nine feature-folder paths. No PR exists (`gh pr list --head ...` returned `[]`).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md` — only source (`## Acceptance Criteria`, AC-1 to AC-50, checkbox format)

### Acceptance criteria

AC-1 to AC-50 as written in `issue.md` lines 33-111 (P7: AC-1 to AC-7; P8: AC-8 to AC-42; cross-cutting: AC-43 to AC-50). The criterion text is not reproduced here to avoid divergence from the source; the evaluation table uses the AC number and short label.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | UTC `Timestamp` sentence in six evidence-skill copies; no `local time` | PASS | Skill diff; reviewer grep for `local time` in three root copies returned no match; pytest pass | `git diff origin/main...HEAD -- .claude/skills/`; `poetry run pytest tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` | Reviewer rerun passed |
| AC-2 | `### Evidence Filename Timestamp` subsection | PASS | Subsection present with write-time, `<name>.<timestamp>.md`, lexicographic selection, exclusions, no-rename text | same | |
| AC-3 | Evidence-skill root copies byte-identical to mirrors | PASS | Reviewer `cmp` over the three pairs: SAME | `cmp <root> <mirror>` | |
| AC-4 | `## Evidence Filename Timestamps in Plans` in six atomic-plan-contract copies | PASS | Section present; `cmp` SAME for three pairs | `cmp`; pytest | |
| AC-5 | `TIMESTAMP_SOURCE_BLOCK` updated | PASS | `test_completion_gate_documentation_contracts.py` diff (9 lines); reviewer pytest pass | pytest | |
| AC-6 | New module with five tests; fail-before exit 1 and pass-after exit 0 | PASS | `evidence/regression-testing/p7-contracts-fail-before.2026-10-13T11-17.md`, `p7-contracts-pass-after.2026-10-13T11-20.md` | pytest | |
| AC-7 | No evidence rename/delete; P7 edits avoid reserved paths | PASS | `git diff --name-status origin/main...HEAD` has no `R` or `D` entry | `git diff --name-status` | Hook edits are P8, not P7 |
| AC-8 | #793 L20 parametrized over `VALID_MERGE_STATUS` | PASS | Test diff; `evidence/regression-testing/p8-793-after.2026-10-13T11-22.md` | pytest | |
| AC-9 | #793 L21 `NON_STRING_ROWS` | PASS | same | pytest | |
| AC-10 | #793 L22 disposition recorded | PASS | `issue.md` Note Dispositions row `#793 L22` | Read | |
| AC-11 | #797 CR-1 ASCII guard in Python and PowerShell; rows added | PASS | Diff; rows at `test_blast_radius_token_shapes.py:170-171` and `BlastRadiusTokenShape.Tests.ps1:296-297`; mirror `cmp` SAME; reviewer coverage 100%/100% | pytest `--cov-branch`; `cmp` | |
| AC-12 | #797 CR-4 assert messages | PASS | Test diff; reviewer pytest pass | pytest | |
| AC-13 | #845 CR-1 split; node-id comparison | PASS | `evidence/regression-testing/p8-845-collect-compare.2026-10-13T11-26.md`; both files under 500 lines | `wc -l` | |
| AC-14 | #845 CR-2 residual rows | PASS | same; reviewer pytest pass | pytest | |
| AC-15 | #845 CR-3 `==` narrowing row | PASS | same | pytest | |
| AC-16 | #846 CR-1 QT009 parametrized | PASS | `evidence/regression-testing/p8-846-cr1-after.2026-10-13T11-27.md`; reviewer pytest pass | pytest | |
| AC-17 | #846 CR-2 `Get-BraceBlockText` | PASS | `PublishMcpNpmWorkflow.Tests.ps1` `[+]` in CI run 38410234897 | CI junit | |
| AC-18 | #846 CR-3 consolidated `exit 1` | PASS | same | CI junit | |
| AC-19 | #846 CR-4 inline `if:` | PASS | same | CI junit | |
| AC-20 | #846 CR-5 TS type alias and `// Assert` | PASS | TS diff; CI extension tests success | CI | |
| AC-21 | #846 CR-6 neutral `WORKSPACE_ROOT` | PASS | TS diff | CI | |
| AC-22 | #846 CR-7 correction note | PASS | `closure-dispositions-correction.2026-10-13T11-29.md` added; original has no diff | `git diff --stat origin/main...HEAD -- <original>` (empty) | |
| AC-23 | #565 CR-8 keyed-only lookup; M8f rows | PASS | Modes diff (4 copies); M8fe/M8fp at `TargetFolder.Tests.ps1:279,286` (Claude) and `:276,283` (Codex); `ps-rows` pass | CI junit | |
| AC-24 | #565 CR-9 disposition; gate main files unedited | PASS | Note Dispositions row; neither gate main file in the diff | `git diff --name-only` | |
| AC-25 | #565 CR-2 trim set in four copies | PASS | Diff; Claude/Codex copies byte-identical; S06/S06c/H01 pass | `cmp`; CI junit | |
| AC-26 | #565 CR-6 disposition and CI catch-line result | PASS | Note Dispositions row cites run 38410234897; uncovered line routed to Operator Follow-up 7 | Read | |
| AC-27 | #736 O-4 entry point | PASS | Diff; three O-4 rows pass | CI junit | |
| AC-28 | #732 CR-2 identifier-boundary regex; U11b/U11c/U11d | PASS | Diff; rows pass on both surfaces | CI junit | |
| AC-29 | #732 CR-3 shared outcome function | PASS | `Resolve-OrchestrationEpicTargetOutcome`; U25 (five outcomes, exact session-root string); full gate suite set passes in CI; `evidence/qa-gates/cr3-decision.2026-10-13T13-43.md` | CI junit | Coverage consequence tracked as FA-1, not as an AC-29 gap |
| AC-30 | #732 CR-4 no line over 120 characters in targets copies | PASS | Parity row `keeps every line ... at or under 120 characters` passes | CI junit | |
| AC-31 | #732 CR-5 rename; analyzer clean | PASS | Reviewer grep: no `Get-OrchestrationTargetResult` outside `docs/` (only the gitignored scratch copy); CI analyzer no findings | grep; CI | |
| AC-32 | #732 CR-6 `git-command-word-missing` | PASS | Diff; U24 passes on both surfaces | CI junit | |
| AC-33 | #732 CR-9 one-paragraph multi-message form | PASS | `.agents/skills/epic-plan/SKILL.md` diff; mirror SAME; `codex-epic-runtime-contracts.Tests.ps1:136` | `cmp`; CI | |
| AC-34 | #737 F-1, or withhold under the stated condition | PASS | Withhold branch: Discovery run 38404520141 flagged suites matching the issue's own reserved pattern `hook-dependency-failure*` (concurrent epic) and a #901-inferred suite; four F-1/F-2 files have no net diff from `origin/main` (reviewer `git diff --stat` empty); withhold recorded in Note Dispositions and Operator Follow-up 10 | `git diff --stat origin/main...HEAD -- <four paths>` | See assessment below |
| AC-35 | #737 F-2, or withhold under the same condition | PASS | Same as AC-34; every finding carried the F-2 literal | same | See assessment below |
| AC-36 | #737 F-3 disposition and header paragraph | PASS | `EpicStateIsolation.Discovery.Helpers.ps1` diff (+8); Note Dispositions; Follow-up 4 | Read | |
| AC-37 | #737 F-4 DEV-2 iterates admitted tool names | PASS | `codex-pretooluse-integration.Tests.ps1` diff; `[+]` in CI | CI | |
| AC-38 | #737 F-5 `Assert-FamilySetEqual` | PASS | Parity test lines 81-121 | CI | |
| AC-39 | #737 F-6 disposition and header note | PASS | Discovery.Helpers header; Note Dispositions | Read | |
| AC-40 | #737 N-1 stale parenthetical removed | PASS | `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` diff | Read | |
| AC-41 | #737 N-2 helper comment; TargetResolution suite unchanged | PASS | `EpicStateIsolation.Baseline.Helpers.ps1` diff; reviewer `git diff --stat` on the suite empty | `git diff --stat` | |
| AC-42 | #737 I-3 disposition; four 500-line files unmodified | PASS | `evidence/qa-gates/i3-files-unchanged.2026-10-13T12-48.md`; none of the four in the diff | `git diff --name-only` | |
| AC-43 | No changed code file over 500 lines | PASS | Reviewer `wc -l`: maximum 496 | `wc -l` | |
| AC-44 | No `.claude/rules/` or `.github/instructions/` change | PASS | Reviewer `git diff --stat` over both folders empty | `git diff --stat` | |
| AC-45 | No hook gains a Python invocation | PASS | `evidence/qa-gates/hooks-no-python.2026-10-13T14-03.md`; CI Pester pass | CI | |
| AC-46 | Python toolchain; `_blast_radius_token_shapes` coverage | PASS | Reviewer black/ruff clean; 100% line, 100% branch; full suite 7094 passed | `poetry run black --check`, `ruff check`, `pytest --cov-branch` | |
| AC-47 | TypeScript toolchain | PASS | `evidence/qa-gates/ts-*.2026-10-13T13-4*.md`; CI extension tests success | CI | |
| AC-48 | PowerShell toolchain through MCP; per-test results and per-file coverage from PR CI | PARTIAL | MCP format/analyze/test ok; per-file coverage at or above 85% for all ten production files in run 38410234897; no PR exists, so the PR CI artifact clause is not yet satisfiable | `gh pr list --head ...` returned `[]` | Left unchecked. Separately, FA-1 must be fixed before PR CI is read |
| AC-49 | Mirrors byte-identical; push-down suites pass | PASS | Reviewer `cmp` over 17 pairs: all SAME; `evidence/qa-gates/py-contract-suites.2026-10-13T13-48.md` | `cmp` | |
| AC-50 | Reserved passages and files untouched | PASS | No `enforce-pr-author-skill*` path in the diff; `evidence/qa-gates/scope.2026-10-13T14-02.md` | `git diff --name-only` | |

### Assessment of AC-34 and AC-35 check-off

The check-off is correct. Each AC defines two acceptable outcomes: deliver the fix, or withhold it when the full-population Discovery run raises a new finding in a suite owned by #901 or by the concurrent epic `subagentstop-envelope`, leave that suite unedited, and record the withhold in `## Note Dispositions` and `## Operator Follow-ups`. Verified by the reviewer:

1. The trigger occurred. CI run 38404520141 flagged seven suites. Three match `hook-dependency-failure*`, which `issue.md` `## Concurrency Constraints` reserves for the concurrent epic, so their ownership is established by the item's own text, not inferred.
2. No flagged suite is edited. The branch edits `codex-epic-runtime-contracts.Tests.ps1` for AC-33, which is one of the three unknown-owner flagged suites. The withhold condition binds only #901-owned and epic-owned suites, so this does not breach it.
3. F-1 and F-2 are withheld. The four F-1/F-2 files have no net diff from `origin/main`.
4. The withhold is recorded. Both Note Disposition rows read `withheld`, and Operator Follow-up 10 lists the seven suites with owners.

Limitation (Non-blocking): all findings carried the F-2 literal. F-1 was withheld with F-2 without a run isolating F-1. The AC text permits this, because any finding during the run triggers the withhold for both. Follow-up 10 should evaluate F-1 on its own.

### Assessment of the executor-recorded coverage finding

- `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356` and `:370`: **Blocking (FA-1).** The reviewer re-read the baseline XML (lines 318 and 327, `ci` 1) and the final XML (356 and 370, `ci` 0). This is a measured regression on changed lines, which `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` prohibit.
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207`: **Non-blocking (FA-2).** These lines replace statements that were also `ci` 0 at baseline, so nothing regressed. The file rose from 78.33% to 89.09%, above the 85% floor. The plan's P12-T24 rule is stricter than repository policy and still records it as a failure. Fix it in the same remediation or record a plan exemption.

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Total blocking findings: 1.**

**Criteria summary:**
- **PASS:** 49 criteria
- **PARTIAL:** 1 criterion (AC-48)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. FA-1 (Blocking): changed-line coverage regression at `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356,370`. Plan tasks P12-T24 and P12-T28 remain unchecked for this reason.
2. AC-48 (Non-blocking for this review, required before merge): it can only be satisfied from PR CI artifacts, and no PR exists yet.
3. FA-2 (Non-blocking): Codex epic-scope lines 206-207 have no attributed coverage, and the attribution cause is not determined.

**Recommended follow-up verification steps:**

1. Add surface-parameterized rows to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` that assert the exact `Get-OrchestrationEpicTargetDenyReason` text for `target-ambiguous` and for the fall-through code. Re-run CI, re-read lines 356 and 370 in the coverage XML, and then re-run P12-T24 and P12-T28.
2. After the PR opens, read the PR CI Pester artifacts, record per-test and per-file results, and check off AC-48.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

No source-file change was made in this review. All 49 PASS criteria were already checked. AC-48 is PARTIAL and stays unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md`
- Total AC items: 50
- Checked off (delivered): 49
- Remaining (unchecked): 1
- Items remaining: AC-48 — PowerShell toolchain passes through the PoshQC MCP tools only (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) on every changed `.ps1`/`.psm1` file and suite, with no sh/bash/pwsh wrapper. Per-test results and per-file line coverage (at least 85%) for changed production PowerShell files are taken from the PR CI Pester artifacts and recorded in evidence.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md` | 50 | 49 | 1 | Checkbox-backed; AC-48 pending PR CI |
