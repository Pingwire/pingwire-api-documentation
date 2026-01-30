Webhooks can be used to receive notifications about specific events from the Pingwire system. This is useful when you need to react to events triggered by our system that do not result from any direct API interaction.

Parameters regarding which events to subscribe to and how the events shall be delivered can be configured using our [webhook configurations endpoints](./#tag/Webhook-configurations). They can be used to configure:
- the webhook delivery URL
- the secret used to sign the delivered events (generated and managed by you)
- the timeout and retry policy to be used when delivering events
- which headers to use for events signatures and idempotency

### Webhook delivery signing
All events sent from the Pingwire system are signed so that their authenticity and integrity can be easily verified.

The secret provided when creating the webhook configuration will be used to sign the deliveries. The signature will be present in each delivery as an HTTP header which can be configured in the webhook configuration (default: X-Pingwire-Signature). The delivery will also have a timestamp which will be provided as an HTTP header as well (default X-Pingwire-Timestamp). The signature is a SHA256 HMAC hex digest of the concatenation of the delivery timestamp in unix format, a UTF-8 `.` character and the raw HTTP request body of the delivery.

To verify a webhook delivery follow the following steps:
- Extract the delivery timestamp from the correct header (default X-Pingwire-Timestamp). Check that the timestamp is within an acceptable time range (for example ± 5 min), if not reject the delivery. This is to prevent a malicious actor from replaying deliveries.
- Extract the signature from the correct header (default: X-Pingwire-Signature). The header value will always start with `sha256=`, the part after the `=` is the signature.
- Recreate the signature payload by concatenating the timestamp, a `.` and the delivery raw HTTP request body.
- Compute a SHA256 HMAC hex digest using the signature payload and the shared secret: `expected = HMAC_SHA256(secret, timestamp + "." + raw_body)`
- Compare the obtained signature with the one provided in the header. If they do not match reject the delivery.

### Idempotency

Webhook deliveries are sent with at-least-once semantics. Ordering is not guaranteed. The same event may be delivered multiple times and consumers must rely on idempotency.

Each webhook delivery includes an idempotency key in an HTTP header (default: `Idempotency-Key`). The value of this header is the unique event identifier.

The same idempotency key is reused across retries of the same event. Consumers are expected to use this key to safely deduplicate duplicate deliveries.
