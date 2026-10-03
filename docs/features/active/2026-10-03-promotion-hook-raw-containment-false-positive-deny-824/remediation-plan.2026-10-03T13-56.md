# promotion-hook-raw-containment-false-positive-deny (Remediation Plan, cycle 2)

- **Issue:** #824
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-03 (remediation cycle 2, R1 revision after preflight round 1: D7 third edit removes the multi-line `-Command` string; D13 single workflow edit with the new upload before the gate)
- **Status:** Draft
- **Version:** 2.2
- **Work Mode:** full-bug
- **Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824`
- **Remediation inputs:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-inputs.2026-10-03T13-56.md` (R1 / CR-1, R2 / CR-2, R3 / CR-3 blocking; advisories A1 to A6), with `code-review.2026-10-03T13-56.md`, `feature-audit.2026-10-03T13-56.md`, and `policy-audit.2026-10-03T13-56.md` in the same folder.
- **Requirements source (sole AC source):** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` v0.3, sections `## Acceptance Criteria` (AC-1 to AC-29, AC-42, AC-43) and `## Scope Extension` (AC-30 to AC-41), read together with `### Cycle 2 design decision` under `## Proposed Fix`.
- **Prior plan (execution mechanics carried forward):** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-03T10-30.md` (v1.3).
- **Languages in scope:** PowerShell (hooks, Pester suites, one new dev-tools gate script and two new Pester suites); bash (`.codex/codex-web-setup.sh`, its bundle copy, and one new bats file); GitHub Actions (`.github/workflows/_shell-coverage.yml`, decision Q1); one plain-text fixture. Python and TypeScript run in baseline and final QC only; no Python or TypeScript file changes.

**Mode note (full-bug):** `spec.md` is required and is the only acceptance-criteria source. `user-story.md` is not required. Execution fails closed if `spec.md` or either AC section is missing, if a required Phase 0 artifact is missing or incomplete, or if checklist state contradicts evidence on disk.

**Fail-closed evidence rule:** line coverage >= 85% applies to every changed PowerShell production file, with no uncovered changed line (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`; Pester measures no branch coverage). The baseline (P0-T14) coverage task records numeric values for the seven COV-TARGETS and the final-QC (P8-T4) task for the eight COV-TARGETS-FINAL (the seven plus the new gate script, which has no baseline because it does not exist at BASE_SHA). Python and TypeScript new-code coverage is the literal `N/A - no production file of this language changes`; the repository-wide Python and TypeScript figures are recorded numerically at baseline and final QC. Bash: the bats tests and their kcov measurement cannot run on this host through any permitted route (D8). Decision Q1 (option a) adds a dedicated kcov measurement and a failing coverage gate for `.codex/codex-web-setup.sh` to the CI job `shell-coverage / Shell Coverage (Bats + kcov)` (D13). AC-42's bats pass and kcov threshold are checked off at orchestration step S9 from that job's step `Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)` on the PR head (P9-T4 states the exact S9 condition); this plan does not check AC-42 off. The gate's decision logic is PowerShell and is tested and coverage-gated locally (P5-T5, P8-T4). If any required baseline artifact, final-QC artifact, or PowerShell coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` is determined in this order. (1) When the task's step script ends with a VERDICT or RELAY line (Terms) or another explicit `exit` statement, it is that step script's process exit code; when a task runs more than one step script, it is the value the task names, and by default the largest of their process exit codes. (2) Otherwise it is the exit code of the task's gating command, read from the `$LASTEXITCODE` value printed after it. (3) A task with neither uses its last command (STEP-SCRIPT term). Every task whose acceptance states a value that its gating command's exit code does not itself decide ends with a VERDICT or RELAY line, so that its `EXIT_CODE:` is non-zero whenever any stated acceptance value is not met. When a RELAY task in Phase 8 passes through its baseline, PRE-EXISTING-FAILURE, or ISSUE-510-BRANCH branch with a non-zero relayed exit code, its artifact also records `ExpectedExitCode:` equal to that exit code. No planned command task may record `EXIT_CODE: SKIPPED`; the only authorized skip branch is the MCP route step in "Execution constraints".

**Evidence location:** the caller supplied only canonical paths, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is needed. Phase 0 writes to FEATURE/evidence/remediation-baseline/; regression runs to FEATURE/evidence/regression-testing/; task records to FEATURE/evidence/other/; final QC and AC re-verification to FEATURE/evidence/qa-gates/. Every artifact name in this cycle starts with `r2-`. `artifacts/pester/` is used only as the Pester tool output location the repository settings define (and, in CI only, as the kcov output location of the existing and the new shell-coverage steps), never as an evidence location.

**Host-path rule:** no file under FEATURE may contain an absolute host path. Runner output files (JUnit XML, coverage XML, captured logs) are written under SCRATCH (or, for the full PoshQC run, the repository's `artifacts/pester/` tool location), never under FEATURE; `.md` artifacts carry the full `PASSED:` and `FAILED:` lists instead. When recorded output contains an absolute path, the executor replaces the WORKTREE prefix with the token WORKTREE and the SCRATCH prefix with the token SCRATCH, in both slash forms, before writing the artifact; any other absolute path is replaced in full by the token HOSTPATH. P8-T17 and P9-T6 verify the feature folder carries no host path.

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`.
- TS means the task's execution time in yyyy-MM-ddTHH-mm form, the value of the `TS=` line that the A0 preamble prints when the task's first step script runs. Phase 9 uses the P9-T1 value for every append to its one check-off artifact.
- SCRATCH means the executor's session scratchpad directory (outside the repository and outside both checkouts). Step scripts are written to SCRATCH/steps/. Artifacts record it as the literal token SCRATCH. Inside commands it is the variable `$Scratch`, which A0 sets.
- WORKTREE means the worktree root the caller supplied (the checkout whose branch is `bug/promotion-hook-raw-containment-false-positive-deny-824`). Artifacts record it as the literal token WORKTREE.
- BASE_SHA means the 40-character commit printed by P0-T3 before any edit. Every scope diff, changed-line computation, and test-integrity check is anchored to it. In a step script it is written as the recorded value.
- STEP-SCRIPT means the execution form of every command in this plan, including commands in Acceptance lines. For each task the executor writes SCRATCH/steps/r2-<task-id>.ps1 (for example SCRATCH/steps/r2-p0-t1.ps1) with the Write tool, containing the A0 preamble from the Appendix followed by the task's commands verbatim, in order, one per line, with BASE_SHA substituted. It runs the file through its Bash tool as `pwsh -NoProfile -File "<SCRATCH>/steps/r2-<task-id>.ps1" -Worktree "<WORKTREE>"` (absolute paths with forward slashes) and records the printed output in the task's artifact. The Bash tool's working directory resets to the main checkout between calls, so A0 sets the location to WORKTREE before any command runs. A re-run task rewrites its step script.
  - A command written `pwsh -NoProfile -Command '<script>'` starts a child pwsh whose working directory is WORKTREE; the outer single quotes stop the step script from expanding `$`. These forms call module functions directly and never invoke a script file through `&`.
  - A command written ``pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' ...; exit `$LASTEXITCODE"`` starts A2 in a child process; the double quotes expand `$Scratch`, and the backtick keeps `$LASTEXITCODE` literal so the child exits with A2's own exit code. Every A2 command in this plan ends with ``; exit `$LASTEXITCODE`` immediately before its closing double quote. Commands containing a backtick are delimited in this plan by double backticks; the command is the text between them without the single padding space on each side.
  - A command written `& "$Scratch/<helper>.ps1" <args>; $LASTEXITCODE` runs A1, A3, A4, or A5 in the step-script process.
  - When a task's last command is a native command (`git`, `npm`, `npx`, `poetry`), a child pwsh, or a helper, its exit code is the `$LASTEXITCODE` value printed after it; where the plan does not already write `; $LASTEXITCODE` after that last command, the executor appends it. When the last command is a cmdlet expression, it is the step-script process exit code.
  - Tasks that use the Write or Edit tool, or an MCP tool, perform that tool call directly and run their verification commands as a step script.
- PARSE-CHECK(F) means `$e = $null; [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path F).Path, [ref]$null, [ref]$e) | Out-Null; "PARSE-ERRORS=$(@($e).Count)"`, which prints `PARSE-ERRORS=0` for a file with no parse error. `$e` is reset first so a value left from an earlier line cannot be reported, and it stays set so that the task's VERDICT line can read `@($e).Count`.
- SH-CHECK(F1, F2) means `$sh = (Get-Command -Name sh -CommandType Application | Select-Object -First 1).Source; $worst = 0; foreach ($f in @(F1, F2)) { & $sh -n $f; "$f SYNTAX-EXIT=$LASTEXITCODE"; $worst = [Math]::Max($worst, $LASTEXITCODE) }; "SYNTAX-EXIT=$worst"`, with each file a single-quoted repository-relative path. It assigns `$worst`, which a following VERDICT line reads.
- VERDICT(C) means the step script's last line `exit ([int](-not (C)))`, where C is the PowerShell condition the task states over the variables its commands assign.
- RELAY(X, C) means the step script's last line `exit $(if (C) { X } else { 255 })`, where X is the gating command's captured exit code.
- RECORDED(Pn-Tm KEY) means the value that the named earlier artifact records for KEY, written into the step script as a literal in the same way as BASE_SHA (a number as digits; a `TREE-DIGEST=` value in single quotes; a list as a single-quoted array literal such as `@('a', 'b')`, or `@()` when empty).
- A0 to A5 mean the preamble and the five helper scripts defined verbatim in the Appendix; P0-T4 saves A1 to A5 as SCRATCH/cov-derive.ps1, SCRATCH/issue824-pester.ps1, SCRATCH/resolver-ast-check.ps1, SCRATCH/phrase-scan.ps1, and SCRATCH/raw-predicate-ast-check.ps1. B1 and B2 mean the bats file and fixture contents defined verbatim in the Appendix; B3, B4, and B5 mean the gate script, its Pester suite, and the workflow-invariant Pester suite defined verbatim in the Appendix; W1 means the one workflow edit defined verbatim in D13.
- Suites:
  - S1 `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1`
  - S2 `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1`
  - S3 `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1`; S3X `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1`
  - S6 `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`
  - S7 `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`
  - S8 `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`
  - U1 `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1`; U2 `tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1`
  - LEGACY `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (not edited)
  - PYG `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (not edited)
  - BATS `tests/shell/test_codex_web_setup_codex_copy.bats` (new)
  - FIXTURE `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` (new)
  - GT `tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1` (new, B4; tests G824-1 to G824-15)
  - WT `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1` (new, B5; tests W824-1 to W824-6)
- ISSUE824-PATHS means the A2 argument `-Path @('tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1')` (S1, S2, S6, S7, S8, U1, U2).
- GATE-SUITE-PATHS means the A2 argument `-Path @('tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1')`.
- Production files:
  - CLAUDE-RAW `.claude/hooks/hook-command-raw-invocation.ps1`; CODEX-RAW `.codex/hooks/hook-command-raw-invocation.ps1`.
  - CLAUDE-INV `.claude/hooks/hook-command-invocation.ps1`; CODEX-INV `.codex/hooks/hook-command-invocation.ps1`.
  - EPIC-GATE `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; PAR-GATE `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`; CODEX-GATE `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
  - SETUP `.codex/codex-web-setup.sh`.
  - GATE `scripts/dev-tools/KcovFunctionCoverageGate.ps1` (new, B3).
  - WORKFLOW `.github/workflows/_shell-coverage.yml` (CI configuration, edited per D13).
- YAML-CHECK(LOG) means these two step-script lines, with LOG a file name under SCRATCH: `$yamlCode = "import yaml; d = yaml.safe_load(open('.github/workflows/_shell-coverage.yml', encoding='utf-8')); s = d['jobs']['shell-coverage']['steps']; print('YAML-STEPS=' + str(len(s))); print('YAML-NAMES=' + '|'.join(x['name'] for x in s))"; poetry run python -c $yamlCode *> "$Scratch/LOG"; $yamlExit = $LASTEXITCODE; "YAML-EXIT=$yamlExit"` and `$yamlLines = @(Select-String -LiteralPath "$Scratch/LOG" -CaseSensitive -Pattern '^YAML-(STEPS|NAMES)=' | ForEach-Object { $_.Line }); $yamlLines; $yamlSteps = @($yamlLines | Where-Object { $_ -cmatch '^YAML-STEPS=\d+$' } | ForEach-Object { [int]($_ -split '=')[1] }); "YAML-STEP-COUNT=$(if ($yamlSteps.Count -eq 1) { $yamlSteps[0] } else { -1 })"`. The Python code is one line, so `-c` executes it; the printed `YAML-STEPS=` line exists only when the file parses and the job's step list is read, so a silent no-op yields `YAML-STEP-COUNT=-1`.
- ACTIONLINT-RUN(LOG) means this step-script line, with LOG a file name under SCRATCH: `$actionlint = Get-Command -Name actionlint -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; $actionlintMessages = @(); if ($null -ne $actionlint) { & $actionlint.Source -no-color -shellcheck= -pyflakes= .github/workflows/_shell-coverage.yml *> "$Scratch/LOG"; $actionlintExit = $LASTEXITCODE; $actionlintMessages = @(Select-String -LiteralPath "$Scratch/LOG" -Pattern '^[^:\s]+:\d+:\d+: (.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value }) } else { $actionlintExit = -1 }; "ACTIONLINT-EXIT=$actionlintExit"; $actionlintMessages | ForEach-Object { "ACTIONLINT-MESSAGE: $_" }`. It runs actionlint only when it is already on PATH, never through `scripts/dev-tools/run-actionlint.ps1`, with the shellcheck and pyflakes integrations disabled, and prints `ACTIONLINT-EXIT=-1` otherwise. A message list carried by RECORDED doubles every `'` inside an entry.
- CB means `extensions/drm-copilot/resources/claude-customizations/` and XB means `extensions/drm-copilot/resources/codex-and-agents-customizations/`. A path written CB + `.claude/x` means `extensions/drm-copilot/resources/claude-customizations/.claude/x`.
- MIRROR-PAIRS means the ten pairs that must be byte-identical after Phase 6 (source first): MP1 CLAUDE-RAW / CODEX-RAW; MP2 CLAUDE-RAW / CB + `.claude/hooks/hook-command-raw-invocation.ps1`; MP3 CODEX-RAW / XB + `.codex/hooks/hook-command-raw-invocation.ps1`; MP4 CLAUDE-INV / CODEX-INV; MP5 CLAUDE-INV / CB + `.claude/hooks/hook-command-invocation.ps1`; MP6 CODEX-INV / XB + `.codex/hooks/hook-command-invocation.ps1`; MP7 EPIC-GATE / CB + `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; MP8 PAR-GATE / CB + `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`; MP9 CODEX-GATE / XB + `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`; MP10 SETUP / XB + `.codex/codex-web-setup.sh`.
- IDENTITY-LOOP means this one step-script line: `$cb = 'extensions/drm-copilot/resources/claude-customizations/'; $xb = 'extensions/drm-copilot/resources/codex-and-agents-customizations/'; $pairs = @(@('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1'), @('.claude/hooks/hook-command-raw-invocation.ps1', "${cb}.claude/hooks/hook-command-raw-invocation.ps1"), @('.codex/hooks/hook-command-raw-invocation.ps1', "${xb}.codex/hooks/hook-command-raw-invocation.ps1"), @('.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1'), @('.claude/hooks/hook-command-invocation.ps1', "${cb}.claude/hooks/hook-command-invocation.ps1"), @('.codex/hooks/hook-command-invocation.ps1', "${xb}.codex/hooks/hook-command-invocation.ps1"), @('.claude/hooks/enforce-epic-worktree-removal-gate.ps1', "${cb}.claude/hooks/enforce-epic-worktree-removal-gate.ps1"), @('.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', "${cb}.claude/hooks/enforce-parallel-worktree-removal-gate.ps1"), @('.codex/hooks/enforce-epic-worktree-removal-gate.ps1', "${xb}.codex/hooks/enforce-epic-worktree-removal-gate.ps1"), @('.codex/codex-web-setup.sh', "${xb}.codex/codex-web-setup.sh")); $unequal = 0; foreach ($p in $pairs) { $equal = (Get-FileHash -LiteralPath $p[0] -ErrorAction Stop).Hash -eq (Get-FileHash -LiteralPath $p[1] -ErrorAction Stop).Hash; if (-not $equal) { $unequal++ }; "$($p[0]) | $($p[1]) | EQUAL=$equal" }; "PAIRS=$($pairs.Count) UNEQUAL=$unequal"`. It prints ten `EQUAL=` lines and one `PAIRS=10 UNEQUAL=<n>` line.
- COV-TARGETS means the A1 argument `-Target @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1', '.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1')`.
- COV-TARGETS-FINAL means the A1 argument `-Target @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1', '.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1', 'scripts/dev-tools/KcovFunctionCoverageGate.ps1')`: COV-TARGETS plus GATE. A1 treats every line of GATE as changed, because GATE does not exist at BASE_SHA.
- SCOPE-PATHS means the 31 paths listed in D11. Nothing else outside FEATURE and `.claude/agent-memory` may change.
- SCOPE-ARRAY means this step-script line: `$cb = 'extensions/drm-copilot/resources/claude-customizations/'; $xb = 'extensions/drm-copilot/resources/codex-and-agents-customizations/'; $scope = @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1', "${cb}.claude/hooks/hook-command-raw-invocation.ps1", "${xb}.codex/hooks/hook-command-raw-invocation.ps1", '.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1', "${cb}.claude/hooks/hook-command-invocation.ps1", "${xb}.codex/hooks/hook-command-invocation.ps1", '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1', "${cb}.claude/hooks/enforce-epic-worktree-removal-gate.ps1", "${cb}.claude/hooks/enforce-parallel-worktree-removal-gate.ps1", "${xb}.codex/hooks/enforce-epic-worktree-removal-gate.ps1", '.codex/codex-web-setup.sh', "${xb}.codex/codex-web-setup.sh", 'tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/shell/test_codex_web_setup_codex_copy.bats', 'tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt', '.github/workflows/_shell-coverage.yml', 'scripts/dev-tools/KcovFunctionCoverageGate.ps1', 'tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1', 'tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1'); "SCOPE-ARRAY-COUNT=$($scope.Count)"`. It prints `SCOPE-ARRAY-COUNT=31`.
- PARITY-PYTEST means `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_push_down_codex_and_agents_variant_packs.py tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -q -rfE *> "$Scratch/r2-parity.log"; $parityExit = $LASTEXITCODE; "PARITY-EXIT=$parityExit"`, followed by the line `$parityFailed = @(Select-String -LiteralPath "$Scratch/r2-parity.log" -Pattern '^(FAILED|ERROR) (\S+)' | ForEach-Object { $_.Matches[0].Groups[2].Value }); $parityFailed | ForEach-Object { "PARITY-FAILED: $_" }; $parityState = (Select-String -LiteralPath "$Scratch/r2-parity.log" -SimpleMatch -Pattern '.claude/state/').Count; $p510 = ($parityExit -eq 0) -or ($parityExit -eq 1 -and $parityFailed.Count -eq 1 -and $parityFailed[0] -eq 'tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts' -and $parityState -gt 0); "ISSUE-510-BRANCH=$p510"`.
- ISSUE-510-BRANCH means: PARITY-PYTEST passes when it exits 0. It also passes, and only in this case, when it exits 1 with exactly one failed test, `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and its log names a path under `.claude/state/` (open issue #510). Any other failure fails the task.
- PRE-EXISTING-FAILURE means a failing test whose identical node or test name appears in the corresponding Phase 0 baseline failure list (BASELINE-PESTER-FAILURES, BASELINE-PYTEST-FAILURES, or BASELINE-JEST-FAILURES) and whose test file is not one this plan changes or creates. It is recorded by name in the final-QC artifact and does not fail that task; any other failure does.
- TREE-DIGEST means this one step-script line (BASE_SHA substituted): `$d = git diff BASE_SHA --binary -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory' | Out-String; $u = git ls-files --others --exclude-standard -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory' | ForEach-Object { "$((Get-FileHash -LiteralPath $_).Hash) $_" } | Out-String; $treeDigest = [BitConverter]::ToString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($d + $u))); "TREE-DIGEST=$treeDigest"`.
- FIX-SET means the A2 argument `-RequirePassed @('P824-D16*2', 'P824-D17*2', 'P824-D18*2', 'P824-D19*2', 'A824-X1*3', 'A824-X2*3', 'A824-X3*3', 'A824-X4*3', 'A824-X7*3', 'A824-X8*3', 'A824-X10*3', 'A824-WT6*3', 'A824-WT11-1*3', 'R824-P26*2', 'R824-P27*2', 'R824-P28*2', 'R824-P29*2', 'R824-P30*2')`: the 45 tests of the P1-T10 failing set (4 x 2 + 7 x 3 + 3 + 3 + 5 x 2). A2 matches an entry against the start of a passed test's expanded name followed by one space, so `A824-X1` does not match `A824-X10`.

## Execution constraints

- Command route. Every command runs through the executor's Bash tool in STEP-SCRIPT form. Every `git`, `poetry run`, `npm`, and `npx` command is a line inside a step script after A0 has removed `Env:VIRTUAL_ENV` and set the location to WORKTREE. The executor does not choose a route because a hook is or is not registered on it, and does not run `bash`, `bats`, `kcov`, `shfmt`, `shellcheck`, or `wsl`; the only shell invocation is the `sh -n` syntax check that SH-CHECK defines, run from inside a step script as in cycle 1 (D8). The executor does not run `scripts/dev-tools/run-actionlint.ps1`, which downloads a binary from the network into the untracked, non-ignored `tools/actionlint/bin/` and would therefore change the tree outside SCOPE-PATHS; `actionlint` runs only through ACTIONLINT-RUN in P0-T24 and P8-T13, and only when it is already on PATH, with its shellcheck and pyflakes integrations disabled (D13).
- Hook halt rule. Hooks in this session run the main checkout's hook scripts, which do not contain this fix. If any hook denies any command, Write, or Edit, stop, record the denial text in the current task's artifact, and report to the caller. Do not reword, re-route, split, re-quote, or rename a command, script, or file to avoid a hook, and do not bypass a hook.
- Prepared environments. The orchestrator prepared WORKTREE's `.venv` and `extensions/drm-copilot/node_modules`. The executor does not install dependencies; P0-T9 and P0-T10 verify presence and stop the plan when either is missing.
- Production-file writes. CLAUDE-RAW, CLAUDE-INV, the three gates, SETUP, and WORKFLOW are edited with the Edit tool; BATS, FIXTURE, GATE, GT, and WT are created with the Write tool; existing test files are edited with the Edit tool. CODEX-RAW, CODEX-INV, and every bundle copy in MIRROR-PAIRS are produced with `Copy-Item` lines in step scripts (P2-T3, P4-T2, P6-T1), because each must be byte-identical to its source; each copy is then confirmed by `Get-FileHash`.
- MCP route step. `.claude/rules/powershell.md` names `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`. They return a summary composed before the child runs and carry no exit code, count, or percentage, so P8-T1, P8-T2, and P8-T3 call each one as a route-compliance step with its workspace or target-root parameter set to WORKTREE and record `MCP_ROUTE: CALLED` plus whether the call returned or raised; the direct self-hosted command is the gating measurement. Every MCP route step is bracketed by two TREE-DIGEST runs. In P8-T1 and P8-T2 the direct command runs first; in P8-T3 the bracketed MCP call runs first and the direct run last, so `artifacts/pester` holds the direct run's output. Unequal `TREE-DIGEST=` values mean the MCP step rewrote files: record `git status --porcelain` and stop for a caller decision without restarting the loop. Authorized skip branch: if the MCP tool is absent from the executor's tool list, or exposes no parameter that targets WORKTREE, record `MCP_ROUTE: UNAVAILABLE` with the reason; the direct command and both TREE-DIGEST runs remain mandatory. `mcp__drm-copilot__run_poshqc_analyze_autofix` is not used.
- Long runs. P0-T13, P0-T18, P0-T22, P7-T2, P8-T3, P8-T8, and P8-T12 can exceed eight minutes. Run each step script in the Bash tool's background mode (or with the longest available timeout) and wait for the completion notification. A run stopped by a timeout produces no evidence and is re-run in full.
- Commit timing. The executor makes no commit during this plan. Every diff is anchored to BASE_SHA, and new-file detection uses the union of `git diff --name-only BASE_SHA` and `git ls-files --others --exclude-standard` minus the PRE-UNTRACKED list recorded by P0-T3, so each check gives the same result whether the change is uncommitted or committed once at the end by the orchestrator.
- Test-integrity rule. Existing PowerShell test lines change only as D5 lists: the `A824-WT6` title and assertion lines in S6, S7, and S8 (specified by spec v0.3 `### Cycle 2 design decision` item 2), the AC-16 title and one `-Because` text in S3 and S3X, and the `.DESCRIPTION`, one Context title, and two `-Because` texts in U1 and U2 (permitted by spec v0.3 `#### Backward-compatibility expectations`). No other existing test line is modified or deleted. If an existing test fails after an implementation task and its fix would require editing any other existing line, stop and report.
- Stop conditions. When a task's stop condition is reached, write the task's artifact with the stop reason and report to the caller. Do not substitute a different design.
- Scope exclusions. Not edited: `.claude/settings.json`, every hook registration, every deny reason string, `Get-CommandLineRawInvocationOperand`, `Resolve-CommandLineWrappedInvocationOperand`, `Get-CommandLineRawInvocationMatch`, `Get-CommandLineRawInvocationPattern` (D1), every `.claude/rules/` and `.github/instructions/` file (including `.claude/rules/shell.md`), `scripts/bash/shell_qc_lib.sh` and its discovery and include roots (decision Q1 constraint), every `.github/workflows/` file other than WORKFLOW, every existing step of WORKFLOW (D13 only inserts steps), `spec.md` criterion text (only checkboxes change, in Phase 9), `issue.md`, `research/`, and every file outside SCOPE-PATHS. Advisories A1 to A6 and the spec Non-Goals are not acted on.

## Recorded design decisions

- D1 - Requirement precedence and reconciliation with the remediation inputs. The orchestrator recorded that spec v0.3 governs where `remediation-inputs.2026-10-03T13-56.md` conflicts with it. Consequences, each re-derived against the current tree:
  - R2 (CR-2) is fixed by replacing the R2 classifier with the spec's whole-token, order-independent match (spec `### Cycle 2 design decision` item 1, AC-1), not by adding `\$[0-9@*#]` and an `xargs` form to the sequence grammar (remediation-inputs R2 "Required fix" 1 and 2). Every Y form names `gh`, `issue`, and `create` as whole tokens, so it classifies.
  - R1 (CR-1) is fixed in the three gates by removing the `NoOperand` allow branch (spec item 2, AC-43), not by changing `Get-CommandLineRawInvocationOperand` (remediation-inputs R1 "Required fix" 1 to 3). After the change, only a `Status = 'Operand'` result replaces the structural path; `NoOperand`, `Indeterminate`, and `NoMatch` keep the structural path, which an R2 match leaves without an operand (`hook-command-invocation.ps1` lines 316-320 return no operand for `OperandIndex -lt 0`), so the unchanged allow predicates reject it with or without a checkpoint record. The existing rows `A824-WT7` (null path, authorizing record, deny) and `A824-WT8` (indeterminate, authorizing record, deny) already exercise that fall-through on all three gates. The operand reader is unchanged, so the remediation-inputs unit rows asserting `Indeterminate` for each X text are not added; planning-time trace: the reader returns `NoOperand` for X1, X2, X3, X4, X7, X8, and X10, and the gate rows (D6) carry the required behaviour.
  - Remediation-inputs R1 "Required fix" 4 ("keep `A824-WT6` green") and the "Do Not Do" item on assertion edits yield to spec item 2, which changes the `A824-WT6` expected decision from allow to deny on all three gate suites.
  - The remediation-inputs base-versus-head probe for X5, X6, X9, and Y4 is not repeated; those forms are not in AC-14, and the fail-before (P1-T10) and pass-after (P7-T1) runs cover every AC-14 and AC-43 form named in spec v0.3.
