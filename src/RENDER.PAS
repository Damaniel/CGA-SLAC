{ Functions and structures related to rendering the display

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Render;

interface

uses
    jfunc,
    timer,
    txtgraph,
    Globals,
    Dungeon;

const
    DUNGEON_AREA_X = 47;
    DUNGEON_AREA_Y = 1;
    DUNGEON_AREA_PX_WIDTH = 112;
    DUNGEON_AREA_PX_HEIGHT = 84;
    DUNGEON_AREA_TILE_WIDTH = 7;
    DUNGEON_AREA_TILE_HEIGHT = 7;
    DUNGEON_AREA_NUM_H_TILES = DUNGEON_AREA_PX_WIDTH div DUNGEON_AREA_TILE_WIDTH;
    DUNGEON_AREA_NUM_V_TILES = DUNGEON_AREA_PX_HEIGHT div DUNGEON_AREA_TILE_HEIGHT;

    CLEAR_ALL = 0;
    SET_ALL = 1;
type

RenderComponentsType=record
    render_interface: Boolean;
    render_dungeon: Boolean;
    render_interface_values: Boolean;
    render_text_box: Boolean;
end;

var
  { The tile sprite data. }
  g_GameTiles: tDynamicData;
  { Font data }
  g_font: pFontSet;
  { Render components }
  g_render_components: RenderComponentsType;

procedure adjust_all_render_components(var components: RenderComponentsType; comp_val: Integer);
procedure render_init;
procedure render_cleanup;
procedure render_components(var components: RenderComponentsType);
procedure render_dungeon_area(top: Integer; left: Integer; d: SLACDungeon);
procedure render_fog_of_war(dt_x: Integer; dt_y: Integer; tile_x: Integer; tile_y: Integer);

implementation

procedure adjust_all_render_components(var components: RenderComponentsType; comp_val: Integer);
var
    set_val: Boolean;
begin
    if comp_val = CLEAR_ALL then set_val := False;
    if comp_val = SET_ALL then set_val := True;

    components.render_interface := set_val;
    components.render_dungeon := set_val;
    components.render_interface_values := set_val;
    components.render_text_box := set_val;
end;

procedure render_init;
begin
  g_GameTiles.init('SLAC86');
  tileSource := g_GameTiles.dataStart;
  new(g_font, init('FONTS'));

  tg_init;
  tg_clear(0);

  adjust_all_render_components(g_render_components, CLEAR_ALL);
end;

procedure render_cleanup;
begin
  tg_clear(0);
  tg_term;
end;

procedure render_components(var components: RenderComponentsType);
begin
    if components.render_dungeon = True then
    begin
        render_dungeon_area(-5, -5, g_dungeon);
        components.render_dungeon := False;
    end;
end;

{ render_dungeon_area - draws the visible portion of the dungeon in the designated on-screen area.

  Parameters:
    - left: the x position of the dungeon that should be drawn at the top left corner of the area
    - top: the y position of the dungeon that should be drawn at the top left corner of the area

  Note that 'left' and 'top' can be negative.  The left and top positions will generally be
  calculated relative to the player's current position in the dungeon (as the player will always
  be centered in the area).  Note that any rendered area on the screen may also be regions that
  extend beyond the width/height of the dungeon.  In both the <0 and >(width or height) case,
  we'll render fog of war by default.
}
procedure render_dungeon_area(top: Integer; left: Integer; d: SLACDungeon);
var
    x, y: Integer;
    tile_x, tile_y: Integer;
    sq_type: Integer;
    dt_x, dt_y: Integer;
begin
    tile_y := DUNGEON_AREA_Y;
    for y := 0 to DUNGEON_AREA_NUM_V_TILES - 1 do
    begin
        tile_x := DUNGEON_AREA_X;
        for x := 0 to DUNGEON_AREA_NUM_H_TILES - 1 do
        begin
            dt_x := left + x;
            dt_y := top + y;
            { Draw fog of war for squares outside of the dungeon area }
            if (dt_x < 0) or ((dt_x) > DUNGEON_WIDTH - 1) or
               ((dt_y) < 0) or ((dt_y) > DUNGEON_HEIGHT - 1) then
            begin
                render_fog_of_war(Abs(dt_x), Abs(dt_y), tile_x, tile_y);
            end
            else begin
                { Draw fog of war if square isn't seen yet : TODO - should be False }
                if d.get_square_seen(dt_x, dt_y) = True then
                begin
                    render_fog_of_war(Abs(dt_x), Abs(dt_y), tile_x, tile_y);
                end
                else begin
                    sq_type := d.get_square_type(dt_x, dt_y);
                    case sq_type of
                        SQUARE_WALL: tg_tile7(tile_x, tile_y, SPRITE_WALL1);
                        SQUARE_FLOOR: begin
                                    end;
                        SQUARE_UP_STAIRS: begin
                                        end;
                        SQUARE_DOWN_STAIRS: begin
                                            end;
                    end;
                end;
            end;
            tile_x := tile_x + DUNGEON_AREA_TILE_WIDTH;
        end;
        tile_y := tile_y + DUNGEON_AREA_TILE_HEIGHT;
    end;
end;

procedure render_fog_of_war(dt_x: Integer; dt_y: Integer; tile_x: Integer; tile_y: Integer);
begin
    if ((dt_x mod 2 = 0) and (dt_y mod 2 = 0)) or
        ((dt_x mod 2 = 1) and (dt_y mod 2 = 1)) then
    begin
        tg_tile7(tile_x, tile_y, SPRITE_BFOW1);
    end
    else begin
        tg_tile7(tile_x, tile_y, SPRITE_BFOW2);
    end;
end;

end.