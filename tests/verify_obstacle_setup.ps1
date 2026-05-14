param(
	[string]$ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$factoryPath = Join-Path $ProjectRoot "obstacle_factory.gd"
$pathScriptPath = Join-Path $ProjectRoot "cable_path.gd"

if (-not (Test-Path $factoryPath)) {
	throw "Missing obstacle_factory.gd"
}

$factory = Get-Content -Raw -Path $factoryPath
$pathScript = Get-Content -Raw -Path $pathScriptPath

$requiredFactoryTerms = @(
	"class_name ObstacleFactory",
	"create_kicker",
	"create_flat_box",
	"create_pipe_rail",
	"`"Kicker`", `"kicker`", 11.5",
	"`"FlatBox`", `"grind`", 12.0",
	"`"PipeRail`", `"grind`", 10.5",
	"ride_height",
	"obstacle_kind",
	"interaction_radius",
	"points"
)

foreach ($term in $requiredFactoryTerms) {
	if ($factory -notmatch [regex]::Escape($term)) {
		throw "Missing factory term: $term"
	}
}

$requiredPathTerms = @(
	"ObstacleFactory.create_kicker",
	"ObstacleFactory.create_flat_box",
	"ObstacleFactory.create_pipe_rail",
	"preload(`"res://scenery_factory.gd`")",
	"SceneryFactoryScript.create_wakepark_scene",
	"_place_obstacle_on_segment",
	"_side_offset",
	"9.0",
	"-10.0",
	"8.0",
	"_tower_base_position",
	"EnvironmentFactory.create_engine_tower",
	"EnvironmentFactory.create_corner_tower"
)

foreach ($term in $requiredPathTerms) {
	if ($pathScript -notmatch [regex]::Escape($term)) {
		throw "Missing path term: $term"
	}
}

$riderPath = Join-Path $ProjectRoot "rider.gd"
$rider = Get-Content -Raw -Path $riderPath

$requiredRiderTerms = @(
	"preload(`"res://rider_factory.gd`")",
	"RiderFactoryScript.populate",
	"trick_rotation_axis",
	"obstacle_approach_radius",
	"approach_axis",
	"target_lane_offset",
	"current_lane_offset",
	"_update_lane_offset",
	"_set_approach_axis",
	"is_riding_obstacle",
	"_start_obstacle_ride",
	"_update_obstacle_ride",
	"required_hold_time",
	"trick_hold_time",
	"spin_180_hold_time",
	"spin_360_hold_time",
	"_start_spin_key",
	"_finish_spin_key",
	"_finish_trick_rotation",
	"_release_trick_key",
	"_apply_trick_rotation",
	"_clear_trick_rotation",
	"visual_root.rotation_degrees.y = rotation_amount",
	"_apply_ride_pose",
	"_apply_edge_pose",
	"_apply_pop_pose",
	"_apply_grind_pose",
	"_check_obstacle_interactions",
	"_hit_kicker",
	"_hit_grind_obstacle",
	"show_obstacle",
	"last_trick = `""
)

foreach ($term in $requiredRiderTerms) {
	if ($rider -notmatch [regex]::Escape($term)) {
		throw "Missing rider term: $term"
	}
}

if ($rider -match [regex]::Escape("no trick performed")) {
	throw "Landing without a trick should not be treated as a crash."
}

$riderFactoryPath = Join-Path $ProjectRoot "rider_factory.gd"
$riderFactory = Get-Content -Raw -Path $riderFactoryPath

$requiredRiderFactoryTerms = @(
	"class_name RiderFactory",
	"Wakeboard",
	"BoardCenter",
	"BoardNose",
	"BoardTail",
	"WhiteCenterGraphic",
	"PurpleAccentGraphic",
	"FrontBinding",
	"BackBinding",
	"RiderBody",
	"LifeVest",
	"Helmet",
	"HandleAndRope",
	"TowRope"
)

foreach ($term in $requiredRiderFactoryTerms) {
	if ($riderFactory -notmatch [regex]::Escape($term)) {
		throw "Missing rider factory term: $term"
	}
}

$uiPath = Join-Path $ProjectRoot "ui.gd"
$ui = Get-Content -Raw -Path $uiPath
$scenePath = Join-Path $ProjectRoot "main.tscn"
$scene = Get-Content -Raw -Path $scenePath

if ($ui -notmatch [regex]::Escape("func show_obstacle")) {
	throw "Missing UI obstacle display handler."
}

$environmentPath = Join-Path $ProjectRoot "environment_factory.gd"
$environment = Get-Content -Raw -Path $environmentPath

$requiredEnvironmentTerms = @(
	"create_engine_tower",
	"create_corner_tower",
	"EngineBoom",
	"CrossBraceA",
	"CornerPulley"
)

foreach ($term in $requiredEnvironmentTerms) {
	if ($environment -notmatch [regex]::Escape($term)) {
		throw "Missing environment term: $term"
	}
}

$sceneryPath = Join-Path $ProjectRoot "scenery_factory.gd"
$scenery = Get-Content -Raw -Path $sceneryPath

$requiredSceneryTerms = @(
	"class_name SceneryFactory",
	"create_wakepark_scene",
	"MIN_WATER_CLEARANCE = 75.0",
	"CentralIsland",
	"Vector3(0.0, 0.02, 154.0)",
	"Vector3(8.0, 0.02, -147.0)",
	"Vector3(176.0, 0.02, 8.0)",
	"Vector3(184.0, 0.0",
	"LakeHut",
	"EventCanopy",
	"DistantMountainLine",
	"WindTurbine"
)

foreach ($term in $requiredSceneryTerms) {
	if ($scenery -notmatch [regex]::Escape($term)) {
		throw "Missing scenery term: $term"
	}
}

if ($scene -notmatch [regex]::Escape("size = Vector2(600, 410)")) {
	throw "Water plane should be large enough for the expanded wakepark spacing."
}

$readmePath = Join-Path $ProjectRoot "README.md"
$readme = Get-Content -Raw -Path $readmePath

$requiredReadmeTerms = @(
	"Hold ``A``",
	"Hold ``D``",
	"Hold ``Left Arrow``",
	"Hold ``Right Arrow``",
	"Release after enough rotation for a 180",
	"keep holding for a full 360",
	"must be held long enough",
	"obstacle lane"
)

foreach ($term in $requiredReadmeTerms) {
	if ($readme -notmatch [regex]::Escape($term)) {
		throw "Missing README controls term: $term"
	}
}

"Obstacle setup source check passed."
