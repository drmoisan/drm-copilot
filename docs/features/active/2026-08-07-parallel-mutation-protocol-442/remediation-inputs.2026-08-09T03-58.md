# Remediation Inputs — 2026-08-07-parallel-mutation-protocol-442 (post-cycle-1)

- **Timestamp:** 2026-08-09T03-58
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Whole-branch diff base:** `c939b5b8` · **HEAD:** `fc10a471`
- **Source artifacts:**
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/policy-audit.2026-08-09T03-58.md`
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/code-review.2026-08-09T03-58.md`
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/feature-audit.2026-08-09T03-58.md`

## THE REMEDIATION LOOP EXITS — NO FURTHER CYCLE IS REQUIRED

**Blocking count: 0.** Remediation cycle 1 discharged the prior Blocking finding and four of five
Partials, and deferred the fifth with a recorded artifact. This document exists only so the two
remaining non-gating items are not lost. **Neither item below is a merge gate, and neither warrants
a remediation cycle 2.**

| Classification | Count | Merge gate |
|---|---|---|
| Blocking | **0** | — |
| Partial | 2 | **No** |
| Advisory | 6 | No |

## Non-Gating Items

### N1 — PARTIAL (new) — spec 1.2 left three pre-1.2 formulations in `spec.md`

- **Artifacts:** `policy-audit.2026-08-09T03-58.md` finding **P1**; `feature-audit.2026-08-09T03-58.md`
  § Acceptance Criteria Status (closing note).
- **Locations:**
  - `spec.md:457` — `## Non-Negotiable Constraints` item 1: "recoloring is a pure function of
    `(remaining subgraph, pinned set)`". This is the **two-argument** pre-1.2 form, in a normative
    section, contradicting amended FR4 at `spec.md:176` and amended AC S5.
  - `spec.md:694` — Seeded Test Conditions: "admission decision (no-conflict admit,
    **in-flight-conflict defer**)" — the pre-1.2 admission rule.
  - `spec.md:695` — Seeded Test Conditions: "recoloring is a pure function of
    `(remaining subgraph, pinned set)`".
- **Violated expectation:** an amended spec must be internally consistent. A normative
  `## Non-Negotiable Constraints` entry that contradicts the amended functional requirement leaves
  two readings of the same contract in one document. The amendment record
  `evidence/other/remediation1-spec-amendment-1.2.md` enumerates FR1 step 4, the recompute boundary,
  the API snippet, Test Strategy scenario 4, FR9 invariant 3, and S2/S5/S9/U1/U5; it does not cover
  these three sites.
- **Why it is not a gate:** no delivered behavior is wrong — the code implements the amended FR4 —
  and no acceptance criterion is falsified. `spec.md:694-695` are Seeded Test Conditions and remain
  `[ ]` unchecked, so no claim is asserted against them. `spec.md:457` is a constraints
  restatement, not an AC.
- **Verification commands:**
  - `grep -rn "remaining subgraph, pinned set)" docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md`
    → returns lines `457` and `695`.
  - `grep -n "in-flight-conflict defer" docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md`
    → returns line `694`.
  - The same greps over `user-story.md` and `.claude/skills/parallel-orchestrate/SKILL.md` return
    nothing, so the stale text is confined to `spec.md`.
- **Remediation (documentation only, three one-line edits):** append ", pinned cohort index" to the
  recolor formulation at `:457` and `:695`; broaden `:694` from "in-flight-conflict defer" to
  "current-cohort-conflict defer". No code change, no AC change, no test change. Suitable for the
  PR-authoring pass or a follow-up documentation commit.

### N2 — PARTIAL (carried, reduced) — S603 comment format is not verbatim on the violating line

- **Artifacts:** `policy-audit.2026-08-09T03-58.md` finding **P2** (was P5 / R6).
- **Location:** `scripts/dev_tools/parallel_mutation_abandon_cli.py:152-154`.
- **Violated rule:** `.claude/rules/python-suppressions.md` § S603 requires the comment format
  `# noqa: S603 - static analysis can't verify runtime validation`, and its enforcement checklist
  requires it verbatim. Line 154 carries a bare `# noqa: S603`; the rationale sits on lines 152-153
  as a non-directive comment.
- **What cycle 1 fixed:** the prior finding had two halves. The **inert directive-shaped comment**
  half is resolved — line 152 no longer begins `# noqa:`, so no line of the file carries a `noqa`
  token that suppresses nothing.
