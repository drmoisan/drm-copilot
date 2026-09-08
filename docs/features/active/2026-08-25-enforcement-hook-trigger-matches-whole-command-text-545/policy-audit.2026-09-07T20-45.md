# Policy Compliance Audit: Enforcement-hook trigger scoping (issue #545) — re-audit closing remediation cycle 1

- Issue: #545
- Feature folder: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`
- Audit timestamp: 2026-09-07T20-45
- Reviewer: feature-review agent
- Round: re-audit closing remediation cycle 1 (supersedes `policy-audit.2026-09-07T17-44.md`)

## Baseline

| Field | Value |
|---|---|
| Base branch (resolved) | `epic/cleanup-merged-worktrees-hardening-integration` |
| Merge-base SHA | `6dff80ed4596bec088d548b23013e6077e32c484` |
| Head SHA | `85a3c3448c0900762e47d03f4fed2a9442cc1ef9` |
| Head branch | `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` |
| Diff range | `6dff80ed..85a3c344` (merge-base is a direct ancestor; unscoped diff is evaluable) |
| Working tree | clean (`git status --porcelain` produced no output) |
| PR context summary | `artifacts/pr_context.summary.txt` — generated 2026-09-07 20:28:54 UTC, head SHA matches |
| PR context appendix | `artifacts/pr_context.appendix.txt` — same generation |
| Work mode marker | `- Work Mode: full-bug` (`issue.md` line 12) |
| Acceptance-criteria source | `spec.md` only (per `full-bug`) |
| Commits in range | 11 |
| Files changed | 202 (`27911` insertions, `351` deletions) |

## Rejected Scope Narrowing

None. The caller prompt explicitly directed a full feature-vs-base re-audit with no scope
narrowing, and supplied the resolved base branch and merge-base that this audit used. No caller
instruction attempted to limit the audit to the remediation delta, to a plan or phase subset, to a
subset of changed files, or to mark any language's coverage as out of scope. The audit was
performed against the full `6dff80ed..85a3c344` diff.

One instruction is recorded for transparency because it constrains an artifact rather than the
audit scope: the caller stated that AC-22 "cannot pass this round; it closes on the PR body." That
is a statement of fact about a criterion whose evidence is a not-yet-written PR body, not a scope
narrowing, and this audit independently confirmed AC-22's evidence is unavailable.

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** with no output.

An independent scan of the branch diff for files written under `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` returned zero matches:

```
grep -E "^(artifacts/(baselines|qa|evidence|coverage))/" <changed-file-list>   # no matches
```

Every evidence artifact produced by this feature is under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`
with `<kind>` in `{baselines, qa-gates, regression-testing, issue-updates, other}`. **PASS.**

## Verification Route and Toolchain Substitutions

`pwsh`, `powershell`, and `cmd` are refused by this session's runtime guard, and the
`mcp__drm-copilot__*` tools are not exposed to this agent. The following substitutions were used
and are recorded rather than omitted.

