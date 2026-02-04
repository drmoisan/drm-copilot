import { describe, expect, it } from "@jest/globals";

import { resolveExecutable } from "../../src/utilities/tool-preflight.ts";

describe("tool-preflight", () => {
  it("returns undefined when executable not in PATH", () => {
    // Mock an empty PATH to simulate executable not found
    const originalPath = process.env.PATH;
    try {
      process.env.PATH = "";
      const result = resolveExecutable("gh");
      expect(result).toBeUndefined();
    } finally {
      process.env.PATH = originalPath;
    }
  });
});
