# Remediation Inputs — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T14-59
- Branch: `feature/parallel-planner-surface-443`
- Base: `epic/parallel-orchestration-integration` (merge base `b086cf6958ee4b628f60309cda80aac772304bc8`)

## Source Audit Artifacts

- `docs/features/active/2026-08-07-parallel-planner-surface-443/policy-audit.2026-08-08T14-59.md`
- `docs/features/active/2026-08-07-parallel-planner-surface-443/code-review.2026-08-08T14-59.md`
- `docs/features/active/2026-08-07-parallel-planner-surface-443/feature-audit.2026-08-08T14-59.md`

## Finding Counts

- Blocking: 4
- Non-blocking: 3
- Advisory: 3

## Root Cause

The kickoff contract has a producer (the fenced template in `.claude/skills/parallel-plan/SKILL.md`
`## Kickoff Artifact`) and a consumer (`scripts/dev_tools/parallel_kickoff_contract.py` with its
TypeScript parity port). Both were verified independently — the consumer against hand-authored
fixtures reaching 100% branch coverage, the producer against heading-presence assertions — and
never against each other. They disagree in two places. Remediation must fix the disagreement *and*
close the seam so it cannot reopen.

## Remediation-Required Findings

### R-1 (Blocking, from code-review B1) — resume-boundary sentence rejected

**Files:**
- `.claude/skills/parallel-plan/SKILL.md:369-371`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` (byte-identical mirror)
- `scripts/dev_tools/parallel_kickoff_contract.py:72-77`
- `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:19-20`

**Defect.** The skill template emits `Each item\nresumes at atomic execution from its committed
plan-path on its own pushed feature branch`. `RESUME_RE` admits only the alternation
`(?:Every item|items)`, so the template fails the mandatory `## Invocation Prompt` structural
check in both runtimes.

**Reproduction.**
```
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff <rendered-template>
```
EXIT_CODE 1, error: `Parallel kickoff invocation must structurally name the manifest, plan-home
branch, and atomic-execution resume boundary.`

**Preferred correction — widen the regex, not the template.** `spec.md:451` states the R5
requirement as "a resume-boundary sentence stating that **each item** resumes at atomic execution
from its committed plan-path **on its own pushed feature branch**". The specification's own wording
is `each item`, so the matcher — not the template — is the party that deviates. Add `Each item` to
the alternation in **both** runtimes:

```python
r"(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+"
```
```ts
/(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+.../i
```

Because the pattern is already case-insensitive in both runtimes, `Each item` also admits
`each item`. Add a parametrized test covering all three alternants in each runtime so the two
patterns cannot drift.

**Acceptable alternative.** Change the template's `Each item` to `Every item`. This is a
one-word edit but leaves the matcher narrower than R5, so spec criterion 20 would remain PARTIAL.

### R-2 (Blocking, from code-review B2) — `## Integrity` commit field name rejected

**Files:**
- `.claude/skills/parallel-plan/SKILL.md:381`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` (mirror)

**Defect.** The template emits `parallel/<slug>-plan head commit: <hex>`. `INTEGRITY_COMMIT_RE`
(`scripts/dev_tools/_parallel_kickoff_tables.py:28-30`) accepts only
`planning_commit: <hex>`. `parse_integrity` routes the line to an error *and* leaves
`planning_commit` as `None`, so the run-level provenance is silently lost in addition to the
document being rejected.

**Reproduction.** Same CLI invocation as R-1; second error line:
`Parallel kickoff integrity line is invalid: parallel/bugfix-batch-plan head commit: aabb...`

**Required correction — change the template, not the regex.** `spec.md:458-460` specifies that
"the epic's single `planning_commit` field generalizes to the head commit of
`parallel/<slug>-plan`" — the field *name* stays `planning_commit`; only its *semantics*
generalize. Change `SKILL.md:381` to:

```
planning_commit: <hex>
```

The surrounding prose at `SKILL.md:399-401` already states the plan-home-branch provenance
correctly and needs no change. Mirror the edit into the bundled payload and re-verify byte
identity with `cmp`.

**Scoping note.** `## Integrity` is optional, so R-2 fires only when the section is emitted while
R-1 fires unconditionally. Fixing only one leaves the surface broken; both are required.

