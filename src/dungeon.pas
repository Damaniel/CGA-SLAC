{ Functions and structures related to dungeons and dungeon generation

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Dungeon;

interface

const
   { The square types that a particular dungeon square can have }
   SQUARE_VOID = 0;
   SQUARE_WALL = 1;
   SQUARE_FLOOR = 2;

   { A generic 'nothing' value for enemy and item uids }
   NOTHING = -1;

   { Dungeon size definitions }
   DUNGEON_WIDTH = 60;
   DUNGEON_HEIGHT = 60;
   DUNGEON_GEN_NUM_ROWS = 5;
   DUNGEON_GEN_NUM_COLS = 5;
   NUM_REGIONS = DUNGEON_GEN_NUM_ROWS * DUNGEON_GEN_NUM_COLS;
   REGION_WIDTH = DUNGEON_WIDTH div DUNGEON_GEN_NUM_COLS;
   REGION_HEIGHT = DUNGEON_WIDTH div DUNGEON_GEN_NUM_ROWS;
   MIN_ROOM_WIDTH = 3;
   MIN_ROOM_HEIGHT = 3;

   { The maximum number of connections a room can have to other rooms }
   MAX_CONNECTIONS = 6;

type

{ A list of neighbors}
NeighborType=record
   num_neighbors: Byte;
   neighbors: array[0..3] of Byte;
end;

{ DungeonGenType - the content of a single region of the generated dungeon}
DungeonGenType=record
   room_x: Byte;
   room_y: Byte;
   room_width: Byte;
   room_height: Byte;
   connected: array[0..(MAX_CONNECTIONS - 1)] of Byte;
   num_connected: Byte;
end;

{ TODO : Do the encapsulation once the generator is done }
DungeonGenerator=object
   dungeon_rooms: array[0..DUNGEON_GEN_NUM_COLS-1, 0..DUNGEON_GEN_NUM_ROWS-1] of DungeonGenType;

   procedure Init;
   procedure generate;
   procedure get_region(region_idx: Integer; var region: DungeonGenType);
   procedure create_room(region_idx: Integer);
   procedure connect_rooms(from_region: Integer; to_region: Integer);
   procedure get_neighbors(region: Integer; var neighbors: NeighborType);
   function get_random_unconnected_neighbor(region: Integer) : Integer;
   function get_random_connected_neighbor(region: Integer) : Integer;
   procedure region_to_xy(region: Integer; var x: Integer; var y: Integer);
   function xy_to_region(x: Integer; y: Integer) : Integer;

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
   procedure create_from_gen_data(var gen: DungeonGenerator);
   procedure dump;

   private
      squares: array[0..DUNGEON_WIDTH-1, 0..DUNGEON_HEIGHT-1] of DungeonSquareType;
      procedure get_random_room_pos(x1: Integer; y1: Integer; x2: Integer; y2: Integer;
                                    var room_x: Integer; var room_y: Integer);
end;

var
  { The main dungeon and associated generator. }
  g_dungeon: SLACDungeon;
  g_generator: DungeonGenerator;

implementation

{ ------------------------------------------------------------------------------------------------- }
{ DungeonGenerator                                                                                  }
{ ------------------------------------------------------------------------------------------------- }

{ Init : Initialization function }
procedure DungeonGenerator.Init;
var
   x: Integer;
   y: Integer;
begin
   for x := 0 to DUNGEON_GEN_NUM_COLS - 1 do
   begin
      for y := 0 to DUNGEON_GEN_NUM_ROWS - 1 do
      begin
         dungeon_rooms[x][y].room_x := 0;
         dungeon_rooms[x][y].room_y := 0;
         dungeon_rooms[x][y].room_width := 0;
         dungeon_rooms[x][y].room_height := 0;
         dungeon_rooms[x][y].num_connected := 0;
      end;
   end;
end;

{ generate : generates a dungeon (rooms and connections) }
procedure DungeonGenerator.generate;
var
   region_x: Integer;
   region_y: Integer;
   region: Integer;
   neighbor_region: Integer;
   connected_count: Integer;
begin
   { Generate a room in every region }
   for region_y := 0 to DUNGEON_GEN_NUM_ROWS - 1 do
   begin
      for region_x := 0 to DUNGEON_GEN_NUM_COLS - 1 do
      begin
         region := xy_to_region(region_x, region_y);
         create_room(region);
      end;
   end;

   { Pick the initial spot, find random unconnected neighbors and continue until none are found. }
   connected_count := 0;
   region := Random(NUM_REGIONS);
   neighbor_region := get_random_unconnected_neighbor(region);
   while neighbor_region <> -1 do
   begin
      connect_rooms(region, neighbor_region);
      connected_count := connected_count + 1;
      region := neighbor_region;
      neighbor_region := get_random_unconnected_neighbor(region);
   end;

   { Now, pick sequential spots until one with an already connected neighbor is found, connect them
     and repeat until all rooms are marked as connected. }
{   while connected_count < NUM_REGIONS do
   begin
      region := 0;
      repeat
         neighbor_region := get_random_connected_neighbor(region);
         region := region + 1;
      until neighbor_region <> -1;
      connect_rooms(region, neighbor_region);
      connected_count := connected_count + 1;
      Writeln(connected_count);
   end;}

   { Finally, try connecting random regions that aren't already connected }
end;

procedure DungeonGenerator.get_region(region_idx: Integer; var region: DungeonGenType);
var
   region_x, region_y: Integer;
begin
   region_to_xy(region_idx, region_x, region_y);
   region := dungeon_rooms[region_x][region_y];
end;

{ create_room : adds a room to a region in the dungeon

  Parameters:
    region_x, region_y : the region to place the room
}
procedure DungeonGenerator.create_room(region_idx: Integer);
var
   region_x: Integer;
   region_y: Integer;
   room_width: Integer;
   room_height: Integer;
   room_x: Integer;
   room_y: Integer;
   rand_range: Integer;
   min_pos: Integer;
   max_pos: Integer;
begin
   { A room is a space inside a region.  Each dimension of the room is separate.
     The length of width of a room must be at least 4 and at most (region size - 2).
     The room can be anywhere in the region - connecting the rooms with passages
     will happen later when the final dungeon is generated.

     Note that the room defined here only contains the carved out floor for the room.
     When the final dungeon is assembled, a wall will be built around the floor space.
     This is why the maximum room dimension is (region_size - 2) - rooms can take up
     maximal space while still allowing room for walls. }

   { Create the width of the room }
   rand_range := (REGION_WIDTH - 2) - MIN_ROOM_WIDTH + 1;
   room_width := Random(rand_range) + MIN_ROOM_WIDTH;

   { Create the height of the room }
   rand_range := (REGION_HEIGHT - 2) - MIN_ROOM_HEIGHT + 1;
   room_height := Random(rand_range) + MIN_ROOM_HEIGHT;

   { Pick a room position that places the entire room within the range of 1..SECTOR_WIDTH-1 in both dimensions
     and place it randomly within the region.  Note that adjacent rooms may not connect directly to each other
     with a straight passage; we'll punt on the passage creation until we carve out the final dungeon. }

   { Start with the width }
   min_pos := 1;
   max_pos := (REGION_WIDTH - 2) - room_width + 1;
   room_x := Random(max_pos - min_pos) + min_pos;

   { Then the height }
   min_pos := 1;
   max_pos := (REGION_HEIGHT - 2) - room_height + 1;
   room_y := Random(max_pos - min_pos) + min_pos;

   region_to_xy(region_idx, region_x, region_y);
   dungeon_rooms[region_x][region_y].room_x := room_x;
   dungeon_rooms[region_x][region_y].room_y := room_y;
   dungeon_rooms[region_x][region_y].room_width := room_width;
   dungeon_rooms[region_x][region_y].room_height := room_height;

   Write('Created room of size ');
   Write(dungeon_rooms[region_x][region_y].room_width);
   Write(' x ');
   Write(dungeon_rooms[region_x][region_y].room_height);
   Write(' at ');
   Write(dungeon_rooms[region_x][region_y].room_x);
   Write(',');
   Writeln(dungeon_rooms[region_x][region_y].room_y);
end;

{ connect_rooms : joins two rooms by marking them as connected in the source and target room structs

  Parameters:
    region_x1, region_y1 : the source room region
    region_x2, region_y2 : the destination room region

   Note: the connections array holds numbers ranging between 0 and (DUNGEON_GEN_NUM_ROWS * DUNGEON_GEN_NUM_COLS - 1).
   Those numbers represent the different regions starting from the upper left corner and moving left to right,
   top to bottom.
}
procedure DungeonGenerator.connect_rooms(from_region: Integer; to_region: Integer);
var
   region_x1, region_y1: Integer;
   region_x2, region_y2: Integer;
   source_index: Integer;
   dest_index: Integer;
   source_connected: Integer;
   dest_connected: Integer;
   already_connected: Boolean;
   idx: Integer;
begin
   region_to_xy(from_region, region_x1, region_y1);
   region_to_xy(to_region, region_x2, region_y2);
   { If either the source or destination room has a spare open connection, then continue }
   if (dungeon_rooms[region_x1][region_y1].num_connected < MAX_CONNECTIONS) and
      (dungeon_rooms[region_x2][region_y2].num_connected < MAX_CONNECTIONS) then
   begin
      { Get the index of the source and destination regions }
      source_index := (region_y1 * DUNGEON_GEN_NUM_COLS) + region_x1;
      dest_index := (region_y2 * DUNGEON_GEN_NUM_ROWS) + region_x2;

      { these two variables are used to help make some of the following lines of code shorter }
      source_connected := dungeon_rooms[region_x1][region_y1].num_connected;
      dest_connected := dungeon_rooms[region_x2][region_y2].num_connected;

      { If both rooms are already directly connected to each other, skip the connection.
        Since rooms are connected in pairs, we'll just check the source room for the connection
        to the destination room. }
      already_connected := False;
      for idx := 0 to MAX_CONNECTIONS - 1 do
      begin
         if dungeon_rooms[region_x1][region_y1].connected[idx] = dest_index then
         begin
            already_connected := True;
         end;
      end;

      if already_connected = False then begin
         { Set the connected value of the source region to the destination region }
         dungeon_rooms[region_x1][region_y1].connected[source_connected] := dest_index;
         dungeon_rooms[region_x1][region_y1].num_connected := source_connected + 1;

         { Set the connected value of the destination region to the source region }
         dungeon_rooms[region_x2][region_y2].connected[dest_connected] := source_index;
         dungeon_rooms[region_x2][region_y2].num_connected := dest_connected + 1;
      end;
   end;
end;

{ get_neighbors - given a region index, return the region indices of its neighbors.

  Parameters:
    region : the region index of the region with neighbors (y * width + x)
    var neighbors: an list and count of neighbor region inidices.
}
procedure DungeonGenerator.get_neighbors(region: Integer; var neighbors: NeighborType);
var
   r_x: Integer;
   r_y: Integer;
begin
   neighbors.num_neighbors := 0;

   { Get the x,y position of the region}
   region_to_xy(region, r_x, r_y);

   { Check each of the four directions.  If a valid region, add it to the list }
   if r_x > 0 then begin
      neighbors.neighbors[neighbors.num_neighbors] := xy_to_region(r_x - 1, r_y);
      neighbors.num_neighbors := neighbors.num_neighbors + 1;
   end;
   if r_y > 0 then begin
      neighbors.neighbors[neighbors.num_neighbors] := xy_to_region(r_x, r_y - 1);
      neighbors.num_neighbors := neighbors.num_neighbors + 1;
   end;
   if r_x < (DUNGEON_GEN_NUM_COLS - 1) then begin
      neighbors.neighbors[neighbors.num_neighbors] := xy_to_region(r_x + 1, r_y);
      neighbors.num_neighbors := neighbors.num_neighbors + 1;
   end;
   if r_y < (DUNGEON_GEN_NUM_ROWS - 1) then begin
      neighbors.neighbors[neighbors.num_neighbors] := xy_to_region(r_x, r_y + 1);
      neighbors.num_neighbors := neighbors.num_neighbors + 1;
   end;
end;

{ xy_to_region - converts a region in x, y format to a single numeric value

  Parameters:
    x, y - the x, y coordinates of the target region
    region - the combined region value
}
function DungeonGenerator.xy_to_region(x: Integer; y: Integer) : Integer;
begin
   xy_to_region := y * DUNGEON_GEN_NUM_COLS + x;
end;

{ region_to_xy - converts a region in single numeric format back to x,y format

  Parameters:
    region - the combined region value
    x, y - the x,y coordinates of the target region
}
procedure DungeonGenerator.region_to_xy(region: Integer; var x: Integer; var y: Integer);
begin
   x := region mod DUNGEON_GEN_NUM_COLS;
   y := region div DUNGEON_GEN_NUM_COLS;
end;

{ get_random_unconnected_neighbor - picks an adjacent region that isn't connected to any other region.

   Parameters:
      region: the current region

   Returns:
      the randomly chosen neighbor, or -1 if all neighbors are already connected
}
function DungeonGenerator.get_random_unconnected_neighbor(region: Integer) : Integer;
begin
   get_random_unconnected_neighbor := -1;
end;

{ get_random_connected_neighbor - picks an adjacent region that is connected to any other region.

   Parameters:
      region: the current region

   Returns:
      the randomly chosen neighbor, or -1 if all neigbors are unconnected
}
function DungeonGenerator.get_random_connected_neighbor(region: Integer) : Integer;
begin
   get_random_connected_neighbor := -1;
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
      gen: A DungeonGenerator instance
}
procedure SLACDungeon.create_from_gen_data(var gen: DungeonGenerator);
var
   { The region to pull the generator/room info from }
   region_x: Integer;
   region_y: Integer;
   region_idx: Integer;
   { The counters used to carve rooms into the dungeon }
   idx_x: Integer;
   idx_y: Integer;
   { The position of the upper left corner of the room to carve }
   offset_x: Integer;
   offset_y: Integer;
   { A reference to a single region, used to extract room data for the region }
   region: DungeonGenType;
begin
   { Carve the rooms out of the base dungeon}
   for region_idx := 0 to NUM_REGIONS - 1 do
   begin
      gen.get_region(region_idx, region);
      { Get the room position and calculate the dungeon offset from it.
         Note that the offsets start one to the left / above the actual room area and
         the index ranges end one to the right / below the room area.  This allows us to draw
         the walls around the room more easily. }
      gen.region_to_xy(region_idx, region_x, region_y);
      offset_x := region_x * REGION_WIDTH + region.room_x - 1;
      offset_y := region_y * REGION_HEIGHT + region.room_y - 1;
      { Loop through the appropriate region in the dungeon and carve the room}
      for idx_y := offset_y to offset_y + region.room_height + 1do
      begin
         for idx_x := offset_x to offset_x + region.room_width + 1 do
         begin
            { If a left or right wall, set the square type to wall }
            if (idx_x = offset_x) or (idx_x = offset_x + region.room_width + 1) then
            begin
               set_square_type(idx_x, idx_y, SQUARE_WALL);
            end
            { If a top or bottom wall, set the square type to wall }
            else if (idx_y = offset_y) or (idx_y = offset_y + region.room_height + 1) then
            begin
               set_square_type(idx_x, idx_y, SQUARE_WALL);
            end
            else begin
               set_square_type(idx_x, idx_y, SQUARE_FLOOR);
            end;
         end;
      end;
   end;

   { Generate a list of unique connections between rooms - i.e. flatten the connected
     lists into a single list with no duplicate connections }

   { Carve connections between each pair of connected rooms }
end;

{ dump - debug function that prints a copy of the dungeon to the console.}
procedure SLACDungeon.dump;
var
   x: Integer;
   y: Integer;
begin
   for y := 0 to DUNGEON_HEIGHT - 1 do
   begin
      for x := 0 to DUNGEON_WIDTH - 1 do
      begin
         case get_square_type(x, y) of
            SQUARE_VOID: Write('.');
            SQUARE_WALL: Write('#');
            SQUARE_FLOOR: Write(' ');
         end;
      end;
      Writeln('');
   end;
end;

{ get_random_room_pos - returns a random position within the region specified by (x1,y1)-(x2,y2).

}
procedure SLACDungeon.get_random_room_pos(x1: Integer; y1: Integer; x2: Integer; y2: Integer;
                                          var room_x: Integer; var room_y: Integer);
begin

end;

end.
