# Feature Audit — Issue #526 (Cycle-1 REAUDIT)

- **Timestamp:** 2026-08-26T04-33
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `515b4d97`
- **Base:** `main` @ merge base `b36179b2`
- **Work Mode:** `full-bug` -> **`spec.md` is the sole acceptance-criteria source**
- **AC count:** 30 (AC29 and AC30 added during the remediation cycle)
- **Prior audit:** `feature-audit.2026-08-26T02-36.md`

## Verdict

| Result | Count |
|---|---|
| PASS | 28 |
| PARTIAL | 1 (AC21) |
| PENDING — correctly unchecked | 1 (AC18) |
| FAIL | 0 |

**Criteria checked beyond their evidence: 1 (AC21, marginal — see below). No criterion is checked
without substantial supporting evidence.**

---

## Work-Mode Resolution

`spec.md:9` records `- **Work Mode:** full-bug (spec.md is the sole acceptance-criteria source; no
user-story.md)`. `issue.md` carries the same marker. Confirmed that no `user-story.md` exists in the
feature folder, so the `full-bug` mapping is consistent with the artifacts present. `spec.md`'s
`## Acceptance Criteria` section (lines 395-426) is the sole AC source for this audit.

---

## Acceptance Criteria Evaluation

Verification method column: **X** = re-executed by this review; **R** = read from source/diff;
**A** = read from a feature-folder evidence artifact whose figures were independently reproduced.

