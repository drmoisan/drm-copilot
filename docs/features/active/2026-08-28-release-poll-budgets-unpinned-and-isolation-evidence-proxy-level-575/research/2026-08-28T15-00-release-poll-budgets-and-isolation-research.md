\
# Research — Issue #575: release poll budgets unpinned at call site; AC21 isolation evidence proxy-level

- Timestamp: 2026-08-28T15-00
- Scope: `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/`
- Method: read-only. All claims below are grounded in file reads of the current worktree state and of the
  `#526` feature-folder artifacts. Where a claim could not be verified it is stated as such.

---

## 1. The call site and the three budgets

### 1.1 Three layers of "budget defaults" exist, and they are not all equal

There are three distinct places in the codebase where an interval/attempts pair for a check is declared,
and only one of them is authoritative for the shipped release path.

| Layer | Location | Values | Role |
|---|---|---|---|
| **Script-level CLI parameters** | `scripts/dev-tools/Invoke-ReleaseVerification.ps1:40-45` (`param()` block) | `RunIntervalSeconds=10, RunMaxAttempts=18, StepIntervalSeconds=20, StepMaxAttempts=60, NpmIntervalSeconds=15, NpmMaxAttempts=40` | Forwarded verbatim to `Invoke-TagPublishVerification` in the entry-point block at `:403-416`, which runs only when the script is invoked as a process (`$MyInvocation.InvocationName -ne '.'`), never when dot-sourced. |
| **`Invoke-TagPublishVerification` (composition entry point)** | `Invoke-ReleaseVerification.ps1:345-360` | Same six values, same defaults | **This is "the call site" that matters.** It is the function every consumer actually invokes: the standalone script's entry-point block, and `Invoke-ReleaseTagPushGuarded` in `Invoke-ReleaseTagPush.ps1:244-250`. Its defaults are what a caller gets when it supplies none, and they are what is currently pinned by test (see 1.3). |
| **Individual helper functions** | `Wait-ForWorkflowRun` (`:163-164`, `IntervalSeconds=10, MaxAttempts=18`); `Test-PublishStepConclusion` (`:272-273`, `IntervalSeconds=10, MaxAttempts=18`) | Own, independent defaults | **Not authoritative for production behaviour.** `Invoke-TagPublishVerification` always calls both helpers with explicit `-IntervalSeconds`/`-MaxAttempts` arguments (`:362-366` and `:372-377`), so the helper's own default is reachable only by a caller that invokes the helper directly without specifying those parameters — which no production code path does. |

**The precise mismatch the issue statement gestures at.** `Wait-ForWorkflowRun`'s own default (10s x 18 = 3
min) happens to match §3.4's ceiling for check (a), so it is silently "correct" if ever invoked bare.
`Test-PublishStepConclusion`'s own default is **also** `IntervalSeconds=10, MaxAttempts=18` (3 min) —
copy-pasted from `Wait-ForWorkflowRun`'s signature — but check (b)'s spec ceiling is **20 minutes**
(`20s x 60`). This is the literal "3-minute pair where the spec requires 20 minutes" the issue references:
it is a real textual defect in `Test-PublishStepConclusion`'s own default parameter values, but it is inert
today because nothing in the shipped release path calls that function without overriding both parameters.
No test in the repository exercises `Test-PublishStepConclusion`'s bare defaults (every existing test
supplies `-MaxAttempts` explicitly; see `Invoke-ReleaseVerification.Tests.ps1:259-274`), so the mismatch
is neither caught nor consequential under current callers, but it is a footgun for any future direct caller.

### 1.2 The actual "call site" the issue's Gap 1 targets

The issue's own environment/steps text and the #526 reaudit's own vocabulary (`m8`) identify the call site
precisely as **`Invoke-ReleaseTagPush.ps1:244-250`**, inside `Invoke-ReleaseTagPushGuarded`:

```powershell
$verification = Invoke-TagPublishVerification `
    -TagName $entry.Tag `
    -WorkflowFileName $entry.WorkflowFileName `
    -JobName $entry.JobName `
    -StepName $entry.StepName `
    -Version $entry.Version `
    -SkipRegistryResolutionCheck:$entry.SkipRegistry
```

