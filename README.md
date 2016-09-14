# Texas

Texas is a library that writes javascritp so you don't have too.  Tightly coupled with [phoenix_ratchet](https://github.com/iamvery/phoenix_ratchet) to provide javascript boilerplate that will hijack specified forms to update in realtime over websockets rather than use http for request/response, full page reloads.

## Installation

You'll need two libraries, texas from the hex repos and texasjs from npm's repos.  Texas will handle the macro that writes our JS for us and texasjs will only pull in the dependencies for us. The config setup is a bit heavy - hopefully I can fix that in the near future.

  1. Add texas to your list of dependencies in `mix.exs`:

        def deps do
          [{
            ...,
            :texas, "~> 0.1.2",
            ...
          }]
        end

    then you can pull it down with `mix deps.get` or simply starting your phoenix server.

  2. Install texasjs with `npm install texasjs --save`.  This will bring in the virtual-dom related dependencies and save you the trouble of grabbing them one by one.  It doesn't actually do anything other than that.

  3. Texas is tightly coupled with phoenix_ratchet (at least for now), so lets configure our view layer to use it as our templating engine.  In `config/config.ex` throw this in there somewhere taking note that the last import declaration needs to stay at the bottom:

    ```
    config :phoenix, :template_engines,
      ratchet: Ratchet.Phoenix.Engine
    ```

  4. Now, in order to avoid tons of manual configuration, I like to configure brunch to append all texasjs files to a single file and load that up seperately from the rest of our applications javascript.  You will need a version of brunch later than 2.3 I think?  I don't know, I just make sure it's latest, which as of me typing this I'm using version `2.8.2`.  Phoenix `1.2.1` appears to install brunch `2.8.0` so you should be fine if you're using a newer version of phoenix.

```
  tip: I've included a brunch-config-example.js in the repo to compare
```

  inside `brunch-config.js`:

<img src="/images/brunch-diff.png" width="400">

  this is a diff of a default brunch-config and one with the added changes, note that the import bits are the declarations to give texas its own joinTo file and make sure node_modules are being pulled in  - I'm not sure why I have to make that vendor declaration because I believe it's supposed to happen like that by default, but this way works so /shrug - also important is to auto-require texas just like default auto-requires app

here's the diff in text so you can copy/paste xD

```
diff --git a/brunch-test.js b/brunch-config.js
index d2fe679..09ec8b2 100644
--- a/brunch-test.js
+++ b/brunch-config.js
@@ -2,7 +2,11 @@ exports.config = {
   // See http://brunch.io/#documentation for docs.
   files: {
     javascripts: {
-      joinTo: "js/app.js"
+      joinTo: {
+        "js/vendor.js": /^node_modules/,
+        "js/app.js": /^web\/static\/js/,
+        "js/texas.js": /^web\/static\/js\/texas/
+      }

       // To use a separate vendor.js bundle, specify two files path
       // http://brunch.io/docs/config#-files-
@@ -59,7 +63,7 @@ exports.config = {

   modules: {
     autoRequire: {
-      "js/app.js": ["web/static/js/app"]
+      "js/app.js": ["web/static/js/app", "web/static/js/texas"]
     }
   },
```

  5.  great! now when we compile (given we have a texas macro declared somewhere) all our boilerplate stuff will be written to `web/static/js/texas/` which brunch will compile everything in the texas directory into a texas.js file that by default will be located in `priv/static/js/` - so lets make sure we tell our html to serve that to our clients

  in `web/templates/layout/app.html.eex` lets make sure our newly compiled priv/static/js files are being served to the client.  At the bottom it should look something like this - taking note that order does matter here as dependencies of texas are located in vendor:

  ```
    <script src="<%= static_path(@conn, "/js/vendor.js") %>"></script>
    <script src="<%= static_path(@conn, "/js/texas.js") %>"></script>
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
  ```

  6. also important to mention is that the default `socket.js` file is expected to stay in the `web/static/js/` dir as texas is importing by relative file location.  This will likely change in the future with some config options I'm sure, and since you have access to all the `texas/` dir you can manually change the imports if you need too if you need to put socket.js somewhere else.
