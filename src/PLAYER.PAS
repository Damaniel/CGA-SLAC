
unit Player;

interface

uses
    Globals,
    Item;

const
    PLAYER_BASE_HP = 20;
    PLAYER_BASE_SPEED = 100;
    PLAYER_BASE_LUCK = 10;
    PLAYER_BASE_ATTACK = 0;
    PLAYER_BASE_DEF = 0;

    EQUIP_SLOT_WEAPON = 0;
    EQUIP_SLOT_SHIELD = 1;
    EQUIP_SLOT_HEAD = 2;
    EQUIP_SLOT_CHEST = 3;
    EQUIP_SLOT_FEET = 4;
    EQUIP_SLOT_RING = 5;
    NUM_EQUIP_SLOTS = 6;
type

SLACPlayer=object
    level: Byte;
    hp: Integer;
    max_hp: Integer;
    xp: Longint;
    money: Longint;
    atk: Integer;
    def: Integer;
    spd: Integer;
    luck: Integer;
    equipment: array[0..NUM_EQUIP_SLOTS-1] of Shortint;
    procedure Init;
    procedure equip(inv_index: Integer; var was_equipped: Boolean);
    procedure unequip(equip_index: Integer; var was_removed: Boolean);
    procedure recalculate_stats;
end;

PSLACPlayer=^SLACPlayer;

var
    g_player: SLACPlayer;


function get_base_hp(level: Integer) : Integer;
function get_base_attack(level: Integer) : Integer;
function get_base_defense(level: Integer) : Integer;
function get_base_speed(level: Integer) : Integer;
function get_base_luck(level: Integer) : Integer;
function get_xp_for_next_level(cur_level: Integer) : Longint;

implementation

procedure SLACPlayer.Init;
var
  idx: Integer;
begin
    level := 1;
    xp := 0;
    money := 0;
    max_hp := get_base_hp(level);
    hp := max_hp;
    atk := get_base_attack(level);
    def := get_base_defense(level);
    spd := get_base_speed(level);
    luck := get_base_luck(level);
    for idx :=0 to NUM_EQUIP_SLOTS - 1 do
    begin
      equipment[idx] := NO_ITEM;
    end;
end;

{ equip - equips the specifed item from the player's inventory

  Parameters:
    inv_index - the offset into the inventory of the player

  Returns:
    True if the item was equippable and actually equipped, False otherwise
}
procedure SLACPlayer.equip(inv_index: Integer; var was_equipped: Boolean);
var
  is_weapon_type: Boolean;
  was_removed : Boolean;
  equip_type: Integer;
  slot: Integer;
begin
  was_equipped := False;

  { Determine if the item at inv_index is a weapon or armor }
  if is_equippable(g_inventory[inv_index].item) = True then
  begin
      if is_weapon(g_inventory[inv_index].item) = True then
      begin
        is_weapon_type := True;
      end
      else if is_armor(g_inventory[inv_index].item) = True then
      begin
        is_weapon_type := False;
        equip_type := get_armor_type(g_inventory[inv_index].item);
      end;
      { If a weapon, add it to the appropriate equipment slot}
      if is_weapon_type = True then
      begin
        unequip(EQUIP_SLOT_WEAPON, was_removed);
        equipment[EQUIP_SLOT_WEAPON] := inv_index;
        g_inventory[inv_index].item.equipped := True;
        was_equipped := True;
      end
      { If an armor, determine the type and equip it to the proper slot }
      else begin
        slot := NOTHING;
        case equip_type of
          ARMOR_SHIELD: slot := EQUIP_SLOT_SHIELD;
          ARMOR_HELM: slot := EQUIP_SLOT_HEAD;
          ARMOR_CHEST: slot := EQUIP_SLOT_CHEST;
          ARMOR_BOOTS: slot := EQUIP_SLOT_FEET;
          ARMOR_RING: slot := EQUIP_SLOT_RING;
        end;
        if slot = NOTHING then
        begin
          was_equipped := False;
        end
        else begin
          unequip(slot, was_removed);
          equipment[slot] := inv_index;
          g_inventory[inv_index].item.equipped := True;
          was_equipped := True;
        end;
      end;
  end
  else begin
    was_equipped := False;
  end;

  if was_equipped = True then
  begin
    recalculate_stats;
  end;
end;

{ unequip - unequips an item by removing it from the player's equipment list

  Parameters
    equip_index - the equipment slot to unequip
    was_removed - True if the item was actually unequipped, False otherwise (currently unused)
}
procedure SLACPlayer.unequip(equip_index: Integer; var was_removed: Boolean);
begin
  g_inventory[equipment[equip_index]].item.equipped := False;
  equipment[equip_index] := NO_ITEM;
  recalculate_stats;
