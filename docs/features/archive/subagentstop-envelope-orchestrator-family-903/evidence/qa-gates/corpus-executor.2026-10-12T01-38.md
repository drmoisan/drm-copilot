# Executor Corpus Gate ([P2-T13])

Timestamp: 2026-10-12T01-38
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/corpus-gate.ps1 -Validator executor -CorpusRef 2ef8d361e978ca8b7733a545d76a87e8418005ce -OracleScript <SCRATCHPAD>/corpus-oracle.py -WorkDirectory <SCRATCHPAD>/corpus-executor
EXIT_CODE: 0
Output Summary: Final run: ENTRY_BINDING=RawPayload, CORPUS_TOTAL=307, EXPECTED_PASS=164, EXPECTED_BLOCK=59, UNCLASSIFIED=84, FALSE_POSITIVES=0, FALSE_NEGATIVES=1 (informational), EXCEPTIONS=0, CORPUS_VACUOUS=False, MEMBER_LIST_SHA256=3556D04752F0A76D01939508018EA77CA11A2F87BF4B1C1DC1A5107E162283DE. First run (exit 1): FALSE_POSITIVES=164, EXCEPTIONS=307, every false positive with `HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.`, as the plan predicted. The rule 16 binding fix and row CORPUS-EXE-1 were applied (RULE-CHANGE 1 in evidence/other/corpus-rule-changes.2026-10-12T01-27.md) and the task was re-run.

## First run (before RULE-CHANGE 1), EXIT_CODE: 1

