# Code Review — Issue #526

- **Timestamp:** 2026-08-26T02-36
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `d9c148a7`
- **Base:** `main` @ merge base `b36179b2`
- **Reviewed surface:** 3 production `.ps1`, 5 test `.ps1`, 2 workflow `.yml`, 2 run-settings
  `.psd1`, 1 engineering runbook. Documentation and evidence artifacts read for corroboration.

---

## Overall Assessment

The change is well constructed. The three-layer design is sound and the layering argument is
correct: a workflow genuinely cannot detect its own non-existence, so Layer B has to live outside CI,
and Layer C is the only mechanism that can surface a divergence nobody went looking for. The
dependency-first push order with an inter-push gate is the right structural fix — it makes the
1.0.25 outcome (a consumer artifact pinning an unpublished dependency) impossible by construction
rather than by detection.

Two design decisions deserve specific credit because they are the ones that make the guards
falsifiable rather than decorative:

1. **The exact-version registry operand.** `Test-NpmVersionResolved` requires *both* exit code 0 and
   stdout equal to the requested version. The bare-package form resolves the `latest` dist-tag and
   would have passed throughout the 1.0.25 failure. The implementation gets this right and the test
   at `Invoke-ReleaseVerification.Tests.ps1:118-135` is constructed so that it fails against a
   bare-package implementation.
2. **Separating the pure classifier from the poller.** `Resolve-PublishStepConclusion` is a pure
   function over a deserialized payload, so every classification branch — including the two that a
   poll would rarely reach — is directly testable. This is what got the module from 82.61% to 90.22%
   without weakening any assertion.

The defects found are concentrated in one place: the polling budgets and the state token that budget
exhaustion maps to. Everything else is minor.

---

## The Six Judgment Points

### 1. AC18 and `modified-workflow-needs-green-run` — is the deferral acceptable?

**Verdict: not acceptable as a final disposition for `publish-mcp-npm.yml`; acceptable and forced for
`verify-published-releases.yml`. Recorded as Blocking finding B2, remediable before merge with no
code change.**

Reasoning, stated explicitly because this is the criterion execution could not satisfy.

The rule (`.claude/skills/feature-review-workflow/SKILL.md:70`) is unconditional in form: a diff to
`.github/workflows/**` is Blocking "unless evidence of a green workflow run against the branch head
is present". It contains no exception for "the PR is not open yet". More decisively, it *anticipates*
that exact situation and names the remedy at line 74: "A green `workflow_dispatch` run against the
branch head also satisfies the rule, not only a PR-context run. This mitigates the chicken-and-egg
case where a feature must land its CI gate before the gate can run in PR context."

That carve-out resolves the two files differently, which is why a single verdict on "the deferral"
would be wrong:

- **`publish-mcp-npm.yml`.** The branch head `d9c148a7` is on origin (verified:
  `git ls-remote --heads origin` returns it). The workflow already exists on the default branch and
  already carries `workflow_dispatch:`. So `gh workflow run publish-mcp-npm.yml --ref
  bug/tag-push-can-silently-skip-npm-publish-526` is available today. Under the new ref guards that
  dispatch produces `github.ref == refs/heads/bug/...`, which matches none of the three
  `startsWith(github.ref, 'refs/tags/mcp-server-v')` guards, so the version-equality step, the
  publish step, and the registry poll all skip. The run consumes no version number and should be
  green. The evidence the rule wants was obtainable and was not obtained.
- **`verify-published-releases.yml`.** Verified live:
  `gh run list --workflow=verify-published-releases.yml` returns
  `HTTP 404: workflow verify-published-releases.yml not found on the default branch`. GitHub resolves
  `workflow_dispatch` against the default branch, so this file cannot be dispatched until it lands.
  Its new `pull_request` trigger is the only path to a branch-head run, and that requires a PR. The
  deferral here is forced and is the correct disposition.

