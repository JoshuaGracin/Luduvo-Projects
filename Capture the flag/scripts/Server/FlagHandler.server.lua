return function(core: Instance, shared: typeof({}), self: typeof({}))
    local CFrame = require("../Modules/CFrame.client")
    local logger = require('../Modules/Logger.client');
    local TeamSelection = shared.TeamSelection;
    
    local Storage = core:FindFirstChild('Storage');
    local Workspace = core:FindFirstChild('Workspace');

    local flagPrim = Storage:FindFirstChild('Flag');

    local redPoint = Workspace:FindFirstChild('Points'):FindFirstChild('Red');
    local bluePoint = Workspace:FindFirstChild('Points'):FindFirstChild('Blue');

    local SetRenderDisabled = function(a: Instance)
        a:AddComponent('RenderDisabled');
        for i, v in a:GetChildren() do
            v:AddComponent('RenderDisabled');
        end;
    end;

    local MakeFlag = function(color: vector?, pos: vector?)
        local flag = flagPrim:Clone();
        flag.Parent = Workspace;
        local vis: Instance? = nil;

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

        flag.Equipped:Connect(function(plr: Instance)
            SetRenderDisabled(flag);
            if (vis) then
                return;
            end;

            local char = plr.Character;
            vis = flagPrim:Clone();
            flag.Other = vis;

            if (color) then
                vis:FindFirstChild('Flag').Color = color;
            end;

            (CFrame.fromInstance(char) * CFrame.new(0, 0, 0.5) * (CFrame.Angles(0, math.rad(180), 0) * CFrame.Angles(0, 0, math.rad(45)))):toInstance(vis);
            vis.Parent = char;
            vis.Other = char;
        end);

        return flag;
    end;

    local Intersects = function(a: Instance, b: Instance)
        if (not a or not a:IsAlive() or not b or not b:IsAlive()) then
            return false;
        end;

        local apos, bpos = a.Position, b.Position;
        return (math.abs(bpos.X - apos.X) <= 6 and math.abs(bpos.Y - apos.Y) <= 6 and math.abs(bpos.Z - apos.Z) <= 6);
    end;

    local redFlag, blueFlag = MakeFlag(redPoint.Color, redPoint.Position), MakeFlag(bluePoint.Color, bluePoint.Position);
    local redHolder, blueHolder = nil, nil;

    self.Init = function()
        local players = TeamSelection.Players;

        task.defer(function()
            while (true) do
                task.wait(0.016);

                for team = 1, 2 do
                    local flag = if (team == 1) then redFlag else blueFlag;
                    local point = if (team == 1) then bluePoint else redPoint;
                    local holder = if (team == 1) then redHolder else blueHolder;

                    for i: Instance, v in players do
                        local character = v.Character;
                        if ((not character or not character:IsAlive()) or v.Team == team) then
                            continue;
                        end;

                        -- if said team is at there flag make sure they cant pick it up
                        if (Intersects(character, point)) then
                            if (character:HasComponent('Backpack')) then
                                character:RemoveComponent('Backpack');
                            end;
                        else
                            if (not character:HasComponent('Backpack')) then
                                character:AddComponent('Backpack');
                            end;
                        end;
                    end;

                    -- respawn flag
                    if (not flag or not flag:IsAlive()) then

                        local spawn = if (team == 1) then redPoint else bluePoint;
                        flag = MakeFlag(spawn.Color, spawn.Position);

                        if (team == 1) then
                            redFlag = flag;
                            redHolder = nil;
                        else
                            blueFlag = flag;
                            blueHolder = nil;
                        end;

                        logger('Flag respawned');
                        continue;
                    end;

                    -- is being held else spin
                    if (not holder or not holder:IsAlive()) then
                        local a = flag.Parent;
                        if (a and a.Parent) then
                            if (team == 1) then
                                redHolder = a.Parent;
                            else
                                blueHolder = a.Parent;
                            end;

                            logger(`Got holder for {team}, {a.Parent}`);
                        end;
                        
                        -- spin flag :>
                        (CFrame.fromInstance(flag) * CFrame.Angles(0, math.rad(1.5), 0)):toInstance(flag);
                        continue;
                    end;

                    -- win for said team
                    if (flag and flag:IsAlive() and Intersects(flag, point)) then
                        logger(`{team} got a point`);
                        if (flag.Other) then
                            flag.Other:Destroy();
                        end;
                        flag:Destroy();
                    end;
                    
                end;
            end;
        end);
    end;

end;