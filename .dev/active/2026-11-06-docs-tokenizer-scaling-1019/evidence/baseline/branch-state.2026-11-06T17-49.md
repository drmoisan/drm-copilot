# Branch State - Issue 1019

Timestamp: 2026-11-06T17-49
Command: sh SCRATCH/issue-1019-p0-state.sh (git fetch origin epic/documentation-estate-tooling-integration feature/docs-enforcement-and-ci-1034-r2; git merge-base origin/epic/documentation-estate-tooling-integration HEAD; git log -n 1 --format=%H --grep=stop.passing.the.whole.source origin/feature/docs-enforcement-and-ci-1034-r2; git status --porcelain; sha256sum of the module copies and blobs)
EXIT_CODE: 0
Output Summary: Fetch succeeded and tracking refs equal git ls-remote. The unfixed copy equals MODULE at HEAD and was reused without rewriting. The candidate copy was created and equals the CANDIDATE blob. git status --porcelain was empty.

## Branch and Refs

| Item | Value |
| --- | --- |
| Branch | `bug/docs-tokenizer-scaling-1019` |
| `HEAD` | `6e33db871c185b2bf92e96aaf262eb6db6516db7` |
| `MERGE_BASE` | `c4a2398aa93c721e06f6878851526d4338ec98c7` |
| `origin/epic/documentation-estate-tooling-integration` | `eca4fc203b0c031d046254fadeab3554791f77ca` |
| `origin/feature/docs-enforcement-and-ci-1034-r2` | `fd6d789308e049ae16db55c84232080523460b3b` |
| `CANDIDATE` | `1332ba34f3fee7a6f1ca14534ab8b970dffce559` |
| `CANDIDATE` subject | `fix(docs): stop passing the whole source to .NET calls in the Python tokenizer` |

The candidate search on the 1034 branch returned exactly one commit.

## git status --porcelain

Empty output before any Phase 0 artifact was written.

## Scratch Copies

- `SCRATCH/unfixed/.claude/lib/`: already present, reused, not rewritten. `diff -r` against the worktree `.claude/lib` exited 0 with no differences (172 files on each side).
- `SCRATCH/candidate-tree/.claude/lib/`: created from the worktree `.claude/lib`, with `docs/DocsPythonTokens.psm1` taken from the `CANDIDATE` blob. `diff -rq` against the worktree reports that one file as the only difference.

## SHA-256 Hashes

| Object | SHA-256 |
| --- | --- |
| `MODULE` blob at `HEAD` | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` |
| `MODULE` in the worktree | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` |
| `SCRATCH/unfixed` module copy | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` |
| `MODULE` blob at `CANDIDATE` | `7fcca693045a6bea1a6c7f2145314a3e512389b24e04fe79386ad77bf08374b9` |
| `SCRATCH/candidate-tree` module copy | `7fcca693045a6bea1a6c7f2145314a3e512389b24e04fe79386ad77bf08374b9` |
| `SUITE` blob at `HEAD` | `e65dbcba81983aa29e0b04d5e421ba0cff84ba288a8a48954c394cdbbc758bd1` |
| `SCRATCH/unfixed` suite copy | `e65dbcba81983aa29e0b04d5e421ba0cff84ba288a8a48954c394cdbbc758bd1` |

Result: the unfixed copy equals `MODULE` at `HEAD`, and the candidate copy equals the `CANDIDATE` blob.
