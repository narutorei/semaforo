unit unClassSemaforo;

interface
  uses ExtCtrls, Classes, Controls, Graphics, MMSystem, System.SysUtils,
    Vcl.Dialogs;

Type
  TSemaforo = class(TImage)
    private
      // Fields
      FTamLamp  : Byte;
      FTimer    : TTimer;
      FAtual    : Byte;
      FAlerta   : Boolean;
      FAcende   : Boolean;
      FQueimada : Array[1..13] of Boolean;
      FNomeRua  : String;
      FPosition : Byte;

      procedure Desenha;
      procedure DesenhaNome(Val: String);
      procedure Lampada(Pos: Byte; Liga: Boolean);
      procedure ResetAberto;
      procedure ResetFechado;
      procedure MudaAlerta(Init, Prox: TSemaforo);
      function  TraduzClick(X, Y: Integer): Byte;

      // Eventos
      procedure FTimerTimer (Sender: TObject);
      procedure TSemaforoMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      procedure SetAlerta(const Value: Boolean);
      procedure SetNomeRua(const Value: String);
    public
      Proximo: TSemaforo;

      constructor Create(X, Y: Integer; crTamLamp: Byte; crNome: String;
        crPos: Byte; AOwner: TComponent);
      destructor Destroy;

      property Alerta: Boolean read FAlerta Write SetAlerta;
      property NomeRua: String read FNomeRua Write SetNomeRua;

  end;

implementation

{ TSemaforo }

constructor TSemaforo.Create(X, Y: Integer; crTamLamp: Byte; crNome: String;
  crPos: Byte; AOwner: TComponent);
begin
  inherited Create(AOwner);

  Parent := TWinControl(AOwner);

  Left := X;
  Top  := Y;

  FPosition := crPos;

  FTamLamp := CrTamLamp;

  // CSS Styles
  case FPosition of
    1, 3: begin
      Width    := 3 * FTamLamp;
      Height   := 7 * FTamLamp;
    end;
    2, 4: begin
      Width    := 6 * FTamLamp;
      Height   := 4 * FTamLamp;
    end;
  end;

  Color    := clWhite;

  FAtual   := 7;
  FAlerta  := True;
  Desenha;

  NomeRua  := crNome;

  OnMouseDown := TSemaforoMouseDown; // Assinando o evento

  FTimer := TTimer.Create(AOwner);
  FTimer.Interval := 500;
  FTimer.Enabled  := True;
  FTimer.OnTimer  := FTimerTImer;
end;

procedure TSemaforo.Desenha;
var i: Byte;
begin
  with Canvas do
  begin
    Pen.Color := clBlack;
    Brush.Color := clSilver;

    case FPosition of
      1, 3: Rectangle(0, 0, 3 * FTamLamp, 6 * FTamLamp);
      2, 4: Rectangle(0, 0, 6 * FTamLamp, 3 * FTamLamp);
    end;

    for I := 1 to 13 do
      Lampada(i, False);
  end;
end;

procedure TSemaforo.DesenhaNome(Val: String);
begin
  with Canvas do
    begin
      Brush.Color := clWhite;
      Pen.Color := clWhite;

      case FPosition of
       1, 3: Rectangle(0, 6 * FTamLamp, 3 * FTamLamp, 7 * FTamLamp);
       2, 4: Rectangle(0, 3 * FTamLamp, 6 * FTamLamp, 4 * FTamLamp);
      end;

      Font.Size := Round(0.5 * FTamLamp);
      Font.Color := clRed;

      case FPosition of
        1, 3: TextOut(10, 6 * FTamLamp + 5, Val);
        2, 4: TextOut(10, 3 * FTamLamp + 5, Val);
      end;

    end;
end;

destructor TSemaforo.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TSemaforo.FTimerTimer(Sender: TObject);
begin
  if FAlerta then
    begin
      FAcende := Not FAcende;
      Lampada(7, FAcende);
    end
  else
    begin
      // Incrementando o Atual
      if FAtual = 13 then
        FAtual := 1
      else
        inc(FAtual);

      case FAtual of
        1    : Begin
          Lampada(13, False);
          Lampada(1, True);
          Lampada(6, True);
        End;
        2..7,
        9..13: begin
          if(FAtual = 3) AND (Proximo <> Nil) then
            Proximo.FTimer.Enabled := True;

          Lampada(FAtual - 1, False);
          Lampada(FAtual, True);
        end;
        8    : begin
            FTimer.Enabled := False;
            Lampada(7, False);
            Lampada(8, True);
            Lampada(13, True);
        end;
      end;

    end;
end;

procedure TSemaforo.Lampada(Pos: Byte; Liga: Boolean);
var x, y: Integer;
    cor: TColor;
