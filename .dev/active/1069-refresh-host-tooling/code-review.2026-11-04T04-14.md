# Code Review: Host tooling alignment (#1069)

**Review Date:** 2026-11-04
**Reviewer:** feature-reviewer-c3
**Feature Folder:** docs/features/active/2026-11-03-refresh-host-tooling-1069
**Feature Folder Selection Rule:** Explicit folder matches branch issue suffix and primary changed requirements.
**Base Branch:** main
**Head Branch:** feature/refresh-host-tooling-1069 at 4998aae13a522bfda43ea68084bad09289fe0197
**Review Type:** Initial full feature-versus-base review, MCP code-review template populated.

## Executive Summary

The implementation synchronizes manifest minima, minimum-aware bootstrap, both Dockerfiles, a pure shell version predicate, shared runtime verification, development CI and current guides. Review inspected every changed runtime/config/test surface and accepted measured ordered QA/coverage/isolation/build artifacts. No autonomous correctness or maintainability blocker was identified. All22 CI jobs at the reviewed head and full Python coverage now pass; the previous wait is resolved.

**Verified scope:** Actual amd64 builds are verified; no other architecture is claimed. CI 41769663345 is complete/success, and unrelated CLI pins/package engines remain preserved.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|

No autonomous code findings. No changed covered file reaches the700-line advisory or800-line hard limit.

## Implementation Audit

### PowerShell implementation audit

Install-WithWinget and Install-PoetryWithPip add optional minima, retain missing-only behavior for legacy/unmanaged callers, preserve equal/newer versions, and fail explicitly for unreadable versions/native failures. ApplyMode remains the mutation control. Arguments pass as arrays through existing wrappers; constrained pip requirements are not shell-interpolated. Invoke-BootstrapHost handles missing minimumVersions under StrictMode and refreshes PATH before Poetry. Mock signatures and existing callers were inspected.

### Bash / container implementation audit

The pure predicate accepts Python 3.13 patch>=17 and exact other pins, rejecting malformed/unknown tools without I/O. The verifier resolves its helper/config/venv from its own repository location and aggregates explicit failures. Native outputs are consumed completely to avoid pipefail/SIGPIPE. Both Dockerfiles use a real official Python runtime stage and explicit PATH/NVM selection so older feature shims do not shadow selected tools. Actual full builds and vscode/from-/tmp native checks verify wiring and feature-provided commands.

### Python and configuration audit

The only Python addition is a typed, parameterized contract-test module. Immutable committed configuration reads are explicit; no new production Python API or runtime file exists. Tests guard host/container/CI agreement and unchanged local mounts, Codespaces resources, package engines and Python3.11/3.12 compatibility entries. Manifest IDs/shape and public bootstrap flags remain unchanged. Workflow changes pin development tools without changing jobs or publishing workflows.

## Test Quality Audit

- PowerShell raw JUnit13742 total,13732 passed,0 failures/errors,10 disclosed skips; raw line counter21284/22733=93.63%; HostBootstrap 190/190 and35new lines100%.
- Pure helper16/16; verifier96.77% and both new functions100%; setup89.92% with unchanged canonical formatter-only source. Positive/stale/missing/native-error/OS/config/venv scenarios passed in both images.
- Python80 focused contracts and reverse/concurrent runs passed; full CI16,083 passed/6 skipped,96.67036% line and>=75% branch verified by the successful explicit gate. Unchanged selected cleanup remains94.44% line/90% branch.
- Root5301 and extension5284 Node tests passed at26.13/npm11.20; coverage98.21%/93.4% and97.06%/93.67%; extension seed1069 also passed.
- Three host seeds17/1069/31415 each79pass; full serial and3shards agree. New tests use pure functions/native mocks, descriptive cases and explicit expected failures, without temporary-file fixtures.
- Full serial941.82s includes measured existing AST/import-scan costs; no speculative performance refactor was included.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets introduced | PASS | Inspected full non-feature diff and new tests/config; no credentials/env files added |
| Native arguments are structured | PASS | Existing wrapper arrays preserved; no Invoke-Expression or string-built shell installation |
| Version decisions fail closed | PASS | Null/unreadable native version and nonzero installer outcomes tested; malformed pure inputs rejected |
| Compatible behavior retained | PASS | Optional parameters/legacy fixtures, no consumer engine or public flag changes |
| Configuration paths resolve predictably | PASS | Repo-relative verifier plus actual from-/tmp full-image runs; platform JSON settings unchanged |

## Research Log

No additional external research was required for code review. Official image/package availability and actual runtime provenance are documented in the feature research and measured builds; live GitHub workflow status was independently checked.

## Verdict

PASS. No autonomous or unresolved code/policy findings remain. Current-head CI 41769663345 and Python coverage requirements passed. Normal PR flow may proceed; S9 must still verify every check at the final actual PR head.
## CI wait resolution

The previous awaiting_ci finding is resolved. Independent gh run view 41769663345 verifies status completed/conclusion success at reviewed head 4998aae13a522bfda43ea68084bad09289fe0197, with all 22 jobs successful. Python job 126376256895 log independently verifies16,083 passed,6 skipped in784.33s, TOTAL33,367 statements and1,111 misses. Executable line coverage is32,256/33,367=96.67036%. The explicit --min-line 85 --min-branch 75 gate passed; global branch coverage is verified >=75%, with no exact percentage invented.

Evidence: evidence/qa-gates/branch-ci.2026-11-04T04-11.md; https://github.com/drmoisan/drm-copilot/actions/runs/41769663345 . Commands: gh run view 41769663345 --json headSha,status,conclusion,jobs,url; gh run view 41769663345 --job 126376256895 --log. This green head includes the latest outside-feature change. If later commits contain only active-feature artifacts, the documented predecessor-head conditions apply; S9 still verifies every check at the final actual PR head before completion.
