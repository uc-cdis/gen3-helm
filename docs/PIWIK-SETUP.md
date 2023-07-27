## Piwik Tracker Setup Docs

Our piwik domain for our 3 aced-idp sites, development,staging, and production is located at: https://aced-idp.piwik.pro/

## Steps to setup Piwik Customized Data Portal

Clone data portal
```
git clone https://github.com/uc-cdis/data-portal.git
```

go to https://aced-idp.piwik.pro/administration/

add a site or app by click the green button on the bottom left of the screen. 

click on the new site and change the time zone to your local time zone.

Verify that the Site or app address matches the intended address

Click on installation -> install manuall.y

click copy to clipboard and paste that code block into a text editor

add a nonce value that effectively whitelists the script block that you are pasting into your 
local build of data-portal so that

```
<script type="text/javascript">
tag becomes:
<script type="text/javascript" nonce="you_nonce_string_here">
```
This step is done to comply with the Content Security Policy meta element that can be found in the data portal
source code as an extra measure of security to the website: https://github.com/uc-cdis/data-portal/blob/master/src/index.ejs#L15

More information about nonces can be found here: https://content-security-policy.com/nonce/

More general information about content security policies can be found here: https://blog.sucuri.net/2023/04/how-to-set-up-a-content-security-policy-csp-in-3-steps.html

Change tags.src in the script block to from
```
"https://aced-idp.containers.piwik.pro/"+id+".js"
 to:
https://aced-idp.piwik.pro/containers/your_piwik_site_id.js
```
This might not be neccessary but didn't test it without it

Insert this script block into the very beginning of the <body> element like  instructed in 
the installation tab of https://aced-idp.piwik.pro/administration/ when a specific site is selected

## Modify Content Security Policy:
Next you need to modify the content Security Policiy to match the nonce value that you specified in the script tag.
Alot of other changes were made that might not need to be made, but a working content security policy appears below:
```
    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://login.bionimbus.org https://aced-idp.piwik.pro https://wayf.incommonfederation.org; child-src blob:; img-src 'self' <%= htmlWebpackPlugin.options.imgSrc %> https://opendata.datacommons.io https://static.planx-pla.net data: https://*.s3.amazonaws.com blob:; script-src 'self' 'nonce-your_nonce_string_here' https://aced-idp.piwik.pro https://aced-idp.containers.piwik.pro/ppms.js 'unsafe-eval' <%= htmlWebpackPlugin.options.scriptSrc %>; worker-src 'self' blob:; style-src 'self' 'unsafe-inline' https://aced-idp.piwik.pro https://fonts.googleapis.com; object-src 'none'; font-src 'self' data: https://fonts.googleapis.com https://fonts.gstatic.com; connect-src 'self' https://login.bionimbus.org https://wayf.incommonfederation.org https://opendata.datacommons.io https://static.planx-pla.net https://aced-idp.containers.piwik.pro https://aced-idp.containers.piwik.pro/ppms.js https://aced-idp.piwik.pro <%= htmlWebpackPlugin.options.connectSrc %>; frame-src <%= htmlWebpackPlugin.options.connectSrc %> 'self' https://auspice.planx-pla.net https://auspice.pandemicresponsecommons.org https://*.quicksight.aws.amazon.com;">    
```
Make these changes on src/index.ejs and /dev.html and save.

It might not be neccesary to make changes to dev.html, but this has not been tested.

## build image, deploy and restart services.

To build and push an image:

```
docker login quay.io
docker build -t quay.io/ohsu-comp-bio/data-portal-prebuilt:analytics . --platform linux/amd64
docker push quay.io/ohsu-comp-bio/data-portal-prebuilt:analytics
```

Next, make sure you have helm setup and are applying the proper values.yaml file where the portal section
is uncommented specifically:

```
portal:
  image:
    # Default cdis data-portal image, requires webpack build
    # Prebuilt portal with custom gitops and data schema
     repository: quay.io/ohsu-comp-bio/data-portal-prebuilt
     pullPolicy: IfNotPresent
     tag: "analytics"
```
Make sure the tag in this case, "analytics" reflects that tag used in the build and push steps done prior

Make sure you have only one secrets folder in your directory structure and it is pointing to that values.yaml file.
if it isn't or you're juggling multiple kubectl environments a

```
ln -s Secrets.development Secrets
```

could be used to specifiy which secrets folder "Secrets" is pointing to

Next run
```
helm upgrade --install local ./helm/gen3 -f Secrets/values.yaml -f Secrets/user.yaml -f Secrets/fence-config.yaml
```

to update the service with this specified new docker image and then 

```
kubectl rollout restart deployment/portal-deployment
```

to restart the service.

## Verify Piwik Installation

To verify that Piwik installed correctly you can go to:
https://aced-idp.piwik.pro/analytics/#/YOUR_WEBSITE_ID_HERE/settings/debugger/

and refresh. If nothing pops up then it's probably broken and inspecting element and clicking on console will
likely tell you the error that your are facing.