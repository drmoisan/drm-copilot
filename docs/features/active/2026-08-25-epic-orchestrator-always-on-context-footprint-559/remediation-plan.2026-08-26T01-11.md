# Remediation Plan — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T01-11
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- Work mode: `full-bug`
- Feature folder (`<FEATURE>` below): `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/`
- Inputs: `remediation-inputs.2026-08-26T01-11.md`, `policy-audit.2026-08-26T01-11.md`,
  `code-review.2026-08-26T01-11.md`, `feature-audit.2026-08-26T01-11.md`, all in `<FEATURE>`.

All evidence paths below are written relative to `<FEATURE>`, e.g. `evidence/remediation-baseline/x.md`
resolves to `<FEATURE>/evidence/remediation-baseline/x.md`. No evidence path in this plan resolves
under `artifacts/`.

## Scope — exactly three items, no others

- **R1 (Blocking).** `claude_markdown_files()` in
  `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` enumerates `.claude/` by filesystem walk
  and excludes only `agent-memory`, so it also scans `.claude/worktrees/` and `.claude/state/`. This
  is non-deterministic across machines. Fix: extend `EXCLUDED_CLAUDE_SUBDIRS` from
  `frozenset({"agent-memory"})` to `frozenset({"agent-memory", "worktrees", "state"})`, naming all
  three known gitignored, machine-local subtrees. This is a bounded, name-based fix, not a structural
  one: it enumerates the specific directory names known today, so a future gitignored subtree
  introduced under `.claude/` and not added to this frozenset would reintroduce the defect. That
  residual is documented here rather than left implicit, in the same spirit as the bounded residuals
  `.claude/rules/plan-acceptance-gates.md` records for the G6 false-positive case and the
  placeholder-marker false-negative class; this fix does not claim to remove the whole defect class.
- **R2 (Non-blocking).** `CLAUDE.md:11` claims `.claude/rules/tonality.md` is "the authoritative
  source" while `CLAUDE.md:13` (pre-existing, untouched) claims the two `.github/` files "are
  authoritative." Fix: reword only line 11 to describe `.claude/rules/tonality.md` as a mirror, not an
  authority. Line 13 is not touched.
- **R3 (Non-blocking).** Three evidence artifacts —
  `evidence/other/ac-reconciliation.2026-08-26T00-00.md`,
  `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`, and
  `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` — lack `Command:`/`EXIT_CODE:`; the
  first also lacks `Output Summary:`. Fix: classify each as a narrative/derivation record (no
  fabricated `Command:`/`EXIT_CODE:` line), add the missing `Output Summary:` to the first, and
  correct the overstated four-field-conformance claim in the reconciliation artifact.

## Hard boundaries (apply to every phase below)

- Do not touch `spec.md` line 644 (the F5 decision-half criterion, `**BLOCKED — DO NOT CHECK.**`).
- Do not change any coverage threshold value or toolchain stage count anywhere. Do not edit
  `AGENTS.md` or anything under `.github/instructions/`.
- Do not amend `spec.md` line 623.
- Do not touch `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
- Do not attempt to fix `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Do not
  delete, move, or mutate any gitignored file, in particular
  `.claude/state/python-batch-budget.default.json`.
- No task in this plan adds, removes, or renames a test function in
  `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`; it must continue to collect exactly
  eight tests.

### Phase 0 — Remediation Baseline Capture

- [x] [P0-T1] Read, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`;
      `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`;
      `.claude/rules/python-suppressions.md`; `.claude/rules/quality-tiers.md`;
      `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`; and
      `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Write
      `evidence/remediation-baseline/phase0-instructions-read.2026-08-26T01-11.md` with `Timestamp:`,
      `Policy Order:`, and the explicit list of files read. Acceptance: the artifact exists and
      contains each of the nine file paths above as a literal, verified by
      `grep -c -F ".claude/rules/plan-acceptance-gates.md" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/remediation-baseline/phase0-instructions-read.2026-08-26T01-11.md; echo EXIT_CODE=$?`
      reporting a count of at least 1 and `EXIT_CODE=0`.
- [x] [P0-T2] Capture the starting git state:
      `git branch --show-current; echo EXIT_CODE=$?` and `git rev-parse HEAD; echo EXIT_CODE=$?` and
      `git status --porcelain; echo EXIT_CODE=$?`. Write
      `evidence/remediation-baseline/baseline-git-state.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: all three commands report
      `EXIT_CODE=0`, and the branch name printed is exactly
      `bug/epic-orchestrator-always-on-context-footprint-559`.
- [x] [P0-T3] Run
      `wc -l tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`. Write
      `evidence/remediation-baseline/baseline-file-size.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: reported line count is exactly `499`
      and `EXIT_CODE=0`.
