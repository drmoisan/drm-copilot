# Research: parallel pytest (xdist) and concurrent Pester shards (issue #1048)

- Timestamp: 2026-10-31T13-15
- Scope: Part 1 (pytest with pytest-xdist) and Part 2 (Pester) of `docs/features/potential/promoted/2026-10-31-pytest-xdist-parallel-test-cycle.md`.
- Method: Read, Grep, Glob and WebFetch only. No command was run; every item that needs a command is under "Orchestrator to confirm".
- Confidence labels: verified = read directly from the cited file or page; likely = inferred from verified facts; unverified = not checked.
- No numeric `spec.md` acceptance criterion is proposed from this document, so no `## Numeric Derivation Evidence` section is included. Counts below are grep occurrence counts for orientation only.

## Corrections to the issue text

- `tests/unit` holds only TypeScript files (`hello-typescript.test.ts`, `jest-config-resolution.test.ts`, `vscode-test-removal.test.ts`); a grep for Python `def test_` in `tests/unit` found no match. pytest collects `testpaths = ["tests"]`, which in practice is `tests/schemas`, `tests/scripts`, `tests/discovery_runtime` and `tests/test_pytest_collection.py`. (pyproject.toml `[tool.pytest.ini_options]`; Glob of `tests/*/*`; verified)
- The local `artifacts/pester/pester-junit.xml` (gitignored, from a serial run on the owner machine) holds 436 `<testsuite>` elements, one per test file, but the issue states 482 `*.Tests.ps1` files. The gap is unexplained (older artifact, or excluded folders). (artifacts/pester/pester-junit.xml; verified count, cause unverified)

## Part 1: pytest

### Q1. Inventory of patterns that fail under xdist

Grep occurrence counts over `tests/**/*.py` (source: Grep on `tests`; verified as counts, relevance judged by reading):

| Pattern | Occurrences | Files | Where |
|---|---|---|---|
| `os.environ[...]`, `os.environ.update/pop/setdefault`, `os.putenv` | 0 | 0 | none (tests use `monkeypatch`; `monkeypatch.setenv` and friends were counted only to confirm use) |
| `os.chdir`, `sys.path.insert/append/remove`, `sys.modules[..]` writes, `importlib.reload` | 9 | 3 | `tests/conftest.py` 2, `test_resolve_hard_lock_prompt.py` 3, `test_validate_orchestration_artifacts_invocation.py` 4 |
| `tempfile`, `mkdtemp`, `NamedTemporaryFile`, `TemporaryDirectory`, `/tmp/` | 3 | 2 | string literals only (`atomic_executor/test_cli.py` `"/tmp/repo"` with `noqa: S108`; `test_potential_to_issue.py` `Path("/workspace/tmp/file.md")`); no real temp file |
| `tmp_path`, `tmpdir` | 1 | 1 | a docstring in `test_collect_pr_context_expected_exit.py` saying it is never used |
| `time.sleep`, `asyncio.sleep`, `time.time()`, `datetime.now()`, `date.today()` | 5 | 3 | `test_agentic_sync_branches.py` 2, `test_agentic_sync_artifacts.py` 2 (`datetime.now(timezone.utc)` building a value, not a wait), `test_fix_all_json_cancel.py` 1 (docstring says `time.sleep` is never called) |
| `scope="module"` / `session` / `package` fixtures | 27 | 21 | all `module`; 0 `session`. Concentrated in `tests/discovery_runtime` (20 files incl. `*_test_support.py`), plus `tests/scripts/dev_tools/discovery/analyzer/test_vsto_compatibility.py` and `tests/scripts/dev_tools/test_orchestration_handoff_schema.py` |
| Module-level mutable containers, `count(`, `lru_cache`, `global` (heuristic regex, includes constants) | 80 | 52 | `tests/scripts/dev_tools` 47 files, `tests/discovery_runtime` 7, `tests/schemas` 1; most are constant tables, not mutated state |
| Real `subprocess.run/Popen/check_output` calls | 2 | 1 | `atomic_executor/test_qc_runner.py` (likely argv assertions, not real launches; unverified) |
| `parametrize(...)` fed by `set(`, `.keys()`, `glob(`, `iterdir(`, `rglob(`, `listdir` on the same line | 0 | 0 | none found on single lines; multi-line forms not checked |
| Hypothesis imports | 0 | 0 | `tests` does not use Hypothesis; property tests use seeded `random.Random` (12 files, 35 occurrences) |

Per-directory split (only where a grep returned per-file rows): `os.chdir/sys.path/sys.modules/reload` hits are all under `tests/` root and `tests/scripts/dev_tools`; module-scope fixtures are 25 of 27 under `tests/discovery_runtime`; real-temp-file hits are all under `tests/scripts/dev_tools`.

Environment and gitignored state: no test writes `os.environ`. The `artifacts/` token appears in 278 occurrences across 115 files, but sampled uses are path strings built against an in-memory filesystem (for example `test_epic_planner_readiness.py` sets `ROOT = Path("C:/workspace")` and serves files from a `MemoryFileSystem` class). No test was found that reads a real gitignored `artifacts/` file. (tests/scripts/dev_tools/test_epic_planner_readiness.py; likely, because only a sample was read)

Isolation primitive: `tests/conftest.py` provides `mem_fs_path`, which monkeypatches about 17 `pathlib.Path` methods plus `os.getcwd` and `os.chdir` for one test and restores them through `monkeypatch`. Its `_MEM_TEST_ROOT_COUNTER` is a process-global `itertools.count`, which is per worker under xdist and harmless. The autouse `guard_unmocked_code_launcher_subprocess` keys on `request.node.nodeid` substring, unchanged by xdist. `tests/scripts/dev_tools/conftest.py` has one autouse `stub_npm_resolution`. There are no other conftest files in the repo outside `.venv`. (tests/conftest.py; tests/scripts/dev_tools/conftest.py; Glob `**/conftest.py`; verified)

Most suspect files (12 are evidence-backed; the remaining three slots are not filled because no further evidence was found):

