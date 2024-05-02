unit Controller.Comum;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DataSet.Serialize;

function CreateJsonObj(pairName: string; value: string): TJSONObject; overload;
function CreateJsonObj(pairName: string; value: integer): TJSONObject; overload;
function CreateJsonObj(pairName: string; value: double): TJSONObject; overload;

implementation

function CreateJsonObj(pairName: string; value: string): TJSONObject;
begin
    Result := TJSONObject.Create(TJSONPair.Create(pairName, value));
end;

function CreateJsonObj(pairName: string; value: integer): TJSONObject;
begin
    Result := TJSONObject.Create(TJSONPair.Create(pairName, TJSONNumber.Create(value)));
end;

function CreateJsonObj(pairName: string; value: double): TJSONObject;
begin
    Result := TJSONObject.Create(TJSONPair.Create(pairName, TJSONNumber.Create(value)));
end;

end.