| AC | Checkbox | Verdict | Method | Evidence |
|---|---|---|---|---|
| AC1 | `[x]` | **PASS** | R, X | `Invoke-ReleaseVerification.ps1:56-105` defines `Invoke-GhExe`, `Invoke-NpmExe` (both returning `@{ Output; ExitCode }`) and `Invoke-Sleep`. `Invoke-ReleaseVerification.Tests.ps1:10` dot-sources; `:52-76` mocks all three; `:80-90` asserts all three resolve and are invoked. Suite green. |
| AC2 | `[x]` | **PASS** | R, X | `Test-NpmVersionResolved:130` builds `'{0}@{1}' -f $PackageName, $Version`. Test `:94-103` captures the argument vector and asserts `$operand -eq "$package@1.1.2"` and `$operand -Should -Not -Be $package`. |
| AC3 | `[x]` | **PASS** | R, X | Test `:105-122` arranges the npm seam to return exit 0 with a different version for the bare-package form and exit 1 for the exact form, asserts `-BeFalse`, and asserts the captured operand is the exact-version form — which is what makes it fail against a bare-package implementation. |
| AC4 | `[x]` | **PASS** | R, X | `Invoke-ReleaseTagPush.Tests.ps1:163-193` derives `$mcpPushIndex` and `$extensionPushIndex` from the captured git argument vectors and asserts `$mcpPushIndex -BeLessThan $extensionPushIndex`. Also `:138-146` asserts `pushLines[0] = "push origin mcp-server-v0.0.2"`, `pushLines[1] = "push origin v0.0.3"`. |
| AC5 | `[x]` | **PASS** | R, X | `:215-236` arranges `STEP_SKIPPED` for the mcp verification, then asserts non-zero return, exactly one push, that it carries the mcp tag, and zero tag-creation invocations carrying `v0.0.3`. All four clauses present. |
| AC6 | `[x]` | **PASS** | R, X | All six tokens returned as distinct literals and each asserted: `NO_RUN` `:132-136`, `RUN_FAILED` `:138-142`, `STEP_SKIPPED` `:144-148`, `STEP_MISSING` `:150-154`, `UNRESOLVED` `:156-161`, `RESOLVED` `:126-130`. **Re-verified after R3:** the seventh token `RUN_INCOMPLETE` was added at `Invoke-ReleaseVerification.ps1:296` without collapsing any of the six; `RUN_FAILED` retains its observed-terminal-failure meaning at `Resolve-PublishStepConclusion:219-221`. |
| AC7 | `[x]` | **PASS** | R, X | `:172-178` asserts `State -eq 'STEP_MISSING'` **and** `ExitCode -Not -Be 0`. `Resolve-PublishStepConclusion:223-231` returns `STEP_MISSING` for both the absent-job and absent-step paths; `:219-229` covers absent-job separately. |
| AC8 | `[x]` | **PASS** | R, X | `Invoke-ReleaseVerificationHelpers.Tests.ps1:35-48` asserts all three of `NO_RUN`, `STEP_SKIPPED`, `UNRESOLVED` non-empty and pairwise different. |
| AC9 | `[x]` | **PASS** | R, X | "bounded polling budgets" context, `:241-294`. Nine tests: three per check (first-attempt / later-attempt / exhausted), each asserting `Should -Invoke -CommandName Invoke-Sleep -Times N -Exactly`. Later-attempt cases use attempt 3 of 4, satisfying "at least three attempts". |
| AC10 | `[x]` | **PASS** | R, X | `:203-215` compares the exhausted run-existence outcome against the negative publish-step outcome, asserting different tokens and both non-zero. |
| AC11 | `[x]` | **PASS** | R, X | `Invoke-ReleaseTagPush.Tests.ps1:289-322` asserts non-zero return, `VERSION_CONSUMED_ELSEWHERE` in the message, zero pushes, zero tag creations, and `Invoke-TagPublishVerification` invoked zero times. |
| AC12 | `[x]` | **PASS** | R, X | `Invoke-ReleaseVerification.Tests.ps1:296-312`: the pin is read from an in-memory string and passed to the registry check (operand asserted); the companion test asserts failure when the pinned version does not resolve. Also `Invoke-ReleaseVerificationHelpers.Tests.ps1:100-123`. No temporary file. |
| AC13 | `[x]` | **PASS** | R, X | `publish-mcp-npm.yml:8-15` declares `pull_request` with paths `packages/mcp-server/**` and `.github/workflows/publish-mcp-npm.yml`; the comment at `:8-11` names "the modified-workflow-needs-green-run rule". Pinned by `PublishMcpNpmWorkflow.Tests.ps1:68-76`. |
| AC14 | `[x]` | **PASS** | R, X | `grep -n "github.event_name" .github/workflows/publish-mcp-npm.yml` -> no output (exit 1). `grep -c "startsWith(github.ref, 'refs/tags/mcp-server-v')"` -> **3**. Pinned by `PublishMcpNpmWorkflow.Tests.ps1:78-88`, which asserts the event-name guard count is exactly 0. |
| AC15 | `[x]` | **PASS** | R, X | `publish-mcp-npm.yml:71-86`: step `Verify tag version matches the mcp-server manifest`, ref-guarded at `:73`, ordered before the publish step at `:92`, parses `$env:GITHUB_REF_NAME`, compares against the manifest `.version`, `exit 1` on mismatch. Ordering pinned by test `:90-111` via step-index comparison. |
| AC16 | `[x]` | **PASS** | R, X | `publish-mcp-npm.yml:101-128`: post-publish step polling `@danmoisan/drm-copilot-mcp@$version` (exact-version form), 18 attempts x 10 s, `exit 1` on budget expiry. Ordering and operand pinned by test `:113-126`. |
| AC17 | `[x]` | **PASS** | R, X | All four added `pwsh` steps comply: `publish-mcp-npm.yml:86` (`exit 0`) / `:84` (`exit 1`); `:115` (`$LASTEXITCODE = 0`) with `:127-128`; `verify-published-releases.yml:44,46` (`exit 1`/`exit 0`); `:70,76` (two resets) with `:91,95`. Pinned by both workflow suites. |
| **AC18** | `[ ]` | **PENDING — correctly unchecked** | X | See ruling below. |
| AC19 | `[x]` | **PASS** | R, X | `verify-published-releases.yml` exists with a `schedule` cron at `:9`. `Get-UnpublishedTagVersion` (`Invoke-ReleaseReconciliation.ps1:42-111`) is a pure set difference. Three required cases all present offline: every tag published `Invoke-ReleaseReconciliation.Tests.ps1:19-23`, one tag unpublished `:25-33`, empty tag set `:35-41`. Five further cases beyond the minimum. |
| AC20 | `[x]` | **PASS** | R, X | `grep -nE "Count \| Should -Be 5\|Times 5\|five" tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` -> no output (exit 1). The file asserts mcp-first ordering instead. Whole file passes: `Invoke-Pester -Path ./tests/scripts/dev-tools/,./tests/scripts/workflows/` -> 438 passed, 0 failed, 2 skipped. |
| **AC21** | `[x]` | **PARTIAL** | X | See analysis below. |
| AC22 | `[x]` | **PASS** | X | SearchScope: `tests/scripts/dev-tools/`, `tests/scripts/workflows/` (recursive; contains all six changed test files). SearchPatterns: `New-TemporaryFile\|GetTempFileName\|\$env:TEMP\|TestDrive\|Start-Sleep`. SearchResult: **0 matches in either directory.** |
| AC23 | `[x]` | **PASS** | X | `wc -l` over all 10 changed `.ps1` files: 166, 278, 421, 156, 89, 497, 364, 125, 150, 106. Maximum 497 <= 500. |
| AC24 | `[x]` | **PASS** | X | Re-measured from `artifacts/pester/powershell-coverage.xml` after a fresh suite run: `Invoke-ReleaseVerification.ps1` **56/65 = 86.1538 %**; `Invoke-ReleaseVerificationHelpers.ps1` **29/29 = 100.0000 %**; `Invoke-ReleaseTagPush.ps1` **75/77 = 97.4026 %**. All >= 85 %. No exclusion list entry for any of them; both are registered in `CodeCoverage.Path` in both byte-identical copies of `pester.runsettings.psd1`. |
| AC25 | `[x]` | **PASS** | X | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1` -> **exit 0**. |
| AC26 | `[x]` | **PASS** | X | Single consecutive pass: `Invoke-PoshQCFormat` exit 0, 413 files "Already formatted", **zero auto-fixes**, `git status --short` empty afterwards; `Invoke-PoshQCAnalyze` exit 0, `PSScriptAnalyzer passed: no findings`; `Invoke-PoshQCTest` exit 0, 3646 passed / 0 failed / 9 skipped. |
| AC27 | `[x]` | **PASS** | R | `docs/engineering/missed-npm-publish.runbook.md` (216 lines) has a section per state — `NO_RUN` `:36`, `RUN_INCOMPLETE` `:57`, `RUN_FAILED` `:76`, `STEP_SKIPPED` `:91`, `STEP_MISSING` `:103`, `UNRESOLVED` `:115`, `VERSION_CONSUMED_ELSEWHERE` `:128` — plus the two jointly-necessary delete-and-re-push preconditions `:155-189` and the human-only disposition statement `:191-208`. |
| AC28 | `[x]` | **PASS** | X | `git diff --name-only b36179b2..HEAD \| grep -iE 'README\.md\|quality-tiers\.yml'` -> no output (exit 1). `publish-extension.yml` likewise untouched. |
| **AC29** | `[x]` | **PASS** | X | See R1 verification below. |
| **AC30** | `[x]` | **PASS** | R, X | `Test-PublishStepConclusion:296` returns `RUN_INCOMPLETE` on exhaustion. Own recovery instruction at `Invoke-ReleaseVerificationHelpers.ps1:78`, distinct from `RUN_FAILED`'s at `:77` (asserted `Invoke-ReleaseVerificationHelpers.Tests.ps1:50-62`). Own runbook section at `missed-npm-publish.runbook.md:57-74` plus a row in the at-a-glance table at `:19`. `Invoke-ReleaseVerification.Tests.ps1:180-201` asserts the exhausted-budget token differs from the concluded-failure token and that both carry non-zero exit codes. |

---

## AC29 — the criterion that closed the Blocking finding

AC29 requires that `Invoke-TagPublishVerification` accept and forward a separate interval and attempt
budget for each of the three checks, each defaulted to its own §3.4 ceiling, and that the tests assert
the forwarded budget of each check individually.

**Structure (read):** six parameters declared at `Invoke-ReleaseVerification.ps1:353-358`; forwarded
to check (a) at `:362-366`, check (b) at `:372-377`, check (c) at `:387-394`. Defaults are 10/18,
20/60, 15/40, matching §3.4's 3-, 20-, and 10-minute ceilings.

**Tests (read and re-run):** three tests at `Invoke-ReleaseVerification.Tests.ps1:322-362`, one per
check. The check-(a) and check-(b) tests use a `-ParameterFilter` so a wrong budget makes the mock not
apply, which changes the returned state and fails the assertion; the check-(c) test asserts 40 npm
invocations and 39 sleeps filtered to `$Seconds -eq 15`.

**End-to-end behaviour (re-executed).** AC29 speaks about the composition entry point, but the
original defect was that the caller supplied nothing, so this audit tested the release path itself. A
reviewer probe dot-sourced the real `Invoke-ReleaseTagPush.ps1`, mocked only the three check entry
points, and invoked `Invoke-ReleaseTagPushGuarded -ConfirmToken yes`:

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18
CHECK_B_CALLS=1 INTERVAL=20 MAX=60
CHECK_C_15S_SLEEPS=39
Tests Passed: 1, Failed: 0
```

