{ Functions and structures related to dungeons and dungeon generation

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Dungeon;

interface

const
   { The square types that a particular dungeon square can have }
   SQUARE_FLOOR = 0;
   SQUARE_WALL = 1;

   { A generic 'nothing' value for enemy and item uids }
   NOTHING = -1;

   { Dungeon size definitions }
   DUNGEON_WIDTH = 60;
   DUNGEON_HEIGHT = 60;
   DUNGEON_GEN_NUM_ROWS = 5;
   DUNGEON_GEN_NOM_COLS = 5;
   SECTOR_WIDTH = DUNGEON_WIDTH / DUNGEON_GEN_NOM_COLS;
   SECTOR_HEIGHT = DUNGEON_WIDTH / DUNGEON_GEN_NUM_ROWS;

type
{ DungeonGenType - the content of a single region of the generated dungeon}
DungeonGenType=record
   room_x: Byte;
   room_y: Byte;
   room_width: Byte;
   room_height: Byte;
   connected: array[0..5] of Byte;
end;

DungeonGenerator=object
   procedure Init;
   procedure generate;

   private
      dungeon_rooms: array[0..DUNGEON_GEN_NOM_COLS-1, 0..DUNGEON_GEN_NUM_ROWS-1] of DungeonGenType;
      procedure create_room(region_x: Integer; region_y: Integer);
      procedure connect_rooms(region_x1: Integer; region_y1: Integer; region_x2: Integer; region_y2: Integer);
end;

{ DungeonSquareType - the content of a single carved square of the dungeon}
DungeonSquareType=record
   flags: Byte;
   enemy_uid: Shortint;
   item_uid: Shortint;
end;

{ SLACDungeon - the complete carved dungeon }
SLACDungeon=object
   procedure Init;
   procedure initialize_square(x: Integer; y: Integer);
   procedure add_enemy(x: Integer; y: Integer; uid: Integer);
   procedure add_item(x: Integer; y: Integer; uid: Integer);
   procedure set_square_type(x: Integer; y: Integer; square_type: Byte);
   procedure set_square_seen(x: Integer; y: Integer; seen: Boolean);
   function get_square_type(x: Integer; y: Integer) : Byte;
   function get_square_seen(x: Integer; y: Integer) : Boolean;
   function get_enemy(x: Integer; y: Integer) : Shortint;
   function get_item(x: Integer; y: Integer) : Shortint;
   procedure create_from_gen_data;

   private
      squares: array[0..DUNGEON_WIDTH-1, 0..DUNGEON_HEIGHT-1] of DungeonSquareType;
end;

implementation

{ ------------------------------------------------------------------------------------------------- }
{ DungeonGenerator                                                                                  }
{ ------------------------------------------------------------------------------------------------- }

{ Init : Initialization function }
procedure DungeonGenerator.Init;
begin
end;

{ generate : generates a dungeon (rooms and connections) }
procedure DungeonGenerator.generate;
begin
end;

{ create_room : adds a room to a region in the dungeon

  Parameters:
    region_x, region_y : the region to place the room
}
procedure DungeonGenerator.create_room(region_x: Integer; region_y: Integer);
begin
end;

{ connect_rooms : joins two rooms by marking them as connected in the source and target room structs

  Parameters:
    region_x1, region_y1 : the source room region
    region_x2, region_y2 : the destination room region
}
procedure DungeonGenerator.connect_rooms(region_x1: Integer; region_y1: Integer; region_x2: Integer; region_y2: Integer);
begin
end;

{ ------------------------------------------------------------------------------------------------- }
{ SLACDungeon                                                                                       }
{ ------------------------------------------------------------------------------------------------- }

{ Init : Initialization function }
procedure SLACDungeon.Init;
var
   x: Integer;
   y: Integer;
begin
   for x := 0 to DUNGEON_WIDTH - 1 do
   begin
      for y := 0 to DUNGEON_HEIGHT - 1 do
      begin
         initialize_square(x, y);
      end;
   end;
end;

{ initialize_square : sets the default state for the square at a specified location

  Parameters:
    x, y : the position of the square to initialize
}
procedure SLACDungeon.initialize_square(x: Integer; y: Integer);
begin
   squares[x][y].flags := $00;
   squares[x][y].enemy_uid := NOTHING;
   squares[x][y].item_uid := NOTHING;
end;

{ add_enemy : Places an enemy reference in the square at the specified location

  Parameters:
    x, y : the position of the square to modify
    uid : the uid of the enemy in the active enemy list
}
procedure SLACDungeon.add_enemy(x: Integer; y: Integer; uid: Integer);
begin
   squares[x][y].enemy_uid := uid;
end;

{ add_item : Places an item reference in the square at the specified location

  Parameters:
    x, y : the position of the square to modify
    uid : the uid of the item in the active item list
}
procedure SLACDungeon.add_item(x: Integer; y: Integer; uid: Integer);
begin
   squares[x][y].item_uid := uid;
end;

{ set_square_type: sets the type of square (floor or wall) of the square at the specified location

  Parameters:
    x, y : the location of the square to modify
    square_type : the type of the square (SQUARE_FLOOR or SQUARE_WALL)
}
procedure SLACDungeon.set_square_type(x: Integer; y: Integer; square_type: Byte);
var
   st: Byte;
begin
   squares[x][y].flags := squares[x][y].flags and $F0;
   st := square_type and $0F;
   squares[x][y].flags := squares[x][y].flags or st;
end;

{ set_square_seen: sets the visible status of the square at the specified location

  Parameters:
    x, y : the location of the square to modify
    seen : has this square been seen (and therefore should it be visible?)
}
procedure SLACDungeon.set_square_seen(x: Integer; y: Integer; seen: Boolean);
begin
   if seen = True then
   begin
      squares[x][y].flags := squares[x][y].flags or $10;
   end
   else begin
      squares[x][y].flags := squares[x][y].flags and $ef;
   end;
end;

{ get_square_type : gets the square type of the square at the specified location

  Parameters:
    x, y : the location of the square

  Returns:
    the type of the square (SQUARE_WALL or SQUARE_FLOOR)
}
function SLACDungeon.get_square_type(x: Integer; y: Integer) : Byte;
begin
   get_square_type := squares[x][y].flags and $0F;
end;

{ get_square_seen : gets the visibility of the square at the specified location

  Parameters:
    x, y : the location of the square

  Returns:
    the visibility of the square (True = has been seen, False = hasn't been seen)
}
function SLACDungeon.get_square_seen(x: Integer; y: Integer) : Boolean;
var
   seen: Byte;
begin
   seen := (squares[x][y].flags and $10) shr 4;
   if seen = 1 then
   begin
      get_square_seen := True;
   end
   else begin
      get_square_seen := False;
   end;
end;

{ get_enemy : gets the enemy, if any, on the square at the specified location

  Parameters:
    x, y : the location of the square

  Returns:
    the uid of the enemy on the square, or NOTHING if no enemy is present
}
function SLACDungeon.get_enemy(x: Integer; y: Integer) : Shortint;
begin
   get_enemy := squares[x][y].enemy_uid;
end;

{ get_item : gets the items, if any, on the square at the specified location

  Parameters:
    x, y : the location of the square

  Returns:
    the uid of the item on the square, or NOTHING if no item is present
}
function SLACDungeon.get_item(x: Integer; y: Integer) : Shortint;
begin
   get_item := squares[x][y]. item_uid;
end;

{ create_from_gen_data : converts the generated dungeon map into the final dungeon struct

   Parameters:
      None (Note: the data is pulled from g_dungeon_rooms)
}
procedure SLACDungeon.create_from_gen_data;
begin
end;

end.
