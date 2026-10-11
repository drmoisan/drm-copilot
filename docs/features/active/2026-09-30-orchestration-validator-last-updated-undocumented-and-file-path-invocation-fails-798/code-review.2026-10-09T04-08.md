# Code Review: Issue #798 - orchestration validator required keys and dispatcher file-path invocation (Re-audit R4, remediation cycle 1)

- **Branch:** `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798` @ `bb5f5f283707067cd4c9098abbb795c4a04d16fe`
- **Base:** `origin/main` @ `e7d3779b398604af919678c16c877c8539a86cc0` (merge base; remote `main` has not advanced)
- **Scope:** full branch diff, 81 files (+3808/-10). Code: 1 modified production file, 2 new test modules. Runtime docs: 3 `.claude/` files and 3 bundle mirrors. Remainder: feature-folder documentation and evidence.
- **Review date:** 2026-10-09
- **Prior pass:** `code-review.2026-10-09T03-29.md` at `ee7d144d`.
- **Primary evidence:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-10-09 08:06 UTC at head `bb5f5f28`; current).

## Executive Summary

No code, test, or runtime-document file changed between the prior review head `ee7d144d` and HEAD `bb5f5f28`; `git diff --name-only ee7d144d HEAD` lists only feature-folder paths (prior review artifacts, the cycle 1 remediation plan, and coverage evidence). The code-quality assessment from the prior pass therefore stands, and the reviewer re-ran the check-only toolchain at HEAD to confirm it.

The production change remains one statement in `scripts/dev_tools/validate_orchestration_artifacts.py`:

```python
# File-path invocation has no package context; make the repo root importable.
sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
```

It is inert under `-m` and normal import, and appends the repository root under `python <file>` and `runpy.run_path`. Black, Ruff, and Pyright report zero findings on the three changed Python files. The new test modules isolate import state, use no subprocess or temporary file, and restore `sys.path` and module objects.

The prior blocking item (coverage artifact absent, a policy item rather than a code defect) is resolved: `artifacts/python/lcov.info` is present and the dispatcher reports 97.99% lines and 92.86% branches, with the changed line covered.

No code-quality blocker was found. CR-2 (Medium, non-blocking) carries forward unchanged: the PD8 follow-up has not been filed. CR-3 and CR-4 (Low, optional) are unchanged.

