A demo of selected features of CPub.

Create a User
=============

Users can be created from the Elixir shell.

For example we create the user \"alice\" with password \"123\":

``` {.elixir}
{:ok, alice} = CPub.User.create("alice")
{:ok, _registration} = CPub.User.Registration.create_internal(alice, "123")
```

This creates the user, an actor profile, inbox and outbox for the user
and inserts it into the database in a transaction.

``` {.restclient exports="both"}
GET http://localhost:4000/users/alice
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:4000/users/alice>
    a as:Person ;
    ldp:inbox <http://localhost:4000/users/alice/inbox> ;
    as:outbox <http://localhost:4000/users/alice/outbox> ;
    as:preferredUsername "alice" .

// GET http://localhost:4000/users/alice
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 518
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 11:48:34 GMT
// server: Cowboy
// x-request-id: Fk9nX3QrNfU_3gEAADjk
// Request duration: 0.167211s
```

An inbox and outbox has been created for the actor.

The inbox and outbox are protected so that only the user \"alice\" can
access them.

In order to access the inbox and outbox we first need to authenticate
and receive authorization.

Authentication and Authorization
================================

Some resources (such as user inbox and outbox) are accessible only to
specific users. If a user wants to access such a resource, they need to
authenticate (prove that they are the user) and then receive
authorization to access the route. See *Authentication and
Authorization* for a complete reference on how this works.

In this demo we will use the OAuth 2.0 \"Resource Owner Password
Credentials\" flow. We will authenticate with a username and password
and immediately receive a token (an Access Token in OAuth terminology)
with which we can access the inbox and outbox.

This flow is suitable for clients that are capable of securely handling
user secrets (i.e. password).

Web applications are not capable of securely handling user secrets and
should use the \"Authorization Code\" flow. See the documentation on
[Authentication and Authorization](./auth.md) for more information.

Resource Owner Password Credentials flow
----------------------------------------

``` {.restclient exports="both"}
POST http://localhost:4000/oauth/token
Content-type: application/json

{"grant_type": "password",
 "username": "alice",
 "password": "123"
}
```

``` {.javascript org-language="js"}
{
  "access_token": "BY33XRRLBE3JVE4JAK4BEKCIYCXKJWJ4XK47U34C2MBTTNTR6Y3A",
  "expires_in": 5184000,
  "refresh_token": "3KNFH6LW6Z6OQKUZWCQVYXMU75YVBAF5HBIGMBTSKROJREFIZ6TA",
  "token_type": "bearer"
}
// POST http://localhost:4000/oauth/token
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 185
// content-type: application/json; charset=utf-8
// date: Fri, 11 Dec 2020 11:48:42 GMT
// server: Cowboy
// x-request-id: Fk9nYQ5POalqxw8AAFTi
// Request duration: 1.644388s
```

Authorization Code
------------------

For illustration purposes we demonstrate the OAuth \"Authorization
Code\" flow including dynamic client registration.

### Client registration

