{ Global structs and constants, including sprite indices and item/enemy tables

  Copyright 2025 Shaun Brandt

  Licensed under the MIT license.  See LICENSE.md.
}
unit Globals;

interface

type

{ Entries in the monster data table }
MonsterTableEntryType = record
    name: string[16];
    min_floor: Byte;
    hp: Integer;
    atk: Integer;
    def: Integer;
    spd: Integer;
    exp: Integer;
    gold: Integer;
    droprate: Byte;
    tid: Byte;
end;

{ Entries in the weapon data table }
WeaponTableEntryType = record
    name: string[16];
    item_class: Byte;
    min_floor: Byte;
    rarity: Byte;
    atk: Integer;
    spd: Integer;
    tid: Byte;
end;

{ Entries in the armor data table }
ArmorTableEntryType = record
    name: string[16];
    item_class: Byte;
    min_floor: Byte;
    rarity: Byte;
    def: Byte;
    spd: Shortint;
    atk: Byte;
    luck: Byte;
    tid: Byte;
end;

{ Entries in the item data table }
ItemTableEntryType = record
    name: string [16];
    item_class: Byte;
    min_floor: Byte;
    rarity: Byte;
    effect_id: Byte;
    tid: Byte;
end;

RenderComponentsType=record
    render_interface: Boolean;
    render_dungeon: Boolean;
    render_interface_values: Boolean;
    render_text_box: Boolean;
end;

