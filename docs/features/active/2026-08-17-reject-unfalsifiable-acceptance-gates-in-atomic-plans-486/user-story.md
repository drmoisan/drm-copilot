# `2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans` — User Story

- Issue: #486
- Owner: drmoisan
- Status: Ready for Planning
- Last Updated: 2026-08-17T17-00

## Story Statement

- As a plan-authoring agent, I want the mandatory plan-acceptance gate to tell me when an acceptance command cannot discriminate between completed and untouched work, so that I repair the gate at authoring time instead of discovering the defect after preflight has consumed iterations.
- As an engineer reviewing an agent-authored plan, I want each such finding to name the plan task and state the mechanical remedy, so that remediation is directed at the gate rather than at the implementation.
- As the owner of the validator surface, I want advisory findings to be reported without failing the gate, so that a rule whose false-positive rate is not yet measured can ship without generating false rejections.

## Problem / Why

Atomic plans express acceptance criteria as concrete shell commands. Some of those commands produce the same result whether or not the work was done, so the gate does not discriminate between a completed task and an untouched one. A gate that cannot fail provides no verification; a gate that cannot pass produces a false blocking finding. Both are invisible at authoring time, because the command is syntactically valid and runs without error.

The #479 preflight run made the cost concrete. It required three iterations and produced 13 blocking findings, of which at least two were defects in the gates rather than in the code under review, and one plan assertion was empirically disproved by the executor. Each such gate consumes a full preflight iteration before anyone can determine that the code was never the problem.

Three failure modes are confirmed:

- **Phrase-wrapping greps.** An acceptance grep searches for a multi-word phrase that exists in the source but wraps across a line boundary, or is broken by formatter-inserted wrapping. `git grep` matches within a single line, so the search returns zero matches regardless of whether the phrase is present in the file.
- **Interpolated-literal greps.** An acceptance grep searches for an error message that the source constructs through f-string interpolation. The literal never appears contiguously in the source, so the search returns zero matches regardless of whether the message is produced at runtime.
- **Path-form coverage thresholds.** A plan asserted a per-file coverage threshold using a `--cov` value that names a filesystem path rather than an importable module. The executor established empirically that this form collects no coverage data at all. The reported figure is therefore not a measurement of the named file, and the threshold is unenforceable.

The common property is that the command's output is invariant with respect to the state of the work. Whether that surfaces as a false pass or a false blocking finding depends only on which direction the acceptance condition points.

## Personas & Scenarios

- **Persona: the plan-authoring agent (`atomic-planner`).**
  - Who they are: an automated agent that produces an atomic plan for a feature or bug, then hands it to an executor through a preflight loop.
  - What they care about: producing a plan that passes the mandatory validator gate on the first attempt and whose acceptance commands actually verify the work.
  - Constraints: the agent authors acceptance commands from the spec and from reading source, without executing them. It cannot observe that a phrase wraps, that a message is interpolated, or that a `--cov` value collects no data.
  - Goals and frustrations: it wants a mechanical signal at authoring time. Today the only signal arrives after an executor has run the gate and found it uninformative, which costs a full preflight iteration per defective gate.
  - Context and motivation: the validator gate is already mandatory before a plan can be reported as approved, so the agent already runs it. Detection must land inside that existing call to be useful.

- **Persona: the engineer reviewing the agent's output (repository owner).**
  - Who they are: the person who reads preflight findings and decides whether the code or the gate is at fault.
  - What they care about: not spending review time distinguishing a real regression from a gate that could never have passed.
  - Constraints: they cannot re-run every acceptance command by hand, and they need advisory signal to stay advisory so it does not train them to ignore the report.
  - Goals and frustrations: they want a Blocking finding to mean the plan is genuinely defective, and a Warning to mean the plan is worth a second look, with no possibility of a Warning silently becoming a rejection.

- **Scenario: an interpolated error message asserted verbatim.**
  1. The planning agent writes a task that hardens a validator and adds an acceptance command searching the source for the exact rendered error text.
  2. The agent runs the mandatory plan validator before reporting the plan as approved.
  3. The validator finds the literal nowhere in the tracked tree, and finds no contiguous occurrence of it in the plan document either, so nobody has been instructed to create it.
  4. The validator returns a Blocking finding naming the task identifier and the unmatched literal.
  5. The agent replaces the assertion with a search for the invariant fragment that the source actually contains, re-runs the validator, and the plan passes.
  6. Outcome: the defect is repaired before an executor ever runs, rather than after a preflight iteration is spent proving the code was not at fault.

