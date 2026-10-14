namespace PrabinBhusal.OdooIntegration;

codeunit 50100 "Odoo API Client"
{
    var
        ConnectionFailedErr: Label 'Could not connect to Odoo at %1. Check the base URL and that the server is reachable.', Comment = '%1 = Odoo base URL';
        HttpStatusErr: Label 'Odoo returned HTTP status %1 (%2).', Comment = '%1 = HTTP status code, %2 = reason phrase';
        InvalidResponseErr: Label 'Odoo returned a response that is not a valid JSON-RPC result.';
        OdooErrorErr: Label 'Odoo returned an error: %1', Comment = '%1 = error message from Odoo';
        ApiKeyPlaceholderTok: Label '%1', Locked = true;

    // Calls a model method through Odoo's external API (object.execute_kw) and returns the "result" token
    procedure ExecuteKw(Model: Text; Method: Text; Arguments: JsonArray; Options: JsonObject): JsonToken
    var
        OdooConnectionSetup: Record "Odoo Connection Setup";
        Args: JsonArray;
        Params: JsonObject;
        RequestBody: JsonObject;
        BodyTemplate: Text;
    begin
        OdooConnectionSetup.Get();
        OdooConnectionSetup.CheckComplete();

        // execute_kw(db, uid, api key, model, method, args, kwargs)
        Args.Add(OdooConnectionSetup."Database Name");
        Args.Add(OdooConnectionSetup."Odoo User ID");
        Args.Add(ApiKeyPlaceholderTok);
        Args.Add(Model);
        Args.Add(Method);
        Args.Add(Arguments);
        Args.Add(Options);

        Params.Add('service', 'object');
        Params.Add('method', 'execute_kw');
        Params.Add('args', Args);

        RequestBody.Add('jsonrpc', '2.0');
        RequestBody.Add('method', 'call');
        RequestBody.Add('params', Params);
        RequestBody.WriteTo(BodyTemplate);

        // The key is merged in as SecretText so it never sits in a plain Text variable
        exit(Send(OdooConnectionSetup."Base URL", SecretStrSubstNo(BodyTemplate, OdooConnectionSetup.GetApiKey())));
    end;

    procedure TestConnection(): Integer
    var
        Arguments: JsonArray;
        Domain: JsonArray;
        Options: JsonObject;
    begin
        Arguments.Add(Domain);
        exit(ExecuteKw('product.template', 'search_count', Arguments, Options).AsValue().AsInteger());
    end;

    [NonDebuggable]
    local procedure Send(BaseUrl: Text; Body: SecretText) Result: JsonToken
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseJson: JsonObject;
        ErrorToken: JsonToken;
        ResponseText: Text;
    begin
        Content.WriteFrom(Body);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Method := 'POST';
        Request.SetRequestUri(BaseUrl + '/jsonrpc');
        Request.Content := Content;

        if not Client.Send(Request, Response) then
            Error(ConnectionFailedErr, BaseUrl);
        if not Response.IsSuccessStatusCode() then
            Error(HttpStatusErr, Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content().ReadAs(ResponseText);
        if not ResponseJson.ReadFrom(ResponseText) then
            Error(InvalidResponseErr);

        // Odoo answers business errors (access rights, unknown fields) with HTTP 200 and an "error" object
        if ResponseJson.Get('error', ErrorToken) then
            Error(OdooErrorErr, GetErrorMessage(ErrorToken));
        if not ResponseJson.Get('result', Result) then
            Error(InvalidResponseErr);
    end;

    local procedure GetErrorMessage(ErrorToken: JsonToken): Text
    var
        MessageToken: JsonToken;
    begin
        if ErrorToken.SelectToken('data.message', MessageToken) then
            exit(MessageToken.AsValue().AsText());
        if ErrorToken.SelectToken('message', MessageToken) then
            exit(MessageToken.AsValue().AsText());
        exit(Format(ErrorToken));
    end;
}
