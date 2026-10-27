return function(core: Instance, shared: typeof({}), self: typeof({}))
    local logger = require('../Modules/Logger.client');
    self.Players = {};

    const TEAM_ID_RED = 1;
    const TEAM_ID_BLUE = 2;

    local players = self.Players;

    local redCount, blueCount = 0, 0;
    game.Players.PlayerAdded:Connect(function(plr: Instance)
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

        players[plr] = {
            Team = team,
            Character = nil;
        };

        logger(`Added Player: {plr.Name}, {if (team == TEAM_ID_RED) then 'Red' else 'Blue'}`);
    end);

    game.Players.PlayerRemoving:Connect(function(plr: Instance)
        local data = players[plr];
        if (not data) then
            return;
        end;

        players[plr] = nil;

        logger(`Removed Player: {plr.Name}`);
    end);

    game.Players.CharacterAdded:Connect(function(plr, char)
        local data = players[plr];
        if (not data) then
            return;
        end;

        data.Character = char;
        logger(`Character Added: {plr.Name}`);
    end);

    game.Players.CharacterDied:Connect(function(plr, char)
        local data = players[plr];
        if (not data) then
            return;
        end;

        data.Character = nil;
        logger(`Character Died: {plr.Name}`);
    end);
end;