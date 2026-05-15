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
	"Vector3(-260, 0, -108)",
	"Vector3(-330, 0, -18)",
	"Vector3(-252, 0, 118)",
	"Vector3(292, 0, 116)",
	"Vector3(318, 0, -112)",
	"_add_air_trick_markers",
	"preload(`"res://scenery_factory.gd`")",
	"SceneryFactoryScript.create_wakepark_scene",
	"_place_obstacle_on_segment",
	"_side_offset",
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
	"progress_ratio += speed * delta",
	"progress_ratio = 0.0",
	"KEY_A",
	"_set_approach_axis(1)",
	"KEY_D",
	"_set_approach_axis(-1)",
	"is_riding_obstacle",
	"_start_obstacle_ride",
	"_update_obstacle_ride",
	"required_hold_time",
	"trick_hold_time",
	"spin_180_hold_time",
	"spin_360_hold_time",
	"base_stance_yaw",
	"stance_yaw",
	"_set_stance_yaw",
	"_start_spin_key",
	"_finish_spin_key",
	"_finish_trick_rotation",
	"_release_trick_key",
	"_apply_trick_rotation",
	"_clear_trick_rotation",
	"visual_root.rotation_degrees.y = stance_yaw + rotation_amount",
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
	"Handle"
)

foreach ($term in $requiredRiderFactoryTerms) {
	if ($riderFactory -notmatch [regex]::Escape($term)) {
		throw "Missing rider factory term: $term"
	}
}

if ($riderFactory -match [regex]::Escape("TowRope")) {
	throw "Rider visual should not include the cable line."
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
	"create_daytime_world_environment",
	"ProceduralSkyMaterial.new",
	"WorldEnvironment.new",
	"Environment.BG_SKY",
	"Environment.AMBIENT_SOURCE_SKY",
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
	"Vector3(0.0, 0.02, 252.0)",
	"Vector3(8.0, 0.02, -220.0)",
	"Vector3(356.0, 0.02, 8.0)",
	"Vector3(364.0, 0.0",
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

if ($scene -notmatch [regex]::Escape("size = Vector2(900, 620)")) {
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
