local Signal = require 'lib.signal'

local function buildObject(scene, container, key, objectTable)
    local args = objectTable.arguments
    if type(args) == 'function' then args = args(scene) end
    local object = require(objectTable.script)(args)
    if type(key) == 'string' then
        container:addAs(key, object)
    else
        container:add(object)
    end
end

local function build(src)
    local scene = require('core.GameScene'):new()
    local setupTable = require(src .. '.setup')()

    function scene:setup()
        -- setup properties
        for name, propertyTable in pairs(setupTable.properties or {}) do
            self:set(name, propertyTable)
        end

        -- create groups
        for name, groupTable in pairs(setupTable.groups or {}) do
            local group = scene:createGroup(name)
            if groupTable.init then
                groupTable.init(scene)
                groupTable.init = nil
            end
            -- build each object in the group
            for key, objectTable in pairs(groupTable) do
                buildObject(self, group, key, objectTable)
            end
        end

        -- create objects
        for key, objectTable in pairs(setupTable.objects or {}) do
            buildObject(self, self, key, objectTable)
        end

        -- register signals
        for event, funcs in pairs(setupTable.signals or {}) do
            for _, func in ipairs(funcs) do Signal.register(event, func) end
        end

        -- register update actions
        for _, updateAction in pairs(setupTable.updateActions or {}) do
            self:addUpdateAction(updateAction)
        end
    end

    return scene

end

return {build = build}
