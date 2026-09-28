# Policy Compliance Audit — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T12-29
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`
- Work mode: `full-bug` (marker read from `issue.md` line `- Work Mode: full-bug`)
- Acceptance-criteria source: `spec.md` only
- Base branch: `epic/worktree-scoped-state-resolution-integration`
- Merge base: `d039e89b2b2569151e9170e1bbefb9f974419f87`
- Head: `03dfdc84fa7fd6107545d4b52f34247961d306f5` on `feature/2026-09-13-prd-feature-gate-target-resolution-672`
- Diff scope: 50 files changed, 2709 insertions, 455 deletions

## Executive Summary

The change set is a PowerShell-only enforcement-hook fix plus its bundled-payload mirror, delivery
registrations, and a new Pester suite. Formatting, analyzer, file-size, mirror-parity, evidence-location,
and coverage gates all pass against independently re-run commands. Coverage for both delivered production
files is above the uniform 85 percent line threshold, and PowerShell is exempt from the branch threshold
because Pester measures line and command coverage only.

One blocking finding is recorded. The delivered fix changes the gate's decision only for calls whose text
carries an absolutely-placed path token. For a repo-relative citation of the target feature folder issued
from a coordinating session root — the first row of the verified decision matrix in `issue.md` — the gate
still denies, and still denies with the work-mode-marker reason that acceptance criterion 6 set out to
remove from that path. This was confirmed by direct execution against the delivered hook, not by
inspection alone.

The two Pester failures reported by the executor were independently confirmed to be environment-coupled
and pre-existing. Neither failing suite, nor the production file either one exercises, appears anywhere in
the branch diff, and both failures are driven by orchestration-checkpoint state that this branch does not
write.

## Rejected Scope Narrowing

None detected. The delegating prompt stated "Scope determination is yours" and supplied the resolved base
branch and refreshed PR context artifacts. No instruction attempted to limit the audit to a plan, task,
phase, or file subset, and no language with changed files was asserted to be out of scope. The audit was
performed against the full branch diff versus `d039e89b2b2569151e9170e1bbefb9f974419f87`.

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 with no reported
paths.

Every evidence artifact added by this branch is under the canonical
`<FEATURE>/evidence/<kind>/` scheme. The branch diff contains zero files under `artifacts/baselines/`,
`artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, or
`artifacts/coverage/`. Kinds used: `baseline/` (7 files), `other/` (10), `qa-gates/` (14),
`regression-testing/` (7). All four are canonical kinds per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

Verdict: **PASS**.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | The new suite injects every input as data; no case writes shared state. Suites were re-run individually and as a set with identical results. |
| Isolation | PASS | Each `It` targets one decision path or one helper function. |
| Fast execution | PASS | The three prd-feature suites complete in under 3 seconds combined. |
| Determinism | PASS | No `Start-Sleep`, `Get-Date`, `New-Guid`, `New-TemporaryFile`, `TestDrive`, `Set-Location`, `Push-Location`, or `$env:TEMP` appears in any of the three suites (grep returned zero matches). Synthetic worktree roots are bare string literals; the modelled current directory is carried on an injected `SessionRoot` member. |
| Readability | PASS | Case names state the decision and the condition; each row carries a rationale comment. |
| Scenario completeness | PASS | Positive (allow), negative (three distinct deny reasons), boundary (four work modes, two path forms, two modelled roots), and error-handling (payload anomaly, indeterminate marker) paths are all covered. |
| Arrange-Act-Assert | PASS | Every case arranges mocks and payload, invokes the decision, then asserts. |
| No external dependencies | PASS | All three filesystem seams are mocked in every case that reaches them. |
| No temporary files | PASS | Confirmed by grep and by reading the suite. |
| Test file location mirrors source | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`. |
| Coverage exclusion policy | PASS | The new production file was added to `CodeCoverage.Path` in both copies of `pester.runsettings.psd1`. No production path was excluded. |

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 9 | 97 across the three prd-feature suites; 4758 repo-wide | 97 passed / 0 failed in scope; 4756 passed / 2 failed repo-wide | 95.65% repo-wide line | 95.64% repo-wide line | 93.55% line on the new helpers file |
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | 17 delivery-contract tests | 17 passed / 0 failed | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Coverage evidence checklist:

- TypeScript baseline coverage artifact: N/A — the branch diff contains zero TypeScript files.
- TypeScript post-change coverage artifact: N/A — the branch diff contains zero TypeScript files.
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, re-parsed independently during this audit
- Per-language comparison summary: PowerShell is the sole language with changed files and its disposition is PASS; the other three languages have zero changed files.

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.65% repo-wide line. Post-change: 95.64% repo-wide line. Change: -0.01 percentage points, with the covered-line count rising from 9333 to 9386 as the denominator rose from 9757 to 9814. New/changed-code coverage: 93.55% line on `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and 90.91% line on `.claude/hooks/enforce-prd-feature-before-planner.ps1`. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, aggregated over 105 `sourcefile` nodes during this audit.
- TypeScript: N/A — zero changed files in the branch diff.
- Python: N/A — zero changed files in the branch diff.
- C#: N/A — zero changed files in the branch diff.

