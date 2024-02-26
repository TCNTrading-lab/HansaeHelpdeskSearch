module.exports = {
  apps : [
      {
        name: "helpdesksearch",
        script: "./bundle.js",
        watch: false,
        env: {
            "PORT": 3000,
            "NODE_ENV": "development"
        },
        env_production: {
            "PORT": 7085,
            "NODE_ENV": "production",
        }
      }
  ]

 
};
