# codex-web-setup-review-follow-ups (Issue #895)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-web-setup-review-follow-ups/ (Issue #895)
- Origin: issue #824 follow-ups (PR #879), code-review findings CR-1, CR-2, CR-3, CR-10, CR-11, CR-12, CR-14

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #895
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/895
- Last Updated: 2026-10-11
## Summary

PR #879 brought `.codex/codex-web-setup.sh` under shell-qc and kcov and added bats suites for it. The two code reviews left seven non-blocking findings open against the script and its suites: silent selection among several root `*.sln` files, a missing positive discovery test, an undocumented GNU `find -printf` dependency, duplicated bats helpers, a fixture precondition not asserted in Arrange, a stub `PATH` pointing at `tests/shell`, and three kcov-uncovered subshell lines.

## Environment

- OS/version: Linux (Codex web environment; CI bats/kcov job)
- Python version: n/a (bash)
- Command/flags used: `bats tests/shell/test_codex_web_setup_codex_*.bats`; kcov in CI
- Data source or fixture: main at 2ef8d361; review artifacts in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`

## Steps to Reproduce

1. Place two `*.sln` files at a repository root and run `.codex/codex-web-setup.sh`; observe that no message states which was selected.
2. Run the script on a system whose `find` lacks `-printf` (BSD `find`).
3. Read the bats suites listed below for the duplicated helpers and the stub `PATH`.

## Expected Behavior

The script logs which solution file it selected and how many it found, documents its GNU tool requirements, and its bats suites share helpers, assert fixture preconditions before acting, and use a dedicated empty stub directory.

## Actual Behavior

| ID | Severity | Location | Finding |
|---|---|---|---|
| CR-1 | Minor | `.codex/codex-web-setup.sh:17-23` (`select_solution_file`), line 35 | With several root `*.sln` files, the first in C order is selected silently. |
| CR-2 | Minor | `tests/shell/test_codex_web_setup_codex_copy.bats`, case C824-7 | No positive case where `list_root_solution_files` lists a `*.sln` (proposed committed fixture with an empty `Alpha.sln`). |
| CR-3 | Nit | `.codex/codex-web-setup.sh:26-30` | The GNU `find -printf` requirement is not documented. |
| CR-10 | Nit | `tests/shell/test_codex_web_setup_codex_{installers,dotnet,verify}.bats`, about lines 21-44 | Helpers duplicated across suites; no shared `load`ed file exists. |
| CR-11 | Minor | `tests/shell/test_codex_web_setup_codex_dotnet.bats`, C824-37, lines 76-86 | Fixture invariant not asserted in Arrange. |
| CR-12 | Nit | the same three suites, `run_with_stub_path` | Stub `PATH` points at `tests/shell` rather than a dedicated empty fixture directory. |
| CR-14 | Info | `.codex/codex-web-setup.sh:207, 210, 302` | kcov reports three subshell lines as uncovered; likely an attribution limit, not confirmed. |

CR-1, CR-3 and CR-10 were spot-checked on main and are unchanged.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: sources are `code-review.2026-10-10T00-44.md` findings table lines 33-41 (CR-1..CR-9) and `code-review.2026-10-10T14-25.md` lines 36-40 (CR-10..CR-14); the latter's carried-items table (lines 46-54) marks CR-1..CR-6 "Open, deferred". PR #879 Risks: "Several root `*.sln` files: the first in C order is selected silently (CR-1). Mitigation: documented; logging is a follow-up."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. The script works for the single-solution case; the findings affect diagnosability, portability and test robustness.

## Suspected Cause / Notes

- The script and suites were brought into scope late in #824 (PA-1, operator decision to widen scope), and these findings were accepted as non-blocking.

## Proposed Fix / Validation Ideas

- [ ] Log the selected solution and the count when several exist (CR-1); document the GNU `find` requirement or replace `-printf` (CR-3).
- [ ] Unit coverage areas: add the positive `Alpha.sln` discovery case (CR-2); assert the C824-37 fixture precondition in Arrange (CR-11).
- [ ] Move shared bats helpers into one `load`ed file (CR-10); use a dedicated empty stub directory (CR-12).
- [ ] Manual verification notes: confirm whether the three CR-14 lines are a kcov attribution limit.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch