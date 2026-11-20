# Code Review: Parallel planner leaves scratch worktrees (#1002)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #1002 in the branch name.
**Base Branch:** `main` (merge base `c7b2850fda58ef2c80624952e582738b76a546f4`)
**Head Branch:** `bug/parallel-planner-leaves-scratch-worktrees-1002` (`589fef537`)
**Review Type:** Initial review of the full branch diff

---

## Executive Summary

The branch removes the cause of issue #1002 at the instruction level. The planner improvised scratch worktrees because the `parallel-plan` skill required a commit to `parallel/<slug>-plan` and reads of item-branch text without giving a worktree-free technique. The skill now gives that technique: `git fetch origin main` then `git checkout -b parallel/<slug>-plan origin/main` in the planner's own session checkout (resume form `git checkout parallel/<slug>-plan`), by-ref reads with `git fetch origin <branch>` and `git show origin/<branch>:<path>`, and a **No planner worktrees.** paragraph stating the prohibition and the reason. The agent carries a pointer sentence and Completion Requirements item 8. The bundled copies are byte-identical. A 14-case contract module protects the wording.

**What changed:** two Markdown runtime files (+36 lines, -6 lines), their two bundled copies, one new Python test module (292 lines), and the feature folder.

**Top 3 risks:**
1. The prohibition is instruction-level; `Bash(git *)` still admits `git worktree add`. The contract tests prevent wording regression but cannot prevent a model from disobeying. The spec records this and rejects a hook.
2. After the plan-home checkout, the session checkout sits on `origin/main`'s copy of the tree for the remainder of the run, including `.claude/hooks/`. The ordering (after the last preparation child, before manifest authoring) and the stop-on-refusal rule mitigate this, as the `epic-plan` precedent does.
3. The live `/parallel-plan` check (no planner registration in `git worktree list --porcelain` afterwards) is a manual note, not a gate, so the behavioral outcome is unverified by automation.

**PR readiness recommendation:** **Go**. No Blocker, Major, or Minor finding; the toolchain and coverage thresholds pass (repo-wide Python 96.69% lines, 93.63% branches). Merge remains subject to the S9 CI green gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` | lines 176-201 and 228-272 | Two functions sit inside `# fmt: off` / `# fmt: on` regions and use `def \` plus a backslash continuation so that a name too long for 88 columns passes Ruff E501 without a `# noqa`. The directive is outside `.claude/rules/python-suppressions.md`, which governs `# noqa` and `# type: ignore`, and `tests/scripts/dev_tools/test_potential_to_issue.py` already uses the same directive. Black does not check the two function bodies. | No change required. If a later edit touches these bodies, format them by hand or shorten the names where the plan allows. | Compliant with the rule text; the form is unusual. Ruff exempts a single-token line, which the continuation creates, and Ruff passes. Names are fixed by the spec acceptance criteria. | Reviewer `black --check` (unchanged), `ruff check` (passed), `pyright` (0 errors); `grep` for `fmt:` over `tests` and `scripts`. |
| Info | `.claude/skills/parallel-plan/SKILL.md` | `## Artifact Home`, **Plan-home checkout.** | `git checkout -b parallel/<slug>-plan origin/main` carries uncommitted operator changes across the checkout. The spec mitigates this with the existing pathspec-bearing commit forms. | No change required. | Recorded so a future edit does not remove the pathspec requirement. | Skill text; spec `## Risks and Mitigations`. |

No Blocker, Major, or Minor finding. No covered file in the branch diff is at or above 700 lines (the new test module has 292 logical lines), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `paragraph_from_marker` raises `AssertionError` when a marker is absent, so a paragraph-scoped assertion cannot pass against an empty string.
- `test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence` compares the count of `git worktree add` with the count of the full prohibition fragment, which proves no creating instruction exists in either document and requires at least one prohibition.
- Fragments are matched on whitespace-collapsed text, so line-wrapping edits do not break the tests.
- The test reads only committed files through `parallel_orchestrator_surface_test_support`; no write, temp file, or `artifacts/` read.
- Names map one to one to the spec acceptance criteria.

#### Typing and API notes

- Pyright: 0 errors, 0 warnings, 0 informations (reviewer). All functions are annotated.

#### Error handling and logging

- Assertion messages name the document, the fragment, or the counts.

### Markdown runtime surface audit

- Skill and agent text agree: both state that the planner runs no `git worktree add` and that the plan branch is checked out in the session checkout and pushed.
- Existing wording constraints hold: no case-insensitive "pinned"; none of the forbidden fragments; the required sentences, `(P10)` text, and the three untouched sections are intact (116 of 116 passing across the ten named contract modules).
- The runtime-removal claim is stated with its qualifier: immediate removal when a child leaves no changes, otherwise the periodic sweep once commits are pushed and the tree is clean.
- Bundled copies are byte-identical (byte-identity tests pass).

### TypeScript, PowerShell, and C# implementation audit

- Not applicable; no file of those languages changed.

---

## Test Quality Audit

The reviewer ran the new module (14 passed), the ten named contract modules (116 passed), Black, Ruff, and Pyright.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py`: all 14 cases read.
- `evidence/regression-testing/expect-fail.2026-10-31T12-53.md`: 10 expected failures before the text change; the 4 passing cases (two byte-identity cases, the wording-constraint case, and the untouched-sections case) are regression guards that hold before and after, which the evidence explains.
- `evidence/regression-testing/isolation.2026-10-31T13-01.md`: reversed-order run of 136 passed; zero matches for `tmp_path`, `tempfile`, `write_text`, `write_bytes`, `artifacts/`.

### Quality assessment prompts

- **Determinism:** no clock, RNG, or process use.
- **Isolation:** no shared mutable state; module-level constants are immutable.
- **Speed:** 14 tests in 0.12 s.
- **Diagnostics:** messages name the absent fragment.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | No executable code added; the skill's git commands are inline instructions. |
| Instruction safety | PASS | The checkout rules forbid stash, force, and reset on refusal; the push uses `-u origin parallel/<slug>-plan`, not a force form. |
| No host paths in committed artifacts | PASS | Test uses repository-relative paths only. |
| Scope isolation | PASS | No hook, rule, validator, `.agents`, `.codex`, `.github`, `quality-tiers.yml`, or Run Closing change. |

---

## Research Log

No external research was required. The review relied on the branch diff, the spec, the plan, the executor's evidence, and repository policy files.

---

## Verdict

The change implements Required Behavior 1 to 4 as specified and protects it with contract tests that fail before and pass after. The `# fmt: off` regions comply with the suppression policy. The code is ready for the normal PR flow.
