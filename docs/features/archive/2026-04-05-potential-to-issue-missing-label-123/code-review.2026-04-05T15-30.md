# Code Review: potential-to-issue-missing-label (Bug #123)

**Review Timestamp:** 2026-04-05T15-30  
**Branch:** `bug/potential-to-issue-missing-label-123`  
**Base:** `development`  
**Work Mode:** `minor-audit`  
**Feature Folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Feature Folder Selection Rule:** Derived from branch name suffix `-123` matching the issue number.

---

## 1. Executive Summary

**What changed:** The `promote_potential()` function in both the root and bundled-runtime copies of `potential_to_issue.py` now detects the `could not add label: 'feature' not found` failure from `gh issue create`, calls `gh label create` to ensure the label exists, and retries the issue creation. Supporting changes extend the `GhClient` protocol with `ensure_label()` and add a `_is_missing_label_failure()` detection helper. Test coverage was expanded from 4 wrapper-level tests to 14 full-coverage tests (bundled) and from 26 to 28 tests (root).

**Top 3 risks:**

1. **Test file size (689 and 877 lines)** — The bundled test file exceeds the 500-line limit by 189 lines. Future maintenance burden increases without a split. (Minor)
2. **Dual-copy maintenance** — The root and bundled-runtime production files are parallel copies. Any future change must be applied to both. This is a pre-existing architectural pattern, not introduced by this branch. (Nit — pre-existing)
3. **Label creation is not idempotent for all edge cases** — `gh label create` fails if the label already exists with a different color/description. The recovery branch only fires when `ensure_label` returns exit_code 0 before retrying, so a conflicting label would cause the retry to be skipped and the original failure propagated. This is acceptable behavior. (Nit)

**Go/No-Go recommendation:** **Go.** The bugfix is minimal, well-tested, and all QA gates pass. The test file size gap is a minor non-blocker that should be tracked for follow-up.

---

## 2. Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Minor | `tests/extensions/.../test_potential_to_issue.py` | File-level | File is 689 lines (limit: 500). Grew from 123 to 689 on this branch. | Split into `test_potential_to_issue_wrapper.py` (wrapper import tests) and `test_potential_to_issue_runtime.py` (bundled-runtime tests). | General code change policy §4: "Do not exceed 500 lines for any one file." | `wc -l` returns 689 lines. |
| Minor | `tests/scripts/.../test_potential_to_issue.py` | File-level | File is 877 lines (limit: 500). Was 784 lines on `development` (pre-existing). | Track for follow-up refactor. Not attributable solely to this branch (+93 lines). | Same policy. Pre-existing violation. | `git show development:<file> | wc -l` returns 784. |
| Nit | `extensions/.../potential_to_issue.py` | Lines 201-205 | `_is_missing_label_failure` uses `.lower()` on each line but the expected fragment is already lowercase. This is correct defensive coding against case differences in gh output. | No change required. Defensive lowering is appropriate. | gh CLI output casing is not guaranteed across versions. | Code inspection. |
| Nit | `extensions/.../potential_to_issue.py` | Lines 121-131 | `ensure_label` method in bundled runtime lacks a docstring (root copy has one). | Add a one-line docstring for consistency. | Self-explanatory code commenting policy requires docstrings on all methods. | Diff comparison between root and bundled. |

---

## 3. Typed Python Audit

| Check | Status | Evidence |
|-------|--------|---------|
| No new `Any` | ✅ PASS | No `Any` usage anywhere in changed code. All parameters and returns fully typed. |
| No type-check weakening | ✅ PASS | No `# type: ignore` added. No Pyright config changes. No rule suppressions. |
| Precise types used | ✅ PASS | `list[str]`, `str`, `bool`, `int`, `Path`, `GhResult`, `PromotionOutcome`. Protocol-based `GhClient` and `FileSystem`. |
| Protocol/TypedDict/dataclass usage | ✅ PASS | `GhClient(Protocol)` extended with `ensure_label`. `GhResult` and `RealGhClient` are `@dataclass`. |
| Error handling typed | ✅ PASS | `PromotionError(Exception)` for domain errors. `FileNotFoundError` for missing gh. `RuntimeError` for unresolved path. No naked `except`. |
| Logging | ✅ PASS | `emit` callback pattern used. No raw `print` in production logic except in `_default` fallback emitter. |
| Public API clarity | ✅ PASS | `ensure_label` added to `GhClient` protocol (public contract). `_is_missing_label_failure` underscore-prefixed (internal). |

---

## 4. Test Quality Audit

| Check | Status | Evidence |
|-------|--------|---------|
| Deterministic | ✅ PASS | All tests use deterministic fakes. No randomness, timing, or external state. |
| Isolated | ✅ PASS | Each test creates its own fakes and cleans up module imports in `finally`. |
| Fast | ✅ PASS | 42 tests in 0.13s. 14 bundled tests in 0.58s (with coverage). |
| Good failure messages | ✅ PASS | Direct assertions (`assert outcome.exit_code == 0`) produce clear pytest diffs. Fail-before evidence shows readable assertion failure. |
| Coverage expectations | ✅ PASS | Bundled: 95%. Root: 90%. Both meet ≥90% for new code. |

---

## 5. Security / Correctness Checks

| Check | Status | Evidence |
|-------|--------|---------|
| No secrets in code | ✅ PASS | No credentials, tokens, or API keys. `FEATURE_LABEL_COLOR` is a hex color code. |
| No unsafe subprocess usage | ✅ PASS | `subprocess.run` uses `shutil.which()` validated path. Two pre-authorized `# noqa: S603` suppressions with correct comment format. `check=False` used (no unchecked shell execution). |
| Input validation at boundaries | ✅ PASS | `promotion_type` validated against `PROMOTION_TYPES`. `work_mode` validated against `WORK_MODES`. `GhClient` authentication checked. File existence and non-emptiness verified. |

---

## 6. Research Log

No external research was required for this review. All findings are based on code inspection, stored evidence artifacts, and live toolchain execution.
