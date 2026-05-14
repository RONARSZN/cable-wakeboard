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
	"_place_obstacle_on_segment",
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
	"_check_obstacle_interactions",
	"_hit_kicker",
	"_hit_grind_obstacle",
	"show_obstacle"
)

foreach ($term in $requiredRiderTerms) {
	if ($rider -notmatch [regex]::Escape($term)) {
		throw "Missing rider term: $term"
	}
}

$uiPath = Join-Path $ProjectRoot "ui.gd"
$ui = Get-Content -Raw -Path $uiPath

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

"Obstacle setup source check passed."
