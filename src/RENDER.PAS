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
    Generate,
    Player,
    Item,
    Enemy,
    Dungeon,
    Textlog;

const
    { Used by adjust_game_render_components, to either set or clear all components at once }
    CLEAR_ALL = 0;
    SET_ALL = 1;

    { Colors }
    COLOR_BLACK = 0;
    COLOR_GREEN = 2;
    COLOR_CYAN = 3;
    COLOR_RED = 4;
    COLOR_MAGENTA = 5;
    COLOR_YELLOW = 14;
    COLOR_WHITE = 15;

    { ------ UI constants ------ }

    { The main window area - outside border and crossing lines }
    GAME_AREA_X1 = 1;
    GAME_AREA_Y1 = 0;
    GAME_AREA_X2 = 158;
    GAME_AREA_Y2 = 99;
    { The separator between the status area and the dungeon area }
    GAME_LR_SEP_X = 45;
    GAME_LR_SEP_Y1 = 0;
    GAME_LR_SEP_Y2 = 99;
    { The separator between the status area and the enemy / text box area}
    GAME_TEXT_SEP_X1 = 1;
    GAME_TEXT_SEP_X2 = 158;
    GAME_TEXT_SEP_Y = 85;
    { The separator that creates the region where the game title goes}
    GAME_TITLE_SEP_X1 = 1;
    GAME_TITLE_SEP_X2 = 45;
    GAME_TITLE_SEP_Y = 14;
    { The separator that separates the stat section from the status section }
    GAME_ENEMY_SEP_X1 = 1;
    GAME_ENEMY_SEP_X2 = 45;
    GAME_ENEMY_SEP_Y = 61;
    { The cyan outer rectangle up in the title area }
    TITLE_OUTER_BOX_X1 = 2;
    TITLE_OUTER_BOX_Y1 = 1;
    TITLE_OUTER_BOX_X2 = 44;
    TITLE_OUTER_BOX_Y2 = 13;
    { The magentia inner rectangle up in the title area }
    TITLE_INNER_BOX_X1 = 3;
    TITLE_INNER_BOX_Y1 = 2;
    TITLE_INNER_BOX_X2 = 43;
    TITLE_INNER_BOX_Y2 = 12;
    { The 4 pixels making up the 2 little lines next to the letters CGA-SLAC }
    TITLE_PX1_X = 5;
    TITLE_PX2_X = 6;
    TITLE_PX3_X = 40;
    TITLE_PX4_X = 41;
    TITLE_PX_Y = 7;
    { The 3 text segments of the title text ('CG', 'A-S', 'LAC')}
    TITLE_TEXT1_X = 8;
    TITLE_TEXT2_X = 16;
    TITLE_TEXT3_X = 28;
    TITLE_TEXT_Y = 5;
    { The icons used for main status (depth, level, health, xp, money) }
    STATUS_DEPTH_ICON_X = 3;
    STATUS_DEPTH_ICON_Y = 18;
    STATUS_LEVEL_ICON_X = 3;
    STATUS_LEVEL_ICON_Y = 26;
    STATUS_HEALTH_ICON_X = 3;
    STATUS_HEALTH_ICON_Y = 34;
    STATUS_XP_ICON_X = 3;
    STATUS_XP_ICON_Y = 42;
    STATUS_MONEY_ICON_X = 3;
    STATUS_MONEY_ICON_Y = 50;
    { The icons used for player stats (atk, def, speed, luck) }
    STAT_ATK_ICON_X = 3;
    STAT_ATK_ICON_Y = 66;
    STAT_DEF_ICON_X = 3;
    STAT_DEF_ICON_Y = 74;
    STAT_SPEED_ICON_X = 24;
    STAT_SPEED_ICON_Y = 66;
    STAT_LUCK_ICON_X = 24;
    STAT_LUCK_ICON_Y = 74;
    { The HP box (just the box, not the bar inside that shows current HP) }
    PLAYER_HP_BOX_X1 = 11;
    PLAYER_HP_BOX_Y1 = 35;
    PLAYER_HP_BOX_X2 = 43;
    PLAYER_HP_BOX_Y2 = 39;
    { The XP box (just the box, not the bar inside that shows current XP) }
    PLAYER_XP_BOX_X1 = 11;
    PLAYER_XP_BOX_Y1 = 43;
    PLAYER_XP_BOX_X2 = 43;
    PLAYER_XP_BOX_Y2 = 47;
    { The locations of the text for the various status values }
    STATUS_DEPTH_TEXT_X = 42;
    STATUS_DEPTH_TEXT_Y = 19;
    STATUS_LEVEL_TEXT_X = 42;
    STATUS_LEVEL_TEXT_Y = 27;
    STATUS_MONEY_TEXT_X = 42;
    STATUS_MONEY_TEXT_Y = 51;
    { The locations of the text for the player stat values }
    STAT_ATK_TEXT_X = 21;
    STAT_ATK_TEXT_Y = 67;
    STAT_DEF_TEXT_X = 21;
    STAT_DEF_TEXT_Y = 75;
    STAT_SPEED_TEXT_X = 44;
    STAT_SPEED_TEXT_Y = 67;
    STAT_LUCK_TEXT_X = 44;
    STAT_LUCK_TEXT_Y = 75;
    { The dungeon area }
    DUNGEON_AREA_X = 46;
    DUNGEON_AREA_Y = 1;
    DUNGEON_AREA_PX_WIDTH = 112;
    DUNGEON_AREA_PX_HEIGHT = 84;
    DUNGEON_AREA_TILE_WIDTH = 7;
    DUNGEON_AREA_TILE_HEIGHT = 7;
    DUNGEON_AREA_NUM_H_TILES = DUNGEON_AREA_PX_WIDTH div DUNGEON_AREA_TILE_WIDTH;
    DUNGEON_AREA_NUM_V_TILES = DUNGEON_AREA_PX_HEIGHT div DUNGEON_AREA_TILE_HEIGHT;
    { The player HP and XP bar interior regions}
    PLAYER_HP_X = 12;
    PLAYER_HP_Y = 36;
    PLAYER_HP_W = 31;
    PLAYER_HP_H =  3;
    PLAYER_XP_X = 12;
    PLAYER_XP_Y = 44;
    PLAYER_XP_W = 31;
    PLAYER_XP_H =  3;

    { Constants to help clear areas }
    STATUS_TEXT_CLEAR_X1 = 10;
    STATUS_TEXT_CLEAR_X2 = 42;
    STATUS_TEXT_CLEAR_HEIGHT = 5;
    STAT_LEFT_TEXT_CLEAR_X1 = 10;
    STAT_LEFT_TEXT_CLEAR_X2 = 22;
    STAT_RIGHT_TEXT_CLEAR_X1 = 31;
    STAT_RIGHT_TEXT_CLEAR_X2 = 43;

    { Text log info }
    VISIBLE_LOG_LINES = 2;
    TEXT_LINE_X = 47;
    TEXT_LINE_1_Y = 87;
    TEXT_LINE_HEIGHT = 6;
    TEXT_AREA_X1 = 46;
    TEXT_AREA_Y1 = 86;
    TEXT_AREA_X2 = 157;
    TEXT_AREA_Y2 = 98;

