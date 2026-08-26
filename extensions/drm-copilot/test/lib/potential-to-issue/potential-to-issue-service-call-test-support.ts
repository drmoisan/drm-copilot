import {
  type CommandResult,
  type CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { FakePotentialFileSystem } from "./promotion-test-support";

/**
 * Hermetic seam helpers and fixed paths for the `potentialToIssueServiceCall`
 * scenarios.
 *
 * Extracted from `potential-to-issue-service-call.test.ts` so that file stays
 * within the 500-line limit once the unconditional slug-resolution seam and the
 * fail-closed scenario are added. Follows the `-test-support.ts` convention
 * already used by `promotion-test-support.ts` and
 * `collect-commit-context-test-support.ts`. Every value here is moved verbatim;
 * no expected value asserted by any scenario is changed.
 */

/** Potential record used by the workspace-rooted scenarios. */
export const POTENTIAL = "/workspace/docs/features/potential/sample.md";

/** Slug returned by the injected resolver seam in the resolution tests. */
export const RESOLVED_SLUG = "drmoisan/drm-copilot";

/** Workspace root that is not the process working directory. */
export const DIFFERING_WORKSPACE = "/other-checkout";

/** Potential record living under {@link DIFFERING_WORKSPACE}. */
export const DIFFERING_POTENTIAL = `${DIFFERING_WORKSPACE}/docs/features/potential/sample.md`;

/**
 * Workspace root equal to the process working directory.
 *
 * The promotion workflow joins the workspace root with forward slashes, so the
 * host separator is normalized here and every expected value derived from it
 * stays deterministic on any host.
 */
export const PROCESS_ROOT = process.cwd().replace(/\\/g, "/");

/** Potential record living under {@link PROCESS_ROOT}. */
export const PROCESS_POTENTIAL = `${PROCESS_ROOT}/docs/features/potential/sample.md`;

/** Repository-view resolution words, following the executable token. */
const REPO_VIEW_WORDS: readonly string[] = [
  "repo",
  "view",
  "--json",
  "nameWithOwner",
];

/**
 * @param args Argument vector handed to the stub.
 * @returns True when the vector is the repository-view resolution call. The
 *   executable token is ignored, because the resolver invokes the bare program
 *   name rather than a seeded lookup path.
 */
function isRepoViewVector(args: readonly string[]): boolean {
  return REPO_VIEW_WORDS.every((word, index) => args[index + 1] === word);
}

/**
 * Recording {@link CommandRunner} stub.
 *
 * Slug resolution runs unconditionally, so this stub answers the
 * repository-view vector with a resolvable payload; every other vector keeps
 * the pre-existing empty result. Without the branch, empty output would be an
 * unresolvable condition and every scenario would fail closed.
 *
 * @param recorded Sink that receives one entry per recorded argument vector.
 * @returns The recording runner.
 */
export function makeRunner(recorded: string[][]): CommandRunner {
  return {
    run(args: readonly string[]): CommandResult {
      recorded.push([...args]);
      if (isRepoViewVector(args)) {
        return {
          stdout: `{"nameWithOwner":"${RESOLVED_SLUG}"}`,
          stderr: "",
          code: 0,
        };
      }
      return { stdout: "", stderr: "", code: 0 };
    },
  };
}

/**
 * Filesystem fake that reports one designated path as absent.
 *
 * Used to drive the receipt post-condition: the promotion still moves the file
 * normally, but the reported destination fails its existence check.
 */
export class BlockedPathPotentialFileSystem extends FakePotentialFileSystem {
  /**
   * @param blockedPath Path whose existence check always reports false.
   */
  constructor(private readonly blockedPath: string) {
    super();
  }

  /**
   * @param path Path to test.
   * @returns False for the blocked path; otherwise the inherited answer.
   */
  override exists(path: string): boolean {
    return path === this.blockedPath ? false : super.exists(path);
  }
}

/**
 * Seed a feature potential with all required sections.
 *
 * @param fs Filesystem fake to seed.
 * @param path Path the potential record is written to.
 */
export function seedFeature(fs: FakePotentialFileSystem, path: string): void {
  fs.files.set(
    path,
    [
      "# Feature Title",
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
    ].join("\n"),
  );
}

/**
 * Recording resolver seam that captures the workspace value it was handed.
 *
 * @param recorded Sink that receives one entry per resolver invocation.
 * @returns A resolver returning {@link RESOLVED_SLUG}.
 */
export function makeRecordingResolver(
  recorded: string[],
): (workspaceRoot: string) => string {
  return (workspaceRoot: string): string => {
    recorded.push(workspaceRoot);
    return RESOLVED_SLUG;
  };
}
