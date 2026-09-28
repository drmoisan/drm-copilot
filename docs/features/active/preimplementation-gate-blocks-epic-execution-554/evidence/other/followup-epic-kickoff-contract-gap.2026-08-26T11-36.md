# Follow-Up Issue Draft — Epic Child Kickoff Prompt Carries No Guaranteed Target Token

Timestamp: 2026-08-26T11-36

Status: DRAFT ONLY. Not filed. See the companion deferral record
`evidence/other/followup-issue-filing-deferred.2026-08-26T11-36.md` for why filing is a maintainer
action outside this branch.

Origin: decision **D3** of
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, and section E1 of
`research/2026-08-26T09-30-preimplementation-gate-epic-execution-554-research.md`.

---

## Title

Epic child kickoff contract does not guarantee a target-resolvable token, so `Agent` PreToolUse gates cannot resolve a wave-0 child

## Labels (suggested)

`bug`, `orchestration`, `contract-gap`

## Body

### Summary

`.claude/skills/epic-orchestrate/SKILL.md` does not mandate that an epic child's kickoff prompt
carry the child's own `docs/features/active/<slug>` basename token, and its kickoff marker line
carries no `issue_num:` key. Two `PreToolUse` hooks registered on the `Agent` matcher must resolve
the delegation's target feature from the prompt in order to make a decision, so a child whose
kickoff prompt happens to carry neither identifier is denied by both.

### The gap in detail

Target resolution on the `Agent` matcher works by scanning the field-scoped `prompt` for a
`docs[\\/]+features[\\/]+active[\\/]+...` path token, longest unique match winning, with a match
ending in the Markdown extension resolving to its parent directory and the comparison made on
basename. `issue_num` is accepted as an alternative when the prompt carries a resolvable issue
number and the checkpoint records `issue_num` on its feature entries.

The epic kickoff contract guarantees neither identifier:

- The kickoff marker line beginning `Epic mode: true` carries no `issue_num:` key.
- The only line that reliably carries a `docs/features/active/` path is the dependency-citation
  line, which is emitted **only** for a feature with a non-empty `depends_on`, and which names the
  **dependency's** folder rather than the target's.

A **wave-0 child has no dependencies by construction**, so it gets no dependency-citation line, and
therefore has no contractually guaranteed target token. Whether such a child's prompt happens to
contain a usable token is left to incidental wording — which is the same class of fault as Fault 1
in issue #554, one level up in the contract rather than in the classifier.

The parallel surface does **not** have this gap: `.claude/skills/parallel-orchestrate/SKILL.md`
mandates the path token in its item kickoff.

### Affected consumers

| Hook | Behaviour when no target resolves |
| --- | --- |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | denies with `EPIC_WAVE_BARRIER_BLOCKED: an epic-mode orchestrator delegation must reference the target feature folder in the prompt` |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (as of issue #554) | denies; deny-by-default is preserved |

### Why this is inherited, not introduced

Issue #554's fix adopts the wave-barrier hook's existing resolution technique verbatim. The
wave-barrier hook is registered on the **same** `Agent` `PreToolUse` matcher and **already denies**
the exact case in which no target resolves. Requiring the token in the preimplementation gate
therefore creates **no new denial surface**: any prompt that fails the new predicate is already
denied by the sibling hook on the same matcher, so the marginal behavioural cost of issue #554's
decision D3 is zero. The gap predates #554 and is untouched by it.

### Recommended contract amendment

Amend `.claude/skills/epic-orchestrate/SKILL.md` so the epic child kickoff prompt carries a target
identifier unconditionally. Either of the following closes it; the first is preferred because it
matches the parallel surface and the existing resolution technique:

1. **Mandate the child's own `docs/features/active/<slug>` basename token** in the kickoff prompt,
   emitted for every child regardless of `depends_on`, in the same way
   `.claude/skills/parallel-orchestrate/SKILL.md` already mandates it for a parallel item.
2. **Add an `issue_num:` key** to the `Epic mode: true` kickoff marker line, and confirm that the
   epic orchestrator checkpoint records `issue_num` on its `features[]` entries so the alternative
   resolution path has a matching operand on both sides.

A fix should also add a Pester assertion that the kickoff contract emits the mandated token for a
wave-0 child, so the guarantee is tested rather than documented.

### Related

- Issue #554 — the structural repair of the preimplementation gate that surfaced this gap.
- Issue #555 — single-surface readiness for the Codex file and command legs; separate and also open.
- A second, independent follow-up recorded in `spec.md` `## Rollout & Follow-up`: extraction of a
  shared mode-resolution module used by all seven mode-aware hooks. That is a refactor, not a bug
  fix, and must not be bundled with either this gap or #554.

---

## Rationale for raising it separately

Three reasons, each sufficient on its own:

1. **It is a different defect in a different artifact.** Issue #554 is a decision-procedure fault
   inside a `PreToolUse` hook. This is a missing guarantee in an authoring contract consumed by two
   hooks. Fixing the hook does not fix the contract, and fixing the contract would not have fixed
   the hook.
2. **Closing it here would require an edit this feature is forbidden to make.** The remedy is an
   edit to `.claude/skills/epic-orchestrate/SKILL.md`.
3. **Zero marginal exposure means there is no urgency argument for bundling.** Because the
   wave-barrier hook already denies the unresolvable case on the same matcher, deferring this gap
   leaves no delegation denied that was not already denied before issue #554.

## Explicit out-of-scope statement

**Closing this gap is out of scope for issue #554.**

**No `.claude/skills/` file is modified by this feature**, on either surface or in any mirror. That
prohibition is stated in three places and all three are honoured:

- `spec.md` `## Scope & Non-Goals`: "Do not modify any `.claude/skills/**` or `.claude/rules/**`
  file, including the epic kickoff contract gap identified in D3."
- `spec.md` decision D3: "**No `SKILL.md` file is modified by this feature**, on either surface or
  in any mirror."
- `spec.md` `## DECLARED BLAST RADIUS` statement (b), which excludes the entire `.claude/skills/`
  prefix from the radius.

Compliance is verified by measurement, not by assertion: the P5-T2 artifact
`evidence/qa-gates/policy-paths-untouched.2026-08-26T11-36.md` records a match count of 0 for the
pattern `^\.claude/rules/|^\.claude/skills/|^\.github/` against the full 45-path branch diff.
