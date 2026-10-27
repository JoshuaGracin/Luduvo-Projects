return function(core: Instance, shared: typeof({}), self: typeof({}))
    local CFrame = require("../Modules/CFrame.client")
    local logger = require('../Modules/Logger.client');
    local TeamSelection = shared.TeamSelection;
    
    local Storage = core:FindFirstChild('Storage');
    local Workspace = core:FindFirstChild('Workspace');

    local flagPrim = Storage:FindFirstChild('Flag');

    local redPoint = Workspace:FindFirstChild('Points'):FindFirstChild('Red');
    local bluePoint = Workspace:FindFirstChild('Points'):FindFirstChild('Blue');

    local MakeFlag = function(color: vector?, pos: vector?)
        local flag = flagPrim:Clone();
        flag.Parent = Workspace;

        if (pos) then
            flag.Position = pos;
        end;

        if (color) then
            flag:FindFirstChild('Flag').Color = color;
        end;

        if (not flag:HasComponent('Tool')) then
            flag:AddComponent('Tool');
        end;
    
        flag.Tool.noDrop = 1;

        return flag;
    end;

    local redFlag, blueFlag = MakeFlag(redPoint.Color, redPoint.Position), MakeFlag(bluePoint.Color, bluePoint.Position);
    local redHolder, blueHolder = nil, nil;

    task.defer(function()
        while (true) do
            local dt = task.wait(0.016);

            for team = 1, 2 do
                local flag = if (team == 1) then redFlag else blueFlag;
                local holder = if (team == 1) then redHolder else blueHolder;

                -- respawn flag
                if (not flag or not flag:IsAlive()) then

                    if (holder and holder:IsAlive()) then
                        holder:RemoveComponent('Backpack');
                    end;
                    
                    local point = if (team == 1) then redPoint else bluePoint;
                    flag = MakeFlag(point.Color, point.Position);

                    if (team == 1) then
                        redFlag = flag;
                        redHolder = nil;
                    else
                        blueFlag = flag;
                        blueHolder = nil;
                    end;
                    
                    continue;
                end;

                if (not holder or not holder:IsAlive()) then
                    local a = flag.Parent;
                    if (a and a.Parent) then
                        if (team == 1) then
                            redHolder = a.Parent;
                        else
                            blueHolder = a.Parent;
                        end;
                    end;
                    
                    -- spin flag :> idk
                    (CFrame.fromInstance(flag) * CFrame.Angles(0, math.rad(2), 0)):toInstance(flag);

                    continue;
                end;

            end;
        end;
    end);

end;