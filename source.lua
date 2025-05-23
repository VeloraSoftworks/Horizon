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
local DefaultProperties = {
    Tracer = {Thickness = 1, Color = Color3.new(1, 1, 1)},
    Box = {Thickness = 2, Color = Color3.new(1, 1, 1)}
}

-- Object Creation
local function createESPObject(instanceType, class, settings)
    local instance = type(instanceType) == 'string' and Drawing.new(instanceType) or instanceType

    local object = {
        Instance = instance,
        Type = type(instanceType) == 'string' and instanceType or instance.ClassName,
        Class = class,
        Active = settings.Active or true,
    }

    if settings.Properties then
        for i, v in pairs(settings.Properties) do
            instance[i] = v
        end

        settings.Properties = nil
    else
        for i, v in pairs(DefaultProperties[object.Class]) do
            instance[i] = v
        end
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

        for i = #Objects[class], 1, -1 do
            if Objects[class][i] == self then
                table.remove(Objects[class], i)
                break
            end
        end
    end

    if not Objects[class] then
        Objects[class] = {}
    end

    table.insert(Objects[class], object)
    return object
end

-- Create Instances
function Horizon:CreateTracer(settings)
    return createESPObject('Line', 'Tracer', settings)
end

function Horizon:CreateBox(settings)
    return createESPObject('Square', 'Box', settings)
end

-- Player & Character Management
function Horizon:GetCharacter(player)
    return player.Character, nil -- character, rootpart
end

Players.PlayerRemoving:Connect(function(player)
    for _, classObjects in pairs(Objects) do
        for i = #classObjects, 1, -1 do
            if classObjects[i].Target == player then
                classObjects[i]:Destroy()
            end
        end
    end
end)

-- RenderStepped
RunService.RenderStepped:Connect(function()
    for _, objectList in pairs(Objects) do
        for class, object in pairs(objectList) do
            if object.Active then
                if class == 'Box' then

                elseif class == 'Tracer' then
                    local Character, Root = Horizon.GetCharacter(object.Target)
                    Root = Root or Character and Character:FindFirstChild('HumanoidRootPart')
                    if not Root then
                        object.Instance.Visible = false
                        continue
                    end

                    local Vector, OnScreen = Camera:WorldToViewportPoint(Root.Position)

                    if OnScreen then
                        object.Instance.Visible = true
                    else
                        object.Instance.Visible = false
                        continue
                    end

                    object.From = object.Origin ~= 'Mouse' and Vector2.new(Camera.ViewportSize.X / 2, object.Origin == 'Top' and 0 or object.Origin == 'Bottom' and Camera.ViewportSize.Y or Camera.ViewportSize.Y / 2) or Mouse.Position
                    object.To = Vector
                end
            else
                object.Instance.Visible = false
            end
        end
    end
end)

-- Final setup
function Horizon:GetObjects(class)
    return class and Objects[class] or Objects
end

return Horizon