1. `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`: three tests call `importlib.reload(resolve_hard_lock_prompt)` while `sys.modules["pyperclip"]` is patched to a mock or `None`. The reloaded module keeps its `pyperclip` global after the patch exits, so later tests in the same worker that call `copy_to_clipboard` see the mock. Order-sensitive leaker; xdist changes which tests share a worker. (likely)
2. `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`: `isolated_import_state` rebinds `sys.path` and deletes and restores every `scripts.*` entry in `sys.modules`; it restores in `finally`, but any failure between the delete and the restore, or a concurrent import in a plugin, would leave `scripts` half-imported. Safe per process; order-sensitive within a worker. (likely)
3. `tests/conftest.py`: the `sys.path.insert(0, repo_root)` at import is what makes `import scripts...` work in each worker. Workers import `conftest.py` themselves, so it is safe, but `tests/test_pytest_collection.py` asserts `"conftest" in sys.modules` and would fail under `--import-mode=importlib` (module name differs). (likely)
4. `tests/test_pytest_collection.py`: pins conftest bootstrap behavior (see 3). (verified)
5. `tests/discovery_runtime/source_snapshot_test_support.py` (three module-scope fixtures), `initialization_test_support.py` (three), `test_path_resolution.py` (two), `test_source_reads.py` (two): module-scope fixtures run once per worker and can be rebuilt several times in total under `-n`, and any test that mutates the fixture object leaks to later tests in that module. Cost, not correctness, unless a test mutates. (likely)
6. `tests/discovery_runtime/test_activation_filesystem.py` (14 drive-letter or absolute-path literals) and `test_repository_reader.py`, `test_gateway_boundaries.py`: absolute-path fixtures; correctness depends on in-memory seams, not on shared files. (likely)
7. `tests/scripts/dev_tools/test_new_active_feature_folder*.py`, `test_new_potential_bug_entry.py`, `test_push_down_claude_customizations.py`: heavy filesystem seam use (12, 14 and 25 `mem_fs_path` uses). If any test bypasses the fixture it would write the real tree. (unverified)
8. `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: the only file with `subprocess.run/Popen` patterns. (unverified)
9. `tests/scripts/dev_tools/test_collect_commit_context.py`, `test_json_config.py`, `test_validate_json.py`: reference `tasks.json` or `artifacts/commit_context.txt` through in-memory directories; confirm they never read the real `.vscode/tasks.json`. (unverified)

Plain reading of the evidence: the suite appears broadly xdist-safe by construction (no `os.environ` writes, no real temp files, no session fixtures). The realistic risk is the reload and `sys.modules` leakers above, not file collisions. (likely; the proof is a run)

### Q2. Coverage under xdist

Configuration read: `[tool.coverage.run]` has `source = ["src", "scripts/dev_tools", "packages/discovery-runtime/src"]`, `data_file = "artifacts/.coverage"`, an `omit` list, and no `parallel`, `concurrency` or `patch` key. `[tool.pytest.ini_options]` has `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, `minversion = "7.0"`, `testpaths = ["tests"]`. (pyproject.toml; verified)

CI step (`_quality-checks.yml`, step `Run tests with Pytest`): `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`. Next step `Enforce Python coverage thresholds` runs `python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`; the checker reads `totals.percent_statements_covered` and `totals.percent_branches_covered` only. Codecov uploads `./coverage.xml` on 3.13. (.github/workflows/_quality-checks.yml; scripts/dev_tools/check_python_coverage_thresholds.py; verified)

Locked versions: pytest 9.0.2, pytest-cov 7.0.0, coverage 7.13.2; `pytest-xdist`, `execnet` and `psutil` are not in `poetry.lock` (a name-anchored grep matched only `coverage` among those). (poetry.lock; verified)

