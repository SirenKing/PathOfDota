var hud = GetDotaHud();
var contextPanel = $.GetContextPanel();

var centerHeroHud = hud.FindChildTraverse("center_with_stats");
var centerBlock = hud.FindChildTraverse("center_block");

/*** INVENTORY *****/
var inventoryPanel = hud.FindChildTraverse("inventory");
var inventoryItemsPanel = inventoryPanel.FindChildTraverse("inventory_items");
var inventoryContainer = inventoryPanel.FindChildTraverse("inventory_container");

/*** ABILITIES *****/
const CenterBlockAbilitiesParent = hud.FindChildTraverse("AbilitiesAndStatBranch");
const abilitiesPanel = CenterBlockAbilitiesParent.FindChildTraverse("abilities");

var player = Players.GetLocalPlayer();
var heroName = Players.GetPlayerSelectedHero( player );
const localHeroIndex = Players.GetPlayerHeroEntityIndex( player );
// var data = CustomNetTables.GetTableValue( "gem_slots", heroName + player );

StartWaitForAbilityPanelLoad();

function StartWaitForAbilityPanelLoad() {
    $.Schedule(0.5, function() {
        if ( abilitiesPanel.FindChildTraverse( "Ability0" )!==null ) {
            PinGemSlots();
            UpdateGemSlotsPanelTimed()
        } else {
            StartWaitForAbilityPanelLoad();
        }
    });
}

function UpdateGemSlotsPanelTimed() {
    $.Schedule(0.25, function() {
        let unitIndex = Players.GetLocalPlayerPortraitUnit();
        UpdateGemSlots(unitIndex);
        UpdateGemSlotsPanelTimed();
    });
}

/**
 * HOOKS
 */

GameEvents.Subscribe("dota_player_learned_ability", function() {  // For when the local player selects a NEW UNIT. Check if the unit is a hero, then update the backpack panel is needed.
	let unitIndex = Players.GetLocalPlayerPortraitUnit();
    PinGemSlots();
    UpdateGemSlots(unitIndex)
});

GameEvents.Subscribe("dota_player_update_query_unit", function() {  // For when the local player selects a NEW UNIT. Check if the unit is a hero, then update the backpack panel is needed.
	let unitIndex = Players.GetLocalPlayerPortraitUnit();
    // $.Msg( "Player queried a unit..." );
    PinGemSlots();
    UpdateGemSlots(unitIndex)
});

GameEvents.Subscribe("dota_player_update_selected_unit", function() {  // For when the local player selects a NEW UNIT. Check if the unit is a hero, then update the backpack panel is needed.
	let unitIndex = Players.GetLocalPlayerPortraitUnit();
    // $.Msg( "Player queried a unit..." );
    PinGemSlots();
    UpdateGemSlots(unitIndex)
});

GameEvents.Subscribe("player_reconnected", function() {  // For when the local player selects a NEW UNIT. Check if the unit is a hero, then update the backpack panel is needed.
	let unit = Players.GetLocalPlayerPortraitUnit();
    PinGemSlots();
});

/**
 * FUNCTIONS
 */

function GetDotaHud() {
    var p = $.GetContextPanel();
    while (p !== null && p.id !== 'Hud') {
        p = p.GetParent();
    }
    if (p === null) {
        throw new HudNotFoundException('Could not find Hud root as parent of panel with id: ' + $.GetContextPanel().id);
    } else {
        return p;
    }
}

