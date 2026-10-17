# Research: codex-web-setup review follow-ups (issue #895)

- Issue: #895 (bug, work mode minor-audit). Requirements source: `docs/features/active/2026-10-11-codex-web-setup-review-follow-ups-895/issue.md` (AC-1..AC-8).
- Method: read-only investigation with Read, Grep and Glob. No shell, bats, kcov, shellcheck, shfmt or git command was run. Anything that needs CI output is marked "unverified".
- Tree: worktree on branch `bug/codex-web-setup-review-follow-ups-895` (from origin/main 2ef8d361e).

## 1. `.codex/codex-web-setup.sh` current state

File length is 413 lines, so there is room under the 500-line limit.

### Solution selection (CR-1, CR-3)

- `select_solution_file` is at `.codex/codex-web-setup.sh:20-24`. It prints nothing for empty input, else `printf '%s\n' "$1" | LC_ALL=C sort | sed -n '1p'`. The count of candidates is discarded and nothing is logged.
- `list_root_solution_files` is at `:28-30`. Its body is `find "$1" -maxdepth 1 -type f -name '*.sln' -printf '%f\n' 2>/dev/null`. The comment above it (`:26-27`) does not mention GNU `find`. `-printf` is a GNU extension. On a non-GNU `find` the call fails, `2>/dev/null` hides the error, the listing is empty, and `resolve_repo_root` silently falls back to `pwd`.
- Consumption:
  - `:34` `REPO_ROOT="$(resolve_repo_root "${SCRIPT_RELATIVE_ROOT}" "$(list_root_solution_files "${SCRIPT_RELATIVE_ROOT}")")"`
  - `:35` `SOLUTION_FILE="$(select_solution_file "$(list_root_solution_files "${REPO_ROOT}")")"`
  - `SOLUTION_FILE` is then used in `restore_packages_if_needed` (`:287-293`) and `verify_windows_visual_studio_task_capability` (`:313-314`).
- Logging helpers are `log` (`:37-39`, `printf '[codex-web-setup] %s\n' "$*"` to stdout), `fail` (`:41-44`, stderr, exit 1) and `warn` (`:46-48`, stderr).
- Ordering constraint: `log` is defined at `:37`, after the top-level selection at `:34-35`. A log call placed at `:35` would run before `log` exists, and would also print every time a bats suite sources the file. The suites source the script in `setup()` and C824-1 pins the source guard (`:413`).
- `main()` is at `:380-411`. Its first statement is `log "Bootstrapping a Codex Web environment for ${REPO_ROOT}"` (`:381`).

### CR-14 lines (207, 210, 302)

| Line | Text | Enclosing construct |
|---|---|---|
| 207 | `(` | opens a subshell in `install_dotnet_tools` (`:197-211`); body is `cd "${REPO_ROOT}"` (`:208`) and `dotnet tool restore --tool-manifest ...` (`:209`) |
| 210 | `)` | closes that subshell |
| 302 | `(` | opens a subshell in `verify_formatting_capability` (`:296-306`); body is `cd` (`:303`) and `dotnet tool run csharpier --version >/dev/null` (`:304`) |
| 305 | `) \|\| fail "CSharpier ..."` | closes that subshell; the line carries a command (`fail`) |

Likely cause (inferred from the code and the xtrace mechanism; not confirmed against a CI `cov.xml`):

- kcov's bash engine records coverage from xtrace lines (`PS4='kcov@${BASH_SOURCE}@${LINENO}@'`; see `scripts/bash/kcov_trace_env.sh:8`). bash emits a trace event only when it executes a simple command.
- Lines 207, 210 and 302 contain only a subshell delimiter and no command, so no trace event can ever carry those line numbers. kcov's source parser still counts them as executable.
- This fits the observed pattern: line 305 is reported covered, because its `fail` command runs in C824-50. Lines 208, 209, 303 and 304 are covered, because their commands run.
- The enclosing functions are already exercised:
  - `install_dotnet_tools` by C824-43 (`test_codex_web_setup_codex_dotnet.bats:152-162`).
  - `verify_formatting_capability` by C824-50 and C824-51 (`test_codex_web_setup_codex_verify.bats:64-86`).
  - A bats case can therefore not add coverage to these three lines. They have no command to execute.
