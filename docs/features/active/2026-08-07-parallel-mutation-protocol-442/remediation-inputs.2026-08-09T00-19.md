# Remediation Inputs — 2026-08-07-parallel-mutation-protocol-442

- **Timestamp:** 2026-08-09T00-19
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Diff base (pinned):** `c939b5b8`
- **Source artifacts:**
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/policy-audit.2026-08-09T00-19.md`
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/code-review.2026-08-09T00-19.md`
  - `docs/features/active/2026-08-07-parallel-mutation-protocol-442/feature-audit.2026-08-09T00-19.md`

## Summary

| Classification | Count | Remediation required |
|---|---|---|
| Blocking | 1 | Yes — merge gate |
| Partial | 5 | R2 recommended before merge; R3-R6 may be batched |
| Advisory | 9 | Optional; not merge gates |

All automated gates are green. No remediation item is a gate failure; every item below was
found by inspection or by reasoning that no gate in this repository performs.

## Remediation-Required Findings

### R1 — BLOCKING — Admission into the current cohort ignores not-yet-launched cohort members

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **B1**;
  `code-review.2026-08-09T00-19.md` § Correctness Concerns → Blocking;
  `feature-audit.2026-08-09T00-19.md` § Discrepancies → **D1**.
- **Locations:**
  - `scripts/dev_tools/parallel_mutation_protocol.py:114-161` (`decide_admission`)
  - `scripts/dev_tools/parallel_mutation_protocol.py:127-130` (docstring asserting a mitigation
    that does not apply on the admit branch)
  - `.claude/skills/parallel-add/SKILL.md:69-79` (procedure step 4 and the follow-on claim)
  - `docs/features/active/.../spec.md:45-48` (FR1 step 4 — root cause)
  - `docs/features/active/.../spec.md:535-536` (AC S2), `user-story.md:88` (AC U1)
- **Violated expectation:** items scheduled to run concurrently must be pairwise blast-radius
  disjoint (`docs/features/epics/parallel-orchestration/epic.md` § Shared Design; design §6).
- **Reproduction (by construction; no test exercises this path today):** items 100 `in_flight`,
  200 `scheduled` in current cohort 0 and not yet launched, candidate 300 conflicting with 200
  only. `decide_admission(300, [(200, 300)], frozenset({100}))` returns
  `ADMIT_CURRENT_COHORT` with `triggers_recompute is False`, so 300 joins cohort 0 at unchanged
  generation. The next `max_concurrency` batch launches 200 and 300 concurrently on overlapping
  blast radius. Durability of the `scheduled`-in-current-cohort state is established by
  `.claude/skills/parallel-orchestrate/SKILL.md:120-124`.
- **Why no gate catches it:** F3 invariants 12-13 constrain cohort shape and coverage but not
  independence; F6's validator adds no cohort-independence check; F7's
  `PARALLEL_COHORT_BARRIER_VIOLATION` concerns ordering. `.github/workflows/ci.yml` declares
  `pull_request: branches: [main, development]`, so a PR based on
  `epic/parallel-orchestration-integration` schedules no CI run.
- **Verification command:** none available — the absence of any test or validator covering this
  path is part of the finding. Established by reading `decide_admission`'s signature (it never
  receives the current cohort's membership) against
  `.claude/skills/parallel-orchestrate/SKILL.md:120-124`.
- **Important scoping note:** the implementation is **faithful to its approved spec and AC**.
  This is a requirement-level defect inherited from design §8.3 line 173, not an executor
  error. It is not covered by any epic non-goal (`epic.md:86-101`).
- **Two acceptable resolutions — choose one:**
  1. **Fix (requires spec amendment first).** Amend `spec.md` FR1 step 4, AC S2, and
     `user-story.md` AC U1 to: admit into the current cohort only when the candidate conflicts
     with no member of the current cohort — `in_flight` **or** unstarted; otherwise defer and
     recolor. Then extend `decide_admission` to receive the current cohort's member set
     (a signature change), update `parallel-add/SKILL.md` step 4 and the engine docstring at
     lines 127-130, and add a test for the `scheduled`-member-conflict case. Because AC text
     changes, this is a scope change requiring a spec amendment, not a review-time addition.
  2. **Accept as a tracked limitation.** Record it explicitly in `spec.md` § Constraints &
     Risks (as a new item alongside the existing item 4 on mid-cohort-launch exclusion, which
     is a *different* concern) and open a follow-up issue against the epic. It must not ship
     undocumented.

