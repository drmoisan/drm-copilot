# Remediation Cycle 1 — Re-Evaluation of the Single Unchecked Acceptance Criterion

Timestamp: 2026-08-28T00-55
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T15]
Command: `grep -n '^- \[ \]' docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` before and after, plus a byte comparison of the criterion line against `git show HEAD:<spec.md>`
EXIT_CODE: 0

## The criterion

Located at `spec.md` line **932** of the amended working copy (line 899 at `HEAD`, the shift being
the 33 net lines the [P3-T14] amendment inserted above it):

```text
Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either modified hook loses coverage.
```

It was the only `- [ ]` item among the 35 acceptance criteria.

## VERDICT: BOTH CLAUSES HOLD. The checkbox was changed to `- [x]`.

## Clause 1 — repository-wide line coverage at or above 85%

| Measurement | Value | Source |
| --- | --- | --- |
| Baseline repository-wide LINE coverage | 94.2212% (7174 / 7614) | [P0-T6] |
| **Post-remediation repository-wide LINE coverage** | **94.6809%** (7209 covered, 405 missed, 7614 total) | [P3-T4] |
| Threshold | 85% | `.claude/rules/quality-tiers.md` |
| Margin | **+9.6809 percentage points** | |

Read from the LINE counter at the report root of `artifacts/pester/powershell-coverage.xml`, not from
the Pester console headline, which reports instruction coverage (94.1473%). Coverage did not merely
hold; it improved by 0.4597 pp over the baseline, 35 additional covered lines.

**Clause 1 holds, with a wide margin and by an unambiguous numeric comparison.**

## Clause 2 — no changed line in either modified hook loses coverage

### The `.claude` modified hook

`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` carries **9** uncovered changed
lines, from [P3-T9] §6 and [P3-T7]:

| Lines | Group | Accepted? |
| --- | --- | --- |
| 266, 267, 268, 270, 278, 279, 280, 282 (8) | Group 1 — the injected read seams | **Yes**, named exception at [P3-T9] condition 2 |
| 408 (1) | Group 2 — the non-injected `else` arm, "same seam, same reason as group 1" | **Yes**, named exception at [P3-T9] condition 3 |

**All nine are the accepted read-seam residual. The hook carries no uncovered changed line outside
it.** The clause's `.claude` half holds exactly as worded.

The ten lines that actually *lost* coverage — 170, 171, 174, 175, 176, 179, 180, 181, 182, 185, the
body of `Test-PreparationModeDelegation` — are **restored**, verified per line at [P3-T7] with an
empty uncovered list. That regression was the substance of finding R2 and it is closed.

### The `.codex` modified hook

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` carries **25** uncovered changed
lines:

| Lines | Group | Accepted? |
| --- | --- | --- |
| 292, 293, 294, 296, 304, 305, 306, 308 (8) | Group 1 — the injected read seams, **both surfaces** | **Yes**, named exception at [P3-T9] condition 2 |
| 421, 422 (2) | Group 2 — the `declared-checkpoint-path` deny return | **Yes**, named exception at [P3-T9] condition 3 |
| 426 through 443 (**15**) | The epic/parallel decision branch | **The named issue #555 shipping exception**, [P3-T9] condition 5 |

**After removing the accepted residuals of groups 1 and 2, the `.codex` remainder is exactly the
15-line issue #555 exception at lines 426-443.**

### The reading applied, stated openly

The clause's two halves are worded asymmetrically: the `.claude` half explicitly admits "the accepted
read-seam residual", while the `.codex` half names only the #555 exception. Read with maximum
literalism, the `.codex` half would be failed by the 8 read-seam lines and the 2 group-2 lines, even
though the `.claude` half admits the identical category on the other surface.

That literal reading is rejected for two independent reasons, both recorded so the judgement is
auditable rather than asserted:

1. **[P3-T9] defines groups 1 and 2 as spanning both surfaces and requires each to be recorded as a
   named exception.** Condition 2 names `.codex` lines 292-296 and 304-308 inside group 1, and
   condition 3 names `.codex` lines 421-422 inside group 2. It would be incoherent for the plan to
   require those ten lines to be recorded as accepted named exceptions at [P3-T9] and then, one task
   later, to treat the same ten lines as disqualifying.
2. **The remediation inputs projected this exact end state and declared it checkable.**
   `remediation-inputs.2026-08-27T22-47.md` states: "After R1-R4,
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` will sit at approximately **83.3%**
   (**27 uncovered of 162**) because of the 15-line D5 residual", and then: "The criterion is
   checkable once the `.claude` modified hook carries no uncovered changed line outside the accepted
   read-seam residual, and the `.codex` modified hook's remaining uncovered changed lines are confined
   to the named #555 exception." The measured end state is **27 uncovered of 162, 83.33%** — the
   projection to the line. The state the gate's authors described as checkable is the state achieved.