- D2 - Matcher change in CLAUDE-RAW (AC-1, AC-14 promotion forms). Three edits with the Edit tool; every other function is unchanged:
  - Replace lines 5 to 40 (the `.DESCRIPTION` body of the module header: from the line after `.DESCRIPTION`, which is line 4, through the line `    . (Join-Path $PSScriptRoot 'hook-command-raw-invocation.ps1')`) with:

    ```text
        Realizes the R2 fail-closed rule of issue #824 as revised by remediation cycle 2. A
        wrapper-led or live-substitution segment carries its nested command line inside its
        raw text, often inside a quoted -Command or -c argument, so the structural token walk
        cannot see it. Test-CommandLineRawInvocation classifies such a segment when the
        command word and every subcommand element each occur in the raw text as whole tokens,
        in any order, rather than merely as substrings of longer words.

        Whole-token rule, applied case-insensitively and culture-invariantly: no word
        character or hyphen may touch the word on either side, so 'gh' inside 'through' and
        'new' inside 'New-Object' do not match, while '/usr/bin/gh', 'gh.exe', and a quoted or
        backslash-escaped 'gh' do. Order, adjacency, and the number of occurrences are not
        checked, so positional parameters ('gh "$@"'), xargs-led invocations, variables,
        splats, and arrays that carry the subcommand words still classify.

        Operand extraction is separate from classification. Get-CommandLineRawInvocationMatch
        finds the invocation as a sequence (the command word followed by the subcommand
        elements, with options skipped and shell expansions standing in for positions) or as
        an absorption (a token after the command word that may carry the remaining elements).
        Get-CommandLineRawInvocationOperand reads the operand that follows a fully literal
        sequence, and Resolve-CommandLineWrappedInvocationOperand applies it to the segment a
        wrapped invocation classified on. The worktree-removal gates deny a classified segment
        from which exactly one literal operand is not read. Resolve-CommandLineWrappedInvocationOperand
        calls Resolve-CommandLineInvocation, which is defined in hook-command-invocation.ps1;
        that module dot-sources this file, so the function resolves at call time (a runtime
        dependency, not a load-time one).

        Pure string logic only: no disk, process, network, clock, or environment access. It is
        dot-sourced by hook-command-invocation.ps1 as:
        . (Join-Path $PSScriptRoot 'hook-command-raw-invocation.ps1')
    ```

  - Replace the whole `Test-CommandLineRawWordPresent` function (lines 95 to 115) with:

    ```text
    function Test-CommandLineRawWordPresent {
        <#
        .SYNOPSIS
            Report whether a word occurs as a whole token somewhere in a raw text.
        .DESCRIPTION
            A whole token is bounded on both sides: no word character or hyphen touches it, as
            matched by (?<![\w-])word(?![\w-]) with the word regex-escaped. A '.exe' suffix, a
            path prefix, and a surrounding or backslash-escaped quote need no special case,
            because '.', '/', '\', and the quote characters are not word characters. Compared
            case-insensitively and culture-invariantly.
        .OUTPUTS
            System.Boolean
        #>
        [CmdletBinding()]
        [OutputType([bool])]
        param(
            [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
            [Parameter(Mandatory)][string] $Word
        )

        $pattern = '(?<![\w-])' + [regex]::Escape($Word) + '(?![\w-])'
        $options = [System.Text.RegularExpressions.RegexOptions]'IgnoreCase, CultureInvariant'
        return [regex]::IsMatch($RawText, $pattern, $options)
    }
    ```

    The only behavioural difference from the current body is the removal of the optional `(?:\.exe)?` group, which cannot change a result: the lookahead `(?![\w-])` already accepts the `.` that begins `.exe`. `Get-CommandLineRawInvocationMatch` (lines 141 and 154) therefore reads the same values, and the R824-O and R824-W operand rows are unaffected.
  - Replace the whole `Test-CommandLineRawInvocation` function (lines 166 to 194) with:

    ```text
    function Test-CommandLineRawInvocation {
        <#
        .SYNOPSIS
            Report whether a raw text names a command word and every subcommand element as
            whole tokens, in any order.
        .DESCRIPTION
            The R2 predicate of Resolve-CommandLineInvocation for a wrapper-led or
            live-substitution segment. Returns $true when Test-CommandLineRawWordPresent finds
            the command word and each subcommand element in RawText, and $false as soon as one
            of them is absent. Order, adjacency, and the number of occurrences are not checked,
            and the sequence grammar used for operand extraction plays no part.
        .PARAMETER RawText
            The segment's raw text, including the contents of any quoted -Command or -c argument.
        .PARAMETER CommandWord
            The command name, e.g. 'git' or 'gh'. Compared case-insensitively.
        .PARAMETER SubcommandPath
            One or more subcommand tokens. Compared case-insensitively; their order is not checked.
        .OUTPUTS
            System.Boolean
        #>
        [CmdletBinding()]
        [OutputType([bool])]
        param(
            [Parameter(Mandatory)][AllowEmptyString()][string] $RawText,
            [Parameter(Mandatory)][string] $CommandWord,
            [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
        )

        foreach ($word in @($CommandWord) + @($SubcommandPath)) {
            if (-not (Test-CommandLineRawWordPresent -RawText $RawText -Word $word)) {
                return $false
            }
        }
        return $true
    }
    ```

  - Planning-time trace (every existing U1/U2 classification row re-derived against the whole-token rule): R824-P1 to P25 each contain every word as a whole token (P12 `C:\tools\gh.exe`, P14 `\"gh\"`, P19 `c=gh;`, P20 `x=create;`, P21 `"issue create"`, P22 `"issue","create"`, P23 `(issue create)`, P24 the line-feed-separated `create`, P25 `"worktree remove"`), so all stay `$true`. R824-N1 to N10 each lack at least one whole token (`through`, `legit`, `removed`, `high`/`priority`, `newline`, `list`, `$a $b $c`, `gh $x`, `$prefix` with no `gh`, `$path` with no `git`), so all stay `$false`. The whole-token match is a subset of the merge-base substring containment, so every pre-existing test that expected no classification at the merge base still holds; P7-T2 runs every hook suite to confirm.
- D3 - Gate change (AC-43, AC-14 worktree forms). In each gate, replace the four comment lines and the `NoOperand` line of the cycle-1 block with five comment lines, leaving the `$wrapped = ...` line and the `Operand` line unchanged:
  - EPIC-GATE lines 360 to 366 become:

    ```text
        # Issue #824 cycle 2: a wrapper-led or substitution removal is gated on its raw-text
        # operand only when exactly one literal operand is read from it. Every other outcome
        # (no operand, an unreadable or expansion-sourced operand, several operands, or no
        # sequence to read) keeps the structural path, which an R2 match leaves without an
        # operand, so the unchanged predicates below deny it with or without a checkpoint record.
        $wrapped = Resolve-CommandLineWrappedInvocationOperand -CommandText $commandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')
        if ($wrapped.Status -eq 'Operand') { $worktreePath = $wrapped.Operand }
    ```

  - PAR-GATE lines 366 to 372: the same seven lines.
  - CODEX-GATE lines 130 to 136: the same five comment lines, then the unchanged `$wrapped = Resolve-CommandLineWrappedInvocationOperand -CommandText $command -CommandWord 'git' -SubcommandPath @('worktree', 'remove')` and `if ($wrapped.Status -eq 'Operand') { $target = $wrapped.Operand }` lines.
  - Each gate's BASE_SHA-anchored numstat is therefore `5	5` and its line count is unchanged; no deny reason changes; the `-CommandWord '` call-site count stays 37 in 13 files.
- D4 - Documented contract in CLAUDE-INV (AC-22). Three edits with the Edit tool; CODEX-INV is then a copy:
  - Lines 32 and 33 (`# validate-bash structural leg deny on it. Under-classification is a bypass. Pinned by test` and `# through Get-CommandLineGlobalOption (rule R6).`) become:

    ```text
    # validate-bash structural leg deny on it, both for this rule and for R2, which classifies a
    # wrapper-led or live-substitution segment only when the command word and every subcommand
    # element occur in its raw text as whole tokens. Under-classification is a bypass. Pinned
    # by test through Get-CommandLineGlobalOption (rule R6).
    ```

  - Lines 102 and 103 (`        wrapper-led and live-substitution segments are classified by the token-aware` and `        Test-CommandLineRawInvocation (hook-command-raw-invocation.ps1).`) become:

    ```text
            wrapper-led and live-substitution segments are classified by
            Test-CommandLineRawInvocation (hook-command-raw-invocation.ps1), which requires the
            command word and every subcommand element to occur as whole tokens.
    ```

  - Lines 178 and 179 (`        finds the command word followed by every subcommand element as a token-bounded,` and `        ordered sequence in its RawText, including inside a quoted -Command or -c argument;`) become:

    ```text
            finds the command word and every subcommand element as whole tokens, in any order,
            in its RawText, including inside a quoted -Command or -c argument;
    ```

  - The hard-deny callers stay named in lines 30 to 31 (option-table comment) and lines 183 to 185 (Resolve description). Result: the literal `whole tokens` occurs on exactly 3 lines, `ordered sequence` on none, the numstat is `9	6`, and the file grows by 3 lines (491 at planning time, so 494).
- D5 - Edits to existing test lines (each one Edit call; nothing else in these files changes except the appended blocks of D6):
  - S6 line 184 becomes `        It 'A824-WT6 denies a wrapped removal that names no operand' -Tag 'Issue824' {`; line 193 (`                Should -Be 'allow' -Because 'a wrapped removal that names no operand removes nothing'`) becomes the three lines `                Should -Be 'deny' -Because 'a classified wrapped removal without exactly one literal operand fails closed (cycle 2 design decision 2)'`, `            $decision.hookSpecificOutput.permissionDecisionReason |`, and `                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'`. Deleted lines: 2.
  - S7: line 164 and line 173 change the same way, with `^PARALLEL_WORKTREE_REMOVAL_BLOCKED`. Deleted lines: 2.
  - S8: line 169 becomes the same title; line 177 (`            $decision | Should -BeNullOrEmpty -Because 'a wrapped removal that names no operand removes nothing'`) becomes the four lines `            $decision.hookSpecificOutput.permissionDecision |`, `                Should -Be 'deny' -Because 'a classified wrapped removal without exactly one literal operand fails closed (cycle 2 design decision 2)'`, `            $decision.hookSpecificOutput.permissionDecisionReason |`, and `                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'`. Deleted lines: 2.
  - S3 and S3X (AC-16): line 207 becomes `        It 'classifies a wrapper-led segment whose raw text carries every word as a whole token' {`; line 244 becomes `                Should -BeFalse -Because 'gh does not occur as a whole token in the reproduction'`. Assertions unchanged. Numstat `2	2` each.
  - U1 and U2: lines 10 to 13 become `    command word and every subcommand element each occur as whole tokens, in any order,`, `    and must classify. The negative rows (R824-N) lack at least one of the words as a`, `    whole token (it occurs only inside a longer word, only through a shell expansion, or`, and `    not at all) and must not classify. The R824-O and R824-W rows cover operand extraction.`; line 25 becomes `    Context 'positive rows - every word occurs as a whole token' {`; line 54's `-Because` text becomes `"'$RawText' carries $CommandWord $($SubcommandPath -join ' ') as whole tokens"`; line 74's `-Because` text becomes `"'$RawText' lacks $CommandWord or a subcommand word as a whole token"`. Deleted lines: 7 each.
