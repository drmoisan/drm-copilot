# reject-unfalsifiable-acceptance-gates-in-atomic-plans (Potential)

- Date captured: 2026-08-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/ (Issue #486)
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/486

## Restoration Note

This lifecycle record was restored by hand. `mcp__drm-copilot__potential_to_issue` returned `ok: true` with this `destination_path`, and an immediate probe confirmed the file present at 6295 bytes. A second probe taken after `mcp__drm-copilot__new_active_feature_folder` found the path absent. The observed sequence matches the defect tracked in `docs/features/potential/2026-08-15-potential-to-issue-loses-promoted-record.md`; this is the sixth recorded occurrence. The body below is the authored potential text as promoted, with the promotion metadata added above.

## Problem / Why

Atomic plans express acceptance criteria as concrete shell commands. Some of those commands produce the same result whether or not the work was done, so the gate does not discriminate between a completed task and an untouched one. A gate that cannot fail provides no verification; a gate that cannot pass produces a false blocking finding. Both are invisible at authoring time, because the command is syntactically valid and runs without error.

The #479 preflight run made the cost concrete. It required three iterations and produced 13 blocking findings, of which at least two were defects in the gates rather than in the code under review, and one plan assertion was empirically disproved by the executor. Each such gate consumes a full preflight iteration before anyone can determine that the code was never the problem.

Three failure modes are confirmed:

- **Phrase-wrapping greps.** An acceptance grep searches for a multi-word phrase that exists in the source but wraps across a line boundary, or is broken by formatter-inserted wrapping. `git grep` matches within a single line, so the search returns zero matches regardless of whether the phrase is present in the file.
- **Interpolated-literal greps.** An acceptance grep searches for an error message that the source constructs through f-string interpolation. The literal never appears contiguously in the source, so the search returns zero matches regardless of whether the message is produced at runtime.
- **Path-form coverage thresholds.** A plan asserted a per-file coverage threshold using `poetry run pytest --cov=<path>.py`. The executor established empirically that this form collects no coverage data at all. The reported figure is therefore not a measurement of the named file, and the threshold is unenforceable.

The common property is that the command's output is invariant with respect to the state of the work. Whether that surfaces as a false pass or a false blocking finding depends only on which direction the acceptance condition points.

## Proposed Behavior

Add a plan-authoring check that rejects acceptance commands which cannot discriminate, and run it before a plan is accepted for execution rather than after preflight has already burned iterations on it.

At minimum the check should:

- Detect grep-family acceptance commands whose search pattern spans a word boundary count high enough that line-wrapping is plausible, and require either a pattern that tolerates wrapping or a structural assertion in place of a text search.
- Detect grep-family acceptance commands whose search pattern is a string literal that does not appear contiguously in any tracked file, and reject the command as unsatisfiable at authoring time.
- Reject `--cov=` arguments that name a filesystem path ending in `.py` rather than a module or package, since that form collects no data.
- Require every acceptance command to declare its acceptance condition explicitly, including the expected exit code, so that a gate whose acceptance is a non-zero exit is expressible. This depends on the evidence-schema change tracked in `2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit.md`; the two are related but separately scoped.

The check reports each violation with the offending plan task identifier and the specific reason, so the author can repair the gate rather than the code.

## Acceptance Criteria (early draft)

- [ ] A plan containing an acceptance grep for a literal absent from every tracked file is rejected, and the message names the plan task and the unmatched pattern.
- [ ] A plan containing `--cov=` with a `.py` path argument is rejected, and the message names the correct module or package form.
- [ ] A plan whose acceptance commands are all discriminating passes unchanged, producing byte-identical output to the pre-change tool for the existing plan corpus.
- [ ] The check is invoked automatically as part of plan acceptance, not only on explicit request.
- [ ] Every rejection identifies the plan task identifier, so remediation is directed at the gate rather than at the implementation.

## Constraints & Risks

- **False rejection risk.** A pattern that is legitimately absent at plan-authoring time because the task creates it is a normal and expected case. The check must distinguish "absent because the work is not done yet" from "absent because the pattern can never match". The interpolated-literal case is detectable structurally; the wrapping case may only be reportable as a warning.
- **Scope discipline.** The goal is to catch mechanically detectable non-discrimination, not to judge whether a gate tests the right thing. Semantic adequacy of acceptance criteria stays with review.
- **Parity.** If the check lands in a surface that has both a Python implementation and a TypeScript port, both must be updated together, consistent with the parity requirements already recorded for the validator surfaces.
- **Existing plans.** Applying the check retroactively to the committed plan corpus will surface violations in plans already executed. Those are informational; the check must not block on historical artifacts.

## Test Conditions to Consider

- [ ] Unit coverage areas: pattern-absence detection against a controlled tracked-file set; `--cov=` argument-form classification for path, module, and package forms; the plan-task identifier attached to each rejection; the no-violation path producing an empty result.
- [ ] Integration scenarios: a synthetic plan carrying one instance of each of the three confirmed failure modes is rejected with three distinct messages; a clean plan from the existing corpus passes.
- [ ] CLI/API examples: exit-code and message-format contract for the check, including the zero-violation case.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/reject-unfalsifiable-acceptance-gates-in-atomic-plans/` folder from the template
