// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

const channels = require.context('.', true, /_channel\.js$/)
channels.keys().forEach(channels)
window.liveSettings={api_key:"d9697d9b0f384c699944b913131835b6"}