var
  { The tile sprite data. }
  g_GameTiles: tDynamicData;
  { Font data }
  g_font: pFontSet;

procedure adjust_game_render_components(comp_val: Integer);
procedure adjust_inventory_render_components(comp_val: Integer);
procedure render_init;
procedure render_cleanup;
procedure render_components;
procedure render_title_components;
procedure render_game_components;
procedure render_inventory_components;
procedure render_dungeon_area(left: Integer; top: Integer);
procedure render_fog_of_war(dt_x: Integer; dt_y: Integer; tile_x: Integer; tile_y: Integer);
procedure render_text_box;
procedure render_interface;
procedure render_interface_values;

implementation

{ adjust_game_render_components - a helper function to force all parts of the screen to be
  (or not be) redrawn.

  Parameters:
    - comp_val: should they be enabled (SET_ALL) or disabled (CLEAR_ALL)?
}
procedure adjust_game_render_components(comp_val: Integer);
var
    set_val: Boolean;
begin
    if comp_val = CLEAR_ALL then set_val := False;
    if comp_val = SET_ALL then set_val := True;

    g_render_components.render_interface := set_val;
    g_render_components.render_dungeon := set_val;
    g_render_components.render_interface_values := set_val;
    g_render_components.render_text_box := set_val;
end;

