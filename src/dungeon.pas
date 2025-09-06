{ Functions and structures related to dungeons and dungeon generation

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Dungeon;

interface

const
   { The square types that a particular dungeon square can have }
   SQUARE_WALL = 0;
   SQUARE_FLOOR = 1;
   SQUARE_UP_STAIRS = 2;
   SQUARE_DOWN_STAIRS = 3;
   SQUARE_VOID = 4;

   WALL_LEFT = 0;
   WALL_RIGHT = 1;
   WALL_UP = 2;
   WALL_DOWN = 3;

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
   MAX_ROOM_WIDTH = 8;
   MAX_ROOM_HEIGHT = 8;

   { The maximum number of connections a room can have to other rooms }
   MAX_CONNECTIONS = 6;
   { The maximum number of room connections the entire dungeon can have
     Note that a standard dungeon will have NUM_REGIONS - 1 connections,
     but additional connections may be added later.  This number
     greatly overestimates the total potential connection count, but
     that's OK. }
   MAX_TOTAL_CONNECTIONS = NUM_REGIONS * 2;

type

{ A list of neighbors}
NeighborType=record
   num_neighbors: Byte;
   neighbors: array[0..3] of Byte;
end;

{ ConnectionType - a record containing the source and destination region of a connection}
ConnectionType=record
   source: Byte;
   dest: Byte;
end;

{ ConnectionListType - a list of unique connections }
ConnectionListType=record
   num_connections: Integer;
   connections: array[0..MAX_TOTAL_CONNECTIONS - 1] of ConnectionType;
end;

{ DungeonRegionType - the content of a single region of the generated dungeon}
DungeonRegionType=record
   room_x: Byte;
   room_y: Byte;
   room_width: Byte;
   room_height: Byte;
   connected: array[0..(MAX_CONNECTIONS - 1)] of Shortint;
   num_connected: Byte;
end;

{ DungeonGenerator - the class that actually generates the dungeon structure }
DungeonGenerator=object
   procedure Init;
   procedure generate;
   procedure get_region(region_idx: Integer; var region: DungeonRegionType);
   procedure region_to_xy(region: Integer; var x: Integer; var y: Integer);
   function xy_to_region(x: Integer; y: Integer) : Integer;
   function get_up_stair_region: Integer;
   function get_down_stair_region: Integer;

   private
      dungeon_regions: array[0..DUNGEON_GEN_NUM_COLS-1, 0..DUNGEON_GEN_NUM_ROWS-1] of DungeonRegionType;
      up_stair_region: Byte;
      down_stair_region: Byte;
      procedure create_room(region_idx: Integer);
      procedure connect_rooms(from_region: Integer; to_region: Integer);
      procedure get_neighbors(region: Integer; var neighbors: NeighborType);
      procedure dump_connections;
      function get_random_unconnected_neighbor(region: Integer) : Integer;
      function get_random_connected_neighbor(region: Integer) : Integer;
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
   procedure set_square_in_room(x: Integer; y: Integer; in_room: Boolean);
   procedure light_area(x: Integer; y: Integer);
   procedure get_room_extents(x: byte; y: Byte; var x1: Byte; var y1: Byte; var x2: Byte; var y2: Byte);
   function get_square_type(x: Integer; y: Integer) : Byte;
   function get_square_seen(x: Integer; y: Integer) : Boolean;
   function get_square_in_room(x: Integer; y: Integer) : Boolean;
   function get_enemy(x: Integer; y: Integer) : Shortint;
   function get_item(x: Integer; y: Integer) : Shortint;
   procedure create_from_gen_data(var gen: DungeonGenerator);
   procedure get_up_stair_pos(var x: Byte; var y: Byte);
   procedure get_down_stair_pos(var x: Byte; var y: Byte);
   procedure dump;

   private
      up_stair_x, up_stair_y: Byte;
      down_stair_x, down_stair_y: Byte;
      squares: array[0..DUNGEON_WIDTH-1, 0..DUNGEON_HEIGHT-1] of DungeonSquareType;
      procedure add_stairs(gen: DungeonGenerator);
      procedure generate_unique_connection_list(gen: DungeonGenerator; var clist: ConnectionListType);
      procedure get_random_room_pos(x1: Integer; y1: Integer; x2: Integer; y2: Integer;
                                    var room_x: Integer; var room_y: Integer);
      procedure carve_between_regions(src_region: Integer; dest_region: Integer; gen: DungeonGenerator);
      procedure carve_between_xy(x1: Integer; y1: Integer; x2: Integer; y2: Integer);
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
   idx: Integer;
begin
   for x := 0 to DUNGEON_GEN_NUM_COLS - 1 do
   begin
      for y := 0 to DUNGEON_GEN_NUM_ROWS - 1 do
      begin
         dungeon_regions[x][y].room_x := 0;
         dungeon_regions[x][y].room_y := 0;
         dungeon_regions[x][y].room_width := 0;
         dungeon_regions[x][y].room_height := 0;
         dungeon_regions[x][y].num_connected := 0;
         for idx := 0 to MAX_CONNECTIONS - 1 do
         begin
            dungeon_regions[x][y].connected[idx] := -1;
         end;
      end;
   end;
end;

{ generate : generates a dungeon (rooms and connections) }
procedure DungeonGenerator.generate;
var
   region: Integer;
   neighbor_region: Integer;
   connected_count: Integer;
   region_found: Boolean;
   dgt: DungeonRegionType;
begin

   { Generate a room in every region }
   for region := 0 to NUM_REGIONS - 1 do
   begin
      create_room(region);
   end;

   { Pick the initial spot, find random unconnected neighbors and continue until none are found. }
   { Note: the inital spot is connected to the first room it finds, so we'll start the count at
     1 so the counts line up correctly. }
   connected_count := 1;
   region := Random(NUM_REGIONS);
   { Mark the first region as having the up stairs }
   up_stair_region := region;
   neighbor_region := get_random_unconnected_neighbor(region);
   while neighbor_region <> -1 do
   begin
      connect_rooms(region, neighbor_region);
      connected_count := connected_count + 1;
      region := neighbor_region;
      neighbor_region := get_random_unconnected_neighbor(region);
   end;

   { Now, pick sequential regions until an unconnected one with an already connected neighbor is found.
     Connect them and repeat until all regions are marked as connected. }
   while (connected_count < NUM_REGIONS) do
   begin
      region := 0;
      region_found := False;
      repeat
         get_region(region, dgt);
         { Is this region unconnected? }
         if dgt.num_connected = 0 then begin
            { An unconnected region was found.  Get any connected neighbors }
            neighbor_region := get_random_connected_neighbor(region);
            { If any connected neighbor was found, connect the room, increment the connected count
              and end the loop }
            if neighbor_region <> -1 then begin
               connect_rooms(region, neighbor_region);
               connected_count := connected_count + 1;
               region_found := True;
            end
            { Otherwise, just continue the search with the next region }
            else begin
               region := region + 1;
            end;
         end
         else begin
            { This region is connected; continue the search with the next region. }
            region := region + 1;
         end;
      until (region_found = True) or (region >= NUM_REGIONS);
   end;
   { Mark last connected region as having the down stairs }
   down_stair_region := region;

   { Finally, try connecting random regions that aren't already connected }
end;

{ get_region - returns information about the specified region

   Parameters:
     - region_idx: the index value of the region
     - var region: the information about that region
}
procedure DungeonGenerator.get_region(region_idx: Integer; var region: DungeonRegionType);
var
   region_x, region_y: Integer;
begin
   region_to_xy(region_idx, region_x, region_y);
   region := dungeon_regions[region_x][region_y];
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
   room_width := Random(MAX_ROOM_WIDTH - MIN_ROOM_WIDTH - 1) + MIN_ROOM_WIDTH;

   { Create the height of the room }
   room_height := Random(MAX_ROOM_HEIGHT - MIN_ROOM_HEIGHT - 1) + MIN_ROOM_HEIGHT;

   { Pick a room position that places the entire room within the range of 1..REGION_WIDTH-1 in both dimensions
     and place it randomly within the region.  Note that adjacent rooms may not connect directly to each other
     with a straight passage; we'll punt on the passage creation until we carve out the final dungeon. }

   { Start with the width }
   room_x := (REGION_WIDTH - room_width) div 2;

   { Then the height }
   room_y := (REGION_HEIGHT - room_height) div 2;;

   region_to_xy(region_idx, region_x, region_y);
   dungeon_regions[region_x][region_y].room_x := room_x;
   dungeon_regions[region_x][region_y].room_y := room_y;
   dungeon_regions[region_x][region_y].room_width := room_width;
   dungeon_regions[region_x][region_y].room_height := room_height;
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
   if (dungeon_regions[region_x1][region_y1].num_connected < MAX_CONNECTIONS) and
      (dungeon_regions[region_x2][region_y2].num_connected < MAX_CONNECTIONS) then
   begin
      { Get the index of the source and destination regions }
      source_index := (region_y1 * DUNGEON_GEN_NUM_COLS) + region_x1;
      dest_index := (region_y2 * DUNGEON_GEN_NUM_ROWS) + region_x2;

      { these two variables are used to help make some of the following lines of code shorter }
      source_connected := dungeon_regions[region_x1][region_y1].num_connected;
      dest_connected := dungeon_regions[region_x2][region_y2].num_connected;

      { If both rooms are already directly connected to each other, skip the connection.
        Since rooms are connected in pairs, we'll just check the source room for the connection
        to the destination room. }
      already_connected := False;
      for idx := 0 to MAX_CONNECTIONS - 1 do
      begin
         if dungeon_regions[region_x1][region_y1].connected[idx] <> -1 then
         begin
            if dungeon_regions[region_x1][region_y1].connected[idx] = dest_index then
            begin
               already_connected := True;
            end;
         end;
      end;

      if already_connected = False then begin
         { Set the connected value of the source region to the destination region }
         dungeon_regions[region_x1][region_y1].connected[source_connected] := dest_index;
         dungeon_regions[region_x1][region_y1].num_connected := source_connected + 1;

         { Set the connected value of the destination region to the source region }
         dungeon_regions[region_x2][region_y2].connected[dest_connected] := source_index;
         dungeon_regions[region_x2][region_y2].num_connected := dest_connected + 1;
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
var
   num_candidates: Integer;
   candidates: array[0..3] of Byte;
   neighbors: NeighborType;
   dgt: DungeonRegionType;
   idx: Integer;
begin
   num_candidates := 0;
   get_neighbors(region, neighbors);
   for idx := 0 to neighbors.num_neighbors - 1 do
   begin
      get_region(neighbors.neighbors[idx], dgt);
      if dgt.num_connected = 0 then begin
         candidates[num_candidates] := neighbors.neighbors[idx];
         num_candidates := num_candidates + 1;
      end;
   end;
   if num_candidates = 0 then begin
      get_random_unconnected_neighbor := -1;
   end
   else begin
      get_random_unconnected_neighbor := candidates[Random(num_candidates)];
   end;
end;

{ get_random_connected_neighbor - picks an adjacent region that is connected to any other region.

   Parameters:
      region: the current region

   Returns:
      the randomly chosen neighbor, or -1 if all neigbors are unconnected
}
function DungeonGenerator.get_random_connected_neighbor(region: Integer) : Integer;
var
   num_candidates: Integer;
   candidates: array[0..3] of Byte;
   neighbors: NeighborType;
   dgt: DungeonRegionType;
   idx: Integer;
begin
   num_candidates := 0;
   get_neighbors(region, neighbors);
   for idx := 0 to neighbors.num_neighbors - 1 do
   begin
      get_region(neighbors.neighbors[idx], dgt);
      if dgt.num_connected <> 0 then begin
         candidates[num_candidates] := neighbors.neighbors[idx];
         num_candidates := num_candidates + 1;
      end;
   end;
   if num_candidates = 0 then begin
      get_random_connected_neighbor := -1;
   end
   else begin
      get_random_connected_neighbor := candidates[Random(num_candidates)];
   end;
end;

{ get_up_stair_region - returns the marked up stair region }
function DungeonGenerator.get_up_stair_region: Integer;
begin
   get_up_stair_region := up_stair_region;
end;

{ get_down_stair_region - returns the marked down stair region }
function DungeonGenerator.get_down_stair_region: Integer;
begin
   get_down_stair_region := down_stair_region;
end;

{ dump_connections - lists all connections between regions to the console.

  Note that these are not *unique* connections - each connected room has
  the other room as a destination in their own connected lists.  A
  unique list of connections can be generated by a separate function, to
  be used to determine what passages to carve.
}
procedure DungeonGenerator.dump_connections;
var
   region, idx: Integer;
   dgt: DungeonRegionType;
begin
   for region := 0 to NUM_REGIONS - 1 do
   begin
      get_region(region, dgt);
      Write('Region ');
      Write(region);
      Write(': connections - ');
      for idx := 0 to dgt.num_connected - 1 do
      begin
         Write(dgt.connected[idx]);
         Write(' ');
      end;
      Writeln('');
   end;
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

{ set_square_in_room: sets the in-room status of the square at the specified location

  Parameters:
    x, y : the location of the square to modify
    in_room : is this square in a room?
}
procedure SLACDungeon.set_square_in_room(x: Integer; y: Integer; in_room: Boolean);
begin
   if in_room = True then
   begin
      squares[x][y].flags := squares[x][y].flags or $20;
   end
   else begin
      squares[x][y].flags := squares[x][y].flags and $df;
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

{ get_square_in_room : gets the in-room status of the square at the specified location

  Parameters:
    x, y : the location of the square

  Returns:
    the in-room status of the square (True = in a room, False = not in a room)
}
function SLACDungeon.get_square_in_room(x: Integer; y: Integer) : Boolean;
var
   in_room: Byte;
begin
   in_room := (squares[x][y].flags and $20) shr 5;
   if in_room = 1 then
   begin
      get_square_in_room := True;
   end
   else begin
      get_square_in_room := False;
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
      var gen: A DungeonGenerator instance
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
   connection_idx: Integer;
   { The position of the upper left corner of the room to carve }
   offset_x: Integer;
   offset_y: Integer;
   { A reference to a single region, used to extract room data for the region }
   region: DungeonRegionType;
   { A unique connection list, used to carve between rooms }
   clist: ConnectionListType;
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
      offset_x := region_x * REGION_WIDTH + region.room_x;
      offset_y := region_y * REGION_HEIGHT + region.room_y;
      { Loop through the appropriate region in the dungeon and carve the room}
      for idx_y := offset_y to offset_y + region.room_height - 1 do
      begin
         for idx_x := offset_x to offset_x + region.room_width - 1 do
         begin
            set_square_type(idx_x, idx_y, SQUARE_FLOOR);
            set_square_in_room(idx_x, idx_y, True);
         end;
      end;
   end;

   { Generate a list of unique connections between rooms - i.e. flatten the connected
     lists into a single list with no duplicate connections }
   generate_unique_connection_list(gen, clist);

   { Carve connections between each pair of connected rooms }
   for connection_idx := 0 to clist.num_connections - 1 do
   begin
      carve_between_regions(clist.connections[connection_idx].source, clist.connections[connection_idx].dest, gen);
   end;

   { Add the stairs }
   add_stairs(gen);

end;

{ generate_unique_connection_list - takes the collection of connections from each region and
  generates a list containing only unique connections.

  We'll do this by iterating through every region, and only append source/destination pairs
  where the destination region is larger than the source region.

   Parameters:
     gen: a copy of the dungeon generator object (to get region info)
     var clist: the assembled list of unique connections
}
procedure SLACDungeon.generate_unique_connection_list(gen: DungeonGenerator; var clist: ConnectionListType);
var
   idx: Integer;
   idx2: Integer;
   dgt: DungeonRegionType;
begin
   clist.num_connections := 0;

   for idx := 0 to NUM_REGIONS - 1 do
   begin
      gen.get_region(idx, dgt);
      for idx2 :=0 to dgt.num_connected - 1 do
      begin
         if dgt.connected[idx2] > idx then
         begin
            clist.connections[clist.num_connections].source := idx;
            clist.connections[clist.num_connections].dest := dgt.connected[idx2];
            clist.num_connections := clist.num_connections + 1;
         end;
      end;
   end;
end;

{ carve_between_regions - carves a passage between a random point in the source region and a random point in
                          the destination region

   Parameters:
     src_region - the source region
     dest_region - the destination region
     gen - the dungeon generator (used to get region info)
}
procedure SLACDungeon.carve_between_regions(src_region: Integer; dest_region: Integer; gen: DungeonGenerator);
var
   src_dgt, dest_dgt: DungeonRegionType;
   source_wall_dir: Byte;
   src_room_top, src_room_left, src_room_bottom, src_room_right: Integer;
   dest_room_top, dest_room_left, dest_room_bottom, dest_room_right: Integer;
   src_region_x, src_region_y: Integer;
   dest_region_x, dest_region_y: Integer;
   source_x, source_y: Integer;
   dest_x, dest_y: Integer;
   cx, cy: Integer;
   i1x, i1y: Integer;
   i2x, i2y: Integer;
begin

   { Get the source and destination regions }
   gen.get_region(src_region, src_dgt);
   gen.get_region(dest_region, dest_dgt);
   gen.region_to_xy(src_region, src_region_x, src_region_y);
   gen.region_to_xy(dest_region, dest_region_x, dest_region_y);

   { Get the source room edges }
   src_room_top := src_region_y * REGION_HEIGHT + src_dgt.room_y - 1;
   src_room_left := src_region_x * REGION_WIDTH + src_dgt.room_x - 1;
   src_room_bottom := src_room_top + src_dgt.room_height;
   src_room_right := src_room_left + src_dgt.room_width;

   { Get the dest room edges }
   dest_room_top := dest_region_y * REGION_HEIGHT + dest_dgt.room_y - 1;
   dest_room_left := dest_region_x * REGION_WIDTH + dest_dgt.room_x - 1;
   dest_room_bottom := dest_room_top + dest_dgt.room_height;
   dest_room_right := dest_room_left + dest_dgt.room_width;

   { Determine the wall(s) to be connected and the center point }
   if src_region_x > dest_region_x then
   begin
      source_wall_dir := WALL_LEFT;
      cx := ((src_room_left - dest_room_right) div 2) + (dest_room_right);
   end
   else if src_region_x < dest_region_x then
   begin
      source_wall_dir := WALL_RIGHT;
      cx := ((dest_room_left - src_room_right) div 2) + (src_room_right);
   end
   else if src_region_y > dest_region_y then
   begin
      source_wall_dir := WALL_UP;
      cy := ((src_room_top - dest_room_bottom) div 2) + (dest_room_bottom);
   end
   else
   begin
      source_wall_dir := WALL_DOWN;
      cy := ((dest_room_top - src_room_bottom) div 2) + (src_room_bottom)
   end;

   { Find a spot on each wall not in a corner }
   case source_wall_dir of
      WALL_UP: begin
                  source_x := (src_room_right - src_room_left - 2) + src_room_left + 1;
                  source_y := src_room_top;
                  dest_x := (dest_room_right - dest_room_left - 2 ) + dest_room_left + 1;
                  dest_y := dest_room_bottom;
                  i1x := source_x;
                  i1y := cy;
                  i2x := dest_x;
                  i2y := cy;
               end;
      WALL_DOWN: begin
                  source_x := (src_room_right - src_room_left - 2) + src_room_left + 1;
                  source_y := src_room_bottom;
                  dest_x := (dest_room_right - dest_room_left - 2 ) + dest_room_left + 1;
                  dest_y := dest_room_top;
                  i1x := source_x;
                  i1y := cy;
                  i2x := dest_x;
                  i2y := cy;
                 end;
      WALL_LEFT: begin
                  source_x := src_room_left;
                  source_y := (src_room_bottom - src_room_top - 2) + src_room_top + 1;
                  dest_x := dest_room_right;
                  dest_y := (dest_room_bottom - dest_room_top - 2) + dest_room_top + 1;
                  i1x := cx;
                  i1y := source_y;
                  i2x := cx;
                  i2y := dest_y;
                 end;
      WALL_RIGHT: begin
                  source_x := src_room_right;
                  source_y := (src_room_bottom - src_room_top - 2) + src_room_top + 1;
                  dest_x := dest_room_left;
                  dest_y := (dest_room_bottom - dest_room_top - 2) + dest_room_top + 1;
                  i1x := cx;
                  i1y := source_y;
                  i2x := cx;
                  i2y := dest_y;
                  end;
   end;

   { Connect a straight line to the middle position}
   carve_between_xy(source_x, source_y, i1x, i1y);

   { Connect the first middle position to the second }
   carve_between_xy(i1x, i1y, i2x, i2y);

   { Connect the second middle position to the second wall }
   carve_between_xy(i2x, i2y, dest_x, dest_y);

end;

{ carve_between_xy - carves all of the dungeon spaces between two locations.  The two locations should be
                     form either a horizontal or vertical line.

   Parameters:
     x1, y1 - the location to carve from
     x2, y2 - the location to carve to
}
procedure SLACDungeon.carve_between_xy(x1: Integer; y1: Integer; x2: Integer; y2: Integer);
var
   start_pos, end_pos: Integer;
   idx: Integer;
begin
   { All carving will be either horizontal or vertical}

   { Determine if horizontal or vertical }

   { If horizontal, iterate from the lower of the two x values to the higher of the two }
   { Carve each space along the way }
   if y1 = y2 then
   begin
      if (x1 <= x2) then
      begin
         start_pos := x1;
         end_pos := x2;
      end
      else begin
         start_pos := x2;
         end_pos := x1;
      end;
      for idx := start_pos to end_pos do
      begin
         set_square_type(idx, y1, SQUARE_FLOOR);
         { set_square_in_room(idx, y1, False); }
      end;
   end
   { If vertical, iterate from the lower of the two y values to the higher of the two }
   { Carve each space along the way }
   else if x1 = x2 then
   begin
      if (y1 <= y2) then
      begin
         start_pos := y1;
         end_pos := y2;
      end
      else begin
         start_pos := y2;
         end_pos := y1;
      end;
      for idx := start_pos to end_pos do
      begin
         set_square_type(x1, idx, SQUARE_FLOOR);
         { set_square_in_room(x1, idx, False);}
      end;
   end
   else begin
      Writeln('Warning: non-horizontal, non-vertical carve request!');
   end;
end;

procedure SLACDungeon.add_stairs(gen: DungeonGenerator);
var
   dgt: DungeonRegionType;
   room_top, room_left: Integer;
   region_x, region_y: Integer;
   stair_x, stair_y: Integer;
   up_stair_region, down_stair_region: Integer;
begin
   { Get a random room position from the up stairs region}
   up_stair_region := gen.get_up_stair_region;
   gen.get_region(up_stair_region, dgt);
   gen.region_to_xy(up_stair_region, region_x, region_y);
   room_top := region_y * REGION_HEIGHT + dgt.room_y;
   room_left := region_x * REGION_WIDTH + dgt.room_x;
   get_random_room_pos(room_left, room_top, room_left + dgt.room_width - 1,
                       room_top + dgt.room_height - 1, stair_x, stair_y);
   { Add up stairs }
   set_square_type(stair_x, stair_y, SQUARE_UP_STAIRS);
   up_stair_x := stair_x;
   up_stair_y := stair_y;

   { Get a random room position from the down stairs region }
   down_stair_region := gen.get_down_stair_region;
   gen.get_region(down_stair_region, dgt);
   gen.region_to_xy(down_stair_region, region_x, region_y);
   room_top := region_y * REGION_HEIGHT + dgt.room_y;
   room_left := region_x * REGION_WIDTH + dgt.room_x;
   get_random_room_pos(room_left, room_top, room_left + dgt.room_width - 1,
                       room_top + dgt.room_height - 1, stair_x, stair_y);

   { Add down stairs }
   set_square_type(stair_x, stair_y, SQUARE_DOWN_STAIRS);
   down_stair_x := stair_x;
   down_stair_y := stair_y;
end;

{ get_random_room_pos - returns a random position within the region specified by (x1,y1)-(x2,y2).

   Parameters:
     x1, y1, x2, y2: the extents of the room
     var room_x, var room_y: the random position of the space selected in the room
}
procedure SLACDungeon.get_random_room_pos(x1: Integer; y1: Integer; x2: Integer; y2: Integer;
                                          var room_x: Integer; var room_y: Integer);
begin
   room_x := Random(x2 - x1) + x1;
   room_y := Random(y2 - y1) + y1;
end;

procedure SLACDungeon.get_up_stair_pos(var x: Byte; var y: Byte);
begin
   x := up_stair_x;
   y := up_stair_y;
end;

procedure SLACDungeon.get_down_stair_pos(var x: Byte; var y: Byte);
begin
   x := down_stair_x;
   y := down_stair_y;
end;

procedure SLACDungeon.light_area(x: Integer; y: Integer);
var
   x1, y1, x2, y2: Byte;
   idx_x, idx_y : Byte;
begin
   { If in a room, light the room }
   if get_square_in_room(x, y) = True then
   begin
      get_room_extents(x, y, x1, y1, x2, y2);
      { Check to see if a spot in the room is already lit.  If not, light the room }
      { Note we check all four spots diagonally from the player, since the spots
        where the player is standing now will already be technically seen, as we
        marked it when the player moved to the previous step.  By checking the 4 diagonals,
        one of them will catch the room but not a square that was previously marked.
        Hacky, but 4 comparisons per move in a room beats potentially dozens by just
        marking each spot in the room every time the player moves. }
      if (get_square_seen(x - 1 , y - 1) = False) or
         (get_square_seen(x + 1, y - 1) = False) or
         (get_square_seen(x - 1, y + 1) = False) or
         (get_square_seen(x + 1, y + 1) = False) then
      begin
         for idx_y := y1 to y2 do
         begin
            for idx_x := x1 to x2 do
            begin
               set_square_seen(idx_x, idx_y, True);
            end;
         end;
      end;
   end;

   { Light the square and the ones immediately surrounding }
   set_square_seen(x - 1, y - 1, True);
   set_square_seen(x, y - 1, True);
   set_square_seen(x + 1, y - 1, True);
   set_square_seen(x - 1, y, True);
   set_square_seen(x, y, True);
   set_square_seen(x + 1, y, True);
   set_square_seen(x - 1, y + 1, True);
   set_square_seen(x, y + 1, True);
   set_square_seen(x + 1, y + 1, True);

end;

procedure SLACDungeon.get_room_extents(x: Byte; y: Byte; var x1: Byte; var y1: Byte; var x2: Byte; var y2: Byte);
var
   lx, ty, rx, by: Byte;
begin
   { Check to see if we're even in a room to begin with}
   if get_square_in_room(x, y) = True then
   begin
      { Get the left extent }
      lx := x;
      while get_square_in_room(lx, y) = True do
      begin
         lx := lx - 1;
      end;
      x1 := lx;

      { Get the right extent }
      rx := x;
      while get_square_in_room(rx, y) = True do
      begin
         rx := rx + 1;
      end;
      x2 := rx;

      { Get the top extent }
      ty := y;
      while get_square_in_room(x, ty) = True do
      begin
         ty := ty - 1;
      end;
      y1 := ty;

      { Get the bottom extent }
      by := y;
      while get_square_in_room(x, by) = True do
      begin
         by := by + 1;
      end;
      y2 := by;
   end;
end;


{ dump - debug function that prints a copy of the dungeon to the console.}
procedure SLACDungeon.dump;
var
   x: Integer;
   y: Integer;
begin
{   Writeln('--------------------------------------');
   Writeln('Dungeon map');
   Writeln('--------------------------------------');
   for y := 0 to DUNGEON_HEIGHT - 1 do
   begin
      for x := 0 to DUNGEON_WIDTH - 1 do
      begin
         case get_square_type(x, y) of
            SQUARE_VOID: Write('.');
            SQUARE_WALL: Write('#');
            SQUARE_FLOOR: Write(' ');
            SQUARE_UP_STAIRS: Write('<');
            SQUARE_DOWN_STAIRS: Write('>');
         end;
      end;
      Writeln('');
   end;

   Writeln('--------------------------------------');
   Writeln('Room map');
   Writeln('--------------------------------------');
   for y := 0 to DUNGEON_HEIGHT - 1 do
   begin
      for x := 0 to DUNGEON_WIDTH - 1 do
      begin
         if get_square_in_room(x, y) = True then
         begin
            Write('#');
         end
         else begin
            Write(' ');
         end;
      end;
      Writeln('');
   end;

   Writeln('--------------------------------------');
   Writeln('Visible map');
   Writeln('--------------------------------------');
   for y := 0 to DUNGEON_HEIGHT - 1 do
   begin
      for x := 0 to DUNGEON_WIDTH - 1 do
      begin
         if get_square_seen(x, y) = True then
         begin
            Write(' ');
         end
         else begin
            Write('#');
         end;
      end;
      Writeln('');
   end;}
end;

end.
