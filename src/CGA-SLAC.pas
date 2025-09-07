{ CGA-SLAC - a roguelike for DOS PCs with a CGA (or better) graphics card

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Globals,
  Dungeon,
  Player,
  Render,
  Enemy,
  Generate,
  Input;

const
  FRAME_RATE = 30;

var
  g_TimerInterval: Word;
  p_x, p_y: Byte;
  idx, enemy_idx: Integer;

procedure game_init;
begin
  startTimer;
  g_TimerInterval := getUserClockInterval(FRAME_RATE);
  g_exit_game := False;
  render_init;
end;

procedure game_cleanup;
begin
  render_cleanup;
  killTimer;
end;

begin

  Randomize;
  game_init;
  g_player.Init;
  g_dungeon.Init;
  g_dungeon.generate(@g_generator, 1);

  g_render_components.render_dungeon := True;
  g_render_components.render_interface := True;
  g_render_components.render_interface_values := True;

  while g_exit_game = False do
  begin
    if (userTimerExpired(g_TimerInterval)) then
    begin
      process_input(g_player, g_dungeon);
      render_components(g_render_components);
    end;
  end;

  game_cleanup;


end.