begin

  X   := 0;
  Y   := 0;
  cor := clBlack;

  case FPosition of
    1:
      case Pos of
        1..6 : begin
          X   := FTamLamp * 2;
          Y   := FTamLamp * (Pos - 1);
          cor := clLime;
        end;
        7    : begin
          X   := FTamLamp;
          Y   := FTamLamp * 5;
          cor := clYellow;
        end;
        8..13: begin
          X   := 0;
          Y   := FTamLamp * (Pos - 8);
          cor := clRed;
        end;
      end;
    2:
      case Pos of
        1..6 : begin
          X   := FTamLamp * (Pos - 1);
          Y   := 0;
          cor := clLime;
        end;
        7    : begin
          X   := FTamLamp * 5;
          Y   := FTamLamp;
          cor := clYellow;
        end;
        8..13: begin
          X   := FTamLamp * (Pos - 8);
          Y   := FTamLamp * 2;
          cor := clRed;
        end;
      end;
    3:
      case Pos of
        1..6 : begin
          X   := 0;
          Y   := FTamLamp * (6 - Pos);
          cor := clLime;
        end;
        7    : begin
          X   := FTamLamp;
          Y   := 0;
          cor := clYellow;
        end;
        8..13: begin
          X   := FTamLamp * 2;
          Y   := FTamLamp * (13 - Pos);
          cor := clRed;
        end;
      end;
    4:
      case Pos of
        1..6 : begin
          X   := FTamLamp * (6 - Pos);
          Y   := FTamLamp * 2;
          cor := clLime;
        end;
        7    : begin
          X   := 0;
          Y   := FTamLamp;
          cor := clYellow;
        end;
        8..13: begin
          X   := FTamLamp * (13 - Pos);
          Y   := 0;
          cor := clRed;
        end;
      end;
  end;

  if FQueimada[Pos] then
    cor := clBlue
  else
    if Not Liga then
      cor := clBlack;

  with Canvas do
  begin
    Pen.Color := clBlack;
    Brush.Color := clSilver;
    Rectangle(x, y, x + FTamLamp, y + FTamLamp);

    Brush.Color := cor;
    Ellipse(x, y, x + FTamLamp, y + FTamLamp);
  end;
end;

procedure TSemaforo.MudaAlerta(Init, Prox: TSemaforo);
begin
  if(Init = Prox) OR (Proximo = Nil) then
    with Init do
    begin
      Desenha;
      FTimer.Enabled := False;
      FAcende := False;
      if Not FAlerta then
        ResetAberto
      else
        FAtual := 7;
      FTimer.Enabled := True;
    end
  else
    with Prox do
    begin
      Desenha;
      FTimer.Enabled := False;
      FAcende := False;
      FAlerta := Init.FAlerta;

      if Not FAlerta then
        ResetFechado
      else
        FAtual := 7;

      if Proximo <> Nil then
        MudaAlerta(Init, Proximo);

      FTimer.Enabled := FAlerta;
    end;
end;

procedure TSemaforo.ResetAberto;
begin
  FAtual := 1;
  Lampada(1, True);
  Lampada(6, True);
end;

procedure TSemaforo.ResetFechado;
begin
  FAtual := 8;
  Lampada(8, True);
  Lampada(13, True);
end;

procedure TSemaforo.SetAlerta(const Value: Boolean);
begin
  if Value <> FAlerta then
    begin
      FAlerta := Value;
      MudaAlerta(Self, Proximo);
    end;
end;

procedure TSemaforo.SetNomeRua(const Value: String);
begin
  if(FNomeRua <> Value) then
  begin
    FNomeRua := Value;
    DesenhaNome(FNomeRua);
  end;
end;

function TSemaforo.TraduzClick(X, Y: Integer): Byte;
var
  PosX, PosY: Byte;
begin
  PosX := (X div FTamLamp) + 1;
  PosY := (Y div FTamLamp) + 1;

  case FPosition of
    1:
      if(PosX = 1) AND (PosY < 7) then
        Result := PosY + 7
      else
        if(PosX = 2) AND (PosY = 6) then
          Result := 7
        else
          if(PosX = 3) AND (PosY < 7) then
            Result := PosY
          else
            Result := 0;

    2:
      if(PosX < 7) AND (PosY = 3) then
        Result := PosX + 7
      else
        if(PosX = 6) AND (PosY = 2) then
          Result := 7
        else
          if(PosX < 7) AND (PosY = 1) then
            Result := PosX
          else
            Result := 0;

    3:
      if(PosX = 3) AND (PosY < 7) then
         Result := 14 - PosY
      else
        if(PosX = 2) AND (PosY = 1) then
          Result := 7
        else
          if(PosX = 1) AND (PosY < 7) then
            Result := 7 - PosY
          else
            Result := 0;

    4:
      if(PosX < 7) AND (PosY = 1) then
        Result := 14 - PosX
      else
        if(PosX = 1) AND (PosY = 2) then
          Result := 7
        else
          if(PosX < 7) AND (PosY = 3) then
            Result := 7 - PosX
          else
            Result := 0;

    else
      Result := 0;

  end;

end;

procedure TSemaforo.TSemaforoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  PosLamp: Byte;
  Liga: Boolean;
begin
  PosLamp := TraduzClick(X, Y);

  if(PosLamp <> 0) then
    begin
      if NOT FQueimada[PosLamp] then
        PlaySound('quebra.wav', 1, $0001)
      else
        PlaySound('troca.wav', 1, $0001);

      FQueimada[PosLamp] := NOT FQueimada[PosLamp];

      Liga := (PosLamp = FAtual) OR
        ((PosLamp = 6) AND (FAtual < 6)) OR
        ((PosLamp = 13) AND (FAtual < 13) AND (FAtual > 7));

      Lampada(PosLamp, Liga);
    end;
end;

end.