- Options for AC-7:
  - (a) Record an attribution limit in the feature folder, citing the PR's CI kcov report (`shell-coverage` artifact, `artifacts/pester/kcov/cov.xml`, lines 207/210/302 with 0 hits while 208/209/303/304 have hits). This needs no code change.
  - (b) Restructure to remove the subshell, for example `dotnet tool restore --tool-manifest ...` without `cd`, or `pushd`/`popd`. Both change behaviour (working directory handling), and the rewrite brings new lines into the mirror-parity set. Not recommended for a minor-audit item.
- Recommendation: (a). The evidence must come from the PR's CI run, per the issue's operator constraint. Line numbers will shift after CR-1/CR-3 edits, so cite lines by content.

## 2. Mirrors and parity enforcement

- Mirror path: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
  - It is 413 lines, the same as the source. Lines 1-60 were compared by reading and are identical (including the `select_solution_file`, `list_root_solution_files`, `log`, `warn` blocks).
  - `git hash-object` equality was not run (no shell allowed). Byte identity is unverified. The implementer must apply the same edit to both files and the PR CI or a reviewer should confirm with `git hash-object`.
- Parity enforcement: no repository test compares the two files byte for byte. Findings:
  - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` lists both paths in `SOLUTION_SURFACES` (`:53-54`). It checks existence (`test_every_follow_up_copy_exists`, `EXPECTED_LISTED_COPY_COUNT = 36` at `:94`, `:181-197`) and that the text does not contain `TaskMaster.sln` (`test_surface_does_not_hard_code_solution_file`, `:214-225`; `test_pushed_roots_carry_no_hard_coded_solution_file`, `:228-238`). It does not compare bytes.
  - Pytest node IDs that touch the file:
    - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_every_follow_up_copy_exists`
    - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_surface_does_not_hard_code_solution_file[.codex/codex-web-setup.sh]`
    - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh]`
    - `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_roots_carry_no_hard_coded_solution_file`
  - Other byte-identity tests found (`test_push_down_codex_and_agents_virtual_paths.py:170-175`, `test_push_down_codex_and_agents_resource_contracts.py:211`, `test_push_down_claude_resource_contracts.py:113`) cover other files, not this script.
- Consequence for AC-8: the "existing push-down parity test" named in the issue's Verification Steps does not compare this script. AC-8 parity rests on identical edits and a hash comparison. The implementer should verify it with `git hash-object` in the execution phase.
- New text must not contain the literal `TaskMaster.sln`; the sample name `Alpha.sln` is safe. The 824 scan roots are `.agents`, `.codex`, `.github`, `.claude/*` and `extensions/drm-copilot/resources` (`:58-68`), and do not include `tests/`.
- `.github/codex/codex-web-setup.sh` exists as a separate script (Glob confirmed). It is tested by `test_codex_web_setup_source_safety.bats` (`SCRIPT_UNDER_TEST=".github/codex/codex-web-setup.sh"`, `:13`). It is not a mirror and is out of scope.
- `tests/shell` and fixtures have no bundled mirrors: Grep for `tests/shell` and `fixtures/codex_web_setup` under `extensions/` found nothing in the bundle contract tests. The only other bundle copies of the script are `.codex/codex-web-setup.plan.md` (a plan document, no code).

## 3. bats suites

Suites for `.codex/codex-web-setup.sh`: `test_codex_web_setup_codex_{copy,dotnet,installers,verify}.bats`. Other codex-web-setup suites (`apt_helpers`, `pypi_connectivity`, `source_safety`) target the `.github/codex` script.

### Duplicated helpers (CR-10)

All three suites (installers, dotnet, verify) define, in this order:

| Item | installers | dotnet | verify | Body |
|---|---|---|---|---|
| `SCRIPT_UNDER_TEST=` | :22 | :22 | :21 | identical |
| `FIXTURES=` | absent | :23 | :22 | identical where present |
| `setup()` | :24-27 | :25-28 | :24-27 | identical (`source "${SCRIPT_UNDER_TEST}"`) |
| `teardown()` | :29-31 | :30-32 | :29-31 | differs per suite (the `unset -f` list) |
| `run_with_stub_path()` | :34-38 | :35-39 | :34-38 | identical |
| `record()` | :41-43 | :42-44 | :41-43 | identical |

