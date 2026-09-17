# Code Review — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T12-29
- Base: `epic/worktree-scoped-state-resolution-integration` @ `d039e89b2b2569151e9170e1bbefb9f974419f87`
- Head: `feature/2026-09-13-prd-feature-gate-target-resolution-672` @ `03dfdc84fa7fd6107545d4b52f34247961d306f5`
- Scope: full branch diff, 50 files, 2709 insertions, 455 deletions

## Executive Summary

The implementation is well structured and disciplined. The extraction into a dot-sourced sibling is clean,
the two relocated functions are byte-identical to their originals, the F1 resolution contract is consumed
rather than re-implemented, and the new Pester suite is one of the stronger suites in this hook family:
every existence mock is keyed on a fully composed path, allow rows assert exact positive invocation counts,
and the ambiguity branch carries a zero-invocation guard. Formatter, analyzer, file-size, mirror-parity,
and delivery-registration gates are all clean under independently re-run commands.

The substantive concern is the scope of the repair. `Get-PrdFeatureCallTarget` short-circuits to `$null`
unless the call text carries an absolutely-placed path token, so the fix changes behaviour only for
absolute citations. A repo-relative citation from a coordinating session root — the first row of the
decision matrix in `issue.md` and the shape the originating run actually used — still denies, and still
denies with the misleading work-mode-marker reason. The pre-filter also makes F1's `Branch` and relative
`FilePath` signals unreachable from this hook, so the one remaining channel that could have placed such a
call is closed off.

