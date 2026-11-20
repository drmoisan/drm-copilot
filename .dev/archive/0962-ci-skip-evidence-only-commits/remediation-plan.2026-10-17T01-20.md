# 2026-10-16-ci-skip-evidence-only-commits (Remediation Plan, cycle 1, CI failure)

- **Issue:** #962
- **Owner:** drmoisan
- **Last Updated:** 2026-10-17
- **Status:** Ready for executor preflight
- **Work Mode:** full-bug (`issue.md` marker `- Work Mode: full-bug`). The acceptance-criteria source is `spec.md`, section `## Acceptance Criteria`.
- **Primary input:** `remediation-inputs.2026-10-17T01-20.md`, finding RI-1 (the only finding in scope). The carried-forward findings B-1 to B-4 of `remediation-inputs.2026-10-17T00-43.md` are not remediated here.
- **Reference plan:** `plan.2026-10-16T10-27.md` (PD-18, G2, row W18 of section 8, section 10 `### Security scan`, and the command recipes of section 5). The reference plan is not edited; where this plan states a different text for W18 or for the `### Security scan` subsection, this plan supersedes it.
- **Branch:** `bug/ci-skip-evidence-only-commits-962`. The only push is `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962` (fast-forward only). No force push, no `--amend`, no rebase, no deletion of any repository file or branch.

## 1. Terms

