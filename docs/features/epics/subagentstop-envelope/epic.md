---
epic: subagentstop-envelope
integration_branch: epic/subagentstop-envelope-integration
created_at: 2026-10-11T14:00
intent:
  epic_type: enabler
  business_outcome_hypothesis: Every SubagentStop completion gate reads the documented hook envelope and blocks with exit code 2, so a subagent can no longer report completion without the artifact that proves it.
  leading_indicators:
    - A recorded differential run shows what a real SubagentStop hook receives on stdin and whether CLAUDE_HOOK_INPUT is set.
    - Each of the nine validators blocks with exit 2 when the documented envelope on stdin lacks its required artifact.
    - No file under .claude/hooks reads CLAUDE_HOOK_INPUT for a SubagentStop decision or blocks with exit 1.
    - The Claude and Codex feature-review coverage hooks report the same floor for the same CLAUDE.md.
  nfrs:
    - Enforcement hooks gain no Python legs.
    - No production file exceeds the 500-line cap.
    - Line coverage >= 85% for every changed PowerShell file.
    - Bundled mirrors under extensions/drm-copilot/resources stay byte-identical to their sources.
features:
  - issue_num: 897
    feature_folder: subagentstop-envelope-core-897
    depends_on: []
  - issue_num: 903
    feature_folder: subagentstop-envelope-orchestrator-family-903
    depends_on: [subagentstop-envelope-core-897]
  - issue_num: 897
    feature_folder: subagentstop-envelope-artifact-gates-897
    depends_on: [subagentstop-envelope-core-897]
  - issue_num: 896
    feature_folder: subagentstop-envelope-feature-review-coverage-896
    depends_on: [subagentstop-envelope-core-897]
---

# Epic: SubagentStop Envelope

Epic issue: #904.

> **Manifest status.** Draft written 2026-10-11 before preparation. The `feature_folder` values are
> hints and are back-filled from each prepared child's active folder at fan-in. `depends_on` uses
> folder hints rather than issue numbers because E1 and E3 are both keyed to #897; the
> uniqueness of that key is an open decision recorded under Open Decisions.

## Goal

Make the nine SubagentStop validators under `.claude/hooks/` (`validate-*.ps1`) and the inline
SubagentStop command at `.claude/settings.json:218` read the documented SubagentStop envelope
(JSON on stdin, carrying `last_assistant_message`) and block with exit code 2, through one shared
helper. Today they read the `CLAUDE_HOOK_INPUT` environment variable, take `output` off the parsed
root, and block with exit 1. PR #881 (#786) proved that exit 1 does not block in this family.

## Scope

- One shared envelope-read and exit-2 block helper, with tests and bundled mirror.
- The inline SubagentStop command at `.claude/settings.json:218`.
- The nine validators: `validate-orchestrator-output.ps1` (with
  `validate-orchestrator-output-resolution.ps1`), `validate-executor-output.ps1`,
  `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`,
  `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`,
  `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`, and
  `validate-feature-review-coverage.ps1`.
- Same-file review notes: #903's notes for #787 (CR-1, CR-3, CR-7), the #786 double import of
  `OrchestratorState.psm1` (lines 51 and 59), and the `FailClosed.Tests.ps1` nits; #896 CR-4,
  CR-6, CR-8 and CR-9.
- The Codex half of #884: `.codex/hooks/validate-feature-review-coverage.ps1` reads the same floor
  source as the Claude hook and reaches at least 85% line coverage (from 7.30%).
- The feature-review-workflow skills, `.codex/agents/feature-review.toml`, and their mirrors.

## Non-Goals

