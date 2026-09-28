# Consolidated Fail-Before Summary — Phase 1 ([P1-T5])

Timestamp: 2026-08-25T09-33

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`

Phase 1 authored regression tests only. No file under `extensions/drm-copilot/src/` was created or
modified, which is why every run below failed.

## The Four Fail-Before Artifacts

| # | Artifact filename | Task | EXIT_CODE | ExpectedExitCode | Failure level |
|---|---|---|---|---|---|
| 1 | `p1-t1-repo-slug.2026-08-23T23-23.md` | [P1-T1] | 1 | 1 | existence-level |
| 2 | `p1-t2-gh-client.2026-08-23T23-23.md` | [P1-T2] | 1 | 1 | value-level |
| 3 | `p1-t3-service-call-differing-root.2026-08-23T23-23.md` | [P1-T3] | 1 | 1 | value-level |
| 4 | `p1-t4-service-call-matching-root.2026-08-23T23-23.md` | [P1-T4] | 1 | 1 | value-level |

All four artifacts live in this directory,
`docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/`.

## Which Required Case Each Artifact Covers

The spec requires two cases to be demonstrable: a **differing workspace root** (the defect case) and
a **matching workspace root** (requirement R3, the case that works today and must stay unchanged).

1. **`p1-t1-repo-slug.2026-08-23T23-23.md` — EXIT_CODE 1 — covers neither case directly; it is the
   precondition for both.** It pins the resolution mechanism itself: the slug resolver must run the
   repository-view operation with its working directory set to the supplied workspace root. Both
   cases depend on that resolver existing, and it does not, so the suite failed to run with
   `Cannot find module '../../../src/lib/potential-to-issue/repo-slug'` and `Tests: 0 total`.

2. **`p1-t2-gh-client.2026-08-23T23-23.md` — EXIT_CODE 1 — covers the differing workspace root at the
   argument boundary.** Three exact-vector assertions failed because the recorded vectors for issue
   creation, label creation, and issue view carry no `--repo` selector. Without a selector the target
   repository is chosen by the process working directory, which is exactly the differing-root defect.
   `Tests: 3 failed, 12 passed, 15 total`.

3. **`p1-t3-service-call-differing-root.2026-08-23T23-23.md` — EXIT_CODE 1 — covers the differing
   workspace root at the service call.** The workspace root `/other-checkout` is not the process
   working directory. The injected resolver seam recorded `Array []` instead of that root, proving
   the workspace value is never handed to any repository-resolution step, and the echoed
   `targetRepository` field does not exist on the result. `Tests: 1 failed, 8 skipped, 9 total`.

4. **`p1-t4-service-call-matching-root.2026-08-23T23-23.md` — EXIT_CODE 1 — covers the matching
   workspace root.** The workspace root is `process.cwd()` with separators normalized. The resolver
   again recorded `Array []`, so even the same-repository case performs no explicit resolution today.
   The test additionally re-asserts the pre-existing `summary`, `destinationPath`, and `artifacts`
   values so requirement R3 is pinned once the fix lands. `Tests: 1 failed, 9 skipped, 10 total`.

## Failure-Level Note

[P1-T1] is deliberately weaker than the other three. A module that does not yet exist cannot produce
a value comparison, because none of its code runs; `Tests: 0 total` is the proof that no assertion
was evaluated. [P1-T2], [P1-T3], and [P1-T4] all executed their tests to completion and failed on a
comparison between two values.

Per Settled Design Decision 6, no fail-before in this phase is a compile diagnostic:
`extensions/drm-copilot/tsconfig.jest.json` sets `"isolatedModules": true`, so ts-jest transpiles
each test module without type checking. References to the not-yet-existing `repo` constructor option,
`repoSlugResolver` input property, and `targetRepository` result property therefore produce no
compile error and fail at runtime instead.

## Exit-Code Capture Method

For each of the four runs, stdout and stderr were redirected to a file and the exit code was echoed
in the same shell invocation immediately afterwards. No command was piped into another process, so
each recorded status is the status of the test command itself and not of a downstream process.