- [x] [P0-T4] Run
      `poetry run black --check tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/remediation-baseline/baseline-black.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P0-T5] Run
      `poetry run ruff check --no-fix tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/remediation-baseline/baseline-ruff.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P0-T6] Run
      `poetry run pyright tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/remediation-baseline/baseline-pyright.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0` and the output contains
      `0 errors`.
- [x] [P0-T7] Run
      `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q; echo EXIT_CODE=$?`
      from this worktree. Write
      `evidence/remediation-baseline/baseline-target-module-pytest.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the output contains
      `8 passed` and `EXIT_CODE=0`, recording that the defect does not reproduce from inside a
      worktree (no nested `.claude/worktrees/` exists here).
- [x] [P0-T8] Run
      `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing -q; echo EXIT_CODE=$?`.
      Write `evidence/remediation-baseline/baseline-full-pytest-coverage.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the numeric coverage
      total. Acceptance: `EXIT_CODE=1`; the output contains `4150 passed`, `5 skipped`, and the node ID
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as the sole failure; the
      `TOTAL` coverage row reads `15014    1104    93%` (92.65% exact, 13910/15014 covered).
- [x] [P0-T9] Run, each independently:
      `git ls-files -- .claude/worktrees; echo EXIT_CODE=$?` and
      `git ls-files -- .claude/state; echo EXIT_CODE=$?` and
      `git ls-files -- .claude/agent-memory; echo EXIT_CODE=$?`. Write
      `evidence/remediation-baseline/baseline-git-tracked-subtrees.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: all three commands
      produce zero lines of file-path output and `EXIT_CODE=0`, establishing that no file under any of
      the three gitignored subtrees is ever tracked, in any checkout of this repository.
- [x] [P0-T10] Inspect schema-field presence across the 29 committed evidence artifacts under
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md`:
      run
      `grep -L "^Command:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md; echo EXIT_CODE=$?`,
      `grep -L "^EXIT_CODE:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md; echo EXIT_CODE=$?`,
      and
      `grep -L "^Output Summary:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md; echo EXIT_CODE=$?`.
      Write `evidence/remediation-baseline/evidence-schema-inventory.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording exactly which files are
      listed by each command. Acceptance: the first two commands each list exactly three files —
      `evidence/other/ac-reconciliation.2026-08-26T00-00.md`,
      `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`,
      `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` — and the third lists exactly one
      file, `evidence/other/ac-reconciliation.2026-08-26T00-00.md`. Do not guess; report exactly what
      the three commands print.

### Phase 1 — Fix R1: Deterministic `.claude/` Markdown Enumeration

- [x] [P1-T1] In `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, change the
      `EXCLUDED_CLAUDE_SUBDIRS` assignment at line 37 from `frozenset({"agent-memory"})` to
      `frozenset({"agent-memory", "worktrees", "state"})`. Replace the existing comment on lines
      35-36 with exactly these two lines, verbatim, and add no third comment line:

      ```
      # `.claude/agent-memory/`, `.claude/worktrees/`, and `.claude/state/` are gitignored,
      # machine-local subtrees excluded here for determinism.
      ```

      These two lines are a one-for-one replacement for the two lines they replace, so the file's
      total line count does not change. Do not add the parenthetical descriptions `(nested worktree
      checkouts)` or `(session-keyed run state)` anywhere in the comment: they are deliberately
      omitted to keep both lines within the repository's configured Black line length of 88
      characters. The body and docstring of `claude_markdown_files()` are otherwise unchanged. Do not
      add, remove, or rename any test function. Acceptance:
      `grep -c -F 'frozenset({"agent-memory", "worktrees", "state"})' tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`
      reports a count of `1` and `EXIT_CODE=0`; and
      `wc -l tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?` reports
      exactly `499` and `EXIT_CODE=0`.
