# Code Review — Issue #539 (S7 Feature Review)

- Feature: 2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539
- Range reviewed: `cdfd69f6..7611d576` (54 files, +4633/-107)
- Reviewer: feature-review agent
- Date: 2026-08-24T22-49

## Summary

The change adds an allow-side pathspec-scoped exemption to the command branch of the
orchestration preimplementation gate. The parser is extracted into a dot-sourced sibling helper
(`enforce-orchestration-preimplementation-gate-helpers.ps1`) that is byte-identical across all
four sides, and the hook edit itself is a small, well-commented loop restructuring in
`Test-ImplementationCommand` that consults the exemption only for the git staging trigger
(index 0) and only to `continue`, never to suppress another pattern. The design matches the
spec's D1/D3 contract: the exemption is stateless, granted only on a positive parse, and every
ambiguity degrades to the pre-change deny.

## Strengths

1. **Fail-closed by construction.** Every function returns false for every unmodeled input:
   unknown options, pathspec magic, absolute/parent/glob-escaping operands, unbalanced quotes,
   interpolation/redirection characters, non-leading `git`, and zero-operand invocations. The
   deny fallback is the pre-fix behavior, so rollback and parser defects both degrade safely.
2. **Purity.** The helper performs no disk, process, network, or environment access, which keeps
   the decision seam unit-testable exactly as the existing suites already test it
   (in-memory payload plus in-memory checkpoint, no temp files).
3. **Loop design in `Test-ImplementationCommand`.** Using `continue` rather than an early return
   when the exemption clears index 0 preserves classification by every other implementation
   pattern on the same line. This closes the obvious composition hole
   (`git add docs/... && poetry run pytest` still denies), and the inline comment explains why.
4. **Documentation density is appropriate.** Each helper function's comment block cites the D4
   rows it realizes; the deliberate all-segments strictness is documented in the entry
   predicate's help text rather than left implicit.
5. **Test quality.** 44 named deny cases per side (one or more per D4 row), 8 allow cases per
   side, mixed-pathspec cases across `.ps1`/`.py`/`.ts`/`.cs`, and a here-document D3/D8
   residual-behavior case. Fixtures for row 14 were re-selected so every case actually fires the
   trigger (see feature-audit D-EXEC-2 adjudication). Arrange–Act–Assert with `-Because`
   messages throughout. Both suites are structural mirrors, reducing drift risk between sides.
6. **Registration completeness.** Helper registered on all five surfaces (Codex
   `SharedModuleNames`, both pack manifests, both PoshQC runsettings), verified present and
   enforced by passing contract suites and parity pytests.

## Non-Blocking Findings

- **N1 — Stale mid-execution pair-hash artifacts.**
  `evidence/other/claude-pair-hash.2026-08-24T19-57.md` and
  `evidence/other/codex-pair-hash.2026-08-24T20-06.md` record hashes matching no commit at
  branch head. `evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md` supersedes them
  and explains the discrepancy, and this review independently re-hashed all eight files and
  confirmed the final artifact. Recommendation: keep all three files as-is — the final artifact
  documents the supersession and the earlier files are honest phase-completion records. No
  action required; do not report these as a parity failure in later reviews.

- **N2 — All-segments strictness is broader than a minimal reading of D4 row 13.**
  D4 row 13 requires every *trigger-matching* segment to pass independently. The implementation
  requires *every* segment to be a recognized all-exempt invocation, so a chained line pairing
  an exempt git segment with an innocuous non-implementation segment (for example
  `git add docs/features/epics/x/epic.md && echo done`) denies. This is deny-direction
  (strictly safer), deliberate, and documented in the entry predicate's help text. No change
  requested; recorded so a future report of a false denial on such a chain is traced to a
  documented design choice, not a defect. If planner surfaces ever need mixed chains, the
  correct fix is a follow-up widening with its own rule-table row, not an ad-hoc edit.

- **N3 — Attached-message acceptance relies on a two-condition prefix test.**
  `$candidate.Length -gt 2 -and $candidate.StartsWith('-m')` accepts any single-dash token
  beginning `-m` as an attached message (`-mfoo`). This matches git's own parsing (git treats
  `-mfoo` and even `-message` as `-m` with an attached value), and no dangerous `git commit`
  option begins with `-m`, so no widening results. Recorded because the safety argument is
  option-table-dependent: if git ever grows a content-widening `commit` option starting with
  `-m`, this branch would mis-classify it as a message. Acceptable residual; a comment already
  marks the message option as the only modeled option.

- **N4 — Spec text correction required for D4 row 14 / post-fix decision table (D-EXEC-2).**
  Documentation defect in `spec.md`, not in the code. Adjudication and exact replacement text
  are in `feature-audit.2026-08-24T22-49.md` and `remediation-inputs.2026-08-24T22-49.md`.

## Blocking Findings

None.

## Verification Performed by This Review

- Re-ran the four relevant Pester suites at HEAD: 194 tests, 0 failures.
- Re-ran `test_push_down_claude_resource_contracts.py` and `test_poshqc_bundled_parity.py`:
  11 passed.
- Independently hashed all eight hook/helper copies; both pairs identical, all four helper
  copies share one hash.
- Parsed `artifacts/pester/powershell-coverage.xml` keyed on `package`: all four changed/added
  production files at or above 85% line coverage (90.3 / 94.9 / 99.2 / 94.9).
- Ran `validate_evidence_locations.py --root .`: exit 0.
- Adversarial parse-bypass analysis (documented in `policy-audit.2026-08-24T22-49.md`): no
  operand form found that can escape the five exempt trees while the exemption fires.
