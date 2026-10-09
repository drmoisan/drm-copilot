# promotion-hook-raw-containment-false-positive-deny (Remediation Plan, Cycle 1: merge conflict)

- **Issue:** #824
- **PR:** #855 (base `epic/enforcement-hook-precision-integration`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09T01-50
- **Status:** Draft (awaiting validator run and executor preflight)
- **Work Mode:** full-bug. Acceptance criteria source: `spec.md`. This cycle closes remediation finding MC-1 and re-verifies the AC-24 and AC-27 obligations that the conflicted files carry.
- **Inputs:** `FEATURE/remediation-inputs.2026-10-09T01-50.md` (finding MC-1 and the required union resolution); `FEATURE/plan.2026-10-08T13-53.md` (original plan; test-suite and pytest file names).

---

## 0. Definitions

- `FEATURE` = `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824`
- `REMOTE_BRANCH` = `bug/promotion-hook-raw-containment-false-positive-deny-exec-824`
- `INTEGRATION_REF` = `origin/epic/enforcement-hook-precision-integration`
- `STAMP` = the artifact creation time in `yyyy-MM-ddTHH-mm` form, chosen when the artifact is written.
- `SCRATCHPAD` = the executing agent's session scratchpad directory, spelled with forward slashes in Bash commands and recorded in artifacts only as the literal `<SCRATCHPAD>`.
- `HEAD_SHA`, `REMOTE_SHA`, `INTEGRATION_SHA`, `PRE_MERGE_SHA`, `MERGE_SHA` = values recorded by [P0-T6], [P0-T12], and [P1-T9].
- `CLAUDE_MANIFEST` = `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `CODEX_MANIFEST` = `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `LEGACY_TEST` = `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `PUSH_CMD` = `git push origin HEAD:bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (never with `--force` or `--force-with-lease`).

## 1. Rules binding on every task

