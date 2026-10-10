# Code Review: Issue #823 tier-rule adoption follow-ups (#824 Addendum 2) - Re-review after PA-1 scope widening

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`
**Feature Folder Selection Rule:** suffix `-824` matches the canonical issue number; it is the only active feature folder changed by the branch.
**Base Branch:** `origin/main` @ `793731a12` (merge base `7bbd0b9b9`)
**Head Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824` @ `b0e84df4b`
**Review Type:** Re-review (prior review `code-review.2026-10-10T00-44.md` at `1d5b66015`)

---

## Executive Summary

The full merge-base diff contains 67 non-evidence files and 162 evidence files. Since the prior review, the branch added the PA-1 scope widening: `.codex/` joins the shell-qc discovery roots and kcov include roots (`scripts/bash/shell_qc_lib.sh`, `.claude/rules/shell.md` and its bundled copy), `.codex/codex-web-setup.sh` and its bundled copy take the shfmt default layout (whitespace-only, verified with `git diff -w 1d5b66015 HEAD`), and three new bats suites plus fixtures raise kcov line coverage of the script to 95.67%. The FU-823-1/2/3/5 and note A/B implementation is unchanged since the prior review.

Evidence reviewed: the regenerated PR context (`artifacts/pr_context.summary.txt`, head `b0e84df4b`), the full diff, CI run 38057811190 (log and `cov.xml`, recomputed), CI run 38022356096 (PoshQC artifact, recomputed), reviewer-run Python checks and parity suites, and mirror byte-parity checks.

**Top 3 risks:**
1. The branch is 58 commits behind `origin/main`; PR CI must run on the updated tree (policy audit PA-6). A trial merge reports no conflict.
2. Runtime solution discovery still selects the first root `*.sln` silently when several exist (CR-1, carried).
3. Three new bats suites duplicate the same stub helpers, and one case relies on a fixture invariant that, if broken, would let the function under test append to a committed file (CR-10, CR-11).

**PR readiness recommendation:** **Go**, subject to the pending items owned by PR authoring and PR CI (AC-13, AC-15).

Total blocking findings in this artifact: **0**.

---

## Findings Table

### New findings (this re-review)

| ID | Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|---|
| CR-10 | Nit (Non-blocking) | `tests/shell/test_codex_web_setup_codex_installers.bats`, `..._dotnet.bats`, `..._verify.bats` | helper functions near lines 21-44 of each file | `SCRIPT_UNDER_TEST`, `setup()`, `run_with_stub_path`, and `record` are defined identically in all three new suites (and `SCRIPT_UNDER_TEST`/`setup` also in `..._copy.bats`). | Move the shared helpers into one file under `tests/shell/` (for example `codex_web_setup_helpers.bash`) and `load` it from each suite. | Reduces duplication; a future change to stub isolation (for example the PATH policy) would otherwise need four edits. | Reviewer read of the three files. |
| CR-11 | Minor (Non-blocking) | `tests/shell/test_codex_web_setup_codex_dotnet.bats` | C824-37, lines 76-86 | `append_if_missing` runs against the committed fixture `tests/fixtures/codex_web_setup/bashrc-with-ci.txt` with only `touch` stubbed. The case relies on the fixture already containing `export CI=true`; if the fixture lost that line (or gained CRLF endings), the function would append to the committed fixture before the assertion fails. | Assert the precondition in Arrange (for example `grep -Fqx 'export CI=true' "${FIXTURES}/bashrc-with-ci.txt"` before Act), so a broken fixture fails the case before the function can write. | Keeps the "no file changes" guarantee stated in the suite header independent of fixture state. The fixture is currently LF (`git ls-files --eol`) and holds the line once, so the case is correct today. | Test source; `.codex/codex-web-setup.sh:62-70` (`append_if_missing`). |
| CR-12 | Nit (Non-blocking) | `tests/shell/test_codex_web_setup_codex_{installers,dotnet,verify}.bats` | `run_with_stub_path` | `PATH` is narrowed to `tests/shell`, which holds the executable `.bats` files. Tool absence therefore depends on no file in that directory sharing a probed tool name (`tar`, `pwsh`, `dotnet`, and others). | Point `PATH` at a dedicated committed empty directory under `tests/fixtures/codex_web_setup/`. | Removes an implicit coupling between unrelated test file names and these cases. | Suite headers state the directory "holds no executable"; the `.bats` files are executable in the working tree. |
| CR-13 | Nit (Non-blocking) | `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` | lines 299 and 310 | The Risks bullet and the Rollout follow-up still state that kcov does not measure `.codex/`. The Change Log (line 316) supersedes both, but the original bullets carry no inline marker. | Optionally append "(superseded; see Change Log 2026-10-10)" to the two bullets. | Prevents a reader of the Risks section from drawing the outdated conclusion. | spec.md lines 299, 310, 316. |
| CR-14 | Info (Non-blocking) | `.codex/codex-web-setup.sh` | lines 207, 210, 302 | kcov reports these subshell lines (`cd "${REPO_ROOT}"` and the `dotnet` call inside `( ... )`) as uncovered although C824-43 and C824-50/51 execute the enclosing subshells. | None required; likely a kcov subshell-attribution limit (not confirmed). | The file is at 95.67%; the remaining six uncovered lines are inside the `pwsh -Command` string that AC-14 protects. | `cov.xml` recomputation; test sources. |

