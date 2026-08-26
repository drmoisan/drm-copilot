# Phase 0 — Policy Instructions Read (P0-T1)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: the plan fixes every evidence filename suffix at `.2026-08-24T13-10.md`.
This execution ran on 2026-08-25 and substituted its own stamp `2026-08-25T23-33` in that same
position, per the plan's "Evidence filename timestamps" clause. The path prefix and base name are
unchanged. One stamp is used for every Phase 0 artifact.

Policy Order: The files below were read in the exact order the plan's P0-T1 task enumerates, which
matches the required reading order of `.claude/skills/policy-compliance-order/SKILL.md` and the
"Policy Compliance Reading Order" section of `CLAUDE.md`.

## Files Read

1. `CLAUDE.md` — repository standing instructions: tone policy, policy-compliance reading order,
   language-rule routing, four-layer runtime architecture, orchestration checkpoint path.
   Read via standing-instruction preload (auto-loaded, full text).
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles,
   module rigor tiers, the mandatory seven-stage toolchain loop, the 500-line file cap, error
   handling, naming, dependencies, I/O boundaries.
   Read via standing-instruction preload (auto-loaded, full text).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: the five core test
   properties, coverage requirements (line >= 85% all tiers; branch >= 75% except PowerShell and
   bash), the Coverage Exclusion Policy, scenario completeness, Arrange-Act-Assert, the prohibition
   on temporary files in tests, test-file location, determinism infrastructure.
   Read via standing-instruction preload (auto-loaded, full text).
4. `.claude/rules/powershell.md` — PowerShell toolchain (`mcp__drm-copilot__run_poshqc_format`,
   `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`), PowerShell 7+
   compatibility, coding standards, change budget, the wrapper-function design seam
   (`Invoke-<Tool>Exe -<Tool>Args <string[]>`), Pester testing standards, mocking rules (never mock
   `git`/`gh` directly — mock the wrapper), prohibited behaviors.
   Read explicitly with the Read tool during this task (98 lines).
5. `.claude/rules/ci-workflows.md` — the deliberately-failing nested command pattern for `pwsh`
   workflow steps: a step that intentionally invokes a failing command must reset
   `$LASTEXITCODE = 0` or terminate with an explicit `exit 0` / `exit 1`.
   Read via standing-instruction preload (auto-loaded, full text).
6. `.claude/rules/quality-tiers.md` — the T1-T4 module rigor tier system, `quality-tiers.yml` as the
   source of truth, and the uniform-versus-tier-dependent gate matrix (coverage thresholds uniform
   across tiers; Pester exempt from the branch threshold only).
   Read via standing-instruction preload (auto-loaded, full text).
7. `.claude/rules/plan-acceptance-gates.md` — acceptance-gate rules G1 through G6, the checkable-
   literal definition and placeholder guard, the dotted `--cov=` form requirement, the message-
   formatting prohibition on `repr()` / `!r` / `pythonRepr`, and the authoring guidance for plan
   acceptance conditions.
   Read via standing-instruction preload (auto-loaded, full text).
8. `.claude/rules/tonality.md` — required professional tone; prohibitions on humor, hyperbole, and
   decorative metaphor; evidence-first wording; the restrained-phrasing default.
   Read via standing-instruction preload (auto-loaded, full text).

## Count

8 of 8 policy paths enumerated above were read before any Phase 0 command was executed.

## Rules Recorded as Binding on This Execution

- `.claude/rules/powershell.md` fixes the three MCP toolchain entry points this phase invokes for
  P0-T3, P0-T4, and P0-T5, and states that VS Code task wrappers must not be substituted.
- `.claude/rules/general-unit-test.md` Coverage Exclusion Policy is why P0-T5 records per-file
  covered-line and total-line counts for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` rather than an
  overall percentage alone.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` fixes every artifact in this phase
  under `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/`.
  No `artifacts/`-rooted evidence path was written. No non-canonical evidence path was supplied to
  this executor, so `EVIDENCE_LOCATION_OVERRIDE_REJECTED` does not apply.
- The plan's hard prohibitions are binding: this phase performed no release, no publish, no tag
  creation, no tag push, no tag deletion, no `npm publish`, no `npm version`, no `npm deprecate`,
  no `npm unpublish`, and no `git push`. Only read-only registry queries and read-only `gh` queries
  were issued.
