# PR Linkage Notes for epic-orchestrator ([P7-T10])

Timestamp: 2026-10-12T04-23

## Pull request

- Base branch: `epic/subagentstop-envelope-integration`.
- Head: `bug/subagentstop-envelope-orchestrator-family-exec-903` (pushed by this plan).
- The PR body carries these two lines:

```text
Refs #903
Refs #897
```

- No closing keyword is used next to any issue number: issue 903 is delivered only in part, and issue 897 is delivered by E1, E2, and E3 together (epic Issue Closure).
- Pull-request authoring and CI monitoring are executed by `epic-orchestrator`, not by this plan's executor.

## Open follow-ups (spec Rollout & Follow-up)

- Frontmatter `SubagentStop` firing question: still unverified. Observation artifact: `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/subagentstop-firing-observation.2026-10-12T04-13.md` (FIRING_CONCLUSION: UNVERIFIED; five frontmatter-only agents: atomic-executor, epic-review, prd-feature, staged-review, status-updater; four dual-registered agents; the settings matcher `orchestrator` is a substring of `epic-orchestrator` and `parallel-orchestrator`, and whether matching is by regex, substring, or exact name is unverified).
  - Superseded: this firing conclusion is superseded by `evidence/other/subagentstop-firing-runtime-observation.2026-10-12T08-55.md`, which records that a frontmatter-only SubagentStop registration was observed to fire for atomic-executor.
- The always-true conditional in the three PreToolUse hooks (review of issue 786): out of E2 scope, open.
- The Codex `SilentlyContinue` nit in `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42` (review of issue 786): out of E2 scope, open.
- The `prd-feature.md` `user-story-path` requirement for full-feature mode: removed by Amendment A; a mode-aware replacement is a separate follow-up.

## Amendment outcomes

- Amendment A, `.claude/agents/prd-feature.md:18` registration: completed on this branch. The [P5-T9] artifact `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/prd-feature-registration.2026-10-12T04-06.md` records `AGENT_EDIT_OUTCOME: LANDED` and `LINE18_REQUIRED_ARTIFACT_COUNT: 1`; the bundled mirror is byte-identical (`evidence/qa-gates/agent-mirror-hashes.2026-10-12T04-06.md`), and registration row REG-5 passes (`evidence/regression-testing/registration-after-agent-edit.2026-10-12T04-07.md`). No operator item was needed.
- Amendment B, corpus gate results (re-run against the final decision functions at pinned `origin/main` 2ef8d361e978ca8b7733a545d76a87e8418005ce):
  - orchestrator: `evidence/qa-gates/corpus-orchestrator.2026-10-12T04-11.md` (CORPUS_TOTAL=7, FALSE_POSITIVES=0, CORPUS_VACUOUS=False)
  - executor: `evidence/qa-gates/corpus-executor.2026-10-12T04-11.md` (CORPUS_TOTAL=307, FALSE_POSITIVES=0, CORPUS_VACUOUS=False)
  - planner: `evidence/qa-gates/corpus-planner.2026-10-12T04-12.md` (CORPUS_TOTAL=307, FALSE_POSITIVES=0, CORPUS_VACUOUS=False)
  - required-artifact: `evidence/qa-gates/corpus-required-artifact.2026-10-12T04-12.md` (CORPUS_TOTAL=49, FALSE_POSITIVES=0, CORPUS_VACUOUS=False)
  - No validator reported `CORPUS_VACUOUS=True`.

## RULE-CHANGE coordinator items (record in spec.md `## Amendments`)

From `evidence/other/corpus-rule-changes.2026-10-12T01-27.md` (CORPUS_RULE_CHANGE_COUNT: 2):

- RULE-CHANGE 1: validator executor (`.claude/hooks/validate-executor-output.ps1`, `Test-IsPreflightPlan` and `Get-TouchedLanguagesFromPlan` accept empty plan lines through `[AllowEmptyString()]`); row `CORPUS-EXE-1 accepts a plan line array that contains an empty line`; `SPEC_INVARIANT_EXCEPTION: spec.md:217 (operator Amendment B)`.
- RULE-CHANGE 2: validator planner (`.claude/hooks/validate-planner-output.ps1`, `Get-PlanStructureValidationReport` accepts empty plan lines and skips non-task checkbox lines outside phase sections); row `CORPUS-PLN-1 ignores a non-task checkbox line under a level-2 heading after the final phase`; `SPEC_INVARIANT_EXCEPTION: spec.md:217 (operator Amendment B)`.