- **What remains:** the verbatim-format half only.
- **Recorded, measured rationale:** `evidence/other/remediation1-s603-comment-placement.md` measures
  the composed line at **95 characters** against the **88-character** Black/Ruff limit
  (`pyproject.toml:85`, `:90`), and records that shortening the call expression would break the
  `cli.subprocess.run` monkeypatch seam in
  `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`.
- **Why it is not a gate:** every substantive requirement of the rule is met — pre-authorized
  pattern, `shutil.which` validation at line 148 with a fail-fast `AbandonSideEffectError`,
  single-line suppression scope, accurate rationale present and adjacent. The deviation is from the
  formatting clause alone, is measured rather than asserted, and is documented in evidence.
- **Verification commands:**
  - `git grep -n "# noqa" scripts/dev_tools/parallel_mutation_abandon_cli.py` → exactly one match,
    on the violating line.
  - `poetry run ruff check .` → `All checks passed!`
- **Remediation (optional):** either accept as recorded, or amend
  `.claude/rules/python-suppressions.md` to permit an adjacent rationale when the composed line
  would exceed the line limit. Amending the rule file is itself a policy change requiring review and
  is out of scope for F6.

## Advisory — no action required

| ID | Item | Location |
|---|---|---|
| A1 | `spec.md` Definition of Done (7) and Seeded Test Conditions (4) entirely unchecked while all 24 AC are checked. Not AC sources under `full-feature`. | `spec.md:687-698` |
| A2 | Two test modules at exactly 500 lines, zero headroom: `test_parallel_mutation_protocol_ops.py`, `test_parallel_mutation_protocol_properties.py`. Next edit forces a split. | `wc -l` |
| A3 | The rewritten pinned-edges test compares class partitions, so it no longer asserts `generation` equality (covered by a sibling test). Net strictly stronger. | `test_parallel_mutation_protocol_properties.py:335-387` |
| A4 | F6 op-classification imports form a second comment-separated block from the same package. Ruff `I` is selected and passes. Stylistic. | `_parallel_mutation_models.py:73-80` |
| A5 | Repo PowerShell coverage measured 94.8072% line / 94.4104% instruction against the reported 94.3362% — a counter-basis difference, not a regression. | `artifacts/pester/powershell-coverage.xml` |
| A6 | A `blocked` item may sit outside every current-generation cohort under F3 invariant 13, so the cohort map is not a total partition of `items[]`. Not a contention hazard. | `.claude/rules/parallel-orchestration.md` invariant 13 |

## Explicitly Out of Scope — Do Not Remediate

**Pre-existing PowerShell test failure.**
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists".

The hook reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a
mocked seam, so its verdict tracks live orchestration state. Confirmed by this reviewer as the
**only** failure in the 2053-case run (`artifacts/pester/pester-junit.xml`:
`failures="1"`, resolved to that test case by nearest-preceding-`<testcase>` offset matching).
Neither the hook nor its test appears in `git diff --name-only c939b5b8 fc10a471`.

**It must not be treated as a regression, must not be counted against this feature, and must not be
edited to force a green gate.** It was correctly left untouched across both commits.

**TypeScript parity port for the three F6 FR9 invariant families.** Deferred with a recorded
artifact at `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`. Do not
attempt the port on this branch: F6 has no designated TypeScript seam, the only comment-delimited
seam in `parallel-orchestrator-state-core.ts` is explicitly F7's, and F7 is executing concurrently
against the same integration branch.

## Cycle-1 Exit Criteria — verified satisfied

1. **R1 (Blocking)** resolved via option 1: spec/AC amendment plus engine change plus regression
   test. **Blocking count is 0.** ✔
2. **R2** resolved — F3's three op-classification constants imported at both sites (copies deleted),
   with 14 identity (`is`) assertions plus a parametrized guard on the three deleted copy names. ✔
3. **R3** resolved — FR9 invariant 3 and AC S9 amended to the delivered two-signal formalization;
   the amended text verified clause-by-clause against
   `_parallel_orchestrator_state_mode_completion.py:249-289`. ✔
4. **R4** recorded as a `docs/features/potential/` follow-up artifact; no TypeScript port attempted. ✔
5. **R5** resolved — both `# noqa: S311` removed, replaced by three confined `per-file-ignores`
   entries. **R6** substantively resolved (see N2). ✔
6. Full toolchain green in a single pass, re-run by this reviewer: black 393 clean, ruff clean,
   pyright 0 errors, pytest 3407 passed / 0 failed, line **92.0491%** (>= 85%), branch **84.1920%**
   (>= 75%), all seven F6 modules **100% line / 100% branch**. ✔
7. The single pre-existing Pester failure remains the only PowerShell failure and is unedited. ✔
