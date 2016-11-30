unit Unit91;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MongoDB,
  FireDAC.Phys.MongoDBDef, System.Rtti, System.JSON.Types, System.JSON.Readers, System.JSON.BSON, System.JSON.Builders,
  FireDAC.Phys.MongoDBWrapper, FireDAC.VCLUI.Wait, Vcl.ExtCtrls, FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client,
  Vcl.StdCtrls, dxGDIPlusClasses;

type

  TMinhaImagem = class
  private
    FNome   : String;
    FImagem : WideString;
    constructor InternalCreate(const Value : String);
  public
    function ToJSON : String;
    class function FromJSON(const Value : String) : TMinhaImagem;
    property Nome: String read FNome write FNome;
    property Imagem: WideString read FImagem write FImagem;
  end;

  TForm91 = class(TForm)
    FDConnection1: TFDConnection;
    FDPhysMongoDriverLink1: TFDPhysMongoDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure FDConnection1AfterConnect(Sender: TObject);
    procedure FDConnection1AfterDisconnect(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FConnMongo  : TMongoConnection;
    FEnv        : TMongoEnv;
  end;

var
  Form91: TForm91;

implementation

uses
  System.JSON, REST.Json;

{$R *.dfm}

procedure TForm91.Button1Click(Sender: TObject);
var
  aMI : TMinhaImagem;
  Doc : TMongoDocument;
  aBS : TStringStream;
  aBM : TBitmap;
begin
  if not FDConnection1.Connected then
    FDConnection1.Open;

  aBS := TStringStream.Create;
  aBM := TBitmap.Create;
  aBM.Assign(Image1.Picture.Graphic);
  aBM.SaveToStream(aBS);
  aMI := TMinhaImagem.Create;
  aMI.Nome := Edit1.Text;
  aMI.Imagem := aBS.DataString;
  Doc := FEnv.NewDoc;
  Doc.AsJSON := aMI.ToJSON;

  FConnMongo['teste_img']['Doc_com_imagem'].Insert(Doc);

end;

procedure TForm91.Button2Click(Sender: TObject);
var
  aMI     : TMinhaImagem;
  aBS     : TStringStream;
  aBM     : TBitmap;
  aQry    : TMongoQuery;
  aCursor : IMongoCursor;
begin
  Image1.Picture := nil;
  Edit1.Text     := '';
  ShowMessage('Agora busca a imagem do banco');

  if not FDConnection1.Connected then
    FDConnection1.Open;

  aMI := TMinhaImagem.Create;

  aQry := TMongoQuery.Create(FEnv);
  aCursor := FConnMongo['teste_img']['Doc_com_imagem'].Find(aQry);
  while aCursor.Next do
  begin
    aMI := TMinhaImagem.FromJSON(aCursor.Doc.AsJSON);
  end;

  Edit1.Text := aMI.Nome;

  aBS := TStringStream.Create(aMI.Imagem);
  aBM := TBitmap.Create;

  aBM.LoadFromStream(aBS);
  Image1.Picture.Bitmap := aBM;

end;

procedure TForm91.FDConnection1AfterConnect(Sender: TObject);
begin
  FConnMongo := TMongoConnection(FDConnection1.CliObj);
  FEnv       := FConnMongo.Env;
end;

procedure TForm91.FDConnection1AfterDisconnect(Sender: TObject);
begin
  FConnMongo := Nil;
  FEnv       := Nil;

end;

{ TMinhaImagem }

class function TMinhaImagem.FromJSON(const Value: String): TMinhaImagem;
begin
  Result := InternalCreate(Value);
end;

constructor TMinhaImagem.InternalCreate(const Value: String);
begin
  Create;
  Self := TJson.JsonToObject<TMinhaImagem>(Value);
end;

function TMinhaImagem.ToJSON: String;
begin
  Result := TJson.ObjectToJsonString(Self,[]);
end;

end.