1. **Evidence location and schema.** Every artifact is written under `FEATURE/evidence/remediation-baseline/` (Phase 0), `FEATURE/evidence/other/` (Phase 1), or `FEATURE/evidence/qa-gates/` (Phase 2). Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose command is expected to exit non-zero also carries `ExpectedExitCode: <n>`. `EXIT_CODE: SKIPPED` is never a passing outcome; no task in this plan authorizes a skip.
2. **No host data.** No artifact contains an absolute host path or account name. Output containing the worktree root is recorded with the root replaced by `<WORKSPACE_ROOT>`.
3. **Plain git commands.** `git`, `poetry`, and `gh` commands run directly in the Bash tool, one command per call: no `&&`, no `;`, no `cd`, no heredoc. No rebase, no force-push, no branch deletion, no `git stash`.
4. **PowerShell route.** The worktree isolation guard refuses Bash command text containing `pwsh`, `bash`, `wsl`, or a heredoc. Each observation script of section 3 is written with the Write tool to `SCRATCHPAD/<name>.ps1` together with a launcher `SCRATCHPAD/<name>.sh` and launched with the Bash command `sh SCRATCHPAD/<name>.sh`. Each script obtains the repository root with `$root = (Get-Location).Path`. If a launcher is refused, the executor records the refusal text in the task artifact and stops as BLOCKED.
5. **MCP results carry no output.** The PoshQC MCP tools `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` are recorded by call disposition only (`MCP_CALL: returned`, `MCP_CALL: error <message>`, or `MCP_CALL: unavailable <reason>`). No count or finding is read from an MCP result; every count an acceptance condition reads comes from a section-3 script or from git.
6. **Hook denials.** If any hook denies a Write, Edit, or Bash call of this plan, the executor records the denial text in the task artifact and stops as BLOCKED. It never works around a hook and never deletes hook state.
7. **Write set (complete).** `CLAUDE_MANIFEST` and `LEGACY_TEST` (conflict resolution in Phase 1, and fixes under the Phase 2 QC loop rule only), this plan file (checklist state only), and new files under `FEATURE/evidence/`. Every other path change comes only from the merge of `INTEGRATION_REF` as git auto-merged it. `CODEX_MANIFEST` is auto-merged and is verified, not edited. No change belongs to #824 addendum 2, and `FEATURE/spec.md` is not edited in this cycle.
8. **Commit attribution.** Every non-merge commit of this plan carries these two trailer lines, supplied as additional `-m` arguments after the subject: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_01RsMhy8je7BeARkv8LPcpSa`. The merge commit uses `git commit --no-edit` and carries the default merge message.
9. **Coverage.** This cycle changes no production `.ps1` file on the branch side of the merge; the only edited code file is `LEGACY_TEST`, a test file outside the coverage denominator. The #824 coverage evidence of record remains `FEATURE/evidence/qa-gates/qc-pass-2-pester-full-coverage.2026-10-08T23-19.md` and `FEATURE/evidence/qa-gates/coverage-delta.2026-10-08T23-20.md`. Production files arriving from `INTEGRATION_REF` were coverage-gated on that branch (#565) and are measured again by CI on PR #855. No local coverage task is planned in this cycle, and this rule is the recorded rationale.

## 2. Required conflict resolution (exact)

Source: `FEATURE/remediation-inputs.2026-10-09T01-50.md` lines 15-16 and 22-24.

- **`CLAUDE_MANIFEST`** (conflict near line 56). The conflict region is replaced by the union of both sides with no marker lines. In the final file the `paths` array contains, consecutively and in this order:

  ```text
      ".claude/hooks/enforce-promotion-mcp-only.ps1",
      ".claude/hooks/feature-folder-resolution.ps1",
      ".claude/hooks/hook-command-heredoc.ps1",
      ".claude/hooks/hook-command-invocation.ps1",
  ```

  Every other entry either side contributed is kept exactly once. The file is valid JSON.

- **`LEGACY_TEST`** (`$script:SharedModuleNames` assignment, line 30 on this branch). The conflict region is replaced by exactly this one line (eight leading spaces), with no marker lines:

  ```text
          $script:SharedModuleNames = @('codex-pretooluse-file-mapping.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1', 'hook-command-scanner.ps1', 'hook-command-invocation.ps1', 'enforce-batch-budget-route.ps1', 'feature-folder-resolution.ps1', 'hook-command-heredoc.ps1', 'hook-command-payload.ps1', 'hook-command-payload-powershell.ps1', 'hook-command-invocation-operands.ps1')
  ```

  This is the integration side's six names followed by this branch's four additional names: ten distinct names. If the conflict region in `LEGACY_TEST` covers any line other than the `SharedModuleNames` assignment, the executor keeps both sides' content for that other line only when the two sides are identical, and otherwise records the region text and stops as BLOCKED.

- If the merge reports a conflict in any path other than these two, the executor runs `git merge --abort`, records the conflict list, and stops as BLOCKED (the inputs are stale).

## 3. Observation scripts (written in [P0-T8]; full text copied into the [P0-T8] artifact)

Each `<name>.sh` launcher has exactly one line: `exec pwsh -NoProfile -File "$(dirname "$0")/<name>.ps1" "$@"`, except `s-qc-pester.sh`, which has exactly four lines: `pwsh -NoProfile -File "$(dirname "$0")/s-qc-pester.ps1" "$@"`, `code=$?`, `echo "QC_PESTER_EXIT_CODE: $code"`, `exit $code`.

- **S-MERGE-CHECK** (`s-merge-check.ps1`): for each of `CLAUDE_MANIFEST` and `CODEX_MANIFEST`, reads the file with `Get-Content -Raw -LiteralPath` and parses it with `ConvertFrom-Json -ErrorAction Stop` inside `try`/`catch`; prints `MANIFEST_PARSE <relpath> OK` or `MANIFEST_PARSE <relpath> FAIL`; prints `MANIFEST <relpath> paths=<n> duplicates=<k>` where `k` is the number of `paths` entries occurring more than once (ordinal comparison) and `DUPLICATE <entry>` for each. For `CLAUDE_MANIFEST` it prints `ORDER feature-folder-resolution=<i> hook-command-heredoc=<j>` (zero-based indexes in `paths`, `-1` when absent). For `CODEX_MANIFEST` it prints `CODEX_ENTRY <entry> <PRESENT|ABSENT>` for `.codex/hooks/feature-folder-resolution.ps1` and `.codex/hooks/hook-command-heredoc.ps1`. For `LEGACY_TEST` it reads the lines, selects every line matching `^\s*\$script:SharedModuleNames = @\(`, prints `SHARED_MODULE_LINES: <n>`, extracts the single-quoted names of the first such line with `[regex]::Matches($line, "'([^']+)'")`, prints `SHARED_MODULE_COUNT: <n>`, `SHARED_MODULE_DUPLICATES: <k>`, and `SHARED_MODULE_MISSING: <name>` for each of the ten names of section 2 that is absent; prints `LEGACY_LINES: <n>`; prints `CONFLICT_MARKER <relpath>:<line>` for each line of the three files matching `^(<<<<<<<|=======|>>>>>>>)( |$)` and `CONFLICT_MARKER_COUNT: <n>`. It prints `MERGE_CHECK: PASS` and exits 0 only when both manifests parse, both have `duplicates=0`, `j` equals `i + 1` with `i -ge 0`, both `CODEX_ENTRY` lines read `PRESENT`, `SHARED_MODULE_LINES: 1`, `SHARED_MODULE_COUNT: 10`, `SHARED_MODULE_DUPLICATES: 0`, no `SHARED_MODULE_MISSING` line, `LEGACY_LINES` is at most 500, and `CONFLICT_MARKER_COUNT: 0`; otherwise it prints `MERGE_CHECK: FAIL` and exits 1.
  - Parse-failure path: when a manifest fails to parse, the script prints `MANIFEST_PARSE <relpath> FAIL` and then `MANIFEST <relpath> paths=-1 duplicates=-1`; for `CLAUDE_MANIFEST` it also prints `ORDER feature-folder-resolution=-1 hook-command-heredoc=-1`; for `CODEX_MANIFEST` both `CODEX_ENTRY` lines read `ABSENT`. The script then continues with the remaining checks. No read or parse failure ends the script before `CONFLICT_MARKER_COUNT:` and the `MERGE_CHECK:` verdict are printed.
- **S-FMT-LEGACY** (`s-fmt-legacy.ps1`): imports PSScriptAnalyzer; runs `Invoke-Formatter -ScriptDefinition <LF-normalized content of LEGACY_TEST> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` without writing; prints `FORMAT_CLEAN tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` or `FORMAT_DRIFT tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, then `FORMAT_DRIFT_COUNT: <n>`; exits 1 when n > 0.
- **S-PSSA-LEGACY** (`s-pssa-legacy.ps1`): runs `Invoke-ScriptAnalyzer -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information`; prints `PSSA <relpath>:<line> <RuleName>` per finding and `PSSA_FINDING_COUNT: <n>`; exits 1 when n > 0.
- **S-QC-PESTER** (`s-qc-pester.ps1`): `New-PesterConfiguration` with `Run.Path` set to the 27 files of set `QC` below, `Run.PassThru = $true`, `Run.Exit = $false`, `Output.Verbosity = 'Normal'`, coverage off; after the run prints `PESTER_TOTAL`, `PESTER_PASSED`, `PESTER_FAILED`, `PESTER_SKIPPED`, `PESTER_FAILED_BLOCKS`, `PESTER_FAILED_CONTAINERS` lines, one `FILE_RESULT <relpath> passed=<n> failed=<m>` line per container (relpath = container path with the root stripped and `\` replaced by `/`), and `FAILED_TEST: <ExpandedPath>` per failed test; exits 1 when `PESTER_FAILED`, `PESTER_FAILED_BLOCKS`, or `PESTER_FAILED_CONTAINERS` is greater than 0.
  - Set `QC` (27 files). Conflicted file: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. #565 feature-folder-resolution suites (`docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/plan.2026-10-08T13-52.md` rows W21, W22; both files arrive with the merge): `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1`, `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1`. #824 new suites (original plan section 3): `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-payload.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1`, `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`. #824 modified suites other than `LEGACY_TEST` (original plan section 3): `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1`, `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`. Remaining original-plan `PARITY` suites: `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
  - The script first checks that each of the 27 paths exists and prints `QC_MISSING_FILE: <relpath>` for each absent one, exiting 1 before running Pester when any is absent.
  - Baseline variant: with the optional positional argument `baseline` (passed through by the launcher's `"$@"`), `Run.Path` is set `QC` minus `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1` and `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1` (25 files, all present before the merge), and the existence check covers those 25 paths only. Without the argument the script uses all 27 files.

## 4. Pytest node IDs (from `FEATURE/plan.2026-10-08T13-53.md` line 257 files)

Manifest completeness:

- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`

Bundle parity:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`

---

### Phase 0 — Policy Reads and Remediation Baseline

- [ ] [P0-T1] Read `CLAUDE.md` in full.
  - Acceptance: recorded by [P0-T5].
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
  - Acceptance: recorded by [P0-T5].
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` in full.
  - Acceptance: recorded by [P0-T5].
- [ ] [P0-T4] Read `.claude/rules/powershell.md` in full (PowerShell is the only code language edited; the JSON manifest has no language policy file).
  - Acceptance: recorded by [P0-T5].
- [ ] [P0-T5] Write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.md`.
  - Acceptance: the file contains `Timestamp:`, `Policy Order: CLAUDE.md > general-code-change > general-unit-test > quality-tiers > powershell`, and the five repository-relative paths read in [P0-T1]-[P0-T4].
- [ ] [P0-T6] Run, as separate Bash calls, `git fetch origin`, `git branch --show-current`, `git status --porcelain`, `git rev-parse HEAD` (value `HEAD_SHA`), `git rev-parse origin/bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (value `REMOTE_SHA`), and `git rev-parse origin/epic/enforcement-hook-precision-integration` (value `INTEGRATION_SHA`); record all six in `FEATURE/evidence/remediation-baseline/git-baseline.STAMP.md`.
  - Acceptance: each command records `EXIT_CODE: 0`; `HEAD_SHA:`, `REMOTE_SHA:`, and `INTEGRATION_SHA:` are 40-hex values; `HEAD_SHA` equals `REMOTE_SHA` (otherwise `PUSH_CMD` would not fast-forward, and execution stops as BLOCKED); the `git status --porcelain` output is empty, or lists only paths under `FEATURE/` (otherwise BLOCKED).
- [ ] [P0-T7] [expect-fail] Run `git merge-tree --write-tree --name-only HEAD origin/epic/enforcement-hook-precision-integration` and record `FEATURE/evidence/remediation-baseline/merge-tree-conflicts.STAMP.md`.
  - Acceptance: `EXIT_CODE: 1` and `ExpectedExitCode: 1`; `Output Summary:` lists the conflicted-file section of the output (the lines after the first tree-OID line and before the first blank line), and that section is exactly the two lines `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Any other conflicted path, or exit 0, stops execution as BLOCKED because the inputs no longer describe the merge.
- [ ] [P0-T8] Write the four section-3 scripts and their launchers to `SCRATCHPAD/` and copy each script's and launcher's full text into `FEATURE/evidence/remediation-baseline/observation-scripts.STAMP.md`.
  - Acceptance: the artifact contains `Timestamp:` and one fenced block for each of `s-merge-check.ps1`, `s-fmt-legacy.ps1`, `s-pssa-legacy.ps1`, `s-qc-pester.ps1`, and the four launchers (eight blocks).
- [ ] [P0-T9] Run `sh SCRATCHPAD/s-fmt-legacy.sh` against the pre-merge `LEGACY_TEST` and record `FEATURE/evidence/remediation-baseline/legacy-format.STAMP.md`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:` (the observed integer), and `Output Summary:` containing the `FORMAT_CLEAN` or `FORMAT_DRIFT` line and the `FORMAT_DRIFT_COUNT:` line with its integer value. This is a baseline observation and is non-blocking: any `FORMAT_DRIFT_COUNT:` value is recorded as observed. [P2-T2] still requires `FORMAT_DRIFT_COUNT: 0`.
- [ ] [P0-T10] Run `sh SCRATCHPAD/s-pssa-legacy.sh` against the pre-merge `LEGACY_TEST` and record `FEATURE/evidence/remediation-baseline/legacy-analyze.STAMP.md`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:` (the observed integer), and `Output Summary:` containing every `PSSA` finding line and the `PSSA_FINDING_COUNT:` line with its integer value. This is a baseline observation and is non-blocking. [P2-T3] still requires `PSSA_FINDING_COUNT: 0`.
- [ ] [P0-T11] Run `sh SCRATCHPAD/s-qc-pester.sh baseline` with the Bash parameter `run_in_background: true`, wait for the background-task completion notification, and record `FEATURE/evidence/remediation-baseline/legacy-pester.STAMP.md`.
  - Acceptance: the output contains a `QC_PESTER_EXIT_CODE:` line and `EXIT_CODE:` records its integer; no `QC_MISSING_FILE:` line; `Output Summary:` records the `PESTER_TOTAL`, `PESTER_PASSED`, `PESTER_FAILED`, `PESTER_FAILED_BLOCKS`, and `PESTER_FAILED_CONTAINERS` lines, the 25 `FILE_RESULT` lines, and every `FAILED_TEST:` line. Failures are recorded as the pre-merge baseline and are not blocking. A run whose output lacks the `QC_PESTER_EXIT_CODE:` line, or that prints a `QC_MISSING_FILE:` line, is recorded as incomplete and stops execution as BLOCKED.
- [ ] [P0-T12] Commit and push Phase 0 evidence and this plan: `git add -- docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md`; `git commit -m "docs(824): record remediation cycle 1 baseline" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01RsMhy8je7BeARkv8LPcpSa" -- docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md`; then `PUSH_CMD`; then `git status --porcelain` (the post-push listing); then `git rev-parse HEAD` (value `PRE_MERGE_SHA`), appended to the [P0-T6] artifact as a `PRE_MERGE_SHA:` line; then `git status --porcelain` again (the post-append listing). The [P0-T12] checkbox is ticked only after the post-append listing is recorded; that plan-file change and the [P0-T6] artifact change are committed by [P2-T9].
  - Acceptance: each command exits 0; the push output names `bug/promotion-hook-raw-containment-false-positive-deny-exec-824`; the post-push listing is empty; `PRE_MERGE_SHA:` is a 40-hex value; the post-append listing is exactly one line, ` M docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/git-baseline.STAMP.md` (with `STAMP` substituted). A rejected push stops execution as BLOCKED.

### Phase 1 — Merge and Union Conflict Resolution

- [ ] [P1-T1] [expect-fail] Run `git merge --no-edit origin/epic/enforcement-hook-precision-integration` and record `FEATURE/evidence/other/remediation-1-merge.STAMP.md`.
  - Acceptance: `EXIT_CODE: 1` and `ExpectedExitCode: 1`; `Output Summary:` contains the two `CONFLICT (content): Merge conflict in <path>` lines for `CLAUDE_MANIFEST` and `LEGACY_TEST` and no other `CONFLICT` line (a different conflict set triggers the section 2 abort-and-BLOCKED rule).
- [ ] [P1-T2] Run `git ls-files -u` and `git status --porcelain`; append both outputs to the [P1-T1] artifact under a `Pre-resolution state:` heading.
  - Acceptance: both exit 0; `git ls-files -u` lists stage entries for exactly the two conflicted paths; the porcelain listing shows `UU` for exactly those two paths and no other unmerged code (`AA`, `DU`, `UD`, `AU`, `UA`, `DD`).
- [ ] [P1-T3] [expect-fail] Run `sh SCRATCHPAD/s-merge-check.sh` before resolution and append it to the [P1-T1] artifact under a `Pre-resolution merge check:` heading.
  - Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and the output prints `MERGE_CHECK: FAIL` with a `CONFLICT_MARKER_COUNT:` value greater than 0. This shows the [P1-T6] check can fail.
- [ ] [P1-T4] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` with the Edit tool: replace the conflict region (from its `<<<<<<<` line through its `>>>>>>>` line) with the union of section 2, so the four consecutive lines quoted there appear in that order.
  - Acceptance: [P1-T6] prints `MANIFEST_PARSE extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json OK`, `duplicates=0` for that file, and an `ORDER` line whose second index is the first index plus 1.
- [ ] [P1-T5] Edit `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` with the Edit tool: replace the conflict region with the single `$script:SharedModuleNames` line quoted in section 2.
  - Acceptance: [P1-T6] prints `SHARED_MODULE_LINES: 1`, `SHARED_MODULE_COUNT: 10`, `SHARED_MODULE_DUPLICATES: 0`, no `SHARED_MODULE_MISSING` line, and `LEGACY_LINES:` at most 500.
- [ ] [P1-T6] Run `sh SCRATCHPAD/s-merge-check.sh` and record `FEATURE/evidence/other/remediation-1-merge-check.STAMP.md`.
  - Acceptance: `EXIT_CODE: 0`; `Output Summary:` contains `MERGE_CHECK: PASS`, `CONFLICT_MARKER_COUNT: 0`, both `MANIFEST_PARSE ... OK` lines, both `duplicates=0` values, both `CODEX_ENTRY ... PRESENT` lines, and the `LEGACY_LINES:` value.
- [ ] [P1-T7] Run `git add -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, then `git ls-files -u`, then `git status --porcelain`; append all three to the [P1-T6] artifact.
  - Acceptance: each command exits 0; `git ls-files -u` prints nothing; the porcelain listing contains no unmerged code (`UU`, `AA`, `DU`, `UD`, `AU`, `UA`, `DD`) and no unstaged change (second column blank) on any path outside `FEATURE/`.
- [ ] [P1-T8] Run `git commit --no-edit` to conclude the merge.
  - Acceptance: exit 0; the commit output names a new commit and no hook denial is printed.
- [ ] [P1-T9] Run `git rev-list --parents -n 1 HEAD` and record `FEATURE/evidence/other/remediation-1-merge-commit.STAMP.md` with `MERGE_SHA` (the first value).
  - Acceptance: `EXIT_CODE: 0`; the output has exactly three 40-hex values; the second equals `PRE_MERGE_SHA` from [P0-T12] and the third equals `INTEGRATION_SHA` from [P0-T6].
- [ ] [P1-T10] Run `PUSH_CMD` and append its output to the [P1-T9] artifact.
  - Acceptance: exit 0; the output contains a ref-update line of the form `<old>..<new>  HEAD -> bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (a two-dot range) and contains no `forced update` text. A rejected push stops execution as BLOCKED.

### Phase 2 — Final QC and Evidence Commit

QC loop rule: if [P2-T1] or [P2-T2] changes `LEGACY_TEST`, or any task of [P2-T1]-[P2-T6] fails, the executor fixes only `LEGACY_TEST` or `CLAUDE_MANIFEST`, commits the fix as a non-merge commit per rule 8, and restarts Phase 2 from [P2-T1] with artifact names suffixed `pass-N`. [P2-T7] names the clean pass.

- [ ] [P2-T1] Run `git status --porcelain` (record as the before-listing), then call `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = the worktree root and `scan_folders` = `tests/scripts/codex-hooks`, then run `git status --porcelain` again (the after-listing); record `FEATURE/evidence/qa-gates/remediation-1-format.STAMP.md`.
  - Acceptance: the MCP call disposition is `MCP_CALL: returned`; both git calls record `EXIT_CODE: 0`. Paths added by the formatter other than `LEGACY_TEST` are pre-existing drift outside this cycle's write set: the executor runs `git restore -- <path>` for each, records one `FORMAT_OUTSIDE_SCOPE_RESTORED: <path>` line per path (or `FORMAT_OUTSIDE_SCOPE_RESTORED: none`), and records a third `git status --porcelain` listing. Pass condition: after removing lines under `FEATURE/` from both the before-listing and the final listing, the two filtered listings are identical, and the final listing does not contain `LEGACY_TEST`. If `LEGACY_TEST` was rewritten, the QC loop rule restarts the phase.
- [ ] [P2-T2] Run `sh SCRATCHPAD/s-fmt-legacy.sh` and append it to the [P2-T1] artifact.
  - Acceptance: `EXIT_CODE: 0`; `Output Summary:` contains `FORMAT_DRIFT_COUNT: 0`.
- [ ] [P2-T3] Call `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = the worktree root and `scan_folders` = `tests/scripts/codex-hooks`, then run `sh SCRATCHPAD/s-pssa-legacy.sh`; record `FEATURE/evidence/qa-gates/remediation-1-analyze.STAMP.md`.
  - Acceptance: the MCP call disposition is `MCP_CALL: returned`; the script records `EXIT_CODE: 0` and `PSSA_FINDING_COUNT: 0`.
- [ ] [P2-T4] Run `sh SCRATCHPAD/s-qc-pester.sh` with the Bash parameter `run_in_background: true`, wait for the background-task completion notification, and record `FEATURE/evidence/qa-gates/remediation-1-pester.STAMP.md`.
  - Acceptance: the output contains a `QC_PESTER_EXIT_CODE:` line and `EXIT_CODE:` records its integer; no `QC_MISSING_FILE:` line; `PESTER_FAILED_BLOCKS: 0` and `PESTER_FAILED_CONTAINERS: 0`; 27 `FILE_RESULT` lines; the `FILE_RESULT` lines for `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1` each show `passed=` greater than 0. A failure that is present with an identical `FAILED_TEST:` name in the [P0-T11] baseline is recorded as pre-existing, one `PRE_EXISTING_FAILURE: <name>` line per failure, and does not fail [P2-T4]; any failure absent from the baseline fails it. When every `FAILED_TEST:` line is pre-existing, the `PESTER_FAILED` value equals the number of `PRE_EXISTING_FAILURE:` lines, and the artifact records `ExpectedExitCode: 1` with `EXIT_CODE: 1`. When the run prints no `FAILED_TEST:` line, `EXIT_CODE: 0`, `PESTER_FAILED: 0`, and each `FILE_RESULT` line shows `failed=0`. A run whose output lacks the `QC_PESTER_EXIT_CODE:` line is recorded as incomplete and stops execution as BLOCKED.
- [ ] [P2-T5] Run `poetry install --no-interaction` (its own Bash call), then run `poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`; record both in `FEATURE/evidence/qa-gates/remediation-1-pytest-manifest-parity.STAMP.md`.
  - Acceptance: `poetry install` exits 0; pytest `EXIT_CODE: 0`; `Output Summary:` records the final summary line, which reads `6 passed` with no `failed` or `error` count, and the six `PASSED` node-ID lines. Sole exception (gitignored-state defect #510, precedent: original plan rule 8): when the only failing node is `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and its failure message names a gitignored path, the executor records `KNOWN-510-LOCAL-ONLY: <failure message first line>`, the remaining five nodes must pass, and the node is judged by CI on PR #855; any other failure stops the phase under the QC loop rule.
- [ ] [P2-T6] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` (the original [P0-T19] command) and record `FEATURE/evidence/qa-gates/remediation-1-pytest-files.STAMP.md`.
  - Acceptance: `EXIT_CODE: 0`; the final summary line is printed, reports a passed total greater than 0, and reports no failed or errored test. The [P2-T5] #510 exception applies identically and to that one node only.
- [ ] [P2-T7] Write `FEATURE/evidence/qa-gates/remediation-1-qc-summary.STAMP.md` naming the clean pass number and listing the five artifacts of [P2-T1]-[P2-T6] of that pass (format, which includes [P2-T2]; analyze; pester; pytest-manifest-parity; pytest-files), `MERGE_SHA`, and the finding disposition `MC-1: RESOLVED`.
  - Acceptance: the file contains `Timestamp:`, the five artifact paths, a 40-hex `MERGE_SHA:` value, and `MC-1: RESOLVED`.
- [ ] [P2-T8] Run `git status --porcelain` and `git diff --name-only MERGE_SHA` (substituting the recorded value); append both to the [P2-T7] artifact.
  - Acceptance: both exit 0; every path in both listings is under `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/`, except that `LEGACY_TEST` or `CLAUDE_MANIFEST` may appear in the `git diff` listing only when a QC-loop fix commit for that path is recorded in a `pass-N` artifact.
- [ ] [P2-T9] Commit and push: `git add -- docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md`; `git commit -m "docs(824): record remediation cycle 1 merge resolution and QC evidence" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01RsMhy8je7BeARkv8LPcpSa" -- docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-09T01-50.md`; then `PUSH_CMD`.
  - Acceptance: each command exits 0; the push output names `bug/promotion-hook-raw-containment-false-positive-deny-exec-824` with no `forced update`; `git status --porcelain` afterward is empty. PR #855 mergeability and CI are read by the orchestrator after this push. The [P2-T9] checkbox is ticked only after the empty post-push listing is recorded. The resulting one-line plan-file change is the only uncommitted change at plan completion; the executor reports it in the completion report, and the orchestrator commits it with its next checkpoint.

## 5. Acceptance traceability

| ID | Implementation | Tests | Evidence |
|---|---|---|---|
| MC-1 | P1-T1, P1-T4, P1-T5, P1-T8, P1-T10 | P1-T6 S-MERGE-CHECK; P2-T4 `legacy-codex-hook-contracts.Tests.ps1` | other/remediation-1-merge-check, other/remediation-1-merge-commit, qa-gates/remediation-1-qc-summary |
| AC-24 | P1-T4 (Claude manifest union), P1-T5 (`SharedModuleNames` union) | P2-T4 legacy contracts; P2-T5 six pytest node IDs; P2-T6 four pytest files | qa-gates/remediation-1-pester, qa-gates/remediation-1-pytest-manifest-parity, qa-gates/remediation-1-pytest-files (CI result read by the orchestrator; spec AC-24 stays unchecked here) |
| AC-27 | P1-T5 (single-line replacement) | P1-T6 `LEGACY_LINES:` at most 500 | other/remediation-1-merge-check |
