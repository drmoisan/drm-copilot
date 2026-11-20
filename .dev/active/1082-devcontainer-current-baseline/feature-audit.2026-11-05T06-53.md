# Feature Audit: Devcontainer current baseline (#1082)

Audit Date: 2026-11-05T06-53 UTC
Feature Folder: docs/features/active/2026-11-04-devcontainer-current-baseline-1082
Base Branch: main
Head Branch: bug/devcontainer-current-baseline-1082 @71350a287101906f3f1aeef7dba4cf039aeba07b
Work Mode: full-bug
Audit Type: initial acceptance review
Template: MCP feature-audit-template copied before completion.

## Scope and Baseline

Complete main-vs-feature audit: 285 paths, including earlier unmerged commits7dc01121c/76ca88ecb. Explicit authorized base main; merge-base df65c30ccc98f89f9808e84ca393c8d75c805641, timestamp2026-11-04T15:28:37-05:00. Canonical PR context summary/appendix agree on the reviewed head and generation timestamp2026-11-05 06:48:10 UTC. Subsequent context refreshes at unchanged head do not invalidate this source-bound review.

Deterministic feature selection follows material spec/issue changes and suffix1082. issue.md says Work Mode: full-bug, therefore only spec.md is authoritative. Original plan.2026-11-04T21-35.md, research, canonical evidence and raw retained reports were inspected. All78 changed non-feature files are byte-equal to the final tested snapshot. Reviewer changed only review/evidence artifacts.

Coverage passes for every changed source language: Python96.7123% lines/93.6561% branches, PowerShell93.7821% lines, Bash95.1829% production/89.0860% raw. Full main-base changed runtime lines are Bash122/123 and PS3/3; the prior executor115/115 is its preimplementation-snapshot comparison. Only missing-lock skip-message output is uncovered, with thresholds still satisfied.

## Acceptance Criteria Inventory

### Source files used

- spec.md, authoritative full-bug source, 12 checkbox criteria.
- issue.md supplies mode/scope; its other checklist material is not an additional acceptance source.
- user-story.md is not required for full-bug.

### Extracted acceptance criteria

- [x] AC1: Both configurations run the shared post-create command against their actual workspace; local Docker exposes host uncommitted source changes immediately without a seeded Git checkout, and neither setup nor migration deletes host source/data or the former workspace volume.
- [x] AC2: Local `.venv` and all three `node_modules` paths use independent Linux dependency volumes with `volume-nocopy`; fresh and interrupted initialization plus repeated setup succeed without deleting mount roots or changing host dependency contents.
- [x] AC3: Both full images select the exact base image and required versions in the selected baseline table, including its Python 3.13.18 runtime and Git minimum, and preserve the repository's additional tools; no unavailable artifact is replaced silently.
- [x] AC4: Automatic verification checks every selected runtime, CLI and PowerShell module, required supporting tools, operating system/configuration and Linux virtual environment; missing, unreadable, failed or unsupported probes produce a nonzero exit and prevent the setup completion banner.
- [x] AC5: PoshQC installation/import boundaries, settings, CI and asserting tests support Pester 6.2.0, use supported coverage output and assertion APIs, and pass the applicable real test and coverage runs without weakening test selection, failure propagation, coverage population or thresholds.
- [x] AC6: Git commands in the local container trust only the intended workspace path and avoid the host file-monitor delay; the container-specific handling leaves host repository configuration unchanged.
- [x] AC7: Codex, Claude Code and claude-swap entrypoints are available to the container user at their selected versions; required state directories have that user's ownership, pinned CLI update handling is configured, and the image contains no user credential material or destructive state initialization.
- [x] AC8: Both complete devcontainer configurations build with their required features, finish post-create, and pass version/module verification; repeated setup succeeds, with the actual commands and results recorded as feature evidence.
- [x] AC9: Relevant host manifest/bootstrap and development CI contracts match the selected baseline, retain minimum-aware host handling for newer compliant installations, and preserve Python compatibility jobs and published consumer engine ranges.
- [x] AC10: Regression, contract and applicable format/lint/type/test loops pass for changed behavior, with numeric baseline/final coverage evidence where required and no regression in changed-code coverage or report compatibility.
- [x] AC11: Active container guides, relevant repository documentation, and all six execution-environment source/bundle mirrors describe the implemented baseline, workspace/dependency storage and recovery behavior consistently; mirror/contract validation passes.
- [ ] AC12: Every GitHub check on the final pull-request head passes or is skipped according to repository rules, and CI-dependent acceptance evidence records that exact head.

## Acceptance Criteria Evaluation

