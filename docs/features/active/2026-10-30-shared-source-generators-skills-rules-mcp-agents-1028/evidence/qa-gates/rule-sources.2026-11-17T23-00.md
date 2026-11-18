# Rule sources ([P4-T2])

Timestamp: 2026-11-17T23-00
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-rulesrc.ps1 -Write (builds each source pair from the current targets and renders it through `Get-HarnessRuleFileMap`); sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-rulerows.ps1 (the tables below); sh SCRATCH/issue-1028-gen.sh rules check
EXIT_CODE: 0
Output Summary: There are 20 source pairs under `scripts/harness-generation/sources/rules/`, one per current Claude rule (OQ-3), and together they produce all 38 selected `path-scoped-rule` targets: 20 Claude rules and 18 Copilot instruction files. They also produce 16 Codex rule-skills (OQ-2), and each of the 54 targets has a bundle copy, so 108 files are rendered. No selected target lacks a source (0 `NO-SOURCE` findings), and no Copilot instruction file is left unmapped. 50 of the 54 targets render byte-equal to the committed file. The other four are Copilot normalizations that [P4-T3] writes:
- `general-unit-test.instructions.md` gains the opening `---` its frontmatter lacks;
- `typescript-unit-test.instructions.md` loses the blank line before its opening `---`;
- `tonality.instructions.md` and `self-explanatory-code-commenting.instructions.md` gain a final line feed.

The five members of `DELIBERATE_UNCONDITIONAL_RULES` (`bash-command-shape`, `general-code-change`, `general-unit-test`, `quality-tiers` and `tonality`) declare `claudeUnconditional: true`. Every other Claude target carries a `paths` key without a `**` glob.

Method:
- **Source per Claude rule.** Each source is named for a Claude rule stem. It lists, in order, the Claude rule, then the Copilot files of that stem (`<stem>`, `<stem>-code-change` and `<stem>-unit-test`, with `github-actions` and `github-actions-ci-cd-best-practices` under `ci-workflows`), then the Codex rule-skill `.agents/skills/<stem>/SKILL.md` when one exists and `.claude/skills/<stem>/` does not. No instruction file is renamed or deleted (PQ-1).
- **Sections.** Each target body is split at H2 headings outside fenced blocks, and the text before the first H2 becomes a `head` section. The Claude rule's sections come first in the body (OQ-3). A section whose text is byte-identical in two targets is stored once and listed for both. A section a Copilot or Codex target carries that the Claude rule lacks, or carries in different wording, is stored once and listed for that target only (D-4).
- **Frontmatter.** Each target's frontmatter is stored as ordered keys with raw value text. That keeps the Claude `paths` lists, the Copilot `applyTo` strings and the Codex `name` and `description` exactly as they are today.
- **Precedence wording.** The pinned `CLAUDE_PRECEDENCE_FRAGMENTS` and `CODEX_PRECEDENCE_FRAGMENTS` wording stays in the Claude and Codex sections, which keep their current text. The sections that carry it differ between targets, so each target lists its own section and no substitution is needed. `test_push_down_tier_rule_adoption_gate.py` verifies this in [P4-T3].
- **Ledger regions.** Each target keeps its current text verbatim, so every recorded region in `.claude/rules/*.md`, `.github/instructions/*.instructions.md` and the Codex rule-skills stays present and contiguous. No source uses a substitution, so no `find` can overlap a region. `ProcessReductionChain.Ledger.Tests.ps1` verifies this in [P4-T3].

Positive review and decision. Child 1's approval artifact (`survey/difference-approval.md` of #1025) holds no Diff ID for a rule or instruction file: its 297 rows are all skills. Its Codex rule-skill rows record `native` with parity tracked through the rule entries. So every Copilot-only or Codex-only section was reviewed as a candidate positive and given the disposition `retained-target-only`: it stays in its own target, listed for that target only, and is not ported into the Claude rule. The reasons:
- with no approved Diff ID, a port would change policy text that no approval covers;
- the Claude rules are launch-loaded summaries, and adding full Copilot sections would grow every session's context;
- keeping each section in its own target loses no guidance.

