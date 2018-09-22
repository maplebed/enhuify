# Enhuify is a Rails app fronting a Hue light bulb

Light bulb can have the following set.

* hue (0-65535)
* saturation (0-255)
* brightness (0-255)

# Example use

After running `db:migrate` and `db:seed`, the following is a transcript of how you might interact with this server.

## Phase One — Basic Interactions

    $ curl localhost/bulb
    {"hue":1234,"saturation":255,"brightness":52}

    $ curl -X PUT localhost/bulb -H "Content-Type: application/json" -d '{"color":"orange"}'

    $ curl localhost/bulb
    {"hue":4915,"saturation":254,"brightness":254,"color":"orange"}%

## Phase Two — Request IDs

Enable returning request IDs.

    $ curl -H "x-trustme: puppies4eva" localhost/admin/toggle_return_ids
    {"return_ids":true}

Then repeat the same steps as above, note the new field, and that the request ID returned when issuing a `PUT` is then present in the resulting `GET` indicating that that request is in fact the one that changed the state.

    $ curl localhost/bulb
    {"hue":4915,"saturation":254,"brightness":254,"color":"orange","request_id":"d11ae0e5-4be4-40d1-927b-98ac8dea20c8"}

    $ curl -X PUT localhost/bulb -H "Content-Type: application/json" -d '{"color":"blue"}'
    {"request_id":"5e1ee9de-e784-4d4e-89a7-d69da0ffd1b7"}

    $ curl localhost/bulb
    {"hue":47000,"saturation":254,"brightness":254,"color":"blue","request_id":"5e1ee9de-e784-4d4e-89a7-d69da0ffd1b7"}

However, notice that if you issue two commands in quick succession and immediately fetch the state, the second command takes some time before it has happened.

    $ curl -X PUT localhost/bulb -H "Content-Type: application/json" -d '{"hue":12345, "saturation": 30, "brightness": 10}';
    {"request_id":"f1608698-6ff8-4bd2-9937-8ec9c7223b7d"}
    $ curl -X PUT localhost/bulb -H "Content-Type: application/json" -d '{"hue":55120, "saturation": 200, "brightness": 240}';
    {"request_id":"20888436-041f-4469-a6a3-1569f4d93488"}
    $ curl localhost/bulb
    {"hue":12345,"saturation":30,"brightness":10,"request_id":"f1608698-6ff8-4bd2-9937-8ec9c7223b7d"}
    $ curl localhost/bulb
    {"hue":55120,"saturation":200,"brightness":240,"request_id":"20888436-041f-4469-a6a3-1569f4d93488"}

Though the `PUT` returns immediately, there is some queuing before the command takes effect in order to give the light time to change state.

We introduce two new endpoints here to let you more easily understand the state of the light.

The `pending` endpoint gives you a list of currently outstanding change requests.

    $ for i in {1..4}; do curl -X PUT localhost/bulb -H "Content-Type: application/json" -d '{"hue":12345, "saturation": 30, "brightness": 10}'; done
    {"request_id":"44c2b57a-2698-4821-8164-4b8a57648777"}{"request_id":"fc700191-9953-4619-8ef0-f45eef6b2db8"}{"request_id":"4db9320a-12a9-45e9-aa89-f7bcecc01deb"}{"request_id":"ef0ebf44-d782-4e0f-baaa-1b185d51a659"}
    $ curl localhost/pending
    [{"id":738,"remote_id":"127.0.0.1","guid":"4db9320a-12a9-45e9-aa89-f7bcecc01deb","created_at":"2018-04-09T05:26:45.000Z","updated_at":"2018-04-09T05:26:45.000Z","action":"update","bulb_id":1,"hue":"12345","saturation":"30","brightness":"10","succeeded":false},{"id":739,"remote_id":"127.0.0.1","guid":"ef0ebf44-d782-4e0f-baaa-1b185d51a659","created_at":"2018-04-09T05:26:45.000Z","updated_at":"2018-04-09T05:26:45.000Z","action":"update","bulb_id":1,"hue":"12345","saturation":"30","brightness":"10","succeeded":false}]
    $ curl localhost/pending
    []

The `changes` endpoint gives you the most recent 50 changes to have succeeded.

    $ curl -s localhost/changes | jq '.[0]'
    {
      "id": 650,
      "remote_id": "127.0.0.1",
      "guid": "cd6b249a-9fb3-45e6-9935-06303050944a",
      "created_at": "2018-04-09T04:36:20.000Z",
      "updated_at": "2018-04-09T04:36:29.000Z",
      "action": "update",
      "bulb_id": 1,
      "hue": "3138",
      "saturation": "0",
      "brightness": "0",
      "succeeded": true
    }
    $ curl -s localhost/changes | jq '. | length'
    50

## Phase Three — Sharding

In order to reduce contention on the one bulb, we shard incoming requests by IP address - those that end with an odd number go to bulb 1 and those with even number go to bulb 2.

Enable sharding.

    $ curl -H "x-trustme: puppies4eva" localhost/admin/toggle_sharding
    {"allow_sharding":true}

Now, depending on your source IP, you'll get one of two bulbs.

But in order to properly observe the system we need to let our internal checks override the default shard selection, so all operaitons now support an `shard_override` parameter that takes "even" or "odd" as an argument.