Three lower-severity findings concern documentation that no longer matches the code.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | lines 242-245, and the guard at line 368 | The absolutely-placed-token pre-filter returns `$null` for any call whose text carries no drive-rooted or slash-rooted token, so a repo-relative citation derives no target, probes the bare repo-relative path against the process working directory, and denies with the work-mode-marker reason. This is unchanged from the pre-change hook and is the first row of the verified decision matrix in `issue.md`. | Either derive a target for repo-relative citations by handing the text to `Resolve-WorktreeCallTarget` unfiltered so its `Branch` and `FilePath` signals can place the call, or — if the current behaviour is intended — make the folder-absent case on that path emit the ambiguity reason code rather than the marker-is-broken reason, and record the scope decision in `spec.md` and in the hook's `.DESCRIPTION`. | The marker-is-broken reason prescribes editing `issue.md`, a remedy that is wrong whenever the true condition is "this folder was probed at the wrong root". Acceptance criterion 6 exists specifically to remove that remedy from this path. | Review diagnostic D2: prompt `Plan the work in docs/features/active/2026-09-13-synthetic-target-672 now.`, `cwd` a coordinating session root, document present only under the item worktree, yields `deny` with `PRD_FEATURE_BLOCKED: resolved feature folder '...', but its work mode could not be determined from '.../issue.md' ...`. Identical to the pre-change reason recorded in `evidence/regression-testing/fail-before.2026-09-17T11-20.md`. |
| Major | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | lines 14-34 | The `.DESCRIPTION` resolution-order block still documents behaviour the change set removed: step 2 states "otherwise the earliest-occurring candidate in the prompt wins", and step 3 states "If no candidate was found in the prompt, read the feature-folder field from artifacts/orchestration/orchestrator-state.json" with no qualification. Both were deliberately removed by acceptance criteria 5 and 4 respectively. | Rewrite steps 2 and 3 to describe the derived-target disambiguator, the unresolved-tie deny, and the session-root-only condition on the checkpoint fallback; add a step describing the ambiguity branch. | The comment-based help on an enforcement hook is the operator-facing contract; a reader diagnosing a denial will be misled about which rule fired. The same file is the bundled payload shipped to consumer repositories. | `git show <base>:.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 25-32 are carried unchanged into the head revision at lines 25-32, while the code they describe changed at lines 316-336. |
| Major | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | lines 219-223 and 242-245 | The pre-filter is itself target-derivation policy living in the hook rather than in the F1 module, and it narrows F1's contract: `Resolve-WorktreeCallTarget` accepts feature-folder, file-path, and branch signals, but the pre-filter suppresses the latter two whenever no absolute token is present. | Move the decision about which signals are admissible into the F1 module, or delete the pre-filter and let `Resolve-WorktreeCallTarget` return `NoTarget` for a call it cannot place. | Spec non-goal 2 states that target derivation is consumed from F1 and not re-implemented locally. A local predicate that decides when derivation may run is a partial re-implementation of derivation's input contract, and it is invisible to F1's own suites. | Review diagnostic D3: adding `branch: feature/2026-09-13-x-672` to an otherwise repo-relative prompt produces the identical marker-is-broken deny, proving the branch signal never reaches F1. |
| Minor | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | lines 12-13 versus line 21 | The file's own `.DESCRIPTION` states "The file declares no file-scope parameter block, no requires directive, and no entrypoint. It is loaded for its declarations only." The file does execute one file-scope statement, an unguarded `Import-Module`. | Amend the sentence to state that the only file-scope statement is the resolution-module import, and that the import is deliberately unguarded so an unloadable module fails the gate closed. | A future reader relying on "declarations only" may dot-source the file expecting no side effects. The import is a deliberate and correct design choice; only the description is inaccurate. | Direct read of the delivered file. |
| Minor | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` | acceptance criterion at line 655 | The criterion states the new suite "derives no absolute path from the environment, the current directory, the script file location, or a source-control query". The suite necessarily derives the path to the files under test from `$PSScriptRoot` at lines 99, 100, 109, and 110. | Narrow the criterion's wording to the modelled or synthetic paths, which is plainly the intent stated in its following sentence. | The delivered suite satisfies the intent completely; the criterion as written is over-broad and cannot be satisfied by any Pester suite that loads a file under test. | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` lines 99-110. |
| Informational | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | line 334-336 | The `$target.WorktreeRoot` dereference in the deny detail is reachable only when `Status` is `OtherWorktree`, because the `Ambiguous` case returns at line 312 and the `NoTarget`/`SessionRoot` cases are absorbed by `Test-PrdFeatureSessionRootTarget`. The reasoning is correct but depends on the ordering of two non-adjacent branches. | No change required. Optionally assert the status inline for readability. | Recorded so a future edit that reorders those branches is recognised as load-bearing. | Direct read plus the `New-WorktreeResolutionTargetResult` invariant that `WorktreeRoot` is null for the two unresolved states. |
| Informational | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` | The coverage configuration is an explicit per-file allow-list rather than an exclude list, so any production PowerShell file not named there is outside the coverage denominator. This branch correctly registers its new file in both copies. | No change required in this branch. The allow-list model is a repository-wide concern. | Recorded because the Coverage Exclusion Policy's intent is a complete denominator, and an allow-list achieves that only by continuous maintenance. | `git diff` of both `pester.runsettings.psd1` copies shows the identical 4-line addition. |

## What the change set does well

- **The extraction is behaviour-preserving and verifiable as such.** `Resolve-PrdFeatureWorkMode` and
  `Get-PrdFeatureRequiredFile` diff to a single trailing blank line against their base-branch originals.
  That is exactly what acceptance criterion 27 asks for and it makes the extraction reviewable
  independently of the behaviour change.

- **The test suite resists the failure mode the spec names as highest risk.** Every
  `Get-PrdFeatureFileExistence` mock answers true only for one fully composed path, allow rows assert
  `-Times N -Exactly`, and the ambiguity branch asserts `-Times 0 -Exactly`. An implementation that
  returned `allow` without probing, or that probed a path it never composed, fails the suite. The change
  set also replaces a pre-existing blanket `{ $true }` mock in `enforce-prd-feature-before-planner.Tests.ps1`
  with a path-keyed one, which is a net improvement outside the minimum required.

- **The modelled target objects are built with F1's own constructor.** `New-ModelledTarget` calls
  `New-WorktreeResolutionTargetResult`, so the injected shape is the shipped shape and cannot drift from
  it. This is a materially better choice than hand-rolling a `pscustomobject` with the fields the hook
  happens to read today.

- **Both suites now dot-source the helpers file explicitly** rather than relying on the parent's own
  dot-source line, with a stated rationale. That removes a class of silent redirection.

- **Fail-before evidence distinguishes behavioural failures from binding failures.** Two of the ten rows
  fail against the pre-change hook with `Expected 'deny' But was 'allow'` rather than a parameter-binding
  error, which is the only form of fail-before proof that rules out a vacuous pass.

- **Fail-closed discipline is explicit and commented.** Both `Import-Module` calls are unguarded on
  purpose, the indeterminate-marker branch denies without naming a prerequisite set, and
  `Get-PrdFeatureRequiredFile`'s `default` arm returns `spec.md` alone rather than an empty set.

## Design and structure

The decision function reads as a sequence of guarded early returns in a deliberate order: payload anomaly,
non-planner passthrough, ambiguity, unresolved tie, checkpoint fallback, no-folder, probe-path composition,
folder-absent-under-target, indeterminate marker, missing documents, allow. Each branch carries a comment
explaining why it sits where it does. That is the right shape for a gate whose correctness is about branch
ordering.

The split between parent and sibling is principled rather than arbitrary: the three functions that touch
disk stay in the parent, which is what the existing suites mock, and the pure string and collection logic
moves out. The parent retains 69 lines of headroom and the sibling 186.

One structural observation. `ConvertTo-PrdFeatureFolderToken` performs two distinct jobs — placing an
absolute token via F1's normalisation, then collapsing depth to four segments. The two halves are
documented separately and correctly, but a caller reading the name would not expect the second. The name
is accurate enough that this is not worth changing on its own.

## Error handling and logging

Every failure path denies. No path returns `allow` on an error condition. The two `catch` blocks in the
parent return `$null` for an unreadable file, and every caller treats `$null` as "not present", which is the
fail-closed reading. Deny reasons are specific, name the resolved folder first, and retain the
`PRD_FEATURE_BLOCKED:` prefix so existing greps continue to work. The ambiguity code is read from the F1
module rather than restated, so the gate and the module cannot disagree about its spelling — a good
decision that removes a whole class of drift.

The one weakness is the one recorded as finding B1: on the repo-relative path a resolution failure is
reported as a marker failure, and the remedy the message prescribes is wrong for that condition.

## Test quality

Determinism is genuinely achieved, not merely asserted. A scan of all three suites for `Start-Sleep`,
`Get-Date`, `New-Guid`, `New-TemporaryFile`, `TestDrive`, `Set-Location`, `Push-Location`, and `$env:TEMP`
returns zero matches. The modelled current directory is carried as data on an injected target result rather
than read from the process, which is the requirement `.claude/rules/powershell.md` imposes and which most
hook suites in this repository satisfy less cleanly.

Coverage of the delivered code is 93.55 percent on the sibling and 90.91 percent on the parent. The
uncovered lines are the real-disk checkpoint read and the entry-point tail, which are the two regions that
were uncovered at baseline as well.

Gap worth noting alongside finding B1: there is no row exercising a repo-relative citation from a session
root that differs from the target. The suite's second row (`allows when the modelled cwd is the item
worktree`) uses the repo-relative form but models the two roots as coincident, so it cannot detect the
behaviour B1 describes. A row for that shape would have surfaced the gap during execution.

## Documentation

Three of the six findings are documentation accuracy issues (M1, the helpers `.DESCRIPTION`, and the
over-broad acceptance-criterion wording). None affects runtime behaviour, but M1 is on the operator-facing
contract of a shipped enforcement hook and should be corrected before merge.

Positively: the plan, the spec, and 36 evidence artifacts give an unusually complete record of what was
run and why, and the per-task deviation notes for the four unchecked tasks are honest and specific rather
than glossed.

## Recommendation

Address finding B1 and finding M1 before merge. The remaining findings can be folded into the same
remediation pass or deferred, at the maintainer's discretion. The two repository-wide Pester failures are
pre-existing and environment-coupled and should not block this branch; they warrant a separate issue
against the two suites that read live orchestration state through unmocked seams.
