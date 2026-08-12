# Translation Authority Baseline

Timestamp: `2026-08-10T22-54`

mode=apply

Command: `if (-not (Test-Path -LiteralPath 'docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md')) { throw 'Corrected Codex research basis is missing' }; if (Test-Path -LiteralPath 'artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md') { throw 'Obsolete Codex research basis must not be authoritative' }`

EXIT_CODE: `0`

Output Summary: Verified the corrected Codex research authority at `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`, verified the obsolete `artifacts/research/` alias is absent, and retained feature-scoped translation evidence under `evidence/other/`.

The authoritative translation research basis is `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`, verified with SHA-256 `90e781fff85ed9f9ecc434f90c982f9753ac985c224edd56eddd85a74b9f9494`.

The obsolete path `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` is absent and is not authoritative.

Apply-mode outputs are classified as feature implementation evidence under `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/`:

- `translation-plan.2026-08-10T20-25.md`
- `translation-diff.2026-08-10T20-25.md`
- `translation-snapshots/`

EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...
