#' @import XML RCurl

# Find the authenticity_token in the page.
auth.token <- function(text) {
  doc <- htmlParse(text, asText = TRUE)
  xpathApply(doc, '//input[@name="authenticity_token"]', xmlAttrs)[[1]]['value'][[1]]
}

# Set up the curl hadle.
handle <- function() {
  curl  <- getCurlHandle()
  agent <- 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
  curlSetOpt(cookiejar = "",  useragent = agent, followlocation = TRUE, curl = curl)
}

#' Submit a task to taskrabbit.
#'
#' @return character
#' @export
taskrabbit <- function(email, password, price, freeform.address, lng, lat, name, description, datetime = Sys.time()) {
  curl <- handle()
  text <- httpGET('https://www.taskrabbit.com/p/tasks/new', curl = curl)
  
  # Log in
  params <- list(
    utf8 = '✓',
    'authenticity_token' = auth.token(text),
    after_auth = '/p/tasks/new',
    'user_session[email]' = email,
    'user_session[password]' = password,
    commit = 'Log in'
  )
  text <- postForm('https://www.taskrabbit.com/user_session', .params = params, curl=curl)
  
  # Post task
  params <- list(
    'utf8' = '✓',
    'authenticity_token' = auth.token(text),
    'task[id]' = '',
    'task[name]' = name,
    'task[category_id]' = '999',
    'task[start_end]' = 'finish_by',
    'extra[datepicker]' = strftime(datetime, format = '%A %B %d'),
    'task[date]' = strftime(datetime, format = '%A %B %d'),
  # 'task[datetime]' = strftime(datetime, format = '%a %b %d %Y %H:%M:%S GMT%z (%Z)'),
    'task[datetime]' = strftime(datetime, format = '%a %b %d %Y %H:%M:%S GMT+0000 (GMT)'),
    'task[patron_flow]' = 'general',
    'task[time]' = '',
    'task[locations_attributes][0][freeform_address]' = freeform.address,
    'task[locations_attributes][0][lat]' = lat,
    'task[locations_attributes][0][lng]' = lng,
    'task[locations_attributes][0][parent_id]' = '',
    'task[locations_attributes][0][id]' = '',
    'task[review_runners]' = 'false',
    'task[named_price]' = price,
    'task[description]' = description
  )
  text <- postForm('https://www.taskrabbit.com/p/tasks', .params = params, curl=curl)
  doc <- htmlParse(text, asText = TRUE)
  href <- xpathApply(doc, '//h3[@class="eventTitle"][position()=1]/a', xmlAttrs)[[1]]['href'][[1]]
  list(
    html = text,
    href = href
  )
}