- D6 - New test rows (all `-Tag 'Issue824'`, Arrange-Act-Assert, pure seams, no file or process access, `-ForEach` tables written inline, appended as the last children of the file's top-level `Describe`).
  - U1 and U2, one new Context `issue #824 cycle 2 - whole-token order-independent classification`, acting through `Test-CommandLineRawInvocation`: `It 'R824-P<Id> classifies <Label>'` asserting `$true` with rows (Id / Label / RawText / CommandWord / SubcommandPath): 26 / `every word named in another order` / `pwsh -c 'Write-Output "create an issue with gh"'` / gh / issue,create; 27 / `a positional-parameter list after the command word` / `bash -c 'gh "$@"' _ issue create` / gh / issue,create; 28 / `a special-parameter expansion after the command word` / `bash -c 'gh $*' _ issue create` / gh / issue,create; 29 / `an xargs-led command word` / `bash -c 'echo issue create | xargs gh'` / gh / issue,create; 30 / `numbered positional parameters` / `bash -c 'gh $1 $2' _ issue create` / gh / issue,create. `It 'R824-N<Id> rejects <Label>'` asserting `$false`: 11 / `a positional-parameter list whose trailing words name another subcommand` / `bash -c 'gh "$@"' _ pr list` / gh / issue,create; 12 / `an xargs-led command word with one subcommand word absent` / `echo issue | xargs gh` / gh / issue,create. Row 26 pins the accepted trade recorded in spec `## Risks & Mitigations`.
  - S1 (through `Get-PromotionTriggerScopingDecision`) and S2 (through `Get-CodexPromotionTriggerScopingDecision`), one new Context `issue #824 cycle 2 - review pass 2 bypass forms`: `It 'P824-D<Id> denies <Label>'` with Label equal to Command, rows 16 `bash -c 'gh "$@"' _ issue create`, 17 `bash -c 'gh $*' _ issue create`, 18 `bash -c 'echo issue create | xargs gh'`, 19 `bash -c 'gh $1 $2' _ issue create`, each asserting `permissionDecision` is `deny` and `permissionDecisionReason` equals `Get-PromotionMcpOnlyGhIssueBlockedReason`.
  - S6, S7, and S8, two new Contexts. In S6 and S7 the mocks follow the file's existing addendum Contexts (S6: `Get-EpicWorktreeGateCheckpointContent` and `Get-EpicWorktreeGateParallelCheckpointContent`; S7: `Get-ParallelWorktreeRemovalGateCheckpointContent` and `Get-ParallelWorktreeRemovalGateEpicCheckpointContent`), with the unrelated record (item-b-102) in the first Context and the authorizing record (item-a-101) in the second; decisions act through `Invoke-EpicWorktreeRemovalGateDecision` or `Invoke-ParallelWorktreeRemovalGateDecision` with `ConvertTo-CommandEnvelope`, and deny rows assert `deny` and a reason matching `^EPIC_WORKTREE_REMOVAL_BLOCKED` or `^PARALLEL_WORKTREE_REMOVAL_BLOCKED`. In S8, decisions act through `Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $Command)` with `-EpicCheckpointRaw $script:UnrelatedCheckpoint` in the first Context and, in the second, `$script:AuthorizingCheckpoint` assigned in that Context's own `BeforeAll` as `@{ features = @(@{ worktree_path = $script:TargetPath; merge_status = 'merged' }) } | ConvertTo-Json -Compress -Depth 4`; deny rows assert `deny` and `^EPIC_WORKTREE_REMOVAL_BLOCKED`.
    - Context `issue #824 cycle 2 - review pass 2 removal forms without an authorizing record`: `It 'A824-X<Id> denies <Label> without an authorizing record'` with Label equal to Command and the seven AC-14 strings verbatim: 1 `bash -c 'echo /repo/worktrees/item-a-101 | xargs git worktree remove'`; 2 `echo /repo/worktrees/item-a-101 | xargs git worktree remove`; 3 `pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'`; 4 `bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101'`; 7 `pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)'`; 8 `bash -c 'printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force'`; 10 `bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101'`. Then `It 'A824-WT10 denies a wrapped removal whose operand is an expansion without an authorizing record'` with `bash -c 'git worktree remove "$target"'`.
    - Context `issue #824 cycle 2 - non-literal operand outcomes with an authorizing record`: `It 'A824-WT11-<Id> denies <Label> even with an authorizing record'` with Label equal to Command: 1 `pwsh -NoProfile -Command 'git worktree remove'`; 2 `bash -c 'git worktree remove "$target"'`.
- D7 - Setup script (AC-42). Three Edit calls on SETUP, in this order, then BATS and FIXTURE from the Appendix:
  - Lines 4 to 16 (from `SCRIPT_DIR="$(cd ...` through the `SOLUTION_FILE="$(find ...` line) become:

    ```text
    # Print the repository root. Codex Web copies this script to /tmp before running it, so
    # the script-relative root can resolve to / rather than the actual checkout. The checkout
    # is recognized by a solution file at its root; the solution name is not assumed. When the
    # script-relative root lists no solution file, fall back to the working directory, which
    # Codex sets to the repo root.
    # Args: $1 = script-relative root; $2 = solution file names at that root, one per line.
    resolve_repo_root() {
      if [ -n "$2" ]; then
        printf '%s\n' "$1"
      else
        pwd
      fi
    }

    # Print the first solution file name in LC_ALL=C order, or nothing when none is listed.
    # Args: $1 = solution file names, one per line.
    select_solution_file() {
      if [ -n "$1" ]; then
        printf '%s\n' "$1" | LC_ALL=C sort | sed -n '1p'
      fi
    }

    # Print the names of the solution files at the root of a directory, one per line.
    # Args: $1 = directory.
    list_root_solution_files() {
      find "$1" -maxdepth 1 -type f -name '*.sln' -printf '%f\n' 2>/dev/null
    }

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SCRIPT_RELATIVE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    REPO_ROOT="$(resolve_repo_root "${SCRIPT_RELATIVE_ROOT}" "$(list_root_solution_files "${SCRIPT_RELATIVE_ROOT}")")"
    SOLUTION_FILE="$(select_solution_file "$(list_root_solution_files "${REPO_ROOT}")")"
    ```

  - The last line `main "$@"` becomes the guard line of `.github/codex/codex-web-setup.sh` line 332, copied exactly: `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi`.
  - In `verify_windows_visual_studio_task_capability`, the 11 lines from `  pwsh -NoProfile -ExecutionPolicy Bypass -Command "& {` through `  }" >/dev/null || fail "Visual Studio test tooling required by the MSTest tasks is unavailable."` (BASE_SHA lines 297-307; the Edit matches on this text, because the first edit shifts line numbers) become these 3 lines:

    ```text
      local vswhere_check="\$vswherePath = Join-Path \${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'; if (-not (Test-Path \$vswherePath)) { throw 'vswhere.exe was not found. Install Visual Studio 2022 (or Build Tools) with Test Platform components.' }"
      local vstest_check="\$vstestPath = & \$vswherePath -latest -products * -find 'Common7\IDE\Extensions\TestPlatform\vstest.console.exe' | Select-Object -First 1; if (-not \$vstestPath) { throw 'vstest.console.exe not found via vswhere. Install Visual Studio Test Platform components.' }"
      pwsh -NoProfile -ExecutionPolicy Bypass -Command "& { ${vswhere_check}; ${vstest_check} }" >/dev/null || fail "Visual Studio test tooling required by the MSTest tasks is unavailable."
    ```

    The block above is indented by four extra spaces for this list; in SETUP each line starts with two spaces. Reason: kcov counts the lines inside a multi-line string as executable and never reports them hit (D13 instrumentation evidence), so the multi-line `-Command` string would hold the function below the AC-42 threshold. The PowerShell text pwsh receives is unchanged apart from line breaks becoming `; ` separators: inside bash double quotes `\$` yields `$`, `\${` yields `${`, a backslash before any other character is kept, and `*` is not globbed. The failure message and the function name are unchanged, so B1 cases C824-12 to C824-14 and the P5-T2 message list are unaffected. No line of the result opens a `"& {` string at its end.
  - The file grows by 11 lines (394 at planning time, so 405): +19 from the first edit (13 lines become 32), 0 from the second (1 line becomes 1), and -8 from the third (11 lines become 3). Indentation follows the file's existing two-space style. `sed -n '1p'` reads its whole input, so `sort` cannot receive SIGPIPE under `set -o pipefail`. `resolve_repo_root` keeps the previous fallback rule (script-relative root when it holds a solution file, otherwise the working directory); its input is now the file list rather than `compgen -G`, so a directory named `*.sln` no longer counts as a solution.
  - Changed functions whose lines BATS drives (each function with a line changed by this issue): `resolve_repo_root`, `select_solution_file`, `list_root_solution_files` (new), `restore_packages_if_needed` and `verify_windows_visual_studio_task_capability` (cycle 1 lines 268-271 and 294-295, plus the three lines of the third edit, which C824-13 reaches because its `pwsh` stub returns 0 for both calls), and `write_repo_notes` (cycle 1 heredoc lines 350-352). BATS cases C824-1 to C824-15 cover every executable line of these functions, including the populated-packages and nuget-unavailable branches, so the AC-42 per-function threshold is reachable in the D13 kcov run.
  - B1 resolves `SCRIPT_UNDER_TEST` to a canonical absolute path (`"$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"`) rather than the cycle-1 form `${BATS_TEST_DIRNAME}/../../.codex/codex-web-setup.sh`. The path bash reports for the sourced file is then exactly `${GITHUB_WORKSPACE}/.codex/codex-web-setup.sh` in CI, which is the D13 `--include-pattern`; the unnormalized form would carry a `/tests/shell/../..` segment that the include pattern does not contain.
  - BATS uses no temporary file: discovery is driven through functions that take their candidates as arguments; the only directories read are `tests/shell` and FIXTURE's parent; `nuget` and `pwsh` are replaced by shell functions that print to stderr. FIXTURE lives in a new directory that no suite enumerates (planning-time Grep found no enumeration of `tests/fixtures/codex_web_setup`), and `.gitignore` has no entry matching it.
- D8 - Shell QC route and decision Q1. `.claude/rules/shell.md` runs shfmt, shellcheck, bats, and kcov natively through `scripts/bash/shell-qc.sh`, "On Windows, ... under WSL", and in CI in `.github/workflows/_shell-coverage.yml` job `shell-coverage` named `Shell Coverage (Bats + kcov)`, called from `.github/workflows/ci.yml` line 26 (PR check name `shell-coverage / Shell Coverage (Bats + kcov)`). The executor has no `bash`, `bats`, `kcov`, or `wsl` permission, and the repository provides no PowerShell wrapper for bats or kcov (planning-time Grep of `*.ps1` for `bats|kcov`: no files). Local shell evidence is therefore limited to `sh -n` on both setup copies (Git for Windows `sh`, as in cycle 1), byte identity, line counts, and static traceability between BATS and SETUP (P5-T2, P7-T9). The bats pass is CI-dependent: the job runs `bash scripts/bash/shell-qc.sh test --coverage`, which runs every bats file under `tests/shell`, so BATS runs on the PR head. The existing kcov run cannot produce the changed-line measurement: `scripts/bash/shell_qc_lib.sh` line 350 sets `--include-pattern` to `tools`, `scripts`, `.claude/lib/bash`, and `.claude/skills` only, so its coverage report never contains SETUP, and shfmt and shellcheck do not discover `.codex/` or `.bats` files (`.claude/rules/shell.md` lines 48-55). Decision Q1 was resolved by the orchestrator as option (a): a dedicated, scoped kcov measurement in CI, without changing the discovery or include roots. D13 records the design. This plan does not check AC-42 off; P9-T4 records the exact S9 condition.
- D9 - Expected test arithmetic (re-derived from the current files). Issue824-tagged tests today: S1 19, S2 19, S6 17, S7 17, S8 17, U1 51, U2 51. Added: S1 and S2 4 each; S6, S7, and S8 10 each; U1 and U2 7 each (52 new). Failing before the fix, by planning-time trace against the unfixed tree:
  - S1/S2 rows 16 to 19: the cycle-1 sequence grammar has no expansion for `$@`, `$*`, or `$1`, and `xargs gh` has no word after `gh`, so R2 does not classify and the hook allows (4 + 4).
  - S6/S7/S8 `A824-X1` to `A824-X10` (7 each): the reader returns `NoOperand` (the token after `remove` is empty at `'`, end of text, `(`, `>`, or `<`, or follows a skipped `--force`), and the gates allow on `NoOperand` (21). `A824-WT6` after its D5 edit (3) and `A824-WT11-1` (3) fail for the same reason.
  - U1/U2 `R824-P26` to `R824-P30` (5 + 5): no sequence or absorption match exists.
  - Passing before the fix: every existing Issue824 test except `A824-WT6`; `R824-N11`, `R824-N12` (no classification either way); `A824-WT10` and `A824-WT11-2` (the reader returns `Indeterminate` for `"$target"`, so the gates deny today).
  - Totals: failed 4 + 4 + 21 + 3 + 3 + 10 = 45; passed (19 + 19 + 16 x 3 + 51 x 2) + (2 x 2 + 2 x 3) = 188 + 10 = 198; all 243 pass after the fix. U1 and U2 each total 58.
  - GT (15 tests) and WT (6 tests) are outside ISSUE824-PATHS, so they do not enter the P1-T10 or P7-T1 arithmetic; P5-T5 and P5-T8 count them, and the P8-T3 floor adds them (52 + 21 = 73 new Pester tests in the full run).
- D10 - Orphaned-contract ownership table:

  | Contract | Location | Owning task |
  |---|---|---|
  | Every repo `.claude/**` file byte-identical in the Claude bundle | `test_push_down_claude_resource_contracts.py` | P6-T1 (copy), P6-T2 and P8-T8 (verify) |
  | Codex bundle identity and manifest closure | `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_core_manifest_closure.py` | P6-T1; no file is added to or removed from either hooks root, so no manifest changes |
  | `.claude`/`.codex` identity of the raw and invocation modules (AC-23) | file hashes | P2-T3, P4-T2, P7-T7 |
  | Codex shared-module list, 500-line cap | LEGACY lines 22 and 30 | P7-T8 (unchanged) |
  | Every `.codex/hooks/*.ps1` within 500 lines | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | P8-T15 |
  | AC-17 call-site inventory (37 call expressions in 13 files) | FEATURE/evidence/other/containment-path-hook-audit.md | P7-T6 (re-derive, cycle 2 addendum) |
  | No hard-coded solution name on pushed surfaces | PYG `SOLUTION_SURFACES` includes SETUP and its bundle copy | P6-T2 |
  | Coverage population | `config/poshqc-coverage.json` folder roots include both hooks roots and `scripts` (line 8), so GATE is in the denominator | none needed; P8-T4 records per-file values for COV-TARGETS-FINAL |
  | Shell coverage population | `scripts/bash/shell_qc_lib.sh` line 350 | not changed (decision Q1 constraint); SETUP is measured by the dedicated D13 step instead |
  | Existing shell-coverage steps, their order, and the existing artifact path `artifacts/pester/kcov/**` | WT tests W824-1 and W824-2 | P5-T7, P5-T8, P8-T3 |
  | Gate step names exactly the six changed functions, each defined once in SETUP | WT test W824-5 | P5-T7, P5-T8, P8-T3 |
  | Every `.github/**/*.yml` scanned for npm-token misuse | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (enumerates every workflow file) | P8-T8; D13 adds no token, secret, or `npm` command |
  | Pester discovery of the two new suites | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 3 (`tests/scripts` root) | P8-T3 (`tests=` floor includes the 21 new tests) |
- D11 - SCOPE-PATHS (31). Tracked and modified (26): CLAUDE-RAW, CODEX-RAW, CB + `.claude/hooks/hook-command-raw-invocation.ps1`, XB + `.codex/hooks/hook-command-raw-invocation.ps1`, CLAUDE-INV, CODEX-INV, CB + `.claude/hooks/hook-command-invocation.ps1`, XB + `.codex/hooks/hook-command-invocation.ps1`, EPIC-GATE, PAR-GATE, CODEX-GATE and their three bundle copies, SETUP and XB + `.codex/codex-web-setup.sh`, S1, S2, S3, S3X, S6, S7, S8, U1, U2, WORKFLOW. New (5): BATS, FIXTURE, GATE, GT, WT.
- D12 - Tier. `.claude/hooks` and `.codex/hooks` are T3 (`quality-tiers.yml`). Uniform 85% line coverage applies; no property-test or mutation obligation applies. SETUP is T4 scaffolding; the 85% line threshold applies to the changed functions per AC-42. GATE is under `scripts/dev-tools`, which `quality-tiers.yml` lines 19-21 classify as T4, so no tier entry is added; the uniform 85% line threshold applies to it (P8-T4), and PowerShell has no branch-coverage gate.
- D13 - Decision Q1 design: dedicated CI kcov measurement and gate for SETUP (orchestrator option (a)).
  - Choice: the gate logic is a script, not inline workflow text. It must locate six function bodies in SETUP, read per-line hits from a Cobertura report, parse zero-context diff hunks, apply an 85% per-function threshold, and fail closed on a missing class, a missing function, or a function with no instrumented line. That is not trivial, so it is GATE, a PowerShell file of pure functions under `scripts/dev-tools` with its own Pester suite GT, rather than a bash script with bats tests. Reason: GATE's tests and coverage can run on this host before CI (P5-T5, P8-T1 to P8-T4), PoshQC format and analyze cover it, and `config/poshqc-coverage.json` measures it in the `poshqc / PowerShell QC` job; a bash gate would be verifiable here only by `sh -n`, and its own kcov figure would come from the existing run, which has no threshold. Precedent: `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` (pure functions, dot-sourced) is called from `.github/workflows/verify-published-releases.yml` line 39 and tested by dot-sourcing in `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1`. This is a deliberate departure from the orchestrator's suggested "bats tests" form for a non-trivial gate, recorded for the caller. GATE defines functions only (no entry block), so every executable line is reachable from GT and A1's new-file rule (every line changed) can be met.
  - Workflow change (W1, one Edit call; the job, its triggers, and its eight existing steps (including the existing upload) are unchanged and keep their order; no new action reference, no secret, no permission change). W1 appends three steps after the existing `Upload shell coverage artifacts` step, whose last two lines are the last two lines of WORKFLOW (lines 61-62): Measure, then the new upload, then Gate. The new upload precedes Gate so that the measurement artifact is already uploaded when Gate fails. Step `Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)` (`shell: bash`, so `-eo pipefail` applies) reuses the kcov and bats the job already installed, runs only BATS under kcov with `--include-pattern=${GITHUB_WORKSPACE}/.codex/codex-web-setup.sh` and no exclude pattern, merges the single run exactly as `run_test_coverage` does (`shell_qc_lib.sh` lines 376-384, giving `kcov-merged/cov.xml`), fails if that file is absent, and, when `BASE_SHA` (`github.event.pull_request.base.sha`, passed through `env:` rather than interpolated into the script) is non-empty, fetches that one commit at depth 1 with the token `actions/checkout` persisted and writes `git diff --unified=0 BASE_SHA HEAD -- .codex/codex-web-setup.sh`. Step `Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)` (`shell: pwsh`) dot-sources GATE and exits with `Invoke-KcovFunctionCoverageGate`'s exit code for the six functions of D7 at `-Threshold 85`; it fails when any function is below 85%, has no instrumented line, or is absent, or when any added line that kcov instrumented has zero hits. Step `Upload .codex/codex-web-setup.sh coverage artifacts (issue 824)` reuses `actions/upload-artifact@v7` with `if-no-files-found: error` and artifact name `shell-coverage-codex-web-setup`.
  - Upload condition: the new upload step carries no `if:` key, so it runs under the default `success()` condition, as the existing upload step does. Reasons: (1) the case that needs the artifact for diagnosis is a Gate failure, and the upload already runs before Gate whenever Measure succeeded; (2) under `if: always()` or `if: ${{ !cancelled() }}`, a failure in any earlier step (for example the existing `Run shell-qc test with coverage` step, which skips Measure) would run the upload against a missing directory, and `if-no-files-found: error` would add a second failing step that reports nothing about the cause; (3) conditioning on Measure's own outcome needs an `id:` on the Measure step, which this revision keeps unchanged. When Measure fails, its step log carries the bats and kcov output. WT therefore does not assert an `if:` key, and W824-1 to W824-6 are unchanged apart from the W824-1 order.
  - Output isolation: the new output directory is `artifacts/pester/kcov-codex-web-setup`. The existing step's `rm -rf "$out_dir"` (`shell_qc_lib.sh` line 344) deletes only `artifacts/pester/kcov` (line 338 default), and it runs before the new steps; the existing upload step (WORKFLOW lines 57-62, glob `artifacts/pester/kcov/**` on line 61) completes before Measure creates the sibling directory, and its glob does not match that directory, so the existing artifact and the existing merged report are unaffected.
  - Changed lines: on a `pull_request` run the diff is the PR's change to SETUP (the checkout is the merge commit and BASE_SHA is the base), which covers cycle 0 to cycle 2 edits including the top-level discovery lines and the guard. On `push` and `workflow_dispatch` runs `BASE_SHA` is empty, GATE prints `CHANGED-LINES=NOT-CHECKED`, and only the per-function threshold applies; such a run does not satisfy AC-42 (P9-T4).
  - Local validation of WORKFLOW (CI is canonical, S9 provides the green run on the branch head): YAML-CHECK parses it with PyYAML from the project environment (`pyproject.toml` line 19) and reads the step list (P0-T24, P5-T6, P8-T13); WT pins the step order, the restricted include pattern, the separate output directory, the threshold, and the six function names against SETUP (P5-T8, P8-T3); `actionlint` runs only if already on PATH (P0-T24 baseline, P8-T13; `.github/instructions/github-actions.instructions.md` names `scripts/dev-tools/run-actionlint.ps1` and a CI job `actionlint` in `ci.yml`, but planning-time Grep of `.github/workflows` found no `actionlint` job, and the script downloads into the tree).
  - Instrumentation evidence and known-risk rule. kcov's bash parser decides which lines are instrumented. Evidence from CI run 37128678013 (artifact `shell-coverage`): kcov counted lines 112-123 of `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`, which lie inside a multi-line single-quoted string, as executable with 0 hits, and counted no heredoc body or terminator line. Consequences: the heredoc body and terminator of `write_repo_notes` (BASE_SHA lines 332-358, after the `cat <<'EOF'` line 331) are not counted, and the multi-line `-Command` string in `verify_windows_visual_studio_task_capability` (BASE_SHA lines 297-307), whose inner lines would be counted and never hit, is removed by D7's third edit; P5-T1 confirms that no line of SETUP still ends with an opening `"& {`. Not mitigated by weakening the gate: if the Gate step still fails at S9, the S9 response is to stop and report the `FUNCTION` and `CHANGED-LINES` lines to the caller; the threshold, the function list, and the include pattern are not changed to pass.
  - W1, one Edit call on WORKFLOW. `old_string` is the two lines `          path: artifacts/pester/kcov/**` and `          if-no-files-found: error` (WORKFLOW lines 61-62, the last two lines of the file; the first of them occurs once in the file, so the match is unique). `new_string` is those two lines followed by the 35 lines below: an empty line, the Measure step (17 lines), an empty line, the new upload step (6 lines), an empty line, and the Gate step (9 lines). The last new line is `exit $report.ExitCode`; the file's existing final newline follows it, so no trailing empty line is added.

    ```yaml

          - name: Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)
            # .codex/ is outside the shell-QC kcov include roots, so this step runs only the
            # setup script's bats file under kcov with the include pattern restricted to it.
            # Pull requests also record the script's zero-context diff against the base commit.
            shell: bash
            env:
              BASE_SHA: ${{ github.event.pull_request.base.sha }}
            run: |
              out_dir="artifacts/pester/kcov-codex-web-setup"
              mkdir -p "${out_dir}"
              kcov "--include-pattern=${GITHUB_WORKSPACE}/.codex/codex-web-setup.sh" "${out_dir}/run" "$(command -v bats)" tests/shell/test_codex_web_setup_codex_copy.bats
              kcov --merge "${out_dir}/merged" "${out_dir}/run"
              test -f "${out_dir}/merged/kcov-merged/cov.xml"
              if [[ -n "${BASE_SHA}" ]]; then
                git fetch --no-tags --depth=1 origin "${BASE_SHA}"
                git diff --unified=0 "${BASE_SHA}" HEAD -- .codex/codex-web-setup.sh >"${out_dir}/changed-lines.diff"
              fi

          - name: Upload .codex/codex-web-setup.sh coverage artifacts (issue 824)
            uses: actions/upload-artifact@v7
            with:
              name: shell-coverage-codex-web-setup
              path: artifacts/pester/kcov-codex-web-setup/**
              if-no-files-found: error

          - name: Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)
            shell: pwsh
            run: |
              . ./scripts/dev-tools/KcovFunctionCoverageGate.ps1
              $diffPath = 'artifacts/pester/kcov-codex-web-setup/changed-lines.diff'
              if (-not (Test-Path -LiteralPath $diffPath)) { $diffPath = '' }
              $report = Invoke-KcovFunctionCoverageGate -CoberturaPath 'artifacts/pester/kcov-codex-web-setup/merged/kcov-merged/cov.xml' -SourcePath '.codex/codex-web-setup.sh' -DiffPath $diffPath -Function @('resolve_repo_root', 'select_solution_file', 'list_root_solution_files', 'restore_packages_if_needed', 'verify_windows_visual_studio_task_capability', 'write_repo_notes') -Threshold 85
              $report.Message
              exit $report.ExitCode
    ```

    The block above is indented by four extra spaces for this list; in WORKFLOW, `- name:` starts in column 7 (six spaces), step keys in column 9, and `run:` and `with:` bodies in column 11, matching the existing steps. Step names contain no `#`, because ` #` would start a YAML comment.
  - Result: WORKFLOW gains 35 lines and loses none (BASE_SHA-anchored numstat `35	0`), and its step count goes from 8 to 11 in this order: the eight existing steps unchanged (through `Upload shell coverage artifacts`), then the Measure step, then the new upload step, then the Gate step. Planning-time WORKFLOW line count: 62, so 97 after the edit.

### Phase 0 — Remediation Baseline: Policy Reads, Environment, and Toolchain Baselines

- [x] [P0-T1] Verify the full-bug preconditions and the AC state, and record FEATURE/evidence/remediation-baseline/r2-mode-check.TS.md.
      Commands: `$c = @((Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/issue.md -SimpleMatch -Pattern 'Work Mode: full-bug').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^## (Acceptance Criteria|Scope Extension)$').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[x\] AC-\d+:').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[ \] AC-\d+:').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-inputs.2026-10-03T13-56.md -SimpleMatch -Pattern 'Review-Verdict: REMEDIATION_REQUIRED').Count, (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -SimpleMatch -Pattern '- **Version:** 0.3').Count); "COUNTS=$($c -join ',')"`; `$open = @(Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[ \] (AC-\d+):' | ForEach-Object { $_.Matches[0].Groups[1].Value }); "OPEN=$($open -join ',')"`; VERDICT(`($c -join ',') -eq '1,2,39,4,1,1' -and ($open -join ',') -eq 'AC-14,AC-27,AC-42,AC-43'`).
      Acceptance: EXIT_CODE 0, `COUNTS=1,2,39,4,1,1`, and `OPEN=AC-14,AC-27,AC-42,AC-43`. Any other value exits 1 and stops the plan.
- [x] [P0-T2] Read the policy files in order and record FEATURE/evidence/remediation-baseline/r2-phase0-instructions-read.TS.md with `Timestamp:`, `Policy Order:`, and the files read, in this order: (1) `CLAUDE.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/quality-tiers.md`; (5) `.claude/rules/powershell.md`; (6) `.claude/rules/shell.md` (a `.sh` and a `.bats` file change); (7) `.claude/rules/python.md` and (8) `.claude/rules/python-suppressions.md` (the Python toolchain runs in final QC); (9) `.claude/rules/typescript.md` (the TypeScript toolchain runs in final QC); (10) `.claude/rules/tonality.md`; (11) `.claude/rules/plan-acceptance-gates.md`; (12) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; (13) `.github/instructions/github-actions.instructions.md` and (14) `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` (WORKFLOW changes, D13). The artifact states that `.claude/rules/csharp.md` is not read because no C# file or C# policy file changes.
      Its `Timestamp:` is the `TS=` value printed by a step script containing only A0 (SCRATCH/steps/r2-p0-t2.ps1).
      Acceptance: the artifact has the three headers, lists all 14 files above in that order, and carries the not-read statement.
- [x] [P0-T3] Record BASE_SHA, the branch, the code identity with the reviewed cycle-1 head, the pre-existing untracked list, and the clean pre-edit state of every edited directory; record FEATURE/evidence/remediation-baseline/r2-base-sha.TS.md.
      Commands: `$branch = git branch --show-current; $branch`; `$head = git rev-parse HEAD; $head`; `git merge-base --is-ancestor c7b78cd2 HEAD; $ancestorExit = $LASTEXITCODE; "ANCESTOR-EXIT=$ancestorExit"`; `git diff --quiet c7b78cd2 HEAD -- .claude/hooks .codex extensions/drm-copilot/resources tests scripts; $cycleOneDiff = $LASTEXITCODE; "CYCLE1-CODE-DIFF-EXIT=$cycleOneDiff"`; `Set-Content -LiteralPath "$Scratch/pre-untracked.txt" -Value @(git ls-files --others --exclude-standard -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory')`; `"PRE-UNTRACKED-COUNT=$(@(Get-Content -LiteralPath "$Scratch/pre-untracked.txt").Count)"`; `$status = @(git status --porcelain --untracked-files=all -- .claude/hooks .codex/hooks .codex/codex-web-setup.sh extensions/drm-copilot/resources tests/scripts/claude-hooks tests/scripts/codex-hooks tests/shell tests/fixtures/codex_web_setup .github/workflows/_shell-coverage.yml scripts/dev-tools tests/scripts/dev-tools tests/scripts/workflows); $status; "STATUS-LINES=$($status.Count)"`; VERDICT(`$branch -eq 'bug/promotion-hook-raw-containment-false-positive-deny-824' -and "$head" -match '^[0-9a-f]{40}$' -and $ancestorExit -eq 0 -and $cycleOneDiff -eq 0 -and $status.Count -eq 0`).
      Acceptance: EXIT_CODE 0; the branch is `bug/promotion-hook-raw-containment-false-positive-deny-824`; one 40-character SHA, recorded as BASE_SHA (the caller reported `9dbceb3a`; BASE_SHA is taken only from this output); `ANCESTOR-EXIT=0`; `CYCLE1-CODE-DIFF-EXIT=0` (the code under test equals the cycle-1 head `c7b78cd2` that review pass 2 examined, so the P1-T10 fail-before run is a run against that head); `PRE-UNTRACKED-COUNT=` recorded with every listed path; `STATUS-LINES=0`. Any other value exits 1 and stops the plan.
- [x] [P0-T4] Write A1 to A5 verbatim from the Appendix into SCRATCH with the Write tool, hash them, and record FEATURE/evidence/remediation-baseline/r2-scratch-scripts.TS.md.
      Commands: `$hashes = @(Get-FileHash -Algorithm SHA256 -ErrorAction Stop -LiteralPath "$Scratch/cov-derive.ps1", "$Scratch/issue824-pester.ps1", "$Scratch/resolver-ast-check.ps1", "$Scratch/phrase-scan.ps1", "$Scratch/raw-predicate-ast-check.ps1" | ForEach-Object { $_.Hash }); $hashes`; VERDICT(`$hashes.Count -eq 5`).
      Acceptance: EXIT_CODE 0 and five hash lines, recorded with the SCRATCH token. A missing script raises a terminating error, so the step script exits 1.
- [x] [P0-T5] Baseline the line count of every existing file this plan edits and record FEATURE/evidence/remediation-baseline/r2-line-counts.TS.md.
      Commands: `$n = @{}; foreach ($f in @('.claude/hooks/hook-command-raw-invocation.ps1', '.claude/hooks/hook-command-invocation.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1', '.codex/codex-web-setup.sh', 'tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1', '.github/workflows/_shell-coverage.yml')) { $n[$f] = @(Get-Content -LiteralPath $f -ErrorAction Stop).Count; "$f $($n[$f])" }`; VERDICT(`$n.Count -eq 17 -and $n['.claude/hooks/hook-command-invocation.ps1'] -le 496 -and $n['.codex/codex-web-setup.sh'] -le 470 -and $n['.claude/hooks/hook-command-raw-invocation.ps1'] -le 310`).
      Acceptance: EXIT_CODE 0; every count is printed and recorded as that file's P0 count. Planning-time values, for comparison only: CLAUDE-RAW 298, CLAUDE-INV 491, EPIC-GATE 464, PAR-GATE 481, CODEX-GATE 184, SETUP 394, S1 292, S2 278, S3 347, S3X 284, S6 259, S7 239, S8 242, U1 159, U2 159, LEGACY 497, WORKFLOW 62. A P0 count above 496 for CLAUDE-INV, above 470 for SETUP, or above 310 for CLAUDE-RAW exits 1 and stops the plan, because the D4, D7, and D2 budgets would no longer fit.
- [x] [P0-T6] Baseline byte identity of every mirror pair and record FEATURE/evidence/remediation-baseline/r2-identity.TS.md.
      Commands: IDENTITY-LOOP; VERDICT(`$pairs.Count -eq 10 -and $unequal -eq 0`).
      Acceptance: EXIT_CODE 0; ten lines ending `EQUAL=True`; `PAIRS=10 UNEQUAL=0`. Any `EQUAL=False` exits 1 and stops the plan, because P2-T3, P4-T2, and P6-T1 replace each copy with a copy of its source and would discard a real difference.
- [x] [P0-T7] Baseline the inventories this plan changes and record FEATURE/evidence/remediation-baseline/r2-inventory.TS.md.
      Commands: (1) `$callSites = (Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '").Count; $callFiles = @(Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '" | Select-Object -ExpandProperty Path -Unique).Count; "CALL-SITES=$callSites CALL-FILES=$callFiles"`; (2) `$containment = @(Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern 'Test-CommandLineRawContainment' | ForEach-Object { "$($_.Filename):$($_.LineNumber)" }); $containment`; (3) `& "$Scratch/phrase-scan.ps1" -Root @('.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources'); $scanExit = $LASTEXITCODE; "PHRASE-SCAN-EXIT=$scanExit"`; (4) `$count = { param([string] $File, [string] $Token) (Select-String -LiteralPath $File -SimpleMatch -Pattern $Token).Count }; $counts = @((& $count .claude/hooks/hook-command-invocation.ps1 'whole tokens'), (& $count .claude/hooks/hook-command-invocation.ps1 'ordered sequence'), (& $count .claude/hooks/hook-command-raw-invocation.ps1 'ordered sequence'), (& $count .claude/hooks/hook-command-raw-invocation.ps1 '.exe)?'), (& $count .claude/hooks/enforce-epic-worktree-removal-gate.ps1 'NoOperand'), (& $count .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 'NoOperand'), (& $count .codex/hooks/enforce-epic-worktree-removal-gate.ps1 'NoOperand'), (& $count .codex/codex-web-setup.sh 'resolve_repo_root')); "COUNTS=$($counts -join ',')"`; (5) `$setupLast = @(Get-Content -LiteralPath .codex/codex-web-setup.sh)[-1]; $guard = @(Select-String -LiteralPath .github/codex/codex-web-setup.sh -SimpleMatch -Pattern 'then main' | ForEach-Object { $_.Line }); $lastIsGuard = $guard.Count -eq 1 -and $setupLast -ceq $guard[0]; "GUARD-LINES=$($guard.Count) SETUP-LAST-IS-GUARD=$lastIsGuard"`; (6) `$include = @(Select-String -LiteralPath scripts/bash/shell_qc_lib.sh -SimpleMatch -Pattern 'local include_pattern=' | ForEach-Object { $_.Line }); $includeHasCodex = "$include" -like '*.codex*'; "INCLUDE-LINES=$($include.Count) INCLUDE-HAS-CODEX=$includeHasCodex"`; (7) `$wfSteps = (Select-String -LiteralPath .github/workflows/_shell-coverage.yml -CaseSensitive -Pattern '^ {6}- name:').Count; $wfNew = (Select-String -LiteralPath .github/workflows/_shell-coverage.yml -SimpleMatch -Pattern 'kcov-codex-web-setup').Count; $wfUpload = (Select-String -LiteralPath .github/workflows/_shell-coverage.yml -SimpleMatch -Pattern 'path: artifacts/pester/kcov/**').Count; $gateExists = Test-Path -LiteralPath scripts/dev-tools/KcovFunctionCoverageGate.ps1; "WORKFLOW-STEPS=$wfSteps WORKFLOW-NEW-TOKENS=$wfNew EXISTING-UPLOAD-PATH=$wfUpload GATE-EXISTS=$gateExists"`; (8) `$outDefault = (Select-String -LiteralPath scripts/bash/shell_qc_lib.sh -SimpleMatch -Pattern 'local out_dir=${SHELL_QC_KCOV_OUT_DIR:-artifacts/pester/kcov}').Count; $rmOut = (Select-String -LiteralPath scripts/bash/shell_qc_lib.sh -SimpleMatch -Pattern 'rm -rf "$out_dir"').Count; "OUT-DIR-DEFAULT=$outDefault RM-OUT-DIR=$rmOut"`; VERDICT(`$callSites -eq 37 -and $callFiles -eq 13 -and $containment.Count -eq 4 -and $scanExit -eq 0 -and ($counts -join ',') -eq '0,1,2,2,1,1,1,0' -and $guard.Count -eq 1 -and -not $lastIsGuard -and $include.Count -eq 1 -and -not $includeHasCodex -and $wfSteps -eq 8 -and $wfNew -eq 0 -and $wfUpload -eq 1 -and -not $gateExists -and $outDefault -eq 1 -and $rmOut -eq 1`).
      Acceptance: EXIT_CODE 0; `CALL-SITES=37 CALL-FILES=13`; exactly four containment locations, `hook-command-invocation.ps1:94` (definition) and `hook-command-invocation.ps1:490` (the `Test-CommandLineMention` caller) once per hooks root; `FILES-SCANNED=` recorded, `HITS=0`, `PHRASE-SCAN-EXIT=0`; `COUNTS=0,1,2,2,1,1,1,0` (CLAUDE-INV `whole tokens` 0 and `ordered sequence` 1; CLAUDE-RAW `ordered sequence` 2 and `.exe)?` 2; one `NoOperand` per gate; no `resolve_repo_root` in SETUP); `GUARD-LINES=1 SETUP-LAST-IS-GUARD=False`; `INCLUDE-LINES=1 INCLUDE-HAS-CODEX=False` (the D8 fact behind decision Q1); `WORKFLOW-STEPS=8 WORKFLOW-NEW-TOKENS=0 EXISTING-UPLOAD-PATH=1 GATE-EXISTS=False`; `OUT-DIR-DEFAULT=1 RM-OUT-DIR=1` (the existing step deletes only its own `artifacts/pester/kcov` directory, D13). Any other value exits 1 and stops the plan. The `$` characters in the item (8) tokens are literal because the tokens are single-quoted.
- [x] [P0-T8] Record tool versions and record FEATURE/evidence/remediation-baseline/r2-tool-versions.TS.md.
      Commands: `pwsh -NoProfile -Command 'Get-Module -ListAvailable -Name Pester, PSScriptAnalyzer | Sort-Object Name, Version -Descending | ForEach-Object { "$($_.Name) $($_.Version)" }; $PSVersionTable.PSVersion.ToString()'`; `$pesterMajor = [int](pwsh -NoProfile -Command '@(Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending)[0].Version.Major'); "PESTER-MAJOR=$pesterMajor"`; `$analyzerCount = [int](pwsh -NoProfile -Command '@(Get-Module -ListAvailable -Name PSScriptAnalyzer).Count'); "PSSCRIPTANALYZER-VERSIONS=$analyzerCount"`; `"STEP-PWSH-MAJOR=$($PSVersionTable.PSVersion.Major)"`; `poetry --version; $poetryExit = $LASTEXITCODE; "POETRY-EXIT=$poetryExit"`; `node --version; $nodeExit = $LASTEXITCODE; "NODE-EXIT=$nodeExit"`; `npm --version; $npmExit = $LASTEXITCODE; "NPM-EXIT=$npmExit"`; `$sh = Get-Command -Name sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; "SH-FOUND=$($null -ne $sh)"`; VERDICT(`$pesterMajor -ge 5 -and $analyzerCount -ge 1 -and $PSVersionTable.PSVersion.Major -ge 7 -and $poetryExit -eq 0 -and $nodeExit -eq 0 -and $npmExit -eq 0 -and $null -ne $sh`).
      Acceptance: EXIT_CODE 0; `PESTER-MAJOR=` at least 5, `PSSCRIPTANALYZER-VERSIONS=` at least 1, `STEP-PWSH-MAJOR=` at least 7, `POETRY-EXIT=0`, `NODE-EXIT=0`, `NPM-EXIT=0`, and `SH-FOUND=True`. `SH-FOUND=False` stops the plan, because P0-T23, P5-T1, and P8-T13 need `sh -n`.
- [x] [P0-T9] Verify the prepared Python environment and record FEATURE/evidence/remediation-baseline/r2-python-env.TS.md.
      Commands: `$venvSet = Test-Path -Path Env:VIRTUAL_ENV; "VIRTUAL_ENV-SET=$venvSet"`; `$envPath = (poetry env info --path | Out-String).Trim(); $envExit = $LASTEXITCODE; "POETRY-ENV-EXIT=$envExit"`; `$isWorktreeVenv = ($envPath -replace '\\', '/').EndsWith('drm-copilot-wt-824/.venv', [System.StringComparison]::OrdinalIgnoreCase); "POETRY-ENV-IS-WORKTREE-VENV=$isWorktreeVenv"`; `$pythonVersion = poetry run python --version; $pythonExit = $LASTEXITCODE; $pythonVersion; "PYTHON-EXIT=$pythonExit"`; VERDICT(`-not $venvSet -and $envExit -eq 0 -and $isWorktreeVenv -and "$pythonVersion" -like 'Python 3.*' -and $pythonExit -eq 0`).
      Acceptance: EXIT_CODE 0; `VIRTUAL_ENV-SET=False`, `POETRY-ENV-EXIT=0`, `POETRY-ENV-IS-WORKTREE-VENV=True`, a `Python 3.` line, and `PYTHON-EXIT=0`. Any other value stops the plan; the executor does not run `poetry install`. The environment path itself is not printed.
- [x] [P0-T10] Verify the prepared extension Node environment and record FEATURE/evidence/remediation-baseline/r2-node-env.TS.md.
      Commands: `$jest = Test-Path -LiteralPath extensions/drm-copilot/node_modules/jest/package.json; $prettier = Test-Path -LiteralPath extensions/drm-copilot/node_modules/prettier/package.json; "JEST-PACKAGE=$jest PRETTIER-PACKAGE=$prettier"`; VERDICT(`$jest -and $prettier`).
      Acceptance: EXIT_CODE 0 and both values `True`. Any other value stops the plan; the executor does not run `npm ci`.
- [x] [P0-T11] Baseline PowerShell format in check-only mode and record FEATURE/evidence/remediation-baseline/r2-poshqc-format.TS.md.
      Commands: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) }' *> "$Scratch/r2-format-baseline.log"; $formatExit = $LASTEXITCODE; "FORMAT-EXIT=$formatExit"`; `$formatted = (Select-String -LiteralPath "$Scratch/r2-format-baseline.log" -Pattern '^Formatted: ').Count; "FORMATTED=$formatted"`; `$already = (Select-String -LiteralPath "$Scratch/r2-format-baseline.log" -Pattern '^Already formatted: ').Count; "ALREADY-FORMATTED=$already"`; VERDICT(`$formatExit -eq 0 -and $formatted -eq 0 -and $already -gt 0`).
      Acceptance: EXIT_CODE 0; `FORMAT-EXIT=0`, `FORMATTED=0`, and `ALREADY-FORMATTED=` greater than 0. The injected no-op `-WriteFile` makes the run rewrite nothing. A non-zero `FORMATTED=` count is recorded with its paths and stops the plan.
- [x] [P0-T12] Baseline PowerShell analyze and record FEATURE/evidence/remediation-baseline/r2-poshqc-analyze.TS.md.
      Commands: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r2-analyze-baseline.log"; $analyzeExit = $LASTEXITCODE; "ANALYZE-EXIT=$analyzeExit"`; `$passLine = (Select-String -LiteralPath "$Scratch/r2-analyze-baseline.log" -SimpleMatch -Pattern 'PSScriptAnalyzer passed: no findings under').Count; "PASS-LINE=$passLine"`; VERDICT(`$analyzeExit -eq 0 -and $passLine -eq 1`).
      Acceptance: EXIT_CODE 0, `ANALYZE-EXIT=0`, and `PASS-LINE=1`. A finding is recorded with its rows and stops the plan.
