# plan-gate-nonzero-exit-seam-semantics (Potential)

- Date captured: 2026-08-20
- Author: atomic-executor (remediation cycle 2, feature `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`, issue #486)
- Status: Draft

## Problem / Why

`.claude/rules/plan-acceptance-gates.md` § Graceful degradation states that a repository seam
reporting a non-zero exit causes G2, G3, G5, and G6 to be **skipped** with no finding produced. The
shipped adapters do not implement that reading. Both translate every non-zero `git` exit into a
**negative answer**, which is not the same as a skip: a negative answer feeds the rule cascade and
can produce a finding.

Affected files, identically in both runtimes:

1. `scripts/dev_tools/plan_gate_discrimination.py` — `GitPlanGateRepository`. The runner is invoked
   with `allow_error=True`, and each query returns falsy when `code != 0` (lines 113-148 at capture
   time: `files_containing`, `is_tracked_file`, `is_tracked_directory` return empty/`False`, and
   `read_tracked_text` returns `""`).
2. `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` — the TypeScript twin, with
   the same `result.code !== 0` to negative-answer translation (lines 103-148 at capture time).
3. `.claude/rules/plan-acceptance-gates.md` § Graceful degradation — the governing prose the two
   adapters diverge from.

Consequence: a **fatal** `git` failure (for example exit 128 from a corrupt or absent repository)
is indistinguishable from a legitimate negative answer. `is_tracked_file` and
`is_tracked_directory` then both answer `False`, so a path-separator `--cov` value yields a spurious
**G3 Warning** claiming the value resolves to nothing tracked, when in truth nothing was resolvable
at all. The same substitution can yield a spurious **G5 Warning** for a search literal, because a
failed `git grep` is read as "absent from the tracked tree".

For `git grep` specifically, exit 1 is the ordinary **no-match** answer, so translating exit 1 into
an empty match list is correct by design. Only exit codes greater than 1 are fatal for `git grep`;
for `ls-files` and `show`, any non-zero exit is fatal.

Impact is confined to the **Warning** channel and is identical across the two runtimes, so no
cross-runtime divergence exists for this item. This is why it was classified Minor (M1) and
deferred.

## Proposed Behavior

Adopt one of the two options recorded in the cycle-2 remediation inputs. They are alternatives, not
steps; choosing one closes the item.

1. **Distinguish fatal exits in both adapters.** Treat `git grep` exit > 1, and any non-zero exit
   from `ls-files` and `show`, as a seam failure that skips the dependent rules rather than
   answering negatively. Raising from the adapter is one way to reach the existing
   graceful-degradation guards; returning a tri-state answer is another. Both runtimes must change
   together, with paired parity tests.
2. **Reconcile the rule prose to the shipped semantics.** Amend
   `.claude/rules/plan-acceptance-gates.md` § Graceful degradation so that "reports a non-zero exit"
   describes the negative-answer translation the adapters actually implement, and state the
   consequence for a fatal exit explicitly.

## Acceptance Criteria (early draft)

- [ ] The chosen option is applied in both runtimes at once, or in the rule file alone, with no
      period in which the two runtimes disagree.
- [ ] No finding string, severity constant (`G5_SEVERITY` included), rule ordering, or channel
      routing changes as a side effect.
- [ ] If option 1 is chosen, a fatal `git` exit produces zero G2, G3, G5, and G6 findings and no
      exception escapes `evaluate_plan_gates` or `evaluatePlanGates`.
- [ ] If option 1 is chosen, `git grep` exit 1 continues to mean no-match and continues to produce
      the ordinary tree-absence outcome.
- [ ] If option 2 is chosen, the amended prose is consistent with every shipped adapter branch and
      no code change is made.

## Constraints & Risks

- **This entry is documentation-only.** No code change accompanies it. Cycle 2 of issue #486 fixed
  only finding R5 (the missing Python guard on the G2/G3 coverage path); its Do Not Do list
  explicitly prohibits adapter exit-code rework, so folding M1 in would have expanded the cycle
  beyond its single Blocking finding.
- Option 1 changes gate output for a class of environment failure, so any test asserting the current
  spurious-Warning behavior must be revisited deliberately rather than adjusted to pass.
- Option 2 modifies a policy rule file. Policy files are read-only for most agents, so the change
  needs an explicitly scoped authorization.
- The distinction between fatal and non-fatal exit codes is command-specific, so a single shared
  threshold across `grep`, `ls-files`, and `show` would be wrong.

## Test Conditions to Consider

- [ ] Unit coverage: `git grep` exit 1 (no match), `git grep` exit 128 (fatal), `ls-files` exit 128,
      `show` exit 128, each in both runtimes.
- [ ] A path-separator `--cov` value evaluated against a fatally failing seam produces no G3 Warning
      under option 1.
- [ ] A checkable search literal evaluated against a fatally failing seam produces no G5 Warning
      under option 1.
- [ ] Cross-runtime parity fixtures asserting identical finding sets for every exit-code case.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
