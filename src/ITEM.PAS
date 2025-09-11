{ Functions and structures related to items and inventory

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Item;

interface

uses
    Globals;

const
    { Size limits for the inventory and the items on the dungeon floor }
    MAX_INVENTORY_SIZE = 20;
    MAX_DUNGEON_ITEMS = 100;

    { The broad types of items that can exist (weapon, armor, item) }
    SLAC_WEAPON_TYPE = 0;
    SLAC_ARMOR_TYPE = 1;
    SLAC_ITEM_TYPE = 2;
    SLAC_NO_TYPE = 255;

    { A flag used to specify whether an item is present...somewhere }
    NO_ITEM = -1;

type

SLACItem=record
    item_class: Byte; {SLAC_WEAPON_TYPE, SLAC_ARMOR_TYPE, SLAC_ITEM_TYPE }
    item_idx: Shortint;
    plus_mod: Byte;
    amount: Integer;
    identified: Boolean;
end;

SLACInventoryItem=record
    item_here: Boolean;
    item: SLACitem;
end;

PSLACItem=^SLACItem;

var

{ The items that show up on the dungeon floor }
g_item_list: array[0..MAX_DUNGEON_ITEMS-1] of SLACItem;

{ The player's inventory }
g_inventory: array[0..MAX_INVENTORY_SIZE-1] of SLACInventoryItem;

function get_sprite_index(var i: SLACItem): Integer;
function get_first_available_item_list_slot : Integer;
function get_first_available_inventory_slot : Integer;
function is_item_list_slot_empty(slot: Integer) : Boolean;
function is_inventory_slot_empty(slot: Integer) : Boolean;
function get_item_name(item_class: Integer; idx: Integer) : String;
procedure copy_item_to_item(var s_it: SLACItem; var d_it: SLACItem);
procedure add_new_to_item_list_at(idx: Integer; var it: SLACItem);
procedure add_new_to_inventory_at(idx: Integer; var it: SLACItem);
procedure delete_item_list_item_at(slot: Integer);
procedure delete_inventory_item_at(slot: Integer);
procedure clear_item(var i: SLACItem);
procedure dump_inventory;
procedure dump_item(var i: SLACItem);
procedure clear_item_list;
procedure clear_inventory;

implementation

function get_sprite_index(var i: SLACItem) : Integer;
var
    item_type: Integer;
begin
    case i.item_class of
        SLAC_WEAPON_TYPE: get_sprite_index := g_weapon_data[i.item_idx].tid;
        SLAC_ARMOR_TYPE:  get_sprite_index := g_armor_data[i.item_idx].tid;
        SLAC_ITEM_TYPE:   get_sprite_index := g_item_data[i.item_idx].tid;
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

procedure copy_item_to_item(var s_it: SLACItem; var d_it: SLACItem);
begin
    d_it.item_class := s_it.item_class;
    d_it.item_idx := s_it.item_idx;
    d_it.plus_mod := s_it.plus_mod;
    d_it.amount := s_it.amount;
    d_it.identified := s_it.identified;
end;

procedure add_new_to_item_list_at(idx: Integer; var it: SLACItem);
begin
    if (idx >= 0) and (idx <= MAX_DUNGEON_ITEMS - 1) then
    begin
        copy_item_to_item(it, g_item_list[idx]);
    end
    else begin
        Writeln('Warning: item index out of range');
    end;
end;

procedure add_new_to_inventory_at(idx: Integer; var it: SLACItem);
begin
    if (idx >=0) and (idx <= MAX_INVENTORY_SIZE - 1) then
    begin
        copy_item_to_item(it, g_inventory[idx].item);
        g_inventory[idx].item_here := True;
    end
    else begin
        Writeln('Warning: item index out of range');
    end;
end;

procedure clear_item(var i: SLACItem);
begin
    i.item_class := SLAC_NO_TYPE;
    i.item_idx := NO_ITEM;
    i.plus_mod := 0;
    i.amount := 0;
    i.identified := False;
end;

procedure delete_item_list_item_at(slot: Integer);
begin
    if (slot > 0) and (slot <= MAX_DUNGEON_ITEMS - 1) then
    begin
        clear_item(g_item_list[slot]);
    end;
end;

procedure delete_inventory_item_at(slot: Integer);
begin
    if (slot >= 0) and (slot <= MAX_INVENTORY_SIZE - 1) then
    begin
        clear_item(g_inventory[slot].item);
        g_inventory[slot].item_here := False;
    end;
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

procedure clear_inventory;
var
    idx: Integer;
begin
    for idx := 0 to MAX_INVENTORY_SIZE - 1 do
    begin
        delete_inventory_item_at(idx);
    end;
end;

function is_item_list_slot_empty(slot: Integer) : Boolean;
begin
    { If the index is out of range, it's 'technically' empty... }
    if (slot < 0) or (slot > MAX_DUNGEON_ITEMS - 1) then
    begin
        is_item_list_slot_empty := True;
    end;

    if g_item_list[slot].item_class = SLAC_NO_TYPE then
    begin
        is_item_list_slot_empty := True;
    end
    else begin
        is_item_list_slot_empty := False;
    end;
end;

function is_inventory_slot_empty(slot: Integer) : Boolean;
begin
    { If the index is out of range, it's 'technically' empty... }
    if (slot < 0) or (slot > MAX_INVENTORY_SIZE - 1) then
    begin
        is_inventory_slot_empty := True;
    end;

    if g_inventory[slot].item.item_class = SLAC_NO_TYPE then
    begin
        is_inventory_slot_empty := True;
    end
    else begin
        is_inventory_slot_empty := False;
    end;
end;

function get_item_name(item_class: Integer; idx: Integer) : String;
begin
    case item_class of
        SLAC_WEAPON_TYPE: get_item_name := g_weapon_data[idx].name;
        SLAC_ARMOR_TYPE:  get_item_name := g_armor_data[idx].name;
        SLAC_ITEM_TYPE:   get_item_name := g_item_data[idx].name;
    else
        get_item_name := '';
    end;
end;

procedure dump_inventory;
var
    idx: Integer;
begin
    Writeln('Inventory');
    Writeln('----------------------------');

    for idx := 0 to MAX_INVENTORY_SIZE - 1 do
    begin
        Write('  ');
        Write(idx + 1);
        Write(': ');
        if g_inventory[idx].item.item_class = SLAC_NO_TYPE then
        begin
            Writeln('<empty>')
        end
        else begin
            dump_item(g_inventory[idx].item);
        end;
    end;
end;

{ dump_item - writes the name of an item as seen by the player

  Parameters:
    i: the item to dump
}
procedure dump_item(var i: SLACItem);
begin
    case i.item_class of
        SLAC_WEAPON_TYPE: begin
                            Write(g_weapon_data[i.item_idx].name);
                            if i.plus_mod > 0 then
                            begin
                                Write(' (+');
                                Write(i.plus_mod);
                                Writeln(')');
                            end
                            else begin
                                Writeln('');
                            end;
                         end;
        SLAC_ARMOR_TYPE: begin
                            Write(g_armor_data[i.item_idx].name);
                            if i.plus_mod > 0 then
                            begin
                                Write(' (+');
                                Write(i.plus_mod);
                                Writeln(')');
                            end
                            else begin
                                Writeln('');
                            end;
                        end;
        SLAC_ITEM_TYPE:  begin
                            if g_item_data[i.item_idx].item_class = ITEM_MONEY then
                            begin
                                Write(i.amount);
                                Write(' ');
                            end;
                            if g_item_data[i.item_idx].item_class = ITEM_SCROLL then
                            begin
                                Write('SCROLL OF ');
                            end;
                            if g_item_data[i.item_idx].item_class = ITEM_POTION then
                            begin
                                Write('POTION ');
                            end;
                            Writeln(g_item_data[i.item_idx].name);
                            if i.plus_mod <> 0 then
                            begin
                                Write (' Warning - item has a plus mod of ');
                                Writeln(i.plus_mod);
                            end;
                        end;
    else
        Writeln('<Unknown>');
    end;
end;

end.