procedure adjust_inventory_render_components(comp_val: Integer);
var
    set_val: Boolean;
begin
    if comp_val = CLEAR_ALL then set_val := False;
    if comp_val = SET_ALL then set_val := True;

    g_render_components.render_inventory_ui := set_val;
    g_render_components.render_inventory_items := set_val;
    g_render_components.render_inventory_highlight := set_val;
end;

{ render_init - sets up the graphics system }
procedure render_init;
begin
  g_GameTiles.init('SLAC86');
  tileSource := g_GameTiles.dataStart;
  new(g_font, init('FONTS'));

  tg_init;
  tg_clear(0);

  adjust_game_render_components(CLEAR_ALL);
end;

{ render_cleanup - shuts down the graphics system }
procedure render_cleanup;
begin
  tg_clear(0);
  tg_term;
end;

procedure render_inventory_components;
begin

end;

procedure render_game_components;
var
    x, y: Byte;
begin
    if g_render_components.render_interface = True then
    begin
        render_interface;
        g_render_components.render_interface := False;
    end;

    if g_render_components.render_interface_values = True then
    begin
        render_interface_values;
        g_render_components.render_interface_values := False;
    end;

    if g_render_components.render_dungeon = True then
    begin
        render_dungeon_area(g_dungeon.player_x - 8, g_dungeon.player_y - 6);
        g_render_components.render_dungeon := False;
    end;

    if g_render_components.render_text_box = True then
    begin
        render_text_box;
        g_render_components.render_text_box := False;
    end;
end;

procedure render_title_components;
begin

end;

{ render_components - the main render function }
procedure render_components;
begin
    case g_current_state of
        STATE_TITLE: begin
                        render_title_components;
                     end;
        STATE_GAME: begin
                        if g_substate = SUBSTATE_GAME_INVENTORY then
                        begin
                            render_inventory_components;
                        end
                        else begin
                            render_game_components;
                        end;
                    end;
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
procedure render_dungeon_area(left: Integer; top: Integer);
var
    x, y: Integer;
    tile_x, tile_y: Integer;
    sq_type: Integer;
    dt_x, dt_y: Integer;
    sprite: Integer;
    enemy, item: Integer;
    s: SLACEnemy;
    it: SLACItem;
