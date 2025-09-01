program CGASLAC;

uses
  jfunc,    { 3rd party }
  timer,    { 3rd party }
  txtgraph, { 3rd party }
  Dungeon,
  Slacutil;

var
  { The main dungeon. }
  g_dungeon: DungeonType;

begin
  g_dungeon.Init;
  g_dungeon.add_enemy(5, 5, 12);
  g_dungeon.add_item(5, 5, 2);
  g_dungeon.set_square_type(5, 5, SQUARE_WALL);
  g_dungeon.set_square_seen(5, 5, True);

  Writeln(g_dungeon.get_square_type(5, 5));
  Writeln(g_dungeon.get_square_seen(5, 5));
  Writeln(g_dungeon.get_enemy(5, 5));
  Writeln(g_dungeon.get_item(5, 5));
end.