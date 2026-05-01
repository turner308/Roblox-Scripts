--!strict
--!native
--!optimize 2

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

type DrawingObject = any

type Slot = {
	obj: DrawingObject,
	drawType: string,

	ax: number, ay: number,
	bx: number, by: number,
	cx: number, cy: number,
	dx: number, dy: number,

	r: number, g: number, b: number,

	filled: boolean,
	thickness: number,
	radius: number,

	text: string,
	size: number,
	font: number,
	outline: boolean,
}

local TRIM_DELAY = 180
local TRIM_RATIO = 0.5

local slots: {Slot} = {}
local count = 0
local drawCursor = 0
local underuse = 0

local function poolReset()
	drawCursor = 0
end

local function poolFlush()
	local used = drawCursor
	local total = count

	for i = used + 1, total do
		slots[i].obj.Visible = false
	end

	if total > 0 and used / total < TRIM_RATIO then
		underuse += 1
	else
		underuse = 0
	end

	if underuse >= TRIM_DELAY then
		local keep = math.ceil(used * 1.25)
		for i = keep + 1, total do
			slots[i].obj:Remove()
			slots[i] = nil :: any
		end
		count = keep
		underuse = 0
	end
end

local function getSlot(drawType: string): Slot
	drawCursor += 1
	local i = drawCursor
	local s = slots[i]

	if not s then
		local obj = Drawing.new(drawType)
		s = {
			obj = obj,
			drawType = drawType,

			ax = 0, ay = 0,
			bx = 0, by = 0,
			cx = 0, cy = 0,
			dx = 0, dy = 0,

			r = -1, g = -1, b = -1,

			filled = false,
			thickness = -1,
			radius = -1,

			text = "",
			size = -1,
			font = -1,
			outline = false,
		}

		slots[i] = s
		if i > count then
			count = i
		end
	elseif s.drawType ~= drawType then
		s.obj:Remove()
		s.obj = Drawing.new(drawType)
		s.drawType = drawType

		s.ax = 0; s.ay = 0
		s.bx = 0; s.by = 0
		s.cx = 0; s.cy = 0
		s.dx = 0; s.dy = 0

		s.r = -1; s.g = -1; s.b = -1

		s.filled = false
		s.thickness = -1
		s.radius = -1

		s.text = ""
		s.size = -1
		s.font = -1
		s.outline = false
	end

	if not s.obj.Visible then
		s.obj.Visible = true
	end

	return s
end

local Im = {}
local fl = math.floor

function Im.Begin()
	poolReset()
end

function Im.End()
	poolFlush()
end

function Im.Line(ax: number, ay: number, bx: number, by: number, color: Color3, thickness: number)
	local s = getSlot("Line")
	local cr, cg, cb = color.R, color.G, color.B

	if s.ax ~= ax or s.ay ~= ay then
		s.ax = ax
		s.ay = ay
		s.obj.From = Vector2.new(fl(ax), fl(ay))
	end

	if s.bx ~= bx or s.by ~= by then
		s.bx = bx
		s.by = by
		s.obj.To = Vector2.new(fl(bx), fl(by))
	end

	if s.r ~= cr or s.g ~= cg or s.b ~= cb then
		s.r = cr
		s.g = cg
		s.b = cb
		s.obj.Color = color
	end

	if s.thickness ~= thickness then
		s.thickness = thickness
		s.obj.Thickness = thickness
	end
end

function Im.Quad(ax:number, ay:number, bx:number, by:number, cx:number, cy:number, dx:number, dy:number, color:Color3, filled:boolean, thickness:number)
	local s = getSlot("Quad")
	local cr, cg, cb = color.R, color.G, color.B

	if s.ax ~= ax or s.ay ~= ay then s.ax = ax; s.ay = ay; s.obj.PointA = Vector2.new(fl(ax), fl(ay)) end
	if s.bx ~= bx or s.by ~= by then s.bx = bx; s.by = by; s.obj.PointB = Vector2.new(fl(bx), fl(by)) end
	if s.cx ~= cx or s.cy ~= cy then s.cx = cx; s.cy = cy; s.obj.PointC = Vector2.new(fl(cx), fl(cy)) end
	if s.dx ~= dx or s.dy ~= dy then s.dx = dx; s.dy = dy; s.obj.PointD = Vector2.new(fl(dx), fl(dy)) end

	if s.r ~= cr or s.g ~= cg or s.b ~= cb then
		s.r = cr; s.g = cg; s.b = cb
		s.obj.Color = color
	end

	if s.filled ~= filled then
		s.filled = filled
		s.obj.Filled = filled
	end

	if s.thickness ~= thickness then
		s.thickness = thickness
		s.obj.Thickness = thickness
	end
end

function Im.Rect(x:number, y:number, w:number, h:number, color:Color3, filled:boolean, thickness:number)
	Im.Quad(x, y, x + w, y, x + w, y + h, x, y + h, color, filled, thickness)
end

function Im.Text(x:number, y:number, text:string, size:number, color:Color3, font:number, outline:boolean, center:boolean?)
	local s = getSlot("Text")
	local cr, cg, cb = color.R, color.G, color.B

	if s.ax ~= x or s.ay ~= y then
		s.ax = x
		s.ay = y
		s.obj.Position = Vector2.new(fl(x), fl(y))
	end

	if s.text ~= text then
		s.text = text
		s.obj.Text = text
		s.obj.Center = center == true
	end

	if s.size ~= size then
		s.size = size
		s.obj.Size = size
	end

	if s.r ~= cr or s.g ~= cg or s.b ~= cb then
		s.r = cr
		s.g = cg
		s.b = cb
		s.obj.Color = color
	end

	if s.font ~= font then
		s.font = font
		s.obj.Font = font
	end

	if s.outline ~= outline then
		s.outline = outline
		s.obj.Outline = outline
	end
end

local OFFSETS = {
	-1,-1, 1,  -1, 1, 1,  1, 1, 1,  1,-1, 1,
	-1,-1,-1,  -1, 1,-1,  1, 1,-1,  1,-1,-1,
}

local EDGES = {
	1,2, 2,3, 3,4, 4,1,
	5,6, 6,7, 7,8, 8,5,
	1,5, 2,6, 3,7, 4,8,
}

local _psx = table.create(8, 0)
local _psy = table.create(8, 0)

local function _projectCornersRaw(cf: CFrame, size: Vector3): boolean
	local hx, hy, hz = size.X * .5, size.Y * .5, size.Z * .5
	local oi = 0

	for i = 1, 8 do
		oi += 1 local ox = OFFSETS[oi]
		oi += 1 local oy = OFFSETS[oi]
		oi += 1 local oz = OFFSETS[oi]

		local s, vis = camera:WorldToViewportPoint(cf * Vector3.new(ox * hx, oy * hy, oz * hz))
		if not vis then
			return false
		end

		_psx[i] = s.X
		_psy[i] = s.Y
	end

	return true
end

local function _drawEdges(color: Color3, thickness: number)
	local ei = 0
	for _ = 1, 12 do
		ei += 1 local a = EDGES[ei]
		ei += 1 local b = EDGES[ei]
		Im.Line(_psx[a], _psy[a], _psx[b], _psy[b], color, thickness)
	end
end

local function _resolveBounds(inst: Instance): (CFrame?, Vector3?)
	if inst:IsA("BasePart") then
		local part = inst :: BasePart
		return part.CFrame, part.Size
	end

	if inst:IsA("Model") then
		local cf, size = (inst :: Model):GetBoundingBox()
		return cf, size
	end

	return nil, nil
end

function Im.Draw2DBox(inst: Instance, color: Color3, thickness: number): boolean
	local cf, size = _resolveBounds(inst)
	if not cf then
		return false
	end

	if not _projectCornersRaw(cf, size) then
		return false
	end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for i = 1, 8 do
		local x, y = _psx[i], _psy[i]
		if x < minX then minX = x end
		if y < minY then minY = y end
		if x > maxX then maxX = x end
		if y > maxY then maxY = y end
	end

	Im.Rect(minX, minY, maxX - minX, maxY - minY, color, false, thickness)
	return true
end

function Im.Draw3DBox(inst: Instance, color: Color3, thickness: number): boolean
	local cf, size = _resolveBounds(inst)
	if not cf then
		return false
	end

	if not _projectCornersRaw(cf, size) then
		return false
	end

	_drawEdges(color, thickness)
	return true
end

return Im