| Stage | Route used by this audit | Substitution note |
|---|---|---|
| Review artifact templates | Read directly from `extensions/drm-copilot/resources/templates/policy_audit/*.yyyy-MM-ddTHH-mm.md` | TOOLCHAIN_SUBSTITUTION: the MCP `resolve_policy_audit_template_asset` tool is not exposed to this agent. The repo-side asset is the same file the MCP selector resolves (`src/policy-audit-template-assets.ts`). Structure and required headings were taken from it. |
| PowerShell format / lint | Evidence inspection of `evidence/qa-gates/final-poshqc-format.2026-09-07T20-04.md` and `final-poshqc-analyze.2026-09-07T20-05.md` | TOOLCHAIN_SUBSTITUTION: no local PowerShell host is invocable. Both artifacts record `EXIT_CODE: 0` and carry their own substitution notes. |
| PowerShell tests | Independent parse of `artifacts/pester/pester-junit.xml` | Not a substitution — this is a direct re-derivation from the run artifact, stronger than reading the executor's summary. |
| PowerShell coverage | Independent parse of `artifacts/pester/powershell-coverage.xml`, cross-checked against the CI-dispatch figures in `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md` and `…T20-21.md` | Coverage generation was not re-run, per the Coverage Verification contract. |
| Pair parity | `cmp -s` over all 18 canonical/bundle pairs | Not a substitution — byte comparison is stronger than the SHA-256 claims in the evidence artifacts. |
| CI run conclusion | Orchestrator-attested | UNVERIFIED-BY-THIS-AGENT: `gh` is not installed in this session (`pr_context.summary.txt` records "GitHub CLI unavailable"), so the `success` conclusion of run `34158596238` could not be read from the GitHub API. All numeric values that run supplied were corroborated by other means (see Coverage). |

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Every new suite drives pure string functions or a mocked decision seam with literal fixtures. No suite writes shared state. |
| Isolation | PASS | Each `It` targets one function or one decision. |
| Fast execution | PASS | 2381 cases across 99 suites in one Pester run. |
| Determinism | PASS | Each new test file carries an explicit determinism note ("no disk I/O, no child process, no temporary file, no live executable, no ambient state"). Spot-checked in `validate-bash.TriggerScoping.Tests.ps1`, `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`, `hook-command-scanner.Tests.ps1`. |
| Readability | PASS | Case names carry the AT/R1 identifier and the asserted decision; each carries an explanatory comment naming the mechanism. |
| Line coverage >= 85% | PASS | All 18 changed-or-added canonical production files at or above 85. See §5. |
| Branch coverage >= 75% | N/A (not a FAIL) | Pester emits no `BRANCH` counter. Enumeration of `counter/@type` across `powershell-coverage.xml` yields exactly `{CLASS, INSTRUCTION, LINE, METHOD}`. Per `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, no branch gate applies to PowerShell. |
| No regression on changed lines | PASS | `.claude/hooks/validate-bash.ps1` 94.3182 → 94.4444; `.codex/hooks/validate-bash.ps1` 100.0000 → 100.0000. No other production file changed after the 18-file measurement. |
| Coverage Exclusion Policy — no production file excluded | PASS | The `pester.runsettings.psd1` diff is **additive only**: eight new `CodeCoverage.Path` entries, zero new `exclude` entries. The two new parser files and four previously-unregistered Codex canonical hooks were brought *into* the denominator. The bundle mirrors under `extensions/drm-copilot/resources/` remain outside the list, which is the pre-existing repo-wide convention for that prefix (the list holds zero entries under it) and is guarded instead by the byte-identity parity mechanisms; the change adds no entry under that prefix and therefore introduces no new exclusion. |
| Test file location mirrors source tree | PASS | Every new test lives under `tests/scripts/claude-hooks/` or `tests/scripts/codex-hooks/`, mirroring `.claude/hooks/` and `.codex/hooks/`. No colocation in the production tree. |
| Scenario completeness | PASS | Each new behavior carries positive, negative, and boundary cases. The R-1 pinning set is five per side, including one negative (`R1-C4`/`R1-X4`) and one unbalanced-quoting boundary (`R1-C5`/`R1-X5`). |
| No temporary files in tests | PASS | Grep of the new suites found no `New-TemporaryFile`, `[System.IO.Path]::GetTempPath`, or `TestDrive` write. |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | The remedy is two dot-sourced pure-string `.ps1` files consumed by nine hooks. No new module, no class hierarchy, no DI. |
| Reusability | PASS | Nine hooks across two runtimes share one scanner and one matcher instead of nine private regexes. Duplication genuinely removed: `Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath` now delegate the same concern to `Get-CommandLineOperand`. |
| Extensibility | PASS | The wrapper set, transparent-wrapper set, and global-option tables are named script-scope constants exposed through accessors and pinned by membership tests, so adding a member is a one-line change with a failing test to update. |
| Separation of concerns | PASS | Both parser files are pure string logic — no disk, process, network, clock, or environment access. Verified by reading both files end to end; the only `Join-Path` uses are the `$PSScriptRoot` dot-source lines. |
| File size limit (500 lines) | PASS | Largest changed or added file is 500 lines exactly (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, both copies). Zero files over. Full table re-derived independently; see §7. |
| Fail fast / explicit errors | PARTIAL | The design's stated posture is fail-closed on unresolvable input, and it holds in most call sites. It does **not** hold in four call sites where a wrapper-led segment now produces an allow where the pre-change code denied. See §8 and finding **R-2**. |
| Naming | PASS | All new public functions use approved PowerShell verbs and descriptive nouns (`Read-CommandLineSegment`, `Test-CommandLineInvocation`, `Get-CommandLineFlagValue`). PSScriptAnalyzer clean. |
| Public API compatibility | PASS | `Get-EpicWorktreeRemovalCommandPath`, `Get-ParallelWorktreeRemovalCommandPath`, `Get-EpicMergeGateCommandPrNumber`, `Test-ParallelAbandonCommandInScope`, and `Get-BlockedPatternMatch` all keep their names, signatures, and null-on-miss contracts, so the existing pinning suites run unmodified. |
| Dependencies | PASS | No new package. No import added beyond dot-sourcing two in-repo files. |
| I/O boundaries | PASS | Checkpoint reads stay behind the pre-existing injectable read seams; the parser touches no I/O at all. |

## 3. Language-Specific Code Change Policy Compliance (PowerShell)

| Requirement | Verdict | Evidence |
|---|---|---|
| `Invoke-Formatter` clean | PASS | `evidence/qa-gates/final-poshqc-format.2026-09-07T20-04.md`, `EXIT_CODE: 0`, `ok: true`. |
| PSScriptAnalyzer clean | PASS | `evidence/qa-gates/final-poshqc-analyze.2026-09-07T20-05.md`, `EXIT_CODE: 0`, `ok: true`. |
| No type-check stage | N/A | PowerShell has no type-check stage per the mandatory toolchain loop. |
| `[CmdletBinding()]` + `[OutputType()]` on every function | PASS | Every function in both new parser files carries both attributes. Spot-verified across all 12 public and private functions. |
| Comment-based help on public functions | PASS | Every function in `hook-command-scanner.ps1` and `hook-command-invocation.ps1` carries `.SYNOPSIS`, `.DESCRIPTION`, and `.OUTPUTS`. |
| No `$env:CLAUDE_` reference in shared parser | PASS | Grep returned zero matches in both files, both runtimes. |
| No Python interpreter invoked from a hook | PASS | Zero `python`/`.py` references in either new parser file. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` builds its scan set by recursive `Get-ChildItem` over `.ps1`/`.psm1`, so the new files are automatically in scope, and the suite passes. |
| Approved verbs | PASS | PSScriptAnalyzer's `PSUseApprovedVerbs` is part of the clean analyze run. |

