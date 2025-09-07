{ generators for enemies and items }

unit Generate;

interface

uses
    Globals;

const
    GEN_WEAPON_TYPE = 0;
    GEN_ARMOR_TYPE = 1;
    GEN_ITEM_TYPE = 2;
    NUM_GEN_TYPES = 3;

    { There's a 25% chance of rolling an enemy 1-2 levels out of depth }
    FIRST_OOD_ODDS = 25;
    { There's a 2.5% chance (10% of 25%) chance of rolling an enemy 3-4 levels out of depth }
    SECOND_OOD_ODDS = 10;

    { How many floors above the current one is the cutoff for the low end of the enemy range? }
    MIN_FLOOR_CUTOFF = 6;

    { How many floors to add to the maximum floor level if an out of depth check is triggered }
    FIRST_OOD_FLOOR_DIFF = 2;
    SECOND_OOD_FLOOR_DIFF = 4;

    MAX_GENERATE_ATTEMPTS = 50;

    PLUS_MOD_CHANCE = 15;
type

GenItemType=record
    item_type: Integer;
    item_idx: Integer;
    quantity: Integer;
    plus_mod: Byte;
end;

procedure generate_random_enemy(floor: Integer; var enemy_idx: Integer);
procedure generate_random_drop(floor: Integer; var gen_item: GenItemType);
procedure generate_random_item(floor: Integer; var item_idx: Integer; var quant: Integer);
procedure generate_random_weapon(floor: Integer; var item_idx: Integer; var plus_mod: Integer);
procedure generate_random_armor(floor: Integer; var item_idx: Integer; var plus_mod: Integer);
procedure dump_item(i: GenItemType);
function get_item_at_breakpoint(idx: Integer) : Integer;
function get_weapon_at_breakpoint(idx: Integer) : Integer;
function get_armor_at_breakpoint(idx: Integer) : Integer;
function gen_check(floor: Integer; min_floor: Integer) : Boolean;
function get_plus_mod_val : Integer;

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

procedure generate_random_drop(floor: Integer; var gen_item: GenItemType);
var
    item_type: Integer;
    item_idx: Integer;
    r: Integer;
    val: Integer;
begin
    r := Random(100);
    { 15 % chance of a weapon, 35 % chance of an armor, 50% chance of an item }
    if (r < 15) then item_type := GEN_WEAPON_TYPE;
    if (r >= 15) and (r < 50) then item_type := GEN_ARMOR_TYPE;
    if (r >= 50) then item_type := GEN_ITEM_TYPE;

    gen_item.item_type := item_type;
    case item_type of
        GEN_WEAPON_TYPE: begin
                            generate_random_weapon(floor, item_idx, val);
                            gen_item.plus_mod := val;
                        end;
        GEN_ARMOR_TYPE:  begin
                            generate_random_armor(floor, item_idx, val);
                            gen_item.plus_mod := val;
                         end;
        GEN_ITEM_TYPE:   begin
                            generate_random_item(floor, item_idx, val);
                            gen_item.quantity := val;
                         end;
    end;
    gen_item.item_idx := item_idx;
end;

{ generate_random_item - create an arbitrary item }
procedure generate_random_item(floor: Integer; var item_idx: Integer; var quant: Integer);
var
    i, r: Integer;
    gen_idx: Integer;
    generated: Boolean;
begin
    { Repeat until item generated or 50 iterations have occurred}
    generated := False;
    gen_idx := 0;
    i := NOTHING;

    while (generated = False) and (gen_idx < MAX_GENERATE_ATTEMPTS) do
    begin
        { Roll a random between 0 and the highest breakpoint value}
        r := Random(g_item_rarity_breakpoints[NUM_ITEMS - 1]);
        { Find the item that's represented by the random }
        i := get_item_at_breakpoint(r);

        generated := gen_check(floor, g_item_data[i].min_floor);
        if generated = True then
        begin
            item_idx := i;
        end;
        gen_idx := gen_idx + 1;
    end;

    if generated = False then
    begin
        item_idx := DEFAULT_ITEM_IDX; { Copper coin }
    end;

    { if the item is currency, calculate some quantity of it
      TODO: make the quant increase based on the type of currency
      (i.e. diamonds should generate more quant than copper given the same
       floor)
    }
    if g_item_data[i].class = ITEM_MONEY then
    begin
        quant := (Random(100) * floor) + 1;
    end
    else begin
        quant := 1;
    end;
end;

procedure generate_random_weapon(floor: Integer; var item_idx: Integer; var plus_mod: Integer);
var
    i, r: Integer;
    gen_idx: Integer;
    generated: Boolean;
begin
    { Repeat until item generated or 50 iterations have occurred}
    generated := False;
    gen_idx := 0;
    i := NOTHING;

    while (generated = False) and (gen_idx < MAX_GENERATE_ATTEMPTS) do
    begin
        { Roll a random between 0 and the highest breakpoint value}
        r := Random(g_weapon_rarity_breakpoints[NUM_WEAPONS - 1]);
        { Find the weapon that's represented by the random }
        i := get_weapon_at_breakpoint(r);

        generated := gen_check(floor, g_weapon_data[i].min_floor);
        if generated = True then
        begin
            item_idx := i;
        end;
        gen_idx := gen_idx + 1;
    end;

    if generated = False then
    begin
        item_idx := DEFAULT_WEAPON_IDX; { Wooden Dagger }
    end;

    plus_mod := get_plus_mod_val;
end;

procedure generate_random_armor(floor: Integer; var item_idx: Integer; var plus_mod: Integer);
var
    i, r: Integer;
    gen_idx: Integer;
    generated: Boolean;
begin
    { Repeat until item generated or 50 iterations have occurred}
    generated := False;
    gen_idx := 0;
    i := NOTHING;

    while (generated = False) and (gen_idx < MAX_GENERATE_ATTEMPTS) do
    begin
        { Roll a random between 0 and the highest breakpoint value}
        r := Random(g_armor_rarity_breakpoints[NUM_ARMORS - 1]);
        { Find the weapon that's represented by the random }
        i := get_armor_at_breakpoint(r);

        generated := gen_check(floor, g_armor_data[i].min_floor);
        if generated = True then
        begin
            item_idx := i;
        end;
        gen_idx := gen_idx + 1;
    end;

    if generated = False then
    begin
        item_idx := DEFAULT_ARMOR_IDX; { Wood Shield }
    end;

    plus_mod := get_plus_mod_val;
end;

function get_plus_mod_val : Integer;
var
    plus_mod: Integer;
    idx: Integer;
    cont: Boolean;
begin
    plus_mod := 0;
    cont := True;

    for idx := 1 to 5 do
    begin
        if Random(100) < PLUS_MOD_CHANCE then
        begin
            plus_mod := plus_mod + 1;
        end
        else begin
            break;
        end;
    end;

    get_plus_mod_val := plus_mod;
end;

function gen_check(floor: Integer; min_floor: Integer) : Boolean;
var
    floor_delta: Integer;
    odds: Byte;
begin
    gen_check := False;
    floor_delta := min_floor - floor;
    if min_floor <= floor then
    begin
        gen_check := True;
    end
    else begin
        { If the current floor is 5 or more lower than the minimum_floor,
          then roll a random between 0-99.  If that roll equals zero,
          roll a second random between 0-99.  If that roll is less than
          50, the item is generated (essentially 0.5% odds)
        }
        if floor_delta > 5 then
        begin
            if Random(100) = 0 then
            begin
                if Random(100) < 50 then
                begin
                    gen_check := True;
                end;
            end;
        end
        else begin
            { Otherwise, the odds of the out of depth roll depends on the difference between
              the current floor and min floor.  See the docs for more information.}
            case (floor_delta) of
                1: odds := 50;
                2: odds := 25;
                3: odds := 12;
                4: odds := 6;
                5: odds := 3;
            end;
            if Random(100) < odds then
            begin
                gen_check := True;
            end;
        end;
    end;
end;

function get_item_at_breakpoint(idx: Integer) : Integer;
var
    c: Integer;
begin
    if (idx < 0) or (idx > g_item_rarity_breakpoints[NUM_ITEMS - 1]) then
    begin
        get_item_at_breakpoint := NOTHING;
    end
    else begin
        for c := 0 to NUM_ITEMS - 1 do
        begin
            if idx <= g_item_rarity_breakpoints[c] then begin
                get_item_at_breakpoint := c;
                break;
            end;
        end;
    end;
end;

function get_weapon_at_breakpoint(idx: Integer) : Integer;
var
    c: Integer;
begin
    if (idx < 0) or (idx > g_weapon_rarity_breakpoints[NUM_WEAPONS - 1]) then
    begin
        get_weapon_at_breakpoint := NOTHING;
    end
    else begin
        for c := 0 to NUM_WEAPONS - 1 do
        begin
            if idx <= g_weapon_rarity_breakpoints[c] then begin
                get_weapon_at_breakpoint := c;
                break;
            end;
        end;
    end;
end;

function get_armor_at_breakpoint(idx: Integer) : Integer;
var
    c: Integer;
begin
    if (idx < 0) or (idx > g_armor_rarity_breakpoints[NUM_ARMORS - 1]) then
    begin
        get_armor_at_breakpoint := NOTHING;
    end
    else begin
        for c := 0 to NUM_ARMORS - 1 do
        begin
            if idx <= g_armor_rarity_breakpoints[c] then begin
                get_armor_at_breakpoint := c;
                break;
            end;
        end;
    end;
end;

procedure dump_item(i: GenItemType);
begin
    case i.item_type of
        GEN_WEAPON_TYPE: begin
                            Write(g_weapon_data[i.item_idx].name);
                            if i.plus_mod > 0 then
                            begin
                                Write(' (+');
                                Write(i.plus_mod);
                                Writeln(')');
                            end
                            else begin
                                Writeln('');
                            end;
                         end;
        GEN_ARMOR_TYPE: begin
                            Write(g_armor_data[i.item_idx].name);
                            if i.plus_mod > 0 then
                            begin
                                Write(' (+');
                                Write(i.plus_mod);
                                Writeln(')');
                            end
                            else begin
                                Writeln('');
                            end;
                        end;
        GEN_ITEM_TYPE:  begin
                            if g_item_data[i.item_idx].class = ITEM_MONEY then
                            begin
                                Write(i.quantity);
                                Write(' ');
                            end;
                            if g_item_data[i.item_idx].class = ITEM_SCROLL then
                            begin
                                Write('Scroll of ');
                            end;
                            if g_item_data[i.item_idx].class = ITEM_POTION then
                            begin
                                Write('Potion of ');
                            end;
                            Writeln(g_item_data[i.item_idx].name);
                        end;
    else
        Writeln('<Unknown>');
    end;
end;

end.