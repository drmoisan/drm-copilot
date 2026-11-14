---
name: test-execution-policy
description: 'Test-execution policy and launcher. Use before running any local test suite so it runs through the launcher under the machine test-suite lock with the integration and golden lanes excluded, and so exit codes 75 and 2 are read correctly.'
---

# Test-Execution Policy

Local test suites run only through one launcher. The launcher excludes the integration and golden lanes, holds the machine test-suite lock so that at most one suite runs on a machine at a time, and leaves the suite's own parallel workers unchanged. A PreToolUse hook denies direct runner commands and scripts that hide one.

CI integration and golden lanes are evidence: a plan step that would run an integration or golden lane locally records a non-blocking deviation under `evidence/other/` of the feature folder and cites the CI job that runs the lane instead.

## When to Use This Skill

Use this skill when:

- running a test suite as a gate, a phase gate, a task check, or a debugging run;
- reading the exit code or the first output line of a launcher run;
- writing a plan or a skill that names a test command;
- changing `config/test-execution-policy.json`.

## Commands

The suite name is the first argument; extra arguments follow it and reach the suite unchanged. There is no `-Suite` or `-ExtraArgument` parameter.

- Claude agents: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` (the `sh` form with a literal `.sh` path passes the worktree isolation guard).
- In an agent worktree, the pytest gate unsets the inherited virtual environment: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` (see `## Worktree Python Environment` of the `execution-environment` skill).
- Codex and humans: the same, or `pwsh -NoProfile -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pytest` followed by the extra arguments.
- Codex-only destinations use the same scripts under `.agents/skills/test-execution-policy/scripts/`.

Built-in suites: `pytest` (`poetry run pytest -n auto`), `pester` (`Invoke-PesterSuite.ps1`, below), `jest` (`node run-jest.cjs` in the repository root), and `dotnet-test` (`dotnet test`). This repository's configuration adds `jest-extension` (`node run-jest.cjs` in `extensions/drm-copilot`) and `bats` (the shell QC script `scripts/bash/shell-qc.sh` with its `test` command).

### The `pester` suite entry

The `pester` suite runs `pwsh -NoProfile -NonInteractive -File` with the launcher-sibling `Invoke-PesterSuite.ps1`, which imports `scripts/powershell/PoshQC/PoshQC.psd1`, calls `Invoke-PoshQCParallelTest` with `-Root .` and no `-WorkerCount`, and exits with the result's `ExitCode`. It reads its arguments as follows: a word equal, ignoring case, to `-` plus a declared parameter name of `Invoke-PoshQCParallelTest` starts a key; every other word is a value of the current key, so a suffix such as `-integration.test.ts` stays a value; a key with no value is `$true`; a repeated key appends; and a value before any key stops the script with exit 1 and a message starting `Invoke-PesterSuite: unexpected argument`. It runs only through the launcher; a direct `pwsh -File` call of it, or a script that calls it, is a direct runner for the hook.

### Scoped Pester runs

A task check, a fail-before proof, and a consumer-suite check run their Pester selection through the launcher `pester` suite followed by `-TestPath` and the test files or folders, for example `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/powershell/PoshQC tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1`. The suite passes `-TestPath` to `Invoke-PoshQCParallelTest`, which resolves the selection to its test files and runs them under the machine test-suite lock with the integration and golden lanes excluded, starting at most one shard per file. The hook denies a lane path in that list. The merged files under `artifacts/pester/` then cover the selection only and are not gate evidence. Such a run replaces a direct one-process Pester run.

## Exit Codes and Messages

| Code | Meaning |
|---|---|
| 75 | Queue timeout: the machine test-suite lock stayed busy for `machineLock.waitMilliseconds`. The stderr line starts `TEST_EXECUTION_QUEUE_TIMEOUT:` and names the holder. |
| 2 | Policy refusal or invalid configuration, written as the first stderr line, starting `TEST_EXECUTION_POLICY_BLOCKED:`, before any suite starts. |
| any other | The suite's own exit code. A suite's own exit 75 is reported as 1 with a stderr line starting `TEST_EXECUTION_SUITE_EXIT:`, so a launcher exit 75 always means a queue timeout. |

Classification by consumers: a result is a queue timeout when its exit code is 75, or when it is non-zero and the first non-blank line of its captured output starts with `TEST_EXECUTION_QUEUE_TIMEOUT:`. It is a policy refusal only when its exit code is 2 and the first non-blank line of its captured output starts with `TEST_EXECUTION_POLICY_BLOCKED:`, because pytest also exits 2 on an interrupted run or a collection error and `scripts/bash/shell-qc.sh` exits 2 on a usage error. Every other result keeps its usual handling. A consumer that does not capture output classifies only 75. The Python consumers share `classify_launcher_exit` in `scripts/dev_tools/atomic_executor/qc_runner_expectations.py`.

Re-run rule: a launcher exit 75 means the machine test-suite lock was busy; the gate is re-run after the holder finishes and is recorded as a queue timeout, not a failure.

## Configuration