function PinGemSlots() {
    // var slotParent = ability0.FindChildTraverse( "ButtonAndLevel" );
    var ability0 = abilitiesPanel.FindChildTraverse( "Ability0" );
    var gemSlot0 = null;
    if (ability0!=undefined ) {   gemSlot0 =  ability0.FindChildTraverse( "gem_slot0" ) };
    
    var ability1 = abilitiesPanel.FindChildTraverse( "Ability1" );
    var gemSlot1 = null;
    if (ability1!=undefined ) {   gemSlot1 =  ability1.FindChildTraverse( "gem_slot1" ) };
    
    var ability2 = abilitiesPanel.FindChildTraverse( "Ability2" );
    var gemSlot2 = null;
    if (ability2!=undefined ) {   gemSlot2 =  ability2.FindChildTraverse( "gem_slot2" ) };
    
    var ability3 = abilitiesPanel.FindChildTraverse( "Ability3" );
    var gemSlot3 = null;
    if (ability3!=undefined ) {   gemSlot3 =  ability3.FindChildTraverse( "gem_slot3" ) };
    
    var ability4 = abilitiesPanel.FindChildTraverse( "Ability4" );
    var gemSlot4 = null;
    if (ability4!=undefined ) {   gemSlot4 =  ability4.FindChildTraverse( "gem_slot4" ) };
    
    var ability5 = abilitiesPanel.FindChildTraverse( "Ability5" );
    var gemSlot5 = null;
    if (ability5!=undefined ) {   gemSlot5 =  ability5.FindChildTraverse( "gem_slot5" ) };

    if (gemSlot0==undefined ) {
        gemSlot0 = GenerateGemSlot( ability0, 0 );
    }

    if (gemSlot1==undefined ) {
        gemSlot1 = GenerateGemSlot( ability1, 1 );
    }

    if (gemSlot2==undefined ) {
        gemSlot2 = GenerateGemSlot( ability2, 2 );
    }

    if (gemSlot3==undefined ) {
        gemSlot3 = GenerateGemSlot( ability3, 3 );
    }

    if (gemSlot4==undefined ) {
        gemSlot4 = GenerateGemSlot( ability4, 4 );
    }

    if (gemSlot5==undefined ) {
        gemSlot5 = GenerateGemSlot( ability5, 5 );
    }
}

function GenerateGemSlot( panel, num ) {

    if (panel!==null) {
        var gemSlot = $.CreatePanel( "Panel", panel, "gem_slot" + num );
        // gemSlot.id = "gem_slot" + num;
        RegisterDragDropEvents(gemSlot);
        gemSlot.keyBindStr = Game.GetKeybindForAbility( num )

        gemSlot.style["width"] = "36px";
        gemSlot.style["height"] = "26px";
        gemSlot.style["background-color"] = "gradient( linear, 0% 0%, 0% 100%, from(#242424aa), to(#242424FF) )";
        gemSlot.style["horizontal-align"] = "center";
        gemSlot.style["margin"] = "60px 0px 0px 0px";
        gemSlot.style["background-size"] = "100%";
        gemSlot.style["border"] = "1px solid black";

        return gemSlot
    };
}

function UpdateGemSlots(unitIndex) { //Find the local player's unit query. If it is a hero, update the backpack panel.

    // var unitName = Entities.GetUnitName(unitIndex);
    // var data = CustomNetTables.GetTableValue( "gem_slots", unitIndex );
    // $.Msg( "Updating gem slots..." );
    
    for (let i = 0; i < 6; i++) {
        var abilitiesPanel = CenterBlockAbilitiesParent.FindChildTraverse("abilities");
        // $.Msg( abilitiesPanel.id );
        var abilityPanel = abilitiesPanel.FindChildTraverse( "Ability" + i );
        // $.Msg( abilityPanel.id );
        var gemSlot = abilityPanel.FindChildTraverse( "gem_slot" + i );
        // var abilityIndex = Entities.GetAbility( unitIndex, i );
        // $.Msg( Abilities.GetAbilityName( abilityIndex ) + " is in gem_slot" + i );
        UpdateGemSlotImageAndEvents( gemSlot, unitIndex )
    }
    
}

function UpdateGemSlotImageAndEvents( gem_panel, unitIndex ) {

    if (gem_panel!==null) {
        var panelID = gem_panel.id;
        var slotNum = panelID.replace( "gem_slot", "");
        var ability_index = GetNthVisibleAbility( unitIndex, slotNum );

        if (ability_index!==undefined) {

            var data = CustomNetTables.GetTableValue( "gem_slots", unitIndex );
            // $.Msg( "Ability " + ability_index + " is " + Abilities.GetAbilityName( ability_index ) );

            if ( data ) {
                var pattern_name = data[ability_index];
                var gem_name = "item_ability_gem_" + pattern_name;
                var itemTexturePath = "s2r://panorama/images/items/" + gem_name.replace('item_','') + ".png";
                gem_panel.style["background-image"] = "url('" + itemTexturePath + "')";

                gem_panel.SetPanelEvent("onmouseover", function() {
                    gem_panel.style["brightness"] = "1.7";
                    $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", gem_panel, gem_name, unitIndex );
                });

                gem_panel.SetPanelEvent("onmouseout", function() {
                    gem_panel.style["brightness"] = "1";
                    $.DispatchEvent("DOTAHideAbilityTooltip", gem_panel);
                });
            } else {
                gem_panel.style["background-image"] = "none";

                gem_panel.SetPanelEvent("onmouseover", function() {
                    gem_panel.style["brightness"] = "1.7";
                });

                gem_panel.SetPanelEvent("onmouseout", function() {
                    gem_panel.style["brightness"] = "1";
                });

            }
        }

    } else {
        // $.Msg( "gem_slot panel was not found" );
    }
    
}

