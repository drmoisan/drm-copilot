# Code Review — Issue #526 (Cycle-1 REAUDIT)

- **Timestamp:** 2026-08-26T04-33
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `515b4d97`
- **Base:** `main` @ merge base `b36179b2`
- **Prior review:** `code-review.2026-08-26T02-36.md`
- **Verdict:** Blocking 0, Major 1, Minor 10. No code change is required to clear the blocking gate.

## Scope Reviewed

Read from the diff against `main`, not from the remediation summary.

| Area | Files |
|---|---|
| Production PowerShell | `Invoke-ReleaseVerification.ps1` (new, 421), `Invoke-ReleaseVerificationHelpers.ps1` (new, 156), `Invoke-ReleaseReconciliation.ps1` (new, 166), `Invoke-ReleaseTagPush.ps1` (modified, 278) |
| Workflows | `publish-mcp-npm.yml` (modified), `verify-published-releases.yml` (new) |
| Test PowerShell | 4 dev-tools suites, 2 workflow-invariant suites |
| Configuration | `pester.runsettings.psd1` x 2 (byte-identical, `diff` exit 0) |
| Documentation | `docs/engineering/missed-npm-publish.runbook.md` (new), 70 feature-folder Markdown artifacts |

Languages with changed files: PowerShell only. No TypeScript, Python, C#, or JavaScript.

---

## What the Module Split Did to the Design

R1 forced the four pure helpers out of `Invoke-ReleaseVerification.ps1` into a sibling file because
the parent stood one line under the 500-line cap and the six per-check budget parameters would not
fit. This is a mechanically motivated split, and the risk with such splits is that the seam lands
somewhere arbitrary. It did not here.

The partition is **pure versus impure**, which is the correct axis:

- `Invoke-ReleaseVerificationHelpers.ps1` holds `ConvertFrom-JsonSafely`, `Get-RecoveryInstruction`,
  `ConvertTo-VerificationResult`, `Get-CodexPinnedMcpVersion`. Every one is a total function of its
  parameters with no external call, no filesystem access, and no wait. Its test file registers no
  mock at all — the strongest available evidence that the partition is real. Coverage: **29 / 29 =
  100 %**.
- `Resolve-PublishStepConclusion` stayed behind. It is also pure, so this is the one asymmetry, but
  it is defensible: it is the classifier the polling loop calls on every completed payload and reads
  only from that loop's deserialized run object, so it belongs with the check it serves rather than
  with the general-purpose helpers.

The dot-source direction is correct and deliberately documented at
`Invoke-ReleaseVerification.ps1:49-54`: helpers are dot-sourced rather than imported as a module so
their functions resolve in every consumer scope, including `Invoke-ReleaseTagPush.ps1`, which
dot-sources the verification module and calls `Get-CodexPinnedMcpVersion` transitively. The comment
states the reason in place rather than leaving a reader to infer it.

**Cost of the split, and it is real (Minor m10).** The parent file's coverage fell from 90.22 % to
**86.15 %**, not because anything regressed but because four fully covered functions left the
denominator, concentrating the uncoverable seam bodies in a smaller file. The margin above the 85 %
floor is now 1.15 points, roughly one seam line. This is not a defect, but it is a constraint a
future editor should know about before adding another wrapper seam to this file.

---

## Correctness

### Per-check budgets — verified by execution, not by reading

The composition entry point now declares six budget parameters
(`Invoke-ReleaseVerification.ps1:353-358`) and forwards each to its own check: check (a) at
`:362-366`, check (b) at `:372-377`, check (c) at `:387-394`. The script-level `param()` block
mirrors them (`:40-45`) and the entry-point block forwards all six explicitly (`:403-416`) with a
comment naming the defect being prevented.

`Invoke-ReleaseTagPushGuarded` (`:244-250`) supplies **none** of them and relies on the callee's
defaults. That is a legitimate composition, but it means the end-to-end result is a property of the
default values rather than of anything the release path states, so it was tested by execution rather
than by inspection.

