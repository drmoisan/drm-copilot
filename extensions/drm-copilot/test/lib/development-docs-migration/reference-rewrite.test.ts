import { describe, expect, it } from "@jest/globals";

import {
  buildRewritePrefixes,
  isInsideProtectedLiteral,
  isTokenBoundary,
  recomputeRelativeLinks,
  rewritePrefixes,
  type LinkContext,
} from "../../../src/lib/development-docs-migration/reference-rewrite";

const PREFIXES = buildRewritePrefixes(".dev/discovery/templates");
const RENAMES = [
  { area: "active", from: "2026-10-30-foo-1016", to: "1016-foo" },
];

/** Map pre-move paths: the active area moves and one folder is renamed. */
function mapPath(path: string): string {
  return path
    .replace(
      /^docs\/features\/active\/2026-10-30-foo-1016/,
      ".dev/active/1016-foo",
    )
    .replace(/^docs\/features\//, ".dev/");
}

const EXISTING = new Set([
  ".github/instructions/a.md",
  "docs/features/active/2026-10-30-foo-1016",
  "docs/features/active/2026-10-30-foo-1016/spec.md",
  "docs/features/active/2026-10-30-foo-1016/plan.md",
  "docs/features/potential/x.md",
  "README.md",
]);

function context(sourceOld: string): LinkContext {
  return {
    sourceOld,
    sourceNew: mapPath(sourceOld),
    mapPath,
    exists: (path) => EXISTING.has(path),
  };
}

describe("buildRewritePrefixes", () => {
  it("orders prefixes longest first and substitutes the OQ-1 target", () => {
    // Act
    const lengths = PREFIXES.map((prefix) => prefix.from.length);

    // Assert
    expect(lengths).toEqual([...lengths].sort((a, b) => b - a));
    expect(
      PREFIXES.findIndex((p) => p.from === "docs/features/research/"),
    ).toBeLessThan(PREFIXES.findIndex((p) => p.from === "docs/features/"));
    expect(PREFIXES).toContainEqual({
      from: "docs/discovery/templates/",
      to: ".dev/discovery/templates/",
    });
    expect(PREFIXES[PREFIXES.length - 1]).toEqual({
      from: "docs/features/",
      to: ".dev/",
    });
  });
});

describe("rewritePrefixes", () => {
  it.each([
    ["see docs/features/active/x.md", "see .dev/active/x.md"],
    ["docs/features/backlog.md", ".dev/backlog.md"],
    ["(docs/research/r.md)", "(.dev/research/r.md)"],
    ["`docs/engineering/x.md`", "`.dev/engineering/x.md`"],
    ["/docs/features/epics/e", "/.dev/epics/e"],
    ["./docs/features/parallel/p", "./.dev/parallel/p"],
    ["docs/discovery/templates/v2/a", ".dev/discovery/templates/v2/a"],
    ["docs/features/unknown/x", ".dev/unknown/x"],
  ])("rewrites %s on a token boundary", (input, expected) => {
    // Act
    const result = rewritePrefixes(input, PREFIXES);

    // Assert
    expect(result.text).toBe(expected);
    expect(result.occurrences).toBe(1);
  });

  it.each([
    "xdocs/features/a",
    "1docs/features/a",
    ".docs/features/a",
    "_docs/features/a",
    "-docs/features/a",
    "a/docs/features/a",
    "../docs/features/a",
    "docs/other/a",
  ])("does not rewrite %s", (input) => {
    // Act
    const result = rewritePrefixes(input, PREFIXES);

    // Assert
    expect(result.text).toBe(input);
    expect(result.occurrences).toBe(0);
  });

  it("leaves Write( and Edit( literals untouched and counts them as protected", () => {
    // Arrange
    const input =
      "Write(docs/features/**) and docs/features/a\nEdit(/docs/features/x)";

    // Act
    const result = rewritePrefixes(input, PREFIXES);

    // Assert
    expect(result.text).toBe(
      "Write(docs/features/**) and .dev/a\nEdit(/docs/features/x)",
    );
    expect(result.protectedOccurrences).toBe(2);
    expect(result.occurrences).toBe(1);
  });

  it("rewrites renamed basenames only after a .dev/<area>/ prefix", () => {
    // Arrange
    const input = [
      "docs/features/active/2026-10-30-foo-1016/spec.md",
      ".dev/active/2026-10-30-foo-1016",
      "other/active/2026-10-30-foo-1016",
      ".dev/active/2026-10-30-foo-1016-b",
      ".dev/completed/2026-10-30-foo-1016",
    ].join("\n");

    // Act
    const result = rewritePrefixes(input, PREFIXES, RENAMES);

    // Assert
    expect(result.text.split("\n")).toEqual([
      ".dev/active/1016-foo/spec.md",
      ".dev/active/1016-foo",
      "other/active/2026-10-30-foo-1016",
      ".dev/active/2026-10-30-foo-1016-b",
      ".dev/completed/2026-10-30-foo-1016",
    ]);
    expect(result.renamedBasenames).toBe(2);
  });

  it("reports backslash-separated occurrences without rewriting them", () => {
    // Arrange
    const input = "path docs\\features\\active\\x and xdocs\\research\\y";

    // Act
    const result = rewritePrefixes(input, PREFIXES);

    // Assert
    expect(result.text).toBe(input);
    expect(result.backslashOccurrences).toBe(1);
  });

  it("is a no-op on its own output", () => {
    // Arrange
    const first = rewritePrefixes(
      "docs/features/active/2026-10-30-foo-1016 and docs/research/a and Write(docs/features/**)",
      PREFIXES,
      RENAMES,
    );

    // Act
    const second = rewritePrefixes(first.text, PREFIXES, RENAMES);

    // Assert
    expect(second.text).toBe(first.text);
    expect(second.occurrences).toBe(0);
    expect(second.renamedBasenames).toBe(0);
  });
});

describe("isTokenBoundary and isInsideProtectedLiteral", () => {
  it("accepts the start of text and rejects a path character before the prefix", () => {
    expect(isTokenBoundary("docs/x", 0)).toBe(true);
    expect(isTokenBoundary("a docs/x", 2)).toBe(true);
    expect(isTokenBoundary("adocs/x", 1)).toBe(false);
  });

  it("detects an open permission literal on the same line only", () => {
    expect(isInsideProtectedLiteral("Edit(docs/x", 5)).toBe(true);
    expect(isInsideProtectedLiteral("Write(a) docs/x", 9)).toBe(false);
    expect(isInsideProtectedLiteral("Write(\ndocs/x", 7)).toBe(false);
  });
});

describe("recomputeRelativeLinks", () => {
  it.each([
    [
      "docs/features/potential/x.md",
      "../../../.github/instructions/a.md",
      "../../.github/instructions/a.md",
    ],
    [
      "docs/features/active/2026-10-30-foo-1016/spec.md",
      "../../../../.github/instructions/a.md",
      "../../../.github/instructions/a.md",
    ],
    [
      "docs/features/active/2026-10-30-foo-1016/v1/plan.md",
      "../../../../../.github/instructions/a.md",
      "../../../../.github/instructions/a.md",
    ],
    [
      "docs/features/active/2026-10-30-foo-1016/audit-1/review.md",
      "../../../../../.github/instructions/a.md",
      "../../../../.github/instructions/a.md",
    ],
  ])(
    "recomputes a link from %s at its new depth",
    (source, target, expected) => {
      // Act
      const result = recomputeRelativeLinks(`[a](${target})`, context(source));

      // Assert
      expect(result.text).toBe(`[a](${expected})`);
      expect(result.recomputed).toBe(1);
      expect(result.broken).toEqual([]);
    },
  );

  it("recomputes a link from an unmoved file into a moved, renamed tree and keeps the fragment", () => {
    // Act
    const result = recomputeRelativeLinks(
      '[s](docs/features/active/2026-10-30-foo-1016/spec.md#scope "Spec")',
      context("README.md"),
    );

    // Assert
    expect(result.text).toBe('[s](.dev/active/1016-foo/spec.md#scope "Spec")');
  });

  it("keeps a sibling link inside a moved folder unchanged", () => {
    // Act
    const result = recomputeRelativeLinks(
      "[p](./plan.md) [d](./)",
      context("docs/features/active/2026-10-30-foo-1016/spec.md"),
    );

    // Assert
    expect(result.text).toBe("[p](./plan.md) [d](./)");
    expect(result.recomputed).toBe(0);
  });

  it("leaves scheme, fragment-only and root-relative links unchanged", () => {
    // Arrange
    const input =
      "[u](https://example.com/docs/features/x) [f](#top) [r](/docs/features/a.md) [m](mailto:a@b.c)";

    // Act
    const result = recomputeRelativeLinks(input, context("README.md"));

    // Assert
    expect(result.text).toBe(input);
    expect(result.broken).toEqual([]);
  });

  it("reports broken links and links that leave the repository, leaving them unchanged", () => {
    // Arrange
    const input =
      "[b](docs/features/missing.md) [o](../outside.md) [e](%E0%A4%A)";

    // Act
    const result = recomputeRelativeLinks(input, context("README.md"));

    // Assert
    expect(result.text).toBe(input);
    expect(result.broken).toEqual([
      "README.md: docs/features/missing.md",
      "README.md: ../outside.md",
      "README.md: %E0%A4%A",
    ]);
  });

  it("keeps percent-encoded spaces and a trailing slash in a recomputed link", () => {
    // Arrange
    const ctx: LinkContext = {
      sourceOld: "docs/features/potential/x.md",
      sourceNew: ".dev/potential/x.md",
      mapPath: (path) => path,
      exists: (path) =>
        path === "docs/engineering/My Book.md" || path === "docs/engineering",
    };

    // Act
    const result = recomputeRelativeLinks(
      "[b](../../engineering/My%20Book.md) [d](../../engineering/)",
      ctx,
    );

    // Assert
    expect(result.text).toBe(
      "[b](../../docs/engineering/My%20Book.md) [d](../../docs/engineering/)",
    );
  });

  it("is a no-op when re-run against the post-move tree", () => {
    // Arrange
    const first = recomputeRelativeLinks(
      "[a](../../../../.github/instructions/a.md)",
      context("docs/features/active/2026-10-30-foo-1016/spec.md"),
    );
    const after: LinkContext = {
      sourceOld: ".dev/active/1016-foo/spec.md",
      sourceNew: ".dev/active/1016-foo/spec.md",
      mapPath: (path) => path,
      exists: (path) => path === ".github/instructions/a.md",
    };

    // Act
    const second = recomputeRelativeLinks(first.text, after);

    // Assert
    expect(second.text).toBe(first.text);
    expect(second.recomputed).toBe(0);
  });
});
