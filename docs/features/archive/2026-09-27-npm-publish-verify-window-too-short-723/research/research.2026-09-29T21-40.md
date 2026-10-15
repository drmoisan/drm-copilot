# Research: npm publish verify window too short (Issue #723)

- Date: 2026-09-29
- Scope: `.github/workflows/publish-mcp-npm.yml` step "Verify the published version resolves on the registry"
- Requirements source: `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md`

All citations were verified against the current tree on 2026-09-29.

## 1. Current state

### 1.1 Current poll step (`.github/workflows/publish-mcp-npm.yml:97-128`)

- Comment block at lines 97-100 explains the ref guard (issue #526).
- Line 101: `- name: Verify the published version resolves on the registry`
- Line 102: `if: startsWith(github.ref, 'refs/tags/mcp-server-v')`
- Line 103: `shell: pwsh`
- Lines 105-108: `$version` from `steps.resolve-publish-version.outputs.publishVersion`; `$packageOperand = "@danmoisan/drm-copilot-mcp@$version"`; `$maxAttempts = 18`; `$intervalSeconds = 10`.
- Line 110: `for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {`
- Line 111: `$observed = (npm view $packageOperand version 2>$null | Select-Object -First 1)`
- Line 115: `$LASTEXITCODE = 0` (comment at lines 112-114 cites `.claude/rules/ci-workflows.md`).
- Lines 116-120: on `$observed -eq $version`, set `$resolved`, print `Resolved ... on attempt $attempt.`, `break`.
- Line 121: `Write-Host "Attempt $attempt of ${maxAttempts}: $packageOperand not resolvable yet."`
- Line 122: `Start-Sleep -Seconds $intervalSeconds` (runs after every failed attempt, including the last).
- Lines 124-127: on not resolved, line 125 `Write-Host "::error::$packageOperand did not resolve within $maxAttempts attempts; the tag push did not publish."` then `exit 1`.
- Line 128: `exit 0`.

Budget: 18 attempts x 10 s = 180 s of sleep (3 min). The issue records `1.1.12` visible about 248 s after the publish step ended (02:59:32Z to 03:03:40Z), so the window was exceeded. The error text at line 125 asserts "the tag push did not publish", which is false when the publish step has already passed (the poll step only runs after the publish step; job steps are sequential and a failed publish step would skip it).

### 1.2 Tests touching the poll step: `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`

Step-block extraction (BeforeAll, lines 15-66):
- Line 16-17: reads the workflow as text lines (`$script:workflowLines`); no YAML parser, no temp files.
- Line 42: `$stepPattern = '^\s{6}-\s+name:\s*(?<StepName>.+?)\s*$'` - a step starts at exactly six spaces + `- name:`.
- Lines 44-59: builds `$script:stepBlocks`, a list of `[pscustomobject]@{ Name; Index; Text }`; `Text` is the block lines joined by `` `n `` up to the line before the next step start.
- Line 62: `$script:refGuardPattern = "if:\s*startsWith\(github\.ref,\s*'refs/tags/mcp-server-v'\)"`
- Line 63: `$script:publishStep` = first block whose text matches `npm publish`.
- Line 65: `$script:pollStep` = first block whose text matches `npm view`.

To add assertions, use `$script:pollStep.Text` with `Should -Match`. Two caveats for the planner: `$pollStep` is selected by the token `npm view`, so any new comment or text elsewhere in an earlier step containing `npm view` would change selection; and `Should -Match` is regex, so `$` and `{` in expected tokens must be escaped.

Assertions on the poll step:
- Lines 113-126, test "polls the exact published version after publishing and fails the job on budget expiry":
  - line 119: `$script:pollStep.Index | Should -BeGreaterThan $script:publishStep.Index` (ordering)
  - line 120: `$script:pollStep.Text | Should -Match '@danmoisan/drm-copilot-mcp@\$version'` (exact-version operand)
  - line 124: `$script:pollStep.Text | Should -Match 'maxAttempts'`
  - line 125: `$script:pollStep.Text | Should -Match '(?m)^\s*exit 1\s*$'`
  - Comment lines 114-115 cite the 1.0.25 failure: a bare-package operand resolves the `latest` dist-tag and would have passed.
- Lines 128-135, "ref-guards the post-publish registry poll step": line 134 `$script:pollStep.Text | Should -Match $script:refGuardPattern`.
- Lines 137-149, "resets or explicitly exits after every deliberately-failing nested command in an added pwsh step": iterates all `shell: pwsh` steps; line 145 `$step.Text -match '\$LASTEXITCODE\s*=\s*0'`; line 146 requires both `(?m)^\s*exit 0\s*$` and `(?m)^\s*exit 1\s*$`; passes if either the reset or the explicit exits are present (line 147).

No existing assertion mentions the wording "did not resolve", "did not publish", `18`, `intervalSeconds`, or `Start-Sleep`. The recommended design therefore keeps all existing tests green without modification. The identifier `maxAttempts` must remain in the step (line 124).

## 2. Other consumers of the step's wording or budget

Grep for `did not resolve|did not publish|maxAttempts|18 attempts|Verify the published version|not yet resolvable` across the tree (excluding `docs/features`) matched the poll step itself, its test (line 124), and unrelated files. Findings per consumer:

| Consumer | Change needed | Reason |
|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | No | Its check (c) polls the registry independently: `NpmIntervalSeconds` 15 s x `NpmMaxAttempts = 40` (about a 10-minute budget, documented at lines 330-334, defaults at line 358). The "10 seconds by 18 attempts" text at line 316 describes check (a) (workflow-run lookup), not the workflow step. It matches the workflow step's number only by coincidence. It does not read the step name or message; job/step names it looks for concern the publish step (line 200 comment). |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | No | `UNRESOLVED` text (line 81) is about the verifier's own budget and already says "most likely registry propagation delay ... do NOT retry the publish". |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | No | Only references `WorkflowFileName = 'publish-mcp-npm.yml'` (line 212). |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | No | Line 319 comment about "10 seconds by 18 attempts" concerns the verifier's historical shared budget defect, not the workflow step. |
| `.github/workflows/verify-published-releases.yml` | No | Matches only its own name and path filter; does not consume the poll step. |
| `.github/workflows/publish-extension.yml` | No | No verify step; see section 3. |
| `docs/engineering/missed-npm-publish.runbook.md` | Optional (yes if the issue's runbook item is in scope) | Its `UNRESOLVED` section (lines 115-126) describes the verifier, not the workflow step, and is accurate. The issue's "Manual verification notes" asks that the runbook state that a red verify step after a green publish step is not a failed release and that the paired extension tag still needs pushing; no such statement exists today. |
| `docs/engineering/npm-token-rotation.runbook.md` | No | Marked superseded (line 3). |

## 3. Out-of-scope context

- `publish-extension.yml`: no verify or poll step. Grep for `npm view|Start-Sleep|attempts` found nothing. Its steps are `vsce package` (line 60) and `vsce publish` (line 65). There is no analogous window. Out of scope for #723 regardless.
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (issue #739 context): it reads publish-mcp-npm.yml indirectly. Line 218 asserts that `.github/workflows/publish-mcp-npm.yml` is enumerated under `.github/`; lines 224-263 scan every YAML file for `NPM_TOKEN` and `NODE_AUTH_TOKEN` references (`path.read_text`, lines 233 and 254). A rewritten verify step is unaffected provided it does not introduce either token string; do not reference `NODE_AUTH_TOKEN` or `NPM_TOKEN` in new comments or messages. No scope from #739 is proposed.

## 4. Constraints from `.claude/rules/ci-workflows.md`

- Lines 13-15: "A workflow step whose `run:` block intentionally invokes a command expected to fail ... MUST not allow the residual non-zero exit code to propagate to GitHub Actions."
- Lines 17-25: the `run:` block MUST either reset (`$LASTEXITCODE = 0` after the expected failure) or "terminate the success path with an explicit zero exit".
- Line 27: "A `pwsh` step terminates with the exit code of the last external command unless the script explicitly resets it or calls `exit`."
- Line 37: `modified-workflow-needs-green-run` "requires a green workflow run against the branch head before a workflow change can merge".

Implications:
- The `npm view` query is expected to fail before propagation, so keep `$LASTEXITCODE = 0` immediately after it (line 115) and the explicit `exit 0`/`exit 1`.
- Modified-workflow rule: the workflow declares a `pull_request` trigger scoped to this file and `packages/mcp-server/**` (lines 12-15) precisely so a green branch-head run exists (issue #526). On a pull_request run the poll step is skipped by its ref guard (line 102), so the green run exercises build and packaging but not the poll loop. The loop itself is validated only by the Pester text assertions and by the next real `mcp-server-v*` release. Keep the ref guard on the step (test line 134).

## 5. Recommended design

### 5.1 Candidate approaches

A. Widen the bounded loop with capped linear backoff (recommended). Minimal diff, keeps the exact-version resolution as the failure signal, keeps all existing test assertions valid, keeps deterministic structure (fixed attempt count, computed sleep).

B. Issue's alternative: make resolution a warning-level check (never fail). Rejected as the primary design; see 5.4.

C. Exponential backoff (doubling). Rejected: a cap is still needed, and it produces the same total window with less readable arithmetic; capped linear growth matches the issue's "10 s growing to 60 s".

### 5.2 Recommended parameters and schedule

- `$maxAttempts = 14`
- Sleep after failed attempt `k` (only when `k < $maxAttempts`): `min(10 * k, 60)` seconds. Expressed as `$initialIntervalSeconds = 10`, `$maxIntervalSeconds = 60`, `$sleepSeconds = [Math]::Min($initialIntervalSeconds * $attempt, $maxIntervalSeconds)`.

Arithmetic:
- Sleeps 1-6: 10, 20, 30, 40, 50, 60 = 210 s.
- Sleeps 7-13: 7 sleeps x 60 s = 420 s.
- Attempt 14 is the last; no sleep follows it (13 sleeps total).
- Total sleep = 210 + 420 = 630 s = 10.5 min, which is at least the required 10 min. Each `npm view` call adds its own latency (unbounded here, typically about a second), so wall time is somewhat above 630 s.

Probe times (seconds after step start, excluding `npm view` latency): attempt 1 at 0, then cumulative 10, 30, 60, 100, 150, 210, 270, 330, 390, 450, 510, 570, 630 for attempts 2-14.

Check against the observed failure: `1.1.12` became visible about 248 s after the step began (02:59:32Z to 03:03:40Z). Attempt 7 (t = 210 s) would miss and attempt 8 (t = 270 s) would resolve, using less than half of the new window. The old window (last probe at 170 s; 17 sleeps of 10 s plus the 18th probe) could not reach it.

Note: keeping a sleep after the final attempt (as the current code does) would add a pointless 60 s wait; guarding on `$attempt -lt $maxAttempts` avoids that and makes the sleep count exactly `$maxAttempts - 1`.

### 5.3 Timeout message

Replace line 125 with a message stating: the exact version was not yet resolvable after the computed window (about 10 minutes, derive from the sleeps or state "N minutes" as a literal matching the schedule), the "Publish to npm" step succeeded before this check ran, and the operator must check the registry (`npm view @danmoisan/drm-copilot-mcp@<version>`) before re-running because re-publishing an existing version fails. Keep it a single `::error::` line followed by `exit 1`. Avoid the strings `NPM_TOKEN` and `NODE_AUTH_TOKEN` (section 3).

Keep in place: ref guard (line 102), `shell: pwsh`, exact-version operand, `$LASTEXITCODE = 0` reset, `break` on success, `exit 1` / `exit 0` on their own lines (tests use line-anchored regexes).

### 5.4 Warning-level resolution check: recommendation

Do not adopt as the primary behavior. Reasons:
- The exact-version check exists because the 1.0.25 failure (test comment lines 114-115) showed that a version can appear to publish without being resolvable; a check that cannot fail would silently pass in that case. The test at line 125 also requires `exit 1` after budget expiry.
- A job that stays green when the version never appears removes the only in-workflow detection of a missing publish. The out-of-band verifier (`Invoke-ReleaseVerification.ps1`) and the scheduled `verify-published-releases.yml` exist but are separate detection paths, not replacements.
- The actual defect is the too-short window plus a misleading message; both are fixed by approach A. With a corrected message, a red step after a green publish is diagnosable without changing the failure semantics.
- Possible future refinement (out of scope): use the publish step's own success as the primary signal. In the current job the poll step already runs only after that step succeeded, so the message can state this as fact.

### 5.5 Documentation

The issue also asks to record that a red verify step after a green publish step is not a failed release and that the paired extension tag still needs pushing. Recommended location: a short note in `docs/engineering/missed-npm-publish.runbook.md` near the `UNRESOLVED` section. Whether to include this is a planner decision; it does not affect code or tests. The issue's "update memory" item is not a repository artifact.

## 6. Local validation surface

- Pester: `.claude/rules/powershell.md` line 18 states tests are run via the MCP tool `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The test file header (lines 5-8) notes the runsettings roots are `scripts`, `tests/powershell`, `tests/scripts`; the test path `tests/scripts/workflows/` is discovered. A direct `Invoke-Pester` invocation against that file is the fallback; known issue: the MCP runner reads installed-extension settings (per user memory index, unverified in this pass).
- CI: `.github/workflows/_poshqc.yml` uploads Pester artifacts (lines 49-51), so the suite runs in CI through that reusable workflow.
- actionlint: `.github/instructions/github-actions.instructions.md` lines 12-15 state all workflows must pass `actionlint`, locally via `scripts/dev-tools/run-actionlint.ps1` (file exists), and in CI via "job `actionlint` in `.github/workflows/ci.yml`". A grep for `actionlint` across `.github/workflows/` returned no matches, so the CI job named in the instruction file does not exist in the current tree. Only the local script applies. No yamllint configuration was found. This discrepancy is a finding, not proposed scope.
- No local stage executes the workflow `run:` block (`.claude/rules/ci-workflows.md` line 32); the PowerShell loop logic can be exercised by hand in a scratch pwsh session with `npm view` stubbed, but no such test exists in the repo.

## 7. Candidate acceptance criteria

- [ ] The poll step's total sleep budget is at least 600 s: with `$maxAttempts = 14`, `min(10*k, 60)` sleeps for `k = 1..13` sum to 630 s. Verify by a Pester test asserting `$script:pollStep.Text` matches `\$maxAttempts\s*=\s*14` and the sleep expression `\[Math\]::Min\(` with a `60` cap, or by a computed-schedule assertion in the same test.
- [ ] The step's sleep interval grows (backoff) and is capped at 60 s. Pester: `$script:pollStep.Text | Should -Match 'Start-Sleep\s+-Seconds\s+\$sleepSeconds'` and a match for the `60` cap token.
- [ ] No sleep follows the final attempt. Pester: `$script:pollStep.Text | Should -Match '\$attempt\s+-lt\s+\$maxAttempts'`.
- [ ] The timeout message no longer contains the text `the tag push did not publish`. Pester: `$script:pollStep.Text | Should -Not -Match 'tag push did not publish'`.
- [ ] The timeout message states that the publish step succeeded and directs the operator to check the registry before re-running because re-publishing an existing version fails. Pester: match tokens such as `publish step succeeded` and `re-publishing`.
- [ ] The exact-version operand `@danmoisan/drm-copilot-mcp@$version` is retained (existing test at line 120 continues to pass).
- [ ] `$LASTEXITCODE = 0` remains inside the loop after `npm view`. Pester: `$script:pollStep.Text | Should -Match '\$LASTEXITCODE\s*=\s*0'` (also enforced generically by the test at lines 137-149).
- [ ] The step retains explicit `exit 1` on timeout and `exit 0` on success (existing tests at lines 125 and 146).
- [ ] The ref guard `if: startsWith(github.ref, 'refs/tags/mcp-server-v')` remains on the poll step (existing test at line 134).
- [ ] No `NPM_TOKEN` or `NODE_AUTH_TOKEN` string is introduced: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` passes.
- [ ] `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/publish-mcp-npm.yml`.
- [ ] A green pull_request run of `publish-mcp-npm.yml` exists at the branch head (modified-workflow-needs-green-run).
- [ ] (Optional, planner decision) `docs/engineering/missed-npm-publish.runbook.md` states that a red verify step after a green publish step is not a failed release and that the paired extension tag still needs pushing.

## Numeric Derivation Evidence

The proposed numeric parameters are design choices, not counts derived from a repository population, so no repository-population numeric assertion for an approved `spec.md` is proposed here. The schedule arithmetic in section 5.2 is self-contained (sleeps 10+20+30+40+50+60 = 210; 7 x 60 = 420; 210 + 420 = 630 s). If the planner promotes the 630 s figure into a `spec.md` criterion, it is a computed value from the chosen parameters and should be re-derived from the final step text.
