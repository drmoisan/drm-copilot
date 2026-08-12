# Publishing and CI Registration Acceptance Evidence

- Timestamp: `2026-08-11T15:39:13.7962940-04:00`
- Plan task: `[P5-T12]`
- Result: `PASS`
- EXIT_CODE: `0`

## Ordered acceptance pass

| Gate | Command | Result | Elapsed |
| --- | --- | --- | ---: |
| Python publisher, pack, parity, and selection | `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'` | exit `0`; `58` passed, `3,785` deselected | `1,925 ms` (`0.80 s` Pytest) |
| Full TypeScript unit suite | `npm --prefix extensions/drm-copilot run test:unit -- --runInBand` | exit `0`; `193/193` suites and `2,665/2,665` tests passed; `0` snapshots | `7,320 ms` (`6.616 s` Jest) |
| Cross-runtime in-memory publisher comparator | read-only Python and transpiled-TypeScript public publisher invocation | exit `0`; sorted paths `19/19`, hashes `19/19` | `1,018 ms` |
| Root/resource and registration comparator | read-only SHA-256 and parsed-TOML registration comparator | exit `0`; byte pairs `36/36`; registered targets `28/28` at root and `28/28` in the bundle | `11 ms` |
| Pack-closure comparator | read-only core and language-pack validator | exit `0`; closure `48/48`, core members `127`, effective sources `48/48`, selected packs `5/5` | `5 ms` |
| Routing-merge parity comparator | read-only normalized Python and TypeScript comparator | exit `0`; destination retention, equal skip, and unequal collision `3/3` | `909 ms` |
| Python isolated publication | `poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <python-destination> --packs core` | exit `0`; `126` files | `831 ms` |
| TypeScript isolated publication | `node -` using the repository transpile hook, `RealPushDownFileSystem`, and the public publisher | exit `0`; `126` files | `320 ms` |
| Isolated-destination comparison | read-only sorted path/SHA comparator | exit `0`; paths `126/126`, hashes `126/126`, destination routes `2/2`, generic config `2/2` | `22 ms` |
| Python restricted-PATH payload contract | Git Bash with `env -i PATH=tests/fixtures/parallel_payload_path` | exit `0`; assertions `21/21` | `17,738 ms` |
| TypeScript restricted-PATH payload contract | Git Bash with `env -i PATH=tests/fixtures/parallel_payload_path` | exit `0`; assertions `21/21` | `17,172 ms` |
| Five-owner Bats contract | supported Bats `1.13.0` wrapper with the five plan-owned files | exit `0`; TAP `1..75`, `75/75` passed | `132,203 ms` |
| Authoritative PoshQC contract suite | `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]` | exit `0`; fresh JUnit `539/539`, failures `0`, errors `0`, disabled `0` | `99.05 s` JUnit |
| Required completion-job contract | focused `parallel-completion-compensating-controls.Tests.ps1` | exit `0`; `8/8` passed, failed `0`, skipped `0` | `1,679 ms` |
| Shell quality check | Git Bash: `bash scripts/bash/shell-qc.sh check` | exit `0`; stdout and stderr empty | `5,365 ms` |
| Claude manifest comparator | fresh SHA-256 manifest compared with P0-T7 | exit `0`; baseline/current/matched `150/150/150`, missing `0`, extra `0`, changed `0` | `24 ms` |

## Publisher, pack, and merge proof

- The fresh in-memory publisher comparison emitted identical Python and
  TypeScript path and byte-hash manifests. Its deterministic fixture manifest
  SHA-256 was
  `9b06c297e9340642e73e2c308b1f77c91c57cf7ad437474e604c97250fd94ea2`.
- Root/resource pair parity retained SHA-256
  `5c8d751c4f2e490a032cd52e5992d65461249055fc93290f5e399ef6ebf0e13f`.
  Registration parity retained SHA-256
  `099bc154156a7b1b1ac88d12c73252b764cdc73a6a165b2457dbd52dd76b6462`.
- Core closure remained `48/48` with `127` unique core members, `0` internal
  duplicates, `0` cross-language closure duplicates, exactly `14/14` approved
  portable Claude library paths, `0` unrelated Claude paths, and core SHA-256
  `2009cfc43103347db57e1418e80fa4b0057e4026674aa76784e807174d64b8cc`.
- Routing merge parity remained `3/3`. Both runtimes emitted
  `ROUTING_MERGE_SUBSTANTIVE_COLLISION` with details
  `routes.alpha, routes.zeta` in that order. The fresh normalized matrix
  SHA-256 was
  `74b912a751dd9159423339b5c3bb35c4bb9ac96541506092dc0bd082d53dec26`.
- The two repository-contained isolated destinations emitted identical
  `126/126` path and `126/126` hash manifests. The fresh fixture manifest
  SHA-256 was
  `efd018bd82a2fdab27b1edf8451c6ee52e02aae1428e7a4914f0990ff1d93038`.
  Both retained their destination-owned route, included the exact portable
  `14/14` library paths and generic blast-radius config, and included `0`
  unrelated Claude paths.

## Payload-only execution

- The restricted child `PATH` exposed only the checked-in `sort`, `cut`,
  `cat`, and `dirname` shims. `python`, `python3`, and `poetry` were unresolved
  for both published destinations.
- Both destinations produced cohorts `[[2],[1,3]]`, batches
  `[[1,2],[3,5]]` at concurrency `2`, batches `[[1],[2],[3]]` at concurrency
  `1`, manifest mode `closed`, and max concurrency `4`.
- The self-loop negative case exited `1` with empty stdout and the canonical
  error on stderr. All successful payload calls had empty stderr.
- Bats owner counts were: payload-only `12/12`, manifest validation `20/20`,
  cohorts `31/31`, cohort parity `4/4`, and Bash membership `8/8`.

## CI and compatibility proof

- The authoritative PoshQC result includes the existing epic contracts and
  all Codex hook contracts. Its fresh JUnit timestamp was
  `2026-08-11T15:30:45.3387674-04:00`.
- The full TypeScript suite includes the existing Claude publisher and pack
  suites. No suite or test failed.
- The focused G16 owner parsed the real root workflow and verified the single
  required, non-optional `parallel-completion-gate` reuse of
  `./.github/workflows/_poshqc.yml`, continuation limits, root refusal, and
  immutable completion-receipt behavior.
- `bash scripts/bash/shell-qc.sh check` used shfmt `3.12.0` and ShellCheck
  `0.11.0`; both checks completed without output.

## Runtime preservation and cleanup

- The fresh `.claude/` manifest retained `150/150` exact byte hashes from
  P0-T7. Its normalized manifest SHA-256 was
  `34dc80d7280c55bdd5ec16b6d2014ce6a0dbabcb01745e90952f6ea1ef188559`.
- Root `.claude/` status entries: `0`. Root `.claude/` diff entries: `0`.
- The two isolated destinations contained `252` files total. Those files and
  the two verified publisher summary artifacts were removed after validation.
  PowerShell-bearing destination files were removed in `29` receipt-isolated
  batches that each respected the three-production-file cap.
- The transient destination root is absent. The generated publisher artifact
  directory is absent. `.codex/state` is absent.
- `git diff --check` exited `0`. It emitted only the existing non-failing
  `testResults.xml` CRLF-to-LF warning.

P5_T12_RESULT: PASS
PUBLISHER_PATH_HASH_PARITY: 126/126
ROOT_BUNDLE_PARITY: 36/36
REGISTRATION_EXISTENCE: 28/28 root; 28/28 bundle
CI_CONTRACTS: 539/539; completion owner 8/8
CLAUDE_MANIFEST: 150/150 unchanged