Every §3.4 ceiling is reached on the release path. Repeating the probe against a scratch copy with the
check-(b) defaults reverted to the pre-fix shared pair produced
`CHECK_B_CALLS=1 INTERVAL=10 MAX=18` and `Expected 20, but got 10`, so the verification discriminates
the fixed module from the defective one.

`Invoke-ReleaseTagPushGuarded` still supplies no explicit arguments and relies on the callee's
defaults. That composition is correct and now proven by execution, but it is unpinned by any
repository test — recorded as Minor m8 in the policy audit, not as an AC29 failure, because AC29 does
not require the call site to state the budgets.

**AC29 PASS.**

---

## AC18 — the reading is correct

AC18 text: *"A green run of `publish-mcp-npm.yml` against the branch head exists, **produced by the
new `pull_request` trigger**, and the run's publish-step conclusion is `skipped`."*

Independently verified via `gh`:

```
gh run view 32946866360 --json event,conclusion,headSha,headBranch
{"conclusion":"success","event":"workflow_dispatch",
 "headSha":"5cb5224a6062213cf6694f16871b61dbf1759da2",
 "headBranch":"bug/tag-push-can-silently-skip-npm-publish-526"}
```

The run's `event` is `workflow_dispatch`, not `pull_request`. AC18 names the trigger explicitly, and
the observed trigger is not the named one.

