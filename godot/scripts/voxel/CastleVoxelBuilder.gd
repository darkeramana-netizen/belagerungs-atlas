extends Node
## CastleVoxelBuilder -- places castle components into the VoxelWorld block grid.
##
## Reads the same DNA Dictionary produced by ProceduralCastleGen (or hero JSON),
## translates every component into integer block coordinates, and writes them via
## VoxelWorld.set_block().
##
## Coordinate convention:
##   All component positions in the DNA are in metres (floats).
##   We convert: block_x = round(metres_x), block_z = round(metres_z).
##   Castle base Y = VoxelWorld.BASE_Y (= 20 by default).
##
## Foundation Logic (requirement 4):
##   After placing every surface block, call fill_foundations() which walks
##   downward from the castle base Y until it hits solid terrain, filling with
##   FOUNDATION blocks.  This ensures walls above cliffs never float.

const BT = preload("res://scripts/voxel/BlockTypes.gd")

## VoxelWorld reference (set by Main before calling build()).
var world = null   # VoxelWorld

## Y block where castle floor sits (matches VoxelWorld.BASE_Y).
const BASE_Y := 20


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------

## Build a castle from a DNA dictionary into the VoxelWorld.
## model has the same structure as ProceduralCastleGen.generate() output.
func build(model: Dictionary) -> void:
	if world == null:
		push_error("[CastleVoxelBuilder] world is null")
		return

	var components: Array = model.get("components", [])
	for comp in components:
		if not comp is Dictionary:
			continue
		_dispatch(comp)

	# Lay down a cobblestone courtyard at ground level
	var cam_r: float = model.get("cameraRadius", 60.0)
	var yard_r: int  = int(cam_r * 0.38)
	_fill_courtyard(yard_r)


# ---------------------------------------------------------------------------
# Component dispatcher
# ---------------------------------------------------------------------------

func _dispatch(comp: Dictionary) -> void:
	var type: String = comp.get("type", "")
	match type:
		"RING":
			_build_ring(comp)
		"ROUND_TOWER":
			_build_round_tower(comp)
		"SQUARE_TOWER":
			_build_square_tower(comp)
		"GATE":
			_build_gate(comp)
		"GABLED_HALL":
			_build_hall(comp)
		"GLACIS":
			_build_glacis(comp)
		_:
			pass   # WATER_PLANE, TERRAIN_STACK, etc. -- silently skip


# ---------------------------------------------------------------------------
# RING -- towers at vertices + curtain walls between them
# ---------------------------------------------------------------------------

func _build_ring(comp: Dictionary) -> void:
	var pts: Array   = comp.get("points", [])
	var wall_h: int  = maxi(1, int(comp.get("wall", {}).get("h",     8.0)))
	var wall_t: int  = maxi(1, int(comp.get("wall", {}).get("thick", 1.5)))
	var gate_i: int  = comp.get("gate", {}).get("atIndex", -1) if comp.has("gate") else -1
	var sq: bool     = bool(comp.get("squareTowers", false))
	var ring_y: int  = BASE_Y + int(float(comp.get("y", 0.0)))

	for i in pts.size():
		var pt = pts[i]
		var px: int = int(round(float(pt.get("x", 0.0))))
		var pz: int = int(round(float(pt.get("z", 0.0))))
		var tr: int = maxi(1, int(round(float(pt.get("r", 3.0)))))
		var th: int = maxi(3, int(round(float(pt.get("h", 14.0)))))

		if sq:
			_place_square_tower(px, ring_y, pz, tr, th, BT.STONE_BRICK)
		else:
			_place_round_tower(px, ring_y, pz, tr, th, BT.STONE_BRICK)

		# Curtain wall to next tower (skip gate segment)
		var ni: int = (i + 1) % pts.size()
		if i == gate_i:
			_build_gate_gap(pts[i], pts[ni], ring_y, wall_h)
			continue

		var np = pts[ni]
		var bx: int = int(round(float(np.get("x", 0.0))))
		var bz: int = int(round(float(np.get("z", 0.0))))
		_place_wall(px, ring_y, pz, bx, bz, wall_h, wall_t, BT.STONE_BRICK)


# ---------------------------------------------------------------------------
# ROUND_TOWER
# ---------------------------------------------------------------------------

func _build_round_tower(comp: Dictionary) -> void:
	var px: int = int(round(float(comp.get("x", 0.0))))
	var pz: int = int(round(float(comp.get("z", 0.0))))
	var r:  int = maxi(2, int(round(float(comp.get("r", 5.0)))))
	var h:  int = maxi(3, int(round(float(comp.get("h", 16.0)))))
	_place_round_tower(px, BASE_Y, pz, r, h, BT.STONE_BRICK)


# ---------------------------------------------------------------------------
# SQUARE_TOWER
# ---------------------------------------------------------------------------

func _build_square_tower(comp: Dictionary) -> void:
	var px: int = int(round(float(comp.get("x", 0.0))))
	var pz: int = int(round(float(comp.get("z", 0.0))))
	var r:  int = maxi(1, int(round(float(comp.get("r", 4.0)))))
	var h:  int = maxi(3, int(round(float(comp.get("h", 14.0)))))
	_place_square_tower(px, BASE_Y, pz, r, h, BT.STONE_BRICK)


# ---------------------------------------------------------------------------
# GATE (two flanking towers + portcullis gap)
# ---------------------------------------------------------------------------

func _build_gate(comp: Dictionary) -> void:
	var px: int = int(round(float(comp.get("x", 0.0))))
	var pz: int = int(round(float(comp.get("z", 0.0))))
	var w:  int = maxi(2, int(round(float(comp.get("w", 4.0)))))
	var h:  int = maxi(3, int(round(float(comp.get("h", 10.0)))))
	var tr: int = maxi(2, w)
	# Two flanking towers
	_place_round_tower(px - w - tr, BASE_Y, pz, tr, h, BT.DARK_BRICK)
	_place_round_tower(px + w + tr, BASE_Y, pz, tr, h, BT.DARK_BRICK)
	# Arch blocks over gate passage
	for dx in range(-w, w + 1):
		world.set_block(px + dx, BASE_Y + h - 1, pz, BT.ARCH)
		world.set_block(px + dx, BASE_Y + h - 2, pz, BT.ARCH)


# ---------------------------------------------------------------------------
# GABLED_HALL
# ---------------------------------------------------------------------------

func _build_hall(comp: Dictionary) -> void:
	var cx: int = int(round(float(comp.get("x", 0.0))))
	var cz: int = int(round(float(comp.get("z", 0.0))))
	var w:  int = maxi(3, int(round(float(comp.get("w", 10.0)))))
	var d:  int = maxi(3, int(round(float(comp.get("d", 16.0)))))
	var h:  int = maxi(2, int(round(float(comp.get("h",  7.0)))))
	var rh: int = maxi(1, int(round(float(comp.get("roofH", 3.0)))))

	var hw: int = w / 2
	var hd: int = d / 2

	# Hollow walls (1 block thick)
	for z in range(cz - hd, cz + hd + 1):
		for x in range(cx - hw, cx + hw + 1):
			var on_wall: bool = (x == cx - hw or x == cx + hw or
			                     z == cz - hd or z == cz + hd)
			for y in range(BASE_Y, BASE_Y + h):
				if on_wall:
					world.set_block(x, y, z, BT.STONE_BRICK)
				elif y == BASE_Y:
					world.set_block(x, y, z, BT.CLAY_TILE)   # interior floor

	# Gabled roof (SLATE_ROOF blocks)
	for dz in range(-hd, hd + 1):
		for dy in range(rh):
			var span: int = hw - dy
			for dx in range(-span, span + 1):
				world.set_block(cx + dx, BASE_Y + h + dy, cz + dz, BT.SLATE_ROOF)

	# Foundations
	_auto_foundations(cx - hw, cx + hw, cz - hd, cz + hd)


# ---------------------------------------------------------------------------
# GLACIS (sloped base ring) -- approximated as a ring of stone blocks
# ---------------------------------------------------------------------------

func _build_glacis(comp: Dictionary) -> void:
	var r: int = maxi(1, int(round(float(comp.get("r", 30.0)))))
	var h: int = maxi(1, int(round(float(comp.get("h",  4.0)))))
	for y in h:
		var ry: int = r - y   # ring shrinks as it goes up (frustum)
		_ring_blocks(0, BASE_Y - h + y, 0, ry, 1, BT.STONE)


# ---------------------------------------------------------------------------
# Primitive block placers
# ---------------------------------------------------------------------------

## Hollow cylinder shell: outer radius r, shell thickness wall_t (in blocks).
func _place_round_tower(cx: int, base_y: int, cz: int,
		r: int, height: int, block_id: int) -> void:
	var shell: int = maxi(1, r / 4)   # wall thickness ~ 25% of radius
	for y in range(base_y, base_y + height):
		_ring_blocks(cx, y, cz, r, shell, block_id)

	# Battlements (crenellations) on top: alternating merlons
	var merlon_gap := 2
	for angle_step in range(0, 360, merlon_gap * 15):
		var a: float = deg_to_rad(float(angle_step))
		var bx: int = cx + int(round(cos(a) * float(r)))
		var bz_: int = cz + int(round(sin(a) * float(r)))
		world.set_block(bx, base_y + height, bz_, BT.BATTLEMENT)

	# Foundation column
	_fill_column_to_ground(cx, base_y, cz, block_id)
	fill_ring_foundations(cx, cz, r, base_y)


## Solid box tower: half-extent r, hollow interior.
func _place_square_tower(cx: int, base_y: int, cz: int,
		r: int, height: int, block_id: int) -> void:
	for y in range(base_y, base_y + height):
		for z in range(cz - r, cz + r + 1):
			for x in range(cx - r, cx + r + 1):
				var on_wall: bool = (x == cx - r or x == cx + r or
				                     z == cz - r or z == cz + r)
				if on_wall or y == base_y:
					world.set_block(x, y, z, block_id)

	# Battlements
	for x in range(cx - r, cx + r + 1, 2):
		world.set_block(x, base_y + height, cz - r, BT.BATTLEMENT)
		world.set_block(x, base_y + height, cz + r, BT.BATTLEMENT)
	for z in range(cz - r, cz + r + 1, 2):
		world.set_block(cx - r, base_y + height, z, BT.BATTLEMENT)
		world.set_block(cx + r, base_y + height, z, BT.BATTLEMENT)

	_auto_foundations(cx - r, cx + r, cz - r, cz + r)


## Curtain wall from (ax, base_y, az) to (bx, base_y, bz).
func _place_wall(ax: int, base_y: int, az: int,
		bx: int, bz: int, height: int, thickness: int,
		block_id: int) -> void:
	var dx: int = bx - ax
	var dz: int = bz - az
	var steps: int = maxi(abs(dx), abs(dz))
	if steps == 0:
		return

	# Walk along the longer axis, snap to grid
	for s in range(steps + 1):
		var t: float = float(s) / float(steps)
		var wx: int  = ax + int(round(t * float(dx)))
		var wz: int  = az + int(round(t * float(dz)))

		for y in range(base_y, base_y + height):
			world.set_block(wx, y, wz, block_id)
			# Wall thickness perpendicular to travel direction
			if abs(dx) > abs(dz):   # mostly horizontal wall -> thicken in Z
				for tz in range(-(thickness / 2), (thickness / 2) + 1):
					world.set_block(wx, y, wz + tz, block_id)
			else:                    # mostly vertical wall -> thicken in X
				for tx in range(-(thickness / 2), (thickness / 2) + 1):
					world.set_block(wx + tx, y, wz, block_id)

		# Battlements every 2 blocks
		if s % 2 == 0:
			world.set_block(wx, base_y + height, wz, BT.BATTLEMENT)

	# Foundations under wall
	for s in range(steps + 1):
		var t: float = float(s) / float(steps)
		var wx: int  = ax + int(round(t * float(dx)))
		var wz: int  = az + int(round(t * float(dz)))
		world.fill_foundation(wx, base_y, wz, BT.FOUNDATION)


## Leave a gap in the wall for a gate passage.
func _build_gate_gap(pt_a, pt_b, base_y: int, wall_h: int) -> void:
	# The gate index just leaves an open passage -- CastleVoxelBuilder.build_gate()
	# handles the arch + flanking towers separately.
	pass


## Courtyard: fill a circle of COBBLE at BASE_Y (only over AIR blocks).
func _fill_courtyard(radius: int) -> void:
	for z in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + z * z <= radius * radius:
				var cur: int = world.get_block(x, BASE_Y, z)
				if cur == BT.AIR or cur == BT.GRASS or cur == BT.DIRT:
					world.set_block(x, BASE_Y, z, BT.COBBLE)


# ---------------------------------------------------------------------------
# Geometry helpers
# ---------------------------------------------------------------------------

## Place a ring of blocks at radius r with wall thickness shell.
func _ring_blocks(cx: int, y: int, cz: int, r: int, shell: int, block_id: int) -> void:
	var r_inner: int = maxi(0, r - shell)
	for z in range(cz - r, cz + r + 1):
		for x in range(cx - r, cx + r + 1):
			var dist2: int = (x - cx) * (x - cx) + (z - cz) * (z - cz)
			if dist2 <= r * r and dist2 >= r_inner * r_inner:
				world.set_block(x, y, z, block_id)


## Fill a single column down to ground level with FOUNDATION blocks.
func _fill_column_to_ground(wx: int, top_y: int, wz: int, block_id: int) -> void:
	world.fill_foundation(wx, top_y, wz, block_id)


## Fill foundations under all columns within an AABB.
func _auto_foundations(x0: int, x1: int, z0: int, z1: int) -> void:
	for z in range(z0, z1 + 1):
		for x in range(x0, x1 + 1):
			world.fill_foundation(x, BASE_Y, z, BT.FOUNDATION)


## Fill foundations under a ring perimeter.
func fill_ring_foundations(cx: int, cz: int, r: int, base_y: int) -> void:
	for z in range(cz - r, cz + r + 1):
		for x in range(cx - r, cx + r + 1):
			var d2: int = (x - cx) * (x - cx) + (z - cz) * (z - cz)
			if d2 <= r * r:
				world.fill_foundation(x, base_y, z, BT.FOUNDATION)