- [x] [P0-T13] Baseline the full Pester run with coverage and record FEATURE/evidence/remediation-baseline/r2-poshqc-test.TS.md. Run in the background and wait for completion.
      Commands: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r2-pester-baseline.log"; $LASTEXITCODE`; `Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination "$Scratch/r2-baseline-coverage.xml" -Force -ErrorAction Stop`; `[xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; "tests=$($j.testsuites.tests) failures=$($j.testsuites.failures) errors=$($j.testsuites.errors)"; $j.SelectNodes('//testcase[failure]') | ForEach-Object { "FAILED: $($_.name)" }`.
      Acceptance: the run's exit code, the totals line, and every `FAILED:` line are recorded; the failing set is BASELINE-PESTER-FAILURES (possibly empty). This task does not stop on failures.
- [x] [P0-T14] Derive the baseline per-file PowerShell coverage and record FEATURE/evidence/remediation-baseline/r2-coverage.TS.md.
      Commands: `$cov = @(& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r2-baseline-coverage.xml" -BaseSha 'BASE_SHA' COV-TARGETS); $covExit = $LASTEXITCODE; $cov; "COV-DERIVE-EXIT=$covExit"` (COV-TARGETS written out in full); VERDICT(`$covExit -eq 0 -and @($cov | Where-Object { $_ -match '^COV \S+ covered=\d+ missed=\d+ pct=[\d.]+$' }).Count -eq 8 -and @($cov | Where-Object { $_ -like '*ABSENT*' }).Count -eq 0`). A1 is called without `-FailBelow`, so its gate is off for the baseline; the VERDICT line is the gate.
      Acceptance: EXIT_CODE 0; `COV-DERIVE-EXIT=0`; eight numeric `COV` lines (`COV TOTAL` and the seven COV-TARGETS); no `ABSENT` or `SOURCE-ABSENT` line. Each pct is recorded as that file's BASELINE value. A non-numeric value stops the plan.
- [x] [P0-T15] Baseline Python formatting and record FEATURE/evidence/remediation-baseline/r2-black.TS.md.
      Commands: `poetry run black --check . *> "$Scratch/r2-black-baseline.log"; $LASTEXITCODE`; `Select-String -LiteralPath "$Scratch/r2-black-baseline.log" -Pattern '^would reformat ' | ForEach-Object { $_.Line }`; `Select-String -LiteralPath "$Scratch/r2-black-baseline.log" -Pattern 'would be left unchanged' | ForEach-Object { $_.Line }`.
      Acceptance: the exit code, every `would reformat` path (BASELINE-BLACK-SET, host-path rule applied), and the unchanged-count line are recorded. `black --check` is check-only. This task does not stop on a non-zero exit.
- [x] [P0-T16] Baseline Python lint and record FEATURE/evidence/remediation-baseline/r2-ruff.TS.md.
      Commands: `poetry run ruff check . *> "$Scratch/r2-ruff-baseline.log"; $LASTEXITCODE`; `Select-String -LiteralPath "$Scratch/r2-ruff-baseline.log" -Pattern '^(All checks passed!|Found \d+ error)' | ForEach-Object { $_.Line }`.
      Acceptance: the exit code and the summary line are recorded; a clean run prints `All checks passed!`. Every finding is recorded as BASELINE-RUFF-SET. This task does not stop on a non-zero exit.
- [x] [P0-T17] Baseline Python type checking and record FEATURE/evidence/remediation-baseline/r2-pyright.TS.md.
      Commands: `poetry run pyright *> "$Scratch/r2-pyright-baseline.log"; $LASTEXITCODE`; `Select-String -LiteralPath "$Scratch/r2-pyright-baseline.log" -Pattern '^\d+ errors?, \d+ warnings?' | ForEach-Object { $_.Line }`.
      Acceptance: the exit code and the summary line are recorded; every error, made repo-relative under the host-path rule, is recorded as BASELINE-PYRIGHT-SET. This task does not stop on a non-zero exit.
