# Reduced-Audit Handoff (P2-T13, Issue 887)

Timestamp: 2026-10-12T15-19
Work Mode: minor-audit
AC source: docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/issue.md, section `## Acceptance Criteria`
Mapping source: plan.2026-10-11T08-29.md, section `## AC Traceability` (Evidence column)
Evidence root: docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/evidence/

| AC | Evidence tasks | Evidence artifact paths (relative to evidence root) |
|---|---|---|
| AC-1 | P1-T34, P1-T54, P2-T3 | regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-2 | P1-T34, P1-T54, P2-T3 | regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-3 | P1-T34, P1-T54, P2-T3 | regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-4 | P1-T34, P1-T54, P2-T3 | regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-5 | P1-T33, P1-T54, P2-T7 | regression-testing/expect-fail.HostTooling.2026-10-12T14-52.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/manifest-path.2026-10-12T14-50.md |
| AC-6 | P1-T34, P1-T54, P2-T3 | regression-testing/expect-fail.host-tools-manifest.2026-10-12T14-53.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-7 | P1-T35, P1-T54, P2-T3 | regression-testing/expect-fail.HostBootstrap-Invoke.2026-10-12T14-55.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-8 | P1-T35, P1-T36, P1-T54 | regression-testing/expect-fail.HostBootstrap-Invoke.2026-10-12T14-55.md; regression-testing/expect-fail.HostBootstrapWorkspace.2026-10-12T14-56.md; regression-testing/pass-after-fix.2026-10-12T15-08.md |
| AC-9 | P1-T35, P1-T54, P2-T5 | regression-testing/expect-fail.HostBootstrap-Invoke.2026-10-12T14-55.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/bootstrap-sh-search.2026-10-12T14-50.md |
| AC-10 | P1-T33, P1-T54, P2-T3 | regression-testing/expect-fail.HostTooling.2026-10-12T14-52.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-11 | P1-T36, P1-T37, P1-T54 | regression-testing/expect-fail.HostBootstrapWorkspace.2026-10-12T14-56.md; regression-testing/expect-fail.HostBootstrap.2026-10-12T14-57.md; regression-testing/pass-after-fix.2026-10-12T15-08.md |
| AC-12 | P2-T6 | qa-gates/capture-sites.2026-10-12T14-50.md |
| AC-13 | P1-T38, P1-T54, P2-T3 | regression-testing/expect-fail.publish-sideloaded-extension.2026-10-12T14-58.md; regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-14 | P1-T54, P2-T3 | regression-testing/pass-after-fix.2026-10-12T15-08.md; qa-gates/poshqc-test.2026-10-12T14-48.md |
| AC-15 | P1-T38, P1-T54 | regression-testing/expect-fail.publish-sideloaded-extension.2026-10-12T14-58.md; regression-testing/pass-after-fix.2026-10-12T15-08.md |
| AC-16 | P2-T10 | qa-gates/ci-poshqc-job.2026-10-12T15-17.md |
| AC-17 | P0-T13, P2-T8, P2-T11, P2-T12 | baseline/ci-coverage-main.2026-10-12T14-33.md; qa-gates/coverage-exclusion-check.2026-10-12T14-51.md; qa-gates/ci-coverage-perfile.2026-10-12T15-18.md; qa-gates/coverage-delta.2026-10-12T15-19.md |
| AC-18 | P0-T14, P2-T4 | baseline/line-counts.2026-10-12T14-33.md; qa-gates/line-counts.2026-10-12T14-49.md |

## Supporting QC artifacts (Phase 2 loop, MCP leg of the CI-gate criterion)

- qa-gates/poshqc-format.2026-10-12T15-14.md (P2-T1)
- qa-gates/poshqc-analyze.2026-10-12T15-14.md (P2-T2)
- qa-gates/poshqc-test.2026-10-12T14-48.md (P2-T3)

## Status

- CI: PR #919 run 38294481892, headSha 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8, `poshqc / PowerShell QC` success.
- Coverage verdict (P2-T12): PASS. Post-change pct: HostTooling.psm1 95.24, HostBootstrapWorkspace.psm1 100.00, HostBootstrap.psm1 100.00, publish-sideloaded-extension.ps1 100.00; changed-line pct 100.00 for all four.
- AC check-off state in issue.md at handoff: all eighteen criteria checked.
