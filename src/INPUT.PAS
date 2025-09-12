{ Functions and structures related to rendering the display

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Input;

interface

uses
    jfunc,
    Player,
    Globals,
    Dungeon,
    Item,
    Textlog,
    State,
    Render;

procedure process_input;
procedure process_game_state_input(key_read: char; extended_key: Boolean);
procedure process_inventory_input(key_read: char; extended_key: Boolean);
procedure process_title_state_input(key_read: char; extended_key: Boolean);

var
    g_exit_game: Boolean;

implementation

procedure process_title_state_input(key_read: char; extended_key: Boolean);
begin
end;

procedure process_game_state_input(key_read: char; extended_key: Boolean);
var
    x, y: Byte;
    sq: Byte;
    moved: Boolean;
begin
    if g_substate = SUBSTATE_GAME_INVENTORY then
    begin
        process_inventory_input(key_read, extended_key);
    end
    else begin
        x := g_dungeon.player_x;
        y := g_dungeon.player_y;
        moved := False;

        { Moving up }
        if (key_read = #72) and (extended_key = True) then begin
            sq := g_dungeon.get_square_type(x, y-1);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x, y-1);
                g_dungeon.light_area(x, y-1);
                moved := True;
            end;
        end;

        { Moving down }
        if (key_read = #80) and (extended_key = True) then begin
            sq := g_dungeon.get_square_type(x, y+1);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x, y+1);
                g_dungeon.light_area(x, y+1);
                moved := True;
            end;
        end;

        { Moving left }
        if (key_read = #75) and (extended_key = True) then begin
            sq := g_dungeon.get_square_type(x-1, y);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x-1, y);
                g_dungeon.light_area(x-1, y);
                moved := True;
            end;
        end;

        { Moving right }
        if (key_read = #77) and (extended_key = True) then begin
            sq := g_dungeon.get_square_type(x+1, y);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x+1, y);
                g_dungeon.light_area(x+1, y);
                moved := True;
            end;
        end;

        { Pick up item }
        if (key_read = 'g') and (extended_key = False) then
        begin
            g_dungeon.pick_up_from_ground(g_dungeon.player_x, g_dungeon.player_y);
            g_render_components.render_dungeon := True;
            g_render_components.render_interface_values := True;
        end;

        { Go up stairs }
        if (key_read = '<') and (extended_key = False) then
        begin
            if (g_dungeon.player_x = g_dungeon.up_stair_x) and
               (g_dungeon.player_y = g_dungeon.up_stair_y) then
            begin
                { If not on the top floor, make a new floor}
                if (g_depth > 1) then
                begin
                    create_SLAC_dungeon(g_depth - 1, DIRECTION_UP);
                end
                { Otherwise, end the game regardless of status }
                else begin
                end;
            end;
        end;

        { Go down stairs }
        if (key_read = '>') and (extended_key = False) then
        begin
            if (g_dungeon.player_x = g_dungeon.down_stair_x) and
               (g_dungeon.player_y = g_dungeon.down_stair_y) and
               (g_depth < NUM_FLOORS - 1) then
            begin
                create_SLAC_dungeon(g_depth + 1, DIRECTION_DOWN);
            end;
        end;

        { Open inventory }
        if (key_read = 'i') and (extended_key = False) then
        begin
            g_substate := SUBSTATE_GAME_INVENTORY;
            adjust_inventory_render_components(SET_ALL);
        end;

        { Tell game to exit }
        if key_read = #27 then begin
            g_exit_game := True;
        end;

        if moved = True then begin
            g_render_components.render_dungeon := True;
        end;
    end;
end;

procedure process_inventory_input(key_read: Char; extended_key: Boolean);
var
    index: Integer;
    num_items_on_this_page: Integer;
begin
    if (key_read = #27) or (key_read = 'i') then
    begin
        g_substate := SUBSTATE_GAME_DEFAULT;
        clear_tiles;
        adjust_game_render_components(SET_ALL);
    end;

    { Moving down }
    if (key_read = #80) and (extended_key = True) then begin
        if g_inventory_count > 0 then
        begin
            num_items_on_this_page := get_num_items_on_inventory_page;
            g_inventory_pos_components.old_index := g_inventory_pos_components.index;
            g_inventory_pos_components.index := (g_inventory_pos_components.index + 1) mod num_items_on_this_page;
            g_render_components.render_inventory_highlight := True;
        end;
    end;

    { Moving up }
    if (key_read = #72) and (extended_key = True) then begin
        if g_inventory_count > 0 then
        begin
            num_items_on_this_page := get_num_items_on_inventory_page;
            g_inventory_pos_components.old_index := g_inventory_pos_components.index;
            g_inventory_pos_components.index := g_inventory_pos_components.index - 1;
            if g_inventory_pos_components.index < 0 then
            begin
                g_inventory_pos_components.index := num_items_on_this_page - 1;
            end;
            g_render_components.render_inventory_highlight := True;
        end;
    end;

    if (key_read = 'n') and (extended_key = False) then
    begin
        if (g_inventory_pos_components.page < (NUM_INVENTORY_PAGES - 1)) and
           (g_inventory_count > (g_inventory_pos_components.page + 1) * INVENTORY_ITEMS_PER_PAGE) then
        begin
            g_inventory_pos_components.page := g_inventory_pos_components.page + 1;
            g_inventory_pos_components.index := 0;
            g_inventory_pos_components.old_index := 0;
            adjust_inventory_render_components(SET_ALL);
        end;
    end;

    if (key_read = 'p') and (extended_key = False) then
    begin
        if (g_inventory_pos_components.page > 0) then
        begin
            g_inventory_pos_components.page := g_inventory_pos_components.page - 1;
            g_inventory_pos_components.index := 0;
            g_inventory_pos_components.old_index := 0;
            adjust_inventory_render_components(SET_ALL);
        end;
    end;

end;

{ process_input - gets and handle keypresses }
procedure process_input;
var
  key_read: Char;
  extended_key: Boolean;
begin
    { If a key press (normal or extended) is detected, figure out what it is and process appropriately. }
    if keypressed then begin
        key_read := readkey;
        extended_key := False;

        { Detect extended keypress. }
        if (key_read = #0) then begin
            extended_key := True;
            key_read := readkey;
        end;

        { Select what to do based on the game state }
        case g_current_state of
            STATE_TITLE: process_title_state_input(key_read, extended_key);
            STATE_GAME: process_game_state_input(key_read, extended_key);
        end;
    end;
end;

end.
