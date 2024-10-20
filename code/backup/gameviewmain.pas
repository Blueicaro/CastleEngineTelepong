{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleScene,
  CastleTransform, CastleLog, CastleSoundEngine;

type
  { Main view, where most of the application logic takes place. }

  { TViewMain }

  TViewMain = class(TCastleView)
  private
    VelocidadPlayer1: integer;
    VelocidadPlayer2: integer;
    PuntosPlayer1: integer;
    PuntosPlayer2: integer;
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
    Player1: TCastleBox;
    Player2: TCastleBox;
    PlayerHit: TCastleSound;
    LadoDerecho: TCastleBox;
    LadoIzquierdo: TCastleBox;
    LadoSuperior: TCastleBox;
    LadoInferior: TCastleBox;
    MarcadorPlayer1: TCastleLabel;
    MarcadorPlayer2: TCastleLabel;
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

uses SysUtils;

  { TViewMain ----------------------------------------------------------------- }

procedure TViewMain.ColisionLadoDerecho(
  const CollisionDetails: TPhysicsCollisionDetails);
begin
  //EL jugador 1  (izquierdo) consigue un punto
  PuntosPlayer1 := PuntosPlayer1 + 1;
  MarcadorPlayer1.Caption := IntToStr(PuntosPlayer1);
end;

procedure TViewMain.ColisionLadoIzquierdo(
  const CollisionDetails: TPhysicsCollisionDetails);
begin
  //El jugador 2 (derecha) consigue un punto
  PuntosPlayer2 := PuntosPlayer2 + 1;
  MarcadorPlayer2.Caption := IntToStr(PuntosPlayer2);
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
  VelocidadPlayer1 := 0;
  VelocidadPlayer2 := 0;
  PuntosPlayer1 := 0;
  PuntosPlayer2 := 0;


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

end.
