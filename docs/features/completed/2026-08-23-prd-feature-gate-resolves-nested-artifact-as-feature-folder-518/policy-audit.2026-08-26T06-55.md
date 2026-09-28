# Policy Compliance Audit — Issue #518

Timestamp: 2026-08-26T06-55
Reviewer: feature-review
Branch: `bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518`
Head: `2ae27c0112210657996f51a7f8f5046dd69cdec1`
Base: `origin/main` @ `b5a7490b685a08584ab618a1debfed7ba4417a32`
Merge base: `b5a7490b685a08584ab618a1debfed7ba4417a32` (branch is rebased; merge base equals the base tip)
Audit scope: the full branch diff `origin/main..HEAD`, 35 files.

## Rejected Scope Narrowing

None. The caller directive instructed a review of the full branch diff against `main` and added
supplementary checks. No instruction narrowed the audit to a plan, task, phase, or file subset, and no
instruction marked a language with changed files as out of scope. Nothing to record under this heading.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at the start of
review. Both were regenerated before adjudication:

```text
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD
```

EXIT_CODE: 0. Resolved base `b5a7490b`, resolved head `2ae27c01`, merge base `b5a7490b` — identical to
the values this audit resolved independently.

One observation from the regenerated summary: the collector reports author-asserted auto-close issues
`#501` and `#518`. `#501` is already CLOSED and appears in the branch only as a citation to a prior
fix. The pull request must close `#518` alone.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`

Language selection: the branch changes two `.ps1` production files and two `.ps1` test files. No
Python, TypeScript, C#, bash, or GitHub Actions file is changed, so no other language rule file is in
scope.

No policy document under `.claude/rules/` or `.github/instructions/` is modified by this branch.
Verified against the diff file list.

## Changed-File Inventory by Category

| Category | Count | Paths |
| --- | --- | --- |
| Production PowerShell | 2 | `.claude/hooks/enforce-prd-feature-before-planner.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| Test PowerShell | 2 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (M); `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` (A) |
| Feature documents | 4 | `issue.md`, `spec.md`, `plan.2026-08-23T23-22.md`, `research/2026-08-23T23-40-...md` |
| Evidence artifacts | 19 | all under `<FEATURE>/evidence/<kind>/` |
| Follow-up lifecycle records | 4 | `docs/features/potential/promoted/2026-08-26-*.md` |
| Python / TypeScript / C# / bash / workflows | 0 | — |

## Verdicts

### 1. Change budget — PASS

`.claude/rules/powershell.md:37-40` caps direct mode at 2 production PowerShell files plus
corresponding tests, and caps any batch at 3 production and 3 test files. The branch changes exactly
2 production PowerShell files (the hook and its mandatory bundled mirror) and 2 test files. No
override was requested and none is required.

### 2. File-size limit (500 lines) — PASS

Measured by `wc -l` at review time, not transcribed from evidence:

| File | Lines |
| --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 447 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 447 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 430 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 419 |

All four are below 500. The companion-file split was the correct application of the rule: the existing
test file was 408 lines at baseline and the 25 new cases would have carried it past the limit.

### 3. Bundle parity (byte identity) — PASS

```text
git hash-object .claude/hooks/enforce-prd-feature-before-planner.ps1 \
  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1
469fecca912e3be687a123b8a3e33ce8a7f327c6
469fecca912e3be687a123b8a3e33ce8a7f327c6
```

`cmp` reports no difference. The two copies are byte-identical. This is the durable evidence for the
parity property; see finding NB-1 for the separate question of the parity test's exit code.

### 4. Toolchain — PASS

Every stage was re-executed by the reviewer rather than accepted from the evidence.

| Stage | Reviewer command | Result |
| --- | --- | --- |
| Format | `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` against all three self-hosted files | CLEAN on all three; formatter output is character-identical to the committed text |
| Lint | `Invoke-ScriptAnalyzer` across all four changed `.ps1` files | `FINDINGS=0` |
| Type check | not applicable | PowerShell has no type-checking stage (`.claude/rules/powershell.md:17`) |
| Unit tests (target files) | `Invoke-Pester` on both hook test files | 72 tests, 0 failed, 0 skipped |
| Unit tests (full suite) | read from `artifacts/pester/pester-junit.xml` | `tests="3680" errors="0" failures="0" disabled="9"` |
| Bundle parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 9 passed / 1 failed at review time — see NB-1 |

The full-suite JUnit artifact figure of 3680 tests and 0 failures matches the post-rebase
re-verification artifact exactly, so that attestation is corroborated by the artifact it cites.

### 5. Coverage — PASS

Only PowerShell has changed files, so PowerShell is the only language with a coverage obligation.

Coverage artifact present: `artifacts/pester/powershell-coverage.xml`, report name
`Pester (08/26/2026 06:38:38)`. The reviewer parsed the JaCoCo document directly.

