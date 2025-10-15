This API uses OAuth as an authentication mechanism.

A Client ID and a Client Secret are required for authenticating. They can be retrieved from the interface by a user who has the relevant permissions.

The recommended flow for an optimized authentication is the following:
1. Call the [login endpoint](/#tag/Auth/operation/login) using the client id and client secret to retrieve an access token and a refresh token
    - Cache the access token and the refresh token on the client side for their respective validity time. The exact expiry dates of the tokens are returned by the login endpoint. The refresh token should be valid for significantly longer than the access token.
    - Use the access token to access protected endpoints. The access token should be provided as a Bearer token in the Authorization header: `Authorization: Bearer <access token>`
2. When the access token is expired and while the refresh token is still valid, call the [refresh token endpoint](/#tag/Auth/operation/RefreshToken) with the refresh token.
    - Cache the new access token on the client side for as long as it is valid. The exact expiry time is returned by the refresh token endpoint
    - Use the new access token to access protected endpoints.
3. When both the access token and the refresh token are expired then start the flow again from step 1.

The refresh token endpoint is to be prioritized over the login endpoint when a refresh token is available as it does not require the client ID and client secret to be sent again. The refresh token is less sensitive than the client ID and client secret as it is only valid for a limited period of time.
