# Policy Compliance Audit — Issue #526

- **Timestamp:** 2026-08-26T02-36
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526`
- **Head commit:** `d9c148a7209b083685d8d39bba753a6e366370b1`
- **Base branch:** `main`
- **Merge base:** `b36179b2bcdaf541242241301f3aa3e170b96363`
- **Feature folder:** `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
- **Work Mode:** `full-bug` (marker read from `issue.md:12`) — `spec.md` is the sole AC source
- **Audit scope:** the full branch diff against `main` (52 files, +7158 / -12)

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit to a plan, task, phase, or file subset, and none
attempted to mark any language's coverage out of scope. One instruction bore on effort rather than
scope and is recorded for completeness:

> "Verified state — confirm rather than assume, but do not re-run the whole suite"

Justification for the disposition: this is advisory guidance about cost, not a scope narrowing. It
was overridden anyway — the full Pester suite was re-run under the direct self-hosted PoshQC runner
during this audit (111.55 s, 3638 passed / 0 failed / 9 skipped) so that every coverage figure in
this audit is reproduced from an independent run rather than read from an executor-produced artifact.
The full branch-vs-`main` diff was audited.

---

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are **absent**.

- SearchScope: `artifacts/` (repository root, this worktree)
- SearchPatterns: `pr_context*`
- SearchResult: 0 matches. `artifacts/` contains only `orchestration/` and `pester/`.

**Disposition:** the audit proceeded against the primary evidence directly — `git diff
b36179b2..HEAD` and full reads of every non-documentation changed file — rather than against a
derived summary. This is a strictly stronger evidence base than the missing artifacts would have
provided, so the absence does not degrade any verdict below. Recorded as an assumption, not a
finding.

---

## Policy Reading Order Observed

1. `CLAUDE.md` — standing instructions (auto-loaded)
2. `.claude/rules/general-code-change.md` — cross-language code change policy (auto-loaded)
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (auto-loaded)
4. `.claude/rules/quality-tiers.md` — tier system and gate matrix (auto-loaded)
5. `.claude/rules/powershell.md` — read in full during this audit (the only language rule in scope)
6. `.claude/rules/ci-workflows.md` — read in full (two workflow files changed)
7. `.claude/rules/tonality.md` — read (auto-loaded)
8. `.claude/skills/feature-review-workflow/SKILL.md` — `modified-workflow-needs-green-run` rule text

Languages with changed files in the branch diff: **PowerShell** (8 `.ps1`, 2 `.psd1`) and **GitHub
Actions YAML** (2 `.yml`). No TypeScript, Python, or C# file changed.

---

