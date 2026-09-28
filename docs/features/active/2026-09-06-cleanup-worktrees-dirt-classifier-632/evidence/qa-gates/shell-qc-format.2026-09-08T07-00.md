# Final QC — shell format stage (shfmt write mode)

Timestamp: 2026-09-08T07-22

Task: [P8-T1] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum
bash scripts/bash/shell-qc.sh format
for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum
```

EXIT_CODE: 0

BeforeDigest: `c40cdd4347cb0d80c6a4513ed4578df3c5089366a52da8a8e1a123d277b75006`
AfterDigest: `c40cdd4347cb0d80c6a4513ed4578df3c5089366a52da8a8e1a123d277b75006`
DigestsEqual: yes

The digest differs from the [P0-T3] baseline value
`642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7` because
`scripts/bash/cleanup_worktrees_dirt_lib.sh` was modified by Phases 2, 3, and 4. That is the
expected difference. What this task asserts is the equality of the before and after digests
of THIS run, which shows the formatter rewrote nothing.

Output Summary: `bash scripts/bash/shell-qc.sh format` exited 0 and printed no output. The
tree digest over the three discovery roots is byte-identical before and after the run, so
the formatter rewrote no file and the loop does not restart. The digest equality is the
failable observation; `shfmt` in write mode prints nothing and exits 0 whether or not it
rewrote a file, so the exit code alone is identical on a clean run and on a repairing one.
