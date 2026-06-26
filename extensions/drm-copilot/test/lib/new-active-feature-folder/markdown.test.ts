/**
 * Unit tests for `src/lib/new-active-feature-folder/markdown.ts`.
 *
 * Mirrors `tests/scripts/dev_tools/test_new_active_feature_folder_markdown_escape.py`
 * and the markdown scenarios in the active-folder part tests. Hermetic; AAA;
 * one behavior per test.
 */

import { describe, expect, it } from "@jest/globals";

import {
  formatChecklist,
  getSection,
  prependToSectionBody,
  setHeaderPlaceholder,
  setSection,
  updateSectionBody,
  upsertWorkModeMarker,
} from "../../../src/lib/new-active-feature-folder/markdown";

describe("setSection", () => {
  it("preserves backslashes in the replacement body and a following section", () => {
    // Arrange: a Windows-style path body that must not be treated as a regex escape.
    const content = "## Overview\nold\n\n## Next\nkeep\n";
    const body = "Outlook object path: C:\\Outlook\\Objects";

    // Act
    const updated = setSection(content, "Overview", body);

    // Assert
    expect(updated).toContain(body);
    expect(updated).toContain("## Next\nkeep");
  });

  it("returns content unchanged for an empty body", () => {
    // Arrange
    const content = "## Overview\nold\n";

    // Act
    const updated = setSection(content, "Overview", "   ");

    // Assert
    expect(updated).toBe(content);
  });

  it("replaces an existing section body", () => {
    // Arrange
    const content = "## Overview\nold body\n\n## Next\nkeep\n";

    // Act
    const updated = setSection(content, "Overview", "new body");

    // Assert
    expect(updated).toContain("## Overview\nnew body\n\n");
    expect(updated).toContain("## Next\nkeep");
    expect(updated).not.toContain("old body");
  });

  it("appends a new section when the heading is absent", () => {
    // Arrange
    const content = "## Overview\nbody\n";

    // Act
    const updated = setSection(content, "Behavior", "added");

    // Assert
    expect(updated).toContain("## Behavior\nadded\n");
    expect(updated.indexOf("## Behavior")).toBeGreaterThan(
      updated.indexOf("## Overview"),
    );
  });
});

describe("updateSectionBody", () => {
  it("preserves backslashes in updater output and reports changed", () => {
    // Arrange
    const content = "## Overview\nold\n\n## Next\nkeep\n";
    const expectedBody = "Updated path: C:\\Outlook\\Objects";

    // Act
    const [updated, changed] = updateSectionBody(
      content,
      "Overview",
      () => expectedBody,
    );

    // Assert
    expect(changed).toBe(true);
    expect(updated).toContain(expectedBody);
    expect(updated).toContain("## Next\nkeep");
  });

  it("returns [content, false] when the section is absent", () => {
    // Arrange
    const content = "## Overview\nbody\n";

    // Act
    const [updated, changed] = updateSectionBody(content, "Missing", () => "x");

    // Assert
    expect(changed).toBe(false);
    expect(updated).toBe(content);
  });

  it("returns [content, false] when the updater leaves the body unchanged", () => {
    // Arrange
    const content = "## Overview\nbody\n";

    // Act
    const [updated, changed] = updateSectionBody(
      content,
      "Overview",
      (body) => body,
    );

    // Assert
    expect(changed).toBe(false);
    expect(updated).toBe(content);
  });
});

describe("formatChecklist", () => {
  it("keeps existing checkbox and bullet lines and prefixes plain lines, skipping blanks", () => {
    // Arrange
    const text = "- [ ] existing\n- bullet\nplain\n\n  spaced plain  ";

    // Act
    const result = formatChecklist(text);

    // Assert
    expect(result).toBe(
      "- [ ] existing\n- bullet\n- [ ] plain\n- [ ] spaced plain",
    );
  });
});

