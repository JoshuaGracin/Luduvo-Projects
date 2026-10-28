local logger = {};
logger.__index = logger;

logger.__call = function(_, text, _type)
    return print(`[{debug.info(2, "s"):gsub("scripts/", ""):gsub(".server", ""):gsub(".client", "")}] {string.upper(_type or "INFO")}: {text}`);
end;

logger.Log = function(text, _type)
    return logger(text, _type);
end;

logger.Assert = function(a, _type, arg)
    if (typeof(a) == _type) then
        return;
    end;

    return error(`[{debug.info(2, "s"):gsub("scripts/", ""):gsub(".server", ""):gsub(".client", "")}] "ASSERT": {`invalid argument #{arg or 'undefined'} to '{debug.info(2, 'n')}' ({_type} expected, got {typeof(a)})`}`, 2);
end;

return setmetatable({}, logger);