# G11 to G13 Corpus Measurement — Issue #964

Timestamp: 2026-10-16T23-46
Task: [P1-T13]
Command: PYTHONPATH=. poetry run python SCRATCH/issue-964-corpus-measure.py; PYTHONIOENCODING=utf-8 PYTHONPATH=. poetry run python SCRATCH/issue-964-corpus-classes.py
EXIT_CODE: 0
Output Summary:
- Files scanned: 615 committed `plan*.md` and `remediation-plan*.md` files under `docs/` (feature-template files excluded), each read at `HEAD` with `git show` so uncommitted edits are not measured.
- G11: 13190 findings in 350 files (prose form 10633, path form 2557, anchor form 0).
- G12: 1681 findings in 218 files (541 distinct values).
- G13: 280 findings in 280 files (one per oversized plan without a justification section).
- The measurement informed the false-positive class list in `.claude/rules/plan-acceptance-gates.md`; it did not decide the channel. G11 and G12 ship Blocking by operator-approved scope and G13 ships Blocking because its exoneration is author-controlled.

## Method

- Enumeration: `git ls-files docs`, filtered to basenames matching `plan*.md` or `remediation-plan*.md`, excluding paths under `/templates/`.
- Evaluation: `evaluate_document_gates` from `scripts.dev_tools.plan_gate_document` on each file's committed text; findings classified by message text.
- Classification pass: `line_citations` and `sha_citations` on the same files, with the enclosing line inspected for output-related wording, quoted validator prefixes, and commit-related wording.

## Samples per Rule

- G11 (prose form): `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/plan.2026-09-29T14-12.md` reports `line 436`, `line 243`, `line 3`, `lines 42`, `line 19`, `line 205` (file positions cited in task text).
- G11 (path form): extensions of matched `path:line` tokens, most frequent first: `ps1` 726, `md` 480, `ts` 253, `py` 252, `psm1` 252, `sh` 231, `bats` 141, `psd1` 70, `json` 44, `yml` 41.
- G12: commit citations such as an abbreviated SHA in `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/plan.2026-09-29T13-19.md` (cited three times) and full 40-character SHAs in the metadata block of `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/remediation-plan.2026-09-30T15-25.md`.
- G13: `126 tasks, 756 lines` (issue #509 plan), `132 tasks, 841 lines` (issue #769 plan), `42 tasks, 235 lines` (issue #338 plan), `60 tasks, 399 lines` (issue #509 remediation plan).

## False-Positive Classes Observed

1. G11, prose that refers to a line of command output or a printed result line: 1475 prose-form findings sit on lines that also mention output, stdout, stderr, or a log. Not every one is a false positive (many also cite a file line), but the class exists.
2. G11, a quoted validator prefix written outside backticks: 23 prose-form findings sit on lines that quote a `Line N:` prefix.
3. G12, synthetic hexadecimal fixture identifiers in test-scenario task text (for example the fixture values `aaaa0000`, `bbbb1111`, `ffff8888` in plans that create `tests/fixtures/cleanup_worktrees/scenarios/` fixtures).
4. G12, git object identifiers that are not commits, such as blob hashes produced by `git hash-object` and recorded as parity evidence.
5. G12, a bare hexadecimal color or similar identifier was not observed in the corpus; it remains a documented class.

Of the 541 distinct G12 values, 123 sit on lines with no commit-related wording (commit, SHA, HEAD, merge, base, rev, ref, tip, pushed, squash, cherry); classes 3 and 4 above were drawn from that subset.
