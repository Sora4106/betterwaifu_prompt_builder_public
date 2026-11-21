import 'public_catalog_data.dart';
import 'curated_pose_extension_data.dart';
import 'finger_gesture_data.dart';
import 'single_person_pose_data.dart';

/// Public-edition replacement for the former expanded catalogue.
///
/// It deliberately contains only general poses, gestures, and motion helpers.
/// The placeholder conflict-group names keep old local saves harmless without
/// reintroducing any removed catalogue entries.
const bodyFluidPickerGroups = <String>[];
const oralSexPrimaryGroup = '__removed_public_group__';
const oralSexPositionGroup = '__removed_public_group__';
const oralFellatioPrimaryConflictGroup = '__removed_public_conflict__';
const oralFellatioPositionConflictGroup = '__removed_public_conflict__';
const oralFellatioPrimaryTerms = <String>{};

const expandedGeneralPoseGroups = <String>{
  ...curatedPoseExtensionGroups,
  ...fingerGestureGroups,
  ...singlePersonPoseGroups,
};

const expandedSexualPoseGroups = <String>{};
const expandedSexualActGroups = <String>{};
const individualAdultPersonActionGroups = <String>{};
const expandedAdultClothingGroups = <String>{};
const expandedAdultToolGroups = <String>{};
const expandedSharedFinalGroups = <String>{};

const expandedPickerTagGroups = <String>{
  ...expandedGeneralPoseGroups,
};

const expandedTagPickerSections = <String, List<String>>{
  '一般姿勢': <String>[
    ...singlePersonPoseGroups,
    ...curatedPoseExtensionGroups,
    ...fingerGestureGroups,
  ],
};

final List<CatalogTagData> expandedPromptTags = <CatalogTagData>[
  ...singlePersonPoseTags,
  ...curatedPoseExtensionTags,
  ...fingerGestureTags,
];
