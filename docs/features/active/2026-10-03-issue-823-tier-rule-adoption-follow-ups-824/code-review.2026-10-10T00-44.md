# Code Review: Issue #823 tier-rule adoption follow-ups (#824 Addendum 2)

**Review Date:** 2026-10-10
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`
**Feature Folder Selection Rule:** suffix `-824` matches the branch issue number; it is the only active folder changed by the branch.
**Base Branch:** `origin/main` @ `816b5513a` (merge base)
**Head Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824` @ `1d5b66015`
**Review Type:** Initial review

---

## Executive Summary

The branch changes 47 non-evidence files (17 repository surfaces, 20 bundle mirrors or manifest entries, 6 test/fixture files, 3 feature records, and 1 research document) plus 116 evidence files. The functional changes are small and well contained: a new 77-line pure PowerShell resolver for coverage thresholds, threshold parameters threaded through the existing feature-review hook, runtime solution discovery in `.codex/codex-web-setup.sh`, and text edits to pushed policy, agent, and skill surfaces. Evidence reviewed: the full merge-base diff, regenerated PR context (`artifacts/pr_context.summary.txt`, head `1d5b66015`), reviewer-run Python toolchain and parity suites, reviewer recomputation of CI PowerShell coverage, and a byte-parity check of all 17 mirror pairs.

**What changed:**
`Get-FeatureReviewCoverageThreshold` resolves line and branch thresholds independently from root `CLAUDE.md` text, reading a figure only when a comparator phrase links it to the metric, with 85/75 defaults. `Invoke-FeatureReviewCoverageValidation` reads `CLAUDE.md` once through `Get-ArtifactFileContent` and passes the floors into `Test-LanguageCoverageRow`, whose reason strings now state the governing figure. `.codex/codex-web-setup.sh` discovers the first root `*.sln` in C order, skips restore with a warning and fails the Visual Studio verification when none exists, and gains a `BASH_SOURCE` guard. Product names are neutralized, `TaskMaster.sln` becomes `<solution>.sln`, and the per-metric fallback sentence is added to every precedence surface.

**Top 3 risks:**
1. The changed bash script has no coverage measurement and is not formatted or linted by shell-qc (pre-existing `.codex/` discovery gap; see policy audit PA-1 and PA-5).
2. Runtime discovery selects the first solution file silently when several exist at the repository root (CR-1).
3. bats verification of the script changes is pending CI on the PR head (OPS-1).

**PR readiness recommendation:** **Conditional Go** — the code review has no Blocker or Major finding; readiness depends on the bats CI result and on the policy-audit decision for PA-1.

