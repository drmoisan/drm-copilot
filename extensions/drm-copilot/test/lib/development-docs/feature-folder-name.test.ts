/**
 * Unit tests for the feature-folder name parser and formatter (issue #1035).
 * Cases are titled by spec ID (F-1 to F-6, N-1 to N-5).
 */
import {
  formatFeatureFolderName,
  parseFeatureFolderName,
  stripDateFirstPrefix,
} from "../../../src/lib/development-docs/feature-folder-name";

describe("parseFeatureFolderName", () => {
  it("F-1 parses a date-first name with an issue", () => {
    expect(parseFeatureFolderName("2026-10-30-foo-bar-1016")).toEqual({
      format: "date-first",
      date: "2026-10-30",
      feature: "foo-bar",
      issueNumber: 1016,
    });
  });

  it("F-2 parses a date-first name without an issue and never reads the year as the issue", () => {
    expect(parseFeatureFolderName("2026-10-30-foo-bar")).toEqual({
      format: "date-first",
      date: "2026-10-30",
      feature: "foo-bar",
      issueNumber: null,
    });
  });

  it("F-3 parses an issue-first name", () => {
    expect(parseFeatureFolderName("1016-foo-bar")).toEqual({
      format: "issue-first",
      issueNumber: 1016,
      feature: "foo-bar",
    });
  });

  it("F-4 parses a zero-padded issue-first name", () => {
    expect(parseFeatureFolderName("0042-foo-bar")).toEqual({
      format: "issue-first",
      issueNumber: 42,
      feature: "foo-bar",
    });
  });

  it("F-5 parses an other-shape name with a trailing issue", () => {
    expect(parseFeatureFolderName("subagentstop-envelope-core-897")).toEqual({
      format: "other",
      feature: "subagentstop-envelope-core",
      issueNumber: 897,
    });
  });

  it("F-6 parses an other-shape name without an issue", () => {
    expect(parseFeatureFolderName("notes-feature")).toEqual({
      format: "other",
      feature: "notes-feature",
      issueNumber: null,
    });
  });

  it("treats a 0000 prefix as other", () => {
    expect(parseFeatureFolderName("0000-foo").format).toBe("other");
  });
});

describe("formatFeatureFolderName", () => {
  it("N-1 formats a four-digit issue", () => {
    expect(formatFeatureFolderName(1016, "move-development-docs")).toBe(
      "1016-move-development-docs",
    );
  });

  it("N-2 pads a small issue to four digits", () => {
    expect(formatFeatureFolderName(42, "notes")).toBe("0042-notes");
  });

  it.each([
    ["zero", 0],
    ["negative", -3],
    ["non-integer", 4.5],
  ])("N-3 rejects a %s issue number", (_label, issue) => {
    expect(() => formatFeatureFolderName(issue, "notes")).toThrow(
      "must be a positive integer",
    );
  });

  it("N-4 rejects an issue above 9999", () => {
    expect(() => formatFeatureFolderName(10000, "notes")).toThrow(
      "must be at most 9999",
    );
  });

  it.each([
    ["empty", ""],
    ["pattern failure", "Bad Name"],
    ["partial date prefix", "10-30-foo"],
    ["date only", "2026-10-30-"],
  ])("N-5 rejects a feature that is %s", (_label, feature) => {
    expect(() => formatFeatureFolderName(7, feature)).toThrow(
      "Feature folder feature name is invalid",
    );
  });

  it("removes the date-first prefix and a trailing issue", () => {
    expect(formatFeatureFolderName(1016, "2026-10-30-foo-1016")).toBe(
      "1016-foo",
    );
  });

  it("keeps a trailing number that is not the issue", () => {
    expect(formatFeatureFolderName(5, "foo-12")).toBe("0005-foo-12");
  });

  it("keeps a feature that equals only the issue suffix", () => {
    expect(() => formatFeatureFolderName(5, "-5")).toThrow(
      "Feature folder feature name is invalid",
    );
  });
});

describe("stripDateFirstPrefix", () => {
  it("removes a leading date", () => {
    expect(stripDateFirstPrefix("2026-10-30-foo")).toBe("foo");
  });

  it("leaves a stem without a date unchanged", () => {
    expect(stripDateFirstPrefix("foo-2026-10-30")).toBe("foo-2026-10-30");
  });
});
