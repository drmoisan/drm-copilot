/**
 * Feature-folder name parser and formatter (issue #1035; spec D-18, D-19).
 *
 * Purpose:
 *     Parse the three folder-name shapes (date-first, issue-first, other) and
 *     format the issue-first shape `<NNNN>-<feature>` for new folders.
 *
 * Side effects:
 *     None. Pure functions; this module imports no `vscode` API.
 */
import { NAME_PATTERN } from "../new-active-feature-folder/models";

/** A parsed feature-folder name. */
export type FeatureFolderName =
  | {
      format: "date-first";
      date: string;
      feature: string;
      issueNumber: number | null;
    }
  | { format: "issue-first"; issueNumber: number; feature: string }
  | { format: "other"; feature: string; issueNumber: number | null };

const DATE_FIRST = /^(\d{4}-\d{2}-\d{2})-(.+)$/;
const ISSUE_FIRST = /^(\d{4})-(.+)$/;
const TRAILING_ISSUE = /^(.+)-(\d+)$/;
const DATE_PREFIX = /^\d{4}-\d{2}-\d{2}-/;
const PARTIAL_DATE_PREFIX = /^\d{2}-\d{2}-/;

/** Largest issue number the four-digit prefix can carry (D-18). */
export const MAX_FEATURE_FOLDER_ISSUE = 9999;

/**
 * Split a trailing `-<digits>` issue suffix from a name.
 *
 * @param text Name or remainder.
 * @returns The feature and issue number, or the whole text with a null issue.
 */
function splitTrailingIssue(text: string): {
  feature: string;
  issueNumber: number | null;
} {
  const match = TRAILING_ISSUE.exec(text);
  if (match === null) {
    return { feature: text, issueNumber: null };
  }
  return { feature: String(match[1]), issueNumber: Number(match[2]) };
}

/**
 * Parse a feature-folder name (F-1 to F-6).
 *
 * @param name A folder basename.
 * @returns The parsed name.
 */
export function parseFeatureFolderName(name: string): FeatureFolderName {
  const dated = DATE_FIRST.exec(name);
  if (dated !== null) {
    const rest = splitTrailingIssue(String(dated[2]));
    return {
      format: "date-first",
      date: String(dated[1]),
      feature: rest.feature,
      issueNumber: rest.issueNumber,
    };
  }
  const issueFirst = ISSUE_FIRST.exec(name);
  if (issueFirst !== null && Number(issueFirst[1]) > 0) {
    return {
      format: "issue-first",
      issueNumber: Number(issueFirst[1]),
      feature: String(issueFirst[2]),
    };
  }
  const rest = splitTrailingIssue(name);
  return {
    format: "other",
    feature: rest.feature,
    issueNumber: rest.issueNumber,
  };
}

/**
 * Remove a leading `yyyy-MM-dd-` date from a potential stem.
 *
 * @param stem A potential file stem.
 * @returns The stem without its date prefix.
 */
export function stripDateFirstPrefix(stem: string): string {
  return stem.replace(DATE_PREFIX, "");
}

/**
 * Format the issue-first folder name `<NNNN>-<feature>` (N-1 to N-5).
 *
 * The feature has its date-first prefix removed and a trailing `-<issue>`
 * removed before validation.
 *
 * @param issueNumber Integer issue number from 1 to 9999.
 * @param feature Potential stem or feature name.
 * @returns The folder name.
 * @throws Error For an invalid issue number or feature.
 */
export function formatFeatureFolderName(
  issueNumber: number,
  feature: string,
): string {
  if (!Number.isInteger(issueNumber) || issueNumber <= 0) {
    throw new Error(
      `Feature folder issue number must be a positive integer: ${String(issueNumber)}`,
    );
  }
  if (issueNumber > MAX_FEATURE_FOLDER_ISSUE) {
    throw new Error(
      `Feature folder issue number must be at most ${String(MAX_FEATURE_FOLDER_ISSUE)}: ${String(issueNumber)}`,
    );
  }
  let stem = stripDateFirstPrefix(feature);
  const issueSuffix = `-${String(issueNumber)}`;
  if (stem.endsWith(issueSuffix) && stem.length > issueSuffix.length) {
    stem = stem.slice(0, -issueSuffix.length);
  }
  if (
    stem === "" ||
    !NAME_PATTERN.test(stem) ||
    PARTIAL_DATE_PREFIX.test(stem)
  ) {
    throw new Error(
      `Feature folder feature name is invalid: ${JSON.stringify(feature)}`,
    );
  }
  return `${String(issueNumber).padStart(4, "0")}-${stem}`;
}
