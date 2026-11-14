# Remediation Inputs — Issue 1160 (cycle 3 resumption under owner directive OD-1)

Timestamp: 2026-11-14T00-18
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Head: `45b50fe338e6dc0317526d3e78afceac6b857870`
Base: `main`, merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`
Opening review: review 2 of PR #1174 (`remediation-inputs.2026-11-13T19-53.md`, finding F2)
Remediation plan target: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T19-53.md` (revised in place)
Prior cycle record: the cycle opened at 2026-11-13T19-59 stopped with `blocked_preflight_iteration_limit` after its confirming preflight (`evidence/other/preflight-fixes.2026-11-13T20-59.md`) and applied no candidate.

## Owner Directive

OD-1 (class `scope_narrowing`), recorded in the checkpoint: "1. accept. 2. A) Policy Level." Item 2 selects the policy-level standard for the stage-2 pytest detection of issue 1160. Deliberately obfuscated commands are out of scope, because the pre-implementation gate is a policy-level control, not a security boundary.

Disposition rule for this item: a later review finding that is only a further obfuscation variant is dispositioned as out of scope under OD-1 and recorded, not remediated. A genuine policy-level defect, an ordinary non-obfuscated invocation that the gate misclassifies, is still fixed.

## Required Changes (closed list)

The cycle carries exactly the three changes the confirming preflight returned, plus the non-goal record. No other construct class is added.

1. Kind a: apply the `$_` clause of decision D17 at every modelled payload depth, not only at depth 0, and add row ED-94 `bash -c 'echo pytest; env $_'` with `Expected = $true`.
2. Kind b: treat a single-dash `git` option bundle containing `O` as the executing `-O` option (`git grep -iOpytest pytest` is classified).
3. Kind b: add `--hostname-bin` to `ExecutingOption.rg` (`rg --hostname-bin pytest x` is classified).
4. Non-goal: record a spec decision (D18, after D17 in `spec.md` under `## Decisions`) stating that deliberately obfuscated commands are out of scope for stage 2 because the gate is a policy-level control and not a security boundary, citing OD-1; and add the same sentence to the honest-disclosure text of the D17 rule (the commands sibling header and the #1160 bullet of the execution-environment brief).

Finding-Scope: contained (all four changes stay within the branch file set: `spec.md`, the Cases file, the new Modelled suite, the four sibling copies, and the six brief copies).
