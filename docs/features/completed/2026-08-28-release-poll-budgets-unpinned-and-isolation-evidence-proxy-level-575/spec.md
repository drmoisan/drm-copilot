# 2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level (Spec)

- **Issue:** #575
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T15-00
- **Status:** Draft
- **Version:** 0.2

## Context
Two follow-ups deferred from issue #526 (fixed by PR #564). First, no test pins the three per-check polling budgets at the call site, so a caller passing wrong explicit interval/attempts arguments would reproduce the original defect (a budget expiring early, tripping the pre-push check after the tag is pushed, and burning a version number on a false negative) while the suite stays green. Second, acceptance criterion AC21's network-isolation evidence is proxy-level: during #526's verification a raw socket still reached the registry from inside the "isolated" session, so the recorded isolation evidence proves less than the criterion states.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository toolchain (release scripts)
- Command/flags used: release verification flow shipped by PR #564
- Data source or fixture: #526 execution and reaudit artifacts under the feature folder; reaudit follow-up recorded as `m8`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Neither gap is a live defect today; both are regression exposure. The budget gap recreates a version-number-burning failure mode if the call site regresses; the AC21 gap records stronger evidence than exists.


## Repro & Evidence
Steps to Reproduce:
1. For the budget gap: change the call site to pass an explicit wrong budget (for example the 3-minute pair where the spec requires 20 minutes) for check (b); run the full test suite; observe it passes.
2. For AC21: rerun the isolation probe the #526 reaudit wrote (a raw socket to the registry from inside the isolated session); observe it connects despite the recorded isolation evidence.

Expected:
1. A call-site test pins each of the three checks to its specified interval/attempts pair, failing when any budget deviates from the spec.
2. AC21's evidence demonstrates actual network isolation (the probe cannot reach the registry), or the criterion's wording is corrected to state the weaker property that is actually verified.

Actual:
1. The three budgets are correct in the shipped code but are pinned by no test; the reaudit wrote a working probe for the budget check but did not land it as a test (follow-up `m8`).
2. AC21 is checked off but was graded PARTIAL during #526's review: the isolation evidence is a proxy (exit-code level), and a raw socket connection from inside the session succeeded.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: recorded in #526's reaudit artifacts (follow-up m8; AC21 graded PARTIAL) and disclosed in PR #564's review notes.


## Problem Statement

This bug records two distinct gaps left open by #526. Both are regression-exposure gaps, not live defects: the shipped, currently running code is correct for Gap 1, and the substantive test-purity guarantee behind Gap 2 already holds. Each gap is stated separately below.

**Gap 1 — call-site budget pinning (regression exposure, not a live defect).**
`Invoke-TagPublishVerification` (`scripts/dev-tools/Invoke-ReleaseVerification.ps1:353-358`) defaults its three per-check budgets to the values #526 §3.4 specifies: check (a) 10s x 18 attempts, check (b) 20s x 60 attempts, check (c) 15s x 40 attempts. These defaults are already pinned by a test (`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1:315-363`). The release path's actual call site, `Invoke-ReleaseTagPushGuarded` in `scripts/dev-tools/Invoke-ReleaseTagPush.ps1:244-250`, calls `Invoke-TagPublishVerification` with no explicit budget arguments and relies entirely on those defaults — and today those defaults are correct, so the shipped behavior is correct today. The gap is that `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` mocks `Invoke-TagPublishVerification` wholesale and its mock body discards all six budget parameters (`:41-72`), so no test would fail if a future edit to the call site passed explicit, wrong budget arguments (the same shape as the original #526 R1 defect). This is regression exposure: the code is right, and nothing would catch it going wrong.

**Gap 2 — AC21 isolation-evidence wording (regression exposure in the written record, not a live defect in test purity).**
#526's AC21 (`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md:417`) states that "the complete Pester suite passes with no network access available." The cited evidence (`evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md`) demonstrates only proxy-environment-variable isolation: `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY`/`NPM_CONFIG_REGISTRY` are redirected to an unreachable discard endpoint, which blocks `npm`, `gh`, and other proxy-aware clients. It does not block a raw socket: the #526 reaudit's own R4 probe opened a raw `TcpClient` to `registry.npmjs.org:443` from inside the same "isolated" session and it connected. AC21's second clause — that no test added or modified by #526 invokes `npm`, `gh`, or `git` as a real external process — already holds and was independently re-verified twice. The gap is confined to the first clause's wording, which overstates the isolation mechanism's depth; it was graded Minor `m7` / PARTIAL in the #526 feature-audit dated 2026-08-26T04-33.

## Scope & Non-Goals

