# npm-publish-verify-window-too-short (Plan)

- **Issue:** #723
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T21-31
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit
- **Complexity Band:** C2

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Requirements Source

The sole acceptance-criteria source is the `## Acceptance Criteria` section (AC-1 through AC-6) of the feature issue document. No spec or user-story document exists for this minor-audit item, and none may be created.

## Scope and Boundaries

- Widen the registry verify poll in the publish-mcp-npm workflow to a bounded backoff schedule of 14 attempts with sleep after failed attempt k of min(10 x k, 60) seconds, skipped after the final attempt (13 sleeps, 630 seconds total).
- Reword the timeout error message, add Pester assertions, and add one runbook section.
- Out of scope, and not to be edited: the publish-extension workflow, the verify-published-releases workflow, the Invoke-Release scripts under the dev-tools scripts folder, and any issue #739 npm-token-guard scope.
- The new workflow text, comments, and messages must not contain the two secret-name strings that the npm-token-guard test scans for (the strings are named in AC-6). The new comments must also not repeat the old timeout wording that AC-3 removes.

## Coverage Contract

No PowerShell or Python production source file changes in this plan. The written files are a workflow YAML file, a Markdown runbook, and a Pester test file (test code). None of these is a coverage-measured production source file, so no coverage percentage is asserted and no coverage-comparison task applies. P2-T8 mechanically verifies that no production source file under the scripts, extensions, or packages trees changes. The Pester summary line and the pytest summary token are the only numeric signals asserted.

## Evidence Layout

All evidence lives under `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/` in the canonical kinds `baseline`, `regression-testing`, and `qa-gates`. Each command-step artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Design Reference (exact literals the executor writes)

Poll-step variable block, replacing the former attempt-count and interval assignments:

```
$maxAttempts = 14
$initialIntervalSeconds = 10
$maxIntervalSeconds = 60
```

Sleep block, replacing the former unconditional sleep after every failed attempt:

```
if ($attempt -lt $maxAttempts) {
  $sleepSeconds = [Math]::Min($initialIntervalSeconds * $attempt, $maxIntervalSeconds)
  Start-Sleep -Seconds $sleepSeconds
}
```

Timeout message, a single physical line replacing the former error line:

```
Write-Host "::error::$packageOperand was not yet resolvable on the registry after $maxAttempts attempts over about 10 minutes. The publish step succeeded before this check ran, so the version is probably published. Check the registry with 'npm view $packageOperand version' before re-running, because re-publishing an existing version fails."
```

Tokens the tests assert on the error line: "not yet resolvable", "publish step succeeded", "Check the registry", and "re-publishing an existing version fails". The old wording asserted absent is "tag push did not publish".

Schedule arithmetic: sleeps after attempts 1 through 6 are 10, 20, 30, 40, 50, 60 (210 s); attempts 7 through 13 sleep 60 s each (420 s); no sleep follows attempt 14; total 630 s, which is at least 600 s.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the order defined by the policy-compliance-order skill: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`.
  - Acceptance: each of the four files was opened in this session; the file list is recorded by P0-T3.
- [x] [P0-T2] Read the domain policy files: `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, `.github/instructions/github-actions.instructions.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: each of the four files was opened in this session; the file list is recorded by P0-T3.
- [x] [P0-T3] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/phase0-instructions-read.md` listing every file read in P0-T1 and P0-T2, in the order read.
  - Acceptance: the artifact contains a `Timestamp:` line, a `Policy Order:` line, and one list entry for each of the eight files read in P0-T1 and P0-T2.
- [x] [P0-T4] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/baseline-branch-state.md` recording the output of `git status --porcelain --branch`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` that quotes the first output line beginning with two hash characters (the branch line).
- [x] [P0-T5] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/baseline-feature-folder-shape.md` recording the output of `git ls-files --cached --others -- docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/spec.md docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/user-story.md`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating the command printed nothing, which proves neither minor-audit-forbidden document exists. Any printed path fails the task.
- [ ] [P0-T6] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/baseline-pester-publish-mcp-npm-workflow.md` recording the output of `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"` run before any edit.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that quotes the Pester summary line and the printed `Failed: 0` token. The tree contains six existing `It` blocks, so the recorded passed count is expected to be 6; record the printed value as observed.
- [x] [P0-T7] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/baseline-actionlint-publish-mcp-npm.md` recording the result of `actionlint .github/workflows/publish-mcp-npm.yml`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating the output was empty (actionlint prints nothing on success).
- [x] [P0-T8] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/baseline/baseline-token-guard-pytest.md` recording the output of `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` that quotes the pytest summary line containing the token `passed` and no `failed`.

### Phase 1 — Implementation (small-path, constrained)

Ordering note: P1-T2 adds assertions that fail against the current workflow. No gate runs the Pester file as a must-pass between P1-T2 and P1-T5. The only run in that interval is P1-T3, which expects failures.

- [x] [P1-T1] Delegate P1-T2 through P1-T7 to the small-path implementation engineer with the Design Reference section of this plan as the exact-literal source.
  - Acceptance: the implementation engineer receives the handoff and edits only the three files named in P1-T2, P1-T4 (and P1-T5), and P1-T7. Any other product-file edit fails the handoff.
