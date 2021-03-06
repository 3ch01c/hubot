proxy = require 'proxy-agent'
module.exports = (robot) ->
  HTTP_PROXY = process.env.http_proxy
  if HTTP_PROXY?
    robot.globalHttpOptions.httpAgent  = proxy(HTTP_PROXY, false)
  HTTPS_PROXY = process.env.https_proxy
  if HTTPS_PROXY?
    robot.globalHttpOptions.httpsAgent = proxy(HTTPS_PROXY, true)