{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleScene,
  CastleTransform, CastleLog, CastleSoundEngine, castlewindow;

type
  { Main view, where most of the application logic takes place. }

  { TViewMain }

  TViewMain = class(TCastleView)
  private
    VelocidadPlayer1: integer;
    VelocidadPlayer2: integer;
    MaximaPuntuacion: integer;
    PuntosPlayer1: integer;
    PuntosPlayer2: integer;
    procedure EmpezarJuego;
    procedure JugadoresAlOrigen;
    procedure MuestraTextoInicial;
    procedure BorraTextoInicial;
    procedure Saque(const Player: string = '');
    procedure FinJuego;
    procedure ColisionLadoDerecho(const CollisionDetails: TPhysicsCollisionDetails);
    procedure ColisionLadoIzquierdo(
      const CollisionDetails: TPhysicsCollisionDetails);
    procedure ColisionParedes(const CollisionDetails: TPhysicsCollisionDetails);
    procedure ColisionPlayer1(const CollisionDetails: TPhysicsCollisionDetails);
    procedure ColisionPlayer2(const CollisionDetails: TPhysicsCollisionDetails);
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;
    MarcadorPlayer1: TCastleLabel;
    MarcadorPlayer2: TCastleLabel;
    TeclasPlayer1: TCastleLabel;
    TeclasPlayer2: TCastleLabel;
    SpaceBar: TCastleLabel;
    Player1: TCastleBox;
    Player2: TCastleBox;
    PlayerHit: TCastleSound;
    LadoDerecho: TCastleBox;
    LadoIzquierdo: TCastleBox;
    LadoSuperior: TCastleBox;
    LadoInferior: TCastleBox;
    Pelota: TCastleSphere;
    Gol: TCastleSound;
    Rebote: TCastleSound;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: single; var HandleInput: boolean); override;
    function Press(const Event: TInputPressRelease): boolean; override;
  end;

var
  ViewMain: TViewMain;

implementation

uses SysUtils, CastleUtils, CastleTimeUtils;

  { TViewMain ----------------------------------------------------------------- }

procedure TViewMain.EmpezarJuego;
begin
  //Iniciar Valores
  VelocidadPlayer1 := 0;
  VelocidadPlayer2 := 0;
  PuntosPlayer1 := 0;
  PuntosPlayer2 := 0;
  MaximaPuntuacion := 12;
  Player1.Translation := Vector3(-690, 0, 0);
  Player2.Translation := Vector3(690, 0, 0);
  MarcadorPlayer1.Caption := '0';
  MarcadorPlayer2.Caption := '0';
  BorraTextoInicial;
  Saque;
end;

procedure TViewMain.JugadoresAlOrigen;
begin
  Player1.Translation := Vector3(-690, 0, 0);
  Player2.Translation := Vector3(690, 0, 0);
end;

procedure TViewMain.MuestraTextoInicial;
begin
  TeclasPlayer1.Exists := True;
  TeclasPlayer2.Exists := True;
  SpaceBar.Exists := True;
end;

procedure TViewMain.BorraTextoInicial;
begin
  TeclasPlayer1.Exists := False;
  TeclasPlayer2.Exists := False;
  SpaceBar.Exists := False;
end;

procedure TViewMain.Saque(const Player: string);
var
  Body: TCastleRigidBody;
  Vector: TVector3;
  Direccion: int64;

begin
  //Saque
  //Dirección por defecto, saca el jugador 1
  Vector.X := 500;
  Vector.Y := 500;
  Randomize;
  //Determinar si es hacia arriba o hacia abajo
  Direccion := random(100);
  WritelnLog(Direccion.ToString);
  if Direccion mod 2 = 0 then
  begin
    Vector.Y := -500;
  end;
  //Si tiene que sacar el jugador 2 cambiamos la dirección
  if Player = Player1.Name then
  begin
    Vector.X := -Vector.X;
  end
  //sino se especifica ningún jugador se elige al azar
  else if Player = '' then
  begin
    //Determinar hacia que lado sacamos
    Randomize;
    direccion := random(100);
    WritelnLog(Direccion.ToString);
    if Direccion mod 2 = 0 then
    begin
      Vector.X := -500;
    end;
  end;

  JugadoresAlOrigen;

  //Situar pelota en el centro
  Pelota.Translation := Vector3(0, 0, 0);
  //Mostrar Pelota
  Pelota.Visible := True;

  //Aplicar Velocidad.
  Body := Pelota.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  Body.LinearVelocity := Vector;
  WritelnLog(Vector.ToString);
end;

procedure TViewMain.FinJuego;
var
  Body: TCastleRigidBody;
begin
  Body := Pelota.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  Body.LinearVelocity := Vector3(0, 0, 0);
  Pelota.Visible := False;
  MuestraTextoInicial;
end;

procedure TViewMain.ColisionLadoDerecho(
  const CollisionDetails: TPhysicsCollisionDetails);
begin
  //EL jugador 1  (izquierdo) consigue un punto
  PuntosPlayer1 := PuntosPlayer1 + 1;

  MarcadorPlayer1.Caption := IntToStr(PuntosPlayer1);
  SoundEngine.Play(Gol);
  if PuntosPlayer1 >= MaximaPuntuacion then
  begin
    FinJuego;
  end
  else
  begin
    Saque(Player1.Name);
  end;

