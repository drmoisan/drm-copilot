# Align devcontainers with the current tool baseline

- Issue: #1082
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1082
- Work Mode: full-bug
- Status: Active
- Source: [Promoted bug report](../../potential/promoted/2026-11-04-devcontainer-current-baseline.md)

## Summary

The local devcontainer previously created a separate persistent Git checkout, which could be incomplete or stale after rebuilding. Repairing its missing `HEAD` did not correct outdated tool pins or install the missing tools identified by the user. The previous verification script accepted that incomplete baseline.

## Reproduction

1. Rebuild using `.devcontainer/local/devcontainer.json` from the Windows host checkout.
2. Inspect workspace contents and installed tool versions after post-create.
3. Compare those results with the user's supplied current Dockerfile baseline.

The initial failure was `fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree.` The follow-up report confirmed that the rebuilt environment still had incorrect dependencies. A successful check against the old verifier does not establish compliance with the requested baseline.

## Expected Behavior

Local Docker and Codespaces use the same post-create setup against their actual workspace, install the approved pinned tool baseline and this repository's additional tools, and verify the complete environment before reporting completion. Local Docker directly exposes host source edits while isolating Linux `.venv` and `node_modules` contents from Windows packages.

## Baseline Authority

The user's supplied Dockerfile establishes the selected base image and starting tool versions. The [completed research](research/2026-11-05T02-42-devcontainer-current-baseline-research.md) verifies actual artifact availability and migration requirements. The selected base provides Python 3.13.18 and Git 2.56.0; an older Python runtime must not be copied over it. The complete version contract and acceptance criteria are in [spec.md](spec.md).

## Scope

Synchronize both devcontainer configurations, Dockerfiles, shared setup and verification, version predicates, relevant host bootstrap and CI contracts, documentation and execution-environment mirrors, and their asserting tests. Migrate the repository's Pester integration to the supplied Pester 6.2.0 baseline with verified test and coverage compatibility.

Preserve the existing Python consumer compatibility matrix, published extension engine ranges, additional development tools, host source/data, and the unused previous workspace volume until any container-only work has been recovered.

## Acceptance Source

This is a full-bug workflow. The authoritative acceptance criteria are the unchecked items under `## Acceptance Criteria` in [spec.md](spec.md). No user-story document is required.
