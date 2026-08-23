# ruff-check-is-write-mode-and-exits-zero-after-fixing (Issue #515)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ruff-check-is-write-mode-and-exits-zero-after-fixing/ (Issue #515)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #515
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/515
- Last Updated: 2026-08-23
## Summary

`pyproject.toml` sets `fix = true` under `[tool.ruff]`, so `poetry run ruff check` rewrites fixable violations in place and still exits 0. Every agent and workflow that reads "ruff exited 0" as "the lint stage found nothing and changed nothing" is wrong, and the mandatory-toolchain rule in `.claude/rules/general-code-change.md` requires a restart from stage 1 whenever a stage auto-fixes a file — an obligation nothing in the repository currently observes.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: ruff 0.15.12 under Poetry; Python 3.13
- Command/flags used: `poetry run ruff check <file>` and `poetry run ruff check --no-fix <file>`
- Data source or fixture: `pyproject.toml` lines 90-91 (`fix = true`, `show-fixes = true`) at commit `bee15c06`

## Steps to Reproduce

1. Confirm the configuration: `[tool.ruff]` in `pyproject.toml` sets `fix = true` and `show-fixes = true`.
2. Create a scratch file outside the repository containing an unused import followed by any statement, for example `import os` then `x = 1`.
3. Record the file's content or hash.
4. Run `poetry run ruff check <that file>` and record both the exit code and the file's content afterwards.
5. Recreate the same file and run `poetry run ruff check --no-fix <that file>`, again recording exit code and content.
6. Compare.

## Expected Behavior

A command named `check` should not modify its input. Whatever the configured default, a stage that rewrites source must be observable as having done so: either it exits non-zero, or the repository provides a gate that detects the rewrite. The toolchain rule's restart-on-auto-fix requirement presupposes that an auto-fix is detectable.

## Actual Behavior

Step 4 deletes the import and exits 0. Step 5 leaves the file untouched and exits 1.

```text
$ poetry run ruff check <file>
Fixed 1 error:
- <file>:
    1 × F401 (unused-import)
Found 1 error (1 fixed, 0 remaining).
(exit 0)
--- file after: the `import os` line has been deleted ---

$ poetry run ruff check --no-fix <file>
F401 [*] `os` imported but unused
I001 [*] Import block is un-sorted or un-formatted
Found 2 errors.
[*] 2 fixable with the `--fix` option.
(exit 1)
--- file after: unchanged ---
```

The rewrite was confirmed by comparing file content before and after, not inferred from the output text.

Note the asymmetry that makes this easy to miss. The repository already guards three write-mode stages: `black .` is guarded by asserting no output line begins with `reformatted `, and both `run_poshqc_format` and `npm run format` are guarded by before/after `git status` snapshot pairs. All three are formatters. The linter has the identical write-mode property and no guard at all, because reviewers checking "which stages write" have consistently read that as "which formatters write".

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It is repository-wide and silent, and it defeats a rule rather than a single gate. Three consequences, in decreasing order of severity:

1. **The restart-on-auto-fix rule is unenforceable.** `.claude/rules/general-code-change.md` requires restarting the seven-stage loop from step 1 if any stage "auto-fixes any files". No agent can comply, because the auto-fix produces no signal.
2. **An agent can lose its own edit and be told it succeeded.** If an agent writes an import that turns out to be unused, the lint stage deletes the line and reports success. The agent proceeds believing its code is intact. This was found in exactly that form: an atomic plan for issue #502 anticipated an `F401` on a specific task and gated it with the bare command, so the gate would have silently repaired the defect it was written to catch.
3. **Any acceptance gate stating "ruff exits 0" is satisfiable by a run that rewrote production files.** That is the same unfalsifiable-gate class as [[plan-acceptance-gates-miss-unobservable-and-ambient-state-gates]].

It is not a Blocker because it fails toward a *formatted* tree rather than a broken one; the damage is to observability and to agent reasoning, not directly to correctness.

## Suspected Cause / Notes

- `pyproject.toml` `[tool.ruff]` sets `fix = true`. This is a deliberate developer convenience for interactive use, where auto-fixing on save or on demand is desirable. The defect is not the setting itself but that agent-facing policy and gates were written as though it were absent.
- Two directions are available and they are not equivalent. Removing `fix = true` from the shared config changes interactive behavior for humans; requiring `--no-fix` at every agent-facing call site leaves interactive behavior alone but must be applied everywhere and re-applied to each new call site. A third option is a dedicated Poetry script or Make target for the agent path.
- A complete inventory of write-mode versus read-only commands was produced while investigating this, and is worth landing somewhere durable rather than leaving in a single plan document:
  - **Write-mode:** `black .`, `ruff check` (this defect), `run_poshqc_format`, `npm run format`, `npm ci`, `git add -A`.
  - **Read-only, verified:** `black --check`, `ruff check --no-fix`, `pyright`, all `pytest` invocations, `run_poshqc_analyze`, `run_poshqc_test`, `npm run lint` (eslint with no `--fix`, and no fix setting in `eslint.config.mjs`), `npm run typecheck`.
- Check whether CI invokes the bare form. If it does, a CI lint stage may be rewriting files inside the runner and passing, which would mask a lint failure that a developer would see locally under a different working-tree state.
- `.claude/rules/python.md` and the Python toolchain instruction files should be checked for the bare form, since those are what agents read to decide the command.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — a test asserting the agent-facing lint invocation is read-only: run it against a fixture with a fixable violation and assert the fixture is byte-identical afterwards. A test asserting only the exit code would reproduce the blind spot.
- [x] Integration scenario to retest — the differential above, as a regression test: bare form rewrites and exits 0, `--no-fix` preserves and exits 1. Keep both halves; the `--no-fix` half alone would not catch a future config change that re-enables fixing on the agent path.
- [x] Manual verification notes — after any fix, confirm the lint stage still *fails* on an unfixable violation, and still reports fixable violations rather than hiding them. A change that made the stage silent on real findings would be worse than the defect.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
