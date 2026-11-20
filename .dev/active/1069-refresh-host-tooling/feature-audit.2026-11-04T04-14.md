# Feature Audit: Host tooling alignment (#1069)

**Audit Date:** 2026-11-04
**Feature Folder:** docs/features/active/2026-11-03-refresh-host-tooling-1069
**Base Branch:** main
**Head Branch:** feature/refresh-host-tooling-1069 at 4998aae13a522bfda43ea68084bad09289fe0197
**Work Mode:** full-feature, from issue.md metadata
**Audit Type:** Initial acceptance review, MCP feature-audit template populated.

## Scope and Baseline

Merge base01706c697f3ad4a53b4a771d99d851afc7417ea9; primary artifacts/pr_context.summary.txt and secondary artifacts/pr_context.appendix.txt share generated timestamp2026-11-04 04:11:39 UTC and reviewed HEAD. Acceptance sources are spec.md and user-story.md. Entire branch diff reviewed, including both platform configs, workflows, tests, guides and operational brief mirrors. IMAGE, COVER, HANDOFF and ISO evidence are under this feature's canonical evidence directories.

## Acceptance Criteria Inventory

### From user-story.md (exact checkbox wording)
- [x] AC1: `scripts/host-tools.manifest.json` declares Python 3.13.17, Node.js 26.13.0, PowerShell 7.6.9, and Poetry 2.3.2 minima; existing package IDs and command classifications remain valid.
- [x] AC2: Bootstrap installs missing managed tools and upgrades below-minimum managed tools only with `-Apply`; dry run performs no installation, and equal or newer versions are preserved without downgrades.
- [x] AC3: Bootstrap reports unreadable installed versions and native installation failures explicitly, propagates failure, and never reports an unverified managed tool as compliant; deterministic tests cover these errors and minimum-version boundaries.
- [x] AC4: Both local and Codespaces images build and provide Python 3.13.17 or newer within 3.13, Node.js 26.13.0/npm 11.20.0, PowerShell 7.6.9, Poetry 2.3.2, shfmt 3.14.1, ShellCheck 0.11.0, and actionlint 1.7.12; their shared verifier accepts that baseline and rejects stale required versions.
- [x] AC5: Local mounts and Docker features, Codespaces resource settings, Python 3.11/3.12 compatibility testing, and consumer package engine requirements are preserved.
- [x] AC6: Development CI pins, the shared container scripts, README development guidance, current devcontainer guides, and any affected execution-environment mirrors consistently describe the selected baseline and intentional compatibility differences.
- [x] AC7: Changed behavior and configuration contracts pass the applicable ordered toolchains, coverage and isolation checks; actual build and runtime-verification results for both containers are recorded in canonical feature evidence.

