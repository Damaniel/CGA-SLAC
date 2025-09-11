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
procedure process_game_state_input(keyRead: char; extendedKey: Boolean);
procedure process_inventory_input(keyRead: char; extendedKey: Boolean);
procedure process_title_state_input(keyRead: char; extendedKey: Boolean);

var
    g_exit_game: Boolean;

implementation

procedure process_title_state_input(keyRead: char; extendedKey: Boolean);
begin
end;

procedure process_game_state_input(keyRead: char; extendedKey: Boolean);
var
    x, y: Byte;
    sq: Byte;
    moved: Boolean;
begin
    if g_substate = SUBSTATE_GAME_INVENTORY then
    begin
        process_inventory_input(keyRead, extendedKey);
    end
    else begin
        x := g_dungeon.player_x;
        y := g_dungeon.player_y;
        moved := False;

        { Moving up }
        if (keyRead = #72) and (extendedKey = True) then begin
            sq := g_dungeon.get_square_type(x, y-1);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x, y-1);
                g_dungeon.light_area(x, y-1);
                moved := True;
            end;
        end;

        { Moving down }
        if (keyRead = #80) and (extendedKey = True) then begin
            sq := g_dungeon.get_square_type(x, y+1);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x, y+1);
                g_dungeon.light_area(x, y+1);
                moved := True;
            end;
        end;

        { Moving left }
        if (keyRead = #75) and (extendedKey = True) then begin
            sq := g_dungeon.get_square_type(x-1, y);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x-1, y);
                g_dungeon.light_area(x-1, y);
                moved := True;
            end;
        end;

        { Moving right }
        if (keyRead = #77) and (extendedKey = True) then begin
            sq := g_dungeon.get_square_type(x+1, y);
            if sq <> SQUARE_WALL then begin
                g_dungeon.set_player_pos(x+1, y);
                g_dungeon.light_area(x+1, y);
                moved := True;
            end;
        end;

        { Pick up item }
        if (keyRead = 'g') and (extendedKey = False) then
        begin
            g_dungeon.pick_up_from_ground(g_dungeon.player_x, g_dungeon.player_y);
            g_render_components.render_dungeon := True;
            g_render_components.render_interface_values := True;
        end;

        { Go up stairs }
        if (keyRead = '<') and (extendedKey = False) then
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
        if (keyRead = '>') and (extendedKey = False) then
        begin
            if (g_dungeon.player_x = g_dungeon.down_stair_x) and
               (g_dungeon.player_y = g_dungeon.down_stair_y) and
               (g_depth < NUM_FLOORS - 1) then
            begin
                create_SLAC_dungeon(g_depth + 1, DIRECTION_DOWN);
            end;
        end;

        if keyRead = #27 then begin
            g_exit_game := True;
        end;

        if moved = True then begin
            g_render_components.render_dungeon := True;
        end;
    end;
end;

procedure process_inventory_input(keyRead: Char; extendedKey: Boolean);
begin
    if keyRead = #27 then
    begin
        g_substate := SUBSTATE_GAME_DEFAULT;
        adjust_all_render_components(SET_ALL);
    end;
end;

{ process_input - gets and handle keypresses }
procedure process_input;
var
  keyRead: Char;
  extendedKey: Boolean;
begin
    { If a key press (normal or extended) is detected, figure out what it is and process appropriately. }
    if keypressed then begin
        keyRead := readkey;
        extendedKey := False;

        { Detect extended keypress. }
        if (keyRead = #0) then begin
            extendedKey := True;
            keyRead := readkey;
        end;

        { Select what to do based on the game state }
        case g_current_state of
            STATE_TITLE: process_title_state_input(keyRead, extendedKey);
            STATE_GAME: process_game_state_input(keyRead, extendedKey);
        end;
    end;
end;

end.
