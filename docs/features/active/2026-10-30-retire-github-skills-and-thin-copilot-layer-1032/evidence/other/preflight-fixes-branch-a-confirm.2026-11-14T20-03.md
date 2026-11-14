# Preflight Fixes — Agents Branch A Plan (confirming preflight)

Timestamp: 2026-11-14T20-03
Plan: plan-agents-branch-a.md
Signal: PREFLIGHT: ALL CLEAR (the fixes below are trivial and were applied in place in task text and preamble only; no task added, removed or reordered)

## Round-1 defects re-verified

- [P0-T1] / UA-A1: the acceptance reads both E3 observation lines `CLI-Lists-Claude-Agent:` and `Cloud-Lists-Claude-Agent:` from `E3-RESULT` and records `blocked: premise_falsified` on a missing file or either value other than `yes`. This matches the main plan `## Derivation Rules` and child 1 `owner-decision-plan.md` `## Decision Application Rules` rule 6, which uses the same two field names.
- UA-A2 / UA-A5 / [P0-T2] / [P1-T1] / [P1-T2]: `OVERRIDE-IDS` is recorded in P0-T2 from `## Owner Overrides` rows and decided `## Disputed Cases` blocks (field `Owner-Decision`, as in child 1 spec `### Owner Approval Artifact`), and both set tasks exclude it. This is consistent with child 1 rule 1 (precedence H2).
- [P1-T4]: the outcome record lists every `copilot:agent:` and `copilot:handoff:` entry with the four fields and an origin marker, and has per-entry acceptance conditions.

## Fix 1 — [P1-T4] file-to-entry mapping key

- Defect class: evidence derivation (validator-blind); the correction keeps the assertion (each file mapped to exactly one `copilot:agent:` entry).
- Finding: child 1 spec `### Parity Matrix: Feature Entry` defines an agent entry's `name` as the "agent file stem" and never as the frontmatter `name:` value. For a `<x>.agent.md` file the spec does not say whether the stem is `<x>` or `<x>.agent`, and child 1 has not been implemented on any branch, so nothing in the tree settles it. Under the `<x>.agent` reading, the previous rule (file name without `.agent.md`, or the `name:` value) maps no file to any entry. The `name:` alternative is also not part of child 1's rule. The same spec row states that consumers that select by `name` also use `source_path`.
- Change: files are now mapped by the entry's `source_path` equal to the file's repository-relative path. That key is defined by child 1 for every entry, including `Powershell DI Unit Test Engineer.agent.md`, whose name contains spaces.

## Fix 2 — [P1-T4] `NonConforming` definition

- Defect class: evidence derivation (validator-blind; the executor must not choose the evidence it is judged against).
- Change: `NonConforming` is defined as the count of listed `copilot:agent:` and `copilot:handoff:` entries that fail any per-entry condition in the acceptance. The asserted value (`0`) is unchanged.

## Fix 3 — [P0-T2] drop-approval derivation

- Defect class: evidence derivation (validator-blind).
- Finding: under child 1 rule 1, an empty owner answer to a `## Disposition Proposals` row accepts the proposal. A proposed `dropped` with no answer is therefore an owner approval to drop, and the task text did not say so.
- Change: P0-T2 now names the three forms of a drop approval. The UA-A2 stop condition is unchanged.

## Fix 4 — Execution Order citation of AD-5

- Defect class: citation correction.
- Finding: AD-5 is not recorded in `spec.md` `### Owner Decisions`, which lists AD-1 to AD-4. It is recorded in `autonomous_decisions` of the item checkpoint.
- Change: the citation now names that location. The governing rule remains child 1 H2.

## Probes (read-only, under SCRATCH)

- Binding resolution on the current tree: 106 prompt `agent:` and handoff `agent:` values, zero unresolved under the P1-T3 rule.
- `.github/agents`: 50 `*.agent.md` files, 20 declare `handoffs:`; no frontmatter `name:` value equals the stem of another file; the four `docs-*` roles have `name:` equal to the `name:` of their `.claude/agents` counterparts.
- Root Prettier `format:check` scope in the worktree: exit 0 (`All matched files use Prettier code style!`), so stage 1 of the P1-T5 phase gate has no pre-existing finding in that scope.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan (Poetry, worktree project), after the fixes; MCP `validate_orchestration_artifacts` (`plan`) after the fixes.
- EXIT_CODE: 0
- Output Summary: CLI `plan validation passed`; MCP `ok: true`.