| Metric | Reviewer-measured value | Threshold | Verdict |
| --- | --- | --- | --- |
| Repo-wide PowerShell line coverage | **96.17 %** (6696 covered / 6963 analyzable) | >= 85 % | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` line coverage (modified file) | **91.35 %** (95 / 104) | >= 85 % | PASS |
| Changed-line coverage | 100.00 % (24 of 24 analyzable changed lines) | no regression | PASS |
| Branch coverage | not measured by Pester | no gate applies | Not applicable by capability |

Regression check: the hook's missed-line count is 9 at baseline and 9 after the change, and the per-file
figure rose from 90.32 % to 91.35 %. No line covered at baseline became uncovered.

The `.claude/rules/quality-tiers.md` branch threshold does not apply to PowerShell because Pester
measures command and line coverage only. No FAIL is recorded for the absent branch figure.

Language coverage verdicts, per the mandatory rule that every language with changed files receives an
explicit verdict:

| Language | Changed files on branch | Verdict |
| --- | --- | --- |
| PowerShell | 4 | **PASS** |
| Python | 0 | not applicable (zero changed files) |
| TypeScript | 0 | not applicable (zero changed files) |
| C# | 0 | not applicable (zero changed files) |

### 6. Coverage Exclusion Policy — PASS

No coverage exclusion was added for any production file. Neither copy of
`pester.runsettings.psd1` is touched by this branch (see section 8). The hook is already present in the
`CodeCoverage.Path` allow-list at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:210`, and
no new production file was created, so no allow-list edit was required or made.

### 7. Evidence Location Compliance — PASS

```text
python scripts/dev_tools/validate_evidence_locations.py --root .
```

EXIT_CODE: 0. No violations reported.

Independent cross-check: `git diff --name-only origin/main..HEAD | grep -E '^artifacts/'` returns zero
paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or
`artifacts/coverage/`. All 19 evidence artifacts resolve under
`<FEATURE>/evidence/<kind>/` with the kinds `baseline`, `regression-testing`, `qa-gates`,
`issue-updates`, and `other`, each of which is a canonical kind.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose: no delegation instruction supplied a
non-canonical evidence path.

### 8. Scope containment — PASS

Verified by the branch diff file list, not by assertion. Every file below is absent from
`git diff --name-status origin/main..HEAD`:

| File | Status on this branch |
| --- | --- |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | untouched |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | untouched |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | untouched |
| the three corresponding bundled mirrors | untouched |
| the three corresponding test files | untouched |
| `.claude/hooks/enforce-feature-folder-order.ps1` and its bundled mirror | untouched |
| `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` | untouched |
| `.claude/settings.json` and its bundled mirror | untouched |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | untouched |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | untouched |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | untouched |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | untouched |

**Attribution of the `pester.runsettings.psd1` change.** Both copies were modified recently, but on
`origin/main`, not on this branch. `git log origin/main -- <both paths>` attributes the most recent
change to `a7e5606e fix(526): wire the per-check polling budgets and split the verification module`,
part of sibling parallel item #526. `git diff --name-only origin/main..HEAD` reports zero changes to
either path. The change is correctly attributable to #526 and is **not** charged to this branch.

The residual `Sort-Object -Property Length -Descending` occurrences are confined to the three
out-of-scope sibling hooks and their mirrors (six occurrences), and are absent from the target hook
and its mirror. This matches the declared scope exactly.

### 9. Write-set conformance — PARTIAL (non-blocking)

The branch adds four files outside the plan's Declared write set:

```text
docs/features/potential/promoted/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md
docs/features/potential/promoted/2026-08-26-feature-folder-order-hook-work-mode-and-plan-filename-defects.md
docs/features/potential/promoted/2026-08-26-parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder.md
docs/features/potential/promoted/2026-08-26-parallel-drift-gate-resolves-nested-artifact-as-feature-folder.md
```

These are the lifecycle records the approved MCP promotion path produces. See finding NB-10 and the
adjudication of item 2 in `code-review.2026-08-26T06-55.md`. No Scope Containment criterion is
violated: every such criterion names a file that must remain unmodified, and none of those files is
touched.

### 10. Tone policy — PASS

The hook's comment-based help, the in-code rationale comments, the test comments, and all 19 evidence
artifacts use neutral, factual language. No humour, hyperbole, metaphor, or celebratory phrasing was
observed. Claims are matched to evidence: the bundle-parity artifact, for example, states plainly that
the baseline was not green and names the environmental cause rather than presenting the improvement as
a result of the change.

### 11. Test policy conformance — PASS

- Test placement mirrors the production tree: both test files sit under
  `tests/scripts/claude-hooks/`, matching `.claude/hooks/`. No colocation.
- No temporary file is created or used by either test file. Every filesystem interaction goes through
  the mocked seams `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, and
  `Get-PrdFeatureCheckpointFolder`.
- Determinism: no `Start-Sleep`, no wall-clock read, no network access, no external process. Paths are
  resolved from `$PSScriptRoot`, not from the process working directory.
- Independence: each `It` establishes its own mocks; no shared mutable state crosses cases.
- Scenario completeness: positive flows, negative flows (three mandatory deny cases), boundary
  conditions (the degenerate short token, the empty prompt, the no-token prompt), and error handling
  (unreadable `issue.md`, malformed envelope) are all covered.

Two documentation defects inside the test files are recorded as NB-4 and NB-5. They do not affect what
the tests assert.

## Summary

| Area | Verdict |
| --- | --- |
| Rejected scope narrowing | none to record |
| Change budget | PASS |
| File-size limit | PASS |
| Bundle parity (byte identity) | PASS |
| Toolchain (format / lint / test) | PASS |
| Coverage — PowerShell | PASS |
| Coverage exclusion policy | PASS |
| Evidence location compliance | PASS |
| Scope containment | PASS |
| Write-set conformance | PARTIAL (non-blocking) |
| Tone policy | PASS |
| Test policy | PASS |

Blocking findings: **0**. Non-blocking findings: **11**, enumerated in
`remediation-inputs.2026-08-26T06-55.md`.
