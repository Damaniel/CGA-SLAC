{ STATE.PAS - state machine management and associated helpers

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit State;

interface

uses
  Globals,
  Player,
  Dungeon,
  Item,
  Textlog,
  Render;

const
  STATE_TITLE = 0;
  STATE_GAME = 1;
  STATE_INVENTORY = 2;

var
  g_current_state: Integer;
  g_previous_state: Integer;

procedure do_change_to_title_state;
procedure do_change_to_game_state;
procedure do_change_to_inventory_state;
procedure change_state(new_state: Integer);
procedure create_SLAC_dungeon(floor: Integer);

implementation

{ ------ Miscellaneous ------ }
procedure create_SLAC_dungeon(floor: Integer);
var
   s, s2: String;
begin
  g_dungeon.Init;
  g_depth := floor;
  g_dungeon.generate(@g_generator);
  clear_text_log;
  Str(g_depth, s2);
  s := 'YOU ENTER LEVEL ' + s2 + '.';
  append_text_to_log(s);
  adjust_all_render_components(SET_ALL);
end;

{ do_change_to_title_state - does the initialization required when transitioning to STATE_TITLE }
procedure do_change_to_title_state;
begin

end;

{ do_change_to_game_state - does the initialization required when transitioning to STATE_GAME }
procedure do_change_to_game_state;
begin
  g_player.Init;
  clear_inventory;
  create_SLAC_dungeon(1);
end;

{ do_change_to_inventory_state - does the initialization required when transitioning to STATE_INVENTORY }
procedure do_change_to_inventory_state;
begin

end;

{ change_state - changes the current game state

  Parameters
    new_state: the state to change to
}
procedure change_state(new_state: Integer);
begin
    g_previous_state := g_current_state;
    g_current_state := new_state;

    case g_current_state of
        STATE_TITLE: begin
                      do_change_to_title_state;
                     end;
        STATE_GAME:  begin
                      do_change_to_game_state;
                     end;
        STATE_INVENTORY: begin
                          do_change_to_inventory_state;
                         end;
    else
        Writeln('Warning: unknown state');
    end;
end;

end.