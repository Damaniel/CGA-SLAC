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
procedure render_dungeon_area(top: Integer; left: Integer);

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
        render_dungeon_area(0, 0);
        components.render_dungeon := False;
    end;
end;

procedure render_dungeon_area(top: Integer; left: Integer);
begin
    Writeln('rendering dungeon area');
end;

end.