import Text "mo:base/Text";
import Http "http";

actor {
public type HttpRequest = Http.HttpRequest;
public type HttpResponse = Http.HttpResponse;


public query func http_request(req : HttpRequest) : async HttpResponse {
    return ({
        body = Text.encodeUtf8("Hello, world!");
        headers = [];
        status_code = 200;
        streaming_strategy = null;
    })
};}



