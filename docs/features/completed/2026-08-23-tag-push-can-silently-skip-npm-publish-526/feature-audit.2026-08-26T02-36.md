# Feature Audit — Issue #526

- **Timestamp:** 2026-08-26T02-36
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `d9c148a7`
- **Baseline:** `main` @ merge base `b36179b2`
- **Work Mode:** `full-bug` (`issue.md:12`) — **`spec.md` is the sole acceptance-criteria source**
- **AC source file:** `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, section "Acceptance Criteria", AC1-AC28
- **No `user-story.md` exists**, which is correct for `full-bug`

Every criterion below was evaluated against the code, the tests, and the tooling directly. Where an
AC is already checked in `spec.md`, the check was verified rather than accepted: the named test or
artifact was read, and where a criterion asserts a command result or a negative claim, that command
was re-run during this audit.

---

## Evaluation Table

| AC | Verdict | Evidence verified by this audit |
|---|---|---|
| AC1 | **PASS** | `Invoke-ReleaseVerification.ps1:44` `Invoke-GhExe`, `:61` `Invoke-NpmExe` (both return `@{ Output; ExitCode }`), `:78` `Invoke-Sleep` isolating `Start-Sleep`. Test file dot-sources at `:10` and mocks all three at `:46`, `:61`, `:70`. Entry-point guard at `:484` confirmed covered-but-not-entered. |
| AC2 | **PASS** | `Test-NpmVersionResolved:148` builds `'{0}@{1}' -f $PackageName, $Version`. Test `passes the package operand in exact-version form to the npm seam` (`:107-116`) captures the vector and asserts `$operand -eq "$package@1.1.2"` and `-Not -Be $package`. No bare-package call path exists in the module. |
| AC3 | **PASS** | Test at `:118-135` arranges the bare form to exit 0 with a different version and the exact form to exit 1. Discriminating power confirmed by inspection: `Should -BeFalse` alone would pass against a bare-package implementation (the `$observed -eq $Version` conjunct still fails), so the operand assertion at `:134` is what makes the test able to fail. It is present. |
| AC4 | **PASS** | Test `pushes the mcp-server tag before the extension tag` (`Invoke-ReleaseTagPush.Tests.ps1:157-187`) derives `$pushLines` from captured git vectors and asserts `$mcpPushIndex -lt $extensionPushIndex`. Production order confirmed at `Invoke-ReleaseTagPush.ps1:208-231` (mcp entry first). |
| AC5 | **PASS** | Test at `:209-230` asserts all four conjuncts: non-zero return; `$pushLines.Count -eq 1`; `$pushLines[0] -eq "push origin mcp-server-v0.0.2"`; and zero tag-creation invocations matching the extension tag. The fourth is the one that distinguishes "not created" from "not pushed" and it is asserted. |
| AC6 | **PASS** | Six state-machine tests at `:139-174`, one per token: `RESOLVED`, `NO_RUN`, `RUN_FAILED`, `STEP_SKIPPED`, `STEP_MISSING`, `UNRESOLVED`. All six tokens exist as distinct literals in the module (`:207`, `:224-258`, `:452`, `:463`, `:472`, `:479`). |
| AC7 | **PASS** | Test `treats a missing publish step as a non-zero failure rather than absence of evidence` (`:185-191`) asserts both `State -eq 'STEP_MISSING'` and `ExitCode -Not -Be 0`. `Resolve-PublishStepConclusion:242,248` returns the token for absent job and absent step respectively; `ConvertTo-VerificationResult:366` gives ExitCode 0 only for `RESOLVED`. |
| AC8 | **PASS** | `Get-RecoveryInstruction:327-335` defines six non-empty instructions. Test at `:232-245` asserts all three named instructions non-empty and pairwise unequal. Read directly: no two of the six strings are the same and none is generic. |
| AC9 | **PASS** | Nine tests at `:258-309`, three per check, each asserting `Should -Invoke -CommandName Invoke-Sleep -Times N -Exactly`. "At least three attempts" satisfied: later-attempt cases set the found-on attempt to 3 and assert exactly 2 sleeps. |
| AC10 | **PASS** | Test at `:193-205` computes both outcomes in one test and asserts `$exhausted.State -Not -Be $negative.State` plus both ExitCodes non-zero. Tokens are `NO_RUN` versus `STEP_SKIPPED`. |
| AC11 | **PASS** | Test at `:284-316` asserts non-zero return, `VERSION_CONSUMED_ELSEWHERE` in the captured message, zero `^push ` invocations, zero `^tag ` invocations, and `Should -Invoke Invoke-TagPublishVerification -Times 0 -Exactly`. Production guard at `Invoke-ReleaseTagPush.ps1:198-201`, placed before any tag creation. |
| AC12 | **PASS** | `Get-CodexPinnedMcpVersion:373-408` takes content as a parameter, reads no path. Tests at `:313-321` and `:323-328` supply in-memory TOML. The **guard-level** assertion is indirect but real: the `Test-NpmVersionResolved` mock (`Invoke-ReleaseTagPush.Tests.ps1:36-40`) returns true only for the pinned `9.9.9` while manifests give `0.0.2`/`0.0.3`, so a guard passing the manifest version would fail the success-path `Should -Be 0`. |
| AC13 | **PASS** | `publish-mcp-npm.yml:12-14` declares `pull_request:` with `paths: packages/mcp-server/**` and the workflow file. `:7-11` carries the comment naming `modified-workflow-needs-green-run`. Test at `PublishMcpNpmWorkflow.Tests.ps1:68-76` asserts all three, scoped to the extracted `on:` block so an unrelated occurrence cannot satisfy it. |
| AC14 | **PASS** | **Re-verified live:** `grep -n "github.event_name" .github/workflows/publish-mcp-npm.yml` -> **NONE**; `grep -c "startsWith(github.ref, 'refs/tags/mcp-server-v')"` -> **3**. Test at `:78-88` asserts `$eventNameGuards.Count -eq 0` and `$refGuards.Count -gt 0`. |
| AC15 | **PASS** | Step `Verify tag version matches the mcp-server manifest` is ref-guarded, sits before the publish step, parses `$env:GITHUB_REF_NAME`, compares against `packages/mcp-server/package.json`'s `.version`, and `exit 1`s on mismatch. Test at `:90-111` asserts ordering by step index, the ref guard, `GITHUB_REF_NAME`, `.version`, `-ne`, and `exit 1`. |
| AC16 | **PASS** | Post-publish step polls `@danmoisan/drm-copilot-mcp@$version` for 18 attempts and `exit 1`s on expiry. Tests at `:113-126` (index after publish; exact-version operand; `maxAttempts`; `exit 1`) and `:128-135` (ref guard). |
| AC17 | **PASS** | All four added `pwsh` steps enumerated from the YAML and each carries a remedy — see the code review table. Predicate falsifiability **measured**: a synthetic naked step returns `False`, reset returns `True`, explicit exits return `True`. The assertion is not vacuous. |
| **AC18** | **FAIL** | **Correctly left unchecked.** Re-verified live at review time: `gh run list --workflow=publish-mcp-npm.yml --limit 8 --json headSha` returns 8 runs, none with `headSha == d9c148a7`; `gh run list --workflow=verify-published-releases.yml` returns `HTTP 404 ... not found on the default branch`; `gh pr list --head <branch> --state all` returns `[]`. No green branch-head run exists and no run URL or step conclusion is recorded. See Blocking finding B2. |
| AC19 | **PASS** | `.github/workflows/verify-published-releases.yml` exists with `schedule:` cron. `Get-UnpublishedTagVersion` is a pure set difference performing no external call. Nine offline tests including all three required cases. **End-to-end replay executed during this audit:** divergent -> `UNPUBLISHED_TAG_VERSIONS: 9.9.9`, exit 1; convergent -> `none`, exit 0; the workflow's offline validation step reproduces `count=1 first=9.9.9`. |
| AC20 | **PASS** | The five-invocation and extension-first assertions are gone; the file now asserts `$pushLines.Count -eq 2` with mcp first (`:132-139`). Whole-file pass confirmed by this audit's independent suite run: 3638 passed, 0 failed, 9 skipped. |
| AC21 | **PARTIAL** | **Second clause PASS, first clause UNVERIFIED.** All five test files read in full: every `npm`/`gh`/`git` occurrence is a mock payload, a test name, a mock declaration, an assertion regex, or workflow-YAML text; no real process is spawned. Suite passes. But "with no network access available" was never exercised. SearchScope: `evidence/` (28 artifacts, recursive). SearchPatterns: `network[- ](disabled\|isolat\|off\|unavailable)`, `offline run`, `no network access` (case-insensitive). SearchResult: **0 matches.** No network-isolated run is recorded. See Major finding M2. |
| AC22 | **PASS** | **Re-verified live:** `grep -rn "New-TemporaryFile\|GetTempFileName\|env:TEMP\|TestDrive\|Start-Sleep"` across all five test files -> **NO MATCHES**. |
| AC23 | **PASS** | **Re-measured with `wc -l`:** 499, 278, 166, 346, 491, 89, 150, 106. All eight at or below 500. |
| AC24 | **PASS** | **Reproduced from an independent PoshQC run performed during this audit:** `Invoke-ReleaseVerification.ps1` 83/92 = **90.2174%**, `Invoke-ReleaseTagPush.ps1` 75/77 = **97.4026%**, both >= 85%. Neither file appears in any exclusion list; both were **added** to the `CodeCoverage.Path` allow-list in both `pester.runsettings.psd1` copies, which is the opposite of exclusion. |
| AC25 | **PASS** | **Re-run during this audit:** `pwsh -NoProfile -Command "& ./scripts/dev-tools/run-actionlint.ps1"` -> `ACTIONLINT_EXIT=0`. |
| AC26 | **PASS** | **All three stages re-run independently.** Format: in-memory `Invoke-Formatter -ScriptDefinition` against `scripts/powershell/PoshQC/settings/pssa.settings.psd1` for all eight changed `.ps1` files -> **8/8 SAME** (no rewrite would occur). Lint: `Invoke-PoshQCAnalyze` -> `PSScriptAnalyzer passed: no findings`. Test: `Invoke-PoshQCTest` -> 3638 passed, 0 failed, 9 skipped. Single consecutive pass, no auto-fix, no restart. |
| AC27 | **PASS** | `docs/engineering/missed-npm-publish.runbook.md` read in full: one section per state at `:35`, `:56`, `:69`, `:81`, `:93`, `:106`; `### Precondition 1 — version resolves nowhere` at `:139`; `### Precondition 2 — no successful run for the tag` at `:151`; `### Human decision — consumed version disposition` at `:171` with an explicit "made by a human and is never taken by automation". |
| AC28 | **PASS** | **Re-verified from the diff:** `git diff --name-only b36179b2..HEAD` (52 paths) contains no `README.md` and no `quality-tiers.yml`. `ls quality-tiers.yml` confirms the file remains absent, as `spec.md` §2.2 documents. |

---

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md
- Total AC items: 28
- Checked off (delivered): 27
- Remaining (unchecked): 1
- Items remaining: AC18 — A green run of `publish-mcp-npm.yml` against the branch head exists,
  produced by the new `pull_request` trigger, and the run's publish-step conclusion is `skipped`.
```

Reviewer verdict distribution: **26 PASS, 1 PARTIAL (AC21), 1 FAIL (AC18)**.

No AC was checked off by this review, because every criterion this audit rates PASS was already
checked in `spec.md`. No phantom criteria were added and no criterion text was modified.

---

## Criteria Checked Without Adequate Evidence

The brief asks specifically for these, on the grounds that a criterion checked without evidence is a
worse defect than one left unchecked. One was found.

### AC21 — checked, but only one of its two clauses is evidenced

AC21 asserts two things:

1. "The complete Pester suite passes **with no network access available**"
2. "no test added or modified by this change invokes `npm`, `gh`, or `git` as a real external process"

Clause 2 is thoroughly evidenced and was independently confirmed during this audit by reading all
five test files: every wrapper seam is mocked, several contexts mock `Invoke-GitExe` with a body that
throws if reached (an assertion of non-invocation rather than a permission), and the pure-function
suite needs no mock at all.

Clause 1 is not evidenced. The suite has never been run with network access removed. The supporting
artifact `evidence/qa-gates/test-purity.2026-08-26T02-05.md` offers a textual purity scan over the
five changed test files plus a wall-clock-cost corroboration ("A suite containing a real `npm view`
... would exhibit wall-clock cost far above that"). That argument is reasonable and it does support
clause 2 for those five files. It is not evidence about the other roughly 3600 tests in the suite,
which is what "the complete Pester suite" ranges over.

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/`
  (recursive, 28 artifacts)
- SearchPatterns: `network[- ](disabled|isolat|off|unavailable)`, `offline run`, `no network access`
  (case-insensitive)
- SearchResult: **0 matches**

**Severity: Major, not Blocking.** The clause that actually protects this change — clause 2 — is
solid, and the practical risk is low. The finding is that the checkbox asserts more than the evidence
establishes.

**Disposition of the checkbox.** The AC21 checkbox was **left checked** and `spec.md` was not
modified. Unchecking it would discard the executor's fully verified work on clause 2 to signal a
shortfall in a secondary clause, and the shortfall is recorded here and in the policy audit where a
remediation step can act on it. The recorded remediation is to run the suite once with network access
removed and add the result to `evidence/qa-gates/`, which is cheap and would settle the clause
outright.

### Criteria explicitly re-tested rather than accepted

The following were checked in `spec.md` on the strength of an executor-produced artifact. Each was
independently re-executed during this audit and each reproduced exactly, so each is confirmed rather
than merely inherited:

| AC | Independent re-execution | Result |
|---|---|---|
| AC14 | `grep -n "github.event_name"` / `grep -c "startsWith(github.ref..."` | NONE / 3 — matches |
| AC22 | `grep -rn` for five temp/sleep literals across five test files | NO MATCHES — matches |
| AC23 | `wc -l` on all eight `.ps1` files | 499, 278, 166, 346, 491, 89, 150, 106 — matches |
| AC24 | Fresh `Invoke-PoshQCTest` + JaCoCo parse | 90.2174% / 97.4026% — matches to the digit |
| AC25 | `run-actionlint.ps1` | exit 0 — matches |
| AC26 | `Invoke-Formatter` in memory, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest` | 8/8 SAME, no findings, 3638/0/9 — matches |
| AC28 | `git diff --name-only b36179b2..HEAD` | no README.md, no quality-tiers.yml — matches |
| AC19 | Direct execution of the reconciliation script and the workflow's offline step | exit 1 / exit 0 / count=1 first=9.9.9 — behaves as claimed |
| AC18 | `gh run list` x2, `gh pr list`, `git ls-remote` | DEFERRED confirmed accurate, including the exact 404 |

No discrepancy was found between any recorded figure and any re-measured figure.

---

## Behavioural Requirements Not Expressed as Acceptance Criteria

`spec.md` §4 states fifteen behavioural requirements. Most map onto an AC, but three do not, and one
of those is where the substantive defect lives. Recorded here because a BR without an AC is exactly
the gap an AC-only audit would miss.

| BR | Status | Note |
|---|---|---|
| BR-3 — bounded two-phase polling at a configurable interval and attempt count | **PARTIAL** | Configurable at the module level, but `Invoke-ReleaseTagPushGuarded:244-250` supplies neither, and the module forwards one budget to all three checks. `spec.md` §3.4 tabulates three distinct budgets: (a) 10 s x 18, (b) 20 s x 60, (c) 15 s x 40. Shipped: 10 s x 18 for all three. **Blocking finding B1.** |
| BR-4 — distinct failure states, `STEP_MISSING` a failure | **PARTIAL** | The six tokens are distinct and `STEP_MISSING` is a failure (AC7 PASS). But check-(b) budget exhaustion returns `RUN_FAILED`, colliding with the genuinely-failed-run case, against §3.4's "An exhausted budget must be reported as a state distinct from a negative result". **Major finding M1.** |
| BR-8 — the flow propagates a non-success outcome instead of returning 0 | **PASS** | Verified at `Invoke-FullReleaseFlow.ps1:387-391`: `if ($tagPushExit -ne 0) { ...; return 1 }`. Already correct; the diff rightly leaves the file untouched. |
| BR-9 — the pin guard reads the committed `.codex/config.toml` | **PASS** | Satisfied as worded (singular). Narrower than `spec.md` §1.1's framing of "both copies"; the second copy is at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` and both currently pin `1.1.2`. Minor finding m4. |
| BR-1, BR-2, BR-5, BR-6, BR-7, BR-10 - BR-15 | **PASS** | Each maps onto a PASS criterion above. |

---

## Scope Boundary Against the Baseline

| Boundary | Status | Verification |
|---|---|---|
| `README.md` not modified (owned by #528) | **HELD** | Absent from the 52-path changed-file list |
| `quality-tiers.yml` not added | **HELD** | Absent from the diff; `ls quality-tiers.yml` -> not found |
| No offline pin-equals-manifest test added (owned by #522) | **HELD** | The pin guard is registry-resolution only and runs post-push, never per-commit |
| `publish-extension.yml` publish semantics unchanged | **HELD** | Not in the changed-file list; only read for its job/step names |
| No automated delete-and-re-push | **HELD** | No destructive tag operation in any script; the runbook gates it on two preconditions and assigns it to a human |
| No change to the npm credential mechanism | **HELD** | `npm publish --provenance --access public` under OIDC is unchanged; no secret added |
| Root-cause confirmation out of scope | **HELD** | No criterion depends on it; the design detects, gates, and recovers instead |

All declared boundaries hold. The three production files, two workflows, two run-settings copies, one
runbook, and five test files delivered match `spec.md` §7 "Files Expected to Change" exactly, with the
addition of `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` and its test, which §2.1 item 8
(Layer C) calls for.

---

## Verdict

**Remediation required.**

The feature is substantially delivered: 26 of 28 acceptance criteria pass on verified evidence, the
architecture is sound, the test suite is strong and genuinely falsifiable, and the toolchain is clean
under independent re-execution. The change would materially reduce the risk the issue reports.

Two Blocking findings prevent a ready-to-merge verdict:

- **B2** is a process gap with no code change required. A `workflow_dispatch` run of
  `publish-mcp-npm.yml` against the branch head is available today and would satisfy the rule for
  that file; the second file resolves once the PR opens.
- **B1** is a code defect. The polling budgets `spec.md` §3.4 specifies were not implemented, and the
  release path runs every check at 3 minutes against a specified 20-minute ceiling for check (b). The
  failure mode is a false abort after the mcp tag has been pushed, which burns an mcp version number
  — the irreversible outcome this feature exists to prevent.

Both are small to fix. B1 is a parameter change; B2 is one command plus an artifact update.