- [x] [P1-T2] Run
      `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/pass-after-r1-fix.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the output contains `8 passed` and
      `EXIT_CODE=0`.
- [ ] [P1-T3] Run, as a single line:
      `poetry run python -c "import sys; sys.path.insert(0, 'tests/scripts/dev_tools'); from test_claude_rules_frontmatter import claude_markdown_files; files = claude_markdown_files(); bad = [f for f in files if 'worktrees' in f.parts or 'state' in f.parts or 'agent-memory' in f.parts]; print('BAD_COUNT=' + str(len(bad))); print('TOTAL=' + str(len(files)))"; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/subdir-exclusion-proof.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the output contains
      `BAD_COUNT=0`, a `TOTAL=` value greater than `0` (proving the function still returns real
      files), and `EXIT_CODE=0`, confirming the expanded `EXCLUDED_CLAUDE_SUBDIRS` frozenset filters
      all three named subtrees out of the returned file list.
- [x] [P1-T4] Run, as a single line:
      `poetry run python -c "import sys; sys.path.insert(0, 'tests/scripts/dev_tools'); from test_claude_rules_frontmatter import UNQUALIFIED_SPEC_SECTION, normalize_whitespace; print(bool(UNQUALIFIED_SPEC_SECTION.search(normalize_whitespace('See spec.md §613 for details'))))"; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/detection-regex-still-matches.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the printed value is
      `True` and `EXIT_CODE=0`, demonstrating as a fail-before-style probe that the detection
      assertion (untouched by this fix) still flags an unqualified `spec.md §` citation if one is
      reintroduced into a committed `.claude/` file.
- [x] [P1-T5] Run
      `poetry run black --check tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/r1-black-check.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P1-T6] Run
      `poetry run ruff check --no-fix tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/r1-ruff-check.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P1-T7] Run
      `poetry run pyright tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/regression-testing/r1-pyright-check.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0` and the output contains
      `0 errors`.

### Phase 2 — Fix R2: `CLAUDE.md` Tone-Policy Authority Wording

- [x] [P2-T1] In `CLAUDE.md`, replace line 11 only:
      old text `The specific tone rules are stated once in \`.claude/rules/tonality.md\`, which the
      runtime loads as the authoritative source; they are not restated here.`
      with new text `The specific tone rules are stated once in \`.claude/rules/tonality.md\`, which
      the runtime loads as a mirror of the authoritative source defined below; they are not restated
      here.` Do not modify line 13 (`The full tone policy is defined in ...`). Acceptance:
      `grep -c -F "a mirror of the authoritative source defined below" CLAUDE.md; echo EXIT_CODE=$?`
      reports a count of `1`, and
      `grep -c -F "loads as the authoritative source" CLAUDE.md; echo EXIT_CODE=$?` reports a count of
      `0`.
- [x] [P2-T2] Run `git diff HEAD -- CLAUDE.md; echo EXIT_CODE=$?`. Write
      `evidence/regression-testing/r2-claude-md-diff-scope.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the diff shows exactly one changed
      line, and the removed/added pair is confined to the sentence named in `[P2-T1]`; no hunk touches
      the line beginning `The full tone policy is defined in`.
- [x] [P2-T3] Run `file CLAUDE.md; echo EXIT_CODE=$?` and confirm no `CRLF` token appears in the
      output (Windows `file` reports `CRLF line terminators` when present and reports nothing of the
      sort for LF-only text). Write
      `evidence/regression-testing/r2-claude-md-line-endings.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the output does not contain the string
      `CRLF`.

### Phase 3 — Fix R3: Evidence Artifact Schema Corrections

- [x] [P3-T1] In
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md`,
      insert the following section immediately before the line
      `## Checkbox partition — 42 total, 38 acceptance criteria`:

      ```
      ## Evidence Schema Classification (Remediation R3, Issue #559)

      Timestamp: 2026-08-26T01-11

      This artifact is a narrative reconciliation record: it maps acceptance criteria to prior
      command-step evidence artifacts and records no command of its own. It therefore carries no
      `Command:` or `EXIT_CODE:` field.

      Output Summary: 38 acceptance criteria reconciled; 36 checked, 2 left unchecked (spec lines 623
      and 644) for the reasons adjudicated below.

      Of the 29 evidence artifacts this feature produced, 26 conform to the full four-field schema
      (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`). The remaining three are narrative
      or derivation records that record no single command: this artifact,
      `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`, and
      `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`. This paragraph supersedes any
      earlier statement in this feature's evidence claiming uniform four-field conformance across all
      29 artifacts.
      ```

      Acceptance:
      `grep -c -F "narrative reconciliation record" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md; echo EXIT_CODE=$?`
      reports a count of at least `1`;
      `grep -c -F "Output Summary: 38 acceptance criteria reconciled" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md; echo EXIT_CODE=$?`
      reports a count of `1`; and
      `grep -c -F "26 conform to the full four-field schema" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/other/ac-reconciliation.2026-08-26T00-00.md; echo EXIT_CODE=$?`
      reports a count of at least `1`.
- [x] [P3-T2] In
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`,
      insert the following section immediately before the line `## Sources compared`:

      ```
      ## Evidence Schema Classification (Remediation R3, Issue #559)

      This artifact is a derived comparison record: it compares two prior command-step artifacts
      (`evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md` and
      `evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md`) and runs no command of its own.
      It therefore carries no `Command:` or `EXIT_CODE:` field; the underlying command those two
      artifacts record is `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`.
      ```

      Acceptance:
      `grep -c -F "derived comparison record" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/coverage-delta.2026-08-26T00-00.md; echo EXIT_CODE=$?`
      reports a count of at least `1`.
