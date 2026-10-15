# RT-3 CI Artifact Head Qualification

Timestamp: 2026-10-11T01-42
Task: [P3-T1]
Command: git merge-base --is-ancestor e0cbb9bc9 d1211a7ae; git merge-base --is-ancestor d1211a7ae HEAD; git diff --quiet e0cbb9bc9 d1211a7ae -- . ':(exclude)docs'; git diff --quiet d1211a7ae HEAD -- . ':(exclude)docs'
EXIT_CODE: 0

| Check | Exit code |
|---|---|
| `git merge-base --is-ancestor e0cbb9bc9 d1211a7ae` | 0 |
| `git merge-base --is-ancestor d1211a7ae HEAD` | 0 |
| `git diff --quiet e0cbb9bc9 d1211a7ae -- . ':(exclude)docs'` | 0 |
| `git diff --quiet d1211a7ae HEAD -- . ':(exclude)docs'` | 0 |

SHA comparison:

- `HeadSha:` in `evidence/other/rt3-ci-run.md`: `d1211a7aebefe9648e16542919027587544ee153`
- Full `d1211a7ae` SHA from [P0-T5] (`r0-head.md`): `d1211a7aebefe9648e16542919027587544ee153`
- Match: yes

Reasoning: the reviewer accepts a CI artifact for `e0cbb9bc9` or later. `d1211a7ae` descends from `e0cbb9bc9` and differs from it only under `docs/`, and HEAD (`308fca553e5a6772423b05c6ee51b0de593b4406`) descends from `d1211a7ae` and differs from it only under `docs/`. The shell content measured by CI run 38112992719 is therefore identical to HEAD's.

Output Summary: All four exit codes 0; CI HeadSha equals the full d1211a7ae SHA. Head qualification passes.