Observation (not a violation): `$script:CdChainedReadCommandPattern` in `validate-bash.ps1` line 222
is now assigned and never read. It is retained deliberately to discharge the AC-07 byte-unchanged
obligation, and the retention is documented in the adjacent comment block. See code review finding
**C-3** for the remediation that would make it live again.

## 4. Language-Specific Unit Test Policy Compliance (PowerShell)

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester 5 syntax | PASS | Every new suite opens with `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| `Describe` / `Context` / `It` structure | PASS | Verified across all 20 new and modified suites. |
| Arrange–Act–Assert | PASS | Each case is a two- or three-line arrange/act followed by a single `Should`. |
| Mocking at injectable seams | PASS | Checkpoint reads mocked through `Get-*CheckpointContent` seams; no filesystem mock hooks. |
| Test files mirror source layout | PASS | See §1. |
| Suites dot-source the file under test by resolved path | PASS | Every new suite resolves `$PSScriptRoot/../../../.claude/hooks/...` or the `.codex` equivalent. |

## 5. Test Coverage Detail

Languages with changed files in the branch diff: **PowerShell only**. The diff contains no `.py`,
`.ts`, `.tsx`, or `.cs` file. Verdicts:

| Language | Changed files | Coverage artifact | Repo-wide line | Verdict |
|---|---|---|---|---|
| PowerShell | 38 `.ps1` (18 canonical production, 18 bundle mirrors, plus 20 test suites) and 2 `.psd1` settings | `artifacts/pester/powershell-coverage.xml` (present) and CI run `34158596238` | 95.4638 | **PASS** |
| Python | 0 | — | — | N/A (zero changed files) |
| TypeScript | 0 | — | — | N/A (zero changed files) |
| C# | 0 | — | — | N/A (zero changed files) |

### Composite measurement provenance

Coverage for this branch is carried by two CI dispatches of `.github/workflows/_poshqc.yml`,
because the local MCP runner resolves runsettings from the installed VS Code extension and cannot
see this branch's new `CodeCoverage.Path` entries. The audit verified that the composite covers the
head:

1. Run `34145103168` measured commit `5903d0c7` and produced the 18-file table in
   `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md`.
2. Run `34158596238` measured commit `3b4f10b9` and re-measured the two `validate-bash.ps1`
   canonical files after the R-1 fix.
3. Independently re-derived drift check:
   `git diff --name-only 5903d0c7 85a3c344 -- '.claude/hooks/*.ps1' '.codex/hooks/*.ps1' 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`
   returns exactly `.claude/hooks/validate-bash.ps1` and `.codex/hooks/validate-bash.ps1` — the
   two files run 2 re-measured. **No production file is measured at stale content.**
4. `git diff --name-only 3b4f10b9..85a3c344` returns docs-only paths, so run 2's measurement is
   valid at the head.

### Per-file line coverage (18 changed-or-added canonical production files)

| # | File | Covered | Missed | Line % | >= 85 |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 176 | 4 | 97.7778 | yes |
| 2 | `.claude/hooks/hook-command-invocation.ps1` | 122 | 2 | 98.3871 | yes |
| 3 | `.codex/hooks/hook-command-scanner.ps1` | 180 | 0 | 100.0000 | yes |
| 4 | `.codex/hooks/hook-command-invocation.ps1` | 120 | 4 | 96.7742 | yes |
| 5 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 136 | 18 | 88.3117 | yes |
| 6 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 164 | 2 | 98.7952 | yes |
| 7 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 56 | 4 | 93.3333 | yes |
| 8 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 65 | 0 | 100.0000 | yes |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 64 | 3 | 95.5224 | yes |
| 10 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 24 | 2 | 92.3077 | yes |
| 11 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 | 5 | 94.9495 | yes |
| 12 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 67 | 1 | 98.5294 | yes |
| 13 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 | 5 | 93.2432 | yes |
| 14 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 114 | 4 | 96.6102 | yes |
| 15 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 66 | 1 | 98.5075 | yes |
| 16 | `.claude/hooks/validate-bash.ps1` | 85 | 5 | **94.4444** | yes |
| 17 | `.codex/hooks/validate-bash.ps1` | 75 | 0 | 100.0000 | yes |
| 18 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 64 | 5 | 92.7536 | yes |

Zero files below 85. Zero files with no row.

### Independent corroboration of the reported figures

The reviewer parsed the local `artifacts/pester/powershell-coverage.xml` directly, selecting the
`LINE` counter on the `sourcefile` whose bare name matches, within the `package` whose name ends
with the file's directory (package-qualified selection is required because ~10 hook filenames exist
under both `.claude/hooks` and `.codex/hooks`). Eight of the eighteen rows are reproducible from
that artifact and **all eight match the CI-reported figures exactly**:

| File | CI-reported | Locally re-derived | Match |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 136 / 18 | 136 / 18 | yes |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 56 / 4 | 56 / 4 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 64 / 3 | 64 / 3 | yes |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 24 / 2 | 24 / 2 | yes |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 / 5 | 94 / 5 | yes |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 / 5 | 69 / 5 | yes |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 114 / 4 | 114 / 4 | yes |
| `.claude/hooks/validate-bash.ps1` | 85 / 5 (post-fix) | 85 / 5 | yes |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 64 / 5 | 64 / 5 | yes |

The remaining rows (the four parser files and the four Codex canonical hooks) produce **NO ROW** in
the local artifact, which is exactly the documented MCP limitation the evidence artifacts cite: the
local runner cannot see the branch's newly added `CodeCoverage.Path` entries. Their absence here is
confirmatory of the stated reason for using the CI route, not a coverage gap.

The local repo-wide aggregate (5096 / 2839 = 64.2218) is **not** comparable to the CI figure because
the local run measured a narrower denominator. The repo-wide 95.4638 figure remains
orchestrator-attested from run `34158596238` and was not independently re-derived; the arithmetic
consistency check (8418 / 8818) holds.

## 6. Test Execution Metrics

Independently re-derived from `artifacts/pester/pester-junit.xml`:

| Metric | Value |
|---|---|
| Suites | 99 |
| Cases | 2381 |
| Failures | 2 |
| Errors | 0 |
| Skipped | 0 |

### The two failures are ambient, not change-caused — verified independently

| Failing case | Cause | Change-caused? |
|---|---|---|
| `enforce-pr-author-skill.ps1 > allowed commands > allows gh pr create --body-file … when context exists` | The `allowed commands` `BeforeEach` does not mock `Get-PrAuthorCheckpointContent`, so `Test-EpicBaseBranchOverride` reads the real gitignored `artifacts/orchestration/orchestrator-state.json`. That file carries `"epic_mode": true` (line 24), and the fixture command carries no `--base`, so the hook returns `EPIC_BASE_BRANCH_MISMATCH`. | **No.** `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is not in the branch diff. The reviewer compared the pre- and post-change trigger predicates: the base-branch hook's scope filter moved from `$CommandText -notmatch '(?i)\bgh\s+pr\s+create\b'` to `Test-CommandLineInvocation … @('pr','create')`. Both classify `gh pr create --title "foo" --body-file …` as in scope, so both reach the same `EPIC_BASE_BRANCH_MISMATCH` for the same ambient checkpoint. Filed as F-4. |
| `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` | `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED: '545' cannot mutate until every depends_on edge is merged` after reading this worktree's gitignored epic checkpoint. | **No.** Neither `enforce-epic-wave-barrier.ps1` nor `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` is in the branch diff. |