**What the deferral record gets right, and it is a lot.** Every factual claim in
`evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md` was independently reproduced during
this review, including the exact 404 string and the absence of any branch-head run among the eight
most recent `publish-mcp-npm.yml` runs. It names the owner, the exact deferred read-only invocation,
and the expected outcome per workflow. It does not overclaim: it states in terms that completing the
task "does not itself satisfy AC18". Leaving the AC18 checkbox unchecked was the correct call and is
strictly better than the alternative failure mode of checking it on the strength of an expectation.

**And the substantive obligation is discharged.** The reason this rule is usually painful for a
tag-triggered workflow is that no trigger can produce a branch-head run at all. This change fixes
that root condition: it adds a `pull_request` trigger to both workflows and ref-guards every
tag-dependent step so a PR run stays green rather than failing on an absent tag or a pre-existing
registry divergence. That design work — AC13 through AC17, all verified PASS — is the hard part, and
it is done and correct. What remains is one command.

**Recommendation:** dispatch `publish-mcp-npm.yml` against the branch head now and record the run URL
and publish-step conclusion in the existing artifact; take `verify-published-releases.yml` from the
PR-context run once the PR is opened. B2 clears at that point.

### 2. Coverage-measurement route — is it sound, and are the figures reproducible?

**Verdict: sound, and independently reproduced exactly. No caveat.**

The route's premise was verified rather than accepted. `mcp__drm-copilot__run_poshqc_test` resolves
its Pester run-settings from the installed VS Code extension bundle, not from the repository. The two
new production files were registered in the two in-repo `pester.runsettings.psd1` copies, which the
MCP runner does not read, so it emits no coverage row for either. The executor's response — run the
MCP tool as the pass/fail gate, then run the self-hosted module directly *afterwards* so that the
later run's `artifacts/pester/powershell-coverage.xml` is the one parsed — is correct, because both
runners write the same path and the second write wins.

Reproducibility was tested, not assumed. A fresh independent run during this review:

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
```

produced `Tests completed in 111.55s`, `Tests Passed: 3638, Failed: 0, Skipped: 9`, and a coverage
document that reproduces every recorded figure to the digit:

| Figure | Recorded by executor | Reproduced by this review |
|---|---|---|
| Sourcefile rows | 84 | 84 |
| Repo-wide | 6792 / 7071 = 96.0543% | 6792 / 7071 = 96.0543% |
| `Invoke-ReleaseTagPush.ps1` | 75 / 77 = 97.4026% | 75 / 77 = 97.4026% |
| `Invoke-ReleaseVerification.ps1` | 83 / 92 = 90.2174% | 83 / 92 = 90.2174% |
| `Invoke-ReleaseReconciliation.ps1` | 24 / 27 = 88.8889% | 24 / 27 = 88.8889% |
| Restricted to the 82-row baseline set | 6685 / 6952 = 96.1594% | 6685 / 6952 = 96.1594% |

The reasoning in `evidence/qa-gates/coverage-delta.2026-08-26T02-05.md` about *not* asserting the
restricted post-change figure against the 96.1433% baseline is also correct and worth endorsing. The
two denominators differ by construction, and asserting equality on the restricted set would silently
impose a 96.14% requirement on the Phase 3 added lines that no acceptance criterion states. Carrying
the no-regression obligation on the changed-line metric instead is what
`.claude/rules/general-unit-test.md` actually asserts. That artifact reasons about its own gate's
falsifiability, which is the right instinct.

One presentational note: registering a new file in `CodeCoverage.Path` moves the *unrestricted*
repo-wide figure down slightly (96.1433% to 96.0543%) purely because two files with entry-point
residue joined the denominator. That is the Coverage Exclusion Policy working correctly, and the
artifact explains it rather than hiding it.

### 3. The 499-line file — acceptable as shipped, or a finding in itself?

**Verdict: acceptable as shipped. Recorded as Minor finding m1, not as a violation. The plan's
decision to decline the helper extraction was correct.**

`Invoke-ReleaseVerification.ps1` measures 499 lines against a 500-line cap. It complies. There is no
rule against thin headroom, and inventing one would be reviewer-authored policy.

The plan's cost analysis for declining the extraction is accurate and was checked against the
repository rather than taken on trust. Splitting the five pure helpers (`ConvertFrom-JsonSafely`,
`Resolve-PublishStepConclusion`, `Get-RecoveryInstruction`, `ConvertTo-VerificationResult`,
`Get-CodexPinnedMcpVersion`) into a sibling module would require: a new `CodeCoverage.Path` entry in
**both** `pester.runsettings.psd1` copies (confirmed — there are exactly two, at
`scripts/powershell/PoshQC/settings/` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/`,
and they must stay in parity); a new test file; and a re-partitioned coverage denominator that
invalidates every per-file figure the plan records. Doing that at the end of a plan whose remaining
phases add nothing to the file would be a large, late, evidence-invalidating refactor undertaken to
buy headroom nobody was about to spend.