This is the release path's actual invocation of the composition entry point, and it supplies **no**
interval/attempts arguments at all — it relies entirely on `Invoke-TagPublishVerification`'s own defaults
(10/18, 20/60, 15/40). This is confirmed by direct reading of the current file (lines 244-250, verified
above) and matches the code comment at `:402` ("Forward all six per-check budgets; one shared pair was
the issue 526 R1 defect") which applies only to the standalone script's own entry-point block, not to this
call site.

### 1.3 What is pinned today, and what is not

`Invoke-ReleaseVerification.Tests.ps1:315-363` ("per-check polling budgets" context) **does** pin
`Invoke-TagPublishVerification`'s own defaults (10/18, 20/60, 15/40) by mocking `Wait-ForWorkflowRun` and
`Test-PublishStepConclusion` with a `-ParameterFilter` and by counting sleeps for check (c). This closes
the original #526 R1 Blocking defect (one shared budget reaching all three checks).

What is **not** pinned by any test is whether `Invoke-ReleaseTagPush.ps1:244-250` — the actual release
path — forwards those same defaults unmodified. `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`
mocks `Invoke-TagPublishVerification` wholesale (`:41-72`) and its mock function explicitly discards the
six budget parameters it declares:

```powershell
$null = $RunIntervalSeconds, $RunMaxAttempts, $StepIntervalSeconds
$null = $StepMaxAttempts, $NpmIntervalSeconds, $NpmMaxAttempts
```

`$script:capturedVerificationCalls` (`:60-64`) records only `TagName`, `WorkflowFileName`, and
`SkipRegistryResolutionCheck` — none of the six budget values. This is a full, file-level confirmation of
Gap 1: **if a future edit added explicit, wrong budget arguments at `Invoke-ReleaseTagPush.ps1:244-250`
(the same shape as the original #526 R1 defect), every existing test in the repository would still pass.**
This was independently reproduced by the #526 reaudit (see §4) and is recorded there as Minor finding
`m8`.

---

## 2. What the specification requires (issue's "3-minute pair" claim, confirmed)

`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md:191-210`, section
"3.4 Polling is mandatory":

> | Check | Interval | Max attempts | Ceiling |
> |---|---|---|---|
> | (a) run appears | 10 s | 18 | 3 min |
> | (b) run reaches a terminal conclusion | 20 s | 60 | 20 min |
> | (c) npm resolves the exact version | 15 s | 40 | 10 min |
> | (c') Marketplace lists the exact version | 30 s | 30 | 15 min |

The table is explicitly **labelled unverified** at `:198-199` and again at `:453-454` under "Open
questions, with verification status": "Extrapolated from a single release observation... not from a
measured distribution. Treat as initial values." AC29 (added during #526's remediation cycle, see §4)
requires that these ceilings be the actual defaults `Invoke-TagPublishVerification` forwards to each
check, and `feature-audit.2026-08-26T04-33.md:79-81` confirms by direct read that the shipped defaults
(10/18, 20/60, 15/40 at `Invoke-ReleaseVerification.ps1:353-358`) match this table exactly.

**Correcting the issue's illustrative claim precisely.** The issue text uses "the 3-minute pair where the
spec requires 20 minutes" as an example of what a *future regression* at the call site would look like —
it is not describing a defect present in the shipped code today. The shipped code is correct (§1.1, §1.3
confirm this by direct read and by the reaudit's independent execution probe, §4). The 3-minute-vs-20-
minute pairing is real, but it exists as a **latent mismatch in `Test-PublishStepConclusion`'s own,
currently-unused default parameters** (§1.1), and separately as the **exact shape a future call-site
regression would take** if someone added explicit wrong arguments at `Invoke-ReleaseTagPush.ps1:244-250`.
Both readings are grounded in evidence; neither describes a live defect.

---

## 3. Current test coverage (detailed)

### 3.1 `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` (364 lines)

- Dot-sources `Invoke-ReleaseVerification.ps1` (`:10`), which in turn dot-sources
  `Invoke-ReleaseVerificationHelpers.ps1`, so both production files run under Pester coverage
  instrumentation without spawning the entry-point block.
- `BeforeEach` (`:25-77`) registers deterministic mocks for `Invoke-GhExe`, `Invoke-NpmExe`, and
  `Invoke-Sleep`, using "OnAttempt" counters so a test can place a positive result on the first attempt,
  a later attempt, or never.
- Context **"bounded polling budgets"** (`:241-294`) asserts sleep counts for checks (a), (b), (c)
  individually, at small test-local budgets (`RunMaxAttempts=3/4`, `StepMaxAttempts=3/4`,
  `NpmMaxAttempts=3/4` — set in `$script:verifyArgs`, `:43-50`), not the production defaults.
- Context **"per-check polling budgets"** (`:315-363`) is the one that pins `Invoke-TagPublishVerification`'s
  own production defaults: it calls the function supplying **only** `TagName`, `Version`, `PackageName`
  (letting every budget default), mocks `Wait-ForWorkflowRun` and `Test-PublishStepConclusion` with a
  `-ParameterFilter` asserting `IntervalSeconds`/`MaxAttempts`, and for check (c) asserts exactly 40
  `Invoke-NpmExe` calls and 39 `Invoke-Sleep` calls filtered to `$Seconds -eq 15`.
- **What is asserted:** the composition entry point's own defaults equal 10/18, 20/60, 15/40.
- **What is not asserted:** anything about `Invoke-ReleaseTagPush.ps1`'s call to this function. This file
  never dot-sources `Invoke-ReleaseTagPush.ps1` and has no knowledge of `Invoke-ReleaseTagPushGuarded`.

### 3.2 `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` (497 lines — 3 lines under the 500-line cap)

- Dot-sources `Invoke-ReleaseTagPush.ps1` (`:5-10`), which transitively dot-sources
  `Invoke-ReleaseVerification.ps1` (so `Invoke-TagPublishVerification` and its dependencies resolve in
  this scope and are mockable).
- File-scoped `BeforeEach` (`:13-84`) mocks `Test-NpmVersionResolved`, `Invoke-TagPublishVerification`
  (wholesale — see §1.3 for its param-discarding body), `Get-CodexPinnedMcpVersion`, and `Get-Content`.
  These mocks apply to **every** `It` in the file's single top-level `Describe`, including any new
  `Context` added without an overriding mock.
- **What is asserted about budgets:** nothing. The mock's own `param()` block declares the six budget
  parameters (for signature parity with the real function, per `.claude/rules/powershell.md`'s "Mock
  signature parity" rule) but explicitly discards their values (`$null = ...`), and
  `$script:capturedVerificationCalls` records only `TagName`, `WorkflowFileName`,
  `SkipRegistryResolutionCheck`.
- **Confirmed: no test fails when a wrong explicit budget is passed at the call site.** Because
  `Invoke-TagPublishVerification` is entirely mocked in this file, any value passed for
  `RunIntervalSeconds`/`RunMaxAttempts`/etc. at `Invoke-ReleaseTagPush.ps1:244-250` is silently absorbed
  by the mock and never observed by any assertion.

### 3.3 `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` (125 lines)

- Dot-sources only `Invoke-ReleaseVerificationHelpers.ps1` (the four pure functions:
  `ConvertFrom-JsonSafely`, `Get-RecoveryInstruction`, `ConvertTo-VerificationResult`,
  `Get-CodexPinnedMcpVersion`). Registers **no mock at all** (confirmed by direct read; the code-review
  artifact notes this as proof of the file's purity, `code-review.2026-08-26T04-33.md:190-191`).
- No budget-related assertions; none of these four functions accepts an interval or attempt parameter.

### 3.4 Mocking approach and idiomatic placement for a new test

- **`Invoke-GhExe`, `Invoke-NpmExe`** are wrapper-function seams per `.claude/rules/powershell.md`
  ("Design Seams (Minimal DI)" and "External executable mocking" — never mock `gh`/`npm` directly, mock
  the wrapper). Both return `@{ Output = string[]; ExitCode = int }`.
- **`Invoke-Sleep`** wraps `Start-Sleep`; every test mocks it to a no-op so no wall-clock time is
  consumed and the number of invocations is directly assertable.
- **`Invoke-GitExe`** wraps `git` in `Invoke-ReleaseTagPush.ps1`, mocked in that file's tests.
- The idiomatic place for a call-site budget-pinning test is a **new `Context`** (or new file — see §7)
  that dot-sources `Invoke-ReleaseTagPush.ps1` and mocks `Wait-ForWorkflowRun`, `Test-PublishStepConclusion`,
  `Invoke-NpmExe`, and `Invoke-Sleep` directly — mirroring exactly the #526 reaudit's reviewer probe
  methodology (§4) — rather than mocking `Invoke-TagPublishVerification`. This is a structural constraint,
  not a style preference: as long as `Invoke-TagPublishVerification` itself is mocked (as it is throughout
  the existing file), the real composition/forwarding logic under test never runs, so no assertion made
  against that mock can distinguish "the call site forwarded 20/60" from "the call site forwarded 10/18" —
  the mock's own `param()` block discards those values regardless of what is passed.

---

## 4. The #526 reaudit's budget probe (follow-up `m8`) — recovered content and gap

### 4.1 What is recorded, and what is not

The reaudit (`feature-audit.2026-08-26T04-33.md`, `policy-audit.2026-08-26T04-33.md`,
`code-review.2026-08-26T04-33.md`) documents the probe's **methodology and verbatim output**, but **no
file in the `#526` feature folder contains the probe's PowerShell source code**. This was confirmed by a
targeted search across the feature folder (all `evidence/`, `code-review.*`, `feature-audit.*`,
`policy-audit.*`, `remediation-inputs.*`, `remediation-plan.*` artifacts) for `Mock -CommandName
Wait-ForWorkflowRun`, `Mock -CommandName Test-PublishStepConclusion`, `-ConfirmToken yes`, and related
patterns; only the prose description and the transcript below were found. **This claim — that no verbatim
probe source exists in the feature folder — is a negative finding and is recorded as such rather than
inferred; a plan implementing this fix will need to write the test from the methodology description, not
copy-paste committed source.**

### 4.2 Recovered methodology (from `feature-audit.2026-08-26T04-33.md:88-108` and
`policy-audit.2026-08-26T04-33.md:307-350`)

> "A reviewer probe dot-sourced the real `Invoke-ReleaseTagPush.ps1`, mocked only the three **check
> entry points** (never `Invoke-TagPublishVerification` itself, so the composition under test is real),
> and invoked `Invoke-ReleaseTagPushGuarded -ConfirmToken yes`"

Recovered verbatim output (both audit artifacts agree):

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18
CHECK_B_CALLS=1 INTERVAL=20 MAX=60
CHECK_C_15S_SLEEPS=39
Tests Passed: 1, Failed: 0
```

Falsifiability was demonstrated by mutation: reverting `Test-PublishStepConclusion`'s and
`Invoke-TagPublishVerification`'s check-(b) defaults to the pre-fix shared pair (`StepIntervalSeconds=10,
StepMaxAttempts=18`) in a scratch copy reproduced:

```
CHECK_A_CALLS=1 INTERVAL=10 MAX=18
CHECK_B_CALLS=1 INTERVAL=10 MAX=18
Expected 20, but got 10.
Tests Passed: 0, Failed: 1
```

### 4.3 Adaptation needed to land as a repository Pester test

Reconstructing the probe as a landed test requires resolving one structural obstacle not present in the
throwaway probe: the existing test file's file-scoped `BeforeEach` mocks `Invoke-TagPublishVerification`
wholesale (§3.2), and Pester mocks registered in a parent `Describe`/`BeforeEach` apply to every nested
`Context`. A new `Context` added to `Invoke-ReleaseTagPush.Tests.ps1` without further action would still
run under that outer mock and would therefore observe nothing about the real composition/forwarding path
— the same defect this new test exists to close. Two structurally sound options, in order of proximity to
the recovered probe's own approach:

1. **A new, separate top-level `Describe` block** (same file or, given the 500-line headroom constraint
   below, a new sibling file) that dot-sources `Invoke-ReleaseTagPush.ps1` independently and declares its
   **own** `BeforeEach` mocking only `Invoke-GitExe`, `Test-NpmVersionResolved` (for the pre-push guard),
   `Wait-ForWorkflowRun`, `Test-PublishStepConclusion`, `Invoke-NpmExe`, and `Invoke-Sleep` — never
   `Invoke-TagPublishVerification`. This reproduces the reaudit probe's methodology exactly: the real
   `Invoke-TagPublishVerification` composition function runs unmocked, so its default-parameter values
   genuinely flow through to the mocked check functions, and a `-ParameterFilter` on those mocks (mirroring
   `Invoke-ReleaseVerification.Tests.ps1:322-361`) asserts the forwarded interval/attempts pair per check.
2. A less faithful alternative — asserting `$PSBoundParameters` on the existing wholesale
   `Invoke-TagPublishVerification` mock — was considered and rejected here as inferior: it can prove only
   that the call site passed *no explicit* budget arguments (relying on defaults), not that the values
   which *would* reach the checks are the §3.4 ceilings. Option 1 is the one that actually recreates the
   `m8` finding's evidentiary strength.

**File-size constraint bearing on the choice.** `Invoke-ReleaseTagPush.Tests.ps1` is 497 lines, 3 lines
under the general-code-change 500-line cap (`.claude/rules/general-code-change.md`, "File Size Limit"; also
recorded as carried Minor `m1` in `policy-audit.2026-08-26T04-33.md:460`). A new `Context` of the size
needed to reproduce the three per-check `-ParameterFilter` assertions (the existing analogous context at
`Invoke-ReleaseVerification.Tests.ps1:315-363` is ~48 lines) cannot fit. **A fix landing this test must
either (a) create a new sibling test file, or (b) split `Invoke-ReleaseTagPush.Tests.ps1` first**, following
the precedent already set for the production side: `Invoke-ReleaseVerification.ps1` itself was split into
`Invoke-ReleaseVerification.ps1` + `Invoke-ReleaseVerificationHelpers.ps1` during #526 for the identical
reason (a file one line under the cap could not absorb the per-check budget parameters —
`Invoke-ReleaseVerificationHelpers.ps1:10-13`).

**Requirements the new test must satisfy** (per `.claude/rules/general-unit-test.md` and
`.claude/rules/powershell.md`): no `Start-Sleep` (use `Invoke-Sleep` mock), no temporary files, no real
`git`/`gh`/`npm` process (mock every wrapper seam), deterministic (no wall-clock dependency — confirmed
achievable, since every seam the composition path touches is already an established mockable wrapper),
and file location under `tests/scripts/dev-tools/` mirroring `scripts/dev-tools/`.

---

## 5. AC21 gap, precisely characterised

### 5.1 AC21's exact current text

`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md:417`:

> - [x] AC21 — The complete Pester suite passes with no network access available, and no test added or
>   modified by this change invokes `npm`, `gh`, or `git` as a real external process. The first clause is
>   evidenced by `evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md`, which records the verbatim
>   `ECONNREFUSED` isolation probe against the discard endpoint and the 3646-passed, 0-failed suite run
>   executed inside that same isolated session.

AC21 has two clauses, as the reaudit itself decomposes it (`feature-audit.2026-08-26T04-33.md:150-179`):

- **Clause 1:** "The complete Pester suite passes with **no network access available**."
- **Clause 2:** "no test added or modified by this change invokes `npm`, `gh`, or `git` as a real external
  process."

### 5.2 What the cited evidence artifact actually demonstrates

`evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md` (read in full, §content above) documents:

- `IsolationMethod`: "Process-scoped environment isolation inside a single `pwsh` session." Sets
  `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY` to `http://127.0.0.1:9` (the IANA discard port, not listening),
  `NO_PROXY` to empty, and `NPM_CONFIG_REGISTRY` to the same discard endpoint.
- Runs `npm view "@danmoisan/drm-copilot-mcp" version` first as an isolation probe: exits 1 with
  `ECONNREFUSED` on `syscall connect` against `127.0.0.1:9`.
- Runs the full Pester suite (`Invoke-PoshQCTest`) inside the **same** `pwsh -Command` string/session:
  3646 passed, 0 failed, 9 skipped.
- The artifact's own prose (`:53-68`) argues the probe establishes more than "a bare non-zero exit" by
  four points (npm itself ran; failure is transport-layer `ECONNREFUSED`, not `E404`/auth/config; the
  refused address is exactly the configured discard endpoint; the requested URL is the real scoped-package
  path) — all true, and independently reproduced by the #526 reaudit (`feature-audit.2026-08-26T04-33.md:161-180`,
  `policy-audit.2026-08-26T04-33.md:373-406`).

**What this actually proves:** that npm, gh, and (by the reaudit's independent confirmation) any
**proxy-aware** HTTP client inside that session cannot reach the registry, because `HTTP_PROXY` /
`HTTPS_PROXY` / `ALL_PROXY` / `NPM_CONFIG_REGISTRY` bind proxy-aware clients to the discard endpoint. It
does **not** prove that the session has "no network access available" as a categorical property of the
process or host.

### 5.3 The measured delta

`policy-audit.2026-08-26T04-33.md:395-406` (R4 section) records a third probe added by the reaudit itself:

```
=== PROBE raw socket ===
RAW_SOCKET_CONNECTED=TRUE
```

A direct `System.Net.Sockets.TcpClient` connection to `registry.npmjs.org:443` **succeeded** from inside
the same isolated session, because a raw socket bypasses the proxy-environment variables entirely. The
audit's own conclusion (`:405-406`): "AC21's literal wording, 'with no network access available', is
therefore stronger than what the artifact demonstrates." This is graded **Minor `m7`**, not Major or
Blocking, "because the substantive guarantee — AC21 clause 2, that no test added or modified invokes
`npm`, `gh`, or `git` as a real external process — is independently verified, and the two tools those
tests could plausibly reach are provably unreachable" (`feature-audit.2026-08-26T04-33.md:408-412`).

### 5.4 The review artifact that graded AC21 PARTIAL

`feature-audit.2026-08-26T04-33.md:60`: `| **AC21** | `[x]` | **PARTIAL** | X | See analysis below. |`,
with the analysis at `:150-180` quoted above (§5.1-5.3). The same review's summary table
(`:12-17`) records: "PARTIAL | 1 (AC21)" and "Criteria checked beyond their evidence: 1 (AC21, marginal —
see below). No criterion is checked without substantial supporting evidence." AC21's checkbox in
`spec.md` is `[x]` despite this PARTIAL grading; the reaudit explicitly frames this as the checkbox
"marginally exceed[ing] its evidence" (`:150`) rather than being unsupported outright.

The companion `code-review.2026-08-26T04-33.md` Minor-findings table (`:280`) restates the same finding:
`m7 | AC21 / network-isolated-suite artifact | "no network access available" overstates proxy-env
isolation; raw socket measured reachable`, and the remediation-item verdict table (`policy-audit
.2026-08-26T04-33.md:304`) records: `R4 / M2 — AC21 network isolation | Major | SUBSTANTIALLY RESOLVED;
residual Minor m7 | Isolation probe and isolated suite run reproduced; measured counter-example on
isolation depth`.

---

## 6. Remedies for AC21: assessment and recommendation

### 6.1 Option A — produce real network-isolation evidence

**What it would require on Windows 11 for a Pester run.** No existing repository tooling offers process-
level or namespace-level network isolation (confirmed: a search of `scripts/` for firewall-rule,
sandboxing, or namespace-isolation constructs — `New-NetFirewallRule`, "Windows Sandbox", "network
namespace", `Test-NetConnection` used as an isolation gate — returned no matches). The candidate
mechanisms that would genuinely block a raw socket, not just a proxy-aware client, are:

- **A per-process or host-level Windows Firewall outbound-block rule** (`New-NetFirewallRule -Direction
  Outbound -Action Block ...`, scoped to the `pwsh.exe` binary or to the destination host/port). This
  requires local administrator privileges to create/remove, is a host-wide, session-persistent mutation
  (not scoped to the test process), and — critically — falls outside what a **unit test** may do under
  repository policy: `.claude/rules/general-unit-test.md` prohibits external dependencies and requires
  determinism/isolation from the *host*, not mutation *of* the host; a test that edits Windows Firewall
  state as a side effect is itself an operational hazard, not a unit-test technique.
- **A container or VM boundary** (Windows Sandbox, Hyper-V isolated VM, or a network-namespaced container)
  around the entire test-runner process. This is real isolation, but is infrastructure the repository does
  not currently have, requires elevation/feature enablement, and would move "run the Pester suite" outside
  the toolchain's current single-process invocation model — a scope far larger than a Medium-severity
  documentation/evidence-precision gap warrants.

Both mechanisms are technically capable of closing the gap, but both require new, elevated, host-mutating
infrastructure that does not exist today and that the existing regression corpus never needed for any other
gate.

### 6.2 Option B — amend AC21's wording to state the actually-verified property

The reviewer's own recorded suggestion (`policy-audit.2026-08-26T04-33.md:466`, `m7` row): "Suggest
narrowing the wording to name the isolation mechanism." This asks for no new infrastructure: the existing
`network-isolated-suite` evidence artifact already supports a precise, weaker, true claim — e.g., "the
complete Pester suite passes with all proxy-aware network clients (`npm`, `gh`, .NET `HttpClient`'s default
proxy) redirected to an unreachable discard endpoint; a raw socket is not blocked by this mechanism" — and
clause 2 (no test invokes a real external process) is untouched and remains independently verified.

### 6.3 Precedent on amending a merged feature's AC/document text

The `acceptance-criteria-tracking` skill (`.agents/skills/acceptance-criteria-tracking/SKILL.md:56`) states
a "Preserve text" rule for the check-off protocol: "When checking off, change only `- [ ]` to `- [x]`. Do
not modify the criterion text." This rule governs an executor/reviewer's behaviour *during the original
feature's delivery*, not a deliberate, reasoned correction landed by a later, separate bug fix under its
own issue and audit trail — but it does establish the repository's general norm that AC text, once
authored, is not casually rewritten in place.

A directly on-point precedent for *how* this repository corrects a historical claim it has since found to
be false, without silently rewriting the record, exists at
`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/documentation-corrections.2026-08-20T20-02.md`
(P5-T3): a prior audit document (`docs/research/2026-07-09-potential-entries-duplicate-audit.md`) had
asserted a false claim (that promoted records are never relocated). The #487 fix's disposition was
**"applied — appended only; the historical body is unchanged"**: a dated `## Correction — 2026-08-20 (issue
#487)` section was appended to the end of the file, stating the falsified claim, why the original audit
missed it, what was and was not retracted, and the current (corrected) state. No line of the original
document was rewritten, deleted, or reworded.

**Recommendation: Option B (amend/narrow the claim), using the #487 append-only correction pattern rather
than an in-place rewrite of AC21's sentence.** Reasoning:

1. Clause 2 of AC21 — the substantive guarantee that no test invokes a real external process — already
   holds and is independently re-verified twice (original evidence artifact, reaudit reproduction). The
   gap is confined to clause 1's wording overstating the isolation mechanism's depth, not to a missing or
   false test-purity guarantee.
2. Option A's cost (new elevated, host-mutating infrastructure; a departure from the unit-test isolation
   model this repository otherwise applies uniformly) is disproportionate to a Medium-severity,
   non-live-defect gap whose only consequence is that a written claim is more precise than what was proven.
3. The repository has a specific, already-applied precedent for exactly this situation — a merged
   artifact's claim was found to overstate what evidence supports — and the precedent's chosen remedy was
   an append-only, dated correction that preserves the original record rather than rewriting it. Applying
   the same pattern to `spec.md` AC21 (append a dated correction note near AC21 stating the precise,
   proxy-level isolation mechanism actually verified, rather than editing the AC21 sentence in place)
   keeps `#526`'s spec.md an accurate historical record of what was believed and graded at merge time,
   while making the corrected, narrower claim discoverable at the point future readers would look for it.
4. This is consistent with the issue's own second remedy option ("amend the criterion text") and with the
   `m7` reviewer's own suggested direction ("narrowing the wording").

The plan that follows this research should treat the correction as living in **both** places: a new,
precisely-worded AC in `#575`'s own `spec.md` (the authoritative AC source for this bug fix, since Work
Mode is `full-bug`) asserting the corrected/verified property with fresh evidence, **and** a short,
dated append-only correction note in `#526`'s `spec.md` near AC21, cross-referencing `#575`, following the
`#487` P5-T3 pattern exactly (state the original claim, what was actually verified, and a pointer to the
correcting issue) — never rewriting AC21's original sentence or its `[x]` checkbox.

---

## 7. Files a fix would touch (repository-relative paths, exact — not globs)

### Gap 1 (call-site budget pinning)

- `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` — very likely requires a **split** before any
  addition, since it is 497/500 lines (confirmed by direct line count via the #526 reaudit's `wc -l`
  reproduction, `feature-audit.2026-08-26T04-33.md:62`, and independently confirmed as carried Minor `m1`).
- A **new test file** is the most probable outcome of that split, e.g.
  `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` (exact name is a plan-level
  decision; this path is a concrete, minimal, non-glob proposal consistent with the existing
  `<ScriptName>.Tests.ps1` naming convention and mirror-layout rule). It would dot-source
  `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` and mock only `Invoke-GitExe`, `Test-NpmVersionResolved`,
  `Wait-ForWorkflowRun`, `Test-PublishStepConclusion`, `Invoke-NpmExe`, and `Invoke-Sleep` (never
  `Invoke-TagPublishVerification`), per §4.3 option 1.
- No production `.ps1` file needs to change for Gap 1 in isolation: the shipped budgets are already
  correct (§1.3, §4.2). This is a test-only fix.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its byte-identical mirror
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — only if the split
  introduces a new production file needing `CodeCoverage.Path` registration; not needed if the split is
  test-file-only (test files are discovered via `Path = @('scripts', 'tests/powershell', 'tests/scripts')`,
  `pester.runsettings.psd1:3`, and are not part of the `CodeCoverage.Path` allow-list).

### Gap 2 (AC21 evidence/wording)

- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` — append a dated
  correction note near AC21 (line 417), per the recommended §6.3 pattern. Do not rewrite the AC21 sentence
  or its checkbox.
- `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/spec.md`
  — this feature's own spec, to be filled in with the precise, corrected AC text for both gaps (currently a
  blank `Draft` template; confirmed by direct read).
- A new evidence artifact under
  `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/evidence/qa-gates/`
  recording the corrected isolation-mechanism claim and/or a re-run of the proxy-isolation probe with
  precise wording (exact filename is timestamp-dependent at execution time per
  `evidence-and-timestamp-conventions`, so cannot be named exactly here).

No file under `scripts/dev-tools/Invoke-ReleaseVerification.ps1`,
`scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, or `.github/workflows/publish-mcp-npm.yml`
needs to change for either gap: both are test/documentation-precision fixes over already-correct
production behaviour.

---

## 8. Applicable toolchain

Per `.claude/rules/powershell.md` ("Toolchain"), run in order, restarting from step 1 on any failure or
auto-fix, per `.claude/rules/general-code-change.md` ("Mandatory Toolchain Loop"):

1. **Format** — `mcp__drm-copilot__run_poshqc_format` (repo-hosted equivalent used in #526 evidence:
   `Invoke-PoshQCFormat`, confirmed producing "Already formatted" / zero auto-fixes,
   `feature-audit.2026-08-26T04-33.md:65`).
2. **Lint** — `mcp__drm-copilot__run_poshqc_analyze` (repo-hosted equivalent: `Invoke-PoshQCAnalyze`,
   confirmed "PSScriptAnalyzer passed: no findings" in #526 evidence).
3. **Type check** — not applicable to PowerShell (per `.claude/rules/powershell.md:17` and
   `.claude/rules/general-code-change.md`'s toolchain step 3, skipped for PowerShell).
4. **Test with coverage** — `mcp__drm-copilot__run_poshqc_test`, using
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Coverage is reported **per file** via an
   explicit `CodeCoverage.Path` allow-list (verified: `pester.runsettings.psd1:17-245`); a new production
   file must be added to this list (and its byte-identical mirror at
   `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`) or it sits outside
   the coverage denominator, which the Coverage Exclusion Policy
   (`.claude/rules/general-unit-test.md`) forbids. Both `Invoke-ReleaseVerification.ps1`,
   `Invoke-ReleaseVerificationHelpers.ps1`, and `Invoke-ReleaseTagPush.ps1` are already registered
   (confirmed at lines 227, 235, and 41 respectively, in both copies).
   `CodeCoveragePercentTarget = 0` in this file — PoshQC itself does not gate on a percentage; the
   uniform >= 85% line-coverage threshold is a repository policy gate
   (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`), enforced by review/audit
   reading `artifacts/pester/powershell-coverage.xml`, not by the test runner failing the run.
   Branch coverage is not measured for PowerShell (Pester does not produce it); only the line threshold
   applies, per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`.

**Known MCP-runner constraint (not independently re-verified in this research session, carried from prior
session record).** A prior finding recorded in this repository's agent memory states that the MCP PoshQC
test runner (`mcp__drm-copilot__run_poshqc_test`) may read settings from an **installed VS Code extension**
rather than the repo-local `pester.runsettings.psd1`, so newly-added `CodeCoverage.Path` entries can be
silently ignored by the MCP path; the stated workaround is to invoke the self-hosted PoshQC module
directly (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root
(Get-Location).Path`), which is also exactly the invocation the #526 `network-isolated-suite` evidence
artifact used (§5.2). This constraint could not be re-verified within this read-only research session (it
would require actually running both the MCP and self-hosted paths against a coverage-list change) and is
reported here as inherited context, not as independently confirmed fact.

`quality-tiers.yml` does not exist at the repository root in this worktree (confirmed: file-not-found on
direct read and on glob search). This is noted as an observation; it is outside the scope of this
research's two gaps and is not investigated further here.

---

## Summary of findings for the planner

1. Gap 1's fix is **test-only**. No production budget value is wrong. The fix is a new Pester test
   (§4.3, §7) that mocks the three check entry points — not `Invoke-TagPublishVerification` — around a
   real invocation of `Invoke-ReleaseTagPushGuarded`, reproducing the #526 reaudit's `m8` probe
   methodology (its output transcript is recovered verbatim in §4.2; its source code is not committed
   anywhere in the `#526` feature folder and must be authored fresh). Landing it very likely requires
   splitting or supplementing `Invoke-ReleaseTagPush.Tests.ps1` first, because that file has 3 lines of
   headroom under the 500-line cap.
2. Gap 2's recommended fix is to **narrow AC21's wording** via an append-only, dated correction in
   `#526`'s `spec.md` (never rewriting the original AC21 sentence/checkbox) plus a fresh, precisely-worded
   AC in `#575`'s own `spec.md`, following the repository's own `#487` precedent for correcting a merged
   artifact's overstated claim. Building genuine host-level network isolation (Option A) was assessed and
   rejected as disproportionate: it requires new, elevated, host-mutating infrastructure this repository
   does not have and that no other gate in the corpus needs.