### New-case presence, re-derived from the JUnit artifact

All ten R-1 pinning cases are present and none appears in the failing set:
`R1-C1`…`R1-C5` (1 case each) and `R1-X1`…`R1-X5` (1 case each). The acceptance-test identifiers
`AT-1`, `AT-2`, `AT-4`, `AT-6`, `AT-7`, `AT-11`, `AT-12` each resolve to a named case, and `AT-8`,
`AT-9`, `AT-10` resolve to 4, 2, and 4 cases respectively across both sides.

## 7. Code Quality Checks

### File size (500-line cap)

Re-derived independently over every `.ps1` in the branch diff. Zero files exceed 500 lines.

| File | Lines |
|---|---|
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (both copies) | **500** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (both copies) | 495 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 |
| `hook-command-invocation.ps1` (all four copies) | 483 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` (both copies) | 472 |
| `hook-command-scanner.ps1` (all four copies) | 450 |
| … remaining 50 files | < 450 |

Observation: the Codex preimplementation gate sits at exactly the cap with zero headroom. Any
future edit to that file must be paired with an extraction. Recorded as code review finding **C-4**.

### Canonical/bundle byte parity

`cmp -s` over every pair, run by this reviewer:

- 11 Claude pairs (`.claude/hooks/<f>` vs `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<f>`): **all byte-identical**.
- 7 Codex pairs (`.codex/hooks/<f>` vs `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<f>`): **all byte-identical**.
- Cross-runtime parser identity: `.claude/hooks/hook-command-scanner.ps1` ≡ `.codex/hooks/hook-command-scanner.ps1` and the same for `hook-command-invocation.ps1`: **byte-identical**.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` ≡ `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`: **byte-identical** (the textual-identity requirement `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` enforces).

