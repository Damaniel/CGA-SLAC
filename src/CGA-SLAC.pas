program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Dungeon,
  Slacutil;

var
  { The main dungeon. }
  g_dungeon: SLACDungeon;
  g_generator: DungeonGenerator;

begin
  g_generator.Init;
end.