Total blocking findings in this artifact: **0**.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `.codex/codex-web-setup.sh` | `select_solution_file`, lines 17-23; global `SOLUTION_FILE` line 35 | When several `*.sln` files exist at the root, the first in `LC_ALL=C` order is selected without any log line. | Log the selected solution (and the count when more than one exists) in `restore_packages_if_needed` or at startup. | A consumer with several solutions may restore or verify the wrong one with no visible signal. | Diff of `.codex/codex-web-setup.sh`; bats C824-6 pins the ordering only. |
| Minor (Non-blocking) | `tests/shell/test_codex_web_setup_codex_copy.bats` | C824-7 | `list_root_solution_files` is tested only against a directory without solution files; no case proves that a root `*.sln` is listed, and no case exercises the top-level `REPO_ROOT`/`SOLUTION_FILE` wiring. | Add a committed fixture directory containing an empty `Alpha.sln` and assert the listing; optionally assert `REPO_ROOT` selection through `resolve_repo_root` with that listing. | The spec Test Strategy lists "solution discovery"; the positive `find` path is unexercised. | bats file lines 82-88; spec Test Strategy. |
| Nit (Non-blocking) | `.codex/codex-web-setup.sh` | `list_root_solution_files`, lines 26-30 | The spec states that the GNU-specific `find -printf` dependency "is documented in the script"; the function comment does not mention it. | Add one comment line noting the GNU `find -printf` requirement (Linux Codex Web and Git Bash). | Keeps the documented portability constraint discoverable for consumers on BSD/macOS. | `grep -n "GNU" .codex/codex-web-setup.sh` returns no match; spec Technical specifications. |
| Minor (Non-blocking) | `.claude/hooks/validate-feature-review-coverage.ps1` | `Get-ArtifactFileContent` (lines 50-71) as used at line 441 | A root `CLAUDE.md` that exists but cannot be read makes `Get-Content -ErrorAction Stop` throw, so the hook terminates with an error (blocking) instead of applying the defaults as the spec Error-handling bullet states ("treated as no figures"). | Either catch the read failure for `CLAUDE.md` only and fall back to defaults, or amend the spec wording to "fails closed". | Behavior is fail-closed and therefore safe, but it differs from the documented contract. | Hook source; spec "Error handling and logging updates". |
| Minor (Non-blocking) | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | `PRE_EXISTING_NAME_EXCEPTIONS`, lines 110-120 | Exceptions are per file. A new `TaskMaster` or `No-COM` occurrence added to `typescript.md`, `csharp.md`, or `parallel-orchestration.md` (or their mirrors) would not fail the scan. | Consider pinning the expected occurrence count per excepted file so additions fail while the staleness guard still detects removal. | AC-5 is met as written; the per-file granularity weakens the reintroduction guard for the excepted files. | Test source; OPS-3 record `evidence/other/plan-revision-ops3.2026-10-10T00-09.md`. |
| Nit (Non-blocking) | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | F824-1 .. F824-8 | Each case repeats an 8-to-10-line `Get-ArtifactFileContent` mock switch that differs only in a few values. | Extract a helper in `BeforeAll` that builds the mock map from a hashtable of overrides. | Reduces duplication and the chance of divergent fixtures in future edits. | Test source lines 41-230. |
| Info (Non-blocking) | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | F824-9 | The case reads its own test file and probes an absent path without a mock. | None required; the docstring discloses it and no file is written. | Read-only access to a tracked file is permitted; temporary files are not used. | Test source lines 211-224. |
| Info (Non-blocking) | `.claude/hooks/validate-feature-review-coverage.ps1` | whole file | The hook is 471 lines, 29 lines below the 500-line limit. | Place further logic in dot-sourced helpers, following the pattern used for the resolver. | Concurrent items (#847) also edit this file. | `wc -l` (reviewer). |
| Info (Non-blocking) | `.claude/hooks/feature-review-coverage-thresholds.ps1` | regex at line 57 | Statements that put the comparator after the figure ("line coverage: 70% minimum") are not read and fall back to the defaults; hyphenated forms such as "on-line coverage >= 50%" would match the `line` metric. | Optionally mention the comparator-before-figure requirement in the consumer-facing rule text. | Both cases resolve toward the stricter default or are unlikely in practice; behavior is deterministic and documented in the helper help text. | Helper source; resolver rows T824-8, T824-9. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `test_push_down_issue_824_follow_ups.py` pins every listed copy, scans all pushed rule and skill globs (repository, bundle, and variant trees), scans the pushed roots for `TaskMaster.sln`, and includes synthetic tests proving the product-name check and step-8 extraction can fail.
- `coverage_threshold_context` narrows the #823 retired-figure scan to blank-line-separated paragraphs that mention coverage; the regex `\n\s*\n` also handles CRLF input. A positive/negative unit test is included.
- The prior-run `# noqa: S105` suppression was removed by renaming the constant to `FALLBACK_PHRASE`.

#### Typing and API notes

- No new public Python API. All helpers are annotated; Pyright reports 0 errors.

#### Error handling and logging

- No exception handling is added; file reads fail loudly, which is appropriate for contract tests.

### PowerShell implementation audit

#### What changed well

- The resolver is pure (caller supplies text), uses invariant-culture parsing, bounds figures to 0-100, resolves each metric independently, and documents the combined-phrase limitation, which resolves toward the stricter defaults.
- The hook change is minimal: new parameters with defaults keep existing callers and the existing Pester suite unchanged; thresholds are resolved once per run after the changed-language set is known to be non-empty.
- Reason strings now report the governing figure, which F824-2 and F824-3 assert.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, mandatory parameter with `AllowNull`/`AllowEmptyString`; approved verb `Get-` with a singular noun. No state-changing operation, so `ShouldProcess` is not required.

#### Error handling and logging

- Missing `CLAUDE.md` yields defaults. Unreadable `CLAUDE.md` throws (fail closed), which differs from the spec wording (CR-4 above).

### Bash implementation audit

- Discovery is split into argument-driven functions (`resolve_repo_root`, `select_solution_file`, `list_root_solution_files`), which makes the logic testable without filesystem fixtures beyond one committed directory.
- All expansions are quoted; `find ... 2>/dev/null` inside command substitution cannot abort the script under `set -e` because the outer assignment status is that of the enclosing function.
- The `vswhere`/`vstest` block is untouched (AC-14), and the `BASH_SOURCE` guard allows sourcing in tests.

---

## Test Quality Audit

Reviewed evidence: reviewer-run pytest (151 passed across the two issue modules and four parity/manifest suites); `evidence/qa-gates/poshqc-test.2026-10-10T00-22.md` (6780 Pester cases, 0 failures); `evidence/qa-gates/powershell-coverage-values.2026-10-10T00-22.md` and the CI report recomputed by the reviewer (helper 100.0%, hook 95.28%, repo 88.63%); `evidence/regression-testing/expect-fail-*` (fail-before records for the new tests); `evidence/qa-gates/bats.2026-10-10T00-23.md` (PENDING-CI).

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` — 11 data rows covering every resolution-table case plus prose, combined, decimal, and out-of-range inputs.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` — F824-1..3 pin the FU-823-1 behavior; remaining cases raise hook coverage from 49.52% to 95.28%.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` — 43 cases for FU-823-2, FU-823-3, FU-823-5, and note A.
- `tests/shell/test_codex_web_setup_codex_copy.bats` — 15 cases; positive discovery case absent (CR-2); result pending CI.
- `evidence/regression-testing/expect-fail-follow-ups-pytest.2026-10-09T23-21.md` — records the expect-fail split on the base tree.

### Quality assessment prompts

- **Determinism:** No clock, randomness, network, or temporary files; mocks for file reads; shell-function stubs for external commands.
- **Isolation:** Each case targets one behavior with a single assertion family.
- **Speed:** 151 Python cases in 0.63 s; Pester cases are string-only.
- **Diagnostics:** `-Because` messages, path-naming assertion messages, and exact-message bats assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credential or token text added. |
| No unsafe subprocess or command construction | PASS | `SOLUTION_FILE` is passed quoted to `nuget` and `pwsh -File ... -SolutionPath "${SOLUTION_FILE}"`; it comes from `find -name '*.sln'` at the repository root. |
| Input validation at boundaries | PASS | Resolver bounds figures to 0-100 and requires a comparator phrase; non-numeric values are ignored. |
| Error handling remains explicit | PASS | Missing solution produces an explicit warning or failure; hook failures remain blocking. |
| Configuration / path handling is safe | PASS | `CLAUDE.md` read relative to the hook working directory (repository root per settings); no absolute paths encoded in artifacts. |

---

## Research Log

No external research was required. All conclusions are based on the branch diff, repository policy files, regenerated PR context, local and CI coverage reports, and `gh run view` metadata for runs 38017407907 and 38022356096.

---

## Verdict

The implementation is correct against the spec design for FU-823-1, FU-823-2, FU-823-3, FU-823-5, and review notes A and B. All mirrors are byte-identical, the hook's decision rule is unchanged apart from the floor values, and behavior in this repository is unchanged because the root `CLAUDE.md` states no coverage threshold. The code review records 0 blocking findings and 9 non-blocking findings (CR-1 to CR-9 in table order).

The change is ready for normal PR flow once the bats suite passes in CI on the PR head and the policy-audit blocking item PA-1 (bash coverage measurement for `.codex/`) is decided by the maintainer. The minor items CR-1, CR-2, and CR-4 can be addressed in this PR or as follow-ups without affecting the acceptance criteria.