describe("getSection", () => {
  it("extracts a body, stops at the next heading, and returns '' for a missing heading", () => {
    // Arrange
    const content = "## A\nalpha line\n\n## B\nbeta\n";

    // Act / Assert
    expect(getSection(content, "A")).toBe("alpha line");
    expect(getSection(content, "B")).toBe("beta");
    expect(getSection(content, "Missing")).toBe("");
  });
});

describe("upsertWorkModeMarker", () => {
  it("inserts the marker above the first heading", () => {
    // Arrange
    const content = "# Title\n\n## Problem\nbody\n";

    // Act
    const result = upsertWorkModeMarker(content, "minor-audit");

    // Assert
    expect(result).toContain("- Work Mode: minor-audit\n\n## Problem");
  });

  it("replaces an existing marker", () => {
    // Arrange
    const content = "# Title\n- Work Mode: full\n\n## Problem\nbody\n";

    // Act
    const result = upsertWorkModeMarker(content, "full-feature");

    // Assert
    expect(result).toContain("- Work Mode: full-feature");
    expect(result).not.toContain("- Work Mode: full\n");
  });

  it("appends the marker when no heading exists", () => {
    // Arrange
    const content = "# Title\nbody";

    // Act
    const result = upsertWorkModeMarker(content, "full-bug");

    // Assert
    expect(result).toBe("# Title\nbody\n\n- Work Mode: full-bug");
  });
});

describe("prependToSectionBody", () => {
  it("returns the body unchanged for an empty prefix", () => {
    // Arrange / Act / Assert
    expect(prependToSectionBody("body", "   ")).toBe("body");
  });

  it("returns prefix + newline when the body is empty", () => {
    // Arrange / Act / Assert
    expect(prependToSectionBody("   ", "prefix")).toBe("prefix\n");
  });

  it("joins prefix and body when both are populated", () => {
    // Arrange / Act / Assert
    expect(prependToSectionBody("body", "prefix")).toBe("prefix\n\nbody\n");
  });
});

describe("setHeaderPlaceholder", () => {
  it("substitutes placeholders and rewrites both bold and plain metadata lines", () => {
    // Arrange: a header containing placeholder tokens and metadata lines.
    const content = [
      "# <feature-name>",
      "- **Issue:** #<id>",
      "- Owner: name",
      "- **Last Updated:** <yyyy-MM-ddTHH-mm>",
      "- Status: old",
      "- **Version:** 0.0",
      "",
      "## Overview",
      "body",
    ].join("\n");

    // Act
    const result = setHeaderPlaceholder(
      content,
      "notes-feature",
      "#123",
      "octocat",
      "2026-03-14T15-48",
      "Draft",
      "none",
      "0.1",
    );

    // Assert
    expect(result).toContain("# notes-feature");
    expect(result).toContain("- **Issue:** #123");
    expect(result).toContain("- Owner: octocat");
    expect(result).toContain("- **Last Updated:** 2026-03-14T15-48");
    expect(result).toContain("- Status: Draft");
    expect(result).toContain("- **Version:** 0.1");
  });

  it("prepends a - Issue: line when no Issue metadata line is present", () => {
    // Arrange
    const content = "# <feature-name>\n\n## Overview\nbody\n";

    // Act
    const result = setHeaderPlaceholder(
      content,
      "notes-feature",
      "#7",
      "TBD",
      "2026-03-14T15-48",
    );

    // Assert
    expect(result.startsWith("- Issue: #7\n")).toBe(true);
  });

  it("does not prepend a - Issue: line when one already exists", () => {
    // Arrange
    const content = "- Issue: #<id>\n# <feature-name>\n\n## Overview\nbody\n";

    // Act
    const result = setHeaderPlaceholder(
      content,
      "notes-feature",
      "#9",
      "TBD",
      "2026-03-14T15-48",
    );

    // Assert
    expect(result).toContain("- Issue: #9");
    expect(result.match(/- Issue:/g)?.length).toBe(1);
  });
});