Behavior of pytest-cov under xdist (sources: https://pytest-cov.readthedocs.io/en/latest/xdist.html; https://raw.githubusercontent.com/pytest-dev/pytest-cov/master/src/pytest_cov/engine.py; https://pytest-cov.readthedocs.io/en/latest/changelog.html; verified):

- Docs: "Distributed testing with dist mode set to load will report on the combined coverage of all workers." The example is `pytest --cov=myproj -n 2 tests/`.
- Engine: the xdist controller class `DistMaster` receives each worker's data in `testnodedown` and loads it with a unique suffix, then `finish()` combines through a `combining_cov` object and saves. A collocated `DistWorker` only saves, because the source comment says combining there can race ("it's not atomic"). Reports (XML, JSON, term-missing, lcov) are produced once, in the controller process, from the combined data.
- No config key needs to change: `parallel`, `concurrency` and `data_file` are not required; the engine sets its own `data_suffix`. `source` is honored as today; the controller sets `paths['source']` to the top directory. The only hard failure is `dynamic_context = test_function`, which `DistMaster` rejects and which is not set here.
- pytest-cov 7.0.0 dropped subprocess measurement (the `.pth` mechanism); coverage now needs `patch = subprocess` under `[run]`, which implies `parallel = True`. Nothing in this repo needs that unless a test spawns a Python subprocess that must be measured; the grep found no such test. (changelog; likely)
- Terminal and JSON totals may differ slightly from a serial run only if tests behave differently by order; they should be equal otherwise. Comparison needs a run (orchestrator to confirm).

Worker count (source: https://pytest-xdist.readthedocs.io/en/stable/distribution.html; verified): "`-n auto` ... as many processes as your computer has physical CPU cores"; `-n logical` uses logical cores but needs `psutil` and falls back to auto otherwise; `PYTEST_XDIST_AUTO_NUM_WORKERS` sets the count, and the `pytest_xdist_auto_num_workers` hook wins over it. Consequence (likely): a 4 vCPU hosted runner is commonly 2 physical cores, so `-n auto` may start only 2 workers, which matches the downstream result of no gain on 2 vCPU. The page does not mention cgroups or affinity (unverified). Known limitations page (https://pytest-xdist.readthedocs.io/en/stable/known-limitations.html): collection order and count must be identical in every worker (parametrize values from sets must be sorted), `-s` output and `--pdb` are unsupported. Distribution modes: `load` (default), `loadscope`, `loadfile`, `worksteal`.

### Q3. Tests that pin the pytest command, workflow, pyproject options, tasks.json or the brief

| Test | What it pins | Effect of adding `-n auto` to the CI step |
|---|---|---|
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | Step named `Run tests with Pytest` is unique; shell-split tokens include `--cov-branch`, include no token starting `--cov=`, include `--cov-report=json:artifacts/python/coverage.json`; threshold step passes `--min-line 85` and `--min-branch 75`, carries `if` equal to `${{ inputs.run-heavy }}`; Codecov uses `files`. | Passes: extra tokens `-n` and `auto` break none of the assertions. A step rename would break it. |
| `tests/scripts/dev_tools/test_plan_gate_parity.py`, `test_plan_gate_observability.py`, `test_plan_gate_observability_boundaries.py`, `test_validate_orchestration_artifacts_plan_gates.py` | Plan-gate G9 logic reads `addopts` from a stubbed `pyproject.toml` text (`addopts = "-ra --cov-report=lcov:..."`), through `scripts/dev_tools/plan_gate_observability.py` regexes. | Unaffected while `addopts` is unchanged. Adding `-n` to `addopts` would also contradict the issue constraint. |
| `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | argv of `poetry run pytest tests/test_module.py` and `--cov-report=xml/term-missing` in `scripts.dev_tools.atomic_executor.qc_runner`. | Unaffected: the executor QC runner is separate from the CI step. Adding xdist there is out of scope. |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | Six byte-identical brief copies; required headings in order; `## Test Runtime` must contain `--junitxml`, `cProfile`, `pstats`, `built once per owning instance`, `its own copy`, `wall-clock time only`, `-p <module>`, `PYTHONPATH`. | Not about the command, but any edit to `## Test Runtime` must keep every token. |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` (`test_execution_environment_fact_is_unchanged_across_copies`) | Byte identity of every `execution-environment/SKILL.md` found by `rglob`. | Same. |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | Lists the Copilot brief path in a mirrored set; asserts `Mirror parity` wording. | Same. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, pack-manifest completeness and dependency-closure tests | Bundle copies equal and manifested (per brief `## Contract Tests That Pin Mirrored Files`). | A brief edit must reach the bundled copies. |
| `tests/scripts/dev_tools/test_json_config.py`, `test_validate_json.py` | Mention `.vscode/tasks.json` in an in-memory `vscode_dir`. | Probably do not read the real file. The governed-JSON gate `python -m scripts.dev_tools.validate_json` validates `tasks.json` against `schemas/tasks.schema.json`, so new tasks must satisfy it (orchestrator to confirm). |
| `tests/test_pytest_collection.py` | conftest bootstrap and repo root on `sys.path`. | Safe under `-n` (workers load conftest). Breaks under `--import-mode=importlib` (likely). |

No test pins `.vscode/tasks.json` task labels, and no test reads `[tool.pytest.ini_options]` from the real `pyproject.toml` (tests that mention `pyproject.toml` are alignment tests for ruff and pyright, plus stubs). (Grep over `tests`; verified for the files searched)

### Q4. Order-independence guard, plugins and hooks

- No seeded-shuffle step, no `pytest-randomly` or `pytest-random-order` in `poetry.lock` or `pyproject.toml`, and no `shuffle`, `randomize`, `--seed` or `reverse` match in `.github/workflows`. The only guard is the manual rule in the brief `## Test Isolation Checks` (reversed-order run of changed Python modules; seeded shuffled Pester runs; seeded Jest). (Grep; verified)
- No `pytest_plugins`, `pytest_collection*`, `pytest_configure`, `pytest_sessionstart/finish`, `pytest_runtest_*`, `pytest_addoption`, `pytest11` entry point, or `vscode_pytest` reference in `tests`, `scripts`, `packages`, `pyproject.toml` or `.vscode`. The only hooks are fixtures in the two conftest files. `vscode_pytest` is injected by the VS Code extension at run time (the issue's own account); not in this repo. (Grep; verified)
- Therefore xdist interacts only through (a) identical collection in every worker, which the repo's parametrize inputs support as far as grep shows, and (b) module-scope fixtures running once per worker.

### Q5. Windows portability hazards (downstream repo's four patterns)

- POSIX-style absolute fixture paths (`/home`, `/tmp`, `/workspace`, `/repo`, `/mnt`, `/usr`, `/opt`, `/var`): about 650 occurrences in 139 files under `tests`, concentrated in `tests/scripts/dev_tools` and `tests/discovery_runtime`. They work today because they are strings fed to in-memory seams and CI runs on Linux; on Windows, `Path("/workspace/x").is_absolute()` is false, so any test that applies `pathlib` absoluteness to such a path would differ. Real failures were not identified; the local Windows suite passing is the evidence needed (orchestrator to confirm).
- Drive-letter literals (`"C:/workspace"` style): 197 occurrences in 67 files, with a normalizing `_key` helper in `test_epic_planner_readiness.py`. These are the inverse hazard (pass on Windows, fail on Linux) and CI is Linux, so the existing CI already exercises it. (verified count)
- Fakes keyed on `str(path)` rather than `Path.as_posix()`: a single-line grep for common shapes returned no clean list (one regex failed on look-around). Existing helpers normalize (`_key` replaces backslashes in `test_epic_planner_readiness.py`; `mem_fs_path._key` uses `as_posix()`). Unverified for the rest.
- `strftime('%y')` with Hypothesis dates before 1900: no `strftime` or Hypothesis use in `tests` (grep for `strftime`, `dates(`, `datetimes(`, `from hypothesis`: 0 relevant matches). Not applicable.
- Temp files and wall-clock waits: none real (see Q1).

### Q6. `## Test Runtime`, verbatim, and proposed edits

Verbatim current text (identical in the six copies; from `.claude/skills/execution-environment/SKILL.md`):

```
## Test Runtime

- A unit test runs in milliseconds. A full suite above about 15 minutes, or a single unit test above about 10 seconds, indicates repeated work in the code under test or its fixtures, not missing parallelism.
- Diagnose before proposing sharding or parallel workers. First aggregate per-test and per-module time from the JUnit report that the full run already writes (`--junitxml`); a small fraction of tests usually holds most of the time. Then run the slowest test under a profiler (`python -m cProfile -o <file> -m pytest <node id>`) and read the profile with `pstats`.
- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.
- Second, build an expensive immutable fixture once per session and hand each test its own copy wherever a test could mutate it, so test independence is unchanged.
- Parallel shards reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.
- A candidate fix can be measured before the tree is edited by loading a pytest plugin module from `SCRATCH` with `-p <module>` and `PYTHONPATH`.
```

Proposed edits (keep every existing sentence and every token pinned by `test_brief_test_runtime_section_orders_diagnosis_before_parallelism`):

1. Replace the bullet `Parallel shards reduce wall-clock time only: ...` with: `Parallel workers reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.` (The pinned token is `wall-clock time only`.) Then add the bullets below directly after it.
2. Add (pytest): `After the diagnosis, run Python tests in parallel with pytest-xdist by passing `-n auto` on the command line of the CI step and of the parallel VS Code tasks; never put `-n` in `addopts`, because the VS Code Test Explorer result hook then keys results to the wrong file. `-n auto` counts physical cores, so a hosted runner can start fewer workers than it has vCPUs; measure `-n auto` against an explicit count before keeping it. Each worker is a separate process with its own session and module fixtures, and pytest-cov combines worker coverage into one report with no coverage configuration change. The serial command stays available and remains the reference for isolation checks.`
3. Add (Pester): `Pester 5.x, the supported range, has no in-process parallel mode; Pester 6 `Run.Parallel` is experimental and outside the supported range. Parallelism for Pester is separate processes, each running a shard of test files: `Invoke-PoshQCTest -ShardIndex -ShardCount` on separate CI runners, or the local concurrent runner on one machine. A shard is capped by its slowest test file, so read per-file `time` from the JUnit `testsuite` elements before changing shard counts or weights.`
4. Add to `## Test Isolation Checks` (separate section, so also copied to six places): a bullet requiring a concurrent-shard Pester run and a `-n auto` pytest run in addition to the serial runs. Keep the existing tokens (`node run-jest.cjs --randomize --seed=<n>`, `with the seed recorded`, `reversed-order run of the new or changed Python test modules`, `seeded shuffled file-order run of the touched Pester suites`, `at least three seeds`, `each seed and its file order recorded`).
5. If the shard count or job set changes, update `## CI Shape and Required Checks` in the same change (it names `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` and the three-shard matrix). All six copies change byte-for-byte; the bundled copies under `extensions/drm-copilot/resources/` are `claude-customizations`, `codex-and-agents-customizations` and `customizations` (names from `test_execution_environment_brief_contracts.py`).

(Sources: brief file; test file above; verified.)

## Part 2: Pester

### Q7. How `Invoke-PoshQCTest` works

Source: `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `PoshQC.Shard.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `settings/pester.runsettings.psd1`, `config/poshqc-scan.json`, `config/poshqc-coverage.json`, `README.md` (all verified).

- Module wiring: `PoshQC.psm1` parses and dot-sources seven sub-modules in a fixed list (`FileDiscovery`, `ScanConfig`, `Coverage`, `Analyzer`, `Shard`, `CoverageMerge`, `Testing`), caching parsed script blocks in an AppDomain data slot. `PoshQC.psd1` lists `FunctionsToExport` explicitly (14 names including `Invoke-PoshQCTest`, `Get-PoshQCShardSlice`, `Merge-PoshQCCoverageReport`). A new module file needs entries in both, in `test_poshqc_bundled_parity.py` `POSHQC_PARITY_PATHS`, and a bundled copy under `extensions/drm-copilot/resources/powershell/PoshQC/`.
- Pester range: `Install-PoshQCTool` requires Pester `5.9.0` with `UpperBound = '6.0.0'`; `Invoke-PoshQCTest` imports with `-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`; the workflow does the same; `PoshQC.RunSettings.Tests.ps1` (RS03, RS05, RS06, RS07, RS08) pins this.
- Settings: `Run.Path = scripts, tests/powershell, tests/scripts`; `Run.Exit = $true`; `Output.Verbosity = Detailed` (the function overrides to `Normal`); `TestResult` = JUnitXml at `artifacts/pester/pester-junit.xml`; `CodeCoverage` = CoverageGutters at `artifacts/pester/powershell-coverage.xml`, `UseBreakpoints = $false`, `CoveragePercentTarget = 0`, no `Path` list.
- Scan folders: `config/poshqc-scan.json` -> `test.scanFolders = ["scripts", "tests/powershell", "tests/scripts"]`, which replaces `Run.Path` when present.
- Test discovery: the `EnumerateTests` seam runs `Get-ChildItem -Path <run path> -Recurse -Include *.Tests.ps1`, drops any path with a segment in `DefaultExcludedDirs` (`.git`, `.venv`, `node_modules`, `artifacts`, ...), sorts by `FullName`, and returns file objects. If none is found it logs and returns.
- Shard assignment: when `-ShardCount` is above 0, `Select-PoshQCShardTestFile` calls `Get-PoshQCShardTestFileWeight` and `New-PoshQCShardManifest`, which calls `Get-PoshQCShardSlice` and then sets `Run.Path` to the shard's full file paths. The Weight is the UTF-8 byte count of the file text with CRLF counted as LF (so a CRLF checkout matches an LF checkout). `Get-PoshQCShardSlice` is longest-processing-time greedy: heaviest first, ties by ordinal path, each file to the shard with least load, then fewest files, then lowest index. It accepts `[long[]] -Weight` (non-negative, parallel to `-TestFile`), so a measured weight can already be passed to it; `Select-PoshQCShardTestFile` has no parameter for it and `Get-PoshQCShardTestFileWeight` has only the `ReadTestFileText` seam, so feeding durations needs a change in `Get-PoshQCShardTestFileWeight` or a new parameter on `Select-PoshQCShardTestFile` and `Invoke-PoshQCTest`.
- Outputs: JUnit and coverage at the fixed settings paths (made absolute against `-Root`); a Koverage relative-path copy `powershell-coverage.koverage.xml` unless `-DisableKoverageCopy`; the manifest JSON (`shardIndex`, `shardCount`, `all`, `selected`) at `-ShardFileListPath`. `Invoke-PoshQCTest` has no parameter to redirect the JUnit or coverage output path; the only route is a different settings file through `-SettingsPath`, or the `BuildConfiguration`/`EnsureResultPath` seams.
- Coverage population: `Resolve-PoshQCCoveragePopulation` derives files from `config/poshqc-coverage.json` roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`), excluding `*.Tests.ps1`, `tests/` and excluded directories. Every shard instruments the same population, which is why `Merge-PoshQCCoverageReport` can require identical line sets.
- Overwrite hazard: any `-ShardCount` run, and any serial run, writes the same fixed `artifacts/pester/pester-junit.xml` and `powershell-coverage.xml`. A partial (shard) run in a worktree therefore replaces a previous full run's outputs. In CI each shard has its own runner, so there is no collision; the aggregator writes the merged coverage into `artifacts/pester/` on a separate runner.
- Exit semantics: `Run.Exit = $true` makes Pester exit non-zero when the run fails (https://pester.dev/docs/v5/usage/configuration: "Exit with non-zero exit code when the test run fails"; "Exit code is always set to `$LASTEXITCODE`"). Whether Pester also exits on success and whether code after `Invoke-Pester` (Koverage copy, summary) runs after a failed run is not documented there; `Invoke-PoshQCTest` code after the Pester call likely does not run on failure (unverified).
- Merge helpers that exist: `Merge-PoshQCCoverageReport` (LINE and INSTRUCTION only: `ci = max(ci)`, class/method elements and other counters removed), `Get-PoshQCCoverageLineSummary`, `Test-PoshQCShardCompleteness`, `Test-PoshQCShardTestCount`, `Convert-PoshQCCoverageToRelative`. There is no JUnit merge function.

### Q8. `_poshqc.yml`

Source: `.github/workflows/_poshqc.yml`; `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (verified).

- Jobs: `poshqc-static` (format, analyze; `windows-latest`); `poshqc-shard` matrix `shard: [1, 2, 3]`, `fail-fast: false`, runs `Invoke-PoshQCTest -Root ... -ShardIndex ${{ matrix.shard }} -ShardCount ${{ strategy.job-total }} -ShardFileListPath artifacts/pester/shard-files.json -DisableKoverageCopy`, uploads `pester-junit.xml`, `powershell-coverage.xml`, `shard-files.json` as `poshqc-test-results-shard-N` (`if: always()`); `poshqc` (aggregator; `needs: [poshqc-static, poshqc-shard]`, `if: always()`); `poshqc-linux-hooks` (`ubuntu-latest`).
- Aggregator needs from each shard: `shard-files.json` (indices exactly 1..N, identical `all`, pairwise-disjoint `selected`, union equals `all`; `Test-PoshQCShardCompleteness`), `pester-junit.xml` (`testsuites/@tests` summed and compared with a SkipRun discovery over `all` through `Test-PoshQCShardTestCount`), and `powershell-coverage.xml` (merged with `Merge-PoshQCCoverageReport`, then converted to relative with `Convert-PoshQCCoverageToRelative`, then re-uploaded). The shard count is read from shard 1's manifest, never a literal (test WF05 pins `1..$shardCount` appearing twice).
- Can the count or assignment change without breaking completeness? Assignment: yes. The check depends only on manifests, so weights, ordering and algorithm may change as long as every shard job computes the same assignment from the same inputs (a weights file committed to the repo satisfies that; a CI-time measurement would not). Count: yes for the logic, but `PoshQcWorkflow.Tests.ps1` pins `shard: [1, 2, 3]` ("three-shard matrix", WF-titled `It`) and the brief names shards 1 to 3, so a count change edits that test and the brief.
- Linux hook-suite job duplicates work: `config/poshqc-scan.json` includes `tests/scripts`, so Windows shards already run all of `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`; the Linux job re-runs only those two folders on Linux with coverage off (`Run.Path` pinned by the workflow test). The duplication is deliberate: the brief's `## CI-Only Failure Classes` lists the case-sensitive Linux file-system failures this job catches. It is not on the critical path: the aggregator `needs` only the static and shard jobs, and the Linux job (316 s as reported) is shorter than the longest shard (462 s). The brief's required-context list does not include `poshqc / PowerShell hook suites (Linux)`, so the job is not itself a required check (verified in the brief; ruleset not re-read). Narrowing it saves runner minutes, not wall-clock time. Recommendation: keep it.
- Critical-path arithmetic from the owner's figures (shard 462, 290, 364 s; static 224 s): the sum is 1116 s; perfect balance on 3 shards is 372 s (saves 90 s on the longest shard) and on 4 shards 279 s (saves 183 s). These include per-shard setup (module install, checkout), so real gains are smaller. (arithmetic; likely)

### Q9. Local invocation and why it is slow

- `.vscode/tasks.json`: task `PoshQC: 4 test (Pester)` runs `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module '<ws>/scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '<ws>' }"`. Also used by `QC: Coverage: All Providers` and `QC: 5 Run All Checks` (both `dependsOrder: sequence`). The Python tasks are `QC: 4 Pytest: run tests` (`poetry run pytest`, default test task) and `QC: 4 Pytest: run tests with coverage` (`--cov=src/lexile_corpus_tuner --cov=scripts/dev_tools ...`); note the coverage task names `src/lexile_corpus_tuner`, which the repo may not contain (unverified; the workflow contract test forbids that token in the workflow only). The `QC: 5 Run All Checks` task depends on labels (`QC: Black: format`, `QC: Ruff: lint`, ...) that do not match the actual labels (`QC: 1 Black: format`, ...), a pre-existing inconsistency outside scope. (tasks.json; verified)
- Why slow: one process, one `Invoke-Pester` over all scan folders, coverage on with the profiler tracer over the six coverage roots, Windows process spawning in about 22 suites that start `pwsh` (grep: `Start-Process`, `& pwsh`, `Invoke-Pester` in 22 files).
- Measured local run (serial, from the gitignored local JUnit): 12203 tests in 711.9 s over 436 files. Eleven files at 10 s or more (all under `tests/scripts`) total about 456 s, 64% of the run: `claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` 133.6 s, `claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` 58.4 s, `claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` 56.9 s, `claude-runtime/hook-dependency-guard-completeness.Tests.ps1` 50.3 s, `codex-hooks/codex-pretooluse-integration.Tests.ps1` 38.0 s, `claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` 37.3 s, `codex-hooks/codex-pretooluse-transport.Tests.ps1` 30.2 s, `codex-hooks/codex-bundle-hook-probe.Tests.ps1` 17.6 s, `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` 13.6 s, `claude-hooks/hook-dependency-failure.Claude.Tests.ps1` 10.3 s, `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` 10.1 s. (artifacts/pester/pester-junit.xml, `testsuite` `time` attributes; verified for this local artifact; CI timings differ)
- Implications: (a) the largest file alone is 133.6 s locally, a floor for any shard; (b) byte-size weights cannot predict these durations (they are subprocess-bound), which explains the 290 to 462 s spread (likely); (c) the brief's own rule says a file this slow should be profiled before parallelizing, and the heavy files that scan the repo or spawn processes may be fixable (orchestrator to confirm with a profile or a re-timed run).
- Tests of PoshQC itself: 18 files under `tests/scripts/powershell/PoshQC/` (for example `PoshQC.TestingShard.Tests.ps1` TS01 to TS06, `PoshQC.Shard.Tests.ps1`, `PoshQC.CoverageMerge.Tests.ps1`, `PoshQC.RunSettings.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`), plus `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. They mock `New-Item`, `Set-Content` and `Invoke-Pester`, so they touch no shared files (verified for `PoshQC.Comprehensive.Tests.ps1`).

### Q10. Pester parallelism, primary sources

- Pinned version: Pester 5.9.0 or later and below 6.0 (`PoshQC.psm1` `Install-PoshQCTool` requirement; `Invoke-PoshQCTest` `EnsureModule`; `_poshqc.yml` Linux step; README Requirements). (verified)
- Pester 5 configuration page (https://pester.dev/docs/v5/usage/configuration) lists `Run.Path`, `ExcludePath`, `ScriptBlock`, `Container`, `TestExtension`, `Exit`, `Throw`, `PassThru`, `SkipRun`, `SkipRemainingOnFailure`; no `Run.Parallel`. `CodeCoverage.OutputFormat` accepts `JaCoCo`, `CoverageGutters`, `Cobertura`. (verified)
- Pester 6 documentation (https://pester.dev/docs/usage/parallel; https://pester.dev/docs/usage/configuration): `Run.Parallel` (experimental, "may change"), `Run.ParallelThrottleLimit` (default 0 = all processors), each test file in its own runspace, coverage merged by the parent, files marked `#pester:no-parallel` run in the parent, workers start clean so shared setup needs `Pester.BeforeContainer.ps1`, mocks in parallel not addressed. The Pester 6 configuration page does not list `CoverageGutters` as an output format (the repo uses it). Pester GitHub issue search (https://github.com/pester/Pester/issues?q=is%3Aissue+parallel): open items include #3047 (concurrent `Import-Module` failures with a shared `InitialSessionState`), #3044, #2991, #2666; closed #3011 (a file's results dropped without failing the run). (verified as page content; issue statuses as shown on the search page)
- Conclusion: Pester 6 `Run.Parallel` is excluded by this repo's `< 6.0` ceiling (tests RS05, RS09) and is experimental with open correctness issues; do not adopt. Pester 5 has no supported in-process parallel mode. (verified)
- Standard pattern: split test files across processes (this repo already does so on CI through `Invoke-PoshQCTest -ShardIndex`), then merge JUnit by concatenating `testsuite` elements and summing the `testsuites` totals, and coverage by line-level `max(ci)` (`Merge-PoshQCCoverageReport`). A generic primary-source statement of this pattern was not found on pester.dev; it is the repo's own implemented design. (unverified as a documented pattern; verified as implemented)
- JUnit structure used for merge and weights, from the local artifact: root `<testsuites name="Pester" tests errors failures disabled time>` containing one `<testsuite name=<file path> tests errors failures hostname id skipped disabled package=<file path> time>` per test file, containing `<testcase name classname status assertions time>`. `name` and `package` hold an absolute path of the machine that ran, so a weights tool must normalize to a repo-relative forward-slash path. (artifacts/pester/pester-junit.xml; verified for that file)

### Q11. Design options for a local concurrent runner

Option A (recommended): process-per-shard launched by a new PoshQC command.
- Mechanism: new function (proposed `Invoke-PoshQCParallelTest`) in a new sub-module (proposed `PoshQC.Parallel.psm1`). It resolves N (default `[Environment]::ProcessorCount` bounded, overridable by parameter), starts N child `pwsh -NoLogo -NoProfile -Command` processes each running `Invoke-PoshQCTest -Root <root> -ShardIndex i -ShardCount N -ShardFileListPath <dir_i>/shard-files.json -DisableKoverageCopy` with per-shard output paths, redirects each child's output to a per-shard log, waits for all, then merges: manifests through `Test-PoshQCShardCompleteness`; coverage through `Merge-PoshQCCoverageReport`; JUnit through a new pure `Merge-PoshQCJunitReport` (concatenate `testsuite` elements, renumber `id`, sum `tests/errors/failures/disabled`, root `time` = the largest shard time or the sum, to be decided); writes `artifacts/pester/pester-junit.xml`, `powershell-coverage.xml` and the Koverage copy; exit code is non-zero when any child exits non-zero or any merge or completeness step fails. A failed shard still triggers the merge of what exists, but the final merged artifacts are written only when every shard produced outputs, so a partial result never replaces a full one.
- Files that change: `PoshQC.Testing.psm1` (new `-TestResultPath` and `-CoverageOutputPath` parameters applied after settings load; the file is about 480 lines), new `PoshQC.Parallel.psm1`, `PoshQC.psm1` (sub-module list), `PoshQC.psd1` (exports), the bundled copies of each under `extensions/drm-copilot/resources/powershell/PoshQC/`, `test_poshqc_bundled_parity.py` (`POSHQC_PARITY_PATHS`), new Pester tests under `tests/scripts/powershell/PoshQC/`, `.vscode/tasks.json` (new task), `scripts/powershell/PoshQC/README.md`, the brief. Four non-test PowerShell or data files in `scripts/` exceed the direct-mode batch cap of three (the cap counts `.ps1`, `.psm1` and `.psd1`; per `.claude/rules/powershell.md` and the brief `## Batch Budget`), so the orchestrated large route is required.
- Shared-state hazards: (1) fixed output files in `artifacts/pester/` (solved by per-shard directories and the new parameters); (2) module cache is an AppDomain slot, per process, safe; (3) environment variables are inherited, and any test that sets `$env:` affects only its child (208 `$env:X =` occurrences in 62 test files; for example `enforce-python-batch-budget.Tests.ps1` sets then nulls `CLAUDE_SESSION_ID`, which deletes rather than restores a real value that a Claude session may have set; likely a pre-existing leaker, see Q13); (4) file locks: coverage in profiler mode holds no file; test-created files under the repo are the risk (Q13); (5) ports: no listener usage found, not grepped exhaustively (unverified); (6) temp paths: five `GetTempPath`, `TestDrive` or `$env:TEMP` occurrences in two files (`codex-hooks/epic-child-launch-hardening.Tests.ps1`, `claude-hooks/check-powershell-test-purity.Tests.ps1`), name collisions unlikely if GUID-based (unverified); (7) CPU and memory contention with about 22 subprocess-spawning suites and N profiler-instrumented processes (unverified, needs a measured run).
- Merge method: JUnit as above; coverage by existing `Merge-PoshQCCoverageReport`; shard test count by comparing summed `testsuites@tests` with the sum of per-manifest `selected` file counts' suite count, or with a SkipRun discovery (slower, optional).
- Risk: moderate. New shared code is pure XML and process management behind injectable seams (consistent with `.claude/rules/powershell.md` seam rules and the no-temp-file test rule: tests use in-memory seams like `WriteShardFileList`).

Option B: `ForEach-Object -Parallel` runspaces driving `Invoke-Pester` in one process. Rejected: Pester 5 holds module-global state, `Invoke-PoshQCTest` hosts runs in the global session state through a trampoline (issue #392 comments), and coverage cannot be merged per runspace.

Option C: Pester 6 `Run.Parallel`. Rejected: outside the supported range and experimental (Q10).

Option D: a launcher script (not in the module) generating one settings file per shard. Rejected: needs temp or generated files, duplicates `Invoke-PoshQCTest` wiring, and leaves no tested seam.

Smallest option meeting the goal: A, with the output-path parameters on `Invoke-PoshQCTest` as the only edit to an existing production function.

### Q12. Shard balance

- Where durations live: each shard's `pester-junit.xml` (`testsuite@name` or `@package` = file, `@time` seconds). The aggregator already downloads them and copies them to `artifacts/pester/pester-junit-shard-N.xml`, uploaded as part of `poshqc-test-results`. (verified)
- Storage: a committed `config/poshqc-shard-weights.json` such as `{"version": 1, "unit": "ms", "files": {"<repo-relative forward-slash path>": <integer ms>}}`, regenerated from CI JUnit artifacts (not local ones; local timings differ). It must be committed (not fetched at run time) so that every shard job computes the same assignment; `config/` is outside `config/ci-docs-only-paths.json`'s allowlist (the allowlist covers docs folders only), so a weights change triggers a full CI run.
- Feeding `PoshQC.Shard.psm1`: add an optional weights lookup to `Get-PoshQCShardTestFileWeight` (read the file through a seam, map each `FileInfo` to its repo-relative path, use the stored millisecond value). For a file with no entry, use the median of known weights (mixing bytes and milliseconds would misorder files). `Get-PoshQCShardSlice` needs no change: it already takes `[long[]] -Weight`. The `-Weight` unit changes from bytes to ms, so `PoshQC.TestingShard.Tests.ps1` TS06 and `PoshQC.Shard.Tests.ps1` expectations, and the README line "weighted by the UTF-8 size in bytes", need updates, and the `-ShardCount 0` and no-weights paths must still work.
- Recommended method: LPT with committed measured weights plus a size-based fallback for unknown files, regenerated by a small PowerShell command from the merged CI JUnit files. The weights affect only wall-clock time; a stale or missing entry cannot fail correctness because `Test-PoshQCShardCompleteness` and the test-count check still guard coverage of every file.
- Rot risk: moderate. New files are absent until the next regeneration (median fallback limits harm); renamed files leave dead entries (ignore them); one-file durations vary by runner. Mitigation: a Pester test that fails when the weights file lists no file or has an unreadable shape, and regeneration documented in the README. Do not add a CI gate requiring fresh weights, since that would fail unrelated pull requests.
- Floor: the largest file bounds one shard; if `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` stays near 130 s locally, a 4th shard helps only until shard load approaches that floor. Reducing the heavy files first (Q9) is likely cheaper than adding shards.

### Q13. Cross-file state hazards in Pester suites (suspects)

Counts over `tests/**/*.Tests.ps1` (verified as counts):

| Pattern | Occurrences | Files |
|---|---|---|
| `$env:NAME = ...`, `SetEnvironmentVariable`, `Remove-Item Env:`, `$global:X =` | 208 | 62 |
| `Import-Module ... -Force` or `Remove-Module` | 293 | 141 |
| `Start-Process`, `& pwsh`, `Invoke-Pester`, `ProcessStartInfo` | 44 | 22 |
| `Set-Content`, `Out-File`, `New-Item`, `WriteAllText`, `Add-Content`, `Remove-Item` (many are `Mock`ed) | 165 in the first 25 files listed | at least 42 |
| `GetTempPath`, `GetTempFileName`, `New-TemporaryFile`, `$env:TEMP`, `$TestDrive` | 5 | 2 |
| `.claude/state` or `.codex/state` | 64 | 16 |
| Module-scope `$script:X =` / `$global:X` in `scripts/powershell/**/*.psm1` | 5 | 1 (`PoshQC.psm1`); `.claude/lib` modules not inventoried |

Most suspect files:
1. `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` (14 env assignments) and `enforce-powershell-batch-budget.Tests.ps1` (10): `AfterEach` sets `CLAUDE_TOOL_INPUT`, `CLAUDE_SESSION_ID`, `CLAUDE_PYTHON_BUDGET_*` to `$null`, which removes the variables instead of restoring original values. Leaker if the host session defines them. (likely)
2. `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` (12 env or global assignments): no `AfterEach` or `AfterAll` matched in the file; confirm cleanup form. (unverified)
3. `tests/scripts/dev-tools/run-actionlint.Tests.ps1`: sets `$env:PATH` repeatedly; `AfterEach` restores `$script:originalPath` (good pattern). (verified)
4. `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1`: defines `function global:Invoke-Pester` and removes `Function:\Invoke-PoshQCPesterRun` and `Function:\Invoke-Pester` in cleanup; a global `Invoke-Pester` stub that is not fully removed would change later suites in the same process. (likely)
5. `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`, `PoshQC.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1` (7 env assignments), and other `PoshQC.*` suites: `Import-Module -Force` / `Remove-Module` of the PoshQC module and its sub-modules, which interacts with the AppDomain cache and the run's own hosting module (comments in `PoshQC.psm1` cite issue #344 and #392). In a shard process the module under test is also the module that launched the run. (likely)
6. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `hook-import-failure-exemptions.Guard.Tests.ps1`, `test-name-uniqueness.Tests.ps1`, `claude-hooks/enforce-gate-suites.EpicStateIsolation.*.Tests.ps1`: scan or load every hook and suite across the tree; read-only, but they depend on other suites' files and are among the slowest (50 s, 57 s, 37 s, 134 s). (verified for timing; likely for dependence)
7. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, `epic-child-launch-hardening.Tests.ps1`, `codex-planning-only-hook.Tests.ps1`: spawn `pwsh` or use temp paths; subprocess contention and real hook state under `.codex/state`. (likely)
8. `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1` (29 `git` command occurrences) and `enforce-epic-worktree-removal-gate.Tests.ps1` (20): if any run a real `git` command in the repository, concurrent shards could contend for `.git` locks; most occurrences are probably command strings. (unverified)
9. `tests/scripts/claude-hooks/enforce-powershell-batch-budget*.Tests.ps1`, `enforce-python-batch-budget*.Tests.ps1`, `persist-session-id.Tests.ps1`, `codex-hooks/codex-batch-budget*.Tests.ps1`: reference `.claude/state` and `.codex/state`; visible samples use `/repo/.claude/state/...` literals passed to pure decision functions, not real files. (likely safe)
10. `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1` (8 `artifacts` references) and `claude-hooks/validate-*-output*.Tests.ps1` (many `artifacts` references): confirm they do not write real files under `artifacts/` (which collides with shard outputs). (unverified)
11. `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, `FileSizeBaseline.Tests.ps1`: read `config/file-size-baseline.json` and scan the repo; read-only. (likely)
12. `tests/scripts/claude-hooks/validate-feature-review-coverage*.Tests.ps1` (8, 13, 18 `artifacts` references) and `check-powershell-test-purity.Tests.ps1`: a purity checker for test content exists (`.claude/hooks/check-powershell-test-purity.ps1`), which may help detect temp-file use. (likely)

The AGENTS and brief isolation rule applies: fix the leaker and the victim, find them with seeded shuffled file-order runs and a concurrent-shard run, never by ordering. (brief `## Test Isolation Checks`; verified)

## Recommendation

Adopt for pytest:
1. Add `pytest-xdist = "^3"` to `[tool.poetry.group.dev.dependencies]` and let Poetry regenerate `poetry.lock`; the CI step `Verify poetry.lock is in sync` enforces this.
2. Add `-n auto` to the CI step `Run tests with Pytest` only; keep every existing token and the step name. No coverage config change is needed. Do not touch `addopts`.
3. Measure `-n auto` against `-n logical` (needs `psutil`, an extra dev dependency, owner decision) or an explicit worker count on the 4 vCPU runner before keeping `-n auto`, and record before and after job time. If the physical-core count gives 2 workers, expect little gain.
4. Add two tasks to `tasks.json` (`-n auto`; `-n auto` with the lcov report) and keep `QC: 4 Pytest: run tests`.
5. Fix the `importlib.reload` leak in `test_resolve_hard_lock_prompt.py` (restore the module state in the test, not through ordering) and verify the `sys.modules` helper; run serially, with `-n auto` several times, and under a seeded shuffle.
6. Strictness options: decide per option after the commands in "Orchestrator to confirm". Likely defer `--import-mode=importlib` (conflicts with `test_pytest_collection.py`, which requires `conftest` in `sys.modules`, and with `from tests.scripts...` absolute imports) and `filterwarnings = ["error"]` (one test already filters a `RuntimeWarning` from `runpy`); try `--strict-markers`, `--strict-config` and `xfail_strict` first.

Adopt for Pester:
1. Local concurrent runner: Option A (new `Invoke-PoshQCParallelTest` plus `Invoke-PoshQCTest` output-path parameters, JUnit merge function, task, tests). Orchestrated large route.
2. Profile the eleven slow files first (Q9) in the same item, because they hold 64% of the local run time and cap every shard.
3. Shard balance by committed measured weights with a size-based fallback; consider a 4th shard only after the profile and the balance are measured.
4. Keep the Linux hook-suite job as is.

Defer: Pester 6 `Run.Parallel`; merging or narrowing the Linux job; the pytest test-classification markers and sharding (out of scope per the issue); the `QC: 5 Run All Checks` label mismatch and the `src/lexile_corpus_tuner` coverage task path found in `tasks.json` (record as follow-ups unless trivial).

Rejected alternatives (brief): in-process `ForEach-Object -Parallel` for Pester; Pester 6 `Run.Parallel`; per-shard generated settings files; `-n` in `addopts`.

## Open owner questions

1. Is a new dev dependency `psutil` acceptable so CI can use `-n logical`, or should the step use `-n auto` or a fixed worker count?
2. Default local worker count for the Pester runner: logical core count (as the issue says), half of it, or capped (each worker runs coverage instrumentation and spawns `pwsh` in some suites)?
3. Should the merged local JUnit be one file `artifacts/pester/pester-junit.xml` with summed totals (the issue's "same artifacts"), and should its root `time` be the sum or the wall-clock?
4. Is `poshqc / PowerShell hook suites (Linux)` intentionally not a required check? The brief's required-context list omits it; a failure there may not block merge.
5. Is a fourth CI shard acceptable (changes the matrix, the brief and `PoshQcWorkflow.Tests.ps1`), or should only weights change?
6. Should the slow-file profile and any resulting product fixes be in this item or a follow-up (the brief says diagnose first)?
7. Is the 436 versus 482 test-file difference expected?

## Files expected to change (candidate list; the orchestrator confirms the route)

Production (PowerShell, data, workflow):
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (output-path parameters)
- `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` (new: launcher and JUnit merge)
- `scripts/powershell/PoshQC/PoshQC.Shard.psm1` (weights lookup)
- `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.psd1` (module wiring and exports)
- Bundled mirrors of each under `extensions/drm-copilot/resources/powershell/PoshQC/`
- `config/poshqc-shard-weights.json` (new data)
- `.github/workflows/_quality-checks.yml` (pytest step), `.github/workflows/_poshqc.yml` (only if shard count changes)
- `pyproject.toml`, `poetry.lock` (xdist dependency)
- `.vscode/tasks.json`

Tests:
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (add an assertion that `-n` is present in the pytest step and absent from `addopts`)
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (`POSHQC_PARITY_PATHS`)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (extend `## Test Runtime` tokens)
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (only if the matrix changes)
- `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`, `PoshQC.Shard.Tests.ps1`, new `PoshQC.Parallel.Tests.ps1`, a JUnit merge test
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` (leak fix) and any leaker or victim found by the isolation runs

Documentation:
- Brief `## Test Runtime` (and `## Test Isolation Checks`, and `## CI Shape and Required Checks` if the matrix changes) in all six copies
- `scripts/powershell/PoshQC/README.md`, and the extension README entry that cites the bundled PoshQC path if it describes commands

## Pre-Mortem

- Review checklists: the review could fail on a workflow change without a green branch-head run (`modified-workflow-needs-green-run`), on a `pwsh` step with a leaked `$LASTEXITCODE`, or on a missing brief update. Mitigation: the plan includes a branch-head `workflow_dispatch` or push run before merge, the pytest step stays a single `poetry run` command, and a brief-update task names all six copies.
- Coverage: PowerShell line coverage is 85% with no branch gate, and the new `PoshQC.Parallel.psm1` is in the coverage denominator through `config/poshqc-coverage.json` (`scripts` root). A launcher that is mostly process wiring could leave uncovered lines. Mitigation: put every process, file and clock interaction behind injectable seams and unit test the pure merge and exit logic; for Python, confirm `coverage.json` totals under `-n auto` equal the serial totals within rounding.
- Mirror parity: the new and changed PoshQC files need bundled copies (`test_poshqc_bundled_parity.py`) and the brief needs six identical copies. Mitigation: list every mirror in the plan, add the new path to `POSHQC_PARITY_PATHS`, and run the parity and brief contract tests.
- File size: `PoshQC.Testing.psm1` is about 480 lines and is near the 500-line guidance; test files for the new module could grow. Mitigation: put all new logic in the new sub-module and new test files, adding only parameters to `Invoke-PoshQCTest`.
- Test isolation: concurrent shards can expose Pester suites that leave state (env nulling, global function stubs, module re-imports) and the pytest `importlib.reload` leaker. Mitigation: run seeded shuffled file-order Pester runs with at least three seeds, a concurrent-shard run, `-n auto` pytest several times, and a reversed-order Python run; fix leaker and victim, never reorder; unit tests of the new code use in-memory seams and no temp files.
- CI-only behavior: Windows shards run `pwsh` suites on a case-insensitive file system while the Linux job is case-sensitive; `-n auto` on a 4 vCPU runner may start 2 workers; Python 3.10 to 3.13 matrix legs each run xdist; and a docs-only change scope skips these jobs, so a green docs-only run proves nothing (brief `## CI Shape and Required Checks`). Mitigation: measure on the branch head, record before and after times for `quality-checks7 / Code Quality & Tests (3.13)` and the Pester jobs, and rely on the newest run whose `CI full run` job succeeded.
- Evidence: this research ran no command; timing figures for CI are the owner's reported numbers, and the per-file durations come from a local gitignored JUnit file that may not match CI. Mitigation: the plan records every measured figure with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary` under `evidence/baseline/` and `evidence/regression-testing/`, and derives shard weights from CI JUnit artifacts only.

## Orchestrator to confirm

1. Timings: `poetry run pytest -q --durations=25 --junitxml=SCRATCH/issue-1048-pytest-serial.xml` (serial baseline and slowest tests); then `poetry run pytest -q -n auto ...` and `-n 4` on the same machine; record the worker count printed in the header.
2. Coverage equality: serial `poetry run pytest --cov --cov-branch --cov-report=json:SCRATCH/issue-1048-serial.json` versus `-n auto` with the same flags; compare `totals.percent_statements_covered` and `percent_branches_covered`.
3. Order independence: reversed order (`-p no:cacheprovider` plus a plugin or `--co` ordering run from `SCRATCH`), and a seeded shuffle through a plugin loaded with `-p` from `SCRATCH`; record seeds.
4. Strictness probes, one at a time: `poetry run pytest -q --strict-markers`, `--strict-config`, `-o xfail_strict=true`, `-W error`, `--import-mode=importlib`; record the failures.
5. Whether a worker test writes real files: run `git status --porcelain` after an `-n auto` run.
6. Local test-file count: `@(Get-ChildItem -Path tests -Recurse -Include *.Tests.ps1 -File).Count` through PowerShell 7 launched from an `sh` script, versus the 436 suites in the local JUnit.
7. Per-file Pester durations in CI: download the artifacts of the newest full green run (`gh run download <run id> -n poshqc-test-results`), read `pester-junit-shard-N.xml` `testsuite@time`, and compare with the local figures in Q9.
8. Profile the 133.6 s `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` run and the next five slowest files before sharding.
9. Pester exit behavior: run `Invoke-PoshQCTest` on a deliberately failing suite and read `$LASTEXITCODE` and whether the summary and Koverage copy code runs.
10. Concurrency probe after Option A: run two shards concurrently against distinct output paths and compare merged JUnit counts with a serial run; run seeded shuffles on the heavy files.
11. The CI before and after job durations: `gh run view <run id> --json jobs` for `quality-checks7 / Code Quality & Tests (3.13)` and the five `poshqc` jobs.
12. Required contexts: `gh api repos/drmoisan/drm-copilot/rulesets/15241672` to confirm `poshqc / PowerShell hook suites (Linux)` is not required.
13. Governed JSON: `poetry run python -m scripts.dev_tools.validate_json` after the `tasks.json` edit, and whether `tasks.json` labels `QC: 5 Run All Checks` dependencies resolve.
14. Mirror contracts after the brief edit: `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` plus the push-down resource and manifest tests named in the brief.
