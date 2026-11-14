# Runtime Schema Copy ([P3-T1])

Timestamp: 2026-11-03T13-13
Command: sh SCRATCH/issue-1020-exec-copy-schemas.sh (one `cp` of `schemas/docs/v1/*.schema.json` to `.claude/lib/docs/schemas/v1/`, then `git status --porcelain --untracked-files=all -- .claude/lib/docs/schemas` and `sha256sum` of each pair)
EXIT_CODE: 0
Output Summary: Eight new untracked files under `.claude/lib/docs/schemas/v1/`, including `docs-command-envelope.schema.json`; every runtime copy has the same SHA-256 as its canonical file.

## Status listing

```
?? .claude/lib/docs/schemas/v1/common.schema.json
?? .claude/lib/docs/schemas/v1/docs-command-envelope.schema.json
?? .claude/lib/docs/schemas/v1/docs-coverage-ledger.schema.json
?? .claude/lib/docs/schemas/v1/docs-evidence-pin.schema.json
?? .claude/lib/docs/schemas/v1/docs-parity-matrix.schema.json
?? .claude/lib/docs/schemas/v1/docs-profile.schema.json
?? .claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json
?? .claude/lib/docs/schemas/v1/surface-inventory-snapshot.schema.json
```

## Per-file digests (canonical = runtime copy)

| File | SHA-256 | Equal |
|---|---|---|
| common.schema.json | 7e9f04527049ddc027237122ddad64048f42be5d76bbcc3a33af083195e5c8dd | yes |
| docs-command-envelope.schema.json | ce0ed48c85990999a0856f89ff656cf364398bf3109ecc707fbecd1d188d08bb | yes |
| docs-coverage-ledger.schema.json | 461c9b25ae6c1455fb560f89616f0971925673c3b0a03232ceb59f8cf4472358 | yes |
| docs-evidence-pin.schema.json | d25c85cf257a76e9782378b16cca4eebd82269833658aa3e16be2e5ad579e2f1 | yes |
| docs-parity-matrix.schema.json | bde17f6f48a4f3d47ade11a563213e695c1a6e450906e3bdf3fb2dc5ed6ab8e5 | yes |
| docs-profile.schema.json | b9bdb572f6912a17bd84d9c03a9a94bdbb68ee818f39f5e867ef5c786632f23e | yes |
| docs-validation-receipt.schema.json | ec77894a038b27fc16826f4d51aef5cdb77da7d7442bed55a25db3ae8f4b2dc6 | yes |
| surface-inventory-snapshot.schema.json | 4cd767089dbf44b8f227b68ad0b4cc3b40a3ac7bfa391304e7d3a6eb908ad609 | yes |