A reviewer probe dot-sourced the real tag-push script, mocked only the three check entry points
(never `Invoke-TagPublishVerification`, so the composition under test is real), and ran
`Invoke-ReleaseTagPushGuarded -ConfirmToken yes`:

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18      -> 3 min   (spec §3.4 ceiling: 3 min)
CHECK_B_CALLS=1 INTERVAL=20 MAX=60      -> 20 min  (spec §3.4 ceiling: 20 min)
CHECK_C_15S_SLEEPS=39  across 40 attempts -> 10 min  (spec §3.4 ceiling: 10 min)
```

Mutating the check-(b) defaults back to the pre-fix shared pair made the probe fail with
`Expected 20, but got 10`, so the verification discriminates. **The defect is genuinely fixed on the
path that matters.**

The sleep arithmetic is correct throughout and is documented at `:150-153`: a sleep is taken only
between attempts, so N attempts produce N-1 sleeps. The observed 39 sleeps across 40 npm attempts
confirms the check-(c) loop at `:387-394` implements the same convention as
`Wait-ForWorkflowRun:184-186` and `Test-PublishStepConclusion:289-291`. Consistency across all three
loops is worth noting — an off-by-one in one of them would be easy to introduce and hard to see.

### The `RUN_INCOMPLETE` state split

`Test-PublishStepConclusion:296` now returns `RUN_INCOMPLETE` on budget exhaustion instead of
`RUN_FAILED`. The distinction is real and the code makes it visible in three places at once: the
return value, the `.OUTPUTS` block at `:259-263`, and the inline comment at `:294-295` ("The budget
expired without the run ever reporting status 'completed', so no conclusion was observed. That is not
the same fact as an observed failure.").

`RUN_FAILED` retains its original meaning at `Resolve-PublishStepConclusion:219-221` — an observed
terminal `failure` or `cancelled` conclusion. The six original tokens are unchanged, still distinct
literals, and still each covered by a test. Nothing was collapsed to make room for the seventh.

The recovery instruction at `Invoke-ReleaseVerificationHelpers.ps1:78` is the right one and says the
right thing: "Re-run the verifier rather than reading the run logs; the logs of an unconcluded run
cannot answer whether the publish succeeded." That sentence is the whole justification for the state
existing, stated where an operator will encounter it.

**Residual (Minor m9).** The runbook tells the operator to raise the budget with `-StepMaxAttempts`
or `-StepIntervalSeconds` (`missed-npm-publish.runbook.md:70-71`). Those parameters exist on
`Invoke-ReleaseVerification.ps1` (`:42-43`) but **not** on `Invoke-ReleaseTagPushGuarded`, which
exposes only `ConfirmToken` and `RepoRoot`. The advice is correct for the prescribed re-run path (the
standalone verifier) and wrong for the release path, which cannot be tuned at all. `spec.md` §8.1
asserts "Budgets are configurable parameters, not constants"; that holds for the verifier and not for
the release entry point.

### The inter-push gate

`Invoke-ReleaseTagPush.ps1:208-268` is the structural heart of the fix and it reads correctly. The
loop body is create -> push -> verify -> (mcp only) Codex pin guard, with an early `return 1` on every
negative branch. Because the mcp entry is first in the array literal, a non-`RESOLVED` mcp
verification returns before the extension entry is ever reached, so **zero** extension tag creations
and **zero** extension pushes occur. That is exactly the property that makes the 1.0.25 outcome
structurally impossible, and it is pinned by test at
`Invoke-ReleaseTagPush.Tests.ps1:215-236`, which asserts one push, that it carries the mcp tag, and
that no tag-creation invocation carries the extension tag.

The pre-push inverted check at `:198-201` is placed before any tag creation, so the
`VERSION_CONSUMED_ELSEWHERE` abort leaves the repository untouched. The test at `:289-322` asserts
zero pushes **and** zero tag creations **and** that `Invoke-TagPublishVerification` was never called —
three independent facts, which is the right level of paranoia for an irreversible operation.

One design point worth recording favourably: the `SkipRegistry` flag on the extension entry
(`:229`) carries an in-place comment explaining that the extension publishes to the Marketplace and
therefore has no npm version for check (c) to resolve. A reader encountering a check being skipped on
a release path will ask why; the answer is at the call site.

### The Codex pin guard

`:256-267` reads the config with `-ErrorAction SilentlyContinue` and coerces to `[string]`, so an
unreadable file yields an empty string rather than `$null`. The guard then tests
`(-not $pinnedVersion) -or (-not (Test-NpmVersionResolved ...))`, so an unreadable config is reported
explicitly rather than passing over. The comment at `:259-260` states this. Good defensive shape for
a guard whose failure mode would otherwise be silent.

### Workflows

`publish-mcp-npm.yml` is coherent. All three tag-dependent steps carry the same ref guard
`startsWith(github.ref, 'refs/tags/mcp-server-v')`, and zero steps are guarded on
`github.event_name` (verified: `grep -n "github.event_name" .github/workflows/publish-mcp-npm.yml`
returns nothing). The comments at `:68-70`, `:88-91`, and `:97-100` each explain why that particular
step needed the guard, and the third one is the most valuable: it records that the publish job still
runs on a pull request because its `needs` is satisfied, so an unguarded poll would query a version
the skipped publish never produced and would make the required green branch-head run unobtainable.
That reasoning is not obvious from the YAML and would have been expensive to rediscover.

`verify-published-releases.yml` splits into an always-run offline validation step (`:36-46`) and a
schedule-only sweep (`:50-95`). The split is what makes a PR run non-empty and simultaneously
incapable of failing on a pre-existing divergence — the 1.0.12 gap the sweep exists to surface would
otherwise fail every PR run. `VerifyPublishedReleasesWorkflow.Tests.ps1:78-91` pins both halves: the
sweep must carry the event-name gate and the offline step must **not**. Asserting the negative is the
part that matters and it is present.

Exit-code hygiene per `.claude/rules/ci-workflows.md` is correct in all four added `pwsh` steps
(explicit `$LASTEXITCODE = 0` after each expected failure, plus explicit `exit 0` / `exit 1` on the
success paths).

---

## Test Quality

Strong overall. Notable properties:

- **Falsifiability is engineered, not assumed.** `Invoke-ReleaseVerification.Tests.ps1:105-122` does
  not merely assert that the registry check fails for an absent version; it asserts the captured
  operand is `@danmoisan/drm-copilot-mcp@1.0.25`, with a comment stating that without the operand
  assertion the test would pass against a bare-package implementation. That is the exact defect the
  issue's own proposal contained, and the test is written so it cannot pass over it.
- **Deterministic seam state.** The `BeforeEach` block at `:25-77` uses "OnAttempt" knobs so a test
  can place a result on the first attempt, a later attempt, or never. All three external surfaces are
  mocked, so no real `gh`, `npm`, or wall-clock wait occurs.
- **Budget pinning after the parameter split.** `:43-50` pins all three budgets to 3 with a comment
  explaining that the pre-existing sleep-count assertions were written against a single shared budget
  and remain valid unchanged. Without that, the split would have silently changed the meaning of nine
  existing tests.
- **The check-(c) budget test is the load-bearing one.** `:350-362` asserts 40 npm invocations and 39
  sleeps filtered to `$Seconds -eq 15`. The interval filter is what excludes check (a)'s 10-second and
  check (b)'s 20-second sleeps; without it the assertion would be ambiguous.
- **Purity of the helpers suite.** `Invoke-ReleaseVerificationHelpers.Tests.ps1` registers no mock
  whatsoever. For a file claiming to hold only pure functions, that is the proof.

### Weaknesses

**m8 — the call site is unpinned.** No test asserts what `Invoke-ReleaseTagPushGuarded` passes to
`Invoke-TagPublishVerification`. The three AC29 tests
(`Invoke-ReleaseVerification.Tests.ps1:322-362`) pin the composition entry point's defaults, which is
where the values live today; but if a future edit added explicit arguments at
`Invoke-ReleaseTagPush.ps1:244-250`, every existing test would still pass while the release path ran
the wrong budgets. That is the same shape as the original R1 defect. The reviewer probe used in this
audit is a ready-made regression test: mock the three check entry points rather than
`Invoke-TagPublishVerification`, drive through `Invoke-ReleaseTagPushGuarded`, and assert the
budgets each check received.

**m6 — position-blind exit-code assertions.** `PublishMcpNpmWorkflow.Tests.ps1:145-147` and
`VerifyPublishedReleasesWorkflow.Tests.ps1:101-103` accept `$LASTEXITCODE = 0` **anywhere** in the
step text. A reset placed before the failing command would satisfy the assertion while leaving the
defect the rule exists to catch. The prior review measured the predicate as falsifiable against a
naked `pwsh` step, so it is not vacuous — but it is weaker than the rule it enforces.

**m1 — headroom.** `Invoke-ReleaseTagPush.Tests.ps1` grew from 491 to **497** lines when the mock
signature was corrected. Three lines remain under the cap. The next addition to this file forces a
split.

---

## The Mock-Signature Correction — Judgment

The `Invoke-TagPublishVerification` mock at `Invoke-ReleaseTagPush.Tests.ps1:41-72` previously
declared the two parameters R1 replaced and stayed green only because the caller passes neither.

**Authorising the fix inside this cycle was the right call.** The stale signature was introduced by
this cycle's own change, not inherited; a test double that no longer mirrors its subject is precisely
the drift that lets a suite pass against an implementation it has stopped describing; and the fix is
mechanical with no behavioural surface. Opening a new remediation cycle would have been
disproportionate to a parameter-list edit in a mock.

**The fix is complete.** All twelve parameters plus the switch are declared at `:42-55` and match
`Invoke-ReleaseVerification.ps1:345-360` exactly. The executor's audit of the other two mocks
reproduces independently:

| Mock | Declares | Real signature | Parity |
|---|---|---|---|
| `Test-NpmVersionResolved` (`:36-40`) | `Version`, `PackageName` | `Invoke-ReleaseVerification.ps1:124-128` | yes |
| `Get-CodexPinnedMcpVersion` (`:73-77`) | `ConfigContent`, `PackageName` | `Invoke-ReleaseVerificationHelpers.ps1:137-143` | yes |

One structural note: this class of defect is invisible to every gate in the repository. PSScriptAnalyzer
does not compare a Pester mock's `param()` block against its subject, and a mock that over- or
under-declares parameters the caller never supplies runs green either way. The only reason it was
caught is that a human read the diff. Worth remembering when judging how much assurance a green suite
carries after a signature change.

---

## Documentation

The runbook (`docs/engineering/missed-npm-publish.runbook.md`, 216 lines) is unusually good for this
genre. Each of the seven states gets a **Meaning**, an **Is the version consumed?**, and a
**Recovery**, and the middle question is the one that decides whether a retry is safe — putting it in
every section is the right structural choice. The `RUN_INCOMPLETE` section (`:57-74`) closes with
"Do **not** re-dispatch the workflow and do **not** delete and re-push the tag from this state. A run
is still in progress; a second publishing run against the same version would race the first." That is
the failure mode a hurried operator would walk into, named explicitly.

The two delete-and-re-push preconditions (`:155-189`) are stated as jointly necessary with an explicit
"Neither precondition alone is sufficient", and the disposition section (`:191-208`) states that the
decision is human and never automated, and that the current `npm unpublish` policy is uncertain rather
than asserting a rule it has not verified. Matching wording strength to evidence strength, in a
document written under pressure to sound authoritative, is the harder choice.

Comment-based help across the four production modules consistently explains **why** rather than
restating **what** — `Test-NpmVersionResolved:111-118` on why the conjunction of exit code and stdout
equality is required; `Wait-ForWorkflowRun:147-153` on why `headBranch` matching needs no head-SHA
fallback and on the sleep-count convention; `Resolve-PublishStepConclusion:196-204` on why the job/step
lookup is hierarchical rather than flat (the publish job and publish step share a name, so a flat
search would be ambiguous). Each of these encodes a fact that was expensive to establish.

---

## Minor Findings (full list)

| ID | Location | Summary |
|---|---|---|
| m1 | `Invoke-ReleaseTagPush.Tests.ps1` (497) | 3 lines of headroom under the 500-line cap |
| m2 | `publish-mcp-npm.yml:105` | GitHub expression interpolated into a PowerShell literal; prefer `env:` |
| m3 | `Invoke-ReleaseTagPush.ps1:48` | Dot-source imports 13 defaulted `param()` variables into consumer scope |
| m4 | `Invoke-ReleaseTagPush.ps1:261` | Codex pin guard reads one of two committed `.codex/config.toml` copies |
| m5 | `verify-published-releases.yml:66-67` | Comment misstates `git ls-remote` exit behaviour; reset harmless, reason wrong |
| m6 | Both workflow suites | Exit-code assertions are position-blind |
| m7 | AC21 / `network-isolated-suite` artifact | "no network access available" overstates proxy-env isolation; raw socket measured reachable |
| m8 | `Invoke-ReleaseTagPush.ps1:244-250` | Call-site budgets unpinned by any test |
| m9 | `Invoke-ReleaseTagPushGuarded` | No budget parameters; runbook's tuning advice unreachable from the release path |
| m10 | `Invoke-ReleaseVerification.ps1` | Coverage margin narrowed to 1.15 points above the floor after the split |

None is remediation-blocking. m8 is the one with the clearest cost-to-benefit case for fixing now,
since the test already exists in this audit's working notes and pins the exact defect class that
opened this cycle.
