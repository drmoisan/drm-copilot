# Feature Audit — Issue #539 (S7 Feature Review)

- Feature: 2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539
- Work mode: `full-bug` — AC source is `spec.md` only (`user-story.md` correctly absent)
- Range audited: `cdfd69f6..7611d576` against `main`
- Reviewer: feature-review agent
- Date: 2026-08-24T22-49

## D-EXEC-2 Adjudication (declared-open deviation)

**Question.** `spec.md` D4 rule-table row 14 and the post-fix decision table state that
relocating-option spellings (`git -C <dir> add ...`, `--git-dir=`, `--work-tree=`) DENY. The
measured behavior for the bare spellings is allow-by-non-match: the trigger regex requires the
command name to be immediately followed by the subcommand, so the trigger never fires and the
gate does not classify the command at all — before and after this fix.

**Adjudication: spec documentation defect combined with a pre-existing trigger limitation that
is out of scope for this fix. Not an implementation gap. Non-blocking for this PR.**

Reasoning:

1. The implementation is correct against the load-bearing contract (D1/D3): the *exemption*
   never fires for a relocating spelling. `Test-ExemptOrchestrationSegmentToken` rejects any
   token between `git` and the subcommand, so no relocating form can be granted the exemption.
   Verified by the four row-14 deny cases per side (env-style prefix; chained lines pairing a
   relocating spelling with a trigger-matching segment), all passing at HEAD.
2. The allow-by-non-match on the bare spellings is the trigger's pre-existing under-match. It is
   not introduced, widened, or reachable through anything in this diff: a bare
   `git -C ../x add scripts/evil.ps1` was equally unclassified before this fix. AC 14 explicitly
   forbids modifying the trigger regex, so asserting deny on the bare spellings is unsatisfiable
   within this feature's own acceptance constraints — the spec contradicts itself on this row.
3. The under-match is the mirror image of the over-match D8 already records as an accepted
   non-goal with a fail-open rationale (narrowing or re-anchoring the trigger risks wrapper
   bypasses). D8's recorded acceptance covers the underlying limitation — the trigger inspects
   whole-command text with a fixed anchor shape — but D8's text names only the over-match
   direction. The correction below therefore extends D8's record to name both directions rather
   than treating the under-match as a new discovery.
4. Severity: **non-blocking documentation correction**, plus a follow-up issue candidate. The
   D4 row-14 *classifier* rule (parser rejects relocating forms) is correct as implemented and
   tested; only the decision-table row and the row-14 rule statement misstate the gate-level
   outcome for bare spellings. The bare-spelling exposure (any command the trigger does not
   match is unclassified) is the same D8 trigger-scope question and belongs in the same
   follow-up issue candidate, which this feature deliberately does not file.

**Exact replacement text** (to be applied to `spec.md` by the owner or a follow-up commit; this
review does not edit acceptance documents):

- D4 rule table, row 14, replace the row with:

  | 14 | Anything between the command name and the subcommand (`-C <dir>`, `--git-dir=`, `--work-tree=`, env-style prefixes) | NEVER EXEMPT — the parser rejects the segment, so any trigger-matching line containing such a segment is denied. A bare relocating spelling that the trigger regex does not match (`git -C ../x add ...` with no other trigger-matching text on the line) never reaches this classifier and passes by non-match — a pre-existing trigger limitation recorded with D8, unchanged by this fix. | Pathspec base relocated; the repo-relative prefix test is no longer sound |

- Post-fix decision table, replace the row
  `| git -C ../x add docs/... / --git-dir / --work-tree | deny |` with two rows:

  | `git -C ../x add docs/...` / `--git-dir` / `--work-tree` chained with a trigger-matching segment, or with an env-style prefix (`GIT_DIR=... git add ...`) | deny (exemption withheld; unchanged deny) |
  | bare `git -C ../x add docs/...` / `--git-dir` / `--work-tree` where the trigger regex does not match the line | allow-by-non-match (pre-existing trigger limitation, recorded with D8; unchanged by this fix) |

- D8 section, append one sentence:
  "The same trigger property produces an under-match in the opposite direction: a relocating
  spelling that separates the command name from the subcommand is never classified at all and
  passes by non-match; this direction is part of the same follow-up candidate."

