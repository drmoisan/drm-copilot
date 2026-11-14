# Preflight Fixes — Agents Branch B Plan (confirming preflight)

Timestamp: 2026-11-14T20-09
Plan: plan-agents-branch-b.md
Signal: PREFLIGHT: ALL CLEAR (the fixes below are trivial and were applied in place in task text and preamble only; no task added, removed, reordered or checked)

## Round-1 defects re-verified

- Preamble `Selected when`, UB-1, [P0-T1]: selection is read from the observation lines `CLI-Lists-Claude-Agent:` and `Cloud-Lists-Claude-Agent:`, matching main plan `## Derivation Rules` and child 1 `owner-decision-plan.md` `## Decision Application Rules` rule 6; no `EXIT_CODE` reading remains.
- `E3-RESULT`, [P1-T1], [P1-T4]: `approved` with `#1025:evidence/other/<E3-RESULT>` exactly when the selection record names a result file present under `C1/evidence/other/`, otherwise `provisional` with the deferral reference `#1025:survey/difference-approval.md#owner-overrides` (the reference the main plan's selection record stores). This matches spec risk R4 and child 1 spec `### Decision Reference Format`.
- UB-5, [P0-T2], [P1-T1], [P1-T2]: `OVERRIDE-IDS` is recorded from `## Owner Overrides` rows and `## Disputed Cases` blocks with a non-empty `Owner-Decision` (child 1 spec `### Owner Approval Artifact`), and both set tasks exclude it, per child 1 rule 1 (precedence H2) and AD-5.
- [P1-T4]: per-entry outcome record with an origin marker and per-entry acceptance conditions is present.

## Fix 1 — [P1-T4] file-to-entry mapping key

- Defect class: evidence derivation (validator-blind); the assertion (each file mapped to exactly one `copilot:agent:` entry) is unchanged.
- Finding: same as Branch A confirm Fix 1. Child 1 spec `### Parity Matrix: Feature Entry` defines an agent entry's `name` as the agent file stem and states that consumers selecting by `name` also use `source_path`; the frontmatter `name:` alternative is not part of child 1's rule.
- Change: files are mapped by the entry's `source_path` equal to the file's repository-relative path, in the same wording as the Branch A plan.

## Fix 2 — [P1-T4] `NonConforming` definition

- Defect class: evidence derivation (validator-blind).
- Change: `NonConforming` is defined as the count of listed `copilot:agent:` and `copilot:handoff:` entries that fail any per-entry condition in the acceptance, as in the Branch A plan. The asserted value (`0`) is unchanged.

## Fix 3 — Execution Order citation of AD-5

- Defect class: citation correction.
- Finding: AD-5 is not in `spec.md` `### Owner Decisions` (AD-1 to AD-4); it is recorded in `autonomous_decisions` of the item checkpoint, where it states that both branch plans exclude overrides, list them as `override kept`, and do not stop.
- Change: the citation names that location, as in the Branch A plan.

## Not applied (checked)

- Branch A confirm Fix 3 (drop-approval forms in P0-T2) does not apply: Branch B has no drop-approval stop, and child 1 plan A gives `copilot:agent:*` the disposition `generated`, so no `copilot:agent:` entry appears in `## Disposition Proposals` (which lists proposed `dropped` entries).
- Generated case: spec `## Upstream Dependencies` states that a `.github/agents` generator target is not assumed, so the UB-2 stop for re-planning is the spec mechanism.
- AC5 for `override kept` entries: the outcome record lists every entry's `disposition` and `reason` with the file mapping, so the P2-T3 check-off of AC5 is evidence-checkable under the acceptance-criteria-tracking protocol.
- `decision_ref` `#1018:epic.md#shared-design` for handoffs is kept unchanged for consistency with the Branch A plan; it passes the child 1 pattern rule.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan (Poetry, worktree project), after the fixes; MCP `validate_orchestration_artifacts` (`plan`) after the fixes.
- EXIT_CODE: 0
- Output Summary: CLI `plan validation passed`; MCP `ok: true`.
