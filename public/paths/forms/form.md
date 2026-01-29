## Introduction to forms

Forms can be used to collect information from the end user either manually or fully automated.

Forms are configured on demand by submitting a new specification to Pingwire. Once the form has been configured you will receive a `formId`. The `formId` is an identification for this specific form configuration which has been implemented. You will need the `formId` when using our API to automate the process of sending out forms.

A typical flow for this feature will look like this:
- Get notified that it is time to send a form to the end user, this can be based on any custom logic on your side. It can for example be as a reaction to a signal present in the recommendation from a request that was sent in to Pingwire.
- Call the [Get form link](#tag/Forms/paths/~1forms~1%7BformId%7D~1%7BentityId%7D~1link/get) endpoint to retrieve a unique link for that `formId` and end user
- Present the end user with that link through whichever setup is relevant (See the [Setups for presenting forms](#section/Setups-for-presenting-forms) section below for more details about the different options)
- Once the end user has filled in the form, continue with the rest of the end user journey
- Access the answers left by the end user either through API using the [Get form answer](#tag/Forms/paths/~1form-answers~1%7BformAnswerId%7D/get) endpoint or directly through the interface. Rules can be configured to use these answers in the interface.

## Setups for presenting forms

### Standalone

In the standalone setup, the form URL retrieved using the [Get form link](#tag/Forms/paths/~1forms~1%7BformId%7D~1%7BentityId%7D~1link/get) endpoint (or from the interface) can be used without modifications and sent to the end user in whichever way is relevant. It can for example be sent by email, text message or even be presented as a QR code for end users to scan.

When the end user finishes to fill in the form, the submitted answers will be saved, the end user is redirected to a "Thank you" page and invited to close their browser. At the moment it is not possible to get notified when a form has been submitted when using this setup.

This setup is particularly well adapted for manual sending out of forms or when the end user should fill in a form in isolation from any other end user journey.

### Redirect flow

In the redirect flow setup, the end user will be redirected to the form URL and after all their answers have been submitted they will be redirected back to a callback URL provided by you. This setup is adapted to be used as part of an existing end user journey where the form should be inserted as part of a unified and cohesive experience.

In order to use that setup, the end user should be sent to the URL retrieved using the [Get form link](#tag/Forms/paths/~1forms~1%7BformId%7D~1%7BentityId%7D~1link/get) endpoint after it has been extended to include information about the redirection setup. The browser of the end user should be redirected to that URL with the addition of the following query parameters:
- `redirectUrl`: The callback URL where the end user should be redirected to when the form is completed (or cancelled). For security reasons, redirectUrl must be whitelisted as part of the form setup. If you would like to update the redirect URL reach out to Pingwire to update the whitelist.
- `state`: Any information that represent the state of the end user journey where the form is inserted. The state will be sent back to the redirect URL which can then be used to resume the end user journey on your side wherever it got interrupted by the form. The state is not required to use the redirect setup but is strongly recommended.


When the end user is redirected to the callback URL, it will be done with several query parameters:
- `status`: Will always be present and can be one of the following values:
|Status|Description|
|------|-----------|
|`SUCCESS`|The form has been successfully submitted and the answers have been saved.|
|`CANCELLED`|The form has been interrupted by the end user who decided to not submit any answers.|
|`ERROR`|There has been a technical error of some sort and the end user was not able to submit any answers.|
- `state`: Will be present if a state was provided to the form URL as a query parameter. It will be exactly identical to that provided value.
- `formAnswerId`: Will only be present if the `status` is `SUCCESS`. This id can be used to retrieve the answers submitted by the end user using the [Get form answer](#tag/Form-answers/paths/~1form-answers~1%7BformAnswerId%7D/get) endpoint.
- `errorCode`: Will only be present if the `status` is `ERROR`. New code can be introduced at any time so the logic reading these codes should be able to handle an unexpected value. Unexpected values can be handled the same way as the code `unknown`. The possible values as of today are:
|Error code|Description|
|----------|-----------|
|`unknown` |The cause of the error is unknown. In that case it is best to consider the form service to be unavailable at that time and handle that failure accordingly.|

### Iframe

In the iframe setup, the iframe should be rendered with a query parameter `iframe=1`. An optional parameter `correlationId` can be used to identify several instances of our form iframes. To use this setup the parent origins must be allowed in our form configuration to prevent phishing.

If using Content Security Policy (CSP) the form origin should be allowed in `form-src`:
- https://form.pingwire.io on production
- https://form.staging.pingwire.io on staging

Schema of the `postMessage` events:
- `type`: one of the types describe in the table below.
- `correlationId`: optional, only used if specified in the iframe query params. Can be used to identify several instance of our form iframe.
- `payload`: described in table below as well. Schema based on the event type.

|Event type|Description|Payload schema|
|----------|-----------|--------------|
|`SUCCESS`|Message sent when the end user successfully submitted the form. Sent by the `iframe window`.| `formAnswerId`: id of the form answer document which can be used to fetch the customer’s answers from our API (same as for the redirect flow)|
|`CANCELLED`|Message sent when the end user cancel the form flow. Sent by the `iframe window`.| No payload|
|`ERROR`|Message sent when the end user encountered an error that is not recoverable. Sent by the `iframe window`.| `errorCode`: same as for the redirect flow.|
|`IFRAME_READY`|Message sent when the iframe has loaded and is ready to receive the `IFRAME_INIT` message. This message will be sent at regular interval until `IFRAME_INIT` is received. Sent by the `iframe window`.| No payload|
|`IFRAME_INIT`|Message sent by the parent window to trigger the parent origin verification and start displaying the content of the iframe. Should be sent after the iframe has emitted `IFRAME_READY`. Sent by the `host window`.| No payload|
|`IFRAME_ACK`|Message sent by the iframe after receiving `IFRAME_INIT` and after the parent origin has been validated. Sent by the `iframe window`.| No payload|

The iframe requires a handshake with the host window before rendering any useful content. This is as a security measure so that we can verify that the host window is one of the allowed parent origins. You can find below a code example of this handshake

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
  </head>
  <body>
    <div id="form-container"></div>

    <script>
      const formURL = 'https://form.pingwire.io/example/form/url'; // Form URL retrieved from the get form link endpoint
      const allowedFormOrigin = 'https://form.pingwire.io'; // Staging: https://form.staging.pingwire.io

      const correlationId = 'example-correlation-id'; // Optional unique correlation id for this iframe

      const container = document.getElementById('form-container');
      const iframeEl = document.createElement('iframe');
      iframeEl.id = 'form-iframe';
      iframeEl.src = `${formURL}?iframe=1&correlationId=${encodeURIComponent(correlationId)}`;
      container.appendChild(iframeEl);

      let initSent = false;
      let handshakeTimeout;

      window.addEventListener('message', function onMessage(event) {
        if (event.origin !== allowedFormOrigin) return;
        if (event.source !== iframeEl.contentWindow) return;

        const data = event.data;
        if (!data || typeof data !== 'object') return;
        if (data.correlationId && data.correlationId !== correlationId) return;

        switch (data.type) {
          case 'IFRAME_READY':
            if (iframeEl.contentWindow) {
              iframeEl.contentWindow.postMessage({ type: 'IFRAME_INIT', correlationId }, allowedFormOrigin);
              if (!initSent) {
                handshakeTimeout = setTimeout(function onTimeout() {
                  console.log(`Handshake timed out. Correlation ID: ${correlationId}`);
                }, 5000);
                initSent = true;
              }
            }
            break;
          case 'IFRAME_ACK':
            if (handshakeTimeout) clearTimeout(handshakeTimeout);
            break;
          case 'SUCCESS':
            console.log(`Form success fully submitted. Answers available from API using formAnswerId: ${data.payload.formAnswerId}. Correlation ID: ${data.correlationId}`);
            break;
          case 'ERROR':
            if (handshakeTimeout) clearTimeout(handshakeTimeout);
            console.log(`Error reported from form iframe with code: ${data.payload.errorCode}. Correlation ID: ${data.correlationId}`);
            break;
          case 'CANCELLED':
            if (handshakeTimeout) clearTimeout(handshakeTimeout);
            console.log(`User cancelled the form flow. Correlation ID: ${data.correlationId}`);
            break;
          default:
            break;
        }
      });
    </script>
  </body>
</html>
```