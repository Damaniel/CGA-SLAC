{ Functions and structures related to rendering the display

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Input;

interface

uses
    jfunc,
    Player,
    Dungeon,
    Render;

procedure process_input;

var
    g_exit_game: Boolean;

implementation

{ process_input - gets and handle keypresses }
procedure process_input;
var
  keyRead: Char;
  extendedKey: Boolean;
  status: Integer;
  x, y: Byte;
  sq: Byte;
  moved: Boolean;
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

        if keyRead = #27 then begin
            g_exit_game := True;
        end;

        if moved = True then begin
            g_render_components.render_dungeon := True;
        end;
    end;
end;

end.
