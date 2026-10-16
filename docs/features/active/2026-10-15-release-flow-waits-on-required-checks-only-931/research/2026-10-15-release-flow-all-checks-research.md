# Research: release flow waits on all checks (Issue #931)

- Issue: #931 (minor-audit bug)
- Branch: bug/release-flow-waits-on-required-checks-only-931
- Date: 2026-10-15
- Scope: `Wait-ForPullRequestChecks` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`
- Method note: no shell was available in this research session, so no command was executed. Line counts come from the line numbers reported by file reads. `gh` behavior comes from the `gh` manual page and `pkg/cmd/pr/checks/checks.go` on the `trunk` branch, both fetched through a summarizing fetch tool; they are not verified against the `gh` version installed on the operator machine.
- No numeric `spec.md` acceptance criterion is proposed here, so no Numeric Derivation Evidence section is required.

## 1. Current state

- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:162-258` defines `Wait-ForPullRequestChecks`.
  - Line 220: `$ghArgs = @('pr', 'checks', $PrNumber, '--required', '--json', 'bucket')`.
  - Lines 223-232 (Phase A): loop while `$poll.ExitCode -ne 0`; sleep through the `Invoke-Sleep` seam; return 1 after `RegistrationMaxAttempts` (default 24, 5 s).
  - Line 234: `$buckets = @(($poll.Output -join "`n") | ConvertFrom-Json) | ForEach-Object { $_.bucket }`.
  - Lines 236-257 (Phase B): return 1 on `fail` or `cancel` (message at line 239, "A required check failed ..."); return 0 when no bucket equals `pending` (lines 243-246); otherwise sleep and re-poll (lines 253-255), up to `CompletionMaxAttempts` (default 120, 10 s).
  - Because line 243-245 only tests for the presence of `pending`, an empty `$buckets` (nothing to test) and an unknown bucket both fall through to `return 0`.
- Wording that says "required": script header lines 15-16 ("reports checks success"), help text lines 165, 167, 196; `SuppressMessageAttribute` justification at line 200; stderr message line 239.
- The caller is `Invoke-FullReleaseFlowGuarded` line 364: `Wait-ForPullRequestChecks -PrNumber $prNumber`; any non-zero result returns 1 before the merge at line 369.
- `Invoke-GhExe` (lines 85-100) runs `& gh @GhArgs 2>&1`, so stderr text is merged into `Output`; `ExitCode` is `$LASTEXITCODE`.

## 2. Question 1: `gh pr checks` semantics

