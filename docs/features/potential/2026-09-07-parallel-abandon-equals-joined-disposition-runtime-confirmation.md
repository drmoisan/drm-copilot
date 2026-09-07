# parallel-abandon-equals-joined-disposition-runtime-confirmation (Potential)

- Date captured: 2026-09-07
- Author: drmoisan
- Status: Draft
- Source: issue #545 specification, design decision D11.6, follow-up 2 of 2
- Specification: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`

## Problem / Why

D11.6 records that the equals-joined disposition bypass in
`.claude/hooks/enforce-parallel-abandon-gate.ps1` was, at specification time, **derived rather than
executed**. The derivation ran as follows: `scripts/dev_tools/parallel_mutation_abandon_cli.py` line
236 registers `--disposition` as an ordinary `argparse` optional with `choices`; `argparse` accepts
the `--option=value` spelling for such an optional; and the hook's scope test compared against the
space-separated two-word literal by substring containment, which the equals-joined spelling does not
contain. D11.6 required runtime confirmation before the corresponding acceptance criterion could be
checked off, on the ground that a finding reasoned from library semantics is not the same evidence as
an observed return value.

That runtime confirmation has now been performed under issue #545, task [P10-T12], and is recorded
at:

`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md`

That artifact records an executed run against the unfixed hook in which
`Test-ParallelAbandonCommandInScope` returned `$false` for the equals-joined spelling and `$true` for
the space-separated spelling, so the bypass is observed rather than inferred. Issue #545 then fixes
the hook so both spellings are recognized structurally through the segment's `Tokens`.

What remains open, and is the reason for this entry, is that the confirmation obtained is a
**decision-seam** confirmation and not an **end-to-end** one. The recorded run drove the hook's
in-process function directly. It did not exercise the full path in which a real agent-issued
equals-joined command reaches the `PreToolUse` hook through the runtime envelope, is normalized, and
produces or fails to produce a deny decision. Two properties are therefore still unobserved end to
end:

1. That the runtime envelope delivers the command text to the hook in the form the decision seam was
   driven with, rather than in a form that differs in quoting, whitespace, or encoding.
2. That the post-fix hook denies the equals-joined spelling in a live invocation, closing the bypass
   in the path that an operator would actually take, rather than only in the seam.

A concrete instance of the same over-match class was observed while this entry was being authored.
Writing this document through a shell heredoc was itself denied by the gate, because the document
text quoted the space-separated two-word literal inside a quoted heredoc body that executes nothing.
That is the over-match direction issue #545 fixes, and it is recorded here as an incidental live
observation rather than as a defect of this entry.

## Proposed Behavior

Confirm the equals-joined disposition bypass, and its closure, through an end-to-end runtime
invocation rather than through the decision seam alone, and record that confirmation as evidence.

The confirmation should observe the pre-fix behaviour if a pre-fix reference is still reachable, and
must observe the post-fix behaviour in the delivered hook. If the pre-fix behaviour is no longer
reachable once issue #545 has merged, the [P10-T12] artifact stands as the pre-fix record and this
work is scoped to the post-fix leg only.

## Acceptance Criteria (early draft)

- [ ] A live `PreToolUse` invocation carrying the equals-joined disposition spelling is observed
      being denied by the post-fix `.claude/hooks/enforce-parallel-abandon-gate.ps1`, with the
      observed decision recorded.
- [ ] The command text as it arrives at the hook through the runtime envelope is recorded verbatim
      and compared against the text used to drive the decision seam in [P10-T12].
- [ ] The evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] The artifact cross-references the [P10-T12] artifact path named above and states which of the
      two legs — pre-fix or post-fix — each observation belongs to.
- [ ] The entry's findings are reconciled against D11.6 so the follow-up can be closed or restated.

## Constraints & Risks

- `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both the hook and the CLI at
  run time and fails if either side's token declaration changes shape. Both token literals in the
  hook must stay in their current single-assignment form. Any work under this entry that touches the
  hook is bound by that constraint.
- An end-to-end runtime confirmation requires driving a real `PreToolUse` invocation, which is not
  reproducible from a pure unit-test seam and cannot be satisfied by adding a Pester case alone.
- `pwsh` has not been invocable in recent sessions in this worktree, which constrains how the
  confirmation can be executed and may make a CI-dispatched route the practical one.

## Test Conditions to Consider

- [ ] Live invocation with the equals-joined spelling against the post-fix hook.
- [ ] Live invocation with the space-separated spelling against the post-fix hook, as the control
      that the fix did not narrow the existing denial.
- [ ] A negative control in which the disposition token appears only inside a quoted span, confirming
      the masked-trigger model still treats it as out of scope.

## Next Step

- [ ] Promote to GitHub issue (bug template — this is a verification-depth gap on a delivered fix)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