- `FEATURE` denotes `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`.
- `SCRATCH` resolves to `<session scratchpad>/issue-962/`. Every scratch file this plan names lives under `SCRATCH/tools/` (the launcher `run-cr.sh` and the `cr-<name>.txt` recipes) or `SCRATCH/stage/` (the staged copies the launcher makes). Artifacts record the literal token `SCRATCH`, never a host path. In Bash command text the executor substitutes the forward-slash form of the resolved path for `SCRATCH`.
- Evidence paths are `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with `<kind>` one of `remediation-baseline`, `regression-testing`, `qa-gates`, `other`. `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`), never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- `CR-<NAME>` is the command recipe of the same name in section 5 of the reference plan, run as `sh SCRATCH/tools/run-cr.sh cr-<name> <arguments>`. This plan uses CR-PROBE, CR-PESTER-LIST, CR-FORMAT, CR-PSSA, CR-HERMETIC, CR-ACTIONLINT, and CR-README.
- `W18-FILE` = `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`. `SCAN-FILE` = `.github/workflows/_security-scan.yml`. `README-FILE` = `.github/workflows/README.md`.

## 2. Rules binding on every task

1. **Reference-plan rules.** Rules 1 (evidence schema), 2 (no host data), 3 (command route), 4 (Bash command text: one command per call; no `&&`, `;`, `cd`, or heredoc; none of the tokens `pwsh`, `bash`, or `wsl` in Bash command text), 4a (no `.ps1`, `.psm1`, or `.psd1` scratch file written with Write or Edit), 5 (PoshQC MCP results carry no output), 6 (success-output observation), 7 (hook denials stop the task BLOCKED), 12 (`?? tools/` is expected and never staged), and 15 (Pester runner and CI job) of section 2 of the reference plan apply unchanged. The `bash` token inside `SCAN-FILE` and `W18-FILE` is written only with Edit, never in Bash command text.
2. **Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, followed by the command output with host paths redacted. An artifact whose expected exit code is non-zero carries `ExpectedExitCode: 1`. When one artifact records several commands, `Command:` and `EXIT_CODE:` describe the first command and each later command's exit code is recorded on its own labelled line.
3. **Scope boundary.** The repository write set of this cycle is exactly: `SCAN-FILE`, `W18-FILE`, `README-FILE`, this plan file, `FEATURE/spec.md` (already amended by the planning agent, RPD-3), and new evidence files under `FEATURE/evidence/`. No other repository file is written. Policy documents under `.claude/rules/` and `.github/instructions/` are read-only.
4. **AC-36 stays unchecked.** No task of this plan checks off AC-36 in `FEATURE/spec.md`. Per RI-1, AC-36 is checked by the item's orchestrator only after a CI run of the remediated head shows the scan step ran a non-vacuous scan (export succeeded, packages scanned) and the `security-scan / Security Scanning` job concluded `success`.
5. **Restart rule.** In Phase 2, if any stage fails or rewrites a file, fix the cause within the rule 3 write set and restart from P2-T1, writing new artifacts.

## 3. Decisions

- **RPD-1 (workflow edit).** In `SCAN-FILE`, job `security-scan`, the step `Check for security vulnerabilities` (lines 45-50 of the current tree) receives exactly one new line, `        continue-on-error: true` (eight spaces), inserted directly after line 47 `        shell: bash` and before line 48 `        run: |`. The step `Install the Poetry export plugin` (lines 41-43), the `if: ${{ inputs.run-heavy }}` lines, and `shell: bash` are unchanged. No other line of the file changes. After the edit the scan step reads, in order: `      - name: Check for security vulnerabilities`, `        if: ${{ inputs.run-heavy }}`, `        shell: bash`, `        continue-on-error: true`, `        run: |`, and the two unchanged `run` lines.
- **RPD-2 (row W18).** The `It` block at lines 308-321 of `W18-FILE` is replaced. The new test name is `runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)`. The new body keeps the existing plugin-step and step-order assertions (lines 309-319 of the current tree, with the line-315 `continue-on-error` count assertion removed), and adds two assertions after the `shell: bash` assertion: (a) the `continue-on-error` lines of the whole job, joined with ` | `, equal exactly `        continue-on-error: true` (so the job holds exactly one such line, with the value `true`); (b) the scan step's lines contain the exact line `        continue-on-error: true` (so that one line is on the scan step). The exact replacement text is in section 4. The row keeps the `(AC-36)` tag, so the reference plan's `NAMED: *(AC-36)*` count stays `Total=1` and the suite stays at 39 expanded rows.
- **RPD-3 (spec amendment, made by the planning agent before execution).** `FEATURE/spec.md` changed in three places only: (1) AC-36 text: the title became `Security scan runs with a working export`; the clause `the security-scan job carries no continue-on-error` became `that step carries continue-on-error: true, which is the only continue-on-error line in the security-scan job`; the findings sentence now records that the first full PR run reported 101 pre-existing findings, that this remediation cycle restored `continue-on-error: true` on the scan step only, and states the check-off condition of rule 4; AC-36 remains `- [ ]`. (2) The D14 In-scope bullet: `a blocking _security-scan.yml scan step` became `a _security-scan.yml scan step ... (D14-b; non-blocking while the pre-existing safety findings remain)`. (3) Out of Scope item 3 gained one closing sentence recording the 101 findings and the non-blocking step. No other criterion text changed. Search performed for this decision: `spec.md` lines naming `AC-36`, `D14-b`, or `continue-on-error` (lines 60, 114, 378, 452, 564 before the amendment); lines 114 and 378 concern the `scope` decision step of `ci.yml` and are unchanged.
- **RPD-4 (README and CR-README).** Line 141 of `README-FILE` (the single body line of `### Security scan`, line 139) is replaced by exactly one line (section 4). CR-README (reference plan section 5) compares the head README against the merge-base README for the base-prefix lines only (lines 1-98 region) and checks a token list against the appended `## Change-Scope Decision (Issue #962)` text; no recipe literal or token is the old line-141 text or the words `has no continue-on-error`, and the token `continue-on-error: true` is already satisfied by line 115 and also by the new line. CR-README therefore needs no change; P2-T6 re-runs it to confirm. The reference plan's section 10 text for this subsection (its line 1473) is superseded by section 4 of this plan and is not edited.
- **RPD-5 (coverage).** No production source file in a coverage-measured language changes in this cycle: `SCAN-FILE` is workflow YAML, `README-FILE` is Markdown, and `W18-FILE` is a test file, which the coverage policy excludes from measurement. No coverage threshold therefore applies to the delta, and no coverage-delta task is planned. The PowerShell coverage figures of record remain those of `FEATURE/evidence/qa-gates/final-coverage-files.*.md` from the reference plan's Phase 6. The P2-T5 MCP test run executes with the PoshQC coverage settings but, per rule 1 (reference rule 5), no number is read from it.
- **RPD-6 (evidence after the push).** P2-T9 writes its commit artifact after the push and sets its own checkbox afterwards; both remain uncommitted and are committed by the item's orchestrator in its next evidence commit. No second push is made by this plan, so the CI run that the orchestrator reads for AC-36 is the run of the P2-T9 head.