- Bucket vocabulary (gh manual, https://cli.github.com/manual/gh_pr_checks): `bucket` "categorizes the `state` field into `pass`, `fail`, `pending`, `skipping`, or `cancel`". JSON fields: `bucket, completedAt, description, event, link, name, startedAt, state, workflow`. `--required` is "Only show checks that are required". Documented additional exit code: `8: Checks pending`.
- Source (`pkg/cmd/pr/checks/checks.go`, trunk, as summarized):
  - Zero reported checks returns an error before any output: `no checks reported on the '<branch>' branch`. This is a plain error, so a non-zero exit (1 by cobra/gh convention; the manual does not state the number).
  - With `--required` and zero required checks after filtering: error `no required checks reported on the '<branch>' branch`, also before the pending/failed logic.
  - At the end of `checksRun`: `counts.Failed > 0` returns `cmdutil.SilentError` (exit 1); else `counts.Pending > 0` returns `cmdutil.PendingError` (exit 8). Failure outranks pending.
  - `--json`: `if opts.Exporter != nil { return opts.Exporter.Write(opts.IO, checks) }` returns before the failed/pending exit logic. With `--json` the exit code is therefore 0 for pass, fail, and pending sets; only the two "no checks" errors (and transport/auth errors) exit non-zero.
- Implication for the registration loop:
  - Because the script always passes `--json`, a pending or failing set exits 0 today and goes to Phase B (this is why the existing tests model `fail` as `ExitCode = 0`, `Tests.ps1:305`, `ChecksWait.Tests.ps1:99`). Exit 8 is not reachable on the current argument list, so a pending set does not loop in Phase A. Dropping `--required` does not change that.
  - What changes when `--required` is dropped: the "no required checks reported" case (checks exist but none are required) no longer ends in a Phase A timeout; it becomes a normal non-empty set. The "no checks reported" case (exit 1) still loops in Phase A until the registration budget expires and then returns 1, which is the correct non-green outcome.
  - Phase A treats every non-zero exit as "not yet registered", including auth or network errors. This only delays the failure by the registration budget (24 x 5 s); it is not a green path and is left unchanged.
  - Residual unknown: the `--json` exit-code behavior is read from trunk source. A positive assertion over parsed buckets makes the function correct whichever exit code `gh` returns, because Phase B never trusts the exit code for green.

## 3. Question 2: the #899 rule

- Parser: `.claude/lib/ci-gate/Invoke-CiGateParser.ps1:19-26` and `Get-CiGateConclusion` (lines 118-241).
  - `fail` or `cancel` returns `failure` immediately (lines 206-207); `pending` is recorded and decides only after failures are ruled out (lines 208, 230-232); `pass` and `skipping` are non-blocking (lines 209-219).
  - Empty or null set returns `success` unless `-RequireWorkflow` is set (lines 177-182), in which case `pending`.
  - Unknown bucket throws, naming the value (lines 220-224); a check without a `bucket` property throws (lines 196-198).
  - Order dependence: a failure that appears after an unknown bucket in the array is not reached because the throw happens first.
- S9 text: `.claude/skills/orchestrate/SKILL.md:292-299`. Query is `gh pr checks --json bucket,name,state,link,workflow` with no `--required` (line 292); "no checks reported" is never green for any PR and keeps the gate `pending` on a non-epic PR (line 294); success means every queried check passed or was skipped (line 298); poll timeout is `awaiting_ci`, not remediation (line 299).
- Consistent semantics for the release flow (recommended in section 11): all checks queried; `skipping` non-blocking; `fail`/`cancel` fail; empty set is never green (stricter than the parser default and equal to S9's no-checks rule); unknown bucket is never green. The release flow must be at least as strict as the parser's default path, and stricter on the empty set to match S9 line 294.

## 4. Question 3: deadlock risk on a release PR

- Branch names: `Invoke-FullRelease.ps1:211` builds `release/<Label>-<yyyyMMddHHmmss>`; label is `'full'` (line 276); PR is `gh pr create --base main --head <branch>` (line 342). So head `release/full-<timestamp>`, base `main`. Files changed: `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json`, lockfiles, and Codex MCP pins (`Invoke-FullRelease.ps1:14-19`).
- Workflows that run on that PR:
  - `ci.yml` (`pull_request` to `main`, `development`, `epic/**`, lines 6-7): nine jobs, including `NPM Audit Gate` (line 35-41). No `environment:` key and no `concurrency:` key exists in any workflow under `.github/workflows/` (grep over the directory found `environment:` nowhere; `concurrency` appears only in `README.md:79` prose).
  - `npm-audit-gate.yml` (lines 8-14): `pull_request` to `main` with `**/package.json` and lockfile paths; the release PR matches, so a second `npm-audit` check runs. A new advisory fails it; that is the behavior #899 and #931 intend.
  - `publish-extension.yml` (lines 12-15): runs on PRs touching `extensions/drm-copilot/**`; the release PR matches. Jobs `Extension Tests (ubuntu/windows)` and `Publish to Marketplace` (lines 39-65) both run; the publish step is guarded by `startsWith(github.ref, 'refs/tags/v')` (line 63), so a PR run packages only and the job concludes success. Comment lines 8-11 confirm "PR runs never publish".
  - `publish-mcp-npm.yml` (lines 12-15): matches `packages/mcp-server/**`; `Publish to npm` job runs on the PR with all tag-dependent steps ref-guarded (lines 73, 93, 102).
  - `verify-published-releases.yml` (lines 16-19): path filter is its own file and `Invoke-ReleaseReconciliation.ps1`; the release PR does not match, and its network steps are `github.event_name != 'pull_request'` (lines 51, 57).
- Non-required checks that could stay pending indefinitely: none found. No environment-approval job, no manual-gate job, no concurrency group that could queue a run indefinitely, and the `Publish to ...` jobs conclude success (publish steps skipped) on PRs. Skipped steps do not change the job bucket; skipped jobs would report `skipping`, which is accepted.
- Checks expected to fail on a release PR: none found. A failure in any of these workflows is a real defect on the release head and should block the release.
- Unknown (not derivable from the repository): wall-clock duration of the slowest workflow versus the completion budget (120 x 10 s = 1200 s). A timeout returns 1 and stops before the merge; it does not merge. The parameters remain overridable. Decision: all-checks waiting is safe from deadlock on the evidence above.
- Race to record: path-filtered workflows (`publish-extension`, `publish-mcp-npm`, `npm-audit-gate`) may register a few seconds after the first `CI` check. Phase B could read a non-empty all-pass set before a late workflow registers. This race exists today with `--required` and in S9 (#899); it is accepted for parity. A confirmation re-poll would alter the exact `Invoke-Sleep` and `Invoke-GhExe` call counts asserted at `ChecksWait.Tests.ps1:34, 54, 74, 111, 138`, so it is rejected as out of scope for a minor-audit fix.

## 5. Question 4: test inventory

| File | Last content line | Role |
|---|---|---|
| `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` | 426 | Flow-level suite for `Invoke-FullReleaseFlowGuarded` |
| `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` | 141 | Direct suite for `Wait-ForPullRequestChecks` |
| `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` | 99 | Parameterized preflight and post-PR failure paths |
| `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | 401 | Production script |

- Assertions coupled to `--required` or required wording:
  - `Invoke-FullReleaseFlow.Tests.ps1:71`: success mock matches `'pr checks 291 --required --json bucket'` (exact joined string; a changed argument list falls through to the default `@{ Output = @(); ExitCode = 0 }` at line 79, which would be an empty set).
  - `Invoke-FullReleaseFlow.Tests.ps1:170`: `$ghFlat | Should -Be @('pr view ...', 'pr checks 291 --required --json bucket', 'pr merge 291 --merge --delete-branch')`.
  - `Invoke-FullReleaseFlow.Tests.ps1:304-305`: failure mock `'pr checks 291 --required --json bucket'` returns `[{"bucket":"fail"}]`.
  - `Invoke-FullReleaseFlow.Tests.ps1:313`: `Should -Match "A required check failed for PR #291"`.
  - `Invoke-FullReleaseFlow.Tests.ps1:335-336`: merge-fails mock matches the `--required` string and returns pass.
  - `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1:110`: `Should -Match "A required check failed for PR #291"`.
  - No assertion in `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` is coupled: line 80 uses the regex `'^pr checks '` and returns `[{"bucket":"pass"}]`, which stays green under the new rule.
- Not coupled (keep as is): `ChecksWait.Tests.ps1:53` ("did not register within the timeout") and `:92` ("did not complete within the timeout"); the new rule must keep those two message fragments.
- Mock seams and loading:
  - `Invoke-GhExe` mocked per test; flow suite dispatches on the joined argument string (`Tests.ps1:65`), the ChecksWait suite dispatches on call counters (`ChecksWait.Tests.ps1:19-23, 63-67`).
  - `Invoke-Sleep` mocked in `BeforeEach` for the flow and failure-path suites (`Tests.ps1:14`, `AdditionalFailurePaths.Tests.ps1:14`) and inside each ChecksWait test, with `Should -Invoke ... -Times N -Exactly` at `ChecksWait.Tests.ps1:34, 74, 138`.
  - `Write-StderrLine` mocked to capture the last message (`ChecksWait.Tests.ps1:45-48, 84-87, 102-105`).
  - All three suites start with `Set-StrictMode -Version Latest` (line 1), resolve the script with `Resolve-Path (Join-Path $PSScriptRoot "../../../scripts/dev-tools/Invoke-FullReleaseFlow.ps1")` (line 4), and dot-source it with `. $script:scriptPath -ConfirmToken 'no'` (line 5); the entry-point guard at script line 398 (`$MyInvocation.InvocationName -ne '.'`) suppresses execution. The functions run under strict mode, so a bucket object without a `bucket` property throws on `$_.bucket` unless the function guards it.
- File-size constraint: `Invoke-FullReleaseFlow.Tests.ps1` is about 74 lines under the 500-line limit. Edit it in place only (replace the four argument strings and the wording at line 313). Put all new tests in `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (about 141 lines now; room for roughly 350 more).

## 6. Question 5: mirrors and references

- Repo-wide search excluding `docs/features/**` for `FullReleaseFlow`, "Automate Full Release", "wait for checks": hits only in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, the three Pester files, `.vscode/tasks.json` (lines 163-183, 238-299), and `docs/research/2026-07-09-active-features-delivery-status-audit.md:26, 31` (historical audit, not a behavior description). No copy of the script exists under `extensions/**/resources/**`, `.codex/**`, `.github/**`, or the skills and agents trees.
- `.vscode/tasks.json:182` ("wait for checks") and `:298` ("waits for gh checks") do not say "required"; they remain accurate and need no edit.
- A second search for "required check(s)" and `--required` outside `docs/features/**` found the release-flow script itself plus unrelated or already-handled text: `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, `Invoke-CiGateParser.ps1:197` and its bundle mirror (an error message about a missing `bucket` property, unrelated to population), and `.claude/skills/quota-throttling/SKILL.md:180` (an illustration about empty sets, unrelated).
- Contract test recommendation: extend `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (266 lines) with one parametrized-style test pinning the release flow, because the Pester suites cannot detect leftover "required" prose in help text (AC5), and the file already hosts the #899 population pins.
  - Follow the existing pattern: constant `REQUIRED_FLAG = "--required"` (line 46); path constants as `Path(...)` (lines 29-37); `read_repo_text` and `collapse_whitespace` from `tests.scripts.dev_tools.parallel_orchestrator_surface_test_support` (lines 23-27); phrase detection like `required_only_phrases` (lines 145-153); Arrange/Act/Assert layout and `_posix_id` ids as at lines 156-168.
  - Add a constant `RELEASE_FLOW_SCRIPT = Path("scripts/dev-tools/Invoke-FullReleaseFlow.ps1")` and a tuple `RELEASE_FLOW_REQUIRED_PHRASES = ("required check",)`. The test reads the whole script (it has no `##` sections, so do not use `extract_section`), collapses whitespace, and asserts `REQUIRED_FLAG not in text` and that no phrase in the tuple appears (case-insensitive).
  - The module docstring (lines 1-15) names #899 and #891; add one sentence for #931. The script has no bundle mirror, so no `_with_mirror` pairing is needed.
  - The phrase `required check` must not remain anywhere in the script, including the `SuppressMessageAttribute` justification at line 200; reword it (the function name is bound by the issue #310 plan contract and must not change).

## 7. Question 6: PowerShell verification mechanics (Option A)

- Test discovery: `config/poshqc-scan.json:4` lists `scanFolders: ["scripts", "tests/powershell", "tests/scripts"]`, which contains `tests/scripts/dev-tools/`.
- Coverage population: `config/poshqc-coverage.json:3-9` lists roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. Per `scripts/powershell/PoshQC/README.md:70-75`, the `config` source applies (`.ps1`/`.psm1` only, `*.Tests.ps1` and `tests/` excluded). `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is under `scripts`, so it is in the denominator.
- Per-file coverage source: CI job `PowerShell QC` (`.github/workflows/_poshqc.yml:8-52`, `windows-latest`, called from `ci.yml:23-24`) runs `Invoke-PoshQCTest`, then uploads artifact `poshqc-test-results` containing `artifacts/pester/powershell-coverage.xml` (CoverageGutters), `powershell-coverage.koverage.xml`, and `pester-junit.xml` (lines 44-52). Read the baseline from the latest `CI` push run on `main` (`ci.yml:4-5`) and the end-state from the PR `CI` run, for example with `gh run list --workflow CI` and `gh run download <run-id> -n poshqc-test-results`, then read the `<class>` entry for `Invoke-FullReleaseFlow.ps1`.
- What a plan can assert:
  - From the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`): only the pass or fail status in the returned summary. The tools return a summary without per-file output (per the delegation brief and the operator's stored note on this behavior), so a plan must not assert a count, percentage, or per-file finding from them.
  - From CI evidence: per-file line coverage for `Invoke-FullReleaseFlow.ps1` and the JUnit test count, available only after the PR `CI` run completes. Treat the coverage no-regression criterion (issue AC6) as CI-dependent, as #899 AC-9 did, and record the baseline from the `main` run artifact before the first code edit.
  - Pester measures line coverage only; no branch gate applies to PowerShell (`.claude/rules/general-unit-test.md`). Every new branch (empty set, unknown bucket, unparsable output, non-zero completion poll) needs its own test so changed lines are covered.

## 8. Candidate approaches

- A (recommended): inline positive assertion inside `Wait-ForPullRequestChecks`. Drop `--required`; classify the parsed buckets with a small pure helper; keep the two-phase structure. Advantage: no new coupling, the existing seams and message fragments stay, the diff is small. Limitation: duplicates the bucket vocabulary that the parser also encodes.
- B (rejected): delegate classification to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. It would need a child process or dot-source seam, extra JSON fields (`workflow`), and `-RequireWorkflow CI` to avoid vacuous success on an empty set; it also throws on unknown buckets, which needs a catch layer. This couples a `scripts/dev-tools` release script to the orchestrator library and enlarges the change beyond a minor-audit fix.

## 9. Behavior semantics (decided)

- Query: `gh pr checks <PrNumber> --json bucket`, no `--required`.
- Per poll, classify the parsed set in this precedence: (1) any `fail` or `cancel` returns 1 at once; (2) any bucket outside `pass`, `skipping`, `pending`, `fail`, `cancel`, or a check with no `bucket` property, returns 1 at once with a message naming the value; (3) any `pending` continues polling; (4) an empty set continues polling; (5) otherwise (non-empty, every bucket `pass` or `skipping`) returns 0. An all-`skipping` set is green, as AC2 and the parser both allow.
- Precedence (1) before (2) deliberately removes the parser's array-order dependence.
- Rows (3) and (4) are bounded by the existing `CompletionMaxAttempts`; the timeout message stays "did not complete within the timeout".
- Phase A is unchanged (non-zero exit means not registered; "did not register within the timeout" message kept).

## 10. Related defects in the same function (fix in the same item)

- Unguarded `ConvertFrom-Json` at lines 234 and 255. Output is merged with stderr (line 98), so a `gh` warning line or a truncated payload on an exit-0 poll makes `ConvertFrom-Json` throw out of the function; the release flow then terminates with an exception instead of the documented return code 1, after the PR is already open. Not executed in this session; based on the code path. Fix: a small parse helper that returns a failure indication, and the function returns 1 with a stderr message ("could not parse check results") rather than throwing. Whether `ConvertFrom-Json ''` returns `$null` or errors differs between PowerShell 5.1 and 7; the helper should treat blank output as unparsable-or-empty and never as green.
- Unchecked completion-phase poll at lines 254-255: the re-poll result's `ExitCode` is never inspected, so a transient `gh` failure (non-JSON error text) is fed to `ConvertFrom-Json`. Fix: on a non-zero exit during Phase B, count it as a consumed completion attempt and continue; the budget bound still applies.
- Both fixes are within AC4's intent (never return 0 on an unreadable or empty result) and use only the existing seams.

Unrelated, to be listed separately and not fixed here:

- `Invoke-GitExe` and `Invoke-GhExe` declare `[OutputType([hashtable])]` (lines 76, 93) but return the `[pscustomobject]` built by `ConvertTo-CommandResult` (lines 53-66, 65). Documentation-level mismatch only.
- Phase A treats auth or network failures identically to "checks not yet registered" (a 120 s delay before reporting failure). Left as is.

## 11. Recommendations

Function semantics for `Wait-ForPullRequestChecks` (name, parameters, and defaults unchanged):

1. `$ghArgs = @('pr', 'checks', $PrNumber, '--json', 'bucket')`.
2. Add one pure helper (for example `Get-CheckSetVerdict`, input: parsed check objects, output: one of `pass`, `fail`, `unknown`, `pending`, `empty`) implementing the precedence in section 9, so the classification is unit-testable without `gh`. Add one small helper for parsing that returns the check array or a failure indication.
3. Phase B loop: on `fail` return 1 with "A check failed for PR #<n>."; on `unknown` return 1 with a message naming the unrecognized bucket; on `pass` return 0; on `pending` or `empty` sleep and re-poll within `CompletionMaxAttempts`; on a non-zero poll exit or unparsable output during Phase B, consume an attempt and continue; on parse failure at first read return 1.
4. Update the comment-based help (lines 163-199), the header (lines 15-16), and the `SuppressMessageAttribute` justification (line 200, keeping the function name and the #310 reference) to describe all checks on the pull request head; stderr wording drops "required".
5. Tests (all in Pester, no temporary files, no real waits):
   - In place edits in `Invoke-FullReleaseFlow.Tests.ps1`: lines 71, 170, 304, 335 to `pr checks 291 --json bucket`; line 313 to match "A check failed for PR #291". Optionally tighten line 170 as the exact argument-list assertion required by AC6.
   - In `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: update line 110; add tests for the argument list (capture `$GhArgs`, assert no `--required`), a failing check (non-required by construction, since the flag is absent), an empty set at exit 0 (keeps polling and times out with return 1; never 0), an unknown bucket (return 1, message names it), an unknown bucket alongside a `fail` (failure wins), an all-`pass`-or-`skipping` set (return 0), a malformed-JSON poll (return 1, no throw), and a non-zero completion poll followed by success.
6. Add the Python pin from section 6 to `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`.
7. Verification order: PoshQC format, analyze, test via MCP (status only); `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`; coverage baseline from the `main` `CI` artifact before editing and end-state from the PR `CI` artifact.

## Automation Feasibility

No human interaction is required for the code, test, and documentation change. The only external dependency is the PR `CI` run, which executes automatically on push and supplies the per-file coverage artifact (`poshqc-test-results`) used for the CI-dependent coverage criterion. The release flow itself (opening, merging, tagging a real release) is not exercised and must not be run as verification; all `gh` and `git` interaction is mocked in Pester.

## Files In Scope

Edit:

- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (in-place string and wording edits only; 74 lines of headroom under the 500-line limit)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (new tests)
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (one release-flow pin)

Create (optional, only if the ChecksWait suite would otherwise approach the 500-line limit):

- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`

No edit needed: `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, `.vscode/tasks.json`, `config/poshqc-scan.json`, `config/poshqc-coverage.json`, `.github/workflows/**`.

Delete: none.