**The orchestrator's reading is confirmed as correct.** Checking AC18 on the strength of a
`workflow_dispatch` run would assert the specific fact the criterion names while the evidence supports
a different one — the same defect class this review raised against AC21 in the prior cycle. Leaving it
unchecked is the right call and is the more valuable of the two errors to avoid: an unchecked
criterion that is in fact satisfied costs a second look, whereas a criterion checked beyond its
evidence silently retires a gate.

Note the distinction the evidence artifact itself draws at `branch-head-dispatch-run.2026-08-26T08-17.md:9-23`,
which is exactly right: the **policy rule** `modified-workflow-needs-green-run` accepts a
`workflow_dispatch` run and is therefore satisfied; **AC18** names the `pull_request` trigger and is
therefore not. Two distinct claims, correctly kept apart.

**Disposition:** AC18 is discharged by the `pull_request`-triggered run once the PR opens. Expected:
conclusion `success` with the publish step `skipped`, which is what the dispatch run already
demonstrates the ref guards produce on a non-tag ref. **No remediation work is available or required
before then.**

---

## AC21 — PARTIAL, and the checkbox marginally exceeds its evidence

AC21 has two clauses.

**Clause 2 — PASS, independently verified.** "No test added or modified by this change invokes `npm`,
`gh`, or `git` as a real external process." Every external call in the changed suites goes through a
mocked seam; the searches for temporary-path facilities and `Start-Sleep` return zero matches across
both test directories. This is the substantive guarantee and it holds.

**Clause 1 — PARTIAL.** "The complete Pester suite passes with no network access available."

The recorded probe was re-executed by this review and reproduces exactly:

```
npm error code ECONNREFUSED
npm error FetchError: request to http://127.0.0.1:9/@danmoisan%2fdrm-copilot-mcp failed,
  reason: connect ECONNREFUSED 127.0.0.1:9
PROBE_NPM_EXIT=1
PROBE_GH_EXIT=1
Tests Passed: 3646, Failed: 0, Skipped: 9
```

The probe **does** establish what it claims about npm, and the caller's specific question — whether it
shows isolation rather than an unrelated failure — resolves affirmatively on four points: npm itself
ran and wrote its own diagnostics; the failure is `ECONNREFUSED` on `syscall connect`, a transport
failure rather than an `E404`, auth, or config failure; the refused address is exactly the configured
discard endpoint; and the requested URL is the real scoped-package registry path. `gh` is likewise
blocked. The suite ran inside the same `pwsh -Command` string as the probe, so it is structurally the
same session, and its counts and repo-wide coverage (6794 / 7073 = 96.0554 %) match this review's
independent run digit for digit.

**The residual, measured rather than argued.** A third probe added by this review shows the isolation
is proxy-level, not absolute:

