# Epic Kickoff: subagentstop-envelope

Planned by epic-planner on 2026-10-11T14:17Z. All child features are prepared: issues promoted, active
folders created, research complete, spec/user-story written, atomic plans approved, preflight
ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json (branch:
epic/subagentstop-envelope-integration). Epic issue: #904.

## Invocation Prompt

Run `/epic-run subagentstop-envelope` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/subagentstop-envelope/epic.md. The integration branch
epic/subagentstop-envelope-integration already contains every prepared feature folder and approved atomic
plan; child features resume at atomic execution from their committed plan-path rather than
re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator runs in
isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR. The epic issue is #904 (epic_issue_num). Read the Execution Notes section
of docs/features/epics/subagentstop-envelope/epic-kickoff.md before the first wave.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 897 | docs/features/active/subagentstop-envelope-core-897 | 0 | C4 | docs/features/active/subagentstop-envelope-core-897/plan.2026-10-11T07-59.md |
| 897 | docs/features/active/subagentstop-envelope-artifact-gates-897 | 1 | C3 | docs/features/active/subagentstop-envelope-artifact-gates-897/plan.2026-10-11T07-59.md |
| 896 | docs/features/active/subagentstop-envelope-feature-review-coverage-896 | 1 | C3 | docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md |
| 903 | docs/features/active/subagentstop-envelope-orchestrator-family-903 | 1 | C3 | docs/features/active/subagentstop-envelope-orchestrator-family-903/plan.2026-10-11T07-59.md |

## Execution Notes

- Main sync before each wave. Before launching each wave, run `git fetch origin main` and
  `git rev-list --count origin/epic/subagentstop-envelope-integration..origin/main`. If the count
  is non-zero, run a dedicated chore child that merges `origin/main` into the integration branch
  through its own PR into the integration branch (the PR #882 pattern), wait for it to merge, and
  only then launch the wave. At planning completion the count was 0.
- Child feature branches (prepared, pushed, already merged into the integration branch):
  - E1 #897: `bug/subagentstop-envelope-core-897`
  - E3 #897: `bug/subagentstop-envelope-artifact-gates-897`
  - E4 #896: `bug/subagentstop-envelope-feature-review-coverage-896`
  - E2 #903: `bug/subagentstop-envelope-orchestrator-family-903`
- Every child execution delegation must begin with the canonical issue-number line
  (`Canonical issue number for this feature is <N>.`) and a lowercase `branch:` label naming the
  branch above. E1 and E3 share issue #897, so the branch label and the feature folder are the only
  distinguishing signals; always state both, and never delegate E1 and E3 with an issue number
  alone.
- Duplicate key. E1 and E3 are both keyed to #897 in the manifest; the planner checkpoint
  validator reports `issue_num must be unique`. The user directed that no new child issues be
  created. Resolve this before `/epic-run` (see epic.md Open Decisions).
- Each child checkpoint was prepared under `route_id: preparation`. The executing orchestrator
  must switch it to a non-terminal large route before Phase 0, because every child changes several
  PowerShell files plus mirrors.
- Wave 1 plans (E2, E3, E4) begin with an upstream-merge check and stop unless E1 is merged into
  the integration branch and its helper `.claude/hooks/subagentstop-envelope.ps1` defines
  `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason` and
  `Exit-SubagentStopBlock`. They are pinned to E1 spec blob `bf86505c`; they stop with a contract
  drift finding if E1's merged spec changes a function signature or its consumer rules.
- E1 changes the SubagentStop behavior that every later child, and the orchestrators themselves,
  run under: it deletes the inline command at `.claude/settings.json:218`. After E1 merges, confirm
  the settings file loads and the discovery-gate entry still fires before launching wave 1.
- After E2, E3 and E4 merge, the validators block for real. Two rules then start refusing work
  (reported by E3, unchanged by this epic): `validate-task-researcher-output.ps1:95-98` accepts only
  `<timestamp>-<short-name>-research.md` research names (more than 60 existing files, including
  E1's, use `research.<timestamp>.md`), and `validate-prd-feature-output.ps1:68` treats any number
  in an acceptance-criterion line as a numeric criterion that needs a derivation section. Expect
  task-researcher and prd-feature delegations in later work to be refused on these grounds;
  file follow-ups rather than widening scope.
- Ownership gap to assign to E2: `.claude/agents/prd-feature.md:18` registers E2's hook
  `validate-required-artifact-output.ps1` with `-RequiredArtifact` passed twice, which PowerShell
  normally rejects at parameter binding, so that registration likely never runs. E2 deferred it to
  E3 (agent owner) and E3's plan asserts that its branch leaves agent files unchanged. Tell E2's
  executing orchestrator to fix that registration (and its bundled mirror) inside E2.
- `pack-manifests/core.json` gains entries from E1, E2 and E4 at nearby lines; expect a merge
  conflict there at fan-in and resolve it by keeping every entry.
- E2 risk: SubagentStop hooks registered only in agent frontmatter (executor, required-artifact)
  are not confirmed to fire; E2 records what it observes.
- E4: the Codex feature-review hook does not use the E1 helper, because exit 2 in Codex means
  "continue the subagent"; it enforces the shared line floor only. #884's 7.30% Codex coverage
  figure appears stale (99.29% recorded in epic-852-main-sync evidence); E4 re-measures. CR-4 is
  resolved as fail-closed for an unreadable `CLAUDE.md` and defaults for a missing one.
- The bundled-copy parity pytest can fail locally on gitignored state files (#510); verify that
  criterion on PR CI.
- Issue closure: child PRs use `Refs #897`, `Refs #903` and `Refs #884` with no closing keyword;
  E4 may close #896. The integration-to-main PR (#904) closes #897 and #896 and references #903
  and #884.
- Operator conflict policy: overlap between wave-1 children blocks only when both sides edit the
  same functions or rules and the cost is comparable to the time saved by running in parallel.
- Throttle: the only limit is overall 5-hour usage, monitored by the coordinator. A brief API
  error or a credential change is transient; retry.
- Commit and push at every phase boundary. Never force-push. Delete nothing.
- Readiness residuals: the children were prepared as full-bug, so none has `user-story.md`; launch
  bindings and Codex receipts are not produced by the Claude runtime (as in epics #770, #771 and
  #852).