Threshold application. The uniform tier rule in `.claude/rules/quality-tiers.md` requires line coverage at
or above 85 percent and branch coverage at or above 75 percent for branch-capable languages. PowerShell is
not branch-capable under Pester, so no branch figure exists and none is recorded as a failure. Both
delivered production files clear the line threshold. The parent hook's per-file figure moved from 91.35
percent (95 of 104) to 90.91 percent (90 of 99); the two uncovered regions are the same two as at baseline
— the `Get-PrdFeatureCheckpointFolder` file-read body and the entry-point tail below the dot-source guard —
renumbered by the extraction. No previously covered line lost coverage, so the no-regression-on-changed-lines
requirement holds.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | The decision function is a linear sequence of guarded early returns; each branch carries a rationale comment. |
| Reusability | PASS | Target derivation, path normalisation, and the ambiguity reason code are imported from `.claude/lib/worktree-resolution/`, not restated. |
| Extensibility | PASS | The new `-ResolvedTarget` injection parameter follows the established `-CheckpointRaw` seam precedent and is bound with `$PSBoundParameters.ContainsKey`, so an explicitly supplied empty value suppresses the derivation rather than falling through. |
| Separation of concerns | PASS | Pure string and collection logic sits in the dot-sourced sibling; the three filesystem seams stay in the parent. |
| Module rigor tier | PASS | The hook set is enforcement tooling; the uniform coverage gates were applied. |
| Mandatory toolchain loop | PARTIAL | Format, analyzer, and targeted tests pass in a single clean pass, independently re-run. The full-repository Pester stage carries 2 failures that are pre-existing and environment-coupled. See section 8. |
| File size limit (500 lines) | PASS | Largest delivered file is 454 lines. Full ledger in section 9. |
| Error handling — fail fast | PASS | Both `Import-Module` calls are deliberately unguarded so an unloadable resolution module denies the delegation rather than degrading to a permissive path. Every deny path retains the `PRD_FEATURE_BLOCKED:` prefix. |
| No silent error suppression | PASS | The two `catch` blocks in the parent return `$null` for a genuinely absent or unreadable file, which the caller then treats as a deny condition, not as success. |
| Naming | PASS | `PascalCase` verb-noun function names consistent with the repository's other hooks. |
| Public API compatibility | PASS | The three mock seam names and signatures, the dot-source guard, and both PreToolUse payload shapes are unchanged; `PreToolUseSchema.Contract.Tests.ps1` passes unedited (15 of 15). |
| Dependencies | PASS | No new external dependency. The only new import is a repository-internal module already merged on the base branch. |
| I/O boundaries | PASS | Every disk read goes through one of the three seams. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell is the only language with changed source files.