- [x] [P1-T2] Add `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` four new `It` blocks inside the existing `Describe`, after the last existing `It`, each asserting against the poll-step text held in the existing poll-step variable [expect-fail]. Use these exact test names:
  - "polls with a bounded backoff schedule whose cumulative sleep budget is at least 600 seconds": match the `$maxAttempts` assignment to 14, match the initial-interval assignment to 10 and the cap assignment to 60, match the `[Math]::Min(` backoff expression over the initial interval, the attempt counter, and the cap, then extract the three values from the step text, compute the sum of min(initial x k, cap) for k from 1 to maxAttempts minus 1, and assert the sum is greater than or equal to 600.
  - "caps the poll interval at 60 seconds and skips the sleep after the final attempt": assert the cap assignment equals 60, assert the step text matches the sleep statement using the computed sleep variable, assert exactly one Start-Sleep statement exists, assert the final-attempt guard (`\$attempt\s+-lt\s+\$maxAttempts`) is present, and assert the guard's position precedes the Start-Sleep statement's position.
  - "reports a timeout message that does not claim the tag push failed to publish": select the single step line containing `::error::`, assert the count of such lines is 1, assert that line does not match the old wording "tag push did not publish", and assert the line matches each of the four tokens listed in the Design Reference section.
  - "keeps the exit-code reset, explicit exits, and exact-version operand in the poll step": assert the poll-step text matches `\$LASTEXITCODE\s*=\s*0`, matches the exact-version operand `@danmoisan/drm-copilot-mcp@\$version`, matches line-anchored `exit 0` and `exit 1`, and matches the existing ref-guard pattern variable. This test passes against the current workflow.
  - Escape regex metacharacters (`$`, `{`, `[`, `(`) in every expected token; keep the file under 500 lines; add a comment citing issue #723 above the new blocks.
  - Acceptance: P1-T3 shows the first three new tests failing and the fourth passing.
- [ ] [P1-T3] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/regression-testing/expect-fail-new-pester-assertions.md` recording the output of `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"` run after P1-T2 and before P1-T4 [expect-fail].
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that quotes the printed `Failed: 3` token and the three failing test names, each printed on a line beginning with the failure marker `[-]`. The three failing names are the first three names listed in P1-T2. The fourth name must appear on a line beginning with the pass marker `[+]`. Also record the six pre-existing tests as passing. If the observed failed count is not 3, stop and reconcile P1-T2 before continuing.
- [x] [P1-T4] Update `.github/workflows/publish-mcp-npm.yml` step "Verify the published version resolves on the registry" to apply the variable block and the sleep block from the Design Reference section.
  - Acceptance: the step contains the literal `$maxAttempts = 14`; the former interval assignment and the unconditional sleep are removed; the sleep sits inside the final-attempt guard; a short comment above the loop states the 630-second schedule and cites issue #723; the ref guard, `shell: pwsh`, exact-version operand, `$LASTEXITCODE = 0` reset, `break`, `exit 1`, and `exit 0` remain unchanged. Verified by P1-T6.
- [x] [P1-T5] Update `.github/workflows/publish-mcp-npm.yml` step "Verify the published version resolves on the registry" to replace the former timeout error line with the single-line timeout message from the Design Reference section.
  - Acceptance: the step contains exactly one line with `::error::`; that line contains the four tokens named in the Design Reference section and does not contain the old wording named in the Design Reference section; no line of the file contains either secret-name string. Verified by P1-T6 and P2-T6.
- [ ] [P1-T6] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/regression-testing/pass-after-new-pester-assertions.md` recording the output of `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"` run after P1-T5.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that quotes the printed `Failed: 0` token and shows all four new test names on lines beginning with `[+]`. This is the pass-after counterpart of P1-T3.
- [x] [P1-T7] Update `docs/engineering/missed-npm-publish.runbook.md` to add a new section headed "## Red verify step after a green publish step", placed after the UNRESOLVED section and before the VERSION_CONSUMED_ELSEWHERE section.
  - The section states three sentences, each on its own single physical line with no hard wrap, using these exact literals:
    - "A red verify step after a green Publish to npm step is not a failed release."
    - "Check the exact version on the registry instead of re-running the publish, because re-publishing an existing version fails."
    - "The paired extension tag still needs to be pushed, because the VS Code extension release is not published until that tag is pushed."
  - The section also names the workflow step by its title "Verify the published version resolves on the registry" and states that it is a workflow step, not one of the verifier state tokens. The section must not contain either secret-name string.
  - Acceptance: verified by P2-T7.

### Phase 2 — Final QC Loop

Loop rule: run P2-T1 through P2-T8 in order. If any step fails or changes a file, correct the cause and restart from P2-T1, overwriting the affected artifacts. AC check-off tasks P2-T9 through P2-T14 run only after a clean pass.

Final QC note: the green pull_request run of the publish-mcp-npm workflow at the branch head (the modified-workflow-needs-green-run rule) is verified later by the orchestrator's CI gate, not by the executor. The executor does not claim that run. The poll step is ref-guarded and skipped on a pull_request run, so the loop is validated by the Pester assertions and by the next real tag release.