function OnDragDrop(targetPanel, draggedPanel) {
    // var ownerHeroIndex = Items.GetPurchaser( draggedPanel.contextEntityIndex );
    var localQueriedHero = Players.GetLocalPlayerPortraitUnit(player);
    var localPlayerHeroIndex = Players.GetPlayerHeroEntityIndex(player);
    var heroPlayerOwnerID = Entities.GetPlayerOwnerID( localQueriedHero );
    var isControlledByLocalPlayer = Entities.IsControllableByPlayer( localQueriedHero, player );
    var isABot = Players.IsValidPlayerID( heroPlayerOwnerID );

    // $.Msg( isABot );
    // $.Msg( isControlledByLocalPlayer );

    if ( draggedPanel.itemname.match("item_ability_gem") && (isControlledByLocalPlayer || isABot )) {
        // $.Msg("Moving ability gem to special slot");
        var textureName = Abilities.GetAbilityTextureName( draggedPanel.contextEntityIndex );
        // var itemTexturePath = "s2r://panorama/images/items/" + textureName.replace('item_','') + ".png";
        // targetPanel.style["background-image"] = "url('" + itemTexturePath + "')";
        // targetPanel.itemname = draggedPanel.itemname;
        // targetPanel.heroindex = localQueriedHero;
        var targetPanelID = targetPanel.id;
        var slotNum = targetPanelID.replace( "gem_slot", "");
        var ability_index = GetNthVisibleAbility( localQueriedHero, parseInt( slotNum ) );
        // var ability_index = Entities.GetAbility( localQueriedHero, parseInt( slotNum ) );
        // $.Msg( ability_index + " ability name is " + Abilities.GetAbilityName( ability_index ) );

        GameEvents.SendCustomGameEventToServer( "gem_slot_assigned", { "item_index" : draggedPanel.contextEntityIndex, "hero_index" : localQueriedHero, "ability_index" : ability_index }); // 

        targetPanel.SetPanelEvent("onmouseover", function() {
            targetPanel.style["brightness"] = "1.7";
            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", targetPanel, targetPanel.itemname, targetPanel.heroindex);
        });
    
        targetPanel.SetPanelEvent("onmouseout", function() {
            targetPanel.style["brightness"] = "1";
            $.DispatchEvent("DOTAHideAbilityTooltip", targetPanel);
        });

        
        $.Schedule(0.1, function() {
            let unitIndex = Players.GetLocalPlayerPortraitUnit();
            // $.Msg( "Player queried a unit..." );
            PinGemSlots();
            UpdateGemSlots(unitIndex)
        });

    }
}

function GetNthVisibleAbility( heroIndex, slotNum ) {
    var ability_count = Entities.GetAbilityCount( heroIndex );
    var visible_abilities = [];
    for ( let i = 0; i < ability_count; i++ ) {
        var test_ability = Entities.GetAbility( heroIndex, i );
        if ( Abilities.IsDisplayedAbility( test_ability )) {
            // $.Msg( "visible is " + test_ability );
            visible_abilities.push( test_ability );
        }
    }
    var final = visible_abilities[slotNum]
    // $.Msg( slotNum + "th of array is " + final );
    return visible_abilities[slotNum]
}

function OnDragEnter(targetPanel, draggedPanel) {
    // $.Msg("OnDragEnter ran");
}

function OnDragLeave(targetPanel, draggedPanel) {
    // $.Msg("OnDragLeave ran");
}

function OnDragStart(targetPanel, draggedPanel) {
    // $.Msg("OnDragStart ran");
    // $.Msg( draggedPanel );
}

function OnDragEnd(targetPanel, draggedPanel) {
    // $.Msg("OnDragEnd ran");
}

function RegisterDragDropEvents(panel) {
	RegisterEventsForBackpackSlot('DragDrop', OnDragDrop, panel);
	RegisterEventsForBackpackSlot('DragEnter', OnDragEnter, panel);
	RegisterEventsForBackpackSlot('DragLeave', OnDragLeave, panel);
	RegisterEventsForBackpackSlot('DragStart', OnDragStart, panel);
	RegisterEventsForBackpackSlot('DragEnd', OnDragEnd, panel);
}

function RegisterEventsForBackpackSlot(eventName, func, panel) {
    // $.Msg("RegisterEventsForBackpackSlot ran.")
    $.RegisterEventHandler( eventName, panel, func);
}