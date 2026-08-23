# Baseline — Conflict-Graph Density, Before-State — [P0-T14]

Timestamp: 2026-08-23T01-10

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T14]
State captured: PRE-CHANGE baseline

Command: `poetry run python <corpus measurement script>` — a deterministic measurement that enumerates the top-level plan documents under the active feature corpus in sorted order, derives one radius per document with a single constant derivation timestamp and the sibling spec text when present, evaluates every canonical ascending pair through the conflict relation, and colors the resulting graph with the production cohort computation.

EXIT_CODE: 0

## Determinism controls

- **Item enumeration** is the sorted glob of top-level plan documents in the active feature corpus. Sorting makes the list order reproducible independently of filesystem order.
- **Constant derivation timestamp** `2026-08-23T00:00:00Z` is passed to every derivation, so no radius carries a wall-clock value and the after-measurement is comparable byte for byte.
- **Item keys** are the 1-based positions in the sorted list. The cohort computation requires integer keys and several corpus folders carry no issue number, so a positional key is the only assignment that is both total and deterministic.
- **Sibling spec text** is read when a `spec.md` exists next to the plan and is the empty string otherwise, matching how derivation is invoked in production.
- **Pair enumeration** is every canonical ascending pair (a < b), so each unordered pair is evaluated exactly once.

## Headline quantities

| Quantity | Value |
| --- | --- |
| item count | **58** |
| edge count | **1282** |
| maximum possible edges (C(n,2)) | 1653 |
| density | **77.6%** |
| cohort count | **32** |
| maximum cohort width | **4** |
| total radius path entries across all radii | **3729** |

The item count is 58, which is non-zero and equals the 58 the plan's AC-19 pre-registration assumed. No deviation from 58 is recorded because none occurred.

Density is reported as the fraction of realized edges over the maximum possible edges, to one decimal place: 1282 / 1653 = 77.6%.

## Reason-kind breakdown of the before-state edge set

Edges carrying each reason kind (an edge may carry several):

| Reason kind | Edges carrying it |
| --- | --- |
| `path_overlap` | 1245 |
| `shared_surface_overlap` | 325 |
| `module_overlap` | 291 |
| `contract_dependency` | 144 |

Distinct reason-kind combinations:

| Reason-kind combination | Edge count |
| --- | --- |
| `path_overlap` | 774 |
| `path_overlap+module_overlap+shared_surface_overlap` | 192 |
| `path_overlap+shared_surface_overlap` | 97 |
| `path_overlap+contract_dependency` | 78 |
| `path_overlap+module_overlap` | 59 |
| `contract_dependency` | 21 |
| `path_overlap+shared_surface_overlap+contract_dependency` | 21 |
| `module_overlap` | 16 |
| `path_overlap+module_overlap+shared_surface_overlap+contract_dependency` | 15 |
| `path_overlap+module_overlap+contract_dependency` | 9 |

## Item list, stored verbatim

This is the authoritative list the [P7-T1] after-measurement must run over. It is stored verbatim so the two measurements are taken over a byte-identical set.

| Key | Plan document | Spec sibling | Radius path entries |
| --- | --- | --- | --- |
| 1 | docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/plan.2026-07-09T10-30.md | yes | 70 |
| 2 | docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.2026-07-10T17-06.md | yes | 11 |
| 3 | docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.md | yes | 77 |
| 4 | docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/plan.2026-07-17T14-37.md | yes | 25 |
| 5 | docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/plan.2026-07-17T14-37.md | yes | 21 |
| 6 | docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/plan.2026-07-17T14-34.md | yes | 37 |
| 7 | docs/features/active/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md | yes | 34 |
| 8 | docs/features/active/2026-07-17-legacy-discovery-documentation-371/plan.2026-07-17T15-28.md | yes | 26 |
| 9 | docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/plan.2026-07-17T15-07.md | yes | 49 |
| 10 | docs/features/active/2026-07-17-legacy-discovery-hooks-366/plan.2026-07-17T14-38.md | yes | 27 |
| 11 | docs/features/active/2026-07-17-legacy-discovery-init-templates-362/plan.2026-07-17T14-05.md | yes | 46 |
| 12 | docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md | yes | 79 |
| 13 | docs/features/active/2026-07-17-legacy-discovery-publishing-372/plan.2026-07-17T15-30.md | yes | 122 |
| 14 | docs/features/active/2026-07-17-legacy-discovery-reports-368/plan.2026-07-17T15-03.md | yes | 40 |
| 15 | docs/features/active/2026-07-17-legacy-discovery-schemas-359/plan.2026-07-17T14-03.md | yes | 53 |
| 16 | docs/features/active/2026-07-17-legacy-discovery-skills-367/plan.2026-07-17T15-03.md | yes | 45 |
| 17 | docs/features/active/2026-07-17-legacy-discovery-validators-361/plan.2026-07-17T14-03.md | yes | 40 |
| 18 | docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/plan.2026-07-21T19-00.md | yes | 54 |
| 19 | docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/plan.2026-07-21T17-26.md | yes | 54 |
| 20 | docs/features/active/2026-07-22-cleanup-merged-worktrees-396/plan.2026-07-22T07-46.md | yes | 25 |
| 21 | docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/plan.2026-07-22T09-36.md | no | 17 |
| 22 | docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/plan.2026-07-22T09-56.md | yes | 52 |
| 23 | docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/plan.2026-07-22T07-54.md | yes | 44 |
| 24 | docs/features/active/2026-07-25-bundled-coverage-path-portability-409/plan.2026-07-25T09-58.md | yes | 50 |
| 25 | docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/plan.2026-07-25T21-44.md | yes | 49 |
| 26 | docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md | yes | 62 |
| 27 | docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md | yes | 47 |
| 28 | docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md | yes | 66 |
| 29 | docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/plan.2026-07-25T15-37.md | yes | 112 |
| 30 | docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md | yes | 64 |
| 31 | docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md | yes | 50 |
| 32 | docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/plan.2026-08-04T09-49.md | yes | 44 |
| 33 | docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/plan.2026-08-04T10-00.md | yes | 74 |
| 34 | docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/plan.2026-08-08T09-43.md | yes | 125 |
| 35 | docs/features/active/2026-08-07-parallel-blast-radius-447/plan.md | yes | 73 |
| 36 | docs/features/active/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md | yes | 27 |
| 37 | docs/features/active/2026-08-07-parallel-drift-detection-446/plan.2026-08-07T11-11.md | yes | 50 |
| 38 | docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md | yes | 74 |
| 39 | docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md | yes | 71 |
| 40 | docs/features/active/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md | yes | 68 |
| 41 | docs/features/active/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md | yes | 107 |
| 42 | docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md | yes | 98 |
| 43 | docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/plan.2026-08-10T09-36.md | yes | 101 |
| 44 | docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/plan.2026-08-13T16-26.md | yes | 65 |
| 45 | docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/plan.2026-08-15T09-48.md | yes | 108 |
| 46 | docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/plan.2026-08-15T12-47.md | yes | 124 |
| 47 | docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/plan.2026-08-16T22-09.md | yes | 129 |
| 48 | docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/plan.2026-08-16T16-36.md | yes | 76 |
| 49 | docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/plan.2026-08-17T20-44.md | yes | 88 |
| 50 | docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/plan.2026-08-17T15-00.md | yes | 128 |
| 51 | docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/plan.2026-08-17T15-01.md | yes | 95 |
| 52 | docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md | yes | 95 |
| 53 | docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/plan.2026-08-19T08-50.md | yes | 111 |
| 54 | docs/features/active/2026-08-19-parallel-merge-gate-allow-branch-492/plan.2026-08-19T09-39.md | no | 23 |
| 55 | docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md | yes | 83 |
| 56 | docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/plan.2026-08-21T17-45.md | yes | 119 |
| 57 | docs/features/active/planner-hook-em-dash-mismatch-357/plan.2026-07-17T10-11.md | no | 4 |
| 58 | docs/features/active/repo-housekeeping-audit/plan.2026-07-09T11-29.md | no | 21 |

## Cohort assignment

32 cohorts, maximum width 4. Cohort membership by item key:

```text
cohort  0: [11]
cohort  1: [12]
cohort  2: [15]
cohort  3: [18]
cohort  4: [31]
cohort  5: [35]
cohort  6: [41]
cohort  7: [43]
cohort  8: [44]
cohort  9: [45]
cohort 10: [48]
cohort 11: [49]
cohort 12: [53]
cohort 13: [32, 34]
cohort 14: [46]
cohort 15: [13, 19, 21]
cohort 16: [23, 56]
cohort 17: [42, 57, 58]
cohort 18: [9, 29]
cohort 19: [10, 26, 27, 36]
cohort 20: [3, 16]
cohort 21: [7, 38]
cohort 22: [14, 33, 54]
cohort 23: [17, 40]
cohort 24: [24, 47, 51]
cohort 25: [6, 30]
cohort 26: [2, 4, 25]
cohort 27: [1, 8, 55]
cohort 28: [22]
cohort 29: [28, 37, 50, 52]
cohort 30: [39]
cohort 31: [5, 20]
```

## Full edge set with reason kind and detail

All 1282 edges are enumerated below, one per line, in canonical ascending pair order. Each line carries the pair, then every triggered reason as `kind=detail`, in the fixed reason-kind order the conflict relation guarantees.

