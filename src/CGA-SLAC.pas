{ CGA-SLAC - a roguelike for DOS PCs with a CGA (or better) graphics card

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
program CGASLAC;

{$P+}

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Globals,
  State,
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
  idx: Integer;

procedure game_init;
begin
  Randomize;
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

  game_init;

  change_state(STATE_GAME);

  while g_exit_game = False do
  begin
    if (userTimerExpired(g_TimerInterval)) then
    begin
      process_input;
      render_components;
    end;
  end;

  game_cleanup;

end.