- [x] [P0-T18] Baseline the full pytest run with coverage and record FEATURE/evidence/remediation-baseline/r2-pytest.TS.md. Run in the background and wait for completion.
      Commands: `poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r2-pytest-baseline.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit"`; `$lines = @(Select-String -LiteralPath "$Scratch/r2-pytest-baseline.log" -Pattern '^(TOTAL\s|FAILED |ERROR |\d+ (passed|failed|errors?)\b)' | ForEach-Object { $_.Line }); $lines`; RELAY(`$pytestExit`, `@($lines | Where-Object { $_ -match '^TOTAL\s.*\d+%' }).Count -eq 1 -and @($lines | Where-Object { $_ -match '^\d+ (passed|failed|errors?)\b' }).Count -ge 1`).
      Acceptance: the relayed exit code (pytest's own when the `TOTAL` line and a summary line are present, 255 otherwise), the `TOTAL` line with its numeric percentage, the final summary line (with `-q` it has no `=` padding, for example `32 passed in 0.34s`), its passed count (recorded as the P0-T18 passed count), and every `FAILED ` and `ERROR ` node (BASELINE-PYTEST-FAILURES) are recorded. A missing `TOTAL` line relays 255 and stops the plan. Test failures do not stop the plan.
- [x] [P0-T19] Baseline TypeScript formatting and record FEATURE/evidence/remediation-baseline/r2-prettier.TS.md.
      Command: `Push-Location extensions/drm-copilot; npx prettier --check 'src/**/*.ts' 'test/**/*.ts' '*.json' '*.cjs' *> "$Scratch/r2-prettier-baseline.log"; $code = $LASTEXITCODE; Pop-Location; "PRETTIER-EXIT=$code"; Select-String -LiteralPath "$Scratch/r2-prettier-baseline.log" -Pattern '(All matched files use Prettier code style!|\[warn\])' | ForEach-Object { $_.Line }`.
      Acceptance: `PRETTIER-EXIT=` and the matched lines are recorded; a clean run prints `All matched files use Prettier code style!`. This task does not stop on a non-zero exit.
- [x] [P0-T20] Baseline TypeScript lint and record FEATURE/evidence/remediation-baseline/r2-eslint.TS.md.
      Commands: `npm --prefix extensions/drm-copilot run lint *> "$Scratch/r2-eslint-baseline.log"; $LASTEXITCODE`; `(Select-String -LiteralPath "$Scratch/r2-eslint-baseline.log" -Pattern '\d+ problems?').Count`.
      Acceptance: the exit code and the problem-line count are recorded. This task does not stop on a non-zero exit.
- [x] [P0-T21] Baseline TypeScript type checking and record FEATURE/evidence/remediation-baseline/r2-tsc.TS.md.
      Commands: `npm --prefix extensions/drm-copilot run typecheck *> "$Scratch/r2-tsc-baseline.log"; $LASTEXITCODE`; `(Select-String -LiteralPath "$Scratch/r2-tsc-baseline.log" -Pattern 'error TS\d+').Count`.
      Acceptance: the exit code and the `error TS` count are recorded. This task does not stop on a non-zero exit.
- [x] [P0-T22] Baseline the Jest suite with coverage and record FEATURE/evidence/remediation-baseline/r2-jest.TS.md. Run in the background and wait for completion.
      Commands: `npm --prefix extensions/drm-copilot run test:coverage *> "$Scratch/r2-jest-baseline.log"; $jestExit = $LASTEXITCODE; "JEST-EXIT=$jestExit"`; `$lines = @(Select-String -LiteralPath "$Scratch/r2-jest-baseline.log" -Pattern '^(Tests:|Test Suites:|Lines\s*:|Branches\s*:|Statements\s*:|\s*●)' | ForEach-Object { $_.Line }); $lines`; RELAY(`$jestExit`, `@($lines | Where-Object { $_ -match '^Lines\s*:\s*[\d.]+%' }).Count -eq 1 -and @($lines | Where-Object { $_ -match '^Branches\s*:\s*[\d.]+%' }).Count -eq 1`).
      Acceptance: the relayed exit code, the `Test Suites:` and `Tests:` lines, and the numeric `Lines` and `Branches` text-summary percentages are recorded; failing test names are BASELINE-JEST-FAILURES. Missing percentages relay 255 and stop the plan. Test failures do not stop the plan.
- [x] [P0-T23] Baseline the shell syntax check of both setup-script copies and record FEATURE/evidence/remediation-baseline/r2-sh-syntax.TS.md.
      Commands: SH-CHECK('.codex/codex-web-setup.sh', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh'); VERDICT(`$worst -eq 0`).
      Acceptance: three lines print `SYNTAX-EXIT=0` (one per file and the aggregate), and EXIT_CODE is 0. A non-zero value stops the plan.
- [x] [P0-T24] Baseline the WORKFLOW YAML parse and the actionlint availability, and record FEATURE/evidence/remediation-baseline/r2-workflow-yaml.TS.md.
      Commands: YAML-CHECK(r2-yaml-baseline.log); ACTIONLINT-RUN(r2-actionlint-baseline.log); VERDICT(`$yamlExit -eq 0 -and $yamlSteps.Count -eq 1 -and $yamlSteps[0] -eq 8`).
      Acceptance: EXIT_CODE 0; `YAML-EXIT=0`; `YAML-STEPS=8` and `YAML-STEP-COUNT=8`; the `YAML-NAMES=` line recorded (informational, not gated); `ACTIONLINT-EXIT=` recorded (`-1` when actionlint is not on PATH) with every `ACTIONLINT-MESSAGE:` line, which together form BASELINE-ACTIONLINT-MESSAGES (possibly empty). The actionlint result does not gate this task. Any other YAML value exits 1 and stops the plan.

### Phase 1 — Regression Tests First (fail before the fix)

Phase 1 to Phase 6 are exempt from the restart-on-failure rule, which resumes in Phase 8. Every P1 authoring task only appends lines, creates a file, or makes the D5 `A824-WT6` edit; its acceptance is static and runs no test, because P1-T10 runs them together against the unfixed tree.

Shared static acceptance for P1-T1 to P1-T7 (each task names its file F, its tokens, and its deleted-line count D). The step script runs, with F, D, and the token list substituted: PARSE-CHECK(F); `$missing = @(foreach ($t in @(TOKENS)) { if ((Select-String -LiteralPath F -SimpleMatch -Pattern $t).Count -lt 1) { $t } }); "MISSING-TOKENS=$($missing.Count)"; $missing` (TOKENS as single-quoted strings, a `'` inside a token doubled; every token is new in F); `$lineCount = @(Get-Content -LiteralPath F).Count; "LINES=$lineCount"`; `$numstat = @(git diff --numstat BASE_SHA -- F); $numstat`; VERDICT(`@($e).Count -eq 0 -and $missing.Count -eq 0 -and $lineCount -le 500 -and $numstat.Count -eq 1 -and [int]($numstat[0] -split '\t')[0] -gt 0 -and [int]($numstat[0] -split '\t')[1] -eq D`). Acceptance: EXIT_CODE 0, `PARSE-ERRORS=0`, `MISSING-TOKENS=0`, a `LINES=` value of at most 500, and a numstat line whose added count is greater than 0 and whose deleted count equals D.

- [x] [P1-T1] Append to U1 the D6 Context `issue #824 cycle 2 - whole-token order-independent classification` (rows R824-P26 to R824-P30 and R824-N11, R824-N12), and record FEATURE/evidence/other/r2-p1-t1.TS.md.
      Tokens: `issue #824 cycle 2 - whole-token order-independent classification`, `create an issue with gh`, `xargs gh`, `_ pr list`. D = 0.
- [x] [P1-T2] Append the same Context, with identical names, rows, assertions, and tags, to U2, and record FEATURE/evidence/other/r2-p1-t2.TS.md.
      Tokens and D: as P1-T1.
- [x] [P1-T3] Append to S1 the D6 Context `issue #824 cycle 2 - review pass 2 bypass forms` (rows P824-D16 to P824-D19), and record FEATURE/evidence/other/r2-p1-t3.TS.md.
      Tokens: `issue #824 cycle 2 - review pass 2 bypass forms`, `Id = 16;`, `Id = 19;`, `xargs gh`. D = 0.
- [x] [P1-T4] Append the same Context to S2, driven through `Get-CodexPromotionTriggerScopingDecision`, and record FEATURE/evidence/other/r2-p1-t4.TS.md.
      Tokens and D: as P1-T3.
- [x] [P1-T5] Make the D5 `A824-WT6` edit in S6 and append the two D6 Contexts (A824-X1 to A824-X10, A824-WT10, A824-WT11-1, A824-WT11-2), and record FEATURE/evidence/other/r2-p1-t5.TS.md.
      Tokens: `issue #824 cycle 2 - review pass 2 removal forms without an authorizing record`, `issue #824 cycle 2 - non-literal operand outcomes with an authorizing record`, `A824-X`, `A824-WT10`, `A824-WT11-`, `A824-WT6 denies a wrapped removal that names no operand`, `(Join-Path /repo/worktrees item-a-101)`, `cycle 2 design decision 2`. D = 2. The step script also runs `$oldTitle = (Select-String -LiteralPath F -SimpleMatch -Pattern 'A824-WT6 allows').Count; "OLD-TITLE=$oldTitle"` and its VERDICT condition is extended with `-and $oldTitle -eq 0`; acceptance adds `OLD-TITLE=0`.
- [x] [P1-T6] Make the same edit and append the same two Contexts to S7 (parallel seams and `^PARALLEL_WORKTREE_REMOVAL_BLOCKED`), and record FEATURE/evidence/other/r2-p1-t6.TS.md.
      Tokens, D, and the `OLD-TITLE` extension: as P1-T5.
- [x] [P1-T7] Make the S8 edit of D5 and append the same two Contexts to S8 in the Codex idiom of D6, and record FEATURE/evidence/other/r2-p1-t7.TS.md.
      Tokens, D, and the `OLD-TITLE` extension: as P1-T5.
- [x] [P1-T8] Create BATS with the Write tool from Appendix B1, verbatim, and record FEATURE/evidence/other/r2-p1-t8.TS.md.
      Commands: `$tests = (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -CaseSensitive -Pattern '^@test "C824-\d+ ').Count; "TESTS=$tests"`; `$target = (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -SimpleMatch -Pattern '/../.." && pwd)/.codex/codex-web-setup.sh"').Count; $other = (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -SimpleMatch -Pattern '.github/codex').Count; $temp = (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -Pattern 'mktemp|TMPDIR').Count; "TARGET=$target OTHER=$other TEMP=$temp"`; `$lineCount = @(Get-Content -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats).Count; "LINES=$lineCount"`; `$status = @(git status --porcelain --untracked-files=all -- tests/shell/test_codex_web_setup_codex_copy.bats); $status`; VERDICT(`$tests -eq 15 -and $target -eq 1 -and $other -eq 0 -and $temp -eq 0 -and $lineCount -le 500 -and $status.Count -eq 1 -and $status[0].StartsWith('?? ')`).
      Acceptance: EXIT_CODE 0; `TESTS=15`; `TARGET=1 OTHER=0 TEMP=0` (the file sources the `.codex` copy through the canonical absolute path of D7, never `.github/codex`, and creates no temporary file); `LINES=` at most 500; one `??` status line.
- [x] [P1-T9] Create FIXTURE with the Write tool from Appendix B2 and record FEATURE/evidence/other/r2-p1-t9.TS.md.
      Commands: `$status = @(git status --porcelain --untracked-files=all -- tests/fixtures/codex_web_setup); $status`; `$content = @(Get-Content -LiteralPath tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt); "FIXTURE-LINES=$($content.Count)"`; VERDICT(`$status.Count -eq 1 -and $status[0] -eq '?? tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt' -and $content.Count -eq 1`).
      Acceptance: EXIT_CODE 0; exactly the one `??` line naming FIXTURE (so the file is not ignored); `FIXTURE-LINES=1`.
- [x] [P1-T10] [expect-fail] Run every Issue824 test in S1, S2, S6, S7, S8, U1, and U2 against the unfixed tree and record FEATURE/evidence/regression-testing/r2-expect-fail-pester.TS.md with `ExpectedExitCode: 45`.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' ISSUE824-PATHS -JUnitPath '$Scratch/r2-expect-fail-pester.junit.xml' -Tag 'Issue824' -ExpectPassed 198 -ExpectFailed 45; exit `$LASTEXITCODE"; $LASTEXITCODE `` (ISSUE824-PATHS written out in full; the JUnit file stays in SCRATCH).
      Acceptance: exit code 45; `TOTALS` prints `passed=198 failed=45`; `EXPECTATION-MISMATCHES=0`; no `CONTAINER-ERROR:` line. A2 exits 45 only when both counts match and no container failed (a container error raises the exit code, and a count mismatch makes A2 exit 255), so the recorded `EXIT_CODE:` cannot equal `ExpectedExitCode: 45` on a wrong result. The 45 `FAILED:` names are exactly the FIX-SET members (D9): `P824-D16` to `P824-D19` in S1 and S2; `A824-X1`, `A824-X2`, `A824-X3`, `A824-X4`, `A824-X7`, `A824-X8`, `A824-X10`, `A824-WT6`, and `A824-WT11-1` in S6, S7, and S8; `R824-P26` to `R824-P30` in U1 and U2. The 198 `PASSED:` names are every other Issue824 test in these files, including `R824-N11`, `R824-N12`, `A824-WT10`, and `A824-WT11-2`. The artifact lists every `FAILED:` and `PASSED:` line. Any other set stops the plan.
- [x] [P1-T11] Write the fail-before exception dossier for the pass-before rows and for BATS, and record FEATURE/evidence/regression-testing/fail-before-exception.TS.md.
      Commands, step script SCRATCH/steps/r2-p1-t11.ps1, run before the dossier is written: `$base = @(git show BASE_SHA:.codex/codex-web-setup.sh); $showExit = $LASTEXITCODE; "SHOW-EXIT=$showExit"`; `$baseDefs = @(foreach ($t in @('resolve_repo_root() {', 'select_solution_file() {', 'list_root_solution_files() {')) { @($base | Where-Object { $_.Contains($t) }).Count }); "BASE-DEFINITIONS=$($baseDefs -join ',')"`; `$baseLast = $base[-1]; $guard = @(Select-String -LiteralPath .github/codex/codex-web-setup.sh -SimpleMatch -Pattern 'then main' | ForEach-Object { $_.Line }); $baseGuarded = $guard.Count -eq 1 -and $baseLast -ceq $guard[0]; "BASE-LAST-IS-GUARD=$baseGuarded"`; VERDICT(`$showExit -eq 0 -and ($baseDefs -join ',') -eq '0,0,0' -and -not $baseGuarded`).
      Content: `Timestamp:`; `WhyFailingRunImpossible:` (a) `R824-N11`, `R824-N12`, `A824-WT10`, and `A824-WT11-2` pin behaviour that already holds at BASE_SHA (D9), so they cannot fail on the unfixed tree; (b) BATS cannot run on this host: bats and kcov run only in the CI job `shell-coverage / Shell Coverage (Bats + kcov)` (the existing `Run shell-qc test with coverage` step and the D13 Measure step), which runs on the PR head after the fix, and the executor has no permitted local route (D8). `Alternative proof:` for (a), the P1-T10 artifact path with these names on `PASSED:` lines, and the FIX-SET rows that fail in the same run; for (b), the step-script output above: `BASE-DEFINITIONS=0,0,0` (the functions C824-2 to C824-7 call do not exist at BASE_SHA, so those cases would fail with a command-not-found status) and `BASE-LAST-IS-GUARD=False` (at BASE_SHA sourcing the file runs `main`, so C824-1 fails and the `setup` of every case would run the full bootstrap). `SearchScope:` FEATURE/evidence/regression-testing/; `SearchPatterns:` `r2-expect-fail-*.md`, `fail-before-exception.*.md`; `SearchResult:` the P1-T10 artifact path and this dossier.
      Then, in step script SCRATCH/steps/r2-p1-t11-check.ps1 (artifact path substituted; the key is assembled at run time and matched at a line start, so the check's own recorded `Command:` line cannot be counted): `$key = 'WhyFailing' + 'RunImpossible:'; $whyCount = (Select-String -LiteralPath <artifact> -Pattern ('^' + $key)).Count; "WHY-COUNT=$whyCount"`; VERDICT(`$whyCount -eq 1`).
      Acceptance: the first script exits 0 with `SHOW-EXIT=0`, `BASE-DEFINITIONS=0,0,0`, and `BASE-LAST-IS-GUARD=False`; the second exits 0 with `WHY-COUNT=1`; the artifact's `EXIT_CODE:` is the larger of the two process exit codes.

### Phase 2 — Whole-Token Matcher (R2 / CR-2, AC-1)

- [x] [P2-T1] Make the three D2 edits to CLAUDE-RAW with the Edit tool and record FEATURE/evidence/other/r2-p2-t1.TS.md.
      Commands: PARSE-CHECK(.claude/hooks/hook-command-raw-invocation.ps1); `& "$Scratch/raw-predicate-ast-check.ps1" -Path '.claude/hooks/hook-command-raw-invocation.ps1'; $astExit = $LASTEXITCODE; "AST-EXIT=$astExit"`; `$notOne = 0; foreach ($t in @('function Get-CommandLineRawInvocationPattern', 'function Test-CommandLineRawWordPresent', 'function Get-CommandLineRawInvocationMatch', 'function Test-CommandLineRawInvocation', 'function Get-CommandLineRawInvocationOperand', 'function Resolve-CommandLineWrappedInvocationOperand')) { $c = (Select-String -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1 -SimpleMatch -Pattern $t).Count; if ($c -ne 1) { $notOne++ }; "$t COUNT=$c" }`; `$count = { param([string] $Token) (Select-String -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1 -SimpleMatch -Pattern $Token).Count }; $ordered = & $count 'ordered sequence'; $whole = & $count 'whole tokens'; $exe = & $count '.exe)?'; $containment = & $count 'Test-CommandLineRawContainment'; $commandWord = & $count "-CommandWord '"; "ORDERED=$ordered WHOLE=$whole EXE-SUFFIX=$exe CONTAINMENT=$containment COMMANDWORD-LITERAL=$commandWord"`; `$io = (Select-String -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1 -Pattern 'Get-Content|Set-Content|Start-Process|Invoke-Expression|Get-Date|\$env:').Count; "IO=$io"`; `& "$Scratch/phrase-scan.ps1" -Root @('.claude/hooks'); $scanExit = $LASTEXITCODE; "PHRASE-SCAN-EXIT=$scanExit"`; `$lineCount = @(Get-Content -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1).Count; "LINES=$lineCount"`; VERDICT(`@($e).Count -eq 0 -and $astExit -eq 0 -and $notOne -eq 0 -and $ordered -eq 0 -and $whole -ge 2 -and $exe -eq 1 -and $containment -eq 0 -and $commandWord -eq 0 -and $io -eq 0 -and $scanExit -eq 0 -and $lineCount -le 320`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; A5 prints `WORDPRESENT=1` and `SEQUENCEMATCH=0` (`Test-CommandLineRawInvocation` calls `Test-CommandLineRawWordPresent` once and `Get-CommandLineRawInvocationMatch` never) with `AST-EXIT=0`; six `COUNT=1` lines; `ORDERED=0`, `WHOLE=` at least 2, `EXE-SUFFIX=1` (only the sequence-pattern builder keeps the `.exe` group), `CONTAINMENT=0`, `COMMANDWORD-LITERAL=0`; `IO=0`; `HITS=0` and `PHRASE-SCAN-EXIT=0`; `LINES=` at most 320.
- [x] [P2-T2] Run U1 in full and record FEATURE/evidence/other/r2-p2-t2.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1') -JUnitPath '$Scratch/r2-u1.junit.xml' -ExpectPassed 58 -ExpectFailed 0; exit `$LASTEXITCODE"; $LASTEXITCODE ``.
      Acceptance: exit 0 (A2 exits 255 on a count mismatch); `TOTALS` prints `passed=58 failed=0` (51 prior rows plus the 7 D6 rows). A failing row is fixed in CLAUDE-RAW, never by changing the row.
- [x] [P2-T3] Copy CLAUDE-RAW to CODEX-RAW with a `Copy-Item` line, verify identity, run U2, and record FEATURE/evidence/other/r2-p2-t3.TS.md.
      Commands: `Copy-Item -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1 -Destination .codex/hooks/hook-command-raw-invocation.ps1 -Force`; `$equal = (Get-FileHash -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1).Hash -eq (Get-FileHash -LiteralPath .codex/hooks/hook-command-raw-invocation.ps1).Hash; "EQUAL=$equal"`; `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1') -JUnitPath '$Scratch/r2-u2.junit.xml' -ExpectPassed 58 -ExpectFailed 0; exit `$LASTEXITCODE"; $u2Exit = $LASTEXITCODE; "U2-EXIT=$u2Exit" ``; VERDICT(`$equal -and $u2Exit -eq 0`).
      Acceptance: EXIT_CODE 0; `EQUAL=True`; `U2-EXIT=0` with `passed=58 failed=0`.
- [x] [P2-T4] Run S1, S2, S3, and S3X in full and record FEATURE/evidence/other/r2-p2-t4.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1') -JUnitPath '$Scratch/r2-promotion.junit.xml' -ExpectFailed 0 -RequirePassed @('P824-D16*2', 'P824-D17*2', 'P824-D18*2', 'P824-D19*2', 'P824-A1*2', 'P824-A2*2', 'P824-A3*2', 'P824-A4*2', 'N824-1*2'); exit `$LASTEXITCODE"; $LASTEXITCODE ``.
      Acceptance: exit 0 with `failed=0` and `EXPECTATION-MISMATCHES=0`; the `PASSED:` lines include `P824-D16` to `P824-D19`, `P824-A1` to `P824-A4` (S1 and S2), and `N824-1` (S3 and S3X), each twice.

### Phase 3 — Worktree-Removal Gates Fail Closed (R1 / CR-1, AC-43)

GATE-CHECK(F) means PARSE-CHECK(F); `$noOperand = (Select-String -LiteralPath F -SimpleMatch -Pattern 'NoOperand').Count; $wired = (Select-String -LiteralPath F -SimpleMatch -Pattern 'Resolve-CommandLineWrappedInvocationOperand').Count; $rule = (Select-String -LiteralPath F -SimpleMatch -Pattern 'exactly one literal operand').Count; "NOOPERAND=$noOperand WIRED=$wired RULE-COMMENT=$rule"`; `$numstat = @(git diff --numstat BASE_SHA -- F); $numstat`; `$lineCount = @(Get-Content -LiteralPath F).Count; "LINES=$lineCount"`; VERDICT(`@($e).Count -eq 0 -and $noOperand -eq 0 -and $wired -eq 1 -and $rule -eq 1 -and $numstat.Count -eq 1 -and $numstat[0] -match '^5\t5\t' -and $lineCount -eq RECORDED(P0-T5 F count)`). Acceptance for each task: EXIT_CODE 0; `PARSE-ERRORS=0`; `NOOPERAND=0 WIRED=1 RULE-COMMENT=1`; numstat `5	5`; `LINES=` equal to the P0-T5 count of F.

- [x] [P3-T1] Apply the D3 edit to EPIC-GATE with the Edit tool and record FEATURE/evidence/other/r2-p3-t1.TS.md.
      Commands: GATE-CHECK(.claude/hooks/enforce-epic-worktree-removal-gate.ps1).
- [x] [P3-T2] Apply the D3 edit to PAR-GATE with the Edit tool and record FEATURE/evidence/other/r2-p3-t2.TS.md.
      Commands: GATE-CHECK(.claude/hooks/enforce-parallel-worktree-removal-gate.ps1).
- [x] [P3-T3] Apply the D3 edit to CODEX-GATE with the Edit tool and record FEATURE/evidence/other/r2-p3-t3.TS.md.
      Commands: GATE-CHECK(.codex/hooks/enforce-epic-worktree-removal-gate.ps1).
- [x] [P3-T4] Run every worktree-gate suite in full and record FEATURE/evidence/other/r2-p3-t4.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' GATE-SUITE-PATHS -JUnitPath '$Scratch/r2-gates.junit.xml' -ExpectFailed 0 -RequirePassed @('A824-X1*3', 'A824-X2*3', 'A824-X3*3', 'A824-X4*3', 'A824-X7*3', 'A824-X8*3', 'A824-X10*3', 'A824-WT6*3', 'A824-WT10*3', 'A824-WT11-1*3', 'A824-WT11-2*3', 'A824-WT3*3', 'A824-WT9*3'); exit `$LASTEXITCODE"; $LASTEXITCODE `` (GATE-SUITE-PATHS written out in full).
      Acceptance: exit 0 with `failed=0`, `EXPECTATION-MISMATCHES=0`, and no `CONTAINER-ERROR:` line; each listed name appears on `PASSED:` lines three times. A failure in a pre-existing test is fixed in a gate or CLAUDE-RAW (then P2-T3 is re-run when CLAUDE-RAW changed), never by editing an existing assertion.

### Phase 4 — Documented Contract and Test Titles (AC-22, AC-16)

- [x] [P4-T1] Apply the three D4 edits to CLAUDE-INV with the Edit tool and record FEATURE/evidence/other/r2-p4-t1.TS.md.
      Commands: PARSE-CHECK(.claude/hooks/hook-command-invocation.ps1); `& "$Scratch/resolver-ast-check.ps1" -Path '.claude/hooks/hook-command-invocation.ps1'; $astExit = $LASTEXITCODE; "AST-EXIT=$astExit"`; `$whole = (Select-String -LiteralPath .claude/hooks/hook-command-invocation.ps1 -SimpleMatch -Pattern 'whole tokens').Count; $ordered = (Select-String -LiteralPath .claude/hooks/hook-command-invocation.ps1 -SimpleMatch -Pattern 'ordered sequence').Count; "WHOLE=$whole ORDERED=$ordered"`; `$numstat = @(git diff --numstat BASE_SHA -- .claude/hooks/hook-command-invocation.ps1); $numstat`; `$lineCount = @(Get-Content -LiteralPath .claude/hooks/hook-command-invocation.ps1).Count; "LINES=$lineCount"`; VERDICT(`@($e).Count -eq 0 -and $astExit -eq 0 -and $whole -eq 3 -and $ordered -eq 0 -and $numstat.Count -eq 1 -and $numstat[0] -match '^9\t6\t' -and $lineCount -eq RECORDED(P0-T5 CLAUDE-INV count) + 3 -and $lineCount -le 500`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; A3 prints `RAWINVOCATION=1` and `RAWCONTAINMENT=0` with `AST-EXIT=0`; `WHOLE=3 ORDERED=0`; numstat `9	6`; `LINES=` equal to the P0-T5 count plus 3 and at most 500.
- [x] [P4-T2] Copy CLAUDE-INV to CODEX-INV with a `Copy-Item` line, verify identity, and record FEATURE/evidence/other/r2-p4-t2.TS.md.
      Commands: `Copy-Item -LiteralPath .claude/hooks/hook-command-invocation.ps1 -Destination .codex/hooks/hook-command-invocation.ps1 -Force`; `$equal = (Get-FileHash -LiteralPath .claude/hooks/hook-command-invocation.ps1).Hash -eq (Get-FileHash -LiteralPath .codex/hooks/hook-command-invocation.ps1).Hash; "EQUAL=$equal"`; `$numstat = @(git diff --numstat BASE_SHA -- .codex/hooks/hook-command-invocation.ps1); $numstat`; VERDICT(`$equal -and $numstat.Count -eq 1 -and $numstat[0] -match '^9\t6\t'`).
      Acceptance: EXIT_CODE 0; `EQUAL=True`; numstat `9	6` (P0-T6 showed the two copies identical at BASE_SHA).
- [x] [P4-T3] Apply the D5 S3 edits (title line 207 and the `-Because` text on line 244) with the Edit tool and record FEATURE/evidence/other/r2-p4-t3.TS.md.
      Commands: PARSE-CHECK(tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1); `$newTitle = (Select-String -LiteralPath tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 -SimpleMatch -Pattern 'carries every word as a whole token').Count; $oldTitle = (Select-String -LiteralPath tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 -SimpleMatch -Pattern 'token-aware ordered sequence').Count; $because = (Select-String -LiteralPath tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 -SimpleMatch -Pattern 'gh does not occur as a whole token in the reproduction').Count; "NEW-TITLE=$newTitle OLD-TITLE=$oldTitle BECAUSE=$because"`; `$numstat = @(git diff --numstat BASE_SHA -- tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1); $numstat`; VERDICT(`@($e).Count -eq 0 -and $newTitle -eq 1 -and $oldTitle -eq 0 -and $because -eq 1 -and $numstat.Count -eq 1 -and $numstat[0] -match '^2\t2\t'`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; `NEW-TITLE=1 OLD-TITLE=0 BECAUSE=1`; numstat `2	2` (no assertion line changed).
- [x] [P4-T4] Apply the same two edits to S3X and record FEATURE/evidence/other/r2-p4-t4.TS.md.
      Commands: the P4-T3 commands with every S3 path replaced by `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1`.
      Acceptance: as P4-T3.
- [x] [P4-T5] Apply the D5 U1 edits (lines 10 to 13, 25, 54, and 74) with the Edit tool and record FEATURE/evidence/other/r2-p4-t5.TS.md.
      Commands: PARSE-CHECK(tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1); `$ordered = (Select-String -LiteralPath tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 -SimpleMatch -Pattern 'ordered sequence').Count; $context = (Select-String -LiteralPath tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 -SimpleMatch -Pattern 'positive rows - every word occurs as a whole token').Count; "ORDERED=$ordered CONTEXT=$context"`; `$numstat = @(git diff --numstat BASE_SHA -- tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1); $numstat`; VERDICT(`@($e).Count -eq 0 -and $ordered -eq 0 -and $context -eq 1 -and $numstat.Count -eq 1 -and [int]($numstat[0] -split '\t')[1] -eq 7`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; `ORDERED=0 CONTEXT=1`; the numstat deleted count is 7.
- [x] [P4-T6] Apply the same edits to U2 and record FEATURE/evidence/other/r2-p4-t6.TS.md.
      Commands: the P4-T5 commands with every U1 path replaced by `tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1`.
      Acceptance: as P4-T5.
- [x] [P4-T7] Run S3, S3X, U1, and U2 in full and record FEATURE/evidence/other/r2-p4-t7.TS.md.
      Commands: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1') -JUnitPath '$Scratch/r2-p4-t7.junit.xml' -ExpectFailed 0 -RequirePassed @('N824-1*2', 'R824-P26*2', 'R824-N11*2'); exit `$LASTEXITCODE"; $runExit = $LASTEXITCODE; "RUN-EXIT=$runExit" ``; `[xml]$j = Get-Content -Raw -LiteralPath "$Scratch/r2-p4-t7.junit.xml"; $renamed = @($j.SelectNodes('//testcase') | Where-Object { $_.name -like '*carries every word as a whole token' -and -not $_.failure }).Count; "RENAMED-PASSED=$renamed"`; VERDICT(`$runExit -eq 0 -and $renamed -eq 2`).
      Acceptance: EXIT_CODE 0; `RUN-EXIT=0` with `failed=0` and `EXPECTATION-MISMATCHES=0`; `RENAMED-PASSED=2` (the AC-16 test passes on both surfaces under its new title).

### Phase 5 — Setup Script Safe to Source and Its CI Coverage Gate (R3 / CR-3, AC-42, decision Q1)

- [x] [P5-T1] Apply the three D7 edits to SETUP with the Edit tool, in D7 order, and record FEATURE/evidence/other/r2-p5-t1.TS.md.
      Commands: SH-CHECK('.codex/codex-web-setup.sh', '.codex/codex-web-setup.sh'); `$defs = @(foreach ($t in @('resolve_repo_root() {', 'select_solution_file() {', 'list_root_solution_files() {')) { (Select-String -LiteralPath .codex/codex-web-setup.sh -SimpleMatch -Pattern $t).Count }); "DEFINITIONS=$($defs -join ',')"`; `$compgen = (Select-String -LiteralPath .codex/codex-web-setup.sh -SimpleMatch -Pattern 'compgen -G').Count; $hardCoded = (Select-String -LiteralPath .codex/codex-web-setup.sh -SimpleMatch -Pattern 'TaskMaster.sln').Count; "COMPGEN=$compgen HARD-CODED=$hardCoded"`; `$setupLast = @(Get-Content -LiteralPath .codex/codex-web-setup.sh)[-1]; $guard = @(Select-String -LiteralPath .github/codex/codex-web-setup.sh -SimpleMatch -Pattern 'then main' | ForEach-Object { $_.Line }); $lastIsGuard = $guard.Count -eq 1 -and $setupLast -ceq $guard[0]; "SETUP-LAST-IS-GUARD=$lastIsGuard"`; `$multiline = (Select-String -LiteralPath .codex/codex-web-setup.sh -Pattern '"& \{\s*$').Count; "MULTILINE-COMMAND-OPENERS=$multiline"`; `$lineCount = @(Get-Content -LiteralPath .codex/codex-web-setup.sh).Count; "LINES=$lineCount"`; VERDICT(`$worst -eq 0 -and ($defs -join ',') -eq '1,1,1' -and $compgen -eq 0 -and $hardCoded -eq 0 -and $lastIsGuard -and $multiline -eq 0 -and $lineCount -eq RECORDED(P0-T5 SETUP count) + 11 -and $lineCount -le 500`).
      Acceptance: EXIT_CODE 0; `SYNTAX-EXIT=0`; `DEFINITIONS=1,1,1`; `COMPGEN=0 HARD-CODED=0`; `SETUP-LAST-IS-GUARD=True` (the last line equals the `.github/codex/codex-web-setup.sh` guard, so sourcing defines the functions without running `main`); `MULTILINE-COMMAND-OPENERS=0` (no line ends with an opening `"& {`, so the multi-line `-Command` string of BASE_SHA line 297 is gone; at BASE_SHA this count is 1); `LINES=` equal to the P0-T5 count plus 11 and at most 500. (SH-CHECK names the file twice so its shape matches P0-T23; P6-T1 and P8-T13 check the bundle copy.)
- [x] [P5-T2] Verify static traceability between BATS and SETUP and record FEATURE/evidence/other/r2-p5-t2.TS.md.
      Commands: `$functions = @('resolve_repo_root', 'select_solution_file', 'list_root_solution_files', 'restore_packages_if_needed', 'verify_windows_visual_studio_task_capability', 'write_repo_notes'); $defined = @(foreach ($f in $functions) { (Select-String -LiteralPath .codex/codex-web-setup.sh -SimpleMatch -Pattern ($f + '() {')).Count }); $called = @(foreach ($f in $functions) { (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -CaseSensitive -Pattern ('run ' + $f + '\b')).Count }); "DEFINED=$($defined -join ',') CALLED=$($called -join ',')"`; `$messages = @('No solution file was found at', 'skipping package restore.', 'MSBuild task verification needs one.', 'packages/ is already populated; skipping restore.', 'nuget is unavailable; cannot restore packages.config dependencies.', 'MSBuild tooling required by the restore/build/lint/type-check tasks is unavailable.'); $missing = @(foreach ($m in $messages) { if ((Select-String -LiteralPath .codex/codex-web-setup.sh -SimpleMatch -Pattern $m).Count -lt 1 -or (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -SimpleMatch -Pattern $m).Count -lt 1) { $m } }); "MISSING-MESSAGES=$($missing.Count)"; $missing`; VERDICT(`($defined -join ',') -eq '1,1,1,1,1,1' -and @($called | Where-Object { $_ -lt 1 }).Count -eq 0 -and $missing.Count -eq 0`).
      Acceptance: EXIT_CODE 0; `DEFINED=1,1,1,1,1,1`; every `CALLED=` value at least 1 (`restore_packages_if_needed` is reached through the `restore_without_nuget` wrapper in C824-11 and directly in C824-8 to C824-10); `MISSING-MESSAGES=0` (every message BATS asserts exists in SETUP). This is static evidence only; the bats run is CI-dependent (D8, D13).
- [x] [P5-T3] Create GT with the Write tool from Appendix B4, verbatim, and record FEATURE/evidence/other/r2-p5-t3.TS.md.
      Commands: PARSE-CHECK(tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1); `$tests = (Select-String -LiteralPath tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1 -CaseSensitive -Pattern "^\s+It 'G824-\d+ ").Count; $temp = (Select-String -LiteralPath tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1 -Pattern 'TestDrive|New-TemporaryFile|GetTempPath|Out-File|Set-Content').Count; "TESTS=$tests TEMP=$temp"`; `$lineCount = @(Get-Content -LiteralPath tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1).Count; "LINES=$lineCount"`; `$status = @(git status --porcelain --untracked-files=all -- tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1); $status`; VERDICT(`@($e).Count -eq 0 -and $tests -eq 15 -and $temp -eq 0 -and $lineCount -le 500 -and $status.Count -eq 1 -and $status[0].StartsWith('?? ')`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; `TESTS=15 TEMP=0` (no temporary file or write API); `LINES=` at most 500; one `??` status line.
- [x] [P5-T4] Create GATE with the Write tool from Appendix B3, verbatim, and record FEATURE/evidence/other/r2-p5-t4.TS.md.
      Commands: PARSE-CHECK(scripts/dev-tools/KcovFunctionCoverageGate.ps1); `$notOne = 0; foreach ($t in @('function Get-KcovLineHit {', 'function Get-BashFunctionLineRange {', 'function Get-AddedLineNumber {', 'function Get-KcovFunctionCoverageReport {', 'function Invoke-KcovFunctionCoverageGate {')) { $c = (Select-String -LiteralPath scripts/dev-tools/KcovFunctionCoverageGate.ps1 -SimpleMatch -Pattern $t).Count; if ($c -ne 1) { $notOne++ }; "$t COUNT=$c" }`; `$reads = (Select-String -LiteralPath scripts/dev-tools/KcovFunctionCoverageGate.ps1 -SimpleMatch -Pattern 'Get-Content -Raw -LiteralPath').Count; $io = (Select-String -LiteralPath scripts/dev-tools/KcovFunctionCoverageGate.ps1 -Pattern 'Set-Content|Out-File|New-Item|Remove-Item|Start-Process|Invoke-Expression|Get-Date|\$env:|InvocationName').Count; "READS=$reads IO=$io"`; `$lineCount = @(Get-Content -LiteralPath scripts/dev-tools/KcovFunctionCoverageGate.ps1).Count; "LINES=$lineCount"`; `$status = @(git status --porcelain --untracked-files=all -- scripts/dev-tools/KcovFunctionCoverageGate.ps1); $status`; VERDICT(`@($e).Count -eq 0 -and $notOne -eq 0 -and $reads -eq 3 -and $io -eq 0 -and $lineCount -le 500 -and $status.Count -eq 1 -and $status[0].StartsWith('?? ')`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; five `COUNT=1` lines; `READS=3 IO=0` (the three file reads are in `Invoke-KcovFunctionCoverageGate`; no write, process, clock, environment access, or entry block); `LINES=` at most 500; one `??` status line.
- [x] [P5-T5] Run GT in full and record FEATURE/evidence/other/r2-p5-t5.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1') -JUnitPath '$Scratch/r2-gt.junit.xml' -ExpectPassed 15 -ExpectFailed 0 -RequirePassed @('G824-1', 'G824-9', 'G824-12', 'G824-14', 'G824-15'); exit `$LASTEXITCODE"; $LASTEXITCODE ``.
      Acceptance: exit 0 (A2 exits 255 on a count mismatch or a missing required name); `TOTALS` prints `passed=15 failed=0`; `EXPECTATION-MISMATCHES=0`; no `CONTAINER-ERROR:` line. A failing test is fixed in GATE, never by changing a test.
- [x] [P5-T6] Apply the D13 workflow edit W1 to WORKFLOW with the Edit tool and record FEATURE/evidence/other/r2-p5-t6.TS.md.
      Commands: YAML-CHECK(r2-yaml-p5.log); `$numstat = @(git diff --numstat BASE_SHA -- .github/workflows/_shell-coverage.yml); $numstat`; `$lineCount = @(Get-Content -LiteralPath .github/workflows/_shell-coverage.yml).Count; "LINES=$lineCount"`; `$count = { param([string] $Token) (Select-String -LiteralPath .github/workflows/_shell-coverage.yml -SimpleMatch -Pattern $Token).Count }; $include = & $count 'include-pattern='; $exclude = & $count 'exclude-pattern'; $outDir = & $count 'artifacts/pester/kcov-codex-web-setup'; $oldUpload = & $count 'path: artifacts/pester/kcov/**'; $baseEnv = & $count 'BASE_SHA: ${{ github.event.pull_request.base.sha }}'; "INCLUDE=$include EXCLUDE=$exclude OUT-DIR=$outDir OLD-UPLOAD=$oldUpload BASE-ENV=$baseEnv"`; VERDICT(`$yamlExit -eq 0 -and $yamlSteps.Count -eq 1 -and $yamlSteps[0] -eq 11 -and $numstat.Count -eq 1 -and $numstat[0] -match '^35\t0\t' -and $lineCount -eq RECORDED(P0-T5 WORKFLOW count) + 35 -and $include -eq 1 -and $exclude -eq 0 -and $outDir -eq 4 -and $oldUpload -eq 1 -and $baseEnv -eq 1`).
      Acceptance: EXIT_CODE 0; `YAML-EXIT=0`, `YAML-STEPS=11`, `YAML-STEP-COUNT=11`, and the `YAML-NAMES=` line recorded (the name order is gated by W824-1 in P5-T8, not by this task); numstat `35	0` (no existing line changed); `LINES=` equal to the P0-T5 WORKFLOW count plus 35; `INCLUDE=1 EXCLUDE=0 OUT-DIR=4 OLD-UPLOAD=1 BASE-ENV=1` (OUT-DIR counts the `out_dir=` line, the two Gate-step paths, and the new upload path). The `$` characters in the BASE-ENV token are literal because the token is single-quoted.
- [x] [P5-T7] Create WT with the Write tool from Appendix B5, verbatim, and record FEATURE/evidence/other/r2-p5-t7.TS.md.
      Commands: PARSE-CHECK(tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1); `$tests = (Select-String -LiteralPath tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1 -CaseSensitive -Pattern "^\s+It 'W824-\d+ ").Count; $temp = (Select-String -LiteralPath tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1 -Pattern 'TestDrive|New-TemporaryFile|GetTempPath|Out-File|Set-Content').Count; "TESTS=$tests TEMP=$temp"`; `$lineCount = @(Get-Content -LiteralPath tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1).Count; "LINES=$lineCount"`; `$status = @(git status --porcelain --untracked-files=all -- tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1); $status`; VERDICT(`@($e).Count -eq 0 -and $tests -eq 6 -and $temp -eq 0 -and $lineCount -le 500 -and $status.Count -eq 1 -and $status[0].StartsWith('?? ')`).
      Acceptance: EXIT_CODE 0; `PARSE-ERRORS=0`; `TESTS=6 TEMP=0`; `LINES=` at most 500; one `??` status line.
- [x] [P5-T8] Run WT in full and record FEATURE/evidence/other/r2-p5-t8.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1') -JUnitPath '$Scratch/r2-wt.junit.xml' -ExpectPassed 6 -ExpectFailed 0 -RequirePassed @('W824-1', 'W824-3', 'W824-5'); exit `$LASTEXITCODE"; $LASTEXITCODE ``.
      Acceptance: exit 0; `TOTALS` prints `passed=6 failed=0`; `EXPECTATION-MISMATCHES=0`; no `CONTAINER-ERROR:` line. W824-5 reads SETUP after P5-T1, so it confirms that the six gated functions are each defined once. A failure is fixed in WORKFLOW (re-running P5-T6) or SETUP (re-running P5-T1), never by changing a test.

### Phase 6 — Bundle Mirrors and Parity

- [x] [P6-T1] Copy every bundle file of MIRROR-PAIRS from its source with `Copy-Item -Force` lines, verify identity, run the bundle syntax check, and record FEATURE/evidence/other/r2-p6-t1.TS.md.
      Commands: `Copy-Item -LiteralPath .claude/hooks/hook-command-raw-invocation.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1 -Force`; `Copy-Item -LiteralPath .codex/hooks/hook-command-raw-invocation.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1 -Force`; `Copy-Item -LiteralPath .claude/hooks/hook-command-invocation.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 -Force`; `Copy-Item -LiteralPath .codex/hooks/hook-command-invocation.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 -Force`; `Copy-Item -LiteralPath .claude/hooks/enforce-epic-worktree-removal-gate.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 -Force`; `Copy-Item -LiteralPath .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -Force`; `Copy-Item -LiteralPath .codex/hooks/enforce-epic-worktree-removal-gate.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 -Force`; `Copy-Item -LiteralPath .codex/codex-web-setup.sh -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh -Force`; IDENTITY-LOOP; SH-CHECK('.codex/codex-web-setup.sh', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh'); VERDICT(`$pairs.Count -eq 10 -and $unequal -eq 0 -and $worst -eq 0`).
      Acceptance: EXIT_CODE 0; ten lines ending `EQUAL=True`; `PAIRS=10 UNEQUAL=0`; three `SYNTAX-EXIT=0` lines.
- [x] [P6-T2] Run PARITY-PYTEST and PYG after the mirror edits and record FEATURE/evidence/other/r2-p6-t2.TS.md.
      Commands: PARITY-PYTEST (both of its lines); `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q -rfE *> "$Scratch/r2-pyg.log"; $pygExit = $LASTEXITCODE; "PYG-EXIT=$pygExit"; $pygSummary = @(Select-String -LiteralPath "$Scratch/r2-pyg.log" -Pattern '^\d+ (passed|failed|errors?)\b' | ForEach-Object { $_.Line }); $pygSummary`; VERDICT(`$p510 -and $pygExit -eq 0 -and @($pygSummary | Where-Object { $_ -match '^40 passed\b' }).Count -eq 1`).
      Acceptance: EXIT_CODE 0; `ISSUE-510-BRANCH=True`; `PYG-EXIT=0` and the `-q` summary line `40 passed` (no `=` padding), which includes the SETUP and bundle-copy nodes of `test_surface_does_not_hard_code_solution_file`.

### Phase 7 — Pass-After Verification and Criterion Re-verification

- [x] [P7-T1] Run every Issue824 test in S1, S2, S6, S7, S8, U1, and U2 after the fix and record FEATURE/evidence/regression-testing/r2-pass-after-pester.TS.md.
      Command: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' ISSUE824-PATHS -JUnitPath '$Scratch/r2-pass-after-pester.junit.xml' -Tag 'Issue824' -ExpectPassed 243 -ExpectFailed 0 FIX-SET; exit `$LASTEXITCODE"; $LASTEXITCODE `` (ISSUE824-PATHS and FIX-SET written out in full).
      Acceptance: exit 0; `TOTALS` prints `passed=243 failed=0`; `EXPECTATION-MISMATCHES=0`; no `CONTAINER-ERROR:` line; every P1-T10 failing name appears as `PASSED:` in every suite that carries it (FIX-SET; a missing name makes A2 exit 255). The artifact lists every `PASSED:` line.
- [x] [P7-T2] Run every test in `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` without coverage (the suite selection of the `poshqc / PowerShell hook suites (Linux)` job, run locally on Windows) and record FEATURE/evidence/regression-testing/r2-hook-suites-full.TS.md. Run in the background and wait for completion.
      Commands: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks') -JUnitPath '$Scratch/r2-hook-suites.junit.xml' -ExpectFailed 0 -MinPassed 243; exit `$LASTEXITCODE" *> "$Scratch/r2-hook-suites.log"; $LASTEXITCODE ``; `Select-String -LiteralPath "$Scratch/r2-hook-suites.log" -Pattern '^(TOTALS|FAILED:|CONTAINER-ERROR:|EXPECTATION-MISMATCH)' | ForEach-Object { $_.Line }`.
      Acceptance: exit 0; `TOTALS` prints `failed=0` and a `passed=` value of at least 243; no `FAILED:`, `CONTAINER-ERROR:`, or `EXPECTATION-MISMATCH:` line. This run covers every pre-existing wrapper deny pin (AC-16), the cycle-0 Issue824 rows of the pr-author, validate-bash, preimplementation, and epic-merge suites (AC-17 to AC-21), the signature pins (AC-29), and the Addendum 2 rows (AC-34). A PRE-EXISTING-FAILURE is recorded and stops the plan for a caller decision; any other failure is fixed in a production file of this plan (then the dependent copies are re-made), never by editing an existing assertion.
- [x] [P7-T3] Re-verify AC-1 and AC-2 and record FEATURE/evidence/qa-gates/r2-ac1-ac2.TS.md.
      Commands: `$exits = @(); foreach ($f in @('.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1')) { & "$Scratch/resolver-ast-check.ps1" -Path $f; "RESOLVER-AST-EXIT=$LASTEXITCODE"; $exits += $LASTEXITCODE }`; `foreach ($f in @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1')) { & "$Scratch/raw-predicate-ast-check.ps1" -Path $f; "PREDICATE-AST-EXIT=$LASTEXITCODE"; $exits += $LASTEXITCODE }`; `$hits = @(Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern 'Test-CommandLineRawContainment'); $definitions = @($hits | Where-Object { $_.Filename -eq 'hook-command-invocation.ps1' -and $_.Line -match '^function Test-CommandLineRawContainment' }).Count; $callers = @($hits | Where-Object { $_.Filename -eq 'hook-command-invocation.ps1' -and $_.Line -match 'return \(Test-CommandLineRawContainment' }).Count; "CONTAINMENT-HITS=$($hits.Count) DEFINITIONS=$definitions MENTION-CALLERS=$callers"`; RELAY(`($exits | Measure-Object -Maximum).Maximum`, `$hits.Count -eq 4 -and $definitions -eq 2 -and $callers -eq 2`).
      Acceptance: EXIT_CODE 0 (the largest of the four AST exit codes; A3 and A5 exit 1 on any violation); each A3 run prints `RAWINVOCATION=1 RAWCONTAINMENT=0`; each A5 run prints `WORDPRESENT=1 SEQUENCEMATCH=0`; `CONTAINMENT-HITS=4 DEFINITIONS=2 MENTION-CALLERS=2` (the definition and the `Test-CommandLineMention` caller on each surface); the RELAY line reports 255 when the containment counts differ. Order independence is evidenced by `R824-P26` to `R824-P30` in P7-T1.
- [x] [P7-T4] Re-verify AC-22 and record FEATURE/evidence/qa-gates/r2-ac22.TS.md.
      Commands: `& "$Scratch/phrase-scan.ps1" -Root @('.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources'); $scanExit = $LASTEXITCODE; "PHRASE-SCAN-EXIT=$scanExit"`; `$copies = @('.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1'); $rows = @(foreach ($f in $copies) { "$((Select-String -LiteralPath $f -SimpleMatch -Pattern 'whole tokens').Count)/$((Select-String -LiteralPath $f -SimpleMatch -Pattern 'ordered sequence').Count)/$((Select-String -LiteralPath $f -SimpleMatch -Pattern 'worktree-removal gates').Count)" }); "WHOLE-ORDERED-CALLERS=$($rows -join ',')"`; RELAY(`$scanExit`, `($rows -join ',') -eq '3/0/2,3/0/2,3/0/2,3/0/2'`).
      Acceptance: EXIT_CODE 0 with `HITS=0` (A4 exits 1 on any hit); `WHOLE-ORDERED-CALLERS=3/0/2,3/0/2,3/0/2,3/0/2` (on each of the four copies, three lines state the whole-token requirement, none states an ordered sequence, and the two hard-deny caller lists that name the worktree-removal gates remain, D4); the RELAY line reports 255 otherwise.
- [x] [P7-T5] Verify test integrity (only the D5 lines changed in existing tests) and record FEATURE/evidence/qa-gates/r2-test-integrity.TS.md.
      Commands: `$numstat = @(git diff --numstat BASE_SHA -- tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/dev_tools tests/scripts/dev-tools tests/scripts/workflows tests/shell tests/fixtures/codex_web_setup); $numstat`; `$status = @(git status --porcelain --untracked-files=all -- tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/dev_tools tests/scripts/dev-tools tests/scripts/workflows tests/shell tests/fixtures/codex_web_setup); $status`; `$expectedDeleted = @{ 'tests/shell/test_codex_web_setup_codex_copy.bats' = 0; 'tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt' = 0; 'tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1' = 0; 'tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1' = 0; 'tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1' = 0; 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1' = 0; 'tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1' = 2; 'tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1' = 2; 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1' = 2; 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1' = 2; 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1' = 2; 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1' = 7; 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1' = 7 }; $badDeletes = @($numstat | Where-Object { $parts = $_ -split '\t'; -not $expectedDeleted.ContainsKey($parts[2]) -or [int]$parts[1] -ne $expectedDeleted[$parts[2]] }); $named = @(@($numstat | ForEach-Object { ($_ -split '\t')[2] }) + @($status | Where-Object { $_.StartsWith('?? ') } | ForEach-Object { $_.Substring(3) }) | Select-Object -Unique); $expected = @($expectedDeleted.Keys); $setDiff = @(Compare-Object -ReferenceObject $expected -DifferenceObject $named); "NAMED=$($named.Count) BAD-DELETES=$($badDeletes.Count) SET-DIFFERENCES=$($setDiff.Count)"`; VERDICT(`$expected.Count -eq 13 -and $named.Count -eq 13 -and $badDeletes.Count -eq 0 -and $setDiff.Count -eq 0`).
      Acceptance: EXIT_CODE 0 and `NAMED=13 BAD-DELETES=0 SET-DIFFERENCES=0`: the numstat lists exactly the nine edited test files with the D5 deleted counts (S1 and S2 0; S3, S3X, S6, S7, and S8 2; U1 and U2 7), plus the four new test-tree files (BATS, FIXTURE, GT, WT) with 0 deleted lines if committed; the status command lists those four as untracked if not committed. Together the two commands name exactly these 13 files. (The four new files carry an expected deleted count of 0, so a committed new file is not reported as a bad delete.)
- [x] [P7-T6] Re-derive the resolver call-site inventory and append a cycle-2 addendum to the AC-17 audit record; record FEATURE/evidence/other/r2-call-site-derivation.TS.md.
      Commands, in step script SCRATCH/steps/r2-p7-t6.ps1: `Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '" | ForEach-Object { "$(Resolve-Path -LiteralPath $_.Path -Relative):$($_.LineNumber)" }`; `$callSites = (Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '").Count; $callFiles = @(Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '" | Select-Object -ExpandProperty Path -Unique).Count; "CALL-SITES=$callSites FILES=$callFiles"`; VERDICT(`$callSites -eq 37 -and $callFiles -eq 13`). Then, with the Edit tool, append to FEATURE/evidence/other/containment-path-hook-audit.md a section headed `## Remediation cycle 2 addendum (issue #824)` containing `Timestamp:`, the `CALL-SITES=37 FILES=13` line, the statement that R2 now classifies a wrapper-led or substitution segment when the command word and every subcommand element occur as whole tokens in any order (so every R2 caller in the audit table classifies the review-pass-2 forms Y1, Y2, Y3, and Y5), the statement that the three worktree-removal gates now deny every R2-classified removal from which exactly one literal operand is not read, with or without a checkpoint record (the cycle-1 `NoOperand` allow is removed), and the covering tests `P824-D16` to `P824-D19`, `A824-X1` to `A824-X10`, `A824-WT6`, `A824-WT10`, and `A824-WT11-1` to `A824-WT11-2`.
      Then, in step script SCRATCH/steps/r2-p7-t6-check.ps1: `$absent = @(foreach ($t in @('Remediation cycle 2 addendum', 'CALL-SITES=37', 'A824-WT11-2', 'P824-D19')) { if ((Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/other/containment-path-hook-audit.md -SimpleMatch -Pattern $t).Count -lt 1) { $t } }); "ABSENT-TOKENS=$($absent.Count)"; $absent`; VERDICT(`$absent.Count -eq 0`).
      Acceptance: the first script prints `CALL-SITES=37 FILES=13`; the second prints `ABSENT-TOKENS=0`; both exit 0, and the artifact's `EXIT_CODE:` is the larger of the two process exit codes. The audit file is not this task's artifact, so the check's recorded `Command:` line does not enter the file it searches.
- [x] [P7-T7] Re-verify AC-23 and AC-29 and record FEATURE/evidence/qa-gates/r2-ac23-ac29.TS.md.
      Commands: `$pairEqual = @(foreach ($p in @(@('.claude/hooks/hook-command-invocation.ps1', '.codex/hooks/hook-command-invocation.ps1'), @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1'))) { (Get-FileHash -LiteralPath $p[0]).Hash -eq (Get-FileHash -LiteralPath $p[1]).Hash }); "AC23-EQUAL=$($pairEqual -join ',')"`; `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1') -JUnitPath '$Scratch/r2-s3.junit.xml' -ExpectFailed 0; exit `$LASTEXITCODE"; $s3Exit = $LASTEXITCODE; "S3-EXIT=$s3Exit" ``; `[xml]$j = Get-Content -Raw -LiteralPath "$Scratch/r2-s3.junit.xml"; $pins = @($j.SelectNodes('//testcase') | Where-Object { $_.name -like '*pins the *' -and -not $_.failure }).Count; "PINS=$pins"`; VERDICT(`($pairEqual -join ',') -eq 'True,True' -and $s3Exit -eq 0 -and $pins -eq 5`).
      Acceptance: EXIT_CODE 0; `AC23-EQUAL=True,True`; `S3-EXIT=0` with `failed=0`; `PINS=5` (the signature-pin tests pass; P7-T5 shows S3 changed only on the two D5 lines, neither of which is a pin).
- [x] [P7-T8] Re-verify AC-25 (LEGACY unchanged and passing) and record FEATURE/evidence/qa-gates/r2-ac25.TS.md.
      Commands: `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1') -JUnitPath '$Scratch/r2-legacy.junit.xml' -ExpectFailed 0; exit `$LASTEXITCODE"; $legacyExit = $LASTEXITCODE; "LEGACY-EXIT=$legacyExit" ``; `$lineCount = @(Get-Content -LiteralPath tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1).Count; "LINES=$lineCount"`; `$numstat = @(git diff --numstat BASE_SHA -- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1); "NUMSTAT-LINES=$($numstat.Count)"`; VERDICT(`$legacyExit -eq 0 -and $lineCount -eq RECORDED(P0-T5 LEGACY count) -and $numstat.Count -eq 0`).
      Acceptance: EXIT_CODE 0; `LEGACY-EXIT=0` with `failed=0`; `LINES=` equal to the P0-T5 LEGACY count; `NUMSTAT-LINES=0`.
- [x] [P7-T9] Record the AC-42 local evidence and its pending items and record FEATURE/evidence/qa-gates/r2-ac42-local.TS.md.
      Commands: SH-CHECK('.codex/codex-web-setup.sh', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh'); `$equal = (Get-FileHash -LiteralPath .codex/codex-web-setup.sh).Hash -eq (Get-FileHash -LiteralPath extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh).Hash; "BUNDLE-EQUAL=$equal"`; `$counts = @(@(Get-Content -LiteralPath .codex/codex-web-setup.sh).Count, @(Get-Content -LiteralPath extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh).Count, @(Get-Content -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats).Count); "LINES=$($counts -join ',')"`; `$setupLast = @(Get-Content -LiteralPath .codex/codex-web-setup.sh)[-1]; $guard = @(Select-String -LiteralPath .github/codex/codex-web-setup.sh -SimpleMatch -Pattern 'then main' | ForEach-Object { $_.Line }); $lastIsGuard = $guard.Count -eq 1 -and $setupLast -ceq $guard[0]; "SETUP-LAST-IS-GUARD=$lastIsGuard"`; `$tests = (Select-String -LiteralPath tests/shell/test_codex_web_setup_codex_copy.bats -CaseSensitive -Pattern '^@test "C824-\d+ ').Count; "BATS-TESTS=$tests"`; VERDICT(`$worst -eq 0 -and $equal -and @($counts | Where-Object { $_ -gt 500 }).Count -eq 0 -and $lastIsGuard -and $tests -eq 15`).
      Content added to the artifact after the output: `AC-42 local criteria: VERIFIED` for safe-to-source (guard), byte identity, `sh -n` on both copies, line counts, the 15 BATS cases with their static traceability (P5-T2), the gate logic (r2-p5-t5, 15 passed), and the workflow invariants (r2-p5-t8, 6 passed); `AC-42 bats pass: PENDING CI - shell-coverage / Shell Coverage (Bats + kcov), steps Run shell-qc test with coverage and Measure .codex/codex-web-setup.sh coverage with kcov (issue 824), on the PR head`; `AC-42 kcov changed-function coverage: PENDING CI - step Gate .codex/codex-web-setup.sh changed-function coverage (issue 824) on the PR head pull_request run (D13, P9-T4)`.
      Acceptance: EXIT_CODE 0; three `SYNTAX-EXIT=0` lines; `BUNDLE-EQUAL=True`; every `LINES=` value at most 500; `SETUP-LAST-IS-GUARD=True`; `BATS-TESTS=15`; the three status lines are present.

### Phase 8 — Final QC Loop (Full Repository Toolchain)

Loop rule: the loop is the repository's seven-stage order across the languages in scope: formatting (P8-T1 PowerShell, which includes GATE, GT, and WT; P8-T5 Python; P8-T9 TypeScript); linting (P8-T2, P8-T6, P8-T10); type checking (P8-T7 Python, P8-T11 TypeScript; PowerShell and bash have none); tests with coverage (P8-T3 and P8-T4, P8-T8, P8-T12), which include the architecture-boundary, contract/schema (parity and manifest suites inside pytest and Jest, and the WT workflow invariants), and integration suites the repository defines; then the shell syntax check and the WORKFLOW static checks (P8-T13). Run the tasks in this order: P8-T1, P8-T5, P8-T9, P8-T2, P8-T6, P8-T10, P8-T7, P8-T11, P8-T3, P8-T4, P8-T8, P8-T12, then P8-T13 to P8-T18. If any task fails, or the P8-T1 direct format run reports a `Formatted:` line, fix the cause, re-make every copy whose source changed (P2-T3, P4-T2, P6-T1), and restart from P8-T1. Each re-run writes a new artifact with a new TS; the artifacts of the last clean pass gate. Exceptions: unequal `TREE-DIGEST=` values around an MCP route step stop the plan for a caller decision without a restart; a P8-T17 match is fixed inside FEATURE only and P8-T17 alone is re-run, because no file in SCOPE-PATHS changes.

- [x] [P8-T1] PowerShell format: the direct whole-worktree format in write mode (gating run), then the MCP route step bracketed by TREE-DIGEST; record FEATURE/evidence/qa-gates/r2-poshqc-format.TS.md.
      Commands, in order: (1) SCRATCH/steps/r2-p8-t1.ps1: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path' *> "$Scratch/r2-format-final.log"; $formatExit = $LASTEXITCODE; "FORMAT-EXIT=$formatExit"`; `$formatted = (Select-String -LiteralPath "$Scratch/r2-format-final.log" -Pattern '^Formatted: ').Count; "FORMATTED=$formatted"`; `$already = (Select-String -LiteralPath "$Scratch/r2-format-final.log" -Pattern '^Already formatted: ').Count; "ALREADY-FORMATTED=$already"`; TREE-DIGEST; VERDICT(`$formatExit -eq 0 -and $formatted -eq 0 -and $already -gt 0`); (2) `mcp__drm-copilot__run_poshqc_format` (route step); (3) SCRATCH/steps/r2-p8-t1-after.ps1 containing A0, TREE-DIGEST, and VERDICT(`$treeDigest -eq RECORDED(step script (1) TREE-DIGEST)`).
      Acceptance: the top-level `EXIT_CODE:` is the larger of the exit codes of step scripts (1) and (3), and is 0; `FORMAT-EXIT=0`; `FORMATTED=0` and `ALREADY-FORMATTED=` greater than 0 (on a clean tree every file logs `Already formatted: <path>`; a `Formatted: <path>` line means a rewrite, which restarts the loop); `MCP_ROUTE:` recorded; the two `TREE-DIGEST=` values are equal.
- [x] [P8-T2] PowerShell analyze: the direct whole-worktree analysis (gating run), then the MCP route step bracketed by TREE-DIGEST; record FEATURE/evidence/qa-gates/r2-poshqc-analyze.TS.md.
      Commands, in order: (1) SCRATCH/steps/r2-p8-t2.ps1: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r2-analyze-final.log"; $analyzeExit = $LASTEXITCODE; "ANALYZE-EXIT=$analyzeExit"`; `$passLine = (Select-String -LiteralPath "$Scratch/r2-analyze-final.log" -SimpleMatch -Pattern 'PSScriptAnalyzer passed: no findings under').Count; "PASS-LINE=$passLine"`; TREE-DIGEST; VERDICT(`$analyzeExit -eq 0 -and $passLine -eq 1`); (2) `mcp__drm-copilot__run_poshqc_analyze`; (3) SCRATCH/steps/r2-p8-t2-after.ps1 containing A0, TREE-DIGEST, and VERDICT(`$treeDigest -eq RECORDED(step script (1) TREE-DIGEST)`).
      Acceptance: top-level `EXIT_CODE:` 0 (the larger of scripts (1) and (3)); `ANALYZE-EXIT=0` and `PASS-LINE=1` (zero findings); `MCP_ROUTE:` recorded; the two `TREE-DIGEST=` values are equal.
- [x] [P8-T3] PowerShell tests with coverage: the MCP route step bracketed by TREE-DIGEST, then the direct full Pester run (gating run, last); record FEATURE/evidence/qa-gates/r2-poshqc-test.TS.md. Run the second step script in the background and wait for completion.
      Commands, in order: (1) SCRATCH/steps/r2-p8-t3.ps1 containing A0 and TREE-DIGEST; (2) `mcp__drm-copilot__run_poshqc_test` with scan folders `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`; (3) SCRATCH/steps/r2-p8-t3-after.ps1 containing A0, TREE-DIGEST, then `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r2-pester-final.log"; $testExit = $LASTEXITCODE; "PESTER-EXIT=$testExit"`; `Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination "$Scratch/r2-final-coverage.xml" -Force -ErrorAction Stop`; `[xml]$j = Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $tests = [int]$j.testsuites.tests; $failures = [int]$j.testsuites.failures; $errors = [int]$j.testsuites.errors; "tests=$tests failures=$failures errors=$errors"; $j.SelectNodes('//testcase[failure]') | ForEach-Object { "FAILED: $($_.name)" }`; VERDICT(`$treeDigest -eq RECORDED(step script (1) TREE-DIGEST) -and $testExit -eq 0 -and $failures -eq 0 -and $errors -eq 0 -and $tests -ge RECORDED(P0-T13 tests) + 73`).
      Acceptance: top-level `EXIT_CODE:` is the exit code of step script (3), and is 0; `MCP_ROUTE:` recorded; the two `TREE-DIGEST=` values are equal; `PESTER-EXIT=0`; `failures=0 errors=0` and a `tests=` value at least the P0-T13 value plus 73 (the 52 D9 new rows plus the 15 GT and 6 WT tests); no `FAILED:` line, except a PRE-EXISTING-FAILURE, which is recorded and stops the plan for a caller decision.
- [x] [P8-T4] Derive post-change PowerShell coverage and the delta; record FEATURE/evidence/qa-gates/r2-coverage-delta.TS.md (AC-26, AC-33).
      Command: `& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r2-final-coverage.xml" -BaseSha 'BASE_SHA' COV-TARGETS-FINAL -FailBelow 85; $LASTEXITCODE` (COV-TARGETS-FINAL written out in full).
      Acceptance: exit 0 and `GATE-FAILED=False` (with `-FailBelow 85`, A1 exits 1 on any `ABSENT` or `SOURCE-ABSENT` line, a pct below 85, or a non-empty `UNCOVERED-CHANGED` list); `Output Summary:` records the P0-T14 baseline values, the post-change `COV TOTAL`, and eight post-change per-file lines, each numeric (GATE's baseline is recorded as `N/A - new file`). Pass conditions: each of the eight pct values is at least 85; each `UNCOVERED-CHANGED` line prints `NONE` (new/changed-code coverage: every changed executable line in CLAUDE-RAW, CODEX-RAW, and the three gates is covered, every executable line of GATE is covered, and the CLAUDE-INV and CODEX-INV changes are comment lines with no executable line). A failing condition is fixed by adding a test case that drives the uncovered lines, then the loop restarts from P8-T1.
- [x] [P8-T5] Python format check; record FEATURE/evidence/qa-gates/r2-black.TS.md.
      Commands: `poetry run black --check . *> "$Scratch/r2-black-final.log"; $blackExit = $LASTEXITCODE; "BLACK-EXIT=$blackExit"`; `$reformat = @(Select-String -LiteralPath "$Scratch/r2-black-final.log" -Pattern '^would reformat ' | ForEach-Object { $_.Line }); "WOULD-REFORMAT=$($reformat.Count)"`; `$unchanged = @(Select-String -LiteralPath "$Scratch/r2-black-final.log" -Pattern 'would be left unchanged' | ForEach-Object { $_.Line }); $unchanged`; RELAY(`$blackExit`, `$unchanged.Count -eq 1 -and (($blackExit -eq 0 -and $reformat.Count -eq 0) -or (RECORDED(P0-T15 exit) -ne 0 -and $reformat.Count -le RECORDED(P0-T15 would-reformat count)))`).
      Acceptance: EXIT_CODE 0, `WOULD-REFORMAT=0`, and black's summary line containing `would be left unchanged` (a clean `--check` run prints `All done!` then `N files would be left unchanged.`); or, only if P0-T15 recorded a non-zero exit, the relayed non-zero exit with `ExpectedExitCode:` equal to it and a count not above the P0-T15 count (no Python file changes in this plan). Any other result relays 255. `black --check` never rewrites.
- [x] [P8-T6] Python lint; record FEATURE/evidence/qa-gates/r2-ruff.TS.md.
      Commands: `poetry run ruff check . *> "$Scratch/r2-ruff-final.log"; $ruffExit = $LASTEXITCODE; "RUFF-EXIT=$ruffExit"`; `$summary = @(Select-String -LiteralPath "$Scratch/r2-ruff-final.log" -Pattern '^(All checks passed!|Found \d+ error)' | ForEach-Object { $_.Line }); $summary`; `$found = if ("$summary" -match 'Found (\d+) error') { [int]$Matches[1] } else { 0 }; "FOUND=$found"`; RELAY(`$ruffExit`, `($ruffExit -eq 0 -and "$summary" -like 'All checks passed!*') -or (RECORDED(P0-T16 exit) -ne 0 -and $found -le RECORDED(P0-T16 Found count))`).
      Acceptance: EXIT_CODE 0 with `All checks passed!`; or, only if P0-T16 was non-zero, the relayed non-zero exit with `ExpectedExitCode:` equal to it and a `Found` count not above the P0-T16 count. Any other result relays 255.
- [x] [P8-T7] Python type check; record FEATURE/evidence/qa-gates/r2-pyright.TS.md.
      Commands: `poetry run pyright *> "$Scratch/r2-pyright-final.log"; $pyrightExit = $LASTEXITCODE; "PYRIGHT-EXIT=$pyrightExit"`; `$summary = @(Select-String -LiteralPath "$Scratch/r2-pyright-final.log" -Pattern '^\d+ errors?, \d+ warnings?' | ForEach-Object { $_.Line }); $summary`; `$errorCount = if ("$summary" -match '^(\d+) errors?') { [int]$Matches[1] } else { -1 }; "ERRORS=$errorCount"`; RELAY(`$pyrightExit`, `$summary.Count -eq 1 -and (($pyrightExit -eq 0 -and $errorCount -eq 0) -or (RECORDED(P0-T17 exit) -ne 0 -and $errorCount -ge 0 -and $errorCount -le RECORDED(P0-T17 error count)))`).
      Acceptance: EXIT_CODE 0 with `0 errors`; or, only if P0-T17 was non-zero, the relayed non-zero exit with `ExpectedExitCode:` equal to it and an error count not above the P0-T17 count. Any other result relays 255.
- [x] [P8-T8] Python tests with coverage; record FEATURE/evidence/qa-gates/r2-pytest.TS.md. Run in the background and wait for completion.
      Commands: `poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r2-pytest-final.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit"`; `$lines = @(Select-String -LiteralPath "$Scratch/r2-pytest-final.log" -Pattern '^(TOTAL\s|FAILED |ERROR |\d+ (passed|failed|errors?)\b)' | ForEach-Object { $_.Line }); $lines`; `$failedNodes = @($lines | Where-Object { $_ -match '^(FAILED|ERROR) (\S+)' } | ForEach-Object { ($_ -split ' ')[1] }); $allowed = @(RECORDED(P0-T18 BASELINE-PYTEST-FAILURES node ids)); if ((Select-String -LiteralPath "$Scratch/r2-pytest-final.log" -SimpleMatch -Pattern '.claude/state/').Count -gt 0) { $allowed += 'tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts' }; $unexpected = @($failedNodes | Where-Object { $allowed -notcontains $_ }); $summary = @($lines | Where-Object { $_ -match '^\d+ (passed|failed|errors?)\b' })[-1]; $passed = if ("$summary" -match '(\d+) passed') { [int]$Matches[1] } else { 0 }; "UNEXPECTED-FAILURES=$($unexpected.Count) PASSED=$passed"; $unexpected | ForEach-Object { "UNEXPECTED: $_" }`; RELAY(`$pytestExit`, `@($lines | Where-Object { $_ -match '^TOTAL\s.*\d+%' }).Count -eq 1 -and $unexpected.Count -eq 0 -and $passed -ge RECORDED(P0-T18 passed count) -and ($pytestExit -eq 0 -or ($pytestExit -eq 1 -and $failedNodes.Count -gt 0))`).
      Acceptance: EXIT_CODE 0; or EXIT_CODE 1 where every `FAILED ` and `ERROR ` node is a PRE-EXISTING-FAILURE or the ISSUE-510-BRANCH test (`UNEXPECTED-FAILURES=0`), recorded with `ExpectedExitCode: 1`. Any other result, including a missing `TOTAL` line or a passed count below the P0-T18 count, relays 255. With `-q` the summary line has no `=` padding. The `TOTAL` percentage is recorded beside the P0-T18 value. Python new-code coverage: `N/A - no production file of this language changes`.
- [x] [P8-T9] TypeScript format check; record FEATURE/evidence/qa-gates/r2-prettier.TS.md.
      Commands: `Push-Location extensions/drm-copilot; npx prettier --check 'src/**/*.ts' 'test/**/*.ts' '*.json' '*.cjs' *> "$Scratch/r2-prettier-final.log"; $code = $LASTEXITCODE; Pop-Location; "PRETTIER-EXIT=$code"; $matched = @(Select-String -LiteralPath "$Scratch/r2-prettier-final.log" -Pattern '(All matched files use Prettier code style!|\[warn\])' | ForEach-Object { $_.Line }); $matched`; `$warn = @($matched | Where-Object { $_ -match '\[warn\]' }); $clean = @($matched | Where-Object { $_ -like '*All matched files use Prettier code style!*' }).Count; "WARN-LINES=$($warn.Count) CLEAN-LINE=$clean"`; RELAY(`$code`, `($code -eq 0 -and $clean -eq 1) -or (RECORDED(P0-T19 PRETTIER-EXIT) -ne 0 -and @(Compare-Object -ReferenceObject @(RECORDED(P0-T19 [warn] lines)) -DifferenceObject $warn).Count -eq 0)`).
      Acceptance: EXIT_CODE 0 with `PRETTIER-EXIT=0` and `All matched files use Prettier code style!`; or, only if P0-T19 was non-zero, the relayed exit with `ExpectedExitCode:` equal to it and a `[warn]` set equal to the P0-T19 set. Any other result relays 255.
- [x] [P8-T10] TypeScript lint; record FEATURE/evidence/qa-gates/r2-eslint.TS.md.
      Commands: `npm --prefix extensions/drm-copilot run lint *> "$Scratch/r2-eslint-final.log"; $lintExit = $LASTEXITCODE; "LINT-EXIT=$lintExit"`; `$problemLines = (Select-String -LiteralPath "$Scratch/r2-eslint-final.log" -Pattern '\d+ problems?').Count; "PROBLEM-LINES=$problemLines"`; RELAY(`$lintExit`, `($lintExit -eq 0 -and $problemLines -eq 0) -or (RECORDED(P0-T20 exit) -ne 0 -and $lintExit -eq RECORDED(P0-T20 exit) -and $problemLines -eq RECORDED(P0-T20 problem-line count))`).
      Acceptance: EXIT_CODE 0 and `PROBLEM-LINES=0`; or, only if P0-T20 was non-zero, the same exit and count as P0-T20 with `ExpectedExitCode:` equal to that exit. Any other result relays 255.
- [x] [P8-T11] TypeScript type check; record FEATURE/evidence/qa-gates/r2-tsc.TS.md.
      Commands: `npm --prefix extensions/drm-copilot run typecheck *> "$Scratch/r2-tsc-final.log"; $tscExit = $LASTEXITCODE; "TSC-EXIT=$tscExit"`; `$tsErrors = (Select-String -LiteralPath "$Scratch/r2-tsc-final.log" -Pattern 'error TS\d+').Count; "TS-ERRORS=$tsErrors"`; RELAY(`$tscExit`, `($tscExit -eq 0 -and $tsErrors -eq 0) -or (RECORDED(P0-T21 exit) -ne 0 -and $tsErrors -eq RECORDED(P0-T21 error TS count))`).
      Acceptance: EXIT_CODE 0 and `TS-ERRORS=0`; or, only if P0-T21 was non-zero, the same count as P0-T21 with `ExpectedExitCode:` equal to the relayed exit. Any other result relays 255.
- [x] [P8-T12] TypeScript tests with coverage; record FEATURE/evidence/qa-gates/r2-jest.TS.md. Run in the background and wait for completion.
      Commands: `npm --prefix extensions/drm-copilot run test:coverage *> "$Scratch/r2-jest-final.log"; $jestExit = $LASTEXITCODE; "JEST-EXIT=$jestExit"`; `$lines = @(Select-String -LiteralPath "$Scratch/r2-jest-final.log" -Pattern '^(Tests:|Test Suites:|Lines\s*:|Branches\s*:|Statements\s*:|\s*●)' | ForEach-Object { $_.Line }); $lines`; `$failing = @($lines | Where-Object { $_ -match '^\s*●' } | ForEach-Object { $_.Trim() } | Select-Object -Unique); $unexpected = @($failing | Where-Object { @(RECORDED(P0-T22 BASELINE-JEST-FAILURES lines)) -notcontains $_ }); "FAILING=$($failing.Count) UNEXPECTED-FAILURES=$($unexpected.Count)"`; RELAY(`$jestExit`, `@($lines | Where-Object { $_ -match '^Lines\s*:\s*[\d.]+%' }).Count -eq 1 -and @($lines | Where-Object { $_ -match '^Branches\s*:\s*[\d.]+%' }).Count -eq 1 -and $unexpected.Count -eq 0 -and ($jestExit -eq 0 -or $failing.Count -gt 0)`).
      Acceptance: EXIT_CODE 0; or a non-zero exit where every failing test is a PRE-EXISTING-FAILURE (`UNEXPECTED-FAILURES=0`), recorded with `ExpectedExitCode:` equal to that exit. Any other result, including a missing `Lines` or `Branches` percentage, relays 255. The numeric `Lines` and `Branches` percentages are recorded beside the P0-T22 values. TypeScript new-code coverage: `N/A - no production file of this language changes`. This run includes `claude-pack-manifest-completeness.test.ts` and `codex-agents-customizations.test.ts`.
- [x] [P8-T13] Shell syntax check of both setup copies, the WORKFLOW static checks, and the shell-QC route record; record FEATURE/evidence/qa-gates/r2-shell-qc.TS.md.
      Commands: SH-CHECK('.codex/codex-web-setup.sh', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh'); YAML-CHECK(r2-yaml-final.log); ACTIONLINT-RUN(r2-actionlint-final.log); `$newMessages = @($actionlintMessages | Where-Object { @(RECORDED(P0-T24 BASELINE-ACTIONLINT-MESSAGES)) -notcontains $_ }); "ACTIONLINT-NEW-MESSAGES=$($newMessages.Count)"`; VERDICT(`$worst -eq 0 -and $yamlExit -eq 0 -and $yamlSteps.Count -eq 1 -and $yamlSteps[0] -eq 11 -and ($actionlintExit -eq 0 -or ($actionlintExit -eq -1 -and $null -eq $actionlint) -or ($actionlintExit -gt 0 -and RECORDED(P0-T24 ACTIONLINT-EXIT) -gt 0 -and $actionlintMessages.Count -gt 0 -and $newMessages.Count -eq 0))`).
      Acceptance: EXIT_CODE 0; three lines print `SYNTAX-EXIT=0`; `YAML-EXIT=0`, `YAML-STEPS=11`, `YAML-STEP-COUNT=11`; and one of: `ACTIONLINT-EXIT=0` (actionlint was on PATH and reported no finding); or a non-zero `ACTIONLINT-EXIT=` where P0-T24 also recorded a non-zero exit and `ACTIONLINT-NEW-MESSAGES=0` (every finding message, compared without its line and column prefix so that a finding is matched by its message rather than its position, is a pre-existing BASELINE-ACTIONLINT-MESSAGES entry; recorded by message); or, as the one authorized skip branch of this task, `ACTIONLINT-EXIT=-1` with the line `ACTIONLINT: UNAVAILABLE - not on PATH; scripts/dev-tools/run-actionlint.ps1 downloads into the untracked tools/actionlint/bin and is not run (D13); WORKFLOW is validated by YAML-CHECK, WT, and the S9 CI run` added to `Output Summary:`. Any other actionlint result (a new finding message, or a non-zero exit with no parseable message) fails the task and is fixed in WORKFLOW (then P5-T6 and P5-T8 are re-run). `Output Summary:` also records the literals `Shell format (shfmt) and lint (shellcheck): N/A locally - .codex/ and .bats files are outside the shell-QC discovery roots (.claude/rules/shell.md Discovery Contract)`, `Shell tests (bats): CI-dependent - shell-coverage / Shell Coverage (Bats + kcov) runs tests/shell on the PR head`, and `Shell coverage (kcov) for .codex/codex-web-setup.sh: CI - Measure and Gate steps of shell-coverage / Shell Coverage (Bats + kcov) on the PR head (D13)`.
- [x] [P8-T14] Identity checks; record FEATURE/evidence/qa-gates/r2-identity.TS.md.
      Commands: IDENTITY-LOOP; VERDICT(`$pairs.Count -eq 10 -and $unequal -eq 0`).
      Acceptance: EXIT_CODE 0; ten lines ending `EQUAL=True`; `PAIRS=10 UNEQUAL=0` (AC-23 and AC-24 identity, and AC-42 bundle identity).
- [x] [P8-T15] Line counts of every changed or new code and test file; record FEATURE/evidence/qa-gates/r2-line-counts.TS.md (AC-28).
      Commands: SCOPE-ARRAY; `$n = @{}; foreach ($f in $scope) { $n[$f] = @(Get-Content -LiteralPath $f -ErrorAction Stop).Count; "$f $($n[$f])" }`; `$over = @(Get-ChildItem .codex/hooks, .claude/hooks -Filter *.ps1 -File | Where-Object { @(Get-Content -LiteralPath $_.FullName).Count -gt 500 }).Count; "HOOKS-OVER-500=$over"`; VERDICT(`$n.Count -eq 31 -and @($n.Values | Where-Object { $_ -gt 500 }).Count -eq 0 -and $n['.claude/hooks/hook-command-raw-invocation.ps1'] -le 320 -and $n['.claude/hooks/hook-command-raw-invocation.ps1'] -eq $n['.codex/hooks/hook-command-raw-invocation.ps1'] -and $n['.claude/hooks/hook-command-invocation.ps1'] -eq $n['.codex/hooks/hook-command-invocation.ps1'] -and $over -eq 0`).
      Acceptance: EXIT_CODE 0; `SCOPE-ARRAY-COUNT=31`; every count is at most 500 (including GATE, GT, WT, and WORKFLOW); CLAUDE-RAW at most 320 and equal to CODEX-RAW; CLAUDE-INV equal to CODEX-INV; `HOOKS-OVER-500=0`.
- [x] [P8-T16] Scope check; record FEATURE/evidence/qa-gates/r2-scope.TS.md.
      Commands: `$tracked = @(git diff --name-only BASE_SHA -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory'); $others = @(git ls-files --others --exclude-standard -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory'); $pre = @(Get-Content -LiteralPath "$Scratch/pre-untracked.txt"); $changed = @(@($tracked) + @($others | Where-Object { $pre -notcontains $_ }) | Sort-Object -Unique); "CHANGED-COUNT=$($changed.Count)"; $changed`; `$status = @(git status --porcelain --untracked-files=all -- .claude/hooks .codex/hooks .codex/codex-web-setup.sh extensions/drm-copilot/resources tests/scripts/claude-hooks tests/scripts/codex-hooks tests/shell tests/fixtures/codex_web_setup .github/workflows scripts/dev-tools tests/scripts/dev-tools tests/scripts/workflows tools); $status`; SCOPE-ARRAY; `$scopeDiff = @(Compare-Object -ReferenceObject $scope -DifferenceObject $changed); $scopeDiff | ForEach-Object { "SCOPE-DIFFERENCE: $($_.SideIndicator) $($_.InputObject)" }; $statusOutside = @($status | Where-Object { $scope -notcontains $_.Substring(3) }); "SCOPE-DIFFERENCES=$($scopeDiff.Count) STATUS-OUTSIDE=$($statusOutside.Count)"`; VERDICT(`$scope.Count -eq 31 -and $changed.Count -eq 31 -and $scopeDiff.Count -eq 0 -and $statusOutside.Count -eq 0`).
      Acceptance: EXIT_CODE 0; `CHANGED-COUNT=31`; `SCOPE-ARRAY-COUNT=31`; `SCOPE-DIFFERENCES=0 STATUS-OUTSIDE=0`. Any other path is recorded as a `SCOPE-DIFFERENCE:` line, exits 1, and stops the plan for a caller decision.
- [x] [P8-T17] Verify that no file in the feature folder carries an absolute host path; record FEATURE/evidence/qa-gates/r2-host-path-scan.TS.md.
      Commands: `$t1 = 'danm' + 'oi'; $t2 = 'app' + 'data'; git grep --untracked -i -l -e $t1 -e $t2 -- docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824; $grepExit = $LASTEXITCODE; "HOSTPATH-GREP-EXIT=$grepExit"`; `$junitCount = @(Get-ChildItem -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824 -Recurse -File -Filter '*.junit.xml').Count; "JUNIT-COUNT=$junitCount"`; `if ($grepExit -ne 1 -or $junitCount -ne 0) { exit 1 }`.
      Acceptance: no file-name line, `HOSTPATH-GREP-EXIT=1`, `JUNIT-COUNT=0`, and EXIT_CODE 0. `-l` prints only file names, so the scan cannot copy a host path into this artifact; the two tokens are assembled at run time and contain no backslash. A match is fixed by replacing the host path in the named artifact under the host-path rule, then this task alone is re-run.
- [x] [P8-T18] Record QC loop completion; record FEATURE/evidence/qa-gates/r2-qc-loop-complete.TS.md.
      Content: `Timestamp:`; the gating artifacts of the last clean pass (P8-T1 to P8-T17); the number of loop passes; `PowerShell type check: N/A - PowerShell has no type-check stage (.claude/rules/powershell.md)`; the numeric PowerShell, Python, and TypeScript coverage headlines from P8-T4, P8-T8, and P8-T12; the three shell literals of P8-T13.
      Commands (the 17 artifact paths substituted): `$listed = @(<the 17 gating artifact paths of P8-T1 to P8-T17, as single-quoted strings>); $missing = @($listed | Where-Object { -not (Test-Path -LiteralPath $_) }); "LISTED=$($listed.Count) MISSING=$($missing.Count)"; $missing`; VERDICT(`$listed.Count -eq 17 -and $missing.Count -eq 0`).
      Acceptance: the artifact exists with every field; EXIT_CODE 0 and `LISTED=17 MISSING=0`.

### Phase 9 — Acceptance-Criteria Check-off and Re-verification

Rule for P9-T2 and P9-T3: a task changes the line beginning `- [ ] AC-n:` in `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` to `- [x] AC-n:` only when every named evidence artifact exists with its acceptance met; its step script, with n substituted, runs `$checked = (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -SimpleMatch -Pattern '- [x] AC-n:').Count; "CHECKED=$checked"` and VERDICT(`$checked -eq 1`), and its acceptance is EXIT_CODE 0 with `CHECKED=1`. Each Phase 9 task appends its lines to FEATURE/evidence/other/r2-ac-checkoff.TS.md, where TS is the value printed by the P9-T1 step script. No criterion text changes.

- [x] [P9-T1] Re-verify every previously checked criterion and append the result to FEATURE/evidence/other/r2-ac-checkoff.TS.md.
      Content: one line per criterion, beginning `RE-VERIFIED AC-<n>:` (n substituted) and naming its evidence: AC-1 (r2-ac1-ac2; r2-pass-after-pester `R824-P26` to `R824-P30`, which carry the words in an order the earlier grammar rejected); AC-2 (r2-ac1-ac2); AC-3 and AC-5 to AC-13 (r2-pass-after-pester `P824-A1`, `P824-A2`, `P824-D1` to `P824-D11`; r2-p2-t4); AC-4 (r2-p2-t2, r2-p2-t3); AC-15 (r2-p4-t7 `N824-1`); AC-16 (r2-p4-t3, r2-p4-t4, r2-p4-t7 `RENAMED-PASSED=2`, r2-test-integrity, r2-hook-suites-full); AC-17 (r2-call-site-derivation and the cycle-2 audit addendum); AC-18 to AC-21 (r2-hook-suites-full); AC-22 (r2-ac22); AC-23 and AC-24 (r2-ac23-ac29, r2-identity, r2-p6-t2); AC-25 (r2-ac25); AC-26 and AC-33 (r2-poshqc-format, r2-poshqc-analyze, r2-poshqc-test, r2-coverage-delta); AC-28 (r2-line-counts); AC-29 (r2-ac23-ac29); AC-30 to AC-32 (r2-pass-after-pester `A824-WT3`, `A824-WT4-1` to `-5`, `A824-WT5-1` to `-5`); AC-34 (r2-hook-suites-full `F824-1` to `F824-3`); AC-35 to AC-38 (r2-p6-t2 PYG `40 passed`); AC-39 (r2-pytest); AC-40 (the cycle-1 check-off evidence named in FEATURE/evidence/other/r1-ac-checkoff.2026-10-03T13-43.md, and r2-scope, which shows `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` unchanged in this cycle); AC-41 (every P8 artifact and r2-qc-loop-complete). A criterion that cannot name a passing artifact is recorded on a line beginning `REGRESSED AC-<n>:`, and its checkbox is changed to `- [ ]`.
      Commands (run after the lines are written; the artifact path is substituted): `$reverified = (Select-String -LiteralPath <artifact> -CaseSensitive -Pattern '^RE-VERIFIED AC-\d+:').Count; $regressedKey = 'REGRE' + 'SSED'; $regressed = (Select-String -LiteralPath <artifact> -CaseSensitive -Pattern ('^' + $regressedKey + ' AC-\d+:')).Count; $checked = (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[x\] AC-\d+:').Count; "REVERIFIED=$reverified REGRESSED-COUNT=$regressed CHECKED=$checked"`; VERDICT(`$reverified -eq 39 -and $regressed -eq 0 -and $checked -eq 39`). Both artifact counts are case-sensitive and anchored at a line start, so neither reads this check's own `Command:` or `Output Summary:` line.
      Acceptance: EXIT_CODE 0 and `REVERIFIED=39 REGRESSED-COUNT=0 CHECKED=39` (AC-1 to AC-13, AC-15 to AC-26, and AC-28 to AC-41).
- [x] [P9-T2] Check off AC-14 (evidence: r2-expect-fail-pester and r2-pass-after-pester, `P824-D16` to `P824-D19` in S1 and S2 asserting `Get-PromotionMcpOnlyGhIssueBlockedReason`; `A824-X1`, `A824-X2`, `A824-X3`, `A824-X4`, `A824-X7`, `A824-X8`, `A824-X10` in S6, S7, and S8; the unchanged prior rows `P824-D8`, `P824-D9`, `P824-D10`, and `P824-A3`; r2-p2-t4; r2-p3-t4).
- [x] [P9-T3] Check off AC-43 (evidence: r2-expect-fail-pester and r2-pass-after-pester `A824-WT6`, `A824-WT10`, `A824-WT11-1`, `A824-WT11-2` in S6, S7, and S8; `A824-WT3` (AC-30 reproduction still allowed) and `A824-WT4-1` to `-5` and `A824-WT5-1` to `-5` (AC-31 gating unchanged); r2-p3-t1 to r2-p3-t4).
- [x] [P9-T4] Record AC-42 as not checked off by this plan and append to FEATURE/evidence/other/r2-ac-checkoff.TS.md.
      Content: one line `PENDING AC-42:` naming r2-ac42-local (local criteria verified), r2-p5-t1, r2-p5-t2, r2-p5-t5, r2-p5-t6, r2-p5-t8, r2-shell-qc, and fail-before-exception, and stating the S9 check-off condition: on the PR head's `pull_request` run of `shell-coverage / Shell Coverage (Bats + kcov)`, whose `headSha` equals the branch head, the steps `Run shell-qc test with coverage`, `Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)`, and `Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)` succeed, and the Gate step log shows six `FUNCTION <name> ... PASS` lines (one per D7 function, each `pct=` at least 85), a `CHANGED-LINES=<n> INSTRUMENTED=<m> UNCOVERED-CHANGED=NONE` line with n greater than 0, and `GATE-FAILED=False`; the orchestrator transcribes those lines with the run URL and `headSha` into FEATURE/evidence/qa-gates/r2-ac42-ci-kcov.<TS>.md (spec AC-42 requires the record under `evidence/qa-gates/`) and then checks AC-42 off. A run that prints `CHANGED-LINES=NOT-CHECKED` (a `push` or `workflow_dispatch` run) does not satisfy AC-42. If the Gate step fails, the S9 response is the D13 known-risk rule (stop and report; no change to the threshold, the function list, or the include pattern).
      Commands: `$pendingKey = 'PENDING' + ' AC-42:'; $pending = (Select-String -LiteralPath <artifact> -CaseSensitive -Pattern ('^' + $pendingKey)).Count; $open = (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -SimpleMatch -Pattern '- [ ] AC-42:').Count; "PENDING-LINES=$pending AC42-UNCHECKED=$open"`; VERDICT(`$pending -eq 1 -and $open -eq 1`).
      Acceptance: EXIT_CODE 0; `PENDING-LINES=1 AC42-UNCHECKED=1`.
- [x] [P9-T5] Write the PR-body callouts to FEATURE/evidence/other/r2-pr-callouts.TS.md.
      Content: `Timestamp:`; one line `CALLOUT: TRADE-ADDENDUM-1-CHANGE-2 | ...` stating that a classified wrapped `git worktree remove` with no extractable literal operand is now denied even when it removes nothing, which departs from Addendum 1 required change 2 in favour of issue requirement 4 (spec `### Cycle 2 design decision` item 2); one line `CALLOUT: TRADE-WHOLE-TOKEN | ...` stating the accepted false-positive class of spec `## Risks & Mitigations` (a wrapped payload naming every command word as a whole token, for example `pwsh -c 'Write-Output "create an issue with gh"'`, is denied by hard-deny callers, as raw containment denied it at the merge base); one line `CALLOUT: AC-42-PENDING | ...` repeating the P9-T4 S9 condition; one line `CALLOUT: CI-SHELL-COVERAGE-STEPS | ...` stating that `.github/workflows/_shell-coverage.yml` gains three steps (a kcov run of the setup script's bats file restricted to `.codex/codex-web-setup.sh`, a PowerShell coverage gate in `scripts/dev-tools/KcovFunctionCoverageGate.ps1` at 85% per changed function with no uncovered changed line on pull requests, and a separate artifact upload) without changing the shell-QC discovery or include roots, and that the gate logic is PowerShell with a Pester suite rather than bash with bats (D13).
      Commands (artifact path substituted): `$callouts = @(Select-String -LiteralPath <artifact> -CaseSensitive -Pattern '^CALLOUT: (TRADE-ADDENDUM-1-CHANGE-2|TRADE-WHOLE-TOKEN|AC-42-PENDING|CI-SHELL-COVERAGE-STEPS) \| \S' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique); "CALLOUTS=$($callouts -join ',')"`; VERDICT(`($callouts -join ',') -eq 'AC-42-PENDING,CI-SHELL-COVERAGE-STEPS,TRADE-ADDENDUM-1-CHANGE-2,TRADE-WHOLE-TOKEN'`).
      Acceptance: EXIT_CODE 0; `CALLOUTS=AC-42-PENDING,CI-SHELL-COVERAGE-STEPS,TRADE-ADDENDUM-1-CHANGE-2,TRADE-WHOLE-TOKEN`.
- [x] [P9-T6] Record AC-27 as pending CI and verify the final checkbox state; append to FEATURE/evidence/other/r2-ac-checkoff.TS.md.
      Commands: `$checked = (Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[x\] AC-\d+:').Count; $open = @(Select-String -LiteralPath docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md -Pattern '^- \[ \] (AC-\d+):' | ForEach-Object { $_.Matches[0].Groups[1].Value }); "CHECKED=$checked OPEN=$($open -join ',')"`; then the P8-T17 commands without their closing `if` line, re-run after every Phase 9 artifact and the spec.md checkbox edits are written; then VERDICT(`$checked -eq 41 -and ($open -join ',') -eq 'AC-27,AC-42' -and $grepExit -eq 1 -and $junitCount -eq 0`).
      Acceptance: EXIT_CODE 0; `CHECKED=41 OPEN=AC-27,AC-42`; the re-run host-path scan prints no file-name line, `HOSTPATH-GREP-EXIT=1`, and `JUNIT-COUNT=0`. The appended line states that AC-27 depends on the `poshqc / PowerShell QC` (`windows-latest`, every suite with coverage) and `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled) jobs of `.github/workflows/_poshqc.yml` and the rest of the repository CI on the PR head, and that AC-27 is checked off at orchestration step S9.

## Appendix — step-script preamble, helper scripts, and new file contents (save verbatim)

A0 step-script preamble, the first lines of every SCRATCH/steps/r2-<task-id>.ps1:

```powershell
param([Parameter(Mandatory)][string] $Worktree)
Remove-Item -Path Env:VIRTUAL_ENV -ErrorAction SilentlyContinue
Set-Location -LiteralPath $Worktree -ErrorAction Stop
$Scratch = (Split-Path -Parent $PSScriptRoot) -replace '\\', '/'
"TS=$(Get-Date -Format yyyy-MM-ddTHH-mm)"
```

A1 `SCRATCH/cov-derive.ps1`:

```powershell
param(
    [Parameter(Mandatory)][string] $CoveragePath,
    [Parameter(Mandatory)][string] $BaseSha,
    [Parameter(Mandatory)][string[]] $Target,
    [double] $FailBelow = -1
)
$ErrorActionPreference = 'Stop'
$gateFailed = $false
[xml]$report = Get-Content -Raw -LiteralPath $CoveragePath
$rootPath = ((Get-Location).Path -replace '\\', '/').TrimEnd('/')
$totalCovered = 0
$totalMissed = 0
foreach ($measured in @($report.report.package | ForEach-Object { $_.class })) {
    $classLine = @($measured.counter | Where-Object { $_.type -eq 'LINE' })
    if ($classLine.Count -gt 0) {
        $totalCovered += [int]$classLine[0].covered
        $totalMissed += [int]$classLine[0].missed
    }
}
if (($totalCovered + $totalMissed) -eq 0) { 'COV TOTAL ABSENT'; exit 1 }
"COV TOTAL covered=$totalCovered missed=$totalMissed pct=$([math]::Round(100.0 * $totalCovered / ($totalCovered + $totalMissed), 2))"
foreach ($relative in $Target) {
    $surface = (Split-Path -Parent $relative) -replace '\\', '/'
    $file = Split-Path -Leaf $relative
    $package = @($report.report.package | Where-Object { ($_.name -replace '\\', '/') -eq "$rootPath/$surface" })
    $class = @($package | ForEach-Object { $_.class } | Where-Object { $_.sourcefilename -eq $file })
    if ($class.Count -ne 1) {
        "COV $relative ABSENT rows=$($class.Count)"
        if ($FailBelow -ge 0) { $gateFailed = $true }
        continue
    }
    $line = @($class[0].counter | Where-Object { $_.type -eq 'LINE' })[0]
    $covered = [int]$line.covered
    $missed = [int]$line.missed
    $pct = if (($covered + $missed) -gt 0) { [math]::Round(100.0 * $covered / ($covered + $missed), 2) } else { 0 }
    "COV $relative covered=$covered missed=$missed pct=$pct"
    if ($FailBelow -ge 0 -and $pct -lt $FailBelow) { $gateFailed = $true }
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    git cat-file -e "$($BaseSha):$relative" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $hunks = git diff --unified=0 $BaseSha -- $relative | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@'
        foreach ($hunk in $hunks) {
            $start = [int]$hunk.Matches[0].Groups[1].Value
            $count = if ($hunk.Matches[0].Groups[2].Success) { [int]$hunk.Matches[0].Groups[2].Value } else { 1 }
            for ($n = $start; $n -lt ($start + $count); $n++) { [void]$changed.Add($n) }
        }
    } else {
        $lineCount = @(Get-Content -LiteralPath $relative).Count
        for ($n = 1; $n -le $lineCount; $n++) { [void]$changed.Add($n) }
    }
    $source = @($package | ForEach-Object { $_.sourcefile } | Where-Object { $_.name -eq $file })
    if ($source.Count -ne 1) {
        "UNCOVERED-CHANGED $relative SOURCE-ABSENT"
        if ($FailBelow -ge 0) { $gateFailed = $true }
        continue
    }
    $uncovered = @(@($source[0].line) | Where-Object { [int]$_.ci -eq 0 -and $changed.Contains([int]$_.nr) } | ForEach-Object { [int]$_.nr })
    if ($FailBelow -ge 0 -and $uncovered.Count -gt 0) { $gateFailed = $true }
    $list = if ($uncovered.Count -gt 0) { $uncovered -join ',' } else { 'NONE' }
    "UNCOVERED-CHANGED $relative $list"
}
"GATE-FAILED=$gateFailed"
exit ([int]$gateFailed)
```

A2 `SCRATCH/issue824-pester.ps1`:

```powershell
param(
    [Parameter(Mandatory)][string[]] $Path,
    [Parameter(Mandatory)][string] $JUnitPath,
    [string[]] $Tag = @(),
    [int] $ExpectPassed = -1,
    [int] $ExpectFailed = -1,
    [int] $MinPassed = 1,
    [string[]] $RequirePassed = @()
)
$ErrorActionPreference = 'Stop'
Import-Module Pester -MinimumVersion 5.0.0
$config = New-PesterConfiguration
$config.Run.Path = $Path
$config.Run.PassThru = $true
$config.Run.Exit = $false
if ($Tag.Count -gt 0) { $config.Filter.Tag = $Tag }
$config.CodeCoverage.Enabled = $false
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = 'JUnitXml'
$config.TestResult.OutputPath = $JUnitPath
$config.Output.Verbosity = 'Normal'
$result = Invoke-Pester -Configuration $config
"TOTALS passed=$($result.PassedCount) failed=$($result.FailedCount) skipped=$($result.SkippedCount) notrun=$($result.NotRunCount) total=$($result.TotalCount)"
foreach ($test in $result.Passed) { "PASSED: $($test.ExpandedName)" }
foreach ($test in $result.Failed) { "FAILED: $($test.ExpandedName)" }
$containerErrors = @($result.Containers | Where-Object { $_.Result -eq 'Failed' -and $_.ErrorRecord.Count -gt 0 })
foreach ($container in $containerErrors) { "CONTAINER-ERROR: $(Resolve-Path -LiteralPath ([string]$container.Item) -Relative)" }
$mismatch = [System.Collections.Generic.List[string]]::new()
if ($ExpectPassed -ge 0 -and $result.PassedCount -ne $ExpectPassed) { $mismatch.Add("passed=$($result.PassedCount) expected=$ExpectPassed") }
if ($ExpectFailed -ge 0 -and $result.FailedCount -ne $ExpectFailed) { $mismatch.Add("failed=$($result.FailedCount) expected=$ExpectFailed") }
if ($result.PassedCount -lt $MinPassed) { $mismatch.Add("passed=$($result.PassedCount) minimum=$MinPassed") }
foreach ($entry in $RequirePassed) {
    $parts = $entry -split '\*'
    $minimum = if ($parts.Count -gt 1) { [int]$parts[1] } else { 1 }
    $prefix = "$($parts[0]) "
    $found = @($result.Passed | Where-Object { $_.ExpandedName.StartsWith($prefix, [System.StringComparison]::Ordinal) }).Count
    if ($found -lt $minimum) { $mismatch.Add("required $($parts[0]) passed=$found minimum=$minimum") }
}
foreach ($line in $mismatch) { "EXPECTATION-MISMATCH: $line" }
"EXPECTATION-MISMATCHES=$($mismatch.Count)"
if ($mismatch.Count -gt 0) { exit 255 }
exit ($result.FailedCount + $containerErrors.Count)
```

A3 `SCRATCH/resolver-ast-check.ps1`:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref]$tokens, [ref]$errors)
if ($errors) { "PARSE-ERRORS=$($errors.Count)"; exit 1 }
$function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Resolve-CommandLineInvocation' }, $true)
if ($null -eq $function) { 'FUNCTION-ABSENT'; exit 1 }
$names = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })
$rawInvocation = @($names | Where-Object { $_ -eq 'Test-CommandLineRawInvocation' }).Count
$rawContainment = @($names | Where-Object { $_ -eq 'Test-CommandLineRawContainment' }).Count
"RAWINVOCATION=$rawInvocation"
"RAWCONTAINMENT=$rawContainment"
exit ([int](-not ($rawInvocation -eq 1 -and $rawContainment -eq 0)))
```

A4 `SCRATCH/phrase-scan.ps1`:

```powershell
param([Parameter(Mandatory)][string[]] $Root)
$ErrorActionPreference = 'Stop'
$hits = 0
$files = 0
foreach ($scanRoot in $Root) {
    foreach ($file in Get-ChildItem -LiteralPath $scanRoot -Recurse -File -Filter '*.ps1') {
        $files++
        $text = ((Get-Content -Raw -LiteralPath $file.FullName) -replace '(?m)^\s*#', ' ') -replace '\s+', ' '
        if ($text.IndexOf('only forces a checkpoint check', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            "HIT: $(Resolve-Path -LiteralPath $file.FullName -Relative)"
            $hits++
        }
    }
}
"FILES-SCANNED=$files HITS=$hits"
exit ([int]($hits -gt 0))
```

A5 `SCRATCH/raw-predicate-ast-check.ps1` (new in this cycle; it shows that classification no longer depends on the sequence grammar):

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref]$tokens, [ref]$errors)
if ($errors) { "PARSE-ERRORS=$($errors.Count)"; exit 1 }
$function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Test-CommandLineRawInvocation' }, $true)
if ($null -eq $function) { 'FUNCTION-ABSENT'; exit 1 }
$names = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })
$wordPresent = @($names | Where-Object { $_ -eq 'Test-CommandLineRawWordPresent' }).Count
$sequenceMatch = @($names | Where-Object { $_ -eq 'Get-CommandLineRawInvocationMatch' }).Count
"WORDPRESENT=$wordPresent"
"SEQUENCEMATCH=$sequenceMatch"
exit ([int](-not ($wordPresent -eq 1 -and $sequenceMatch -eq 0)))
```

B1 `tests/shell/test_codex_web_setup_codex_copy.bats`:

```bash
#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_copy.bats
#
# Purpose:
#   Cover the lines issue #824 changed in .codex/codex-web-setup.sh (the Codex
#   copy, not the GitHub Codex copy): the source guard, solution-file
#   discovery, the skipped package restore, the MSBuild verification guard, and
#   the solution-neutral repository notes.
#
# Determinism: discovery is driven through functions that take their candidates
# as arguments; the only directories read are this test directory and the
# committed fixture tests/fixtures/codex_web_setup/populated-packages. External
# commands (nuget, pwsh) are replaced by shell functions that print to stderr.
# No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
GUARD_LINE='if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi'

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

@test "C824-1 the Codex copy ends with the BASH_SOURCE source guard" {
    # Arrange: the guard must be the script's last line.
    # Act
    run tail -n 1 "${SCRIPT_UNDER_TEST}"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "${GUARD_LINE}" ]
}

@test "C824-2 resolve_repo_root falls back to the working directory when no solution file is listed" {
    # Arrange
    local expected
    expected="$(pwd)"
    # Act
    run resolve_repo_root /script/root ""
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "${expected}" ]
}

@test "C824-3 select_solution_file prints nothing when no solution file is listed" {
    # Act
    run select_solution_file ""
    # Assert
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "C824-4 resolve_repo_root keeps the script-relative root when one solution file is listed" {
    # Act
    run resolve_repo_root /script/root "Alpha.sln"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "/script/root" ]
}

@test "C824-5 select_solution_file selects the only listed solution file" {
    # Act
    run select_solution_file "Alpha.sln"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "Alpha.sln" ]
}

@test "C824-6 select_solution_file selects the first of several solution files in LC_ALL=C order" {
    # Arrange: in C order uppercase sorts before lowercase, so Beta.sln precedes alpha.sln.
    local listed
    listed="$(printf '%s\n' alpha.sln Zeta.sln Beta.sln)"
    # Act
    run select_solution_file "${listed}"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "Beta.sln" ]
}

@test "C824-7 list_root_solution_files prints nothing for a directory without solution files" {
    # Act
    run list_root_solution_files "${BATS_TEST_DIRNAME}"
    # Assert
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "C824-8 restore_packages_if_needed skips the restore with a warning when no solution file exists" {
    # Arrange
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE=""
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"No solution file was found at ${BATS_TEST_DIRNAME}; skipping package restore."* ]]
    [[ "$output" != *"nuget-called"* ]]
}

@test "C824-9 restore_packages_if_needed restores the selected solution file" {
    # Arrange
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget-called restore ${BATS_TEST_DIRNAME}/Alpha.sln -PackagesDirectory ${BATS_TEST_DIRNAME}/packages"* ]]
}

@test "C824-10 restore_packages_if_needed skips the restore when packages/ is already populated" {
    # Arrange: the committed fixture carries a non-empty packages/ directory.
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup/populated-packages"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"packages/ is already populated; skipping restore."* ]]
    [[ "$output" != *"nuget-called"* ]]
}

@test "C824-11 restore_packages_if_needed warns when nuget is unavailable" {
    # Arrange: PATH names only this test directory, which holds no nuget executable,
    # and no nuget function is defined.
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    restore_without_nuget() {
        local PATH="${BATS_TEST_DIRNAME}"
        restore_packages_if_needed
    }
    # Act
    run restore_without_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget is unavailable; cannot restore packages.config dependencies."* ]]
}

@test "C824-12 verify_windows_visual_studio_task_capability fails when no solution file exists" {
    # Arrange
    pwsh() { printf 'pwsh-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE=""
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"No solution file was found at ${BATS_TEST_DIRNAME}; MSBuild task verification needs one."* ]]
    [[ "$output" != *"pwsh-called"* ]]
}

@test "C824-13 verify_windows_visual_studio_task_capability passes the selected solution file to Invoke-VSBuild.ps1" {
    # Arrange
    pwsh() { printf 'pwsh-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"-SolutionPath Alpha.sln"* ]]
}

@test "C824-14 verify_windows_visual_studio_task_capability fails when the MSBuild tooling is unavailable" {
    # Arrange
    pwsh() { return 1; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"MSBuild tooling required by the restore/build/lint/type-check tasks is unavailable."* ]]
}

@test "C824-15 write_repo_notes names a solution-neutral placeholder" {
    # Act
    run write_repo_notes
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"-SolutionPath <solution>.sln"* ]]
}
```

B2 `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` (one line):

```text
Fixture: a non-empty packages/ directory for tests/shell/test_codex_web_setup_codex_copy.bats (issue #824).
```

B3 `scripts/dev-tools/KcovFunctionCoverageGate.ps1`:

```powershell
<#
.SYNOPSIS
    Gate kcov line coverage of named bash functions and of the changed lines of one bash
    script.

.DESCRIPTION
    Issue #824 added this gate for .codex/codex-web-setup.sh, which lies outside the
    shell-QC kcov include roots. The shell-coverage job in
    .github/workflows/_shell-coverage.yml runs that script's bats file under kcov with the
    include pattern restricted to the script, then dot-sources this file and calls
    Invoke-KcovFunctionCoverageGate.

    For each named function the report counts the kcov-instrumented lines inside the
    function body and the lines that were hit. It fails when a function is absent, has no
    instrumented line, or has a line coverage below the threshold. When a zero-context
    unified diff of the script is supplied, every added line that kcov instrumented must
    have been hit; added lines that kcov did not instrument (comments, blank lines,
    closing braces) are counted but not gated.

    A function body runs from the line 'name() {' to the first later line that is exactly
    '}'. Every decision is made by the pure functions below; only
    Invoke-KcovFunctionCoverageGate reads files. The file defines functions only and runs
    nothing when it is dot-sourced.
#>

Set-StrictMode -Version Latest

function Get-KcovLineHit {
    <#
    .SYNOPSIS
        Map each line number of one measured file to its kcov hit count.
    .DESCRIPTION
        Selects the single Cobertura class whose filename attribute ends with the given
        file name and returns a hashtable from line number to hit count. Throws when no
        class or more than one class matches.
    .PARAMETER CoberturaXml
        The text of a kcov Cobertura report.
    .PARAMETER SourceLeaf
        The file name of the measured script, for example 'codex-web-setup.sh'.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][string] $CoberturaXml,
        [Parameter(Mandatory)][string] $SourceLeaf
    )

    [xml] $report = $CoberturaXml
    $classes = @($report.SelectNodes('//class') | Where-Object { (($_.GetAttribute('filename') -replace '\\', '/') -split '/')[-1] -ceq $SourceLeaf })
    if ($classes.Count -ne 1) {
        throw "Expected exactly one Cobertura class for '$SourceLeaf'; found $($classes.Count)."
    }
    $hits = @{}
    foreach ($line in @($classes[0].SelectNodes('lines/line'))) {
        $hits[[int]$line.GetAttribute('number')] = [int]$line.GetAttribute('hits')
    }
    return $hits
}

