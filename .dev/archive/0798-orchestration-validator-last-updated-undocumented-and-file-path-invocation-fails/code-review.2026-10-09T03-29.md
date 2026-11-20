# Code Review: Issue #798 - orchestration validator required keys and dispatcher file-path invocation

- **Branch:** `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798` @ `ee7d144d96dd7a18acfdc62a2298c6537c7dda74`
- **Base:** `origin/main` @ `e7d3779b398604af919678c16c877c8539a86cc0` (merge base)
- **Scope:** full branch diff, 63 files (+2889/-10). Code: 1 modified production file, 2 new test modules. Runtime docs: 3 `.claude/` files and 3 bundle mirrors. Remainder: feature-folder documentation and evidence.
- **Review date:** 2026-10-09
- **Primary evidence:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-10-09 07:25 UTC at head `ee7d144d`; current).

## Executive Summary

The change is small and targeted. The production change is one statement in `scripts/dev_tools/validate_orchestration_artifacts.py`:

```python
# File-path invocation has no package context; make the repo root importable.
sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
```

It is inert under `-m` and normal import (`__package__ == "scripts.dev_tools"`), and appends the repository root under `python <file>` and `runpy.run_path`. Black, Ruff, and Pyright report zero findings on the three changed Python files (reviewer rerun). The two new test modules are well isolated: they run the dispatcher in process with `runpy`, rebind and restore `sys.path`, evict and restore `scripts.*` modules, and use no subprocess or temporary file. The documentation-parity tests import `REQUIRED_STATE_KEYS` from the authority and check both set directions, with a negative control.

Documentation edits are confined to the sections named in the spec. The rule, skill, and agent persona now state the 22 required keys and the `last_updated` contract, and each mirror is byte-identical.

No code-quality blocker was found. One Medium item concerns behavior in the shared environment this repository is known to use: the appended root is shadowed by an editable-install entry naming another checkout, so a plain file-path run imports another worktree's modules while the new rule text states that the two forms are identical. The plan records this residual (PD8) and assigns a follow-up that has not been filed. The blocking policy item for this branch (absent coverage artifact) is recorded in the policy audit as PA-1 and is not a code defect.

