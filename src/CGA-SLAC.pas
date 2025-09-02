program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Dungeon,
  Render,
  Input,
  Slacutil;

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
  g_generator.Init;
  g_generator.generate;
  g_dungeon.create_from_gen_data(g_generator);
  g_dungeon.dump;

  g_render_components.render_dungeon := True;

  while g_exit_game = False do
  begin
    process_input;
    render_components(g_render_components);
  end;

  game_cleanup;
end.