CORPUS_VALIDATOR=executor
CORPUS_REF_SHA=2ef8d361e978ca8b7733a545d76a87e8418005ce
ENTRY_BINDING=RawPayload
EXCEPTION path=docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/plan.2026-09-29T14-12.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/plan.2026-09-29T14-12.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/plan.2026-09-29T13-19.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/plan.2026-09-29T14-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/plan.2026-09-29T14-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/plan.2026-09-29T15-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/plan.2026-09-29T15-16.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/plan.2026-10-08T13-52.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/plan.2026-09-29T18-29.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/plan.2026-09-29T19-29.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/plan.2026-09-29T20-10.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/plan.2026-09-29T20-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T17-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/plan.2026-09-30T03-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/plan.2026-10-08T13-52.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/plan.2026-10-08T13-53.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/plan.2026-09-29T21-31.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/plan.2026-09-30T03-18.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/plan.2026-09-29T22-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/plan.2026-09-29T21-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/plan.2026-09-30T03-38.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/plan.2026-09-28T19-35.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/plan.2026-09-28T19-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/plan.2026-09-28T23-50.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/plan.2026-09-29T15-52.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/plan.2026-09-29T17-35.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/plan.2026-09-29T14-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/plan.2026-09-29T17-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/plan.2026-09-29T14-19.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/plan.2026-10-08T13-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/plan.2026-10-08T17-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/plan.2026-09-30T08-50.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/plan.2026-09-30T13-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/plan.2026-10-08T17-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/plan.2026-10-03T08-04.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/plan.2026-10-07T09-57.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/plan.2026-10-07T14-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/plan.2026-10-08T22-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/plan.2026-10-08T23-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/plan.2026-10-08T23-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/plan.2026-10-08T22-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/plan.2026-10-09T01-32.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/2026-10-09-npm-audit-handlebars-864/plan.2026-10-09T08-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/epic-852-main-sync/plan.2026-10-10T22-52.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/plan.2026-10-08T13-53.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-01-28-scaffold-extension-16/plan.2026-03-01T00-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-22-create-active-folder-bug-43/plan.2026-02-22T14-53.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-22-pr-context-verification-contract-gap-46/plan.2026-02-22T21-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/plan.2026-02-22T22-33.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-22-testing-missing-mock-injections-42/plan.2026-02-22T15-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55/plan.2026-02-23T20-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-02-23-minor-audit-planning-58/plan.2026-02-23T17-20.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-03-expose-commit-script-74/plan.2026-03-03T21-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-03-extension-name-71/plan.2026-03-03T12-35.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-05-blank-pr-context-81/plan.2026-03-05T10-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-05-bootstrap-agentic-csharp-work-79/plan.2026-03-05T06-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-09-pr-context-not-bundled-extension-side-82/plan.2026-03-09T11-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-09-pr-context-not-bundled-extension-side-82/plan.2026-03-09T12-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-09-push-down-copilot-customizations-84/v1/plan.2026-03-09T23-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-09-push-down-copilot-customizations-84/v2/plan.2026-03-10T20-38.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-11-expose-placeholder-commands-92/plan.2026-03-11T21-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-12-extension-template-resolution-93/plan.2026-03-12T19-08.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-13-new-potential-entry-missing-dir-95/plan.2026-03-13T21-22.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-14-bundle-hard-lock-resolver-into-extension-103/plan.2026-03-14T22-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-14-noninteractive-bundled-command-flags-104/plan.2026-03-14T22-59.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-14-orchestrator-not-following-sequential-tasks-101/plan.2026-03-14T18-08.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-14-potential-to-issue-auto-resolve-prompts-98/plan.2026-03-14T11-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-03-21-bundle-sync-agents-113/plan.2026-03-21T20-41.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-05-ci-failing-error-128/plan.2026-04-05T19-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-05-fix-sync-agents-bundling-120/plan.2026-04-05T10-12.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-05-general-instructions-first-122/plan.2026-04-05T13-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/plan.2026-04-05T13-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-05-push-down-codex-agents-customizations-124/plan.2026-04-05T13-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/archive/2026-09-13-taskmaster-push-down-and-resume-674/plan.2026-09-13T20-48.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/plan.2026-04-04T11-48.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/plan.2026-04-04T11-48.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-11-claude-code-architecture-136/v1/plan.2026-04-11T19-55.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-11-claude-code-architecture-136/v1/plan.2026-04-11T19-55.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-12-bundle-link-parent-child-into-extension-144/plan.2026-04-12T15-09.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-20-claude-cli-background-script-155/plan.2026-04-20T09-59.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-20-claude-cli-background-script-155/plan.2026-04-20T09-59.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/plan.2026-04-25T14-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/plan.2026-04-25T14-37.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-26-codex-native-converter-164/v1/plan.2026-04-26T18-01.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-26-codex-native-converter-164/v1/plan.2026-04-26T18-01.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-26-codex-native-converter-164/v2/plan.2026-04-30T19-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-26-codex-native-converter-164/v2/plan.2026-04-30T19-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-26-push-down-claude-customizations-162/plan.2026-04-26T13-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-26-push-down-claude-customizations-162/plan.2026-04-26T13-49.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-26-worktree-naming-bug/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-26-worktree-naming-bug/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/plan.2026-04-29T08-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/plan.2026-04-29T08-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-05-06-publish-mcp-server-to-npm-173/plan.2026-05-06T21-36.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-05-06-publish-mcp-server-to-npm-173/plan.2026-05-06T21-36.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T11-51.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-13-claude-memory-scope-and-hardening-181/plan.2026-06-13T13-28.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-16-bump-and-publish-task-191/plan.2026-06-16T19-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-16-bump-and-publish-task-191/plan.2026-06-16T19-49.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-16-pre-claude-session-script-189/plan.2026-06-16T13-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-16-pre-claude-session-script-189/plan.2026-06-16T13-49.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/plan.2026-06-16T10-28.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/plan.2026-06-16T11-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/plan.2026-06-16T11-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-17-pester-adapter-id-collision-198/plan.2026-06-17T21-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-17-remove-secondary-worktrees-command-194/plan.2026-06-17T16-01.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-17-remove-secondary-worktrees-command-194/plan.2026-06-17T16-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-17-remove-secondary-worktrees-command-194/plan.2026-06-17T16-42.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-17-resync-bundled-orchestration-validator-196/plan.2026-06-17T18-19.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-17-resync-bundled-orchestration-validator-196/plan.2026-06-17T19-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-17-resync-bundled-orchestration-validator-196/plan.2026-06-17T19-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-18-activate-prompt-null-background-202/plan.2026-06-18T09-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-19-fix-all-typescript-branch-205/plan.2026-06-19T17-31.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-19-harden-small-path-completion-gate-207/plan.2026-06-19T18-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-19-harden-small-path-completion-gate-207/plan.2026-06-19T18-43.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-21-full-release-missing-branch-push-221/plan.2026-06-21T12-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-21-full-release-missing-branch-push-221/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-21-full-release-missing-branch-push-221/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-missing-ci-gate-parser-script-229/plan.2026-06-24T17-34.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-missing-ci-gate-parser-script-229/plan.2026-06-24T17-34.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-orchestrator-state-routing-contract-mismatch-230/plan.2026-06-24T17-33.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-orchestrator-state-routing-contract-mismatch-230/plan.2026-06-24T17-33.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-push-down-language-packs-csharp-variant-226/plan.2026-06-24T13-04.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-push-down-language-packs-csharp-variant-226/plan.2026-06-24T13-04.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-relocate-research-canonical-location-227/plan.2026-06-24T13-09.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-relocate-research-canonical-location-227/plan.2026-06-24T13-09.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-24-require-pr-author-agent-for-prs-231/plan.2026-06-24T15-17.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-24-require-pr-author-agent-for-prs-231/plan.2026-06-24T15-17.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-26-orchestration-enforcement-hardening-253/plan.2026-06-26T15-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-26-orchestration-enforcement-hardening-253/plan.2026-06-26T15-50.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-26-orchestration-enforcement-hardening-253/plan.2026-06-26T15-50.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-27-fix-csharp-push-down-pack-name-256/plan.2026-06-27T14-16.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-27-fix-csharp-push-down-pack-name-256/plan.2026-06-27T14-16.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-27-harden-claude-pretooluse-hook-schema-259/plan.2026-06-27T20-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-27-harden-claude-pretooluse-hook-schema-259/plan.2026-06-28T00-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-27-harden-claude-pretooluse-hook-schema-259/plan.2026-06-28T00-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/plan.2026-06-27T22-38.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/plan.2026-06-27T23-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/plan.2026-06-27T23-30.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-15.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-02-codex-push-down-language-packs-269/plan.2026-07-02T13-20.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-02-codex-worktree-session-failures-268/plan.2026-07-02T13-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-02-epic-orchestrate-275/plan.2026-07-02T19-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-02-epic-orchestrate-275/plan.2026-07-02T19-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/plan.2026-07-02T18-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-automate-full-release-flow-291/plan.2026-07-03T17-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-automate-full-release-flow-291/plan.2026-07-03T17-15.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-codex-worktree-session-regression-281/plan.2026-07-03T09-14.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/plan.2026-07-03T00-44.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/plan.2026-07-03T00-44.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-fix-convertto-commandresult-empty-array-298/plan.2026-07-03T21-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-fix-convertto-commandresult-empty-array-298/plan.2026-07-03T21-26.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/plan.2026-07-03T11-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/plan.2026-07-03T11-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-parallel-ci-subworkflows-294/plan.2026-07-03T18-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-parallel-ci-subworkflows-294/plan.2026-07-03T18-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-pester-completion-consistency-301/plan.2026-07-03T22-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-pester-completion-consistency-301/plan.2026-07-03T22-46.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-two-axis-model-selection-286/plan.2026-07-03T16-19.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-two-axis-model-selection-286/plan.2026-07-03T16-19.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-03-update-extension-icon-description-285/plan.2026-07-03T15-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-03-update-extension-icon-description-285/plan.2026-07-03T15-40.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-bundle-model-routing-deps-312/plan.2026-07-04T22-47.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-04-bundle-model-routing-deps-312/plan.2026-07-04T22-47.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-enforce-model-selection-routing-305/plan.2026-07-04T13-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-enforce-model-selection-routing-305/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-04-enforce-model-selection-routing-305/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-release-flow-wait-for-ci-310/plan.2026-07-04T21-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-04-release-flow-wait-for-ci-310/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-04-release-flow-wait-for-ci-310/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-06-fix-subagent-tree-discovery-terminal-325/plan.2026-07-06T22-35.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-06-fix-subagent-tree-discovery-terminal-325/plan.2026-07-06T22-35.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-07-epic-single-home-manifest-331/plan.2026-07-07T20-29.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-07-epic-single-home-manifest-331/plan.2026-07-07T20-29.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-07-nested-worktree-folder-scheme-328/plan.2026-07-07T12-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-07-nested-worktree-folder-scheme-328/plan.2026-07-07T12-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-09-subagent-tree-mcp-and-dropdown-334/plan.2026-07-09T10-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-09-subagent-tree-mcp-and-dropdown-334/plan.2026-07-09T10-30.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.2026-07-10T17-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-acceptance-scenarios-364/plan.2026-07-17T14-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-acceptance-scenarios-364/plan.2026-07-17T14-37.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-agent-roles-365/plan.2026-07-17T14-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-agent-roles-365/plan.2026-07-17T14-37.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-analyzer-framework-363/plan.2026-07-17T14-34.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-analyzer-framework-363/plan.2026-07-17T14-34.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-documentation-371/plan.2026-07-17T15-28.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-documentation-371/plan.2026-07-17T15-28.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/plan.2026-07-17T15-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/plan.2026-07-17T15-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-hooks-366/plan.2026-07-17T14-38.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-hooks-366/plan.2026-07-17T14-38.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-init-templates-362/plan.2026-07-17T14-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-init-templates-362/plan.2026-07-17T14-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-publishing-372/plan.2026-07-17T15-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-reports-368/plan.2026-07-17T15-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-reports-368/plan.2026-07-17T15-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-schemas-359/plan.2026-07-17T14-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-schemas-359/plan.2026-07-17T14-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-skills-367/plan.2026-07-17T15-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-skills-367/plan.2026-07-17T15-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-17-legacy-discovery-validators-361/plan.2026-07-17T14-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-17-legacy-discovery-validators-361/plan.2026-07-17T14-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-21-native-bash-toolchain-no-poetry-393/plan.2026-07-21T19-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-21-poshqc-bundled-mock-scope-failure-392/plan.2026-07-21T17-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-21-poshqc-bundled-mock-scope-failure-392/plan.2026-07-21T17-26.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/plan.2026-07-22T07-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/plan.2026-07-22T07-46.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-22-large-route-matrix-promotion-type-gap-399/plan.2026-07-22T09-36.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-22-large-route-matrix-promotion-type-gap-399/plan.2026-07-22T09-36.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/plan.2026-07-22T07-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-bundled-coverage-path-portability-409/plan.2026-07-25T09-58.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-bundled-coverage-path-portability-409/plan.2026-07-25T09-58.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-claude-rules-vitest-jest-divergence-422/plan.2026-07-25T21-44.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-claude-rules-vitest-jest-divergence-422/plan.2026-07-25T21-44.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-orchestration-state-contract-divergences-412/plan.2026-07-25T15-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-orchestration-state-contract-divergences-412/plan.2026-07-25T15-37.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-04-crlf-atomic-plan-validator-434/plan.2026-08-04T09-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-04-mixed-promotion-agent-delegation-receipts-435/plan.2026-08-04T10-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-04-mixed-promotion-agent-delegation-receipts-435/plan.2026-08-04T10-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-blast-radius-under-reporting-gaps-452/plan.2026-08-08T09-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-blast-radius-under-reporting-gaps-452/plan.2026-08-08T09-43.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-blast-radius-447/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-blast-radius-447/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-mutation-protocol-442/plan.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-mutation-protocol-442/plan.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-10-parallel-surface-destination-portability-bash-462/plan.2026-08-10T09-36.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-10-parallel-surface-destination-portability-bash-462/plan.2026-08-10T09-36.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-13-csharp-legacy-gate-command-correctness-469/plan.2026-08-13T16-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-13-csharp-legacy-gate-command-correctness-469/plan.2026-08-13T16-26.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-15-blast-radius-module-map-forces-serial-runs-472/plan.2026-08-15T09-48.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-15-blast-radius-module-map-forces-serial-runs-472/plan.2026-08-15T09-48.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/plan.2026-08-15T12-47.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/plan.2026-08-15T12-47.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/plan.2026-08-16T16-36.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/plan.2026-08-16T16-36.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/plan.2026-08-17T20-44.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/plan.2026-08-17T20-44.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/plan.2026-08-17T15-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/plan.2026-08-17T15-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/plan.2026-08-17T15-01.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/plan.2026-08-17T15-01.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-19-mermaid-diagram-claude-runtime-491/plan.2026-08-19T08-50.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-19-mermaid-diagram-claude-runtime-491/plan.2026-08-19T08-50.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-19-parallel-merge-gate-allow-branch-492/plan.2026-08-19T09-39.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-19-parallel-merge-gate-allow-branch-492/plan.2026-08-19T09-39.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/plan.2026-08-21T22-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/plan.2026-08-21T22-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/plan.2026-08-21T17-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/plan.2026-08-21T17-45.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/plan.2026-08-23T20-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/plan.2026-08-23T20-40.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-readme-misstates-npm-publish-credential-528/plan.2026-09-25T22-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-readme-misstates-npm-publish-credential-528/plan.2026-09-25T22-06.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/plan.2026-09-25T22-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/plan.2026-09-25T22-06.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/plan.2026-08-24T09-18.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/plan.2026-08-24T09-18.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/plan.2026-08-25T14-58.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/plan.2026-08-25T14-58.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.2026-08-25T22-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.2026-08-25T22-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-25-repair-invalid-codex-skill-frontmatter-549/plan.2026-08-25T13-14.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-25-repair-invalid-codex-skill-frontmatter-549/plan.2026-08-25T13-14.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-atomic-preflight-convergence-586/plan.2026-08-28T20-02.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-atomic-preflight-convergence-586/plan.2026-08-28T20-02.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/plan.2026-08-28T18-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/plan.2026-08-28T18-43.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-conflictresult-truthiness-always-true-576/plan.2026-08-28T09-31.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-conflictresult-truthiness-always-true-576/plan.2026-08-28T09-31.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/plan.2026-08-28T09-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/plan.2026-08-28T09-30.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-pr-context-gh-detection-false-negative-588/plan.2026-09-25T22-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-pr-context-gh-detection-false-negative-588/plan.2026-09-25T22-06.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/plan.2026-08-28T09-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/plan.2026-08-28T09-30.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-batch-budget-state-portability-596/plan.2026-08-29T16-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-caller-site-invocation-correctness-597/plan.2026-08-29T16-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-29-caller-site-invocation-correctness-597/plan.2026-08-29T16-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-claude-planning-integrity-593/plan.2026-08-29T12-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-29-claude-planning-integrity-593/plan.2026-08-29T12-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/plan.2026-09-25T22-07.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/plan.2026-09-25T22-07.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/plan.2026-08-29T16-06.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/plan.2026-08-29T16-06.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-30-preimplementation-gate-bare-hash-record-resolution-606/plan.2026-08-30T07-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-30-preimplementation-gate-bare-hash-record-resolution-606/plan.2026-08-30T07-30.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/plan.2026-08-31T08-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/plan.2026-09-01T08-22.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/plan.2026-09-01T08-22.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-03-npm-audit-fast-uri-qs-browserslist-humanfs-627/plan.2026-09-03T07-43.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-03-npm-audit-fast-uri-qs-browserslist-humanfs-627/plan.2026-09-03T07-43.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/plan.2026-09-06T23-08.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/plan.2026-09-06T23-08.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-cleanup-worktrees-dirt-classifier-632/plan.2026-09-06T23-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-06-collect-pr-context-omits-claude-tree-633/plan.2026-09-06T23-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-06-collect-pr-context-omits-claude-tree-633/plan.2026-09-06T23-05.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/plan.2026-09-07T01-26.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-collect-pr-context-explicit-target-675/plan.2026-09-13T20-49.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T13-30.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T16-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-19T09-00.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-17-no-target-reason-code-and-explicit-head-687/plan.2026-09-18T01-05.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-17-quota-throttling-skill-679/plan.2026-09-17T12-10.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-25-codex-pushdown-self-sufficiency-697/plan.2026-09-25T08-22.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-25-codex-pushdown-self-sufficiency-697/plan.2026-09-25T08-22.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/2026-09-26-remaining-cannot-fail-count-assertions-711/plan.2026-09-26T22-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/2026-09-26-remaining-cannot-fail-count-assertions-711/plan.2026-09-26T22-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/blast-radius-over-reports-and-zero-overlap-tolerance-722/plan.2026-09-27T12-16.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/blast-radius-over-reports-and-zero-overlap-tolerance-722/plan.2026-09-27T12-16.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/cleanup-report-registration-lost-false-positive-706/plan.2026-09-26T22-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/cleanup-report-registration-lost-false-positive-706/plan.2026-09-26T22-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/collect-pr-context-fabricates-auto-close-issues-622/plan.2026-09-25T23-29.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/collect-pr-context-fabricates-auto-close-issues-622/plan.2026-09-25T23-29.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/completion-consistency-edit-reads-relative-checkpoint-708/plan.2026-09-26T22-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/completion-consistency-edit-reads-relative-checkpoint-708/plan.2026-09-26T22-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/enforcement-gates-lack-epic-level-checkpoint-seam-663/plan.2026-09-25T08-25.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/enforcement-gates-lack-epic-level-checkpoint-seam-663/plan.2026-09-25T08-25.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/plan.2026-09-26T22-55.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/plan.2026-09-26T22-55.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/npm-audit-gate-and-dependabot/plan.2026-06-19T20-37.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/npm-dependency-vulnerability-remediation/plan.2026-06-19T19-51.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/parallel-worktree-gate-epic-awareness-688/plan.2026-09-18T00-15.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/planner-hook-em-dash-mismatch-357/plan.2026-07-17T10-11.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/planner-hook-em-dash-mismatch-357/plan.2026-07-17T10-11.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/portable-orchestrator-state-preflight/plan.2026-07-06T09-54.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/portable-orchestrator-state-preflight/plan.2026-07-06T09-54.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/repo-housekeeping-audit/plan.2026-07-09T11-29.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/repo-housekeeping-audit/plan.2026-07-09T11-29.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/separate-version-bump-from-publish-214/plan.2026-06-19T21-18.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/separate-version-bump-from-publish-214/plan.2026-06-19T21-18.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/subagent-tree-command/plan.2026-07-05T18-28.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/subagent-tree-command/plan.2026-07-05T18-28.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
EXCEPTION path=docs/features/completed/unused-npm-token-secret-712/plan.2026-09-27T00-23.md message=Cannot bind argument to parameter 'Lines' because it is an empty string.
FALSE-POSITIVE path=docs/features/completed/unused-npm-token-secret-712/plan.2026-09-27T00-23.md message=HARNESS-EXCEPTION: Cannot bind argument to parameter 'Lines' because it is an empty string.
MEMBER_LIST_SHA256=3556D04752F0A76D01939508018EA77CA11A2F87BF4B1C1DC1A5107E162283DE
CORPUS_TOTAL=307
EXPECTED_PASS=164
EXPECTED_BLOCK=59
UNCLASSIFIED=84
FALSE_POSITIVES=164
FALSE_NEGATIVES=0
EXCEPTIONS=307
CORPUS_VACUOUS=False

## Final run (after RULE-CHANGE 1), EXIT_CODE: 0

CORPUS_VALIDATOR=executor
CORPUS_REF_SHA=2ef8d361e978ca8b7733a545d76a87e8418005ce
ENTRY_BINDING=RawPayload
FALSE-NEGATIVE path=docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md
MEMBER_LIST_SHA256=3556D04752F0A76D01939508018EA77CA11A2F87BF4B1C1DC1A5107E162283DE
CORPUS_TOTAL=307
EXPECTED_PASS=164
EXPECTED_BLOCK=59
UNCLASSIFIED=84
FALSE_POSITIVES=0
FALSE_NEGATIVES=1
EXCEPTIONS=0
CORPUS_VACUOUS=False