Typed-Python review: annotations are complete; `from __future__ import annotations` and `TYPE_CHECKING` imports are used correctly; no `Any`, no `cast`, no suppressions.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (policy, not code) | `artifacts/python/lcov.info` | n/a | The canonical Python coverage artifact is absent at review time (policy audit PA-1). Recorded coverage values meet thresholds. | Re-run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` in the worktree; record a new `evidence/qa-gates/` file with the values. | The review contract requires the artifact for every language with changed files. | `ls artifacts/` shows no `python/` directory; `evidence/qa-gates/pytest-full-coverage.2026-10-09T03-10.md` |
| Medium (CR-2) | `scripts/dev_tools/validate_orchestration_artifacts.py`; `.claude/rules/orchestrator-state.md` (+ mirror) | dispatcher line 17; rule `## Bare-Module CLI Contract` | The bootstrap appends the repo root after site-packages. In the shared Poetry environment, an editable-install `.pth` entry resolves `scripts` to another worktree, so `python scripts/dev_tools/validate_orchestration_artifacts.py ...` (without `-S`) runs this worktree's `main()` against another checkout's `scripts.dev_tools.*` validators. The new rule text states that both forms "reach the same `main()`, so their flags, output lines, and exit codes are identical", which does not hold in that environment. | Non-blocking for this issue. File the follow-up that plan PD8 assigns to the orchestrator (candidate remedies: per-worktree virtual environment, or prepend with an `if` block and an approved E402 per-file ignore). Optionally add one sentence to the rule noting that an installed `scripts` distribution on `sys.path` takes precedence in the file-path form. | Silent execution of a different checkout's validator code can produce a pass or fail that does not reflect the local tree. The spec chose append deliberately (D5, PD8), and all ACs are met. | Reviewer probe `poetry run python -I -c "...find_spec('scripts')..."` -> `ORIGIN_CLASS FOREIGN`; `evidence/baseline/scripts-package-origin.2026-10-09T02-59.md`; plan line 80 (PD8); `gh issue list --search` returned no follow-up |
| Low (CR-3) | `scripts/dev_tools/validate_orchestration_artifacts.py` | line 17 | The bootstrap uses a conditional expression for its side effect (`sys.path += [...] if not __package__ else []`). This is less readable than an `if` block. The form was selected because Ruff's E402 exemption covers this statement shape and not an `if` block, which avoids a suppression. The comment states why the bootstrap exists but not why this shape was chosen. | Optional: extend the comment with the E402 reason (for example, "single statement keeps Ruff's E402 sys.path exemption"). The file is at 498 of 500 lines, so a second comment line is still within the limit. | A future editor may convert it to an `if` block and reintroduce E402. | `poetry run ruff check` -> All checks passed; spec D5 line 103; `wc -l` -> 498 |
| Low (CR-4) | `docs/features/active/2026-09-30-...-798/issue.md` | line 5 | The `Status:` line points to `docs/features/active/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails/`, which lacks the date prefix and `-798` suffix of the actual folder. | Optional: correct the path to the actual folder name. | Stale cross-reference; documentation accuracy only. | `issue.md` line 5 |
| Info (CR-5) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` | lines 70-77, 98-115 | `isolated_import_state` also drops any `sys.path` entry that can supply a regular `scripts` package. This makes the fail-before/pass-after result independent of the foreign editable-install entry, which is correct for a unit test, but it also means the test suite does not exercise the CR-2 environment. | No change required. If the CR-2 follow-up changes to prepend, add a test that keeps a foreign-`scripts` entry on `sys.path` and asserts the local package wins. | Test isolation is correct; this records the boundary of what it proves. | Test module docstring lines 11-17 |
| Info (CR-6) | `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` | `section()` lines 57-72 | Section extraction stops at the next line starting with `## `. A `## ` line inside a fenced code block in a target section would truncate the section. None of the target sections contain fenced blocks today. | No change required. | Robustness note only. | Reviewer inspection of the rule, skill, and agent sections |
| Info (CR-7) | `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md` | skill lines 37, 271; rule lines 35-65, 204 | Edits are confined to `## Checkpoint Handling`, `## Issue Number Consistency`, `## Required Top-Level Keys` (new), and `## Bare-Module CLI Contract`. `## Step S9 - CI Green Gate` and the issue_adoption sections are unchanged. The skill contains no `python -m scripts.` or `python scripts/` text. | None. | Confirms coordination constraints with concurrent issues #841 and #849. | `evidence/qa-gates/scope-check.2026-10-09T03-12.md`; reviewer diff read; `test_every_skill_script_reference_is_bundled` passes |
| Info (CR-8) | `.claude/agents/orchestrator.md` | lines 175-180 | The persona list now names all 22 keys with each step-status key written out, and points to the rule section as the authority. Existing receipt bullets are retained. | None. | Removes the second source of incomplete checkpoints. | `test_orchestrator_agent_checkpoint_persistence_lists_required_keys` (22 cases) passes |

## Positive Observations

- Fail-before evidence is concrete: 3 of 4 invocation tests failed with `ModuleNotFoundError` on the unmodified dispatcher, and the `-m` control passed (`evidence/regression-testing/expect-fail-invocation.2026-10-09T03-03.md`).
- `test_file_path_invocation_validates_committed_fixture` compares stdout and stderr in addition to the exit code, which is stronger than the AC requires.
- `test_file_path_bootstrap_appends_repo_root_once` asserts both count and position, pinning the append decision.
- The parity test is parametrized over the authority tuple, so a key added to `REQUIRED_STATE_KEYS` without documentation fails the suite.

## Verification Performed by Reviewer

| Check | Command | Result |
|---|---|---|
| Format | `poetry run black --check <3 files>` | 3 files unchanged |
| Lint | `poetry run ruff check <3 files>` | All checks passed |
| Types | `poetry run pyright <3 files>` | 0 errors, 0 warnings, 0 informations |
| Tests | `poetry run pytest -q -p no:cacheprovider <9 modules>` | 182 passed in 1.38s |
| File-path form | `poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` | exit 0, success line printed |
| Whitespace | `git diff --check e7d3779b HEAD` | exit 0 |
| Protected paths | `git diff --name-only e7d3779b HEAD -- scripts/dev_tools/validate_orchestrator_state.py extensions/drm-copilot/src .claude/lib .claude/hooks pyproject.toml` | no paths |
| File sizes | `wc -l` | 498 / 203 / 253 |

## Verdict

No code-level blocker. The branch requires remediation only for the policy item PA-1 (coverage artifact retention). CR-2 is recommended as a tracked follow-up; CR-3 and CR-4 are optional.