Two observations that qualify the verdict without changing it:

- The headroom was **consumed by condensing comment-based help**, not by adding logic. That is the
  less desirable of the two ways to reach 499, because comment-based help on a module whose whole
  purpose is to be operated by a human under release pressure is load-bearing documentation. Reading
  the file, the surviving help is still genuinely informative — each function's `.DESCRIPTION`
  explains *why* the behaviour is what it is, not just what it does — so the condensation did not
  cross into terseness. It should not be condensed further.
- If any future change touches this file, the extraction becomes mandatory rather than optional,
  because the "authorized remedy" the plan names for that case (condense help further) is no longer
  available at acceptable quality. The plan already records the extraction as the remedy; that record
  should be treated as binding on the next change, not as a suggestion.

`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` at 491 lines carries the same condition
with 9 lines of headroom and warrants the same note.

### 4. The nine deliberately uncovered lines — legitimate, or a coverage gap?

**Verdict: legitimate. Not a gap. Verified by enumerating the uncovered lines independently rather
than accepting the classification.**

Parsing `ci == 0` line elements from this review's own coverage run:

| File | Uncovered lines | What is actually there |
|---|---|---|
| `Invoke-ReleaseVerification.ps1` | 57, 58 | `Invoke-GhExe` body: `& gh @GhArgs 2>&1` and the return |
| | 74, 75 | `Invoke-NpmExe` body: `& npm @NpmArgs 2>&1` and the return |
| | 92 | `Invoke-Sleep` body: `Start-Sleep -Seconds $Seconds` |
| | 485, 496, 497, 498 | entry-point block body |
| `Invoke-ReleaseReconciliation.ps1` | 163, 164, 165 | entry-point block body |
| `Invoke-ReleaseTagPush.ps1` | 74, 75 | `Invoke-GitExe` body |

Every one is either a two-line wrapper whose only statement invokes the external process it exists to
isolate, or an entry-point body. Not one is business logic, a branch, or an error path.

