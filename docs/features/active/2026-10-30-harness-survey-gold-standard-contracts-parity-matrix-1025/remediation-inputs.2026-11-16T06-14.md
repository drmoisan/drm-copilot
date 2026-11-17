# Remediation Inputs — Issue 1025 (re-audit after light cycle 1)

Timestamp: 2026-11-16T06-14
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Issue: 1025
Base: epic/shared-agent-harness-layer-integration
Merge-Base: bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee
Reviewed-Head: 6ad9b31f62c479a18d1b41d75dcf8db38add93b2
Source review artifacts:
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/policy-audit.2026-11-16T06-14.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/code-review.2026-11-16T06-14.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/feature-audit.2026-11-16T06-14.md`

## Disposition

Findings R1 and R2 of `remediation-inputs.2026-11-16T05-19.md` are closed in all 65 contracts and all 65 bundle copies, and the cycle 1 rewrites match their sources. Policy compliance passes; 41 of 43 acceptance criteria evaluate PASS and the other two are pending CI by design.

A source-comparison scan found three further content findings from the same contract generator, which neither the R1 grep nor the cycle 1 sweep grep could match: 29 Observable Behavior items in 20 contracts. Each finding is autonomous and contained: the fix edits only contract files already in the branch diff and their bundle mirrors, and changes no spec acceptance criterion, public interface, schema, validator contract, hook decision or production logic. The prior cycle was light, so this cycle takes the full path.

Scope boundary: the remediation covers exactly the 29 items named below. The 45 other items that the scan matched (code review CR-12) are complete behavior sentences and are accepted as written; do not edit them. Do not edit any `SKILL.md`, survey record, matrix, module or test.

## Finding R3 (code review CR-9): fragment, placeholder and dangling behavior items

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the contracts and their bundle copies are on this branch and the complete behavior is stated in the source SKILL.md section each item names, so the fix needs no external input or owner decision.
Finding-Scope: contained

- Location: `## Observable Behaviors` of `.agents/skills/<name>/references/standard.md` and its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`. 8 items in 6 files:
  - `acceptance-criteria-tracking` OB-4 (source `## AC Status Summary (Required at Completion)`)
  - `atomic-plan-contract` OB-4 (`## Short-Path Minimal Plan Contract`) and OB-5 (`## Minimal-Audit Directive Contract (Small Path)`)
  - `evidence-and-timestamp-conventions` OB-5 (`## Canonical Evidence Discovery Order`)
  - `policy-audit-template-usage` OB-2 (`## Required Steps`)
  - `review-epic` OB-1 (`## Inputs`)
  - `skill-canonical-location-audit` OB-2 (`## Audit Workflow`) and OB-3 (`## Output Template (Suggested)`)
- Observed: each item is a sentence fragment, a template placeholder ("Item: <canonical item name>."), an ordinal fragment ("1) Baseline capture block."), a bare token, or a reference to text the contract does not contain ("Use the list order", "under that epic").
- Required: each item is one complete, tool-neutral sentence that states the behavior of the whole source section; the `- **OB-<n>** <Heading>: ` prefix, numbering and `AC-<n>` citations stay unchanged; each bundle copy stays byte-identical.

## Finding R4 (code review CR-10): one member stated as the whole set

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: every member of each set or order is listed in the source SKILL.md section on this branch, so the fix copies existing content with no external input or owner decision.
Finding-Scope: contained

- Location: `## Observable Behaviors` of the base contract and its bundle copy. 17 items in 12 files:
  - `policy-compliance-order` OB-1 (`## Required Policy Reading Order (Baseline)`: the full order, stated tool-neutrally)
  - `evidence-and-timestamp-conventions` OB-3 (`## Canonical Evidence Locations`: all five locations)
  - `csharp-orchestration-state-machine` OB-2 and `powershell-orchestration-state-machine` OB-2 (`## Required Checkpoint Fields`)
  - `feature-promotion-lifecycle` OB-3 (`## Canonical Variables`) and OB-4 (`## Required Outputs for Downstream Handoffs`)
  - `feature-review-workflow` OB-1 (`## Required Shared Skills`)
  - `fill-feature-docs` OB-2 (`## Output Paths`)
  - `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer` OB-3 (`## Required Reporting Block`) and OB-5 (`## Preloaded Contracts`)
  - `pr-context-artifacts` OB-1 (`## Canonical Artifact Locations`)
  - `execute-hard-lock` OB-2 (`## Invocation Flow`: both required parameters, stated as plan path and calling checkout root) and OB-5 (`## Delegation Contract`: the preloaded shared skills)
- Observed: each item names one member of an enumerated set or order, so the contract reads as if that member were the whole requirement.
- Required: each item states the section's behavior as a whole and names every member of the set, or the full order, in tool-neutral terms; prefix, numbering and citations unchanged; bundle copies byte-identical.

## Finding R5 (code review CR-11): tool-specific mechanism in a behavior

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the tool-neutral behavior is stated in each source section on this branch, and cycle 1 already applied the same neutral wording to other contracts, so no external input or owner decision is needed.
Finding-Scope: contained

- Location: `## Observable Behaviors` of the base contract and its bundle copy. 4 items in 3 files:
  - `translate-copilot-to-claude` OB-2 ("Read the full file with `Read`.") and OB-5 ("`Read` the existing file when it exists.")
  - `orchestrate` OB-1 ("Read `AGENTS.md` ...")
  - `epic-plan` OB-1 ("... must read `AGENTS.md`, the applicable language policies under `.agents/skills/` ...")
- Observed: the behavior is stated through a runtime-specific tool name or instruction-file path, contrary to spec `### Contract Format` rule 6.
- Required: state the tool-neutral behavior (for example "reads the full source file"; "reads the repository standing instructions and the applicable language policies"); prefix, numbering and citations unchanged; bundle copies byte-identical.

## Verification Commands

1. Contract lint over every changed contract and its bundle copy (`Get-HarnessSkillContractViolation`): 0 violations.
2. Mirror identity: `cmp -s` of each of the 65 base contracts against its bundle copy: no differing pair.
3. Regression greps over both trees, each returning nothing: the R1 grep `grep -n ";\.$\|,\.$\|:\.$\|listed above\|listed below"`, the R2 grep `grep -l "Produce the outcome that the"`, the cycle 1 sweep grep, and `grep -n "^- \*\*OB-" <tree>/*/references/standard.md | grep -E 'AGENTS\.md|`Read`|<canonical|: 1\) |list order|that epic'`.
4. Source check: each of the 29 rewritten items read against the `SKILL.md` section it names, recorded per item in the task-check evidence.
5. The full parallel Pester gate (including `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`) and the Python bundle-parity contract set through the test-execution launcher, recorded under `evidence/qa-gates/`.

## Do Not Do

- No edit to the 45 accepted items (code review CR-12), to any `SKILL.md`, survey record, matrix, schema, module or test.
- No change to contract structure, numbering, headings or `AC-<n>` text.
- No serial, single-process, shuffled or reversed test run; no edit or deletion of existing evidence.

## Non-remediation notes

- Info (code review CR-13): the docs MCP tool names in four items are the same mechanism in every runtime; no change.
- Nit (code review CR-14): `powershell-qa-gate` OB-2 omits the source qualifier "(when enforced by task/repo flow)" on the coverage step; optional. This cycle does not touch that file, so leave it unchanged.
- Info (CR-3 to CR-7, carried): no change required.
- Pending-CI: spec `Required CI check` and the user-story completeness-gate criterion are checked off by the orchestrator at S9.
- These items do not gate the PR.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
