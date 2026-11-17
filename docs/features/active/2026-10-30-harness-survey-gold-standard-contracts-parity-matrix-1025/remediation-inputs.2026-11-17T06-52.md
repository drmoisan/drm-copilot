# Remediation Inputs — Issue 1025 (re-audit R4 after remediation cycle 2)

Timestamp: 2026-11-17T06-52
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Issue: 1025
Base: epic/shared-agent-harness-layer-integration
Merge-Base: bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee
Reviewed-Head: d3ad430482b75bbc3631d5fe93448e3f135c446d
Source review artifacts:
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/policy-audit.2026-11-17T06-52.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/code-review.2026-11-17T06-52.md`
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/feature-audit.2026-11-17T06-52.md`

## Disposition

Findings R3, R4 and R5 of `remediation-inputs.2026-11-16T06-14.md` are closed in every named item and every bundle copy, and the 56 sweep fixes are accurate to their sources. Policy compliance passes; 41 of 43 acceptance criteria evaluate PASS and the other two are pending CI by design.

The reviewer's class sweep of all 262 Observable Behavior items found two residual instances of the same defect classes, one item each in two contracts. Both are autonomous and contained: the fix edits one line of a contract file already in the branch diff and copies it to its bundle mirror, and changes no spec acceptance criterion, public interface, schema, validator contract, hook decision or production logic. Cycle 2 took the full path, so this cycle takes the light path.

Scope boundary: the remediation covers the two items below, plus the optional CR-17 alignment in the same file as R6. Do not edit any other contract item, any `SKILL.md`, survey record, matrix, schema, module or test.

## Finding R6 (code review CR-15): tool-specific mechanism in a router behavior

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: the contract and its bundle copy are on this branch, and the tool-neutral wording already exists in the two sibling router contracts, so the fix needs no external input or owner decision.
Finding-Scope: contained

- Location: `## Observable Behaviors` OB-3 of `.agents/skills/python-change-budget-router/references/standard.md` and its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-change-budget-router/references/standard.md`.
- Observed: "If the MCP server or required tool is unavailable, stop before promotion." states the behavior through the MCP server mechanism (spec `### Contract Format` rule 6). Cycle 1 rewrote the identical source sentence in the C# and PowerShell router contracts.
- Required: the item text after the unchanged `- **OB-3** Orchestrated Small-Path Requirements: ` prefix reads, as in the sibling contracts, "Promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins." Numbering and `AC-<n>` text unchanged; the bundle copy byte-identical.

## Finding R7 (code review CR-16): count stated without members

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: both mechanisms and the preferred forms are stated in the source section on this branch, so the fix copies existing content with no external input or owner decision.
Finding-Scope: contained

- Location: `## Observable Behaviors` OB-4 of `.agents/skills/execution-environment/references/standard.md` and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/references/standard.md`.
- Observed: "Two separate mechanisms restrict Bash command text." is the lead-in sentence of `## Command-Text Restrictions` and names neither mechanism (plan `## Defect Class Tests` R4).
- Required: one complete sentence after the unchanged `- **OB-4** Command-Text Restrictions: ` prefix that names both mechanisms and their effect, and the preferred form, for example: "Command text is restricted by two separate mechanisms with different causes and fixes, the runtime worktree isolation guard, which is not a repository hook and refuses command text it cannot show stays inside an agent-isolated worktree, and the repository command hooks, which deny destructive patterns and a directory change followed later in the same command by a file-reading command, so the preferred forms name the target directory on the tool instead of changing into it." Mechanism names stay allowed because this contract's subject is the execution environment. Numbering and `AC-<n>` text unchanged; the bundle copy byte-identical.

## Light Fix Tasks

- [x] [P0-T1] Fix R6 (CR-15) in `.agents/skills/python-change-budget-router/references/standard.md` OB-3 with the required text, optionally apply the CR-17 alignment to OB-1 in the same edit, and copy the file byte for byte to its bundle mirror.
- [x] [P0-T2] Fix R7 (CR-16) in `.agents/skills/execution-environment/references/standard.md` OB-4 with one complete sentence naming both mechanisms and the preferred form, and copy the file byte for byte to its bundle mirror.

## Verification Commands

1. Contract lint (`Get-HarnessSkillContractViolation`) over the two contracts and their bundle copies: 0 violations.
2. `cmp -s` of each of the 65 base contracts against its bundle copy: no differing pair.
3. Over both trees, each returning nothing: the R1 grep, the R2 grep, the cycle 1 sweep grep, the R3–R5 grep of `remediation-inputs.2026-11-16T06-14.md`, and `grep -n "^- \*\*OB-" <tree>/python-change-budget-router/references/standard.md | grep -i mcp`.
4. Source check: each rewritten item read against its `SKILL.md` section, recorded in the task-check evidence.
5. Through the test-execution launcher (parallel only): the Pester selection including `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`, and the Python bundle-parity contract set; record results under `evidence/`.

## Do Not Do

- No edit to any other contract item, `SKILL.md`, survey record, matrix, schema, module or test.
- No change to contract structure, numbering, headings or `AC-<n>` text.
- No serial, single-process, shuffled or reversed test run; no edit or deletion of existing evidence.

## Non-remediation notes

- Nit (code review CR-17): `python-change-budget-router` OB-1 states only the estimate step; the sibling contracts state the full routing. Optional in the P0-T1 edit (estimate from production Python files, 1 to 3 production files to the small path in direct mode, more than 3 to the large path with no production-file cap, test files not counted).
- Info (CR-18, CR-19, CR-12, CR-13 and CR-3 to CR-7): no change required.
- Pending-CI: spec `Required CI check` and the user-story completeness-gate criterion are checked off by the orchestrator at S9; they do not gate this remediation.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
