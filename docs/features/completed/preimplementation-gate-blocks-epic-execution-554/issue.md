# Bug: preimplementation-gate-blocks-epic-execution

- Issue: #554
- Work Mode: full-bug
- Promotion Type: bug
- State: OPEN
- Labels: bug
- Author: drmoisan
- Feature Folder: docs/features/active/preimplementation-gate-blocks-epic-execution-554
- Branch: bug/preimplementation-gate-blocks-epic-execution-554
- Acceptance-Criteria Source: `spec.md` (work mode `full-bug`)

## Provenance Note

Issue #554 pre-existed this preparation run. `potential_to_issue` was deliberately not
called and no new issue was created. The active feature folder was created for the
existing issue number via `new_active_feature_folder` with `issue_number=554`,
`type=bug`, `work_mode=full-bug`. That tool produced no `issue.md`, so this file was
authored from the live issue body and its amendment comment to carry the work-mode
marker required by the promotion-lifecycle contract.

The issue body cites `docs/features/potential/2026-08-25-preimplementation-gate-blocks-epic-execution.md`
as its source. That potential record is not present in this checkout, under either
`docs/features/potential/` or `docs/features/potential/promoted/`. Its absence is
recorded here rather than reconstructed.

## Requirement Sources and Precedence

Two sources define this requirement:

1. The issue body as originally filed (below, verbatim).
2. The maintainer amendment comment of 2026-08-26
   (<https://github.com/drmoisan/drm-copilot/issues/554#issuecomment-5425395081>),
   reproduced verbatim in `spec.md`.

**Where the body and the amendment disagree, the amendment governs.** The amendment
explicitly retracts one statement in the body's Expected Behavior; see the
"Superseded Requirement" section of `spec.md`.

---

## Issue Body (verbatim, as filed)

- Work Mode: full-bug

### Summary
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` denies every epic-execution
`Agent(orchestrator)` delegation, so a fully prepared epic cannot be executed. The gate reads
readiness from a single hard-coded single-feature checkpoint and applies a single-feature
readiness predicate, neither of which the epic (or parallel) execution surface can satisfy.

### Environment
- OS/version: Windows 11 Pro 10.0.26200 (also reproduces in any destination repo carrying the pushed-down `.claude` pack)
- Python version: n/a (PowerShell 7+ hook)
- Command/flags used: `/epic-run <epic-slug>` after a successful `/epic-plan <epic-slug>`
- Data source or fixture: destination-repo epic `quickfiler-bug-family`, commit `41eb2a5e`, verified live 2026-08-25; four verbatim denials recorded in the epic checkpoint's `delegation_failures[]`

### Steps to Reproduce
1. Run `/epic-plan <epic-slug>` to completion. Every child feature is promoted, planned, and preflight-cleared; `docs/features/epics/<epic-slug>/epic-kickoff.md` is committed to the integration branch.
2. Run `/epic-run <epic-slug>`. `epic-orchestrator` writes `artifacts/orchestration/epic-orchestrator-state.json` and delegates wave 0's first child feature via `Agent(orchestrator)` with the epic-mode kickoff line `Epic mode: true. ... epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. ...`.
3. Observe that the `PreToolUse` `Agent`-matcher hook denies the delegation.

### Expected Behavior
An epic-execution delegation whose kickoff prompt carries the epic-mode markers is evaluated for
orchestration readiness against the epic checkpoint the prompt itself names, using a readiness
predicate that matches the epic checkpoint's schema. A prepared epic executes without manual
intervention.

> **SUPERSEDED.** The amendment retracts "the epic checkpoint the prompt itself names".
> See `spec.md`, section "Superseded Requirement".

### Actual Behavior
Every epic-execution delegation is denied with:

`PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`

### Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet: four `delegation_failures[]` entries in the destination repo's
  `artifacts/orchestration/epic-orchestrator-state.json`, each carrying the
  `PREIMPLEMENTATION_GATE_BLOCKED:` reason string above.

### Impact / Severity
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The entire epic execution surface is unreachable. `/epic-plan` succeeds and `/epic-run` cannot
start, so epic-scale work can be prepared but never executed.

### Source
From: docs/features/potential/2026-08-25-preimplementation-gate-blocks-epic-execution.md

---

## Amendment

The 2026-08-26 amendment comment is reproduced verbatim in `spec.md` and is the
governing requirement source. It adds a previously unrecorded fault (Fault 1, the
seven-token substring classifier), measured evidence, the full required-fix
structure, non-goals and prohibitions, a ten-case test matrix, and four acceptance
criteria.

## Acceptance Criteria

For work mode `full-bug`, `spec.md` is the authoritative acceptance-criteria source.
This section is a pointer, not a second source. Do not check items off here.

See `spec.md` → `## Acceptance Criteria`.
