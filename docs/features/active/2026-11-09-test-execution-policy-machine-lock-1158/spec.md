# 2026-11-09-test-execution-policy-machine-lock — Spec

- **Issue:** #1158
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-50
- **Status:** Draft
- **Version:** 0.3

## Overview

Several features ran full test suites at the same time on one machine, each with one worker per core and each including the slow integration and golden suites under coverage. Load reached about four to five times the core count, and suite runs that take a few minutes alone took over 100 minutes. Agents also ran suites through scratch wrapper scripts that process-based checks could not see.

This feature adds a configurable test-execution policy with three harness defaults that change by design:

1. Local runs exclude the integration lane and the golden lane; those lanes are CI-only evidence.
2. At most one test suite runs per machine (per user), serialized by an OS advisory file lock outside every worktree. A queued suite waits a bounded time below the tool-call timeout and then exits with retry code 75 naming the lock holder. The running suite's parallel worker count is not reduced.
3. Suites run only through one recognizable launcher command; direct runner invocations and hidden wrapper scripts are denied by a PreToolUse hook.

- Target users: agent operators (orchestrators, executors, planners running in parallel worktrees) and the repository owner who maintains the harness and pushes it down to destination repositories.
- Success metrics: no two suites run concurrently on one machine through the governed routes; no local run executes an integration or golden lane; a queued suite returns within the bounded wait with exit 75 rather than contending for the CPU; plans cite CI lanes as evidence instead of running them locally.