- **Scenario: a coverage threshold that collects no data.**
  1. The planning agent writes a final-QC task asserting a per-module coverage threshold using a slash-path `--cov` value.
  2. The validator classifies the value as a path spelling of a module and returns a Blocking finding stating the exact dotted replacement.
  3. The agent applies the stated replacement and the plan passes.
  4. Outcome: the executed gate measures the module it names, so the recorded coverage figure is a real measurement rather than a number that would have been reported regardless of the work.

- **Scenario: a phrase that wraps in the target file.**
  1. The planning agent writes an acceptance command searching a hand-wrapped Markdown skill file for a multi-word sentence.
  2. The validator finds the sentence in the whitespace-normalised join of two adjacent lines but on no single line, and returns a Warning naming the task and recommending a shorter single-line token.
  3. The plan validator still exits 0 and the plan is accepted; the agent may act on the warning or record why the assertion is correct as written.
  4. Outcome: the author is told about a likely defect without a rule whose residual false-positive case is not yet measured being able to reject a correct plan.

## Acceptance Criteria

- [ ] **AC-U1.** A plan whose acceptance command searches for a literal that is absent from the tracked tree **and** absent from the plan document text is reported, and the report names the plan task and the unmatched literal. A plan whose literal is absent from the tree but quoted in the plan document is not reported. Verified by the two named tests recorded in `spec.md` AC1.
- [ ] **AC-U2.** A plan that names a `.py` filesystem path in a `--cov` argument is rejected, and the message states the correct dotted module form. Verified by the named test recorded in `spec.md` AC2.
- [ ] **AC-U3.** The check runs as part of the existing mandatory plan-validator call, with no new flag, no new artifact type, and no change to the MCP tool input schema. Verified by the named dispatch test and the schema property-key test recorded in `spec.md` AC4.
- [ ] **AC-U4.** Every report, whether it fails the gate or not, begins with the identifier of the plan task the command belongs to, and commands that cannot be attributed to a task are not reported at all. Verified by the four named tests recorded in `spec.md` AC5.
- [ ] **AC-U5.** A plan whose only finding is advisory is accepted: the validator exits 0 and the MCP call does not throw, while the advisory text is still surfaced to the author. Verified by the named test recorded in `spec.md` AC6.
- [ ] **AC-U6.** A plan with no findings behaves exactly as it did before the change, including the existing structural error strings, the success line, and the exit code. Verified by the named test recorded in `spec.md` AC3.

## Non-Goals

- **Semantic adequacy of acceptance criteria.** The check detects mechanically decidable non-discrimination only. Whether a gate tests the right behaviour, tests enough of it, or tests it at the right level remains a review responsibility and is not evaluated here.
- **The word-count wrap heuristic.** The issue's first Proposed-Behavior bullet asks for detection of patterns whose word count makes wrapping plausible. It is not shipped. There is no formatter wrap column for Markdown — no `.prettierrc*` file exists in the repository and Markdown is outside the Prettier format glob — and Markdown is the file type in which the observed failure occurred, so the heuristic would have no ground truth and a high false-positive rate. A high-noise advisory stream trains readers to ignore the entire report, which is the failure mode this feature exists to remove. Guidance about authoring wrap-tolerant assertions belongs in `.claude/skills/atomic-plan-contract/SKILL.md`, not in a validator rule.
- **The expected-exit-code declaration requirement.** The issue's fourth Proposed-Behavior bullet is out of scope and is tracked by `2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit.md`. Every rule shipped here is polarity-independent, so none of them needs that field; the extractor seam that will carry it is fixed in `spec.md`.
- **Any change to the PowerShell planner hook.** `.claude/hooks/validate-planner-output.ps1` is not modified. It already duplicates plan-structure validation, and adding these rules would create a third implementation to keep in parity with two others for no gain, because the MCP validator gate is already mandatory.
- **A grandfathering or exemption mechanism for committed plans.** None is added. The validator only ever runs against the artifact it is pointed at, and no CI job or test sweeps the plan corpus, so historical plans are never re-validated and are never blocked.
- **Reimplementing pattern matching.** The check delegates matching to `git grep`. It does not build an independent matcher, because a matcher that disagreed with the command under validation would create the same defect class this feature removes.
- **Fixing the pre-existing defects found during research.** The plan template's non-canonical `### Phase 0:` heading, the absent `quality-tiers.yml`, and the divergent PowerShell plan-structure implementation are recorded in the research artifact and are out of scope for this feature.