### R2 — PARTIAL — F3 op-classification tuples copied without a binding assertion

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **P1**;
  `code-review.2026-08-09T00-19.md` § Correctness Concerns → Partial.
- **Locations:**
  - `scripts/dev_tools/_parallel_mutation_models.py:109-113`
    (`ITEM_SCOPED_OPS`, `OPS_WITH_NULL_PRIOR_STATE`, `OPS_WITH_NULL_NEW_STATE`)
  - `scripts/dev_tools/_parallel_orchestrator_state_mutations.py:92-99` (same three, duplicated)
  - F3's importable originals: `scripts/dev_tools/_parallel_state_records.py:49-56`
    (`OPS_REQUIRING_ITEM_KEY`, `OPS_REQUIRING_NULL_PRIOR_STATE`, `OPS_REQUIRING_NULL_NEW_STATE`)
- **Violated rule:** `.claude/rules/parallel-orchestration.md` § Enum Ownership (consume, do not
  restate what can drift); `.claude/rules/general-code-change.md` § Reusability.
- **Impact:** this is the same silent-divergence class the token seam was built to prevent — two
  sides at 100% coverage agreeing only by coincidence. If F3 amended
  `OPS_REQUIRING_NULL_PRIOR_STATE`, F6's two copies would diverge and
  `_validate_entry_completeness` would emit a "must not be null" error for a field F3 then
  requires null, with no failing test anywhere.
- **Verification command:**
  `grep -rn "OPS_REQUIRING_NULL\|OPS_WITH_NULL\|ITEM_SCOPED_OPS" tests/scripts/dev_tools/test_parallel_mutation_protocol.py tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`
  → returns no binding assertion (only `MUTATION_ENTRY_FIELDS` and item-state subset checks).
  Contrast the binding that *does* exist at
  `tests/scripts/dev_tools/test_parallel_mutation_protocol.py:86-101`.
- **Remediation (few lines, no behavior change):** either import F3's three constants at both
  sites, or add three equality assertions binding each local copy to its F3 counterpart, in the
  style of the existing enum-subset tests. Recommended before merge — it is cheap and it closes
  the exact failure mode this feature otherwise guarded against well.

### R3 — PARTIAL — FR9 invariant 3 is narrower than its spec/AC wording

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **P2** (full independent
  assessment); `feature-audit.2026-08-09T00-19.md` AC **S9** = PARTIAL.
- **Locations:** `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py:247-289`;
  `docs/features/active/.../spec.md:170-173` (FR9 invariant 3) and `:543` (AC S9).