| Requirement | Verdict | Evidence |
|---|---|---|
| Formatter clean | PASS | `Invoke-Formatter` produced byte-identical output for all five changed `.ps1` files. |
| PSScriptAnalyzer clean | PASS | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` returned 0 findings for all 7 changed and mirrored `.ps1` files. |
| Comment-based help on every function | PASS | All 11 delivered functions carry a `.SYNOPSIS`, and most carry a `.DESCRIPTION`. |
| Type checking | PASS | Not applicable to PowerShell per the mandatory toolchain loop. |
| No Python in the enforcement path | PASS | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes 27 of 27. |
| Bundled-payload mirroring | PASS | SHA-256 of both `.claude/hooks/` files equals the SHA-256 of the corresponding `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` file. |
| Documentation accuracy of the changed file | FAIL | The parent hook's `.DESCRIPTION` block still documents the removed positional tie-break and the removed unconditional checkpoint fallback. See finding M1 in the code review. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester 5 discovery/run separation respected | PASS | `-ForEach` data arrays are declared at discovery scope; run-time copies are re-declared in `BeforeAll`. |
| `Should -Invoke ... -Exactly` used for invocation counts | PASS | Zero-count guards on the ambiguity branch and exact positive counts on every allow row. |
| No blanket always-true mocks | PASS | Every `Get-PrdFeatureFileExistence` mock is keyed on the fully composed probe path. The one pre-existing blanket mock in `enforce-prd-feature-before-planner.Tests.ps1` was replaced with a path-keyed mock in this change set. |
| Test file naming and placement | PASS | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. |
| No process working-directory dependence | PASS | The modelled current directory is data on an injected target result. |
| Fail-before evidence for the behaviour change | PASS | `evidence/regression-testing/fail-before.2026-09-17T11-20.md` records 8 required rows failing against the pre-change hook, including two rows failing with a behavioural `Expected 'deny' But was 'allow'` rather than a binding error. |

## 5. Test Coverage Detail

Per-file line coverage read from `artifacts/pester/powershell-coverage.xml` during this audit, keyed on the
parent `package` directory name:

| File | Status | Covered / Total | Line coverage | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | added | 58 / 62 | 93.55% | >= 85% | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | modified | 90 / 99 | 90.91% | >= 85% | PASS |
| Repository-wide PowerShell | — | 9386 / 9814 | 95.64% | >= 85% | PASS |

Uncovered lines on the parent hook: 143, 144, 147, 150, 151, 153 (the `Get-PrdFeatureCheckpointFolder`
real-disk read body) and 427, 429, 431 (the entry-point tail below the dot-source guard). Uncovered lines
on the sibling: 121, 126, 138 (early returns in `ConvertTo-PrdFeatureFolderToken`) and 237 (the no-match
return in `Select-PrdFeatureFolderByTarget`).

No branch-coverage figure is recorded or required. Pester measures line and command coverage only, so the
branch threshold does not apply to PowerShell per `.claude/rules/quality-tiers.md`.

Coverage exclusion review: `CodeCoverage.Path` in `pester.runsettings.psd1` is an explicit per-file
allow-list rather than an `exclude` list. This branch adds the one new production file to that list in both
copies. No `exclude` entry matching a production source path exists, and this branch removes none. The
allow-list model itself is a pre-existing repository-wide condition outside this branch's scope; it is
recorded here as an observation, not as a finding against this change.

## 6. Test Execution Metrics

| Run | Command | Result |
|---|---|---|
| Three prd-feature suites | `Invoke-Pester` per suite, re-run during this audit | 47 + 25 + 25 = 97 total, 97 passed, 0 failed |
| PreToolUse schema contract | `Invoke-Pester` on `PreToolUseSchema.Contract.Tests.ps1` | 15 total, 15 passed, 0 failed |
| No-Python enforcement guard | `Invoke-Pester` on `enforcement-hooks-no-python-invocation.Tests.ps1` | 27 total, 27 passed, 0 failed |
| Must-not-regress gate suites | `Invoke-Pester` on 17 `enforce-orchestration-preimplementation-gate*` and `enforce-epic-merge-gate*` suites, Claude and Codex | 556 total, 556 passed, 0 failed |
| Delivery contract tests | `poetry run pytest` on the three push-down and parity modules | 17 passed, 0 failed, exit 0 |
| Repository-wide Pester (executor run, re-parsed here) | `artifacts/pester/pester-junit.xml` | tests 4758, failures 2, errors 0, passed 4756 |

### 6.1 The two repository-wide failures — independent determination

The delegating prompt asked for an independent determination of whether the two failures are pre-existing
or a regression introduced by this branch. They are **pre-existing and environment-coupled, not a
regression**. Four independent lines of evidence:

1. **Neither failing suite nor its subject is in the branch diff.** `git diff --name-only <base>..<head>`
   restricted to `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`,
   `.claude/hooks/enforce-pr-author-skill.ps1`,
   `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`,
   `.claude/hooks/enforce-epic-wave-barrier.ps1`, and `.codex/` returns an empty set against a 50-file
   diff.

2. **Failure 1 reproduces in isolation, with this feature's suites not loaded.** Running
   `enforce-pr-author-skill.Tests.ps1` alone during this audit yields 43 total, 42 passed, 1 failed, with
   the same case and the same `Expected: 'allow' But was: 'deny'` message.

3. **Failure 1's cause is traced to an unmocked seam that reads live orchestration state.** The failing
   case is `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. Its `BeforeEach`
   mocks `Get-PrContextArtifactExistence`, `Invoke-OrchestratorStatePreflight`, `Get-PrBodyFileBytes`,
   `Get-PrAuthorReceiptContent`, and `Get-PrContextSummaryLastWriteUtc`. It does **not** mock
   `Get-PrAuthorCheckpointContent`, which `Test-EpicBaseBranchOverride` (check 6 in
   `.claude/hooks/enforce-pr-author-skill-helpers.ps1`) calls to read the real checkpoint. Check 6 applies
   to `gh pr create` only, which is exactly why the sibling `gh pr edit` case in the same `Context` passes.
   The checkpoint present in this worktree carries `epic_mode`, so the test payload, which carries no
   `--base`, is denied with `EPIC_BASE_BRANCH_MISMATCH`. That is ambient state, not branch code.