function Get-BashFunctionLineRange {
    <#
    .SYNOPSIS
        Locate the body of one bash function by its definition and closing lines.
    .DESCRIPTION
        Returns the 1-based numbers of the line 'name() {' and of the first later line
        that is exactly '}'. Throws when the definition line does not occur exactly once
        or when no closing line follows it.
    .PARAMETER SourceLine
        The lines of the bash script.
    .PARAMETER Name
        The function name.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string[]] $SourceLine,
        [Parameter(Mandatory)][string] $Name
    )

    $header = "$Name() {"
    $starts = [System.Collections.Generic.List[int]]::new()
    for ($index = 0; $index -lt $SourceLine.Count; $index++) {
        if ($SourceLine[$index] -ceq $header) {
            $starts.Add($index)
        }
    }
    if ($starts.Count -ne 1) {
        throw "Expected exactly one definition line '$header'; found $($starts.Count)."
    }
    for ($index = $starts[0] + 1; $index -lt $SourceLine.Count; $index++) {
        if ($SourceLine[$index] -ceq '}') {
            return [pscustomobject]@{ Name = $Name; Start = $starts[0] + 1; End = $index + 1 }
        }
    }
    throw "Function '$Name' has no closing line '}'."
}

function Get-AddedLineNumber {
    <#
    .SYNOPSIS
        List the new-file line numbers that a zero-context unified diff adds.
    .DESCRIPTION
        Reads every hunk header '@@ -a,b +c,d @@' and emits the numbers c to c+d-1; a
        header without ',d' adds one line. Emits nothing for an empty diff or for a
        deletion-only hunk.
    .PARAMETER DiffText
        The output of 'git diff --unified=0' for one file.
    .OUTPUTS
        System.Int32
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $DiffText
    )

    foreach ($match in [regex]::Matches($DiffText, '(?m)^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
        $start = [int]$match.Groups[1].Value
        $count = if ($match.Groups[2].Success) { [int]$match.Groups[2].Value } else { 1 }
        for ($number = $start; $number -lt ($start + $count); $number++) {
            $number
        }
    }
}

