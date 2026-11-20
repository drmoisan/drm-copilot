# Feature Audit: Devcontainer current baseline (#1082)

Audit Date: 2026-11-05T07-24 UTC
Feature Folder: docs/features/active/2026-11-04-devcontainer-current-baseline-1082
Base Branch: main
Head Branch: bug/devcontainer-current-baseline-1082 @184098c31a93bcac6e4473674e55e9713b57d734
Work Mode: full-bug
Audit Type: complete acceptance re-review after CI closure
Template: MCP feature-audit-template copied before completion.

## Scope and Baseline

Complete main-vs-feature audit: 292 paths, including earlier unmerged commits7dc01121c/76ca88ecb. Explicit authorized base main; merge-base df65c30ccc98f89f9808e84ca393c8d75c805641, timestamp2026-11-04T15:28:37-05:00. Canonical PR context summary/appendix agree on the reviewed head and generation timestamp2026-11-05 07:23:16 UTC. Subsequent context refreshes at unchanged head do not invalidate this source-bound review.

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
- [x] AC12: Every GitHub check on the final pull-request head passes or is skipped according to repository rules, and CI-dependent acceptance evidence records that exact head.

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
| 12 | AC12 | PASS | ci-green-before-checkoff.2026-11-05T07-22.md;26 unfiltered checks pass; both workflows success at 184098c31a93bcac6e4473674e55e9713b57d734 | Independent gh pr checks1083 and gh run view41984585912/41984585939; canonical parser evidence | Checked by item's orchestrator after exact-head green gate; future metadata head requires S9 revalidation |

## Summary

Overall Feature Readiness: PASS at the reviewed head. All 12 criteria pass; CI-1 is closed. No blocking implementation or acceptance finding remains.

Criteria summary: PASS12, PARTIAL0, FAIL0, UNVERIFIED0.

CI closure verified against 184098c31a93bcac6e4473674e55e9713b57d734: all 26 unfiltered PR checks pass (zero skipped, failed or pending). CI run41984585912 and extension run41984585939 are completed/success at that exact head, independently confirmed with gh run view. The CI run includes successful changed build, quality, security and PoshQC jobs. Evidence: evidence/qa-gates/ci-green-before-checkoff.2026-11-05T07-22.md. CI-1 is CLOSED. The prior 06-53 AWAITING_CI artifacts remain immutable history; manual run41984047891 at the earlier head was cancelled and is excluded.

The item's orchestrator checked AC12 after observing this green gate. This review is PASS at the reviewed head and metadata working state. The ensuing review/AC metadata commit must be pushed and receive complete renewed exact-head S9 verification before overall DONE. If only active-feature metadata changes after a qualifying green run, the modified-workflow predecessor-head allowance applies; the policy audit explicitly leaves ci_gate.conclusion == "success" and ci_gate.head_sha == final PR head as S9 obligations. This is not an assertion about CI on an unseen future commit.

No remediation is required for this re-review: REMEDIATION_INPUTS: NONE; REMEDIATION_PLAN: NONE. Historical wait-only inputs remain with the 06-53 review. No atomic-planner delegation applies.

## Acceptance Criteria Check-off

Reviewer changed no source checkbox. AC1–AC11 were already checked and independently PASS. The item's orchestrator checked AC12 after the exact-head green result; this review independently verified that result and leaves the authorized checkoff intact.

### Acceptance Criteria Status

- Source: docs/features/active/2026-11-04-devcontainer-current-baseline-1082/spec.md
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: None.

### AC Status Summary

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---|---|---|---|
| spec.md | 12 | 12 | 0 | Checkbox-backed; AC12 verified at reviewed head; repeat S9 after metadata commit |

Final review status: PASS at the reviewed head; remediation inputs/plan NONE. Final metadata-head CI must still be revalidated before overall completion.
