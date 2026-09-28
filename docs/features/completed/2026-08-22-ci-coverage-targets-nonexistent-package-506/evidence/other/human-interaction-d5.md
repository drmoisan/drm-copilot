# Unresolved Human-Interaction Requirement — Decision D5 (P5-T3)

Timestamp: 2026-08-25T22-41

Task: [P5-T3]
Class: **record-only task.** This task executes no command, so per the plan's evidence accounting
rule it records `Timestamp:` and the substantive content the task text prescribes, and carries
**no** `Command:` row and **no** `EXIT_CODE:` row.

Source of record: decision **D5** in the `### Decision record (six open items closed)` section of
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`, and the
`**Human-interaction requirement (...)**` bullet in that document's
`## Assumptions, Constraints, Dependencies` section.

---

## Response class

`response: scope_change`

This is the response class defined by the orchestrator-state human-interaction contract in
`.claude/rules/orchestrator-state.md`, whose per-requirement `response` value must be one of
`scope_change`, `exception`, or `halt`. `scope_change` is the correct class here because resolving
the requirement would change what is in this work item's write set, not waive a policy for it and
not stop the run. No `runbook_path` is required, because that field is mandatory only for a
requirement whose response is `exception`.

---

## The four blocked policy paths

These four files publish the defective coverage command as the approved Python test command. None
of them is in this work item's write set, and no task in this plan writes to any of them.

| # | Path | Nature |
| --- | --- | --- |
| 1 | `.github/instructions/python-unit-test.instructions.md` | Canonical policy source |
| 2 | `.github/instructions/python-suppressions.instructions.md` | Canonical policy source |
| 3 | `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | Bundled mirror of path 1 |
| 4 | `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | Bundled mirror of path 2 |

---

## Why the requirement exists and was not resolved here

`CLAUDE.md` states that the files under `.github/instructions/` are the canonical policy source and
must not be modified. `.github/instructions/general-code-change.instructions.md` instructs that a
conflicting instruction be surfaced rather than resolved unilaterally. The conflict is real and is
not hypothetical: those documents publish the defective command, so an agent that follows them will
continue to reproduce the very defect this work item repairs, one layer up from the CI workflow that
was corrected here.

Resolving the conflict requires a user decision between two options, and neither is available to an
agent:

1. **Authorize a scope change** that brings the four files into this work item's write set, so the
   published command is corrected at its source.
2. **Leave the four files unchanged** and accept the continued propagation of the defective command
   through the instruction surface, tracked as a separate follow-up.

**No user decision was obtained during this work item.** The requirement was recorded, not
resolved. This work item proceeded without it, deliberately and on the terms D5 states: the four
paths stay outside the write set, their absence from the change is asserted by AC-15, by the
working-tree gate [P4-T10], and by the committed-diff gate [P6-T2], and the unresolved decision is
recorded by this artifact.

A recommended follow-up is already carried by the `## Rollout & Follow-up` section of `spec.md`
under **Recommended follow-up, blocked policy files**: once the user decides, apply or formally
waive the correction to the two `.github/instructions/` files and their two bundled mirrors.

---

## Acceptance for [P5-T3]

| Condition | Result |
| --- | --- |
| The artifact exists | **PASS** — this file |
| It names all four blocked policy paths | **PASS** — the four rows of the table above |
| It names the response class `scope_change` | **PASS** |
| It states that no user decision was obtained during this work item | **PASS** — stated in bold above |

Verdict: **PASS.**