function Get-KcovFunctionCoverageReport {
    <#
    .SYNOPSIS
        Decide the coverage gate for named functions and the changed lines of one script.
    .DESCRIPTION
        Returns an object whose Message property holds the report lines and whose ExitCode
        property is 0 when every function has at least one instrumented line and meets
        the threshold and, when CheckChangedLine is set, no added instrumented line has
        zero hits; ExitCode is 1 otherwise.
    .PARAMETER CoberturaXml
        The text of a kcov Cobertura report.
    .PARAMETER SourceText
        The text of the measured bash script.
    .PARAMETER SourceLeaf
        The file name of the measured script.
    .PARAMETER Function
        The names of the functions to gate.
    .PARAMETER Threshold
        The minimum line coverage percentage per function. Defaults to 85.
    .PARAMETER DiffText
        A zero-context unified diff of the script. Read only when CheckChangedLine is set.
    .PARAMETER CheckChangedLine
        Gate the added lines of DiffText. Without it the changed-line check is reported as
        not checked.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $CoberturaXml,
        [Parameter(Mandatory)][AllowEmptyString()][string] $SourceText,
        [Parameter(Mandatory)][string] $SourceLeaf,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $Function,
        [double] $Threshold = 85,
        [AllowEmptyString()][string] $DiffText = '',
        [switch] $CheckChangedLine
    )

    $hits = Get-KcovLineHit -CoberturaXml $CoberturaXml -SourceLeaf $SourceLeaf
    $sourceLines = @($SourceText -split '\r?\n')
    $messages = [System.Collections.Generic.List[string]]::new()
    $failed = $false
    foreach ($name in $Function) {
        $range = Get-BashFunctionLineRange -SourceLine $sourceLines -Name $name
        $measured = @($hits.Keys | Where-Object { $_ -ge $range.Start -and $_ -le $range.End } | Sort-Object)
        $missed = @($measured | Where-Object { $hits[$_] -eq 0 })
        $span = "lines=$($range.Start)-$($range.End) instrumented=$($measured.Count)"
        if ($measured.Count -eq 0) {
            $failed = $true
            $messages.Add("FUNCTION $name $span FAIL")
            continue
        }
        $covered = $measured.Count - $missed.Count
        $pct = [math]::Round(100.0 * $covered / $measured.Count, 2)
        $status = 'PASS'
        if ($pct -lt $Threshold) {
            $failed = $true
            $status = 'FAIL'
        }
        $missedText = if ($missed.Count -gt 0) { $missed -join ',' } else { 'NONE' }
        $messages.Add("FUNCTION $name $span covered=$covered pct=$pct missed=$missedText $status")
    }
    if ($CheckChangedLine) {
        $added = @(Get-AddedLineNumber -DiffText $DiffText)
        $instrumented = @($added | Where-Object { $hits.ContainsKey($_) })
        $uncovered = @($instrumented | Where-Object { $hits[$_] -eq 0 })
        if ($uncovered.Count -gt 0) {
            $failed = $true
        }
        $uncoveredText = if ($uncovered.Count -gt 0) { $uncovered -join ',' } else { 'NONE' }
        $messages.Add("CHANGED-LINES=$($added.Count) INSTRUMENTED=$($instrumented.Count) UNCOVERED-CHANGED=$uncoveredText")
    } else {
        $messages.Add('CHANGED-LINES=NOT-CHECKED')
    }
    $messages.Add("GATE-FAILED=$failed")
    return [pscustomobject]@{ Message = $messages.ToArray(); ExitCode = [int]$failed }
}

