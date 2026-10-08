# Baseline CI main run (P0-T11)

Timestamp: 2026-10-07T00:00:00Z
Command: gh run list --workflow=ci.yml --branch main --event push --status success --limit 30 --json databaseId,headSha,conclusion
EXIT_CODE: 0
Output Summary: Selected run databaseId=37645267440, headSha=08ee030d9584bf15882fbb3654c8e38f34c7c359, conclusion=success. The headSha equals MERGE-BASE (git merge-base HEAD origin/main = 08ee030d9584bf15882fbb3654c8e38f34c7c359, since origin/main was merged into the item branch before execution). This is the pre-change coverage source for P0-T12 and P0-T13.