begin
    tile_y := DUNGEON_AREA_Y;
    for y := 0 to DUNGEON_AREA_NUM_V_TILES - 1 do
    begin
        tile_x := DUNGEON_AREA_X;
        for x := 0 to DUNGEON_AREA_NUM_H_TILES - 1 do
        begin
            dt_x := left + x;
            dt_y := top + y;
            { If in the middle spot (always occupied by the player), render the player sprite
              instead.  This reduces the flicker from rendering him after the fact on slower
              computers. }
            if (x = DUNGEON_AREA_NUM_H_TILES div 2) and (y = DUNGEON_AREA_NUM_V_TILES div 2) then
            begin
                tg_tile7(tile_x, tile_y, SPRITE_HERO);
            end
            { Otherwise, determine what to draw here }
            else begin
                { Draw fog of war for squares outside of the dungeon area }
                if (dt_x < 0) or ((dt_x) > DUNGEON_WIDTH - 1) or
                    ((dt_y) < 0) or ((dt_y) > DUNGEON_HEIGHT - 1) then
                begin
                    render_fog_of_war(x, y, tile_x, tile_y);
                end
                else begin
                    { Draw fog of war if square isn't seen yet }
                    if g_dungeon.get_square_seen(dt_x, dt_y) = False then
                    begin
                        render_fog_of_war(x, y, tile_x, tile_y);
                    end
                    else begin
                        { Otherwise determine which dungeon square goes here and draw it }
                        sq_type := g_dungeon.get_square_type(dt_x, dt_y);
                        case sq_type of
                            SQUARE_WALL: sprite := SPRITE_WALL1;
                            SQUARE_FLOOR: sprite := SPRITE_BLANK;
                            SQUARE_UP_STAIRS: sprite := SPRITE_USTAIR;
                            SQUARE_DOWN_STAIRS: sprite := SPRITE_DSTAIR;
                        end;
                        tg_tile7(tile_x, tile_y, sprite);
                        { If an item is here, render it }
                        if g_dungeon.get_item(dt_x, dt_y) <> NO_ITEM then
                        begin
                            { Determine what item it is and draw the appropriate one }
                            it := g_item_list[g_dungeon.get_item(dt_x, dt_y)];
                            case it.item_class of
                                SLAC_WEAPON_TYPE: tg_tile7(tile_x, tile_y, g_weapon_data[it.item_idx].tid);
                                SLAC_ARMOR_TYPE:  tg_tile7(tile_x, tile_y, g_armor_data[it.item_idx].tid);
                                SLAC_ITEM_TYPE:   tg_tile7(tile_x, tile_y, g_item_data[it.item_idx].tid);
                            end;
                        end;
                        { If an enemy is here, render it }
                        if g_dungeon.get_enemy(dt_x, dt_y) <> NO_ENEMY then
                        begin
                            s := g_enemy_list[g_dungeon.get_enemy(dt_x, dt_y)];
                            enemy := s.enemy_idx;
                            tg_tile7(tile_x, tile_y, g_monster_data[enemy].tid);
                        end;
                    end;
                end;
            end;
            tile_x := tile_x + DUNGEON_AREA_TILE_WIDTH;
        end;
        tile_y := tile_y + DUNGEON_AREA_TILE_HEIGHT;
    end;
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
var
    idx: Integer;
    row: Integer;
begin
    tg_bar(TEXT_AREA_X1, TEXT_AREA_Y1, TEXT_AREA_X2, TEXT_AREA_Y2, COLOR_BLACK);
    row := NUM_LOG_ROWS - VISIBLE_LOG_LINES;

    for idx := 0 to VISIBLE_LOG_LINES do
    begin
        if (row >= 0) and (row <= NUM_LOG_ROWS - 1) then
        begin
            g_font^.outText(TEXT_LINE_X, TEXT_LINE_1_Y + (idx * TEXT_LINE_HEIGHT), g_text_log[row], COLOR_WHITE);
            row := row + 1;
        end;
    end;
end;

{ render_interface - draws the static components of the main game screen }
procedure render_interface;
begin
    { The main window }
    tg_rectangle(GAME_AREA_X1, GAME_AREA_Y1, GAME_AREA_X2, GAME_AREA_Y2, COLOR_WHITE);
    tg_bar(GAME_LR_SEP_X, GAME_LR_SEP_Y1, GAME_LR_SEP_X, GAME_LR_SEP_Y2, COLOR_WHITE);
    tg_bar(GAME_TEXT_SEP_X1, GAME_TEXT_SEP_Y, GAME_TEXT_SEP_X2, GAME_TEXT_SEP_Y, COLOR_WHITE);
    tg_bar(GAME_TITLE_SEP_X1, GAME_TITLE_SEP_Y, GAME_TITLE_SEP_X2, GAME_TITLE_SEP_Y, COLOR_WHITE);
    tg_bar(GAME_ENEMY_SEP_X1, GAME_ENEMY_SEP_Y, GAME_ENEMY_SEP_X2, GAME_ENEMY_SEP_Y, COLOR_WHITE);

    { The CGA-SLAC stuff }
    tg_rectangle(TITLE_OUTER_BOX_X1, TITLE_OUTER_BOX_Y1, TITLE_OUTER_BOX_X2, TITLE_OUTER_BOX_Y2, COLOR_CYAN);
    tg_rectangle(TITLE_INNER_BOX_X1, TITLE_INNER_BOX_Y1, TITLE_INNER_BOX_X2, TITLE_INNER_BOX_Y2, COLOR_MAGENTA);
    tg_putPixel(TITLE_PX1_X, TITLE_PX_Y, COLOR_MAGENTA);
    tg_putPixel(TITLE_PX2_X, TITLE_PX_Y, COLOR_MAGENTA);
    tg_putPixel(TITLE_PX3_X, TITLE_PX_Y, COLOR_WHITE);
    tg_putPixel(TITLE_PX4_X, TITLE_PX_Y, COLOR_WHITE);

    g_font^.outText(TITLE_TEXT1_X, TITLE_TEXT_Y, 'CG', COLOR_MAGENTA);
    g_font^.outText(TITLE_TEXT2_X, TITLE_TEXT_Y, 'A-S', COLOR_CYAN);
    g_font^.outText(TITLE_TEXT3_X, TITLE_TEXT_Y, 'LAC', COLOR_WHITE);

    { Base information }
    tg_tile7(STATUS_DEPTH_ICON_X, STATUS_DEPTH_ICON_Y, SPRITE_DSTAIR);
    tg_tile7(STATUS_LEVEL_ICON_X, STATUS_LEVEL_ICON_Y, SPRITE_LEVEL);
    tg_tile7(STATUS_HEALTH_ICON_X, STATUS_HEALTH_ICON_Y, SPRITE_HEALTH);
    tg_tile7(STATUS_XP_ICON_X, STATUS_XP_ICON_Y, SPRITE_XP);
    tg_tile7(STATUS_MONEY_ICON_X, STATUS_MONEY_ICON_Y, SPRITE_MONEY);

    { Stat information }
    tg_tile7(STAT_ATK_ICON_X, STAT_ATK_ICON_Y, SPRITE_SWORD1);
    tg_tile7(STAT_DEF_ICON_X, STAT_DEF_ICON_Y, SPRITE_SHIELD3);
    tg_tile7(STAT_SPEED_ICON_X, STAT_SPEED_ICON_Y, SPRITE_BOOTS1);
    tg_tile7(STAT_LUCK_ICON_X, STAT_LUCK_ICON_Y, SPRITE_LUCK);

    { The health and xp bars }
    tg_rectangle(PLAYER_HP_BOX_X1, PLAYER_HP_BOX_Y1, PLAYER_HP_BOX_X2, PLAYER_HP_BOX_Y2, COLOR_YELLOW);
    tg_rectangle(PLAYER_XP_BOX_X1, PLAYER_XP_BOX_Y1, PLAYER_XP_BOX_X2, PLAYER_XP_BOX_Y2, COLOR_YELLOW);

end;

{ render_interface_values - draws the player-specific values to the main game interface

  Parameters:
    - p: an instance of SLACPlayer (that represents the current player)
}
procedure render_interface_values;
var
    s: string[10];
    hp_w, xp_w: Integer;
    hp_pct, xp_pct: Integer;
    next_level: Longint;
begin
    { Floor }
    tg_bar(STATUS_TEXT_CLEAR_X1, STATUS_DEPTH_TEXT_Y, STATUS_TEXT_CLEAR_X2,
           STATUS_DEPTH_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_depth, s);
    g_font^.outTextRight(STATUS_DEPTH_TEXT_X, STATUS_DEPTH_TEXT_Y, s, COLOR_WHITE);

    { Level }
    tg_bar(STATUS_TEXT_CLEAR_X1, STATUS_LEVEL_TEXT_Y, STATUS_TEXT_CLEAR_X2,
           STATUS_LEVEL_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.level, s);
    g_font^.outTextRight(STATUS_LEVEL_TEXT_X, STATUS_LEVEL_TEXT_Y, s, COLOR_WHITE);

    { Health bar }
    {pct is a range from 0 to 100 - e.g 75 / 100HP = 7500 / 100 = 75}
    tg_bar(PLAYER_HP_X, PLAYER_HP_Y, PLAYER_HP_X + PLAYER_HP_W - 1, PLAYER_HP_Y + PLAYER_HP_H - 1, COLOR_BLACK);
    hp_pct := (g_player.hp * 100) div (g_player.max_hp);
    hp_w :=  (hp_pct * PLAYER_HP_W) div 100;
    tg_bar(PLAYER_HP_X, PLAYER_HP_Y, PLAYER_HP_X + hp_w - 1, PLAYER_HP_Y + PLAYER_HP_H - 1, COLOR_RED);

    { XP bar }
    tg_bar(PLAYER_XP_X, PLAYER_XP_Y, PLAYER_XP_X + PLAYER_XP_W - 1, PLAYER_XP_Y + PLAYER_XP_H - 1, COLOR_BLACK);
    next_level := get_xp_for_next_level(g_player.level);
    xp_pct := (g_player.xp * 100) div next_level;
    xp_w := (xp_pct * PLAYER_XP_W) div 100;
    tg_bar(PLAYER_XP_X, PLAYER_XP_Y, PLAYER_XP_X + xp_w - 1, PLAYER_XP_Y + PLAYER_XP_H - 1, COLOR_GREEN);

    { Money }
    tg_bar(STATUS_TEXT_CLEAR_X1, STATUS_MONEY_TEXT_Y, STATUS_TEXT_CLEAR_X2,
           STATUS_MONEY_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.money, s);
    g_font^.outTextRight(STATUS_MONEY_TEXT_X, STATUS_MONEY_TEXT_Y, s, COLOR_WHITE);

    { Atk }
    tg_bar(STAT_LEFT_TEXT_CLEAR_X1, STAT_ATK_TEXT_Y, STAT_LEFT_TEXT_CLEAR_X2,
           STAT_ATK_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.atk, s);
    g_font^.outTextRight(STAT_ATK_TEXT_X, STAT_ATK_TEXT_Y, s, COLOR_WHITE);

    { Def }
    tg_bar(STAT_LEFT_TEXT_CLEAR_X1, STAT_DEF_TEXT_Y, STAT_LEFT_TEXT_CLEAR_X2,
           STAT_DEF_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.def, s);
    g_font^.outTextRight(STAT_DEF_TEXT_X, STAT_DEF_TEXT_Y, s, COLOR_WHITE);

    { Spd }
    tg_bar(STAT_RIGHT_TEXT_CLEAR_X1, STAT_SPEED_TEXT_Y, STAT_RIGHT_TEXT_CLEAR_X2,
           STAT_SPEED_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.spd, s);
    g_font^.outTextRight(STAT_SPEED_TEXT_X, STAT_SPEED_TEXT_Y, s, COLOR_WHITE);

    { Luck }
    tg_bar(STAT_RIGHT_TEXT_CLEAR_X1, STAT_LUCK_TEXT_Y, STAT_RIGHT_TEXT_CLEAR_X2,
           STAT_LUCK_TEXT_Y + STATUS_TEXT_CLEAR_HEIGHT, COLOR_BLACK);
    Str(g_player.luck, s);
    g_font^.outTextRight(STAT_LUCK_TEXT_X, STAT_LUCK_TEXT_Y, s, COLOR_WHITE);
end;

end.