Under the autonomous-mode owner rule this is the recommended option, and it is recorded here. No section was dispositioned `ported`, and none needed `deferred-ledger-region`, because no section text was changed. The OQ-2 example difference, the `## Toolchain` coverage threshold in `.agents/skills/python/SKILL.md`, stays as its own Codex-only section. Reconciling it is a policy edit outside this item.

## Sources, targets and section lists

| Source | claudeUnconditional | Target | Frontmatter keys | Sections (in order) |
| --- | --- | --- | --- | --- |
| architecture-boundaries |  | `.claude/rules/architecture-boundaries.md` | paths, description | head, enforcement-tools, host-neutral-architecture-rules-enforceable-assert, layer-boundary-assertions-typescript, layer-boundary-assertions-net-applies-once-the-bac, enforcement-outcome |
| architecture-boundaries |  | `.agents/skills/architecture-boundaries/SKILL.md` | name, description | head-2, enforcement-tools, host-neutral-architecture-rules-enforceable-assert, layer-boundary-assertions-typescript, layer-boundary-assertions-net-applies-once-the-bac, enforcement-outcome |
| bash-command-shape | true | `.claude/rules/bash-command-shape.md` | description | head, forms-by-context, agent-isolated-worktree, sibling-worktree |
| bash-command-shape | true | `.github/instructions/bash-command-shape.instructions.md` | applyTo, name, description | head, forms-by-context, agent-isolated-worktree, sibling-worktree |
| bash-command-shape | true | `.agents/skills/bash-command-shape/SKILL.md` | name, description | head-2, forms-by-context, agent-isolated-worktree, sibling-worktree-2, literal-paths |
| benchmark-baselines |  | `.claude/rules/benchmark-baselines.md` | paths, description | head, runner-environment-parity-required, prohibited-unknown-processor, required-sibling-provenance-file, enforcement, scope |
| benchmark-baselines |  | `.agents/skills/benchmark-baselines/SKILL.md` | name, description | head-2, runner-environment-parity-required, prohibited-unknown-processor, required-sibling-provenance-file, enforcement-2, scope |
| ci-workflows |  | `.claude/rules/ci-workflows.md` | paths, description | head, deliberately-failing-nested-command-pattern-requir, epic-integration-branch-trigger-required-when-epic, rationale, enforcement, scope |
| ci-workflows |  | `.github/instructions/github-actions.instructions.md` | applyTo | head-2 |
| ci-workflows |  | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | applyTo, description | head-3, your-mission, core-concepts-and-structure, security-best-practices-in-github-actions, optimization-and-performance, comprehensive-testing-in-ci-cd-expanded, advanced-deployment-strategies-expanded, github-actions-workflow-review-checklist-comprehen, troubleshooting-common-github-actions-issues-deep, conclusion |
| ci-workflows |  | `.agents/skills/ci-workflows/SKILL.md` | name, description | head-4, deliberately-failing-nested-command-pattern-requir, epic-integration-branch-trigger-required-when-epic-2, rationale, enforcement-2, scope |
| csharp |  | `.claude/rules/csharp.md` | paths, description | head, toolchain, coding-standards, testing-standards, analyzer-stack, banned-apis, deterministic-test-rules, di-seams, prohibited-behaviors |
| csharp |  | `.github/instructions/csharp-code-change.instructions.md` | applyTo, name, description | head-2, 1-tooling-baseline-for-c, 2-c-design-type-safety-principles, 3-classes-methods-and-apis-c-specific-guidance, 4-error-handling-logging-and-contracts-c, 5-module-file-structure-c, 6-naming-docs-and-comments-c, 7-dependencies-and-analyzer-configuration-c |
| csharp |  | `.github/instructions/csharp-unit-test.instructions.md` | applyTo, name, description | head-3, 1-framework-selection, 2-c-specific-libraries-and-conventions, 3-c-toolchain-command-selection |
| csharp |  | `.agents/skills/csharp/SKILL.md` | name, description | head-4, toolchain-2, coding-standards-2, testing-standards-2, deterministic-test-rules, di-seams-2, prohibited-behaviors |
| general-code-change | true | `.claude/rules/general-code-change.md` | paths, description | head, design-principles, classes-functions-and-apis, module-rigor-tiers, mandatory-toolchain-loop, file-size-limit, error-handling-and-logging, naming, public-apis-and-compatibility, dependencies, i-o-boundaries |
| general-code-change | true | `.github/instructions/general-code-change.instructions.md` | applyTo, name, description | head-2, before-making-changes, bugfix-workflow-all-languages-defects-only, 1-design-principles, 2-classes-functions-and-apis, 3-error-handling-logging-and-contracts, 4-module-file-structure, 5-naming-docs-and-comments, 6-performance-i-o-and-dependencies, 7-how-to-interact-with-existing-code, 8-after-making-changes |
| general-code-change | true | `.agents/skills/general-code-change/SKILL.md` | name, description | head-3, design-principles, classes-functions-and-apis, module-rigor-tiers-2, mandatory-toolchain-loop, file-size-limit, error-handling-and-logging, naming, public-apis-and-compatibility, dependencies, i-o-boundaries |
| general-unit-test | true | `.claude/rules/general-unit-test.md` | paths, description | head, core-principles, coverage-requirements, coverage-exclusion-policy, scenario-completeness, test-structure-arrange-act-assert, external-dependencies, test-file-location, documentation, test-categories, determinism-infrastructure |
| general-unit-test | true | `.github/instructions/general-unit-test.instructions.md` | applyTo, name, description | head-2, 1-core-principles, 2-coverage-and-scenarios, 3-test-structure-and-diagnostics, 4-external-dependencies-and-environment, 5-policy-audit |
| general-unit-test | true | `.agents/skills/general-unit-test/SKILL.md` | name, description | head-3, core-principles, coverage-requirements-2, coverage-exclusion-policy, scenario-completeness, test-structure-arrange-act-assert, external-dependencies, test-file-location, documentation, test-categories-2, determinism-infrastructure |
| mermaid |  | `.claude/rules/mermaid.md` | paths, description | head, diagram-file-conventions, validation-mandate, managed-diagrams-do-not-hand-edit, opt-out-marker-for-deliberate-counter-examples, out-of-scope-the-non-portable-extension-mechanisms, example |
| mermaid |  | `.github/instructions/mermaid.instructions.md` | applyTo | head-2, workflow, lm-tools-call-these-for-every-diagram-interaction, vs-code-commands, mermaid-chart-slash-commands, rules, docs |
| orchestrator-state |  | `.claude/rules/orchestrator-state.md` | paths, description | head, foreign-schema-warning-do-not-copy-verbatim, required-top-level-keys, scope-and-backward-compatibility, invariants-per-remediation-cycle, invariants-remediation-loop-review-outcomes, human-interaction-scope-and-backward-compatibility, invariants-human-interaction-block, blocked-reason-vocabulary, complexity-assessment-scope-and-backward-compatibi, invariants-complexity-assessments-array, model-routing-receipt-scope-and-backward-compatibi, invariants-model-routing-receipts-array, model-budget-contract, require-model-routing-mode-scope-and-backward-comp, bare-module-cli-contract, invariants-require-model-routing-mode, epic-launch-binding-activation-scope, standalone-merge-authorization-scope-and-backward, invariants-standalone-merge-authorizations-array, green-ci-standalone-merge-issue-997, epic-child-ci-verification-issue-1130, issue-adoption-scope-and-backward-compatibility, invariants-issue-adoption-object, concurrent-review-scope-and-backward-compatibility, owner-directive-scope-and-backward-compatibility, regeneration-path-scope-and-backward-compatibility, enforcement |
| orchestrator-state |  | `.agents/skills/orchestrator-state/SKILL.md` | name, description | head-2, foreign-schema-warning-do-not-copy-verbatim, portable-handoff-projection-invariants, scope-and-backward-compatibility, invariants-per-remediation-cycle, invariants-remediation-loop-review-outcomes, concurrent-review-key-review-mode, human-interaction-scope-and-backward-compatibility-2, invariants-human-interaction-block, enforcement-2 |
| parallel-orchestration |  | `.claude/rules/parallel-orchestration.md` | paths, description | head, foreign-schema-warning-do-not-copy-verbatim, scope-and-backward-compatibility, invariants-parallel-orchestrator-checkpoint, invariants-parallel-planner-checkpoint, invariants-parallel-run-manifest, cache-doctrine-the-checkpoint-is-not-the-source-of, omitted-epic-schema-fields-s8, concurrency-bound-a7, drift-event-recording-rule-a8, enum-ownership-f6-f7-f8-consume-never-extend, mutation-rejection-signal-issue-1012, f7-seam, f3-scope-boundary-kickoff-contract-deferred-to-f4, prepared-item-admission-issue-1047, blast-radius-contention-doctrine-issue-489, enforcement |
| plan-acceptance-gates |  | `.claude/rules/plan-acceptance-gates.md` | paths, description | head, scope-of-invocation-no-exemption-marker, rule-table, severity-decisions, the-write-mode-register, deliberately-uncovered-sub-classes, checkable-literal-definition-and-the-placeholder-g, message-formatting-no-repr-no-r-no-pythonrepr, authoring-guidance-for-plan-authors, enforcement |
| powershell |  | `.claude/rules/powershell.md` | paths, description | head, toolchain, compatibility, coding-standards, change-budget, design-seams-minimal-di, testing-standards, prohibited-behaviors |
| powershell |  | `.github/instructions/powershell-code-change.instructions.md` | applyTo, name, description | head-2, 1-tooling-baseline-for-powershell, 2-powershell-design-safety, 3-structure-naming-and-comments, 4-running-the-toolchain-powershell |
| powershell |  | `.github/instructions/powershell-unit-test.instructions.md` | applyTo, name, description | head-3, 1-framework-and-scope, 2-test-style-and-structure-powershell, 3-naming-and-readability-python, 4-running-the-toolchain-powershell-tests |
| powershell |  | `.agents/skills/powershell/SKILL.md` | name, description | head, toolchain, compatibility, coding-standards-2, change-budget-2, design-seams-minimal-di, testing-standards-2, prohibited-behaviors |
| python-suppressions |  | `.claude/rules/python-suppressions.md` | paths, description | head, authorization-requirement, pre-authorized-noqa-patterns, pre-authorized-type-ignore-patterns, explicitly-not-authorized-with-required-workaround, policy-enforcement-checklist |
| python-suppressions |  | `.github/instructions/python-suppressions.instructions.md` | applyTo, name, description | head-2, ruff-suppressions, pyright-suppressions, non-authorized-patterns-explicitly-prohibited-with, policy-enforcement, non-authorized-patterns-explicitly-prohibited |
| python-suppressions |  | `.agents/skills/python-suppressions/SKILL.md` | name, description | head, authorization-requirement, pre-authorized-noqa-patterns, pre-authorized-type-ignore-patterns, explicitly-not-authorized-with-required-workaround, policy-enforcement-checklist |
| python |  | `.claude/rules/python.md` | paths, description | head, toolchain, coding-standards, python-design-rules, pytest-rules, prohibited-behaviors |
| python |  | `.github/instructions/python-code-change.instructions.md` | applyTo, name, description | head-2, 1-tooling-baseline-for-python, 2-python-design-typing-principles, 3-classes-functions-and-apis-python-specific-guida, 4-error-handling-logging-and-contracts-python, 5-module-file-structure-python, 6-naming-docs-and-comments-python, 7-dependencies-and-third-party-libraries-python |
| python |  | `.github/instructions/python-unit-test.instructions.md` | applyTo, name, description | head-3, 1-framework-and-scope, 2-test-style-and-structure-python, 3-naming-and-readability-python, 4-respecting-the-toolchain-loop |
| python |  | `.agents/skills/python/SKILL.md` | name, description | head, toolchain-2, coding-standards, python-design-rules, pytest-rules-2, prohibited-behaviors |
| quality-tiers | true | `.claude/rules/quality-tiers.md` | paths, description | head, tiers, source-of-truth, uniform-vs-tier-dependent-gate-matrix, rationale-uniform-coverage-thresholds |
| quality-tiers | true | `.agents/skills/quality-tiers/SKILL.md` | name, description | head-2, tiers, source-of-truth, uniform-vs-tier-dependent-gate-matrix-2, rationale-uniform-coverage-thresholds-2 |
| self-explanatory-code-commenting |  | `.claude/rules/self-explanatory-code-commenting.md` | paths, description | head, core-principle, mandatory-class-docstrings, mandatory-function-and-method-docstrings, loops-and-comprehensions-intent-comments-required, branching-decision-logic-comments-required, multi-step-blocks-meta-what-comments, 6-do-not-number-notes, meta-what-vs-narration, quality-checklist |
| self-explanatory-code-commenting |  | `.github/instructions/self-explanatory-code-commenting.instructions.md` | description, applyTo | head-2, core-principle-2, 1-mandatory-class-docstrings-robust, 2-mandatory-function-method-docstrings-robust-c-li, 3-loops-and-list-comprehensions-must-be-explained, 4-branching-must-explain-decision-logic-if-elif-el, 5-forest-through-the-trees-comment-multi-step-bloc, 6-do-not-number-notes-2, 7-what-vs-why-allow-meta-what-when-it-explains-int, anti-patterns-still-avoid, quality-checklist-2 |
| self-explanatory-code-commenting |  | `.agents/skills/self-explanatory-code-commenting/SKILL.md` | name, description | head, core-principle, mandatory-class-docstrings, mandatory-function-and-method-docstrings, loops-and-comprehensions-intent-comments-required, branching-decision-logic-comments-required, multi-step-blocks-meta-what-comments, 6-do-not-number-notes, meta-what-vs-narration, quality-checklist |
| shell |  | `.claude/rules/shell.md` | paths, description | head, toolchain, native-invocation-and-environment, discovery-contract, coverage-expectations, ci-vs-local-version-drift, coding-standards |
| tonality | true | `.claude/rules/tonality.md` | paths, description | head, required-professional-tone, humor-and-joking-prohibited, hyperbole-prohibited, metaphors-tightly-restricted, evidence-first-wording, difficult-messages, final-rule |
| tonality | true | `.github/instructions/tonality.instructions.md` | applyTo, name, description | head-2, 1-required-default-tone, 2-humor-and-joking-are-prohibited, 3-hyperbole-is-prohibited, 4-metaphors-are-tightly-restricted, 5-evidence-first-wording, 6-style-guidance-for-difficult-messages, 7-examples, 8-final-rule |
| tonality | true | `.agents/skills/tonality/SKILL.md` | name, description | head-3, required-professional-tone, humor-and-joking-prohibited, hyperbole-prohibited, metaphors-tightly-restricted, evidence-first-wording, difficult-messages, final-rule |
| typescript-suppressions |  | `.claude/rules/typescript-suppressions.md` | paths, description | head, authorization-requirement, pre-authorized-patterns, explicitly-prohibited-patterns, policy-enforcement-checklist |
| typescript-suppressions |  | `.github/instructions/typescript-suppressions.instructions.md` | description, applyTo, name | head-2, eslint-suppressions, typescript-suppressions, non-authorized-patterns-explicitly-prohibited-with, policy-enforcement |
| typescript-suppressions |  | `.agents/skills/typescript-suppressions/SKILL.md` | name, description | head, authorization-requirement, pre-authorized-patterns, explicitly-prohibited-patterns, policy-enforcement-checklist |
| typescript |  | `.claude/rules/typescript.md` | paths, description | head, toolchain, coding-standards, eslint-stack, testing-standards, architecture-boundaries, property-based-and-mutation-testing, golden-tests, runtime-determinism |
| typescript |  | `.github/instructions/typescript-code-change.instructions.md` | description, applyTo, name | head-2, 1-tooling-baseline-for-typescript, 2-typescript-design-typing-principles, 3-imports-modules-and-dependencies, 4-error-handling-and-logging, 5-suppressions-and-escape-hatches, 6-public-apis-and-compatibility, 7-project-organization-naming-and-documentation, 8-security-configuration-and-external-integrations, 9-ui-ux-and-lifecycle-hygiene-vs-code-extension-co, 10-performance-and-reliability |
| typescript |  | `.github/instructions/typescript-unit-test.instructions.md` | description, applyTo, name | head-3, 1-framework-and-scope, 2-test-layout-and-naming, 3-test-style-and-structure-typescript, 4-mocking-and-isolation, 5-assertions-and-diagnostics, 6-required-commands |
| typescript |  | `.agents/skills/typescript/SKILL.md` | name, description | head, toolchain, coding-standards-2, testing-standards-2 |