## Acceptance Criteria Evaluation (spec.md, 14 items)

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Command-branch exemption iff positive parse of a recognized `git add`/`git commit` invocation, >= 1 operand, all operands in exactly the five exempt trees after quote-stripping and separator normalization, verified via the pure seam with a not-ready checkpoint | PASS | Helper `Test-ExemptOrchestrationStagingCommand` implements exactly this; 8 allow cases per side through `Invoke-OrchestrationPreimplementationGateDecision` with an explicitly not-ready checkpoint; 194/194 tests pass at HEAD (re-run this review). Note: for chained lines the implementation is strictly stricter than the criterion's "trigger-matching segment" wording — every segment must be an all-exempt invocation. Deny-direction; documented in the helper; recorded as code-review note N2. |
| 2 | Every group-1 allow scenario as a named `It` per side (epic.md, manifest+kickoff, quoted, backslash, artifacts/orchestration kickoff, pathspec-bearing commit, all-exempt chain, potential-tree operand) | PASS | All eight named allow `It` blocks present in both new suites and passing. |
| 3 | Mixed operand deny across `.ps1`/`.py`/`.ts`/`.cs` with `PREIMPLEMENTATION_GATE_BLOCKED`, `route metadata`, `lifecycle readiness` asserted | PASS | `-ForEach` mixed-pathspec context in both suites asserts decision and all three reason phrases; passing. |
| 4 | Named case per D4 row 1–17 and 19 per side (row 18 via backslash allow case) | PASS | 44 named deny cases per side covering rows 1–17 and 19, including all enumerated forms; row 18 covered by the backslash allow case. Row-14 exemplars were re-selected to keep the trigger firing (D-EXEC-2); all four deny as mandated for trigger-matching lines. The bare relocating spellings are unassertable-as-deny under AC 14's own trigger-freeze — adjudicated above as a spec documentation defect, not a test gap. |
| 5 | Existing behavior unchanged: existing Claude suite passes unmodified; Codex table passes incl. pathless `git commit -m "wip"` still `$true`; readiness path, classifiers, block text, schema unmodified | PASS | The pre-existing Claude suite is absent from the diff (unmodified) and passes; Codex contract suite passes (its only diff is the mandated `SharedModuleNames` append); hook diffs contain exactly 4 hunks (dot-source line + classifier loop per hook) touching neither `Test-OrchestrationReady`, `Test-ImplementationPath`, nor the block-reason text. |
| 6 | Behavioral change in all four hook copies; Codex pair byte-identical (hook and helper) with hash-binding `It` passing; Claude pair content-equal with parity pytest passing | PASS | Independent SHA-256 this review: Claude hook pair identical (`bf3fe18d...`), Codex hook pair identical (`db69f084...`), all four helper copies identical (`45c339fd...`). Codex contract suite and `test_push_down_claude_resource_contracts.py` both pass. |
| 7 | Recomputed pair-hash evidence (SHA256, line counts, method) under `evidence/other/` following the #535 shape | PASS | `evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md` records all eight files with hashes, content lines, bytes, method, and a git-object cross-check; values match this review's independent hashing exactly. The two earlier mid-execution artifacts are superseded and the final artifact documents the discrepancy. |
| 8 | Parser extracted to dot-sourced sibling helpers mirrored on all four sides; every touched/added production and test file <= 500 lines | PASS | Helpers present on all four sides (byte-identical); measured line counts: hooks 382, helpers 349, new suites 267/271, Codex contract suite 494 — all <= 500. |
| 9 | Helper registered on every surface: `SharedModuleNames`, both pack manifests, both PoshQC coverage lists; completeness pytest and codex contract suite pass | PASS | All five registrations verified present by grep; `test_poshqc_bundled_parity.py` and the Codex contract suite pass at HEAD (re-run this review). |
| 10 | Pester line coverage >= 85% on every changed/added production PowerShell file, helpers inside the denominator, verified by the `mcp__drm-copilot__run_poshqc_test` coverage report | PASS (verification mechanism substituted, D-EXEC-5) | The cited MCP runner reads the installed extension's runsettings and cannot display the new rows; the authoritative run used the self-hosted module directly. This review independently parsed the committed `artifacts/pester/powershell-coverage.xml` keyed on `package`: Claude hook 90.3% (102/113), Claude helper 94.9% (112/118), Codex hook 99.2% (124/125), Codex helper 94.9% (112/118) — all >= 85%, helpers in the denominator, no regression vs. baseline. The substance of the criterion is met; the mechanism citation is superseded per the declared context. |
| 11 | Additive pathspec-bearing-form prose in both planner SKILL.md files and both bundle mirrors; pinned preparation-mode marker literals byte-unchanged; #535 marker tests pass unmodified | PASS | `### Integration Commit Form (issue #539)` sections present in all four files; canonical and bundle sections diff-equal; range diff contains no change to either pinned marker literal; the pre-existing suites carrying the marker assertions pass unmodified. |
| 12 | Fail-before evidence (allow cases vs. unfixed hook) plus pass-after per pair under `evidence/regression-testing/` | PASS | `fail-before-pester-claude.2026-08-24T17-43.md`, `fail-before-pester-codex.2026-08-24T17-46.md`, `pass-after-claude.2026-08-24T19-28.md`, `pass-after-codex.2026-08-24T19-42.md` all present in the diff. |
| 13 | PoshQC toolchain clean in a single pass over all changed/added PowerShell files | PASS | Final QA loop at HEAD: format 0 files changed, analyze 0 findings (`evidence/qa-gates/final-poshqc-format.2026-08-24T22-08.md`, `final-poshqc-analyze.2026-08-24T22-08.md`), Pester 1778 tests 0 failures EXIT_CODE 0 (`final-pester.2026-08-24T22-24.md`). This review re-ran the four decision suites (194/194) and both parity pytests (11/11) at HEAD. |
| 14 | No out-of-scope changes: trigger regex unmodified (here-string literal still denies, named case per side); no alternative readiness source; `Test-OrchestrationReady` unchanged; nothing under `.github/instructions/` or `.claude/rules/` modified; no Python leg in any enforcement hook | PASS | Trigger pattern byte-unchanged in both hook diffs; the D3/D8 here-document deny case is present and passing on each side; no readiness-source or `Test-OrchestrationReady` hunk exists; range contains no path under `.github/instructions/` or `.claude/rules/`; no Python files added under any hooks tree. |