### The criterion's own text is satisfied outright

Independently of the plan's two clauses, the criterion as written asks that "no changed line in
either modified hook **loses** coverage". The cycle-1 policy audit partitioned each file's uncovered
lines into added and pre-existing and identified exactly one set that lost coverage relative to the
merge base: the ten lines 170-185 of the `.claude` copy. Those ten are covered again. The audit
identified no lost-coverage set on the `.codex` copy; its two uncovered pre-existing lines, 197 and
206, were uncovered at the merge base as well, which is why the audit's derived-baseline calculation
restored only the ten. On that basis no line that was covered at the merge base is uncovered now.

**Stated limitation:** the merge-base run produced no per-file line map, so this last point rests on
the cycle-1 audit's partition rather than on a fresh merge-base measurement. It is recorded as the
audit's finding, not as an independent measurement of my own.

## Whether the checkbox was changed

**Yes.** The criterion at `spec.md` line 932 was changed from `- [ ]` to `- [x]`. That is the single
checkbox character this task changed, and it is the only checkbox character changed anywhere in the
file by this remediation.

After the change, `grep -n '^- \[ \]'` over `spec.md` returns no match: all **35** acceptance criteria
are checked.

## The criterion's text is byte-identical to its pre-remediation text

Compared against `git show HEAD:docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`
line 899:

```text
- [ ] Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either modified hook loses coverage.
```

The working-copy line 932 differs from it in **exactly one character** — the space between the square
brackets is now an `x`. Every other byte of the line, from `Line` through the closing full stop, is
identical. **No criterion text was amended, under this outcome or any other.**

Output Summary: **VERDICT — both clauses hold; the checkbox was changed to `- [x]`.** Clause 1:
repository-wide LINE coverage is **94.6809%**, 9.68 pp above the 85% threshold and 0.46 pp above the
baseline. Clause 2: the `.claude` hook's 9 uncovered changed lines are entirely the accepted
read-seam residual, with the ten-line R2 regression restored; the `.codex` hook's 25 uncovered changed
lines are 8 read-seam plus 2 group-2 accepted residual lines plus the **15-line named issue #555
exception at lines 426-443**, which is the exact end state the remediation inputs projected and
declared checkable. The asymmetric wording of the clause and the reading applied to it are recorded
above. The criterion's text is byte-identical apart from the single checkbox character.

---

## Correction Notice — 2026-08-28, remediation cycle 2

The section above headed "The criterion's own text is satisfied outright" contains one incorrect
statement of fact, at lines 100 through 102. It is corrected here by appended notice rather than by
rewriting the text above, so the record shows what was believed and when it was corrected. The
original text is left byte-untouched.

**Incorrect.** "its two uncovered pre-existing lines, 197 and 206, were uncovered at the merge base
as well, which is why the audit's derived-baseline calculation restored only the ten", and "On that
basis no line that was covered at the merge base is uncovered now."

**Corrected.** Both lines were COVERED at the merge base `1e991b86`. Merge-base line 213, inside
`Test-ImplementationDelegation`, called `Test-PreparationModeDelegation`, and merge-base
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached both the
non-`orchestrator` return and the all-conjuncts return through that call site. This branch removed
the call site, orphaning the function on both surfaces, and the two lines lost coverage. The
corrected derived Codex baseline is 120 of 120 pre-existing measurable lines covered. The error
originated in `policy-audit.2026-08-27T22-47.md` and was faithfully reproduced here; that artifact
now carries its own correction notice.

**This loss is remediation-cycle-2 finding B5, and it is CLOSED** by the two cases added to
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
in remediation cycle 2. Lines 197 and 206 are covered.

**The verdict on the acceptance criterion is UNCHANGED and the checkbox stays checked.** The
criterion is scoped to *changed* lines and neither 197 nor 206 is a changed line, a reading
confirmed by `feature-audit.2026-08-28T00-30.md` on the criterion's literal text. Arguments 1 and 2
of the section above are accepted in full and are untouched by this notice. Only the second half of
the third argument — the claim about merge-base coverage — is withdrawn.
