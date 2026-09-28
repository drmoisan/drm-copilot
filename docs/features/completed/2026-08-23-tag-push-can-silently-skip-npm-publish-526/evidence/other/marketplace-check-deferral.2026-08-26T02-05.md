# Deferral Record — Marketplace Listing Verification — P6-T3

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command: none. This is a recorded design decision, not a command result.

EXIT_CODE: not applicable — no command was executed for this record.

## Source

`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`, section 8.2
("Open questions, with verification status"), first bullet: **UNVERIFIED — the Marketplace
verification command.**

## What is deferred

The spec records two candidate mechanisms for verifying that a published extension version is listed
on the VS Code Marketplace:

1. `npx --yes @vscode/vsce show <publisher>.<name> --json`
2. The unauthenticated Marketplace `extensionquery` REST endpoint

Neither was executed by the research artifact. The exact invocation, the output shape, and whether
the current `vsce` supports `--json` are therefore all unverified. Spec section 8.2 states that the
implementation must validate the command before depending on it, and that if validation fails the
Marketplace check may be deferred without weakening the npm-side guarantee.

This execution did not validate either candidate. Both remain unverified, and the Marketplace
listing check is deferred.

## Why the deferral costs nothing against the acceptance criteria

No acceptance criterion in `spec.md` depends on the Marketplace check. AC1 through AC28 were
reviewed for a Marketplace dependency and none was found: the registry-side criteria (AC2, AC3,
AC16) name the npm registry explicitly, and the state-model criteria (AC6 through AC10) enumerate
the six tokens `RESOLVED`, `NO_RUN`, `RUN_FAILED`, `STEP_SKIPPED`, `STEP_MISSING`, and `UNRESOLVED`,
none of which is a Marketplace state. Spec section 2.3 additionally excludes any change to the
Marketplace publish path "beyond read-only verification", and spec section 3.4 lists the Marketplace
poll as check (c') — a fourth check distinct from the three the state model composes.

The npm-side guarantee is the one that covers the 1.0.25 defect, which was an absent npm package
version consumed by a shipped `.codex/config.toml` pin. That guarantee is unaffected.

## Consequence for the implementation

The extension post-push verification added by P3-T6 in
`scripts/dev-tools/Invoke-ReleaseTagPush.ps1` calls `Invoke-TagPublishVerification` with the
`SkipRegistryResolutionCheck` switch supplied. It therefore runs **checks (a) and (b) only**:

- check (a) — a workflow run exists for the extension tag ref
- check (b) — the publish step of that run concluded `success` rather than `skipped` or absent

Check (c) is omitted for the extension tag because the extension publishes to the VS Code
Marketplace rather than to the npm registry, so there is no npm version for check (c) to resolve.
The check (c') Marketplace equivalent is the deferred item recorded above, so no third check runs on
the extension path.

The switch is asserted by the test named "does not invoke the npm seam when the registry-resolution
check is skipped" in `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`, which records an
`Invoke-NpmExe` mock invocation count of exactly 0 for a skipped-check call.

Output Summary: Marketplace listing verification is deferred. Both candidate commands from spec
section 8.2 remain unverified and neither was executed. No acceptance criterion (AC1 through AC28)
depends on the Marketplace check. The extension post-push verification consequently uses checks (a)
and (b) only, via the `SkipRegistryResolutionCheck` switch. The npm-side guarantee that covers the
1.0.25 defect is unaffected by this deferral.
