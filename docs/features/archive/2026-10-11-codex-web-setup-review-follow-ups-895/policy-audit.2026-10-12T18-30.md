# Policy Audit (issue #895)

Timestamp: 2026-10-12T18-30
Branch: bug/codex-web-setup-review-follow-ups-895
Base: origin/main @ 88946d10a47911a426abec906b2b2163814f5950; Head: 18566f978bcf04c4411f975b5d4c08c3ff6fe97e
Work mode: minor-audit
Scope: full branch diff against base (9 non-doc files, 35 docs/evidence files). Languages with changed files: Bash/bats only. No Python, TypeScript, PowerShell, or C# files changed.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope. It stated that shell tools are verified only via CI (operator Option A); that is a statement about evidence sources, not a scope reduction, and is handled under Coverage Verification and the shell toolchain row below.

## Verdict Summary

| Area | Verdict |
|---|---|
| Tone policy (artifacts) | PASS |
| General code change (design, size, naming, error handling) | PASS |
| General unit test (AAA, independence, no temp files, location) | PASS |
| Shell toolchain (shfmt, shellcheck, bats, kcov) | FAIL (CI evidence pending; see below) |
| Coverage verification (Bash) | FAIL (artifact absent; see below) |
| Mirror parity | PASS |
| File size limit | PASS |
| Evidence Location Compliance | PASS |
| Coverage exclusions | PASS |

## Evidence

- File size (500 lines): `evidence/qa-gates/line-counts-895.md` lists the script at 429 lines, helper 34, and the four suites at 220, 195, 254, 194. All below 500. PASS.
- Mirror parity: `git hash-object` run during review returned `db6cf823a72a7568ae96304725b530746e8ef748` for both `.codex/codex-web-setup.sh` and the bundled mirror. PASS.
- Test location: new helper at `tests/shell/helpers/codex_web_setup_common.bash`, fixtures under `tests/fixtures/codex_web_setup/`; no colocation under production source. PASS. The helper is in a subdirectory; `find_bats_test_dirs` in `scripts/bash/shell_qc_lib.sh` passes `tests/shell` to bats without a recursive flag, so the helper is not run as a suite. PASS.
- Temp files in tests: none created; new fixtures are committed (`Alpha.sln`, `empty-path/.gitkeep`). PASS.
- AAA structure: C824-62, -63, -64 use Arrange/Act/Assert comments; C824-37 Arrange now asserts the fixture invariant. PASS.
- Determinism: no clock, sleep, or randomness added. PASS.
- Error handling: `log_solution_selection` logs nothing when the listing is empty, consistent with the existing `select_solution_file` contract; no errors swallowed. The pre-existing `2>/dev/null` on `find` is now documented by the GNU-find comment. PASS.
- Coverage exclusions: the diff adds no coverage-exclude entries and changes no coverage configuration. PASS.
- Shell formatting convention: the script uses tab indentation (shfmt default per `.claude/rules/shell.md`). The new script lines use tabs. The helper and bats files use four spaces, matching the pre-existing bats suites; `discover_shell_scripts` roots (`tools`, `scripts`, `.claude/lib/bash`, `.claude/skills`, `.codex`) exclude `tests/`, so shfmt does not scan them. PASS (shfmt result itself still pending, below).
- Tone: feature artifacts are factual; no promotional or humorous wording found. PASS.

## Shell Toolchain (shfmt, shellcheck, bats, kcov)

Per the operator constraint these tools were not run locally and were not run by this reviewer. `evidence/qa-gates/ci-shell-check-895.md`, `ci-bats-895.md`, and `ci-kcov-coverage-895.md` contain `S9-EVIDENCE: PENDING`, and `EXIT_CODE: DEFERRED-S9`. No PR exists, so no CI run exists for the head. The mandatory toolchain loop (`.claude/rules/general-code-change.md`) cannot be shown satisfied for the shell stages. Verdict FAIL for these stages until the orchestrator records the CI results at S9. The static review found no construct likely to fail shellcheck or shfmt on the changed `.codex/codex-web-setup.sh` lines.

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0. The branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,qa-gates,other}/`. PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

## Coverage Verification

Language with changed files: Bash (`.codex/codex-web-setup.sh` and its bundled mirror modified; bats suites and helper are test code).

- Coverage artifact: kcov output is produced only in CI (`Run shell-qc test with coverage`). No local artifact exists (`artifacts/` holds only orchestration and PR-context files; no `coverage/` directory). Per the coverage contract, an absent artifact for a language with changed files is FAIL.
- Repo-wide Bash line coverage: not determinable from artifacts. Baseline reference from PR #879 CI run: 94.3% (script file 95.7%, 199/208), above 85%.
- Modified file `.codex/codex-web-setup.sh`: new lines added are 16 (one comment, 13-line function with comments, one call). Tests C824-62 and C824-63 exercise both branches of `log_solution_selection`, and `main` is exercised by the verify suite case that runs `main`. Static expectation: no regression. Not confirmed by artifact.
- Branch coverage: kcov does not measure it; no branch gate applies (`.claude/rules/quality-tiers.md`).
- Verdict: FAIL (coverage artifact absent for Bash). Remediation trigger recorded; resolved by S9 CI evidence in `ci-kcov-coverage-895.md`.

## Other Observations

- The mirror under `extensions/drm-copilot/resources/` was edited directly, consistent with the issue's byte-identity requirement.
- Python guard tests for the push-down existence check were recorded as passing (4 passed) in `evidence/qa-gates/pytest-push-down-824-895.md`; this reviewer did not rerun them.