end;

procedure TViewMain.ColisionLadoIzquierdo(
  const CollisionDetails: TPhysicsCollisionDetails);
begin
  //El jugador 2 (derecha) consigue un punto
  PuntosPlayer2 := PuntosPlayer2 + 1;
  MarcadorPlayer2.Caption := IntToStr(PuntosPlayer2);
  SoundEngine.Play(Gol);
  if PuntosPlayer2 >= MaximaPuntuacion then
  begin
    FinJuego;
  end
  else
  begin
    Saque(Player2.Name);
  end;
end;

procedure TViewMain.ColisionParedes(const CollisionDetails: TPhysicsCollisionDetails);
begin
  SoundEngine.Play(Rebote);
end;

procedure TViewMain.ColisionPlayer1(const CollisionDetails: TPhysicsCollisionDetails);
begin
  VelocidadPlayer1 := 0;
  SoundEngine.Play(PlayerHit);
end;

procedure TViewMain.ColisionPlayer2(const CollisionDetails: TPhysicsCollisionDetails);
begin
  VelocidadPlayer2 := 0;
  SoundEngine.Play(PlayerHit);
end;


constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
end;

procedure TViewMain.Start;
var
  Body: TCastleRigidBody;
begin
  inherited;

  Body := Player1.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
  Body.OnCollisionEnter:=@ColisionPlayer1;
  {$ELSE}
  Body.OnCollisionEnter := ColisionPlayer1;
  {$ENDIF}

  Body := Player2.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
    Body.OnCollisionEnter:=@ColisionPlayer2;
  {$ELSE}
  Body.OnCollisionEnter := ColisionPlayer2;
  {$ENDIF}


  //Lado Derecho
  Body := LadoDerecho.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
  Body.OnCollisionEnter := @ColisionLadoDerecho;
  {$ELSE}
  Body.OnCollisionEnter := ColisionLadoDerecho;
  {$ENDIF}

  //Lado Izqquierdo
  Body := LadoIzquierdo.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
  Body.OnCollisionEnter := @ColisionLadoIzquierdo;
  {$ELSE}
  Body.OnCollisionEnter := ColisionLadoIzquierdo;
  {$ENDIF}

  Body := LadoSuperior.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
   Body.OnCollisionEnter:=@ColisionParedes;
  {$ELSE}
  Body.OnCollisionEnter := ColisionParedes;
  {$ENDIF}

  Body := LadoInferior.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
  {$IFDEF FPC}
   Body.OnCollisionEnter:=@ColisionParedes;
  {$ELSE}
  Body.OnCollisionEnter := ColisionParedes;
  {$ENDIF}
end;


procedure TViewMain.Update(const SecondsPassed: single; var HandleInput: boolean);
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil,
    'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  if (Player1.Translation.Y > 300) then
  begin
    VelocidadPlayer1 := 0;
    Player1.Translation := Vector3(-690, 300, 0);
  end;

  if (Player1.Translation.Y < -300) then
  begin
    VelocidadPlayer1 := 0;
    Player1.Translation := Vector3(-690, -300, 0);
  end;


  if (Player2.Translation.Y > 300) then
  begin
    VelocidadPlayer2 := 0;
    Player2.Translation := Vector3(690, 300, 0);
  end;

  if (Player2.Translation.Y < -300) then
  begin
    VelocidadPlayer2 := 0;
    Player2.Translation := Vector3(690, -300, 0);
  end;

  Player1.Translation := Player1.Translation +
    Vector3(0, VelocidadPlayer1 * SecondsPassed, 0);
  Player2.Translation := Player2.Translation +
    Vector3(0, VelocidadPlayer2 * SecondsPassed, 0);
end;

function TViewMain.Press(const Event: TInputPressRelease): boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys
  if Pelota.Visible = True then
  begin
    if Event.IsKey(keyQ) then
    begin
      if VelocidadPlayer1 < 0 then
      begin
        VelocidadPlayer1 := 0;
      end
      else
      begin
        VelocidadPlayer1 := 300;
      end;
      Exit(True);
    end;
    if Event.IsKey(keyA) then
    begin
      if VelocidadPlayer1 > 0 then
      begin
        VelocidadPlayer1 := 0;
      end
      else
      begin
        VelocidadPlayer1 := -300;
      end;
    end;
    //Teclas jugadaor 2
    if Event.IsKey(keyArrowUp) then
    begin
      if VelocidadPlayer2 < 0 then
      begin
        VelocidadPlayer2 := 0;
      end
      else
      begin
        VelocidadPlayer2 := 300;
      end;
      Exit(True);
    end;
    if Event.IsKey(keyArrowDown) then
    begin
      if VelocidadPlayer2 > 0 then
      begin
        VelocidadPlayer2 := 0;
      end
      else
      begin
        VelocidadPlayer2 := -300;
      end;
      Exit(True);
    end;
  end;
  if Event.IsKey(keyEscape) then
  begin
    Application.Terminate;
    Exit(True);
  end;

  if (Pelota.Visible = False) and (Event.IsKey(keySpace)) then
  begin
    EmpezarJuego;
  end;

end;

end.