Evidence paths below are relative to this feature; qa-gates and regression-testing refer to canonical evidence subfolders. Policy audit supplies complete command references, source mapping and numeric denominators.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | AC1 | PASS | local config live bind; shared post-create; preservation/repeat evidence04-05 | Dev Containers CLI up local; repeat post-create; preservation hashes | No seeding or source/data cleanup remains. |
| 2 | AC2 | PASS | four volume-nocopy dependency mounts; workspace helper tests; fresh/interrupted/reused evidence | Independent shfmt/ShellCheck/syntax/Bats workspace suite; retained full lifecycle | Only dependency mount-root ownership changes; mounted .venv root retained. |
| 3 | AC3 | PASS | equal Dockerfiles; exact baseline arguments; retained full image/runtime outputs | Complete config builds; independent bash .devcontainer/verify-container.sh | amd64 runtime; no extra architecture claim. |
| 4 | AC4 | PASS | source-safe verifier/version predicate; 38 independent Bats cases and all-tool runtime | Independent Bash loop and complete local verifier | Failed/missing/stale/unreadable probes prevent completion. |
| 5 | AC5 | PASS | actual native Pester6.2 cohort/JUnit/JaCoCo; identical bundle/settings; consumer suites | Retained Invoke-PoshQCParallelTest complete cohort; fresh serial; three shuffled seeds | MCP cached-provider Pester5 invocation receipt is distinct from native6 proof. |
| 6 | AC6 | PASS | exact trust helper; GIT_CONFIG_* override; host core.fsmonitor preserved | Git trust unit cases; retained host-configuration/preservation comparison | No host .git/config change. |
| 7 | AC7 | PASS | CLI install/native optional package/system config; state directory runtime ownership | Retained local/Codespaces final-interactive-verification06-23; current native version probes | No credentials included; empty state initialization only. |
| 8 | AC8 | PASS | complete local and Codespaces config lifecycle/repeat evidence | Dev Containers CLI up; post-create; actual runtime verification | Codespaces config exercised locally with CODESPACES=true; no hosted provision claim. |
| 9 | AC9 | PASS | manifest minima; unchanged HostBootstrap behavior; preserved engines/compatibility matrices | Native host consumer tests; 36 host-environment contracts; current Python focused loop | Host newer compliant installations retained by existing tested minimum-aware logic. |
| 10 | AC10 | PASS | full Python/Bash/Pester loops; actual coverage reports; independent full-main mapping | Independent Python55/Bats38; retained full suite/cohort/serial/seed gates | Bash122/123 vs executor preimplementation115/115; PS3/3. Thresholds pass; log-only miss disclosed. |
| 11 | AC11 | PASS | root/container/PoshQC docs; six mirrors and runtime/settings parity | 109 retained contract cases; SHA256 parity; byte binding of78 non-feature files | Execution-environment edits explicitly authorized; no review policy mutation. |
| 12 | AC12 | UNVERIFIED | AC12 unchecked; no branch workflow runs; fresh context CI unavailable | gh run list --branch bug/devcontainer-current-baseline-1082 --limit15 returned [] | CI-1; Remediability: awaiting_ci; final exact-head S9 still required. |

## Summary

Overall Feature Readiness: BLOCKED — AWAITING_CI. Eleven local criteria pass; AC12 remains UNVERIFIED and classified awaiting_ci. No autonomous blocking implementation finding was identified.

Criteria summary: PASS11, PARTIAL0, FAIL0, UNVERIFIED1.

CI-1 also independently follows modified-workflow-needs-green-run for the four changed workflows. Actionlint/local success cannot establish runner success. Proceed through normal ready-for-review PR CI; record affected workflow URLs/head/conclusion. The orchestrator CI Green Gate S9 remains responsible for ci_gate.conclusion == success with ci_gate.head_sha equal to the final PR head before DONE. AC12 must be checked off by this item's orchestrator after its exact-head gate, committed/pushed and reverified.

A wait-only remediation-inputs artifact is required. No autonomous finding exists, so no remediation plan target is created and atomic-planner is not delegated.

## Acceptance Criteria Check-off

No source checkbox changed during this review. AC1–AC11 were already checked and independently evaluated PASS. AC12 remains unchecked; no CI success is implied.

### Acceptance Criteria Status

- Source: docs/features/active/2026-11-04-devcontainer-current-baseline-1082/spec.md
- Total AC items: 12
- Checked off (delivered): 11
- Remaining (unchecked): 1
- Items remaining: - [ ] AC12: Every GitHub check on the final pull-request head passes or is skipped according to repository rules, and CI-dependent acceptance evidence records that exact head.

### AC Status Summary

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---|---|---|---|
| spec.md | 12 | 11 | 1 | Checkbox-backed; AC12 pending final-head CI |

Final review status: AWAITING_CI; remediation plan NONE.

# Current CI Coordination Update

The orchestrator reports workflow_dispatch run 41984047891 in progress at the exact reviewed head 71350a287101906f3f1aeef7dba4cf039aeba07b: https://github.com/drmoisan/drm-copilot/actions/runs/41984047891. The earlier empty-run search is retained as historical evidence. This pending run is not a green result; CI-1 and AC12 remain awaiting_ci.