`config/test-execution-policy.json` is optional and repository-owned (it is not pushed down). It is merged over the built-in defaults: objects merge by key and arrays replace. An absent file means the defaults. An invalid file stops every launcher and runner command with `TEST_EXECUTION_POLICY_BLOCKED:` naming the file and the failing field. Unknown top-level keys are errors.

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
| `suites` | object of suite definitions | the built-in suites | each entry: `workingDirectory` repository-relative with no absolute path and no `..` segment; `command` a non-empty string array with no worker-reduction token; `runner` one of `pytest`, `pester`, `jest`, `mstest`, `bats` |

Lane exclusion arguments per runner: pytest receives `-m` with one `not integration and not golden` word and one `--ignore-glob=*<suffix>` word per suffix (the `integration` and `golden` markers are registered in `pyproject.toml`); the `pester` suite receives `-ExcludeTag` and `-ExcludeTestFileSuffix` with one word per value; Jest receives one `--testPathIgnorePatterns=<pattern>` word each for `/node_modules/`, `/out/`, and each suffix; MSTest receives one `--filter` word; bats receives none.

Disable switches: `requireLauncher: false` turns off the direct-runner and hidden-wrapper denials; `localLanes.exclude: []` turns off the lane exclusions and lane denials; `machineLock.enabled: false` turns off the launcher queue and the hook's busy denial of the MCP Pester tools.

## Machine Test-Suite Lock

- Lock directory: on Windows, `[Environment]::GetFolderPath('LocalApplicationData')` joined with `drm-copilot/test-execution`; elsewhere `$XDG_STATE_HOME`, or `$HOME/.local/state` when it is unset, joined with `drm-copilot/test-execution`. `XDG_RUNTIME_DIR` is not used.
- Files: the lock file `test-suite.lock`, held with an OS file lock (`FileShare.None`) for the whole run, and the holder record `test-suite.holder.json`.
- Holder record fields: `pid`, `processStartUtc`, `suite`, `commandLine`, `worktreeRoot`, `acquiredAtUtc`, and `policyVersion`. Evidence never copies `worktreeRoot` or another absolute path.
- The OS releases the lock when the holder process exits for any reason; a stale holder record is overwritten by the next holder. A lock is per user and per machine, so a devcontainer and its host hold separate locks.
- The lock serializes suites; it never reduces the parallel worker count of the running suite.

## Hook

`.claude/hooks/enforce-test-execution-policy.ps1` (Codex twin `.codex/hooks/enforce-test-execution-policy.ps1`) reads every Bash command record, including `sh -c`, `bash -c`, `pwsh -Command`, `pwsh -EncodedCommand`, `eval`, `xargs`, and substitution bodies, and denies with `TEST_EXECUTION_POLICY_BLOCKED:` and the launcher command:

- a direct runner: `pytest`, `py.test`, `jest`, the interpreters `python`, `python3`, or `py` with `-m pytest`, `coverage run` with `-m pytest`, a Python `-c` or `node -e` code argument that runs a suite, `node` with `run-jest.cjs` or a Jest package path, `bats`, `shell-qc.sh test`, `Invoke-Pester`, `Invoke-PoshQCTest`, `Invoke-PoshQCParallelTest`, `Invoke-PoshQCSuite`, `Invoke-PesterSuite.ps1`, and `dotnet test`. A runner word followed only by `--version`, `--help`, or `-h` is allowed;
- an npm script runner: `npm`, after an optional `--prefix <directory>`, with `test` or `t`, or `run` or `run-script` followed by a script name equal to `test` or starting with `test:` (so `npm run test:unit` is a runner and `npm run build`, `npm run testing`, and `npm run typecheck:test` are not);
- a hidden wrapper: a script file run by `sh`, `bash`, `zsh`, `dash`, `ksh`, `pwsh -File`, `powershell -File`, `python`, `poetry run python`, or `node` whose text runs a suite (read up to 262144 bytes; an unreadable or larger file is allowed);
- a launcher or runner argument that selects an excluded lane, or a worker-reduction token of the suite's runner;
- text naming the launcher seam variables `TestSuiteLauncherSeams` or `PesterSuiteSeams` (`TEST_EXECUTION_POLICY_BLOCKED: launcher seam override`).

Prefixes do not hide a runner: `VAR=value`, `env` with its options (including `-u`, `-C`, and `-S`), `timeout`, `time`, `command`, `nohup`, `exec`, `nice`, `stdbuf`, and `sudo` are skipped, and the launch commands `poetry run`, `uv run`, `uvx`, `pipx run`, `npx`, and `npm exec` are replaced by the command they launch. `command -v` and `command -V` only look a name up and are allowed. A prefix or launch option the hook does not model, followed by a runner word, is denied.

Worker-reduction tokens per runner: pytest `-n` or `--numprocesses` with a number (space or `=` form) and `-p no:xdist` (`-n auto` is accepted); Jest `--maxWorkers`, `-w`, `--runInBand`, and `-i`; Pester `-WorkerCount`; MSTest and bats have none.

The hook does not queue: a launcher command is allowed while the lock is busy, and the second launcher waits and exits 75. The hook is a policy-level control, not a security control.

## MCP Gap

`mcp__drm-copilot__run_poshqc_test` and `mcp__drm-copilot__run_poshqc_suite` are denied while the lock is busy, naming the holder. The MCP templates hold the lock and pass the lane exclusions only after the extension release that carries them is installed; until then an MCP Pester run does not itself hold the lock. An MCP result carries no exit code, so a template exit 75 is not visible in it, and an MCP Pester run is not gate evidence.