- `copy.bats` also defines `SCRIPT_UNDER_TEST` (`:19`) and the same `setup()` (`:22-25`), but not `run_with_stub_path` or `record`. It has an inline `PATH` override inside C824-11 (`:133-136`). It is outside the AC-4 scope.
- Candidate shared content: `SCRIPT_UNDER_TEST`, `setup`, `run_with_stub_path`, `record`, and `FIXTURES` (dotnet/verify). `teardown` stays per suite because the stubbed function names differ. If `setup` is moved, the three suites no longer define it, which satisfies "none of the three redefines them". `FIXTURES` is not required by installers, so loading it there is harmless.

### `run_with_stub_path` (CR-12)

- Body: `local PATH="${BATS_TEST_DIRNAME}"`, `local HOME="${BATS_TEST_DIRNAME}"`, then `"$@"`. The PATH it builds is the single directory `tests/shell`.
- `tests/shell` currently holds only `.bats` files, so the stub PATH is effectively empty, but it is fragile: any executable added to `tests/shell` would satisfy `command -v`. A dedicated empty fixture directory removes that dependency.
- Callers: installers (many cases), dotnet C824-41, C824-44, C824-46, C824-47, verify C824-48, C824-49, C824-55, C824-56.
- Git cannot store an empty directory, so the directory needs a `.gitkeep`. Precedent: `tests/fixtures/cleanup_worktrees/preserve/no-jq/.gitkeep` and other `.gitkeep` files under `tests/fixtures/`. A `.gitkeep` is not executable and is not found by `command -v`.

### C824-37 (CR-11)

- `test_codex_web_setup_codex_dotnet.bats:76-86`. Title: "append_if_missing leaves a file that already contains the line". Arrange only stubs `touch`. The act runs `append_if_missing "${FIXTURES}/bashrc-with-ci.txt" 'export CI=true'`. The assertions follow, including `run grep -c -x 'export CI=true' ...` yielding `1`.
- Fixture: `tests/fixtures/codex_web_setup/bashrc-with-ci.txt`, which contains exactly one line, `export CI=true` (verified by reading).
- Recommended Arrange assertion: a precondition check before the act, using a plain command substitution so `$status` and `$output` are not clobbered, for example `[ "$(grep -c -x 'export CI=true' "${FIXTURES}/bashrc-with-ci.txt")" = "1" ]`. `grep` is not stubbed in this test, and `teardown` unsets any stub afterwards.

### C824-7 (CR-2)

- `test_codex_web_setup_codex_copy.bats:82-88`: `run list_root_solution_files "${BATS_TEST_DIRNAME}"`, asserts status 0 and empty output. This is the only direct test of `list_root_solution_files`. There is no positive case.
- Existing fixtures contain no `.sln` file (Glob of `tests/fixtures/codex_web_setup/**` shows only `bashrc-with-ci.txt`, `dotnet-repo/`, `dotnet-sdk-installed/`, `populated-packages/`).

### Fixture directories and how they are referenced

- Location: `tests/fixtures/codex_web_setup/` (`bashrc-with-ci.txt`, `dotnet-repo/{coverage.config,dotnet-tools.json,global.json}`, `dotnet-sdk-installed/...`, `populated-packages/packages/placeholder.txt`).
- Referenced via `FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"` (dotnet `:23`, verify `:22`) and via `${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup/populated-packages` (copy `:118`).
- Tension to resolve: AC-2 requires the `Alpha.sln` fixture "under `tests/shell/`", whereas `.claude/rules/shell.md:93-96` says to use checked-in fixtures under `tests/fixtures/`. The AC text governs. Recommended location: `tests/shell/fixtures/codex_web_setup/solution-root/Alpha.sln` (empty file). Placing the empty stub-PATH directory next to it keeps both new fixtures together: `tests/shell/fixtures/codex_web_setup/empty-path/.gitkeep`. Putting the fixtures in a subdirectory also keeps them out of the bats top-level directory listing.

### Existing precedent for shared `load`ed helpers

- None. Grep for `load ` / `*.bash` in `tests/shell` found no matches, and Glob of `tests/shell/**` returns only `*.bats` files at the top level (no subdirectories). The shared helper is therefore the first of its kind.
- Recommended file: `tests/shell/helpers/codex_web_setup_common.bash`, loaded with `load 'helpers/codex_web_setup_common'` (bats resolves relative to `BATS_TEST_DIRNAME` and appends `.bash`). It is sourced in the test scope, so `BATS_TEST_DIRNAME` is available. Define `SCRIPT_UNDER_TEST`, `FIXTURES`, `setup`, `run_with_stub_path`, `record` there. `load` must appear at file top level, before the first `@test`.

## 4. CI

