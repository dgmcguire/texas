exports.config = {
  files: {
    javascripts: {
      joinTo: {
        "js/vendor.js": /^node_modules/,
        "js/app.js": /^web\/static\/js/,
        "js/texas.js": /^web\/static\/js\/texas/
      }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"]
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },
  conventions: {
    assets: /^(web\/static\/assets)/
  },
  paths: {
    watched: [
      "web/static",
      "test/static"
    ],
    public: "priv/static"
  },
  plugins: {
    babel: {
      ignore: [/web\/static\/vendor/]
    }
  },
  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app", "web/static/js/texas/texas"]
    }
  },
  npm: {
    enabled: true
  }
};