Clients can be dynamically registered using the [OAuth 2.0 Dynamic
Client Registration Protocol (RFC
7591)](https://tools.ietf.org/html/rfc7591):

``` {.restclient exports="both"}
POST http://localhost:4000/oauth/clients
Content-type: application/json

{"client_name": "Demo client",
 "redirect_uris": ["https://example.com/"],
 "scope": "read write"
}
```

``` {.javascript org-language="js"}
{
  "client_id": "86ff98ca-b61c-4a5f-ba7b-0668f81af113",
  "client_name": "Demo client",
  "client_secret": "VEJ5SCFUA4VNXNE4CO5EV5DTIW377LVFY3AVOIEINKH52GA73BQQ",
  "redirect_uris": [
    "https://example.com/"
  ],
  "scope": [
    "read",
    "write"
  ]
}
// POST http://localhost:4000/oauth/clients
// HTTP/1.1 201 Created
// cache-control: max-age=0, private, must-revalidate
// content-length: 217
// content-type: application/json; charset=utf-8
// date: Thu, 19 Nov 2020 10:17:53 GMT
// server: Cowboy
// x-request-id: Fki_Pz5H44PceYUAADYE
// Request duration: 0.034235s
```

### Authorization request

A user can now be requested to grant authorization to the client by
redirecting to following URL:

<http://localhost:4000/oauth/authorize?client_id=86ff98ca-b61c-4a5f-ba7b-0668f81af113&scope=read+write&response_type=code>

Note how this includes the `client_id`, the requested `scope` and the
`response_type=code`.

The user will be presented with an interface where they can either
\"Accept\" or \"Deny\" the request.

If the request is granted the browser will be redirected to the
`redirect_uri` with an \"Authorization Grant\" that is encoded in the
`code` query parameter:

<https://example.com/?code=A2DWGE3CLKVGA3XXTFFSZJRM7NJMBZKGPLHLUER3UWDIPK32RQDA>

### Authorization Grant

The Authorization Grant can be exchanged for an access token by making a
call to the token endpoint:

``` {.restclient exports="both"}
POST http://localhost:4000/oauth/token
Content-type: application/json

{"grant_type": "authorization_code",
 "code": "A2DWGE3CLKVGA3XXTFFSZJRM7NJMBZKGPLHLUER3UWDIPK32RQDA",
 "client_id": "86ff98ca-b61c-4a5f-ba7b-0668f81af113"}
```

``` {.javascript org-language="js"}
{
  "access_token": "5ULWP3ZLUDZM6UFF55SCQPZRHH45W52SPG4UV4GSYFE2DEPF25GA",
  "expires_in": 5184000,
  "refresh_token": "VZGG2FCYDGXFNTFGIF3Z5GO76VF65QVZE7LSWIMVFQEBKOZQINMQ",
  "token_type": "bearer"
}
// POST http://localhost:4000/oauth/token
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 185
// content-type: application/json; charset=utf-8
// date: Thu, 19 Nov 2020 11:26:11 GMT
// server: Cowboy
// x-request-id: FkjC6RXdaUxefXAAAFqB
// Request duration: 1.410083s
```

The returned `access_token` can be used to access protected resources.

Inbox and Outbox
================

We can now access Alice\'s inbox by using the \`access~token~\`:

``` {.restclient exports="both"}
GET http://localhost:4000/users/alice/inbox
Accept: text/turtle
Authorization: Bearer BY33XRRLBE3JVE4JAK4BEKCIYCXKJWJ4XK47U34C2MBTTNTR6Y3A
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:4000/users/alice/inbox>
    a ldp:BasicContainer, as:Collection .

// GET http://localhost:4000/users/alice/inbox
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 396
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:06:49 GMT
// server: Cowboy
// x-request-id: Fk9oYN0IONLwoQgAADxE
// Request duration: 0.594034s
```

As well as the outbox:

``` {.restclient exports="both"}
GET http://localhost:4000/users/alice/outbox
Accept: text/turtle
Authorization: Bearer BY33XRRLBE3JVE4JAK4BEKCIYCXKJWJ4XK47U34C2MBTTNTR6Y3A
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:4000/users/alice/outbox>
    a ldp:BasicContainer, as:Collection .

// GET http://localhost:4000/users/alice/outbox
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 397
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:09:19 GMT
// server: Cowboy
// x-request-id: Fk9og_rli75OS1YAAEAh
// Request duration: 0.160957s
```

Both inbox and outbox are still empty.

Note that the inbox and outbox are both a Linked Data Platform basic
containers and ActivityStreams collection.

Posting an Activity
===================

We create another user `bob`:

``` {.elixir}
{:ok, bob} = CPub.User.create("bob")
{:ok, _registration} = CPub.User.Registration.create_internal(bob, "123")
```

And get an access token for Bob:

``` {.restclient exports="both"}
POST http://localhost:4000/oauth/token
Content-type: application/json

{"grant_type": "password",
 "username": "bob",
 "password": "123"
}
```

``` {.javascript org-language="js"}
{
  "access_token": "32MAIUDZ2FZV56ULTHEZKKTFT4MFET3N4Z7HFCDTLSJSKE6SVDXQ",
  "expires_in": 5184000,
  "refresh_token": "3NQ6IAOKNDDML4OZWHOLABEWIHNPZROYG6DOXM6KU2AAS2CWTCBA",
  "token_type": "bearer"
}
// POST http://localhost:4000/oauth/token
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 185
// content-type: application/json; charset=utf-8
// date: Fri, 11 Dec 2020 12:29:23 GMT
// server: Cowboy
// x-request-id: Fk9pnsfKhN3-MIcAAD2D
// Request duration: 1.629478s
```

We can get Bob\'s inbox:

``` {.restclient exports="both"}
GET http://localhost:4000/users/bob/inbox
Accept: text/turtle
Authorization: Bearer 32MAIUDZ2FZV56ULTHEZKKTFT4MFET3N4Z7HFCDTLSJSKE6SVDXQ
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:4000/users/bob/inbox>
    a ldp:BasicContainer, as:Collection .

// GET http://localhost:4000/users/bob/inbox
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 394
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:29:46 GMT
// server: Cowboy
// x-request-id: Fk9ppKHVrTRPRAIAAFtC
// Request duration: 0.294868s
```

Also empty. Let\'s change that.

Alice can post a note to Bob:

``` {.restclient exports="both"}
POST http://localhost:4000/users/alice/outbox
Authorization: Bearer BY33XRRLBE3JVE4JAK4BEKCIYCXKJWJ4XK47U34C2MBTTNTR6Y3A
Accept: text/turtle
Content-type: text/turtle

@prefix as: <https://www.w3.org/ns/activitystreams#> .

<>
    a as:Create ;
    as:to <local:bob> ;
    as:object _:object .

_:object
    a as:Note ;
    as:content "Good day!"@en ;
    as:content "Guten Tag!"@de ;
    as:content "Gr??ezi"@gsw ;
    as:content "Bun di!"@roh .
```

``` {.javascript org-language="js"}
// POST http://localhost:4000/users/alice/outbox
// HTTP/1.1 201 Created
// cache-control: max-age=0, private, must-revalidate
// content-length: 0
// date: Fri, 11 Dec 2020 12:37:27 GMT
// location: urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ
// server: Cowboy
// x-request-id: Fk9qEQwfW4Tu8lQAAFvC
// Request duration: 0.219732s
```

The activity has been created and the IRI of the created activity is
returned in the location header.

Note that we used a special IRI \<local:bob\> to address Bob. This is a
temporary hack...stay tuned.

The created activity is content-addressed. The IRI is not a HTTP
location but a hash of the content (see [Content-addressable
RDF](https://openengiadina.net/papers/content-addressable-rdf.html) and
[An Encoding for Robust Immutable Storage](http://purl.org/eris) for
more information). The `/resolve` endpoint can be used to resolve such
content-addressed IRIs.

``` {.restclient exports="both"}
GET http://localhost:4000/resolve?iri=urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ>
    a as:Create ;
    as:object <urn:erisx2:AAAJCG3NTPIG26N5OO4IYMXLDB42B5MBBLDKSVAQRVPPACJAY4BA6KSZXF4QI7VH7QFXGMLLWCHONU35XUWTPBP54WWRVOS4N2NHNX3CFE> ;
    as:to <local:bob> .

// GET http://localhost:4000/resolve?iri=urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 610
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:43:18 GMT
// server: Cowboy
// x-request-id: Fk9qY1iCit_Nwv8AAD6k
// Request duration: 0.197014s
```

No authentication is required to access the activity. Simply the fact of
knowing the id (which is not guessable) is enough to gain access.

The created object has not been included in the response, it has an id
of it\'s own and can be accessed directly:

``` {.restclient exports="both"}
GET http://localhost:4000/resolve?iri=urn:erisx2:AAAJCG3NTPIG26N5OO4IYMXLDB42B5MBBLDKSVAQRVPPACJAY4BA6KSZXF4QI7VH7QFXGMLLWCHONU35XUWTPBP54WWRVOS4N2NHNX3CFE
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<urn:erisx2:AAAJCG3NTPIG26N5OO4IYMXLDB42B5MBBLDKSVAQRVPPACJAY4BA6KSZXF4QI7VH7QFXGMLLWCHONU35XUWTPBP54WWRVOS4N2NHNX3CFE>
    a as:Note ;
    as:content "Guten Tag!"@de, "Good day!"@en, "Gr??ezi"@gsw, "Bun di!"@roh .

// GET http://localhost:4000/resolve?iri=urn:erisx2:AAAJCG3NTPIG26N5OO4IYMXLDB42B5MBBLDKSVAQRVPPACJAY4BA6KSZXF4QI7VH7QFXGMLLWCHONU35XUWTPBP54WWRVOS4N2NHNX3CFE
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 527
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:44:26 GMT
// server: Cowboy
// x-request-id: Fk9qc3l_RD64Pd8AAD7E
// Request duration: 0.179893s
```

The activity is now also in Bob\'s inbox:

``` {.restclient exports="both"}
GET http://localhost:4000/users/bob/inbox
Authorization: Bearer 32MAIUDZ2FZV56ULTHEZKKTFT4MFET3N4Z7HFCDTLSJSKE6SVDXQ
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:4000/users/bob/inbox>
    a ldp:BasicContainer, as:Collection ;
    ldp:member <urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ> ;
    as:items <urn:erisx2:AAAGMKSTO7PVBU24HTHZXAJVHCBM47K5BPEPQAGJF3WODA6L6EZ23FC2EIB3T4FHISVJ4NCXUW34XMT3GZPUGEYRJJKTMXMHQSFDN6MMTQ> .

// GET http://localhost:4000/users/bob/inbox
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 666
// content-type: text/turtle; charset=utf-8
// date: Fri, 11 Dec 2020 12:47:06 GMT
// server: Cowboy
// x-request-id: Fk9qmQM0Ekb_TUMAAEIB
// Request duration: 0.594640s
```

Public addressing
=================

Alice can create a note that should be publicly accessible by addressing
it to the special public collection
(`https://www.w3.org/ns/activitystreams#Public`).

``` {.restclient exports="both"}
POST http://localhost:4000/users/alice/outbox
Authorization: Bearer RS6XZHOA5E5CWWXFXK7THURZ3DBGHT6XBO3QHHJUGOEOTMHLGXMQ
Accept: text/turtle
Content-type: text/turtle

@prefix as: <https://www.w3.org/ns/activitystreams#> .

<>
    a as:Create ;
    as:to as:Public ;
    as:object _:object .

_:object
    a as:Note ;
    as:content "Hi! This is a public note." .
```

``` {.javascript org-language="js"}
// POST http://localhost:4000/users/alice/outbox
// HTTP/1.1 201 Created
// Location: http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA
// cache-control: max-age=0, private, must-revalidate
// content-length: 0
// date: Mon, 27 Jul 2020 09:58:36 GMT
// server: Cowboy
// x-request-id: FiWSpYgQC6dWD9gAABlB
// Request duration: 0.056130s
```

This activity has been placed in Alice\'s outbox:

``` {.restclient exports="both"}
GET http://localhost:4000/users/alice/outbox
Authorization: Bearer RS6XZHOA5E5CWWXFXK7THURZ3DBGHT6XBO3QHHJUGOEOTMHLGXMQ
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix as: <https://www.w3.org/ns/activitystreams#> .

<http://localhost:4000/users/alice/outbox>
    a ldp:BasicContainer, as:Collection ;
    ldp:member <urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA> ;
    as:items <urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA> .

<urn:erisx:AAAAAX3CRD27X2GTBX7ILUBK4QX2MHH57KQSQEWWG3NO7X4A5PSS6NISE4LRWEEFJDA6SLJTKFFS2KUPY2M5FXOHWGW2WRGUCBWLVT6WZZ4Q>
    a as:Note ;
    as:content "Hi! This is a public note." .

<urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA>
    a as:Create ;
    as:actor <http://localhost:4000/users/alice> ;
    as:object <urn:erisx:AAAAAX3CRD27X2GTBX7ILUBK4QX2MHH57KQSQEWWG3NO7X4A5PSS6NISE4LRWEEFJDA6SLJTKFFS2KUPY2M5FXOHWGW2WRGUCBWLVT6WZZ4Q> ;
    as:to as:Public .

// GET http://localhost:4000/users/alice/outbox
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 1205
// content-type: text/turtle; charset=utf-8
// date: Mon, 27 Jul 2020 09:58:46 GMT
// server: Cowboy
// x-request-id: FiWSp_eQWrsrNeMAABTC
// Request duration: 0.052612s
```

It can also be accessed from the special endpoint for public activities:

``` {.restclient exports="both"}
GET http://localhost:4000/public
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix as: <https://www.w3.org/ns/activitystreams#> .

as:Public
    a ldp:BasicContainer, as:Collection ;
    ldp:member <urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA> ;
    as:items <urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA> .

<urn:erisx:AAAAAX3CRD27X2GTBX7ILUBK4QX2MHH57KQSQEWWG3NO7X4A5PSS6NISE4LRWEEFJDA6SLJTKFFS2KUPY2M5FXOHWGW2WRGUCBWLVT6WZZ4Q>
    a as:Note ;
    as:content "Hi! This is a public note." .

<urn:erisx:AAAABEB6W7PGNETW6HQ36XR5HT736RZNS4JFDLCZN7K42JGIC5HOT4L2WLQHLY2JUOIHJKDPL45NATIIQY2PQJUA7WQUJUN7JQ7ES3EDN6GA>
    a as:Create ;
    as:actor <http://localhost:4000/users/alice> ;
    as:object <urn:erisx:AAAAAX3CRD27X2GTBX7ILUBK4QX2MHH57KQSQEWWG3NO7X4A5PSS6NISE4LRWEEFJDA6SLJTKFFS2KUPY2M5FXOHWGW2WRGUCBWLVT6WZZ4Q> ;
    as:to as:Public .

// GET http://localhost:4000/public
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 1172
// content-type: text/turtle; charset=utf-8
// date: Mon, 27 Jul 2020 10:00:24 GMT
// server: Cowboy
// x-request-id: FiWSvy8HAmNfr7wAABlk
// Request duration: 0.477107s
```

Generality
==========

CPub has an understanding of what activities are (as defined in
ActivityStreams) and uses this understanding to figure out what to do
when you post something to an outbox.

Other than that, CPub is completely oblivious to what kind of data you
create, share or link to (as long as it is RDF).

Event
-----

For example we can create an event instead of a note (using the
schema.org vocabulary):

``` {.restclient exports="both"}
POST http://localhost:4000/users/alice/outbox
Authorization: Bearer RS6XZHOA5E5CWWXFXK7THURZ3DBGHT6XBO3QHHJUGOEOTMHLGXMQ
Accept: text/turtle
Content-type: text/turtle

@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix schema: <http://schema.org/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema> .

<>
    a as:Create ;
    as:to <http://localhost:4000/users/bob> ;
    as:object _:object .

_:object
    a schema:Event ;
    schema:name "My super cool event" ;
    schema:url "http://website-to-my-event" ;
    schema:startDate "2020-04-31T00:00:00+01:00"^^xsd:date ;
    schema:endDate "2020-05-02T00:00:00+01:00"^^xsd:date .

```

``` {.javascript org-language="js"}
// POST http://localhost:4000/users/alice/outbox
// HTTP/1.1 201 Created
// Location: http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAAZQTUAUZ3TFD72O4GZBOZPDWGL7U3MJ6NGLPHUV6UJUOJHIYBOATPDPE4GJJAR6HPUGPBSBEFQATY5FN6JBU4WAUZYZ5GAO6JZEOKTMQ
// cache-control: max-age=0, private, must-revalidate
// content-length: 0
// date: Mon, 27 Jul 2020 10:01:10 GMT
// server: Cowboy
// x-request-id: FiWSyek0P7vsgzYAAByi
// Request duration: 0.044583s
```

The activity:

``` {.restclient exports="both"}
GET http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAAZQTUAUZ3TFD72O4GZBOZPDWGL7U3MJ6NGLPHUV6UJUOJHIYBOATPDPE4GJJAR6HPUGPBSBEFQATY5FN6JBU4WAUZYZ5GAO6JZEOKTMQ
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix as: <https://www.w3.org/ns/activitystreams#> .

<urn:erisx:AAAAAZQTUAUZ3TFD72O4GZBOZPDWGL7U3MJ6NGLPHUV6UJUOJHIYBOATPDPE4GJJAR6HPUGPBSBEFQATY5FN6JBU4WAUZYZ5GAO6JZEOKTMQ>
    a as:Create ;
    as:actor <http://localhost:4000/users/alice> ;
    as:object <urn:erisx:AAAABZSRNIW5KYSVZN54JUIKR3V35BMU4DXZPFZFGQA4ZBTVQQLOMJRP2A4ICMRUSKKHGGE44JN7MDHNFDDBX3AEC2QO4CCKEGKN67JBWYOQ> ;
    as:to <http://localhost:4000/users/bob> .

// GET http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAAZQTUAUZ3TFD72O4GZBOZPDWGL7U3MJ6NGLPHUV6UJUOJHIYBOATPDPE4GJJAR6HPUGPBSBEFQATY5FN6JBU4WAUZYZ5GAO6JZEOKTMQ
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 685
// content-type: text/turtle; charset=utf-8
// date: Mon, 27 Jul 2020 10:01:27 GMT
// server: Cowboy
// x-request-id: FiWSzbYU-1XqS8oAAB6B
// Request duration: 0.016299s
```

And the event

``` {.restclient}
GET http://localhost:4000/objects?iri=urn:erisx:AAAABZSRNIW5KYSVZN54JUIKR3V35BMU4DXZPFZFGQA4ZBTVQQLOMJRP2A4ICMRUSKKHGGE44JN7MDHNFDDBX3AEC2QO4CCKEGKN67JBWYOQ
Accept: text/turtle
```

The event can be commented on, liked or shared, like any other
ActivityPub object.

Geo data
--------

It is also possible to post geospatial data. For example a geo-tagged
note:

``` {.restclient exports="both"}
POST http://localhost:4000/users/alice/outbox
Authorization: Bearer RS6XZHOA5E5CWWXFXK7THURZ3DBGHT6XBO3QHHJUGOEOTMHLGXMQ
Accept: text/turtle
Content-type: text/turtle

@prefix as: <https://www.w3.org/ns/activitystreams#> .
@prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .

<>
    a as:Create ;
    as:to <http://localhost:4000/users/bob> ;
    as:object _:object .

_:object
    a as:Note ;
    as:content "The water here is amazing!"@en ;
    geo:lat 46.794932821448725 ;
    geo:long 10.300304889678957 .

```

``` {.javascript org-language="js"}
// POST http://localhost:4000/users/alice/outbox
// HTTP/1.1 201 Created
// Location: http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAADFXIQY4LSBEQ7BBSFKPXO6D2Y7AYJ6ABAD2V4MHGL2USQKH5ZKC2VBATFJLS7JRHFAHTCGE7DSXEXWBPLODKDMOI2TLGPW2BGKX7G4A
// cache-control: max-age=0, private, must-revalidate
// content-length: 0
// date: Mon, 27 Jul 2020 10:03:34 GMT
// server: Cowboy
// x-request-id: FiWS68CX3xx2EY0AAB7h
// Request duration: 0.072037s
```

A geo-tagged note has been created:

``` {.restclient exports="both"}
GET http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAADFXIQY4LSBEQ7BBSFKPXO6D2Y7AYJ6ABAD2V4MHGL2USQKH5ZKC2VBATFJLS7JRHFAHTCGE7DSXEXWBPLODKDMOI2TLGPW2BGKX7G4A
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix as: <https://www.w3.org/ns/activitystreams#> .

<urn:erisx:AAAAADFXIQY4LSBEQ7BBSFKPXO6D2Y7AYJ6ABAD2V4MHGL2USQKH5ZKC2VBATFJLS7JRHFAHTCGE7DSXEXWBPLODKDMOI2TLGPW2BGKX7G4A>
    a as:Create ;
    as:actor <http://localhost:4000/users/alice> ;
    as:object <urn:erisx:AAAABILVVDOAGFEMM76LEU4LB63RPUG53DEMNGIHWTDZET5EE77KSA36IKYKIBWQ5I3MWRF6L3W3JZS74SLTIBJ2NATKIY4WY5MYY2T2GF6A> ;
    as:to <http://localhost:4000/users/bob> .

// GET http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAADFXIQY4LSBEQ7BBSFKPXO6D2Y7AYJ6ABAD2V4MHGL2USQKH5ZKC2VBATFJLS7JRHFAHTCGE7DSXEXWBPLODKDMOI2TLGPW2BGKX7G4A
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 685
// content-type: text/turtle; charset=utf-8
// date: Mon, 27 Jul 2020 10:03:52 GMT
// server: Cowboy
// x-request-id: FiWS7_FGi1eKdCIAAB8B
// Request duration: 0.011451s
```

``` {.restclient exports="both"}
GET http://localhost:4000/objects?iri=urn:erisx:AAAABILVVDOAGFEMM76LEU4LB63RPUG53DEMNGIHWTDZET5EE77KSA36IKYKIBWQ5I3MWRF6L3W3JZS74SLTIBJ2NATKIY4WY5MYY2T2GF6A
Accept: text/turtle
```

``` {.javascript org-language="js"}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix ldp: <http://www.w3.org/ns/ldp#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix as: <https://www.w3.org/ns/activitystreams#> .

<urn:erisx:AAAABILVVDOAGFEMM76LEU4LB63RPUG53DEMNGIHWTDZET5EE77KSA36IKYKIBWQ5I3MWRF6L3W3JZS74SLTIBJ2NATKIY4WY5MYY2T2GF6A>
    a as:Note ;
    <http://www.w3.org/2003/01/geo/wgs84_pos#lat> 46.794932821448725 ;
    <http://www.w3.org/2003/01/geo/wgs84_pos#long> 10.300304889678957 ;
    as:content "The water here is amazing!"@en .

// GET http://localhost:4000/objects?iri=urn:erisx:AAAABILVVDOAGFEMM76LEU4LB63RPUG53DEMNGIHWTDZET5EE77KSA36IKYKIBWQ5I3MWRF6L3W3JZS74SLTIBJ2NATKIY4WY5MYY2T2GF6A
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 641
// content-type: text/turtle; charset=utf-8
// date: Mon, 27 Jul 2020 10:04:46 GMT
// server: Cowboy
// x-request-id: FiWS_KG3uMIW4VoAAB9B
// Request duration: 0.018176s
```

A client that understands what `geo:lat` and `geo:long` means could show
this note on a map.

See [GeoPub](https://gitlab.com/miaEngiadina/geopub) for a client that
understands `geo:lat` and `geo:long`.

Serialization Formats
=====================

In the examples above we have used the RDF/Turtle serialization.

CPub supports following RDF serialization formats:

-   [RDF 1.1 Turtle](https://www.w3.org/TR/turtle/)
-   [RDF 1.1 JSON Alternate Serialization
    (RDF/JSON)](https://www.w3.org/TR/rdf-json/)

RDF/JSON
--------

To get content as RDF/JSON set the `Accept` header to
`application/rdf+json`

``` {.restclient exports="both"}
GET http://localhost:4000/users/alice
Accept: application/rdf+json
```

``` {.javascript org-language="js"}
{
  "http://localhost:4000/users/alice": {
    "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
      {
        "type": "uri",
        "value": "https://www.w3.org/ns/activitystreams#Person"
      }
    ],
    "http://www.w3.org/ns/ldp#inbox": [
      {
        "type": "uri",
        "value": "http://localhost:4000/users/alice/inbox"
      }
    ],
    "https://www.w3.org/ns/activitystreams#outbox": [
      {
        "type": "uri",
        "value": "http://localhost:4000/users/alice/outbox"
      }
    ],
    "https://www.w3.org/ns/activitystreams#preferredUsername": [
      {
        "type": "literal",
        "value": "alice"
      }
    ]
  }
}
// GET http://localhost:4000/users/alice
// HTTP/1.1 200 OK
// cache-control: max-age=0, private, must-revalidate
// content-length: 471
// content-type: application/rdf+json; charset=utf-8
// date: Fri, 11 Dec 2020 12:47:52 GMT
// server: Cowboy
// x-request-id: Fk9qo---djo78fcAAD7D
// Request duration: 0.184257s
```

Data can also be posted as RDF/JSON by setting `Content-type` header:

``` {.restclient exports="both"}
POST http://localhost:4000/users/alice/outbox
Authorization: Bearer RS6XZHOA5E5CWWXFXK7THURZ3DBGHT6XBO3QHHJUGOEOTMHLGXMQ
Content-type: application/rdf+json

{
  "_:object": {
    "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
      {
        "type": "uri",
        "value": "https://www.w3.org/ns/activitystreams#Note"
      }
    ],
    "https://www.w3.org/ns/activitystreams#content": [
      {
        "lang": "en",
        "type": "literal",
        "value": "Hi! This is RDF/JSON. It's ugly, but it's simple."
      }
    ]
  },
  "http://example.org": {
    "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
      {
        "type": "uri",
        "value": "https://www.w3.org/ns/activitystreams#Create"
      }
    ],
    "https://www.w3.org/ns/activitystreams#object": [
      {
        "type": "bnode",
        "value": "_:object"
      }
    ],
    "https://www.w3.org/ns/activitystreams#to": [
      {
        "type": "uri",
        "value": "http://localhost:4000/users/bob"
      }
    ]
  }
}
```

``` {.javascript org-language="js"}
// POST http://localhost:4000/users/alice/outbox
// HTTP/1.1 201 Created
// cache-control: max-age=0, private, must-revalidate
// content-length: 0
// date: Mon, 27 Jul 2020 10:29:24 GMT
// location: http://localhost:4000/objects?iri=urn%3Aerisx%3AAAAAB2UI566HXP3ZTEOTN7WLHZZFMKTAZEMV3ZWN6GCCJ7T53H2QVJKNPULT7OPMGZTDOEIORQNEME3UWGRKVNWW2WZQDFSMB4JKZI3KVTPA
// server: Cowboy
// x-request-id: FiWUV_M6dqt5o30AABuj
// Request duration: 0.368228s
```