## Sections listed for one non-Claude target only (reviewed positives)

| Source | Section | Listed only for | Disposition |
| --- | --- | --- | --- |
| bash-command-shape | sibling-worktree-2 | `.agents/skills/bash-command-shape/SKILL.md` | retained-target-only |
| bash-command-shape | literal-paths | `.agents/skills/bash-command-shape/SKILL.md` | retained-target-only |
| benchmark-baselines | enforcement-2 | `.agents/skills/benchmark-baselines/SKILL.md` | retained-target-only |
| ci-workflows | your-mission | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | core-concepts-and-structure | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | security-best-practices-in-github-actions | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | optimization-and-performance | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | comprehensive-testing-in-ci-cd-expanded | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | advanced-deployment-strategies-expanded | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | github-actions-workflow-review-checklist-comprehen | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | troubleshooting-common-github-actions-issues-deep | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | conclusion | `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | retained-target-only |
| ci-workflows | epic-integration-branch-trigger-required-when-epic-2 | `.agents/skills/ci-workflows/SKILL.md` | retained-target-only |
| ci-workflows | enforcement-2 | `.agents/skills/ci-workflows/SKILL.md` | retained-target-only |
| csharp | 1-tooling-baseline-for-c | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 2-c-design-type-safety-principles | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 3-classes-methods-and-apis-c-specific-guidance | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 4-error-handling-logging-and-contracts-c | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 5-module-file-structure-c | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 6-naming-docs-and-comments-c | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 7-dependencies-and-analyzer-configuration-c | `.github/instructions/csharp-code-change.instructions.md` | retained-target-only |
| csharp | 1-framework-selection | `.github/instructions/csharp-unit-test.instructions.md` | retained-target-only |
| csharp | 2-c-specific-libraries-and-conventions | `.github/instructions/csharp-unit-test.instructions.md` | retained-target-only |
| csharp | 3-c-toolchain-command-selection | `.github/instructions/csharp-unit-test.instructions.md` | retained-target-only |
| csharp | toolchain-2 | `.agents/skills/csharp/SKILL.md` | retained-target-only |
| csharp | coding-standards-2 | `.agents/skills/csharp/SKILL.md` | retained-target-only |
| csharp | testing-standards-2 | `.agents/skills/csharp/SKILL.md` | retained-target-only |
| csharp | di-seams-2 | `.agents/skills/csharp/SKILL.md` | retained-target-only |
| general-code-change | before-making-changes | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | bugfix-workflow-all-languages-defects-only | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 1-design-principles | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 2-classes-functions-and-apis | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 3-error-handling-logging-and-contracts | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 4-module-file-structure | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 5-naming-docs-and-comments | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 6-performance-i-o-and-dependencies | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 7-how-to-interact-with-existing-code | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | 8-after-making-changes | `.github/instructions/general-code-change.instructions.md` | retained-target-only |
| general-code-change | module-rigor-tiers-2 | `.agents/skills/general-code-change/SKILL.md` | retained-target-only |
| general-unit-test | 1-core-principles | `.github/instructions/general-unit-test.instructions.md` | retained-target-only |
| general-unit-test | 2-coverage-and-scenarios | `.github/instructions/general-unit-test.instructions.md` | retained-target-only |
| general-unit-test | 3-test-structure-and-diagnostics | `.github/instructions/general-unit-test.instructions.md` | retained-target-only |
| general-unit-test | 4-external-dependencies-and-environment | `.github/instructions/general-unit-test.instructions.md` | retained-target-only |
| general-unit-test | 5-policy-audit | `.github/instructions/general-unit-test.instructions.md` | retained-target-only |
| general-unit-test | coverage-requirements-2 | `.agents/skills/general-unit-test/SKILL.md` | retained-target-only |
| general-unit-test | test-categories-2 | `.agents/skills/general-unit-test/SKILL.md` | retained-target-only |
| mermaid | workflow | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| mermaid | lm-tools-call-these-for-every-diagram-interaction | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| mermaid | vs-code-commands | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| mermaid | mermaid-chart-slash-commands | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| mermaid | rules | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| mermaid | docs | `.github/instructions/mermaid.instructions.md` | retained-target-only |
| orchestrator-state | portable-handoff-projection-invariants | `.agents/skills/orchestrator-state/SKILL.md` | retained-target-only |
| orchestrator-state | concurrent-review-key-review-mode | `.agents/skills/orchestrator-state/SKILL.md` | retained-target-only |
| orchestrator-state | human-interaction-scope-and-backward-compatibility-2 | `.agents/skills/orchestrator-state/SKILL.md` | retained-target-only |
| orchestrator-state | enforcement-2 | `.agents/skills/orchestrator-state/SKILL.md` | retained-target-only |
| powershell | 1-tooling-baseline-for-powershell | `.github/instructions/powershell-code-change.instructions.md` | retained-target-only |
| powershell | 2-powershell-design-safety | `.github/instructions/powershell-code-change.instructions.md` | retained-target-only |
| powershell | 3-structure-naming-and-comments | `.github/instructions/powershell-code-change.instructions.md` | retained-target-only |
| powershell | 4-running-the-toolchain-powershell | `.github/instructions/powershell-code-change.instructions.md` | retained-target-only |
| powershell | 1-framework-and-scope | `.github/instructions/powershell-unit-test.instructions.md` | retained-target-only |
| powershell | 2-test-style-and-structure-powershell | `.github/instructions/powershell-unit-test.instructions.md` | retained-target-only |
| powershell | 3-naming-and-readability-python | `.github/instructions/powershell-unit-test.instructions.md` | retained-target-only |
| powershell | 4-running-the-toolchain-powershell-tests | `.github/instructions/powershell-unit-test.instructions.md` | retained-target-only |
| powershell | coding-standards-2 | `.agents/skills/powershell/SKILL.md` | retained-target-only |
| powershell | change-budget-2 | `.agents/skills/powershell/SKILL.md` | retained-target-only |
| powershell | testing-standards-2 | `.agents/skills/powershell/SKILL.md` | retained-target-only |
| python-suppressions | ruff-suppressions | `.github/instructions/python-suppressions.instructions.md` | retained-target-only |
| python-suppressions | pyright-suppressions | `.github/instructions/python-suppressions.instructions.md` | retained-target-only |
| python-suppressions | non-authorized-patterns-explicitly-prohibited-with | `.github/instructions/python-suppressions.instructions.md` | retained-target-only |
| python-suppressions | policy-enforcement | `.github/instructions/python-suppressions.instructions.md` | retained-target-only |
| python-suppressions | non-authorized-patterns-explicitly-prohibited | `.github/instructions/python-suppressions.instructions.md` | retained-target-only |
| python | 1-tooling-baseline-for-python | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 2-python-design-typing-principles | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 3-classes-functions-and-apis-python-specific-guida | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 4-error-handling-logging-and-contracts-python | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 5-module-file-structure-python | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 6-naming-docs-and-comments-python | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 7-dependencies-and-third-party-libraries-python | `.github/instructions/python-code-change.instructions.md` | retained-target-only |
| python | 1-framework-and-scope | `.github/instructions/python-unit-test.instructions.md` | retained-target-only |
| python | 2-test-style-and-structure-python | `.github/instructions/python-unit-test.instructions.md` | retained-target-only |
| python | 3-naming-and-readability-python | `.github/instructions/python-unit-test.instructions.md` | retained-target-only |
| python | 4-respecting-the-toolchain-loop | `.github/instructions/python-unit-test.instructions.md` | retained-target-only |
| python | toolchain-2 | `.agents/skills/python/SKILL.md` | retained-target-only |
| python | pytest-rules-2 | `.agents/skills/python/SKILL.md` | retained-target-only |
| quality-tiers | uniform-vs-tier-dependent-gate-matrix-2 | `.agents/skills/quality-tiers/SKILL.md` | retained-target-only |
| quality-tiers | rationale-uniform-coverage-thresholds-2 | `.agents/skills/quality-tiers/SKILL.md` | retained-target-only |
| self-explanatory-code-commenting | core-principle-2 | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 1-mandatory-class-docstrings-robust | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 2-mandatory-function-method-docstrings-robust-c-li | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 3-loops-and-list-comprehensions-must-be-explained | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 4-branching-must-explain-decision-logic-if-elif-el | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 5-forest-through-the-trees-comment-multi-step-bloc | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 6-do-not-number-notes-2 | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | 7-what-vs-why-allow-meta-what-when-it-explains-int | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | anti-patterns-still-avoid | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| self-explanatory-code-commenting | quality-checklist-2 | `.github/instructions/self-explanatory-code-commenting.instructions.md` | retained-target-only |
| tonality | 1-required-default-tone | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 2-humor-and-joking-are-prohibited | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 3-hyperbole-is-prohibited | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 4-metaphors-are-tightly-restricted | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 5-evidence-first-wording | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 6-style-guidance-for-difficult-messages | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 7-examples | `.github/instructions/tonality.instructions.md` | retained-target-only |
| tonality | 8-final-rule | `.github/instructions/tonality.instructions.md` | retained-target-only |
| typescript-suppressions | eslint-suppressions | `.github/instructions/typescript-suppressions.instructions.md` | retained-target-only |
| typescript-suppressions | typescript-suppressions | `.github/instructions/typescript-suppressions.instructions.md` | retained-target-only |
| typescript-suppressions | non-authorized-patterns-explicitly-prohibited-with | `.github/instructions/typescript-suppressions.instructions.md` | retained-target-only |
| typescript-suppressions | policy-enforcement | `.github/instructions/typescript-suppressions.instructions.md` | retained-target-only |
| typescript | 1-tooling-baseline-for-typescript | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 2-typescript-design-typing-principles | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 3-imports-modules-and-dependencies | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 4-error-handling-and-logging | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 5-suppressions-and-escape-hatches | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 6-public-apis-and-compatibility | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 7-project-organization-naming-and-documentation | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 8-security-configuration-and-external-integrations | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 9-ui-ux-and-lifecycle-hygiene-vs-code-extension-co | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 10-performance-and-reliability | `.github/instructions/typescript-code-change.instructions.md` | retained-target-only |
| typescript | 1-framework-and-scope | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | 2-test-layout-and-naming | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | 3-test-style-and-structure-typescript | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | 4-mocking-and-isolation | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | 5-assertions-and-diagnostics | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | 6-required-commands | `.github/instructions/typescript-unit-test.instructions.md` | retained-target-only |
| typescript | coding-standards-2 | `.agents/skills/typescript/SKILL.md` | retained-target-only |
| typescript | testing-standards-2 | `.agents/skills/typescript/SKILL.md` | retained-target-only |