4. **Failure 2's deny reason names state this branch does not write.** The JUnit failure message is
   `EPIC_WAVE_BARRIER_BLOCKED: '672' cannot mutate until every depends_on edge is merged or
   worktree_removed in the epic checkpoint`, emitted by `enforce-epic-wave-barrier.ps1`. The branch diff
   contains no `artifacts/` file and no `.codex/` file.

Consequence: this branch introduces no test regression. The two failures are a test-isolation defect in
two suites outside this feature's file set, and they would not be expected to reproduce on a clean CI
checkout that carries no epic checkpoint. That expectation is stated as an inference from the traced cause,
not as an observed CI result.

## 7. Code Quality Checks

| Check | Command re-run during this audit | Result |
|---|---|---|
| Formatter drift | `Invoke-Formatter` on 5 changed `.ps1` files | 0 files with drift |
| Analyzer, repository settings | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on 7 files | 0 findings |
| File-size cap | `Get-Content ... .Count` on all 9 changed code and settings files | maximum 454, cap 500 |
| Bundled mirror byte identity | `Get-FileHash -Algorithm SHA256` on both pairs | identical |
| Pack-manifest registration | `git diff` on `core.json` | one added path, correct alphabetical position, single occurrence |
| Coverage-path registration parity | `git diff` on both `pester.runsettings.psd1` copies | identical 4-line addition in both |
| No local re-implementation of the F1 contract | string scan for `git worktree`, `Get-Location`, `$PWD`, `Resolve-Path`, and any literal ambiguity code | 0 occurrences across both delivered production files |
| F1 symbol resolution on the base branch | `git ls-tree` at the merge base | both `.claude/lib/worktree-resolution/*.psm1` present at `d039e89b` |
| Spec acceptance-criteria text integrity | normalised diff of `spec.md` base versus head with checkbox state neutralised | zero differences; only checkbox state changed |

## 8. Gaps and Exceptions

**B1 (Blocking) — the repo-relative citation path is unchanged by the fix.**
`Get-PrdFeatureCallTarget` returns `$null` unless the combined prompt and description text matches
`(?<![^\s"'`(])(?:[A-Za-z]:[\\/]|/)`, that is, unless it carries an absolutely-placed path token. For a
repo-relative citation the gate therefore derives no target, keeps the bare repo-relative probe path, and
resolves it against the process working directory exactly as before the change.

Direct execution against the delivered hook (review diagnostic, mocks keyed on the composed path, feature
folder modelled as present only under the item worktree):

- Input: `cwd` = a coordinating session root, prompt = `Plan the work in docs/features/active/2026-09-13-synthetic-target-672 now.`
- Output: `deny`, reason `PRD_FEATURE_BLOCKED: resolved feature folder 'docs/features/active/2026-09-13-synthetic-target-672', but its work mode could not be determined from '.../issue.md' (the '- Work Mode:' marker is absent, unreadable, or unrecognized) ...`

This is byte-for-byte the same reason the pre-change hook emitted, as recorded in the branch's own
`evidence/regression-testing/fail-before.2026-09-17T11-20.md`. Two consequences:

- The first row of the verified decision matrix in `issue.md` (`names its own feature folder | orchestrator
  session root | DENY`) is not repaired for the repo-relative form. Only the absolute form (matrix row 3)
  is repaired.
- Acceptance criterion 6 states the marker-is-broken reason must no longer be emitted for a folder absent
  from the resolved target root, "so the gate no longer prescribes a remedy that would edit the wrong
  repository's `issue.md`". The delivered guard is conditioned on `$probeFolder -ne $folderNormalized`,
  which is true only for the `OtherWorktree` case, so the misleading remedy is still reachable on the most
  common coordinating-session shape.

Adding a branch signal to the prompt does not help: the absolutely-placed-token pre-filter runs before
`Resolve-WorktreeCallTarget`, so F1's `Branch` and relative `FilePath` signals are unreachable from this
hook. Confirmed by direct execution with `branch: feature/2026-09-13-x-672` in the prompt, which produced
the identical marker-is-broken deny.

Related residual risk, not a regression: because no target is derived on the repo-relative path, a call
aimed at another worktree can still be approved on the strength of a copy of the feature folder that
happens to exist under the session root. Direct execution confirms `allow` for that shape. This is
unchanged from the pre-change hook and is not covered by any acceptance criterion, but it is the
false-approval mode the spec names as risk R1, and the ambiguity guard that would catch it is armed only
when an absolutely-placed token is present.

**Exception E1 — the full toolchain loop does not reach a zero-failure pass.** Acceptance criterion 37 and
plan tasks `[P1-T7]`, `[P2-T10]`, `[P4-T21]`, and `[P6-T3]` each require the JUnit `failures` attribute to
be 0. It is 2, for the two pre-existing environment-coupled causes traced in section 6.1. The executor left
all four tasks and that criterion unchecked and recorded the deviation. That handling is correct and is
accepted here. The gates as written are not satisfiable in this worktree without repairing two suites
outside this feature's scope.

**Exception E2 — acceptance criterion 29 records an ordering claim.** The criterion requires the cross-file
mock smoke case to have been "run before the remainder of the extraction is committed". The case exists and
passes, but the ordering is attested by `evidence/regression-testing/cross-file-mock-smoke.2026-09-17T10-55.md`
and the commit sequence rather than being independently reproducible after the fact. Accepted on the
evidence.

## 9. Summary of Changes

File-size ledger for every code and settings file in the change set, measured on the delivered files:

| Lines | File |
|---|---|
| 431 | `.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| 314 | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| 431 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| 314 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| 445 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` |
| 453 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` |
| 454 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` |
| 306 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| 306 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` |

