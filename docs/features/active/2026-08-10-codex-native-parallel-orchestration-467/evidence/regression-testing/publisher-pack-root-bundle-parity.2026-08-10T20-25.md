# Publisher, Pack, Root, and Bundle Parity Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T8]`

Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'`

EXIT_CODE: `0`

Output Summary: 58 selected Python publisher, pack, parity, and resource tests passed; 3,785 tests were deselected in 1.60 seconds.

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`

EXIT_CODE: `0`

Output Summary: The full extension unit suite passed: 193 suites, 2,665 tests, and 0 snapshots in 7.3 seconds.

Command: `@'<read-only Python and transpiled-TypeScript in-memory publisher comparator>'@ | poetry run python -`

EXIT_CODE: `0`

Output Summary: Python and TypeScript emitted identical sorted 19-path and 19-hash manifests. The normalized manifest SHA-256 was `7e5c4867878d5f7fb4524ed2f2ca5121ea2db519ead26e4b99948e699491995b`.

Command: `@'<read-only root/resource SHA and parsed-registration comparator>'@ | poetry run python -`

EXIT_CODE: `0`

Output Summary: All 36 root/resource pairs and all 28 registered targets at both surfaces exist and are byte-identical. The pair-manifest SHA-256 was `5c8d751c4f2e490a032cd52e5992d65461249055fc93290f5e399ef6ebf0e13f`; the registration-manifest SHA-256 was `099bc154156a7b1b1ac88d12c73252b764cdc73a6a165b2457dbd52dd76b6462`.

Command: `@'<read-only core and selected-language-pack closure comparator>'@ | poetry run python -`

EXIT_CODE: `0`

Output Summary: Core closure is 48/48 with 127 members, 0 internal duplicates, 0 cross-language closure duplicates, exact 14/14 approved Claude library membership, 0 unrelated Claude paths, and complete inheritance by 5/5 selected packs. Core SHA-256 was `2009cfc43103347db57e1418e80fa4b0057e4026674aa76784e807174d64b8cc`.

Command: `@'<read-only normalized Python and TypeScript routing-merge comparator>'@ | poetry run python -`

EXIT_CODE: `0`

Output Summary: Destination retention, equal-entry byte skip, and unequal-collision behavior were identical in 3/3 cells. The normalized matrix SHA-256 was `25a9877c0a3580127e47c23ef1a78394bde15fc48b7ef4092967ffa76d9e6da8`; both runtimes emitted `ROUTING_MERGE_SUBSTANTIVE_COLLISION` with `routes.alpha, routes.zeta` in that order.

## Verified Contract

- Python-versus-TypeScript publisher path equality is 19/19 and hash equality is
  19/19. Output ordering is ascending and the unrelated Claude rule fixture is
  excluded.
- Root/resource byte parity is 36/36. Missing roots, missing resource targets,
  and SHA mismatches are all 0.
- Parsed config registrations resolve to 28/28 existing root targets and 28/28
  existing resource targets. Every registered pair is byte-identical.
- Codex core contains the exact 48-path dependency closure. Each of Python,
  PowerShell, TypeScript, C# modern, and C# legacy selections inherits core;
  duplicate closure membership is 0.
- Codex core selects exactly the approved fourteen `.claude/lib/**` paths plus
  generic `config/blast-radius.json`; unrelated `.claude/**` membership is 0.
- Equal destination routing entries retain their exact bytes. Destination-owned
  entries survive additive source merges. Unequal collisions reject before a
  destination write with the same stable reason, details, and ordering in both
  runtimes.
- `.claude` contains 150 tracked and 150 current files, with diff and status
  counts of 0. `.codex/state` is absent.
- `git diff --check` exits 0. The existing `testResults.xml` line-ending warning
  is non-failing.
- `[P5-T9]` was not started.
