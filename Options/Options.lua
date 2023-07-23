-- [[ Namespaces ]] --
local _, addon = ...;
addon.Options = {}; -- Will be overwritten in Load (intended)
local options = addon.Options;
options.OptionsTables = {};

if addon.IsWrathClassic then
    options.WidthMultiplier = 1;
else
    options.WidthMultiplier = 200 / 170; -- 170 comes from AceConfigDialog-3.0.lua, 200 fits better on the screen in DF
end

options.OptionsTable = {
    name = addon.Metadata.Title,
    type = "group",
    childGroups = "tab",
    args = {}
};

local function Open()
    if addon.IsWrathClassic then
        InterfaceAddOnsList_Update(); -- This way the correct category will be shown when calling InterfaceOptionsFrame_OpenToCategory
        InterfaceOptionsFrame_OpenToCategory(addon.Metadata.Title);
        for _, button in next, InterfaceOptionsFrameAddOns.buttons do
            if button.element and button.element.name == addon.Metadata.Title and button.element.collapsed then
                OptionsListButtonToggle_OnClick(button.toggle);
                break;
            end
        end
        return;
    end

    Settings.GetCategory(addon.Metadata.Title).expanded = true;
    Settings.OpenToCategory(addon.Metadata.Title, true);
end

function options.Load()
    addon.Options = LibStub("AceDB-3.0"):New("KrowiMFE_Options", options.Defaults, true);
    addon.Options.WidthMultiplier = options.WidthMultiplier;
    addon.Options.Open = Open;
    addon.Options.db = addon.Options.profile;

    for _, optionsTable in next, options.OptionsTables do
        optionsTable.RegisterOptionsTable();
    end

    for _, optionsTable in next, options.OptionsTables do
        optionsTable.PostLoad();
    end
end

string["InjectAddonName_KMFE"] = function(str)
    return str:ReplaceVars{addonName = addon.Metadata.Title};
end

string["AddDefaultValueText_KMFE"] = function(self, valuePath, values)
    local value = options.Defaults.profile;
    local pathParts = strsplittable(".", valuePath);
    for _, part in next, pathParts do
        part = tonumber(part) and tonumber(part) or part;
        value = value[part];
    end
    if type(value) == "boolean" then
        value = value and addon.L["Checked"] or addon.L["Unchecked"];
    end
    if values then
        value = values[value];
    end
    return self .. "\n\n" .. addon.L["Default value"] .. ": " .. tostring(value);
end

string["AddReloadRequired_KMFE"] = function(self)
    return self .. "\n\n" .. addon.L["Requires a reload"];
end