Byte comparison is a stronger claim than the SHA-256 and content-equality assertions the evidence
artifacts make; both agree.

### Registration completeness (14 entries across 5 registry files)

Re-derived from the diff:

| Registry file | Entries added |
|---|---|
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 2 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | 2 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`$script:SharedModuleNames`) | 2 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 4 (two helpers × two runtimes) |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 4 (identical text) |
| **Total** | **14** |

### `modified-workflow-needs-green-run`

The rule **does not fire**. The branch diff contains no path matching `.github/workflows/**`,
`scripts/benchmarks/**`, or `.github/actions/**`. The `_poshqc.yml` workflow was *dispatched* by the
orchestrator to produce coverage, but not modified.

## 8. Gaps and Exceptions

### G-1 — Wrapper-led segments produce an allow at four flag-gated call sites (**Blocking**)

This is the residual of the same defect class the prior round raised as R-1, in four locations R-1
did not reach. The R-1 fix closed the `validate-bash.ps1` denylist leg. It did not close the call
sites that gate scope on **flag presence** or that read `.Tokens` without an invocation primitive.

The mechanism is fixed and identical in each case. `ConvertTo-CommandLineToken` collapses a balanced
quoted span into ONE token. `Resolve-CommandLineInvocation` correctly classifies a wrapper-led
segment by raw containment and reports `OperandIndex = -1`, but `Test-CommandLineFlag` and
`Get-CommandLineFlagValue` then iterate `$resolved.Segment.Tokens` unconditionally. For a
wrapper-led segment those tokens are collapsed, so every flag reads as absent. Where the call site
treats an absent flag as *out of scope*, the gate allows.

| # | Call site | Command that now allows | Pre-change behavior | Copies |
|---|---|---|---|---|
| G-1.a | `enforce-epic-merge-gate.ps1` `Invoke-EpicMergeGateDecision`, `-not $hasMergeFlag` → `Get-EpicMergeGateAllowDecision` | `bash -c "gh pr merge --merge 688"` | in scope, gate applies, denies with `EPIC_MERGE_GATE_BLOCKED` absent an authorizing checkpoint (`$commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b'` matched the raw text) | 4 (Claude + Codex, canonical + bundle) |
| G-1.b | `enforce-parallel-abandon-gate.ps1` `Test-ParallelAbandonCommandInScope` reads `$segment.Tokens` with no wrapper fallback | `bash -c "python … --disposition abandon"` | in scope (`$NormalizedCommand.Contains('--disposition abandon', OrdinalIgnoreCase)`), denies with `PARALLEL_ABANDON_BLOCKED` absent `--confirm-abandon` | 2 (Claude only) |
| G-1.c | `enforce-pr-author-skill-helpers.ps1` `Get-PrAuthorBypassReason`, `isPrEdit` with both flags false → `return $null` | `bash -c "gh pr edit 42 --body 'x'"` | Case A fired (`--body(?!-file)\b` matched the raw text), denying with `PR_AUTHOR_SKILL_BLOCKED` | 2 (Claude only) |
| G-1.d | `validate-bash.ps1` `Get-CdChainedReadCommandMatch` walks segment `CommandWord`, so a wrapper-led segment has command word `bash`, never `cd` | `bash -c "cd /x && head f"` | denied by `$script:CdChainedReadCommandPattern` over the raw text | 2 (Claude only) |