## 4. Exact replacement texts

### W18 replacement (RPD-2)

Lines 308-321 of `W18-FILE` (from the line beginning `        It 'runs the security scan under bash after installing` through its closing `        }`) become exactly the following 16 lines (eight-space indentation for `It` and the closing brace, twelve spaces for the body; the blank line is empty):

```powershell
        It 'runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)' {
            $job = Get-TestJobLine -FileName '_security-scan.yml' -JobId 'security-scan'
            $job | Should -Not -BeNullOrEmpty
            $steps = Get-TestStepBlock -JobLines $job
            $names = @($steps | ForEach-Object { Get-TestStepName -Step $_ })
            $pluginIndex = [Array]::IndexOf($names, 'Install the Poetry export plugin')

            $pluginIndex | Should -BeGreaterOrEqual 0
            ([string[]]@($steps[$pluginIndex])) -ccontains '        run: poetry self add poetry-plugin-export' | Should -BeTrue
            $pluginIndex + 1 | Should -BeLessThan $steps.Count
            $names[$pluginIndex + 1] | Should -BeExactly 'Check for security vulnerabilities'
            $scanStep = [string[]]@($steps[$pluginIndex + 1])
            $scanStep -ccontains '        shell: bash' | Should -BeTrue -Because 'bash runs with pipefail, so a failed export is reported in the scan step'
            (@($job | Where-Object { $_ -match '^\s*continue-on-error:' }) -join ' | ') | Should -BeExactly '        continue-on-error: true' -Because 'only the scan step is non-blocking while the pre-existing safety findings remain (issue #962 PD-18)'
            $scanStep -ccontains '        continue-on-error: true' | Should -BeTrue -Because 'continue-on-error belongs to the scan step and to no other step'
        }
```

Lines 322-323 of the current tree (`    }` closing the `security scan` Context and `}` closing the Describe) are unchanged and become lines 324-325. The file grows from 323 to 325 lines (as counted by CR-HERMETIC).

### README replacement (RPD-4)

Line 141 of `README-FILE` becomes exactly this one line (no line break inside it):

```markdown
On a full run, `security-scan / Security Scanning` installs the Poetry export plugin, exports the locked dependencies, and runs `safety check` under `bash` with `pipefail`, so the scan reads every locked package. The scan step carries `continue-on-error: true` and does not fail the required check: the first full run of issue #962 reported 101 pre-existing findings in 14 packages of `poetry.lock` (listed in the issue #962 feature folder, `evidence/other/security-scan-findings.2026-10-17T01-18.md`), and the step stays non-blocking until those dependencies are upgraded. Findings and export errors remain visible in the step log.
```

Lines 1-140 (including `### Security scan` at line 139 and the blank line 140) are unchanged; line 141 remains the last line of the file.

## 5. Requirements trace

| ID | Requirement | Implementation | Tests | Evidence |
|---|---|---|---|---|
| RI-1a | `continue-on-error: true` on the scan step only; plugin step, `shell: bash`, run-heavy gating kept | P1-T3 (RPD-1) | W18 (new), W9/W10/W14 rows for `_security-scan.yml` | P1-T4, P2-T3, P2-T4 |
| RI-1b | W18 asserts exactly `continue-on-error: true` with `shell: bash` and the plugin step before it; fail-before then pass | P1-T1 (RPD-2) | W18 (new) | P1-T2 (expect-fail), P1-T4, P2-T4 |
| RI-1c | README `### Security scan` describes the non-blocking scan with a working export and the 101 findings | P1-T5 (RPD-4) | CR-README, README token checks | P1-T6, P2-T6 |
| RI-1d | QC: format, analyzer, Pester for `tests/scripts/workflows`, actionlint, MCP PoshQC test | Phase 2 | CR-FORMAT, CR-PSSA, CR-HERMETIC, CR-PESTER-LIST, CR-ACTIONLINT, `run_poshqc_test` | P2-T1 to P2-T7 |
| RI-1e | Commit and push (no force push) | P2-T9 | porcelain and ref equality | P2-T9 |
| AC-36 | Amended criterion (RPD-3); stays unchecked in this cycle | P1-T1, P1-T3 | W18 (new) | P1-T4, P2-T4; CI check-off by the orchestrator (rule 4) |

