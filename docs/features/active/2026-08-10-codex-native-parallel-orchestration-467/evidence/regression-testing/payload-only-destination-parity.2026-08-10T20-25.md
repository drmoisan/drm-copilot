# Payload-Only Destination Parity Evidence

- Timestamp: `2026-08-11T14:53:34.384-04:00`
- Plan task: `[P5-T9]`
- Result: `PASS`
- EXIT_CODE: `0`

## Isolated publication

The Python and TypeScript public publishers wrote to separate repository-contained integration destinations under the feature evidence tree. Each destination was seeded with the same destination-owned route before publication. The temporary destinations were removed after validation.

| Publisher | Invocation | Exit | Elapsed | Published paths |
| --- | --- | ---: | ---: | ---: |
| Python | `poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <python-destination> --packs core` | 0 | 901 ms | 126 |
| TypeScript | `node -` using the repository TypeScript transpile hook, `RealPushDownFileSystem`, the repository source root, the Codex resource-bundle root, `packs=["core"]`, and `<typescript-destination>` | 0 | 331 ms | 126 |

The sorted destination manifests matched for `126/126` relative paths and `126/126` SHA-256 values. The normalized manifest SHA-256 was `5f65286c00850dd0d7081aa76d59662ca997505dfc2c54e684ee9c50eca619fd`.

Both destinations retained the destination-owned routing entry (`2/2`), carried the exact approved portable Claude set (`14/14`), carried the generic `config/blast-radius.json` (`2/2`), and contained zero unrelated `.claude/**` paths.

## Direct payload-only execution

Each destination was validated independently through `C:\Program Files\Git\bin\bash.exe`. Every payload subprocess used:

```text
env -i PATH=<repository>/tests/fixtures/parallel_payload_path HOME=<current-home> /usr/bin/bash <destination-entrypoint> ...
```

The restricted child path exposes only the checked-in `sort`, `cut`, `cat`, and `dirname` shims. `python`, `python3`, and `poetry` were each unresolved before payload execution.

| Destination | Exit | Elapsed | Assertions | Stdout contract | Stderr |
| --- | ---: | ---: | ---: | --- | --- |
| Python | 0 | 7,607 ms | 21/21 | Exact expected values below | Empty |
| TypeScript | 0 | 7,502 ms | 21/21 | Byte-identical semantic values below | Empty |

Verified output values for both destinations:

- Cohorts: `[[2],[1,3]]`.
- Self-loop conflict: exit `1`; `Self-loop edge on item key 1; the conflict relation is defined over distinct items, so an item cannot conflict with itself.`
- Ascending batches with `max_concurrency=2`: `[[1,2],[3,5]]`.
- Ascending batches with `max_concurrency=1`: `[[1],[2],[3]]`.
- Manifest validation: exit `0`, stdout `0` bytes, stderr `0` bytes.
- Manifest mode: `closed`.
- Manifest max concurrency: `4`.
- Approved portable Claude membership: `14/14`.
- Generic blast-radius configuration: source/destination SHA-256 equality and no repository-only path references.

## Established Bats owners

The supported Bats `1.13.0` wrapper was invoked through Git Bash:

```text
<bats-package>/bin/bats --tap \
  tests/shell/parallel_payload_only.bats \
  tests/shell/parallel_manifest_validate.bats \
  tests/shell/parallel_cohorts.bats \
  tests/shell/parallel_cohorts_parity.bats \
  tests/shell/parallel_bash_manifest_membership.bats
```

Result: exit `0`, elapsed `60,120 ms`, TAP `1..75`, `75/75` passed, stderr empty.

| Owner | Passed |
| --- | ---: |
| `parallel_payload_only.bats` | 12/12 |
| `parallel_manifest_validate.bats` | 20/20 |
| `parallel_cohorts.bats` | 31/31 |
| `parallel_cohorts_parity.bats` | 4/4 |
| `parallel_bash_manifest_membership.bats` | 8/8 |

The cohort-parity owner uses `python3` only in its test harness to decode the checked-in JSON corpus. Payload portability is independently enforced by the direct destination contracts and `parallel_payload_only.bats`, which execute the published entrypoints with the interpreter-free child path.

An initial invocation of the package-internal `libexec/bats-core/bats` file exited `1` before test discovery because its private support path was unresolved. No test ran in that invocation. The supported package wrapper at `bin/bats` produced the authoritative `75/75` result above.

## Terminal checks

- Temporary integration destinations: removed after validating `253` generated files.
- Python publisher summary outside the canonical evidence tree: verified as belonging only to this P5-T9 run, then removed.
- `.claude/**`: `150/150` tracked paths, zero status entries, zero diff entries.
- `.codex/state`: absent.
- `git diff --check`: exit `0`; the existing `testResults.xml` CRLF-to-LF warning remains non-failing.
- P5-T10 work: not started.

P5_T9_RESULT: PASS
