# Task Check — [P0-T2] Light Remediation Cycle 1 (Finding R2 and same-class sweep)

Timestamp: 2026-11-16T06-00
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-inputs.2026-11-16T05-19.md (`## Light Fix Tasks`)
Issue: 1025

## Changed Files

Each contract below is changed in `.agents/skills/<name>/references/standard.md` and copied byte for byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`.

Finding R2: the first sentence of `## Objective` is replaced with the batch-record `Objective (draft)` text; the second sentence is unchanged.

| Contract | Batch record | Tool-neutral adjustment |
|---|---|---|
| csharp-change-budget-router | `survey/batch-d-language-routing-and-gates.md` | "the VS Code extension command surface" replaced with "the repository automation tools" |
| execute-hard-lock | `survey/batch-e-orchestration.md` | none |
| feature-promotion-lifecycle | `survey/batch-c-integration.md` | none |
| make-skill-template | `survey/batch-b-foundation-and-policy.md` | "for GitHub Copilot" removed |
| powershell-change-budget-router | `survey/batch-d-language-routing-and-gates.md` | "the VS Code extension command surface" replaced with "the repository automation tools" |
| pr-base-branch-merge-base | `survey/batch-c-integration.md` | "for mcp__drm-copilot__collect_pr_context" replaced with "for PR context collection" |
| translate-copilot-to-claude | `survey/batch-f-authoring-and-review-wrappers.md` | none (the two runtimes are the skill's subject, not a mechanism) |

Same-class sweep (after the named fixes): 18 Observable Behavior items in 16 contracts, each rewritten as a complete, tool-neutral sentence drawn from the named `SKILL.md` section, with prefix, numbering and AC citations unchanged.

| Contract | Item | Defect class |
|---|---|---|
| csharp-qa-gate | OB-2 | dangling reference ("in this exact order", list not in the contract) |
| powershell-qa-gate | OB-2 | dangling reference ("in this exact order") |
| python-qa-gate | OB-2 | dangling reference ("in this exact order") |
| documentation-workflow | OB-2 | dangling reference ("in this order") |
| epic-orchestrate | OB-2 | truncation (item ended "(issue.") |
| execute-hard-lock | OB-3 | dangling reference ("any of these cases") |
| execute-hard-lock | OB-4 | dangling reference ("entry points below") |
| make-skill-template | OB-3 | placeholder ("The skill defines its ... and applies it on every run") |
| make-skill-template | OB-5 | placeholder |
| owner-directives | OB-3 | dangling reference ("this closed set") |
| policy-compliance-order | OB-2 | substitution defect (same path named twice) |
| pr-base-branch-merge-base | OB-4 | placeholder |
| review-epic | OB-3 | placeholder |
| review-feature | OB-3 | placeholder |
| review-staged | OB-3 | placeholder |
| skill-canonical-location-audit | OB-1 | substitution defect (empty path segment `skills//`) |
| translate-copilot-to-claude | OB-3 | dangling reference ("these decision rules") |
| update-status | OB-3 | placeholder |

One R1 sentence changed again during the sweep: in `feature-promotion-lifecycle` OB-2, "for these operations" became "for them", so the sweep grep for `these ` returns nothing.

## Selection

Rule: a changed Markdown path selects the contract tests that read that path, as for [P0-T1]: `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1`, the three sweep suites under `tests/scripts/claude-runtime/` (`parallel-gate-wording`, `test-cadence-wording`, `policy-toolchain-naming`), and the Python bundle contract set of plan A `## Gate Shape`. This task also requires the full parallel Pester gate, which covers every selected Pester file, so the Pester selection ran inside that gate run and not as a separate run. The gate results are recorded in `evidence/qa-gates/light-remediation-cycle-1.2026-11-16T06-00.md`.

## Commands

1. Format / lint / type check: N/A — the changed files are Markdown; no formatter, linter or type checker in the toolchain applies to them.

2. Contract lint over all 32 changed contracts (base and bundle copy)
Command: `sh SCRATCH/issue-1025-lint-contracts.sh <32 contract names>`
EXIT_CODE: 0
Output Summary: CONTRACTS_CHECKED: 32 (x2 copies); VIOLATIONS: 0

3. R2 grep
Command: `grep -l "Produce the outcome that the" .agents/skills/*/references/standard.md` (and the same over the bundle copies)
EXIT_CODE: 1 (no match) for both trees
Output Summary: empty output

4. Mirror identity
Command: `cmp -s` of each `.agents/skills/*/references/standard.md` against its bundle copy
EXIT_CODE: 0
Output Summary: no differing pair among the 65 contracts

5. Selected tests: see the gate record (Pester 27490 tests, 0 failures; Python contract set 92 passed).