## 6. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in this order and write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/powershell.md`; `.claude/rules/ci-workflows.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/rules/tonality.md`; `.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`; `.github/instructions/general-unit-test.instructions.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.github/instructions/github-actions.instructions.md`; `.claude/skills/acceptance-criteria-tracking/SKILL.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Done when the artifact lists all 15 files in that order. No policy file is edited.
- [x] [P0-T2] Record the branch state in `FEATURE/evidence/remediation-baseline/branch-state.<timestamp>.md` by running `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git rev-parse origin/bug/ci-skip-evidence-only-commits-962`, and `git status --porcelain`.
  - Done when the branch is `bug/ci-skip-evidence-only-commits-962`, `HEAD` equals the remote branch ref, and every porcelain entry is one of: ` M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` (RPD-3), `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-inputs.2026-10-17T01-20.md`, `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-plan.2026-10-17T01-20.md`, `?? tools/`, or an untracked path under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` (this includes the two RI-1 evidence files and the P0-T1 artifact). Any other entry stops the task BLOCKED with the porcelain output recorded.
- [x] [P0-T3] Confirm the command route: for each of `SCRATCH/tools/run-cr.sh`, `cr-probe.txt`, `cr-pester-list.txt`, `cr-format.txt`, `cr-pssa.txt`, `cr-hermetic.txt`, `cr-actionlint.txt`, and `cr-readme.txt` under `SCRATCH/tools/`, read the file with Read; any file that is absent or differs from section 5 of the reference plan is written verbatim from that section with Write (LF line endings for `run-cr.sh`; rule 4a). Then run `sh SCRATCH/tools/run-cr.sh cr-probe` and write `FEATURE/evidence/remediation-baseline/cr-route-probe.<timestamp>.md` with the list of files read or rewritten, the probe output, and the line `CR-ROUTE: sh-launcher` or `CR-ROUTE: BLOCKED`.
  - Done when the probe output contains `RUN-CR: cr-probe`, a line beginning `PROBE-PESTER: 5.`, `PROBE-CWD-IS-REPO-ROOT: True`, and `EXIT_CODE_COMPUTED: 0`, and the artifact records `CR-ROUTE: sh-launcher`. A refusal or a non-zero exit records `CR-ROUTE: BLOCKED` and stops execution.
- [x] [P0-T4] Capture the baseline Pester state of the workflow suites: run `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"` and write `FEATURE/evidence/remediation-baseline/baseline-pester-workflows.<timestamp>.md`.
  - Done when the output shows one `CONTAINER:` line with `Result=Passed` for each of the five files `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, `CiWorkflow.Tests.ps1`, `PoshQcWorkflow.Tests.ps1`, `PublishMcpNpmWorkflow.Tests.ps1`, and `VerifyPublishedReleasesWorkflow.Tests.ps1`, the line `SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0`, the line `NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1`, a `TOTAL:` line with `Failed=0`, and `EXIT_CODE_COMPUTED: 0`. The `Output Summary:` records the `TOTAL:` line verbatim; its `Passed=` value is `BASELINE-TOTAL-PASSED`, recorded on its own line as `BASELINE-TOTAL-PASSED: <n>`. Any failing suite at baseline stops the task BLOCKED with `PREEXISTING_SUITE_FAILURE` and the `FAILED:` lines recorded. CI job: `poshqc / PowerShell QC` (windows-latest).
- [x] [P0-T5] Capture the baseline format state (read-only) of `W18-FILE`: run `sh SCRATCH/tools/run-cr.sh cr-format -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"` and write `FEATURE/evidence/remediation-baseline/baseline-format.<timestamp>.md`.
  - Done when the artifact records the output, including the `FORMAT-DRIFT-COUNT:` line and the exit code. Expected: `FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, `FORMAT-DRIFT-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`; a non-zero drift count is recorded as pre-existing drift in `Output Summary:` and does not stop the task (P2-T1 is the gate).
- [x] [P0-T6] Capture the baseline analyzer state of `W18-FILE`: run `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"` and write `FEATURE/evidence/remediation-baseline/baseline-pssa.<timestamp>.md`.
  - Done when the artifact records the `PSSA:` line, the `PSSA-TOTAL:` line, and the exit code. Expected: `PSSA-TOTAL: 0` and `EXIT_CODE_COMPUTED: 0`.
