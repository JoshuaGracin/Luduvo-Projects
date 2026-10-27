local logger = require('../Modules/Logger.client');

local players = game.Players;

const TEAM_ID_RED = 1;
const TEAM_ID_BLUE = 2;

local redCount = 0;
local blueCount = 0;

local Plrs = {};
players.PlayerAdded:Connect(function(plr: Instance)
    if (not plr:HasComponent('Team')) then
        plr:AddComponent('Team');
    end;
    local team = 0;
    if (redCount <= blueCount) then
        team = TEAM_ID_RED;
		redCount += 1;
	else
		team = TEAM_ID_BLUE;
		blueCount += 1;
	end
    plr.TeamId = team;

    Plrs[plr] = {
        Team = team,
        Character = nil;
    };

    logger(`Added Player: {plr.Name}, {if (team == TEAM_ID_RED) then 'Red' else 'Blue'}`);
end);

players.PlayerRemoving:Connect(function(plr: Instance)
    local data = Plrs[plr];
    if (not data) then
        return;
    end;

    Plrs[plr] = nil;

    logger(`Removed Player: {plr.Name}`);
end);

players.CharacterAdded:Connect(function(plr, char)
    local data = Plrs[plr];
    if (not data) then
        return;
    end;

    data.Character = char;
    logger(`Character Added: {plr.Name}`);
end);

players.CharacterDied:Connect(function(plr, char)
    local data = Plrs[plr];
    if (not data) then
        return;
    end;

    data.Character = nil;
    logger(`Character Died: {plr.Name}`);
end)