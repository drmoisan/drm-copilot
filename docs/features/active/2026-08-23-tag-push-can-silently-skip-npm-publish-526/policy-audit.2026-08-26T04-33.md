# Policy Audit — Issue #526 (Cycle-1 REAUDIT)

- **Timestamp:** 2026-08-26T04-33
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `515b4d97`
- **Base:** `main` @ merge base `b36179b2bcdaf541242241301f3aa3e170b96363`
- **Work Mode:** `full-bug` — `spec.md` is the sole acceptance-criteria source
- **Prior cycle artifacts:** `policy-audit.2026-08-26T02-36.md`, `code-review.2026-08-26T02-36.md`,
  `feature-audit.2026-08-26T02-36.md`, `remediation-inputs.2026-08-26T02-36.md`
- **Prior finding counts:** Blocking 2, Major 3, Minor 6

## Verdict Summary

| Severity | Count |
|---|---|
| **Blocking** | **0** |
| Major | 1 |
| Minor | 10 |

`blocking_count == 0`.

---

## Scope

The audit scope is the full branch diff against the resolved base branch `main` at merge base
`b36179b2`. It is not the scope of the remediation plan, and it is not a subset of changed files.

### Rejected Scope Narrowing

None. The caller prompt supplied the full-branch base (`main`), directed re-evaluation of all 30
acceptance criteria, and explicitly required reading the actual diff rather than the summary. No
narrowing instruction was present and none was rejected.

The caller's single scope exclusion — "`testResults.xml` at the repository root is a tracked Pester
run artifact the suite rewrites on every invocation; ignore it" — was verified rather than accepted:
`git status --short` after a full suite run returned empty output, so the file is not modified by the
run in this worktree and is absent from the branch diff. The instruction is therefore vacuous, not a
narrowing.

### Changed-file language census

```
git diff --name-only b36179b2..HEAD | sed 's/.*\.//' | sort | uniq -c
     70 md
     10 ps1
      2 psd1
      2 yml
```

```
git diff --name-only b36179b2..HEAD -- '*.ts' '*.tsx' '*.py' '*.cs' '*.js'
(no output)
```

Languages with changed files: **PowerShell only**. TypeScript, Python, and C# have zero changed
files on this branch.

---

## Coverage Verification

Coverage was verified by re-executing the self-hosted PoshQC runner and parsing the resulting
JaCoCo artifact directly. The MCP test runner was deliberately not used: it resolves its Pester
runsettings from the installed VS Code extension bundle, which carries no `CodeCoverage.Path` entry
for the newly registered `Invoke-ReleaseVerificationHelpers.ps1` and therefore emits no row for it.

**Command:**
```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
```
Exit code 0. `Tests Passed: 3646, Failed: 0, Skipped: 9`. Completed in 112.49 s.

**Artifact parsed:** `artifacts/pester/powershell-coverage.xml` (85 sourcefiles).

| Metric | Independently measured | Recorded by executor | Match |
|---|---|---|---|
| Repo-wide line coverage | **6794 / 7073 = 96.0554 %** | 96.0554 % | exact |
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | **56 / 65 = 86.1538 %** | 86.15 % | exact |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | **29 / 29 = 100.0000 %** | 100 % | exact |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | **75 / 77 = 97.4026 %** | 97.40 % | exact |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | **24 / 27 = 88.8889 %** | 88.89 % | exact |

**Changed-line coverage** (added lines on the branch, intersected with the measured line set):

| File | Added | Measured | Covered | Changed-line coverage | Uncovered |
|---|---|---|---|---|---|
| `Invoke-ReleaseVerification.ps1` | 421 | 65 | 56 | 86.15 % | 69, 70, 86, 87, 104, 403, 418, 419, 420 |
| `Invoke-ReleaseVerificationHelpers.ps1` | 156 | 29 | 29 | **100.00 %** | none |
| `Invoke-ReleaseTagPush.ps1` | 69 | 31 | 31 | **100.00 %** | none |
| `Invoke-ReleaseReconciliation.ps1` | 166 | 27 | 24 | 88.89 % | 163, 164, 165 |
| **Total** | | **152** | **140** | **92.11 %** | |

Every uncovered line was classified against the source and confirmed to be either a wrapper-seam body
(`Invoke-GhExe` 69-70, `Invoke-NpmExe` 86-87, `Invoke-Sleep` 104, `Invoke-GitExe` in tag-push) or a
dot-source-guarded host-bound entry-point block (403, 418-420; reconciliation 163-165). None is
production decision logic. This reproduces the executor's classification exactly.

