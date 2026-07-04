# Final QA — Grep Proof: Six-Condition PR Creation Gate (AC3)

Timestamp: 2026-06-28T00-09

Target file: .claude/skills/orchestrate/SKILL.md

## PR Authoring heading present

- line 68: `## PR Authoring (pr-author Handoff)` (replaces the former `## PR Creation Delegation`).

## PR Creation Gate — six numbered conditions (lines 209–220)

Heading at line 209: `## PR Creation Gate`
Lead-in (line 211): "until all six conditions are simultaneously true".

1. (line 213) `blocking_findings_resolved: true` — most recent feature-review produced zero blocking findings.
2. (line 214) AC verification artifact confirms all acceptance criteria pass.
3. (line 215) mandatory toolchain passed in its most recent run on the branch.
4. (line 216) checkpoint `next_step` is `S8_create_pr`.
5. (line 217) **Receipt condition** — PR body produced via the pr-author handoff: `artifacts/pr_body_<N>.md` exists with a matching `artifacts/pr_body_<N>.receipt.json`, created with `--body-file`.
6. (line 218) **CI-green condition** — `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`; DONE is not written while either sub-condition is false.

Closing note (line 220): conditions 1-4 unchanged; condition 5 (receipt handoff) and condition 6 (CI-green gate) are additive.

## Result

AC3 satisfied: the `## PR Creation Gate` lists six numbered conditions; condition 5 is the receipt condition and condition 6 is the CI-green condition. The `## PR Authoring (pr-author Handoff)` heading is present.