G-1.d is additionally a deviation from the normative D12 call-site rewrite table, which directs
`validate-bash.ps1 L105` to "the `cd`-chained pattern evaluated per segment against `ScanText`". The
implementation instead performs a `CommandWord` walk. The docstring gives a sound reason the pattern
cannot be the *only* mechanism (`&&` is a segment delimiter, so no single segment carries both sides
of a chain) — but the directed `ScanText` evaluation still works, and is required, for the wrapper
case, where the whole chain sits inside one segment. The two mechanisms are complementary, not
alternatives.

**Why this is Blocking rather than an accepted residual.** Spec D4 enumerates three accepted
residual risks and none of them covers this. D4.1 accepts *over*-match inside wrapper-led segments
(deny-biased); this is *under*-match (allow-biased). D4.3 accepts an *unlisted* wrapper such as
`parallel`; every command above uses a **listed** wrapper. D3's conclusion states the opposite of
the observed behavior: "Every wrapper form D8 cited **that denies today** keeps its denial." AC-09
states "**No existing denial is weakened**." Four denials are weakened, two of them on gates that
authorize irreversible actions (a PR merge, a work-item abandon).

**Why no test caught it.** The seven D3 wrapper deny pins required by AC-08 are asserted at the
parser level (`hook-command-invocation.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`)
and at the preimplementation gate, both of which behave correctly. No wrapper case exists in
`enforce-epic-merge-gate.TriggerScoping.Tests.ps1`,
`enforce-epic-merge-gate-trigger-scoping.Tests.ps1`, or
`enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`. The pins verify that
`Test-CommandLineInvocation` classifies the wrapper form; they do not verify that the hook's
decision surface still denies it. Confirmed by grep: those three files contain no occurrence of
`bash -c`, `sh -c`, `xargs`, `env `, or `pwsh -`.

**In-repo precedent for the fix.** `enforce-promotion-mcp-only.ps1` already implements the correct
shape: the byte-unchanged literals run against `$segment.ScanText`, the adjacency-requiring
expression runs against `$segment.ScanText`, and a structural `Test-CommandLineInvocation` leg is
added alongside for the relocating spelling. Applying that shape to the four sites above closes G-1
without touching any byte-unchanged literal.

### G-2 — `rm -rfv` no longer matches the `rm -rf` denylist literal (**Low, spec-sanctioned**)

Whole-token equality means `rm -rfv /tmp/x` produces tokens `rm`, `-rfv`, `/tmp/x`, and `-rfv` does
not equal `-rf`, so leg 1 does not match. The pre-change `String.Contains('rm -rf')` matched the
prefix and denied. This is a direct and intended consequence of the D11.3 ruling, which names "no
token boundary of any kind" as one of three *defects* in the old primitive and which the same
mechanism uses to deliver AT-8 (`git push --force-with-lease` must allow). The spec does not
enumerate `rm -rfv` specifically. Recorded so it is a known, chosen trade rather than a surprise.

### G-3 — Repo-wide coverage figure is orchestrator-attested (**Informational**)

The 95.4638 repo-wide figure and the `success` conclusion of run `34158596238` come from the
orchestrator. `gh` is unavailable in this session, so neither was read from the GitHub API. Every
per-file figure that *could* be re-derived locally matched exactly (9 of 9 reproducible rows), and
the drift check proves the measurement covers the head content, which is the material question for
the coverage gate. The repo-wide number is above threshold by a wide margin under either reading.

### G-4 — Process deviations recorded by the orchestrator against itself

Both were disclosed by the caller and are recorded here for the audit trail. Neither is a code
defect and neither blocks the PR.

| Deviation | Assessment |
|---|---|
| Preflight ran three rounds against a two-round target. One of the three round-2 defects (D14) was a genuine round-1 miss; the other two were undiscoverable in round 1. | **Accepted with note.** Self-disclosed, with a defensible split between a real miss and two ordering-dependent discoveries. The outcome — the third disjunct being caught before it shipped — argues the extra round earned its cost. |
| The commit-message delegation contract was violated twice: the orchestrator committed before the delegate returned at `5211a2b8` and again at `cfc1ca26`. The second was amended to the delegate-generated message at `85a3c344`; the first was not, because it has since been rebased and is an ancestor of later commits. | **Accepted with note.** The reviewer confirms neither `5211a2b8` nor `cfc1ca26` appears in the `6dff80ed..85a3c344` range, so no non-delegate-authored message reaches the base branch as a distinct commit; the surviving 11 commit messages all carry the conventional-commit shape and the `Refs: #545` trailer. The unremediated first instance is a process record, not a defect in the delivered history. |

