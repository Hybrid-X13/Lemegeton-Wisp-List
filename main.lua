local mod = RegisterMod("Lemegeton Wisp List", 1)

local game = Game()

local COLUMNS = 4
local SPRITE_SCALE = 16

local showList = false
local verticalOffset = 140
local extraHUD = Options.ExtraHUDStyle

local itemSprite = Sprite()
itemSprite:Load("gfx/005.100_collectible.anm2", true)
itemSprite:Play("ShopIdle")

local function GetScreenSize() --Made by Kilburn
    local room = game:GetRoom()
    local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
    
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

local function GetVisibleWisps()
	local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)
	local visibleWisps = {}

	for _, wisp in pairs(itemWisps) do
		if wisp.Visible then
			table.insert(visibleWisps, wisp)
		end
	end

	return visibleWisps
end

function mod:postRender()
	if not showList then return end
	
	local sprites = {}
	local topRight = Vector(GetScreenSize().X - (24 * Options.HUDOffset), 0)
	local itemWisps = GetVisibleWisps()
	
	for i, wisp in pairs(itemWisps) do
		local itemID = wisp.SubType
		local gfx = Isaac.GetItemConfig():GetCollectible(itemID).GfxFileName
		--Shoutout to Wofsauge for making this formula that I would've never figured out on my own
		--Used from ReHUD: https://steamcommunity.com/sharedfiles/filedetails/?id=1906405707
		local pos = topRight + Vector((SPRITE_SCALE / 2 - SPRITE_SCALE * COLUMNS) + SPRITE_SCALE * ((i - 1) % COLUMNS), verticalOffset + SPRITE_SCALE * math.floor((i - 1) / COLUMNS))

		itemSprite:Render(pos, Vector.Zero, Vector.Zero)
		itemSprite:ReplaceSpritesheet(1, gfx)
		itemSprite:LoadGraphics()
		itemSprite:Update()
		table.insert(sprites, itemSprite)
		
		sprites[i].Color = Color(1, 1, 1, 1, 0.15, 0, 0.15)
		sprites[i].Scale = Vector(0.5, 0.5)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.postRender)

function mod:postPEffectUpdate(player)
	local itemWisps = GetVisibleWisps()
	
	if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
	and #itemWisps > 0
	then
		if not showList then
			extraHUD = Options.ExtraHUDStyle
		end
		
		Options.ExtraHUDStyle = 0
		showList = true

		if Input.IsButtonPressed(Keyboard.KEY_MINUS, 0) then
			verticalOffset = verticalOffset + 1
		elseif Input.IsButtonPressed(Keyboard.KEY_EQUAL, 0) then
			verticalOffset = verticalOffset - 1
		end
	else
		if showList then
			showList = false
			
			if extraHUD > 0
			and Options.ExtraHUDStyle ~= extraHUD
			then
				Options.ExtraHUDStyle = extraHUD
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.postPEffectUpdate)