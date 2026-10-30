# `2026-10-30-docs-enforcement-and-ci` — User Story

- Issue: #1034
- Parent epic: #1019 (documentation-estate-tooling), child `docs-enforcement-and-ci` (wave 2, C3)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T23-30
- Specification: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` (contracts, decision table and finding codes are defined there)

## Story Statement

- As a consumer repository maintainer, I want a reusable docs-quality workflow that `init` writes for me and that needs only `pwsh`, so that documentation checks and `docs-complete` validation run in CI without a Python or Node.js toolchain.
- As a consumer repository maintainer, I want a `surface-delta` command that names every added or changed surface element without a matching ledger change, so that documentation drift is reported per element instead of being counted by hand.
- As an epic orchestrator, I want an opt-in merge gate that blocks the integration-to-`main` merge unless a passing `docs-complete` receipt pins the pull request head, so that an epic cannot merge with its documentation out of correspondence, while repositories that have not enabled the gate are unaffected.
- As a feature reviewer, I want a `surface-change-without-ledger-change` check in the feature-review workflow on every runtime surface, so that a branch that changes documentable surface without a ledger change is flagged during review.

## Problem / Why

The documentation-estate tooling of epic #1019 can check pages and emit a `docs-complete` receipt,
but nothing enforces either result. A destination repository can change its documentable surface
(for example add a CLI command) without changing its coverage ledger, and an epic integration branch
can merge to `main` without a passing receipt for its head revision. In one consumer repository, a
feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited, and the gap
was found by hand. The correspondence half of the epic needs a CI surface, a merge gate and a review
check that act on the tooling's results.

## Personas & Scenarios

- Persona: Consumer repository maintainer
  - Maintains a destination repository that receives the Claude push-down and has adopted a docs profile.
  - Cares about a small CI footprint: GitHub-hosted runners with PowerShell 7 and no extra language runtimes.
  - Constraint: will not accept a tool that overwrites an existing workflow without being asked.
  - Goal: detect documentation drift at pull-request time with element-level findings.
- Persona: Epic orchestrator
  - Runs `epic-orchestrate` (or merges by hand) to merge `epic/<slug>-integration` into `main`.
  - Cares that a merge is blocked only for a stated reason and that the reason says how to fix it.
  - Constraint: the existing epic merge gate already runs on the same commands; the docs gate must not replace or weaken it.
  - Goal: a merge that proceeds only with a passing receipt for the exact head revision.
- Persona: Feature reviewer
  - Runs the feature-review agent or skill with read-only tools (`Read`, `Grep`, `Glob`, `git diff`, `git log`).
  - Cares about consistent rules across the Claude, Codex, `.agents` and Copilot surfaces.
  - Constraint: cannot run `pwsh` from the review agent and cannot gain new tools.
  - Goal: a clear Blocking or Warning finding when surface changes lack ledger changes, and a clear "not applicable" when the repository has no docs profile.

- Scenario: Maintainer adds the docs workflow
  - The maintainer runs `Invoke-DocsCommand.ps1 -Command init` and sees `.github/workflows/_docs-quality.yml` listed with action `create`.
  - The maintainer runs `init -Write`; the workflow file is created. A second `init -Write` reports `DOCS_INIT_TARGET_EXISTS` and writes nothing.
  - The maintainer adds a caller job in the repository CI; on the next pull request the workflow checks out the head, runs `check`, `inventory` at the head and `validate -Mode docs-complete`, using `pwsh` only.
- Scenario: Maintainer adds a CLI command without documenting it
  - A branch adds a CLI command. The maintainer materializes the base snapshot and ledger and runs `surface-delta -Base <sha> -BaseSnapshot <path> -BaseLedger <path>`.
  - The command exits 1 with one `DOCS_SURFACE_DELTA_UNLEDGERED` finding naming the new element id.
  - The maintainer records the element in the ledger through `update-ledger`; `surface-delta` then exits 0 with no finding.
- Scenario: Orchestrator merges an integration branch with the gate enabled
  - The profile sets `completion_gates.integration_pr_gate.enabled` to `true`.
  - The orchestrator runs `gh pr merge` for the integration pull request before producing a receipt; the hook denies with `DOCS_COMPLETE_GATE_BLOCKED:` and `DOCS_COMPLETE_GATE_RECEIPT_MISSING`, naming the receipt path.
  - The orchestrator runs `inventory` and `validate -Mode docs-complete` for the head with the write-receipt switch; the receipt passes and pins the head, and the merge proceeds (the epic merge gate must also allow).
  - If a commit is pushed after the receipt was written, the next merge attempt is denied with `DOCS_COMPLETE_GATE_RECEIPT_STALE`, naming both revisions.
- Scenario: Reviewer reviews a branch in a repository with a docs profile
  - The reviewer lists changed files and the profile's source roots and ledger path.
  - A recorded `surface-delta` result lists one element; the reviewer records a Blocking finding naming it.
  - In a repository without a docs profile, the reviewer records "not applicable: no docs profile".

## Acceptance Criteria

- [ ] (Consumer maintainer) `init` without `-Write` lists `.github/workflows/_docs-quality.yml` with action `create` and writes nothing; `init -Write` with that file already present exits 1 with `DOCS_INIT_TARGET_EXISTS` and leaves it unchanged (`tests/scripts/claude-lib/docs/DocsQualityWorkflowTemplate.Tests.ps1`).
- [ ] (Consumer maintainer) The workflow template requires `pwsh` only: every `run:` step declares `shell: pwsh`, the steps invoke `Invoke-DocsCommand.ps1` with `check`, `inventory` and `validate -Mode docs-complete`, and none of `setup-python`, `setup-node`, `python`, `pip`, `poetry`, `node`, `npm` or `npx` appears (`DocsQualityWorkflowTemplate.Tests.ps1`).
- [ ] (Consumer maintainer) `surface-delta` reports an added CLI command with no ledger change (one `DOCS_SURFACE_DELTA_UNLEDGERED` naming the element id, exit 1) and reports nothing when the ledger records it (exit 0) (`tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`).
- [ ] (Consumer maintainer) `surface-delta` fails closed with `DOCS_SURFACE_DELTA_BASE_UNPINNED` for a base snapshot without a revision and with `DOCS_SURFACE_DELTA_BASE_MISMATCH` when the base snapshot revision differs from `-Base`, and its findings are in the same order for identical inputs given in seeded shuffled element order (`DocsSurfaceDelta.Tests.ps1`).
- [ ] (Epic orchestrator) With the gate disabled (the starter-profile default) or with no profile, the hook allows every call, including an integration-to-`main` merge, and performs no pull-request lookup (`tests/scripts/claude-hooks/enforce-docs-complete-gate*.Tests.ps1`).
- [ ] (Epic orchestrator) With the gate enabled, the hook denies an integration-to-`main` merge when the receipt is absent (`DOCS_COMPLETE_GATE_RECEIPT_MISSING`), failing (`DOCS_COMPLETE_GATE_RECEIPT_FAILED`) or pinned to another revision (`DOCS_COMPLETE_GATE_RECEIPT_STALE`), and each deny reason begins `DOCS_COMPLETE_GATE_BLOCKED:` and names the reason code.
- [ ] (Epic orchestrator) With the gate enabled, the hook allows the merge when a schema-valid `docs-complete` receipt for the profile repository has `validation_result` `pass` and a `revision` equal to the live head object id, and allows merges whose base is not `main` or whose head is not an `epic/<slug>-integration` branch.
- [ ] (Epic orchestrator) The hook is registered exactly once in the `"matcher": "Bash"` PreToolUse group of byte-identical `.claude/settings.json` and bundle settings files, and `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass with the new hook and its `DOCS_COMPLETE_GATE_BLOCKED:` prefix.
- [ ] (Feature reviewer) The `surface-change-without-ledger-change` check is present in `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, the `.claude`, `.agents` and `.github` `feature-review-workflow` skills and `.agents/skills/feature-review/SKILL.md`, and in the bundle copy of each, and each source is SHA-256 identical to its bundle copy.
- [ ] (Feature reviewer) Mirror parity checks pass for the edited `feature-review` surfaces (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_completion_gate_documentation_contracts.py`), and the feature-review agent `tools` list is unchanged (`test_feature_review_agent_grants_mcp_artifact_validator`).
- [ ] (Feature reviewer) The check text states "not applicable: no docs profile" for a repository without `docs/documentation-estate/docs-profile.json`, a Blocking finding per element of a recorded `surface-delta` result, and a non-blocking `Warning` recommending `surface-delta` when no result is recorded.
- [ ] (All personas) No Python, TypeScript or JavaScript file is added or modified, every created or edited file appears in the artifact classification table with its class, language and permitting rule, and no test creates a temporary file.
- [ ] (All personas) Pester line coverage is at least 85% for `DocsSurfaceDelta.psm1`, `DocsCompleteGate.psm1` and `enforce-docs-complete-gate.ps1`, and (CI-dependent) `poshqc / PowerShell QC` on `windows-latest` and `poshqc / PowerShell hook suites (Linux)` pass on the pull request head.

## Non-Goals

- Running `surface-delta` from the feature-review agent (it cannot run `pwsh` and gains no tool).
- Resolving symbolic refs or reading git history inside the docs lib (OQ-1 default: caller-materialized base artifacts).
- A Codex hook twin or Codex gating (OQ-3 default).
- Changing this repository's own `.github/workflows/` files or `ci.yml`.
- Persisting receipts (1023), defining the receipt schema (1020) or documenting the consumer caller job (900010).
- Requiring a Markdown or other linter (D4).
- Cryptographic enforcement of the receipt; the gate is a policy-level control.