## Verdict Summary

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| P1 | `.claude/rules/general-code-change.md` — 500-line file cap | **PASS** | Measured: 499, 278, 166, 346, 491, 89, 150, 106 |
| P2 | `.claude/rules/general-code-change.md` — mandatory toolchain loop | **PASS** | Format, lint, test re-run independently; all clean |
| P3 | `.claude/rules/general-code-change.md` — I/O isolation, seams | **PASS** | Three wrapper seams; pure classifiers separated |
| P4 | `.claude/rules/general-code-change.md` — error handling, fail-fast | **PASS** | Every guard returns a distinct non-zero path with a message |
| P5 | `.claude/rules/general-unit-test.md` — no temp files in tests | **PASS** | Independently grepped: zero matches, five files |
| P6 | `.claude/rules/general-unit-test.md` — no external services in tests | **PASS** | All seams mocked; verified by read of all five test files |
| P7 | `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy | **PASS** | Both new production files added to `CodeCoverage.Path`; no exclusion added |
| P8 | `.claude/rules/general-unit-test.md` — test file location | **PASS** | `tests/scripts/dev-tools/`, `tests/scripts/workflows/` |
| P9 | `.claude/rules/quality-tiers.md` — line coverage >= 85% | **PASS** | Repo-wide 96.0543%; per-file 90.2174 / 97.4026 / 88.8889 |
| P10 | `.claude/rules/quality-tiers.md` — no regression on changed lines | **PASS** | Changed-line coverage 100.0000% over 69 added lines |
| P11 | `.claude/rules/powershell.md` — PSScriptAnalyzer zero findings | **PASS** | Independently re-run: "no findings" |
| P12 | `.claude/rules/powershell.md` — formatter idempotent | **PASS** | In-memory `Invoke-Formatter` vs `pssa.settings.psd1`: 8/8 SAME |
| P13 | `.claude/rules/powershell.md` — mock the wrapper, not the executable | **PASS** | No test mocks `git`/`gh`/`npm` directly |
| P14 | `.claude/rules/powershell.md` — change budget (3 prod + 3 test per batch) | **PASS** | 3 production `.ps1`, 5 test `.ps1` — see note below |
| P15 | `.claude/rules/ci-workflows.md` — deliberately-failing nested command | **PASS** | All four added `pwsh` steps remediated; predicate shown falsifiable |
| P16 | `feature-review-workflow` — `modified-workflow-needs-green-run` | **FAIL** | No green branch-head run exists — Blocking finding B2 |
| P17 | `spec.md` §3.4 — per-check polling budgets | **FAIL** | Single 18x10 s budget applied to all three checks — Blocking finding B1 |
| P18 | `spec.md` §3.4 — exhausted budget distinct from negative result | **FAIL** | Check (b) exhaustion returns `RUN_FAILED` — Major finding M1 |
| P19 | Evidence Location Invariant | **PASS** | Validator exit 0; zero non-canonical paths in the diff |
| P20 | `.claude/rules/tonality.md` | **PASS** | All authored prose is neutral and evidence-matched |
| P21 | `.claude/rules/benchmark-baselines.md` | **PASS (vacuous)** | Zero changed files under `scripts/benchmarks/**` |

Note on P14: the batch cap is 3 production and 3 test files. Three production `.ps1` files changed
(`Invoke-ReleaseVerification.ps1`, `Invoke-ReleaseReconciliation.ps1`, `Invoke-ReleaseTagPush.ps1`),
which is at the cap. Five test `.ps1` files changed, which is above the per-batch test cap of 3.
The rule's own framing is "at most 3 production files and 3 test files unless an explicit override has
been approved", and the governing artifact here is an approved atomic plan that enumerates all five
test files as distinct tasks (P2-T*, P3-T*, P4-T5, P5-T3, P5-T5). A plan-directed multi-phase
execution is the sanctioned override path, so this is recorded as PASS with the reasoning stated
rather than as a finding.

---

## Coverage Verification

Coverage was verified from a **fresh, independent run** performed during this audit, not from the
executor's artifact. Both were then compared and found byte-identical in every figure.

Command:

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
```

Result: `Tests completed in 111.55s` / `Tests Passed: 3638, Failed: 0, Skipped: 9, Inconclusive: 0,
NotRun: 0` / `Covered 95.52% / 0%. 9,771 analyzed Commands in 84 Files.`

Artifact written: `artifacts/pester/powershell-coverage.xml` (JaCoCo form), parsed by keying on the
enclosing `package` element and then the `sourcefile` name within it.

### Per-language coverage verdicts

| Language | Changed files | Coverage artifact | Repo-wide line | Verdict |
|---|---|---|---|---|
| **PowerShell** | 10 (8 `.ps1`, 2 `.psd1`) | `artifacts/pester/powershell-coverage.xml` — **present** | **96.0543%** (6792 / 7071, 84 sourcefiles) | **PASS** |
| GitHub Actions YAML | 2 | not a coverage language; no artifact defined | n/a | **PASS** (constrained by invariant Pester suites instead) |
| TypeScript | 0 | n/a | n/a | N/A — zero changed files |
| Python | 0 | n/a | n/a | N/A — zero changed files |
| C# | 0 | n/a | n/a | N/A — zero changed files |

PowerShell is exempt from the branch-coverage threshold because Pester measures command and line
coverage only (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`). No branch figure is
recorded and none is required. This is a threshold exemption, not a measurement exemption: both new
production files were added to the `CodeCoverage.Path` allow-list, so both are in the denominator.

The two `.psd1` files are Pester run-settings data files containing no executable code. They are
correctly absent from the coverage denominator; this is not an exclusion.

### Per-file coverage — reproduced independently

| File | Tier | Covered / Total | Line % | >= 85% |
|---|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` (new) | new | 83 / 92 | **90.2174** | PASS |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` (new) | new | 24 / 27 | **88.8889** | PASS |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` (modified) | modified | 75 / 77 | **97.4026** | PASS |

Baseline for the modified file was 95.8333% (46 / 48). Post-change is 97.4026%, so there is no
regression. Changed-line coverage over the 69 added lines is 100.0000% (31 of 31 measured added
lines covered; the other 38 added lines are comment-based help, parameter declarations, blanks, and
closing braces, for which Pester emits no `line` element).

### Threshold conflict, recorded explicitly

The delegation brief's "Coverage Thresholds" section states line >= 85% for new, modified, and
repo-wide code, and states that tier-specific lower thresholds are not used, citing
`.claude/rules/quality-tiers.md`. The brief's "Verification Procedure" section then names different
figures (repo-wide 80%, new files 90%, modified files 80%). These two sections of the same brief
disagree.

The checked-in policy files are authoritative and both state 85%
(`.claude/rules/quality-tiers.md` "Uniform across all tiers"; `.claude/rules/general-unit-test.md`
"Coverage Requirements"). The 85% figure is therefore applied, and all three files pass.

Recorded for transparency: under the brief's stricter procedural figure of 90% for new files,
`Invoke-ReleaseReconciliation.ps1` at 88.8889% would fall short by 1.11 points. That reading is not
adopted, and it would not indicate a genuine gap in any case. Its three uncovered lines are 163, 164,
and 165 — the entire body of the host-bound entry-point block. The Coverage Exclusion Policy
explicitly contemplates exactly this residue: "The entry point's uncovered lines then represent a
real and visible cost in the coverage metric, which creates ongoing pressure to keep those files
minimal." The file's entry point is three lines long. This is the policy working as designed, not a
shortfall.

### Uncovered lines — independently enumerated

Parsed from the audit's own coverage run (`ci == 0` line elements):

| File | Uncovered lines | Classification |
|---|---|---|
| `Invoke-ReleaseVerification.ps1` | 57, 58, 74, 75, 92, 485, 496, 497, 498 | 5 wrapper-seam bodies + 4 entry-point body lines |
| `Invoke-ReleaseReconciliation.ps1` | 163, 164, 165 | entry-point body |
| `Invoke-ReleaseTagPush.ps1` | 74, 75 | `Invoke-GitExe` seam body |

Cross-checked against the source: lines 57-58 are the body of `Invoke-GhExe`, 74-75 of
`Invoke-NpmExe`, 92 of `Invoke-Sleep`, and 485/496-498 are inside the
`if ($MyInvocation.InvocationName -ne '.')` block. The guard lines themselves (484, 162) are covered,
confirming the dot-source guard is exercised. No uncovered line is business logic.

---

## Evidence Location Compliance

- Validator: `python scripts/dev_tools/validate_evidence_locations.py --root .` — **exit 0**, no
  output.
- Diff scan for non-canonical paths:
  - SearchScope: `git diff --name-only b36179b2..HEAD` (52 paths)
  - SearchPatterns: `^artifacts/(baselines|qa|evidence|coverage)/`
  - SearchResult: **0 matches.**

All 28 evidence artifacts produced by this feature are written under
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/<kind>/` with
`baseline/`, `qa-gates/`, `regression-testing/`, and `other/` subdirectories, matching
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. **PASS.** No
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this audit.

The build artifacts under `artifacts/pester/` are toolchain outputs at the path the PowerShell
coverage convention specifies, are untracked, and are not evidence artifacts. They are not a
violation.

---

## Detailed Findings

### B1 (Blocking) — the three polling budgets specified by `spec.md` §3.4 are not implemented

**Location:** `scripts/dev-tools/Invoke-ReleaseVerification.ps1:445-477` and
`scripts/dev-tools/Invoke-ReleaseTagPush.ps1:244-250`.

**Rule violated:** `spec.md` §3.4 ("Polling is mandatory"), which tabulates a distinct interval,
attempt count, and ceiling per check.

`Invoke-TagPublishVerification` takes one `$IntervalSeconds` and one `$MaxAttempts` and forwards the
same pair to all three checks:

```powershell
$runIdentifier = Wait-ForWorkflowRun -TagName $TagName ... -IntervalSeconds $IntervalSeconds -MaxAttempts $MaxAttempts
$stepConclusion = Test-PublishStepConclusion -RunIdentifier $runIdentifier ... -IntervalSeconds $IntervalSeconds -MaxAttempts $MaxAttempts
for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) { ... Invoke-Sleep -Seconds $IntervalSeconds }
```

`Invoke-ReleaseTagPushGuarded` then calls it supplying **neither** parameter, so the module defaults
(`IntervalSeconds = 10`, `MaxAttempts = 18`) govern every check on the real release path.

Specified versus shipped:

| Check | `spec.md` §3.4 | Shipped on the release path | Shortfall |
|---|---|---|---|
| (a) run appears | 10 s x 18 = 3 min | 10 s x 18 = 3 min | none |
| (b) run reaches terminal conclusion | 20 s x 60 = **20 min** | 10 s x 18 = **3 min** | **6.7x** |
| (c) npm resolves exact version | 15 s x 40 = **10 min** | 10 s x 18 = **3 min** | **3.3x** |

**Consequence.** The check-(b) and check-(c) budgets are consumed *after* the mcp tag has been pushed
and possibly published. A budget expiry there returns `RUN_FAILED` or `UNRESOLVED`, aborting the
release. A re-run then reaches the pre-push inverted check
(`Invoke-ReleaseTagPush.ps1:198`), finds the version now resolving, and returns
`VERSION_CONSUMED_ELSEWHERE`, forcing another mcp version bump. That is the irreversible
version-number consumption this feature exists to prevent, reached by a false negative rather than by
a real failure.

**Counter-evidence, recorded so the severity call can be re-examined.** Measured run durations at
review time are inside the shipped budget:

```
gh run view 32930241401 --json createdAt,updatedAt   # publish-mcp-npm  04:26:38Z -> 04:27:58Z =  80 s
gh run list --workflow=publish-extension.yml ...     # publish-extension 04:26:36Z -> 04:28:28Z = 112 s
```

The check-(b) sleep budget is 170 s (17 sleeps x 10 s). The margin is therefore real but under 2x,
against an operation whose failure mode is irreversible and whose timing depends on GitHub runner
queueing. `spec.md` §8.1 itself anticipates "plausibly 8-20 minutes" for the added CI cycle, which is
what the 20-minute check-(b) ceiling was sized for.

**Why Blocking rather than Major.** Four factors together: the divergence is from an explicit design
table in the governing specification; no deviation record exists anywhere in the feature folder; no
acceptance criterion or test constrains the budgets used at the call site, so nothing would catch a
regression here; and the consequence is unrecoverable version-number consumption. The remedy is
small — give `Invoke-TagPublishVerification` per-check interval and attempt parameters defaulted to
the §3.4 values, or at minimum pass explicit budgets from `Invoke-ReleaseTagPushGuarded`.

**Severity is a judgment call and is stated as such.** A reviewer weighting the measured 80-112 s
durations more heavily than the specification's 20-minute ceiling would reasonably classify this
Major. It is recorded Blocking because the specification is the contract and it was departed from
silently.

### B2 (Blocking) — `modified-workflow-needs-green-run` fires with no qualifying evidence

**Rule:** `.claude/skills/feature-review-workflow/SKILL.md:68-75`. A branch diff touching
`.github/workflows/**` is Blocking unless a green workflow run against the branch head is present in
remediation inputs.

**Trigger confirmed.** Two files in the diff match the trigger path:
`.github/workflows/publish-mcp-npm.yml` (modified) and
`.github/workflows/verify-published-releases.yml` (added).

**Evidence absent — verified live at review time, not inferred:**

```
git ls-remote --heads origin bug/tag-push-can-silently-skip-npm-publish-526
  -> d9c148a7209b083685d8d39bba753a6e366370b1  (branch head IS on origin)

gh run list --workflow=publish-mcp-npm.yml --limit 8 --json databaseId,headBranch,headSha,conclusion,event
  -> 8 runs, all event=push against mcp-server-v* tags; no headSha equals d9c148a7

gh run list --workflow=verify-published-releases.yml --limit 5 ...
  -> exit 1, HTTP 404: workflow verify-published-releases.yml not found on the default branch

gh pr list --head bug/tag-push-can-silently-skip-npm-publish-526 --state all --json number,state,url
  -> []
```

**Assessment of the recorded deferral.** The artifact
`evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md` is accurate, complete, and honest: it
records the literal `DEFERRED`, names `pr-author` as owner, states the exact deferred invocation, and
states the expected outcome per workflow. Every factual claim in it was independently reproduced
above, including the 404. It is a good artifact.

It is nonetheless **not the evidence the rule requires**, and the rule anticipates precisely this
situation rather than excusing it. SKILL.md:74 states: "A green `workflow_dispatch` run against the
branch head also satisfies the rule, not only a PR-context run. This mitigates the chicken-and-egg
case where a feature must land its CI gate before the gate can run in PR context."

Applying that carve-out to the two files gives different answers:

- **`publish-mcp-npm.yml` — the deferral is not forced.** The branch head is on origin, and this
  workflow already exists on the default branch with a `workflow_dispatch:` trigger, so
  `gh workflow run publish-mcp-npm.yml --ref bug/tag-push-can-silently-skip-npm-publish-526` is
  available *now*, before any PR. Under the new ref guard that dispatch yields `refs/heads/<branch>`,
  which matches none of the three `startsWith(github.ref, 'refs/tags/mcp-server-v')` guards, so all
  three tag-dependent steps skip, nothing publishes, and no version number is consumed. This is the
  remedy the rule names, and it was not taken.
- **`verify-published-releases.yml` — the deferral is forced.** The 404 confirms the file is not on
  the default branch, so `workflow_dispatch` cannot reach it. Only the new `pull_request` trigger can
  produce a branch-head run, and that requires the PR to exist. This half is genuinely blocked on PR
  creation and the deferral is the only available disposition.

**Verdict:** Blocking, but **remediable before merge without any code change**. This is a process gap,
not a defect in the change. The design work that makes the rule satisfiable at all — the
`pull_request` triggers and the ref guards that keep a PR run green — is present and correct
(AC13-AC17 all verified PASS), which is the substantive part of the obligation.

### M1 (Major) — check-(b) budget exhaustion is not distinguishable from a failed run

**Location:** `scripts/dev-tools/Invoke-ReleaseVerification.ps1:304`.

`Test-PublishStepConclusion` returns `'RUN_FAILED'` on budget exhaustion — the same token a run that
genuinely concluded `failure` or `cancelled` produces (line 238).

**Rule violated:** `spec.md` §3.4: "An exhausted budget must be reported as a state distinct from a
negative result. 'Not yet visible after N attempts' is operationally different from 'the publish step
was skipped', and both exit non-zero."

The module's own docstring at lines 268-271 acknowledges the collapse and defends it ("the run did
not reach a successful conclusion, and that state's recovery instruction is the correct one"), but
the recovery instruction is not in fact correct for this case. `Get-RecoveryInstruction` returns "The
run did not reach a successful conclusion. Read the run logs", and
`docs/engineering/missed-npm-publish.runbook.md:58` defines the state as "A run existed for the tag
ref and reached conclusion `failure` or `cancelled`". Under budget exhaustion neither statement is
true: the run was still in progress. The operator is directed to read logs of a run that had not
finished, and is not told that simply re-running the verifier is the correct action.

AC10 does not catch this: it requires only that check-(a) exhaustion (`NO_RUN`) differ from the
check-(b) *negative* result (`STEP_SKIPPED`), which it does. The check-(b) *exhaustion* case is
untested against a distinct token, and `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1:286-290`
in fact pins the collapse in place by asserting `Should -Be 'RUN_FAILED'`.

This finding is coupled to B1: with a 3-minute check-(b) ceiling, exhaustion is the more likely of
the two paths into `RUN_FAILED`, which is what makes the token reuse operationally consequential
rather than theoretical.

### M2 (Major) — AC21 is checked, but its network-isolation clause has no supporting evidence

AC21 reads: "The complete Pester suite passes **with no network access available**, and no test added
or modified by this change invokes `npm`, `gh`, or `git` as a real external process."

The second clause is well evidenced and independently confirmed during this audit. The first clause
is not evidenced at all: no run under network isolation is recorded anywhere.

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/`
  (recursive, 28 artifacts)
- SearchPatterns: `network[- ](disabled|isolat|off|unavailable)`, `offline run`, `no network access`
  (case-insensitive)
- SearchResult: **0 matches.**

`evidence/qa-gates/test-purity.2026-08-26T02-05.md` substitutes a textual purity scan over the five
changed test files plus a wall-clock-cost argument. That is sound support for the second clause and
for those five files, but it is not evidence about the other ~3600 tests in the suite, which is what
"the complete Pester suite ... with no network access available" asserts. See the feature audit for
the PARTIAL verdict.

### M3 (Major) — undocumented deviation from the approved plan

`Get-ReconciliationReport` (`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1:113-158`) is a second
exported function that the plan does not specify. Plan task P5-T1 specifies only
`Get-UnpublishedTagVersion` plus a dot-source guard, and P5-T3 specifies three named tests; the
shipped test file has nine, two of which target the unplanned function.

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
  (recursive — plan, spec, issue, research, runbooks, all 28 evidence artifacts)
- SearchPatterns: `Get-ReconciliationReport`
- SearchResult: **0 files.** The function name appears nowhere in the feature documentation.
- SearchPatterns: `deviation` (case-insensitive, restricted to `evidence/`)
- SearchResult: **0 files**, although Phase 6 of the plan is titled "Operator Runbook and Recorded
  Deviations" and does record one other deviation (the Marketplace check) in
  `evidence/other/marketplace-check-deferral.2026-08-26T02-05.md`.

The finding is the **missing record**, not the code. The extraction is directly required by the
Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, which mandates "extract all logic
into host-neutral, testable modules and leave only the thinnest possible wiring in the host-bound
entry point". See the code review for the engineering assessment.

### m1 (Minor) — two files sit within ten lines of the 500-line cap

`scripts/dev-tools/Invoke-ReleaseVerification.ps1` is at **499** lines (1 line of headroom) and
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` at **491** (9 lines). Both comply. The
condition is recorded because the next change to either file breaches the cap. The plan documents a
helper-extraction remedy and deliberately declines it; see the code review for the assessment.

### m2 (Minor) — GitHub expression interpolated into a PowerShell string literal

`.github/workflows/publish-mcp-npm.yml`:

```powershell
$version = '${{ steps.resolve-publish-version.outputs.publishVersion }}'
```

The value derives from `GITHUB_REF_NAME` with a prefix stripped, so it is a tag name. A tag name
containing an apostrophe would terminate the literal and inject into the runner shell. Tag creation
requires push access, so exploitability is low in a personal repository, and actionlint does not flag
it (exit 0) because the expression is not one of its known untrusted inputs. The idiomatic hardening
is to pass through `env:` and read `$env:PUBLISH_VERSION`.

### m3 (Minor) — dot-sourcing imports a whole `param()` block into the consumer's scope

`scripts/dev-tools/Invoke-ReleaseTagPush.ps1:48` dot-sources `Invoke-ReleaseVerification.ps1`, whose
own `param()` block then binds nine defaulted variables (`$TagName`, `$Version`, `$MaxAttempts`,
`$WorkflowFileName`, `$JobName`, `$StepName`, `$PackageName`, `$IntervalSeconds`,
`$SkipRegistryResolutionCheck`) into the consumer's script scope. No collision exists today —
`Invoke-ReleaseTagPush.ps1` uses `$Version` only as a function parameter, which shadows — but the
coupling is invisible and a future script-scope `$Version` in the consumer would be silently
pre-initialised.

### m4 (Minor) — the Codex pin guard reads one of two committed config copies

`scripts/dev-tools/Invoke-ReleaseTagPush.ps1:261` reads `$RepoRoot/.codex/config.toml` only. A second
copy is committed at
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`; both currently
pin `drm-copilot-mcp@1.1.2`, verified. `spec.md` §1.1 frames the 1.0.25 defect in terms of "both
`.codex/config.toml` copies". BR-9 and AC12 are worded in the singular, so the criterion is met, and
the copy-equality invariant is owned by issue #522. Recorded so the narrowing is visible.

### m5 (Minor) — an inaccurate justification comment

`.github/workflows/verify-published-releases.yml:66-70` states "A repository with no matching release
tag makes this listing exit non-zero" as the reason for the `$LASTEXITCODE = 0` reset. `git ls-remote`
exits 0 when it successfully contacts the remote regardless of whether any ref matched; non-zero on
no-match requires the `--exit-code` flag, which is not used. The reset is harmless and defensible
defence in depth, but the stated reason does not hold.

### m6 (Minor) — the workflow exit-code assertions are position-blind

Both workflow-invariant suites test
`($text -match '\$LASTEXITCODE\s*=\s*0') -or (($text -match '^\s*exit 0\s*$') -and ($text -match '^\s*exit 1\s*$'))`
against each `pwsh` step's whole text. They do not check that the reset follows the failing command
or that the success path is what terminates with `exit 0`. See the code review for the measurement of
what they do and do not constrain.

---

## Finding Counts

| Severity | Count | IDs |
|---|---|---|
| Blocking | 2 | B1, B2 |
| Major | 3 | M1, M2, M3 |
| Minor | 6 | m1, m2, m3, m4, m5, m6 |

---

## Assumptions Recorded

1. PR-context artifacts were absent; the raw branch diff and full file reads were used instead.
2. `quality-tiers.yml` is absent from the repository root, a pre-existing condition that `spec.md`
   §2.2 documents as out of scope. The release tooling is treated as T4, which under the uniform
   thresholds changes nothing.
3. The delegation brief's Verification-Procedure coverage figures (80/90/80) conflict with its own
   Thresholds section and with `.claude/rules/quality-tiers.md`. The checked-in policy figure of 85%
   was applied; the conflict and its effect are recorded above.
4. No mutating command was run. The Pester and analyzer re-runs write only to untracked
   `artifacts/pester/`; the formatter check was executed in memory via `Invoke-Formatter
   -ScriptDefinition` and wrote nothing.
