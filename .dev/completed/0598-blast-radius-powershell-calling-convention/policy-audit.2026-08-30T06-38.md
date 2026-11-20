# Policy Audit — issue #598, blast-radius PowerShell calling convention

Timestamp: 2026-08-30T06-38
Reviewer: feature-review
Feature folder: `docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/`
Branch: `feature/blast-radius-powershell-calling-convention-598`
HEAD: `d26beb1e2aef67a3ed1e6f80ac55f69042ed00a5`
Resolved base: `epic/claude-runtime-portability-integration` at `6df3766490977346cf839658f483742856a5e448`
Work Mode: `full-bug` (read from `issue.md:12`); AC source is `spec.md` only.

## Scope resolution

The audit scope is the full branch diff against the resolved base branch. Two spans are reported
because the epic integration branch was merged into this branch mid-execution at
`f4d4f958808a5a420f11189f6fa02ee007a66525`.

| Span | Command | Result |
|---|---|---|
| Branch vs. resolved base | `git diff --name-only 6df37664..HEAD` | 122 paths |
| Feature-attributable set (FAS) | union of `main...6942dee8`, `f4d4f958..HEAD`, `git status --porcelain` | 143 paths |
| FAS `.psm1` | `grep -c '\.psm1$'` | 56 |
| FAS `.py` | `grep -c '\.py$'` | 0 |
| FAS `.Tests.ps1` | `grep -c '\.Tests\.ps1$'` | 2 |

Both spans were computed and both were audited. The full branch-vs-base diff was used for every
exclusion check (policy files, Feature C files, evidence locations) so that no merge-inherited
change could hide behind the attribution split. The FAS was used for authorship attribution so that
merge-inherited paths are not reported as this feature's work.

No scope narrowing was supplied by the caller. The caller supplied the attribution contract as a
correction to a `main`-anchored diff, which is a legitimate base-resolution refinement rather than a
narrowing: it does not exclude any language, file category, or gate. The full branch-vs-base diff was
audited regardless.

## Rejected Scope Narrowing

None. No caller instruction attempted to limit the audit to a plan, task, phase, file subset, or
language subset, and no instruction asserted that a language with changed files was out of scope.

## Language coverage verdicts

Languages with changed files in the branch diff:

| Language | Changed files | Coverage artifact | Repo-wide line coverage | Verdict |
|---|---|---|---|---|
| PowerShell | 58 (56 `.psm1`, 2 `.Tests.ps1`) | `artifacts/pester/powershell-coverage.xml` | 94.79% (7337 covered / 403 missed) | PASS |
| Python | 0 | n/a | n/a | Not applicable — zero changed files on branch |
| TypeScript | 0 | n/a | n/a | Not applicable — zero changed files on branch |
| C# | 0 | n/a | n/a | Not applicable — zero changed files on branch |

Python, TypeScript, and C# are recorded as not applicable on the basis of zero changed files in the
branch diff, which is the only condition under which that verdict is permitted.

Verification of the Python figure:

```
SearchScope: git diff --name-only 6df37664..HEAD ; union of main...6942dee8 and f4d4f958..HEAD
SearchPatterns: '\.py$'
SearchResult: 0 matches in both spans
```

### Coverage verification — PowerShell

Coverage was verified by inspecting the pre-existing artifact, not by rerunning generation.

Command:

```
pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); $c = @($x.report.counter) | Where-Object { $_.type -eq 'LINE' }; 'covered=' + $c.covered + ' missed=' + $c.missed"
```

Output:

```
covered=7337 missed=403
pct=94.79
files=88
```

Artifact mtime is `2026-08-30 02:19`, consistent with the `[P10-T3]` full-suite run recorded at
`2026-08-30T02-22`. The artifact is neither stale nor scoped to a partial suite: the recorded run
supplied no `-ScanFolders` argument and covers the full `Run.Path` of the repository runsettings.

- Repo-wide line coverage 94.79% >= 85%: **PASS**.
- Line-coverage delta versus post-merge baseline 94.78%: **+0.01**, non-negative.
- Missed line count is unchanged at 403 before and after, so no previously covered line became
  uncovered: **PASS** on the no-regression-on-changed-lines requirement, subject to Finding W1.
