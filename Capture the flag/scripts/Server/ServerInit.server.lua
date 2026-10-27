local core = self.Parent.Parent;
local shared = {};

local children = self:GetChildren();
for i = 1, #children do
    shared[children[i].Name] = {};
end;

for i = 1, #children do
    local module = children[i].Name;
    local s, func = pcall(require, `./{module}.server`);
    if (not s) then
        continue;
    end;
    func(core, shared, shared[module]);
end;

for i, v in shared do
    if (type(v) ~= 'table' or not rawget(v, 'PreInit')) then
        continue;
    end;
    rawget(v, 'PreInit')();
end;

for i, v in shared do
    if (type(v) ~= 'table' or not rawget(v, 'Init')) then
        continue;
    end;
    rawget(v, 'Init')();
end;

for i, v in shared do
    if (type(v) ~= 'table' or not rawget(v, 'LateInit')) then
        continue;
    end;
    rawget(v, 'LateInit')();
end;