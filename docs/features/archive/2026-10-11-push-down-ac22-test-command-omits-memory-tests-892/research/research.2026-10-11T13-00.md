# Research: #790 spec AC-22 test command omits memory tests (issue #892)

Date: 2026-10-11. Work mode: minor-audit. Documentation-only bug.
Target: `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` (referred to below as "the spec").
All findings were verified by reading files or running Grep in this worktree.

## 1. Current text of the bullet and AC-22

Python toolchain bullet: spec.md line 196, a single physical line (the Read tool returned it as one numbered line, 196). It is a sub-bullet of "- Toolchain commands:" (line 195). Full text:

```
  - Python (repository root): `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; architecture-boundary stage N/A (no Python boundary tool configured); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing` (dotted `--cov=` form); wider pass `poetry run pytest tests/scripts/dev_tools -k push_down`; contract stage N/A; integration covered by the hermetic push-down suites.
```

The line is long, and the Grep tool reports it as "[Omitted long matching line]". Any later verification must therefore use a short, single-token pattern (for example the two new file names) rather than a pattern spanning the command. The pytest portion is one unbroken run of text with no embedded newlines, so a single-line grep for the new file names will work. Pattern-matching of the full command is fragile.

AC-22: spec.md line 223, status `[x]`. Text:

```
- [x] AC-22 Python coverage for `scripts.dev_tools.push_down_claude_gitignore_merge`, `scripts.dev_tools.push_down_claude_filesystem`, `scripts.dev_tools.push_down_claude_customizations`, and `scripts.dev_tools.push_down_claude_pack_selection` is at least 85% line and at least 75% branch, with no coverage regression on changed lines against the baseline. Verified by the Test Strategy pytest command, with baseline and post-change reports under `<FEATURE>/evidence/baselines/` and `<FEATURE>/evidence/coverage/`.
```

Related lines: spec.md:194 (Coverage bullet naming the same modules); spec.md:225 (AC-24 refers to "the Test Strategy pytest command" and the wider `-k push_down` pass).

## 2. The two omitted test files

Both exist under `tests/scripts/dev_tools/`.

| File | Line count (Grep `^` count) |
|---|---|
| `test_push_down_claude_memory_scope.py` | 288 |
| `test_push_down_claude_pack_memory_modes.py` | 180 |

Module usage (both exercise only `push_down_claude_customizations`; neither references `gitignore_merge`, `filesystem`, or `pack_selection` by name):

- `test_push_down_claude_memory_scope.py:66-69`: `_load_module()` returns `importlib.import_module("scripts.dev_tools.push_down_claude_customizations")` (import at line 69). Called from tests at lines 75, 84, 93, 102, 111, 120 and later.
- `test_push_down_claude_pack_memory_modes.py:4`: docstring names `scripts.dev_tools.push_down_claude_customizations.push_down_customizations`. `_entry_module()` at lines 68-70 imports the module (line 70). Calls to `module.push_down_customizations(` at lines 99, 122 and later.

Because `push_down_customizations` is the entry point, these tests also run code paths in the delegated modules (filesystem, pack selection) indirectly; the direct-reference evidence above is limited to the customizations module.

## 3. Other test files importing any of the four modules and not in the command

Command currently contains: `test_push_down_claude_customizations`, `_gitignore_merge`, `_gitignore_delivery`, `_parity`, `_pack_selection`, `_pack_end_to_end`, `_exclusion_filter`.

Files under `tests/` that reference any of the four modules and are not in the command (Grep for `push_down_claude_(gitignore_merge|filesystem|customizations|pack_selection)`):

- Named by the issue (in scope): `test_push_down_claude_memory_scope.py:69`, `test_push_down_claude_pack_memory_modes.py:70`.
- Additional files, outside the issue scope (observation only):
  - `test_push_down_claude_blast_radius_overlay.py:32` (imports from the customizations test), `:125` (import_module of customizations)
  - `test_push_down_claude_destination_writes.py:51` (source path string), `:369` (import_module of customizations)
  - `test_push_down_claude_gitignore_parity.py:57` (import_module of gitignore_merge)
  - `test_push_down_claude_config_carriage.py:74` (import_module of customizations)
  - `test_push_down_claude_overlay_parity.py:23` (`from scripts.dev_tools.push_down_claude_customizations import EXCLUDED_RELATIVE_PATHS`)
  - `test_push_down_claude_resource_contracts.py:275` (import_module of customizations)
  - `test_push_down_exclusion_manifest.py:17` (`from ... push_down_claude_customizations import ROOT_FOLDERS`)
  - `test_push_down_codex_and_agents_resource_contracts.py:77`, `:101` (module name strings)
- Non-test fixture also matching: `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json:164`.

Already in the command and also touching the filesystem module: `test_push_down_claude_customizations.py:302`, `test_push_down_claude_pack_end_to_end.py:428`, `test_push_down_claude_parity.py:47` (path string).