- **Finding:** the closed-mode arm requires the conjunction of a `mutations[]` `op == 'close'`
  record **and** an empty current-generation cohort set. A spec-conformant `closed`-mode run
  records no `close` at all (`spec.md` FR3; `.claude/skills/parallel-close/SKILL.md:25-27`), so
  that arm is effectively unreachable on conformant data. The open-mode arm ("nothing may
  follow the close record") is a genuine additive invariant and the deliberate non-firing on an
  idle `open` run is **correct**, not a weakening.
- **Reviewer judgment (requested):** the formalization is **defensible and not a blocker**. The
  conjunction is load-bearing, not padding — I verified that requiring the close record alone in
  closed mode would break the landed F3 test at
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py:110`, because
  `build_valid_parallel_state` is `mode: "closed"` with a non-empty current-generation cohort and
  two `scheduled` items. The invariant that actually guards closed-mode completion is F3's own
  invariant 20 under `require_complete`, which F6 correctly does not duplicate.
- **Verification command:**
  `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutation_modes.py -q`
  → passes; `tests/.../test_validate_parallel_orchestrator_state_completion.py:110` is the
  landed constraint that pins the conjunction.
- **Remediation (documentation only, no code change):** amend `spec.md` FR9 invariant 3 and AC
  S9 to describe the two-signal formalization actually implemented — the module docstring at
  `_parallel_orchestrator_state_mode_completion.py:16-43` already documents it precisely — after
  which S9's `[x]` is accurate. Alternatively uncheck S9 pending that amendment.

### R4 — PARTIAL — Python/TypeScript parity gap for the three new FR9 invariants

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **P3**.
- **Locations:** `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
  (unmodified; F3 dispatch at lines 198-200, F7 seam at 307-314);
  `.claude/rules/parallel-orchestration.md` § Enforcement (asserts the TS port "reproduces the
  same invariants", verified 96/96 error strings).
- **Finding:** the Python validator now emits three families of errors the TypeScript core does
  not. A checkpoint whose `add` entry omits `new_state` yields a Python error and zero
  TypeScript errors. No parity test exists —
  `grep -rln "parity" extensions/drm-copilot/src --include=*.test.ts` returns nothing — so
  nothing detects the divergence.
- **Reviewer judgment (requested): correctly deferred, NOT Blocking for this PR.** Three
  reasons: (1) neither `spec.md` S9 nor any plan task required an F6 TypeScript port — S9 names
  only the Python helper and the single Python call site; (2) F6 had **no designated TypeScript
  seam** — the only comment-delimited seam in that file is explicitly F7's, and both F3's prose
  and the plan's Check C forbid F6 from writing inside it, so a port would have required
  contending for F7's seam or creating an unsanctioned one during a concurrent wave; (3) the
  rule file's parity claim is scoped to the F3 invariants it enumerates (1-21), and F6 may not
  amend that rule file. Adding a TypeScript port at review time would be a scope addition
  requiring a spec amendment.
- **Verification command:**
  `grep -n "mutation\|BEGIN\|END" extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
  → shows F3's `validateMutations` dispatch and the F7 seam, and no F6 invariant.
- **Remediation:** open a follow-up issue (or a `docs/features/potential/` entry) recording that
  `parallel-orchestrator-state-core.ts` lacks the F6 mutation-protocol invariants, and note in
  it that the rule file's parity statement is now scoped to invariants 1-21. Do not attempt the
  port on this branch.

### R5 — PARTIAL — Unauthorized `# noqa: S311` suppression

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **P4**.
- **Locations:** `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:125`
  and `:308`.
- **Violated rule:** `.claude/rules/python-suppressions.md` § Authorization Requirement — every
  `# noqa` must match a pre-authorized pattern or carry explicit user approval. S311 is not in
  the pre-authorized list (S603, ARG002, B008, TCH002/003, S310, S314, BLE001, S301, S108/S105).
- **Verification commands:**
  - `grep -rn "noqa: S311" --include=*.py .` → only the two occurrences in this feature; **no
    repo precedent**.
  - `grep -n "per-file-ignores" -A 3 pyproject.toml` → `"tests/**/*" = ["S101"]` only; S311 is
    not configured away.
- **Mitigating:** the underlying seeded-RNG choice is *mandated* by `spec.md` § Constraints &
  Risks item 2 and `.claude/rules/general-unit-test.md` § Determinism Infrastructure. Only the
  suppression mechanism is unauthorized, not the approach.
- **Remediation (policy/config, not code):** add `S311` to the `tests/**/*` per-file-ignores in
  `pyproject.toml`, **or** amend `.claude/rules/python-suppressions.md` to pre-authorize S311
  for seeded test-data generation, **or** record explicit approval in the feature evidence. Note
  that amending the rule file is itself a policy change requiring review.

### R6 — PARTIAL — `# noqa: S603` rationale is on an inert line

- **Artifacts:** `policy-audit.2026-08-09T00-19.md` finding **P5**.
- **Location:** `scripts/dev_tools/parallel_mutation_abandon_cli.py:152-153`.
- **Violated rule:** `.claude/rules/python-suppressions.md` § S603 requires the comment format
  `# noqa: S603 - static analysis can't verify runtime validation`, and its enforcement
  checklist requires the format be used verbatim.
- **Finding:** line 152 carries the full required text as a standalone comment, but Ruff honours
  a `noqa` only on the violating line, so line 152 is inert and the effective suppression on
  line 153 is a bare `# noqa: S603`. Line 152 also reads as a suppression while suppressing
  nothing. The substance is fully satisfied — pre-authorized pattern, `shutil.which` validation
  at line 148, single-line scope.
- **Verification command:** `poetry run ruff check scripts/dev_tools` → passes (the bare `noqa`
  on line 153 is what suppresses the finding, confirming line 152 is inert).
- **Remediation:** move the rationale onto line 153 and delete line 152. One-line change.

## Non-Remediation Items (Advisory — no action required)

Recorded for completeness from `policy-audit.2026-08-09T00-19.md` § Advisory. None is a merge
gate.

| ID | Item | Location |
|---|---|---|
| A1 | Branch carries **zero commits**; all 37 changes uncommitted/untracked. Must be committed before PR authoring | `git log`, `git status --porcelain` |
| A2 | Abandon-gate literal match evadable by `--disposition=abandon`; mitigated because the CLI independently refuses without the marker | `enforce-parallel-abandon-gate.ps1:38,105-107`; `parallel_mutation_abandon_cli.py:342-349` |
| A3 | `test_parser_composes_the_disposition_token` comparison is tautological; the genuine content is the two inner asserts | `test_parallel_abandon_token_seam.py:141-144,258-264` |
| A4 | P3's mutation sequence omits in-flight removals, so "other in-flight items unaffected by a detach/abandon" is unproven | `test_parallel_mutation_protocol_properties.py:319-343` |
| A5 | No dedicated integration-scenario suite; equivalent unit scenarios cover the ground | `spec.md` § Test Strategy; § Seeded Test Conditions bullet 4 honestly unchecked |
| A6 | `spec.md` Definition of Done and Seeded Test Conditions entirely unchecked while all 15 AC are checked | `spec.md:553-566` |
| A7 | Three test files at 498-500 lines leave no headroom under the 500-line cap | `test_parallel_mutation_protocol_ops.py` (500), `_properties.py` (499), `_protocol.py` (498) |
| A8 | PowerShell coverage uses an inclusion allowlist, so most production PS is unmeasured — pre-existing repo condition | `pester.runsettings.psd1` `CodeCoverage.Path` |
| A9 | `wave4-confinement-verification.md` diff stats stale (records 276/55 for plan/spec; now 284/61); conclusions unaffected | `evidence/qa-gates/wave4-confinement-verification.md` |

## Explicitly Out of Scope — Do Not Remediate

**Pre-existing PowerShell test failure.**
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`, case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists", `Expected: 'allow' But was: 'deny'`.

The hook reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of
a mocked seam, so its verdict tracks live orchestration state. Neither the hook nor its test is
in the branch diff. It fails identically at baseline
(`evidence/baseline/baseline-ps-test-coverage.md`) and is the only failure in the 2053-case run.

**It must not be treated as a regression, must not be counted against this feature, and must not
be edited to force a green gate.** It was correctly left untouched; that restraint is the right
call.

## Exit Criteria for Remediation

Remediation is complete when:

1. **R1** is resolved by one of its two documented paths — spec/AC amendment plus engine change
   and test, **or** an explicit `spec.md` § Constraints & Risks entry plus a tracked follow-up
   issue. Blocking count must reach **0**.
2. **R2** is resolved by importing or binding F3's three op-classification constants.
3. **R3** is resolved by amending the FR9 invariant 3 and AC S9 wording (or unchecking S9).
4. **R4** is recorded as a follow-up artifact; no TypeScript port on this branch.
5. **R5** and **R6** are resolved by the config/comment corrections described.
6. The full seven-stage toolchain passes in a single pass after every change, and Python
   coverage remains >= 85% line / >= 75% branch with all new modules at or above their current
   100%/100%.
7. The single pre-existing Pester failure remains the **only** PowerShell failure, unedited.
