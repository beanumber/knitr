library(testit)

# helper function to convert raw src to params list
read_params <- function(src) {
  lines <- strsplit(src, "\n")[[1]]
  knit_params(lines)
}


## test basic parameter parsing --------------------------------------------

params <- read_params('
---
params:
  a: 10
  b: 20
---
'
)
assert(params[[1]]$name == 'a')
assert(params[[1]]$value == 10)
assert(params[[2]]$name == 'b')
assert(params[[2]]$value == 20)

assert(identical(flatten_params(params), list(a = 10L, b = 20L)))

## test date custom type (these deprecated and here for backwards compt) --

params <- read_params('
---
params:
  start: !date 2015-01-01
  end: !datetime 2015-01-01 12:30:00
---
'
)
assert(params[[1]]$name == 'start')
assert('Date' %in% params[[1]]$class)
assert(params[[1]]$value == as.Date("2015-01-01"))
assert(params[[2]]$name == 'end')
assert('POSIXct' %in% params[[2]]$class)
assert(params[[2]]$value == as.POSIXct("2015-01-01 12:30:00", tz = "GMT"))


## test specifying value in sub-object and type at object level ------------

params <- read_params('
---
params:
  file1:
    value: data1.csv
---
'
)
assert(params[[1]]$name == 'file1')
assert(params[[1]]$value == 'data1.csv')


## test parameters with length(value) > 1 ----------------------------------

params <- read_params('
---
params:
  regions:
    value: [North, South]
---
'
)
assert(length(params[[1]]$value) == 2)
assert(params[[1]]$value[[2]] == 'South')


## test including additional parameter attributes --------------------------

params <- read_params('
---
params:
  regions:
    value: [North, South]
    choices: [North, South, East, West]
    label: "Select Regions"
---
'
)
assert(identical(params[[1]]$choices, c('North', 'South', 'East', 'West')))
assert(params[[1]]$label == "Select Regions")


## test y/Y/n/N ------------------------------------------------------------

params <- read_params('
---
params:
  x: 1
  y: 2
  z: 3
  n: 4
  Y: 5
  N: 6
---
'
)

assert(
  'y/Y/n/N are not converted to booleans',
  identical(unlist(lapply(params, `[[`, 'name')), c('x', 'y', 'z', 'n', 'Y', 'N'))
)


## test handling of expressions --------------------------------------------

params <- read_params('
---
params:
  today: !r Sys.Date()
  now: !expr Sys.time()
  x: 10
---
'
)
assert(!is.null(params[[1]]$expr))
assert('Date' %in% params[[1]]$class)
assert(params[[2]]$expr)
assert('POSIXct' %in% params[[2]]$class)
assert(is.null(params[[3]]$expr))






