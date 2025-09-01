program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Dungeon,
  Slacutil;

var
  count: Integer;
begin
  Randomize;
  g_generator.Init;
  g_generator.create_room(0, 0);
end.