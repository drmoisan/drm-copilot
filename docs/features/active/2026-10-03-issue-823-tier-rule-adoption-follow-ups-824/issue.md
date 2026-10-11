# Potential: follow-ups surfaced by issue #823

- Date captured: 2026-10-03
- Author: atomic-executor (issue #823, `pushed-tier-rule-not-gated-on-adoption`)
- Source: the "Rollout & Follow-up" section of `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` (items F1-F4), plus one item observed during planning (FU-823-5).
- Status: Draft. Not promoted. Each entry below can be promoted on its own.

---

- Work Mode: full-bug

## FU-823-1: Feature-review coverage hook ignores consumer thresholds (spec F1)

Status: Resolved by #824.

`.claude/hooks/validate-feature-review-coverage.ps1` hard-codes 85.0 line and 75.0 branch floors (approximately lines 313-327), and its docstring (line 29) states 80. Issue #823 defined threshold precedence in the pushed rule text: a consuming repository's root `CLAUDE.md` thresholds govern when present. The hook does not apply that precedence, so a consumer whose root `CLAUDE.md` sets lower thresholds still receives a FAIL verdict demanded by the hook. The hook should read the governing thresholds under the same precedence, and the docstring should be corrected.

## FU-823-2: Remaining TaskMaster and No-COM mentions in pushed files (spec F2)

Status: Resolved by #824.

`.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, and `.claude/skills/quota-throttling/SKILL.md` (line 9), together with their bundled copies, name a consuming product. Issue #823 removed those names from the tier rule only. The architecture-boundaries rule is specific to one consumer architecture and needs a product decision before it is generalized or withdrawn from the push-down.

## FU-823-3: TaskMaster.sln C# toolchain commands in pushed files (spec F3)

Status: Resolved by #824.

`.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, the `.agents-variants/csharp-legacy/**` bundle variants, and `.codex/codex-web-setup.sh` run `msbuild TaskMaster.sln`. A consuming repository with a different solution name receives commands that cannot run. The `.github/instructions/` files are canonical policy and need an explicit decision before any edit.

## FU-823-4: Extension republish to deliver the gated rule text (spec F4)

Status: Open (out of scope for #824; no release automation is run).

Consuming repositories receive the issue #823 wording only after the extension is rebuilt, published, and reinstalled, because the push-down serves the installed extension payload. After the release, confirm on the next consumer push-down that `.claude/rules/quality-tiers.md` carries the adoption gate.

## FU-823-5: Feature-review workflow remediation trigger still states 80/90 thresholds

Status: Resolved by #824.

`.claude/skills/feature-review-workflow/SKILL.md` step 8 (approximately line 149 after issue #823) lists "coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)" as a remediation trigger. Issue #823 aligned the step 5 coverage bullet with the governing thresholds and left this trigger, which is outside the #823 acceptance criteria. Align it with the governing thresholds in the repository copy and its bundled mirror.
