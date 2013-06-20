#' @docType package
#'
#' @import reshape2 plyr

# Inflate the variation
.inflate <- function(df, x) {
  as.data.frame(lapply(df, function(column) {
    mu.bar <- mean(column)
    sd.bar <- sd(column)
    sd <- sd.bar * x
    zscore <- (column - mu.bar) / sd.bar
    (zscore * sd) + mu.bar
  }))
}

#' Turn some data into food.
#'
#' @param x a factor; each level of the factor will correspond to a recipe
#' @param y a numerical response variable, used to weight the ingredients
#' @param group a factor used to map data to ingredients
#' @param recipe named vector where each name is an ingredient and each
#'   element is its quantity; its length must be the same as the number of
#'   levels in `group`
#' @return data.frame
#' @export
#' @examples
#'   fruit.salad = c(apples = 3, bananas = 1, cherries = 12, grapes = 14,
#'     kiwis = 2, lemons = 0.5, mangos = 1, nectarines = 2, oranges = 2,
#'     pineapples = 0.5, raspberries = 8, watermelons = 0.25)
#'   data.fruit.salad <- gastronomify(
#'     x = paste('Diet', ChickWeight$Diet),
#'     y = ChickWeight$weight,
#'     group = paste(ChickWeight$Time, 'days'),
#'     recipe = fruit.salad)
#' print(data.fruit.salad)
#' print(gastronomify(x = paste('vs', mtcars$vs), y = mtcars$mpg, group = paste('am', mtcars$am), recipe = c(flour = 2, water = 3)))
gastronomify <- function(x, y, group, data = NULL, recipe = guacamole, inflation = 10) {
  #
  # Check inputs
  #

  # Recipe names
  if (is.null(names(recipe))) {
    stop('Recipe must have ingredient names, not just quantities.')
  }

  # Handle the presence or lack of a data parameter.
  if (is.null(data)) {
    data.sliced = data.frame(
      x = x,
      y = y,
      group = group
    )
  } else {
    data.sliced = data[c(x, y, group)]
    colnames(data.sliced) <- c('x','y','group')
    data.sliced$x     <- paste(x,     data.sliced$x)
    data.sliced$group <- paste(group, data.sliced$group)
  }
  rm('data','x','y','group')

  # Recipe length
  n <- length(levels(factor(data.sliced$group)))
  if (n >= 1) {
    truncated.recipe <- recipe[1:n]
    rm('recipe')
  } else {
    stop('Recipe must have at least one ingredient.')
  }


  # Convert the data so that the central value is 1.
  data.normalized <- dcast(data.sliced, x ~ group, value.var = 'y', fun.aggregate = mean)
  data.normalized[-1] <- data.frame(lapply(data.normalized[-1], function(vec) { vec / mean(vec) }))

  # Make it look like a recipe.
  data.recipe <- ddply(data.normalized, 'x', function(df) {df[1,-1] * truncated.recipe})
  colnames(data.recipe)[-1] <- paste(names(truncated.recipe), ' (', colnames(data.recipe[-1]), ')', sep = '')

  # Inflate the variance
  data.recipe[-1] <- .inflate(data.recipe[-1], inflation)

  # Remove the x column
  rownames(data.recipe) <- data.recipe[,1]
  data.recipe <- data.recipe[-1]
}