- The bash half of #884 (`.claude/lib/bash/compute-concurrency-batches.sh`).
- #903 notes for files outside E2's validators, and the #903 evidence-timestamp defect.
- PreToolUse hooks (#501 already converted them).
- Any new validation rule beyond the transport, shape and exit-code change, except the listed
  review notes.

## Shared Design

E1 owns the contract that E2, E3 and E4 consume. The planned contract, which E1's research may
refine and must record in its spec as the authoritative version:

- Helper file: `.claude/hooks/subagentstop-envelope.ps1`, dot-sourced by each validator, with a
  bundled mirror.
- `Read-SubagentStopEnvelope`: reads the hook payload from stdin, parses it as JSON, and returns
  the parsed envelope with the assistant text taken from `last_assistant_message`. Its behavior on
  empty, absent or malformed stdin is defined by E1 from the measured evidence.
- `Exit-SubagentStopBlock -Message <text>`: writes the reason to stderr and exits with code 2.
- No reads of `CLAUDE_HOOK_INPUT` for a SubagentStop decision. Any test seam is a parameter on the
  validator's pure entry point, not an environment variable.

If E1's measured evidence shows a different transport or field, E1's spec governs and the wave-2
plans' upstream-merge check stops them until they are reconciled.

E1 also reviews the inline command's matcher, which lists fifteen agents including
`orchestrator`, `epic-orchestrator` and `epic-planner`. Once the command blocks, any of those
agents whose final message lacks `plan-path`, `research-path`, `review-artifact`, `PREFLIGHT` or
`evidence/` is refused, so E1 states which agents the pattern is correct for before enabling it.

## Decomposition

| Child | Key issue | Other issues | Wave | Band | Files |
| --- | --- | --- | --- | --- | --- |
| E1 core helper and inline command | #897 | none | 1 | C4 | new helper, `.claude/settings.json`, mirrors |
| E2 orchestrator, executor, planner, required-artifact validators | #903 | #897 | 2 | C3 | 5 hooks, tests, mirrors |
| E3 discovery, pr-author, prd-feature, task-researcher validators | #897 | none | 2 | C3 | 4 hooks, tests, mirrors |
| E4 feature-review coverage | #896 | #884 (Codex half), #897 | 2 | C3 | Claude and Codex hooks, thresholds, skills, agent TOML, mirrors |

Waves are numbered from 1 in this narrative; the manifest computation numbers them from 0
(E1 wave 0; E2, E3 and E4 wave 1).

Rationale:

- E2, E3 and E4 each consume the E1 helper, so each depends on E1 and on nothing else.
- E2, E3 and E4 edit disjoint validator files, test suites and mirrors, so they run in parallel.
  Under the operator conflict policy, overlap blocks only when both sides edit the same functions
  or rules and the cost is comparable to the time saved by running in parallel; no such overlap
  was found between the wave-2 children.
- `validate-orchestrator-output.ps1` is 466 lines and `validate-feature-review-coverage.ps1` is
  477 lines, so E2 and E4 each plan a split to stay under 500.
- `validate-discovery-artifact-gate.Tests.ps1` and `validate-pr-author-output.Tests.ps1` assert
  `$LASTEXITCODE | Should -Be 1`; E3 inverts them to exit 2, as #501 did for PreToolUse.

Complexity bands:

- E1 C4: it needs a live runtime measurement before the contract can be fixed, and it defines a
  contract consumed by every other child.
- E2 C3: cross_module_contract_change across five hooks, including the orchestrator completion
  gate, plus a file split.
- E3 C3: cross_module_contract_change across four hooks and an exit-code contract inversion in
  two suites.
- E4 C3: cross_module_contract_change across the Claude and Codex hooks, a shared floor source,
  and a coverage increase from 7.30% to at least 85%.

## Issue Closure

#897 is delivered by E1, E2 and E3 together, #903 only in part, and #884 only in its Codex half.
Child pull requests reference these issues with `Refs` and do not use a closing keyword. #896 is
fully delivered by E4. The integration-to-main pull request (epic issue #904) closes #897 and
#896 and references #903 and #884.

## Open Decisions

- E1 and E3 are both keyed to #897. The epic manifest and the planner checkpoint require a unique
  `issue_num` per child, and the decomposition directive forbids new child issues. Resolution is
  recorded here once the user decides.
