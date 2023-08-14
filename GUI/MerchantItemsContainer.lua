-- [[ Namespaces ]] --
local _, addon = ...;
addon.Gui.MerchantItemsContainer = {};
local merchantItemsContainer = addon.Gui.MerchantItemsContainer;

merchantItemsContainer.FirstOffsetX = 11;
merchantItemsContainer.FirstOffsetY = -69;
merchantItemsContainer.OffsetX = 12;
merchantItemsContainer.OffsetMerchantInfoY = 8;
merchantItemsContainer.OffsetBuybackInfoY = 15;
merchantItemsContainer.DefaultMerchantInfoNumRows = 5;
merchantItemsContainer.DefaultMerchantInfoNumColumns = 2;
merchantItemsContainer.DefaultBuybackInfoNumRows = 6;
merchantItemsContainer.DefaultBuybackInfoNumColumns = 2;
merchantItemsContainer.ItemWidth, merchantItemsContainer.ItemHeight = MerchantItem1:GetSize();

local infoNumRows, infoNumColumns = 0, 0;
local itemSlotTable = {};
for i = 1, 12, 1 do
	tinsert(itemSlotTable, _G["MerchantItem" .. i]);
end

function merchantItemsContainer:HideAll()
    for _, itemSlot in next, itemSlotTable do
		itemSlot:Hide();
	end
end

local function GetItemSlot(index)
	if itemSlotTable[index] then
		return itemSlotTable[index];
	end
	local frame = CreateFrame("Frame", "MerchantItem" .. index, MerchantFrame, "MerchantItemTemplate");
	itemSlotTable[index] = frame;
	return frame;
end

function merchantItemsContainer:LoadMaxNumItemSlots()
    local maxNumRows = math.max(addon.Options.db.profile.NumRows, self.DefaultBuybackInfoNumRows);
    local maxNumColumns = math.max(addon.Options.db.profile.NumColumns, self.DefaultBuybackInfoNumColumns);
    local maxNumItems = maxNumRows * maxNumColumns;
    if #itemSlotTable < maxNumItems then
        for i = 1, maxNumItems, 1 do
            local itemSlot = GetItemSlot(i);
            itemSlot:Hide();
        end
    end
    MERCHANT_ITEMS_PER_PAGE = addon.Options.db.profile.NumRows * addon.Options.db.profile.NumColumns;
end

function merchantItemsContainer:PrepareMerchantInfo()
    infoNumRows, infoNumColumns = addon.Options.db.profile.NumRows, addon.Options.db.profile.NumColumns;
end

function merchantItemsContainer:PrepareBuybackInfo()
    infoNumRows, infoNumColumns = self.DefaultBuybackInfoNumRows, self.DefaultBuybackInfoNumColumns;
end

function merchantItemsContainer:PrepareInfo()
    if MerchantFrame.selectedTab == 1 then
		self:PrepareMerchantInfo();
	else
		self:PrepareBuybackInfo();
	end
end

hooksecurefunc("MerchantFrame_UpdateFilterString", function()
    if not addon.Options.db then
        return;
    end

	merchantItemsContainer:PrepareInfo();
end);

function merchantItemsContainer:DrawItemSlot(index, row, column, offsetX, offsetY)
    local itemSlot = GetItemSlot(index);
    local calculatedOffsetX = self.FirstOffsetX + (column - 1) * (offsetX + self.ItemWidth);
    local calculatedOffsetY = self.FirstOffsetY - (row - 1) * (offsetY + self.ItemHeight);
    itemSlot:ClearAllPoints();
    itemSlot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", calculatedOffsetX, calculatedOffsetY);
    itemSlot:Show();
end

function merchantItemsContainer:DrawItemSlots(numRows, numColumns, offsetX, offsetY)
    if addon.Options.db and addon.Options.db.profile.Direction == addon.L["Columns first"] then
        for row = 1, numRows, 1 do
            for column = 1, numColumns, 1 do
                local index = (column - 1) * numRows + row;
                self:DrawItemSlot(index, row, column, offsetX, offsetY);
            end
        end
    else
        for column = 1, numColumns, 1 do
            for row = 1, numRows, 1 do
                local index = (row - 1) * numColumns + column;
                self:DrawItemSlot(index, row, column, offsetX, offsetY);
            end
        end
    end
end

function merchantItemsContainer:HideRemainingItemSlots(startIndex)
    local numItemSlots = #itemSlotTable;
    for i = startIndex, numItemSlots, 1 do
        itemSlotTable[i]:Hide();
    end
end

function merchantItemsContainer:DrawMerchantBuyBackItem(show)
    if show then
        MerchantBuyBackItem:ClearAllPoints();
        MerchantBuyBackItem:SetPoint("BOTTOMLEFT", MerchantFrameBottomLeftBorder, "BOTTOMLEFT", 205, 7);
	    MerchantBuyBackItem:Show();
	    UndoFrame:Show();
    else
        MerchantBuyBackItem:Hide();
	    UndoFrame:Hide();
    end
end

function merchantItemsContainer:DrawForMerchantInfo()
	self:DrawItemSlots(infoNumRows, infoNumColumns, self.OffsetX, self.OffsetMerchantInfoY);
    self:HideRemainingItemSlots(infoNumRows * infoNumColumns + 1);
	self:DrawMerchantBuyBackItem(true);
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
    merchantItemsContainer:DrawForMerchantInfo();
end);

function merchantItemsContainer:DrawForBuybackInfo()
	self:DrawItemSlots(infoNumRows, infoNumColumns, self.OffsetX, self.OffsetBuybackInfoY);
    self:HideRemainingItemSlots(infoNumRows * infoNumColumns + 1);
	self:DrawMerchantBuyBackItem(false);
end
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
    merchantItemsContainer:DrawForBuybackInfo();
end);