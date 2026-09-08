# Baseline — shell format stage (shfmt write mode)

Timestamp: 2026-09-08T05-04

Task: [P0-T3] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum
bash scripts/bash/shell-qc.sh format
for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum
```

EXIT_CODE: 0

BeforeDigest: `642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7`
AfterDigest: `642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7`
DigestsEqual: yes

Output Summary: `bash scripts/bash/shell-qc.sh format` exited 0 and printed no output. The
tree digest over the three discovery roots (`tools/`, `scripts/`, `.claude/lib/bash/`) is
byte-identical before and after the run, so the formatter rewrote no file. The digest
equality is the failable observation recorded here; `shfmt` in write mode prints nothing and
exits 0 whether or not it rewrote a file, so the exit code alone cannot distinguish a clean
run from a repairing one.