- [x] [P0-T7] Capture the baseline actionlint state of `SCAN-FILE`: run `sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList ".github/workflows/_security-scan.yml"` and write `FEATURE/evidence/remediation-baseline/baseline-actionlint.<timestamp>.md`.
  - Done when the artifact records `ACTIONLINT-WRAPPER-EXIT:`, `ACTIONLINT-DIRECT-EXIT:`, `ACTIONLINT-FINDINGS:`, and `EXIT_CODE_COMPUTED:`. Expected: `ACTIONLINT-FINDINGS: 0` and `EXIT_CODE_COMPUTED: 0`. A porcelain line `?? tools/` after this run is expected (reference rule 12).

### Phase 1 — Non-Blocking Security Scan with a Working Export

- [x] [P1-T1] Edit `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (`W18-FILE`) with Edit: replace lines 308-321 (the `It` block named `runs the security scan under bash after installing the Poetry export plugin and without continue-on-error (AC-36)`) with the 16 lines of section 4, `### W18 replacement`, verbatim.
  - Done when Read of `W18-FILE` shows line 308 equal to `        It 'runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)' {`, the next 15 lines equal to section 4, lines 324-325 equal to `    }` and `}`, and no non-empty line follows line 325. No other line of the file changes. No line of the new block contains a token that `.claude/hooks/check-powershell-test-purity.ps1` rejects (reference rule 8).
- [x] [P1-T2] [expect-fail] Run the workflow suites against the unchanged `SCAN-FILE`: `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"` and write `FEATURE/evidence/regression-testing/rem1-w18-expect-fail.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Done when the output shows `SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=38 | Failed=1`, `NAMED: *(AC-36)* | Passed=0 | Failed=1 | Total=1`, exactly one `FAILED:` line, whose text contains `runs the security scan under bash with continue-on-error true after installing the Poetry export plugin (AC-36)`, the other four `SUITE:` lines with `Failed=0`, and `EXIT_CODE_COMPUTED: 1`. Any other outcome (in particular a pass of the new row) stops the task BLOCKED with the output recorded. This artifact is the fail-before evidence of RI-1b. CI job: `poshqc / PowerShell QC` (windows-latest).
- [x] [P1-T3] Edit `.github/workflows/_security-scan.yml` (`SCAN-FILE`) with Edit per RPD-1: insert the line `        continue-on-error: true` directly after the line `        shell: bash` of the step `Check for security vulnerabilities`.
  - Done when Read of `SCAN-FILE` shows lines 45-51 as `      - name: Check for security vulnerabilities`, `        if: ${{ inputs.run-heavy }}`, `        shell: bash`, `        continue-on-error: true`, `        run: |`, `          poetry run pip install safety`, `          poetry export -f requirements.txt --without-hashes | poetry run safety check --stdin`, and no non-empty line follows line 51; lines 1-44 (including the `Install the Poetry export plugin` step at lines 41-43) are unchanged.
- [x] [P1-T4] Run the workflow suites after the edit: `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-36)*"` and write `FEATURE/evidence/regression-testing/rem1-w18-pass.<timestamp>.md`.
  - Done when the output shows `SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0`, `NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1`, five `CONTAINER:` lines with `Result=Passed`, a `TOTAL:` line with `Failed=0` and `Passed=` equal to `BASELINE-TOTAL-PASSED` from the latest `FEATURE/evidence/remediation-baseline/baseline-pester-workflows.*.md`, and `EXIT_CODE_COMPUTED: 0`. The pass is valid as pass-after evidence only if the latest `FEATURE/evidence/regression-testing/rem1-w18-expect-fail.*.md` exists with its expected outcome. CI job: `poshqc / PowerShell QC` (windows-latest).