const
    { Maximum dungeon depth }
    NUM_FLOORS =      30;

    { Highest player level }
    MAX_PLAYER_LEVEL = 50;

    { Tile IDs }
    SPRITE_HERO =      0;
    SPRITE_BSLIME =    1;
    SPRITE_RSLIME =    2;
    SPRITE_GSLIME =    3;
    SPRITE_ASP =       4;
    SPRITE_COBRA =     5;
    SPRITE_MAMBA =     6;
    SPRITE_SKEL =      7;
    SPRITE_RSKEL =     8;
    SPRITE_ZSKEL =     9;
    SPRITE_BAT =      10;
    SPRITE_RBAT =     11;
    SPRITE_VBAT =     12;
    SPRITE_GHOST =    13;
    SPRITE_SPECTRE =  14;
    SPRITE_PGEIST =   15;
    SPRITE_RGOLEM =   16;
    SPRITE_SGOLEM =   17;
    SPRITE_PGOLEM =   18;
    SPRITE_IMP =      19;
    SPRITE_DEMON =    20;
    SPRITE_DEVIL =    21;
    SPRITE_LIZARD =   22;
    SPRITE_BRONTO =   23;
    SPRITE_TREX =     24;
    SPRITE_STAR =     25;
    SPRITE_NOVA =     26;
    SPRITE_SNOVA =    27;
    SPRITE_OOZE =     28;
    SPRITE_SLUDGE =   29;
    SPRITE_PUDDLE =   30;
    SPRITE_MEGALITH = 31;
    SPRITE_POTION1 =  32;
    SPRITE_POTION2 =  33;
    SPRITE_POTION3 =  34;
    SPRITE_POTION4 =  35;
    SPRITE_POTION5 =  36;
    SPRITE_POTION6 =  37;
    SPRITE_SCROLL1 =  38;
    SPRITE_SCROLL2 =  39;
    SPRITE_SCROLL3 =  40;
    SPRITE_SCROLL4 =  41;
    SPRITE_SCROLL5 =  42;
    SPRITE_SCROLL6 =  43;
    SPRITE_DAGGER1 =  44;
    SPRITE_DAGGER2 =  45;
    SPRITE_SWORD1  =  46;
    SPRITE_SWORD2  =  47;
    SPRITE_LSWORD1 =  48;
    SPRITE_LSWORD2 =  49;
    SPRITE_AXE1 =     50;
    SPRITE_AXE2 =     51;
    SPRITE_SHIELD1 =  52;
    SPRITE_SHIELD2 =  53;
    SPRITE_SHIELD3 =  54;
    SPRITE_SHIELD4 =  55;
    SPRITE_ARMOR1 =   56;
    SPRITE_ARMOR2 =   57;
    SPRITE_ARMOR3 =   58;
    SPRITE_ARMOR4 =   59;
    SPRITE_HAT1 =     60;
    SPRITE_HAT2 =     61;
    SPRITE_HAT3 =     62;
    SPRITE_HAT4 =     63;
    SPRITE_BOOTS1 =   64;
    SPRITE_BOOTS2 =   65;
    SPRITE_BOOTS3 =   66;
    SPRITE_BOOTS4 =   67;
    SPRITE_RING1 =    68;
    SPRITE_RING2 =    69;
    SPRITE_RING3 =    70;
    SPRITE_RING4 =    71;
    SPRITE_COPPER =   72;
    SPRITE_SILVER =   73;
    SPRITE_GOLD =     74;
    SPRITE_RUBY =     75;
    SPRITE_EMERALD =  76;
    SPRITE_DIAMOND =  77;
    SPRITE_ORB =      78;
    SPRITE_WALL1 =    79;
    SPRITE_WALL2 =    80;
    SPRITE_WALL3 =    81;
    SPRITE_BFOW1 =    82;
    SPRITE_BFOW2 =    83;
    SPRITE_RFOW1 =    84;
    SPRITE_RFOW2 =    85;
    SPRITE_GFOW1 =    86;
    SPRITE_GFOW2 =    87;
    SPRITE_HEALTH =   88;
    SPRITE_ARROW =    89;
    SPRITE_XP =       90;
    SPRITE_LUCK =     91;
    SPRITE_USTAIR =   92;
    SPRITE_MONEY =    93;
    SPRITE_LEVEL =    94;
    SPRITE_LPROG =    95;
    SPRITE_CPROG =    96;
    SPRITE_RPROG =    97;
    SPRITE_BLANK =    98;
    SPRITE_DSTAIR =   99;
    NUM_SPRITES =    100;

    { Weapon classes }
    WEAPON_DAGGER =    0;
    WEAPON_SWORD  =    1;
    WEAPON_LSWORD =    2;
    WEAPON_AXE =       3;

    { Armor classes }
    ARMOR_SHIELD =     0;
    ARMOR_CHEST =      1;
    ARMOR_BOOTS =      2;
    ARMOR_HELM =       3;
    ARMOR_RING =       4;

    { Item classes }
    ITEM_POTION =      0;
    ITEM_SCROLL =      1;
    ITEM_MONEY =       2;
    ITEM_SPECIAL =     3;

    { offsets into the item breakpoints array for each item type }
    POTION_MIN = 0;
    POTION_MAX = 447;
    SCROLL_MIN = 448;
    SCROLL_MAX = 1135;
    MONEY_MIN = 1136;
    MONEY_MAX = 2062;

    { The item that's generated if the generator fails to come up with one }
    DEFAULT_ITEM_IDX = 12;
    DEFAULT_WEAPON_IDX = 0;
    DEFAULT_ARMOR_IDX = 0;

    { A generic 'nothing' value for enemy and item uids }
    NOTHING = -1;

    { Monster data }
    NUM_MONSTERS = 31;

    g_monster_data: array[0..NUM_MONSTERS-1] of MonsterTableEntryType =
        (
          (name: 'Blue Slime';  min_floor: 1;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_BSLIME),
          (name: 'Asp';         min_floor: 1;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_ASP),
          (name: 'Skeleton';    min_floor: 2;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_SKEL),
          (name: 'Bat';         min_floor: 2;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_BAT),
          (name: 'Ghost';       min_floor: 4;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_GHOST),
          (name: 'Rock Golem';  min_floor: 4;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_RGOLEM),
          (name: 'Imp';         min_floor: 6;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_IMP),
          (name: 'Lizard';      min_floor: 6;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_LIZARD),
          (name: 'Star';        min_floor: 8;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_STAR),
          (name: 'Ooze';        min_floor: 8;  hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_OOZE),
          (name: 'Red Slime';   min_floor: 10; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_RSLIME),
          (name: 'Cobra';       min_floor: 10; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_COBRA),
          (name: 'Red Skel';    min_floor: 12; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_RSKEL),
          (name: 'Rabid Bat';   min_floor: 12; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_RBAT),
          (name: 'Spectre';     min_floor: 14; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_SPECTRE),
          (name: 'Stone Golem'; min_floor: 14; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_SGOLEM),
          (name: 'Demon';       min_floor: 16; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_DEMON),
          (name: 'Brontosaur';  min_floor: 16; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_BRONTO),
          (name: 'Nova';        min_floor: 18; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_NOVA),
          (name: 'Sludge';      min_floor: 18; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_SLUDGE),
          (name: 'Green Slime'; min_floor: 20; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_GSLIME),
          (name: 'Mamba';       min_floor: 20; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_MAMBA),
          (name: 'Zombie Skel'; min_floor: 22; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_ZSKEL),
          (name: 'Vampire Bat'; min_floor: 22; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_VBAT),
          (name: 'Poltergeist'; min_floor: 24; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_PGEIST),
          (name: 'Plant Golem'; min_floor: 24; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_PGOLEM),
          (name: 'Devil';       min_floor: 26; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_DEVIL),
          (name: 'T-Rex';       min_floor: 26; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_TREX),
          (name: 'Supernova';   min_floor: 28; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_SNOVA),
          (name: 'Puddle';      min_floor: 28; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_PUDDLE),
          (name: 'Megalith';    min_floor: 30; hp: 5; atk: 5; def: 5; spd: 100;
           exp: 4; gold: 5; droprate: 64; tid: SPRITE_MEGALITH)
        );

    { Weapon data }
    NUM_WEAPONS = 12;
    g_weapon_data: array[0..NUM_WEAPONS-1] of WeaponTableEntryType =
        (
          (name: 'WOOD DAGGER';     item_class: WEAPON_DAGGER; min_floor: 1;  rarity: 255;
           atk: 2;  spd: 2;  tid: SPRITE_DAGGER1),
          (name: 'STEEL DAGGER';    item_class: WEAPON_DAGGER; min_floor: 10; rarity: 120;
           atk: 10; spd: 10; tid: SPRITE_DAGGER2),
          (name: 'MAGIC DAGGER';    item_class: WEAPON_DAGGER; min_floor: 20; rarity: 40;
           atk: 20; spd: 20; tid: SPRITE_DAGGER2),
          (name: 'WOOD SWORD';      item_class: WEAPON_SWORD;  min_floor: 1;  rarity: 240;
           atk: 4;  spd: 0;  tid: SPRITE_SWORD1),
          (name: 'STEEL SWORD';     item_class: WEAPON_SWORD;  min_floor: 10; rarity: 110;
           atk: 15; spd: 0;  tid: SPRITE_SWORD2),
          (name: 'MAGIC SWORD';     item_class: WEAPON_SWORD;  min_floor: 20; rarity: 35;
           atk: 30; spd: 0;  tid: SPRITE_SWORD2),
          (name: 'WOOD LONGSWORD';  item_class: WEAPON_LSWORD; min_floor: 2;  rarity: 225;
           atk: 7;  spd: -1; tid: SPRITE_LSWORD1),
          (name: 'STEEL LONGSWORD'; item_class: WEAPON_LSWORD; min_floor: 12; rarity: 100;
           atk: 20; spd: -2; tid: SPRITE_LSWORD2),
          (name: 'MAGIC LONGSWORD'; item_class: WEAPON_LSWORD; min_floor: 22; rarity: 30;
           atk: 45; spd: -3; tid: SPRITE_LSWORD2),
          (name: 'WOOD AXE';        item_class: WEAPON_AXE;    min_floor: 3;  rarity: 215;
           atk: 10; spd: -2; tid: SPRITE_AXE1),
          (name: 'STEEL AXE';       item_class: WEAPON_AXE;    min_floor: 13; rarity: 95;
           atk: 25; spd: -5; tid: SPRITE_AXE2),
          (name: 'MAGIC AXE';       item_class: WEAPON_AXE;    min_floor: 23; rarity: 25;
           atk: 55; spd: -8; tid: SPRITE_AXE2)
        );
    g_weapon_rarity_breakpoints: array[0..NUM_WEAPONS-1] of Integer =
        (255, 375, 415, 655, 765, 800, 1025, 1125, 1155, 1370, 1465, 1490);

    { Armor data }
    NUM_ARMORS = 20;
    g_armor_data: array[0..NUM_ARMORS-1] of ArmorTableEntryType =
        (
          (name: 'WOOD SHIELD';         item_class: ARMOR_SHIELD; min_floor: 1;  rarity: 255; def: 1;
           spd: 5;   atk: 0;  luck: 0;  tid: SPRITE_SHIELD1),
          (name: 'LEATHER SHIELD';      item_class: ARMOR_SHIELD; min_floor: 5;  rarity: 180; def: 4;
           spd: 0;   atk: 0;  luck: 0;  tid: SPRITE_SHIELD2),
          (name: 'STEEL SHIELD';        item_class: ARMOR_SHIELD; min_floor: 10; rarity: 120; def: 8;
           spd: -2;  atk: 0;  luck: 0;  tid: SPRITE_SHIELD3),
          (name: 'MAGIC SHIELD';        item_class: ARMOR_SHIELD; min_floor: 20; rarity: 40;  def: 15;
           spd: -5;  atk: 0;  luck: 0;  tid: SPRITE_SHIELD4),
          (name: 'CLOTH ARMOR';         item_class: ARMOR_CHEST;  min_floor: 1;  rarity: 255; def: 1;
           spd: 5;   atk: 0;  luck: 0;  tid: SPRITE_ARMOR1),
          (name: 'LEATHER ARMOR';       item_class: ARMOR_CHEST;  min_floor: 5;  rarity: 180; def: 4;
           spd: 0;   atk: 0;  luck: 0;  tid: SPRITE_ARMOR2),
          (name: 'CHAIN ARMOR';         item_class: ARMOR_CHEST;  min_floor: 10; rarity: 120; def: 8;
           spd: -5;  atk: 0;  luck: 0;  tid: SPRITE_ARMOR3),
          (name: 'PLATE ARMOR';         item_class: ARMOR_CHEST;  min_floor: 20; rarity: 40;  def: 15;
           spd: -10; atk: 0;  luck: 0;  tid: SPRITE_ARMOR4),
          (name: 'CLOTH BOOTS';         item_class: ARMOR_BOOTS;  min_floor: 1;  rarity: 255; def: 1;
           spd: 5;   atk: 0;  luck: 0;  tid: SPRITE_BOOTS1),
          (name: 'LEATHER BOOTS';       item_class: ARMOR_BOOTS;  min_floor: 5;  rarity: 180; def: 4;
           spd: 0;   atk: 0;  luck: 0;  tid: SPRITE_BOOTS2),
          (name: 'CHAIN BOOTS';         item_class: ARMOR_BOOTS;  min_floor: 10; rarity: 120; def: 8;
           spd: -2;  atk: 0;  luck: 0;  tid: SPRITE_BOOTS3),
          (name: 'PLATE BOOTS';         item_class: ARMOR_BOOTS;  min_floor: 20; rarity: 40;  def: 15;
           spd: -5;  atk: 0;  luck: 0;  tid: SPRITE_BOOTS4),
          (name: 'CLOTH HAT';           item_class: ARMOR_HELM;   min_floor: 1;  rarity: 255; def: 1;
           spd: 5;   atk: 0;  luck: 0;  tid: SPRITE_HAT1),
          (name: 'LEATHER HAT';         item_class: ARMOR_HELM;   min_floor: 5;  rarity: 180; def: 4;
           spd: 0;   atk: 0;  luck: 0;  tid: SPRITE_HAT2),
          (name: 'CHAIN HELM';          item_class: ARMOR_HELM;   min_floor: 10; rarity: 120; def: 8;
           spd: -2;  atk: 0;  luck: 0;  tid: SPRITE_HAT3),
          (name: 'PLATE HELM';          item_class: ARMOR_HELM;   min_floor: 20; rarity: 40;  def: 15;
           spd: -5;  atk: 0;  luck: 0;  tid: SPRITE_HAT4),
          (name: 'ATK RING';            item_class: ARMOR_RING;   min_floor: 10; rarity: 32;  def: 0;
           spd: 0;   atk: 25; luck: 0;  tid: SPRITE_RING1),
          (name: 'SPD RING';            item_class: ARMOR_RING;   min_floor: 10; rarity: 32;  def: 0;
           spd: 25;  atk: 0;  luck: 0;  tid: SPRITE_RING2),
          (name: 'DEF RING';            item_class: ARMOR_RING;   min_floor: 10; rarity: 32;  def: 25;
           spd: 0;   atk: 0;  luck: 0;  tid: SPRITE_RING3),
          (name: 'LUCK RING';           item_class: ARMOR_RING;   min_floor: 10; rarity: 32;  def: 0;
           spd: 0;   atk: 0;  luck: 25; tid: SPRITE_RING4)
        );
    g_armor_rarity_breakpoints: array[0..NUM_ARMORS-1] of Integer =
        (255, 435, 555, 595, 850, 1030, 1150, 1190, 1445, 1625, 1745,
         1785, 2040, 2220, 2340, 2380, 2412, 2444, 2476, 2508);

    { Item data }
    NUM_ITEMS = 18;
    g_item_data: array[0..NUM_ITEMS-1] of ItemTableEntryType =
    (
      (name: 'Heal 1';   item_class: ITEM_POTION;  min_floor: 1;   rarity: 255; effect_id: 0;  tid: SPRITE_POTION1),
      (name: 'Heal 2';   item_class: ITEM_POTION;  min_floor: 15;  rarity: 64;  effect_id: 1;  tid: SPRITE_POTION2),
      (name: 'Speed';    item_class: ITEM_POTION;  min_floor: 5;   rarity: 32;  effect_id: 2;  tid: SPRITE_POTION3),
      (name: 'Attack';   item_class: ITEM_POTION;  min_floor: 5;   rarity: 32;  effect_id: 3;  tid: SPRITE_POTION4),
      (name: 'Luck';     item_class: ITEM_POTION;  min_floor: 5;   rarity: 32;  effect_id: 4;  tid: SPRITE_POTION5),
      (name: 'Harm';     item_class: ITEM_POTION;  min_floor: 5;   rarity: 32;  effect_id: 5;  tid: SPRITE_POTION6),
      (name: 'Identify'; item_class: ITEM_SCROLL;  min_floor: 5;   rarity: 128; effect_id: 6;  tid: SPRITE_SCROLL1),
      (name: 'Phase';    item_class: ITEM_SCROLL;  min_floor: 1;   rarity: 224; effect_id: 7;  tid: SPRITE_SCROLL2),
      (name: 'Up';       item_class: ITEM_SCROLL;  min_floor: 1;   rarity: 224; effect_id: 8;  tid: SPRITE_SCROLL3),
      (name: 'Armor';    item_class: ITEM_SCROLL;  min_floor: 10;  rarity: 16;  effect_id: 9;  tid: SPRITE_SCROLL4),
      (name: 'Confuse';  item_class: ITEM_SCROLL;  min_floor: 1;   rarity: 64;  effect_id: 10; tid: SPRITE_SCROLL5),
      (name: 'Summon';   item_class: ITEM_SCROLL;  min_floor: 10;  rarity: 32;  effect_id: 11; tid: SPRITE_SCROLL6),
      (name: 'Copper';   item_class: ITEM_MONEY;   min_floor: 1;   rarity: 255; effect_id: 12; tid: SPRITE_COPPER),
      (name: 'Silver';   item_class: ITEM_MONEY;   min_floor: 3;   rarity: 224; effect_id: 13; tid: SPRITE_SILVER),
      (name: 'Gold';     item_class: ITEM_MONEY;   min_floor: 5;   rarity: 176; effect_id: 14; tid: SPRITE_GOLD),
      (name: 'Ruby';     item_class: ITEM_MONEY;   min_floor: 8;   rarity: 128; effect_id: 15; tid: SPRITE_RUBY),
      (name: 'Emerald';  item_class: ITEM_MONEY;   min_floor: 12;  rarity: 96;  effect_id: 16; tid: SPRITE_EMERALD),
      (name: 'Diamond';  item_class: ITEM_MONEY;   min_floor: 18;  rarity: 48;  effect_id: 17; tid: SPRITE_DIAMOND)
    );

    g_item_rarity_breakpoints: array[0..NUM_ITEMS-1] of Integer =
        (255, 319, 351, 383, 415, 447, 575,  799, 1023, 1039,
         1103, 1135, 1390, 1614, 1790, 1918, 2014, 2062);

    g_xp_required: array[0..MAX_PLAYER_LEVEL - 1] of Longint =
        (     0,       5,      12,      27,      49,      80,     130,     200,     290,     400,
            540,     700,     900,    1150,    1450,    1850,    2400,    3000,    3800 ,   5000,
           6500,    8500,   11000,   14000,   18000,   23000,   29000,   37000,   48000,   62000,
          80000,  100000,  130000,  170000,  220000,  280000,  360000,  450000,  550000,  680000,
         840000, 1040000, 1290000, 1640000, 2100000, 2650000, 3400000, 4400000, 5700000, 7200000
        );

var
  { Render components }
  g_render_components: RenderComponentsType;

implementation

end.