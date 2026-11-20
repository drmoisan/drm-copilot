# PyYAML Stub Resolution Decision (P5-T4)

Timestamp: 2026-07-18T14-40

## Outcome: no new dependency required

The final Pyright strict-mode run (`poetry run pyright`) completed with
`0 errors, 0 warnings, 0 informations`. No missing-stub diagnostic was emitted for the
`yaml` import. Pyright's bundled typeshed third-party stubs resolved `import yaml` and
`yaml.safe_load` successfully.

## Decision

`types-PyYAML` was NOT added. It would be a new dev-group dependency requiring explicit
approval, and it is unnecessary because the bundled typeshed stubs are sufficient. No
`pyproject.toml` dependency change was made for typing purposes (PyYAML>=6.0 remains the
only YAML-related declared dependency, now load-bearing for the first time via this
feature's `import yaml`).

Pyright diagnostic quoted: none for `yaml` (the stub was resolved; no diagnostic to quote).
