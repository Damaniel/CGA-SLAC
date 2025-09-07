
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
    procedure Init;
    function get_level : Byte;
    function get_hp : Integer;
    function get_max_hp: Integer;
    function get_xp: Longint;
    function get_money : Longint;
    function get_atk : Integer;
    function get_def : Integer;
    function get_spd: Integer;
    function get_luck : Integer;
    procedure set_level(val : Byte);
    procedure set_max_hp(val: Integer);
    procedure set_hp(val: Integer);
    procedure set_xp(val: Longint);
    procedure set_money(val: Longint);
    procedure set_atk(val: Integer);
    procedure set_def(val: Integer);
    procedure set_spd(val: Integer);
    procedure set_luck(val: Integer);

private
    level: Byte;
    hp: Integer;
    max_hp: Integer;
    xp: Longint;
    money: Longint;
    atk: Integer;
    def: Integer;
    spd: Integer;
    luck: Integer;
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

function SLACPlayer.get_level : Byte;
begin
    get_level := level;
end;

function SLACPlayer.get_hp : Integer;
begin
    get_hp := hp;
end;

function SLACPlayer.get_max_hp: Integer;
begin
    get_max_hp := max_hp
end;

function SLACPlayer.get_xp : Longint;
begin
    get_xp := xp;
end;

function SLACPlayer.get_money : Longint;
begin
    get_money := money;
end;

function SLACPlayer.get_atk : Integer;
begin
    get_atk := atk;
end;

function SLACPlayer.get_def : Integer;
begin
    get_def := def;
end;

function SLACPlayer.get_spd : Integer;
begin
    get_spd := spd;
end;

function SLACPlayer.get_luck : Integer;
begin
    get_luck := luck;
end;

procedure SLACPlayer.set_level(val : Byte);
begin
    level := val;
end;

procedure SLACPlayer.set_hp(val : Integer);
begin
    hp := val;
end;

procedure SLACPlayer.set_max_hp(val : Integer);
begin
    max_hp := val;
end;

procedure SLACPlayer.set_xp(val : Longint);
begin
    xp := val;
end;

procedure SLACPlayer.set_money(val : Longint);
begin
    money := val;
end;

procedure SLACPlayer.set_atk(val : Integer);
begin
    atk := val;
end;

procedure SLACPlayer.set_def(val : Integer);
begin
    def := val;
end;

procedure SLACPlayer.set_spd(val : Integer);
begin
    spd := val;
end;

procedure SLACPlayer.set_luck(val : Integer);
begin
    luck := val;
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