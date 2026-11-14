Timestamp: 2026-11-05T05-47
Command: Compare every physical-audit mismatch after CRLF-to-LF normalization and compare complete Git binary diffs.
EXIT_CODE: 0
Output Summary:

All 36 mismatches contain identical content after CRLF-to-LF normalization: 14 existing feature evidence files and 22 existing bundled text files. The clean checkout follows .gitattributes: * text=auto eol=lf. No production or test content differs. All 35576 tracked paths are present. Both complete current Git binary diffs have SHA256 6a67724676cfefe4d7c221e826925c468c6ace59a9e0b69212f13d8a07e0cffd, anchored to HEAD 726184cc65c685d17876be32de2f776441e914f5. The clean projection has 507 test files and the configured coverage resolver selected 271 production files. No test or production source was omitted.

The ignored pre-existing host MCP payload retains SHA256 97643f5bfb6ccc57f69ed46a06a490e3ea2cf5a85ee5a8fa8fb920991bba8a66; it is absent from the clean CI-equivalent checkout because it is untracked/ignored, without deleting or modifying the original. Raw details: SCRATCH/issue-1082-projection-line-ending-audit.json. Initial Windows checkout long-path errors were corrected using core.longpaths=true only in the disposable clone. No host Git configuration was changed.
