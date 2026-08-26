# 2026-08-23-tag-push-can-silently-skip-npm-publish (Spec)

- **Issue:** #526
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-24
- **Status:** Draft (research complete; ready for planning)
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; no `user-story.md`)
- **Authoritative research input:** `research/research.2026-08-24T12-45.md`

---

## 1. Context and Corrected Problem Statement

### 1.1 What was observed

Two `mcp-server-v*` releases published nothing to npm and reported no error anywhere.
`@danmoisan/drm-copilot-mcp` versions `1.0.12` and `1.0.25` are absent from the registry while both
tags exist (`issue.md:44-49`). For `1.0.25` the consequence reached users: both `.codex/config.toml`
copies at tag `v1.0.25` pinned `@danmoisan/drm-copilot-mcp@1.0.25`, so
`npx -y @danmoisan/drm-copilot-mcp@1.0.25` failed outright for every consumer of extension `1.0.25`
between 2026-08-15 and 2026-08-17 (`issue.md:51-57`).

The tag push is the irreversible point of no return. Once a version number is consumed on npm it is
reserved permanently, so `1.0.25` can never be republished under that number.

### 1.2 The corrected problem statement

The research artifact supersedes the issue's own hypotheses. Three corrections are load-bearing and
must not be re-litigated by the plan.

**Correction 1 — sequential pushing is already the current behaviour.** The issue proposes
(`issue.md:99`) making `Invoke-ReleaseTagPush.ps1` "push the two tags sequentially ... rather than
pushing both and returning". The script already issues two separate single-ref pushes in a loop
(`Invoke-ReleaseTagPush.ps1:188-202`), and that shape is pinned by test
(`Invoke-ReleaseTagPush.Tests.ps1:63-70`). Sequential pushing was in effect during **both** known
failures. Research `## 4` D1 and D3.

The real gap is narrower and entirely different: **nothing waits, polls, or confirms anything
between or after the two pushes.** The automation's only success criterion is `git push` exit code 0
(`Invoke-ReleaseTagPush.ps1:198-204`), and the flow returns 0 immediately afterwards
(`Invoke-FullReleaseFlow.ps1:388-394`). A zero exit from `git push` does not imply that a push event
was created, still less that a publish occurred — the "Everything up-to-date" case also exits 0 and
creates no event (research D2). **No achievable improvement to the push command can make exit code 0
a proof of publication.** Only an out-of-band observation can.

A plan built on "make the pushes sequential" would ship a change that was already present when both
failures occurred, and would assert nothing new. Under `.claude/rules/plan-acceptance-gates.md` that
is the shape of a gate that cannot fail.

**Correction 2 — the root cause is not confirmable from inside this repository, and may never be.**
The documented tag-push suppression threshold is *more than three tags in one push*
(research `## 3`); these releases pushed two tags in two separate pushes, so the documented limit
does not explain them, and no other documented mechanism covers a two-ref case. Confirming or
refuting an event-delivery loss requires GitHub's internal event log, which is not available for a
personal repository through any API and would require a GitHub Support ticket (research `## 5` R1,
`## 12`, Automation Feasibility). **This specification is therefore constructed to be sound without
depending on a root cause: it specifies detection, gating, and recoverability, not a targeted
repair.**

**Correction 3 — the issue's proposed registry check is itself a gate that cannot fail.** The issue
proposes `npm view @danmoisan/drm-copilot-mcp version` (`issue.md:98`). That command resolves the
`latest` dist-tag, not the version under test. At the time of the `1.0.25` failure `latest` was
`1.0.24`, so the proposed check would have exited 0 and **passed on the exact failure it is being
proposed to catch** (research D4). The decisive form is
`npm view @danmoisan/drm-copilot-mcp@<exact-version> version`, which exits non-zero (E404) when the
specific version does not exist.

### 1.3 Why detection must be out-of-band

**A workflow cannot detect its own non-existence.** Any missing-run detector must live outside the
workflow — in the release tooling or in a separate scheduled workflow (research `## 6.1`). This is
the governing architectural constraint on the fix.

### 1.4 Why the miss is unrecoverable today

`publish-mcp-npm.yml:60-61` guards the publish step on `github.event_name == 'push'`. A
`workflow_dispatch` re-run therefore builds everything and skips the publish step, concluding
`success` while publishing nothing. `publish-extension.yml:63` guards on the **ref**
(`startsWith(github.ref, 'refs/tags/v')`), so the extension workflow *is* recoverable by dispatching
against the release tag. The asymmetry is the reason a missed mcp run can only be recovered by
deleting and re-pushing the tag — a destructive operation (research `## 1.1`, `## 7.2`).

