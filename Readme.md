Install
=======

    sudo gem install s3gb

make a ~/s3gb/config.yml file in your home folder.  
Enter your config: [Your S3 keys](https://www.amazon.com/ap/signin?openid.ns=http://specs.openid.net/auth/2.0&authCookies=1&openid.mode=checkid_setup&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select&openid.pape.max_auth_age=600&openid.return_to=https://www.amazon.com/gp/aws/ssop/handlers/auth-portal.html%3Fie%3DUTF8%26wreply%3Dhttps%253A%252F%252Faws-portal.amazon.com%252Fgp%252Faws%252Fdeveloper%252Faccount%252Findex.html%26awsrequestchallenge%3Dfalse%26wtrealm%3Durn%253Aaws%253AawsAccessKeyId%253A1QQFCEAYKJXP0J7S2T02%26wctx%3DactionpRmaccess-keypRm%26awsaccountstatuspolicy%3DP1%26wa%3Dwsignin1.0%26awsrequesttfa%3Dtrue&openid.assoc_handle=ssop&openid.pape.preferred_auth_policies=http://schemas.openid.net/pape/policies/2007/06/multi-factor-physical&openid.ns.pape=http://specs.openid.net/extensions/pape/1.0&accountStatusPolicy=P1&)
    bucket: s3gb
    accessKeyId: --your--key--
    secretAccessKey: --your--key--
    acl: private
    strategy: jgit
    cache: ~/.s3gb_cache
    sync:
      - ~/.ssh
      - ~/bin
      - /opt/nginx/conf/nginx.conf
      - ...
    exclude:
      - cache
      - Cache
      - .git

Then:

 - create the bucket using e.g. S3Fox AND add a .git folder to it
 - `sudo s3gb --install` to install dependencies for your chosen strategy
 - `s3gb --backup`
