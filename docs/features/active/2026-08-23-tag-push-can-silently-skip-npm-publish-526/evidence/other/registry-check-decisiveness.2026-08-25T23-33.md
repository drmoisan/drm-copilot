# Registry-Check Decisiveness Determination (P0-T9)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: comparison of the two probes recorded by P0-T7 and P0-T8. No new command was issued for
this task; it compares the two already-observed exit codes.

EXIT_CODE: 0

## Inputs Compared

| Probe | Task | Command | Observed exit code | stdout |
|---|---|---|---|---|
| Absent version | P0-T7 | `npm view @danmoisan/drm-copilot-mcp@1.0.25 version` | 1 | empty (0 lines) |
| Present version | P0-T8 | `npm view @danmoisan/drm-copilot-mcp@1.1.0 version` | 0 | `1.1.0` |

Source artifacts:

- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/other/npm-absent-version-probe.2026-08-25T23-33.md`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/other/npm-present-version-probe.2026-08-25T23-33.md`

## Comparison

Absent-version exit code: 1
Present-version exit code: 0

The two exit codes differ (1 is not equal to 0).

## Determination

REGISTRY_CHECK_DECISIVE: true

DESIGN_PRECONDITION_FAILED_REGISTRY_CHECK: false

## Interpretation

The exact-version registry check specified by AC2, AC3, and AC16 is shown able to fail. The check
distinguishes the two registry states it must distinguish: an absent exact version yields a
non-zero exit with no version on stdout, and a present exact version yields exit code 0 with the
requested version echoed on stdout. A check built on that signal is falsifiable, which is the
design precondition this task exists to confirm.

The stdout dimension corroborates the exit-code dimension independently. `Test-NpmVersionResolved`
(P2-T2) requires both exit code 0 and stdout equal to the requested version, and the two probes
differ on both dimensions, so neither half of that conjunction is vacuous.

Because the determination is true, the plan's false branch does not apply. No downstream task is
marked INCOMPLETE on this basis. The nine tasks the plan enumerates as dependent on this check —
P2-T2, P2-T7, P2-T10, P2-T11, P2-T17, P3-T3, P3-T7, P3-T10, and P4-T4 — proceed normally in their
own phases. No design-precondition failure is escalated.

Output Summary: The absent-version probe exited 1 with empty stdout; the present-version probe
exited 0 with stdout `1.1.0`. The exit codes differ, so `REGISTRY_CHECK_DECISIVE: true` and
`DESIGN_PRECONDITION_FAILED_REGISTRY_CHECK: false`. The exact-version registry check is empirically
decisive and can fail, satisfying the design precondition for AC2, AC3, and AC16. Exactly one
`REGISTRY_CHECK_DECISIVE` line and exactly one `DESIGN_PRECONDITION_FAILED_REGISTRY_CHECK` line are
carried above. Execution continues normally with no downstream task marked INCOMPLETE.
