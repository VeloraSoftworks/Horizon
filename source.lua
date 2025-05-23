-- Loading Dependencies
loadstring(game:HttpGet('https://raw.githubusercontent.com/VeloraSoftworks/Dependencies/refs/heads/main/iris%20protect.lua'))()

-- Services & Horizon Variables
local RunService = game:GetService('RunService')
local Camera = workspace.CurrentCamera
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Horizon = {}
local Objects = {}

-- Object Creation
local function createESPObject(instanceType, class, settings)
    local instance = type(instanceType) == 'string' and Drawing.new(instanceType) or instanceType

    local object = {
        Instance = instance,
        Type = type(instanceType) == 'string' and instanceType or instance.ClassName,
        Active = settings.Active or true,
    }

    if settings.Properties then
        for i, v in pairs(settings.Properties) do
            instance[i] = v
        end

        settings.Properties = nil
    end

    for i, v in pairs(settings) do
        object[i] = v
    end

    function object:Destroy()
        self.Active = false

        if self.Instance then
            self.Instance.Visible = false

            if self.Instance.Destroy then
                self.Instance:Destroy()
            end
        end

        for i = #Objects, 1, -1 do
            if Objects[i] == self then
                table.remove(Objects, i)
                break
            end
        end
    end

    table.insert(Objects, object)
    return object
end

-- Create Instances
function Horizon:AddTracer(settings)
    -- from: center, bottom, top, mouse
    return createESPObject('Line', 'Tracer', settings)
end

function Horizon:CreateBox(settings)
    return createESPObject('Square', 'Box', settings)
end

-- Player & Character Management
Horizon.GetCharacter = function(player)
    return player.Character, nil -- character, rootpart
end

Players.PlayerRemoving:Connect(function(player)
    for i = #Objects, 1, -1 do
        local obj = Objects[i]
        if obj.Target == player then
            obj:Destroy()
        end
    end
end)

-- RenderStepped
RunService.RenderStepped:Connect(function()
    for i, object in pairs(Objects) do
        if object.Active then
            if object.Class == 'Box' then
                local Character, Root = Horizon.GetCharacter(object.Target)
                Root = Root or Character and Character:FindFirstChild('HumanoidRootPart')
                if not Root then return end

            elseif object.Class == 'Tracer' then
                local Character, Root = Horizon.GetCharacter(object.Target)
                Root = Root or Character and Character:FindFirstChild('HumanoidRootPart')
                if not Root then return end

                local Vector, OnScreen = Camera:WorldToViewportPoint(Root.Position)

                if OnScreen then
                    object.Instance.Visible = true
                else
                    object.Instance.Visible = false
                    return
                end

                object.From = object.Origin ~= 'Mouse' and Vector2.new(Camera.ViewportSize.X / 2, object.Origin == 'Top' and 0 or object.Origin == 'Bottom' and Camera.ViewportSize.Y or Camera.ViewportSize.Y / 2) or Mouse.Position
                object.To = Vector
            end
        else
            object.Instance.Visible = false
        end
    end
end)

return Horizon
