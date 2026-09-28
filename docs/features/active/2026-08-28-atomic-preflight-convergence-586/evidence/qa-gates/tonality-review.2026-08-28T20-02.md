# QA Gate — Tonality Review of Phase 1 Added Lines (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T5]
Reviewer: atomic-executor
Files Reviewed: `.claude/skills/atomic-plan-contract/SKILL.md` and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, added lines only
Policy applied: `.claude/rules/tonality.md`

Tonality Violations: 0

This task records no command. The added line ranges below are taken from the diffs recorded by [P2-T1] and [P2-T2].

## Added Line Ranges Under Review

`.claude/skills/atomic-plan-contract/SKILL.md` — 28 added lines, from the [P2-T1] artifact:

| # | Post-change line range | Lines | Content |
| --- | --- | --- | --- |
| 1 | 142–155 | 14 | `## Planner Adversarial Self-Review (Mandatory)` heading, opening paragraph, `Rules:` lead-in, the [P1-T2] and [P1-T3] rule bullets, the [P1-T4] declaration requirement and its two signal bullets, and the blank lines separating them |
| 2 | 166–179 | 14 | `Review depth and reporting rules:` lead-in, the [P1-T5] through [P1-T8] rule bullets, the [P1-T9] convergence paragraph with its two signal bullets and closing reconciling paragraph, and the blank lines separating them |

`.claude/skills/remediation-handoff-atomic-planner/SKILL.md` — 10 added lines, from the [P2-T2] artifact:

| # | Post-change line range | Lines | Content |
| --- | --- | --- | --- |
| 1 | 84–87 | 4 | `### Cycle-Document Sweep Scope` heading, its paragraph, and the blank lines separating them |
| 2 | 109–114 | 6 | The [P1-T10] deferral sentence, the [P1-T11] convergence-recording paragraph, the [P1-T12] iteration-ceiling paragraph, and the blank lines separating them |

Total under review: 38 added lines across the two files. Every non-blank added line was read individually against each of the four categories below.

## Per-Category Verdicts

### 1. Humor and joking — prohibited

**Satisfied.** No added line contains a joke, banter, playful remark, sarcasm, pun, or comedic phrasing. No added line contains self-aware commentary about tools, code, bugs, or the development process. No added line contains casual filler. The register throughout is imperative and declarative: what an agent MUST do, and the mechanism by which omitting it produces a defect.

### 2. Hyperbole — prohibited

**Satisfied.** No added line claims that anything is perfect, flawless, amazing, incredible, revolutionary, or world-class. No added line uses dramatic framing to overstate urgency, difficulty, risk, or impact.

Three phrasings were checked specifically because they are the ones most at risk of reading as inflated, and each was confirmed measured rather than hyperbolic:

- "Exhaustive first-pass review" ([P1-T8], line 171) is a literal description of the review scope required by [P1-T5] on the immediately preceding lines, not a superlative claim about review quality.
- "at most two preflight rounds per plan" ([P1-T8], line 171) is written as a target with a named mechanism, and the same bullet states the condition under which the target is not reached. It does not assert that the target will be met.
- "adversarial self-review" ([P1-T1], lines 142 and 144) is the term of art the requirement is named for in `issue.md` `## Proposed Behavior`. It describes the stance the pass takes toward the planner's own prior work and carries no dramatic claim.

The convergence signal values are likewise measured: `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` and `CONVERGENCE: FURTHER ROUNDS LIKELY` are both stated as expectations, and line 176 requires the reviewer to state why when further rounds are expected. Neither value asserts certainty beyond the available evidence.

### 3. Metaphor — tightly restricted

**Satisfied.** No decorative metaphor, analogy, or figurative construction appears in any added line. Two phrasings were checked specifically:

- "baked into a sibling line or test" ([P1-T3], line 149) is a mildly idiomatic verb for an assumption that is embedded in existing text. It is brief, literal in effect, and identifies the exact failure mechanism the bullet is written to describe, which meets all four conditions the tonality policy places on restricted figurative use. No shorter literal substitute was available that preserved the meaning of an assumption that is implicit in existing text rather than stated by it.
- "the violation ships with the cycle" ([P1-T13], line 86) uses "ships" in its ordinary software-release sense, which is a standard technical usage in this repository rather than a metaphor introduced by this change.

No other added line contains figurative language.

### 4. Evidence-first wording — required

**Satisfied.** Every added rule names its concrete failure mechanism rather than only an abstract goal, which is the standard the plan's `## Design Constraints Binding Every Phase 1 Task` sets by reference to the existing `## Wrap-Tolerant Assertion Authoring (Mandatory)` section. The mechanisms named:

| Added rule | Named mechanism |
| --- | --- |
| `**Re-derive every citation in this pass.**` | An earlier round's verification observed the tree before the intervening edits, so it is evidence about a superseded state. |
| `**Re-check the sibling region.**` | A fix to one line can invalidate an assumption embedded in a sibling line or test that a prior round's citation did not cover. |
| `SELF-REVIEW:` declaration | A signal carrying no enumeration is not a completed declaration; the blocked signal halts the handoff rather than permitting a self-approved plan. |
| `**Review the entire plan in one pass.**` | The unchecked remainder holds defects the same pass could have reported, and each unreported one becomes an additional round. |
| `**Enumerate every defect found.**` | A single-defect report causes the next round to rediscover a defect the same pass could have reported. |
| `**Check the delta against its own rule.**` | A delta that violates the rule it is written to enforce reintroduces the finding it closes. |
| `**Two-round target.**` | An exhaustive pass leaves at most a revision round and a confirming round; a one-defect-at-a-time pass cannot reach the target. |
| `CONVERGENCE:` block | Stated as a required signal with a stated relationship to the pre-existing two-value signal set. |
| `### Cycle-Document Sweep Scope` | A policy-compliance fix whose descriptive text violates the policy it enforces is written into a cycle document rather than into code, so a code-only sweep reports no finding. |
| Iteration ceiling | Names the trigger (`iterations` exceeding 2), the action (record, halt, escalate), and its relationship to the repeat-until-clear behavior it bounds. |

No added line implies certainty, completion, safety, or correctness without support. Where a statement is an expectation rather than a verified fact — the convergence line — it is written as an expectation.

## Self-Referential Check

The content authored by Phase 1 is a rule about review rigor, including a rule requiring a delta's own prose to comply with the policy class it is remediating. That rule was applied to this change's own prose: each of the 38 added lines was read against `.claude/rules/tonality.md` individually rather than assessed in aggregate, and the three hyperbole-risk phrasings and two figurative-language phrasings above were identified and adjudicated rather than passed over.

## Verdict

`Tonality Violations: 0`. No corrective edit was required and no re-run was needed. Gate passes.