- Branch coverage: not evaluated. Pester measures command and line coverage only. Per
  `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, no PowerShell branch-coverage
  gate exists. An absent branch figure is not recorded as FAIL.

## Policy compliance results

Policy files were read in the order required by `CLAUDE.md` and
`.claude/skills/policy-compliance-order`: `CLAUDE.md`, `.claude/rules/general-code-change.md`,
`.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`,
`.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`.

| # | Policy requirement | Source | Verdict |
|---|---|---|---|
| 1 | Formatting stage passes | `.claude/rules/powershell.md` §Toolchain | PASS |
| 2 | Linting stage passes, zero findings | `.claude/rules/powershell.md` §Toolchain | PASS |
| 3 | Type checking | `.claude/rules/powershell.md` §Toolchain | Not applicable to PowerShell by policy |
| 4 | Unit tests pass | `.claude/rules/general-code-change.md` §Mandatory Toolchain Loop | PASS |
| 5 | Toolchain completes in a single pass | `.claude/rules/general-code-change.md` §Mandatory Toolchain Loop | PASS |
| 6 | No production file exceeds 500 lines | `.claude/rules/general-code-change.md` §File Size Limit | PASS |
| 7 | Line coverage >= 85% | `.claude/rules/quality-tiers.md` | PASS |
| 8 | Branch coverage >= 75% | `.claude/rules/quality-tiers.md` | Exempt — Pester measures no branch coverage |
| 9 | No coverage regression on changed lines | `.claude/rules/general-unit-test.md` | PARTIAL — see W1 |
| 10 | No production file excluded from coverage measurement | `.claude/rules/general-unit-test.md` §Coverage Exclusion Policy | PARTIAL — see W1 |
| 11 | Tests create no temporary files | `.claude/rules/general-unit-test.md` §External Dependencies | PASS |
| 12 | Tests have no external dependencies | `.claude/rules/general-unit-test.md` §External Dependencies | PASS |
| 13 | Tests are deterministic | `.claude/rules/general-unit-test.md` §Determinism Infrastructure | PASS |
| 14 | Test files live under `tests/` mirroring source | `.claude/rules/general-unit-test.md` §Test File Location | PASS |
| 15 | Arrange–Act–Assert structure | `.claude/rules/general-unit-test.md` §Test Structure | PASS |
| 16 | Policy documents unmodified | `.claude/skills/policy-compliance-order` §Hard Constraints | PASS |
| 17 | Evidence written to canonical locations | `.claude/skills/evidence-and-timestamp-conventions` | PASS |
| 18 | Evidence artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` | `.claude/skills/evidence-and-timestamp-conventions` | PARTIAL — see W7 |
| 19 | Tonality policy | `.claude/rules/tonality.md` | PASS |
| 20 | PowerShell 7+ compatibility | `.claude/rules/powershell.md` §Compatibility | PASS |
| 21 | No `Invoke-Expression`, secrets, or hard-coded credentials | `.claude/rules/powershell.md` §Coding Standards | PASS |

### Evidence for row 1 — formatting

`evidence/qa-gates/final-poshqc-format.2026-08-30T02-17.md` records `EXIT_CODE: 0`, `Formatted:` count
0, `Already formatted:` count 429, and identical `git status --porcelain` output before and after. No
file was rewritten, so no toolchain restart was required.

### Evidence for row 2 — linting

`evidence/qa-gates/final-poshqc-analyze.2026-08-30T02-18.md` records `EXIT_CODE: 0` and
`PSScriptAnalyzer passed: no findings`.

### Evidence for rows 4 and 5 — tests and single-pass

`evidence/qa-gates/final-pester-suite.2026-08-30T02-22.md` records `EXIT_CODE: 0` and
`Tests Passed: 3881, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` against a post-merge baseline
of 3873 passed / 9 skipped. The increase of exactly 8 corresponds to the 6 `It` blocks added by
`ClaudeLibModuleConvention.Tests.ps1` and the 2 added to `OrchestratorState.Tests.ps1`. Format,
analyze, and Pester ran in that order with no stage failing and no stage rewriting a file.

Independent re-verification by this review:

```
Invoke-Pester -Path './tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1'
  -> Tests Passed: 6, Failed: 0, Skipped: 0

Invoke-Pester -Path 'tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1'
  -> OS PASSED=48 FAILED=0

Invoke-Pester -Path 'tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1'
  -> VF PASSED=13 FAILED=0
```

### Evidence for row 6 — 500-line limit

Every `.psm1` under `.claude/lib` and its bundle mirror was measured by physical line count:

```
for f in $(find .claude/lib extensions/.../claude-customizations/.claude/lib -name '*.psm1' -type f); do
  awk 'END{print NR}' "$f"; done | sort -rn | head -3
```

Output:

```
500
500
499
```

The maximum is 500, reached by `.claude/lib/discovery-validation/DiscoveryValidation.psm1` and its
mirror. The policy caps a file at 500 lines and does not permit exceeding it; 500 is compliant. Seven
distinct modules sit at 490 or above, so headroom for future edits is limited but no limit is
breached.

### Evidence for rows 11–13 — test hygiene

`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` reads files with `Get-Content` only. It
creates no temporary file, starts no external process, reads no clock, performs no network access,
and does not branch on `$PSVersionTable`.

`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` supplies its checkpoint
fixture entirely in memory. `Set-CheckpointFixture` (lines 62–68) registers
`Mock -CommandName Test-Path` and `Mock -CommandName Get-Content` against module-scoped script
variables; no file is written to disk. The added date-coercion test uses a fixed literal instant
`2026-08-29T20:38:00Z` rather than a generated or current time, so the assertion is deterministic.

```
SearchScope: tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1, tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1
SearchPatterns: New-TemporaryFile, TestDrive, [System.IO.Path]::GetTempPath, Start-Process, Invoke-WebRequest, Get-Date, Start-Sleep
SearchResult: 0 matches
```

### Evidence for row 14 — test file location

Both test files live under `tests/scripts/claude-lib/`, mirroring the `.claude/lib/` production tree
and matching the location of the pre-existing suites for `orchestrator-state`, `blast-radius`, and
`discovery-validation`. No test file was placed in the production source tree.

### Evidence for row 16 — policy documents unmodified

```
git diff --name-only 6df37664..HEAD | grep -E '^(\.claude/rules/|\.github/instructions/|scripts/powershell/PoshQC/settings/)'
```

Output: empty. No policy document, no PSScriptAnalyzer settings file, and no Pester runsettings file
was modified on this branch relative to the resolved base.

## Evidence Location Compliance

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

Exit code 0, no output. No violations reported.

Independent scan of the branch diff for non-canonical evidence paths:

```
git diff --name-only 6df37664..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
```

Output: empty, count 0. The branch commits no path under `artifacts/` at all. All 40 evidence
artifacts are written under `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/`, which
are the canonical locations defined by
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

`artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` exist on disk as
untracked tool output. They are the output paths declared by
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and are not committed. They are tool
output, not evidence artifacts, and do not constitute an evidence-location violation.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none. No caller instruction supplied a non-canonical evidence
path.

## Findings

### W1 — Blocking-candidate: one production module sits outside the coverage denominator

Severity: **Warning (High)**. Escalates to **Blocking at the epic level**.

`.claude/lib/requirements/GeneratedDocumentCounters.psm1` is absent from `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. That key is an explicit per-file
allow-list, so an omitted file is measured not at 0% but not at all: it produces no coverage row and
sits entirely outside the denominator.

Violated rule: `.claude/rules/general-unit-test.md` §Coverage Exclusion Policy — "No production file
may be excluded from coverage measurement. Every production source file is in the denominator of the
coverage metric."

Verification:

```
grep -c "GeneratedDocumentCounters" scripts/powershell/PoshQC/settings/pester.runsettings.psd1
-> 0

pwsh -NoProfile -Command "<parse coverage xml, compare sourcefile names to .claude/lib/*.psm1>"
-> GDC present: 0
-> lib modules on disk: 28
-> lib modules NOT in coverage report: 1
-> GeneratedDocumentCounters.psm1
```

Exactly one of the 28 shared library modules is unmeasured. The other 27 are in the denominator.

Attribution — this determines the severity, and it was verified rather than assumed:

```
git cat-file -e "6df37664:.claude/lib/requirements/GeneratedDocumentCounters.psm1"
-> EXISTS_ON_BASE

git show "6df37664:scripts/powershell/PoshQC/settings/pester.runsettings.psd1" | grep -c "GeneratedDocumentCounters"
-> 0