- [x] [P1-T5] Edit `.github/workflows/README.md` (`README-FILE`) with Edit per RPD-4: replace line 141 (the line beginning `On a full run, ` under `### Security scan`) with the one line of section 4, `### README replacement`, verbatim.
  - Done when Read of `README-FILE` shows line 139 `### Security scan`, line 140 empty, line 141 equal to section 4, and no non-empty line after 141. No other line of the file changes.
- [x] [P1-T6] Verify the README text with three `git grep` searches over the working tree and write `FEATURE/evidence/regression-testing/rem1-readme-tokens.<timestamp>.md` recording each command, its output, and its exit code on a labelled line: `git grep -c -F -e 'The scan step carries' -- .github/workflows/README.md`; `git grep -c -F -e '101 pre-existing findings' -- .github/workflows/README.md`; `git grep -c -F -e 'The scan step has no' -- .github/workflows/README.md`.
  - Done when the first two commands each print `.github/workflows/README.md:1` with exit code 0 (the literals `The scan step carries` and `101 pre-existing findings` are created by P1-T5) and the third prints nothing with exit code 1 (the old literal `The scan step has no` is removed by P1-T5; that command's line carries `EXPECTED-EXIT: 1`). The artifact's `EXIT_CODE:` is that of the first command.

### Phase 2 — Final QC, Commit, and Push

- [x] [P2-T1] Formatting stage: run `sh SCRATCH/tools/run-cr.sh cr-format -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -Write` and write `FEATURE/evidence/qa-gates/rem1-format.<timestamp>.md`, recording `git status --porcelain` before and after the run.
  - Done when the output contains `FORMAT-CLEAN: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, `FORMAT-DRIFT-COUNT: 0`, no `FORMAT-WRITTEN:` line, and `EXIT_CODE_COMPUTED: 0`, and the two porcelain listings are identical. A `FORMAT-WRITTEN:` line means the formatter rewrote the file: record it and restart Phase 2 from P2-T1 (rule 5).
- [x] [P2-T2] Linting stage: run `sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"` and write `FEATURE/evidence/qa-gates/rem1-pssa.<timestamp>.md`.
  - Done when the output contains `PSSA: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | findings=0`, `PSSA-TOTAL: 0`, and `EXIT_CODE_COMPUTED: 0`. Type checking does not apply to PowerShell.
- [x] [P2-T3] Workflow lint: run `sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList ".github/workflows/_security-scan.yml"` and write `FEATURE/evidence/qa-gates/rem1-actionlint.<timestamp>.md`.
  - Done when the output contains `ACTIONLINT-WRAPPER-EXIT: 0`, `ACTIONLINT-DIRECT-EXIT: 0`, `ACTIONLINT-FINDINGS: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [x] [P2-T4] Unit-test stage: run `sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*"` and write `FEATURE/evidence/qa-gates/rem1-pester-workflows.<timestamp>.md`.
  - Done when the output shows five `CONTAINER:` lines with `Result=Passed`, `SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0`, the `NAMED:` lines with `Total=5`, `Total=9`, `Total=21`, `Total=3`, and `Total=1` (in pattern order) each with `Failed=0`, a `TOTAL:` line with `Failed=0` and `Passed=` equal to `BASELINE-TOTAL-PASSED`, and `EXIT_CODE_COMPUTED: 0`. CI job: `poshqc / PowerShell QC` (windows-latest).
- [x] [P2-T5] PoshQC MCP test stage: record `git status --porcelain`, call `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the output of `git rev-parse --show-toplevel` and `scan_folders` `["tests/scripts/workflows"]`, record `git status --porcelain` again, and write `FEATURE/evidence/qa-gates/rem1-mcp-poshqc-test.<timestamp>.md` with `Command:` naming the MCP tool and its arguments (with `workspace_root` written as `<WORKSPACE_ROOT>`), `MCP_CALL: returned` and `EXIT_CODE: 0`, or `MCP_CALL: error <message>` and `EXIT_CODE: 1`, and both porcelain listings.
  - Done when the artifact records `MCP_CALL: returned` and the two porcelain listings are identical. Per rule 1 (reference rule 5), no count, percentage, or finding is read from the MCP result; the asserted test counts are those of P2-T4.
- [x] [P2-T6] README recheck: run `sh SCRATCH/tools/run-cr.sh cr-readme` and write `FEATURE/evidence/qa-gates/rem1-readme.<timestamp>.md`.
  - Done when the output contains `README-REPLACED-LINES: 1,1`, `README-ANCHOR-HITS: 1`, `README-PREFIX-IDENTICAL: True`, `README-TOKENS-MISSING: 0`, and `EXIT_CODE_COMPUTED: 0` (AC-24 and AC-35 remain satisfied after the P1-T5 edit).
- [x] [P2-T7] Hygiene and size check of `W18-FILE`: run `sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"` and write `FEATURE/evidence/qa-gates/rem1-hermetic.<timestamp>.md`.
  - Done when the output contains `LINES: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | 325`, `HERMETIC-HITS: 0`, `LINES-OVER-500: 0`, and `EXIT_CODE_COMPUTED: 0`.
- [x] [P2-T8] Scope check: run `git diff --name-only HEAD -- .github tests scripts .claude` and `git status --porcelain`, and write `FEATURE/evidence/qa-gates/rem1-scope.<timestamp>.md` with both outputs.
  - Done when the anchored diff lists exactly `.github/workflows/README.md`, `.github/workflows/_security-scan.yml`, and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, and every porcelain entry is either one of those three paths, ` M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md`, a path under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/` (this plan, the remediation inputs, and evidence), or `?? tools/`. Any other entry stops the task BLOCKED (rule 3).
- [x] [P2-T9] Commit and push, in this order, one command per call: `git add -- docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962 .github/workflows/_security-scan.yml .github/workflows/README.md tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`; `git commit -m "ci(962): keep the security scan non-blocking while pre-existing findings remain" -m "<attribution trailer required by the executing session>"`; `git push origin HEAD:refs/heads/bug/ci-skip-evidence-only-commits-962`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/ci-skip-evidence-only-commits-962`. Then write `FEATURE/evidence/other/commit-remediation-1.<timestamp>.md` with each command's output and exit code, and set this task's checkbox (RPD-6).
  - Done when the push exits 0 without `--force` or `--force-with-lease`, `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-skip-evidence-only-commits-962`, and `git status --porcelain` (observed before the artifact is written) lists nothing except `?? tools/`. A rejected push stops the task BLOCKED with the output recorded. AC-36 remains `- [ ]` in `FEATURE/spec.md` (rule 4).

## Files Written

1. `.github/workflows/_security-scan.yml` (P1-T3)
2. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (P1-T1)
3. `.github/workflows/README.md` (P1-T5)
4. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/spec.md` (RPD-3; amended by the planning agent before execution)
5. `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/remediation-plan.2026-10-17T01-20.md` (checkbox state)
6. New evidence files under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/` as named by the tasks above.

Scratch files: only the launcher and recipe files under `SCRATCH/tools/` (rewritten by P0-T3 only when absent or different) and the launcher's staged copies under `SCRATCH/stage/`, all outside the repository.

## Coordinator follow-up (record only)

Upgrade the 14 affected packages of `poetry.lock` recorded in `evidence/other/security-scan-findings.2026-10-17T01-18.md`, then remove `continue-on-error: true` from the scan step and restore the blocking W18 assertion and README wording. Not part of this cycle.
