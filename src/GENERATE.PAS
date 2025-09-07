{ generators for enemies and items }

unit Generate;

interface

uses
    Globals;

const
    GEN_WEAPON = 0;
    GEN_ARMOR = 1;
    GEN_POTION = 2;
    GEN_SCROLL = 3;
    GEN_MONEY = 4;

    { There's a 10% chance of rolling something 1-2 levels out of depth }
    FIRST_OOD_ODDS = 25;
    { There's a 1% chance (10% of 10%) chance of rolling something 3-4 levels out of depth }
    SECOND_OOD_ODDS = 10;

    { How many floors above the current one is the cutoff for the low end of the enemy range? }
    MIN_FLOOR_CUTOFF = 6;

    { How many floors to add to the maximum floor level if an out of depth check is triggered }
    FIRST_OOD_FLOOR_DIFF = 2;
    SECOND_OOD_FLOOR_DIFF = 4;

procedure generate_random_enemy(floor: Integer; var enemy_idx: Integer);
procedure generate_random_drop(floor: Integer);
procedure generate_random_item(floor: Integer; var item_idx: Integer);
procedure generate_random_weapon(floor: Integer; var item_idx: Integer; var plus_mod: Byte);
procedure generate_random_armor(floor: Integer; var item_idx: Integer; var plus_mod: Byte);

implementation

{ generate_random_enemy - generates an enemy suitable for placement at a particular dungeon floor

  Parameters:
    floor: the floor the monster is intended to be placed on
    var enemy_idx: the offset of the selected enemy in the monster data table

  Note the use of 'NUM_MONSTERS - 2' as the end point of ranges below.  These added checks are to
  ensure that Megalith (at index NUM_MONSTERS-1) isn't selected randomly.
}
procedure generate_random_enemy(floor: Integer; var enemy_idx: Integer);
var
    idx, min_index, max_index: Integer;
begin

    { The lowest end of the range is the weakest enemy 10 or fewer floors above the current one }
    if floor <= MIN_FLOOR_CUTOFF then
    begin
        min_index := 0;
    end
    else begin
        idx := 0;
        while (floor - g_monster_data[idx].min_floor > MIN_FLOOR_CUTOFF) and (idx <= NUM_MONSTERS - 2) do
        begin
            idx := idx + 1;
        end;
        min_index := idx;
    end;

    { The highest natural end of the range is the strongest enemy <= the current floor }
    idx := min_index;
    while (floor - g_monster_data[idx].min_floor >= 0) and (idx <= NUM_MONSTERS - 2) do
    begin
        idx := idx + 1;
    end;
    max_index := idx - 1;


    { ood_index is the strongest enemy 2 or fewer levels higher than the current floor }
    if Random(100) < FIRST_OOD_ODDS then begin
        idx := max_index;
        while (g_monster_data[idx].min_floor - floor <= FIRST_OOD_FLOOR_DIFF) and (idx <= NUM_MONSTERS - 2) do
        begin
            idx := idx + 1;
        end;
        if Random(100) < SECOND_OOD_ODDS then begin
            while (g_monster_data[idx].min_floor - floor <= SECOND_OOD_FLOOR_DIFF) and (idx <= NUM_MONSTERS - 2) do
            begin
                idx := idx + 1;
            end;
        end;
        max_index := idx - 1;
    end;


    { If the end of the range includes Megalith, remove him}
    if max_index > NUM_MONSTERS - 2 then begin
        max_index := NUM_MONSTERS - 2;
    end;

    { Pick an enemy between the min index and the max index }
    enemy_idx := Random(max_index - min_index + 1) + min_index;

end;

procedure generate_random_drop(floor: Integer);
begin
end;

procedure generate_random_item(floor: Integer; var item_idx: Integer);
begin
end;

procedure generate_random_weapon(floor: Integer; var item_idx: Integer; var plus_mod: Byte);
begin
end;

procedure generate_random_armor(floor: Integer; var item_idx: Integer; var plus_mod: Byte);
begin
end;

end.