Scope observation: the issue names only the two memory test files, so adding those two does not fully enumerate every test importing the four modules. The ten additional files above would also contribute coverage but are left out by operator scope. The wider command `poetry run pytest tests/scripts/dev_tools -k push_down` (same bullet and AC-24) covers all of them. Whether the Test Strategy command should enumerate them is not decided here.

## 4. Precedent for dated amendment notes in a spec

Grep for Amendment/Amended/planning agent in `docs/features/**/spec.md` found:

- `docs/features/completed/preimplementation-gate-blocks-epic-execution-554/spec.md:879`: `**Amendment, 2026-08-27.** Three additions and two numeral corrections were made to this section ...`; also `:947` an appendix "Amendment Comment (verbatim)" and `:954` "Amendment (2026-08-26, ...)".
- `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/spec.md:223`: bullet using the word "amended" with a rationale ("the edit is limited to the file reference").

No existing instance uses the literal phrase "planning-agent amendment". The nearest convention is a bold or parenthesized "Amendment" label with an ISO date followed by a short rationale. Within the #790 spec itself, no amendment note exists (no match).

Recommended format, placed as a sub-bullet directly beneath line 196 (nested at four spaces so it renders under the Python bullet):

```
    - Amendment (2026-10-11, issue #892, planning agent): added `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py` to the pytest file list so the command exercises the memory-scope and memory-mode behavior of `push_down_claude_customizations` that AC-22 coverage relies on. AC-22 text is unchanged.
```

Insert the two paths in the pytest argument list immediately before `--cov=scripts.dev_tools.push_down_claude_filesystem`. Keep the `--cov=`, `--cov-branch`, `--cov-report=term-missing` options unchanged.

## 5. Blast radius of the edit

References to the #790 folder name in repository code: Grep for the folder name or `follow-ups-790` under `tests/`, `scripts/`, `.claude/hooks/`, `.github/workflows/` returned no files. No repository test, script, hook, or workflow reads this spec by path.

Artifacts inside the #790 folder that mention the pytest command or related text (match on the start of the pytest file list):
- `spec.md` (the source)
- `research/2026-10-08T18-00-python-push-down-divergence-research.md`
- `plan.2026-10-08T13-56.md`
- `remediation-plan.2026-10-10T08-46.md`
- `policy-audit.2026-10-10T08-46.md`
- `evidence/qa-gates/pytest-targeted-coverage.2026-10-10T08-25.md`
- `evidence/qa-gates/remediation-pytest-targeted-coverage.2026-10-10T09-07.md`
- `evidence/remediation-baseline/pytest-targeted-coverage.2026-10-10T09-04.md`

No artifact cites `spec.md:196` or "spec.md line 196". The evidence files record the executed historical command and results; they are dated records and should not be edited. Thirty files in the folder mention the folder name (plans, audits, reviews, evidence); they reference the folder, not line numbers. Note that the recorded coverage evidence was produced with the original (narrower) command; the amended command will not retroactively match it. This is a consequence of the amendment and is documented by the dated note.

Note for the planner: the Grep did not exhaustively inspect whether other artifacts quote the command's text in line-wrapped form; the match above used the leading file names only.

## 6. Coverage command conventions

`pyproject.toml`:
- Line 114-117: `[tool.pytest.ini_options]`, `minversion = "7.0"`, `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, `testpaths = ["tests"]`. The addopts adds an LCOV report and does not set `--cov-fail-under`, `--cov`, or `--cov-branch`. No default fail-under exists.
- Line 119-121: `[tool.coverage.run]`, `source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`, with an `omit` list for tests and `__pycache__`.
- `[tool.coverage.report]` (line 129 onward) lists `exclude_lines` (pragma, `__repr__`, `raise AssertionError`, `raise NotImplementedError`, `if __name__ == .__main__.:`).

Consequences for the plan: keep dotted `--cov=scripts.dev_tools.<module>` (a `--cov=<path>.py` form measures nothing, per repository memory on verification gates), keep `--cov-branch` and `--cov-report=term-missing`. The addopts LCOV output is written implicitly to `artifacts/python/lcov.info`. Thresholds (85% line, 75% branch) are asserted by AC-22 text and are not enforced by pytest configuration.

## 7. Other copies of this spec

Glob `docs/features/**/*push-down-divergence-follow-ups*/spec*.md` returned a single file: the active #790 folder spec. No successor or duplicate spec was found in `docs/features/`.

## Recommendation

Edit spec.md:196 only: insert the two file paths into the pytest argument list, and add one dated sub-bullet beneath line 196 in the format in section 4. Do not change AC-22 (line 223), AC-24 (line 225), or any evidence file. Verification after the edit: Grep spec.md for `test_push_down_claude_memory_scope.py` and `test_push_down_claude_pack_memory_modes.py` (each should match line 196 plus the amendment note) and confirm lines 223 and 225 are byte-identical via `git diff`.

Rejected alternative: replace the file list with `tests/scripts/dev_tools -k push_down`. This exceeds the operator scope (two named files) and changes the command's shape.

## Automation Feasibility

No human-interaction requirement. The change is a text edit to one Markdown file; verification is by Grep and `git diff`. Running the amended pytest command locally is optional and automatable (`poetry run pytest ...`).