Plus `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one added path) and
38 markdown documents (`spec.md`, `plan.2026-09-13T20-47.md`, and 36 evidence artifacts), which are exempt
from the file-size cap.

Behavioural change surface: one new ambiguity deny branch; removal of the unconditional session-root
checkpoint fallback and of the positional tie-break; probe-path composition against a derived target root;
extraction of five pure functions into a dot-sourced sibling.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PARTIAL — toolchain loop, see exception E1 |
| PowerShell code change policy | PARTIAL — stale comment-based help, finding M1 |
| PowerShell unit test policy | PASS |
| Coverage thresholds (PowerShell) | PASS |
| Coverage thresholds (TypeScript, Python, C#) | N/A — zero changed files in the branch diff |
| Evidence location compliance | PASS |
| Delivery registration and bundled mirroring | PASS |
| Acceptance-criteria delivery | PARTIAL — 35 PASS, 2 PARTIAL, 1 FAIL |

**Overall verdict: PARTIAL. Remediation required.** One blocking finding (B1) and three non-blocking
findings are carried into `remediation-inputs.2026-09-17T12-29.md`.

## Appendix A: Test Inventory

| Suite | Cases | Result |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | 47 passed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 25 passed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 25 | 25 passed |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (unedited) | 15 | 15 passed |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 27 | 27 passed |
| 17 `enforce-orchestration-preimplementation-gate*` and `enforce-epic-merge-gate*` suites | 556 | 556 passed |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and two sibling modules | 17 | 17 passed |

New cases added by this branch: 25 in the `TargetResolution` suite, spanning a cross-file mock smoke case,
seven call-target derivation cases, and a 17-row decision matrix.

## Appendix B: Toolchain Commands Reference

All commands below were executed from the worktree root during this audit via a POSIX wrapper that changes
directory and then invokes `pwsh -NoProfile -File <script>`, this host's route to the PowerShell tool. No
value in this artifact is taken from a PoshQC MCP result, whose summary is composed before the child
process runs and carries no captured output.

1. `Import-Module PSScriptAnalyzer -Force; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
2. `Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw)` compared with `-ceq` against the original text
3. `Get-FileHash -LiteralPath <file> -Algorithm SHA256` on each repository and bundled pair
4. `[xml]$cov = Get-Content artifacts/pester/powershell-coverage.xml -Raw` then aggregation over `//sourcefile` with per-node `line` element `ci` counting
5. `Invoke-Pester -Configuration <per-suite configuration with CodeCoverage disabled>` for each suite in Appendix A
6. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`
7. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
8. `git diff --name-only d039e89b2b2569151e9170e1bbefb9f974419f87..03dfdc84fa7fd6107545d4b52f34247961d306f5`
9. `git ls-tree -r --name-only d039e89b2b2569151e9170e1bbefb9f974419f87 -- .claude/lib/worktree-resolution/`
10. Review diagnostics D1 through D5, Pester files held outside the repository tree, dot-sourcing both delivered hook files and asserting on the returned decision object
