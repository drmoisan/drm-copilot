# 2026-10-11-codex-web-setup-review-follow-ups

- Work Mode: minor-audit
- Issue: #895
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/895
- Lifecycle record: `docs/features/potential/promoted/2026-10-11-codex-web-setup-review-follow-ups.md` at ref `origin/docs/followups-2026-10-11` (unmerged; cited by ref, not copied)

## Problem / Why

PR #879 brought `.codex/codex-web-setup.sh` under shell-qc and kcov and added bats suites for it. The two code reviews of #824 (`code-review.2026-10-10T00-44.md` and `code-review.2026-10-10T14-25.md` in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`) left seven non-blocking findings open against the script and its suites:

| ID | Severity | Location (main at 2ef8d361) | Finding |
|---|---|---|---|
| CR-1 | Minor | `.codex/codex-web-setup.sh:17-23` (`select_solution_file`), line 35 | With several root `*.sln` files, the first in C order is selected silently. |
| CR-2 | Minor | `tests/shell/test_codex_web_setup_codex_copy.bats`, case C824-7 | No positive case where `list_root_solution_files` lists a `*.sln`. |
| CR-3 | Nit | `.codex/codex-web-setup.sh:26-30` | The GNU `find -printf` requirement is not documented. |
| CR-10 | Nit | `tests/shell/test_codex_web_setup_codex_{installers,dotnet,verify}.bats`, about lines 21-44 | Helpers duplicated across suites; no shared `load`ed file exists. |
| CR-11 | Minor | `tests/shell/test_codex_web_setup_codex_dotnet.bats`, C824-37, lines 76-86 | Fixture invariant not asserted in Arrange. |
| CR-12 | Nit | the same three suites, `run_with_stub_path` | Stub `PATH` points at `tests/shell` rather than a dedicated empty fixture directory. |
| CR-14 | Info | `.codex/codex-web-setup.sh:207, 210, 302` | kcov reports three subshell lines as uncovered; likely an attribution limit, not confirmed. |

Impact: Low. The script works for the single-solution case; the findings affect diagnosability, portability and test robustness.

## Implementation Intent

- Log which root `*.sln` file was selected and how many were found (CR-1).
- Document the GNU `find -printf` requirement in the script (CR-3).
- Add a positive discovery case backed by a committed fixture containing an empty `Alpha.sln` (CR-2).
- Move the duplicated helpers of the installers, dotnet and verify suites into one shared file loaded with bats `load` (CR-10).
- Assert the C824-37 fixture invariant in the Arrange section (CR-11).
- Point `run_with_stub_path` at a dedicated empty fixture directory (CR-12).
- Investigate the three kcov-uncovered subshell lines and either cover them or record the attribution limit with evidence (CR-14).
- Keep the bundled mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` byte-identical to `.codex/codex-web-setup.sh`. `.github/codex/codex-web-setup.sh` is a separate, divergent script and is out of scope.

## Acceptance Criteria

- [x] AC-1 (CR-1): When one or more root `*.sln` files exist, `.codex/codex-web-setup.sh` emits a log line naming the selected solution file and the number of root `*.sln` files found; a bats case with two root `*.sln` files asserts both values in the output.
- [x] AC-2 (CR-2): A committed fixture directory containing an empty `Alpha.sln` exists under `tests/fixtures/codex_web_setup/` (fixture location per `.claude/rules/shell.md`), and a bats case asserts that `list_root_solution_files` lists `Alpha.sln` for that fixture.
- [x] AC-3 (CR-3): `.codex/codex-web-setup.sh` contains a comment, adjacent to the `find -printf` call, stating that GNU `find` is required.
- [x] AC-4 (CR-10): The helpers duplicated across `test_codex_web_setup_codex_installers.bats`, `test_codex_web_setup_codex_dotnet.bats` and `test_codex_web_setup_codex_verify.bats` are defined once in a shared helper file under `tests/shell/` that each of the three suites loads with `load`, and none of the three suites redefines them.
- [x] AC-5 (CR-11): Case C824-37 in `test_codex_web_setup_codex_dotnet.bats` asserts its fixture precondition in the Arrange section before the act step.
- [x] AC-6 (CR-12): `run_with_stub_path` places a dedicated empty fixture directory under `tests/fixtures/codex_web_setup/` (committed with a `.gitkeep`), not `tests/shell`, on the stub `PATH`.
- [x] AC-7 (CR-14): The three kcov-uncovered subshell lines are either covered in the PR's CI kcov report or documented in the feature folder as a kcov attribution limit with the CI kcov evidence cited.
- [x] AC-8: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` is byte-identical to `.codex/codex-web-setup.sh`, and the PR's CI shell-qc, bats and kcov jobs pass.

## Dependencies / Risks

- bats, kcov, shellcheck and shfmt results are taken from the PR's CI run (operator constraint: no local `sh`/`bash`/`pwsh` wrapper invocation of those tools).
- A shared helper file must not be picked up as a test suite by the bats runner glob.
- Other parallel items may touch `tests/shell/`; the change set is restricted to the files named above.

## Verification Steps

- PR CI: shell-qc (shellcheck, shfmt), bats and kcov jobs green against the PR head.
- Mirror parity: no repository test compares the two script copies byte for byte, so parity is verified with `git hash-object` on both paths; the existing push-down existence test `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` must still pass.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