```text
  1 -   2  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts
  1 -   3  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -   9  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -  10  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/**
  1 -  12  path_overlap=**/*.py ~ .claude/hooks/persist-session-id.ps1
  1 -  13  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/**
  1 -  16  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  18  path_overlap=**/*.sh ~ .claude/hooks/persist-session-id.ps1
  1 -  20  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -  22  path_overlap=.claude/skills/** ~ .claude/skills/identify-session-id/SKILL.md
  1 -  23  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
  1 -  25  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  27  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -  28  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
  1 -  29  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  30  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/**
  1 -  32  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
  1 -  33  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts
  1 -  34  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  35  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  module_overlap=mcp-server
  1 -  37  path_overlap=.claude/settings.json ~ .claude/settings.json  shared_surface_overlap=.claude/settings.json
  1 -  38  path_overlap=.claude/settings.json ~ .claude/settings.json  shared_surface_overlap=.claude/settings.json
  1 -  39  path_overlap=.claude/settings.json ~ .claude/settings.json  shared_surface_overlap=.claude/settings.json
  1 -  40  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/hooks/persist-session-id.ps1
  1 -  42  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/validate/epic-*
  1 -  43  path_overlap=**/*.sh ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  44  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
  1 -  45  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  46  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  47  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  1 -  48  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  49  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  50  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/pr-context/collector-output.ts
  1 -  51  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts
  1 -  52  path_overlap=extensions/drm-copilot/src/lib/** ~ extensions/drm-copilot/src/lib/subprocess-runner.ts
  1 -  53  path_overlap=**/*.md ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  54  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1
  1 -  56  path_overlap=.claude/** ~ .claude/hooks/persist-session-id.ps1  shared_surface_overlap=.claude/settings.json
  1 -  58  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  2 -   3  path_overlap=config/poshqc-scan.json ~ config/poshqc-scan.json  module_overlap=config  contract_dependency=$ResolveScanConfig
  2 -   5  module_overlap=poshqc
  2 -  10  module_overlap=poshqc
  2 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  2 -  12  path_overlap=**/*.py ~ config/poshqc-scan.json
  2 -  13  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts
  2 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  2 -  18  path_overlap=**/*.sh ~ config/poshqc-scan.json
  2 -  19  path_overlap=tests/scripts/dev_tools/test_poshqc_bundled_parity.py ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py  module_overlap=poshqc
  2 -  21  module_overlap=config
  2 -  22  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts
  2 -  24  path_overlap=settings/*.psd1 ~ settings/pester.runsettings.psd1  module_overlap=poshqc  contract_dependency=run_poshqc_test
  2 -  26  module_overlap=config
  2 -  27  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts
  2 -  29  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts  module_overlap=config
  2 -  30  module_overlap=poshqc
  2 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  2 -  32  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts
  2 -  33  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts
  2 -  34  path_overlap=scripts/*/a.py ~ scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1  module_overlap=config
  2 -  35  path_overlap=config/** ~ config/poshqc-scan.json  module_overlap=config
  2 -  37  module_overlap=poshqc
  2 -  38  path_overlap=settings/*.psd1 ~ settings/pester.runsettings.psd1  module_overlap=poshqc
  2 -  39  module_overlap=config
  2 -  40  module_overlap=config
  2 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ config/poshqc-scan.json  module_overlap=config
  2 -  42  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/epic-*  module_overlap=config
  2 -  43  path_overlap=**/*.sh ~ config/poshqc-scan.json  module_overlap=config
  2 -  44  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts
  2 -  45  path_overlap=config/** ~ config/poshqc-scan.json  module_overlap=config
  2 -  46  path_overlap=tests/** ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py  module_overlap=config
  2 -  47  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
  2 -  48  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts  module_overlap=poshqc
  2 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/src/poshqc-folder-picker.ts  module_overlap=config
  2 -  50  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
  2 -  51  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/new-active-feature-folder/fakes.ts
  2 -  52  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts
  2 -  53  path_overlap=**/*.md ~ config/poshqc-scan.json  module_overlap=poshqc
  2 -  54  module_overlap=poshqc
  2 -  55  path_overlap=tests/scripts/dev_tools/test_poshqc_bundled_parity.py ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py  module_overlap=config
  2 -  56  path_overlap=tests/**/*.ps1 ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py  module_overlap=poshqc
  3 -   5  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -   9  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  3 -  10  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  3 -  12  path_overlap=**/*.py ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md
  3 -  13  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  3 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  3 -  18  path_overlap=**/*.sh ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md
  3 -  19  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 ~ extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  20  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  3 -  21  module_overlap=config
  3 -  22  path_overlap=extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts ~ extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
  3 -  23  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  3 -  24  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 ~ extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1  contract_dependency=run_poshqc_test
  3 -  26  module_overlap=config
  3 -  27  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  3 -  28  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  3 -  29  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=config
  3 -  30  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/**
  3 -  32  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  3 -  33  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts
  3 -  34  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  35  path_overlap=config/** ~ config/poshqc-scan.json  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  37  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  38  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  39  path_overlap=<FEATURE>/evidence/baseline/baseline-ps-analyze.md ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md  module_overlap=config
  3 -  40  module_overlap=config
  3 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md  module_overlap=config
  3 -  42  path_overlap=extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts ~ extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts  module_overlap=config
  3 -  43  path_overlap=**/*.sh ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md  module_overlap=config
  3 -  44  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  3 -  45  path_overlap=config/** ~ config/poshqc-scan.json  module_overlap=config
  3 -  46  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  47  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  3 -  48  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/*.test.ts  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/package.json  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  50  path_overlap=extensions/drm-copilot/test/*.test.ts ~ extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
  3 -  51  path_overlap=extensions/drm-copilot/src/repo-automation-service.ts ~ extensions/drm-copilot/src/repo-automation-service.ts
  3 -  52  path_overlap=extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts ~ extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
  3 -  53  path_overlap=**/*.md ~ <FEATURE>/evidence/baseline/baseline-ps-analyze.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  54  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  55  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  56  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  3 -  58  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
  4 -   6  path_overlap=tests/conftest.py ~ tests/conftest.py  module_overlap=schemas  contract_dependency=id
  4 -   7  path_overlap=tests/conftest.py ~ tests/conftest.py  contract_dependency="__main__":
  4 -   8  path_overlap=docs/features/epics/legacy-discovery-and-parity/objective-source.md ~ docs/features/epics/legacy-discovery-and-parity/objective-source.md  contract_dependency=dev.discovery.*
  4 -   9  path_overlap=tests/conftest.py ~ tests/conftest.py  module_overlap=schemas  contract_dependency=id
  4 -  10  contract_dependency=if
  4 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  contract_dependency=[tool.poetry.scripts]
  4 -  12  path_overlap=**/*.py ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  contract_dependency=--check
  4 -  13  module_overlap=schemas
  4 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/objective-source.md ~ docs/features/epics/legacy-discovery-and-parity/objective-source.md  contract_dependency=None
  4 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  module_overlap=schemas  contract_dependency=id
  4 -  16  contract_dependency=dev.discovery.*
  4 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/objective-source.md ~ docs/features/epics/legacy-discovery-and-parity/objective-source.md  contract_dependency=[tool.poetry.scripts]
  4 -  18  path_overlap=**/*.sh ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  contract_dependency=if
  4 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**
  4 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/format_json.py
  4 -  35  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  module_overlap=schemas
  4 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/format_json.py
  4 -  38  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_generate_acceptance_scenarios.py
  4 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**
  4 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/format_json.py  contract_dependency=int
  4 -  43  path_overlap=**/*.sh ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**
  4 -  44  path_overlap=tests/** ~ tests/conftest.py
  4 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**
  4 -  46  path_overlap=scripts/dev_tools/*.py ~ scripts/dev_tools/format_json.py  module_overlap=schemas
  4 -  48  path_overlap=tests/** ~ tests/conftest.py
  4 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/format_json.py
  4 -  50  contract_dependency=int
  4 -  51  path_overlap=evidence/baseline/phase0-instructions-read.md ~ evidence/baseline/phase0-instructions-read.md
  4 -  52  contract_dependency=main
  4 -  53  path_overlap=**/*.md ~ docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/**  contract_dependency=if
  4 -  56  path_overlap=tests/**/*.ps1 ~ tests/conftest.py
  5 -   6  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/analyzer/__init__.py  contract_dependency=description
  5 -   7  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/**
  5 -   9  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/analyzer/cli.py  contract_dependency=description
  5 -  10  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/**
  5 -  12  path_overlap=**/*.py ~ .claude/agents/*.md
  5 -  13  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  14  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/**
  5 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/**  contract_dependency=description
  5 -  16  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  18  path_overlap=**/*.sh ~ .claude/agents/*.md
  5 -  19  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  22  path_overlap=.claude/agents/** ~ .claude/agents/*.md
  5 -  24  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  25  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  29  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  30  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/**
  5 -  34  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  35  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/discovery/**
  5 -  37  path_overlap=.claude/agents/*.md ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  38  path_overlap=.claude/agents/*.md ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1  contract_dependency=SubagentStop
  5 -  39  path_overlap=.claude/agents/*.md ~ .claude/agents/parallel-orchestrator.md
  5 -  40  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/*.md
  5 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/discovery/**
  5 -  43  path_overlap=**/*.sh ~ .claude/agents/*.md
  5 -  44  path_overlap=tests/** ~ tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1
  5 -  45  path_overlap=.claude/** ~ .claude/agents/*.md
  5 -  46  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  47  path_overlap=.claude/agents/*.md ~ .claude/agents/parallel-orchestrator.md
  5 -  48  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  49  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  53  path_overlap=**/*.md ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1  contract_dependency=description
  5 -  54  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  55  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  56  path_overlap=.claude/** ~ .claude/agents/*.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  5 -  58  path_overlap=.claude/agents/*.md ~ .claude/agents/<name>.md
  6 -   7  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=--json
  6 -   8  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=$schema
  6 -   9  path_overlap=docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/** ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md  module_overlap=schemas  contract_dependency="discovery-profile.yaml"
  6 -  10  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=profile
  6 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/**  contract_dependency=argparse
  6 -  12  path_overlap=**/*.py ~ .github/instructions/*  contract_dependency=--json
  6 -  13  path_overlap=.github/** ~ .github/instructions/*  module_overlap=schemas  contract_dependency=tuple[str,
  6 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=argparse
  6 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/**  module_overlap=schemas  contract_dependency=description
  6 -  16  contract_dependency=dev.discovery.inventory
  6 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=profile
  6 -  18  path_overlap=**/*.sh ~ .github/instructions/*
  6 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/**
  6 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/discovery/analyzer/__init__.py
  6 -  35  path_overlap=.github/** ~ .github/instructions/*  module_overlap=schemas
  6 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/discovery/analyzer/__init__.py
  6 -  37  path_overlap=scripts/dev_tools/discovery/analyzer/inventory.py ~ scripts/dev_tools/discovery/analyzer/inventory.py
  6 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .github/instructions/*
  6 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/discovery/analyzer/__init__.py  contract_dependency=int
  6 -  43  path_overlap=**/*.sh ~ .github/instructions/*
  6 -  44  path_overlap=.github/** ~ .github/instructions/*
  6 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/**
  6 -  46  path_overlap=schemas/discovery/v1/*.json ~ schemas/discovery/v1/evidence-reference.schema.json  module_overlap=schemas
  6 -  48  path_overlap=.github/** ~ .github/instructions/*
  6 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/discovery/analyzer/__init__.py
  6 -  50  contract_dependency=int
  6 -  51  contract_dependency=file
  6 -  53  path_overlap=**/*.md ~ .github/instructions/*  contract_dependency=description
  6 -  56  path_overlap=tests/**/*.ps1 ~ tests/conftest.py
  6 -  58  path_overlap=.github/instructions/* ~ .github/instructions/*.instructions.md
  7 -   8  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=dev.discovery.*
  7 -   9  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  contract_dependency=--json
  7 -  10  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  contract_dependency=if
  7 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-config-contract-360/**  contract_dependency=[tool.poetry.scripts]
  7 -  12  path_overlap=**/*.py ~ .github/copilot-instructions.md  contract_dependency=--json
  7 -  13  path_overlap=.github/** ~ .github/copilot-instructions.md  contract_dependency=tuple[str,
  7 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=None
  7 -  15  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  7 -  16  contract_dependency=dev.discovery.*
  7 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=[tool.poetry.scripts]
  7 -  18  path_overlap=**/*.sh ~ .github/copilot-instructions.md  contract_dependency=if
  7 -  20  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  7 -  23  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  7 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-config-contract-360/**
  7 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/codex_native_converter/parser.py
  7 -  35  path_overlap=.github/** ~ .github/copilot-instructions.md  contract_dependency=class
  7 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/codex_native_converter/parser.py
  7 -  37  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/analyzer/inventory.py
  7 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .github/copilot-instructions.md
  7 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/codex_native_converter/parser.py  contract_dependency=int
  7 -  43  path_overlap=**/*.sh ~ .github/copilot-instructions.md
  7 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md
  7 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-config-contract-360/**
  7 -  46  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  contract_dependency=FileNotFoundError
  7 -  47  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  7 -  48  path_overlap=.github/** ~ .github/copilot-instructions.md
  7 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/codex_native_converter/parser.py
  7 -  50  contract_dependency=int
  7 -  53  path_overlap=**/*.md ~ .github/copilot-instructions.md  contract_dependency=if
  7 -  54  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  7 -  56  path_overlap=tests/**/*.ps1 ~ tests/conftest.py
  7 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  8 -   9  contract_dependency=$schema
  8 -  10  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md
  8 -  11  path_overlap=docs/**/*.json ~ docs/ci.research.md  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=dev.*
  8 -  12  path_overlap=**/*.py ~ docs/ci.research.md  contract_dependency=pyproject.toml
  8 -  13  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
  8 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=dev.discovery.*
  8 -  15  path_overlap=docs/**/*.json ~ docs/ci.research.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
  8 -  16  contract_dependency=dev.discovery.*
  8 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=pyproject.toml
  8 -  18  path_overlap=**/*.sh ~ docs/ci.research.md
  8 -  31  path_overlap=docs/** ~ docs/ci.research.md
  8 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/push_down_*_customizations.py
  8 -  35  path_overlap=docs/** ~ docs/ci.research.md
  8 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/push_down_*_customizations.py
  8 -  38  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py
  8 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ docs/ci.research.md
  8 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/push_down_*_customizations.py
  8 -  43  path_overlap=**/*.sh ~ docs/ci.research.md
  8 -  44  path_overlap=scripts/dev_tools/push_down_*_customizations.py ~ scripts/dev_tools/push_down_claude_customizations.py
  8 -  45  path_overlap=docs/** ~ docs/ci.research.md
  8 -  46  path_overlap=scripts/dev_tools/*.py ~ scripts/dev_tools/push_down_*_customizations.py
  8 -  47  path_overlap=scripts/dev_tools/validate_json.py ~ scripts/dev_tools/validate_json.py  shared_surface_overlap=scripts/dev_tools/validate_json.py
  8 -  48  path_overlap=docs/ci.research.md ~ docs/ci.research.md
  8 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/push_down_*_customizations.py
  8 -  50  path_overlap=scripts/dev_tools/push_down_*_customizations.py ~ scripts/dev_tools/push_down_claude_customizations.py
  8 -  53  path_overlap=**/*.md ~ docs/ci.research.md
  8 -  56  path_overlap=tests/**/*.ps1 ~ tests/docs/test_legacy_discovery_documentation_contracts.py
  9 -  10  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  contract_dependency=profile
  9 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md  contract_dependency=argparse
  9 -  12  path_overlap=**/*.py ~ .github/copilot-instructions.md  contract_dependency=--json
  9 -  13  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=schemas
  9 -  14  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/analyzer/cli.py  contract_dependency=argparse
  9 -  15  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  module_overlap=schemas  contract_dependency=description
  9 -  16  contract_dependency=dev.discovery.inventory
  9 -  17  contract_dependency=profile
  9 -  18  path_overlap=**/*.sh ~ .github/copilot-instructions.md
  9 -  20  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  9 -  23  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  9 -  27  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  9 -  30  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  9 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md
  9 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/codex_native_converter/classifier.py
  9 -  35  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=schemas
  9 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/codex_native_converter/classifier.py
  9 -  37  path_overlap=scripts/dev_tools/discovery/analyzer/inventory.py ~ scripts/dev_tools/discovery/analyzer/inventory.py
  9 -  39  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
  9 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .github/copilot-instructions.md
  9 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/codex_native_converter/classifier.py  contract_dependency=int
  9 -  43  path_overlap=**/*.sh ~ .github/copilot-instructions.md
  9 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md
  9 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md
  9 -  46  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  module_overlap=schemas
  9 -  47  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  9 -  48  path_overlap=.github/** ~ .github/copilot-instructions.md
  9 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/codex_native_converter/classifier.py
  9 -  50  contract_dependency=int
  9 -  51  contract_dependency=false
  9 -  53  path_overlap=**/*.md ~ .github/copilot-instructions.md  contract_dependency=description
  9 -  54  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
  9 -  56  path_overlap=tests/**/*.ps1 ~ tests/conftest.py
  9 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 10 -  11  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-hooks-366/**
 10 -  12  path_overlap=**/*.py ~ .../issue.md  contract_dependency=<path>
 10 -  13  path_overlap=.claude/** ~ .claude/hooks/*.ps1  shared_surface_overlap=.claude/settings.json
 10 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=list[str]
 10 -  15  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 10 -  16  path_overlap=.claude/** ~ .claude/hooks/*.ps1  contract_dependency=all
 10 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  contract_dependency=-m
 10 -  18  path_overlap=**/*.sh ~ .../issue.md  contract_dependency=if
 10 -  19  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  20  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 10 -  23  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 10 -  24  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  25  path_overlap=.claude/** ~ .claude/hooks/*.ps1
 10 -  28  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/validate-orchestrator-output.ps1
 10 -  29  path_overlap=.claude/** ~ .claude/hooks/*.ps1  shared_surface_overlap=.claude/settings.json
 10 -  30  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-hooks-366/**
 10 -  34  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  35  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  37  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/enforce-epic-*.ps1  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 10 -  38  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/enforce-epic-invocation-origin.ps1  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json  contract_dependency=list[str]
 10 -  39  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/enforce-epic-*  shared_surface_overlap=.claude/settings.json
 10 -  40  path_overlap=.claude/** ~ .claude/hooks/*.ps1  shared_surface_overlap=.claude/settings.json
 10 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../issue.md
 10 -  42  contract_dependency=list[str]
 10 -  43  path_overlap=**/*.sh ~ .../issue.md  shared_surface_overlap=.claude/settings.json
 10 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md
 10 -  45  path_overlap=.claude/** ~ .claude/hooks/*.ps1
 10 -  46  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 10 -  47  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/enforce-parallel-cohort-barrier.ps1
 10 -  48  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  49  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  51  contract_dependency=<path>
 10 -  52  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/validate-planner-output.ps1  contract_dependency=list[str]
 10 -  53  path_overlap=**/*.md ~ .../issue.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json  contract_dependency=($MyInvocation.InvocationName
 10 -  54  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  55  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 10 -  56  path_overlap=.claude/** ~ .claude/hooks/*.ps1  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 10 -  57  path_overlap=.claude/hooks/*.ps1 ~ .claude/hooks/validate-planner-output.ps1
 10 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 11 -  12  path_overlap=**/*.py ~ ../../schemas/v1/feature-contract.schema.json  contract_dependency=[tool.poetry.scripts]
 11 -  13  path_overlap=artifacts/*.json ~ artifacts/*.template.json  shared_surface_overlap=scripts/dev_tools/validate_json.py
 11 -  14  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-reports-368/**  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=argparse
 11 -  15  path_overlap=docs/**/*.json ~ docs/**/*.json  shared_surface_overlap=scripts/dev_tools/validate_json.py
 11 -  16  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-skills-367/**
 11 -  17  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=[tool.poetry.scripts]
 11 -  18  path_overlap=**/*.sh ~ ../../schemas/v1/feature-contract.schema.json
 11 -  19  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**
 11 -  20  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/shell-qc-orchestrator-verification.2026-07-21T23-20.md
 11 -  21  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/**
 11 -  22  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/**
 11 -  23  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/**
 11 -  24  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-21-quickfiler-folder-selector-dropdown-400/evidence/regression-testing/coverage-wrapper-poshqc-test-blocker-retry.2026-07-25T03-33.md
 11 -  25  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/**
 11 -  26  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/**
 11 -  27  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/**
 11 -  28  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/**
 11 -  29  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/**
 11 -  30  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/**
 11 -  31  path_overlap=docs/** ~ docs/**/*.json
 11 -  32  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/**
 11 -  33  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/**
 11 -  34  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/**
 11 -  35  path_overlap=docs/** ~ docs/**/*.json
 11 -  36  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-cohort-scheduler-445/**
 11 -  37  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-drift-detection-446/**
 11 -  38  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md
 11 -  39  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-mutation-protocol-442/**
 11 -  40  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-orchestrator-surface-441/**
 11 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ../../schemas/v1/feature-contract.schema.json
 11 -  42  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-schema-validators-444/**
 11 -  43  path_overlap=**/*.sh ~ ../../schemas/v1/feature-contract.schema.json
 11 -  44  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/**
 11 -  45  path_overlap=docs/** ~ docs/**/*.json
 11 -  46  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/**
 11 -  47  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/**  shared_surface_overlap=scripts/dev_tools/validate_json.py
 11 -  48  path_overlap=docs/**/*.json ~ docs/ci.research.md
 11 -  49  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/**
 11 -  50  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.2026-07-18T10-20.md
 11 -  51  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/**
 11 -  52  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/**
 11 -  53  path_overlap=**/*.md ~ ../../schemas/v1/feature-contract.schema.json
 11 -  54  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-19-parallel-merge-gate-allow-branch-492/**
 11 -  55  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/**
 11 -  56  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/**
 11 -  57  path_overlap=docs/**/*.json ~ docs/features/active/planner-hook-em-dash-mismatch-357/**
 11 -  58  path_overlap=docs/**/*.json ~ docs/code-change.instructions.md
 12 -  13  path_overlap=**/*.py ~ .agents/**
 12 -  14  path_overlap=**/*.py ~ .../evidence/baseline/py-format.<ts>.md  contract_dependency=--input
 12 -  15  path_overlap=**/*.py ~ .cache/schemas/<sha256>.json
 12 -  16  path_overlap=**/*.py ~ .claude/**  contract_dependency=all
 12 -  17  path_overlap=**/*.py ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**  contract_dependency=[tool.poetry.scripts]
 12 -  18  path_overlap=**/*.py ~ **/*.sh  contract_dependency=check
 12 -  19  path_overlap=**/*.py ~ ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1
 12 -  20  path_overlap=**/*.py ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 12 -  21  path_overlap=**/*.py ~ config/orchestration-routing.json
 12 -  22  path_overlap=**/*.py ~ .claude/agents/**  contract_dependency=workspace_root
 12 -  23  path_overlap=**/*.py ~ .github/copilot-instructions.md
 12 -  24  path_overlap=**/*.py ~ ./scripts/powershell/PoshQC/PoshQC.psd1
 12 -  25  path_overlap=**/*.py ~ .agents/**
 12 -  26  path_overlap=**/*.py ~ .codex/config.toml
 12 -  27  path_overlap=**/*.py ~ .agents/skills/**
 12 -  28  path_overlap=**/*.py ~ ./dist/commonjs/index.js
 12 -  29  path_overlap=**/*.py ~ ./src/lib/validate/orchestrator-state-core.ts
 12 -  30  path_overlap=**/*.py ~ .claude/hooks/validate-orchestrator-output.ps1
 12 -  31  path_overlap=**/*.py ~ .../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md
 12 -  32  path_overlap=**/*.py ~ .agents/skills/architecture-boundaries/SKILL.md
 12 -  33  path_overlap=**/*.py ~ .agents/skills/general-code-change/SKILL.md  contract_dependency=validate_orchestration_artifacts
 12 -  34  path_overlap=**/*.py ~ .claude/**  contract_dependency=artifact_type
 12 -  35  path_overlap=**/*.py ~ .agents/**
 12 -  36  path_overlap=**/*.py ~ .claude/lib/**
 12 -  37  path_overlap=**/*.py ~ .claude/agents/parallel-orchestrator.md
 12 -  38  path_overlap=**/*.py ~ .claude/agents/parallel-orchestrator.md  contract_dependency=validate_orchestration_artifacts
 12 -  39  path_overlap=**/*.py ~ .claude/agents/parallel-orchestrator.md
 12 -  40  path_overlap=**/*.py ~ .../.claude/skills/parallel-orchestrate/SKILL.md
 12 -  41  path_overlap=**/*.py ~ **/extensions/drm-copilot/test/**/*.test.ts  contract_dependency=artifact_type
 12 -  42  path_overlap=**/*.py ~ ./src/lib/validate/parallel-orchestrator-state-core.ts
 12 -  43  path_overlap=**/*.py ~ **/*.sh
 12 -  44  path_overlap=**/*.py ~ .agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
 12 -  45  path_overlap=**/*.py ~ .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md
 12 -  46  path_overlap=**/*.py ~ .claude/**
 12 -  47  path_overlap=**/*.py ~ .claude/agents/parallel-orchestrator.md
 12 -  48  path_overlap=**/*.py ~ .agents/**
 12 -  49  path_overlap=**/*.py ~ .claude/**
 12 -  50  path_overlap=${EXT}/package-lock.json ~ **/*.py
 12 -  51  path_overlap=${WORKSPACE}/docs/features/potential/promoted-notes-feature.md ~ **/*.py  contract_dependency=<path>
 12 -  52  path_overlap=**/*.py ~ --cov=scripts/dev_tools/foo.py  contract_dependency=main
 12 -  53  path_overlap=**/*.md ~ **/*.py
 12 -  54  path_overlap=**/*.py ~ .claude/**
 12 -  55  path_overlap=**/*.py ~ .claude/lib/**
 12 -  56  path_overlap=**/*.py ~ .claude/**
 12 -  57  path_overlap=**/*.py ~ .claude/hooks/validate-planner-output.ps1
 12 -  58  path_overlap=**/*.py ~ .claude/agents/<name>.md
 13 -  14  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
 13 -  15  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=schemas  shared_surface_overlap=scripts/dev_tools/validate_json.py
 13 -  16  path_overlap=.claude/** ~ .claude/**
 13 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
 13 -  18  path_overlap=**/*.sh ~ .agents/**
 13 -  20  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 13 -  22  path_overlap=.claude/** ~ .claude/agents/**
 13 -  23  path_overlap=.github/** ~ .github/copilot-instructions.md
 13 -  24  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 13 -  25  path_overlap=.agents/** ~ .agents/**
 13 -  26  path_overlap=.codex/** ~ .codex/config.toml  module_overlap=codex-runtime
 13 -  27  path_overlap=.agents/** ~ .agents/skills/**
 13 -  28  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 13 -  29  path_overlap=.claude/** ~ .claude/**  shared_surface_overlap=.claude/settings.json
 13 -  30  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 13 -  31  path_overlap=.agents/** ~ .agents/skills/**
 13 -  32  path_overlap=.agents/** ~ .agents/skills/architecture-boundaries/SKILL.md
 13 -  33  path_overlap=.agents/** ~ .agents/skills/general-code-change/SKILL.md  module_overlap=codex-runtime
 13 -  34  path_overlap=.claude/** ~ .claude/**
 13 -  35  path_overlap=.agents/** ~ .agents/**  module_overlap=codex-runtime
 13 -  36  path_overlap=.claude/** ~ .claude/lib/**
 13 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 13 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 13 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 13 -  40  path_overlap=.claude/** ~ .claude/**  shared_surface_overlap=.claude/settings.json
 13 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/**
 13 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 13 -  43  path_overlap=**/*.sh ~ .agents/**  shared_surface_overlap=.claude/settings.json
 13 -  44  path_overlap=.agents/** ~ .agents/skills/csharp-qa-gate/SKILL.md
 13 -  45  path_overlap=.claude/** ~ .claude/**
 13 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=schemas  shared_surface_overlap=.claude/settings.json
 13 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
 13 -  48  path_overlap=.agents/** ~ .agents/**  contract_dependency=core
 13 -  49  path_overlap=.claude/** ~ .claude/**
 13 -  50  path_overlap=.agents/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 13 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 13 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 13 -  53  path_overlap=**/*.md ~ .agents/**  shared_surface_overlap=.claude/settings.json
 13 -  54  path_overlap=.claude/** ~ .claude/**
 13 -  55  path_overlap=.claude/** ~ .claude/lib/**
 13 -  56  path_overlap=.claude/** ~ .claude/**  shared_surface_overlap=.claude/settings.json
 13 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 13 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 14 -  15  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-reports-368/**  shared_surface_overlap=scripts/dev_tools/validate_json.py
 14 -  16  contract_dependency=dev.discovery.*
 14 -  17  path_overlap=docs/features/epics/legacy-discovery-and-parity/epic.md ~ docs/features/epics/legacy-discovery-and-parity/epic.md  shared_surface_overlap=scripts/dev_tools/validate_json.py  contract_dependency=list[str]
 14 -  18  path_overlap=**/*.sh ~ .../evidence/baseline/py-format.<ts>.md
 14 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-reports-368/**
 14 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/discovery/**
 14 -  35  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-reports-368/**
 14 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/discovery/**
 14 -  37  path_overlap=scripts/dev_tools/discovery/** ~ scripts/dev_tools/discovery/analyzer/inventory.py
 14 -  38  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_format_json.py  contract_dependency=list[str]
 14 -  40  path_overlap=evidence/qa-gates/coverage-delta.<ts>.md ~ evidence/qa-gates/coverage-delta.<ts>.md
 14 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../evidence/baseline/py-format.<ts>.md
 14 -  42  path_overlap=evidence/qa-gates/coverage-delta.<ts>.md ~ evidence/qa-gates/coverage-delta.<ts>.md  contract_dependency=int
 14 -  43  path_overlap=**/*.sh ~ .../evidence/baseline/py-format.<ts>.md
 14 -  44  path_overlap=tests/** ~ tests/conftest.py
 14 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-reports-368/**
 14 -  46  path_overlap=scripts/dev_tools/*.py ~ scripts/dev_tools/discovery/**
 14 -  47  path_overlap=scripts/dev_tools/validate_json.py ~ scripts/dev_tools/validate_json.py  shared_surface_overlap=scripts/dev_tools/validate_json.py
 14 -  48  path_overlap=tests/** ~ tests/conftest.py
 14 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/discovery/**
 14 -  50  path_overlap=tests/scripts/dev_tools/atomic_executor/__init__.py ~ tests/scripts/dev_tools/atomic_executor/__init__.py  contract_dependency=int
 14 -  52  contract_dependency=list[str]
 14 -  53  path_overlap=**/*.md ~ .../evidence/baseline/py-format.<ts>.md
 14 -  56  path_overlap=tests/**/*.ps1 ~ tests/conftest.py
 15 -  16  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-skills-367/**
 15 -  17  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**  shared_surface_overlap=scripts/dev_tools/validate_json.py
 15 -  18  path_overlap=**/*.sh ~ .cache/schemas/<sha256>.json
 15 -  19  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**
 15 -  20  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 15 -  21  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/**
 15 -  22  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/**
 15 -  23  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 15 -  24  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-21-quickfiler-folder-selector-dropdown-400/evidence/regression-testing/coverage-wrapper-poshqc-test-blocker-retry.2026-07-25T03-33.md
 15 -  25  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/**
 15 -  26  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/**
 15 -  27  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/**
 15 -  28  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/**
 15 -  29  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/**
 15 -  30  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/**
 15 -  31  path_overlap=docs/** ~ docs/**/*.json
 15 -  32  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/**
 15 -  33  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/**
 15 -  34  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/**
 15 -  35  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=schemas
 15 -  36  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-cohort-scheduler-445/**
 15 -  37  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-drift-detection-446/**
 15 -  38  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md
 15 -  39  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-mutation-protocol-442/**
 15 -  40  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-orchestrator-surface-441/**
 15 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .cache/schemas/<sha256>.json
 15 -  42  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-07-parallel-schema-validators-444/**
 15 -  43  path_overlap=**/*.sh ~ .cache/schemas/<sha256>.json
 15 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md
 15 -  45  path_overlap=docs/** ~ docs/**/*.json
 15 -  46  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  module_overlap=schemas
 15 -  47  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md  shared_surface_overlap=scripts/dev_tools/validate_json.py
 15 -  48  path_overlap=.github/** ~ .github/copilot-instructions.md
 15 -  49  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/**
 15 -  50  path_overlap=docs/**/*.json ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.2026-07-18T10-20.md
 15 -  51  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/**
 15 -  52  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/**
 15 -  53  path_overlap=**/*.md ~ .cache/schemas/<sha256>.json  contract_dependency=description
 15 -  54  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 15 -  55  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/**
 15 -  56  path_overlap=docs/**/*.json ~ docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/**
 15 -  57  path_overlap=docs/**/*.json ~ docs/features/active/planner-hook-em-dash-mismatch-357/**
 15 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 16 -  17  contract_dependency=all
 16 -  18  path_overlap=**/*.sh ~ .claude/**
 16 -  20  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 16 -  22  path_overlap=.claude/** ~ .claude/agents/**
 16 -  24  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 16 -  25  path_overlap=.claude/** ~ .claude/**
 16 -  27  path_overlap=.claude/** ~ .claude/worktrees/**
 16 -  28  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 16 -  29  path_overlap=.claude/** ~ .claude/**
 16 -  30  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 16 -  31  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 16 -  34  path_overlap=.claude/** ~ .claude/**
 16 -  35  path_overlap=.claude/** ~ .claude/**
 16 -  36  path_overlap=.claude/** ~ .claude/lib/**
 16 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 16 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  contract_dependency=list[str]
 16 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 16 -  40  path_overlap=.claude/** ~ .claude/**
 16 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**
 16 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  contract_dependency=list[str]
 16 -  43  path_overlap=**/*.sh ~ .claude/**
 16 -  44  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 16 -  45  path_overlap=.claude/** ~ .claude/**
 16 -  46  path_overlap=.claude/** ~ .claude/**
 16 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 16 -  48  path_overlap=.claude/** ~ .claude/**
 16 -  49  path_overlap=.claude/** ~ .claude/**
 16 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 16 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 16 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1  contract_dependency=list[str]
 16 -  53  path_overlap=**/*.md ~ .claude/**
 16 -  54  path_overlap=.claude/** ~ .claude/**
 16 -  55  path_overlap=.claude/** ~ .claude/lib/**
 16 -  56  path_overlap=.claude/** ~ .claude/**
 16 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 16 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 17 -  18  path_overlap=**/*.sh ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**
 17 -  29  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 17 -  30  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 17 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**
 17 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/schema_loading.py
 17 -  35  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 17 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/schema_loading.py
 17 -  38  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 17 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 17 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/schema_loading.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 17 -  43  path_overlap=**/*.sh ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**
 17 -  44  path_overlap=tests/** ~ tests/scripts/dev_tools/test_schema_loading.py
 17 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**
 17 -  46  path_overlap=scripts/dev_tools/*.py ~ scripts/dev_tools/schema_loading.py  shared_surface_overlap=scripts/dev_tools/validate_discovery_artifacts.py
 17 -  47  path_overlap=scripts/dev_tools/validate_discovery_schema_artifacts.py ~ scripts/dev_tools/validate_discovery_schema_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_discovery_schema_artifacts.py
 17 -  48  path_overlap=tests/** ~ tests/scripts/dev_tools/test_schema_loading.py
 17 -  49  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/schema_loading.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 17 -  50  path_overlap=docs/features/active/2026-07-17-legacy-discovery-validators-361/** ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.2026-07-18T10-20.md
 17 -  52  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 17 -  53  path_overlap=**/*.md ~ docs/features/active/2026-07-17-legacy-discovery-validators-361/**
 17 -  56  path_overlap=tests/**/*.ps1 ~ tests/scripts/dev_tools/test_schema_loading.py
 18 -  19  path_overlap=**/*.sh ~ ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1
 18 -  20  path_overlap=**/*.sh ~ .claude/skills/cleanup-merged-worktrees/SKILL.md  contract_dependency=--help
 18 -  21  path_overlap=**/*.sh ~ config/orchestration-routing.json
 18 -  22  path_overlap=**/*.sh ~ .claude/agents/**
 18 -  23  path_overlap=**/*.sh ~ .github/copilot-instructions.md
 18 -  24  path_overlap=**/*.sh ~ ./scripts/powershell/PoshQC/PoshQC.psd1
 18 -  25  path_overlap=**/*.sh ~ .agents/**
 18 -  26  path_overlap=**/*.sh ~ .codex/config.toml
 18 -  27  path_overlap=**/*.sh ~ .agents/skills/**
 18 -  28  path_overlap=**/*.sh ~ ./dist/commonjs/index.js
 18 -  29  path_overlap=**/*.sh ~ ./src/lib/validate/orchestrator-state-core.ts
 18 -  30  path_overlap=**/*.sh ~ .claude/hooks/validate-orchestrator-output.ps1
 18 -  31  path_overlap=**/*.sh ~ .../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md  contract_dependency=test
 18 -  32  path_overlap=**/*.sh ~ .agents/skills/architecture-boundaries/SKILL.md
 18 -  33  path_overlap=**/*.sh ~ .agents/skills/general-code-change/SKILL.md
 18 -  34  path_overlap=**/*.sh ~ .claude/**  shared_surface_overlap=poetry.lock
 18 -  35  path_overlap=**/*.sh ~ .agents/**  shared_surface_overlap=poetry.lock
 18 -  36  path_overlap=**/*.sh ~ .claude/lib/**
 18 -  37  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
 18 -  38  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
 18 -  39  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=poetry.lock
 18 -  40  path_overlap=**/*.sh ~ .../.claude/skills/parallel-orchestrate/SKILL.md
 18 -  41  path_overlap=**/*.sh ~ **/extensions/drm-copilot/test/**/*.test.ts
 18 -  42  path_overlap=**/*.sh ~ ./src/lib/validate/parallel-orchestrator-state-core.ts
 18 -  43  path_overlap=**/*.sh ~ **/*.sh  shared_surface_overlap=poetry.lock  contract_dependency=bash
 18 -  44  path_overlap=**/*.sh ~ .agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
 18 -  45  path_overlap=**/*.sh ~ .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md  shared_surface_overlap=poetry.lock
 18 -  46  path_overlap=**/*.sh ~ .claude/**
 18 -  47  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
 18 -  48  path_overlap=**/*.sh ~ .agents/**
 18 -  49  path_overlap=**/*.sh ~ .claude/**
 18 -  50  path_overlap=${EXT}/package-lock.json ~ **/*.sh
 18 -  51  path_overlap=${WORKSPACE}/docs/features/potential/promoted-notes-feature.md ~ **/*.sh
 18 -  52  path_overlap=**/*.sh ~ --cov=scripts/dev_tools/foo.py
 18 -  53  path_overlap=**/*.md ~ **/*.sh  contract_dependency=if
 18 -  54  path_overlap=**/*.sh ~ .claude/**
 18 -  55  path_overlap=**/*.sh ~ .claude/lib/**
 18 -  56  path_overlap=**/*.sh ~ .claude/**
 18 -  57  path_overlap=**/*.sh ~ .claude/hooks/validate-planner-output.ps1
 18 -  58  path_overlap=**/*.sh ~ .claude/agents/<name>.md
 19 -  24  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 ~ extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  30  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**
 19 -  34  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  35  path_overlap=docs/** ~ docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  37  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  38  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1
 19 -  43  path_overlap=**/*.sh ~ ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1
 19 -  44  path_overlap=tests/** ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py
 19 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**
 19 -  46  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  48  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  53  path_overlap=**/*.md ~ ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  54  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  55  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 19 -  56  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 20 -  22  path_overlap=.claude/skills/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  23  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 20 -  25  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  27  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 20 -  28  path_overlap=.github/workflows/** ~ .github/workflows/_shell-coverage.yml
 20 -  29  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  30  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 20 -  31  path_overlap=.github/workflows/** ~ .github/workflows/_shell-coverage.yml
 20 -  34  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  35  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  39  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 20 -  40  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  43  path_overlap=**/*.sh ~ .claude/skills/cleanup-merged-worktrees/SKILL.md  contract_dependency=bash
 20 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md
 20 -  45  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  46  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  47  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 20 -  48  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  49  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  53  path_overlap=**/*.md ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  54  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  56  path_overlap=.claude/** ~ .claude/skills/cleanup-merged-worktrees/SKILL.md
 20 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 21 -  26  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  29  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-22-large-route-matrix-promotion-type-gap-399/**
 21 -  33  path_overlap=scripts/dev_tools/_orchestrator_state_routing.py ~ scripts/dev_tools/_orchestrator_state_routing.py  shared_surface_overlap=scripts/dev_tools/_orchestrator_state_routing.py
 21 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/_orchestrator_state_routing.py  module_overlap=config
 21 -  35  path_overlap=config/** ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/_orchestrator_state_routing.py
 21 -  38  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_orchestration_routing_config_parity.py
 21 -  39  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  40  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  42  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  43  path_overlap=**/*.sh ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  44  path_overlap=tests/** ~ tests/scripts/dev_tools/test_orchestration_routing_config_parity.py
 21 -  45  path_overlap=config/** ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  46  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 21 -  48  path_overlap=tests/** ~ tests/scripts/dev_tools/test_orchestration_routing_config_parity.py
 21 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/resources/config/orchestration-routing.json  module_overlap=config
 21 -  53  path_overlap=**/*.md ~ config/orchestration-routing.json
 21 -  55  module_overlap=config
 21 -  56  path_overlap=tests/**/*.ps1 ~ tests/scripts/dev_tools/test_orchestration_routing_config_parity.py
 22 -  23  path_overlap=docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md ~ docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md
 22 -  24  path_overlap=.claude/skills/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 22 -  25  path_overlap=.claude/** ~ .claude/agents/**
 22 -  27  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts
 22 -  28  path_overlap=.claude/skills/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 22 -  29  path_overlap=.claude/** ~ .claude/agents/**
 22 -  30  path_overlap=.claude/skills/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 22 -  31  path_overlap=.claude/skills/** ~ .claude/skills/orchestrate/SKILL.md
 22 -  34  path_overlap=.claude/** ~ .claude/agents/**
 22 -  35  path_overlap=.claude/** ~ .claude/agents/**
 22 -  36  path_overlap=docs/research/** ~ docs/research/2026-08-07-parallel-orchestration-design-research.md
 22 -  37  path_overlap=.claude/agents/** ~ .claude/agents/parallel-orchestrator.md
 22 -  38  path_overlap=.claude/agents/** ~ .claude/agents/parallel-orchestrator.md
 22 -  39  path_overlap=.claude/agents/** ~ .claude/agents/parallel-orchestrator.md
 22 -  40  path_overlap=.claude/** ~ .claude/agents/**
 22 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/**
 22 -  42  path_overlap=.claude/skills/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 22 -  43  path_overlap=**/*.sh ~ .claude/agents/**
 22 -  44  path_overlap=.claude/skills/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 22 -  45  path_overlap=.claude/** ~ .claude/agents/**
 22 -  46  path_overlap=.claude/** ~ .claude/agents/**
 22 -  47  path_overlap=.claude/agents/** ~ .claude/agents/parallel-orchestrator.md
 22 -  48  path_overlap=.claude/** ~ .claude/agents/**
 22 -  49  path_overlap=.claude/** ~ .claude/agents/**
 22 -  50  path_overlap=.claude/skills/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 22 -  51  path_overlap=.claude/skills/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 22 -  52  path_overlap=extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts ~ extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
 22 -  53  path_overlap=**/*.md ~ .claude/agents/**
 22 -  54  path_overlap=.claude/** ~ .claude/agents/**
 22 -  55  path_overlap=.claude/skills/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 22 -  56  path_overlap=.claude/** ~ .claude/agents/**
 22 -  58  path_overlap=.claude/agents/** ~ .claude/agents/<name>.md
 23 -  28  path_overlap=.github/workflows/** ~ .github/workflows/_npm-audit-gate.yml  module_overlap=mcp-server  shared_surface_overlap=extensions/drm-copilot/package-lock.json
 23 -  29  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
 23 -  31  path_overlap=.github/workflows/** ~ .github/workflows/_npm-audit-gate.yml  shared_surface_overlap=package-lock.json
 23 -  32  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
 23 -  34  path_overlap=package-lock.json ~ package-lock.json  shared_surface_overlap=package-lock.json
 23 -  35  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=mcp-server
 23 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .github/copilot-instructions.md
 23 -  43  path_overlap=**/*.sh ~ .github/copilot-instructions.md  shared_surface_overlap=package-lock.json
 23 -  44  path_overlap=.github/** ~ .github/copilot-instructions.md  module_overlap=mcp-server
 23 -  45  path_overlap=docs/** ~ docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/**  shared_surface_overlap=package-lock.json
 23 -  46  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 23 -  47  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 23 -  48  path_overlap=.github/** ~ .github/copilot-instructions.md
 23 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/package-lock.json
 23 -  53  path_overlap=**/*.md ~ .github/copilot-instructions.md  shared_surface_overlap=package-lock.json
 23 -  54  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 23 -  55  path_overlap=extensions/drm-copilot/package-lock.json ~ extensions/drm-copilot/package-lock.json  shared_surface_overlap=extensions/drm-copilot/package-lock.json
 23 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 24 -  25  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  28  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  29  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  30  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-21-quickfiler-folder-selector-dropdown-400/evidence/regression-testing/coverage-wrapper-poshqc-test-blocker-retry.2026-07-25T03-33.md
 24 -  34  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  35  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  37  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  38  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  39  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  40  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./scripts/powershell/PoshQC/PoshQC.psd1
 24 -  42  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  43  path_overlap=**/*.sh ~ ./scripts/powershell/PoshQC/PoshQC.psd1
 24 -  44  path_overlap=tests/** ~ tests/scripts/dev_tools/test_poshqc_bundled_parity.py
 24 -  45  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 24 -  46  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  48  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  49  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  53  path_overlap=**/*.md ~ ./scripts/powershell/PoshQC/PoshQC.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  54  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  55  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 24 -  56  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 25 -  26  path_overlap=tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
 25 -  27  path_overlap=.agents/** ~ .agents/skills/**
 25 -  28  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 25 -  29  path_overlap=.claude/** ~ .claude/**
 25 -  30  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 25 -  31  path_overlap=.agents/** ~ .agents/skills/**
 25 -  32  path_overlap=.agents/** ~ .agents/skills/architecture-boundaries/SKILL.md
 25 -  33  path_overlap=.agents/** ~ .agents/skills/general-code-change/SKILL.md
 25 -  34  path_overlap=.claude/** ~ .claude/**
 25 -  35  path_overlap=.agents/** ~ .agents/**
 25 -  36  path_overlap=.claude/** ~ .claude/lib/**
 25 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 25 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 25 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 25 -  40  path_overlap=.claude/** ~ .claude/**
 25 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/**
 25 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 25 -  43  path_overlap=**/*.sh ~ .agents/**
 25 -  44  path_overlap=.agents/** ~ .agents/skills/csharp-qa-gate/SKILL.md
 25 -  45  path_overlap=.claude/** ~ .claude/**
 25 -  46  path_overlap=.claude/** ~ .claude/**
 25 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 25 -  48  path_overlap=.agents/** ~ .agents/**
 25 -  49  path_overlap=.claude/** ~ .claude/**
 25 -  50  path_overlap=.agents/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 25 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 25 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 25 -  53  path_overlap=**/*.md ~ .agents/**
 25 -  54  path_overlap=.claude/** ~ .claude/**
 25 -  55  path_overlap=.claude/** ~ .claude/lib/**
 25 -  56  path_overlap=.claude/** ~ .claude/**
 25 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 25 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 26 -  29  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  30  path_overlap=extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1 ~ extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1
 26 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/**
 26 -  33  module_overlap=codex-runtime
 26 -  34  module_overlap=config
 26 -  35  path_overlap=.codex/** ~ .codex/config.toml  module_overlap=codex-runtime  shared_surface_overlap=config/orchestration-routing.json
 26 -  38  path_overlap=tests/scripts/claude-hooks/*.Tests.ps1 ~ tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
 26 -  39  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  40  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .codex/config.toml  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  42  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  43  path_overlap=**/*.sh ~ .codex/config.toml  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  44  path_overlap=tests/** ~ tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
 26 -  45  path_overlap=config/** ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  46  path_overlap=config/orchestration-routing.json ~ config/orchestration-routing.json  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 26 -  47  path_overlap=pack-manifests/core.json ~ pack-manifests/core.json
 26 -  48  path_overlap=tests/** ~ tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
 26 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml  module_overlap=config
 26 -  50  path_overlap=tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
 26 -  53  path_overlap=**/*.md ~ .codex/config.toml
 26 -  55  path_overlap=pack-manifests/core.json ~ pack-manifests/core.json  module_overlap=config
 26 -  56  path_overlap=FEATURE/evidence/baseline/phase0-instructions-read.md ~ FEATURE/evidence/baseline/phase0-instructions-read.md
 27 -  29  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  30  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 27 -  31  path_overlap=.agents/skills/** ~ .agents/skills/**
 27 -  32  path_overlap=.agents/skills/** ~ .agents/skills/architecture-boundaries/SKILL.md
 27 -  33  path_overlap=.agents/skills/** ~ .agents/skills/general-code-change/SKILL.md
 27 -  34  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  35  path_overlap=.agents/** ~ .agents/skills/**
 27 -  39  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 27 -  40  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/skills/**
 27 -  42  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/lib/validate/epic-*
 27 -  43  path_overlap=**/*.sh ~ .agents/skills/**
 27 -  44  path_overlap=.agents/skills/** ~ .agents/skills/csharp-qa-gate/SKILL.md
 27 -  45  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  46  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  47  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 27 -  48  path_overlap=.agents/** ~ .agents/skills/**
 27 -  49  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  50  path_overlap=.agents/skills/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 27 -  51  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/lib/new-active-feature-folder/fakes.ts
 27 -  52  path_overlap=extensions/drm-copilot/test/** ~ extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts
 27 -  53  path_overlap=**/*.md ~ .agents/skills/**
 27 -  54  path_overlap=.claude/** ~ .claude/worktrees/**
 27 -  55  path_overlap=extensions/drm-copilot/resources/claude-customizations/** ~ extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
 27 -  56  path_overlap=.claude/** ~ .claude/worktrees/**
 28 -  29  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 28 -  30  path_overlap=.claude/hooks/validate-orchestrator-output.ps1 ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 28 -  31  path_overlap=.github/workflows/** ~ .github/workflows/**  shared_surface_overlap=package-lock.json
 28 -  32  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
 28 -  33  path_overlap=scripts/dev_tools/validate_orchestrator_state.py ~ scripts/dev_tools/validate_orchestrator_state.py  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 28 -  34  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=package-lock.json
 28 -  35  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=mcp-server
 28 -  36  path_overlap=.claude/lib/** ~ .claude/lib/model-routing/ModelRouting.psm1
 28 -  38  path_overlap=.claude/hooks/validate-orchestrator-output.ps1 ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  39  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 28 -  40  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./dist/commonjs/index.js
 28 -  42  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 28 -  43  path_overlap=**/*.sh ~ ./dist/commonjs/index.js  shared_surface_overlap=package-lock.json
 28 -  44  path_overlap=.github/** ~ .github/workflows/**  module_overlap=mcp-server
 28 -  45  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=package-lock.json
 28 -  46  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  47  path_overlap=.github/workflows/** ~ .github/workflows/_shell-coverage.yml
 28 -  48  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  49  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  53  path_overlap=**/*.md ~ ./dist/commonjs/index.js  shared_surface_overlap=package-lock.json
 28 -  54  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  55  path_overlap=.claude/lib/** ~ .claude/lib/model-routing/ModelRouting.psm1  shared_surface_overlap=extensions/drm-copilot/package-lock.json
 28 -  56  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 28 -  58  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
 29 -  30  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 29 -  31  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 29 -  32  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
 29 -  33  path_overlap=extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts ~ extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 29 -  34  path_overlap=.claude/** ~ .claude/**  module_overlap=config
 29 -  35  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 29 -  36  path_overlap=.claude/** ~ .claude/lib/**
 29 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 29 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 29 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=.claude/settings.json
 29 -  40  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=.claude/settings.json
 29 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./src/lib/validate/orchestrator-state-core.ts  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 29 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 29 -  43  path_overlap=**/*.sh ~ ./src/lib/validate/orchestrator-state-core.ts  module_overlap=config  shared_surface_overlap=.claude/settings.json
 29 -  44  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 29 -  45  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 29 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=.claude/settings.json  contract_dependency=--require-complete
 29 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 29 -  48  path_overlap=.claude/** ~ .claude/**
 29 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 29 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 29 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 29 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 29 -  53  path_overlap=**/*.md ~ ./src/lib/validate/orchestrator-state-core.ts  shared_surface_overlap=.claude/settings.json
 29 -  54  path_overlap=.claude/** ~ .claude/**
 29 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config
 29 -  56  path_overlap=.claude/** ~ .claude/**  shared_surface_overlap=.claude/settings.json
 29 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 29 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 30 -  31  path_overlap=docs/** ~ docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/**
 30 -  33  path_overlap=scripts/dev_tools/validate_orchestrator_state.py ~ scripts/dev_tools/validate_orchestrator_state.py  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 30 -  34  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  35  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  36  path_overlap=.claude/lib/** ~ .claude/lib/orchestrator-state/OrchestratorState.psm1
 30 -  37  path_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ~ scripts/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  38  path_overlap=.claude/hooks/validate-orchestrator-output.ps1 ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  39  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 30 -  40  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 30 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  42  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  43  path_overlap=**/*.sh ~ .claude/hooks/validate-orchestrator-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 30 -  44  path_overlap=tests/** ~ tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
 30 -  45  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1
 30 -  46  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  47  path_overlap=<FEATURE>/evidence/baseline/phase0-instructions-read.md ~ <FEATURE>/evidence/baseline/phase0-instructions-read.md
 30 -  48  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  49  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  50  path_overlap=tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
 30 -  52  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 30 -  53  path_overlap=**/*.md ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  54  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  55  path_overlap=.claude/lib/** ~ .claude/lib/orchestrator-state/OrchestratorState.psm1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 30 -  56  path_overlap=.claude/** ~ .claude/hooks/validate-orchestrator-output.ps1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 31 -  32  path_overlap=.agents/skills/** ~ .agents/skills/architecture-boundaries/SKILL.md
 31 -  33  path_overlap=.agents/skills/** ~ .agents/skills/general-code-change/SKILL.md
 31 -  34  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md  shared_surface_overlap=package-lock.json
 31 -  35  path_overlap=.agents/** ~ .agents/skills/**
 31 -  36  path_overlap=docs/** ~ docs/features/active/2026-08-07-parallel-cohort-scheduler-445/**
 31 -  37  path_overlap=.claude/skills/orchestrate/SKILL.md ~ .claude/skills/orchestrate/SKILL.md
 31 -  38  path_overlap=docs/** ~ docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md
 31 -  39  path_overlap=docs/** ~ docs/features/active/2026-08-07-parallel-mutation-protocol-442/**
 31 -  40  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 31 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md
 31 -  42  path_overlap=docs/** ~ docs/features/active/2026-08-07-parallel-schema-validators-444/**
 31 -  43  path_overlap=**/*.sh ~ .../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md  shared_surface_overlap=package-lock.json
 31 -  44  path_overlap=.agents/skills/** ~ .agents/skills/csharp-qa-gate/SKILL.md
 31 -  45  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md  shared_surface_overlap=package-lock.json
 31 -  46  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 31 -  47  path_overlap=.github/workflows/** ~ .github/workflows/_shell-coverage.yml
 31 -  48  path_overlap=.agents/** ~ .agents/skills/**
 31 -  49  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 31 -  50  path_overlap=.agents/skills/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 31 -  51  path_overlap=docs/** ~ docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/**
 31 -  52  path_overlap=docs/** ~ docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/**
 31 -  53  path_overlap=**/*.md ~ .../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md  shared_surface_overlap=package-lock.json
 31 -  54  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 31 -  55  path_overlap=docs/** ~ docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/**
 31 -  56  path_overlap=.claude/** ~ .claude/skills/orchestrate/SKILL.md
 31 -  57  path_overlap=docs/** ~ docs/features/active/planner-hook-em-dash-mismatch-357/**
 31 -  58  path_overlap=docs/** ~ docs/code-change.instructions.md
 32 -  33  path_overlap=.agents/skills/general-code-change/SKILL.md ~ .agents/skills/general-code-change/SKILL.md
 32 -  35  path_overlap=.agents/** ~ .agents/skills/architecture-boundaries/SKILL.md  module_overlap=mcp-server
 32 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/skills/architecture-boundaries/SKILL.md
 32 -  42  path_overlap=extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts ~ extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
 32 -  43  path_overlap=**/*.sh ~ .agents/skills/architecture-boundaries/SKILL.md
 32 -  44  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json  module_overlap=mcp-server
 32 -  45  path_overlap=docs/** ~ docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/**
 32 -  48  path_overlap=.agents/** ~ .agents/skills/architecture-boundaries/SKILL.md
 32 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/package.json
 32 -  52  path_overlap=extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts ~ extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
 32 -  53  path_overlap=**/*.md ~ .agents/skills/architecture-boundaries/SKILL.md
 32 -  58  path_overlap=extensions/drm-copilot/package.json ~ extensions/drm-copilot/package.json
 33 -  34  path_overlap=scripts/*/a.py ~ scripts/dev_tools/_orchestrator_state_codex_model_routing.py
 33 -  35  path_overlap=.agents/** ~ .agents/skills/general-code-change/SKILL.md  module_overlap=codex-runtime
 33 -  36  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/_orchestrator_state_codex_model_routing.py
 33 -  38  path_overlap=evidence/baseline/python-tests-coverage.<timestamp>.md ~ evidence/baseline/python-tests-coverage.<timestamp>.md  contract_dependency=validate_orchestration_artifacts
 33 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/skills/general-code-change/SKILL.md
 33 -  42  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/_orchestrator_state_codex_model_routing.py
 33 -  43  path_overlap=**/*.sh ~ .agents/skills/general-code-change/SKILL.md  shared_surface_overlap=scripts/dev_tools/validate_orchestrator_state.py
 33 -  44  path_overlap=tests/** ~ tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py
 33 -  45  path_overlap=docs/** ~ docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/**
 33 -  46  path_overlap=scripts/dev_tools/*.py ~ scripts/dev_tools/_orchestrator_state_codex_model_routing.py
 33 -  48  path_overlap=.agents/** ~ .agents/skills/general-code-change/SKILL.md
 33 -  49  path_overlap=extensions/drm-copilot/** ~ extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts
 33 -  53  path_overlap=**/*.md ~ .agents/skills/general-code-change/SKILL.md
 33 -  56  path_overlap=tests/**/*.ps1 ~ tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py
 34 -  35  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 34 -  36  path_overlap=.claude/** ~ .claude/lib/**
 34 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 34 -  40  path_overlap=.claude/** ~ .claude/**  module_overlap=config
 34 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json  contract_dependency=artifact_type
 34 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config
 34 -  43  path_overlap=**/*.sh ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 34 -  44  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 34 -  45  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 34 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 34 -  48  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 34 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 34 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md  contract_dependency=artifact_type
 34 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 34 -  53  path_overlap=**/*.md ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=package-lock.json  contract_dependency=paths
 34 -  54  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json  contract_dependency=paths
 34 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 34 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 34 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 35 -  36  path_overlap=.claude/** ~ .claude/lib/**
 35 -  37  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1  contract_dependency=--name-only
 35 -  38  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 35 -  39  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 35 -  40  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 35 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 35 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 35 -  43  path_overlap=**/*.sh ~ .agents/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 35 -  44  path_overlap=.agents/** ~ .agents/skills/csharp-qa-gate/SKILL.md  module_overlap=mcp-server
 35 -  45  path_overlap=.claude/** ~ .claude/**  module_overlap=benchmarks  shared_surface_overlap=config/blast-radius.json
 35 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 35 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 35 -  48  path_overlap=.agents/** ~ .agents/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 35 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 35 -  50  path_overlap=.agents/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 35 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 35 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 35 -  53  path_overlap=**/*.md ~ .agents/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 35 -  54  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 35 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 35 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 35 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 35 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 36 -  37  path_overlap=docs/research/2026-08-07-parallel-orchestration-design-research.md ~ docs/research/2026-08-07-parallel-orchestration-design-research.md
 36 -  38  path_overlap=docs/research/2026-08-07-parallel-orchestration-design-research.md ~ docs/research/2026-08-07-parallel-orchestration-design-research.md
 36 -  39  path_overlap=docs/research/2026-08-07-parallel-orchestration-design-research.md ~ docs/research/2026-08-07-parallel-orchestration-design-research.md
 36 -  40  path_overlap=.claude/** ~ .claude/lib/**
 36 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/lib/**
 36 -  42  path_overlap=docs/research/2026-08-07-parallel-orchestration-design-research.md ~ docs/research/2026-08-07-parallel-orchestration-design-research.md
 36 -  43  path_overlap=**/*.sh ~ .claude/lib/**
 36 -  44  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/push_down_claude_customizations.py
 36 -  45  path_overlap=.claude/** ~ .claude/lib/**
 36 -  46  path_overlap=.claude/** ~ .claude/lib/**
 36 -  47  path_overlap=.claude/lib/** ~ .claude/lib/bash/compute-concurrency-batches.sh
 36 -  48  path_overlap=.claude/** ~ .claude/lib/**
 36 -  49  path_overlap=.claude/** ~ .claude/lib/**
 36 -  50  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/atomic_executor/pytest_expectations.py
 36 -  51  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/new_active_feature_folder*.py
 36 -  52  path_overlap=scripts/dev_tools/** ~ scripts/dev_tools/epic_planner_readiness.py
 36 -  53  path_overlap=**/*.md ~ .claude/lib/**
 36 -  54  path_overlap=.claude/** ~ .claude/lib/**
 36 -  55  path_overlap=.claude/lib/** ~ .claude/lib/**
 36 -  56  path_overlap=.claude/** ~ .claude/lib/**
 37 -  38  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 37 -  39  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=b)
 37 -  40  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 37 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/parallel-orchestrator.md
 37 -  42  path_overlap=docs/research/2026-08-07-parallel-orchestration-design-research.md ~ docs/research/2026-08-07-parallel-orchestration-design-research.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py  contract_dependency=bool
 37 -  43  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 37 -  44  path_overlap=tests/** ~ tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
 37 -  45  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 37 -  46  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 37 -  47  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py
 37 -  48  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 37 -  49  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 37 -  51  contract_dependency=true
 37 -  53  path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 37 -  54  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 37 -  55  path_overlap=scripts/dev_tools/compute_blast_radius.py ~ scripts/dev_tools/compute_blast_radius.py  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 37 -  56  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 38 -  39  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=blocked_drift
 38 -  40  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 38 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 38 -  42  path_overlap=docs/features/epics/parallel-orchestration/epic.md ~ docs/features/epics/parallel-orchestration/epic.md  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 38 -  43  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 38 -  44  path_overlap=tests/** ~ tests/scripts/claude-hooks/*.Tests.ps1
 38 -  45  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 38 -  46  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json  contract_dependency=parallel-orchestrator-state
 38 -  47  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py
 38 -  48  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 38 -  49  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 38 -  50  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_collect_pr_context*.py
 38 -  51  path_overlap=tests/scripts/dev_tools/test_*.py ~ tests/scripts/dev_tools/test_new_active_feature_folder.py  contract_dependency=true
 38 -  52  path_overlap=scripts/dev_tools/validate_orchestration_artifacts.py ~ scripts/dev_tools/validate_orchestration_artifacts.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 38 -  53  path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json  contract_dependency=-ToolInputRaw
 38 -  54  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 38 -  55  path_overlap=extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 ~ extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 38 -  56  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 38 -  57  path_overlap=tests/scripts/claude-hooks/*.Tests.ps1 ~ tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
 39 -  40  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=.claude/settings.json
 39 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 39 -  42  path_overlap=.claude/skills/acceptance-criteria-tracking/SKILL.md ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 39 -  43  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=.claude/settings.json
 39 -  44  path_overlap=tests/** ~ tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
 39 -  45  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 39 -  46  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=.claude/settings.json
 39 -  47  path_overlap=.claude/agents/parallel-orchestrator.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py  contract_dependency=max_concurrency
 39 -  48  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 39 -  49  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 39 -  53  path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 39 -  54  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 39 -  55  path_overlap=config/blast-radius.json ~ config/blast-radius.json  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 39 -  56  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=.claude/settings.json
 40 -  41  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../.claude/skills/parallel-orchestrate/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 40 -  42  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 40 -  43  path_overlap=**/*.sh ~ .../.claude/skills/parallel-orchestrate/SKILL.md  module_overlap=config  shared_surface_overlap=.claude/settings.json  contract_dependency=Parallel
 40 -  44  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 40 -  45  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 40 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=.claude/settings.json
 40 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py
 40 -  48  path_overlap=.claude/** ~ .claude/**
 40 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config
 40 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 40 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md  contract_dependency=true
 40 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 40 -  53  path_overlap=**/*.md ~ .../.claude/skills/parallel-orchestrate/SKILL.md  shared_surface_overlap=.claude/settings.json
 40 -  54  path_overlap=.claude/** ~ .claude/**
 40 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config
 40 -  56  path_overlap=.claude/** ~ .claude/**  shared_surface_overlap=.claude/settings.json
 40 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 40 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 41 -  42  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ ./src/lib/validate/parallel-orchestrator-state-core.ts  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 41 -  43  path_overlap=**/*.sh ~ **/extensions/drm-copilot/test/**/*.test.ts  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 41 -  44  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
 41 -  45  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 41 -  46  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 41 -  47  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/parallel-orchestrator.md  shared_surface_overlap=scripts/dev_tools/validate_parallel_planner_state.py
 41 -  48  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .agents/**
 41 -  49  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 41 -  50  path_overlap=${EXT}/package-lock.json ~ **/extensions/drm-copilot/test/**/*.test.ts
 41 -  51  path_overlap=${WORKSPACE}/docs/features/potential/promoted-notes-feature.md ~ **/extensions/drm-copilot/test/**/*.test.ts  contract_dependency=artifact_type
 41 -  52  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ --cov=scripts/dev_tools/foo.py  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 41 -  53  path_overlap=**/*.md ~ **/extensions/drm-copilot/test/**/*.test.ts
 41 -  54  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**
 41 -  55  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 41 -  56  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/**
 41 -  57  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/hooks/validate-planner-output.ps1
 41 -  58  path_overlap=**/extensions/drm-copilot/test/**/*.test.ts ~ .claude/agents/<name>.md
 42 -  43  path_overlap=**/*.sh ~ ./src/lib/validate/parallel-orchestrator-state-core.ts  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 42 -  44  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/push_down_claude_customizations.py
 42 -  45  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 42 -  46  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 42 -  47  path_overlap=extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts ~ extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts  shared_surface_overlap=scripts/dev_tools/validate_parallel_orchestrator_state.py
 42 -  48  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 42 -  49  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md  module_overlap=config  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 42 -  50  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/atomic_executor/pytest_expectations.py  contract_dependency=int
 42 -  51  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/new_active_feature_folder*.py
 42 -  52  path_overlap=extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts ~ extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py  contract_dependency=list[str]
 42 -  53  path_overlap=**/*.md ~ ./src/lib/validate/parallel-orchestrator-state-core.ts
 42 -  54  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 42 -  55  path_overlap=scripts/dev_tools/*parallel* ~ scripts/dev_tools/_blast_radius_extraction.py  module_overlap=config
 42 -  56  path_overlap=.claude/** ~ .claude/skills/acceptance-criteria-tracking/SKILL.md
 43 -  44  path_overlap=**/*.sh ~ .agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
 43 -  45  path_overlap=**/*.sh ~ .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 43 -  46  path_overlap=**/*.sh ~ .claude/**  module_overlap=config  shared_surface_overlap=.claude/settings.json
 43 -  47  path_overlap=**/*.sh ~ .claude/agents/parallel-orchestrator.md
 43 -  48  path_overlap=**/*.sh ~ .agents/**
 43 -  49  path_overlap=**/*.sh ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 43 -  50  path_overlap=${EXT}/package-lock.json ~ **/*.sh
 43 -  51  path_overlap=${WORKSPACE}/docs/features/potential/promoted-notes-feature.md ~ **/*.sh
 43 -  52  path_overlap=**/*.sh ~ --cov=scripts/dev_tools/foo.py
 43 -  53  path_overlap=**/*.md ~ **/*.sh  shared_surface_overlap=.claude/settings.json
 43 -  54  path_overlap=**/*.sh ~ .claude/**
 43 -  55  path_overlap=**/*.sh ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 43 -  56  path_overlap=**/*.sh ~ .claude/**  shared_surface_overlap=.claude/settings.json
 43 -  57  path_overlap=**/*.sh ~ .claude/hooks/validate-planner-output.ps1
 43 -  58  path_overlap=**/*.sh ~ .claude/agents/<name>.md
 44 -  45  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 44 -  46  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 44 -  47  path_overlap=.github/** ~ .github/copilot-instructions.md
 44 -  48  path_overlap=.agents/** ~ .agents/skills/csharp-qa-gate/SKILL.md
 44 -  49  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 44 -  50  path_overlap=.github/** ~ .github/skills/evidence-and-timestamp-conventions/SKILL.md
 44 -  51  path_overlap=tests/** ~ tests/scripts/dev_tools/test_new_active_feature_folder.py
 44 -  52  path_overlap=tests/** ~ tests/scripts/dev_tools/test_plan_gate_commands.py
 44 -  53  path_overlap=**/*.md ~ .agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md
 44 -  54  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 44 -  55  path_overlap=tests/** ~ tests/fixtures/blast_radius/conflict-path-overlap.json
 44 -  56  path_overlap=.claude/** ~ .claude/skills/csharp-qa-gate/SKILL.md
 44 -  57  path_overlap=tests/** ~ tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
 44 -  58  path_overlap=.github/** ~ .github/copilot-instructions.md
 45 -  46  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/orchestration-routing.json
 45 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 45 -  48  path_overlap=.claude/** ~ .claude/**
 45 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 45 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 45 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 45 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 45 -  53  path_overlap=**/*.md ~ .../evidence/qa-gates/final-ts-test-coverage.<ISO-8601>.md  shared_surface_overlap=package-lock.json
 45 -  54  path_overlap=.claude/** ~ .claude/**
 45 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 45 -  56  path_overlap=.claude/** ~ .claude/**
 45 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 45 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 46 -  47  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 46 -  48  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 46 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 46 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 46 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 46 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1  contract_dependency=repr()
 46 -  53  path_overlap=**/*.md ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 46 -  54  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 46 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 46 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 46 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 46 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 47 -  48  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 47 -  49  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 47 -  50  path_overlap=docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/** ~ docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/other/cross-cutting-gates.2026-08-17T02-25.md
 47 -  53  path_overlap=**/*.md ~ .claude/agents/parallel-orchestrator.md
 47 -  54  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 47 -  55  path_overlap=.claude/lib/** ~ .claude/lib/bash/compute-concurrency-batches.sh
 47 -  56  path_overlap=.claude/** ~ .claude/agents/parallel-orchestrator.md
 47 -  58  path_overlap=.github/copilot-instructions.md ~ .github/copilot-instructions.md
 48 -  49  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 48 -  50  path_overlap=.agents/** ~ .agents/skills/evidence-and-timestamp-conventions/SKILL.md
 48 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 48 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 48 -  53  path_overlap=**/*.md ~ .agents/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 48 -  54  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 48 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 48 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 48 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 48 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 49 -  50  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 49 -  51  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 49 -  52  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1  shared_surface_overlap=scripts/dev_tools/validate_orchestration_artifacts.py
 49 -  53  path_overlap=**/*.md ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 49 -  54  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 49 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=config  shared_surface_overlap=config/blast-radius.json
 49 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 49 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 49 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 50 -  53  path_overlap=${EXT}/package-lock.json ~ **/*.md
 50 -  54  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 50 -  55  path_overlap=tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ~ tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
 50 -  56  path_overlap=.claude/** ~ .claude/skills/atomic-plan-contract/SKILL.md:135
 51 -  52  path_overlap=extensions/drm-copilot/src/mcp-tools.ts ~ extensions/drm-copilot/src/mcp-tools.ts
 51 -  53  path_overlap=${WORKSPACE}/docs/features/potential/promoted-notes-feature.md ~ **/*.md
 51 -  54  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 51 -  55  path_overlap=.claude/skills/feature-promotion-lifecycle/SKILL.md ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 51 -  56  path_overlap=.claude/** ~ .claude/skills/feature-promotion-lifecycle/SKILL.md
 51 -  58  path_overlap=docs/research/2026-07-09-potential-entries-duplicate-audit.md ~ docs/research/2026-07-09-potential-entries-duplicate-audit.md
 52 -  53  path_overlap=**/*.md ~ --cov=scripts/dev_tools/foo.py
 52 -  54  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 52 -  56  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 52 -  57  path_overlap=.claude/hooks/validate-planner-output.ps1 ~ .claude/hooks/validate-planner-output.ps1
 53 -  54  path_overlap=**/*.md ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 53 -  55  path_overlap=**/*.md ~ .claude/lib/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1  contract_dependency=paths
 53 -  56  path_overlap=**/*.md ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=.claude/settings.json
 53 -  57  path_overlap=**/*.md ~ .claude/hooks/validate-planner-output.ps1
 53 -  58  path_overlap=**/*.md ~ .claude/agents/<name>.md
 54 -  55  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 54 -  56  path_overlap=.claude/** ~ .claude/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 54 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 54 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
 55 -  56  path_overlap=.claude/** ~ .claude/lib/**  module_overlap=poshqc  shared_surface_overlap=scripts/powershell/PoshQC/settings/pester.runsettings.psd1
 56 -  57  path_overlap=.claude/** ~ .claude/hooks/validate-planner-output.ps1
 56 -  58  path_overlap=.claude/** ~ .claude/agents/<name>.md
```

## Output Summary

Before-state corpus measurement over 58 plan documents: 1282 conflict edges out of 1653 possible pairs, density 77.6%, 32 cohorts, maximum cohort width 4, and 3729 total radius path entries across all radii. The item list and the full edge set with reason kinds and details are stored above for the after-measurement to compare against.