### R-3 (Blocking, from code-review B4) — no test binds the template to the contract

**Files:** `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`,
`extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts`

**Defect.** No test relates the skill's kickoff template to the contract module.
`grep -n "Integrity\|head commit\|planning_commit"` over both surface-contract test modules returns
no matches (EXIT_CODE 1). This is why R-1 and R-2 survived execution despite 100% branch coverage
on the contract module.

**Required correction.** Add a producer/consumer seam test in each runtime:

1. Read `.claude/skills/parallel-plan/SKILL.md`, extract the fenced ```markdown block under
   `## Kickoff Artifact`.
2. Substitute a concrete slug for `<slug>`, a concrete ISO timestamp for `<iso8601>`, a concrete
   40-hex value for `<hex>`, and concrete cell values for the `| ... |` placeholder rows.
3. Assert `validate_parallel_kickoff_text(rendered) == []` (Python) and
   `validateParallelKickoffText(rendered)` has length 0 (TypeScript).

Add a second variant with the optional `## Integrity` section removed, so both the with-integrity
and without-integrity paths of the template are covered.

**Recommended follow-on.** Derive `tests/fixtures/parallel_kickoff/valid-kickoff.md` from the
skill template rather than maintaining it independently, or add an assertion that the fixture and
the template agree on the resume sentence and the integrity field name. The fixture currently uses
`items resume` and omits `## Integrity`, which is exactly why it passes while the template does
not.

### R-4 (Blocking, from code-review B3) — acceptance criteria checked without evidence

**File:** `docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md`

**Defect.** Two criteria are marked `[x]` but are not satisfied:

- `spec.md:655-660` (kickoff artifact per R5) — evaluated **FAIL**. The supporting record at
  `evidence/other/ac-checkoff.2026-08-08T14-45.md:55` cites only "the fenced template headings",
  a heading-presence check that cannot establish the criterion.
- `spec.md:689-692` (`parallel_kickoff_contract.py` validates the R5 kickoff shape) — evaluated
  **PARTIAL**, because `RESUME_RE` is narrower than R5's stated wording.

**Required correction.**
1. Revert both criteria to `- [ ]` immediately, preserving criterion text byte-for-byte per the
   `acceptance-criteria-tracking` preserve-text rule.
2. Re-check them only after R-1, R-2, and R-3 land, citing the new seam test from R-3 as the
   supporting evidence.
3. Update `evidence/other/ac-checkoff.2026-08-08T14-45.md` (or supersede it with a new timestamped
   artifact) so the recorded support for these two criteria names the seam test rather than the
   heading-presence check.

No AC checkbox was modified by the review agent; this action is left to remediation.

## Non-Blocking Findings (correct in the same cycle where practical)

### R-5 (Non-blocking, N1) — measurement evidence artifact missing command-step fields

**File:** `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/other/kickoff-module-size.2026-08-08T14-17.md`

Carries `Timestamp:` but no `Command:`, `EXIT_CODE:`, or `Output Summary:`, though it reports the
results of a line-count command. Per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, add the three fields. The reported
counts are independently confirmed correct (380 / 261 / 449 / 312 by `wc -l`), so only the record
form needs correction.

### R-6 (Non-blocking, N2) — evidence filename lacks the ISO timestamp

**File:** `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/phase0-instructions-read.md`

The only one of 29 evidence artifacts without a `yyyy-MM-ddTHH-mm` filename component. Rename to
`phase0-instructions-read.<timestamp>.md` using the timestamp already recorded inside the file.

### R-7 (Non-blocking, N3) — stale two-argument `conflicts(a, b)` reference