All 14 criteria were already checked `[x]` in `spec.md` by the executor; this review confirms
each check-off is supported by evidence, so no source-file update is required and no criterion
must be unchecked.

### Acceptance Criteria Status
- Source: docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none

## Baseline Comparison

Relative to the merge base, the branch changes exactly the surfaces the spec enumerates: the
four hook copies, the four new helper copies, five registration surfaces, four SKILL.md files,
two new test suites, one one-line contract-suite append, and feature-folder documents/evidence.
No unrelated production surface is touched. The bug's blocking behavior (planner integration
commits denied without a ready single-feature checkpoint) is demonstrably fixed by the passing
allow cases against a not-ready checkpoint, with fail-before evidence proving those same cases
denied at the baseline.

## Outstanding Items

1. Apply the D-EXEC-2 spec text correction (replacement text above; also recorded in
   `remediation-inputs.2026-08-24T22-49.md`). Non-blocking for merge.
2. Follow-up issue candidate (deliberately not filed by this feature, per D8): trigger-scope
   over-match and under-match of the whole-command-text regex, now covering both directions.

## Amendment — R1 applied in-branch (2026-08-24T23-30)

R1 was applied to `spec.md` in this branch at the orchestrator's direction, rather than deferred to a
follow-up commit, so that the merged specification does not contain a statement contradicting the
shipped behavior. The edit used the exact replacement text recorded in the "D-EXEC-2 Adjudication"
section above, applied at three locations:

1. D4 rule table, row 14 — `DENY` replaced with the `NEVER EXEMPT` statement plus the
   allow-by-non-match note for bare relocating spellings.
2. Post-fix decision table — the single `git -C ../x add docs/...` deny row replaced by two rows
   separating the trigger-matching deny case from the bare allow-by-non-match case.
3. D8 — one sentence appended recording the under-match direction as part of the same follow-up
   candidate.

The adjudication itself is unchanged. No acceptance criterion was re-evaluated, re-worded, or
re-checked as a result: all 14 remain `[x]` and all 14 remain PASS on the evidence recorded above.
The edit is documentation-only and touches no hook, helper, test, registration surface, or evidence
artifact. R2 (follow-up issue candidate) and R3 (superseded pair-hash artifacts, keep as-is) are
unaffected and remain as recorded in `remediation-inputs.2026-08-24T22-49.md`.
