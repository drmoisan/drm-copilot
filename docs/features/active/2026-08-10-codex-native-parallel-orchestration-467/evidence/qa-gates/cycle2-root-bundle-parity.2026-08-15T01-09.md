# Cycle 2 Root/Bundle Registration and Byte Parity

Timestamp: 2026-08-15T02-09
Command: Enumerate every file below root `.codex/` and `.agents/`, excluding runtime `.codex/state/**`; enumerate the corresponding `.codex/` and `.agents/` files below `extensions/drm-copilot/resources/codex-and-agents-customizations/`; compare normalized relative paths and SHA-256 values.
EXIT_CODE: 0
Output Summary: The root and bundled customization maps each contain 237 files. All 237 corresponding files are byte-identical, with zero missing, extra, or mismatched path.

- Root source files: `237`
- Bundle files: `237`
- Byte-identical matches: `237/237`
- Missing paths: `0`
- Extra paths: `0`
- Mismatched paths: `0`
- Runtime `.codex/state/**` excluded: `YES`
- Frozen cycle-1 receipt SHA-256: `C9EDFEC6D19DF6B7864DA38061B092A69374EF7F205947AC79D006147C5BD7CA`
- Index paths: `0`

Result: PASS