---

## 2. Scope

### 2.1 In scope

1. **Layer B — out-of-band per-tag verification in the release tooling.** A new dot-sourceable
   PowerShell module providing bounded, mockable polling for the three checks: run existence,
   publish-step conclusion, and exact-version registry resolution.
2. **Push ordering and inter-push gating in `Invoke-ReleaseTagPush.ps1`.** Push the mcp
   (dependency) tag first, verify it to `RESOLVED`, and push the extension (consumer) tag only then.
3. **A pre-push inverted registry check** that refuses to proceed when the target version is already
   present on the registry.
4. **Layer A — in-workflow publish verification** in `.github/workflows/publish-mcp-npm.yml`: a
   tag/manifest version-equality assertion and a post-publish exact-version registry poll.
5. **A ref-based publish guard** in `publish-mcp-npm.yml`, making a missed run recoverable by a
   single non-destructive dispatch that consumes no version number.
6. **A `pull_request` trigger on `publish-mcp-npm.yml`.** This is a hard precondition of touching
   that file at all — see `## 6.1`.
7. **The Codex pin registry-resolution guard** (the online half of the #522 boundary), asserting
   that the version pinned in the committed `.codex/config.toml` resolves on the registry.
8. **Layer C — a scheduled reconciliation sweep** comparing the `mcp-server-v*` tag set against the
   published version set and raising a visible signal on divergence. This is the only retroactive
   layer: it would have surfaced the `1.0.12` gap without anyone running a release.
9. **An operator runbook** covering each failure state and the human-only disposition decision for
   an already-consumed version number.

### 2.2 Out of scope

- **Root-cause confirmation of the dropped push events.** Not obtainable from this repository or
  through `gh` for a personal repository (research `## 5` R1, `## 12`, Automation Feasibility). No
  criterion in this specification depends on knowing why the events went missing. The cheap local
  diagnostics enumerated in research `## 12.1` may be run opportunistically, but recording their
  output cannot fail and is therefore not an acceptance criterion.
- **The `README.md` correction.** `README.md:401-402` misstates the npm publish credential as
  `NPM_TOKEN` and omits `--provenance`; the workflow in fact uses OIDC trusted publishing and no
  secret at all (research `## 9.1`). This is **owned by issue #528** and must not be fixed here. It
  is referenced only because it would misdirect an operator debugging a failed publish.
- **The offline pin-equals-manifest test.** **Owned by issue #522.** See `## 5` for the boundary; the
  two guards cannot be the same test.
- **`quality-tiers.yml`.** The file is absent from the repository root although
  `.claude/rules/quality-tiers.md` declares it authoritative (research `## 9.2`). Known pre-existing
  environment defect. Noted only; no fix proposed and no criterion depends on it. Treat the affected
  release tooling as T4; the uniform line-coverage threshold of 85% applies at every tier regardless.
- **Automated delete-and-re-push recovery.** Destructive and unsafe unconditionally. Documented as a
  precondition-gated human procedure in the runbook instead (research Automation Feasibility).
- **Any change to `publish-extension.yml`'s publish semantics.** Its ref-based guard is the model
  being adopted, not a target of change.
- **Disposition of already-consumed version numbers** (`npm deprecate`, `npm unpublish`, hotfix, or
  no action). A human judgment call; the runbook documents the options, automation does not choose.

### 2.3 Explicitly excluded systems, integrations, and datasets

- No change to the npm publishing credential mechanism (OIDC trusted publishing is retained).
- No change to `secrets.VSCE_PAT` or the Marketplace publish path beyond read-only verification.
- No new external service dependency: `gh` is already assumed authenticated by the release flow
  (`Invoke-FullReleaseFlow.ps1:352,364,369`) and `npm view` needs no authentication for a public
  package.

---

## 3. Verification State Model

The per-tag model below is taken from research `## 11`. Each state is distinct, and each failure
state carries its own recovery instruction. Collapsing states into a single boolean is a defect: a
bare "registry lookup failed" does not tell an operator which recovery to perform.

### 3.1 Success path

```
PUSH_ACCEPTED      git push exited 0        (necessary; proves nothing further)
  -> RUN_OBSERVED       check (a): a workflow run exists for the tag ref
     -> RUN_TERMINAL       the run reached a terminal conclusion
        -> STEP_PUBLISHED     check (b): publish-step conclusion is success, not skipped
           -> RESOLVED           check (c): the exact version resolves on the registry  [SUCCESS]
```

### 3.2 Failure states and recovery

| State | Meaning | Recovery instruction |
|---|---|---|
| `VERSION_CONSUMED_ELSEWHERE` | Pre-push check (c) **succeeded**: the target version already exists on the registry | Abort before pushing anything. The version number is already taken; bump again. |
| `NO_RUN` | Check (a) budget exhausted; no run observed for the tag ref | With the ref-based guard in place: `gh workflow run publish-mcp-npm.yml --ref <tag>` — non-destructive, consumes no version number. Without it: precondition-gated tag delete and re-push (runbook only). |
| `RUN_INCOMPLETE` | Check (b) budget exhausted; the run had not reached a terminal conclusion | Re-run the verifier. The run may still complete; do not read the run logs as though it had failed. |
| `RUN_FAILED` | The run reached conclusion `failure` or `cancelled` | Read the run logs. The version may or may not be consumed; evaluate check (c) before any retry. |
| `STEP_SKIPPED` | Job concluded `success` but the publish step concluded `skipped` | The publish guard did not match. The version is **not** consumed. Fix the guard or the trigger and re-dispatch. |
| `STEP_MISSING` | The named job or step was not found in the run | The workflow was renamed. Treat as failure, never as absence of evidence. |
| `UNRESOLVED` | Check (c) budget exhausted after check (b) succeeded | Most likely registry propagation. Re-run the verifier before concluding. Do **not** retry the publish. |

### 3.3 Check properties

| Check | Detects "no run" | Detects "green run, no publish" | Detects "artifact absent" | Fast enough to gate the next push |
|---|---|---|---|---|
| (a) run exists | yes | no | no | **yes** |
| (b) step conclusion | indirectly | **yes** | no | no |
| (c) exact version resolves | no | yes | **yes** | no |

Check (c) is decisive for the **outcome**; check (a) is decisive for the **diagnosis** and is the
only check fast enough to gate the second push; check (b) is the diagnostic bridge between them
(research `## 6.4`). A sound verifier runs all three, derives its exit code from (c) where (c) has
been reached, and reports (a) and (b) so that the failure is actionable.

Check (c) is decisive **given** that the workflow is the only publisher of this package. In this
repository that is the intended and only path. The assumption is recorded so a later reader does not
transplant the check into a context where it does not hold (research `## 6.3`).

### 3.4 Polling is mandatory

A single immediate check is unsound. Two independent propagation observations are on record: the
Marketplace lagged roughly five to eight minutes on the `1.1.0` release, and the extension run took
three polls to appear (`issue.md:89,98`). A check that runs once would have been inconclusive on a
release that in fact succeeded.

Initial budgets, **labelled unverified** — they are extrapolated from a single release observation,
not from a measured distribution, and are initial values subject to revision:

| Check | Interval | Max attempts | Ceiling |
|---|---|---|---|
| (a) run appears | 10 s | 18 | 3 min |
| (b) run reaches a terminal conclusion | 20 s | 60 | 20 min |
| (c) npm resolves the exact version | 15 s | 40 | 10 min |
| (c') Marketplace lists the exact version | 30 s | 30 | 15 min |

An exhausted budget must be reported as a state distinct from a negative result. "Not yet visible
after N attempts" is operationally different from "the publish step was skipped", and both exit
non-zero.

---

## 4. Behavioural Requirements

Each requirement below is individually testable without performing a release, a publish, or a tag
push.

**BR-1 — Mockable seams.** All external calls in the verifier go through wrapper functions
(`Invoke-GhExe`, `Invoke-NpmExe`) returning `@{ Output; ExitCode }`, and all waits go through an
`Invoke-Sleep` seam. This mirrors the established pattern at `Invoke-FullReleaseFlow.ps1:85-100` and
`:122-142`, whose docstring states the rationale: isolating `Start-Sleep` so tests can assert poll
counts without wall-clock delay.

**BR-2 — Exact-version registry resolution.** The registry check invokes npm with the package
operand in the `<package>@<exact-version>` form. The bare `<package>` form is prohibited because it
resolves the `latest` dist-tag and would have passed during the `1.0.25` failure. Success requires
exit code 0 **and** stdout equal to the requested version.

**BR-3 — Bounded two-phase polling.** Each check polls at a configurable interval up to a
configurable maximum attempt count, following the registration/completion pattern of
`Wait-ForPullRequestChecks` (`Invoke-FullReleaseFlow.ps1:162-258`). Budget exhaustion returns the
state's exhaustion token, never a success.

**BR-4 — Distinct failure states.** The verifier returns each state in `## 3.2` as a distinct token
and emits a distinct operator recovery instruction per state. `STEP_MISSING` is a failure, not an
absence of evidence.

**BR-5 — Dependency-first push order.** `Invoke-ReleaseTagPush.ps1` creates and pushes
`mcp-server-v<mcp-version>` **before** `v<ext-version>`. This reverses the current order
(`Invoke-ReleaseTagPush.ps1:188-190`).

**BR-6 — Inter-push gate.** The extension tag is created and pushed only after the mcp tag reaches
`RESOLVED`. On any other mcp outcome the function returns non-zero and performs **zero** extension
tag creations and **zero** extension tag pushes. This is what makes the `1.0.25` outcome
structurally impossible: if mcp fails to publish, `v1.0.25` is never consumed and no artifact
pinning `1.0.25` ever reaches a user.

**BR-7 — Pre-push inverted check.** Before pushing the mcp tag, the script asserts the target
version is **absent** from the registry. A successful resolution means the version is already
consumed; the script returns `VERSION_CONSUMED_ELSEWHERE`, exits non-zero, and pushes nothing.

**BR-8 — Post-push verification of the extension tag.** After the extension push, the flow verifies
to a terminal state and exits non-zero on any non-success outcome, so
`Invoke-FullReleaseFlow.ps1:388-394` propagates the failure instead of returning 0.

**BR-9 — Codex pin resolution.** The post-push guard reads the pinned version from the committed
`.codex/config.toml` at the released ref and requires that **exact pinned string** to resolve on the
registry. Reading the pin rather than the manifest is strictly stronger and does not depend on #522
having landed: the pin is the string `npx -y` will actually resolve.

**BR-10 — Ref-based publish guard.** `publish-mcp-npm.yml`'s publish step is guarded on the ref
(`startsWith(github.ref, 'refs/tags/mcp-server-v')`) rather than on the event name. A dispatch
against `main` yields `refs/heads/main` and skips; a pull-request run yields `refs/pull/N/merge` and
skips. This is the identical model already proven by `publish-extension.yml:63`.

**BR-11 — Tag/manifest version equality inside the workflow.** Before publishing, the workflow
extracts the version from `github.ref` and fails when it does not equal
`packages/mcp-server/package.json`'s `version`. Nothing currently ties the published version to the
tag (research `## 1.1`). This assertion also bounds the residual risk of BR-10, which trusts the tag
name. The assertion step must itself be ref-guarded so that pull-request runs, which carry no tag
ref, remain green.

**BR-12 — Layer A post-publish poll.** After the publish step, the workflow polls the registry for
the exact version and fails the job when the budget expires.

**BR-13 — `pull_request` trigger.** `publish-mcp-npm.yml` carries a `pull_request` trigger scoped to
`packages/mcp-server/**` and the workflow file itself, with a comment recording why it exists. See
`## 6.1`.

**BR-14 — Layer C reconciliation sweep.** A scheduled workflow compares the remote `mcp-server-v*`
tag version set against the published version set and raises a visible signal on divergence. Its
comparison logic is a pure function over two string collections, testable offline with no network.

**BR-15 — Runbook.** An operator runbook documents each failure state, its recovery, the
non-destructive re-dispatch enabled by BR-10, the two preconditions that must both hold before any
delete-and-re-push is considered (the version resolves nowhere on the registry, and no successful
run exists for the tag), and the human-only disposition decision for a consumed version number.

---

## 5. Boundary with Issue #522 — Who Owns Which Guard

The two guards **cannot be the same test**, and the reason is a policy constraint rather than a
preference.

- **#522 owns the offline invariant.** The pinned version equals
  `packages/mcp-server/package.json`'s `version`, in both `.codex/config.toml` copies, asserted in
  the per-commit Pester suite with no network and full determinism.
- **#526 owns the registry-resolution guard.** Executed once per release, **after** the tag push,
  where network access is inherent and a failure is actionable.

A per-commit test that resolved the pin against npm would violate
`.claude/rules/general-unit-test.md` ("Unit tests must not depend on external services") and would
**fail by construction on every release pull request**: at pull-request-authoring time the pinned
version has been bumped but not yet published, because the publish happens only after the tag push,
which happens only after the pull request merges.

The pin is written from the freshly bumped manifest in the same run that bumps it
(`Invoke-FullRelease.ps1:296,302`), so pin-equals-manifest holds by construction on every path
through the tooling. It held at `1.0.25` while the artifact was broken. Equality is a real guard
against hand edits and merge drift, and is structurally incapable of saying anything about the
registry.

---

## 6. Constraints and Preconditions

### 6.1 Hard precondition: the `pull_request` trigger

`publish-mcp-npm.yml` has **no `pull_request` trigger** (`publish-mcp-npm.yml:3-7`). The
feature-review policy rule `modified-workflow-needs-green-run` makes a workflow diff **Blocking**
unless a green workflow run against the branch head is present in remediation inputs
(`.claude/rules/ci-workflows.md`, "Enforcement"). With no pull-request trigger, a change to this file
**cannot produce a green branch-head run**, so the change would be blocked at review with no
available remedy.

Adding the trigger is therefore a hard precondition of touching that file at all. The repository has
its own precedent with the reason written into the file:
`publish-extension.yml:8-11` states verbatim that its pull-request trigger "provides the green
branch-head run required by modified-workflow-needs-green-run for a new tag-triggered workflow that
cannot be dispatched before it lands." The new trigger must mirror `publish-extension.yml:12-15`
(paths `packages/mcp-server/**` and the workflow file) and carry an equivalent comment.

This precondition is mutually supporting with BR-10: with a ref-based publish guard a pull-request
run has `github.ref == refs/pull/N/merge` and therefore never publishes, which is the same safety
property the extension workflow already relies on. The same reasoning applies to any new workflow
added for Layer C.

### 6.2 Non-functional constraints

- **No temporary files in tests.** `.claude/rules/general-unit-test.md` prohibits the creation and
  use of temporary files in tests without exception. Fixture content is supplied in memory.
- **No real network in unit tests.** Unit tests must not depend on external services or external
  processes. Every `npm`, `gh`, and `git` interaction is exercised through its mocked seam.
- **Determinism through the existing mock seams.** Reuse `Invoke-GitExe`, `Invoke-GhExe`, and
  `Invoke-Sleep`. All three are already mocked in the committed suites, and
  `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` exists specifically for the poll-behaviour case.
- **No wall-clock sleeps in tests.** `.claude/rules/general-unit-test.md` bans real wall-clock waits
  in test code. Poll counts and intervals are asserted through the `Invoke-Sleep` seam.
- **500-line file cap.** `.claude/rules/general-code-change.md` caps production, test, and reusable
  script files at 500 lines. `Invoke-ReleaseTagPush.ps1` is currently 213 lines; adding three seams
  plus the polling implementation to it would approach the cap, which is the reason the verification
  logic belongs in a separate module.
- **`pwsh` steps that deliberately invoke a failing nested command.** A verification step that runs
  a registry lookup on an absent version is exactly the pattern governed by
  `.claude/rules/ci-workflows.md`: a `pwsh` step terminates with the exit code of the last external
  command unless the script explicitly resets it or calls `exit`. Any such step must either reset
  `$LASTEXITCODE = 0` after the expected failure or terminate the success path with an explicit
  `exit 0` / `exit 1`. No local toolchain stage executes a workflow `run:` block, so this defect is
  invisible to local review and the rule is the artifact review cites.
- **Coverage.** Line coverage >= 85% uniformly across tiers
  (`.claude/rules/quality-tiers.md`). PowerShell is exempt from the branch threshold because Pester
  does not measure branch coverage; PowerShell production files remain in the line-coverage
  denominator and may not be excluded from measurement.
- **Test file location.** Tests mirror the production tree: a test for
  `scripts/dev-tools/Foo.ps1` belongs at `tests/scripts/dev-tools/Foo.Tests.ps1`.

### 6.3 Assumptions

- `gh` is authenticated in the release environment. The flow already assumes this
  (`Invoke-FullReleaseFlow.ps1:352,364,369`), so verification adds no new credential.
- `@danmoisan/drm-copilot-mcp` is public, so `npm view` requires no authentication.
- The publish workflow is the only publisher of this package (see `## 3.3`).

---

## 7. Files Expected to Change

| File | Change |
|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` (new) | Checks (a), (b), (c) with bounded polling behind mock seams; per-tag state machine. |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` (new) | Pure helpers (`ConvertFrom-JsonSafely`, `Get-RecoveryInstruction`, `ConvertTo-VerificationResult`, `Get-CodexPinnedMcpVersion`). The file exists because the 500-line cap forced the pure helpers out of the verification module. |
| `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` (new) | Unit tests for those pure helpers. The file exists because the 500-line cap forced the pure helpers out of the verification module, and tests mirror the production tree. |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | Reverse the push order; pre-push inverted check; inter-push gate; post-push verification. |
| `.github/workflows/publish-mcp-npm.yml` | `pull_request` trigger; ref-based publish guard; tag/manifest equality assertion; post-publish registry poll. |
| `.github/workflows/verify-published-releases.yml` (new) | Layer C scheduled reconciliation sweep. |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` (new) | Per-check behaviour, state machine, polling. |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | Existing assertions at `:63-70` pin the five-invocation shape and the extension-first order; both change. |
| `docs/engineering/missed-npm-publish.runbook.md` (new) | Operator recovery per state; human-only disposition decision. |
| `README.md` | **Not in this issue.** Owned by #528. |

---

## Acceptance Criteria

- [x] AC1 — A dot-sourceable module exists at `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, defines wrapper seams for the `gh` and `npm` external calls returning `@{ Output; ExitCode }` and a sleep seam isolating `Start-Sleep`, and is dot-sourced (not executed) by `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, which mocks all three seams.
- [x] AC2 — The registry check builds its npm argument vector with the package operand in the exact-version form `@danmoisan/drm-copilot-mcp@<version>`, and never the bare `@danmoisan/drm-copilot-mcp` (`latest` dist-tag) form. A test in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` captures the argument vector passed to the npm seam and asserts the version suffix is present on the package operand.
- [x] AC3 — A test in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` arranges the npm seam to return a non-zero exit code for the exact requested version while returning a different, present version for the bare-package form, and asserts the registry check reports failure. This test must fail if the implementation is switched to the bare-package form, which is the defect the issue's own proposal contained (research D4).
- [x] AC4 — On a fully successful verified run, `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` asserts from the captured git argument vectors that the `mcp-server-v` tag is pushed **before** the `v` extension tag.
- [x] AC5 — A test in `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` arranges the mcp verification to return a non-success state and asserts all of: the captured git argument vectors contain exactly one push invocation, that push carries the `mcp-server-v` tag, no tag-creation invocation carries the extension tag, and the function returns a non-zero exit code.
- [x] AC6 — The verifier returns each of `NO_RUN`, `RUN_FAILED`, `STEP_SKIPPED`, `STEP_MISSING`, `UNRESOLVED`, and `RESOLVED` as a distinct token, and `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` contains at least one test per state asserting the returned token.
- [x] AC7 — `STEP_MISSING` (the named job or step is absent from the run payload) returns a non-zero result and is asserted by a dedicated test; it is not reported as a pass or as "no evidence".
- [x] AC8 — Each non-success state carries a non-empty operator recovery instruction, and a test asserts that the instructions emitted for `NO_RUN`, `STEP_SKIPPED`, and `UNRESOLVED` are pairwise different strings. A single generic failure message fails this criterion.
- [x] AC9 — For each of the three checks, `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` covers found-on-first-attempt, found-on-a-later-attempt with at least three attempts, and budget-exhausted; each of these tests asserts the number of sleep-seam invocations.
- [x] AC10 — Budget exhaustion and a negative result are distinguishable: a test asserts that the exhausted-budget outcome of the run-existence check and the negative outcome of the publish-step check return different state tokens, and that both are non-zero.
- [x] AC11 — A test asserts that when the pre-push registry check finds the target version already present, `Invoke-ReleaseTagPushGuarded` returns non-zero, reports `VERSION_CONSUMED_ELSEWHERE`, and the captured git argument vectors contain zero push invocations and zero tag-creation invocations.
- [x] AC12 — A test asserts that the Codex pin guard reads the pinned version from the supplied `.codex/config.toml` content (in memory; no temporary file) and passes the **pinned** string to the registry check, and a companion test asserts failure when the pinned version does not resolve.
- [x] AC13 — `.github/workflows/publish-mcp-npm.yml` declares a `pull_request` trigger scoped to `packages/mcp-server/**` and to the workflow file itself, carrying a comment that names the `modified-workflow-needs-green-run` rule as the reason.
- [x] AC14 — The publish step in `.github/workflows/publish-mcp-npm.yml` is guarded on the ref via `startsWith(github.ref, 'refs/tags/mcp-server-v')`, and no step in that file is guarded on `github.event_name == 'push'`.
- [x] AC15 — `.github/workflows/publish-mcp-npm.yml` contains a step, ordered before the publish step and guarded so it does not run on a pull-request ref, that compares the version parsed from `github.ref` against `packages/mcp-server/package.json`'s `version` and fails the job on mismatch.
- [x] AC16 — `.github/workflows/publish-mcp-npm.yml` contains a post-publish step that polls for the exact published version using the exact-version registry form and fails the job when the budget expires.
- [x] AC17 — Every `pwsh` step added to any workflow by this change that deliberately invokes a command expected to fail either resets `$LASTEXITCODE = 0` after the expected failure or terminates the success path with an explicit `exit 0` / `exit 1`, as required by `.claude/rules/ci-workflows.md`.
- [x] AC18 — A green run of `publish-mcp-npm.yml` against the branch head exists, produced by the new `pull_request` trigger, and the run's publish-step conclusion is `skipped`. The run URL and the step conclusion are recorded under `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/`. This satisfies `modified-workflow-needs-green-run` and consumes no version number.
- [x] AC19 — A scheduled reconciliation workflow exists at `.github/workflows/verify-published-releases.yml`, and its divergence computation is a pure function over a tag-version collection and a published-version collection, unit-tested offline with at least three cases: every tag published, one tag unpublished, and an empty tag set.
- [x] AC20 — `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` no longer asserts the previous five-git-invocation shape or the extension-first push order, and the whole file passes under the repository Pester runner.
- [x] AC21 — The complete Pester suite passes with no network access available, and no test added or modified by this change invokes `npm`, `gh`, or `git` as a real external process. The first clause is evidenced by `evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md`, which records the verbatim `ECONNREFUSED` isolation probe against the discard endpoint and the 3646-passed, 0-failed suite run executed inside that same isolated session.
- [x] AC22 — No test file added or modified by this change references a temporary-path facility (`New-TemporaryFile`, `GetTempFileName`, `$env:TEMP`, `TestDrive`), and no test calls `Start-Sleep`.
- [x] AC23 — Every `.ps1` file added or modified by this change is at most 500 lines.
- [x] AC24 — The repository Pester coverage report shows line coverage of at least 85% for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, and for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, and no such file is added to any coverage exclusion list.
- [x] AC25 — `scripts/dev-tools/run-actionlint.ps1` completes with exit code 0 against the changed and added workflow files.
- [x] AC26 — The PowerShell toolchain — format, PSScriptAnalyzer, Pester — completes with no errors and no auto-fixes in a single consecutive pass.
- [x] AC27 — An operator runbook exists at `docs/engineering/missed-npm-publish.runbook.md` documenting, for each state in the spec's failure-state table, the corresponding recovery; the two preconditions that must both hold before any tag delete-and-re-push is considered; and the statement that the disposition of an already-consumed version number is a human decision.
- [x] AC28 — The diff modifies no line of `README.md` (owned by #528) and adds no `quality-tiers.yml`, confirming both remain out of scope.
- [x] AC29 — `Invoke-TagPublishVerification` accepts and forwards a separate interval and attempt budget for each of the three checks — the run-existence check (a), the publish-step check (b), and the registry check (c) — rather than one shared pair, and each pair is defaulted to its own `## 3.4` ceiling (10 s / 18 attempts, 20 s / 60 attempts, 15 s / 40 attempts). `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` asserts the forwarded budget of each check individually. Verified by the three P2-T4 tests recorded as passed in `evidence/regression-testing/pass-after-per-check-budgets.2026-08-26T02-36.md`.
- [x] AC30 — An exhausted check (b) budget returns the distinct token `RUN_INCOMPLETE`, which carries its own operator recovery instruction and its own section in `docs/engineering/missed-npm-publish.runbook.md`, rather than reusing `RUN_FAILED`. A test asserts that the token returned for an exhausted check (b) budget differs from the token returned for a concluded-failure run, and that both results carry a non-zero exit code. Verified by the P3-T3, P3-T4, and P3-T5 tests recorded as passed in `evidence/regression-testing/pass-after-per-check-budgets.2026-08-26T02-36.md`.

---

## 8. Risks and Open Questions

### 8.1 Risks

| Risk | Impact | Mitigation |
|---|---|---|
| The root cause is never confirmed and the event drop recurs | A future release could still miss a run | The design does not depend on the root cause. The inter-push gate prevents the consumer from shipping a pin to an unpublished dependency; the ref-based guard makes recovery a single non-destructive dispatch; the sweep detects a miss that nobody looked for. |
| Reversing the push order lengthens the release by one full CI cycle between the two pushes | Plausibly 8-20 minutes of additional wall-clock time | The time is unattended, so the cost is wall-clock rather than attention. Accepted deliberately (research `## 7.1`). |
| The mcp version is still consumed if mcp publishes and the extension tag later fails | An mcp version exists with no extension consuming it | Harmless: an unconsumed dependency version has no user-visible effect. |
| The extension release now depends on the npm registry being reachable | A registry outage blocks the release | The release halts rather than shipping a broken pin, which is the intended trade. |
| A ref-based publish guard trusts the tag name | Someone could create an arbitrary `mcp-server-v*` tag and dispatch against it | BR-11's tag/manifest equality assertion bounds this; it is worth adding regardless of the guard change. |
| The step-conclusion check is coupled to the workflow's job and step names | A rename silently degrades the check to "step not found" | `STEP_MISSING` is defined as a failure state (AC7), not as absence of evidence. |
| Polling budgets are too short and produce false failures | An operator sees `UNRESOLVED` on a release that in fact succeeded | The states are distinct and the recovery for `UNRESOLVED` is "re-run the verifier; do not retry the publish". Budgets are configurable parameters, not constants. |

### 8.2 Open questions, with verification status

- **UNVERIFIED — the Marketplace verification command.** Two candidate mechanisms exist:
  `npx --yes @vscode/vsce show <publisher>.<name> --json`, and the unauthenticated Marketplace
  `extensionquery` REST endpoint. **Neither was executed by the research**, so the exact invocation,
  the output shape, and whether the current `vsce` supports `--json` are all unverified. The
  implementation must validate the command before depending on it. If validation fails, the
  Marketplace check may be deferred without weakening the npm-side guarantee, which is the one that
  covers the `1.0.25` defect.
- **UNVERIFIED — the polling budgets in `## 3.4`.** Extrapolated from a single release observation
  (`issue.md:89,98`), not from a measured distribution. Treat as initial values.
- **UNVERIFIED — whether `head_branch` carries the short tag name for a tag-triggered run.** The
  run-existence check assumes it does. If it does not, match on head SHA plus workflow, or query the
  runs endpoint filtered on the push event and correlate (research `## 6.1`).
- **UNVERIFIED — whether a workflow whose YAML fails to parse at a tagged ref surfaces as a
  `startup_failure` run associated with the workflow ID that `gh run list --workflow=<file>` filters
  on.** Bears on candidate R4 and on how much the sweep can be trusted to see (research `## 5` R4).
- **UNVERIFIED — GitHub run-metadata retention beyond the 90-day log-and-artifact window.** Bears on
  whether `1.0.12` evidence is still obtainable; the research treats it as probably lost
  (research `## 12.2`).
- **UNVERIFIED — the current `npm unpublish` policy.** Referenced only in the runbook's human
  disposition section; the runbook must state the uncertainty rather than assert a rule.
- **Open — whether the two known failures are explained by an event drop at all.** The research
  notes that a run may have existed without being listed (research `## 5` R5), which would change
  the characterization from "no run at all" to "a run that did not publish" and would move the
  search space. The registry evidence already proves no successful publish occurred, so the fix is
  unaffected either way.

---

## 9. Rollout and Follow-up

- **Rollout.** All changes land in a single pull request. The `pull_request` trigger on
  `publish-mcp-npm.yml` must be present in that same pull request so it produces the green
  branch-head run required by `modified-workflow-needs-green-run` (AC18). The first real exercise of
  the tag-push path occurs on the next release; no release is required to merge.
- **Post-fix monitoring.** The Layer C sweep runs unattended and raises a signal on any tag/registry
  divergence, including divergences that predate this change.
- **Follow-up, other owners.** Issue #522 (offline pin-equals-manifest test). Issue #528
  (`README.md` credential correction). The absent `quality-tiers.yml` remains unfiled here.
- **Links.** Issue: https://github.com/drmoisan/drm-copilot/issues/526. Research:
  `research/research.2026-08-24T12-45.md`.
