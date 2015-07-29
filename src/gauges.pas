{
Copyright (C) Alexey Torgashin, uvviewsoft.com
Written for Lazarus LCL
License: MPL 2.0 or LGPL or any license which LCL can use
}

unit gauges;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls;

type
  { TGauge }

  TGauge = class(TGraphicControl)
  private
    FBorderStyle: TBorderStyle;
    FBitmap: TBitmap;
    FColorBack,
    FColorFore,
    FColorBorder: TColor;
    FMinValue,
    FMaxValue,
    FProgress: integer;
    procedure DoPaintTo(C: TCanvas; r: TRect);
    procedure SetColorBorder(AValue: TColor);
    procedure SetBorderStyle(AValue: TBorderStyle);
    procedure SetColorBack(AValue: TColor);
    procedure SetColorFore(AValue: TColor);
    procedure SetMaxValue(AValue: integer);
    procedure SetMinValue(AValue: integer);
    procedure SetProgress(AValue: integer);
  protected
    procedure Paint; override;
    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property BorderSpacing;
    property Font;
    property Progress: integer read FProgress write SetProgress;
    property MinValue: integer read FMinValue write SetMinValue default 0;
    property MaxValue: integer read FMaxValue write SetMaxValue default 100;
    property BackColor: TColor read FColorBack write SetColorBack default clWhite;
    property ForeColor: TColor read FColorFore write SetColorFore default clNavy;
    property BorderColor: TColor read FColorBorder write SetColorBorder default clBlack;
  end;

implementation

uses
  Math, Types, LCLType, LCLIntf;

{ TGauge }

procedure TGauge.DoPaintTo(C: TCanvas; r: TRect);
var
  NSize: integer;
begin
  //paint backgrd
  C.Pen.Color:= FColorBack;
  C.Brush.Color:= FColorBack;
  C.FillRect(r);

  //paint bar
  C.Brush.Color:= FColorFore;
  NSize:= Round((r.Right-r.Left) * (FProgress-FMinValue) / (FMaxValue-FMinValue));
  C.FillRect(r.Left, r.Top, r.Left+NSize, r.Bottom);

  //paint border
  if FBorderStyle<>bsNone then
  begin
    C.Pen.Color:= FColorBorder;
    C.Brush.Style:= bsClear;
    C.Rectangle(r);
    C.Brush.Style:= bsSolid;
  end;
end;

procedure TGauge.SetColorBorder(AValue: TColor);
begin
  if FColorBorder=AValue then Exit;
  FColorBorder:=AValue;
  Update;
end;

procedure TGauge.SetBorderStyle(AValue: TBorderStyle);
begin
  if FBorderStyle=AValue then Exit;
  FBorderStyle:=AValue;
  Update;
end;

procedure TGauge.SetColorBack(AValue: TColor);
begin
  if FColorBack=AValue then Exit;
  FColorBack:=AValue;
  Update;
end;

procedure TGauge.SetColorFore(AValue: TColor);
begin
  if FColorFore=AValue then Exit;
  FColorFore:=AValue;
  Update;
end;

procedure TGauge.SetMaxValue(AValue: integer);
begin
  if FMaxValue=AValue then Exit;
  FMaxValue:=AValue;
  FProgress:=Min(FProgress, FMaxValue);
  Update;
end;

procedure TGauge.SetMinValue(AValue: integer);
begin
  if FMinValue=AValue then Exit;
  FMinValue:=AValue;
  FProgress:=Max(FProgress, FMinValue);
  Update;
end;

procedure TGauge.SetProgress(AValue: integer);
begin
  if FProgress=AValue then Exit;
  FProgress:=Max(FMinValue, Min(FMaxValue, AValue));
  Update;
end;

procedure TGauge.Paint;
var
  R: TRect;
begin
  inherited;

  R:= ClientRect;
  FBitmap.Canvas.Font.Assign(Self.Font);
  DoPaintTo(FBitmap.Canvas, R);
  Canvas.CopyRect(R, FBitmap.Canvas, R);
end;


constructor TGauge.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle:= ControlStyle
    +[csOpaque, csNoFocus]
    -[csDoubleClicks, csTripleClicks];

  Width:= 150;
  Height:= 30;

  FBitmap:= TBitmap.Create;
  FBitmap.SetSize(500, 80);

  FBorderStyle:= bsSingle;
  FColorBack:= clWhite;
  FColorFore:= clNavy;
  FColorBorder:= clBlack;

  FMinValue:= 0;
  FMaxValue:= 100;
  FProgress:= 20;
end;

destructor TGauge.Destroy;
begin
  FreeAndNil(FBitmap);
  inherited;
end;

procedure TGauge.DoOnResize;
const
  cResizeBitmapStep = 200;
var
  SizeX, SizeY: integer;
begin
  inherited;

  if Assigned(FBitmap) then
  begin
    SizeX:= (Width div cResizeBitmapStep + 1)*cResizeBitmapStep;
    SizeY:= (Height div cResizeBitmapStep + 1)*cResizeBitmapStep;
    if (SizeX>FBitmap.Width) or (SizeY>FBitmap.Height) then
    begin
      FBitmap.SetSize(SizeX, SizeY);
      FBitmap.FreeImage; //recommended, else seen black bitmap on bigsize
    end;
  end;

  Update;
end;


initialization

end.

