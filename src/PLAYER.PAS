
unit Player;

interface

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
    function get_xp: Longint;
    function get_money : Longint;
    function get_atk : Integer;
    function get_def : Integer;
    function get_spd: Integer;
    function get_luck : Integer;
    procedure get_pos(var x: byte; var y: Byte);
    procedure set_level(val : Byte);
    procedure set_hp(val: Integer);
    procedure set_xp(val: Longint);
    procedure set_money(val: Longint);
    procedure set_atk(val: Integer);
    procedure set_def(val: Integer);
    procedure set_spd(val: Integer);
    procedure set_luck(val: Integer);
    procedure set_pos(x: Byte; y: Byte);

private
    x_pos: Byte;
    y_pos: Byte;
    level: Byte;
    hp: Integer;
    xp: Longint;
    money: Longint;
    atk: Integer;
    def: Integer;
    spd: Integer;
    luck: Integer;
end;

var
    g_player: SLACPlayer;


function getBaseHP(level: Integer) : Integer;
function getBaseAttack(level: Integer) : Integer;
function getBaseDefense(level: Integer) : Integer;
function getBaseSpeed(level: Integer) : Integer;
function getBaseLuck(level: Integer) : Integer;

implementation

procedure SLACPlayer.Init;
begin
    level := 1;
    xp := 0;
    money := 0;
    hp := getBaseHP(level);
    atk := getBaseAttack(level);
    def := getBaseDefense(level);
    spd := getBaseSpeed(level);
    luck := getBaseLuck(level);
end;

function SLACPlayer.get_level : Byte;
begin
    get_level := level;
end;

function SLACPlayer.get_hp : Integer;
begin
    get_hp := hp;
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

procedure SLACPlayer.get_pos(var x: Byte; var y: Byte);
begin
    x := x_pos;
end;

procedure SLACPlayer.set_level(val : Byte);
begin
    level := val;
end;

procedure SLACPlayer.set_hp(val : Integer);
begin
    hp := val;
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

procedure SLACPlayer.set_pos(x: Byte; y: Byte);
begin
    x_pos := x;
    y_pos := y;
end;

{ getBaseHP - returns the base HP value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base HP for the player at that level
}
function getBaseHP(level: Integer) : Integer;
begin
   getBaseHP := PLAYER_BASE_HP + ((level - 1) * 5);
end;

{ getBaseAttack - returns the base attack value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base attack for the player at that level
}
function getBaseAttack(level: Integer) : Integer;
begin
   getBaseAttack := PLAYER_BASE_ATTACK + level;
end;

{ getBaseDefense - returns the base defense value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base defense for the player at that level
}
function getBaseDefense(level: Integer) : Integer;
begin
   getBaseDefense := PLAYER_BASE_DEF + level;
end;

{ getBaseSpeed - returns the base speed value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base speed for the player at that level
}
function getBaseSpeed(level: Integer) : Integer;
begin
   getBaseSpeed := PLAYER_BASE_SPEED + (level - 1);
end;

{ getBaseLuck - returns the base luck value for the specified player level.

  Parameters:
    - level : the level of the player

  Returns:
    The base luck for the player at that level
}
function getBaseLuck(level: Integer) : Integer;
begin
   getBaseLuck := PLAYER_BASE_LUCK + (5 * (level div 10));
end;

end.