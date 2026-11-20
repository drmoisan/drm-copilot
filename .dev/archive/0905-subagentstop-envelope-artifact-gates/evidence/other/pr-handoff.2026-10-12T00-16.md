# PR handoff for the epic orchestrator (plan [P12-T20], issue #905)

Timestamp: 2026-10-12T00-16

## Pull request

- Base: `epic/subagentstop-envelope-integration`
- Head: `bug/subagentstop-envelope-artifact-gates-905` per the plan; the work is pushed to the substituted execution branch `bug/subagentstop-envelope-artifact-gates-exec-905` (branch substitution 1, `evidence/other/branch-substitution.2026-10-11T17-05.md`). Open the PR from `bug/subagentstop-envelope-artifact-gates-exec-905`.
- Body requirements: the body must contain `Refs #905` and `Refs #897`, and none of `Closes`, `Fixes`, `Resolves`, or their variants (`Close`, `Closed`, `Fix`, `Fixed`, `Resolve`, `Resolved`) for either issue. Closing happens at the epic integration PR (epic issue #904).
- AC-30: the PR-body clause is verified by the epic orchestrator with `gh pr view <number> --json body`. AC-30 is not checked off by this plan (RS-11).

## Scope result ([P12-T14])

`evidence/qa-gates/final-scope-diff.2026-10-12T00-15.md`: three-dot diff against `origin/epic/subagentstop-envelope-integration` (tip ebf4504ae6f881c5b34b91082b3df474c04d13f2) lists 76 paths, all in W-ALLOWED (four W-HOOKS files, four W-MIRRORS files, seven W-SUITES-CHANGED files, the feature folder); no W-FORBIDDEN path; no #897-folder deletion on this branch; porcelain clean outside the feature folder and runtime-local prefixes.

## CI note

CI on an epic-child PR may require a manual `ci.yml` dispatch, because the workflow triggers on PRs into `main`/`development` only (spec Rollout & Follow-up).

## Follow-ups for the epic-level report (spec Rollout & Follow-up; not E3 work)

- Live smoke run per agent type for frontmatter-registered hooks and working-directory resolution.
- Double registration of pr-author and prd-feature (E1 decision).
- A SubagentStop source-scanning guard against `CLAUDE_HOOK_INPUT`, covering agent-frontmatter registrations, owned by a single child (preferably E1).
- The latent `{ ExitCode; Reason }` versus `Ok`/`Message` shape mismatch in the decision functions remains unreachable while the tail checks the dependency decision first (research section 2.5).
- Specs carrying a derived numeric criterion: the [P5-T9] after-change prd-feature corpus run reported 109 `TRIGGERED-SPEC:` paths (listed below; recorded in `evidence/qa-gates/corpus-prd-feature.2026-10-11T15-03.md`, `## After`). They are not false positives and are not edited by E3.
- Latent discovery prefix match on `scripts/dev_tools/discovery/profile_cli.py`: the [P7-T6] run recorded `TOKEN: SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py | scripts/dev_tools/discovery/profile_cli.py | profile` and `ALLOW` (unreachable with the default declaration reader); recorded in `evidence/qa-gates/corpus-discovery.2026-10-11T15-04.md`.

## Acceptance criteria left unchecked

- AC-27 and AC-29 were checked off: [P12-T12] recorded four `equal` mirror pairs and the parity pytest exit 0 (`evidence/qa-gates/final-mirror-parity.2026-10-12T00-12.md`); [P12-T5] recorded `failures=0 errors=0` (`evidence/qa-gates/final-full-pester.2026-10-11T23-57.md`) and [P11-T20] recorded `failed=0` (`evidence/qa-gates/ac29-agent-registrations.2026-10-11T23-34.md`).
- AC-30 remains unchecked; owner: epic orchestrator (PR-body verification).

## Specs reported as TRIGGERED-SPEC by [P5-T9]

```text
TRIGGERED-SPEC: docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md
TRIGGERED-SPEC: docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md
TRIGGERED-SPEC: docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md
TRIGGERED-SPEC: docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md
TRIGGERED-SPEC: docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-04-26-push-down-claude-customizations-162/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-06-17-pester-adapter-id-collision-198/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-06-24-orchestrator-state-routing-contract-mismatch-230/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-06-24-relocate-research-canonical-location-227/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-03-two-axis-model-selection-286/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-04-bundle-model-routing-deps-312/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-17-legacy-discovery-agent-roles-365/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-17-legacy-discovery-documentation-371/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-17-legacy-discovery-schemas-359/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-21-poshqc-bundled-mock-scope-failure-392/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-25-bundled-coverage-path-portability-409/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-25-claude-rules-vitest-jest-divergence-422/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-25-npm-audit-brace-expansion-dos-414/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-07-25-orchestrator-completion-hook-false-block-413/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-04-mixed-promotion-agent-delegation-receipts-435/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-07-parallel-blast-radius-447/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-07-parallel-orchestrator-surface-441/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-07-parallel-schema-validators-444/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-15-blast-radius-module-map-forces-serial-runs-472/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-25-repair-invalid-codex-skill-frontmatter-549/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-28-conflictresult-truthiness-always-true-576/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-07-mergeable-project-file-overlaps-643/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-13-collect-pr-context-explicit-target-675/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-13-epic-merge-gate-authorization-record-670/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-13-target-worktree-resolution-module-669/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md
TRIGGERED-SPEC: docs/features/completed/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md
TRIGGERED-SPEC: docs/features/completed/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md
TRIGGERED-SPEC: docs/features/completed/codex-gates-4-5-lack-epic-scope-707/spec.md
TRIGGERED-SPEC: docs/features/completed/collect-pr-context-fabricates-auto-close-issues-622/spec.md
TRIGGERED-SPEC: docs/features/completed/compare-code-point-helper-duplicated-716/spec.md
TRIGGERED-SPEC: docs/features/completed/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md
TRIGGERED-SPEC: docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/spec.md
TRIGGERED-SPEC: docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/spec.md
TRIGGERED-SPEC: docs/features/completed/preimplementation-gate-blocks-epic-execution-554/spec.md
TRIGGERED-SPEC: docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/spec.md
```
