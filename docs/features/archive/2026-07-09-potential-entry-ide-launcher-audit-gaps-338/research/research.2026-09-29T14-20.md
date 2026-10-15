# Research: potential-entry IDE launcher audit gaps (Issue #338)

- Timestamp: 2026-09-29T14-20
- Work mode: minor-audit
- Requirements source: `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`
- Background: `docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/code-review.2026-04-04T12-40.md`
- Method: Read and Grep only. No command that modifies files was run, and no pytest or jest run was executed for this artifact.

## 1. Stray literal: current locations

Verified with two independent repo-wide searches (excluding `node_modules`, `.git`, `coverage`).

| Location | Status |
|---|---|
| `scripts/dev_tools/new_potential_bug_entry.py:243` (inside `_resolve_code_cli` docstring, directly under summary line at 242) | Needs edit |
| `scripts/dev_tools/new_active_feature_folder_io.py:270` (inside `_resolve_code_cli` docstring, directly under summary line at 269) | Needs edit |

Files that do not contain the literal (verified):

- `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts` (`resolveCodeCli` JSDoc at 209-219 is clean).
- `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts` (JSDoc at 110-120 is clean).
- `scripts/dev-tools/new-potential-entry.ps1` and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` (they contain `--reuse-window` invocations at lines 130/137 and 122/129 respectively, but no docstring literal).
- No Python files exist under `extensions/drm-copilot/resources/` (glob `extensions/drm-copilot/resources/**/*.py` returned none), so the former Python "bundled mirrors" no longer exist. The issue text ("root and bundled copies") is stale; only two copies remain.
- The only other repo matches are historical prose in `docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/policy-audit.2026-04-04T12-40.md:123` and `code-review.2026-04-04T12-40.md:24`. These are frozen review records and must not be edited.

Note: the 2026-04-04 review cited `new_active_feature_folder_io.py` lines 253-255; the current line is 270, so line numbers in the old review are stale.

### Numeric Derivation Evidence

- Complete Family: every non-`docs/`, non-`node_modules` file in the repo containing the stray docstring literal `[code_cmd, "--reuse-window", *[file_path.as_posix() for file_path in files]],` outside a code statement.
- Exhaustive Search Scope: whole repo tree of the worktree, all file types, excluding `node_modules`, `.git`, `coverage`, `docs`.
- Inclusion Rules: any line containing the literal fragment.
- Exclusion Rules: `docs/**` (frozen historical records).
- Primary Search Strategy or Query Expression: Grep regex `\[code_cmd, "--reuse-window"`.
- Primary Member Set: `scripts/dev_tools/new_potential_bug_entry.py:243`; `scripts/dev_tools/new_active_feature_folder_io.py:270`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep regex `as_posix\(\) for file_path in files` (different token subset of the same fragment).
- Cross-check Member Set: `scripts/dev_tools/new_potential_bug_entry.py:243`; `scripts/dev_tools/new_active_feature_folder_io.py:270`.
- Cross-check Count: 2.
- Member-set Comparison: identical. The actual `subprocess.run` calls at `new_potential_bug_entry.py:305-312` and `new_active_feature_folder_io.py:312-319` use `str(file_path).replace("\\", "/")`, so neither search matches production code.

## 2. Launcher surface and test coverage

### Surface

| Language | Symbols (file:line) |
|---|---|
| Python (potential) | `_INSIDERS_SIGNAL_NAMES` `scripts/dev_tools/new_potential_bug_entry.py:19`; `_is_insiders_session` :205; `_resolve_code_cli` :238; `default_code_launcher` :280 (uses `default_env_lookup`) |
| Python (active folder) | `_INSIDERS_SIGNAL_NAMES` `scripts/dev_tools/new_active_feature_folder_io.py:27`; `_env_lookup` ~:211-229; `_is_insiders_session` :232; `_resolve_code_cli` :265; `default_code_launcher` :307 (one-line docstring; other module has full docstring) |
| TypeScript (potential) | `INSIDERS_SIGNAL_NAMES` `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts:56`; `defaultEnvLookup` :153; `isInsidersSession` :195; `resolveCodeCli` :220; `defaultWhichLookup` :248; `defaultCodeLauncher` :298 |
| TypeScript (active folder) | `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts`: `INSIDERS_SIGNAL_NAMES` :27; `defaultWhichLookup` :44; `defaultEnvLookup` :81; `isInsidersSession` :96; `resolveCodeCli` :121; `defaultCodeLauncher` :164 |
| PowerShell | `Invoke-VSCodeOpen` `scripts/dev-tools/new-potential-entry.ps1:102-142` (mirror `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`); helpers `Test-IsVSCodeInsidersSession` / `Resolve-VSCodeCliCommand` in `scripts/dev-tools/vscode-cli.helpers.ps1:1,27` (mirror under `resources/templates/`) |

Behavioral differences worth recording: PowerShell detects Insiders via `TERM_PROGRAM_VERSION`, `VSCODE_IPC_HOOK_CLI`, or a running `*insiders*` process (lines 114-116), and only falls back to `code` when `code-insiders` is missing; Python/TS check four env signals and fall back symmetrically to the other CLI.

### Existing tests

| Target | Tests |
|---|---|
| Py `new_potential_bug_entry` launcher | `tests/scripts/dev_tools/test_new_potential_bug_entry.py:73` (code, asserts argv `["/usr/bin/code","--reuse-window","file.md"]`), :95 (insiders via `TERM_PROGRAM_VERSION="1.110.0-insider"`, asserts probe order and argv), :125 (none available, asserts probe order `["code","code-insiders"]`) |
| Py active-folder launcher | `tests/scripts/dev_tools/test_new_active_feature_folder.py:461`, :486, :516 (same three shapes, patched on `io_mod`); additional `default_code_launcher` drivers in `test_new_active_feature_folder_part2.py:477` and `_part3.py:217,224`. `tests/conftest.py:97` allowlists names containing `default_code_launcher` from the subprocess guard |
| TS potential | `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts`: :38-77 (resolveCodeCli/isInsidersSession both orders), :80 (argv assertion), :107 (no CLI, probe order), :135 (`defaultWhichLookup` empty PATH); `defaultEnvLookup` in `new-potential-bug-entry.test.ts:166` |
| TS active folder | `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts:387-455` (isInsidersSession, resolveCodeCli both orders, launcher false, launcher argv with backslash-to-posix conversion) |
| PowerShell | `tests/scripts/dev-tools/new-potential-entry.Tests.ps1:238` (true), :246 (false), :253 (argv `--reuse-window` + files), :262 (Insiders prefers `code-insiders`), :431-449 (static body regex checks); helper tests from :291 |

### Existing tests already assert the launcher argv contract

Yes, for `--reuse-window`, file arguments, and Insiders-first CLI selection, in all three languages (Python :92/:122 and :483/:513; TS :100-104 and io.test.ts:449-453; PowerShell :257, :279). This is the deterministic proxy for AC-1/AC-2.

### Launcher branches no test drives (derived by reading; not measured)

1. Python (both modules): no test uses a backslash path, so the `.replace("\\", "/")` conversion is unverified in Python. Tests use `Path("file.md")`.
2. Python (both): `_resolve_code_cli` fallback with a successful second probe is not driven (Insiders session with `code-insiders` absent falling back to `code`; non-Insiders session with `code` absent falling back to `code-insiders`). The false-path test only proves both names are probed. Only `TERM_PROGRAM_VERSION` is used as a signal; `VSCODE_GIT_ASKPASS_MAIN`, `TERM_PROGRAM`, `VSCODE_IPC_HOOK_CLI` are never set true.
3. Python active-folder: `_env_lookup` (:228-229) has no direct test in the launcher tests found (the default lookup path is exercised only via `os.getenv` in undirected tests; confirm with coverage).
4. TS potential (`new-potential-bug-entry.ts`): backslash conversion at :315 is not driven (test passes `C:/ws/file.md`); no end-to-end `defaultCodeLauncher` Insiders test; `defaultWhichLookup` success return (:268-269) and the `win32` PATHEXT branch are not driven (only empty PATH); multi-file argv not asserted.
5. TS active folder (`io-launcher.ts`): no test imports `defaultWhichLookup` or `defaultEnvLookup` (grep of `extensions/drm-copilot/test` shows only `isInsidersSession`, `resolveCodeCli`, `defaultCodeLauncher` for this module), and the default-`deps` parameter (:166-170) is never exercised, so lines 44-70 and 81-84 are likely uncovered.
6. PowerShell: Insiders detection through `VSCODE_IPC_HOOK_CLI` or `Get-Process`, and the Insiders-session-but-`code-insiders`-missing fallback to `code`, are not driven behaviorally (only a static regex at :449).

## 3. Measuring isolated coverage

Configuration verified:

- `pyproject.toml:113-126`: `testpaths = ["tests"]`, `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`. Branch coverage is not enabled in `[tool.coverage.run]`, so pass `--cov-branch` for branch numbers.
- `extensions/drm-copilot/jest.config.cjs`: `coverageProvider: "v8"`, `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`, per-file `coverageThreshold` map with no `global` key and no entry for either launcher TS file (lines 25-324). `package.json` script `test:coverage` runs `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`. `run-jest.cjs` forwards args and rewrites `--testPathPattern` to `--testPathPatterns`; it rejects `--passWithNoTests`, `--onlyChanged`, `--lastCommit`.

Isolated coverage is measurable today. Commands (proposed, not run; they write `artifacts/.coverage` and lcov, which are gitignored build output, so evidence copies belong under `<FEATURE>/evidence/`):

Python (repo root):

```
poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py --cov=scripts.dev_tools.new_potential_bug_entry --cov-branch --cov-report=term-missing
poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part2.py tests/scripts/dev_tools/test_new_active_feature_folder_part3.py --cov=scripts.dev_tools.new_active_feature_folder_io --cov-branch --cov-report=term-missing
```

The dotted module form is required; filesystem-path forms measure nothing. Whole-file percentages will include non-launcher code, so the launcher-only figure is derived from the `Missing` line ranges intersected with lines 205-313 (potential) and 232-320 (active io).

TypeScript (from `extensions/drm-copilot`):

```
npm run test:unit -- --coverage --coverageReporters=text --coverageThreshold={} --collectCoverageFrom=src/lib/new-potential-bug-entry.ts --collectCoverageFrom=src/lib/new-active-feature-folder/io-launcher.ts test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-potential-bug-entry.test.ts test/lib/new-active-feature-folder/io.test.ts
```

`--coverageThreshold={}` is needed because the config's per-file threshold map names files that would not be collected under a narrowed `collectCoverageFrom`; this override is a candidate risk to verify on first run. `--collectCoverageFrom` on the CLI overrides the config value. The `text` reporter prints per-file line/branch/uncovered columns.

Policy threshold: the current `.claude/rules/general-unit-test.md` states line >= 85% and branch >= 75% uniformly for all tiers (branch exempt only for PowerShell and bash). A "90% new-code" threshold does not exist in the current `.claude` rules (grep of `.claude/rules` for `90%` found none). It survives only in the parallel Copilot surface `.github/instructions/general-unit-test.instructions.md:39-40` (repo-wide line >= 80%, new modules >= 90%). `.claude/rules` states `.github/` files are canonical for policy, but its own rule mirror (85/75) is what CLAUDE.md-runtime gates enforce; the two disagree. The 2026-04-04 review applied the 90% rule. Recommendation: target the 85/75 gate as the closure standard and report the observed figure against 90% informationally; record the discrepancy in the closure record rather than resolving it here (the `.github` files are not modifiable per CLAUDE.md).

## Automation Feasibility

Assessment of finding (C), live same-window-reuse in the VS Code desktop UI:

- The behavior being asked for is which OS-level VS Code window receives a file opened by `code --reuse-window <file>` launched from an integrated-terminal or extension-host process on a live Windows desktop, with either VS Code or VS Code Insiders. Observing it requires a running desktop VS Code session with a specific window focus, and a check of window count and which window holds the new editor tab. That state lives in the third-party desktop UI (Electron windows), not on a CLI, file, or API the agent can read.
- No existing repo tooling drives it (no UI-automation harness, no VS Code integration-test host wired for this; `@vscode/test-electron` was not found in this research and was not investigated further). A subagent has no interactive desktop, cannot install a second VS Code build, and cannot legitimately screenshot-verify window identity. The agent-worktree environment also runs Windows without an attended desktop session as far as this research can verify (unverified; stated as likely).
- The observable that the repo controls is fully deterministic: the argv passed to the CLI (`--reuse-window`, forward-slash file arguments) and CLI selection order (Insiders-first in an Insiders session, otherwise `code`-first, with symmetric fallback). Existing tests already assert these (section 2). What remains unproven by any repo test is VS Code's own behavior for `--reuse-window`, which is documented VS Code CLI behavior, not repo code.

Recommended response (exactly one): `scope_change`.

Rationale: replace live observation with (a) deterministic contract tests that close the untested argv/selection branches (backslash conversion, symmetric fallback, all four signals, multi-file argv, PowerShell IPC-hook and fallback), plus (b) a timestamped closure record under `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/other/` that states the residual risk (VS Code host behavior of `--reuse-window` not observed live; the two issue-#116 user-facing AC-1/AC-2 checkboxes remain a human observation) and cites the tests as the proxy. `exception` was rejected because it would leave the requirement unresolved until a human executes a runbook, blocking a minor-audit fix on a Low-severity issue (issue.md marks Impact Low); `halt` was rejected because it blocks DONE with no path to closure. If the repository owner wants the live observation preserved, an `exception` with a runbook via `human-exception-runbook` is the fallback, but it is not recommended.

## 4. Candidate approaches (summary)

- Recommended: minimal docstring fix in two Python files, add deterministic gap-closing tests (Python, TS, PowerShell), record isolated coverage evidence, and write a closure record with the `scope_change` for (C).
- Rejected alternatives: (1) live-observation `exception` with runbook (leaves gate unresolved; Low severity); (2) porting or de-duplicating the Python/TS launcher into a shared module (out of scope for minor-audit; violates minimal-fix rule); (3) adding jest per-file thresholds for the two TS launcher files (worth considering as an optional guard; not required for closure, and the config map has grown by per-issue additions, so adding two entries is consistent with repo convention but is a config change beyond the minimal fix).

## 5. Recommended acceptance criteria (minor-audit)

1. [ ] Neither `_resolve_code_cli` docstring contains the stray literal: `rg -n 'as_posix\(\) for file_path in files' scripts extensions` returns no matches, and `poetry run ruff check scripts/dev_tools/new_potential_bug_entry.py scripts/dev_tools/new_active_feature_folder_io.py` passes.
2. [ ] New Python tests pass and cover the undriven launcher branches (backslash-to-forward-slash argv conversion, symmetric fallback in both session types, each of the four signal variables): `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py`.
3. [ ] New TypeScript tests pass covering `io-launcher.ts` `defaultWhichLookup`/`defaultEnvLookup`, the `new-potential-bug-entry.ts` backslash conversion, and multi-file argv: `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts` from `extensions/drm-copilot`.
4. [ ] Isolated launcher-only coverage evidence is recorded for Python and TypeScript using the section 3 commands, with each launcher file at line >= 85% and branch >= 75% and observed values compared to the 90% informational target; artifacts stored under `<FEATURE>/evidence/qa-gates/` with `Timestamp`, `Command`, `EXIT_CODE`.
5. [ ] A PowerShell behavioral test for the Insiders-session-with-`code-insiders`-missing fallback passes: `Invoke-Pester tests/scripts/dev-tools/new-potential-entry.Tests.ps1`.
6. [ ] A closure record `<FEATURE>/evidence/other/ac1-ac2-scope-change-closure.<timestamp>.md` exists documenting the `scope_change` for finding (C), listing the argv-contract tests (by file and test name) as the proxy, and stating the residual unobserved risk.

## 6. Files the fix would write (repository-relative)

Production:

- `scripts/dev_tools/new_potential_bug_entry.py`
- `scripts/dev_tools/new_active_feature_folder_io.py`

Tests (add cases only):

- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py` (verify remaining size under 500 lines before editing; the file already exceeds 530 lines by the read above, so new cases likely belong in a new sibling such as `tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py`)
- `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts`
- `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts` (or a new `io-launcher.test.ts` in the same directory if size demands)
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` (only if AC 5 is retained; optional given PowerShell is exempt from branch coverage)

Feature-folder artifacts:

- `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/qa-gates/*.md`
- `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/other/ac1-ac2-scope-change-closure.<timestamp>.md`

Files that must not be edited: `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts`, `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts`, both `new-potential-entry.ps1` copies (no stray literal, no defect found), and all files under `docs/features/completed/`.

## Open items and unverified points

- Coverage percentages were not measured here; the uncovered-branch list in section 2 is by inspection and must be confirmed by the section 3 runs.
- `--coverageThreshold={}` override behavior under `run-jest.cjs` is unverified.
- A `plan.2026-09-29T14-12.md` template already exists in the feature folder (unfilled placeholders); it was not modified.
