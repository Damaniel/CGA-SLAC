{ Functions and structures related to items and inventory

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Item;

interface

uses
    Globals;

const
    MAX_INVENTORY_SIZE=20;
    MAX_DUNGEON_ITEMS=100;
    SLAC_WEAPON_TYPE = 0;
    SLAC_ARMOR_TYPE = 1;
    SLAC_ITEM_TYPE = 2;
    SLAC_NO_TYPE = 255;

    NO_ITEM = -1;

type

SLACItem=record
    item_class: Byte; {SLAC_WEAPON_TYPE, SLAC_ARMOR_TYPE, SLAC_ITEM_TYPE }
    item_idx: Byte;
    plus_mod: Byte;
    amount: Integer;
    identified: Boolean;
end;

SLACInventoryItem=record
    item_here: Boolean;
    item: SLACitem;
    quantity: Integer;
end;

PSLACItem=^SLACItem;

var

{ The items that show up on the dungeon floor }
g_item_list: array[0..MAX_DUNGEON_ITEMS-1] of SLACItem;

{ The player's inventory }
g_inventory: array[0..MAX_INVENTORY_SIZE-1] of SLACInventoryItem;

function get_sprite_index(i: PSLACItem): Integer;
function get_first_available_item_list_slot : Integer;
function get_first_available_inventory_slot : Integer;
{function is_slot_empty(slot: Integer) : Boolean;}
procedure add_new_to_item_list_at(idx: Integer; it: PSLACItem);
procedure delete_item_list_item_at(slot: Integer);
procedure clear_item_list;

procedure get_item_at_slot(slot: Integer; var it: PSLACItem);
implementation

function get_sprite_index(i: PSLACItem) : Integer;
var
    item_type: Integer;
begin
    case i^.item_class of
        SLAC_WEAPON_TYPE: get_sprite_index := g_weapon_data[i^.item_idx].tid;
        SLAC_ARMOR_TYPE:  get_sprite_index := g_armor_data[i^.item_idx].tid;
        SLAC_ITEM_TYPE:   get_sprite_index := g_item_data[i^.item_idx].tid;
    else
        get_sprite_index := NOTHING;
    end;
end;

function get_first_available_item_list_slot : Integer;
var
    idx: Integer;
begin
    get_first_available_item_list_slot := -1;

    for idx := 0 to MAX_DUNGEON_ITEMS - 1 do
    begin
        if g_item_list[idx].item_class = SLAC_NO_TYPE then
        begin
            get_first_available_item_list_slot := idx;
            break;
        end;
    end;
end;

function get_first_available_inventory_slot:  Integer;
var
    idx: Integer;
begin
    get_first_available_inventory_slot := -1;

    for idx := 0 to MAX_INVENTORY_SIZE - 1 do
    begin
        if g_inventory[idx].item_here = False then
        begin
            get_first_available_inventory_slot := idx;
            break;
        end;
    end;
end;

procedure add_new_to_item_list_at(idx: Integer; it: PSLACItem);
begin
    if (idx >= 0) and (idx < MAX_DUNGEON_ITEMS - 1) then
    begin
        g_item_list[idx].item_class := it^.item_class;
        g_item_list[idx].item_idx := it^.item_idx;
        g_item_list[idx].plus_mod := it^.plus_mod;
        g_item_list[idx].amount := it^.amount;
        g_item_list[idx].identified := it^.identified;
    end
    else begin
        Writeln('Warning: item index out of range');
    end;
end;

procedure get_item_at_slot(slot: Integer; var it: PSLACItem);
begin
    if (slot < 0) or (slot >= MAX_INVENTORY_SIZE) then
    begin
        it := nil;
    end
    else begin
        if g_inventory[slot].item_here = False then
        begin
            it := nil;
        end
        else begin
            it := @(g_inventory[slot].item);
        end;
    end;
end;

procedure delete_item_list_item_at(slot: Integer);
begin
    g_item_list[slot].item_class := SLAC_NO_TYPE;
    g_item_list[slot].item_idx := 0;
    g_item_list[slot].plus_mod := 0;
    g_item_list[slot].amount := 0;
    g_item_list[slot].identified := False;
end;

procedure clear_item_list;
var
    idx: Integer;
begin
    for idx := 0 to MAX_DUNGEON_ITEMS - 1 do
    begin
        delete_item_list_item_at(idx);
    end;
end;

end.