program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Globals,
  Dungeon,
  Player,
  Render,
  Input;

const
  FRAME_RATE = 30;

var
  g_TimerInterval: Word;

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
  g_generator.Init;
  g_generator.generate;
  g_dungeon.create_from_gen_data(g_generator);
  g_render_components.render_dungeon := True;
  g_render_components.render_interface := True;
  g_render_components.render_interface_values := True;

  while g_exit_game = False do
  begin
    process_input;
    render_components(g_render_components);
  end;

  game_cleanup;
end.