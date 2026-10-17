import { describe, expect, it } from "@jest/globals";

import { validateEpicReadinessIntegrity } from "../../../src/lib/validate/epic-planner-readiness-integrity";
import { launchEvidenceFixture } from "./epic-planner-launch-evidence-test-support";

const FOLDER = "docs/features/active/feature-101";
const PLAN = "docs/features/active/feature-101/plan.md";
const RESEARCH = "artifacts/research/feature-101.md";
const FOLDER_REQUIRED_ERROR =
  "Execution readiness requires feature folder: docs/features/active/feature-101";
const ROOT_FOLDER_REQUIRED_ERROR =
  "Execution readiness requires feature folder: .";
const FOLDER_ESCAPE_ERROR =
  "Epic planner checkpoint features[0].feature_folder must stay within the workspace root.";
const FOLDER_SLASH_ERROR =
  "Epic planner checkpoint features[0].feature_folder must use forward slashes.";
const FOLDER_EMPTY_ERROR =
  "Epic planner checkpoint features[0].feature_folder must be a non-empty repository-relative path.";
const PLAN_ESCAPE_ERROR =
  "Epic planner checkpoint features[0].plan_path must stay within the workspace root.";

/** Validate readiness for one keyless feature with the given paths. */
function errorsFor(featureFolder: string, planPath = PLAN): string[] {
  const { context } = launchEvidenceFixture();
  return validateEpicReadinessIntegrity(
    {
      epic_feature_folder: "sample-epic",
      features: [
        {
          feature_folder: featureFolder,
          plan_path: planPath,
          research_path: RESEARCH,
        },
      ],
    },
    "{}",
    context,
    { requireLaunchPaths: true },
  );
}

const normalizedCases: ReadonlyArray<{
  readonly label: string;
  readonly folder: string;
  readonly expected: string;
}> = [
  { label: "plain", folder: FOLDER, expected: FOLDER_REQUIRED_ERROR },
  {
    label: "dot-prefix",
    folder: `./${FOLDER}`,
    expected: FOLDER_REQUIRED_ERROR,
  },
  {
    label: "dot-segment",
    folder: "docs/features/active/./feature-101",
    expected: FOLDER_REQUIRED_ERROR,
  },
  {
    label: "double-slash",
    folder: "docs/features/active//feature-101",
    expected: FOLDER_REQUIRED_ERROR,
  },
  {
    label: "trailing-slash",
    folder: `${FOLDER}/`,
    expected: FOLDER_REQUIRED_ERROR,
  },
  { label: "dot-only", folder: "./", expected: ROOT_FOLDER_REQUIRED_ERROR },
];

const rejectedCases: ReadonlyArray<{
  readonly label: string;
  readonly folder: string;
  readonly expected: string;
}> = [
  { label: "parent", folder: "../feature-101", expected: FOLDER_ESCAPE_ERROR },
  { label: "absolute", folder: `/${FOLDER}`, expected: FOLDER_ESCAPE_ERROR },
  {
    label: "backslash",
    folder: "docs\\features\\active\\feature-101",
    expected: FOLDER_SLASH_ERROR,
  },
  { label: "blank", folder: "   ", expected: FOLDER_EMPTY_ERROR },
  {
    label: "drive-letter",
    folder: "C:/docs/features/active/feature-101",
    expected: FOLDER_ESCAPE_ERROR,
  },
  {
    label: "drive-relative",
    folder: "c:docs/features/active/feature-101",
    expected: FOLDER_ESCAPE_ERROR,
  },
];

describe("validateEpicReadinessIntegrity repository-relative paths", () => {
  it.each(normalizedCases)(
    "normalizes a $label feature_folder like the Python validator",
    ({ folder, expected }) => {
      expect(errorsFor(folder)).toContain(expected);
    },
  );

  it.each(rejectedCases)(
    "rejects a $label feature_folder",
    ({ folder, expected }) => {
      expect(errorsFor(folder)).toContain(expected);
    },
  );

  it("accepts a dot-prefixed plan_path", () => {
    const planPath = `./${PLAN}`;

    const errors = errorsFor(FOLDER, planPath);

    expect(errors).toContain(FOLDER_REQUIRED_ERROR);
    expect(errors).not.toContain(PLAN_ESCAPE_ERROR);
  });
});