- [ ] [P2-T1] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-format-pester-file.md` recording the `mcp__drm-copilot__run_poshqc_format` run for the Pester test file, with a tree observation before and after.
  - The formatter is write-mode and exits 0 whether or not it rewrote a file, so the exit code is not the acceptance signal. Record `git hash-object tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` and `git status --porcelain` before and after the formatter run.
  - Acceptance: on the passing pass, the before and after hashes are identical and the before and after status listings are identical, which shows the formatter changed nothing. If either differs, record the difference and restart the loop.
- [ ] [P2-T2] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-analyze-pester-file.md` recording the output of `pwsh -NoProfile -Command "Invoke-ScriptAnalyzer -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -EnableExit"`.
  - Acceptance: `EXIT_CODE: 0` and an empty finding list (no diagnostic rows printed). The exit code with the exit-on-findings switch equals the finding count. Record the printed output literally. Any finding fails the task.
- [ ] [P2-T3] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-pester-publish-mcp-npm-workflow.md` recording the output of `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed"`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that quotes the printed `Failed: 0` token, shows the six pre-existing test names and the four new test names on lines beginning with `[+]`, and shows no line beginning with `[-]`. This satisfies AC-4's requirement that every existing test passes.
- [ ] [P2-T4] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-actionlint-publish-mcp-npm.md` recording the result of `actionlint .github/workflows/publish-mcp-npm.yml`.
  - Acceptance: `EXIT_CODE: 0` and empty output.
- [ ] [P2-T5] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-token-guard-pytest.md` recording the output of `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`.
  - Acceptance: `EXIT_CODE: 0` and an `Output Summary:` quoting the summary line with the token `passed` and no `failed`.
- [ ] [P2-T6] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-forbidden-token-scan-workflow.md` recording the result of `git grep -n -E "NPM_TOKEN|NODE_AUTH_TOKEN" -- .github/workflows/publish-mcp-npm.yml`.
  - The expected result is no match, which `git grep` reports as exit code 1 with empty output. Record `ExpectedExitCode: 1` in the artifact; an observed `EXIT_CODE: 1` normalizes to pass. An exit code of 0 (a match) fails the task.
- [ ] [P2-T7] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-runbook-ac5-lines.md` recording the output of `pwsh -NoProfile -Command "Select-String -Path docs/engineering/missed-npm-publish.runbook.md -SimpleMatch 'is not a failed release','instead of re-running the publish','paired extension tag still needs to be pushed'"`.
  - Each token is a short single-line literal quoted here: "is not a failed release", "instead of re-running the publish", and "paired extension tag still needs to be pushed".
  - Acceptance: the output contains exactly three matched lines, one containing each token, all from the new runbook section. A missing line fails the task. The command exits 0 whether or not lines match, so the printed lines are the acceptance signal.
- [ ] [P2-T8] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-no-source-change-check.md` recording the output of `git diff --name-only origin/main...HEAD -- scripts extensions packages` together with the output of `git status --porcelain -- scripts extensions packages`.
  - The three-dot diff lists committed changes since the merge base and the porcelain status lists uncommitted and untracked changes, so together they cover every state a change can be in.
  - Acceptance: both commands print nothing, which supports the Coverage Contract statement that no production source file changed. Any printed path fails the task.
- [ ] [P2-T9] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-1, changing only the leading checkbox of the line beginning with AC-1, after P2-T3 passes.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-1:'"` prints exactly one line. The line begins with the literal "- [x] AC-1:".
- [ ] [P2-T10] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-2, changing only the leading checkbox of the line beginning with AC-2, after P2-T3 passes.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-2:'"` prints exactly one line. The line begins with the literal "- [x] AC-2:".
- [ ] [P2-T11] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-3, changing only the leading checkbox of the line beginning with AC-3, after P2-T3 passes.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-3:'"` prints exactly one line. The line begins with the literal "- [x] AC-3:".
- [ ] [P2-T12] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-4, changing only the leading checkbox of the line beginning with AC-4, after P2-T3 passes.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-4:'"` prints exactly one line. The line begins with the literal "- [x] AC-4:".
- [ ] [P2-T13] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-5, changing only the leading checkbox of the line beginning with AC-5, after P2-T7 passes.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-5:'"` prints exactly one line. The line begins with the literal "- [x] AC-5:".
- [ ] [P2-T14] Update `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md` to check off AC-6, changing only the leading checkbox of the line beginning with AC-6, after P2-T4, P2-T5, and P2-T6 pass.
  - Acceptance: `pwsh -NoProfile -Command "Select-String -Path docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md -SimpleMatch '[x] AC-6:'"` prints exactly one line. The line begins with the literal "- [x] AC-6:".
- [ ] [P2-T15] Hand off to the small-audit reviewer for the reduced post-implementation audit, supplying the baseline, regression-testing, and qa-gates evidence folders and the AC status summary.
  - Acceptance: the reviewer receives the handoff with all Phase 0, Phase 1, and Phase 2 artifacts listed in this plan present on disk; the AC status summary reports 6 of 6 items checked off.
