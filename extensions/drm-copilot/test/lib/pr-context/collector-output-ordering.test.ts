// Holds the issue #796 ordering case for `collector-output.ts`
// (`renderVerificationEvidenceSection` sorts evidence rows by source path).
// It lives in its own file because `collector-output.test.ts` is near the
// 500-line limit.
import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import { renderVerificationEvidenceSection } from "../../../src/lib/pr-context/collector-output";

const ROOT = "/repo";

describe("renderVerificationEvidenceSection ordering", () => {
  it("issue #796 renders a U+E000 evidence source before a supplementary-character evidence source", () => {
    // Arrange: two parseable evidence files whose names differ only by a
    // supplementary character versus U+E000.
    const evidenceDir = "docs/features/active/f/evidence/qa-gates";
    const supplementaryPath = `${evidenceDir}/\u{1F600}.md`;
    const privateUsePath = `${evidenceDir}/\uE000.md`;
    const content =
      "Timestamp: 2026-01-01T00-00\nCommand: npm test\nEXIT_CODE: 0";
    const fs = new TreeFileSystem();
    fs.addFile(`${ROOT}/${supplementaryPath}`, content);
    fs.addFile(`${ROOT}/${privateUsePath}`, content);
    const excerpt = {
      feature: "f",
      excerpt: "",
      issueRefs: [],
      contextFiles: [supplementaryPath, privateUsePath],
      primaryIssueRef: null,
      readinessSignal: null,
    };

    // Act
    const section = renderVerificationEvidenceSection(fs, ROOT, [excerpt]);

    // Assert: code-point order places the U+E000 source first.
    const sourceLines = section
      .split("\n")
      .filter((line) => line.startsWith("  - Source: "));
    expect(sourceLines).toEqual([
      "  - Source: docs/features/active/f/evidence/qa-gates/\uE000.md",
      "  - Source: docs/features/active/f/evidence/qa-gates/\u{1F600}.md",
    ]);
  });
});
