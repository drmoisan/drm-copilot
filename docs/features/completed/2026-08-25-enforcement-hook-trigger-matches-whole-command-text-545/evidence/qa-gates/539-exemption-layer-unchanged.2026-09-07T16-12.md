# [P12-T14] Issue #539 exemption-layer invariance

Timestamp: 2026-09-07T16-12

Command:

```
git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
git status --porcelain -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
```

EXIT_CODE: 0 (both commands)

TOOLCHAIN_SUBSTITUTION: not applicable. This task invokes `git` only; no PowerShell toolchain stage
is required.

## Output Summary

**Both commands returned empty output for both paths.** The anchored diff against
`origin/epic/cleanup-merged-worktrees-hardening-integration` produced 0 bytes and 0 lines, and the
porcelain status restricted to the same two paths produced 0 bytes and 0 lines.

| Path | Anchored diff | Porcelain status |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | **empty** | **empty** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | **empty** | **empty** |

Verbatim captures:

```
$ git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
<no output>
exit 0

$ git status --porcelain -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
<no output>
exit 0
```

Byte and line counts of the captured output, so the emptiness is a measurement rather than an
impression:

| Capture | Bytes | Lines |
| --- | --- | --- |
| diff | 0 | 0 |
| porcelain | 0 | 0 |

## Why both commands are needed

The two observations answer different questions and neither alone is sufficient.

- The **anchored diff** compares the working tree against the base ref, so it reports any committed
  or uncommitted change to a tracked file. It is blind to a file that is untracked.
- The **porcelain status** reports modified, staged, and untracked paths relative to the index and
  HEAD. It goes empty once a change is committed, so it cannot by itself establish that a committed
  change does not exist.

Both empty together establishes that these two files are identical to their base-ref content and that
no uncommitted or untracked variant of either exists.

## What this establishes

`Test-ExemptOrchestrationStagingCommand` carries **no functional edit**. The function is declared at
line 296 of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, inside a file
that is byte-for-byte identical to its base-ref content, so no line of the function, its parameter
block, its option tables, or its prefix tests changed.

The exemption therefore **remains allow-side only**. Its sole call site in each gate is a conjunct
inside the pattern loop, consulted only after the trigger has already matched:

- Claude, `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 151:
  `if ($index -eq 0 -and (Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand)) {`
- Codex, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` line 170:
  `if ($index -eq 0 -and (Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand)) {`

Both call sites are guarded by `$index -eq 0`, which is the `git` staging trigger leg, and both are
reached only from inside the loop over the five trigger patterns. The exemption can therefore only
convert a match into an allow; it is never consulted to produce a deny and it cannot suppress a
trigger. That is D2 rule R5 as the specification states it: the exemption is consulted at the same
point in the decision flow as before.

## Corroboration

The Phase 5 record established that neither helper file appears in the change's diff. This task
verifies that claim directly against the current tree rather than relying on it, and the verification
holds.

Independent corroboration from the [P12-T1] enumeration at
`evidence/qa-gates/scope-and-size.2026-09-07T15-46.md`: neither
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` nor
`.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` appears among the 137 paths in
the union of the name-status diff and the porcelain status. The [P12-T2] scan of the four hook
directories for paths outside the nine in-scope hooks and the two parser siblings returned 0 paths,
which is the same finding reached from the other direction.

Behavioural corroboration from [P12-T13]: both CommandExemption suites report 59 tests with 0
failures on both sides, and all eight allow-side D4 cases plus all 45 denial cases pass unmodified.
An exemption layer that had acquired a functional edit would be expected to move at least one of
those 53 named decisions.

Both bundle mirrors of these helper files are likewise absent from the [P12-T1] enumeration, so the
invariance holds across the copy set and not only on the two canonical paths this task names.
