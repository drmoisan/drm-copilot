# Preflight Fixes — Remediation Cycle 2 (confirming preflight)

Timestamp: 2026-11-19T20-35
Plan: remediation-plan.2026-11-19T19-58.md
Issue: #1032

## Prior-round defects (confirmed resolved in the revision)

- Incoming #1051 `push-down-integration` copies under `RETIRED-SKILL-TREES`: resolved by the `IncomingRetiredAdds` term, P0-T1 listing, P1-T1 deletion and P1-T2 manifest exclusion.
- Six-copy pin in `extensions/drm-copilot/test/packaging/push-down-integration-skill.test.ts`: resolved by the `COPY-SET-PINS` term, the P0-T3 `update` disposition and the P1-T3 edit (`COPIES` to four, titles, `texts[3]`).
- P1-T1 task-check ordering against `CLR-PACK-MANIFESTS finds no retired path in any pack manifest`: resolved; P1-T1 records it as the one expected failure, resolved by P1-T2.

## Fixes made in place

1. `## Planning-Time Observations` | citation completion (known instances) | Added one bullet naming the two incoming tests that the merge preview shows listing both retired brief copies: `every brief copy names the CI data file after the refresh rule` in `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts`, and `$script:BriefCopies` in `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1`. Both already fall under the P0-T3 search for `execution-environment/SKILL.md` in a copy list and the P1-T3 update rule, so no task, ordering or assertion changes.

## Checks run in this pass

- Merge preview (`git merge-tree --write-tree --name-only`): conflict set equals the captured list of the inputs file (two modify/delete, one content).
- Four auto-merged brief copies in the preview tree share one blob hash; no six-copy or retired-path wording in them.
- Parity-matrix row `copilot:skill:push-down-integration` has disposition `dropped`; its `source_path` hit is classifiable `historical`, matching earlier rows.
- Plan validation: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0.
