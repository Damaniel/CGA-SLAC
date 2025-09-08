
unit Player;

interface

uses
    Globals;

const
    PLAYER_BASE_HP = 20;
    PLAYER_BASE_SPEED = 100;
    PLAYER_BASE_LUCK = 10;
    PLAYER_BASE_ATTACK = 0;
    PLAYER_BASE_DEF = 0;

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
    procedure Init;
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