- `.github/workflows/ci.yml:26-27` calls `.github/workflows/_shell-coverage.yml` as job `shell-coverage` ("Shell Coverage (Bats + kcov)", ubuntu-latest).
  - Installs `shellcheck` and `bats` with apt, `shfmt` 3.8.0 as a binary, and kcov v43 built from source (cached).
  - Runs `bash scripts/bash/shell-qc.sh check` (`:51-52`) and `bash scripts/bash/shell-qc.sh test --coverage` (`:54-55`), then uploads `artifacts/pester/kcov/**` as artifact `shell-coverage` (`:57-61`).
  - `_build-check.yml:37` only runs `shell-qc.sh --help`.
- Discovery (`scripts/bash/shell_qc_lib.sh`):
  - shfmt and shellcheck inputs come from `discover_shell_scripts` (`:75-102`), whose roots are `tools`, `scripts`, `.claude/lib/bash`, `.claude/skills` and `.codex` (`:85`). `tests/` is not a root, so a `.bash` helper and the fixtures are not formatted or linted. `.codex/codex-web-setup.sh` is covered, so the script edits must be shfmt-clean (tab indentation) and shellcheck-clean.
  - Test directories come from `find_bats_test_dirs` (`:104-120`): `tests/shell` then `tests/bash`. The runner calls `bats "$test_dir"` (`:262`, `:365`) with no `-r`. bats-core runs `*.bats` files directly in that directory only. A `*.bash` helper (even at `tests/shell` top level) and files in subdirectories are not run as suites. The helper and fixture `.sln` are safe in `tests/shell/helpers/` and `tests/shell/fixtures/`. (This bats behaviour is from bats-core documentation knowledge; it is not demonstrated by a CI run here.)
- kcov: include pattern is `tools,scripts,.claude/lib/bash,.claude/skills,.codex` under the repo root; exclude is `tests` (`:350-351`). A kcov report is a merged Cobertura `cov.xml`.
- Threshold: `scripts/bash/shell-qc.sh` has no threshold or fail-under logic (Grep for `threshold|85` returned nothing). `print_coverage_summary` (`:292-307`) only prints `Bash coverage (lines): NN.N%`. The 85% line threshold in `.claude/rules/quality-tiers.md` is policy, not enforced by the script. Reviewers must read the printed percentage.
- Other repository checks that might react to new files under `tests/shell/fixtures` or `tests/shell/helpers`:
  - No `.gitattributes`, `.prettierignore`, `.editorconfig` or `.gitignore` entry mentions `.sln`, `.bash` or `tests/shell`.
  - `quality-tiers.yml` maps only PoshQC and `scripts/powershell` paths; it does not list `tests/shell`.
  - An empty `Alpha.sln` file is committable without `.gitkeep` (only empty directories need one). The `empty-path` directory needs `.gitkeep`.
  - The 824 hard-coded-solution scan does not read `tests/`.

## 5. Inventory tests

- No pytest or Pester test inventories `tests/shell` files or `tests/fixtures/codex_web_setup`. Grep of `tests/**/*.py`, `tests/**/*.ps1`, `quality-tiers.yml` and config files found only unrelated references (`.bats` token-shape tests in `test_blast_radius_*`, and `*_bash_parity.py` docstrings). No update to any inventory test is needed.
- `EXPECTED_LISTED_COPY_COUNT = 36` in `test_push_down_issue_824_follow_ups.py:94` counts the listed copies, not files in the script. It does not change unless a new listed copy is added, which this work does not do.

## 6. Recommended approach per item

- CR-1 / AC-1: add a small function after `log` (for example `log_solution_selection`) taking the newline-separated listing and the selected name. It prints nothing for an empty listing, else logs the selected file name and the count of listed `*.sln` files, for example `Selected solution file Alpha.sln (2 root *.sln files found).`. Call it from `main()` right after the "Bootstrapping" log, for example `log_solution_selection "$(list_root_solution_files "${REPO_ROOT}")" "${SOLUTION_FILE}"`.
  - This avoids a top-level log before `log` is defined and avoids output on every `source`.
  - Existing main test C824-61 sets `REPO_ROOT="${BATS_TEST_DIRNAME}"`, which has no `.sln`, so an empty-silent function leaves its asserted ordering intact. Alternatively the test can stub the new function.
  - New bats case in the copy suite: call the function with a two-line listing (`Alpha.sln`, `Beta.sln`) and `Alpha.sln`, then assert both the file name and `2` appear in `$output`. Also add an empty-input case for the silent branch. Keep the selection logic in `select_solution_file` (unchanged) so no behaviour change.