### Carried findings from the prior review (operator-approved deferrals)

| ID | Severity | Status at `b0e84df4b` | Summary |
|---|---|---|---|
| CR-1 | Minor (Non-blocking) | Open, deferred | `select_solution_file` picks the first root `*.sln` in C order without logging the choice. |
| CR-2 | Minor (Non-blocking) | Open, deferred | No case lists a root `*.sln` through `list_root_solution_files` (positive `find` path). kcov counts the line as covered because sourcing runs it, but no assertion checks its output. |
| CR-3 | Nit (Non-blocking) | Open, deferred | The GNU `find -printf` dependency is not noted in the script (`grep -n GNU .codex/codex-web-setup.sh` returns no match). |
| CR-4 | Minor (Non-blocking) | Open, deferred | An unreadable root `CLAUDE.md` makes the hook fail closed instead of applying defaults as the spec wording states. |
| CR-5 | Minor (Non-blocking) | Open, deferred | `PRE_EXISTING_NAME_EXCEPTIONS` is per file, so new occurrences in excepted files are not detected. |
| CR-6 | Nit (Non-blocking) | Open, deferred | Repeated `Get-ArtifactFileContent` mock blocks in the Issue824 Pester suite. |
| CR-7 | Info (Non-blocking) | No action | F824-9 reads its own test file (read-only). |
| CR-8 | Info (Non-blocking) | No action | Hook at 471 of 500 lines. |
| CR-9 | Info (Non-blocking) | No action | Resolver does not read comparator-after-figure statements; documented. |

No Blocker or Major findings.

---

## Implementation Audit

### Bash implementation audit (widening)

#### What changed well

- `discover_shell_scripts` and `run_test_coverage` change by one token each (`shell_qc_lib.sh:85`, `:350`); comments and `shell.md` text were updated in the same commit, and the rule and its bundled copy are byte-identical.
- `test_shell_qc_discovery.bats` pins the new root with a positive case and re-pins the full sorted output (8 lines), with a comment that correctly explains the C-locale ordering. `test_shell_qc_commands.bats` pins `.codex` as the last include entry immediately before `--exclude-pattern`.
- The shfmt reformat of `.codex/codex-web-setup.sh` is whitespace-only relative to the prior review head; the `pwsh -Command` vswhere/vstest string is byte-unchanged relative to the base, so AC-14 still holds.
- No `shellcheck disable` directive was needed.

#### Correctness notes

- The include pattern is a comma-separated prefix list; `$repo_root/.codex` does not match the bundled copy under `extensions/`, so only the repository copy enters the denominator, which matches the spec.
- `.codex/` contains one shell script (`git ls-files .codex` plus shebang scan), so the widening adds exactly one production file to shell-qc scope.

### PowerShell and Python implementation audit

Unchanged since the prior review (no PowerShell or Python file in the branch diff changed after `1d5b66015`). Prior assessment stands.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/shell/test_codex_web_setup_codex_installers.bats` (C824-16 to C824-33): every skip, sudo, root, and download-failure branch of the four installers; `mktemp` returns `/nonexistent/...`; `sudo tee` stub drains stdin so no wrapper is written.
- `tests/shell/test_codex_web_setup_codex_dotnet.bats` (C824-34 to C824-47): `global.json` parsing, `append_if_missing` both branches without changing a file, SDK reuse/install, tool restore, `dotnet-coverage` skip/update/install.
- `tests/shell/test_codex_web_setup_codex_verify.bats` (C824-48 to C824-61): verification functions and `main` step order with every step replaced.
- Fixtures under `tests/fixtures/codex_web_setup/` are small, LF, and committed.
- CI evidence: `FEATURE/evidence/qa-gates/ci-shell-rounds.2026-10-10T10-08.md`, `ci-bats-round1.2026-10-10T10-08.md`, `ci-kcov-codex-setup-round1.2026-10-10T10-08.md`, `bash-coverage-comparison.2026-10-10T10-10.md`, each matched by reviewer recomputation.

### Quality assessment prompts

- **Determinism:** shell-function stubs; no network, clock, or temporary files.
- **Isolation:** one function per case.
- **Speed:** no external process beyond bash builtins and the stubbed functions.
- **Diagnostics:** exact message-fragment assertions; negative assertions confirm skipped steps (for example `[[ "$output" != *"append"* ]]`).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | Unchanged from the prior review; shellcheck clean in CI. |
| Tests do not write outside fixtures | PASS | Installers and writers stubbed; `HOME` narrowed where an unstubbed path could reach it; see CR-11 for the one fixture-dependent case. |
| Configuration / path handling is safe | PASS | No absolute host paths in committed files; CI paths appear only in the git-ignored log. |

---

## Research Log

No external research was required. Conclusions are based on the branch diff, repository policy files, the regenerated PR context, CI runs 38057811190 and 38022356096 (metadata, log, and recomputed reports), and reviewer-run checks.

---

## Verdict

The widening resolves PA-1 with a minimal change to the shell-qc library and rule, a behavior-preserving reformat, and a thorough, deterministic bats suite that brings `.codex/codex-web-setup.sh` to 95.67% line coverage. The code review records 0 blocking findings, 5 new non-blocking findings (CR-10 to CR-14), and 9 carried non-blocking findings (CR-1 to CR-9, operator-approved deferrals).
