--[[‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

-			SCRIPT NAME		:	CFrame.client.lua
-			AUTHOR			:	yeno_why
-			DESCRIPTION		:	Basic CFrame lib
-           NOTE            :   Luduvo no have :sob:
______________________________________________________________________]]--

local CFrame = {};
CFrame.__index = CFrame;
CFrame.__type = 'CFrame';

local new = function(px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22)
	return setmetatable({X = px, Y = py, Z = pz, r00 = r00, r01 = r01, r02 = r02, r10 = r10, r11 = r11, r12 = r12, r20 = r20, r21 = r21, r22 = r22}, CFrame);
end;

-- constructors

CFrame.lookAt = function(...) end; -- luau lsp is crying

CFrame.new = function(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
	if (type(x) == 'vector') then
		if (type(y) == 'vector') then return CFrame.lookAt(x, y); end;
		return new(x.X, x.Y, x.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1);
	end;
	if (r00 == nil) then return new(x, y, z, 1, 0, 0, 0, 1, 0, 0, 0, 1); end;
	return new(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22);
end;

CFrame.Angles = function(rx, ry, rz)
	local cx, sx = math.cos(rx), math.sin(rx);
	local cy, sy = math.cos(ry), math.sin(ry);
	local cz, sz = math.cos(rz), math.sin(rz);
	return new(0, 0, 0, cy*cz, -cy*sz, sy, cx*sz + sx*sy*cz, cx*cz - sx*sy*sz, -sx*cy, sx*sz - cx*sy*cz, sx*cz + cx*sy*sz, cx*cy);
end;

CFrame.fromEulerAnglesYXZ = function(rx, ry, rz)
	local cx, sx = math.cos(rx), math.sin(rx);
	local cy, sy = math.cos(ry), math.sin(ry);
	local cz, sz = math.cos(rz), math.sin(rz);
	return new(0, 0, 0, cy*cz + sy*sx*sz, -cy*sz + sy*sx*cz, sy*cx, cx*sz, cx*cz, -sx, -sy*cz + cy*sx*sz, sy*sz + cy*sx*cz, cy*cx);
end;

CFrame.fromOrientation = function(rx, ry, rz)
	return CFrame.fromEulerAnglesYXZ(math.rad(rx), math.rad(ry), math.rad(rz));
end;

CFrame.lookAt = function(pos, target, up)
	local ux0, uy0, uz0 = 0, 1, 0;
	if (up) then ux0, uy0, uz0 = up.X, up.Y, up.Z; end;

	local bx, by, bz = pos.X - target.X, pos.Y - target.Y, pos.Z - target.Z;
	local bl = math.sqrt(bx*bx + by*by + bz*bz);
	bx, by, bz = bx/bl, by/bl, bz/bl;

	local rx, ry, rz = uy0*bz - uz0*by, uz0*bx - ux0*bz, ux0*by - uy0*bx;
	local rl = math.sqrt(rx*rx + ry*ry + rz*rz);
	rx, ry, rz = rx/rl, ry/rl, rz/rl;

	return new(pos.X, pos.Y, pos.Z, rx, by*rz - bz*ry, bx, ry, bz*rx - bx*rz, by, rz, bx*ry - by*rx, bz);
end;

CFrame.fromInstance = function(inst)
	local p = inst.Position;
	local r = inst.Orientation;
	local rot = CFrame.fromOrientation(r.X, r.Y, r.Z);
	rot.X, rot.Y, rot.Z = p.X, p.Y, p.Z;
	return rot;
end;

CFrame.toOrientation = function(self)
	local sx = -self.r12;
	local rx = math.asin(math.max(-1, math.min(1, sx)));
	local ry, rz;
	if (math.abs(sx) < 0.99999) then
		ry = math.atan2(self.r02, self.r22);
		rz = math.atan2(self.r10, self.r11);
	else 
		ry = math.atan2(-self.r20, self.r00);
		rz = 0;
	end;
	return math.deg(rx), math.deg(ry), math.deg(rz);
end;

CFrame.toInstance = function(self, inst)
	local rx, ry, rz = self:toOrientation();
	inst.Position = vector.create(self.X, self.Y, self.Z);
	inst.Orientation = vector.create(rx, ry, rz);
	return inst;
end;

-- methods

CFrame.inverse = function(self)
	local px = -(self.r00*self.X + self.r10*self.Y + self.r20*self.Z);
	local py = -(self.r01*self.X + self.r11*self.Y + self.r21*self.Z);
	local pz = -(self.r02*self.X + self.r12*self.Y + self.r22*self.Z);
	return new(px, py, pz, self.r00, self.r10, self.r20, self.r01, self.r11, self.r21, self.r02, self.r12, self.r22);
end;

CFrame.pointToWorldSpace = function(self, v)
	return vector.create(self.r00*v.X + self.r01*v.Y + self.r02*v.Z + self.X, self.r10*v.X + self.r11*v.Y + self.r12*v.Z + self.Y, self.r20*v.X + self.r21*v.Y + self.r22*v.Z + self.Z);
end;

CFrame.pointToObjectSpace = function(self, v)
	return self:inverse():pointToWorldSpace(v);
end;

-- metamethods

CFrame.__index = function(self, b)

	if (b == 'rightVector') then
		return vector.create(self.r00, self.r10, self.r20);
	elseif (b == 'upVector') then
		return vector.create(self.r01, self.r11, self.r21);
	elseif (b == 'lookVector') then
		return vector.create(-self.r02, -self.r12, -self.r22);
	elseif (b == 'p' or b == 'Position') then
		return vector.create(self.X, self.Y, self.Z);
	elseif (CFrame[b]) then
		return CFrame[b];
	end;

	return nil;
end;

CFrame.__mul = function(self, b)
	if (getmetatable(b) == CFrame) then
		return new(self.r00*b.X + self.r01*b.Y + self.r02*b.Z + self.X, self.r10*b.X + self.r11*b.Y + self.r12*b.Z + self.Y, self.r20*b.X + self.r21*b.Y + self.r22*b.Z + self.Z, self.r00*b.r00 + self.r01*b.r10 + self.r02*b.r20, self.r00*b.r01 + self.r01*b.r11 + self.r02*b.r21, self.r00*b.r02 + self.r01*b.r12 + self.r02*b.r22, self.r10*b.r00 + self.r11*b.r10 + self.r12*b.r20, self.r10*b.r01 + self.r11*b.r11 + self.r12*b.r21, self.r10*b.r02 + self.r11*b.r12 + self.r12*b.r22, self.r20*b.r00 + self.r21*b.r10 + self.r22*b.r20, self.r20*b.r01 + self.r21*b.r11 + self.r22*b.r21, self.r20*b.r02 + self.r21*b.r12 + self.r22*b.r22);
	end;
	return self:pointToWorldSpace(b);
end;

CFrame.__tostring = function(self)
	return string.format('%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g', self.X, self.Y, self.Z, self.r00, self.r01, self.r02, self.r10, self.r11, self.r12, self.r20, self.r21, self.r22);
end;

return CFrame;