- [x] [P3-T3] In
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`,
      insert the following section immediately before the line `## Gates that do not apply`:

      ```
      ## Evidence Schema Classification (Remediation R3, Issue #559)

      This artifact is a narrative record: it enumerates gates that do not apply to this change and
      states the reason each does not apply. It runs no single command of its own and therefore
      carries no `Command:` or `EXIT_CODE:` field.
      ```

      Acceptance:
      `grep -c -F "This artifact is a narrative record" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md; echo EXIT_CODE=$?`
      reports a count of at least `1`.
- [x] [P3-T4] Run, for each of the three files edited by `[P3-T1]`, `[P3-T2]`, and `[P3-T3]`:
      `file <path>; echo EXIT_CODE=$?` (three invocations, one per path). Write
      `evidence/regression-testing/r3-line-ending-check.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: none of the three outputs contains the
      string `CRLF`.
- [x] [P3-T5] Run
      `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .; echo EXIT_CODE=$?`.
      Write `evidence/qa-gates/post-r3-evidence-location-check.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`, confirming the three
      edited artifacts remain at their canonical `<FEATURE>/evidence/<kind>/` paths.

### Phase 4 — Final QA Loop

Run the four stages below in order. If any stage fails, or if any stage's execution changes a file
(for example, `black` without `--check` reformatting a file), restart from `[P4-T1]` until one pass
completes with every stage green.

- [x] [P4-T1] Run
      `poetry run black --check tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/qa-gates/final-remediation-black.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P4-T2] Run
      `poetry run ruff check --no-fix tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/qa-gates/final-remediation-ruff.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0`.
- [x] [P4-T3] Run
      `poetry run pyright tests/scripts/dev_tools/test_claude_rules_frontmatter.py; echo EXIT_CODE=$?`.
      Write `evidence/qa-gates/final-remediation-pyright.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE=0` and the output contains
      `0 errors`.
- [x] [P4-T4] Run
      `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing -q; echo EXIT_CODE=$?`.
      Write `evidence/qa-gates/final-remediation-pytest-coverage.2026-08-26T01-11.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the numeric coverage
      total. Acceptance: `EXIT_CODE=1`; the output names exactly one failing node ID,
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and no other failure; the
      output contains `4150 passed` and `5 skipped`; the `TOTAL` coverage row reads
      `15014    1104    93%` (92.65% exact), matching `[P0-T8]` with a signed delta of `+0.00`
      percentage points.
- [x] [P4-T5] Compute the signed coverage delta between `[P0-T8]` and `[P4-T4]`. Write
      `evidence/qa-gates/remediation-coverage-delta.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact states the pre-remediation
      figure `92.65%`, the post-remediation figure `92.65%`, and the signed delta `+0.00` percentage
      points, both figures derived from `13910/15014` covered statements.
- [x] [P4-T6] Run, each independently:
      `git diff HEAD -- docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md; echo EXIT_CODE=$?`,
      `git diff HEAD -- tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py; echo EXIT_CODE=$?`,
      `git diff HEAD -- AGENTS.md; echo EXIT_CODE=$?`, and
      `git diff HEAD -- .github/instructions; echo EXIT_CODE=$?`. Write
      `evidence/qa-gates/final-remediation-scope-containment.2026-08-26T01-11.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: all four commands produce empty diff
      output and `EXIT_CODE=0`, confirming `spec.md` line 644 remains untouched, the concurrently-owned
      test module is untouched, and no coverage threshold or toolchain-stage-count file is touched.