function Invoke-KcovFunctionCoverageGate {
    <#
    .SYNOPSIS
        Read the kcov report, the script, and an optional diff, and decide the gate.
    .DESCRIPTION
        The only function in this file that reads files. An empty DiffPath disables the
        changed-line check; a DiffPath that names an empty file checks zero lines.
    .PARAMETER CoberturaPath
        Path of the kcov Cobertura report.
    .PARAMETER SourcePath
        Path of the measured bash script.
    .PARAMETER DiffPath
        Path of a zero-context unified diff of the script, or an empty string.
    .PARAMETER Function
        The names of the functions to gate.
    .PARAMETER Threshold
        The minimum line coverage percentage per function. Defaults to 85.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $CoberturaPath,
        [Parameter(Mandatory)][string] $SourcePath,
        [AllowEmptyString()][string] $DiffPath = '',
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $Function,
        [double] $Threshold = 85
    )

    $checkChangedLine = -not [string]::IsNullOrEmpty($DiffPath)
    $diffText = ''
    if ($checkChangedLine) {
        $diffText = [string](Get-Content -Raw -LiteralPath $DiffPath -ErrorAction Stop)
    }
    $coberturaXml = [string](Get-Content -Raw -LiteralPath $CoberturaPath -ErrorAction Stop)
    $sourceText = [string](Get-Content -Raw -LiteralPath $SourcePath -ErrorAction Stop)
    return Get-KcovFunctionCoverageReport -CoberturaXml $coberturaXml -SourceText $sourceText -SourceLeaf (Split-Path -Leaf $SourcePath) -Function $Function -Threshold $Threshold -DiffText $diffText -CheckChangedLine:$checkChangedLine
}
```

B4 `tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1`:

```powershell
Set-StrictMode -Version Latest

# Unit tests for scripts/dev-tools/KcovFunctionCoverageGate.ps1 (issue #824).
#
# Every input is an in-memory string. Invoke-KcovFunctionCoverageGate is driven through a
# Get-Content mock, so no file is read or written, and no process, network call, or clock
# is used.

Describe 'KcovFunctionCoverageGate.ps1' -Tag 'Issue824' {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/KcovFunctionCoverageGate.ps1')).Path
        # Dot-source so the on-disk lines run under Pester coverage instrumentation. The file
        # defines functions only and runs nothing when loaded.
        . $script:scriptPath

        # Lines: 1 shebang, 2 'alpha() {', 3-4 body, 5 '}', 6 blank, 7 'beta() {', 8 body,
        # 9 '}', 10 a top-level call.
        $script:SourceText = @('#!/usr/bin/env bash', 'alpha() {', '  echo a', '  echo b', '}', '', 'beta() {', '  echo c', '}', 'alpha') -join "`n"
        $script:ClassTemplate = '<coverage><packages><package name="p"><classes>{0}</classes></package></packages></coverage>'
        $script:LineTemplate = '<class name="c" filename="{0}"><lines>{1}</lines></class>'
        $script:AllHit = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="2"/><line number="4" hits="1"/><line number="8" hits="1"/><line number="10" hits="1"/>')
        $script:Line4Missed = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="1"/><line number="4" hits="0"/><line number="8" hits="1"/>')
    }

    Context 'Get-KcovLineHit' {
        It 'G824-1 maps line numbers to hits for the one class whose file name matches' {
            # Arrange
            $classes = ($script:LineTemplate -f 'other.sh', '<line number="3" hits="9"/>') + ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="2"/><line number="4" hits="0"/>')
            $xml = $script:ClassTemplate -f $classes

            # Act
            $hits = Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh'

            # Assert
            $hits.Count | Should -Be 2
            $hits[3] | Should -Be 2
            $hits[4] | Should -Be 0
        }

        It 'G824-2 throws when no class names the file' {
            # Arrange
            $xml = $script:ClassTemplate -f ($script:LineTemplate -f 'other.sh', '')

            # Act and assert
            { Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh' } | Should -Throw -ExpectedMessage '*found 0*'
        }

        It 'G824-3 throws when two classes name the file' {
            # Arrange
            $xml = $script:ClassTemplate -f (($script:LineTemplate -f 'a/setup.sh', '') + ($script:LineTemplate -f 'b/setup.sh', ''))

            # Act and assert
            { Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh' } | Should -Throw -ExpectedMessage '*found 2*'
        }
    }

    Context 'Get-BashFunctionLineRange' {
        It 'G824-4 returns the 1-based definition and closing lines of each function' {
            # Arrange
            $lines = $script:SourceText -split "`n"

            # Act
            $alpha = Get-BashFunctionLineRange -SourceLine $lines -Name 'alpha'
            $beta = Get-BashFunctionLineRange -SourceLine $lines -Name 'beta'

            # Assert
            "$($alpha.Start)-$($alpha.End) $($beta.Start)-$($beta.End)" | Should -BeExactly '2-5 7-9'
        }

        It 'G824-5 throws when the definition line is absent' {
            # Arrange
            $lines = $script:SourceText -split "`n"

            # Act and assert
            { Get-BashFunctionLineRange -SourceLine $lines -Name 'gamma' } | Should -Throw -ExpectedMessage '*found 0*'
        }

        It 'G824-6 throws when the function has no closing line' {
            # Act and assert
            { Get-BashFunctionLineRange -SourceLine @('alpha() {', '  echo a') -Name 'alpha' } | Should -Throw -ExpectedMessage '*no closing line*'
        }
    }

    Context 'Get-AddedLineNumber' {
        It 'G824-7 expands counted and single-line hunks into new-file line numbers' {
            # Arrange
            $diff = "diff --git a/s.sh b/s.sh`n@@ -1,0 +2,3 @@`n+x`n+y`n+z`n@@ -9 +12 @@`n-q`n+r"

            # Act
            $added = @(Get-AddedLineNumber -DiffText $diff)

            # Assert
            ($added -join ',') | Should -BeExactly '2,3,4,12'
        }

        It 'G824-8 returns no line for a deletion-only hunk or an empty diff' {
            # Act
            $deletionOnly = @(Get-AddedLineNumber -DiffText "@@ -4,2 +3,0 @@`n-a`n-b")
            $empty = @(Get-AddedLineNumber -DiffText '')

            # Assert
            $deletionOnly.Count | Should -Be 0
            $empty.Count | Should -Be 0
        }
    }

    Context 'Get-KcovFunctionCoverageReport' {
        It 'G824-9 passes when every function meets the threshold and every instrumented changed line was hit' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:AllHit -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha', 'beta') -DiffText '@@ -1,0 +2,3 @@' -CheckChangedLine

            # Assert
            $report.ExitCode | Should -Be 0
            ($report.Message -join '|') | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=2 covered=2 pct=100 missed=NONE PASS|FUNCTION beta lines=7-9 instrumented=1 covered=1 pct=100 missed=NONE PASS|CHANGED-LINES=3 INSTRUMENTED=2 UNCOVERED-CHANGED=NONE|GATE-FAILED=False'
        }

        It 'G824-10 fails a function whose line coverage is below the threshold' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha') -Threshold 85

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[0] | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=2 covered=1 pct=50 missed=4 FAIL'
            $report.Message[-1] | Should -BeExactly 'GATE-FAILED=True'
        }

        It 'G824-11 fails a function with no instrumented line' {
            # Arrange
            $xml = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="10" hits="1"/>')

            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $xml -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha')

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[0] | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=0 FAIL'
        }

        It 'G824-12 fails an instrumented changed line with no hit and ignores changed lines kcov did not instrument' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('beta') -DiffText '@@ -2,0 +3,4 @@' -CheckChangedLine

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=4 INSTRUMENTED=2 UNCOVERED-CHANGED=4'
        }

        It 'G824-13 reports the changed-line check as not checked when it is not requested' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('beta') -DiffText '@@ -2,0 +3,4 @@'

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=NOT-CHECKED'
        }
    }

    Context 'Invoke-KcovFunctionCoverageGate' {
        It 'G824-14 reads the report, the script, and the diff, and checks the changed lines' {
            # Arrange
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/cov.xml' } -MockWith { $script:AllHit }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'src/setup.sh' } -MockWith { $script:SourceText }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/changed.diff' } -MockWith { '@@ -1,0 +2,3 @@' }

            # Act
            $report = Invoke-KcovFunctionCoverageGate -CoberturaPath 'kcov/cov.xml' -SourcePath 'src/setup.sh' -DiffPath 'kcov/changed.diff' -Function @('alpha', 'beta')

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[2] | Should -BeExactly 'CHANGED-LINES=3 INSTRUMENTED=2 UNCOVERED-CHANGED=NONE'
            Should -Invoke Get-Content -Times 3 -Exactly
        }

        It 'G824-15 skips the changed-line check and reads no diff when DiffPath is empty' {
            # Arrange
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/cov.xml' } -MockWith { $script:AllHit }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'src/setup.sh' } -MockWith { $script:SourceText }

            # Act
            $report = Invoke-KcovFunctionCoverageGate -CoberturaPath 'kcov/cov.xml' -SourcePath 'src/setup.sh' -Function @('alpha')

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=NOT-CHECKED'
            Should -Invoke Get-Content -Times 2 -Exactly
        }
    }
}
```

B5 `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1`:

```powershell
Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/_shell-coverage.yml (issue #824).
#
# Location note: the Pester runner discovers tests under 'scripts', 'tests/powershell', and
# 'tests/scripts' (scripts/powershell/PoshQC/settings/pester.runsettings.psd1), so this file
# lives beside PoshQcWorkflow.Tests.ps1.
#
# The workflow is read from disk as text and split into step blocks: a step begins at a line
# of six spaces, '- name:', and the step name, and runs to the line before the next step
# start. No YAML parser module is imported, and no external process, temporary file, or
# network call is made.

Describe '_shell-coverage.yml workflow invariants' -Tag 'Issue824' {
    BeforeAll {
        $repoRoot = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../..')).Path
        $workflowLines = @(Get-Content -LiteralPath (Join-Path -Path $repoRoot -ChildPath '.github/workflows/_shell-coverage.yml'))
        $script:SetupLines = @(Get-Content -LiteralPath (Join-Path -Path $repoRoot -ChildPath '.codex/codex-web-setup.sh'))

        $script:StepNames = [System.Collections.Generic.List[string]]::new()
        $stepLines = @{}
        $current = $null
        foreach ($line in $workflowLines) {
            if ($line -match '^ {6}- name:[ \t]*(?<Name>.+?)[ \t]*$') {
                $current = [System.Collections.Generic.List[string]]::new()
                $script:StepNames.Add($Matches['Name'])
                $stepLines[$Matches['Name']] = $current
                continue
            }
            if ($null -ne $current) {
                $current.Add($line)
            }
        }

        $script:StepText = @{}
        foreach ($name in $script:StepNames) {
            $script:StepText[$name] = ($stepLines[$name] -join "`n")
        }
        $script:MeasureStep = 'Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)'
        $script:GateStep = 'Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)'
        $script:UploadStep = 'Upload .codex/codex-web-setup.sh coverage artifacts (issue 824)'
    }

    It 'W824-1 keeps the existing steps in order and adds the three issue 824 steps' {
        # Arrange
        $expected = @(
            'Check out repository',
            'Install shell tooling (shellcheck, shfmt, bats)',
            'Cache kcov build',
            'Build kcov from source',
            'Install kcov from cache',
            'Run shell-qc check (shfmt diff + shellcheck)',
            'Run shell-qc test with coverage',
            'Upload shell coverage artifacts',
            $script:MeasureStep,
            $script:UploadStep,
            $script:GateStep
        )

        # Act
        $actual = $script:StepNames -join '|'

        # Assert
        $actual | Should -BeExactly ($expected -join '|') -Because 'the dedicated measurement follows the existing coverage upload and leaves the existing steps in place'
    }

    It 'W824-2 leaves the full shell-qc coverage run and its artifact upload unchanged' {
        # Act
        $testStep = $script:StepText['Run shell-qc test with coverage']
        $upload = $script:StepText['Upload shell coverage artifacts']

        # Assert
        $testStep | Should -Match '(?m)^ {8}run: bash scripts/bash/shell-qc\.sh test --coverage[ \t]*$'
        $upload | Should -Match '(?m)^ {10}name: shell-coverage[ \t]*$'
        $upload | Should -Match '(?m)^ {10}path: artifacts/pester/kcov/\*\*[ \t]*$'
        $upload | Should -Match '(?m)^ {10}if-no-files-found: error[ \t]*$'
    }

    It 'W824-3 runs only the setup bats file under kcov with the include pattern restricted to the setup script' {
        # Act
        $step = $script:StepText[$script:MeasureStep]

        # Assert
        $step | Should -Match '(?m)^ {8}shell: bash[ \t]*$'
        $step | Should -Match ([regex]::Escape('"--include-pattern=${GITHUB_WORKSPACE}/.codex/codex-web-setup.sh"'))
        @([regex]::Matches($step, 'include-pattern=')).Count | Should -Be 1
        $step | Should -Match ([regex]::Escape('tests/shell/test_codex_web_setup_codex_copy.bats'))
        $step | Should -Match ([regex]::Escape('out_dir="artifacts/pester/kcov-codex-web-setup"'))
        $step | Should -Match ([regex]::Escape('BASE_SHA: ${{ github.event.pull_request.base.sha }}'))
        $step | Should -Not -Match 'exclude-pattern'
        $step | Should -Not -Match 'shell-qc\.sh'
    }

    It 'W824-4 gates the measurement with the dot-sourced coverage gate at 85 percent' {
        # Act
        $step = $script:StepText[$script:GateStep]

        # Assert
        $step | Should -Match '(?m)^ {8}shell: pwsh[ \t]*$'
        $step | Should -Match ([regex]::Escape('. ./scripts/dev-tools/KcovFunctionCoverageGate.ps1'))
        $step | Should -Match ([regex]::Escape("-CoberturaPath 'artifacts/pester/kcov-codex-web-setup/merged/kcov-merged/cov.xml'"))
        $step | Should -Match ([regex]::Escape("-SourcePath '.codex/codex-web-setup.sh'"))
        $step | Should -Match ([regex]::Escape('-Threshold 85'))
        $step | Should -Match ([regex]::Escape('exit $report.ExitCode'))
    }

    It 'W824-5 names exactly the six changed functions, each defined once in the setup script' {
        # Arrange
        $expected = @('resolve_repo_root', 'select_solution_file', 'list_root_solution_files', 'restore_packages_if_needed', 'verify_windows_visual_studio_task_capability', 'write_repo_notes')

        # Act
        $list = [regex]::Match($script:StepText[$script:GateStep], '-Function @\((?<List>[^)]*)\)')
        $names = @([regex]::Matches($list.Groups['List'].Value, "'(?<Name>[a-z_]+)'") | ForEach-Object { $_.Groups['Name'].Value })

        # Assert
        $list.Success | Should -BeTrue
        ($names -join ',') | Should -BeExactly ($expected -join ',')
        foreach ($name in $names) {
            @($script:SetupLines | Where-Object { $_ -ceq "$name() {" }).Count | Should -Be 1 -Because "$name must be defined exactly once in .codex/codex-web-setup.sh"
        }
    }

    It 'W824-6 uploads the dedicated measurement under its own artifact name' {
        # Act
        $step = $script:StepText[$script:UploadStep]

        # Assert
        $step | Should -Match '(?m)^ {8}uses: actions/upload-artifact@v7[ \t]*$'
        $step | Should -Match '(?m)^ {10}name: shell-coverage-codex-web-setup[ \t]*$'
        $step | Should -Match '(?m)^ {10}path: artifacts/pester/kcov-codex-web-setup/\*\*[ \t]*$'
        $step | Should -Match '(?m)^ {10}if-no-files-found: error[ \t]*$'
    }
}
```