Covering the seam bodies would require spawning a real `gh` or `npm` process or taking a real
wall-clock wait. That is prohibited three times over: by `.claude/rules/general-unit-test.md`
("Unit tests must not depend on external services", "real wall-clock waits ... prohibited in tests"),
by `.claude/rules/powershell.md` ("never mock `git`, `gh`, `actionlint`, or other executables
directly. Mock the wrapper function instead"), and by AC21/AC22. A test that covered line 92 would be
a policy violation that bought one coverage point.

Two details confirm the guard mechanism is genuinely exercised rather than merely uncovered:

- The guard **conditions** are covered while their **bodies** are not. Line 484
  (`if ($MyInvocation.InvocationName -ne '.')`) is covered and 485-498 are not; line 162 is covered
  and 163-165 are not. That is the signature of a dot-source guard evaluating false, which is exactly
  the intended behaviour and proves the guard works.
- The entry-point block is not entirely untested. `Invoke-ReleaseTagPush.Tests.ps1:473-489` executes
  the real entry point via `& $script:scriptPath -ConfirmToken 'no'` and asserts `$LASTEXITCODE` is
  2, which is why that file's entry point does not appear in the uncovered set. The verification
  module's entry point has no equivalent test because reaching it requires the seams to be live.

This is precisely the residue the Coverage Exclusion Policy describes and endorses: no production
file was excluded from measurement, the entry point's uncovered lines are visible in the metric as a
real cost, and both entry points are three to four lines long — the pressure the policy exists to
create is working.

### 5. Exit-code hygiene — do the workflow tests actually constrain the YAML?

**Verdict: yes, they constrain it, and I measured this rather than reasoning about it alone. They
constrain it at exactly the granularity `.claude/rules/ci-workflows.md` states, and no finer. The
residual weakness is positional blindness, recorded as Minor m6.**

First, the four `pwsh` steps this change adds, enumerated from the YAML:

| Workflow | Step | Deliberately-failing command | Remedy present |
|---|---|---|---|
| `publish-mcp-npm.yml` | Verify tag version matches the mcp-server manifest | none | `exit 1` / `exit 0` |
| `publish-mcp-npm.yml` | Verify the published version resolves on the registry | `npm view` on an absent version, once per poll | `$LASTEXITCODE = 0` **and** `exit 0` / `exit 1` |
| `verify-published-releases.yml` | Validate the reconciliation comparison offline | none | `exit 1` / `exit 0` |
| `verify-published-releases.yml` | Reconcile pushed tags against published versions | `git ls-remote`, `npm view` | two `$LASTEXITCODE = 0` resets **and** `exit 0` / `exit 1` |

All four comply. The `npm publish` step carries no `shell: pwsh` and is out of the rule's scope.

**Falsifiability, measured.** I replicated the shipped predicate and ran it against synthetic step
texts:

```
naked (no remedy)        -> False
with LASTEXITCODE reset  -> True
with explicit exits      -> True
```

A newly added `pwsh` step containing a deliberately-failing command and neither remedy **fails** the
assertion. The test is not vacuous. This matters because, as the change's own comments note, no local
toolchain stage executes a workflow `run:` block, so these two suites are the only local mechanism
that can catch the defect at all.

Three qualifications, stated so the assertion is not credited with more than it does:

1. **The disjunct mirrors the rule, so it cannot be tightened without diverging from policy.**
   `.claude/rules/ci-workflows.md` offers reset *or* explicit-exit as alternatives. A consequence is
   that deleting `$LASTEXITCODE = 0` from the registry-poll step would not fail the test, because
   that step also satisfies the `exit 0` / `exit 1` branch. That is correct behaviour, not a hole:
   under the rule the explicit `exit 0` on the success path is sufficient on its own, and the reset
   is defence in depth.
2. **The check is positional.** It matches `$LASTEXITCODE = 0` or `exit 0` plus `exit 1` *anywhere*
   in the step text. It does not verify the reset follows the failing command, nor that the success
   path is what reaches `exit 0`. A step with `exit 0` on a dead branch would pass. Tightening this
   would require parsing the `run:` block rather than pattern-matching it, which is a real cost for a
   narrow gain; recorded as m6 rather than as something to fix now.
3. **The step partition is well built and worth noting.** Both suites split the file on
   `^\s{6}-\s+name:` and the `publish-mcp-npm.yml` suite comments that the publish *job* and publish
   *step* share the name "Publish to npm" but sit at different indentation with no leading dash, so
   the partition never confuses them. I confirmed both share that name. The trigger-block extraction
   is likewise scoped to the `on:` block so a `pull_request` string elsewhere in the file cannot
   satisfy the trigger assertion. These are the details that decide whether a text-based YAML
   assertion is real or theatre, and they were handled.

**A separate empirical check on Layer C.** Because these tests assert over text, I additionally
executed the reconciliation wiring end to end to confirm the exit-code contract the sweep depends on
actually holds:

```
divergent   -> LASTEXITCODE=1     (UNPUBLISHED_TAG_VERSIONS: 9.9.9)
convergent  -> LASTEXITCODE=0     (UNPUBLISHED_TAG_VERSIONS: none)
offline step count=1 first=9.9.9
```

`exit N` inside a script invoked with `&` does propagate to `$LASTEXITCODE`, so
`verify-published-releases.yml:86-92` reads the reconciliation result correctly, and the workflow's
offline validation step reproduces the expected divergence verbatim. The sweep can signal.

### 6. `Get-ReconciliationReport` — sound engineering or unapproved scope creep?

**Verdict: sound engineering. The code is correct and policy-required. The finding is the missing
deviation record, recorded as Major M3 — the process gap, not the change.**

On the engineering merits it is clearly right:

- **A standing policy rule mandates it.** `.claude/rules/general-unit-test.md`, Coverage Exclusion
  Policy: "The correct response to a file that contains untestable lines is to refactor it — extract
  all logic into host-neutral, testable modules and leave only the thinnest possible wiring in the
  host-bound entry point." Before the extraction, the entry point computed the divergence, chose the
  message text, and derived the exit code — three decisions stranded in a host-bound block. After it,
  the entry point is three lines of wiring and every decision is in a pure function. That is the
  policy's stated remedy applied literally.
- **The measured effect is what the policy predicts**: 70.83% to 88.89%, achieved by making logic
  testable rather than by excluding anything or by weakening an assertion.
- **The seam is well chosen.** `Get-ReconciliationReport` returns `{ UnpublishedVersion, Message,
  ExitCode }` — the three things the caller needs and nothing else — and `ExitCode` is derived as
  `[int]$isDivergent`, so the exit contract cannot drift from the divergence computation. The two
  tests that cover it assert the message string and exit code for both polarities, which pins the
  contract the workflow depends on.
- **It costs nothing structurally**: no new file, no new coverage registration, no new run-settings
  parity obligation, no new external surface.

Against that, it is genuinely outside the plan. P5-T1 specifies `Get-UnpublishedTagVersion` and a
dot-source guard; P5-T3 specifies three named tests. The shipped file has two functions and nine
tests. And the plan has a phase titled "Operator Runbook and **Recorded Deviations**" which records a
different deviation (the Marketplace deferral) and not this one. The name
`Get-ReconciliationReport` appears in zero files across the entire feature folder — plan, spec,
issue, research, runbooks, and all 28 evidence artifacts.

So the executor did the right thing and did not say so. The distinction matters because the value of
a plan-plus-deviation-record process is that a reviewer can tell an intentional, policy-grounded
improvement apart from an unnoticed scope expansion, and here that had to be reconstructed from the
code. **Recommendation:** add a short deviation record naming the function, the Coverage Exclusion
Policy clause that motivated it, and the 70.83 to 88.89 measurement. No code change.

---

## Design and Implementation Notes

### The inter-push gate is correctly ordered, and the tests pin the ordering rather than assuming it

`Invoke-ReleaseTagPushGuarded` now iterates a two-entry table with the mcp dependency first and
returns on the first non-`RESOLVED` verification, so the extension tag is never *created* — not
merely never pushed — when the mcp publish fails. The test at
`Invoke-ReleaseTagPush.Tests.ps1:209-230` asserts all four conjuncts including
`@($gitLines | Where-Object { $_ -match "^tag .*(\s|^)v0\.0\.3(\s|$)" }).Count | Should -Be 0`, which
is the assertion that distinguishes "not pushed" from "not created".

The per-entry table also carries `SkipRegistry` and `RequiresCodexPin` flags, which keeps one
composition entry point serving both release paths without a branch inside the loop body. Given that
the extension publishes to the Marketplace and has no npm version for check (c), this is the right
shape.

### The Codex pin guard is discriminating, though only indirectly

`AC12` asks that the guard pass the **pinned** string, not the manifest version, to the registry
check. No test asserts that directly. It is nonetheless pinned, by a nice piece of fixture design:
the `Test-NpmVersionResolved` mock at `Invoke-ReleaseTagPush.Tests.ps1:36-40` returns true *only* for
the pinned `9.9.9`, while the manifests yield `0.0.2` / `0.0.3`. If the guard passed the manifest
version, the mock would return false and the success-path test's `$result | Should -Be 0` would fail.
The mock's comment explains that the two guards have opposite polarity and that this is why it
discriminates on version rather than returning a blanket value. Indirect but genuinely constraining.

### `Invoke-FullReleaseFlow` propagation needs no change, and correctly received none

BR-8 requires the flow to propagate a verification failure rather than returning 0. Checked:
`Invoke-FullReleaseFlow.ps1:387-391` already does `if ($tagPushExit -ne 0) { ...; return 1 }`. The
diff correctly leaves that file untouched.

### The state machine short-circuits in the right order

`Invoke-TagPublishVerification` runs (a), then (b), then (c), returning at the first negative, so the
reported state names the earliest point of divergence. `RunExistence` and `StepConclusion` are
reported alongside the token, so a failure is actionable without a second run. `ConvertTo-VerificationResult`
derives `ExitCode` as `0` only for `RESOLVED`, in one place, so no caller can disagree with the state
machine about success.

### Primary defect: polling budgets (Blocking B1) and state-token reuse (Major M1)

The one substantive problem is documented in full in the policy audit. In short:

- `Invoke-TagPublishVerification` (`Invoke-ReleaseVerification.ps1:445-477`) forwards a single
  `$IntervalSeconds` / `$MaxAttempts` pair to all three checks, and
  `Invoke-ReleaseTagPushGuarded` (`Invoke-ReleaseTagPush.ps1:244-250`) supplies neither, so the
  release path runs every check at the module defaults of 10 s x 18 = 3 minutes. `spec.md` §3.4
  specifies 20 s x 60 (20 min) for check (b) and 15 s x 40 (10 min) for check (c).
- `Test-PublishStepConclusion` (`:304`) returns `RUN_FAILED` on exhaustion, the same token a genuinely
  failed run produces, contradicting §3.4's requirement that exhaustion be distinct from a negative
  result and misdirecting the runbook's `RUN_FAILED` recovery ("read the run logs") at a run that had
  simply not finished.

Measured counter-evidence, recorded honestly: real runs complete in 80 s (`publish-mcp-npm` run
32930241401) and 112 s (`publish-extension` run 32930239459), inside the 170 s sleep budget. The
margin is real but under 2x, and the consequence of exceeding it is an unrecoverable mcp version
number plus a forced bump, because a re-run hits the pre-push inverted check and returns
`VERSION_CONSUMED_ELSEWHERE`.

**Suggested remedy** (small, and it also closes M1):

```powershell
# Invoke-ReleaseVerification.ps1 — per-check budgets, defaulted to the spec §3.4 table
[int]$RunIntervalSeconds   = 10, [int]$RunMaxAttempts   = 18,   # check (a)
[int]$StepIntervalSeconds  = 20, [int]$StepMaxAttempts  = 60,   # check (b)
[int]$NpmIntervalSeconds   = 15, [int]$NpmMaxAttempts   = 40    # check (c)
```

and return a distinct `RUN_INCOMPLETE` token from `Test-PublishStepConclusion` on exhaustion, with
its own `Get-RecoveryInstruction` entry ("the run had not reached a terminal conclusion within the
budget; re-run the verifier before concluding") and its own runbook section. Adding a state token is
a spec-level change, so if that is not acceptable within this issue, the minimum fix is the per-check
budgets alone, with M1 filed as a follow-up.

### Minor implementation observations

- **Expression interpolation into a PowerShell literal** (m2).
  `$version = '${{ steps.resolve-publish-version.outputs.publishVersion }}'` in
  `publish-mcp-npm.yml`. The value is a tag-derived string; an apostrophe in a tag name would break
  the literal. Prefer `env:` plus `$env:PUBLISH_VERSION`. Actionlint does not flag it (exit 0
  confirmed) because the expression is not a known untrusted input.
- **`param()` leakage across the dot-source** (m3). `Invoke-ReleaseTagPush.ps1:48` dot-sources the
  verification module, binding its nine defaulted parameters into the consumer's script scope. No
  collision exists today; the coupling is invisible. Guarding the module's `param()` block or moving
  the shared functions into a `.psm1` would remove it.
- **The pin guard covers one of two committed config copies** (m4).
  `Invoke-ReleaseTagPush.ps1:261` reads `$RepoRoot/.codex/config.toml`; a second copy exists at
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`. Both
  currently pin `1.1.2`. BR-9 and AC12 are singular so the criterion is met, and copy equality is
  #522's; noted so the narrowing is visible.
- **An inaccurate justification comment** (m5). `verify-published-releases.yml:66-70` says a
  no-matching-tag listing "makes this listing exit non-zero". `git ls-remote` exits 0 whenever it
  reaches the remote; non-zero on no-match needs `--exit-code`. The reset is harmless; the reason
  given is wrong.
- **Two files near the 500-line cap** (m1): 499 and 491.

---

## Test Quality

Strong. Notable properties, all verified by reading the files rather than from the evidence:

- **Determinism.** Every wait goes through the mocked `Invoke-Sleep` seam. Independently grepped
  across all five test files for `New-TemporaryFile`, `GetTempFileName`, `env:TEMP`, `TestDrive`, and
  `Start-Sleep`: **zero matches**. Poll counts are asserted exactly (`Should -Invoke -Times N
  -Exactly`), including the off-by-one that matters — a run found on attempt 1 sleeps 0 times, on
  attempt N sleeps N-1 times, and an exhausted budget of M sleeps M-1 times.
- **Fixture design that does work.** The opposite-polarity `Test-NpmVersionResolved` mock discussed
  above; the `neverAttempt = 999` sentinel that makes "budget exhausted" a first-class arrangement;
  the `viewPayload` indirection that lets one mock serve six state-machine tests.
- **Tests that would fail against the wrong implementation.** The AC3 test asserts the captured npm
  operand, not just the boolean, and its comment states why: without the operand assertion it would
  pass against the bare-package form, which is the defect the issue's own proposal contained.
- **Comments explain the *why*.** `Invoke-ReleaseVerification.Tests.ps1:209-214` explains that the
  absent-JOB path is distinct from the absent-STEP path *and* that strict mode means an omitted
  property would throw before the branch under test is reached. That is the kind of note that keeps a
  later maintainer from "simplifying" a fixture into uselessness.

Gaps:

- No test constrains the budgets `Invoke-ReleaseTagPushGuarded` actually uses, which is why B1 was
  not caught locally. A test asserting the `MaxAttempts` forwarded to each check would have.
- `Invoke-ReleaseVerification.Tests.ps1:286-290` pins the check-(b) exhaustion token as `RUN_FAILED`,
  so it actively locks in M1.
- `Invoke-ReleaseTagPush.Tests.ps1:73-77` mocks `Get-Content` for the whole `Describe`. It is scoped
  and justified (the Codex config must be supplied in memory), and the `Get-NpmVersion` context
  re-declares it inline, but a broad mock of a core cmdlet is worth keeping an eye on as the file
  grows.

---

## Documentation

`docs/engineering/missed-npm-publish.runbook.md` is good operator documentation: one section per
state, an explicit "Is the version consumed?" line per state (which is the fact that decides retry
safety), both delete-and-re-push preconditions under stable single-line headings, and an unambiguous
statement that disposition is a human decision. It correctly states that the current `npm unpublish`
policy is unconfirmed rather than asserting a rule.

One correction needed, tied to M1: the `RUN_FAILED` section (`:58`) defines the state as "A run
existed for the tag ref and reached conclusion `failure` or `cancelled`". That is not true when the
token arose from check-(b) budget exhaustion, and the prescribed recovery ("Read the run logs") is
the wrong first action for that case.

---

## Summary of Findings

| ID | Severity | Summary |
|---|---|---|
| B1 | Blocking | Per-check polling budgets from `spec.md` §3.4 not implemented; one 18x10 s budget for all three checks |
| B2 | Blocking | `modified-workflow-needs-green-run`: no green branch-head run for either workflow |
| M1 | Major | Check-(b) budget exhaustion returns `RUN_FAILED`, indistinguishable from a failed run |
| M2 | Major | AC21's "no network access available" clause is checked without supporting evidence |
| M3 | Major | `Get-ReconciliationReport` deviates from the plan with no deviation record |
| m1 | Minor | Two files within 10 lines of the 500-line cap (499, 491) |
| m2 | Minor | GitHub expression interpolated into a PowerShell string literal |
| m3 | Minor | Dot-source imports a full `param()` block into the consumer's scope |
| m4 | Minor | Codex pin guard reads one of two committed config copies |
| m5 | Minor | `git ls-remote` exit-code justification comment is inaccurate |
| m6 | Minor | Workflow exit-code assertions are position-blind |