```
=== PROBE raw socket ===
RAW_SOCKET_CONNECTED=TRUE
```

`System.Net.Sockets.TcpClient` reached `registry.npmjs.org:443` from inside the isolated session.
`HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` / `NPM_CONFIG_REGISTRY` bind proxy-aware clients but not a
raw socket, so "no network access available" is stronger than what was demonstrated.

**Disposition: left checked, graded PARTIAL, recorded.** Consistent with the prior cycle's decision,
the checkbox is not reverted, because unchecking would discard the verified clause 2 and the genuine
clause-1 work. The overstatement is confined to isolation *depth*, the artifact documents its
mechanism honestly in its `IsolationMethod:` field, and no conclusion about the change's correctness
depends on the difference. Recorded as **Minor m7** with a suggested one-line wording narrowing (name
the mechanism: "with npm and gh network access removed by process-scoped proxy isolation") rather than
as a remediation trigger.

This is the **only** criterion in the set whose checkbox asserts more than its evidence, and the excess
is marginal.

---

## Behavioural Requirements Traceability

Spot-checked against `spec.md` §4 to confirm the AC set covers the specified behaviour rather than a
subset.

| BR | Covered by | Status |
|---|---|---|
| BR-1 mockable seams | AC1 | PASS |
| BR-2 exact-version resolution | AC2, AC3 | PASS |
| BR-3 bounded two-phase polling | AC9, AC29 | PASS |
| BR-4 distinct failure states | AC6, AC7, AC8, AC10, AC30 | PASS |
| BR-5 dependency-first push order | AC4 | PASS |
| BR-6 inter-push gate | AC5 | PASS |
| BR-7 pre-push inverted check | AC11 | PASS |
| BR-8 post-push verification of the extension tag | AC5 (partial), `Invoke-ReleaseTagPush.Tests.ps1:238-266` | PASS |
| BR-9 Codex pin resolution | AC12 | PASS |
| BR-10 ref-based publish guard | AC14 | PASS |
| BR-11 tag/manifest equality | AC15 | PASS |
| BR-12 Layer A post-publish poll | AC16 | PASS |
| BR-13 `pull_request` trigger | AC13 | PASS |
| BR-14 Layer C reconciliation sweep | AC19 | PASS |
| BR-15 runbook | AC27 | PASS |

Every behavioural requirement has at least one acceptance criterion and none is orphaned. BR-8's
extension-tag propagation is asserted by a test the AC set does not name explicitly
(`Invoke-ReleaseTagPush.Tests.ps1:238-266`, "returns non-zero when the extension post-push
verification does not succeed"); the coverage exists, the AC wording simply does not enumerate it.

---

## Scope Boundaries

| Boundary | Verification | Result |
|---|---|---|
| `README.md` untouched (owned by #528) | `git diff --name-only` filtered | not in diff |
| `quality-tiers.yml` not added | `git diff --name-only` filtered | not in diff |
| `publish-extension.yml` untouched | `git diff --name-only` filtered | not in diff |
| No new external service dependency | Read of both workflows and all four modules | `gh` and `npm` only, both pre-existing assumptions per `spec.md` §6.3 |
| No credential-mechanism change | Read of `publish-mcp-npm.yml` | OIDC trusted publishing retained; no secret added |

---

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md
- Total AC items: 30
- Checked off (delivered): 29
- Remaining (unchecked): 1
- Items remaining: AC18 — "A green run of publish-mcp-npm.yml against the branch head exists,
  produced by the new pull_request trigger, and the run's publish-step conclusion is skipped."
```

**No checkbox was changed by this review.** AC18 remains correctly unchecked and is not checkable
until the PR-triggered run exists. AC21 remains checked with its PARTIAL grade and residual recorded
above.

---

## Overall

Both prior Blocking findings are discharged. R1 was verified by re-execution with a mutation-based
falsifiability proof rather than by reading the claim; R2 is satisfied for the dispatchable workflow
and forced-deferred for the one GitHub will not let anyone dispatch. All three prior Major findings
are resolved, with one leaving a marginal Minor residual. The acceptance-criteria set is complete
against `spec.md` §4's behavioural requirements, and exactly one criterion (AC21) carries a checkbox
marginally ahead of its evidence, deliberately and on the record.

`blocking_count == 0`. The remaining Major (M1) is a merge-gate obligation discharged automatically by
the PR-triggered runs, not a remediation-cycle obligation.