- In scope:
  - A new Pester test file that pins the three per-check budgets (10s/18, 20s/60, 15s/40) at the actual release call site (`Invoke-ReleaseTagPushGuarded`), by mocking the check entry points and letting the real composition/forwarding logic run.
  - A dated, append-only correction note added near AC21 in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, cross-referencing this issue (#575), stating the original claim, what was actually verified, and the corrected, narrower claim.
  - This feature's own evidence artifacts under `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/evidence/`.
- Out of scope / non-goals:
  - Changing any shipped budget value in `scripts/dev-tools/Invoke-ReleaseVerification.ps1` or `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`. The shipped budgets are already correct.
  - Building real network-isolation infrastructure (Windows Firewall outbound-block rules, a container/VM boundary, or any other host-mutating or elevated mechanism) to make AC21's original wording literally true.
  - Rewriting AC21's original sentence or unchecking its `[x]` checkbox in #526's spec.md.
  - Changing `.github/workflows/publish-mcp-npm.yml`.
  - Changing `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`.
  - Fixing the latent `Test-PublishStepConclusion` unused-default-parameter mismatch described below; it is recorded as a follow-up, not fixed here (see "Latent-Mismatch Disposition").
- Explicitly excluded systems, integrations, or datasets:
  - `.github/workflows/verify-published-releases.yml` and any other workflow not named above.
  - Any change to `quality-tiers.yml` (which does not exist at the repository root in this worktree; out of scope and not investigated further).

## Root Cause Analysis
Deferred deliberately at #526's merge (2026-08-26) so the fix could land while CI was healthy; recorded in the parallel-run receipts as agreed follow-ups. The probe code for item 1 already exists in the reaudit artifacts (as a methodology description and a verbatim output transcript, not as committed source) and needs landing as a test.

## Design Decisions

**(a) The new test mocks the check entry points, never `Invoke-TagPublishVerification`.**
The new Gap 1 test dot-sources `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` and mocks only `Invoke-GitExe`, `Test-NpmVersionResolved`, `Wait-ForWorkflowRun`, `Test-PublishStepConclusion`, `Invoke-NpmExe`, and `Invoke-Sleep`. It never mocks `Invoke-TagPublishVerification`. This is a structural constraint, not a style preference: as long as `Invoke-TagPublishVerification` itself is mocked (as the existing `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` does), the composition/forwarding logic under test never runs, and no assertion against that mock can distinguish "the call site forwarded 20/60" from "the call site forwarded 10/18" — the mock's own `param()` block discards those values regardless of what is passed. Mocking the check entry points instead lets the real `Invoke-TagPublishVerification` defaults genuinely flow through to the mocked checks, reproducing the #526 reaudit's `m8` probe methodology exactly.

**(b) Option B (amend AC21's claim, append-only) was chosen over Option A (build real isolation).**
Option A — a Windows Firewall outbound-block rule or a container/VM boundary around the test runner — is technically capable of closing the gap, but requires new, elevated, host-mutating infrastructure this repository does not have today and that no other gate in the test corpus needs; a firewall-mutating test also falls outside what `.claude/rules/general-unit-test.md` permits a unit test to do to its host. Option B costs no new infrastructure: the existing `network-isolated-suite` evidence already supports a precise, narrower, true claim (proxy-aware clients are redirected to an unreachable endpoint; a raw socket is not blocked by this mechanism), and AC21's substantive guarantee (clause 2: no test invokes `npm`, `gh`, or `git` as a real external process) is untouched and independently re-verified. The correction is applied append-only, following the repository's own precedent at `docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/documentation-corrections.2026-08-20T20-02.md`, which corrected a prior audit's false claim by appending a dated `## Correction` section rather than rewriting the original text. The same pattern is applied here: append a dated correction note near AC21 in #526's spec.md; do not edit AC21's original sentence or checkbox.

## Latent-Mismatch Disposition

`Test-PublishStepConclusion`'s own, independent default parameters (`scripts/dev-tools/Invoke-ReleaseVerification.ps1:272-273`, `IntervalSeconds=10, MaxAttempts=18`, i.e. 3 minutes) do not match the #526 §3.4 ceiling for check (b), which is 20 minutes (20s x 60 attempts). This mismatch is **out of scope for this fix**. It is inert today: `Invoke-TagPublishVerification` always calls `Test-PublishStepConclusion` with explicit `-IntervalSeconds`/`-MaxAttempts` arguments (`:372-377`), so no production code path reaches the function's bare defaults, and no existing test exercises them either. Fixing it is not required to close either Gap 1 or Gap 2, and this feature's scope is deliberately limited to the two gaps in the issue statement.

This mismatch must not be silently dropped. It is recorded as an explicit follow-up item in "Rollout & Follow-up" below, so a later feature or issue can correct `Test-PublishStepConclusion`'s own default parameter values (or document why they are intentionally divergent) without needing to rediscover the mismatch from source.

## Proposed Fix

### Design summary (what changes where):
- Gap 1: add a new Pester test file at `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` that pins the three call-site budgets by invoking `Invoke-ReleaseTagPushGuarded -ConfirmToken yes` with the check entry points mocked (never `Invoke-TagPublishVerification`).
- Gap 2: append a dated correction note near AC21 in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, and add a fresh, precisely-worded AC in this spec (below) asserting the corrected, narrower isolation claim with its own evidence.

### Boundaries and invariants to preserve:
- No shipped budget value changes.
- AC21's original sentence and `[x]` checkbox in #526's spec.md are never rewritten.
- No production `.ps1` file under `scripts/dev-tools/` is required to change for Gap 1; if the executor determines a production change is unavoidable, it must be limited to `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` only, since `Invoke-ReleaseVerification.ps1` and `Invoke-ReleaseVerificationHelpers.ps1` are explicitly out of scope.

### Dependencies or blocked work:
- `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` is 497 of 500 lines; it cannot absorb the new assertions in place. The new test content lands in a new sibling file rather than an in-place addition.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1`.
- Modified (append-only): `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`.
- New: an evidence artifact under `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/evidence/qa-gates/`, named per `evidence-and-timestamp-conventions`.
- This feature's own `spec.md` (this file).

#### Functions/classes/CLI commands impacted:
- `Invoke-ReleaseTagPushGuarded` (`scripts/dev-tools/Invoke-ReleaseTagPush.ps1`) — no signature change; newly covered by a budget-pinning test.
- `Invoke-TagPublishVerification` (`scripts/dev-tools/Invoke-ReleaseVerification.ps1`) — no change; its defaults are exercised, not modified, by the new test.

#### Data flow and validation changes:
- None. This is test and documentation coverage over existing, correct behavior.

#### Error handling and logging updates:
- None.

#### Rollback/feature-flag considerations (if applicable):
- Not applicable; the change adds test and documentation artifacts only.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- The new test asserts `Wait-ForWorkflowRun` is invoked with `-IntervalSeconds 10 -MaxAttempts 18`, `Test-PublishStepConclusion` is invoked with `-IntervalSeconds 20 -MaxAttempts 60`, and `Invoke-NpmExe` is invoked exactly 40 times with 39 intervening `Invoke-Sleep -Seconds 15` calls, mirroring the pattern at `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1:315-363`.

#### Required configuration keys and defaults:
- None added.

#### Backward-compatibility expectations:
- No public interface changes.

#### Performance constraints (latency/throughput/memory):
- The new test must not invoke `Start-Sleep` or otherwise consume wall-clock time; `Invoke-Sleep` is mocked to a no-op per `.claude/rules/general-unit-test.md`.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the Pester runner and mocking seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-Sleep`, `Wait-ForWorkflowRun`, `Test-PublishStepConclusion`, `Test-NpmVersionResolved`) used by existing tests are available and behave identically for the new file.
- Constraints (budget, performance, compatibility): new/modified `.ps1` files must not exceed 500 lines (`.claude/rules/general-code-change.md`); no temporary files or real external processes in tests (`.claude/rules/general-unit-test.md`).
- External dependencies (services, libraries, releases): none; the release verification flow shipped by PR #564 is unchanged.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy
Seeded from issue:

- [ ] Land the reaudit's budget probe as a call-site test pinning all three interval/attempts pairs.
- [ ] Replace AC21's proxy evidence with a real isolation assertion (probe must fail to connect), or amend the criterion text.
- [ ] Zero-regression toolchain pass on the release-script test suite.

- Regression tests to add or update: `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` (new).
- Unit tests (Pester) for the fixed behavior and boundaries: assertions for checks (a), (b), and (c) budgets as specified above, with the check entry points mocked and `Invoke-TagPublishVerification` left real.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): not applicable — this is a coverage-only addition over already-correct defaults; no new production branch is introduced.
- Error handling and logging verification: not applicable.
- Coverage impact and targets for changed lines/modules: no reduction in existing line coverage for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`; overall repository line coverage remains >= 85% (no branch-coverage threshold applies to PowerShell).
- Toolchain commands to run (format → lint → test): PoshQC format, PSScriptAnalyzer analyze, Pester test (type-check is skipped for PowerShell per `.claude/rules/powershell.md`).
- Manual validation steps (if required): none.


## Acceptance Criteria

- [x] AC1 — A new file `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` exists, dot-sources `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, and contains no `Mock -CommandName Invoke-TagPublishVerification` line.
- [x] AC2 — In that file, an `It` test invoking `Invoke-ReleaseTagPushGuarded -ConfirmToken yes` asserts, via a `-ParameterFilter` on a mock of `Wait-ForWorkflowRun`, that the call site forwards `IntervalSeconds 10` and `MaxAttempts 18` for check (a).
- [x] AC3 — In the same file, an `It` test asserts, via a `-ParameterFilter` on a mock of `Test-PublishStepConclusion`, that the call site forwards `IntervalSeconds 20` and `MaxAttempts 60` for check (b).
- [x] AC4 — In the same file, an `It` test asserts exactly 41 calls to `Invoke-NpmExe` and exactly 39 calls to `Invoke-Sleep` filtered to `$Seconds -eq 15` for check (c), mirroring the assertion pattern at `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1:315-363`.
- [x] AC5 — `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` passes with zero failures after the new file is added, without requiring any of its own existing assertions to change.
- [x] AC6 — `tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1` is at most 500 lines, and no other new file added by this fix exceeds 500 lines.
- [x] AC7 — PoshQC format (`Invoke-PoshQCFormat` or the equivalent MCP tool) completes against every file changed or added by this fix with zero auto-fixes applied.
- [x] AC8 — PSScriptAnalyzer (`Invoke-PoshQCAnalyze` or the equivalent MCP tool) reports zero findings against every file changed or added by this fix.
- [x] AC9 — The complete repository Pester suite (`Invoke-PoshQCTest`) passes with zero failed tests after this fix lands.
- [x] AC10 — The repository Pester coverage report shows line coverage of at least 85% for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` after this fix lands, with no reduction from its pre-fix coverage value.
- [x] AC11 — `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` carries a new section headed exactly `## Correction — 2026-08-28 (issue #575)`, appended after AC21's existing location in the document (not inserted at or before line 417), following the append-only pattern used at `docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/documentation-corrections.2026-08-20T20-02.md`.
- [x] AC12 — That correction section states the original claim ("no network access available"), states the mechanism actually verified ("proxy-aware network clients ... redirected to an unreachable discard endpoint; a raw socket is not blocked by this mechanism"), and contains the literal token `#575`.
- [x] AC13 — The AC21 line in `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md` (line 417, beginning `- [x] AC21 — The complete Pester suite passes with no network access available`) is byte-for-byte identical before and after this fix lands, and its checkbox remains `- [x]`.
- [x] AC14 — A new evidence artifact exists under `docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/evidence/qa-gates/`, recording the corrected, proxy-level isolation-mechanism claim.
- [x] AC15 — That evidence artifact records a reproduction of the raw-socket probe (a `System.Net.Sockets.TcpClient` connection attempt to `registry.npmjs.org:443` from inside the proxy-isolated session) and its result, and separately reaffirms that no test added or modified by #526 invokes `npm`, `gh`, or `git` as a real external process.
- [x] AC16 — This spec's "Rollout & Follow-up" section (below) records the `Test-PublishStepConclusion` default-parameter mismatch (its own defaults of 10s/18 attempts versus the #526 §3.4 check-(b) ceiling of 20s/60 attempts) as an explicit follow-up item, out of scope for this fix.
- [x] AC17 — The diff delivered by this fix modifies no line of `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, or `.github/workflows/publish-mcp-npm.yml`.

## Risks & Mitigations
- Technical or operational risks: the AC21 correction, if mis-applied, could be read as retracting a merged feature's evidence. Mitigation: the append-only pattern (AC11-AC13) preserves the original text and checkbox and adds only a clearly dated, clearly attributed correction.
- Technical or operational risks: a new test file added to `tests/scripts/dev-tools/` that is not registered in `pester.runsettings.psd1`'s `CodeCoverage.Path` allow-list would not itself require registration, since it is a test file, not a production file; the corresponding production file `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` is already registered. Mitigation: no action needed, confirmed by direct read of `pester.runsettings.psd1:41`.
- Mitigations and rollbacks: both changes (new test file, append-only doc correction) are additive and can be reverted independently without affecting shipped release-verification behavior.

## Rollout & Follow-up
- Release/rollout steps: none beyond the standard PR merge; no production behavior changes.
- Post-fix monitoring or clean-up tasks:
  - Follow-up: correct `Test-PublishStepConclusion`'s own default parameter values (`scripts/dev-tools/Invoke-ReleaseVerification.ps1:272-273`, currently `IntervalSeconds=10, MaxAttempts=18`) to match the #526 §3.4 check-(b) ceiling (20s / 60 attempts), or document why the divergence is intentional. This is out of scope for #575 because no production code path reaches the bare defaults today; it is recorded here so it is not silently dropped. The mismatch is confined to Test-PublishStepConclusion's own default parameter values; the call site (`Invoke-TagPublishVerification`) always overrides them with explicit arguments.
- Links: issue #575; issue #526 (deferred origin); PR #564 (#526's merge); #526 feature-audit dated 2026-08-26T04-33 (`m7`, `m8` findings); #487 correction precedent (`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/`).