## 9. Summary of Changes

| Area | Change |
|---|---|
| New shared parser | `hook-command-scanner.ps1` (450 lines) and `hook-command-invocation.ps1` (483 lines), dot-sourced `.ps1` files, delivered to all four locations (8 files total), byte-identical across runtimes. |
| Hooks rewired | 9 hooks: preimplementation gate, promotion-mcp-only, epic merge gate, epic worktree removal gate, `validate-bash` (all four copies each); pr-author helpers, parallel worktree removal gate, parallel abandon gate, pr-author epic-base-branch (two Claude copies each). |
| R-1 remediation | `Get-BlockedPatternMatch` leg 1 gained a second condition scanning `$segment.ScanText` by ordinal `IndexOf` when the segment is wrapper-led, carries a live substitution, **or is unbalanced**. Applied identically to all four `validate-bash.ps1` copies at `3b4f10b9`. |
| R-1 pinning | 10 new cases, 5 per side (`R1-C1`–`R1-C5`, `R1-X1`–`R1-X5`). |
| R-2 spec amendment | AC-07 amended to record the pr-author `gh pr create` / `gh pr edit` expressions as superseded by the D12 call-site rewrite table rather than byte-unchanged. |
| Registration | 14 entries across 5 registry files. |
| Follow-ups | 3 potential entries filed under `docs/features/potential/`. |
| Cross-issue annotation | Issue #539's `spec.md` annotated additively at five locations. |

## 10. Compliance Verdict

| Dimension | Verdict |
|---|---|
| General unit test policy | **PASS** |
| General code change policy | **PARTIAL** — fail-fast posture not preserved at four call sites (G-1) |
| PowerShell code change policy | **PASS** |
| PowerShell unit test policy | **PASS** |
| Coverage (PowerShell) | **PASS** |
| Evidence location compliance | **PASS** |
| File size limit | **PASS** |
| Canonical/bundle parity | **PASS** |
| `modified-workflow-needs-green-run` | **Not triggered** |
| Toolchain (format → analyze → test) | **PASS** (test stage green modulo two independently confirmed ambient failures) |
| **Overall** | **PARTIAL — remediation required for G-1** |

### R-1 verification (prior round's blocking finding)

**CLOSED.** The reviewer verified the fix independently rather than accepting the evidence artifact:

- The added condition is `($segment.IsWrapperLed -or $segment.HasLiveSubstitution -or $segment.Unbalanced) -and $segment.ScanText.IndexOf($pattern, [System.StringComparison]::Ordinal) -ge 0` at `.claude/hooks/validate-bash.ps1` lines 197–200 and the `.codex` equivalent.
- The three disjuncts are **exactly** the scanner's own ScanText selection clause at `hook-command-scanner.ps1` line 151: `if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }`. The sets are identical, so the leg reads raw text for precisely the segments the scanner scans raw, and never for a segment whose ScanText is masked.
- The change is present in all four copies and the four pairs are byte-identical.
- The six denylist literals in `Get-BlockedBashPattern` are byte-unchanged (lines 53–60).

### Adjudication of the third disjunct (`Unbalanced`), which the remediation inputs did not specify

**The orchestrator's ruling to apply it rather than defer it was correct, and the disjunct is not
over-broad.**

- *It was necessary.* Without it, `echo "rm -rf /tmp/x` with an unterminated double quote takes the masked path: `ConvertTo-CommandLineToken` never closes the quote, so the trailing text becomes one token and no token run matches, while the pre-change `String.Contains` denied. That is the R-1 mechanism reappearing through a second door, left open by R-1's own fix. Deferring it would have closed AC-09 while a denial remained weakened — the orchestrator's stated ground, which this reviewer confirms.
- *It is not over-broad.* A segment is `Unbalanced` only when a quote never closes, a heredoc body never terminates, or a heredoc delimiter is produced by expansion. In every such case the scanner has already declared the segment unresolvable and selected `RawText` as scan text under D2 Piece 2 clause 1. Scanning raw text there is the design's own fail-closed posture, not an additional one. The reviewer traced the scanner's segmentation loop to confirm `$unbalanced` is set per segment and, for the end-of-input case, applies only to the final record — so an earlier balanced segment is not contaminated.
- *It is pinned.* `R1-C5` and `R1-X5` assert `Get-BlockedPatternMatch -Command 'echo "rm -rf /tmp/x'` returns `rm -rf`, and their comments state explicitly that the case "fails against a two-disjunct fix and passes only against the three-disjunct fix." Both pass in the JUnit artifact.

