# Advisory Finding Dispositions — Remediation Cycle 1

Timestamp: 2026-08-08T15-25

Task: [P6-T6]

This record gives an explicit disposition for each of the three Advisory findings raised by feature review at 2026-08-08T14-59. Advisory findings do not block the cycle; each is either TAKEN in this cycle or DEFERRED with a stated reason.

## A1 — Parity divergences outside the verified scope

Disposition: **DEFERRED**

Reason: the recommended remediation is a verified-scope paragraph added to `.claude/rules/parallel-orchestration.md`. That file is a protected surface for this cycle: the remediation plan's Non-Negotiable Constraints exclude any path under `.claude/rules/`, and `CLAUDE.md` plus `.claude/skills/policy-compliance-order/SKILL.md` both prohibit modifying policy documents. Writing the paragraph would require a policy-document edit this cycle is not authorized to make.

The divergence classes are enumerated here so the deferral is traceable rather than silent. Each mirrors the already-landed `extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts` precedent; none is a regression introduced by this feature.

| # | Divergence class | Nature | Mirrors epic precedent |
|---|---|---|---|
| 1 | `pythonRepr` quote selection | `parallel-state-shared.ts` always single-quotes, while Python's `repr` switches to double quotes when the value contains a single quote. Recorded repo-wide at `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. | yes |
| 2 | Integral floats | `JSON.parse` erases Python's `int`/`float` distinction, so an integral float value produces a different Python-side error count than the TypeScript side. | yes |
| 3 | Boolean/integer equality | `parallel-state-structures.ts` uses `===`, so a boolean is not selected the way Python's `True == 1` equality selects it, producing differing error counts. | yes |
| 4 | Optional-field representation | Python models the absent integrity commit as `planning_commit: None`; TypeScript models it as an omitted optional property `planningCommit?: string`. Both runtimes' seam tests assert the concrete captured value, so the representation difference is not observable at the contract boundary. | yes |
| 5 | Dictionary prototype lookup | The TypeScript port accumulates plan hashes in a plain object literal and tests membership with `planHashes[planPath] !== undefined` (`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:251`, previously line 243 before the [P6-T5] comment addition). A plan path colliding with an inherited `Object.prototype` member name could in principle behave differently from Python's `dict`. | yes |

The recommended `Object.create(null)` / `Map` change to divergence class 5 is also DEFERRED. Reason: the same construct exists unchanged in the epic analogue `extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts`, which this cycle is forbidden to modify. Changing only the parallel port would introduce a NEW asymmetry between two modules that are currently consistent, trading one documented divergence for an undocumented one. The change is outside the four Blocking findings this cycle addresses, and the correct scope for it is a follow-up that changes both ports together.

## A2 — TypeScript port carries no decision-logic comments

Disposition: **TAKEN**, in its comment-only form, via [P6-T5].

Implementation: a note was added inside the existing module-level doc comment of `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` directing readers to `scripts/dev_tools/parallel_kickoff_contract.py` and `scripts/dev_tools/_parallel_kickoff_tables.py` as the documented reference for the shared algorithm's decision rationale.

Reason for taking it in this form: the comment-only change carries no behavioral risk. `git diff` for the [P6-T5] hunk shows an addition inside the doc comment and zero executable-statement changes, so no test outcome, no error string, and no control-flow path can be affected. Pointing at the Python source rather than duplicating the rationale also prevents the two ports from drifting into inconsistent explanations of identical behavior. No numbered notes were introduced, per `.claude/rules/self-explanatory-code-commenting.md`.

## A3 — Epic surface supplies no `## Integrity` template precedent

Disposition: **DEFERRED**

Reason: the recommended remediation targets `.claude/skills/epic-plan/SKILL.md`, which the remediation plan's Non-Negotiable Constraints list explicitly as a protected surface this cycle must not modify.

Recorded observation: [P2-T1] makes the parallel skill the `## Integrity` template precedent that the epic surface still lacks. `.claude/skills/parallel-plan/SKILL.md` now publishes a fenced kickoff template whose integrity commit line reads `planning_commit: <hex>`, matching the field name its consumer's `INTEGRITY_COMMIT_RE` requires, and that agreement is now bound by seam tests in both runtimes. A later feature that adds an `## Integrity` template to the epic skill should follow this shape and should add the equivalent producer/consumer seam test rather than relying on heading-presence assertions.
