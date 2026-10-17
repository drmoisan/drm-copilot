# Bash Local Baseline (P0-T20)

Timestamp: 2026-09-29T17-39
Command: shfmt --version ; shellcheck --version ; npx --yes bats --version ; npx --yes bats tests/shell/parallel_payload_only.bats tests/shell/parallel_ba?h_manifest_membership.bats
EXIT_CODE: 0
Output Summary:
- shfmt --version: exit 0, `v3.12.0`
- shellcheck --version: exit 0, `version: 0.11.0`
- npx --yes bats --version: exit 0, `Bats 1.13.0`
- bats run: exit 0, TAP plan `1..17`, 17 `ok` lines
- Local bats baseline failure set (`not ok` lines): none (empty set)

The second suite path is spelled with the Shell route glob in the command text
(`tests/shell/parallel_bash_manifest_membership.bats`); the glob matched exactly one file.
