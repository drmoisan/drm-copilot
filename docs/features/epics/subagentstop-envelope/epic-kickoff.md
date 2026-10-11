# Epic Kickoff: subagentstop-envelope

Planned by epic-planner on 2026-10-11T16:19Z. All child features are prepared: issues promoted, active
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
| 905 | docs/features/active/subagentstop-envelope-artifact-gates-905 | 1 | C3 | docs/features/active/subagentstop-envelope-artifact-gates-905/plan.2026-10-11T07-59.md |
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
  - E3 #905: `bug/subagentstop-envelope-artifact-gates-905` (re-keyed from #897; the older branch `bug/subagentstop-envelope-artifact-gates-897` is superseded and must not be used)
  - E4 #896: `bug/subagentstop-envelope-feature-review-coverage-896`
  - E2 #903: `bug/subagentstop-envelope-orchestrator-family-903`
- Every child execution delegation must begin with the canonical issue-number line
  (`Canonical issue number for this feature is <N>.`) and a lowercase `branch:` label naming the
  branch above. E3 is keyed to #905 (its slice of #897); use 905 in E3's canonical issue-number
  line, never 897.
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
- E3 corrects four strict rules before its validators block (coordinator decision; spec section
  `Rule Changes`): R1 research filenames accept the forms in use on main
  (`<timestamp>-<short-name>-research.md`, `research.<timestamp>.md`, date-only and compact-date
  forms, `research-addendum.<timestamp>.md`); R2 the prd-feature numeric-derivation rule applies
  only to derived counts, not thresholds, exit codes, issue or line numbers, or policy-quoted
  figures; R3 search-scope wording accepts "whole" and "worktree"; R4 the discovery gate skips
  empty tokens. E3's plan runs each validator against the main-branch artifact corpus and requires
  zero false positives before that validator switches to exit 2. No policy file is edited. If the
  corpus on main has changed by execution time, E3 re-runs the corpus gate on the current tip.
- E2 and E4 hooks are not covered by E3's corpus gate. When E2 and E4 make their validators
  block, a rule that never fired at runtime may refuse legitimate work; record any such refusal as
  a finding in that child's folder rather than widening its scope.
- Ownership gap to assign to E2: `.claude/agents/prd-feature.md:18` registers E2's hook
  `validate-required-artifact-output.ps1` with `-RequiredArtifact` passed twice, which PowerShell
  normally rejects at parameter binding, so that registration likely never runs. E2 deferred it to
  E3 (agent owner) and E3's plan asserts that its branch leaves agent files unchanged. The
  coordinator assigned it to E2: tell E2's executing orchestrator to fix that registration (and its
  bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`)
  inside E2. `.claude/agents/*.md` may be outside the executing agents' write scope; if E2 cannot
  edit it, E2 records it as an operator item in its feature folder and the epic report, and does
  not work around the permission.
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
- Issue closure: child PRs use `Refs #897`, `Refs #905`, `Refs #903` and `Refs #884` with no
  closing keyword; E4 may close #896. The integration-to-main PR (#904) closes #897, #905 and #896
  and references #903 and #884.
- Operator conflict policy: overlap between wave-1 children blocks only when both sides edit the
  same functions or rules and the cost is comparable to the time saved by running in parallel.
- Throttle: the only limit is overall 5-hour usage, monitored by the coordinator. A brief API
  error or a credential change is transient; retry.
- Commit and push at every phase boundary. Never force-push. Delete nothing.
- Readiness residuals: the children were prepared as full-bug, so none has `user-story.md`; launch
  bindings and Codex receipts are not produced by the Claude runtime (as in epics #770, #771 and
  #852).
