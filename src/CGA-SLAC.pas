program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Dungeon,
  Slacutil;

var
  count: Integer;
  x: Integer;
  nt: NeighborType;
begin
  Randomize;
  Writeln('init');
  g_generator.Init;
  Writeln('generate');
  g_generator.generate;
  Writeln('create_from_gen_data');
  g_dungeon.create_from_gen_data(g_generator);
  Writeln('dump');
  g_dungeon.dump;
end.