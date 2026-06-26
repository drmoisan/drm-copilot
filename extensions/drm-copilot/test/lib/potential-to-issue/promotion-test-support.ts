import {
  type GhClient,
  type GhResult,
} from "../../../src/lib/potential-to-issue/gh-client";
import { type PotentialFileSystem } from "../../../src/lib/potential-to-issue/promotion";

/**
 * Shared hermetic fakes and content builders for the promotion workflow tests.
 *
 * Extracted so the promotion test scenarios can live in two files (each under
 * the 500-line limit) while reusing one Map-backed filesystem fake, one ordered
 * gh fake, and one content builder. No real gh, git, filesystem, or temp files.
 */

/** Recorded gh call: verb plus its positional argument tuple. */
export type RecordedGhCall = readonly [verb: string, args: readonly string[]];

/** Map-backed {@link PotentialFileSystem} mirroring the Python FakeFileSystem. */
export class FakePotentialFileSystem implements PotentialFileSystem {
  readonly files = new Map<string, string>();
  readonly dirs = new Set<string>();
  readonly moves: Array<[string, string]> = [];

  /** Mirror the Python fake: return the path unchanged (no resolution). */
  resolvePath(pathStr: string): string {
    return pathStr;
  }

  exists(path: string): boolean {
    return this.files.has(path);
  }

  readText(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`File not found: ${path}`);
    }
    return content;
  }

  writeLines(path: string, lines: readonly string[]): void {
    this.files.set(path, lines.join("\n"));
  }

  ensureDir(path: string): void {
    this.dirs.add(path);
  }

  move(src: string, dest: string): void {
    // Mirror the Python fake: a missing source is an error.
    if (!this.files.has(src)) {
      throw new Error(`File not found: ${src}`);
    }
    this.files.set(dest, this.files.get(src) ?? "");
    this.files.delete(src);
    this.moves.push([src, dest]);
  }
}

/** Ordered {@link GhClient} fake mirroring the Python FakeGhClient. */
export class FakeGhClient implements GhClient {
  readonly calls: RecordedGhCall[] = [];
  readonly ensureLabelCalls: string[] = [];
  private readonly createResults: GhResult[];

  constructor(
    createResults: GhResult | GhResult[],
    private readonly viewResult: GhResult | null = null,
    private readonly labelResult: GhResult = { output: [], exitCode: 0 },
    private readonly authenticated = true,
  ) {
    this.createResults = Array.isArray(createResults)
      ? createResults
      : [createResults];
  }

  isAuthenticated(): boolean {
    return this.authenticated;
  }

  issueCreate(title: string, body: string, promotionType: string): GhResult {
    this.calls.push(["create", [title, body, promotionType]]);
    // Consume queued responses in order, repeating the last when exhausted.
    if (this.createResults.length > 1) {
      return this.createResults.shift() as GhResult;
    }
    return this.createResults[0] as GhResult;
  }

  ensureLabel(label: string): GhResult {
    this.ensureLabelCalls.push(label);
    this.calls.push(["ensure_label", [label]]);
    return this.labelResult;
  }

  issueView(issueNumber: string): GhResult {
    this.calls.push(["view", [issueNumber]]);
    return this.viewResult ?? { output: [], exitCode: 0 };
  }
}

/** Workspace root used across the promotion tests. */
export const WORKSPACE = "/workspace";

/**
 * Build minimal full-feature potential content with all required sections.
 *
 * @param featureName Heading used for the potential entry.
 * @returns Minimal markdown accepted by the promotion workflow.
 */
export function buildFeatureContent(featureName: string): string {
  return [
    `# ${featureName}`,
    "## Problem / Why",
    "why",
    "## Proposed Behavior",
    "behave",
    "## Acceptance Criteria (early draft)",
    "criteria",
    "## Constraints & Risks",
    "risk",
    "## Test Conditions to Consider",
    "tests",
  ].join("\n");
}