**File:** `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md:135`

Non-Goals cites `conflicts(a, b)`; the landed signature is `conflicts(a, b, config)`
(`scripts/dev_tools/_blast_radius_conflicts.py:137-139`). The delivered skill cites the correct
three-argument form at `SKILL.md:168` and `:232`, so no runtime surface is affected. The text is
Non-Goals prose, not an acceptance criterion, so the preserve-text rule does not bar editing it.
Either update to `conflicts(a, b, config)` or add a fourth supersession note alongside the three
at `spec.md:582-603`.

## Advisory Findings (no remediation required this cycle)

### A-1 — Record the verified parity scope for the kickoff module

All 21 error-string literals match between runtimes and all 92 TypeScript and 88 Python tests
pass. Five behavioral divergences exist outside that verified scope — backtick stripping, numeric
cell parsing (`int()` vs `Number()`), duplicate-path detection via prototype lookup, `repr` quote
selection, and the line-boundary set. Each mirrors the landed `epic-kickoff-artifact.ts`
precedent, so none is a regression introduced here. Recommendation: add a verified-scope paragraph
for `parallel_kickoff_contract.py` to `.claude/rules/parallel-orchestration.md` in the same form
F3 used for the state validators. Details in code-review A1.

Of these, the prototype-lookup class
(`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:243`) is the only one with a
cheap structural fix — `Object.create(null)` or a `Map` in place of the object literal — and could
be taken opportunistically.

### A-2 — Port the decision-logic comments into the TypeScript module

`.claude/rules/self-explanatory-code-commenting.md` scopes its requirements to Python, so this is
not a violation. The Python modules carry full docstrings, loop-intent comments, and
branch-rationale comments; the TypeScript port carries one-line doc comments on the three exported
symbols and none on the seven private helpers. Consider porting the rationale comments or adding a
header note directing readers to the Python module as the documented reference.

### A-3 — Establish the Integrity-template precedent

`.claude/skills/epic-plan/SKILL.md` contains no `## Integrity` template
(`grep -n "Integrity"` → EXIT_CODE 1), which is why the F4 author composed the section from
`spec.md`'s prose description of the field's meaning rather than its name. When R-2 lands, the
parallel skill becomes the precedent the epic surface still lacks.

## Exit Criteria for the Remediation Cycle

The cycle may close when all of the following hold:

1. The kickoff template rendered from `.claude/skills/parallel-plan/SKILL.md` validates with an
   empty error list through `artifact_type: "parallel-kickoff"` in **both** runtimes, with and
   without the optional `## Integrity` section.
2. The seam test from R-3 exists in both runtimes and passes.
3. `cmp` confirms byte identity between `.claude/skills/parallel-plan/SKILL.md` and its bundled
   mirror, and between `.claude/agents/parallel-planner.md` and its mirror.
4. Both criteria named in R-4 are either genuinely satisfied and re-checked with the seam test
   cited as evidence, or left unchecked.
5. The full toolchain passes in a single pass for both languages: Black, Ruff, Pyright, pytest;
   Prettier, ESLint, tsc, Jest.
6. Repo-wide coverage does not regress below the recorded post-change values (Python 91.82% line /
   83.80% branch; TypeScript 97.16% line / 89.54% branch), and every changed production file
   remains at or above 85% line and 75% branch.
7. No protected surface appears in the diff:
   `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/epic-planner.md`,
   `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`,
   `config/orchestration-routing.json`, `.claude/rules/**`,
   `scripts/dev_tools/epic_kickoff_contract.py`,
   `extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts`.

Note on exit criterion 7: if R-1 is taken via the preferred regex-widening route, it touches
`scripts/dev_tools/parallel_kickoff_contract.py` and
`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` — both F4-owned modules
delivered by this feature, neither a protected surface. `.claude/rules/parallel-orchestration.md`
is protected; A-1's suggested addition to it is advisory and must not be taken as part of this
remediation cycle without a separate authorization.
