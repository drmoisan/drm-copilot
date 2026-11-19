# Corpus Digests - [P1-T1]

Timestamp: 2026-11-19T09-19
Command: sh SCRATCH/issue-1049-digests.sh (printf with octal escapes writes the normalized bytes of each case; od -An -tx1 renders them; coreutils sha256sum hashes them; independent of the TypeScript and PowerShell implementations); sh SCRATCH/issue-1049-corpus-check.sh (byte scan of tests/fixtures/push-down-manifest-hash/corpus.json with od, and a JSON parse with node)
EXIT_CODE: 0
Output Summary: Nine cases written in the required order with the digests below. `empty` and `abc` equal the published SHA-256 vectors; `lf-pair`, `crlf-pair` and `lone-cr` share one digest. The corpus parses as JSON, holds nine cases, contains no byte 0D and no byte above 7F (CR_BYTES: 0, HIGH_BYTES: 0).

| Case | Normalized bytes (hex) | SHA-256 |
| --- | --- | --- |
| empty | (none) | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 |
| abc | 616263 | ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad |
| lf-pair | 610a62 | 7e18f737311b2dc3b2f269dd78396b0351f14fb66efa879f768cb23181883c78 |
| crlf-pair | 610a62 | 7e18f737311b2dc3b2f269dd78396b0351f14fb66efa879f768cb23181883c78 |
| lone-cr | 610a62 | 7e18f737311b2dc3b2f269dd78396b0351f14fb66efa879f768cb23181883c78 |
| cr-crlf | 610a0a62 | 38022fd2b8dbc5cb3d2cee74e083edbf59e3d4e13d067ebcb5db633d4cff4d8c |
| bom | efbbbf616263 | 1c28dc3f1f804a1ad9c9b4b4cf5e2658d16ad4ed08e3020d04a8d2865018947c |
| non-ascii | 636166c3a920e4b8ad | a9482a7dcae6feb80be9e0a1ba47b979b8cd46c7e17ac8af8fc772eac448e247 |
| trailing-crlf | 780a | 73cb3858a687a8494ca3323053016282f3dad39d42cf62ca4e79dda2aac7d9ac |

Note: the first write of the file stored the BOM, U+00E9 and U+4E2D as raw UTF-8 (the write tool decoded the `\u` escapes). A byte-level `sed` in SCRATCH/issue-1049-corpus-escape.sh restored the `﻿`, `é` and `中` escapes before this record was written; the byte scan above was taken after that correction.
