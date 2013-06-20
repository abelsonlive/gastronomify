#' A guacamole recipe from http://www.theyummylife.com/guacamole
#'
#' @return vector
#' @export
#' @examples
#' data.guacamole <- gastronomify(
#'   x = paste('Diet', ChickWeight$Diet),
#'   y = ChickWeight$weight,
#'   group = paste(ChickWeight$Time, 'days'),
#'   recipe = guacamole)
#' print(data.guacamole)
guacamole <- c(
  avocados =              4,   # ripe medium-size avocados; Haas recommended, if available
  garlic.powder.tsp =     1/2, # teaspoon garlic powder
  kosher.salt.tsp =       1/2, # teaspoon kosher salt
  black.pepper.tsp =      1/2, # teaspoon freshly ground black pepper
  # OPTIONAL ADDITIONS:   
  lime.juice.tbsp =       1,   # tablespoon fresh lime juice
  chopped.cilantro.cup  = 1/4, # cup chopped cilantro
  serranos              = 2,   # hot green chili (2 serranos or 2-3 jalapenos), finely diced
  small.white.onion     = 1/2, # finely diced
  medium.tomato         = 1    # deseeded & chopped in 1/4" pieces
)

#' A Fool's Gold Loaf recipe from http://en.wikipedia.org/wiki/Fool's_Gold_Loaf
#' 
#' @return vector
#' @export
fools.gold.loaf <- c(
  creamy.peanut.butter.jars = 1,
  grape.jelly.jars          = 1,
  bacon.pounds              = 1
)
