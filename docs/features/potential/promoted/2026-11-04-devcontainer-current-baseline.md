# devcontainer-current-baseline (Issue #1082)

- Date captured: 2026-11-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/devcontainer-current-baseline/ (Issue #1082)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1082
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1082
- Last Updated: 2026-11-05
## Summary

Local devcontainer startup used a separately seeded persistent Git checkout, which could be incomplete or differ from the host source. Both container images also have outdated tool pins and omit required development tools compared with the user's supplied current environment baseline.

## Environment

- OS/version: Windows with Docker Desktop Linux containers; Debian Bookworm container
- Python version: current repository runtime 3.13.17
- Command/flags used: Dev Containers: Rebuild Container, local configuration
- Data source or fixture: user-supplied working Dockerfile baseline

## Steps to Reproduce

1. Open this checkout using `.devcontainer/local/devcontainer.json`.
2. Rebuild the devcontainer after updating the host checkout.
3. Inspect workspace contents, installed tools, versions, and post-create completion.

## Expected Behavior

Both configurations build complete environments with the supplied pinned baseline, preserve this repository's additional tools, install locked project dependencies, and verify all managed tools before reporting success. Local setup uses the live workspace in the same manner as Codespaces, with Linux dependency storage isolated from host packages.

## Actual Behavior

The local persistent workspace previously contained `.git` without a valid `HEAD`, causing post-create exit 128. A targeted recovery patch repaired that state but did not address the user-reported outdated dependencies and missing tools. The existing verifier only checked a subset and accepted the outdated environment.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `fatal: ambiguous argument 'HEAD': unknown revision or path not in the working tree.`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The local seeding path differs from the direct workspace setup used by Codespaces. Existing Dockerfiles and verification contracts are synchronized with an older baseline, including a Pester 5-only restriction.

User starting baseline: base image `mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm`; Git >=2.56.0; PowerShell 7.6.9; Poetry 2.5.1; GitHub CLI 2.103.3; Node 26.13.0; .NET SDK 10.0.403; actionlint 1.7.12; Pester 6.2.0; PSScriptAnalyzer 1.25.0; uv 0.13.7; Claude Code 2.1.318; claude-swap 0.29.0; Codex 0.166.0. Preserve additional repository tools and validate actual artifacts and Pester compatibility; do not silently substitute versions.

## Proposed Fix / Validation Ideas

- [ ] Regression tests for the tool-version contract, required CLI/module coverage, and shared setup behavior
- [ ] Build and run both full configurations, including devcontainer features and post-create lifecycle
- [ ] Verify local live source visibility, independent Linux dependencies, Git ownership/fsmonitor handling, and repeated setup
- [ ] Synchronize relevant bootstrap, CI, documentation, and environment mirrors; validate Pester 6 test compatibility

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
