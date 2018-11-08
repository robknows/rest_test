$[()~key hsym `$"config.q";
  .config.frontendOrigin:"*";
  system "l config.q"];

////// ALL REQUESTS

\d .jra

// Append a new endpoint to the existing dictionary
addEndpoint:{[curEndpoints;path;f]
  path:$[1=count path;enlist path;path];
  curEndpoints , (enlist path)!enlist f}

////// GET REQUESTS

\d .get

// Create a GET request dictionary from the dictionary passed to .z.ph
request:{`url`headers!(((x[1]`Host),"/",x 0);x 1)}

// At the start, there are no assigned GET endpoints
endpoints:()!()
paramEndpoints:()!()

// Returns true if the provided endpoint path is parameterised.
hasParams:{[path]":" in path}

// If (reqpath) matches (apipath), then the parameters are extracted and returned as a dictionary. Returns 0b if no match.
matchParams:{[apipath;reqpath]
  if[not .[~;{sum "/"=x} each (apipath;reqpath)]; :0b ];
  expEqAt:where ":"<>first each 1_"/" vs apipath;
  actEqAt:where {.[~;x]} each 1_flip "/" vs/: (apipath;reqpath);
  if[not expEqAt~actEqAt; :0b ];
  argsAt:where ":"=first each 1_"/" vs apipath;
  `path`params!(apipath;{(`$1_/:x[0])!x[1]}("/"vs/:(apipath;reqpath))@\:1+argsAt)}

// Associate a GET endpoint with a function
serve:{[path;f]
  $[hasParams path;
    paramEndpoints,:.jra.addEndpoint[paramEndpoints;path;f];
    endpoints,:.jra.addEndpoint[endpoints;path;f]
  ];}

////// POST REQUESTS

\d .post

// Create a POST request dictionary from the dictionary passed to .z.pp
request:{s:" " vs x 0;`url`headers`body!(((x[1]`Host),"/",s 0);x 1;.j.k raze 1_s)}

// At the start, there are no assigned POST endpoints
endpoints:()!()

// Associate a POST endpoint with a function
serve:{[path;f]endpoints,: .jra.addEndpoint[endpoints;path;f];}

////// General

\d .jra

// HTTP 200 OK
okHeader:"HTTP/1.x 200 OK"

// CORS headers
corsAllowOrigin:"Access-Control-Allow-Origin: ",.config.frontendOrigin
corsAllowMethods:{"Access-Control-Allow-Methods: ",x}
corsAllowHeaders:{"Access-Control-Allow-Headers: ",x}
corsHeaders:{[methods;headers]
  corsAllowOrigin,"\r\n",corsAllowMethods[methods],"\r\n",corsAllowHeaders[headers]}

// HTTP OPTIONS generic preflight response: "The frontend can do whatever it wants."
// See: https://stackoverflow.com/questions/10636611/how-does-access-control-allow-origin-header-work
preflightResponse:{[methods;headers]
  okHeader,"\r\n",corsHeaders[methods;headers],"\r\n\r\n"}

// The header for a JSON resposne
jsonHeader:"Content-Type: application/json"

// The header for sending an authentication cookie
setAuthCookieHeader:{"Set-Cookie: sid=",x}

// Create a JSON response from a Q object
jsonResponse:{okHeader,"\r\n",corsAllowOrigin,"\r\n",jsonHeader,"\r\n\r\n",.j.j x}

// Create a JSON response from a Q object including a cookie
authenticatedJsonResponse:{okHeader,"\r\n",jsonHeader,"\r\n",setAuthCookieHeader[x],"\r\n\r\n",.j.j y}

// Unauthorized (401)
unauthorizedHeader:"HTTP/1.x 401 UNAUTHORIZED"
unauthorizedResponse:{unauthorizedHeader,"\r\n\r\n"}

// Given the raw value in the `Cookie header of a HTTP request, produces a dictionary of the available key/value pairs of cookies.
parseCookies:{[cookieHeader]{(`$x 0)!x 1}flip"="vs/:","vs cookieHeader}

// Gets the session cookie from a request
sessionToken:{[req]parseCookies[req[`headers;`Cookie]]`sid}

// For the given incoming get request url, tries to find a function mapped to that endpoint.
// It returns the appropriate function mapping request to response.
matchGetResponder:{[url]
  -1 "Matching endpoint for url: ",url;
  f:.get.endpoints["/","/"sv 1_"/"vs url]; // First check the non-parameterised endpoints
  if[type[f] in (100h;104h); :f];
  -1 "Couldn't find direct endpoint";
  if[0=count .get.paramEndpoints; :0N];
  paramMatches:{[url;path].get.matchParams[path;url]}["/","/"sv 1_"/" vs url;] each key .get.paramEndpoints;
  matching:paramMatches where {not 0b~x} each paramMatches;
  if[0=count matching; :0N];
  match:first matching;
  `f`params!(.get.paramEndpoints[match`path];match`params);
  f:.get.paramEndpoints[match`path];
  params:match`params;
  {[f;params;req]
    f[req,(enlist `params)!enlist params]}[f;params;]}

// Start listening using the current endpoints on the given port
listen:{[p]
  .z.ph::{
    getreq::.get.request x;
    -1 "Received GET";
    -1 .j.j getreq;
    f::matchGetResponder getreq.url;
    -1 "Matched endpoint";
    getres::$[ 0N~f ; jsonResponse "none" ;  f getreq ];
    -1 "Sending response";
    -1 getres;
    getres};
  .z.pp::{
    postreq::.post.request x;
    -1 "Received POST";
    -1 .j.j postreq;
    f:.post.endpoints["/","/"sv 1_"/"vs postreq.url];
    postres::$[ null f ; jsonResponse "none" ; f postreq ];
    -1 "Sending response";
    -1 postres;
    postres};
  .z.pm::{
    optreq::`path`headers!(x 1;x 2);
    -1 "Received OPTIONS";
    -1 .j.j optreq;
    method:$[ ""~m:optreq[`headers;`$"access-control-request-method"] ; "GET" ; m ];
    headers:$[ ""~h:optreq[`headers;`$"access-control-request-headers"] ; "access-control-allow-origin" ; h ];
    optres::preflightResponse[method;headers];
    -1 "Sending response";
    -1 optres;
    optres};
  system "p ",string p;}

////// RESPONSE

\d .res

ok:{[f]
  {[f;req]
    .jra.jsonResponse f req}[f;]}

okWithAuthCookie:{[sid;f]
  {[sid;f;req]
    .jra.authenticatedJsonResponse[sid;f req]}[sid;f;]}