git diff --name-only 6df37664..HEAD -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1
-> 0 paths
```

The module exists on the resolved base branch, is unregistered on the resolved base branch, and this
branch does not modify the runsettings file. The violation is therefore **pre-existing relative to
the PR base and was not introduced by this feature**.

This feature did modify the file. The diff versus base adds 12 lines: an 11-line module-level
comment-based-help block and one executable statement, `$ErrorActionPreference = 'Stop'`. Exactly one
added line is executable, and it is unmeasured. No line lost coverage, because the file had no
measured coverage before or after; the repo-wide missed count is unchanged at 403.

Assessment on the merits. The condition is a genuine, current violation of the Coverage Exclusion
Policy, and the runsettings file's own comments establish the repository's settled reading of that
policy — for example at lines 156–162, "CodeCoverage.Path is an explicit per-file allow-list, so
without this entry the new production module and the relocated already-measured lines would both sit
outside the coverage denominator, which the Coverage Exclusion Policy forbids." By that standard the
omission is not a technicality.

Recording it without remedying it is nonetheless the correct call for this feature, for three
reasons that are verifiable rather than rhetorical:

1. The defect is not this branch's. It arrived with the integration merge and is present on the base.
   Blocking this PR would not remove it from the epic.
2. Remedying it requires editing `pester.runsettings.psd1`, which `spec.md` places under
   "Out of scope / non-goals" and which cross-cutting acceptance criterion 16 requires to be
   unmodified. Editing it would fail that criterion.
3. The owner of the defect is the sibling epic work that introduced the module. The correct remedy is
   a one-line registration in the settings file, made by whoever owns it, not a scope expansion here.

The gap is documented candidly and accurately in `spec.md` §Execution deviations item 5, and in
tasks `[P0-T18]`, `[P10-T5]`, and `[P10-T11]`. The recorded description matches what this review
independently observed, including the correct statement that no line lost coverage.

Residual defect in the handling: `spec.md` §Rollout & Follow-up enumerates three items deliberately
not filed as issues, and this coverage gap is **not among them**. Deviation 5 states "The remedy is
left as a follow-up for the owner of that settings file" but no follow-up issue is referenced, and no
tracking identifier appears anywhere in the feature folder.

```
SearchScope: docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/**
SearchPatterns: GeneratedDocumentCounters.*(issue|#[0-9]+|follow-up issue|filed)
SearchResult: no issue number associated with the coverage-registration remedy
```

Required action: file a follow-up issue against the epic to register
`.claude/lib/requirements/GeneratedDocumentCounters.psm1` in `CodeCoverage.Path`. The epic must not
merge to `main` with a production module outside the coverage denominator.

### W2 — anti-vacuity assertion uses a floor of zero rather than a count

Severity: **Warning (Medium)**.

`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1:50` asserts
`$discovered.Count | Should -BeGreaterThan 0`. This detects a total discovery failure but not a
partial one. If discovery returned 1 module instead of 28, all six `It` blocks would still pass while
asserting over 1/28th of the surface.

Violated rule: none directly. This is a robustness observation against
`.claude/rules/general-unit-test.md` §Scenario Completeness. The criterion in `spec.md` specifies
"greater than zero" literally, so the test satisfies the criterion as written.

Recommendation: assert a floor consistent with the known module count, or assert equality against a
count derived independently of the same `Get-ChildItem` call.

### W3 — caller-preference non-leakage test samples a single module

Severity: **Warning (Low)**.

`ClaudeLibModuleConvention.Tests.ps1:113` selects `$script:DiscoveredModule[0]` and imports only that
module. A preference leak introduced in any of the other 27 modules would not be detected.

The acceptance criterion is written in the singular — "the caller-scope `$ErrorActionPreference` after
importing a guarded module" — so the test satisfies it as specified. The risk is low because all 28
guard lines are byte-identical and none uses `$global:` scope:

```
grep -rhn "ErrorActionPreference" --include='*.psm1' .claude/lib | sed 's/^[0-9]*://' | sort | uniq -c
-> 28 $ErrorActionPreference = 'Stop'
```

Recommendation: iterate the discovered list rather than sampling index 0.

### W4 — imported module is not removed after the non-leakage test

Severity: **Warning (Low)**.

`ClaudeLibModuleConvention.Tests.ps1:116` runs `Import-Module -Name $module.FullName -Force` with no
matching `Remove-Module` in an `AfterAll` block. The module remains loaded in the session for the
remainder of the run.

Violated rule: `.claude/rules/general-unit-test.md` §Core Principles, item 1 (Independence) — tests
must run in any order without impacting each other.

Impact is low: the module imported is the first by sorted full name, the import is idempotent under
`-Force`, and the full-suite run reports zero failures. The concern is a shared-runspace side effect
that could surface if another suite later asserts on loaded-module state.

### W5 — acceptance criterion 14 states counts the execution superseded

Severity: **Warning (Low)**.

Cross-cutting criterion 14 in `spec.md:657-660` states "all 54 production files (27 repository
modules and 27 mirrors)". The executed figure is 56 production files across 28 pairs, because the
integration merge added a 28th module.

The operative clause of the criterion — that every edited `.claude/**` file has the identical edit in
its counterpart — is count-independent and is satisfied at 28 pairs. The substitution is recorded in
`spec.md` §Execution deviations item 3 and reconciled path by path in
`evidence/qa-gates/spec-acceptance-reconciliation.2026-08-30T02-36.md` row 14. The decision to leave
the criterion text unrewritten in order to preserve the audit trail is defensible and is stated
explicitly.

This is recorded so that a reader comparing the criterion text against the delivered artifact is not
misled by the stale parenthetical.

### W6 — recorded change-set count has drifted from the artifact figure

Severity: **Advisory**.

`evidence/qa-gates/final-change-set.2026-08-30T02-33.md` records `FAS` as 140 paths. Recomputing the
same three spans at HEAD yields 143.

The cause is benign and was verified. At the time the artifact was written, span 2 held 77 committed
paths and span 3 held 12 uncommitted paths. Commit `d26beb1e` at 02:30 committed those 12 and added
the evidence artifacts written after 02:33, moving span 2 to 91 and the union to 143. The three
additional paths are all Markdown evidence and spec documents; the artifact partly counts itself.

The material counts are unchanged and were independently reconfirmed:

```
psm1=56 py=0 tests=2 total=143
```

No action required. The artifact is a correct point-in-time record.

### W7 — five evidence artifacts carry inaccurate, non-monotonic timestamps

Severity: **Warning (Medium)**.

The `Timestamp:` field and filename stamp of five artifacts precede their actual write time by
approximately 80 minutes, and are out of order relative to the batches that ran before them.

| Artifact | Recorded `Timestamp:` | File mtime |
|---|---|---|
| `batch-B23-gate.2026-08-30T01-30.md` | 2026-08-30T01-30 | 01:18:36 |
| `batch-B24-gate.2026-08-30T01-38.md` | 2026-08-30T01-38 | 01:24:51 |
| `batch-B25-gate.2026-08-30T00-10.md` | 2026-08-30T00-10 | 01:34:09 |
| `batch-B26-gate.2026-08-30T00-18.md` | 2026-08-30T00-18 | 01:40:46 |
| `batch-B27-gate.2026-08-30T00-25.md` | 2026-08-30T00-25 | 01:47:06 |
| `batch-B28-gate.2026-08-30T00-33.md` | 2026-08-30T00-33 | 01:53:56 |
| `rollout-complete.2026-08-30T00-38.md` | 2026-08-30T00-38 | 01:54:40 |

Batches B25 through B28 and `rollout-complete` are stamped earlier than B24, which demonstrably ran
before them. The recorded sequence therefore misrepresents execution order.

Violated rule: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — the `Timestamp:` field
records when the evidence was produced.

The final gate artifacts are accurate to within a few minutes and are correctly monotonic:

| Artifact | Recorded | mtime |
|---|---|---|
| `final-pester-suite.2026-08-30T02-22.md` | 02-22 | 02:21:48 |
| `final-line-coverage.2026-08-30T02-24.md` | 02-24 | 02:22:09 |
| `final-change-set.2026-08-30T02-33.md` | 02-33 | 02:26:40 |

Impact on gate outcomes: none. The verdicts rest on recorded commands, exit codes, and outputs, and
every material figure in the final gates was independently reconfirmed by this review. The defect is
confined to the audit trail's ordering fidelity.

## Verdict summary

- Blocking findings: **0**
- Warnings: **6** (W1 High, W2 Medium, W7 Medium, W3 Low, W4 Low, W5 Low)
- Advisory: **1** (W6)

The mandatory PowerShell toolchain completed in a single pass with zero failures. Coverage is
94.79% against an 85% threshold with a non-negative delta. No policy document, analyzer setting, or
runsettings file was modified. No evidence-location violation exists. The single material policy gap
is W1, which was verified to be inherited from the PR base rather than introduced by this branch.
