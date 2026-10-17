# Code Review: quality-tiers.yml classification and tier-classification gate (#734)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #734 in the branch name.
**Base Branch:** `origin/main` (merge base `b080a69ecb60b65d016362b21fffed0a34be9144`; `origin/main` tip `71f8dcb49d8ce5d1402ff441855a64be15b37f29`)
**Head Branch:** `bug/quality-tiers-yml-missing-and-unenforced-734` @ `bd731f4eb4d489fbfd25cae4111303dc7f41340c`
**Review Type:** Initial feature review.

---

## Executive Summary

The full branch diff against the merge base was reviewed: two new Python modules, two new test files, the root `quality-tiers.yml`, one workflow step, four one-line citation corrections, and feature documentation and evidence. Evidence reviewed: the regenerated PR context pair (`artifacts/pr_context.summary.txt` / `.appendix.txt`, generated 2026-10-02 07:53 UTC, `Head SHA: bd731f4e`), the feature `evidence/` tree, the existing coverage artifacts, CI run 36980560291, and reviewer re-runs of Black, Ruff, Pyright, targeted Pytest, the CLI, and the evidence-location validator.

The implementation matches the spec's normative interface (names, failure codes, exit codes, discovery rules R1-R5, fail-closed QT009). No blocking finding was identified.

**Top 3 risks (residual):**
1. CR-2: three defensive branches in the core are untested, including the `version: true` rejection that relies on `type(version) is not int`.
2. CR-3: `test_quality_tiers_contract.py` is at 495 of 500 lines, so CR-1 and CR-2 cannot be addressed in that file without a split.
3. CR-4: QT009 messages carry only git's exit code; git's stderr is captured and discarded, which slows diagnosis of a CI failure.

