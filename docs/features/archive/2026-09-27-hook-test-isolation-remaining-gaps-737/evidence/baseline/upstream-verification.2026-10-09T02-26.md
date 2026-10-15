# P0-T2 Upstream verification

Timestamp: 2026-10-09T02-26
Command: gh pr list --base epic/enforcement-hook-precision-integration --state merged --limit 300 --json number,title,headRefName,mergeCommit,mergedAt; git merge-base --is-ancestor <mergeCommit.oid> origin/epic/enforcement-hook-precision-integration (once per selected pull request)
EXIT_CODE: 0
Output Summary:
The merged-PR list into the integration branch holds six pull requests (#853, #854, #855, #856, #857, #858). Whole-token matching of 736, 732, and 850 against title and headRefName yields one candidate each; each merge commit is an ancestor of the integration ref (git merge-base --is-ancestor exit 0 for all three).

CANDIDATES: 736 | 853
CANDIDATES: 732 | 858
CANDIDATES: 850 | 857
UPSTREAM: 736 | PR=853 | MERGE-COMMIT=bb3c988442c90ccb4c57c052f4d08fe6a3a231fe | ANCESTOR=True
UPSTREAM: 732 | PR=858 | MERGE-COMMIT=73201b5fe7a2106d07b3e0a4f55a72ede6a1965c | ANCESTOR=True
UPSTREAM: 850 | PR=857 | MERGE-COMMIT=f8f7d0ab1b0ed927cccfedd25608a48d28083c57 | ANCESTOR=True
UPSTREAM-VERIFIED: 3

Context: the integration tip also contains #854 (565), #855 (824), and #856 (787), whose suites the discovery guard enumerates at run time (PI-5).