Typed-Python review: annotations are complete; `from __future__ import annotations` and `TYPE_CHECKING` imports are used correctly; no `Any`, no `cast`, no suppressions.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (prior Blocking, policy) | `artifacts/python/lcov.info` | n/a | The canonical Python coverage artifact is now present (496729 bytes, generated 2026-10-09 04:00, after the last code commit at 03:05). Dispatcher 146/149 lines, 52/56 branches; line 17 hit count 1. | None. | PA-1 closed. | Reviewer lcov parse; `evidence/qa-gates/lcov-artifact-final.2026-10-09T04-00.md`; `evidence/qa-gates/python-coverage-values-r1.2026-10-09T03-58.md` |
| Medium (CR-2, carried forward) | `scripts/dev_tools/validate_orchestration_artifacts.py`; `.claude/rules/orchestrator-state.md` (+ mirror) | dispatcher line 17; rule `## Bare-Module CLI Contract` | The bootstrap appends the repo root after site-packages. In the shared Poetry environment an editable-install `.pth` entry resolves `scripts` to another worktree, so a plain `python scripts/dev_tools/validate_orchestration_artifacts.py ...` (without `-S`) can import another checkout's `scripts.dev_tools.*` modules, while the rule states the two forms are identical. | Non-blocking for this issue. The orchestrator should file the follow-up that plan PD8 assigns (candidate remedies: per-worktree virtual environment, or prepend with an `if` block and an approved E402 per-file ignore). | Silent execution of a different checkout's validator code can produce a result that does not reflect the local tree. The spec chose append deliberately (D5, PD8); all ACs are met. | Prior-pass probe `ORIGIN_CLASS FOREIGN`; `evidence/baseline/scripts-package-origin.2026-10-09T02-59.md`; reviewer grep of `docs/features/potential/` for `editable` / `foreign ... scripts`: no match |
| Low (CR-3, unchanged) | `scripts/dev_tools/validate_orchestration_artifacts.py` | line 17 | The bootstrap uses a conditional expression for its side effect. The comment states why the bootstrap exists but not why this shape was chosen (Ruff E402 exempts this statement shape). | Optional: extend the comment with the E402 reason. The file is at 498 of 500 lines. | A future editor may convert it to an `if` block and reintroduce E402. | `poetry run ruff check` -> All checks passed; `wc -l` -> 498 |
| Low (CR-4, unchanged) | `docs/features/active/2026-09-30-...-798/issue.md` | line 5 | The `Status:` line points to `docs/features/active/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails/`, which lacks the date prefix and `-798` suffix of the actual folder. | Optional: correct the path. | Stale cross-reference; documentation accuracy only. | `issue.md` line 5 |
| Info (CR-5) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` | `isolated_import_state` | The isolation fixture drops `sys.path` entries that can supply a `scripts` package, so the suite does not exercise the CR-2 environment. | No change required. If CR-2 is addressed by prepending, add a test that keeps a foreign-`scripts` entry and asserts the local package wins. | Records the boundary of what the tests prove. | Test module docstring |
| Info (CR-6) | `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` | `section()` | Section extraction stops at the next `## ` line; a `## ` line inside a fenced block in a target section would truncate it. No target section contains a fenced block today. | No change required. | Robustness note only. | Reviewer inspection |
| Info (CR-7) | `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md` | skill `## Checkpoint Handling`, `## Issue Number Consistency`; rule `## Required Top-Level Keys`, `## Bare-Module CLI Contract` | Edits remain confined to the named sections; `## Step S9 - CI Green Gate` and the issue_adoption sections are untouched. The skill contains no `python -m scripts.` or `python scripts/` text. | None. | Confirms coordination constraints with concurrent issues #841 and #849. | Reviewer `git diff e7d3779b HEAD` of both files; `test_every_skill_script_reference_is_bundled` passes |
| Info (CR-8) | `.claude/agents/orchestrator.md` and three mirrors | `## Checkpoint Persistence` | The persona names all 22 keys individually and points to the rule section. All three amended files are byte-identical to their bundle mirrors. | None. | Removes the second source of incomplete checkpoints. | `cmp` x3 -> identical; persona parametrized test (22 cases) passes |

## Positive Observations

- The remediation cycle changed evidence only, as the remediation inputs required; no production, test, or runtime-document file was touched.
- The coverage re-run wrote both the lcov and JSON reports explicitly on the command line rather than relying on `addopts`, and recorded artifact size after the final run.
- Fail-before evidence remains concrete: the invocation tests failed with `ModuleNotFoundError` on the unmodified dispatcher while the `-m` control passed.
- The parity test is parametrized over the authority tuple, so a key added to `REQUIRED_STATE_KEYS` without documentation fails the suite.

## Verification Performed by Reviewer

| Check | Command | Result |
|---|---|---|
| Change since prior pass | `git diff --name-only ee7d144d HEAD` | feature-folder paths only |
| Format | `poetry run black --check <3 files>` | 3 files unchanged |
| Lint | `poetry run ruff check <3 files>` | All checks passed |
| Types | `poetry run pyright <3 files>` | 0 errors, 0 warnings, 0 informations |
| Tests | `poetry run pytest -q -p no:cacheprovider --no-cov <9 modules>` | 182 passed in 0.99s |
| File-path form | `poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state <fixture>` | exit 0, success line printed |
| Module form | `poetry run python -S -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <fixture>` | exit 0, identical success line |
| Coverage artifact | reviewer lcov parse of `artifacts/python/lcov.info` | dispatcher 97.99% / 92.86%; repo-wide 93.68% / 87.11% |
| Mirrors | `cmp` x3 | identical |
| Whitespace | `git diff --check e7d3779b HEAD` | no output |
| Protected paths | `git diff --name-only e7d3779b HEAD -- scripts/dev_tools/validate_orchestrator_state.py extensions/drm-copilot/src .claude/lib .claude/hooks pyproject.toml artifacts` | no paths |
| File sizes | `wc -l` | 498 / 203 / 253 |

## Verdict

No code-level blocker and no remaining policy blocker. The branch is ready for the orchestrator-owned PR step. CR-2 is recommended as a tracked follow-up; CR-3 and CR-4 are optional.