**PR readiness recommendation:** **Ready**, after updating the branch from `origin/main` (CR-9) and confirming CI on the updated head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_quality_tiers_contract.py` | line 434 | CR-1 (plan deviation D3). `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` has no `-> None`. D3 says the plan-mandated name cannot fit 88 columns with the annotation. Verified: Black 26.1.0 renders `def <name>() -> (\n    None\n):`, whose first line is 92 characters (Ruff E501). A compliant alternative exists: the name is plan-mandated only, not spec-mandated, so a shorter name (e.g. `test_find_classification_errors_empty_projects_yield_qt007_per_entry`) fits with the annotation. | Rename and annotate when the file is next edited (together with the CR-3 split). | `.claude/rules/python.md` requires full annotations. Non-blocking because Pyright strict infers `None`, Ruff `ANN` is not enabled, and unannotated tests are established precedent (e.g. `test_collect_pr_context.py` lines 137-174). Recorded as PA-1 in the policy audit. | Black probe (scratchpad); `awk 'NR==434{print length}'` = 86 |
| Minor | `scripts/dev_tools/quality_tiers_contract.py` | lines 124, 155, 199 | CR-2. Uncovered: non-scalar mapping key skip (124); non-integer `version` such as `"1"` or `true` (155); missing top-level `projects` key (199). The `type(version) is not int` check deliberately rejects `bool`, which is a correctness detail with no test. | Add QT003 matrix cases `version-not-integer` (`version: "1"`), `version-bool` (`version: true`), and `missing-projects`; optionally a complex-key case for 124. | `general-unit-test.md` Scenario Completeness (negative flows). Coverage thresholds are still met (98.43% / 96.15%). | `artifacts/python/coverage.json` `missing_lines` [124, 155, 199] |
| Minor | `tests/scripts/dev_tools/test_quality_tiers_contract.py` | whole file | CR-3. 495 lines; the D5 restart already trimmed it from 508. | Split the committed-tree tests (`SPEC_TIER_ASSIGNMENTS` and the two `test_committed_*` tests, ~70 lines) into `tests/scripts/dev_tools/test_quality_tiers_committed_tree.py` before the next edit. | 500-line limit in `general-code-change.md`; zero practical headroom. | `wc -l` |
| Info | `scripts/dev_tools/check_quality_tiers.py` | lines 90-94 | CR-4. `capture_output=True` captures git stderr, but the `OSError` message contains only the exit code (`git ls-files exited with code 128`). | Include a decoded, trimmed `result.stderr` in the message (extend `GitRunResult` with `stderr`). | Faster diagnosis of QT009 in CI; behavior stays fail-closed. | Code read |
| Info | `scripts/dev_tools/check_quality_tiers.py` | lines 124-129 | CR-5. `main` keyword parameters `read_manifest_text` and `list_tracked_files` shadow the module-level functions of the same names. Defaults bind at definition time, so behavior is correct. | Optional: rename the parameters (e.g. `manifest_reader`, `tracked_lister`). | Readability. | Code read |
| Info | `scripts/dev_tools/check_quality_tiers.py` | line 91 | CR-6. `git ls-files` runs with `cwd=repo_root`; if `--repo-root` names a subdirectory, git returns paths relative to that subdirectory and discovery would diverge from the repository-relative manifest. CI and the default use the repository root. | Optional: document that `--repo-root` must be the repository top level, or resolve it with `git rev-parse --show-toplevel`. | Edge case outside the CI path. | Code read |
| Info | `scripts/dev_tools/quality_tiers_contract.py` | lines 63-79, 307-311 | CR-7. Exclusion also drops any path with a `node_modules` segment at any depth, a superset of the spec's `node_modules/` prefix. | None. | Untracked in practice; a nested tracked `node_modules` manifest should not be a project. | Code read |
| Info | `scripts/dev_tools/quality_tiers_contract.py` | lines 137-139 | CR-8. `_UniqueKeySafeLoader(text).get_single_data()` does not call `dispose()` (removed under D3 because of a Pyright `reportUnknownMemberType`). | None. | `dispose()` only clears loader state; the loader is discarded immediately. | Plan D3 |
| Info | branch | — | CR-9. `origin/main` advanced to `71f8dcb4` (PR #817) after the merge base. `git merge-tree --write-tree origin/main HEAD` exits 0, and no file added on main since `b080a69e` matches a discovery rule (`package.json`, `*.csproj`, `*.psd1`, `.claude/lib/*`, hook roots, `scripts/<name>/<code>`). | Update the branch from `origin/main` before opening the PR and confirm CI on the new head. | `tier-classification` is expected to stay green; the update is required by the PR process, not by a defect. | `git log b080a69e..origin/main`; `git diff --name-only --diff-filter=A b080a69e origin/main` |

Blocking findings: none.

---

## Implementation Audit

### Python implementation audit

**Spec conformance (normative interface).**
- `QualityTierEntry`, `QualityTierManifest`, `QualityTierError` are frozen dataclasses with the specified fields; `render()` yields `QTnnn: <message>`.
- `parse_quality_tiers(text)` returns `(None, [QT002])` for invalid YAML, duplicate keys (loader subclass raises `ConstructorError`, a `YAMLError`), or a non-mapping root; otherwise a manifest plus accumulated QT003 errors. Unknown top-level keys, missing/invalid `version`, non-list/empty `projects`, non-mapping entries, missing/unknown entry keys, and non-string/empty values are all QT003.
- `discover_projects(tracked_paths)` returns a `frozenset`. `find_classification_errors` returns QT004-QT008. A separate public `find_entry_errors` (QT004-QT006) is added so the CLI can still report entry errors when git fails; this is an additive public name, consistent with the spec allowance for keyword-only additions in spirit and not a contract break.
- One module-level constant `DISCOVERY_RULES` holds all roots and exclusions.
- CLI: `main(argv=None, *, read_manifest_text=..., list_tracked_files=...) -> int`; `--file` and `--repo-root` defaults match the spec; git resolved via `shutil.which`; exit codes 0/1/2.

**Discovery rule correctness (R1-R5).**
- Exclusions applied first (`_is_excluded`) to every tracked path; R2's sibling lookup uses the post-exclusion set, so an excluded `.psm1` cannot qualify a `.psd1`.
- R1: basename `package.json` or suffix `.csproj` -> parent folder, `.` for root.
- R2: `<stem>.psd1` with tracked `<stem>.psm1` (same folder, same stem) -> parent folder. Settings `.psd1` files do not qualify.
- R3: exactly three path parts `scripts/<name>/<file>` with suffix `.py`, `.ps1`, `.psm1`, or `.sh` -> `scripts/<name>`. Deeper files do not qualify, matching "directly contains".
- R4: more than three parts under `.claude/lib/` -> `.claude/lib/<name>`. A file directly in `.claude/lib/` (e.g. `README.md`) does not create a project; tested.
- R5: any tracked file under `.claude/hooks/` or `.codex/hooks/` -> the hook root.
- Nested projects (`scripts/powershell` and `scripts/powershell/PoshQC`) are both discovered; tested.
- Live check: the CLI reports `24 entries, 24 discovered projects`, and `evidence/other/discovery-differences.2026-10-02T03-18.md` records no difference from the spec table.

**Fail-closed QT009.**
- `which("git")` returning `None` raises `FileNotFoundError` (an `OSError`) -> QT009 without invoking the runner (tested with a runner that fails the test if called).
- Non-zero git exit raises `OSError` -> QT009 (tested with return code 128).
- Any `OSError` from the injected lister -> QT009 (tested).
- An empty tracked list cannot pass: every manifest entry yields QT007 (tested). The manifest schema also requires a non-empty `projects` list, so an empty manifest with an empty tracked set cannot pass either.
- On QT009 the CLI still reports QT003 and QT004-QT006 errors (tested), and exits 1.

**Core purity.** `git grep` over the core for `os`, `subprocess`, `shutil`, `pathlib`, `sys` imports and `open(`, `print(`, `read_text`, `write_text`: no match. Only `posixpath` (pure string functions), `re`, `dataclasses`, `typing`, and `yaml` are imported.

**Suppressions and typing.** One `# noqa: S603` in the exact pre-authorized form; no `type: ignore`; one commented `Any` on the PyYAML override signature; two `cast` calls narrow `dict`/`list` after `isinstance` checks.

**Python 3.10.** `from __future__ import annotations` in all four files; `X | None` unions are 3.10-native anyway; no 3.11+ API found by reviewer scan; the CI 3.10 leg passed every step.

### GitHub Actions audit

- One step added at lines 74-77 of `.github/workflows/_quality-checks.yml`, after "Verify Codex agent deployment profiles" and before "Run tests with Pytest", with `continue-on-error: false`. Job name, matrix, triggers, and other steps are unchanged.
- CI run 36980560291 (`workflow_dispatch`, head `bd731f4e`): conclusion `success`; `tier-classification` `success` on 3.10, 3.11, 3.12, and 3.13.

### Policy-document mirror audit

- Four files, one changed line each, exact spec text. Repository and bundled copies resolve to identical blobs (`ab45b338` for the Claude rule pair, `f988f2f4` for the agents-skill pair). Bundled-payload parity tests and the frontmatter test pass.
- `git grep "ci\.research\.md" -- ':!docs'` returns only `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1:249` (fixture string), as AC-14 requires.

---

## Test Quality Audit

Reviewer runs at head `bd731f4e`: `pytest --collect-only` on the two new files collects 61 cases (47 core, 14 CLI); the targeted run with parity and frontmatter tests passes 92/92 in 0.47 s. Coverage from `artifacts/python/coverage.json` (03:43, after the last code commit at 03:41): core 98.43% lines / 96.15% branches; CLI 100.00% / 91.67%; repository 93.61% / 86.89% (baseline 93.53% / 86.76%).

### Reviewed test and QA artifacts

- `evidence/regression-testing/expect-fail-new-tests.2026-10-02T03-18.md` — new tests failed before implementation.
- `evidence/regression-testing/manual-qt008-check.2026-10-02T03-18.md` and `manual-qt008-restore.2026-10-02T03-18.md` — manual negative check (exit 1, one QT008 line naming `scripts/bash`) and restore.
- `evidence/qa-gates/final-*.2026-10-02T03-41.md` — pass 2 of the final QA loop after the D5 restart.
- `evidence/qa-gates/final-test-hermeticity.2026-10-02T03-41.md` — expected-no-match search for temp files and processes.
- `evidence/qa-gates/ci-run-quality-checks.2026-10-02T03-55.md` — CI run record written by this review.

### Quality assessment prompts

- **Hermeticity:** no `tmp_path`, `tempfile`, or `subprocess` in either test file (reviewer `git grep`, exit 1). The default-reader test uses the in-memory `mem_fs_path` fixture. The committed-tree tests are read-only and spec-authorized.
- **Determinism:** no clock, randomness, network, or timing.
- **Isolation:** one QT code or boundary per test; parametrized matrices for QT003, QT004, QT006, exclusions, and hook roots.
- **Diagnostics:** most assertions carry messages naming the offending path or codes.
- **Fail-before evidence:** recorded for the new tests and for the manual QT008 check.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | Fixed argv list `[git, "ls-files", "-z"]`, git resolved by `shutil.which`, no shell, `check=False` with explicit return-code handling. |
| Input validation at boundaries | ✅ PASS | `yaml.SafeLoader` subclass (no arbitrary object construction); strict schema; path-form checks (absolute, drive letter, backslash, trailing slash, empty/`.`/`..` segments). |
| Error handling remains explicit | ✅ PASS | Only `yaml.YAMLError` and boundary `OSError` are caught. |
| Configuration / path handling is safe | ✅ PASS | NUL-separated git output decoded with `surrogateescape`; manifest path resolved relative to `--repo-root` unless absolute. |

---

## Research Log

No external research was required. Black's return-annotation wrapping behavior was confirmed by a local Black 26.1.0 probe in the session scratchpad (used to evaluate D3).

---

## Verdict

The implementation conforms to the spec and the repository policies, with no blocking findings. CR-1 (PA-1) through CR-3 are minor and can be addressed together in a later edit of the contract test file. CR-4 through CR-8 are informational. Update the branch from `origin/main` (CR-9) and confirm CI on the updated head before merge.
