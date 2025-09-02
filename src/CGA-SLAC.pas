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
  g_generator.Init;
  g_generator.generate;
  g_dungeon.create_from_gen_data(g_generator);
  g_dungeon.dump;
  g_generator.dump_connections;
end.