### Correction of a defect in the reviewer's own prior artifact

`feature-audit.2026-09-07T17-44.md` line 131 cited **AC-31** as the criterion covering
`enforce-pr-author-skill.epic-base-branch.ps1`, contradicting its own index four lines earlier. The
reviewer re-derived the index independently from `spec.md` at the current head:

| Index | `spec.md` line | Criterion |
|---|---|---|
| AC-31 | 1615 | `validate-bash.ps1` matching-primitive change (D11.3) — AT-8, AT-9, AT-10 |
| AC-33 | 1631 | `enforce-pr-author-skill.epic-base-branch.ps1` is fixed in both Claude copies |

The prior artifact's *index* was correct and its *adjudication paragraph* was wrong. The pre-amendment
line numbers it recorded (1604 and 1620) differ from the current ones by exactly 11 lines, which is
the length the AC-07 amendment added ahead of both — a consistency check that confirms the mapping
rather than the mis-citation. The mis-citation is **not** reproduced in this round's artifacts, and
`spec.md`'s own AC-07 amendment text states the correct mapping.

## Appendix A: Test Inventory (new and modified suites)

| Suite | Purpose |
|---|---|
| `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | D2 Piece 1 and 2: segmentation, masking, tokenization, all seven heredoc rules, the three ScanText clauses, 14-member wrapper set, D12 signature pins |
| `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | D2 Piece 3, D12 signature pins, transparent-wrapper and global-option membership |
| `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` | D3 fail-closed table rows |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | AT-8/9/10 plus the five `R1-C` pins |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | Codex AT-8/9/10 plus the five `R1-X` pins |
| `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` | Codex denylist and decision-surface preservation |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | AT-2, AT-4 |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-{decision-surface,trigger-scoping}.Tests.ps1` | Codex merge gate, no-digit-scan assertion |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | AT-1 |
| `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-{decision-surface,trigger-scoping}.Tests.ps1` | Codex worktree gate |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | AT-7 |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | AT-11, AT-12, segment-scoped confirmation |
| `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | AT-5, receipt-value allow |
| `tests/scripts/codex-hooks/enforce-promotion-mcp-only-{decision-surface,trigger-scoping}.Tests.ps1` | Codex AT-5 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | AT-6, wrapper deny pins, #539 exemption preservation |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-{trigger-scoping,mode-routing,command-exemption}.Tests.ps1` | Codex equivalents |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `--body` vs `--body-file`, receipt-value allow |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | AC-33 relocating-spelling and quoted-mention cases |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `$script:SharedModuleNames` registration, byte-identity parity, line cap |

## Appendix B: Toolchain Commands Reference

Commands this reviewer executed (all check-only, no mutation of source or policy):

```bash
# Baseline
git diff --stat 6dff80ed..85a3c344
git log --oneline 6dff80ed..85a3c344
git status --porcelain
git diff --name-only 6dff80ed..85a3c344

# Coverage-measurement drift checks
git diff --name-only 5903d0c7 85a3c344 -- '.claude/hooks/*.ps1' '.codex/hooks/*.ps1' \
    'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
git diff --name-only 3b4f10b9..85a3c344

# Canonical/bundle byte parity (18 pairs) and cross-runtime parser identity
cmp -s .claude/hooks/<f> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<f>
cmp -s .codex/hooks/<f>  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<f>
cmp -s .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1
cmp -s scripts/powershell/PoshQC/settings/pester.runsettings.psd1 \
       extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1

# Evidence locations
python scripts/dev_tools/validate_evidence_locations.py --root .        # exit 0, no output

# Evidence artifacts parsed directly (no re-run)
artifacts/pester/pester-junit.xml            # 99 suites, 2381 cases, 2 failures, 0 errors
artifacts/pester/powershell-coverage.xml     # package-qualified LINE counters; no BRANCH counter exists
```

Commands NOT run, with reasons:

```
# Refused by the session runtime guard - no PowerShell host is invocable in this worktree
pwsh -NoProfile -Command "Invoke-Pester ..."
Invoke-Formatter / Invoke-ScriptAnalyzer

# Not exposed to this agent
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test
mcp__drm-copilot__resolve_policy_audit_template_asset

# Not installed in this session (pr_context.summary.txt records the same)
gh run view 34158596238
```
