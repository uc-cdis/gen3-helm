# Google login

You need to set up google credentials for google login as that's the default enabled option in fence. 

The following steps explain how to create credentials for your gen3

Go to the [Credentials page](https://console.developers.google.com/apis/credentials).

Click Create credentials > OAuth client ID.

Select the Web application application type.
Name your OAuth 2.0 client and click Create.

For `Authorized Javascript Origins` add `https://<hostname>`

For `"Authorized redirect URIs"` add  `https://<hostname>/user/login/google/login/` 

After configuration is complete, take note of the client ID that was created. You will need the client ID and client secret to complete the next steps. 