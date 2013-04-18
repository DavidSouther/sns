// Prepare node module loader to handle coffee
require("coffee-script");
// Load confuration data for the server
require("./config");
// Initialize the server
var sns = require("./server")
// Engage!
sns.serve();