end;

{ recalculate_stats - adds up all of the stat adjustments provided by the player's level and gear

  This procedure is used after equipping/unequipping items, using items that modify stats,
  or leveling up, to ensure that stats always reflect the actual state of the player.
}
procedure SLACPlayer.recalculate_stats;
var
  idx: Integer;
  it:  SLACItem;
  stat_boost: Integer;
begin
  { set all the base stats }
  hp := get_base_hp(level);
  atk := get_base_attack(level);
  def := get_base_defense(level);
  spd := get_base_speed(level);
  luck := get_base_luck(level);

  { Add up all of the mods for the equipped items }
  if equipment[EQUIP_SLOT_WEAPON] <> NO_ITEM then
  begin
    it := g_inventory[equipment[EQUIP_SLOT_WEAPON]].item;
    atk := atk + g_weapon_data[it.item_idx].atk;
    spd := spd + g_weapon_data[it.item_idx].spd;

    { If the weapon has a plus mod, then add 20% of the base attack for each + on the
      weapon (adding between 20 and 100% additional attack) }
      if it.plus_mod > 0 then
      begin
        stat_boost := (((g_weapon_data[it.item_idx].atk div 10) + 1) * it.plus_mod);
        atk := atk + stat_boost;
      end;
  end;

  for idx := EQUIP_SLOT_SHIELD to NUM_EQUIP_SLOTS -1 do begin
    if equipment[idx] <> NO_ITEM then
    begin
      it := g_inventory[equipment[idx]].item;
      def := def + g_armor_data[it.item_idx].def;
      spd := spd + g_armor_data[it.item_idx].spd;
      atk := atk + g_armor_data[it.item_idx].atk;
      luck := luck + g_armor_data[it.item_idx].luck;

      { For rings, apply the plus mod to all possible stats.  Mods with zero value on
        a stat will also have zero value in the +x form.  Note that the formula used
        to calculate the boost for rings is different than for other types - a +1 mod
        on other armors or weapons will add at least 1 DEF or ATK to the player's stats,
        but a ring can (and will) add 0 to multiple stats}
      if it.plus_mod > 0 then
      begin
        if it.item_class = ARMOR_RING then
        begin
          stat_boost := ((g_armor_data[it.item_idx].atk div 10) * it.plus_mod);
          atk := atk + stat_boost;
          stat_boost := ((g_armor_data[it.item_idx].def div 10) * it.plus_mod);
          def := def + stat_boost;
          stat_boost := ((g_armor_data[it.item_idx].spd div 10) * it.plus_mod);
          spd := spd + stat_boost;
          stat_boost := ((g_armor_data[it.item_idx].luck div 10) * it.plus_mod);
          luck := luck + stat_boost;
        end
        else begin
          stat_boost := (((g_armor_data[it.item_idx].def div 10) + 1) * it.plus_mod);
          def := def + stat_boost;
        end;
      end;
    end;
  end;

  { TODO: add up the temporary effects from potions }

  g_render_components.render_interface_values := True;
end;

{ get_base_hp - returns the base HP value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base HP for the player at that level
}
function get_base_hp(level: Integer) : Integer;
begin
   get_base_hp := PLAYER_BASE_HP + ((level - 1) * 5);
end;

{ get_base_attack - returns the base attack value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base attack for the player at that level
}
function get_base_attack(level: Integer) : Integer;
begin
   get_base_attack := PLAYER_BASE_ATTACK + level;
end;

{ get_base-defense - returns the base defense value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base defense for the player at that level
}
function get_base_defense(level: Integer) : Integer;
begin
   get_base_defense := PLAYER_BASE_DEF + level;
end;

{ get_base_speed - returns the base speed value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base speed for the player at that level
}
function get_base_speed(level: Integer) : Integer;
begin
   get_base_speed := PLAYER_BASE_SPEED + (level - 1);
end;

{ get_base_luck - returns the base luck value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base luck for the player at that level
}
function get_base_luck(level: Integer) : Integer;
begin
   get_base_luck := PLAYER_BASE_LUCK + (5 * (level div 10));
end;

{ get_xp_for_next_level - returns the total amount of experience to go up to the next level

  Parameters:
    cur_level - the current level

  Returns
    The experience required to achiveve (cur_level + 1)
}
function get_xp_for_next_level(cur_level: Integer) : Longint;
begin
    if (cur_level >= 50) or (cur_level <= 0) then
    begin
        get_xp_for_next_level := -1;
    end
    else begin
        get_xp_for_next_level := g_xp_required[cur_level] - g_xp_required[cur_level - 1];
    end;
end;

end.