### Coverage verdicts by language

| Language | Changed files | Coverage artifact | Verdict |
|---|---|---|---|
| **PowerShell** | 10 `.ps1` + 2 `.psd1` | `artifacts/pester/powershell-coverage.xml` present | **PASS** — repo-wide 96.0554 % >= 85 %; every new and modified production file >= 85 %; no regression on changed lines (31 of 31 changed measured lines in the one modified production file are covered) |
| TypeScript | 0 | n/a | N/A — zero changed files |
| Python | 0 | n/a | N/A — zero changed files |
| C# | 0 | n/a | N/A — zero changed files |

PowerShell branch coverage is not evaluated: Pester measures command and line coverage only, so no
branch percentage exists (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`). Its
absence is not recorded as a FAIL.

**No coverage exclusion was added.** Both new production files are registered in `CodeCoverage.Path`
in both copies of `pester.runsettings.psd1`, and the two copies are byte-identical
(`diff` exit 0). No path under a production source tree appears in any `exclude` list.

---

## Toolchain Re-execution

Every stage was re-executed by this review. Reported results were not inherited.

| Stage | Command | Result |
|---|---|---|
| Format | `Invoke-PoshQCFormat -Root .` | exit 0 — **413 files "Already formatted", zero auto-fixes**; `git status --short` empty afterwards |
| Lint | `Invoke-PoshQCAnalyze -Root .` | exit 0 — `PSScriptAnalyzer passed: no findings` |
| Type check | n/a | PowerShell is exempt per `.claude/rules/general-code-change.md` |
| Unit tests | `Invoke-PoshQCTest -Root .` | exit 0 — 3646 passed, 0 failed, 9 skipped |
| Workflow lint | `pwsh -File scripts/dev-tools/run-actionlint.ps1` | **exit 0** |
| Feature suites | `Invoke-Pester -Path ./tests/scripts/dev-tools/,./tests/scripts/workflows/` | 438 passed, 0 failed, 2 skipped |

All stages passed in a single consecutive pass with no auto-fix. **AC26 PASS.**

---

## Policy Rule Findings

### `modified-workflow-needs-green-run` — the prior B2

Rule text (`.claude/skills/feature-review-workflow/SKILL.md`): a diff under `.github/workflows/**`
is Blocking unless evidence of a green workflow run against the branch head is present. "Green
workflow run against the branch head" means a run whose head SHA matches the current branch head and
whose conclusion is success for the affected workflow. A green `workflow_dispatch` run against the
branch head also satisfies the rule.

Two workflow files are in the diff.

#### `publish-mcp-npm.yml` — **SATISFIED**

Independently verified, not accepted from the artifact:

```
gh run view 32946866360 --json databaseId,headBranch,headSha,event,conclusion,status,url,workflowName
{"conclusion":"success","databaseId":32946866360,"event":"workflow_dispatch",
 "headBranch":"bug/tag-push-can-silently-skip-npm-publish-526",
 "headSha":"5cb5224a6062213cf6694f16871b61dbf1759da2","status":"completed",
 "url":"https://github.com/drmoisan/drm-copilot/actions/runs/32946866360",
 "workflowName":"Publish MCP Server to npm"}
```

```
gh run view 32946866360 --json jobs  (Publish to npm job, abridged)
{"conclusion":"success","name":"Publish to npm","steps":[ ...
 {"c":"skipped","n":"Verify tag version matches the mcp-server manifest"},
 {"c":"skipped","n":"Publish to npm"},
 {"c":"skipped","n":"Verify the published version resolves on the registry"}, ... ]}
```

Conclusion `success`; all three tag-dependent steps observed `skipped`; no npm version consumed.
Every field in `evidence/qa-gates/branch-head-dispatch-run.2026-08-26T08-17.md` reproduces exactly.

**Head-SHA precision ruling.** The run's head SHA is `5cb5224a`; the current branch head is
`515b4d97`, one commit later. The rule is nonetheless **satisfied against the current head**, on
three grounds recorded here so the interpretation is explicit rather than assumed:

1. **The workflow-relevant tree state is provably identical.**
   ```
   git diff --stat 5cb5224a..515b4d97 -- .github/ scripts/ tests/ packages/ extensions/
   (no output; exit 0)

   git show --name-only --format="" 515b4d97
   docs/features/active/.../evidence/qa-gates/branch-head-dispatch-run.2026-08-26T08-17.md
   ```
   The delta is exactly one added Markdown evidence file. Every byte the workflow reads, executes, or
   depends on is unchanged, so a re-run at `515b4d97` is guaranteed to produce the identical result.
2. **A literal same-SHA reading is unsatisfiable by construction for a dispatch-based run.** The rule
   requires the evidence to be present in the remediation inputs, which means committing it; the
   commit advances the head and invalidates the SHA it just recorded. The loop does not terminate.
   A reading that can never be satisfied is not the operative reading.
3. **The residual is covered downstream by a mechanism guaranteed to fire.** The rule states it is a
   second line of defence "separate from and prior to the orchestrator's S9 CI green gate". The new
   `pull_request` trigger produces runs against the final head as soon as the PR opens, and S9
   observes them.

A re-dispatch at `515b4d97` is available (the head is on origin, confirmed by `git ls-remote`) and
would cost one CI cycle, but is **not required**. Recorded as an explicit reviewer ruling.

#### `verify-published-releases.yml` — **NOT SATISFIED, forced deferral** (Major M1)

Independently reproduced:
```
gh run list --workflow=verify-published-releases.yml --limit 3
HTTP 404: workflow verify-published-releases.yml not found on the default branch
(https://api.github.com/repos/drmoisan/drm-copilot/actions/workflows/verify-published-releases.yml)
```

`workflow_dispatch` resolves workflows from the default branch. The file is new on this branch, so
the rule's own dispatch carve-out is unreachable and **no mechanism available at review time can
produce a green branch-head run for this file.**

This is recorded as **Major, not Blocking**, because a Blocking finding whose remediation is
impossible would deadlock the cycle without improving the change. The repository has accepted
precedent for exactly this case: `publish-extension.yml` carries a verbatim comment stating that its
pull-request trigger "provides the green branch-head run required by
modified-workflow-needs-green-run for a new tag-triggered workflow that cannot be dispatched before
it lands." The same remedy is present here (`verify-published-releases.yml:16-19`), and the sweep
step is gated off pull-request runs (`if: github.event_name != 'pull_request'`) so a PR run cannot
fail on a pre-existing divergence. Discharge is a merge-gate obligation on the PR-triggered run, not
a remediation-cycle obligation.

- **Discharge owner:** `pr-author` / orchestrator S9 CI monitoring.
- **Discharge command:** `gh run view <RUN_ID> --json conclusion,jobs` for the
  `pull_request`-triggered run of `verify-published-releases.yml` at the final head.
- **Expected:** conclusion `success`, sweep step `skipped`.

### `.claude/rules/ci-workflows.md` — deliberately-failing nested commands — **PASS**

Every `pwsh` step added by this change either resets `$LASTEXITCODE = 0` after an expected failure or
terminates with an explicit `exit 0` / `exit 1`:

- `publish-mcp-npm.yml:71-86` (version equality): `exit 1` on mismatch, `exit 0` on success.
- `publish-mcp-npm.yml:101-128` (registry poll): `$LASTEXITCODE = 0` at :115 after the expected
  E404, plus `exit 1` / `exit 0`.
- `verify-published-releases.yml:36-46` (offline validation): `exit 1` / `exit 0`.
- `verify-published-releases.yml:56-95` (sweep): `$LASTEXITCODE = 0` at :70 and :76, plus
  `exit 1` / `exit 0`.

Enforced locally by `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1:137-149` and
`VerifyPublishedReleasesWorkflow.Tests.ps1:93-105`. See Minor m6 for a residual weakness in those
assertions.

### `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy — **PASS**

No production path is excluded. Both new production files are added to `CodeCoverage.Path`, not to
any exclusion. The `Get-ReconciliationReport` extraction is the policy-mandated refactor response to
untestable entry-point lines and is now documented (see R5 below).

### `.claude/rules/general-unit-test.md` — test purity — **PASS**

- SearchScope: `tests/scripts/dev-tools/`, `tests/scripts/workflows/` (recursive; contains all six
  changed/added test files)
- SearchPatterns: `New-TemporaryFile|GetTempFileName|\$env:TEMP|TestDrive|Start-Sleep`
- SearchResult: **0 matches in either directory**

### `.claude/rules/general-code-change.md` — 500-line cap — **PASS**

| File | Lines |
|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 421 |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | 156 |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 278 |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | 166 |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | **497** |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | 364 |
| `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` | 125 |
| `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` | 89 |
| `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` | 150 |
| `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` | 106 |

All at or under 500. See Minor m1 on the 497-line file.

### `.claude/rules/general-unit-test.md` — test file location — **PASS**

All test files mirror the production tree under `tests/`. The two workflow-invariant suites live at
`tests/scripts/workflows/` rather than a literal `.github/workflows/` mirror; both files document the
reason in a header comment (the Pester runner discovers only under `scripts`, `tests/powershell`, and
`tests/scripts`). No colocation into a production source tree occurs.

---

## Evidence Location Compliance

```
python scripts/dev_tools/validate_evidence_locations.py --root .
exit 0
```

```
git diff --name-only b36179b2..HEAD -- 'artifacts/baselines/*' 'artifacts/qa/*' 'artifacts/evidence/*' 'artifacts/coverage/*'
(no output; exit 0)
```

Zero files written to non-canonical evidence paths. All evidence for this feature is under
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/<kind>/`.
No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred during this review.

---

## Remediation-Item Verdicts

| Item | Prior severity | Verdict | Basis |
|---|---|---|---|
| **R1 / B1** — per-check polling budgets | Blocking | **RESOLVED** | End-to-end execution probe, with mutation-based falsifiability proof (below) |
| **R2 / B2** — green branch-head runs | Blocking | **RESOLVED for `publish-mcp-npm.yml`; forced deferral for `verify-published-releases.yml`** (M1) | `gh run view` reproduction; 404 reproduction |
| **R3 / M1** — `RUN_INCOMPLETE` state split | Major | **RESOLVED** | Seventh token present with its own instruction, runbook section, and tests; original six unchanged and distinct |
| **R4 / M2** — AC21 network isolation | Major | **SUBSTANTIALLY RESOLVED; residual Minor m7** | Isolation probe and isolated suite run reproduced; measured counter-example on isolation depth |
| **R5 / M3** — `Get-ReconciliationReport` deviation | Major | **RESOLVED** | Deviation record present, coverage figure independently confirmed at 88.8889 % |

### R1 — independently re-executed, not accepted

The caller asked specifically whether the budgets are forwarded **end to end from
`Invoke-ReleaseTagPushGuarded`**, not merely declared as defaults. This was tested by execution.

`Invoke-ReleaseTagPushGuarded` (`Invoke-ReleaseTagPush.ps1:244-250`) still supplies **no** budget
arguments. What changed is that `Invoke-TagPublishVerification` now defaults to six per-check values
and forwards each to its own check. The question is therefore what the release path actually
produces, which only execution can answer.

A reviewer probe dot-sourced the real `Invoke-ReleaseTagPush.ps1`, mocked only the three **check
entry points** (never `Invoke-TagPublishVerification` itself, so the composition under test is real),
and invoked `Invoke-ReleaseTagPushGuarded -ConfirmToken yes`:

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18
CHECK_B_CALLS=1 INTERVAL=20 MAX=60
CHECK_C_15S_SLEEPS=39
[+] forwards 10/18 to check (a), 20/60 to check (b), and polls check (c) at 15s x 40 attempts
Tests Passed: 1, Failed: 0
```

| Check | `spec.md` §3.4 ceiling | Observed from the release path | Verdict |
|---|---|---|---|
| (a) run appears | 10 s x 18 = 3 min | 10 s x 18 | PASS |
| (b) terminal conclusion | 20 s x 60 = 20 min | 20 s x 60 | PASS |
| (c) registry resolves | 15 s x 40 = 10 min | 39 sleeps at 15 s across 40 npm attempts | PASS |

**Falsifiability proven by mutation.** The two check-(b) defaults were reverted to the pre-fix shared
pair (`StepIntervalSeconds = 10`, `StepMaxAttempts = 18`) in a scratch copy of the module, and the
same probe was run against it:

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18
CHECK_B_CALLS=1 INTERVAL=10 MAX=18
[-] forwards 10/18 to check (a), 20/60 to check (b), ...
   Expected 20, but got 10.
Tests Passed: 0, Failed: 1
```

The verification distinguishes the fixed module from the defective one. B1 is genuinely closed.

Residual (Minor m8): no test in the repository suite pins the **call site**. A future edit that
passed explicit wrong arguments at `Invoke-ReleaseTagPush.ps1:244-250` would not be caught locally.

### R3 — original six tokens unchanged and still distinct

Verified against `Invoke-ReleaseVerificationHelpers.ps1:74-83` and the state machine:

`NO_RUN`, `RUN_FAILED`, `STEP_SKIPPED`, `STEP_MISSING`, `UNRESOLVED`, `RESOLVED` are all still
returned, all still distinct string literals, and each still has at least one asserting test in
`Invoke-ReleaseVerification.Tests.ps1`. `RUN_INCOMPLETE` was **added** as a seventh token at
`Invoke-ReleaseVerification.ps1:296` and collapses none of the six. `RUN_FAILED` retains its original
meaning (observed terminal `failure`/`cancelled` conclusion, `Resolve-PublishStepConclusion:219-221`).
**AC6 still holds.**

The runbook advice at `missed-npm-publish.runbook.md:70-71` names `-StepMaxAttempts` and
`-StepIntervalSeconds`; both exist as real script parameters at `Invoke-ReleaseVerification.ps1:42-43`,
so the instruction is actionable. See Minor m9 for the scope limit of that advice.

### R4 — the network-isolation claim, scrutinised by re-execution

The caller asked for specific scrutiny of whether the recorded probe genuinely establishes isolation
and whether the suite result was produced in the isolated session. Both were tested by re-running the
recorded command with two additional probes.

**Reproduced exactly:**
```
=== PROBE npm ===
npm error code ECONNREFUSED
npm error errno ECONNREFUSED
npm error FetchError: request to http://127.0.0.1:9/@danmoisan%2fdrm-copilot-mcp failed,
  reason: connect ECONNREFUSED 127.0.0.1:9
PROBE_NPM_EXIT=1
=== PROBE gh ===
PROBE_GH_EXIT=1
=== SUITE ===
Tests Passed: 3646, Failed: 0, Skipped: 9
```

The probe **does** genuinely establish what it claims about npm: npm ran (its own diagnostic format,
its own debug log), the failure is transport-layer `ECONNREFUSED` on `syscall connect` rather than
`E404`, authentication, or configuration, the refused address is exactly the configured discard
endpoint, and the requested URL is the real scoped-package registry path. This is not an unrelated
failure. `gh` is likewise blocked (exit 1). The suite ran in the same `pwsh -Command` string as the
probe, so it is structurally the same session, and its counts (3646 / 0 / 9) and repo-wide coverage
(6794 / 7073 = 96.0554 %) match this review's independent non-isolated run digit for digit.

**Measured residual.** A third probe added by this review shows the isolation is proxy-level, not
absolute:

```
=== PROBE raw socket ===
RAW_SOCKET_CONNECTED=TRUE
```

A direct `System.Net.Sockets.TcpClient` to `registry.npmjs.org:443` **succeeded inside the isolated
session**. `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` / `NPM_CONFIG_REGISTRY` bind proxy-aware clients
(npm, `gh`, .NET `HttpClient.DefaultProxy`) but not a raw socket. AC21's literal wording, "with no
network access available", is therefore stronger than what the artifact demonstrates.

This is graded **Minor (m7)**, not Major, because the substantive guarantee — AC21 clause 2, that no
test added or modified invokes `npm`, `gh`, or `git` as a real external process — is independently
verified, and the two tools those tests could plausibly reach are provably unreachable. The artifact
also documents its mechanism honestly in its `IsolationMethod:` field. The gap is wording precision
in the criterion and in the artifact's closing sentence.

### R5 — deviation record present and accurate

`evidence/other/get-reconciliation-report-deviation.2026-08-26T02-36.md` names the function, its
location (`Invoke-ReleaseReconciliation.ps1:113-158`), quotes the governing Coverage Exclusion Policy
sentence verbatim, records the 70.83 % -> 88.89 % measurement, and states that no exclusion was added.
The post-extraction figure was independently confirmed at **24 / 27 = 88.8889 %**.

### The one correction beyond the plan — reviewer judgment

`Invoke-ReleaseTagPush.Tests.ps1:41-72` mocks `Invoke-TagPublishVerification`. Before the correction
its `param()` block declared the two parameters R1 replaced, and it stayed green only because the
caller passes neither.

**The call to authorise this as repair of the cycle's own signature change was correct.** The mock is
a test double for a function whose signature this cycle changed; leaving it declaring removed
parameters is a defect introduced by this cycle, not a pre-existing one, and a stale mock signature is
precisely the class of drift that lets a test pass against an implementation it no longer mirrors.
Opening a new cycle for it would have been disproportionate.

**The fix is complete.** All twelve current parameters plus the switch are declared
(`:42-55`) and match `Invoke-TagPublishVerification`'s real signature at
`Invoke-ReleaseVerification.ps1:345-360` exactly. The executor's audit of the other two mocks
reproduces: `Test-NpmVersionResolved` mock (`:36-40`) declares `Version` and `PackageName`, matching
`Invoke-ReleaseVerification.ps1:124-128`; `Get-CodexPinnedMcpVersion` mock (`:73-77`) declares
`ConfigContent` and `PackageName`, matching `Invoke-ReleaseVerificationHelpers.ps1:137-143`. Both are
in parity.

---

## Finding Register

### Blocking — none

### Major

**M1 — `verify-published-releases.yml` has no green branch-head run (forced deferral).**
Rule: `modified-workflow-needs-green-run`. `workflow_dispatch` returns HTTP 404 because the file does
not exist on the default branch, so no mechanism available before the PR opens can produce the run.
The `pull_request` trigger at `verify-published-releases.yml:16-19` is the remedy and follows the
repository's own `publish-extension.yml` precedent. Discharge at PR-open by S9 CI monitoring; **no
remediation cycle required**.

### Minor

| ID | Location | Summary | Status |
|---|---|---|---|
| m1 | `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` (497) | 3 lines of headroom under the 500-line cap, tightened from 491 by the mock-signature fix. The production-file half of the prior m1 is resolved (`Invoke-ReleaseVerification.ps1` now 421). | carried, tightened |
| m2 | `.github/workflows/publish-mcp-npm.yml:105` | `$version = '${{ steps.resolve-publish-version.outputs.publishVersion }}'` interpolates a GitHub expression into a PowerShell literal. Prefer `env:` plus `$env:PUBLISH_VERSION`. | carried, unfixed |
| m3 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:48` | Dot-source imports the verification module's defaulted `param()` variables into the consumer's script scope; the set widened from 9 to 13 with the per-check budgets. A `.psm1` would remove the coupling. | carried, widened |
| m4 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:261` | Codex pin guard reads one of two committed `.codex/config.toml` copies (`./.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, both confirmed present). Copy equality is #522's scope; noted so the narrowing stays visible. | carried |
| m5 | `.github/workflows/verify-published-releases.yml:66-67` | Comment claims `git ls-remote` exits non-zero with no matching tag; it exits 0 without `--exit-code`. The reset is harmless; the stated reason is wrong. | carried, unfixed |
| m6 | Both workflow-invariant suites (`PublishMcpNpmWorkflow.Tests.ps1:145-147`, `VerifyPublishedReleasesWorkflow.Tests.ps1:101-103`) | Exit-code assertions are position-blind: they match `$LASTEXITCODE = 0` / `exit 0` + `exit 1` anywhere in the step rather than checking placement relative to the failing command. | carried, unfixed |
| m7 | `spec.md` AC21; `evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md` | "no network access available" overstates proxy-env isolation. Reviewer probe measured `RAW_SOCKET_CONNECTED=TRUE` to `registry.npmjs.org:443` inside the isolated session. Suggest narrowing the wording to name the isolation mechanism. | **new** |
| m8 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:244-250` | No repository test pins the budgets at the tag-push call site; correctness rests on the callee's defaults. A future edit passing explicit wrong arguments here would not be caught locally. The reviewer probe in this audit is a ready-made regression test. | **new** |
| m9 | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:142-160` | `Invoke-ReleaseTagPushGuarded` exposes no budget parameters, so the runbook's `-StepMaxAttempts` advice is reachable only through the standalone verifier and the release path's budgets are not operator-configurable. `spec.md` §8.1 states "Budgets are configurable parameters, not constants." | **new** |
| m10 | `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | Post-split line coverage is 86.15 %, only 1.15 points above the 85 % floor (was 90.22 % pre-split, because the four fully covered pure helpers moved out). One additional uncovered seam line would breach the floor. | **new** |

---

## Assumptions Recorded

1. **Head-SHA equivalence.** The `modified-workflow-needs-green-run` rule is treated as satisfied for
   `publish-mcp-npm.yml` at `515b4d97` on the strength of a run at `5cb5224a`, because the delta is a
   single Markdown file and the workflow-relevant tree is byte-identical. Reasoning is recorded above
   in full rather than assumed silently.
2. **M1 discharge.** The forced deferral is assumed to be discharged by the PR-triggered runs. If
   either PR-triggered run concludes anything other than `success`, M1 escalates to Blocking at that
   point.
3. **`quality-tiers.yml` absent.** The file remains absent from the repository root, a known
   pre-existing environment defect recorded in `spec.md` §2.2 as out of scope. The affected release
   tooling is treated as T4; the uniform 85 % line floor applies at every tier, so no verdict in this
   audit depends on the missing classification.
