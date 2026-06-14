# claude-memory-scope-and-hardening - User Story

- **Issue:** #181
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/181
- **Owner:** drmoisan
- **Last Updated:** 2026-06-13
- **Status:** Draft
- **Work Mode:** full-feature

## Primary User Story

As a maintainer of the drm-copilot extension, I want the push-down mechanism to distribute
only general-scoped agent memories to consumer repositories, so that repository-specific
memories about the drm-copilot internals do not leak into consumer workspaces where they are
irrelevant or misleading.

## Supporting User Stories

- As a maintainer, I want a deterministic, fail-safe rule for which memories are distributed,
  so that a memory is shared only when explicitly marked `scope: general` and nothing leaks by
  accident.
- As a maintainer, I want the extension template to copy from the bundled customizations
  directory rather than from the destination workspace, so that push-down actually distributes
  the bundled `.claude` content instead of copying a destination's existing `.claude` back to
  itself.
- As an orchestrator agent, I want the orchestrator-state validator to reject malformed
  remediation cycles (empty `plan_path`, execution started without a cleared preflight, exit
  marked met while blocking findings remain), so that invalid checkpoint state is caught before
  resume or review workflows depend on it.
- As an engineer, I want a documented coverage exemption for type-only / interface-only modules,
  so that modules with no executable behavior do not depress coverage figures or trigger
  false coverage findings.
- As an orchestrator agent in any repository, I want six domain-neutral orchestration memories
  available, so that established lifecycle, file-size, branching, and promotion practices are
  applied consistently.

## Personas

- **Extension maintainer (drm-copilot):** authors and bundles agent memories, owns the
  push-down contract and the resource-parity tests.
- **Consumer-repository user:** receives the bundled `.claude` payload via push-down and should
  see only memories that apply to any repository.
- **Orchestrator agent:** reads and writes the orchestrator-state checkpoint and relies on the
  validator to reject malformed remediation cycles.

## Scenarios (Given / When / Then)

### Scenario 1 — General memory is distributed

- Given a bundled memory under `.claude/agent-memory/` with `metadata.scope: general`,
- When push-down runs against a destination workspace,
- Then the memory file is copied into the destination's `.claude/agent-memory/`.

### Scenario 2 — Repo-specific memory is withheld

- Given a memory under `.claude/agent-memory/` with `metadata.scope: repo`,
- When push-down runs,
- Then the memory file is excluded from the destination. Per Option B, repo-specific memories
  are physically removed from the bundled copy and relocated to the root `.claude/agent-memory`
  folder (gitignored / local-only), so they are not present in the bundle to begin with; the
  scope filter remains the fail-safe second line of defense.

### Scenario 3 — Unmarked memory fails safe

- Given a memory under `.claude/agent-memory/` with no `scope` field, no frontmatter, or a
  malformed or unrecognized `scope` value,
- When push-down runs,
- Then the memory is treated as `repo` and excluded from the destination.

### Scenario 4 — Non-memory files unaffected

- Given a file outside `.claude/agent-memory/` (for example a rule or skill file),
- When push-down runs,
- Then the file is copied verbatim, unaffected by the scope filter, and remains byte-identical
  between root and bundle.

### Scenario 5 — Template source-root is the bundled directory

- Given the extension template is invoked from a destination workspace,
- When push-down runs,
- Then the source root is the bundled `claude-customizations/` directory (aligned with the
  codex template), not the destination workspace.

### Scenario 6 — Validator rejects a malformed remediation cycle

- Given an orchestrator-state checkpoint containing a `remediation_loop` whose cycle has an
  empty `plan_path`, an `execution_status` of `in_progress` while `preflight.final_status` is
  not `clear`, or `exit_condition_met == true` while `blocking_count` is non-zero,
- When the validator runs,
- Then it returns an explicit error for each violated invariant.

### Scenario 7 — Validator backward compatibility

- Given an orchestrator-state checkpoint with no `remediation_loop`,
- When the validator runs,
- Then validation behaves exactly as before, producing no new invariant errors.

### Scenario 8 — Type-only module coverage exemption is documented

- Given an engineer reviewing coverage policy,
- When they read the general unit-test rule and the Python, TypeScript, and C# rules,
- Then each documents that type-only / interface-only modules with no executable behavior may
  be excluded from coverage measurement, without lowering any coverage threshold.

## Acceptance Criteria

- [x] A bundled memory marked `scope: general` is distributed to the destination by push-down.
- [x] A bundled memory marked `scope: repo` is not distributed to the destination.
- [x] An unmarked, missing-frontmatter, malformed, or unrecognized-scope memory is treated as `repo` and not distributed (fail-safe default).
- [x] Files outside `.claude/agent-memory/` are copied verbatim and are unaffected by the scope filter.
- [x] The extension template resolves its source root to the bundled `claude-customizations/` directory, aligned with the codex template, and carries the scope filter.
- [x] The bundled `.claude/agent-memory` copy contains only `scope: general` memories plus the orchestrator `MEMORY.md` index (which remains `scope: repo` and is never pushed); `orchestrator/feedback_policy_compliance_not_optional.md` is retained as `scope: general`.
- [x] Repo-specific memories are physically removed from the bundle and relocated to the root `.claude/agent-memory` folder (gitignored / local-only); the `prd-feature/` and `task-researcher/` agent-memory subdirectories are removed from the bundle entirely.
- [x] The resource-contract parity test requires every NON-index bundled agent-memory file to carry `scope: general` and every `MEMORY.md` index to carry `scope: repo`.
- [x] Six domain-neutral orchestration memories are present in the bundle as `scope: general` with repository-neutral wording, referenced by the bundled orchestrator `MEMORY.md`.
- [x] The orchestrator-state validator rejects a cycle with an empty `plan_path`, an execution status started without a cleared preflight, or an exit marked met while blocking findings remain; a checkpoint with no `remediation_loop` validates unchanged.
- [x] The orchestrator-state invariants are documented as a prose rule mirrored byte-identically into root and bundle.
- [x] The type-only / interface-only coverage exemption is documented in the general unit-test rule and the Python, TypeScript, and C# rules, mirrored byte-identically into root and bundle.
- [x] Root coverage policy is unchanged (85% line / 75% branch, tier system retained); no rejected snapshot artifact is introduced.
- [x] Three follow-up GitHub issues are opened for the cross-language items in Decision L. (#182 new-code delta coverage gate; #183 test-purity hooks TS/C#; #184 batch-budget hooks TS/C#.)

## Out of Scope

- New-code delta coverage gate for TypeScript, C#, and PowerShell (follow-up issue).
- Test-purity hooks for TypeScript and C# (follow-up issue).
- Batch-budget hooks for TypeScript and C# (follow-up issue).
- Import of domain-specific memories from `artifacts/.claude/agent-memory/` beyond the six
  generalized memories.
- Any change to root coverage thresholds, the tier system, the toolchain stage count, or the
  property-test obligation.
