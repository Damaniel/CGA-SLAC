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
    Player,
    Enemy,
    Dungeon;

const
    DUNGEON_AREA_X = 46;
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
procedure render_dungeon_area(left: Integer; top: Integer; var d: SLACDungeon);
procedure render_fog_of_war(dt_x: Integer; dt_y: Integer; tile_x: Integer; tile_y: Integer);
procedure render_text_box;
procedure render_interface;
procedure render_interface_values(var p : SLACPlayer);

implementation

{ adjust_all_render_components - a helper function to force all parts of the screen to be
  (or not be) redrawn.

  Parameters:
    - var components: the list of render components to be updated
    - comp_val: should they be enabled (SET_ALL) or disabled (CLEAR_ALL)?
}
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

{ render_init - sets up the graphics system }
procedure render_init;
begin
  g_GameTiles.init('SLAC86');
  tileSource := g_GameTiles.dataStart;
  new(g_font, init('FONTS'));

  tg_init;
  tg_clear(0);

  adjust_all_render_components(g_render_components, CLEAR_ALL);
end;

{ render_cleanup - shuts down the graphics system }
procedure render_cleanup;
begin
  tg_clear(0);
  tg_term;
end;

{ render_components - the main render function

  Parameters:
    - components: a list of components to render (or not render)

  components contains a series of flags that control whether some aspect of the game (i.e. the dungeon,
  the text log, etc) should be rendered.  Generally, some action will set the rendering of one or more
  components to True; when the render loop occurs, the components to render are redrawn, and the flag
  representing that component is set to False so the component won't redraw until requested in the
  future.
}
procedure render_components(var components: RenderComponentsType);
var
    x, y: Byte;
begin
    if components.render_interface = True then
    begin
        render_interface;
        components.render_interface := False;
    end;

    if components.render_interface_values = True then
    begin
        render_interface_values(g_player);
        components.render_interface_values := False;
    end;

    if components.render_dungeon = True then
    begin
        g_player.get_pos(x, y);
        render_dungeon_area(x - 8, y - 6, g_dungeon);
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
procedure render_dungeon_area(left: Integer; top: Integer; var d: SLACDungeon);
var
    x, y: Integer;
    tile_x, tile_y: Integer;
    sq_type: Integer;
    dt_x, dt_y: Integer;
    sprite: Integer;
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
                render_fog_of_war(x, y, tile_x, tile_y);
            end
            else begin
                { Draw fog of war if square isn't seen yet }
                if d.get_square_seen(dt_x, dt_y) = False then
                begin
                    render_fog_of_war(x, y, tile_x, tile_y);
                end
                else begin
                    sq_type := d.get_square_type(dt_x, dt_y);
                    case sq_type of
                        SQUARE_WALL: sprite := SPRITE_WALL1;
                        SQUARE_FLOOR: sprite := SPRITE_BLANK;
                        SQUARE_UP_STAIRS: sprite := SPRITE_FLOOR;
                        SQUARE_DOWN_STAIRS: sprite := SPRITE_FLOOR;
                    end;
                    tg_tile7(tile_x, tile_y, sprite);
                end;
            end;
            tile_x := tile_x + DUNGEON_AREA_TILE_WIDTH;
        end;
        tile_y := tile_y + DUNGEON_AREA_TILE_HEIGHT;
    end;

    { Render the player.  The player is always located in the middle of the play area. }
    tg_tile7(DUNGEON_AREA_X + 56, DUNGEON_AREA_Y + 42, SPRITE_HERO);

end;

{ render_fog_of_war - draws the invisible portion of the dungeon at the specified location

  Parameters:
    - dt_x, dt_y: the relative x and y tile location
    - tile_x, tile_y: the pixel position of the drawn tile

  The fog of war is actually a 2x2 block of tiles where the tiles are arranged as such:

     1 2
     2 1

   This function just renders that pattern relative to the specified location.  Depending
   on the values passed in, this could result in a fog of war that stays fixed relative to
   the screen, or that moves along with the maze.  Currently I use the former since it will
   make dirty block rendering far more efficient.
}
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

{ render_text_box - draws the text box (and text log) on the screen }
procedure render_text_box;
begin
end;

{ render_interface - draws the static components of the main game screen }
procedure render_interface;
begin
    { The main window }
    tg_rectangle(1, 0, 158, 99, 15);
    tg_bar(45, 0, 45, 99, 15);
    tg_bar(1, 85, 158, 85, 15);
    tg_bar(1, 14, 45, 14, 15);
    tg_bar(1, 61, 45, 61, 15);

    { The CGA-SLAC stuff }
    tg_rectangle(2, 1, 44, 13, 3);
    tg_rectangle(3, 2, 43, 12, 5);
    tg_putPixel(5, 7, 5);
    tg_putPixel(6, 7, 5);
    tg_putPixel(40, 7, 15);
    tg_putPixel(41, 7, 15);

    g_font^.outText(8, 5, 'CG', 5);
    g_font^.outText(16, 5, 'A-S', 3);
    g_font^.outText(28, 5, 'LAC', 15);

    { Base information }
    tg_tile7(3, 18, SPRITE_FLOOR);
    tg_tile7(3, 26, SPRITE_LEVEL);
    tg_tile7(3, 34, SPRITE_HEALTH);
    tg_tile7(3, 42, SPRITE_XP);
    tg_tile7(3, 50, SPRITE_MONEY);

    { Stat information }
    tg_tile7(3, 66, SPRITE_SWORD1);
    tg_tile7(3, 74, SPRITE_SHIELD3);
    tg_tile7(24, 66, SPRITE_BOOTS1);
    tg_tile7(24, 74, SPRITE_LUCK);

    { The health and xp bars }
    tg_rectangle(11, 35, 43, 39, 14);
    tg_rectangle(11, 43, 43, 47, 14);
end;

{ render_interface_values - draws the player-specific values to the main game interface

  Parameters:
    - p: an instance of SLACPlayer (that represents the current player)
}
procedure render_interface_values(var p: SLACPlayer);
var
    s: string[10];
begin
    { Floor }
    g_font^.outTextRight(42, 19, '1', 15);
    { Level }
    Str(p.get_level, s);
    g_font^.outTextRight(42, 27, s, 15);
    { Health bar }

    { XP bar }

    { Money }
    Str(p.get_money, s);
    g_font^.outTextRight(42, 51, s, 15);

    { Atk }
    Str(p.get_atk, s);
    g_font^.outTextRight(21, 67, s, 15);

    { Def }
    Str(p.get_def, s);
    g_font^.outTextRight(21, 75, s, 15);

    { Spd }
    Str(p.get_spd, s);
    g_font^.outTextRight(44, 67, s, 15);

    { Luck }
    Str(p.get_luck, s);
    g_font^.outTextRight(44, 75, s, 15);

end;

end.