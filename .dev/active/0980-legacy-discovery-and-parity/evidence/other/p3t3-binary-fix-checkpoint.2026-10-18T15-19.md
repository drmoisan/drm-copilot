# P3-T3 provider prerequisite checkpoint

Timestamp: 2026-10-18T15-19

The two provider paths are frozen for the requested bounded fix commit. NativeDirectory.read and stage now add getattr(os, "O_BINARY", 0), preserving fallback behavior on platforms without the constant. Eight memory-only regressions assert descriptor flags and exact LF, CRLF, Ctrl-Z and mixed bytes.

The real Windows proof passed 17 checks in 0.077 seconds, including independent binary reads and SHA-256 comparison after exclusive creation and digest replacement, stale/collision preservation, and handle/lock/stage cleanup. The failed smoke and independent diagnosis remain retained.

The full current working-tree sequence passed format, lint, full types, architecture, 134 forward tests, 134 reversed tests, 385 contracts, and 12 native activation checks. That sequence binds four unstaged P3-T3 files and is not a standalone proof of the proposed two-source-file commit. Its provider subset contains 42 passing cases; raw coverage is 207/209 lines and 51/54 arcs, unchanged from the accepted provider baseline. The bounded extracted evidence names its complete source binding explicitly.

Leave the four changed task files and unrelated task evidence unstaged. The separate combined initialization physical-byte reproof and final task audit/acceptance remain pending. Earlier Windows exact-byte mutation/initialization claims remain qualified as historical. All repository edits are frozen at this checkpoint, with no running process.

Exact source/evidence hashes and exclusions are in p3t3-binary-fix-checkpoint.2026-10-18T15-19.json. The related executor disposition is owned by the coordinator/verifier.

The Windows text-mode behavior is documented in [Python os.open](https://docs.python.org/3.13/library/os.html#os.open) and [Microsoft translation constants](https://learn.microsoft.com/en-us/cpp/c-runtime-library/translation-mode-constants?view=msvc-170).