- CR-3 / AC-3: add a comment directly above the `find` line in `list_root_solution_files`, for example "Requires GNU find: -printf is a GNU extension; other find implementations fail and the error is hidden by 2>/dev/null." Keep the exact words "GNU `find` is required" in mind for AC wording, and add it to the existing header comment (`:26-27`) so it stays adjacent.
- CR-2 / AC-2: commit `tests/shell/fixtures/codex_web_setup/solution-root/Alpha.sln` (empty file). Add a copy-suite case: `run list_root_solution_files "${BATS_TEST_DIRNAME}/fixtures/codex_web_setup/solution-root"`, assert status 0 and `[ "$output" = "Alpha.sln" ]`. Optionally add a second case for ordering through `select_solution_file`.
- CR-10 / AC-4: create `tests/shell/helpers/codex_web_setup_common.bash` holding the identical definitions; replace them in the three suites with a top-level `load 'helpers/codex_web_setup_common'`; keep per-suite `teardown` and header comments.
- CR-11 / AC-5: add the Arrange precondition assertion in C824-37 as described in section 3.
- CR-12 / AC-6: the shared `run_with_stub_path` sets `PATH` (and `HOME`) to `tests/shell/fixtures/codex_web_setup/empty-path`; commit its `.gitkeep`. Keep the copy suite's inline PATH override in C824-11 unchanged unless the author chooses to align it (out of AC scope).
- CR-14 / AC-7: no script change; document the attribution limit in the feature folder after reading the PR's CI `shell-coverage` artifact (option (a) in section 1).
- AC-8: apply the identical edit to the mirror; verify with `git hash-object` on both paths during execution; CI shell-qc, bats and kcov must be green.

### Rejected alternatives (brief)

- Logging at top level beside `SOLUTION_FILE=` (`:35`): runs before `log` exists and prints on every `source`.
- Removing the subshells to make kcov count the lines: changes working-directory behaviour and the mirror content for a reporting artefact.
- Placing fixtures under `tests/fixtures/` per `shell.md`: conflicts with AC-2's explicit `tests/shell/` location.

### Recommended file list

WRITES (outside the feature folder):

1. `.codex/codex-web-setup.sh` (CR-1 function and `main()` call, CR-3 comment)
2. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` (identical edit)
3. `tests/shell/helpers/codex_web_setup_common.bash` (new shared helper)
4. `tests/shell/test_codex_web_setup_codex_installers.bats` (load helper, remove duplicates)
5. `tests/shell/test_codex_web_setup_codex_dotnet.bats` (load helper, remove duplicates, C824-37 Arrange assertion)
6. `tests/shell/test_codex_web_setup_codex_verify.bats` (load helper, remove duplicates)
7. `tests/shell/test_codex_web_setup_codex_copy.bats` (positive discovery case, two-`.sln` logging case, empty-listing logging case)
8. `tests/shell/fixtures/codex_web_setup/solution-root/Alpha.sln` (new, empty)
9. `tests/shell/fixtures/codex_web_setup/empty-path/.gitkeep` (new, empty)

Only read or run (no edits): `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`, `scripts/bash/kcov_trace_env.sh`, `.github/workflows/_shell-coverage.yml`, `.github/workflows/ci.yml`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `tests/fixtures/codex_web_setup/**`, `.github/codex/codex-web-setup.sh` and its suites, `.claude/rules/shell.md`.

## Testing implications

- Use the AAA structure of the existing suites and the `C824-N` naming; new case IDs continue after C824-61 (next free number to be confirmed by the implementer with a Grep of `C824-` across `tests/shell`).
- No temporary files, no clock or network use; the new tests read committed fixtures only.
- The logging function is pure (arguments in, text out), so it needs no stubs.
- Local bats, kcov, shellcheck and shfmt runs are excluded by the operator constraint; CI is the verification source.

## Automation Feasibility

Fully automatable. All changes are text edits to a shell script, bats suites, a shared helper and two fixtures; verification is the PR's CI (shell-qc, bats, kcov) plus a hash comparison of the two script copies. No human interaction, credentials, interactive tooling or manual review gate was found. The one dependency on an external step is reading the CI kcov report for AC-7, which the implementing agent can fetch from the PR's `shell-coverage` artifact.