Authoritative inputs: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/issue.md` (scope, five acceptance criteria) and `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/research/research.2026-11-09T21-35.md` (design; decisions D1 through D13 adopted). Environment facts are from `.claude/skills/execution-environment/SKILL.md`.

## Behavior

### Launcher

The launcher is `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` (PowerShell 7) with the POSIX shim `.claude/skills/test-execution-policy/scripts/run-test-suite.sh`. The shim takes the suite name as its first argument and passes the remaining arguments through. The launcher runs these steps in order:

1. **Load policy.** Built-in defaults are merged with the repository file `config/test-execution-policy.json` when it exists; an absent file means defaults. An invalid file stops the launcher with exit 2 and a stderr message starting `TEST_EXECUTION_POLICY_BLOCKED:` that names the file and the failing field.
2. **Resolve the suite.** An unknown suite name exits 2 with a `TEST_EXECUTION_POLICY_BLOCKED:` message that lists the known suite names.
3. **Classify the extra arguments.** An argument that selects an excluded lane exits 2 with `TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy)` or the golden equivalent. Lane selection is: a path operand whose file name ends with a configured lane suffix (case-insensitive ordinal); a pytest `-m` expression that selects a lane marker without `not`; a Pester `-Tag` value equal to a lane tag; a `dotnet test` `--filter` that names a lane category. A worker-reduction token (D9) also exits 2 with a `TEST_EXECUTION_POLICY_BLOCKED:` message.
4. **Build the command.** The suite's configured command words, then the lane-exclusion arguments for that runner (D6, D15), then the caller's extra arguments. No worker option is added.
5. **Acquire the machine lock.** Probe the lock file. When busy, read the holder record and poll every `machineLock.pollMilliseconds` until the lock is acquired or `machineLock.waitMilliseconds` elapses. On timeout, write `TEST_EXECUTION_QUEUE_TIMEOUT: test-execution policy allows one suite per machine; lock held by {holder}; waited {ms} ms; retry later.` to stderr and exit 75. `machineLock.enabled: false` skips this step.
6. **Run.** Write the holder record, start the suite as a child process with inherited standard streams, wait for it, then in a `finally` block dispose the lock stream and delete the holder record. Exit with the suite's exit code; for the `pester` suite that is the `ExitCode` property of the `Invoke-PoshQCParallelTest` result.

### Hook

`.claude/hooks/enforce-test-execution-policy.ps1` (Codex twin `.codex/hooks/enforce-test-execution-policy.ps1`) is a standalone PreToolUse hook.

Bash tool calls: for every record returned by `Read-CommandLineInvocationSegment` (including `sh -c`, `bash -c`, `pwsh -Command`, `pwsh -EncodedCommand`, `eval`, `xargs`, and substitution bodies):

- **Sanctioned launcher.** A record whose script path ends with `skills/test-execution-policy/scripts/run-test-suite.sh` or `skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` is allowed unless its arguments select an excluded lane or carry a worker-reduction token (same pure classifier as the launcher). The hook does not queue; a second launcher reaches the lock, waits, and exits 75.
- **Direct runner.** A runner invocation outside the launcher is denied. Runner words: `pytest`, `python -m pytest`, `poetry run pytest`, `npx jest`, `node run-jest.cjs`, `npm test`, `npm run test`, `npm --prefix` followed by a directory and `run test`, `Invoke-Pester`, `Invoke-PoshQCTest`, `Invoke-PoshQCParallelTest`, `Invoke-PoshQCSuite`, `bats`, `shell-qc.sh test`, and `dotnet test`. The message starts `TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher`, names the launcher command for the matching suite, and names the lock holder when the lock is held.
- **Lane selection.** A direct or launcher invocation that selects an excluded lane is denied with the lane message from launcher step 3.
- **Hidden wrapper.** A script-file operand that is not the sanctioned launcher (`sh`, `bash`, `zsh`, `dash`, or `ksh` with a file operand; `pwsh` or `powershell` with `-File`; `python`, `python3`, or `poetry run python` with a `.py` operand; `node` with a `.js`, `.cjs`, or `.mjs` operand other than `run-jest.cjs`) is read through a seam (cap 262144 bytes, resolved against the payload `cwd`). Shell text is parsed through `Read-CommandLineInvocationSegment`, PowerShell text through the PowerShell parser's command AST, Python text is matched for `pytest.main(` or a quoted `pytest` command word, and JavaScript text is matched for `run-jest.cjs`, `runCLI(`, or a quoted runner command word (`pytest`, `jest`, `bats`, `Invoke-Pester`, `Invoke-PoshQCTest`, `Invoke-PoshQCParallelTest`, `Invoke-PoshQCSuite`, or `dotnet` followed by `test`). A runner invocation found inside the file is denied with `TEST_EXECUTION_POLICY_BLOCKED: hidden wrapper suite launch` and the launcher command. An unreadable or oversized file is allowed (policy-level guard). Non-test PowerShell run through `SCRATCH` `sh` launchers (analyzer, `Invoke-PoshQCLeakScan`, format) stays allowed.
- **Invalid configuration.** Every runner or launcher command is denied with a message naming `config/test-execution-policy.json` and the field; non-test commands are unaffected.

MCP tool calls: `mcp__drm-copilot__run_poshqc_test` and `mcp__drm-copilot__run_poshqc_suite` are denied while the lock probe reports busy, with the holder named. When the lock is free they are allowed; until the extension release that carries the template change (D7) is installed, such an MCP run does not itself hold the lock.

Knobs: `requireLauncher: false` disables the direct-runner and hidden-wrapper denials; `localLanes.exclude: []` disables lane denials; `machineLock.enabled: false` disables the MCP busy denial and the launcher queue.

### Edge flows

- An empty or whitespace-only command is allowed.
- A malformed payload is allowed (Claude hook fails open, documented); the Codex twin follows the Codex exit-2 convention for empty or unparseable stdin, as `.codex/hooks/enforce-worktree-poetry-venv.ps1` does.
- A PowerShell-host `Opaque` record with `DecodeFailure` is denied only when the visible text contains a runner word; otherwise allowed.
- A launcher's own suite command is never re-scanned by the hook.
- The holder record of the current process is never reported as a foreign holder.
- A dependency-load failure in the hook follows the guarded dot-source pattern of `hook-dependency-guard.ps1`.

## Inputs / Outputs

### Configuration: `config/test-execution-policy.json`

Optional, repository-owned, `version: 1`, merged over built-in defaults. Not pushed down (D2).

| Key | Type | Default | Validation |
|---|---|---|---|
| `version` | integer | `1` | must equal `1` |
| `localLanes.exclude` | string array | `["integration", "golden"]` | array; no blank entries; every name defined under `lanes` |
| `lanes.integration.pytestMarkers` | string array | `["integration"]` | array; no blank entries |
| `lanes.integration.pesterTags` | string array | `["Integration"]` | array; no blank entries |
| `lanes.integration.mstestCategories` | string array | `["Integration"]` | array; no blank entries |
| `lanes.integration.fileNameSuffixes` | string array | `[".integration.test.ts", ".integration.test.js", "_integration.py", ".integration.tests.ps1"]` | array; no blank entries; case-insensitive ordinal suffix match on the file name |
| `lanes.golden.pytestMarkers` | string array | `["golden"]` | as above |
| `lanes.golden.pesterTags` | string array | `["Golden"]` | as above |
| `lanes.golden.mstestCategories` | string array | `["Golden"]` | as above |
| `lanes.golden.fileNameSuffixes` | string array | `[".golden.test.ts", ".golden.test.js", "_golden.py", ".golden.tests.ps1"]` | as above |
| `machineLock.enabled` | boolean | `true` | boolean |
| `machineLock.waitMilliseconds` | integer | `90000` | 0 to 540000 inclusive |
| `machineLock.pollMilliseconds` | integer | `2000` | 100 to 10000 inclusive |
| `requireLauncher` | boolean | `true` | boolean |
| `suites` | object of suite definitions | built-in suites below | each entry: `workingDirectory` repository-relative with no absolute path and no `..` segment; `command` non-empty string array with no worker-reduction token; `runner` one of `pytest`, `pester`, `jest`, `mstest`, `bats` |

Unknown top-level keys are errors. Built-in suites: `pytest` (`poetry run pytest -n auto`), `pester` (PoshQC module import plus `Invoke-PoshQCParallelTest`, exiting with its `ExitCode`), `jest` (`node run-jest.cjs` in the repository root), `dotnet-test` (`dotnet test`).

This repository's committed `config/test-execution-policy.json` adds the integration suffixes `-integration.test.ts` and `integration.tests.ps1` (covering `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts`, `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1`, and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`) and the suites `jest-extension` (working directory `extensions/drm-copilot`, `node run-jest.cjs`) and `bats` (`bash scripts/bash/shell-qc.sh test`).

Defaults: every knob introduced by this item defaults to the new test-execution behavior (lanes excluded, one suite per machine, launcher required); that change is by design for this workstream. Every other new parameter (the PoshQC `-ExcludeTag` and `-ExcludeTestFileSuffix` parameters, the MCP template lock branch) defaults to today's behavior when omitted or when its helper is absent.

### Environment inputs

- Windows lock directory: `[Environment]::GetFolderPath('LocalApplicationData')` joined with `drm-copilot/test-execution`.
- Other platforms: `$XDG_STATE_HOME`, or `$HOME/.local/state` when unset, joined with `drm-copilot/test-execution`. `XDG_RUNTIME_DIR` is not used.
- `TEST_SUITE_PWSH_BIN`: optional executable override used by `run-test-suite.sh` (test seam); unset means `pwsh`.

### Outputs

- Lock file `test-suite.lock` and holder record `test-suite.holder.json` in the lock directory (outside every worktree).
- Suite standard streams are inherited unchanged; the suite's own artifacts (JUnit, coverage) are unchanged.
- Stderr messages with the prefixes `TEST_EXECUTION_POLICY_BLOCKED:` and `TEST_EXECUTION_QUEUE_TIMEOUT:`.

## API / CLI Surface

### Commands

- Claude agents: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` (the suite name is the first argument; extra arguments follow). This form passes the worktree isolation guard, which admits `sh` with a literal `.sh` path.
- Codex and humans: the same, or `pwsh -NoProfile -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pytest` followed by the extra arguments. `Invoke-TestSuite.ps1` has no param block and no `CmdletBinding`: it reads `$args`, takes the suite name from the first element, and passes the remaining elements to the classifier and the suite unchanged (D18). There is no `-Suite` or `-ExtraArgument` parameter.

### Exit codes (D12)

| Code | Meaning |
|---|---|
| 75 | Queue timeout: the machine lock stayed busy for `waitMilliseconds`; the message names the holder; retry later (`EX_TEMPFAIL`). A documented constant, not a knob. |
| 2 | Policy refusal or invalid configuration: invalid config file, unknown suite, lane selection, worker-reduction token. |
| any other | The suite's own exit code, propagated unchanged. |

### Messages

- Deny and refusal prefix: `TEST_EXECUTION_POLICY_BLOCKED:`. Each message names "test-execution policy", the rule that applied, and the launcher command; busy-lock denials name the holder.
- Queue timeout prefix: `TEST_EXECUTION_QUEUE_TIMEOUT:`.

### Holder record (`test-suite.holder.json`)

Fields: `pid`, `processStartUtc`, `suite`, `commandLine` (the suite's command words), `worktreeRoot`, `acquiredAtUtc`, `policyVersion`. Written by the holder after acquiring the lock and opened with `FileShare.Read` so waiters can read it. Evidence artifacts never copy `worktreeRoot` or other absolute paths; they record repository-relative paths or the token `SCRATCH`.

Holder description: named holder (suite, pid, worktree) when the process seam reports a start time equal to `processStartUtc`; "an unidentified process (stale record for pid N)" when the process is missing or its start time differs; "an unidentified process" when no record is readable.

## Data & State

### Lock-decision state model (pure)

Inputs: `Enabled`, `ProbeResult` (`Free` or `Busy`), `HolderRecord` (absent, unparseable, or parsed), `ProcessStartUtc(pid)` (absent or a time), `StartedAtUtc`, `NowUtc`, `WaitMilliseconds`.

| Condition | Decision |
|---|---|
| `Enabled` is false | `Skip` |
| `Free`, no holder record | `Acquire` |
| `Free`, holder record present | `AcquireReplacingStaleRecord` |
| `Busy`, elapsed (`NowUtc` minus `StartedAtUtc`) below `WaitMilliseconds` | `Wait`, carrying the holder description |
| `Busy`, elapsed at or above `WaitMilliseconds` | `Timeout`, carrying the holder description (exit 75) |

`waitMilliseconds: 0` yields `Timeout` on the first busy probe. The driver loop takes `Clock` and `Sleep` seams; with the defaults it returns `Timeout` once the injected clock reaches 90000 ms.

### Invariants

- The OS releases the file lock when the holder process exits for any reason; only the holder record can be stale, and it is overwritten by the next acquirer.
- Lock scope is per user per machine; a devcontainer and its host are separate machines for the lock.
- The command builder never emits a worker option, and the policy never alters the worker count of a running suite.
- No migration or backfill is required; absence of the config file means defaults.

## Decisions

- **D1. Lock mechanism.** OS file lock: `[System.IO.FileStream]` opened with `FileMode.OpenOrCreate`, `FileAccess.ReadWrite`, `FileShare.None` on `test-suite.lock` in the per-user state directory, with a separate `test-suite.holder.json`. Alternatives: named `Global\` mutex (Linux emulation differs, thread affinity, abandoned-mutex handling, invisible to bash); `flock(1)` (does not interoperate with .NET locks on Windows). Reason: one cross-platform implementation whose lock disappears with the holder process.
- **D2. Policy configuration.** Optional repository file `config/test-execution-policy.json`, `version: 1`, merged over built-in defaults, with the schema in `## Inputs / Outputs`. Not pushed down, because `config/` publication is a plain overwrite of destination files. Alternatives: pushed-down config file (overwrites destination settings); settings in `pyproject.toml` or `package.json` (language-specific). Reason: defaults travel with the code, overrides stay local.
- **D3. Validator.** Pure `Test-TestExecutionPolicyDocument` returns an error list; `Get-TestExecutionPolicy` merges and throws a message naming the file and field. A Pester contract test validates the committed config file. Alternative: JSON Schema file (no schema-validator dependency in the PowerShell path). Reason: same fail-fast style as `Get-PoshQCScanConfigFolder`.
- **D4. File layout.** Pure logic `.claude/hooks/test-execution-policy.ps1` and pure lock decision `.claude/hooks/test-execution-lock-decision.ps1`; thin I/O adapter `.claude/hooks/test-execution-lock.ps1` (starts no process); hook `.claude/hooks/enforce-test-execution-policy.ps1`; each with a byte-identical `.codex/hooks/` twin except the hook, whose Codex twin follows Codex exit-2 conventions. Launcher `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` and `.claude/skills/test-execution-policy/scripts/run-test-suite.sh`, with copies under `.agents/skills/test-execution-policy/scripts/` and the bundles. The launcher locates helpers by probing `.claude/hooks` then `.codex/hooks` under the repository root. Skill documentation `.claude/skills/test-execution-policy/SKILL.md` with mirrors. Alternatives: `.claude/lib/test-execution/` (scanned by the no-Python guard; the launcher starts `poetry`); a new `.claude/scripts/` folder (no precedent). Reason: skill-bundled scripts have precedent (`epic-progress-report`), sit outside the guarded roots, and are covered by shell-qc discovery.
- **D5. Command line seen by agents.** Claude uses `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh` with the suite name; Codex and humans may use the `pwsh -NoProfile -File` form. Pester gates move to the launcher; `SCRATCH` `sh` launchers remain only for non-test PowerShell. Alternative: keep `SCRATCH` launchers for Pester gates (indistinguishable from hidden wrappers). Reason: one recognizable command line.
- **D6. Pester lane exclusion.** Add `-ExcludeTag` and `-ExcludeTestFileSuffix` (string arrays, default empty, today's behavior when omitted) to `Invoke-PoshQCTest` in `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (tags into `$config.Filter.ExcludeTag`; suffixes filter the `EnumerateTests` result before sharding), passed through `Invoke-PoshQCParallelTest` and `Get-PoshQCParallelShardArgument` in `scripts/powershell/PoshQC/PoshQC.Parallel.psm1`, with bundle copies under `extensions/drm-copilot/resources/powershell/PoshQC/` and the PoshQC README. Alternative: launcher computes a file list (no PoshQC parameter accepts one). Reason: smallest seam on the existing enumerator.
- **D7. MCP entry point.** `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` and `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1` dot-source the workspace lock helpers when `.claude/hooks/test-execution-lock.ps1` (or the `.codex/hooks` copy) exists under the workspace root, acquire the lock with the bounded wait around `Invoke-PoshQCTest` (test template) or `Invoke-PoshQCSuite` (suite template, which gains `-ExcludeTag` and `-ExcludeTestFileSuffix` pass-through to `Invoke-PoshQCTest`), and pass the lane exclusions; with no helper present each template makes today's call unchanged. Effective only after an extension release and reinstall; until then the hook's MCP busy denial is the only control. Alternative: no template change (an MCP run would never hold the lock).
- **D8. Hook registration.** Append `pwsh -NoProfile -File .claude/hooks/enforce-test-execution-policy.ps1` as the last entry of the existing `Bash` PreToolUse group in `.claude/settings.json` and add one group with matcher `mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite`; mirror in the bundled `settings.json`. Codex registration per D17. Add every new hook, helper, and launcher file to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and to the Codex `core.json` through the generator. Alternative: extend `validate-bash.ps1` (wider blast radius; conflicts with #1159). Reason: matches the `enforce-worktree-poetry-venv.ps1` pattern and stays absorbable by #1159.
- **D9. Worker preservation.** The pure builder adds no worker option. The validator and classifier reject `-n` followed by a number, `--numprocesses` with a number, `-p no:xdist`, `--maxWorkers`, Jest `-w`, `--runInBand`, Jest `-i`, and `-WorkerCount`. The `pester` suite calls `Invoke-PoshQCParallelTest` without `-WorkerCount`. Alternative: reduce workers per suite to share the machine (rejected by the issue and the parallel-only directive). Reason: serialization, not throttling, removes the contention.
- **D10. `fix_all` and VS Code tasks.** Edit `scripts/dev_tools/fix_all_branches_extra.py` (pytest and Jest steps) and `scripts/dev_tools/fix_all_branches.py` (Pester and bats steps) in place to run the launcher through `pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` with the suite name as the first argument and the existing coverage arguments as the extra arguments (D18); exit 75 is reported as a queue timeout. Update the test tasks in `.vscode/tasks.json` to the same command. Alternative: leave these entry points direct (they would bypass the lock). Reason: every local suite entry point serializes on one lock.
- **D11. Executor tools.** In `.claude/agents/atomic-executor.md`, its bundle copy, and `.codex/agents/atomic-executor.toml`, replace the `Bash(poetry run pytest ...)` and `Bash(npx jest ...)` entries with one Bash entry whose prefix is `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh`; keep the `Bash(pwsh ...)` entry for non-test PowerShell. Toolchain Commands name the launcher and still contain the pinned tokens `poetry run pytest -n auto` and `Invoke-PoshQCParallelTest`. Regenerate Codex variants with the generator. Alternative: leave tools unchanged (they would advertise routes the hook denies).
- **D12. Exit and deny codes.** Launcher exit 75 for queue timeout, exit 2 for policy refusal or invalid configuration, otherwise the suite's exit code. Hook deny prefix `TEST_EXECUTION_POLICY_BLOCKED:`; queue message prefix `TEST_EXECUTION_QUEUE_TIMEOUT:`. Alternative: reuse exit 1 (indistinguishable from a test failure). Reason: 75 is `EX_TEMPFAIL` and no existing script uses it.
- **D13. Plan and skill wording.** Required statements (exact tokens for the wording tests): "CI integration and golden lanes are evidence", "non-blocking deviation", and "machine test-suite lock". A plan step that would run an integration or golden lane locally records a non-blocking deviation under `evidence/other/` of the feature folder and cites the CI job instead; a gate that exits 75 is re-run after the holder finishes and is not a failure. Alternative: free-form wording (not testable). Reason: wording tests pin the tokens across mirrors.
- **D14. Coverage population.** `config/poshqc-coverage.json` roots already include `.claude/hooks`, `.claude/skills`, `.codex/hooks`, and `scripts`, so the new PowerShell files enter the coverage population automatically; that file is not changed. Alternative: add explicit entries (redundant). Reason: the population is derived from roots.
- **D15. pytest markers and lane filtering.** Register `integration` and `golden` under `markers` in `pyproject.toml` `[tool.pytest.ini_options]` so the launcher's `-m "not integration and not golden"` is valid under `--strict-markers`. The launcher also excludes the configured file-name suffixes for pytest through `--ignore-glob`, one per suffix, without `--deselect`. The planner verifies `--ignore-glob` against pytest's documented options; if it is not suitable, the launcher passes explicit `--ignore` paths (no `-k`) computed by the pure classifier over the test tree enumerated through a filesystem seam. Alternative: rely on markers only (no file in this repository carries a lane marker today). Reason: file-name suffixes are the existing lane convention here.
- **D16. Other local suite entry points.** `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, the `.vscode/tasks.json` test tasks, and the full-suite pytest command of the atomic executor tool in `scripts/dev_tools/atomic_executor/qc_runner.py` route through the launcher, extended in place (no new Python file). Existing tests that assert their current argv or wording are updated with stated reasons; candidates to check: `tests/scripts/dev_tools/test_fix_all_branches.py`, `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`, `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py`, `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`, `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`. Alternative: leave them direct (they would bypass the lock and the lane exclusion).
- **D17. Codex MCP hook matcher and `.agents` scripts publication.** `.codex/config.toml` has only the catch-all MCP group today, and no `.agents` skill in the Codex bundle carries a `scripts/` folder. The Codex hook twin registers in the `^Bash$` group (with `command_windows` and `timeout = 30`) and, for MCP tools, in a new group whose matcher is the exact pair of MCP tool names in the form already used by the catch-all group; mirrored in the bundled `config.toml`. The Codex runtime reaches the launcher through `.claude/skills/test-execution-policy/scripts/` when present and through `.agents/skills/test-execution-policy/scripts/` otherwise. The plan includes the bundle copy and the push-down contract test runs that prove publication; if the Codex push-down does not publish `scripts/`, the plan extends the publication list in the existing TypeScript push-down code (permitted as extension-command TypeScript). Alternative: Claude-only launcher location (Codex destinations without `.claude/` would have no launcher).

- **D18. Launcher argument entry.** `Invoke-TestSuite.ps1` has no param block and no `CmdletBinding`; the script-file entry reads `$args`, takes the suite name from the first element, and passes the remaining elements unchanged to an inner function that can be dot-sourced and carries the seams. The `pwsh -NoProfile -File` form is `Invoke-TestSuite.ps1 <suite> <extra arguments>`. Alternative: a `-Suite` parameter plus a `ValueFromRemainingArguments` `-ExtraArgument` (rejected). Reason: a planning probe of that signature through `pwsh -File` showed that `-v` bound to the common parameter `-Verbose` and was dropped, `-s` bound to `-Suite` and raised an error, `-p no:xdist` raised an ambiguous-parameter error instead of the policy exit 2, and `--` was not honored; a script with no param block that reads `$args` kept all of them unchanged.

Plan-time verification obligation: the live Linux two-process lock proof (research 2.1 CONFIRM; .NET `FileShare.None` exclusion between two processes on Linux) is executed in the devcontainer and recorded under `evidence/other/` of the feature folder before the hook registration task, so the proof script (which runs the launcher twice) is not denied by the new hook.

## Constraints & Risks

- **Timeout bound.** `waitMilliseconds` default 90000 and maximum 540000 keep the queue below the Bash tool default (120000 ms) and maximum (600000 ms) timeouts respectively.
- **Security.** The hook is a policy-level control, not a security control. Unreadable or oversized wrapper files are allowed. Holder records contain absolute paths and pids; evidence artifacts redact them.
- **MCP gap.** Until the extension release carrying D7 is installed, an MCP Pester run does not hold the lock; the hook's busy denial is the only control, and the execution-environment brief states the gap.
- **Coverage.** Local runs no longer execute integration-named files, so local per-file coverage of production code reached only by them can fall; plans cite the CI coverage step for such files (D13).
- **File size.** New PowerShell files stay under 500 logical lines through the D4 split. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` is checked against `config/file-size-baseline.json` before parameters are added; lane-filter logic moves to a small helper if the module is near a tier.
- **Python and language constraints.** No new Python file; Python changes are in-place edits of `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/qc_runner.py`, and `pyproject.toml`. Pushed-down logic is PowerShell or bash. TypeScript changes, if any, are limited to the push-down publication list (D17). No hook or `.claude/hooks`, `.claude/lib`, or `.codex/hooks` file starts an interpreter (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
- **Cross-platform.** Lock-directory resolution is a pure function of injected values with both OS branches tested; fixtures use forward-slash relative paths, exact file-name case, and no drive letters (Linux hook-suite job).

## Implementation Strategy

### Scope (new files)

- `.claude/hooks/test-execution-policy.ps1`, `.codex/hooks/test-execution-policy.ps1`
- `.claude/hooks/test-execution-lock-decision.ps1`, `.codex/hooks/test-execution-lock-decision.ps1`
- `.claude/hooks/test-execution-lock.ps1`, `.codex/hooks/test-execution-lock.ps1`
- `.claude/hooks/enforce-test-execution-policy.ps1`, `.codex/hooks/enforce-test-execution-policy.ps1`
- `.claude/skills/test-execution-policy/SKILL.md`, `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, `.claude/skills/test-execution-policy/scripts/run-test-suite.sh`
- `.agents/skills/test-execution-policy/SKILL.md`, `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, `.agents/skills/test-execution-policy/scripts/run-test-suite.sh`
- `.github/skills/test-execution-policy/SKILL.md`
- Claude bundle copies: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/test-execution-policy.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/test-execution-lock-decision.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/test-execution-lock.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-test-execution-policy.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/scripts/run-test-suite.sh`
- Codex bundle copies: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/test-execution-policy.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/test-execution-lock-decision.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/test-execution-lock.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-test-execution-policy.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/run-test-suite.sh`
- Copilot bundle copy: `extensions/drm-copilot/resources/customizations/.github/skills/test-execution-policy/SKILL.md`
- `config/test-execution-policy.json`

### Scope (edited files)

- PoshQC: `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.Parallel.psm1`, `scripts/powershell/PoshQC/README.md`, and their bundle copies `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Parallel.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/README.md`.
- MCP templates: `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`, `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1`.
- Registration: `.claude/settings.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`, `.codex/config.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (generated).
- Python in place: `pyproject.toml`, `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/qc_runner.py`; and `.vscode/tasks.json`.
- execution-environment brief: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`. Sections: Tool Routes by Agent, PowerShell Route and PoshQC MCP Limits, Command-Text Restrictions, Test Runtime, Test Isolation Checks, a new `## Test Execution Policy` section, and Contract Tests That Pin Mirrored Files.
- atomic-plan-contract: `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` (`## Phase 0 Requirements` and `## Final QA Loop`).
- QA-gate and invoke skills: `.claude/skills/python-qa-gate/SKILL.md`, `.agents/skills/python-qa-gate/SKILL.md`, `.claude/skills/powershell-qa-gate/SKILL.md`, `.agents/skills/powershell-qa-gate/SKILL.md`, `.claude/skills/csharp-qa-gate/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.claude/skills/invoke-powershell-engineer/SKILL.md`, `.agents/skills/invoke-powershell-engineer/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `.agents/skills/invoke-csharp-engineer/SKILL.md`, their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, and the csharp legacy variants `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`.
- Agents (TypeScript has no QA-gate or invoke skill; its equivalent is the typescript-engineer agent): `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/typescript-engineer.md`, their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` and `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`; Codex bases `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, `.codex/agents/python-typed-engineer.toml`, `.codex/agents/powershell-typed-engineer.toml`, `.codex/agents/csharp-typed-engineer.toml`, `.codex/agents/typescript-engineer.toml`, `.codex/agents/python-atomic-executor.toml`, `.codex/agents/powershell-atomic-executor.toml`, `.codex/agents/csharp-atomic-executor.toml` (variants and bundle copies regenerated); Copilot `.github/agents/atomic_executor.agent.md`, `.github/agents/powershell-atomic-executor.agent.md`, `.github/agents/python-atomic-executor.agent.md`, `.github/agents/csharp-atomic-executor.agent.md`, `.github/agents/python-typed-engineer.agent.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.github/agents/typescript-engineer.agent.md`, and their bundle copies under `extensions/drm-copilot/resources/customizations/.github/agents/`.
- Contract tests extended: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` gains D13 rows for the skill and agent files above.

### New tests

- `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` (config defaults, merge, validator, lane classifier, worker-token check, command builder, runner recognition, hidden-wrapper text classification).
- `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1` (state model and driver loop with `Clock` and `Sleep` seams).
- `tests/scripts/claude-hooks/test-execution-lock.Tests.ps1` (directory resolution, probe, holder read and write through `OpenLockStream`, `ReadHolderText`, `WriteHolderText`, `GetProcessStartUtc` seams).
- `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` and `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1`.
- `tests/scripts/claude-hooks/test-execution-policy.RepoConfig.Tests.ps1` (validates the committed `config/test-execution-policy.json`).
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` (launcher with a `StartSuiteProcess` seam).
- `tests/shell/test_run_test_suite.bats` with the checked-in stub `tests/fixtures/test-execution-policy/pwsh-stub.sh` reached through `TEST_SUITE_PWSH_BIN`.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingLaneExclusion.Tests.ps1` (`-ExcludeTag`, `-ExcludeTestFileSuffix`, shard argument text) and `tests/scripts/powershell/PoshQC/PoshQC.McpTemplateLock.Tests.ps1` (template lock branch with seams, unchanged behavior with no helper).

### Test strategy

- Pure modules are tested by dot-sourcing the hook-folder helper; inputs are strings, hashtables, and scriptblock seams.
- No temporary files: config text, script-file text, and holder records are in-memory strings passed through read seams; lock file calls go through injected seams.
- No real waits: the driver loop's `Clock` advances by `pollMilliseconds` on each injected `Sleep` call.
- No real process start: the launcher's `StartSuiteProcess` seam and the bats `TEST_SUITE_PWSH_BIN` stub replace the runner.
- Environment reads go through injected values; no test sets an environment variable without a paired restore; `Invoke-PoshQCLeakScan` runs in the gate.
- Gates are parallel only: one `Invoke-PoshQCParallelTest` run (through the launcher once it exists; the Phase 0 baseline uses the current route), one `poetry run pytest -n auto` run with coverage for the edited Python modules in dotted form, bats through `scripts/bash/shell-qc.sh test --coverage`, and Jest through its normal workers only if a TypeScript file changes.
- Coverage: 85% line per changed PowerShell file from `artifacts/pester/powershell-coverage.xml`; 85% line and 75% branch per edited Python module; 85% line through kcov for the shim.

### Push-down and mirror obligations

- Byte-identical twins in `.claude/hooks/` and `.codex/hooks/` for the three helper files; bundle copies for every new and edited `.claude`, `.agents`, `.codex`, and `.github` file.
- Every new hook, helper, and launcher file is listed in the Claude `core.json` and, through the generator, the Codex `core.json`.
- Proof runs: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_poshqc_bundled_parity.py`, the Codex generator `--check`, `test_codex_agent_wrapper_contracts.py`, `test_claude_rules_frontmatter.py`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, and `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
- The execution-environment brief is updated in the same change in all of its copies (its maintenance rule).

### Sibling-item interactions

| Sibling | Shared surface | Handling |
|---|---|---|
| #1156 lighter integration-merge path | execution-environment brief, atomic-plan-contract, orchestrate skill | Text merges only. |
| #1157 owner directives reach agents | atomic-executor, atomic-planner, typed-engineer agents, execution-environment brief | Same agent files; re-read at execution start. |
| #1159 single hook dispatcher | `.claude/settings.json`, `.codex/config.toml`, their bundles, both `core.json` manifests, `hook-dependency-guard.ps1` | The new hook stays a normal standalone hook registered the usual way, so #1159 can absorb it. |
| #1160 preimplementation gate false positives | execution-environment brief `## Hook Execution Context`; `.claude/hooks/hook-command-payload.ps1` parsing if it changes | The new hook consumes `Read-CommandLineInvocationSegment` unchanged and does not edit the parser. |
| #1161 planner worktree removal | atomic-planner agent, atomic-plan-contract | Text merges only. |
| #1162 cross-epic dependencies | epic skills; possibly the execution-environment brief | Low overlap. |
| #1163 isolated worktrees and session-root resolution in hooks | `.claude/settings.json`, `HookTargetWorktree.psm1`, execution-environment brief | The hook reads config relative to `$PSScriptRoot`; if #1163 changes root-resolution conventions, the hook adopts them. |

Shared files (`.claude/settings.json`, `.codex/config.toml`, both `core.json` files, every execution-environment and atomic-plan-contract copy, and the executor and planner agents) are re-read at execution start.

### Dependencies, logging, rollout

- No new package dependency.
- Logging: stderr messages with the two prefixes only; the launcher writes nothing else of its own.
- Rollout: effective in this repository on merge. Destination repositories receive hooks, helpers, launcher, registrations, and skill text through a push-down refresh after the extension release; the MCP template lock (D7) applies after release and reinstall. Fallback: `config/test-execution-policy.json` with `requireLauncher: false`, `localLanes.exclude: []`, or `machineLock.enabled: false`.

## Acceptance Criteria

Each item names the issue acceptance criterion it traces to (AC1 through AC5 in `issue.md`, in order).

### AC1 — Policy configuration documented and validated; defaults changed by design

- [ ] (AC1) `.claude/skills/test-execution-policy/SKILL.md` documents every configuration key in the `## Inputs / Outputs` table with its default and validation rule, the lock location, the holder record fields, exit codes 75 and 2, and the prefixes `TEST_EXECUTION_POLICY_BLOCKED:` and `TEST_EXECUTION_QUEUE_TIMEOUT:`; its `.agents`, `.github`, and bundle copies are equal in text, proven by passing `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`.
- [ ] (AC1) `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` passes cases proving that with no config text `Get-TestExecutionPolicy` returns `localLanes.exclude` equal to integration and golden, `machineLock.enabled` true, `waitMilliseconds` 90000, `pollMilliseconds` 2000, and `requireLauncher` true.
- [ ] (AC1) `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` passes one `Test-TestExecutionPolicyDocument` case per validation rule (unknown top-level key, wrong `version`, non-array or blank entry, excluded lane not defined, `waitMilliseconds` and `pollMilliseconds` below and above range, absolute and `..` `workingDirectory`, empty `command`, worker-reduction token in `command`, unknown `runner`), each returning an error that names the field, and a boundary case accepting each range endpoint.
- [ ] (AC1) `tests/scripts/claude-hooks/test-execution-policy.RepoConfig.Tests.ps1` passes, proving the committed `config/test-execution-policy.json` validates and that its merged policy classifies `collector-integration.test.ts` and `DocsCompleteIntegration.Tests.ps1` as integration-lane file names.
- [ ] (AC1) `pyproject.toml` registers the `integration` and `golden` markers, and a pytest run through the launcher's `pytest` suite completes under `--strict-markers` without a marker error (exit code recorded under `evidence/qa-gates/`).

### AC2 — Machine-wide lock, bounded wait, retry code naming the holder, workers unchanged

- [ ] (AC2) `tests/scripts/claude-hooks/test-execution-lock.Tests.ps1` passes cases proving the lock directory resolves to `LocalApplicationData` joined with `drm-copilot/test-execution` on Windows, to `XDG_STATE_HOME` joined with `drm-copilot/test-execution` when set, and to `HOME` joined with `.local/state/drm-copilot/test-execution` otherwise, from injected values only.
- [ ] (AC2) `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` passes a case where the injected lock stays busy: the launcher does not call `StartSuiteProcess`, exits 75, and writes a stderr line starting `TEST_EXECUTION_QUEUE_TIMEOUT:` that contains the holder's suite name and pid from the injected holder record.
- [ ] (AC2) `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` passes cases proving that on a free lock the launcher writes the holder record before starting the suite, propagates the suite's exit code (including a non-zero code), and disposes the lock stream and deletes the holder record when the suite throws.
- [ ] (AC2) `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` passes a case for each built-in suite proving the built command carries no `-n` with a number, `--numprocesses`, `-p no:xdist`, `--maxWorkers`, `--runInBand`, or `-WorkerCount` token, and that the `pytest` suite keeps `-n auto` and the `pester` suite calls `Invoke-PoshQCParallelTest` without `-WorkerCount`.
- [ ] (AC2) `tests/scripts/powershell/PoshQC/PoshQC.TestingLaneExclusion.Tests.ps1` passes cases proving `-ExcludeTag` reaches `Filter.ExcludeTag`, `-ExcludeTestFileSuffix` removes matching files from the enumerated set before sharding, both pass through `Get-PoshQCParallelShardArgument`, and omitting both leaves the enumerated set and configuration unchanged; `test_poshqc_bundled_parity.py` passes.
- [ ] (AC2) `tests/scripts/powershell/PoshQC/PoshQC.McpTemplateLock.Tests.ps1` passes cases proving the run-poshqc-test and run-poshqc-suite templates acquire the lock and pass lane exclusions when the workspace lock helper exists, and run `Invoke-PoshQCTest` unchanged when it does not.
- [ ] (AC2) `tests/shell/test_run_test_suite.bats` passes, proving through the `TEST_SUITE_PWSH_BIN` stub that the shim passes the suite name and extra arguments to `Invoke-TestSuite.ps1` unchanged and exits with the stub's exit status, including 75.
- [ ] (AC2) `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/qc_runner.py`, and the `.vscode/tasks.json` test tasks invoke `Invoke-TestSuite.ps1`; their tests (`tests/scripts/dev_tools/test_fix_all_branches.py`, `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`, and any other D16 candidate that asserts the changed argv) assert the launcher argv and that exit 75 is reported as a queue timeout, and pass in the pytest gate.
- [ ] (AC2) The live Linux two-process proof is recorded under `evidence/other/` of the feature folder before the hook registration task: with one launcher holding the lock, a second launcher exits 75 with a `TEST_EXECUTION_QUEUE_TIMEOUT:` line naming the first.

### AC3 — Pure lock-decision and lane-classification logic tested with injected seams

- [ ] (AC3) `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1` passes one case per row of the lock-decision state model (`Skip`, `Acquire`, `AcquireReplacingStaleRecord`, `Wait`, `Timeout`), plus `waitMilliseconds` 0 returning `Timeout` on the first busy probe.
- [ ] (AC3) `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1` passes holder-description cases: matching process start time gives the named holder; a missing process or a differing start time gives the unidentified stale-record description with the pid; an absent or unparseable record gives the unidentified description.
- [ ] (AC3) `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1` passes a driver-loop case using injected `Clock` and `Sleep` seams in which every decision before the clock reaches 90000 ms is `Wait`, the decision at 90000 ms is `Timeout`, and the `Sleep` seam receives only `pollMilliseconds` values.
- [ ] (AC3) `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` passes lane-classification cases for each default suffix (including mixed case), a pytest `-m` expression selecting a lane marker, a `-m` expression with `not` before the marker (not a lane selection), a Pester `-Tag` lane value, and a `--filter` naming a lane category.
- [ ] (AC3) The test files named under AC3 create no temporary file and perform no real wait: a review of each file finds no `New-TemporaryFile`, `TestDrive`, `Start-Sleep`, or real filesystem write, and `Invoke-PoshQCLeakScan` passes in the gate run.

### AC4 — Hook denies local lane, second concurrent suite, and hidden wrapper suites, naming the policy

- [ ] (AC4) `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` passes a deny case for each runner word in `## Behavior` invoked directly, inside `sh -c`, inside `pwsh -Command`, and inside `pwsh -EncodedCommand`, each with a reason starting `TEST_EXECUTION_POLICY_BLOCKED:` that contains "test-execution policy" and the launcher command.
- [ ] (AC4) `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` passes cases proving the sanctioned launcher is allowed, and is denied with `TEST_EXECUTION_POLICY_BLOCKED:` when its arguments name an integration-suffixed path, a lane marker, a lane tag, or a worker-reduction token.
- [ ] (AC4) `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` passes hidden-wrapper cases: a `sh` script file, a `pwsh -File` script, and a `.py` script whose seam-supplied text runs a suite are each denied with `TEST_EXECUTION_POLICY_BLOCKED:`; a script that runs only `Invoke-ScriptAnalyzer` is allowed; an unreadable script and a script over 262144 bytes are allowed.
- [ ] (AC4) `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` passes MCP cases: `mcp__drm-copilot__run_poshqc_test` and `mcp__drm-copilot__run_poshqc_suite` are denied with `TEST_EXECUTION_POLICY_BLOCKED:` naming the holder when the injected probe reports busy, and allowed when it reports free or when `machineLock.enabled` is false.
- [ ] (AC4) `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` passes cases for invalid configuration (runner command denied naming `config/test-execution-policy.json` and the field; non-test command allowed), `requireLauncher: false` (direct runner allowed), `localLanes.exclude` empty (lane path allowed), an empty command (allowed), a malformed payload (allowed), and a dependency-load failure.
- [ ] (AC4) `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1` passes the same deny and allow decisions through the Codex twin and its exit-2 entry conventions, including empty or unparseable stdin.
- [ ] (AC4) `.claude/settings.json`, `.codex/config.toml`, and their bundle copies register the hook in the Bash group and in an MCP group whose matcher names exactly `mcp__drm-copilot__run_poshqc_test` and `mcp__drm-copilot__run_poshqc_suite`; `test_push_down_pack_manifest_dependency_closure.py`, both pack-manifest completeness tests, `hook-dependency-guard-completeness.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.

### AC5 — Skill and agent text updated

- [ ] (AC5) `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` passes with new rows requiring the tokens "CI integration and golden lanes are evidence", "non-blocking deviation", and "machine test-suite lock" in every execution-environment, atomic-plan-contract, python-qa-gate, powershell-qa-gate, csharp-qa-gate, invoke-python-engineer, invoke-powershell-engineer, and invoke-csharp-engineer copy and in the typescript-engineer agent copies named in `## Implementation Strategy`, while the existing `poetry run pytest -n auto` and `Invoke-PoshQCParallelTest` requirements still pass.
- [ ] (AC5) The execution-environment brief copies state the launcher command, exit 75 re-run rule, the hook and its deny prefix, the MCP gap until the extension release, and lanes as CI-only evidence, and are byte-identical, proven by `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passing.
- [ ] (AC5) `.claude/agents/atomic-executor.md`, its bundle copy, and `.codex/agents/atomic-executor.toml` list the launcher Bash entry in place of the direct pytest and Jest entries, the Codex generator `--check` passes, and `test_codex_agent_wrapper_contracts.py` passes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