### From spec.md (exact checkbox wording)
- [x] Acceptance criteria documented and mapped to tests or demos: AC1–AC7 in `issue.md` and `user-story.md`, with manifest/bootstrap tests, configuration checks, and actual image verification.
- [x] Behavior matches acceptance criteria in all documented environments: Windows bootstrap and both local/Codespaces image builds meet AC1–AC5.
- [x] Tests updated/added (unit/integration as applicable): manifest/version-selection and existing bootstrap assertions plus relevant workflow/container contracts cover AC1–AC6.
- [x] Edge cases and error handling covered by tests: missing, below, equal, newer, unreadable, dry-run, and failed-install scenarios prove AC2–AC3.
- [x] Docs updated (README, docs/features/active/... links): current development guidance and affected mirrors satisfy AC6 while describing intentional compatibility differences.
- [x] Telemetry/logging added or updated (if applicable): existing bootstrap output identifies compliance, planned work, and errors for AC2–AC3; no new telemetry is needed.
- [x] Toolchain pass completed (format → lint → type-check → test): applicable coverage/isolation checks and both actual image build/runtime results satisfy AC7 with canonical evidence.
- [x] Unit coverage areas: managed-tool and Poetry minimum boundaries, unreadable output, native failure propagation, dry-run side effects, and unchanged unmanaged-command behavior.
- [x] Integration scenarios: both actual Docker builds and shared runtime verification; development workflow and mirrored-document contracts.
- [x] CLI/API examples: existing bootstrap dry run and `-Apply` retain their flags and report the selected manifest requirements.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC1 | Host manifest minima/IDs/classifications | PASS | Manifest diff; host manifest and consumer suites | PoshQC host/manifest test inventory | Python 3.13.17/Node26.13/PowerShell7.6.9/Poetry2.3.2 |
| AC2 | Missing/stale/equal/newer/Apply controls | PASS | HostBootstrap.Versions/Invoke tests; changed lines100% | PoshQC host scoped and full serial/concurrent runs | Legacy/no-minimum callers preserved |
| AC3 | Explicit unreadable/native failure paths | PASS | Version, pip and wrapper tests;100% new methods | PoshQC boundary tests | Structured native seams, no host upgrade performed |
| AC4 | Both built images and selected native tooling | PASS | Both configuration-build/native/instrumented artifacts | Installed devcontainerCLI build; Docker verifier as vscode from/tmp | Actual Python 3.13.17, Node26.13/npm11.20, PowerShell7.6.9, Poetry2.3.2, shell pins |
| AC5 | Platform/consumer/Python compatibility retained | PASS | Both JSON configs unchanged; contract tests; engine/matrix diff |80 focused contracts; source diff | No published engine or release workflow change |
| AC6 | Development CI/docs/brief agreement | PASS | Config contracts/actionlint and six identical operational briefs | generator/resource contracts; actionlint; file comparison | Current-head green workflow verified; final PR-head gate remains S9 |
| AC7 | Changed behavior QA/coverage/isolation/build evidence | PASS | COVER/HANDOFF/ISO/IMAGE, raw Pester counters | Recorded final ordered commands and instrumented image scenarios | Full CI96.67036% line and>=75% branch gate passed; final PR-head checks remain S9 |
| Spec DoD1-7 and seeded conditions1-3 | Requirements, environments, tests, edges, docs, diagnostics, local QA | PASS | Same traced evidence above;17 checked source items | Source checkbox inspection and evidence review | No phantom or reworded criterion; no new checkoffs required |

## Summary

Delivered feature criteria:7 unique PASS,0 partial,0 unverified,0 fail. Specification checklist10/10 and story7/7 agree with inspected local evidence and current-head CI. Overall review readiness:PASS. CI 41769663345 completed successfully at 4998aae13; global Python line coverage96.67036% and the>=75% branch gate passed. No finding remains.

## Acceptance Criteria Check-off

### AC Status Summary

- Source: spec.md and user-story.md
- Total checkbox items:17 (seven unique behavior ACs plus ten spec DoD/seeded conditions)
- Checked off:17
- Remaining:0
- Reviewer source edits: none; already checked items are supported by local delivered-behavior evidence.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| user-story.md |7|7|0|Authoritative full-feature behavior criteria |
| spec.md |10|10|0|Authoritative DoD and seeded conditions |

Next lifecycle verification: S9 must observe every check on the final actual PR head. The current review head already has a complete successful22-job workflow and passing Python coverage gate.
## CI wait resolution

The previous awaiting_ci finding is resolved. Independent gh run view 41769663345 verifies status completed/conclusion success at reviewed head 4998aae13a522bfda43ea68084bad09289fe0197, with all 22 jobs successful. Python job 126376256895 log independently verifies16,083 passed,6 skipped in784.33s, TOTAL33,367 statements and1,111 misses. Executable line coverage is32,256/33,367=96.67036%. The explicit --min-line 85 --min-branch 75 gate passed; global branch coverage is verified >=75%, with no exact percentage invented.

Evidence: evidence/qa-gates/branch-ci.2026-11-04T04-11.md; https://github.com/drmoisan/drm-copilot/actions/runs/41769663345 . Commands: gh run view 41769663345 --json headSha,status,conclusion,jobs,url; gh run view 41769663345 --job 126376256895 --log. This green head includes the latest outside-feature change. If later commits contain only active-feature artifacts, the documented predecessor-head conditions apply; S9 still verifies every check at the final actual PR head before completion.
